;
; LZH TO MPK
;

	lea	source,a6
;
; copie longueur originelle
;
	movep	14(a6),d0
	move.b	13(a6),d0
	swap	d0
	movep	12(a6),d0
	move.b	11(a6),d0
;
; copie longueur pack‚e
;
	movep	10(a6),d1
	move.b	9(a6),d1
	swap	d1
	movep	8(a6),d1
	move.b	7(a6),d1

	clr	d2
	move.b	(a6),d2
	lea	2(a6,d2.w),a5

	clr	d2
	move.b	21(a6),d2
	lea	22(a6,d2.w),a4
;
; copie le CRC
;
	movep	1(a4),d2
	move.b	(a4),d2		;CRC

	move.l	d0,(a6)+	;longueur d‚pack‚e
;	move.l	d1,(a6)+	;longueur pack‚e (INUTILE !!!)
	move	d2,(a6)+
;
; copie le fichier
;
copy	move.b	(a5)+,(a6)+
	subq.l	#1,d1
	bhs.s	copy
	lea	source,a0
	move.l	a6,a1
	illegal
source:
	incbin	PAK.lzh
