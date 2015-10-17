	*************************
	* FULLSCREEN-MAKER V1.0 *
	* (C)1992 EPSILON & TMS *
	*************************

	lea name,a5
	lea full,a6
	move.l #end_full-full,d6
	jsr save
	clr.w -(sp)
	trap #1

	* Routine name *
name	dc.b "a:\integrat.ful\empty.ful",0
	even

	* Fullscreen-line routine *
full	move.w a1,(a1)
	dc.w "NO","P=",1
	move.b d0,(a1)

	dc.w "NO","P=",89

	move.b d0,(a0)
	move.w a1,(a0)

	dc.w "NO","P=",13

	move.w a1,(a1)
	dc.w "NO","P=",1
	move.b d0,(a1)

	dc.w "NO","P=",12

	dc.w -1
end_full	equ *

;
; Sauve un fichier A5 a l'adresse A6 de D6 octets
;
save	clr.w -(sp)
	pea (a5)
	move.w #$3c,-(sp)
	trap #1
	add.l #8,sp
	tst.w d0
	bmi fin_save
	move.w d0,d7
	pea (a6)
	move.l d6,-(sp)
	move.w d7,-(sp)
	move.w #$40,-(sp)
	trap #1
	add.l #12,sp
	tst.l d0
	bmi fin_save
	move.w d7,-(sp)
	move.w #$3e,-(sp)
	trap #1
	addq.l #4,sp
fin_save	rts

	end