#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

struct cpu cpus[NCPU];

struct proc proc[NPROC];

struct proc *initproc;

int nextpid = 1;
struct spinlock pid_lock;

extern void forkret(void);
static void freeproc(struct proc *p);

extern char trampoline[]; // trampoline.S

// helps ensure that wakeups of wait()ing
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
  }
}

// initialize the proc table.
void procinit(void)
{
  struct proc *p;

  initlock(&pid_lock, "nextpid");
  initlock(&wait_lock, "wait_lock");
  for (p = proc; p < &proc[NPROC]; p++)
  {
    initlock(&p->lock, "proc");
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
  }
}

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
  int id = r_tp();
  return id;
}

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
  int id = cpuid();
  struct cpu *c = &cpus[id];
  return c;
}

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
  push_off();
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
  pop_off();
  return p;
}

int allocpid()
{
  int pid;

  acquire(&pid_lock);
  pid = nextpid;
  nextpid = nextpid + 1;
  release(&pid_lock);

  return pid;
}

// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc *
allocproc(void)
{
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
  {
    acquire(&p->lock);
    if (p->state == UNUSED)
    {
      goto found;
    }
    else
    {
      release(&p->lock);
    }
  }
  return 0;

found:
  p->pid = allocpid();
  p->state = USED;

  // Allocate a trapframe page.
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
  {
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
  if (p->pagetable == 0)
  {
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&p->context, 0, sizeof(p->context));
  p->context.ra = (uint64)forkret;
  p->context.sp = p->kstack + PGSIZE;
  p->rtime = 0;
  p->etime = 0;
  p->ctime = ticks;
  for (int i = 0; i < 32; i++)
  {
    p->syscall_count[i] = 0;
  }
  // p->priority = 0;
  // p->ticks = 0;
  // p->alarm_interval = 0;
  // p->ticks = 0;
  // p->alarm_handler = 0;
  // p->is_in_handler = 0;
  //////////
  // p->ticks = 0;
  // p->cur_ticks = 0;
  // p->alarm_on = 0;
  //////////
  // p->handler = 0;
  // p->alarm_tf = 0;
  p->tickets = 1; // By default, each process starts with 1 ticket.
  p->creation_time = ticks;
  p->priority_level = 0;
  p->count = 0;
  p->time_taken = 0;
  return p;
}

// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
  if (p->trapframe)
    kfree((void *)p->trapframe);
  p->trapframe = 0;
  if (p->pagetable)
    proc_freepagetable(p->pagetable, p->sz);
  p->pagetable = 0;
  p->sz = 0;
  // p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;
  p->chan = 0;
  p->killed = 0;
  p->xstate = 0;
  p->state = UNUSED;
}

// Create a user page table for a given process, with no user memory,
// but with trampoline and trapframe pages.
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
  if (pagetable == 0)
    return 0;

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
               (uint64)trampoline, PTE_R | PTE_X) < 0)
  {
    uvmfree(pagetable, 0);
    return 0;
  }

  // map the trapframe page just below the trampoline page, for
  // trampoline.S.
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
               (uint64)(p->trapframe), PTE_R | PTE_W) < 0)
  {
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}

// Free a process's page table, and free the
// physical memory it refers to.
void proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}

// a user program that calls exec("/init")
// assembled from ../user/initcode.S
// od -t xC ../user/initcode
uchar initcode[] = {
    0x17, 0x05, 0x00, 0x00, 0x13, 0x05, 0x45, 0x02,
    0x97, 0x05, 0x00, 0x00, 0x93, 0x85, 0x35, 0x02,
    0x93, 0x08, 0x70, 0x00, 0x73, 0x00, 0x00, 0x00,
    0x93, 0x08, 0x20, 0x00, 0x73, 0x00, 0x00, 0x00,
    0xef, 0xf0, 0x9f, 0xff, 0x2f, 0x69, 0x6e, 0x69,
    0x74, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00};

