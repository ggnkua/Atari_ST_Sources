/****************************************/
/*     Son en variant la p‚riode      */
/*  Laser C    SOUND2.C   */
/****************************************/

#include <osbind.h>

int  i,a;


sound (canal, periode)
int canal, periode;
{
  Giaccess (periode & 255, 128 + (canal-1)*2);    /* Lowbyte */
  Giaccess (periode >> 8,  128 + (canal-1)*2+1);  /* Highbyte */
}


main()
{
  Giaccess (254, 128 + 7);   /* Seul le canal A est actif */
  Giaccess (15,  128 + 8);   /* Volume A = 15 */
  
  for (a = 0;  a < 5;  a++)
  {
    for (i = 4000;  i > 500;  i--)
      sound (1, i);
    
    for (i = 500;  i < 4000;  i++)
      sound (1,i);
  }

  sound (1, 0);   /* Arrˆter son */
}

