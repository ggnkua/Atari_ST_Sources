;
; Routine de recherche des boots
;
; Appel par ~C:rout%(L:buffer%,L:bilio%+6,L:biblio%+6+nombre_boot&*30)
;


	move.l	4(sp),a0
	move.l	8(sp),a1	
	move.l	12(sp),a2

debut:

	move.b	(a1),d0
	cmp.b	1(a0),d0
	bne.s	non
	move.b	1(a1),d0
	cmp.b	58(a0),d0
	bne.s	non
	move.b	2(a1),d0
	cmp.b	66(a0),d0
	bne.s	non
	move.b	3(a1),d0
	cmp.b	87(a0),d0
	bne.s	non
	move.b	4(a1),d0
	cmp.b	109(a0),d0
	bne.s	non
	move.b	5(a1),d0
	cmp.b	116(a0),d0
	bne.s	non
	move.b	6(a1),d0
	cmp.b	139(a0),d0
	bne.s	non
	move.b	7(a1),d0
	cmp.b	147(a0),d0
	bne.s	non
	move.b	8(a1),d0
	cmp.b	169(a0),d0
	bne.s	non
	move.b	9(a1),d0
	cmp.b	182(a0),d0
	bne.s	non
	lea 	10(a1),a1
	lea	name(pc),a3
	move.l	a1,(a3)
	rts

non:

	lea	30(a1),a1
	cmp.l	a2,a1
	blt.s	debut
	rts

name:	dc.l	0

	rts
	rts

