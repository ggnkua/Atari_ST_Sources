;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NOUVELLE ROUTINE DE LIGNE,CLIPPE,AVEC BUFFER D'EFFACEMENT ;
; BY TCHOOM/ARKHAM		(C) 1993		    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 lea.l 12(sp),sp
 bsr init_line
 pea routine
 move.w #$26,-(sp)
 trap #14
 addq.l #6,sp
 clr -(sp)
 trap #1

routine
 clr.w $ffff8240.w
 move.w #$707,$ffff8242.w
 move.w #$777,$ffff8246.w

prog
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp
 clr.w $ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

; efface la ligne

 lea.l clr_buf,a0
fin_reg
 move.l #fin_buf-100*4,d1
 moveq.w #0,d0
clr_line
 movem.l (a0)+,a1-a6
 move.b d0,(a1)
 move.b d0,(a2)
 move.b d0,(a3)
 move.b d0,(a4)
 move.b d0,(a5)
 move.b d0,(a6)
 cmp.l d1,a0
 blo.s clr_line

; trace une ligne

 lea.l clr_buf,a3
 lea.l $1f8000,a0
x1 move.w #199,d0
x2 move.w #50,d1
x3 move.w #0,d2
x4 move.w #199,d3
 bsr line
 move.l a3,fin_reg+2

 subq.w #1,x2+2
; addq.w #1,x3+2
; addq.w #1,x3+2
; subq.w #1,x4+2

 cmpi.b #$36,$fffffc02.w
 bne.s no_shift
 move.w #$211,$ffff8240.w
no_shift
 bra prog

end
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
 rts

;;;;;;;;;;;;;;;;;;;;
; routine de ligne ;
;;;;;;;;;;;;;;;;;;;;

line
 add.w #200,d0			On augmente toute les coord.
 add.w #200,d1			Pour rester positifs pour
 add.w #200,d2			Que les test du clipping se verifient
 add.w #200,d3
 cmp.w d0,d2			Tracage de gauche a droite
 bhi.s sens_x_ok
 exg d0,d2
 exg d1,d3
sens_x_ok
 cmpi.w #199,d2			On teste si la ligne est contenue
 bhi.s no_clip1			Dans l'ecran
 rts
no_clip1
 cmpi.w #320+200,d0
 blo.s no_clip2
 rts
no_clip2
 cmp.w #199,d1
 bhi.s no_clip3
 cmp.w #199,d3
 bhi.s no_clip3
 rts
no_clip3
 cmp.w #200+200,d1
 blo.s no_clip4
 cmp.w #200+200,d3
 blo.s no_clip4
 rts
no_clip4
 move.w d2,d4
 move.w d3,d5
 sub.w d0,d4			Dx
 sub.w d1,d5			Dy
 move.w #$a0,a2			Sens arbitraire de la pente
 cmp.w d1,d3
 bhi.s sens_y_ok
; move.w #$005,$ffff8240.w
 move.w #-$a0,a2		Inverse sens de la pente
 neg.w d5
sens_y_ok
 cmp.w d4,d5
 bhi line_y

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routine de ligne horizontale (Dx>Dy) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

line_x
 cmp.w d4,d5			Traitement des diagonales
 bne.s no_diag
 addq.w #1,d4
no_diag
 swap d5
 divu.w d4,d5			D5=pente

 cmp.w #199,d1 			Clipping haut
 bhi.s ok_clip3
 move.w #200,d6
 sub.w d1,d6
 swap d6
 divu.w d5,d6
 add.w d6,d0
 move.w #200,d1
ok_clip3

 cmp.w #199,d3			Clipping haut II
 bhi.s ok_clip4
 move.w #200,d6
 sub.w d3,d6
 swap d6
 divu.w d5,d6
 sub.w d6,d2
 move.w #200,d3
ok_clip4

 cmp.w #200+200,d3		Clipping Bas I
 blo.s ok_clip5
 sub.w #400,d3
 swap d3
 divu.w d5,d3
 sub.w d3,d2
 move.w #199+200,d3
ok_clip5

 cmp.w #200+200,d1		Clipping bas II
 blo.s ok_clip6
 sub.w #400,d1
 swap d1
 divu.w d5,d1
 add.w d1,d0
 move.w #199+200,d1
ok_clip6

 cmp.w #199,d0			Clipping gauche
 bhi.s ok_clip2
 move.w #$310,$ffff8240.w
 move.w #200,d6
 sub.w d0,d6
 mulu.w d5,d6
 swap d6
 add.w d6,d1
 move.w #200,d0
