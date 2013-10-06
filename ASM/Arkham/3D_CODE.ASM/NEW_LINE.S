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

; trace une ligne

 lea.l $1f8000,a0
 move.w #0,d0
 move.w #0,d1
 move.w #819,d2
 move.w #199,d3
 bsr line

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
 cmp.w d0,d2			Tracage de gauche a droite
 bhi.s sens_x_ok
 exg d0,d2
 exg d1,d3
sens_x_ok
 tst.w d2			Teste si la ligne est contenue
 bpl.s no_clip1			Entiere dans l'ecran
 rts
no_clip1
 cmp.w #320,d0
 blo.s no_clip2
 rts
no_clip2
 tst.w d3
 bpl.s no_clip3
 rts
no_clip3
 cmp.w #200,d1
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
 move.w #-$a0,a2		Inverse sens de la pente
 neg.w d5			Dy reste positif 
sens_y_ok
 cmp.w d4,d5
 bhi line_y

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routine de ligne horizontale (Dx>Dy) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

line_x
 cmp.w d4,d5			Traitement des diagonales
 bne.s no_diag
 subq.w #1,d4
no_diag
 swap d5
 divu.w d4,d5

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
 move.l (a1),a1
 cmpa.l #x_rts,a1
 blo.s ok_clip1
 lea.l x_rts,a1
ok_clip1
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
r_rts move.w #0,code_x

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routine de ligne verticale (Dy>Dx) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

line_y
 rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; code genere pour routine horizontale ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

code_x
 or.b d0,(a0)			; 128
 add.w a1,d7
 bcc.s code_x1
 add.w a2,a0
code_x1
 or.b d1,(a0)			; 64	
 add.w a1,d7
 bcc.s code_x2
 add.w a2,a0
code_x2
 or.b d2,(a0)			; 32	
 add.w a1,d7
 bcc.s code_x3
 add.w a2,a0
code_x3
 or.b d3,(a0)			; 16	
 add.w a1,d7
 bcc.s code_x4
 add.w a2,a0
code_x4
 or.b d4,(a0)			; 08
 add.w a1,d7
 bcc.s code_x5
 add.w a2,a0
code_x5
 bset.b d5,(a0)			; 04
 add.w a1,d7
 bcc.s code_x6
 add.w a2,a0
code_x6
 or.b d5,(a0)			; 02
 add.w a1,d7
 bcc.s code_x7
 add.w a2,a0
code_x7
 or.b d6,(a0)+			; 01
 add.w a1,d7
 bcc.s code_x8
 add.w a2,a0
code_x8
 or.b d0,(a0)			; 128
 add.w a1,d7
 bcc.s code_x9
 add.w a2,a0
code_x9
 or.b d1,(a0)			; 64	
 add.w a1,d7
 bcc.s code_x10
 add.w a2,a0
code_x10
 or.b d2,(a0)			; 32	
 add.w a1,d7
 bcc.s code_x11
 add.w a2,a0
code_x11
 or.b d3,(a0)			; 16	
 add.w a1,d7
 bcc.s code_x12
 add.w a2,a0
code_x12
 or.b d4,(a0)			; 08
 add.w a1,d7
 bcc.s code_x13
 add.w a2,a0
code_x13
 bset.b d5,(a0)			; 04
 add.w a1,d7
 bcc.s code_x14
 add.w a2,a0
code_x14
 or.b d5,(a0)			; 02
 add.w a1,d7
 bcc.s code_x15
 add.w a2,a0
code_x15
 or.b d6,(a0)+			; 01
 add.w a1,d7
 bcc.s code_x16
 add.w a2,a0
code_x16
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
 rept 16
 move.w d1,(a0)+
 endr
 addq.l #8,d1
 dbf d0,rempli_table_x
 rts 


offset_x	ds.l 320
table_x		ds.w 320
table_y		ds.w 200