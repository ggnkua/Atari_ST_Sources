;
; 4 September 1994
;

	****************************
	* Reset centronics port to *
	* enable Deskjet to print  *
	* if switched on after ST  *
	****************************
	* CPX Version              *
	****************************

	OPT	A+,O+
	OUTPUT	.CP

	INCLUDE TOSCALLS.S
	INCLUDE GEMMACRO.I
	INCLUDE DJRESET4.I

;
; Offsets from XCPB
;
x_handle	equ	0
x_booting	equ	2
x_SkipRshFix equ	6
x_rsh_obfix	equ	20
x_form_do	equ	52

	SECTION DATA
;
; cpxinfo structure
;
cpxinfo	dc.l	cpx_call
	dcb.l	9,0
	
	SECTION TEXT	

cpx_init	move.l	4(A7),A6		' Save XCPB
	move.l	A6,xcpb
	appl_init
	tst.w	x_booting(A6)
	beq.s	.notboot
	moveq.l	#-1,D0
	rts

.notboot	tst.w	x_SkipRshFix(A6)
	bne.s	.notfix
	bsr.s	rsc_fix
.notfix	move.l	#cpxinfo,D0
	rts


rsc_fix	lea	our_rsc,A0		start of embedded RSC file

	move.w	18(A0),D0		index to trees
	lea	(A0,D0.W),A4	start of trees
	move.w	22(A0),D4		no. of trees

	BRA.S	endfix

fixloop1	move.l	(A4)+,A3		start of next tree
	clr.w	D3		object number
	clr.l	D5		object offset

fixloop2	move.w	D3,-(A7)		go fix up co-ords
	move.l	A3,-(A7)
	move.l	x_rsh_obfix(A6),A0
	jsr	(A0)
	addq.l	#6,A7

	move.w	8(A3,D5.L),D0	flags
	BTST	#5,D0		last object?
	BNE.S	endfix

	addq.w	#1,D3		next object
	add.l	#24,D5		next offset
	BRA.S	fixloop2
	
endfix	DBRA	D4,fixloop1		more trees to do?
	rts



cpx_call	move.l	4(A7),A5		pointer to rectangle
	lea	tr_CPXForm,A0	put screen coords in tree
	move.w	(A5),16(A0)
	move.w	2(A5),18(A0)

	objc_draw	#tr_CPXForm,#0,#9,(A5),2(A5),4(A5),6(A5)

main_loop	move.l	xcpb,A6		get xcpb pointer back
	pea	msg_buffer
	move.w	#0,-(A7)
	pea	tr_CPXForm
	move.l	x_form_do(A6),A0
	jsr	(A0)
	lea	10(A7),A7
	move.w	D0,D7
	
	cmp.w	#-1,D7
	bne.s	nomessage
				* process messages
	cmp.w	#41,msg_buffer	AC_CLOSE?
	beq.s	exit_loop
	cmp.w	#22,msg_buffer	WM_CLOSE?
	beq.s	exit_loop
	bra.s	main_loop

nomessage	and.w	#$7FFF,D7
	cmp.w	#form_Cancel,D7
	beq.s	exit_loop

	cmp.w	#form_OK,D7
	bne.s	main_loop

	pea	reset		go do the reset
	call_xbios	$26,6

exit_loop	clr.w	D0
	rts	



reset	lea	($ff8800).l,a0	address of YM-2149 registers
	move.b	#$e,(a0)		select port A register
	move.b	(a0),d0		read port A settings
	ori.b	#$20,d0		set Centronics strobe
	move.b	d0,2(a0)		write values to Port A
	RTS


	INCLUDE AESLIB.S

	SECTION DATA

our_rsc
	INCLUDE DJRESET4.RS

	SECTION BSS
xcpb	ds.l	1
msg_buffer	DS.W	8

