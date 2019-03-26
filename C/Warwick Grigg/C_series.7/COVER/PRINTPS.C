
#include <stdio.h>

main(argc, argv)
int argc;
char *argv[];
{
     int i;

     printf("There are %d arguments\n", argc);

     for (i=0; i<argc; i++) {
          printf("Argument %d is %s\n", i, argv[i]);
     }

     getchar();
}
