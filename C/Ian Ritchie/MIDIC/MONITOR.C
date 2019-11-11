/*--------------------------------------------------------------------*/
/*---------------------- MIDI MONITOR --------------------------------*/
/*--------------------------------------------------------------------*/

#include <osbind.h>
#include <stdio.h> 
 
#define TRUE  1
#define FALSE 0
 
unsigned char mnote, mvel;
 
char transpose;
int valid, st, status;
 
main()
{
 
valid = -1;
st = TRUE;
status = TRUE;
menu();
 
printf("\n\n\ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ MIDI MONITOR ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ\n\n");
 
     while (!Bconstat(2))     /* has there been a keypress? */
     {
     
          st = monitor();     /* goto monitor procedure */ 
     }
}
 
 
menu()
{
unsigned char e;
while (e != 51)
{
     printf("\n\n\n\n\n");
     printf("1 ........ 254 FILTER STATUS : ON\n");
     printf("2 ........ 254 FILTER STATUS : OFF\n");
     printf("3 ........ START MONITOR");
     if (status)
     {
          printf("\n\n\n        *** 254 FILTER ON ***  \n\n\n\n\n\n\n\n ");
     }
     else printf("\n\n\n        *** 254 FILTER OFF ***  \n\n\n\n\n\n\n\n ");

     e = Bconin(2);        /* get ASCII key code */

     switch (e)
     {
          case 49:status = TRUE; break ;
          case 50:status = FALSE; break ;
          case 51:break ;
     }
}
 
 
}
 
 
monitor()
{
unsigned char value;
     value = Bconin(3); Bconout(3, value);
     if (value < 128)                       /* if data print value */
     {
          printf(" %d ", value);
     }
     else if (value < 254)                  /* if status byte */
     {
          switch (value)
          {
          case 144:printf("\nNOTE ON : "); break ;
          case 192:printf("\nPROGRAM CHANGE : "); break ;
          case 248:printf("248\n"); break ;
          case 224:printf("\nPITCHBEND : "); break ;
          case 208:printf("\nAFTERTOUCH : "); break ;
          case 176:printf("\nCONTROLLER : "); break ;
          default :printf(" ( %d ) ", value);
          }
     }
     else if (value == 254 && status == FALSE)   /* if running status */
     {
          printf(".");
     }
     return st;
}
 
 
 
 
 
 
 
