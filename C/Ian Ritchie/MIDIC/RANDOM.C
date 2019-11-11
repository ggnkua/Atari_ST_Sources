 
/*--------------------------------------------------------------------*/
/*-------------------- PRINT A BUNCH OF RANDOM NUMBERS ---------------*/
/*--------------------------------------------------------------------*/
 
#include <stdio.h>
#include <time.h>
#include <osbind.h>
 
#define BELL printf("\7")        /* DEFINE A BELL PING */
#define STOP Bconin(2)           /* DEFINE A PAUSE FOR KEYPRESS */
 
main()
{
     int i;
     seed();
     for (i = 0; i < 600; i++)
     {
          if (i%24 == 0)printf("\n");
          printf("%d ", random(36)+10);
     }
     BELL;
     STOP;
}
 
long seed()          /* start random generator at unpredictable value */
{
long t;
           time(&t);
           srand(t);
return t;
}

 
random(range)
int range;
{
int r;
r = rand()%range; /* constrain rand() to a specific range of values */
return r;
}
