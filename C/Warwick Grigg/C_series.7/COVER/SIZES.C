
#include <stdio.h>

main()
{
     printf("\n");
     printf("Type            Size in bytes\n");
     printf("--------------  -------------\n");
     printf("char            %d\n", sizeof(char));
     printf("unsigned char   %d\n", sizeof(unsigned char));
     printf("short           %d\n", sizeof(short));
     printf("unsigned short  %d\n", sizeof(unsigned short));
     printf("int             %d\n", sizeof(int));
     printf("unsigned int    %d\n", sizeof(unsigned int));
     printf("long            %d\n", sizeof(long));
     printf("unsigned long   %d\n", sizeof(unsigned long));
     printf("float           %d\n", sizeof(float));
     printf("double          %d\n", sizeof(double));
     printf("char *          %d\n", sizeof(char *));

     return 0;
}
