***************************************************************************
* Hello ICTARI members! Yep, it's me again (Ralph) and this time I've got
* a colour cycling routine for you which uses the STE palette but should
* work just as well on a standard ST.
* If you want it to run in medium resolution, simply remove the trap #14
* instruction below, and change the "move (a0)+,$ffff825e.w" command in the
* hbl routine to "move (a0)+,$ffff8246.w", as the text colour is different
* for medium resolution.
* Likewise, if you want to have the cycle in the background (rasters style)
* you can change it to "move (a0)+,$ffff8240.w". This gives you around
* 300 colours on screen.
* This routine can easily be incorporated into any program; just remember
* to reload the palette etc. at the start of your vertical blank routine.
* Should the synchronisation required for the horizontal blank cause
* problems, I suggest you use timer B instead - the disadvantage is that
* this method cannot manipulate every visible scanline!
* NOTE: Set your tabs to 10 for everything to make sense. (?!)
* And if anyone has ST Internals, please call me on 0367 241940. Thanks!
***************************************************************************

	clr	-(sp)
	pea	-1.w
	pea	-1.w
	move	#5,-(sp)
	trap	#14		Switch to low res (not essential)
	add.l	#12,sp

	pea	start(pc)
	move	#38,-(sp)
	trap	#14		Execute routine in supervisor mode
	addq.l	#6,sp
	
	move.w	#1,-(sp)
	pea	-1.w
	pea	-1.w
	move	#5,-(sp)
	trap	#14		Switch back to medium res
	add.l	#12,sp

	clr	-(sp)		exit
	trap	#1


start	move.b	#$12,$fffffc02.w	disable mouse
	bclr.b	#5,$fffffa09.w	disable timer C (prevents flicker)

	move.l	$70.w,oldvbl	save the old vbl
	move.l	$68.w,oldhbl	save the old hbl

	clr.w	$ffff8240.w	Background = black
	clr.w	$ffff825e.w	Text = black

	move.l	#text,-(sp)
	move.w	#9,-(sp)
	trap	#1		Print silly text
	addq.l	#6,sp
	
	move.l	#vbl,$70.w	install new vbl
	move.l	#hbl,$68.w	install new hbl
	move	#$2100,sr		set interrupt level

testkey	cmp.b	#$39,$fffffc02.w	check for space bar
	bne.s	testkey

	move.w	#$777,$ffff8240.w	Background = white
	clr.w	$ffff825e.w	Text = black

	move.l	oldhbl,$68.w	load old hbl
	move.l	oldvbl,$70.w	load old vbl

	bset.b	#5,$fffffa09.w	enable timer C (for keyboard input)
	move.b	#8,$fffffc02.w	enable mouse

	rts			user mode

***
vbl	move.l	#pal,offset	reload the palette
	add.l	#2,counter	move down colour table
	cmp.l	#1276,counter	end of table?
	bne.s	continue
	clr.l	counter		back to start of table
continue	move.l	counter(pc),d0
	add.l	d0,offset		pointer to colour for 1st scanline
	rte

***
hbl	dcb.w	88,$4e71		synchronise (88 NOPs)
	move.l	a0,-(sp)
	move.l	offset(pc),a0	get offset into color palette
	move	(a0)+,$ffff825e.w	next color -> next scanline
	move.l	a0,offset		store next color
	move.l	(sp)+,a0
	rte

***************************************************************************
	section	data

text	dc.b	"  The Chromatastic STE Colour Cycle...",13,10
	dc.b	"         Coded by Ralph Lovesy",13,10
	dc.b	"             (aka Axolotl)",13,10
	dc.b	"            in January 1994.",13,10,13,10
	dc.b	"      Some technical information:",13,10
	dc.b	"    The effect is created by using",13,10
	dc.b	"   the Horizontal Blank Auto-Vector",13,10
	dc.b	"       Interrupt at address $68.",13,10,13,10
	dc.b	"  The colours are read off a table of",13,10
	dc.b	"    values and the palette offset is",13,10
	dc.b	"    incremented every vertical blank",13,10
	dc.b	"     after reloading the palette...",13,10,13,10
	dc.b	"  The speed of the colour cycle can be",13,10
	dc.b	"changed by altering the amount by which",13,10
	dc.b	'  the value "counter" is incremented',13,10
	dc.b	" at the start of every vertical blank.",13,10,13,10
	dc.b	"  Although this effect was designed for",13,10
	dc.b	"    STE machines, it works on all STs,",13,10
	dc.b	"  as the extra bits of the STE palette",13,10
	dc.b	"     are ignored by the ST/F/M/FM!",13,10
	dc.b	"  Hope this is useful or inspirational!"
	dc.b	0	

