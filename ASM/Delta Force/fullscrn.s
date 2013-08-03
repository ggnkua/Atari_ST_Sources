*************************************
**       Fullscreen-Routine        **
**       ~~~~~~~~~~~~~~~~~~        **
**       ½ by Felix Brandt         **
**          Jahnstr. 51            **
**        W-8130 Starnberg         **
**            Germany              **
**         : 11.11.1991            **
*************************************
	TEXT
	pea	start(PC)
	move.w	#38,-(SP)
	trap	#14
	addq.l	#6,SP
	clr.w	-(SP)
	trap	#1
;-----------------------------------------------------------------------------
start:
	bsr	install_all
	bsr	get_lines
	movea.l	screen(PC),A0
	lea	160(A0),A0
	move.w	#276-1,D0
doit:	REPT	26/2
	move.w	#%101010101010101,(A0)+
	move.w	#%11001100110011,(A0)+
	move.w	#%111100001111,(A0)+
	move.w	#%11111111,(A0)+
	move.w	#%1010101010101010,(A0)+
	move.w	#%1100110011001100,(A0)+
	move.w	#%1111000011110000,(A0)+
	move.w	#%1111111100000000,(A0)+
	ENDR
	lea	2*8+6(A0),A0
	dbra	D0,doit
	move.l	#fullvbl,$70.w
waiter:
	cmpi.b	#$39,$fffffc02.w
	bne.s	waiter
end:	bsr.s	restore_all
	rts

	>PART 'Install_All'
install_all:
	move.w	#$2700,SR
	move.b	$ffff820a.w,oldsync
	move.b	$ffff8260.w,oldres
	movem.l	$ffff8240.w,D0-D7
	movem.l	D0-D7,oldpalette
	lea	$ffff8201.w,A0
	movep.w	(A0),D0
	move.w	D0,oldscreen
	move.l	#screen_base,D0
	clr.b	D0
	move.l	D0,screen
	lsr.l	#8,D0
	lea	$ffff8201.w,A0
	movep.w	D0,(A0)
	bsr	init_mfp
	move.w	#$2300,SR
	moveq	#$12,D0
	bsr.s	send_ikbd
	bsr	vsync
	move.b	#2,$ffff820a.w
	bsr.s	vsync
	clr.b	$ffff8260.w
	movem.l	palette(PC),D0-D7
	movem.l	D0-D7,$ffff8240.w
	rts

	ENDPART
	>PART 'Restore_All'

restore_all:
	move.l	#vbl,$70.w
	bsr.s	vsync
	movem.l oldpalette,D0-D7
	movem.l D0-D7,$ffff8240.w
	bsr.s	vsync
	move.b	#2,$ffff820a.w
	bsr.s	vsync
	move.b	#0,$ffff820a.w
	bsr.s	vsync
	move.b  oldsync(PC),$ffff820a.w
	move.b  oldres(PC),$ffff8260.w
	bsr	restore_mfp
	moveq	#8,D0
	bsr.s	send_ikbd
	move.w	oldscreen(PC),D0
	lea     $ffff8201.w,A0
	movep.w	D0,(A0)
	rts

	ENDPART
	>PART 'Send_IKBD'

send_ikbd:
	lea	$fffffc00.w,A0
waitkeyready:
	btst	#1,(A0)
	beq.s	waitkeyready
	move.b	D0,2(A0)
	rts

	ENDPART
	>PART 'Vsync'

vsync:
	sf	vblflag
waitforsync:
	tst.b	vblflag
	beq.s	waitforsync
	rts

	ENDPART
	>PART 'MFP-Install+DeInstall'

init_mfp:
	move.l	$120.w,oldtimerb
	move.l	$70.w,oldvbl
	lea	$fffffa00.w,A0
	move.b	$07(A0),oldmfp07
	move.b	$09(A0),oldmfp09
	move.b	$11(A0),oldmfp11
	move.b	$13(A0),oldmfp13
	move.b  $15(A0),oldmfp15
	move.b  $17(A0),oldmfp17
	move.b  $1b(A0),oldmfp1b
	move.b  $21(A0),oldmfp21
	clr.b   $07(A0)
	clr.b   $09(A0)
	clr.b   $13(A0)
	clr.b   $15(A0)
	bset    #0,$07(A0)
	bset    #0,$13(A0)
	bclr    #3,$17(A0)
	move.l	#vbl,$70.w
	move.l	#timer_b,$0120.w
	rts

restore_mfp:
	move.w	#$2700,SR
	move.l	oldtimerb(PC),$0120.w
	move.l	oldvbl(PC),$70.w
	lea	$fffffa00.w,A0
	move.b	oldmfp07(PC),$07(A0)
	move.b	oldmfp09(PC),$09(A0)
	move.b	oldmfp11(PC),$11(A0)
	move.b	oldmfp13(PC),$13(A0)
	move.b	oldmfp15(PC),$15(A0)
	move.b	oldmfp17(PC),$17(A0)
	move.b	oldmfp1b(PC),$1b(A0)
	move.b	oldmfp21(PC),$21(A0)
	move.w	#$2300,SR
	rts

	ENDPART

