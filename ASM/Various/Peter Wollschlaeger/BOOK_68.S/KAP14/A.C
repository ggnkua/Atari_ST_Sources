/* Offsets in Tabelle der Line-A-Variablen 
   --------------------------------------- */

#define   _v_planes  0   /* Anzahl Video-Planes        */
#define   _v_lin_wr  2   /* Bytes/Video-Zeile          */
#define   _fgbp1    24   /* Die 4 Bit-Planes           */
#define   _fgbp2    26   /*   fuer                     */
#define   _fgbp3    28   /*   die                      */
#define   _fgbp4    30   /*   Farbe                    */
#define   _lstlin   32   /*s ollte -1 sein             */
#define   _ln_mask  34   /* Linienmuster               */
#define   _wrt_mode 36   /* Schreibmodus               */
#define   _x1       38   /* Ausgangspunkt              */
#define   _y1       40
#define   _x2       42   /* Endpunkt                   */
#define   _y2       44
#define   _patptr   46   /* Zeiger -> Fuellmuster      */
#define   _patmsk   50   /* Maske Fuellmuster          */
#define   _multifil 52   /* 0/1: 1/alle Planes fuellen */
#define   _clip     54   /* 0/1: Clipping aus/an       */


#include <stdio.h>

long a_base;  /* in a_base wird die Basisadresse der */
              /* Line-A-Variablen-Tabelle gehalten   */

a_init() /* Initialisierung der Line-A-Grafik */
{
  asm
  {
    dc.w    0xA000          ;hole Adresse Tabelle -> A0
    move    #-1,_lstlin(A0) ;immer -1
    move    #0,_clip(A0)    ;Clipping vorerst aus
    move.l  A0,a_base(A4)   ;sichere Adresse
  }
}

a_writemode(m)
   int m;
{
  asm
  {
    move.l   a_base(A4),A0
    move     m(A6),_wrt_mode(A0)
  }
}

a_linepat(l)
   int l;
{
  asm
  {
    move.l   a_base(A4),A0
    move     l(A6),_ln_mask(A0)
  }
}

a_color(c1,c2,c3,c4)  
    int c1,c2,c3,c4;
{
  asm
  {
    move.l   a_base(A4),A0
    move     c1(A6),_fgbp1(A0)   ;s/w (ist massgebend)
    move     c2(A6),_fgbp2(A0) 
    move     c3(A6),_fgbp3(A0)
    move     c4(A6),_fgbp4(A0)
  }
}

a_line(x1,y1,x2,y2)
    register int x1,y1,x2,y2;
{
  asm
  { 
    move.l   a_base(A4),A0
    move     x1,_x1(A0)      ;Zeichen einr Linie
    move     y1,_y1(A0)      ;von x1/y1 -> x2/y2
    move     x2,_x2(A0)
    move     y2,_y2(A0)
    dc.w     0xA003
  }
}

main()
{
  int i,j;
  a_init();
  a_color(1,1,1,1);
  a_writemode(2);
  a_linepat(-1);

  for(i=639;i;i--)
    a_line(i,0,639-i,399);
  for(i=399;i;i--)
    a_line(0,399-i,639,i);
  
  getchar();
}
