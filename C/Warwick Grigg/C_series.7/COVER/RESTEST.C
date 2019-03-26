
#include <osbind.h>
#include <stdio.h>

main()
{
    switch (Getrez()) {

    case 0:
        printf("Low resolution\n");
        break;

    case 1:
        printf("Medium resolution\n");
        break;

    case 2:
        printf("High resolution\n");
        break;

    default:
        printf("What? Not low, medium nor high resolution!\n");

    }

    getchar();
}
