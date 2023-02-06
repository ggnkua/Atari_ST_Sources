#include <INPUT.H>
#include <stdio.h>

int main(int argc, char *argv[])
{
    while (1)
        if (CheckInputStatus() < 0)
            printf("%d\n", ReadCharNoEcho());
    return 0;
}
