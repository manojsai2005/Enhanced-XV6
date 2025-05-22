# xv6

## syscount
    firstly I have created a syscount[] array in the proc.h and then initialising it in the allocproc in proc.c

    for making a new syscall we should add in syscall.c and syscall.h,also we will extern the function getsyscount in the sysproc.c and  also written the the function of the syscall is written in syspro.c
    now I am incresing the count of a syscall in the array in the syscall function of syscall.c

    here I am also adding the child processes count in the function wait in proc.c to the syscall count of parent 

## sigalarm and sigreturn
    initialsing a syscall is same as the above

    I have added 5 the following in the struct proc in the proc.h

    struct trapframe *tf_stored;
    int period;
    uint64 handler_function;
    uint left_ticks;
    uchar in_handlefunc;

    handler_function -> the function pointer that handle sigalarm
    in_handlefunc -> indicates that it is running inside the handle function or not 
    left_ticks -> more ticks needed for going into handler function
    tf_stored -> used for storing tf which is then restored into cpu proc

    written the both functions in sysproc.c and I have implimented the tickets_left logic in the usertrap function of trap.c

    for sigreturn
    I am restoring the before stored tf and setting the in_handlefunc to 0

## LBS scheduler

    firstly makefile is changed to handle the extra input of scheduler type given

    added the below 2 in proc.h

    int tickets;
    uint64 creation_time;

    tickets is initialising generally to 1 if used settickets syscall then the given number of tickets are given to the process

    creation_time to compare when we obtain the tickets of the final process and will again see if there is any process with same tickets count and less creation_time

    for this I am using LCG random function

    this random function gives a random number between the 1 and total ticket count and then we will find the process with refered by the random number (not exactly the same as random number but some logic to find it)

    Process 9 finished
    Process 7 finished
    Process 6 finished
    Process 5 finished
    Process 8 finished
    Process 4 finished
    Process 2 finished
    Process 0 finished
    Process 1 finished
    Process 3 finished
    Average rtime 10,  wtime 140

    when all the priorities are same then it will be same as FCFS

## MLFQ 

    int priority_level;
    int time_taken;
    int count;

    I have added the above in the proc.h

    priority_level -> store the queue level of the process
    time_taken -> the time for which process is ran
    count -> used this flag for implimenting roundrobin in the final queue

    I have implimented the specifications given in the document some in proc.c and some in trap.c

    Process 5 finished
    Process 6 finished
    Process 7 finished
    Process 8 finished
    Process 9 finished
    Process 0 finished
    Process 1 finished
    Process 2 finished
    Process 3 finished
    Process 4 finished
    Average rtime 11,  wtime 136

    here I didn't used queues but just build the logic with the p->priority_level which apparently represents the queuelevel that process is in

## comparing 

    finally in the  schedulers, on avg from the values I got the LBS and MLFQ doesn't differ much but in most cases LBS is taking less wtime than MLFQ (but it is not constant as in the above result I kept is different)

## What is the implication of adding the arrival time in the lottery based scheduling policy?

    when the no.of tickets is same for two process then we are running based on creation_time

    also it adds some fairness as it gives a process which comes first with same tickets count

## What happens if all processes have the same number of tickets?

    when the priority of all processes are same then FCFS occurs

## Are there any pitfalls to watch out for? 

    here are some pitfalls :

        Processes with few tickets may rarely get a chance to run.(Starvation risk)

        Dynamically adjusting tickets based on process behavior can be difficult.

        Random selection can cause inconsistent behavior, making performance hard to predict.

        LBS can't guarantee deadlines for time-critical processes.

