;
; Extension de signe d'un mot de 24 bits
;

	globl	DspTo32;

DspTo32:
	swap	d0
	lsl.l	#8,d0
	and.l	#$FF000000,d0
	and.l	#$00FFFFFF,d1
	or.l	d1,d0
	rts
	