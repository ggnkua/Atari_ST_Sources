/**************************************************/
/*   Entr‚e et sortie de caractŠres sous GEMDOS   */
/*   Megamax Laser C     CHROUT.C   */
/**************************************************/

#include <osbind.h>

char  caractere;
int   scancode;
int   ascii;
long  valretour;

main()
{
  printf ("\nAffichage de codes clavier et ASCII (Fin = ESPACE)\n\n"); 
  do
  {
    valretour = Cconin();
    ascii = (int) valretour;
    caractere = (char) valretour && 255;  /* R‚partition r‚sultat en */
    scancode = valretour >> 16;           /* codes clavier et  ASCII */
    
    Cconout (caractere);

    printf ("\t ASCII = %d \t Scan=%d\n", ascii,
                scancode);
  }
  while (ascii != 32);
}