pal	dcb.w	24
	dc.w	$00F,$00F,$00F,$00F,$80F,$00F,$80F,$80F
	dc.w	$80F,$80F,$80F,$10F,$80F,$10F,$10F,$10F
	dc.w	$10F,$10F,$90F,$10F,$90F,$90F,$90F,$90F
	dc.w	$90F,$20F,$90F,$20F,$20F,$20F,$20F,$20F
	dc.w	$A0F,$20F,$A0F,$A0F,$A0F,$A0F,$A0F,$A0F
	dc.w	$30F,$A0F,$30F,$30F,$30F,$30F,$30F,$B0F
	dc.w	$30F,$B0F,$B0F,$B0F,$B0F,$B0F,$40F,$B0F
	dc.w	$40F,$40F,$40F,$40F,$40F,$C0F,$40F,$C0F
	dc.w	$C0F,$C0F,$C0F,$C0F,$50F,$C0F,$50F,$50F
	dc.w	$50F,$50F,$50F,$D0F,$50F,$D0F,$D0F,$D0F
	dc.w	$D0F,$D0F,$60F,$D0F,$60F,$60F,$60F,$60F
	dc.w	$60F,$E0F,$60F,$E0F,$E0F,$E0F,$E0F,$E0F
	dc.w	$70F,$E0F,$70F,$70F,$70F,$70F,$70F,$F0F
	dc.w	$70F,$F0F,$F0F,$F0F,$F0F,$F0F,$F07,$F0F
	dc.w	$F07,$F07,$F07,$F07,$F07,$F0E,$F07,$F0E
	dc.w	$F0E,$F0E,$F0E,$F0E,$F06,$F0E,$F06,$F06
	dc.w	$F06,$F06,$F06,$F0D,$F06,$F0D,$F0D,$F0D
	dc.w	$F0D,$F0D,$F05,$F0D,$F05,$F05,$F05,$F05
	dc.w	$F05,$F0C,$F05,$F0C,$F0C,$F0C,$F0C,$F0C
	dc.w	$F04,$F0C,$F04,$F04,$F04,$F04,$F04,$F0B
	dc.w	$F04,$F0B,$F0B,$F0B,$F0B,$F0B,$F03,$F0B
	dc.w	$F03,$F03,$F03,$F03,$F03,$F0A,$F03,$F0A
	dc.w	$F0A,$F0A,$F0A,$F0A,$F02,$F0A,$F02,$F02
	dc.w	$F02,$F02,$F02,$F09,$F02,$F09,$F09,$F09
	dc.w	$F09,$F09,$F01,$F09,$F01,$F01,$F01,$F01
	dc.w	$F01,$F08,$F01,$F08,$F08,$F08,$F08,$F08
	dc.w	$F00,$F08,$F00,$F00,$F00,$F00,$F00,$F80
	dc.w	$F00,$F80,$F80,$F80,$F80,$F80,$F10,$F80
	dc.w	$F10,$F10,$F10,$F10,$F10,$F90,$F10,$F90
	dc.w	$F90,$F90,$F90,$F90,$F20,$F90,$F20,$F20
	dc.w	$F20,$F20,$F20,$FA0,$F20,$FA0,$FA0,$FA0
	dc.w	$FA0,$FA0,$F30,$FA0,$F30,$F30,$F30,$F30
	dc.w	$F30,$FB0,$F30,$FB0,$FB0,$FB0,$FB0,$FB0
	dc.w	$F40,$FB0,$F40,$F40,$F40,$F40,$F40,$FC0
	dc.w	$F40,$FC0,$FC0,$FC0,$FC0,$FC0,$F50,$FC0
	dc.w	$F50,$F50,$F50,$F50,$F50,$FD0,$F50,$FD0
	dc.w	$FD0,$FD0,$FD0,$FD0,$F60,$FD0,$F60,$F60
	dc.w	$F60,$F60,$F60,$FE0,$F60,$FE0,$FE0,$FE0
	dc.w	$FE0,$FE0,$F70,$FE0,$F70,$F70,$F70,$F70
	dc.w	$F70,$FF0,$F70,$FF0,$FF0,$FF0,$FF0,$FF0
	dc.w	$FF0,$FF0,$FF0,$FF0,$FF0,$FF0,$FF0,$FF0
	dc.w	$7F0,$FF0,$7F0,$7F0,$7F0,$7F0,$7F0,$EF0
	dc.w	$7F0,$EF0,$EF0,$EF0,$EF0,$EF0,$6F0,$EF0
	dc.w	$6F0,$6F0,$6F0,$6F0,$6F0,$DF0,$6F0,$DF0
	dc.w	$DF0,$DF0,$DF0,$DF0,$5F0,$DF0,$5F0,$5F0
	dc.w	$5F0,$5F0,$5F0,$CF0,$5F0,$CF0,$CF0,$CF0
	dc.w	$CF0,$CF0,$4F0,$CF0,$4F0,$4F0,$4F0,$4F0
	dc.w	$4F0,$BF0,$4F0,$BF0,$BF0,$BF0,$BF0,$BF0
	dc.w	$3F0,$BF0,$3F0,$3F0,$3F0,$3F0,$3F0,$AF0
	dc.w	$3F0,$AF0,$AF0,$AF0,$AF0,$AF0,$2F0,$AF0
	dc.w	$2F0,$2F0,$2F0,$2F0,$2F0,$9F0,$2F0,$9F0
	dc.w	$9F0,$9F0,$9F0,$9F0,$1F0,$9F0,$1F0,$1F0
	dc.w	$1F0,$1F0,$1F0,$8F0,$1F0,$8F0,$8F0,$8F0
	dc.w	$8F0,$8F0,$0F0,$8F0,$0F0,$0F0,$0F0,$0F0
	dc.w	$0F0,$0F8,$0F0,$0F8,$0F8,$0F8,$0F8,$0F8
	dc.w	$0F1,$0F8,$0F1,$0F1,$0F1,$0F1,$0F1,$0F9
	dc.w	$0F1,$0F9,$0F9,$0F9,$0F9,$0F9,$0F2,$0F9
	dc.w	$0F2,$0F2,$0F2,$0F2,$0F2,$0FA,$0F2,$0FA
	dc.w	$0FA,$0FA,$0FA,$0FA,$0F3,$0FA,$0F3,$0F3
	dc.w	$0F3,$0F3,$0F3,$0FB,$0F3,$0FB,$0FB,$0FB
	dc.w	$0FB,$0FB,$0F4,$0FB,$0F4,$0F4,$0F4,$0F4
	dc.w	$0F4,$0FC,$0F4,$0FC,$0FC,$0FC,$0FC,$0FC
	dc.w	$0F5,$0FC,$0F5,$0F5,$0F5,$0F5,$0F5,$0FD
	dc.w	$0F5,$0FD,$0FD,$0FD,$0FD,$0FD,$0F6,$0FD
	dc.w	$0F6,$0F6,$0F6,$0F6,$0F6,$0FE,$0F6,$0FE
	dc.w	$0FE,$0FE,$0FE,$0FE,$0F7,$0FE,$0F7,$0F7
	dc.w	$0F7,$0F7,$0F7,$0FF,$0F7,$0FF,$0FF,$0FF
	dc.w	$0FF,$0FF,$07F,$0FF,$07F,$07F,$07F,$07F
	dc.w	$07F,$0EF,$07F,$0EF,$0EF,$0EF,$0EF,$0EF
	dc.w	$06F,$0EF,$06F,$06F,$06F,$06F,$06F,$0DF
	dc.w	$06F,$0DF,$0DF,$0DF,$0DF,$0DF,$05F,$0DF
	dc.w	$05F,$05F,$05F,$05F,$05F,$0CF,$05F,$0CF
	dc.w	$0CF,$0CF,$0CF,$0CF,$04F,$0CF,$04F,$04F
	dc.w	$04F,$04F,$04F,$0BF,$04F,$0BF,$0BF,$0BF
	dc.w	$0BF,$0BF,$03F,$0BF,$03F,$03F,$03F,$03F
	dc.w	$03F,$0AF,$03F,$0AF,$0AF,$0AF,$0AF,$0AF
	dc.w	$02F,$0AF,$02F,$02F,$02F,$02F,$02F,$09F
	dc.w	$02F,$09F,$09F,$09F,$09F,$09F,$01F,$09F
	dc.w	$01F,$01F,$01F,$01F,$01F,$08F,$01F,$08F
	dc.w	$08F,$08F,$08F,$08F,$00F,$08F,$00F,$00F
	dc.w	$00F,$00F,$80F,$00F,$80F,$80F,$80F,$80F
	dc.w	$80F,$10F,$80F,$10F,$10F,$10F,$10F,$10F
	dc.w	$90F,$10F,$90F,$90F,$90F,$90F,$90F,$20F
	dc.w	$90F,$20F,$20F,$20F,$20F,$20F,$A0F,$20F
	dc.w	$A0F,$A0F,$A0F,$A0F,$A0F,$A0F,$30F,$A0F
	dc.w	$30F,$30F,$30F,$30F,$30F,$B0F,$30F,$B0F
	dc.w	$B0F,$B0F,$B0F,$B0F,$40F,$B0F,$40F,$40F
	dc.w	$40F,$40F,$40F,$C0F,$40F,$C0F,$C0F,$C0F
	dc.w	$C0F,$C0F,$50F,$C0F,$50F,$50F,$50F,$50F
	dc.w	$50F,$D0F,$50F,$D0F,$D0F,$D0F,$D0F,$D0F
	dc.w	$60F,$D0F,$60F,$60F,$60F,$60F,$60F,$E0F
	dc.w	$60F,$E0F,$E0F,$E0F,$E0F,$E0F,$70F,$E0F
	dc.w	$70F,$70F,$70F,$70F,$70F,$F0F,$70F,$F0F
	dc.w	$F0F,$F0F,$F0F,$F0F,$F07,$F0F,$F07,$F07
	dc.w	$F07,$F07,$F07,$F0E,$F07,$F0E,$F0E,$F0E
	dc.w	$F0E,$F0E,$F06,$F0E,$F06,$F06,$F06,$F06
	dc.w	$F06,$F0D,$F06,$F0D,$F0D,$F0D,$F0D,$F0D
	dc.w	$F05,$F0D,$F05,$F05,$F05,$F05,$F05,$F0C
	dc.w	$F05,$F0C,$F0C,$F0C,$F0C,$F0C,$F04,$F0C
	dc.w	$F04,$F04,$F04,$F04,$F04,$F0B,$F04,$F0B
	dc.w	$F0B,$F0B,$F0B,$F0B,$F03,$F0B,$F03,$F03
	dc.w	$F03,$F03,$F03,$F0A,$F03,$F0A,$F0A,$F0A
	dc.w	$F0A,$F0A,$F02,$F0A,$F02,$F02,$F02,$F02
	dc.w	$F02,$F09,$F02,$F09,$F09,$F09,$F09,$F09
	dc.w	$F01,$F09,$F01,$F01,$F01,$F01,$F01,$F08
	dc.w	$F01,$F08,$F08,$F08,$F08,$F08,$F00,$F08
	dc.w	$F00,$F00,$F00,$F00,$F00,$F80,$F00,$F80
	dc.w	$F80,$F80,$F80,$F80,$F10,$F80,$F10,$F10
	dc.w	$F10,$F10,$F10,$F90,$F10,$F90,$F90,$F90
	dc.w	$F90,$F90,$F20,$F90,$F20,$F20,$F20,$F20
	dc.w	$F20,$FA0,$F20,$FA0,$FA0,$FA0,$FA0,$FA0
	dc.w	$F30,$FA0,$F30,$F30,$F30,$F30,$F30,$FB0
	dc.w	$F30,$FB0,$FB0,$FB0,$FB0,$FB0,$F40,$FB0
	dc.w	$F40,$F40,$F40,$F40,$F40,$FC0,$F40,$FC0
	dc.w	$FC0,$FC0,$FC0,$FC0,$F50,$FC0
	
	section	bss
	
counter	ds.l	1
offset	ds.l	1
oldhbl	ds.l	1
oldvbl	ds.l	1

* Th-th-th-tha-that's all folks!