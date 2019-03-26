
#include <stdio.h>

main()    /* reads digit string and returns value of it */
{
     int c, result, signed;

     signed = 0;
     result = 0;
     c = getchar();

     while (c=='-') {    /* process leading minus signs */
          signed = !signed;
          c = getchar();
     }
     while (c != EOF) {
          if (c<'0' || c>'9')
               break;
          result = result*10 + c - '0';
          c = getchar();
     }
     if (signed)
          exit(-result);
     exit(result);
}