ok_clip2

 sub.w #200,d0			On remet les coordonnes
 sub.w #200,d1			En etat car clipping termine
 sub.w #200,d2
 sub.w #200,d3

 lea.l table_y,a1		Trouve adresse ecran
 add.w d1,d1
 add.w d1,a1
 add.w (a1),a0
 lea.l table_x,a1
 add.w d0,d0
 add.w d0,a1
 add.w (a1),a0

 lea.l offset_x,a1		Pose adresse de saut et RTS
 add.w d0,d0			Feinte:d0 ‚tait dej… *2
 add.w d0,a1			
 move.l (a1),a1
 move.l a1,saut+2		Adresse de saut

 lea.l offset_x,a1
 add.w d2,d2
 add.w d2,d2
 add.w d2,a1
 cmp.l #offset_x2,a1		Clipping droite
 blo.s ok_clip1
 lea.l offset_x2-4,a1
ok_clip1
 move.l (a1),a1
 move.w (a1),r_rts+2		Ancien Contenu
 move.l a1,r_rts+4		Adresse de Rts
 move.w #$4e75,(a1)		Pose le rts
 
 move.w d5,a1			a1=pente 
 moveq.w #-128,d0		Valeur de chaque point
 moveq.w #64,d1			Composant l'octet d'ecran
 moveq.w #32,d2
 moveq.w #16,d3
 moveq.w #8,d4
 moveq.w #2,d5
 moveq.w #1,d6
 moveq.w #0,d7			Compteur de pente
saut  jsr code_x
 move.l a0,(a3)+ 
r_rts move.w #0,code_x
 rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routine de ligne verticale (Dy>Dx) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

line_y
 swap d4
 divu.w d5,d4

 cmp.w #200,d0			Clipping gauche
 bhi.s ok_clip7
 move.w #200,d6
 sub.w d0,d6
 swap d6
 divu.w d4,d6
 add.w d6,d1 
 move.w #200,d0
ok_clip7

 cmp.w #320+200,d2		Clipping droite
 blo.s ok_clip8
 sub.w #320+200,d2
 swap d2
 divu.w d4,d2
 sub.w d2,d3
 sub.w d2,d5
 move.w #319+200,d2
ok_clip8

 cmp.w #199,d3			Clipping haut I
 bhi.s ok_clip9
 move.w #200,d6
 sub.w d3,d6
 swap d6
 divu.w d4,d6
 sub.w d6,d2
 move.w #200,d3
ok_clip9 

 cmp.w #199,d1			Clipping haut II
 bhi.s ok_clip10
 move.w #$324,$ffff8240.w
 move.w #200,d6
 sub.w d1,d6
 sub.w d6,d5
 mulu.w d4,d6
 swap d6
 add.w d6,d0
 move.w #200,d1
ok_clip10 

 subi.w #200,d0
 subi.w #200,d1
 subi.w #200,d2
 subi.w #200,d3

 move.l #$00010007,d2
 lea.l table_x2,a1		Calcul adresse ecran
 add.w d0,d0
 add.w d0,d0
 add.w d0,a1
 add.w (a1)+,a0
 move.w (a1),d0
 cmpi.w #8,d0
 blo.s ok_d2
 subq.w #8,d0
 swap d2
 subq.w #1,a0
ok_d2
 addq.w #1,a0
 lea.l table_y,a1
 add.w d1,d1
 add.w d1,a1
 add.w (a1),a0

 lea.l offset_y,a1
 add.w d5,d5
 add.w d5,d5
 add.w d5,a1
 cmp.l #offset_y2,a1
 blo.s clip_bas
 lea.l offset_y2-4,a1
clip_bas
 move.l (a1),a1
 move.w (a1),r_rts2+2
 move.l a1,r_rts2+4
 move.w #$4e75,(a1)

 moveq.w #0,d7
 move.w a2,d1
 jsr code_y
r_rts2
 move.w #0,code_y
 move.l a0,(a3)+
 rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; code genere pour routine verticale ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

code_y
 move.l a0,(a3)+
 bset.b d0,(a0)
 add.w d1,a0
 add.w d4,d7
 bcc.s code_y2
 dbf d0,code_y2
 moveq.w #7,d0
 add.w d2,a0
 swap d2
code_y2
 ds.b 199*(code_y2-code_y)
y_rts
 rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; code genere pour routine horizontale ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

code_x
 or.b d0,(a0)			; 128
 add.w a1,d7
 bcc.s code_x1
 move.l a0,(a3)+
 add.w a2,a0
code_x1
 or.b d1,(a0)			; 64	
 add.w a1,d7
 bcc.s code_x2
 move.l a0,(a3)+
 add.w a2,a0
code_x2
 or.b d2,(a0)			; 32	
 add.w a1,d7
 bcc.s code_x3
 move.l a0,(a3)+
 add.w a2,a0
code_x3
 or.b d3,(a0)			; 16	
 add.w a1,d7
 bcc.s code_x4
 move.l a0,(a3)+
 add.w a2,a0
