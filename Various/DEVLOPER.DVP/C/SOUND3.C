/*********************************/
/*   Enveloppes       SOUND3.C   */
/*   Laser C         */
/*********************************/

#include <osbind.h>


sound (canal, periode)
int canal, periode;
{
  Giaccess (periode & 255, 128 + (canal-1)*2);    /* Lowbyte */
  Giaccess (periode >> 8,  128 + (canal-1)*2+1);  /* Highbyte */
}


wave (courbe, duree)
int courbe, duree;
{
  Giaccess (courbe,      128 + 13);
  Giaccess (duree & 255, 128 + 11);
  Giaccess (duree >> 8,  128 + 12);
}


attend()         /* Boucle de ralentissement */
{
long i;

  for (i = 0;  i < 500000;  i++);
}


main()
{
  Giaccess (254, 128 + 7);  /* Ouvrir canal A */
  Giaccess (16,  128 + 8);  /* Volume pilot‚ par l'enveloppe */
  
  sound (1, 478);     /* D‚but du "son test" */
  
  wave (14, 15);
  attend();
  
  wave (14, 400);
  attend();
  
  wave (14, 3000);
  attend();

  wave (8, 3000);
  attend();
  
  wave (1, 40000);
  attend();
  
  sound (1, 0);   /* Arrˆter le son */
}
