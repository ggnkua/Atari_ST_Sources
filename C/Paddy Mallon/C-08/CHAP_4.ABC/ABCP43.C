/*  ABC p43   eg 4.4             */
/*   case                        */
/*  tested and working 23/11/86  */


#include <stdio.h>
int ticks = 200;

main()
     {
     char reply;
     char let;
          printf("gimme a letter.....");
          scanf("%c",&reply); printf("%c\n",reply);
          printf("grade is ..%d\n",vowel(reply));
          printf("finished\n");
     delay(ticks);
     }

vowel(ch)
          char ch ;
     {
          switch(ch)
               {
                   default: return(0);

                   case 'u': case 'U':return(5);
                   case 'a': case 'A':return(1);
                   case 'e': case 'E':return(2);
                   case 'i': case 'I':return(3);
                   case 'o': case 'O':return(4);
               }
     }
