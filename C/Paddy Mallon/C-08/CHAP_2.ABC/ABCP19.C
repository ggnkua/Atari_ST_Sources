/*   ABC p19/20 eg2.4                 */
/*   functions and parameters         */
/*   tested & run 22/11/86            */

         #include <stdio.h>
         #define gap printf("\n\n\n\n\n");
        
     main()

           {
              long ticks;
               ticks = 300;

                         bigH('H');
                         bigI('I');

              delay(ticks);
           }

     bigH(ch)
          char ch;
          {    gap;
               endstars(ch);endstars(ch);endstars(ch);
               allstars(ch);
               endstars(ch);endstars(ch);endstars(ch);
          }
     bigI(ch)
          char ch;
          {    gap;
               allstars(ch);
               midstars(ch); midstars(ch);midstars(ch);
               midstars(ch); midstars(ch);
               allstars(ch);
          }          

     allstars(ch)
          char ch;
               { printf("%c%c%c%c%c\n",ch,ch,ch,ch,ch); }

     endstars(ch)
          char(ch);
               {printf("%c   %c\n",ch,ch);}

     midstars(ch)
          char ch;
               { printf("  %c  \n",ch);}


