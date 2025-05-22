#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
  return 0; // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if (growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  acquire(&tickslock);
  ticks0 = ticks;
  while (ticks - ticks0 < n)
  {
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_waitx(void)
{
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
  argaddr(1, &addr1); // user virtual memory
  argaddr(2, &addr2);
  int ret = waitx(addr, &wtime, &rtime);
  struct proc *p = myproc();
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    return -1;
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    return -1;
  return ret;
}

uint64 sys_getSysCount(void)
{
  int pid;
  int syscall_num;

  argint(0, &pid);
  argint(1, &syscall_num);

  struct proc *p;
  // Find the process with the specified pid
  for (p = proc; p < &proc[NPROC]; p++)
  {
    if (p->pid == pid)
    {
      return p->syscall_count[syscall_num]; // Return the syscall count
    }
  }
  return -1; // Process not found
}

uint64
sys_sigalarm(void)
{
  // current process
  struct proc* p = myproc();
  int period;
  argint(0, &period);
  argaddr(1, &p->handler_function);

  p->period = period;
  p->left_ticks = period;
  p->in_handlefunc = 0;

  return 0;
}

uint64
sys_sigreturn(void)
{
  struct proc* p = myproc();

  if(p->in_handlefunc && p->tf_stored){

    // restoring the original trapframe of the process, freeing the kalloced page.
    memmove(p->trapframe, p->tf_stored, PGSIZE);
    kfree(p->tf_stored);
    
    //printf("%p", p->trapframe->a0);
    p->left_ticks = p->period;
    p->in_handlefunc = 0;
  }
  
  return 0;
}


uint64 sys_settickets(void)
{
  int n;
  argint(0, &n);

  if (n < 1) // Ensure the number of tickets is valid
    return -1;

  myproc()->tickets = n; // Set the number of tickets for the current process
  return 0;
}