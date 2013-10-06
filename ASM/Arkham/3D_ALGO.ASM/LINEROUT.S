;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ROUTINE DE LIGNE BY TCHOOM/ARKHAM (NON CLIPPE) ;
; INTEGRABLE DANS PROGRAMME UTILISANT LES LIGNES ;
; ENTREE:	A0=ADRESSE ECRAN		 ;
; 		A3=ADR. D'UN BUFFER D'EFFACEMENT ;
;		D0=X1		D1=Y1		 ;
;		D2=X2		D3=Y3		 ;
; SORTIE	A3=FIN DU BUFFER D'EFFACEMENT	 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

line
 cmp.w d0,d2		Sens gauche_droite
 bhi.s no_change1
 exg d0,d2
 exg d1,d3
no_change1

 sub.w d0,d2		Dx
 sub.w d1,d3		Dy

 move.w d1,d4
 lea.l table_y,a1	Calcul de l'adresse ecran
 lsl.w d4
 add.w d4,a1
 add.w (a1)+,a0
 move.w d0,d4
 lea.l table_x,a1	
 lsl.w #2,d4
 add.w d4,a1
 add.w (a1)+,a0
 move.w (a1)+,d4

 move.w #$a0,a2		Sens de la pente
 tst.w d3
 bpl.s no_change2
 neg.w d3
 move.w #-$a0,a2
no_change2

 cmp.w d2,d3		Diagonale
 bne.s no_equ
 addq.w #1,d3
no_equ

 cmp.w d2,d3
 blo.s line_x

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routine de ligne verticale ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

line_y
 move.l #$00070001,d1
 cmpi.w #8,d4
 blo.s no_change4
 addq.w #1,a0
 subq.w #8,d4
 swap d1
no_change4
 moveq.w #7,d0
 sub.w d4,d0
 swap d2 
 tst.w d3
 bne.s no_nul_d3
 moveq.w #1,d3
no_nul_d3
 divu.w d3,d2
 lea.l offset_y,a1
 add.w d3,d3
 add.w d3,d3
 adda.w d3,a1
 move.l (a1),a1

 move.l a1,r_rts2+4
 move.w (a1),r_rts2+2
 move.w #$4e75,(a1)
 move.w d2,a1
 moveq.w #0,d6
 jsr code_y
r_rts2 move.w #0,code_y
 rts

;;;;;;;;;;;;;;;;;;;;;;;
; routine horizontale ;
;;;;;;;;;;;;;;;;;;;;;;;

line_x
 cmpi.w #8,d4
 blo.s no_change3
 addq.w #1,a0
no_change3
 swap d3
 tst.w d2
 bne.s no_d2_0
 moveq.w #1,d2		Evite division par zero !
no_d2_0
 divu.w d2,d3

 lea.l offset_x,a1
 add.w d0,d0
 add.w d0,d0
 add.w d0,a1
 move.l (a1),saut1+2
 add.w d2,d2
 add.w d2,d2
 add.w d2,a1
 move.l (a1),a1

 move.l a1,r_rts+4
 move.w (a1),r_rts+2
 move.w #$4e75,(a1)

 move.w d3,a1		Transfere pente
 moveq.w #0,d6		Compteur de pente
 moveq.w #-128,d5
 moveq.w #64,d4
 moveq.w #32,d3
 moveq.w #8,d2
 moveq.w #4,d1		Sert pour le 4 et 16
 moveq.w #1,d0		Sert pour le 1 et 2
saut1 jsr code_x
 move.l a0,(a3)+
r_rts move.w #0,code_x
 rts  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routine pour code horizontale ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

code_x
 or.b d5,(a0)		; 128
 add.w a1,d6
 bcc.s code_x1
 move.l a0,(a3)+
 add.w a2,a0
code_x1
 or.b d4,(a0)		; 64
 add.w a1,d6
 bcc.s code_x2
 move.l a0,(a3)+
 add.w a2,a0
code_x2
 or.b d3,(a0)		; 32
 add.w a1,d6
 bcc.s code_x3
 move.l a0,(a3)+
 add.w a2,a0
code_x3
 bset.b d1,(a0)		; 16
 add.w a1,d6
 bcc.s code_x4
 move.l a0,(a3)+
 add.w a2,a0
