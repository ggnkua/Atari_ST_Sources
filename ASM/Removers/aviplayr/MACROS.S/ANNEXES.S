*******************************
* Quelques macros bien utiles *
*******************************

Init_prg	macro
; Init_prg #taille_pile
	move.l	4(sp),a6
	move.l	12(a6),a5
	add.l	20(a6),a5
	add.l	28(a6),a5
	add.l	#$100,a5
	add.l	\1,a5
	move.l	a5,d1
	and.w	#$fffe,d1
	add.l	a6,d1
	move.l	d1,sp
	Mshrink	a6,a5
	endm
