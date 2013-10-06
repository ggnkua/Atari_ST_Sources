;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Routine de ligne personnelle by TCHOOM ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,(sp)
 trap #14
 lea.l 12(sp),sp

 jsr init_line

 pea 0.w
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,rpile+2

 clr.w $ffff8240.w
 move.w #$777,$ffff8242.w
 move.w #$777,$ffff8246.w

prog
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp
 clr.w $ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

 rept 14
 move.w #0,d0
 move.w #0,d1
 move.w #10,d2
 move.w #100,d3
 jsr line
 endr

 cmpi.b #$36,$fffffc02.w
 bne no_shift
 move.w #$451,$ffff8240.w
no_shift
 bra prog

end
 clr.w $ffff8240.w
 move.w #$777,$ffff8242.w
rpile pea 0
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 clr -(sp)
 trap #1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routine d'init de la ligne ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

init_line

; rempli offset_y

 lea.l offset_y,a0
 lea.l code_y,a1
 move.w #199,d0
rempli_offset_y
 move.l a1,(a0)+
 adda.l #18,a1
 dbf d0,rempli_offset_y

; complete les routines de code_y
 
 lea.l code_y,a0
 lea.l code_y2,a1
 move.w #198,d0
complete_code_y
 rept 18
 move.b (a0)+,(a1)+
 endr
 dbf d0,complete_code_y

; rempli offset_x
 
 lea.l offset_x,a0
 lea.l code_x,a1
 move.w #19,d0
rempli_offset_x
 rept 16
 move.l a1,(a0)+
 addq.w #8,a1
 endr
 addq.w #2,a1		On passe le addq !
 dbf d0,rempli_offset_x

; rempli table_x

 lea.l table_x,a0
 moveq.w #0,d0
 moveq.w #0,d1
 moveq.w #19,d2
rempli_table_x
 move.w d0,(a0)+
 move.w d1,(a0)+
 addq.w #1,d1
 cmpi.w #16,d1
 bne.s rempli_table_x
 moveq.w #0,d1
 addq.w #8,d0
 dbf d2,rempli_table_x

; rempli table_y

 lea.l table_y,a0
 move.w #199,d0
 moveq.w #0,d1
rempli_table_y
 move.w d1,(a0)+
 addi.w #160,d1
 dbf d0,rempli_table_y

; complete les routines de code_x

 lea.l code_x,a0
 lea.l code_x17,a1
 move.w #18,d0
rempli_code_x
 rept 130
 move.b (a0)+,(a1)+
 endr
 dbf d0,rempli_code_x

 rts

;;;;;;;;;;;;;;;;;;;;
; routine de ligne ;
;;;;;;;;;;;;;;;;;;;;

line

; teste le tracage gauche-droite

 cmp.w d0,d2
 bhi.s no_change1
 exg d0,d2
 exg d1,d3
no_change1

 cmp.w d2,d3
 bne.s no_diagonal
 addq.w #1,d2
no_diagonal

; trouve le sens de la pente

 move.w #$a0,a2
 tst.w d3		Teste directement Dy
 bpl.s no_change2
 move.w #-$a0,a2
 sub.w d0,d2		Dx 
 move.w d1,d4
 sub.w d3,d4
 move.w d4,d3
 bra.s no_change2_1
no_change2
 sub.w d0,d2		Dx 
 sub.w d1,d3		Dy=y2-y1
no_change2_1

; trouve adresse ecran =>a0 avec d0,bit de depart (0<d0<15)

 move.w d1,d4
 lea.l $1f8000,a0
 lea.l table_y,a1
 lsl.w d4
 add.w d4,a1
 add.w (a1),a0	
 lea.l table_x,a1
 lsl.w #2,d0
 add.w d0,a1
 add.w (a1)+,a0
 move.w (a1)+,d0

; calcul de l'adresse a l'octet pres !

 move.l #$00070001,add_dec+2
 cmpi.w #7,d0
 blo.s no_dep_octet
 move.l #$00010007,add_dec+2
 subq.w #8,d0
 addq.w #1,a0
no_dep_octet

 cmp.w d3,d2
 bhi.s line_x

line_y

; calcul adresse de depart de code_y et pose RTS

 lea.l offset_y,a1
 lsl.w #2,d1
 add.w d1,a1
 move.l (a1),a3			Adresse de saut

 move.w d3,d4
 lsl.w #2,d4
 add.w d4,a1
 move.l (a1),a1
 move.l a1,r_rts2+4		Adresse ou on pose le rts
 move.w (a1),r_rts2+2		Ancien contenu de l'adresse
 move.w #$4e75,(a1)		Rts

