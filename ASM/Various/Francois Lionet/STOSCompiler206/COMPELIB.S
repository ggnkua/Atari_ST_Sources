
**************************************************************************
*
*      EXTENSION COMPILATEUR POUR COMPILATEUR STOS BASIC
*
*      (c) FL Soft 1987/89
*
**************************************************************************

	INCLUDE "EQUATES.S"

**************************************************************************

Debu:   dc.l Para-Debu
        dc.l Data-Debu
        dc.l Libr-Debu

***************************** CATALOGUE **********************************

Cata:   dc.w l2-l1,l3-l2

Para:   dc.w 2,2                        ;Nombre de routines/fonc
        dc.w p1-Para,p2-Para
p1:	dc.b 0				;Parametre impossible
	dc.b 0,255,0,1
	dc.b 1
p2:     dc.b 0 				;Pas de parametre
        dc.b 1
 
********************** PARAMETRES / INIT *******************************

Data:  
Init:   lea End(pc),a2
End:	rts

Libr:
**************************************************************************

**************************************************************************
*	RIEN!
l1:	dc.w 0
***************
	rts

**************************************************************************
*       COMPAD
l2:     dc.w 0
******************************************
	tst.w FlaGem(a5)
	bne.s L2a
	move.l Table(a5),-(a6)
	rts
L2a:	move.l a5,d0
	bset #31,d0
	move.l d0,-(a6)
	rts

l3:     dc.w 0



