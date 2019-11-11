/*--------------------------------------------------------------------*/
/*---------------------------- EAR IMPROVER --------------------------*/
/*--------------------------------------------------------------------*/
 
#include <stdio.h>
#include <time.h>
#include <osbind.h>
 
#define BELL printf("\7")        /* DEFINE A BELL PING */
#define STOP Bconin(2)
 
main()
{
unsigned char q, a;
     printf("\n\n\n****** DOC KIPPERS PATENT EAR IMPROVER *******\n\n");
     seed();
     while (1)
     {
          q = question();
          a = answer();
          result(q, a);
          STOP;
     }
     BELL;
}
 
long seed()          /* start random generator at unpredictable value */
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
     for (i = 0; i < v; i++);
}
 
question()
{
int x;
     printf("Guess this note ..................\n\n\n");
          do 
          {
               x = random(12)+1;
          }
          while (x == 2 || x == 4 || x == 7 || x == 9 || x == 11);
          x = x+47;
          Note_On(x); delay(50000); Note_Off(x);
     return x;
}
 
answer()                      /* get answer from midi keyboard */
{
unsigned char m, v;
     do 
     {
          while (m != 144)
          {
               m = Bconin(3);
          }
          m = Bconin(3);
          v = Bconin(3);
     }
     while (v == 0);
     return m;
 
}
 
 
result(question, answer)                /* assess answer */
unsigned char question, answer;
{
     if (question == answer)
     {
          printf("Your answer is CORRECT Well Done!!\n\n");
     }
     else printf("Your answer is WRONG!!  ");
     printf("\n\n            press <SPACEBAR> for another try \n\n\n\n");
}