code_x4
 or.b d4,(a0)			; 08
 add.w a1,d7
 bcc.s code_x5
 move.l a0,(a3)+
 add.w a2,a0
code_x5
 bset.b d5,(a0)			; 04
 add.w a1,d7
 bcc.s code_x6
 move.l a0,(a3)+
 add.w a2,a0
code_x6
 or.b d5,(a0)			; 02
 add.w a1,d7
 bcc.s code_x7
 move.l a0,(a3)+
 add.w a2,a0
code_x7
 move.l a0,(a3)+
 or.b d6,(a0)+			; 01
 add.w a1,d7
 bcc.s code_x8
 add.w a2,a0
code_x8
 or.b d0,(a0)			; 128
 add.w a1,d7
 bcc.s code_x9
 move.l a0,(a3)+
 add.w a2,a0
code_x9
 or.b d1,(a0)			; 64	
 add.w a1,d7
 bcc.s code_x10
 move.l a0,(a3)+
 add.w a2,a0
code_x10
 or.b d2,(a0)			; 32	
 add.w a1,d7
 bcc.s code_x11
 move.l a0,(a3)+
 add.w a2,a0
code_x11
 or.b d3,(a0)			; 16	
 add.w a1,d7
 bcc.s code_x12
 move.l a0,(a3)+
 add.w a2,a0
code_x12
 or.b d4,(a0)			; 08
 add.w a1,d7
 bcc.s code_x13
 move.l a0,(a3)+
 add.w a2,a0
code_x13
 bset.b d5,(a0)			; 04
 add.w a1,d7
 bcc.s code_x14
 move.l a0,(a3)+
 add.w a2,a0
code_x14
 or.b d5,(a0)			; 02
 add.w a1,d7
 bcc.s code_x15
 move.l a0,(a3)+
 add.w a2,a0
code_x15
 move.l a0,(a3)+
 or.b d6,(a0)+			; 01
 add.w a1,d7
 bcc.s code_x16
 add.w a2,a0
code_x16
 move.l a0,(a3)+
 addq.w #6,a0
code_x17
 ds.b 19*(code_x17-code_x)
x_rts
 rts
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routine d'initialisation ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

init_line
 lea.l code_x,a0
 lea.l code_x17,a1
 move.w #19*(code_x17-code_x)-1,d0
rempli_code_x
 move.b (a0)+,(a1)+
 dbf d0,rempli_code_x
 
 lea.l offset_x,a0
n set 0
 rept 20
 move.l #code_x+n,(a0)+
 move.l #code_x1+n,(a0)+
 move.l #code_x2+n,(a0)+
 move.l #code_x3+n,(a0)+
 move.l #code_x4+n,(a0)+
 move.l #code_x5+n,(a0)+
 move.l #code_x6+n,(a0)+
 move.l #code_x7+n,(a0)+
 move.l #code_x8+n,(a0)+
 move.l #code_x9+n,(a0)+
 move.l #code_x10+n,(a0)+
 move.l #code_x11+n,(a0)+
 move.l #code_x12+n,(a0)+
 move.l #code_x13+n,(a0)+
 move.l #code_x14+n,(a0)+
 move.l #code_x15+n,(a0)+
n set n+(code_x17-code_x)
 endr

 lea.l code_y,a0
 lea.l code_y2,a1
 move.w #199*(code_y2-code_y)-1,d0
rempli_code_y
 move.b (a0)+,(a1)+
 dbf d0,rempli_code_y

 lea.l offset_y,a0
 lea.l code_y,a1
 move.w #199,d0
r_offset_y
 move.l a1,(a0)+
 adda.l #(code_y2-code_y),a1
 dbf d0,r_offset_y

 lea.l table_y,a0
 move.w #199,d1
 moveq.w #0,d0
rempli_table_y
 move.w d0,(a0)+
 addi.w #160,d0
 dbf d1,rempli_table_y

 lea.l table_x,a0
 move.w #19,d0
 move.w #0,d1
rempli_table_x
 rept 8
 move.w d1,(a0)+
 endr
 addq.l #1,d1
 rept 8
 move.w d1,(a0)+
 endr
 addq.l #7,d1
 dbf d0,rempli_table_x

 lea.l table_x2,a0
 move.w #19,d0
 move.w #0,d1
rempli_table_x2
n set 15
 rept 16
 move.w d1,(a0)+
 move.w #n,(a0)+
n set n-1
 endr
 addq.l #8,d1
 dbf d0,rempli_table_x2
 rts 

offset_x	ds.l 320
offset_x2
offset_y	ds.l 200
offset_y2
table_x		ds.w 320
table_x2	ds.l 320
table_y		ds.w 200

clr_buf		dcb.l 500,$1f8000
fin_buf