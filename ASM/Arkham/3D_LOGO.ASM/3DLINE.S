***********************************
* 3d vector line by TCHOOM/ANONYM *
***********************************

 section text

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 adda.l #12,sp

 pea 0
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,rpile+2

 clr.w $ffff8240.w
 move.w #$777,$ffff8242.w
 move.w #$777,$ffff8246.w

 jsr prec_sprite

 lea.l $1f8000,a0
 move.w #7999,d0
eff_ecr clr.l (a0)+
 dbf d0,eff_ecr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Et on commence le programme principal ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 lea.l $90000,a6

prog
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp
 clr.w $ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

 lea.l $1f8000+56+50*$a0,a0
 move.w #83,d0
aff_sprite
n set 0
 rept 6
 move.w (a6)+,n(a0)
n set n+8
 endr
 lea.l $a0(a0),a0
 dbf d0,aff_sprite

 cmpa.l #$90000+6*2*84*180,a6
 blo nofin_a6
 lea.l $90000,a6
nofin_a6

 cmpi.b #$62,$fffffc02.w
 bne no_help
 move.w #$145,$ffff8240.w
no_help

 bra prog

end
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
rpile pea 0
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 clr -(sp)
 trap #1

prec_sprite 
 lea.l $90000,a6
prec_sprite2
 lea.l $1f8000+8*$a0,a0
 move.w #83,d0
 moveq.w #0,d1 
eff_clr
n set 0
 rept 6
 move.w d1,n(a0)
n set n+8
 endr
 lea.l $a0(a0),a0
 dbf d0,eff_clr

; calcul des rotations et du zoom

 lea.l object,a0
 lea.l new_coord,a1
 lea.l cosinus,a2
 adda.w alpha,a2
 move.w (a2)+,d5
 move.w (a2),d6

 move.w #nbre_plot-1,d7
calcul_obj
 move.w (a0)+,d0
 move.w (a0)+,d1
 move.w (a0)+,d2

; rotation X

 move.w d1,d3
 move.w d2,d4

 muls.w d5,d1
 muls.w d6,d2
 add.w d2,d1
 asr.w #7,d1

 muls.w d5,d4
 muls.w d6,d3
 sub.w d3,d4
 asr.w #7,d4
 move.w d4,d2

; rotation Y

 move.w d0,d3
 move.w d2,d4

 muls.w d5,d0
 muls.w d6,d2
 add.w d2,d0
 asr.w #7,d0

; projection spherique
 
 addi.w #50,d0
 addi.w #50,d1
 move.w d0,(a1)+
 move.w d1,(a1)+
 dbf d7,calcul_obj

; affiche objet calcule precedemment

 lea.l line,a0
 move.w #nbre_line-1,d7
aff_obj
 move.w (a0)+,d4
 move.w (a0)+,d5
 mulu.w #4,d4
 mulu.w #4,d5
 lea.l new_coord,a1
 move.w (a1,d4.w),d0
 move.w 2(a1,d4.w),d1
 move.w (a1,d5.w),d2
 move.w 2(a1,d5.w),d3
 movea.l #$1f8000,a4
 bsr draw
 dbf d7,aff_obj

; capture le sprite

 lea.l $1f8000+8*$a0,a0
 move.w #83,d0
capture
n set 0
 rept 6
 move.w n(a0),(a6)+
n set n+8
 endr
 lea.l $a0(a0),a0
 dbf d0,capture

; augmente angle de rotation

 add.w #4*2,alpha
 cmp.w #1440,alpha
 bne nofinalpha
 clr.w alpha
 rts
nofinalpha
 bra prec_sprite2



; sous routine de tracage de ligne 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Tracage de ligne sans sauvegarde du fond.Algo de Lucas
;
;A4=ecran (D0,D1)-(D2-D3)=(X0,Y0)-(X1,Y1)

