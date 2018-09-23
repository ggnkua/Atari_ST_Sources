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
 move #2,$ffff8a20.w		Inc x src
 move #0,$ffff8a22.w		Inc y src
 move.l #deb,$ffff8a24.w	Adr src
  
 move #2,$ffff8a2e.w		Inc x dst
 move #0,$ffff8a30.w		Inc y dst
 move.l #recop,$ffff8a32.w	Adr dst

 move #128,$ffff8a36.w		Taille horizontale
 move #1,$ffff8a38.w		Taille verticale
 
 move.b #2,$ffff8a3a.w		Mode de trame
 
 move.b #3,$ffff8a3b.w		Mode recopie

 move.b #8,$ffff8a3d.w		D‚calle de 8 bits
  
 move.b #128+64,$ffff8a3c.w	Lance blitter
 rts
 

deb
var set 0
 rept 256
 dc.b var
var set var+1 
 endr
fin

recop 
 rept 256
 dc.b 0
 endr
 