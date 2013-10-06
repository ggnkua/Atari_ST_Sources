
SKYEFFECTNBOFROUTS	equ	2-1



		text


; ---------------------------------------------------------
; ruft den aktivierten himmelseffekt auf.
; 15.09.00/vk
skyEffect
		movea.l	levelPtr,a6
		movea.l	LEVINITDATA(a6),a0
		adda.l	a6,a0

		tst.w	INITSKYEFFFLAG(a0)
		beq.s	seMoveOnly

		lea	skyEffectRouts,a1
		move.w	INITSKYEFFECT(a0),d0
		cmpi.w	#SKYEFFECTNBOFROUTS,d0
		bgt.s	seOut
		movea.l	(a1,d0.w*4),a1
		jsr	(a1)
		bra.s	seOut

seMoveOnly
		move.w	$468.w,d0
		lsr.w	#4,d0
		move.w	d0,skyMoveCounter

seOut
		rts

; ---------------------------------------------------------
; 15.09.00/vk
skyEffect0
		clr.w	skyMoveCounter
		rts


; ---------------------------------------------------------
; 15.09.00/vk
skyEffect1
		clr.w	skyMoveCounter
		rts






		data


; arraygroesse durch konstante skyeffectnbofrouts bestimmt
skyEffectRouts	dc.l	skyEffect0
		dc.l	skyEffect1




		bss


skyMoveCounter	ds.w	1