// Set up first user process.
void userinit(void)
{
  struct proc *p;

  p = allocproc();
  initproc = p;

  // allocate one user page and copy initcode's instructions
  // and data into it.
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
  p->sz = PGSIZE;

  // prepare for the very first "return" from kernel to user.
  p->trapframe->epc = 0;     // user program counter
  p->trapframe->sp = PGSIZE; // user stack pointer

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;

  release(&p->lock);
}

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int growproc(int n)
{
  uint64 sz;
  struct proc *p = myproc();

  sz = p->sz;
  if (n > 0)
  {
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    {
      return -1;
    }
  }
  else if (n < 0)
  {
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
  return 0;
}

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();

  // Allocate process.
  if ((np = allocproc()) == 0)
  {
    return -1;
  }

  // Copy user memory from parent to child.
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
  {
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;

  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;

  // increment reference counts on open file descriptors.
  for (i = 0; i < NOFILE; i++)
    if (p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);

  safestrcpy(np->name, p->name, sizeof(p->name));

  pid = np->pid;

  release(&np->lock);

  acquire(&wait_lock);
  np->parent = p;
  release(&wait_lock);

  acquire(&np->lock);
  np->state = RUNNABLE;
  release(&np->lock);

  return pid;
}

// Pass p's abandoned children to init.
// Caller must hold wait_lock.
void reparent(struct proc *p)
{
  struct proc *pp;

  for (pp = proc; pp < &proc[NPROC]; pp++)
  {
    if (pp->parent == p)
    {
      pp->parent = initproc;
      wakeup(initproc);
    }
  }
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().
void exit(int status)
{
  struct proc *p = myproc();

  if (p == initproc)
    panic("init exiting");

  // Close all open files.
  for (int fd = 0; fd < NOFILE; fd++)
  {
    if (p->ofile[fd])
    {
      struct file *f = p->ofile[fd];
      fileclose(f);
      p->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(p->cwd);
  end_op();
  p->cwd = 0;

  acquire(&wait_lock);

  // Give any children to init.
  reparent(p);

  // Parent might be sleeping in wait().
  wakeup(p->parent);

  acquire(&p->lock);

  p->xstate = status;
  p->state = ZOMBIE;
  p->etime = ticks;

  release(&wait_lock);

  // Jump into the scheduler, never to return.
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int wait(uint64 addr)
{
  struct proc *pp;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    for (pp = proc; pp < &proc[NPROC]; pp++)
    {
      if (pp->parent == p)
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&pp->lock);

        havekids = 1;
        if (pp->state == ZOMBIE)
        {
          // Found one.
          for (int i = 0; i < 32; i++)
          {
            p->syscall_count[i] += pp->syscall_count[i];
          }
          pid = pp->pid;
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
                                   sizeof(pp->xstate)) < 0)
          {
            release(&pp->lock);
            release(&wait_lock);
            return -1;
          }
          freeproc(pp);
          release(&pp->lock);
          release(&wait_lock);
          return pid;
        }
        release(&pp->lock);
      }
    }

    // No point waiting if we don't have any children.
    if (!havekids || killed(p))
    {
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
  }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.
// void scheduler(void)
// {
//   struct proc *p;
//   struct cpu *c = mycpu();

//   c->proc = 0;
//   for (;;)
//   {
//     // Avoid deadlock by ensuring that devices can interrupt.
//     intr_on();

//     for (p = proc; p < &proc[NPROC]; p++)
//     {
//       acquire(&p->lock);
//       if (p->state == RUNNABLE)
//       {
//         // Switch to chosen process.  It is the process's job
//         // to release its lock and then reacquire it
//         // before jumping back to us.
//         p->state = RUNNING;
//         c->proc = p;
//         swtch(&c->context, &p->context);

//         // Process is done running for now.
//         // It should have changed its p->state before coming back.
//         c->proc = 0;
//       }
//       release(&p->lock);
//     }
//   }
// }

#define RAND_MAX 0x7fffffff
static unsigned int next = 1;

// Linear Congruential Generator (LCG)
unsigned int rand(void)
{
  next = next * 1664525 + 1013904223;
  return (next % RAND_MAX);
}

// Function to seed the generator
void srand(unsigned int seed)
{
  next = seed;
}

void round_robin_scheduler(void)
{
  // printf("no bro\n");
  struct proc *p;
  struct cpu *c = mycpu();

  c->proc = 0;
  for (;;)
  {
    // Avoid deadlock by ensuring that devices can interrupt.
    intr_on();

    for (p = proc; p < &proc[NPROC]; p++)
    {
      acquire(&p->lock);
      if (p->state == RUNNABLE)
      {
        // Switch to chosen process.  It is the process's job
        // to release its lock and then reacquire it
        // before jumping back to us.
        p->state = RUNNING;
        c->proc = p;
        swtch(&c->context, &p->context);

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        c->proc = 0;
      }
      release(&p->lock);
    }
  }
}

void lottery_scheduler(void)
{
  // printf("yes\n");
  struct proc *p;
  int total_tickets = 0;
  struct cpu *c = mycpu();
  c->proc = 0;
  // Calculate total tickets for RUNNABLE processes
  for (p = proc; p < &proc[NPROC]; p++)
  {
    acquire(&p->lock);
    if (p->state == RUNNABLE)
    {
      total_tickets += p->tickets;
    }
    release(&p->lock);
  }

  if (total_tickets == 0)
    return; // No runnable processes

  int winning_ticket = rand() % total_tickets;
  int current_sum = 0;

  // Select the process holding the winning ticket
  for (p = proc; p < &proc[NPROC]; p++)
  {
    acquire(&p->lock);
    if (p->state == RUNNABLE)
    {
      current_sum += p->tickets;
      if (current_sum > winning_ticket)
      {
        p->state = RUNNING;
        c->proc = p;
        swtch(&c->context, &p->context);
        c->proc = 0;
        release(&p->lock);
        break;
      }
    }
    release(&p->lock);
  }
}

// void lottery_scheduler(void) {
//     struct proc *p;
//     int total_tickets = 0;
//     struct cpu *c = mycpu();
//     c->proc = 0;
//     struct proc *selected_proc = 0;
//     int current_sum = 0;

//     // First pass: Calculate total tickets for RUNNABLE processes
//     for (p = proc; p < &proc[NPROC]; p++) {
//         printf("Acquiring lock for process %d\n", p->pid);
//         acquire(&p->lock);  // Acquire lock to access process state and tickets
//         if (p->state == RUNNABLE) {
//             total_tickets += p->tickets;
//         }
//         printf("Releasing lock for process %d\n", p->pid);
//         release(&p->lock);  // Release lock after checking process
//     }

//     if (total_tickets == 0)
//         return; // No runnable processes, so return

//     // Randomly choose a ticket
//     int winning_ticket = rand() % total_tickets;

//     // Second pass: Select the process holding the winning ticket
//     for (p = proc; p < &proc[NPROC]; p++) {
//         printf("Acquiring lock for process %d\n", p->pid);
//         acquire(&p->lock);  // Acquire lock to safely access process data
//         if (p->state == RUNNABLE) {
//             current_sum += p->tickets;
//             if (current_sum > winning_ticket) {
//                 selected_proc = p; // Mark the process that "won" the lottery
//                 printf("Selected process %d\n", p->pid);
//                 release(&p->lock);  // Release the lock immediately after selecting
//                 break;  // Exit loop early after selecting process
//             }
//         }
//         printf("Releasing lock for process %d\n", p->pid);
//         release(&p->lock);  // Release the lock for this process
//     }

//     if (selected_proc == 0)
//         return;  // In case no process was selected, return (unlikely scenario)

//     // Third pass: Handle tie-breaking based on creation time (if needed)
//     for (p = proc; p < &proc[NPROC]; p++) {
//         if (p != selected_proc) {  // Avoid comparing the process to itself
//             printf("Acquiring lock for process %d\n", p->pid);
//             acquire(&p->lock);  // Acquire lock to check process
//             if (p->state == RUNNABLE && p->tickets == selected_proc->tickets && p->ctime < selected_proc->ctime) {
//                 selected_proc = p;  // Update to the older process if there's a tie
//                 printf("Tie-break selected process %d\n", p->pid);
//             }
//             printf("Releasing lock for process %d\n", p->pid);
//             release(&p->lock);  // Release lock after checking
//         }
//     }

//     // Finally, run the selected process
//     printf("Acquiring lock for selected process %d\n", selected_proc->pid);
//     acquire(&selected_proc->lock);  // Acquire lock before switching
//     if (selected_proc->state == RUNNABLE) {  // Check if still runnable
//         selected_proc->state = RUNNING;  // Set its state to RUNNING
//         c->proc = selected_proc;  // Set CPU's proc pointer
//         swtch(&c->context, &selected_proc->context);  // Perform the context switch
//         // The code below runs after the process finishes its time slice
//         c->proc = 0;  // Clear CPU process pointer after switching back
//     }
//     printf("Releasing lock for selected process %d\n", selected_proc->pid);
//     release(&selected_proc->lock);  // Release the lock for the selected process
// }

// int time_slice(int priority) {
//     switch (priority) {
//         case 0: return 1;
//         case 1: return 4;
//         case 2: return 8;
//         case 3: return 16;
//         default: return 1;
//     }
// }
//
// void mlfq_scheduler(void) {
//     struct proc *p;
//     struct proc *highest_priority_proc;
//     int highest_priority;
//     int boost_counter = 0;

//     for (;;) {
//         // Enable interrupts while scheduling
//         intr_on();

//         // Priority boosting logic: Boost all processes after BOOST_INTERVAL ticks
//         if (boost_counter >= 48) {
//             for (p = proc; p < &proc[NPROC]; p++) {

//                 if (p->state == RUNNABLE) {
//                     acquire(&p->lock);
//                     p->priority = 0;
//                     release(&p->lock);
//                      // Boost all processes to highest priority
//                 }
//             }
//             boost_counter = 0;
//         }

//         highest_priority = 3;  // Start with the lowest priority
//         highest_priority_proc = 0;  // No process selected yet

//         // Loop through the process table to find the highest priority RUNNABLE process
//         for (p = proc; p < &proc[NPROC]; p++) {
//             if (p->state == RUNNABLE && p->priority < highest_priority) {
//                 acquire(&p->lock);
//                 highest_priority = p->priority;
//                 highest_priority_proc = p;
//                 release(&p->lock);
//             }
//         }

//         // If a process with the highest priority is found, schedule it
//         if (highest_priority_proc != 0) {
//             p = highest_priority_proc;

//             // Switch to the selected process (context switch)
//             acquire(&p->lock);
//             // Switch to the selected process (context switch)
//             p->state = RUNNING;
//             swtch(&mycpu()->context, &p->context);
//             // Release the process lock after switching back
//             release(&p->lock);

//             // After process runs, check if it used its entire time slice
//             if (p->ticks >= time_slice(p->priority)) {
//                 // Lower the process's priority if it used its full time slice
//                 if (p->priority < 3) {
//                     p->priority++;  // Demote to the next lower priority
//                 }
//                 p->ticks = 0;  // Reset ticks after time slice is exhausted
//             }
//         }

//         boost_counter++;  // Increment the priority boost counter
//     }
// }

// int max_time_per_priority[4] = {1, 4, 8, 16};

// void mlfq_scheduler(void)
// {
//   struct cpu *c = mycpu();

//   c->proc = 0;
//   for (;;)
//   {
//     // Avoid deadlock by ensuring that devices can interrupt.
//     intr_on();
//     struct proc *p;
//     struct proc *high_priority_proc = 0;
//     for (p = proc; p < &proc[NPROC]; p++)
//     {
//       acquire(&p->lock);
//       if (p->state == RUNNABLE)
//       {
//         if (p->Waitticks > 48)
//         {
//           p->Waitticks = 0;
//           p->priority_level--;
//         }
//         if (p->time_taken >= max_time_per_priority[p->priority_level])
//         {
//           p->time_taken = 0;
//           if (p->priority_level < 3)
//           {
//             p->priority_level++;
//           }
//         }
//       }
//       release(&p->lock);
//     }
//     int i = 0;
//     for (p = proc; p < &proc[NPROC]; p++)
//     {
//       acquire(&p->lock);
//       if (p->state == RUNNABLE)
//       {
//         if (i == 0)
//         {
//           high_priority_proc = p;
//           i++;
//         }
//         else
//         {
//           if (high_priority_proc->priority_level > p->priority_level)
//           {
//             high_priority_proc = p;
//           }
//         }
//       }
//       release(&p->lock);
//     }
//     if (high_priority_proc != 0)
//     {
//       acquire(&high_priority_proc->lock);
//       high_priority_proc->state = RUNNING;
//       high_priority_proc->Waitticks = 0;
//       c->proc = high_priority_proc;
//       swtch(&c->context, &high_priority_proc->context);
//       c->proc = 0;
//       release(&high_priority_proc->lock);
//     }
//   }
// }

int max_time_per_priority[4] = {1, 4, 8, 16};

// void mlfq_scheduler(void)
// {
//   // printf("fuck");
//   struct cpu *c = mycpu();
//   c->proc = 0;

//   for (;;)
//   {
//     intr_on(); // Enable interrupts to avoid deadlock.
//     struct proc *p;
//     struct proc *high_priority_proc = 0;
//     // First loop: update process state and select the process to run
//     for (p = proc; p < &proc[NPROC]; p++)
//     {
//       acquire(&p->lock); // Acquire the lock first
//       if (p->state == RUNNABLE)
//       {
//         // printf("%d\n",boost_counter);
//         if (ticks % 60 == 0)
//         {
//           // printf("done\n");
//           p->time_taken = 0;
//           p->priority_level = 0;
//         }
//         // Priority demotion logic
//         if (p->time_taken >= max_time_per_priority[p->priority_level])
//         {
//           if (p->priority_level < 3)
//           {
//             p->time_taken = 0;
//             p->priority_level++; // Demote to lower priority
//           }
//           else if (p->priority_level == 3)
//           {
//             p->time_taken = 0;
//             p->count++;
//           }
//         }
//         // Select the highest-priority process (lowest level number)
//         if (high_priority_proc == 0)
//         {
//           high_priority_proc = p; // Select this process to run
//         }
//         else if (high_priority_proc->priority_level > p->priority_level)
//         {
//           high_priority_proc = p;
//         }

//         else if (high_priority_proc->priority_level == p->priority_level)
//         {
//           if (high_priority_proc->time_taken < p->time_taken)
//           {
//             high_priority_proc = p;
//           }
//         }
//       }
//       release(&p->lock); // Release the lock after checking/modifying the process
//     }
//     //int rec = high_priority_proc->priority_level;
//     // for (p = proc; p < &proc[NPROC]; p++)
//     // {
//     //   if (p->state != RUNNABLE) continue;
//     //   acquire(&p->lock);
//     //   if(p->priority_level == rec && high_priority_proc->time_taken < p->time_taken)
//     //   {
//     //     high_priority_proc = p;
//     //   }
//     //   release(&p->lock);
//     // }

//     // Second loop: schedule the selected process
//     if (high_priority_proc != 0)
//     {
//       acquire(&high_priority_proc->lock); // Acquire lock before running the process
//       if (high_priority_proc->state == RUNNABLE)
//       { // Re-check the state
//         high_priority_proc->count = 0;
//         high_priority_proc->state = RUNNING;
//         c->proc = high_priority_proc;
//         swtch(&c->context, &high_priority_proc->context); // Context switch
//         c->proc = 0;                                      // Clear CPU process pointer
//       }
//       release(&high_priority_proc->lock); // Release the lock after switching
//     }
//   }
// }

void mlfq_scheduler(void)
{
  // printf("fuck");
  struct cpu *c = mycpu();
  c->proc = 0;

  for (;;)
  {
    intr_on(); // Enable interrupts to avoid deadlock.
    struct proc *p;
    struct proc *high_priority_proc = 0;
    // First loop: update process state and select the process to run
    for (p = proc; p < &proc[NPROC]; p++)
    {
      acquire(&p->lock); // Acquire the lock first
      if (p->state == RUNNABLE)
      {
        // printf("%d\n",boost_counter);
        if (ticks % 48 == 0)
        {
          // printf("done\n");
          p->time_taken = 0;
          p->priority_level = 0;
        }
        // Priority demotion logic
        if (p->time_taken >= max_time_per_priority[p->priority_level])
        {
          if (p->priority_level < 3)
          {
            p->time_taken = 0;
            p->priority_level++; // Demote to lower priority
          }
          else if (p->priority_level == 3)
          {
            p->time_taken = 0;
            p->count++;
          }
        }
        // Select the highest-priority process (lowest level number)
        if (high_priority_proc == 0)
        {
          high_priority_proc = p; // Select this process to run
        }
        else if (high_priority_proc->priority_level > p->priority_level)
        {
          high_priority_proc = p;
        }

        else if (high_priority_proc->priority_level == p->priority_level)
        {
          if (high_priority_proc->time_taken < p->time_taken)
          {
            high_priority_proc = p;
          }
          // else if (high_priority_proc->count < p->count)
          // {
          //   high_priority_proc = p;
          // }
        }
      }
      release(&p->lock); // Release the lock after checking/modifying the process
    }

    // Second loop: schedule the selected process
    if (high_priority_proc != 0)
    {
      acquire(&high_priority_proc->lock); // Acquire lock before running the process
      if (high_priority_proc->state == RUNNABLE)
      { // Re-check the state
        high_priority_proc->count = 0;
        high_priority_proc->state = RUNNING;
        c->proc = high_priority_proc;
        swtch(&c->context, &high_priority_proc->context); // Context switch
        c->proc = 0;                                      // Clear CPU process pointer
      }
      release(&high_priority_proc->lock); // Release the lock after switching
    }
  }
}

void scheduler(void)
{
  // struct proc *p;

  for (;;)
  {
    // Enable interrupts on this processor.
    intr_on();

#if SCHEDULER == LBS
    lottery_scheduler();
#elif SCHEDULER == MLFQ
    mlfq_scheduler();
#else
    round_robin_scheduler();
#endif
  }
}

// Switch to scheduler.  Must hold only p->lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void sched(void)
{
  int intena;
  struct proc *p = myproc();

  if (!holding(&p->lock))
    panic("sched p->lock");
  if (mycpu()->noff != 1)
    panic("sched locks");
  if (p->state == RUNNING)
    panic("sched running");
  if (intr_get())
    panic("sched interruptible");

  intena = mycpu()->intena;
  swtch(&p->context, &mycpu()->context);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void yield(void)
{
  struct proc *p = myproc();
  acquire(&p->lock);
  p->state = RUNNABLE;
  sched();
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);

  if (first)
  {
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();

  // Must acquire p->lock in order to
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
  release(lk);

  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  release(&p->lock);
  acquire(lk);
}

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
      {
        p->state = RUNNABLE;
      }
      release(&p->lock);
    }
  }
}

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
  {
    acquire(&p->lock);
    if (p->pid == pid)
    {
      p->killed = 1;
      if (p->state == SLEEPING)
      {
        // Wake process from sleep().
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
  }
  return -1;
}

void setkilled(struct proc *p)
{
  acquire(&p->lock);
  p->killed = 1;
  release(&p->lock);
}

int killed(struct proc *p)
{
  int k;

  acquire(&p->lock);
  k = p->killed;
  release(&p->lock);
  return k;
}

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
  struct proc *p = myproc();
  if (user_dst)
  {
    return copyout(p->pagetable, dst, src, len);
  }
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
  struct proc *p = myproc();
  if (user_src)
  {
    return copyin(p->pagetable, dst, src, len);
  }
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
  static char *states[] = {
      [UNUSED] "unused",
      [USED] "used",
      [SLEEPING] "sleep ",
      [RUNNABLE] "runble",
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
  for (p = proc; p < &proc[NPROC]; p++)
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    printf("%d %s %s", p->pid, state, p->name);
    printf("\n");
  }
}

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    for (np = proc; np < &proc[NPROC]; np++)
    {
      if (np->parent == p)
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
        {
          // Found one.
          pid = np->pid;
          *rtime = np->rtime;
          *wtime = np->etime - np->ctime - np->rtime;
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
                                   sizeof(np->xstate)) < 0)
          {
            release(&np->lock);
            release(&wait_lock);
            return -1;
          }
          freeproc(np);
          release(&np->lock);
          release(&wait_lock);
          return pid;
        }
        release(&np->lock);
      }
    }

    // No point waiting if we don't have any children.
    if (!havekids || p->killed)
    {
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
  }
}

void update_time()
{
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    {
      p->rtime++;
    }
    // if (p->state != UNUSED)
    // {
    //   if (p->state == RUNNING || p->state == RUNNABLE)
    //   {
    //     printf("(%d,%d,%d,%d),\n", p->pid, p->priority_level, ticks, p->state);
    //   }
    // }
    // if (p->pid > 3)
    // {
    //   printf("pid: %d,queue: %d,ticks: %d\n", p->pid, p->priority_level, ticks);
    // }
    release(&p->lock);
  }
}