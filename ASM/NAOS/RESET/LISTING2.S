*         LISTING No 2          *
*                               *
*    Exemple d'installation     *
*       d'une reset d‚mo        *
*                               *
*  ST Mag - Ric de NAOS - 1993  *

	opt	x+

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,-(sp)
	
; initialisation pour que l'‚cran
; plac‚ en 'incbin' a la fin tourne
; en reset demo.
	jsr	ResetDemo
	
	move.l	$70.w,SaveVBL
	move.l	#MainRTE,$70.w

; ceci est mon programme en train
; de tourner...
; (on sort avec ESCAPE)

main	stop	#$2300
	cmp.b	#$1,$fffffc02.w
	bne.s	main

; d‚sactive le reset (au cas o—...)
	clr.l	$426.w
	clr.l	$4d2.w
	move.l	SaveVBL,$70.w

	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1

SaveVBL	dc.l	0
MainRTE	rte
	
ResetDemo	incbin	a:\resetdmo.bin


