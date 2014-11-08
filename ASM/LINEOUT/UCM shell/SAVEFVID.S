	COMMENT	HEAD=%111

	bra	START
	INCLUDE	IO.S

START:	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp

	lea	fvbuf,a0
	move.l	$ffff8282.w,(a0)+		* h-regs
	move.l	$ffff8286.w,(a0)+		* 
	move.l	$ffff828a.w,(a0)+		* 
	move.l	$ffff82a2.w,(a0)+		* v-regs
	move.l	$ffff82a6.w,(a0)+		* 
	move.l	$ffff82aa.w,(a0)+		* 
	move.w	$ffff82c0.w,(a0)+		* vco
	move.w	$ffff82c2.w,(a0)+		* c_s
	move.l	$ffff820e.w,(a0)+		* offset
	move.w	$ffff820a.w,(a0)+		* sync
	move.b  $ffff8256.w,(a0)+		* p_o
	clr.b   (a0)				* test of st(e) or falcon mode
	cmp.w   #$b0,$ffff8282.w		* hht kleiner $b0?
	sle     (a0)+				* flag setzen
	move.w	$ffff8266.w,(a0)+		* f_s
	move.w	$ffff8260.w,(a0)+		* st_s

	_SAVE	filename_txt,fvbuf,#40

	clr.w	-(sp)
	trap	#1

	DATA

filename_txt:
	DC.B	"VIDEO.VID",0
	EVEN

	BSS

fvbuf:	DS.B	40