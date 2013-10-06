debug=0
*
*
* Routine de tra‡age de cercles en arithm‚tique entiŠre.
* (Algorithme de Bresenham)
*
*
;
;
; Quelques constantes pour les modes vid‚os
;
;
col2=0
col4=1
col16=2
col256=3
coltc=4

l40=0
l80=8

tv=0
vga=16
pal=32
overscan=64
st=128
interlace=256

mode=coltc+l40+tv+pal

 pea superviseur
 move #$26,-(sp)
 trap #14
 addq #6,sp
;
; Et quitte
; 
 clr -(sp)
 trap #1



 
superviseur 
 move.l #ecran+4,d0
 and #-1-%11,d0
 move.l d0,‚cran
 
 ifeq debug
;
; R‚cupŠre la r‚solution courante et l'adresse de la m‚moire
; vid‚o
;
 move #-1,-(sp)
 move #88,-(sp)
 trap #14
 addq #4,sp
 move d0,old_video
 
 move #2,-(sp)
 trap #14
 addq #2,sp
 move.l d0,old_adresse

;
; Valide ma propre r‚solution
; et mon propre ecran
; 
 move #mode,-(sp)
 move #3,-(sp)
 move.l ‚cran,-(sp)
 move.l ‚cran,-(sp)
 move #5,-(sp)
 trap #14
 add #14,sp
 endc

 bsr affichage
 
 move #7,-(sp)
 trap #1
 addq #2,sp
 
;
; Restaure tout
; 
 ifeq debug
 move old_video,-(sp)
 move #3,-(sp)
 move.l old_adresse,-(sp)
 move.l old_adresse,-(sp)
 move #5,-(sp)
 trap #14
 add #14,sp
 endc
 rts





affichage
 move #160,cx
 move #100,cy
 move #50,r
 bsr trace_cercle
 rts



trace_cercle
 move.l ‚cran,a0

 move cy,d0
 mulu #640,d0
 add.l d0,a0

 move cx,d0
 add d0,d0
 add d0,a0		A0=Adresse du point central


 moveq #0,d6		D6: Xi=0
 move r,d7		D7: Yi=R

 moveq #1,d4		D4: i=2(1-R)
 sub r,d4
 add d4,d4

 moveq #0,d5		D5: Limite=0
 
_1
 move d7,d0		Plot (Xi,Yi)
 mulu #640,d0
 lea (a0,d0.l),a1
 move d7,d0
 neg d0
 muls #640,d0
 lea (a0,d0.l),a2
 move d6,d0
 add d0,d0
 move #$1234,(a1,d0.w) 
 move #$1234,(a2,d0.w) 
 neg.w d0
 move #$1234,(a1,d0.w) 
 move #$1234,(a2,d0.w) 

 cmp d5,d7		If YióLimite then 4
 ble _4

 tst d4
 bmi _2			If i<0 then 2
 beq _20		If i=0 then 20
 bra _3			If i>0 then 3

 
_2
 move d4,d3		D3: ë=2(i+Yi)-1
 add d7,d3
 add d3,d3
 subq #1,d3

 bpl _20		If ë>0 then 20
 bra _10		If ëó0 then 10

 
_3
 move d4,d3		D3: ë=2(i+Xi)-1
 add d6,d3
 add d3,d3
 subq #1,d3

 bpl _30		If ë>0 then 30
 bra _20		If ëó0 then 20


_10
 addq #1,d6		Xi=Xi+1

 add d6,d4		D4: i=i+2Xi+1
 add d6,d4
 addq #1,d4
 
 bra _1


_20
 addq #1,d6		Xi=Xi+1
 subq #1,d7		Yi=Yi-1

 add d6,d4		D4: i=i+2Xi-2Yi+2
 add d6,d4
 sub d7,d4
 sub d7,d4
 addq #2,d4
 
 bra _1


_30
 subq #1,d7		Yi=Yi-1

 sub d7,d4		D4: i=i-2Yi+1
 sub d7,d4
 addq #1,d4
 
 bra _1



_4
 rts

x	ds.w 1
y	ds.w 1
limite	ds.w 1
delta	ds.w 1

cx	ds.w 1
cy	ds.w 1
r	ds.w 1
 


  
 section DATA 

 section BSS

old_video	ds.w 1 
old_adresse	ds.l 1
‚cran		ds.l 1

 ds.l 10000
ecran		ds.l 128000/4
buffer		ds.l 128000/4
 ds.l 10000

 end
 