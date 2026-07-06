/*   ABC p40                        */
/*   decisions                      */
/* works ok -     23/11/86          */

#include <stdio.h>
int ticks = 200;

main()
     {    char ch,string[20];
          int ans;

          printf("gimme a letter...(y/n)");
          scanf("%c",&ch);
          ans = affirmative(ch);
          if (ans)
               { printf("yes!\n");}
          else
               {printf("no - not yes\n");}

     delay(ticks);
     }
affirmative(ch)
     char ch;
     { if ( ch == 'y' ) return(1);
       else if ( ch =='Y') return(1);
            else return(0);
     }