code_x4
 or.b d2,(a0)		; 8
 add.w a1,d6
 bcc.s code_x5
 move.l a0,(a3)+
 add.w a2,a0
code_x5
 or.b d1,(a0)		; 4
 add.w a1,d6
 bcc.s code_x6
 move.l a0,(a3)+
 add.w a2,a0
code_x6
 bset.b d0,(a0)		; 2
 add.w a1,d6
 bcc.s code_x7
 move.l a0,(a3)+
 add.w a2,a0
code_x7
 move.l a0,(a3)+
 or.b d0,(a0)+		; 1
 add.w a1,d6
 bcc.s code_x8
 move.l a0,(a3)+
 add.w a2,a0
code_x8
 or.b d5,(a0)		; 128
 add.w a1,d6
 bcc.s code_x9
 move.l a0,(a3)+
 add.w a2,a0
code_x9
 or.b d4,(a0)		; 64
 add.w a1,d6
 bcc.s code_x10
 move.l a0,(a3)+
 add.w a2,a0
code_x10
 or.b d3,(a0)		; 32
 add.w a1,d6
 bcc.s code_x11
 move.l a0,(a3)+
 add.w a2,a0
code_x11
 bset.b d1,(a0)		; 16
 add.w a1,d6
 bcc.s code_x12
 move.l a0,(a3)+
 add.w a2,a0
code_x12
 or.b d2,(a0)		; 8
 add.w a1,d6
 bcc.s code_x13
 move.l a0,(a3)+
 add.w a2,a0
code_x13
 or.b d1,(a0)		; 4
 add.w a1,d6
 bcc.s code_x14
 move.l a0,(a3)+
 add.w a2,a0
code_x14
 bset.b d0,(a0)		; 2
 add.w a1,d6
 bcc.s code_x15
 move.l a0,(a3)+
 add.w a2,a0
code_x15
 or.b d0,(a0)		; 1
 add.w a1,d6
 bcc.s code_x16
 move.l a0,(a3)+
 add.w a2,a0
code_x16
 move.l a0,(a3)+
 addq.l #7,a0
code_x17
 ds.b 19*(code_x17-code_x)
x_rts rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; code pour routine verticale ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

code_y
 bset.b d0,(a0)
 move.l a0,(a3)+
 add.w a2,a0
 add.w a1,d6
 bcc.s code_y2
 dbf d0,code_y2
 add.w d1,a0
 swap d1
 moveq.w #7,d0
code_y2
 ds.b 199*(code_y2-code_y)
y_rts rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routine d'init de la ligne ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

init_line
 lea.l table_x,a0		Rempli Table_x
 move.w #319,d0
 moveq.w #0,d1
 move.w #0,d2
rempli_table_x
 move.w d1,(a0)+
 move.w d2,(a0)+
 addq.w #1,d2
 cmpi.w #16,d2
 bne.s rempli_table_x2
 moveq.w #0,d2
 addq.w #8,d1
rempli_table_x2
 dbf d0,rempli_table_x
 lea.l table_y,a0		Rempli Table_y
 move.w #199,d0
 moveq.w #0,d1
rempli_table_y
 move.w d1,(a0)+
 addi.w #160,d1
 dbf d0,rempli_table_y

 lea.l offset_x,a0		Rempli offset_x

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

 lea.l code_x,a0		Complete code_x
 lea.l code_x17,a1
 move.w #18,d0
rempli_code_x
 rept (code_x17-code_x)
 move.b (a0)+,(a1)+
 endr
 dbf d0,rempli_code_x

 lea.l code_y,a0		Complete code_y
 lea.l code_y2,a1
 move.w #198,d0
complete_x
 rept (code_y2-code_y)
 move.b (a0)+,(a1)+
 endr
 dbf d0,complete_x

 lea.l offset_y,a0
 lea.l code_y,a1
 move.w #199,d0
rempli_offset_y
 move.l a1,(a0)+
 add.l #code_y2-code_y,a1
 dbf d0,rempli_offset_y
 rts

table_x  ds.l 320
table_y  ds.w 200
offset_x ds.l 320
offset_y ds.l 200
