	.EXPORT Pixelize16

MACRO   GET_FRGB16

    MOVE.W  (A0),D0
    MOVE.W  D0,D1
    ROL.W   #5,D1
    ANDI.W  #$1F,D1      ; D1.W = Composante ROUGE

    MOVE.W  D0,D2
    LSR.W   #5,D2
    ANDI.W  #$3F,D2      ; D2.W = Composante VERTE (0...63)

    MOVE.W  D0,D3
    ANDI.W  #$1F,D3      ; D3.W = Composante BLEU (0...31)

ENDM

MACRO    SET_FRGB16

    MOVE.W  D3,D0        ; D3 = Composante Bleu
    LSL.W   #5,D2
    ADD.W   D2,D0        ; D0 += Composante Verte
    ROR.W   #5,D1
    ADD.W   D1,D0        ; D0 += Composante Rouge

ENDM

*unsigned short Pixelize16(unsigned short *pt, long nb_lpts, short powerx, short powery)
*
*{
*  unsigned long  rsum = 0 ;
*  unsigned long  gsum = 0 ;
*  unsigned long  bsum = 0 ;
*  unsigned long  p2 = powerx * powery ;
*  unsigned short val, pixel, *ptu ;
*  unsigned short red, green, blue ;
*  short          x, y ;
*
*  for ( y = 0; y < powery; y++ )
*  {
*    ptu = pt + y * nb_lpts ;
*    for ( x = 0; x < powerx; x++, ptu++ )
*    {
*      val    = *ptu ;
*      red    = val >> 11 ;            /* Sur 5 bits */
*      green  = ( val >> 5 ) & 0x3F ;  /* Sur 6 bits */
*      blue   = val & 0x1F ;           /* Sur 5 bits */
*      rsum  += (unsigned long) red ;
*      gsum  += (unsigned long) green ;
*      bsum  += (unsigned long) blue ;
*    }
*  }
*
*  red   = (unsigned short) (rsum / p2) ;
*  green = (unsigned short) (gsum / p2) ;
*  blue  = (unsigned short) (bsum / p2) ;
*  pixel = RVB16( red, green, blue ) ;
*
*  return( pixel ) ;
}

* unsigned short Pixelize16(unsigned short *pt, long nb_lpts, long power)
*         D0                       A0               D0             D1
Pixelize16:
    MOVEM.L   D0-D7/A0-A6,-(SP)

    MOVE.L    D0,D4
    MOVE.L    D1,D5
	MOVE.L    A0,A1
	GET_FRGB16
	

    MOVEM.L   (SP)+,D0-D7/A0-A6 ; Restauration du contexte
