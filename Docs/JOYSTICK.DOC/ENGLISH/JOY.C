/* -------------------------------------------------------------------------
;  Source C de gestion des joysticks normaux sur le port etendu (paddle,joypad)
;  pour STE/FALCON.			       
;  Ce programme n'est qu'un exemple et une maniere de faire...      
;  Elle renvoit les memes valeurs que les joysticks normaux.       
;  Son utilisation est simple le programme vous affiche les positions
;  des 4 joysticks...              
; --------------------------------------------------------------------------
;  Fabrice Vend‚/E-mail: fvende@srvetud.univ-lr.fr	         
; --------------------------------------------------------------------------
*/
   

#include "stdio.h"
#include "tos.h"
#include "screen.h"


/* procedure qui test la position du joy numero_joy */
int position(int numero_joy)
{  
   int resultat=0;
   int joy;
   
   joy=*((int*)(0xfff9202L));		/* recuperation valeur postion */
   if ( (joy & (1<<(4*numero_joy)  ) )==0) resultat=8;
   if ( (joy & (1<<(4*numero_joy)+1) )==0) resultat=4;
   if ( (joy & (1<<(4*numero_joy)+2) )==0) resultat+=2;
   if ( (joy & (1<<(4*numero_joy)+3) )==0) resultat+=1;
   return resultat;
} 


/* procedure qui test le bouton feu du joy numero_joy */
int feu(int numero_joy)
{  
   int resultat=0;
   char joy;
   
   joy=*((char*)(0xfff9201L));		/* recuperation valeur feu */

 /* ne pas oublier que si l'on prend l'ordre 1 2 3 4 comme numero
    de joy pour chaque 4 bits de position, l'ordre lu dans le meme sens
    pour les boutons feu est 1 3 2 4 */  
  
   if ((numero_joy==0) && ((joy & 1 )== 0)) return (1);
   if ((numero_joy==1) && ((joy & 4 )== 0)) return (1); 
   if ((numero_joy==2) && ((joy & 2 )== 0)) return (1);
   if ((numero_joy==3) && ((joy & 8 )== 0)) return (1);
   return(0);
} 




void main(void)
{
 int i;

 Super(0); /* passage en SUPERVISEUR */
		
 
  Clear_home();
  
  while (''=='')
  {
   for (i=0;i<=3;i++)
   {
	  Goto_pos(i,1);
      printf("Joy (%d) Position =>%u     Tire => %u \n",i+1,position(i),feu(i));
    }
  }
  Super(1); /* retour en UTILISATEUR */
 }
 
 
 
 
 
