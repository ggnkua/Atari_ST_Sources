/*--------------------------------------------------------------------*/
/*------------------------ PLAY AVANTE GARDE JAZZ --------------------*/
/*--------------------------------------------------------------------*/
 
#include <stdio.h>
#include <time.h>
#include <osbind.h>
 
#define BELL printf("\7")        /* DEFINE A BELL PING */
 
main()
{
     printf("\n\n\nPress any key to stop this madness!");
     seed();
     play_jazz();
     BELL;
}
 
long seed()     /* start random generator at unpredictable value */
{
long t;
           time(&t);
           srand(t);
return t;
}
 
int random(range)
int range;
{
     int r;
     r = rand()%range;      /* constrain rand() to a range of values */
     return r;
}
 
 
 
Note_On(m)                                        /* Play a midi note */
unsigned char m;
{
     Bconout(3, 144);
     Bconout(3, m);
     Bconout(3, 127);
}
 
 
Note_Off(m)                                       /* Stop a midi note */
unsigned char m;
{
     Bconout(3, 144);
     Bconout(3, m);
     Bconout(3, 0);
}
 
delay(v)
int v;
{
int i;
     v = v*(random(5)+1);
     for (i = 0; i < v; i++);
 
}
 
play_jazz()
{
unsigned char m;
     while (!Bconstat(2))
     {
          m = random(24)+48;
          Note_On(m);
          delay(12000);
          Note_Off(m);
     }
}