; calcul de la pente

 swap d2
 divu.w d3,d2
 move.w d2,a1

add_dec move.l #$00070001,d1

 moveq.w #0,d7		Compteur de pente
 jsr (a3)

r_rts2 move.w #0,code_y

 rts
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routine de ligne horizontale ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

line_x 

; calcul adresse de depart de code_x et pose RTS

 lea.l offset_x,a1
 lsl.w #2,d0
 add.w d0,a1
 move.l (a1),a3			Adresse de saut

 move.w d2,d4
 lsl.w #2,d4
 add.w d4,a1
 move.l (a1),a1
 move.l a1,r_rts+4		Adresse ou on pose le rts
 move.w (a1),r_rts+2		Ancien contenu de l'adresse
 move.w #$4e75,(a1)		Rts

; calcul de la pente

 swap d3
 divu.w d2,d3
 move.w d3,a1

; prepare registres et saut a la routine horizontale

 moveq.w #0,d7		Compteur de pente
 moveq.w #-128,d5
 moveq.w #64,d4
 moveq.w #32,d3
 moveq.w #8,d2
 moveq.w #4,d1		Sert pour le 4 et 16
 moveq.w #1,d0		Sert pour le 1 et 2

 jsr (a3)

r_rts
 move.w #0,code_x	On remet l'ancien octet remplace par le RTS

 rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routine pour code horizontale ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

code_x
 or.b d5,(a0)		; 128
 add.w a1,d7
 bcc.s code_x1
 add.w a2,a0
code_x1
 or.b d4,(a0)		; 64
 add.w a1,d7
 bcc.s code_x2
 add.w a2,a0
code_x2
 or.b d3,(a0)		; 32
 add.w a1,d7
 bcc.s code_x3
 add.w a2,a0
code_x3
 bset.b d1,(a0)		; 16
 add.w a1,d7
 bcc.s code_x4
 add.w a2,a0
code_x4
 or.b d2,(a0)		; 8
 add.w a1,d7
 bcc.s code_x5
 add.w a2,a0
code_x5
 or.b d1,(a0)		; 4
 add.w a1,d7
 bcc.s code_x6
 add.w a2,a0
code_x6
 bset.b d0,(a0)		; 2
 add.w a1,d7
 bcc.s code_x7
 add.w a2,a0
code_x7
 or.b d0,(a0)+		; 1
 add.w a1,d7
 bcc.s code_x8
 add.w a2,a0
code_x8
 or.b d5,(a0)		; 128
 add.w a1,d7
 bcc.s code_x9
 add.w a2,a0
code_x9
 or.b d4,(a0)		; 64
 add.w a1,d7
 bcc.s code_x10
 add.w a2,a0
code_x10
 or.b d3,(a0)		; 32
 add.w a1,d7
 bcc.s code_x11
 add.w a2,a0
code_x11
 bset.b d1,(a0)		; 16
 add.w a1,d7
 bcc.s code_x12
 add.w a2,a0
code_x12
 or.b d2,(a0)		; 8
 add.w a1,d7
 bcc.s code_x13
 add.w a2,a0
code_x13
 or.b d1,(a0)		; 4
 add.w a1,d7
 bcc.s code_x14
 add.w a2,a0
code_x14
 bset.b d0,(a0)		; 2
 add.w a1,d7
 bcc.s code_x15
 add.w a2,a0
code_x15
 or.b d0,(a0)		; 1
 add.w a1,d7
 bcc.s code_x16
 add.w a2,a0
code_x16
 addq.l #7,a0
code_x17
 ds.b 130*19
 rts

;;;;;;;;;;;;;;;;;;
; code verticale ;
;;;;;;;;;;;;;;;;;;

code_y
 bset.b d0,(a0)
 add.w a2,a0
 add.w a1,d7
 bcc.s code_y2
 dbf d0,code_y2
 adda.w d1,a0
 swap d1
 moveq.w #7,d0
code_y2
 ds.b 18*199
 rts

;;;;;;;;;;;;;;;;
; section data ;
;;;;;;;;;;;;;;;;

table_x  ds.l 320
table_y  ds.w 200
offset_x ds.l 320
offset_y ds.l 200