draw	movem.l	d0-d7/a0-a5,-(sp);on les sauve
	move.w	d0,d4		;calcul Dx
	sub.w	d2,d4		;
	bpl.s	draw_00		;Si plus,ok
	neg.w	d4		;arg,inverse les points
	exg	d1,d3		;(affichage de droite …
	move.w	d2,d0		;gauche)
draw_00	move.w	#160,d6		;sens vertical
	sub.w	d1,d3		;Calcul Dy
	mulu	d6,d1		;offset du point [Conserve X]
	roxr.w	#1,d2		;r‚cupŠre X [D2 inutilis‚]
	bpl.s	draw_01		;Le signe de Dy correct
	neg.w	d3		;Ben bon,on remonte.
	neg.w	d6		;et on inverse donc le sens
draw_01	move.l	a4,a0		;
	move.w	d0,d2		;
	lsr.w	#4,d0		;divise par 16

	lsl.w	#3,d0		;*4 ou *2 selon r‚solution

	add.w	d0,d1		;
	adda.w	d1,a0		;hop
	not.w	d2		;maintenant,No de bit pour
	andi.w	#$0f,d2		;le 1er pixel
	moveq	#0,d1		;
	bset	d2,d1		;bingo
	cmp.w	d4,d3		;Dy>Dx ?
	bgt.s	draw_10		;Oui

	move.w	d4,d2		;Algorithme de Lucas.
	move.w	d4,d5		;C'est le + court.
	lsr.w	#1,d2
draw_1	or.w	d1,(a0)
	suba.l #$1f8000,a0
	adda.l #$1f8000,a0
	rol.w	#1,d1
	bcc.s	draw_2
	subq.l	#8,a0		;4 ou 2 selon les r‚solutions
draw_2	sub.w	d3,d2
	bgt.s	draw_3
	adda.w	d6,a0
	add.w	d4,d2
draw_3	subq.w	#1,d5
	bgt.s	draw_1
draw_end
 movem.l (sp)+,d0-d7/a0-a5
 clr.l (a6)
 rts

draw_10	move.w	d3,d2
	move.w	d3,d5
	lsr.w	#1,d2
draw_11	or.w	d1,(a0)
	suba.l #$1f8000,a0
	adda.l #$1f8000,a0
	adda.w	d6,a0
	sub.w	d4,d2
	bgt.s	draw_12
	add.w	d3,d2
	rol.w	#1,d1
	bcc.s	draw_12
	subq.l	#8,a0
draw_12	subq.w	#1,d5
	bpl.s	draw_11
	bra.s	draw_end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fin de la routine de tracage de ligne

 section bss

new_coord even
 ds.w 52*3
 
 section data

alpha even
 dc.w 0

;;;;;;;;;;;;;;;;;;;;
; datas de l'objet ;
;;;;;;;;;;;;;;;;;;;;

nbre_plot equ 28
nbre_line equ 38 

object even
 dc.w -30,40,-10,-30,-20,-10,-10,-40,-10,10,-40,-10,30,-20,-10,30,40,-10,10,40,-10
 dc.w 10,20,-10,-10,20,-10,-10,40,-10,-10,0,-10,-10,-20,-10,10,-20,-10,10,0,-10
 dc.w -30,40,10,-30,-20,10,-10,-40,10,10,-40,10,30,-20,10,30,40,10,10,40,10
 dc.w 10,20,10,-10,20,10,-10,40,10,-10,0,10,-10,-20,10,10,-20,10,10,0,10
line even
 dc.w 0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,0,10,11,11,12,12,13,13,10
 dc.w 0+14,1+14,1+14,2+14,2+14,3+14,3+14,4+14,4+14,5+14,5+14,6+14,6+14,7+14,7+14,8+14,8+14,9+14,9+14,0+14
 dc.w 10+14,11+14,11+14,12+14,12+14,13+14,13+14,10+14
 dc.w 0,14,1,15,2,16,3,17,4,18,5,19,6,20,7,21,8,22,9,23

cosinus even
 incbin cosinus.dat
