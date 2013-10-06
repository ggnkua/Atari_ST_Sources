*********************************
* utilisation des fonctions vdi *************
* (pour le tracage de ligne,c'est le pied ! *
* (beaucoup + rapide que la line a ! 	    *
*********************************************

contrl macro \1,\2
 move.w #\2,contrl+\1*2
 endm
intin macro \1,\2
 move.w #\2,intin+\1*2
 endm
ptsin macro \1,\2
 move.w #\2,ptsin+\1*2
 endm
vdisys macro
 jsr vdi
 endm

; programme principal

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 adda.l #12,sp

* fixe le clipping de l'ecran 1

 contrl 0,129
 contrl 1,2
 contrl 3,1
 contrl 6,1
 intin 0,1	Clipping (cool !)
 ptsin 0,0
 ptsin 1,0
 ptsin 2,319
 ptsin 3,199
 vdisys

* motifs de remplissage

 contrl 0,23
 contrl 1,0
 contrl 3,1
 contrl 6,1
 intin 0,2
 vdisys

 contrl 0,24
 contrl 1,0
 contrl 3,1
 contrl 6,1
 intin 0,4
 vdisys

 contrl 0,104
 contrl 1,0
 contrl 3,1
 contrl 6,1
 intin 0,0
 vdisys

 pea routine
 move.w #$26,-(sp)
 trap #14
 addq.l #6,sp
 clr -(sp)
 trap #1

routine
 clr.w $ffff8240.w
 move.w #$777,$ffff825e.w
 
prog
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp
 cmpi.b #$b9,$fffffc02.w
 beq end
 clr.w $ffff8240.w

* affiche objet
* face pleine

 contrl 0,9
 contrl 1,5
 contrl 3,0
 contrl 6,1
 ptsin 0,50
 ptsin 1,50
 ptsin 2,100
 ptsin 3,50
 ptsin 4,100
 ptsin 5,100
 ptsin 6,50
 ptsin 7,100
 ptsin 8,50
 ptsin 9,50
 vdisys

* move.w #$222,$ffff8240.w
 bra prog

end
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
 rts

vdi move.l #vdipb,d1
 moveq.w #115,d0
 trap #2
 rts
vdipb dc.l contrl,intin,ptsin,intout,ptsout
contrl ds.w 12
intin ds.w 128
intout ds.w 128
ptsin ds.w 128
ptsout ds.w 128
