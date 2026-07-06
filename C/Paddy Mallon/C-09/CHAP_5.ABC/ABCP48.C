/*  ABC p47       eg 5.3           */
/*  escaping from loops            */
/*  works -- except for BELL does not ring
     24/11/86                      */

#include <stdio.h>
int ticks = 200;
main()
     {
     int kount;
     char ch;
     
     
       printf("REPLY = %d\n",replyisyes());   
     delay(ticks);
     }
replyisyes()
     {    
          char ch;
          while(1)
               {
                  ch= getchar();
                    switch(ch)
                    {    default: putchar(BELL);break;
                         case 'y': case'Y': return(1);
                         case 'n': case'N': return(0);
                    }
               }
     }