vbl:	st	vblflag
	rte
timer_b:
	rte

	>PART 'Zeilen ermitteln'

get_lines:
	move.l	$70.w,-(SP)
	move.l	#testvbl1,$70.w
	bsr	vsync
	bsr	vsync
	subq.w	#3,scanlines
	cmpi.w	#216,scanlines
	blt.s	itsok
	move.w	#226,scanlines
itsok:	move.l	(SP)+,$70.w
	rts
testvbl1:
	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.l	#testb1,$0120.w
	move.b	#8,$fffffa1b.w
	move.l	#testvbl2,$70.w
	clr.b	$ffff820a.w
	st	vblflag
	rte
testvbl2:
	clr.b	$fffffa1b.w
	st	vblflag
	rte
testb1:
	addq.w	#1,scanlines
	move.b	#2,$ffff820a.w
	move.l	#testb2,$0120.w
	rte
testb2:	addq.w  #1,scanlines
	rte

	ENDPART
	>PART 'Fullscreen-Routinen'

fullvbl:
	move.l	#open_top,$68.w
	move.w	#33,hblcount
	move.w	#$2100,SR
	st	vblflag
	move.w	#$2100,(SP)
	rte
open_top:
	subq.w	#1,hblcount
	beq.s	openit
	rte
openit:
	move.l	#open_top2,$68.w
	stop	#$2100
open_top2:
	move.w	#$2700,SR
	addq.l	#6,SP
	REPT	86
	nop
	ENDR
	move.b	#0,$ffff820a.w
	REPT	17
	nop
	ENDR
	move.b	#2,$ffff820a.w
	lea	$ffff820a.w,A0
	lea	$ffff8260.w,A1
	moveq	#0,D0
waitsync:
	move.b	$ffff8209.w,D0
	beq.s	waitsync
	not.w	D0
	lsr.w	D0,D0
	REPT	70
	nop
	ENDR
	move.w	scanlines(PC),D7
lines:	nop
	move.w	A1,(A1)
	nop
	move.b	D0,(A1)
	REPT	89
	nop
	ENDR
	move.b	D0,(A0)
	move.w	A0,(A0)
	REPT	13
	nop
	ENDR
	move.w	A1,(A1)
	nop
	move.b	D0,(A1)
	REPT	11-3
	nop
	ENDR
	dbra	D7,lines
	move.w	A1,(A1)
	nop
	move.b	D0,(A1)
	REPT	89
	nop
	ENDR
	move.b	D0,(A0)
	move.w	A0,(A0)
	REPT	10
	nop
	ENDR
	move.w	D0,(A0)
	nop
	move.w	A1,(A1)
	nop
	move.b	D0,(A1)
	REPT	11
	nop
	ENDR
	move.w	A1,(A1)
	move.w	A0,(A0)
	move.b	D0,(A1)
	REPT	89
	nop
	ENDR
	move.b	D0,(A0)              ; [8]  Rechter Rand
	move.w	A0,(A0)
	REPT	13
	nop
	ENDR
	move.w	A1,(A1)
	nop
	move.b	D0,(A1)
	REPT	11-2
	nop
	ENDR
	move.w	#48-1,D7
lines2:	nop
	move.w	A1,(A1)
	nop
	move.b	D0,(A1)
	REPT	89
	nop
	ENDR
	move.b	D0,(A0)
	move.w	A0,(A0)
	REPT	13
	nop
	ENDR
	move.w	A1,(A1)
	nop
	move.b	D0,(A1)
	REPT	11-3
	nop
	ENDR
	dbra	D7,lines2
	move.w	#$2300,(SP)
	rte

	ENDPART
	DATA
palette:
	DC.W	$000,$001,$002,$003,$004,$005,$006,$007
	DC.W	$017,$117,$227,$337,$447,$557,$667,$777
hblcount:
	DC.W	-1
	BSS
screen:         DS.L 1
oldvbl:         DS.L 1
oldtimerb:      DS.L 1
oldpalette:     DS.W 16
oldscreen:      DS.W 1
scanlines:      DS.W 1
oldmfp07:       DS.B 1
oldmfp09:       DS.B 1
oldmfp11:       DS.B 1
oldmfp13:       DS.B 1
oldmfp15:       DS.B 1
oldmfp17:       DS.B 1
oldmfp1b:       DS.B 1
oldmfp21:       DS.B 1
oldres:         DS.B 1
oldsync:        DS.B 1
vblflag:        DS.B 1
                DS.B 256        ; wegen unteren 8 Bits des Screens
screen_base:    DS.B 230*277    ; Bildschirmspeicher
	END
