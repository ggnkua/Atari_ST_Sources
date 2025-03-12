
	include	incdir/gemmacro.s
	include	incdir/aeslib.s

;		RSSET	4
;		RS.B	1
;		RS.B	1
;		RS.B	1
;		RS.B	1
;m_about	RS.B	1
;		RS.B	6+1
;m_return	RS.B	1

m_about	=	7
m_return	=	16

MN_SELECTED	EQU	10
ob_flags	EQU	8
ob_sizeof	EQU	24

*------------------------------------------------------------------------*

DropDownMenu:
	appl_init
	jsr		V_Free
	graf_mouse	#0
	tst.w		MenuCnv
	bne.s		.sk		; object tree already fixed
	lea		MenuBar,a3
	bsr		FixObject 
	move.w	#1,MenuCnv	; make code re-entrant for Dug.
.sk	menu_bar	#MenuBar,#1	; put up menu bar.
EventLoop:
	evnt_mesag	#messbuf
	move.w	messbuf,d0
	cmp.w		#MN_SELECTED,d0
	bne.s		EventLoop		; we only handle menu options

menuoption:
	move.w	messbuf+8,d0	; get menu number
	cmp.w		#m_about,d0
	beq.s		prog_info
	cmp.w		#m_return,d0
	beq		prog_return
	bra		EventLoop

prog_info:
	form_alert		#1,#apex_alert
	menu_tnormal	#MenuBar,messbuf+6,#1
	bra			EventLoop

prog_return:
	menu_tnormal	#MenuBar,messbuf+6,#1
	menu_bar		#MenuBar,#0	; remove menu bar and return to apex.
	appl_exit
	rts

FixObject:
	moveq		#0,d3
	move.l	a3,a0
.loop	move.l	a0,-(sp)
	rsrc_obfix	a3,d3
	move.l	(sp)+,a0
	btst		#5,ob_flags+1(a0)
	bne.s		.done
	addq.w	#1,d3
	add.w		#ob_sizeof,a0
	bra.s		.loop
.done	rts

*------------------------------------------------------------------------*

MenuCnv:	dc.w	0
MenuBar:
_o0	dc.w	-1,1,5,25,0,0,0,0,0,0,80,25
_o1	dc.w	5,2,2,20,0,0
	dc.l	$1181
	dc.w	0,0,80,513
_o2	dc.w	1,3,4,25,0,0,0,0,1,0,15,769
_o3	dc.w	4,-1,-1,32,0,0
	dc.l	_s0
	dc.w	0,0,6,769
_o4	dc.w	2,-1,-1,32,0,0
	dc.l	_s1
	dc.w	6,0,9,769
_o5	dc.w	0,6,15,25,128,0,0,0,1,769,128,3351
_o6	dc.w	15,7,14,20,0,0
	dc.l	$FFFF1181
	dc.w	0,0,20,8
_o7	dc.w	8,-1,-1,28,0,0
	dc.l	_s2
	dc.w	0,0,20,1
_o8	dc.w	9,-1,-1,28,0,8
	dc.l	_s3
	dc.w	0,1,20,1
_o9	dc.w	10,-1,-1,28,0,0
	dc.l	_s4
	dc.w	0,2,20,1
_o10	dc.w	11,-1,-1,28,0,0
	dc.l	_s5
	dc.w	0,3,20,1
_o11	dc.w	12,-1,-1,28,0,0
	dc.l	_s6
	dc.w	0,4,20,1
_o12	dc.w	13,-1,-1,28,0,0
	dc.l	_s7
	dc.w	0,5,20,1
_o13	dc.w	14,-1,-1,28,0,0
	dc.l	_s8
	dc.w	0,6,20,1
_o14	dc.w	6,-1,-1,28,0,0
	dc.l	_s9
	dc.w	0,7,20,1
_o15	dc.w	5,16,16,20,0,0
	dc.l	$FFFF1181
	dc.w	6,0,16,1
_o16	dc.w	15,-1,-1,28,32,0
	dc.l	_s10
	dc.w	0,0,16,1
_s3	dc.b	'--------------------',0
_s4	dc.b	'',0
_s5	dc.b	'',0
_s6	dc.b	'',0
_s7	dc.b	'',0
_s8	dc.b	'',0
_s9	dc.b	'',0
	even

messbuf:	ds.w		8

*------------------------------------------------------------------------*
