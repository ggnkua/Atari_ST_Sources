/***************************************************************************/
/*                                                                         */
/*  The Dhampstone Benchmark.  Written by Jack Purdum.   Ver. 1.0          */
/*       Adapted for GST C by Arick Anders and Michael Bendio.             */
/*                                                                         */
/*  START magazine, Fall 1986.                                             */
/*                                                                         */
/*  The Dhampstone benchmark was first published in Computer Languages     */
/*       February 1985.  It is used here by permission.                    */
/*                                                                         */
/***************************************************************************/
        /*        version 1.0, August 1, 1985                       */

#include <stdio.h>

#define FIB         24
#define TINY        100
#define MAXINT      179
#define LITTLE      1000
#define SMALL       9000
#define FILENAME    "zyxw.vut"
#define NUMTEST     5

#define HOURS       4
#define MINUTES     5
#define SECONDS     6

#define void int

       int      cresult;
       int      iresult;
       int      cprsult;
       unsigned uresult;
       long     lresult;

       long       j;                 /* gst doesn't  support statics */
       long dummy=1;

       main()
       {
           char buf1[TINY], buf2[TINY];
           int i = 0;
           long square, t, t2, keystroke;

           while ( keystroke = poll(dummy) ); /* clear keyboard buffer */
           printf("Start...\n\n");

           while (i < NUMTEST) {
              switch(i) {
                 case (0):                             /* Character test  */
                   t  = time();                   
                   cresult = stest(buf1, buf2);
                   t2 = time();
                   printf("\ncharacter result = %d\n", cresult);
                   printf("the time was = %d seconds\n", t2-t);
                   break;
                 case (1):
                   t  = time();                   
                   iresult = intest();         /* Integer test    */
                   t2 = time();
                   printf("\ninteger result = %d\n", iresult);
                   printf("the time was = %d seconds\n", t2-t);
                   break;
                 case (2):
                   t  = time();                   
                   uresult = fib(FIB);         /* Unsigned test   */
                   t2 = time();
                   printf("\nfibonacci result = %u\n", uresult);
                   printf("the time was = %d seconds\n", t2-t);
                   break;
                 case (3):
                   square = 0;                 /* Long test       */
                   t  = time();                   
                   lresult = sq(square);
                   square = sq(lresult);       /* Check the value */
                   t2 = time();
                   printf("\nlong result = %d\n", lresult);
                   printf("square = %d\n", square);
                   printf("the time was = %d seconds\n", t2-t);
                   break;
                 case (4):
                   t  = time();
                   cprsult = mcopy();          /* Disk copy      */
                   t2 = time();
                   printf("\nfile copy = %d\n", cprsult);
                   printf("the time was = %d seconds\n", t2-t);
                   break;
                 default:
                   break;
              }
              i++;
           }                                            /* End while i    */
           printf("\n\n...End");
           dummy = getchar();
        }

stest(b1, b2)      /* String test using strcpy() and strcmp() */
char *b1, *b2;
        {
            int i, j;

            for (i = 0, j = 0; i < SMALL; ++i) {
                mstrcpy(b1, "0123456789abcdef");
                mstrcpy(b2, "0123456789abcdee");   /* Note it's a */
                j += mstrcmp(b1, b2);              /* different string */
            }

            return (j);
        }

mstrcmp(c, d)                /* External string compare */
char *c, *d;
        {
            while (*c == *d) {
                  if (!*c)
                     return (0);
                  ++c;
                  ++d;
           }
           return (*c - *d);
        }

mstrcpy(c, d)       /* External string copy */
char *c, *d;
        {
            while (*c++ = *d++)
                     ;
        }

intest()            /* Square an integer by iteration */
        {
                int i, j, k, sum;

                for (i = 0; i < LITTLE; ++i) {
                        sum = 0;
                        for (j = 0, k = 1; j < MAXINT; ++j) {
                                sum += k;
                                k += 2;
                        }
                }
                return (sum);
        }

sq(big)          /* Function to square a number by iteration */
long big;
        {
            int i;
            j = 1;

            if (!big)
               for (i = 0; i < SMALL; ++i) {
                   big += j;
                   j += 2;
               }
            else
                for (i = 0; i < SMALL; ++i) {
                    j -= 2;
                    big -= j;
                }
            return (big);
        }


fib(x)          /* Common Fibonacci function */
int x;
        {
            if (x > 2)
                return ( fib(x -1) + fib(x - 2));
            else
                return (1);
        }


mcopy()         /* Disk copy. Test assumes file doesn't exist */
        {
            FILE *fp;
            char buf[TINY];
            int i, j;

            mstrcpy(buf, "Disk I/O test");

            if ((fp = fopen(FILENAME, "w")) == NULL) {
               printf("Cannot open file");
               exit(-1);
            }

            i = 0;

            while (++i < LITTLE)
                  for (j = 0; buf[j]; ++j)
                      putc(buf[j], fp);

            fclose(fp);
            return (i);
        }


time()
{
int datetime[7];

date(dummy, datetime);
return( datetime[HOURS]*3600 + datetime[MINUTES]*60 + datetime[SECONDS] );
}

