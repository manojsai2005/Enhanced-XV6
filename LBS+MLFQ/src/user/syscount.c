// user/syscount.c
#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"




int get_syscall_index(int mask)
{
    int index = 0;
    while (mask > 1)
    {
        mask >>= 1; // Shift the mask right to check the next bit
        index++;
    }
    return index;
}

int main(int argc, char *argv[])
{
    if (argc < 3)
    {
        printf("Usage: syscount <mask> <command> [args]\n");
        exit(1);
    }

    // Convert the mask from the user input
    int mask = atoi(argv[1]);
    if (mask <= 0 || (mask & (mask - 1)) != 0)
    { // Ensure mask is a power of 2
        printf("Error: Invalid mask (must be a power of 2)\n");
        exit(1);
    }


    // Get the syscall index from the mask
    int syscall_index = get_syscall_index(mask);

    int pid = fork();
    if (pid < 0)
    {
        printf("Error: fork failed\n");
        exit(1);
    }

    if (pid == 0)
    {
        // In child process, run the command
        exec(argv[2], &argv[2]); // Exec the command with its arguments
        printf("Error: exec failed\n");
        exit(1);
    }
    else
    {
        // In parent process, wait for the child to exit
        int status;
        wait(&status);

        // After the command has run, get the system call count based on the mask
        int count = getSysCount(pid, syscall_index);
        if (count >= 0)
        {
            printf("PID %d called syscall %d (%d times)\n", pid, syscall_index, count);
        }
        else
        {
            printf("Error getting syscall count\n");
        }
    }

    exit(0);
}
