/***************************************************************************/
/*                                                                         */
/*  The Dhampstone Benchmark.  Written by Jack Purdum.   Ver. 1.1          */
/*        Adapted for Alcyon C by Arick Anders and Michael Bendio.         */
/*                                                                         */
/*  START magazine, Fall 1986.                                             */
/*                                                                         */
/*  The Dhampstone benchmark was first published in Computer Languages     */
/*       February 1985.  It is used here by permission.                    */
/*                                                                         */
/***************************************************************************/
        /*        version 1.1, June 13, 1986                        */

#include <stdio.h>

#define FIB         24
#define TINY        100
#define MAXINT      179
#define LITTLE      1000
#define SMALL       9000
#define PRECISION   .000001
#define FILENAME    "zyxw.vut"
#define NUMTEST     6

#ifndef ERR
#define ERR     -1
#endif
#ifndef void
#define void int
#endif

        struct {
               int      cresult;
               int      iresult;
               int      cprsult;
               unsigned uresult;
               long     lresult;
               double   dresult;
               } results;


/* timing stuff */
#include <osbind.h>
#define Supexec(a) xbios(38, a)
 
long *ptr, *_vbclock = (long *)0x462;

gettime()
{
     *ptr = *_vbclock;
}
/* end of timing stuff */

        main()
        {
           char buf1[TINY], buf2[TINY];
           int i = 0;
           unsigned fib();
           long square, sq(), t, t2;
           double dmath, sroot(), dply();

           printf("Start...\n\n");

           while (i < NUMTEST) {
              switch(i) {
                 case (0):                             /* Character test  */
                   ptr = &t;
                   Supexec(gettime);
                   ptr = &t2;
                   results.cresult = stest(buf1, buf2);
                   Supexec(gettime);
                   printf("\ncresult = %d\n", results.cresult);
                   printf("Took %0.2f seconds\n", (float)(t2-t)/(Getrez() == 2 ? 70 : 60));
                   break;
                 case (1):
                   ptr = &t;
                   Supexec(gettime);
                   ptr = &t2;
                   results.iresult = intest();         /* Integer test    */
                   Supexec(gettime);
                   printf("\niresult = %d\n", results.iresult);
                   printf("Took %0.2f seconds\n", (float)(t2-t)/(Getrez() == 2 ? 70 : 60));
                   break;
                 case (2):
                   ptr = &t;
                   Supexec(gettime);
                   ptr = &t2;
                   results.uresult = fib(FIB);         /* Unsigned test   */
                   Supexec(gettime);
                   printf("\nuresult = %u\n", results.uresult);
                   printf("Took %0.2f seconds\n", (float)(t2-t)/(Getrez() == 2 ? 70 : 60));
                   break;
                 case (3):
                   square = 0L;                        /* Long test       */
                   ptr = &t;
                   Supexec(gettime);
                   ptr = &t2;
                   results.lresult = sq(square);
                   square = sq(results.lresult);       /* Check the value */
                   Supexec(gettime);
                   printf("\nlresult = %ld", results.lresult);
                   printf("\n square = %ld\n", square);
                   printf("Took %0.2f seconds\n", (float)(t2-t)/(Getrez() == 2 ? 70 : 60));
                   break;
                 case (4):                              /* Double test    */
                   ptr = &t;
                   Supexec(gettime);
                   ptr = &t2;
                   results.dresult = sroot((double) results.lresult);
                   dmath = dply(results.dresult);
                   Supexec(gettime);
                   printf("\ndresult = %f\n", results.dresult);
                   printf("  dmath = %f\n", dmath);
                   printf("Took %0.2f seconds\n", (float)(t2-t)/(Getrez() == 2 ? 70 : 60));
                   break;
                 case (5):
                   ptr = &t;
                   Supexec(gettime);
                   ptr = &t2;
                   results.cprsult = mcopy();           /* Disk copy      */
                   Supexec(gettime);
                   printf("\n   copy = %d\n", results.cprsult);
                   printf("Took %0.2f seconds\n", (float)(t2-t)/(Getrez() == 2 ? 70 : 60));
                   break;
                 default:
                   break;
              }
              ++i;
           }                                            /* End while i    */
           printf("\n\n...End\n");
           printf("Type Return to Continue\n");
           getchar();
        }

        long sq(big)          /* Function to square a number by iteration */
        long big;
        {
            int i;
            static long j = 1L;

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

        double sroot(num)                /* Find square root of number */
        double num;
        {
            double temp1, temp2, _abs();

            temp2 = num / 2.0;
            temp1 = num;

            while (temp1 > PRECISION * temp2) {
                      temp1 = (num / temp2) - temp2;
                      temp1 = abs(temp1);
                      temp2 = ((num / temp2) + temp2) / 2.0;
            }
            return (temp2);
        }

        double _abs(x)                    /* Absolute value of a double */
        double x;
        {
            return (x < 0 ? -x : x);
        }
        double dply(x)                   /* Exercise some doubles */
        double x;
        {
            int i = TINY;
            double y;

            while (i--) {
                     y = x * x * x * x * x * x * x;
                     y = y / x / x / x / x / x / x;

                     y = y + x + x + x + x + x + x;
                     y = y - x - x - x - x - x - x;
             }

            return (y);
        }

        unsigned fib(x)          /* Common Fibonacci function */
        int x;
        {
            if (x > 2)
                return ( fib(x -1) + fib(x - 2));
            else
                return (1);
        }

        int stest(b1, b2)      /* String test using strcpy() and strcmp() */
        char *b1, *b2;
        {
            int i, j;
            void mstrcpy();

            for (i = 0, j = 0; i < SMALL; ++i) {
                mstrcpy(b1, "0123456789abcdef");
                mstrcpy(b2, "0123456789abcdee");   /* Note it's a */
                j += mstrcmp(b1, b2);              /* different string */
            }

            return (j);
        }

        int mstrcmp(c, d)                /* External string compare */
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
        void mstrcpy(c, d)       /* External string copy */
        char *c, *d;
        {
            while (*c++ = *d++)
                     ;
        }

        int mcopy()         /* Disk copy. Test assumes file doesn't exist */
        {
            FILE *fp, *fopen();
            char buf[TINY];
            int i, j;

            mstrcpy(buf, "Disk I/O test");

            if ((fp = fopen(FILENAME, "w")) == NULL) {
               printf("Cannot open file");
               exit(ERR);
            }

            i = 0;

            while (++i < LITTLE)
                  for (j = 0; buf[j]; ++j)
                      putc(buf[j], fp);

            fclose(fp);
            return (i);
        }

        int intest()            /* Square an integer by iteration */
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
