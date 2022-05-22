;-----------------------------------------------------------------------;
; MR MUSIC	V2 - 1 CHANNEL VBL PLAYER  				;
; - Uses No Registers and plays 4 bit samples using channel 3.		;
; - Takes about 15% at 11khz with little or no varition.		;
; - Uses no sample shifting tables!! Uses proper integer/frac shifting.	;
; - Completly Position independent!					;
;-----------------------------------------------------------------------;

	clr.l	-(sp)			; Supervisor mode.
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	lea 	tune(pc),a0
	lea 	slist(pc),a1
	lea	vars(pc),a2
	move.l a0,(a2)+
	move.l a1,(a2)+
	bsr	find_stuff
	move.w	#$2700,sr		; interrupts Off.
	bsr	set_up_sound		; Set up sound chip.
	lea oldmfp(pc),a0
	move.b	$fffffa07.w,(a0)+	; Save MFP registers.
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa1d.w,(a0)+
	move.b	$fffffa25.w,(a0)+
	move.l	$70.w,(a0)+	
	move.l	$110.w,(a0)+
	move.b  #0,$fffffa07.w
	move.b	#$10,$fffffa09.w
	move.b  #0,$fffffa13.w
	move.b	#$10,$fffffa15.w
	bclr.b	#3,$fffffa17.w		; Software End Of Interrupt mode.
	lea player(pc),a0
	move.l	a0,$110.w
	lea vbl(pc),a0
	move.l	a0,$70.w
	clr.b $fffffa1d.w
	move.b	#14,$fffffa25.w		; 10.971 Khz (Replay Prof speed.)
	move.b	#3,$fffffa1d.w
	lea Buffer(PC),a0
	move.l a0,usp 
	move.w	#$2300,sr		; Enable interrupts past VBL.

key:	cmpi.b	#57,$fffffc02.w		; Wait for space bar to be pressed.
	bne.s	key

out:	move.w	#$2700,sr		; Restore MFP registers & vectors.
	lea oldmfp(pc),a0
	move.b	(a0)+,$fffffa07.w 
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa1d.w
	move.b	(a0)+,$fffffa25.w
	move.l	(a0)+,$70.w
	move.l	(a0)+,$110.w
	bset.b	#3,$fffffa17.w
flush:	btst.b	#0,$fffffc00.w	
	beq.s	fl_done
	move.b	$fffffc02.w,d0
	bra	flush
fl_done:move.w	#$2300,sr
	clr.w	-(sp)	
	trap	#1

oldmfp:	ds.l	5

;-------------------------------------------------------------------------;
;				INTERRUPTS				  ;
;-------------------------------------------------------------------------;

; VERTICAL BLANK INTERRUPT. THIS IS THE SEQUENCER.

bufsize	EQU 222

vbl:	movem.l	a0-a6/d0-d6,-(sp)	; Stack registers.
	lea	dur1(pc),a2		; Play channel 1 song.
	move.w	vcon(a2),d1
	bne.s	vcson1
	lea nul_sample(pc),A1
	bra.s go
vcson1	move.l	off(a2),d1
	beq.s	not1
	move.l	d1,saddr(a2)
not1	move.l	saddr(a2),A1
go	lea notetab(PC),a5
	adda note(a2),a5		; ptr to int.w/frac.w
	move.w frac(a2),d2
	moveq.l #0,d5
	movem.w (a5),d3/d4		; int.w/frac.w
	lea Buffer(pc),a6
	lea bufsize(a6),a5
	move.l a5,d6
	move.w	#bufsize,d0
	move.l usp,a0
	move.l a0,d1
	sub.l a6,d1
	sub.l a0,d6
	beq.s .Skip
	sub.w d6,d0
	subq.w #1,d6
.loop	move.b (a0)+,(a6)+
	dbf d6,.loop
.Skip	move.l usp,a0
	sub.w d1,a0
	move.l a0,usp
	lea missbig(pc),a0
	lsl #3,d0
	sub d0,a0
	jmp (a0)
	rept bufsize
	move.b	0(a1,d5),(a6)+
	add d4,d2
	addx d3,d5
	endr 
missbig	add d5,a1
	move.w vcon(a2),d0
	beq.s vcoff1
	move.l	a1,saddr(a2)
	move.w  d2,frac(a2)
vcoff1	bsr	mr_music
	movem.l	(sp)+,a0-a6/d0-d6	; Restore registers.
	rte

* MUSIC CONTROLLER (THIS CALLS ALL THE SUBROUTINES)

mr_music:
	move.l	saddr(a2),off(a2)
loop_test:
	move.l	samples(pc),a1		; Get samples start address.
	move.l	a1,d0			; For addition.
	move.l	craddr(a2),a0		; Get current sample address.
	add.l	(a0)+,d0		; Get sample offset in D0.
	moveq	#0,d1
	move.w	(a0)+,d1		; Get sample length in D1.
	add.l	d1,d0			; Add sample length to D0.
	cmp.l	off(a2),d0		; Is it over length?
	bgt.s	noendl			; Nope... No loop yet.
	clr.w	new(a2)			; Yep...  Not new sample.
	tst.w	loop(a2)		; Loop sample?
	bne.s	loopit			; Yep... Loop test.
	clr.w	vcon(a2)		; If no loop, no play.
	clr.w	slidin(a2)		; No slide.
	bra.s	noendl
loopit:	sub.l	off(a2),d0		; Get excess playback.
	move.l	samples(pc),a1		; Get samples start address.
	move.l	a1,d1			; For addition.
	add.l	-6(a0),d1		; Now is sample address.
	move.l	d1,off(a2)		; Store it.
	moveq	#0,d1
	move.w	(a0)+,d1		; Get sample offset.
	sub.l	d0,d1			; Minus excess.
	add.l	d1,off(a2)		; Add to sample base address.
	bra.s endlooptest
noendl:	clr.l	off(a2)			; Don't reset pointer!
	clr.w	new(a2)
endlooptest:
	tst.w	(a2)			; Is duration on channel on?
	bne.s	nonew			; Nope... Keep on playing sample.
	move.l	sptr(a2),a0		; Yep... Get song pointer.
	tst.w	(a0)			; Pattern command or end?
	bpl.s	noend			; No... Get command.
	cmpi.w	#-9999,(a0)		; End of song?
	bne.s	pattern			; No, then it's a pattern loop.
	move.l	sptr+4(a2),a0		; Yes... Restore song pointer.
	bra.s	noend
pattern:bsr	do_loop			; Do pattern loops.
noend:	move.w	(a0)+,d2		; Get command word.
	btst	#0,d2			; NEW SAMPLE?
	beq.s	nosamp
	bsr	new_sample		; Go to sample routine.
nosamp:	btst	#1,d2			; NEW NOTE?
	beq.s	nonote
	bsr	new_note		; Yep... Go to note routine.
nonote:	btst	#2,d2			; SLIDE?
	beq.s	nslide			; Yep... Go to slide routine.
	bsr	slide_note
nslide:	btst	#3,d2
	beq.s	norest
	bsr	rest
norest:	move.l	a0,sptr(a2)		; Store new song pointer.
	btst	#14,d2			; Loop on this channel?
	beq.s	noloop
	move.w	#1,loop(a2)		; Yes... Signal loop flag.
	bra.s	yesl
noloop:	clr.w	loop(a2)		; No... Clear loop flag.
yesl:
nonew:	subq.w	#1,(a2)			; Countdown for next command.

; Slide test.

slideit:tst.w	slidin(a2)		; Are we sliding?
	beq.s	donesl			; Nope... So skip.
	move.w	note(a2),d0		; Yes... Get current note.
	cmp.w	6(a2),d0		; Is it = to destination note?
	beq.s	skipsl			; Yes... Stop sliding.
	subq.w	#1,scount(a2)		; No... Do slide rate...
	bne.s	donesl
	move.w	slide(a2),scount(a2)
	cmp.w	6(a2),d0		; Compare both notes.
	bgt.s	subit
	addq.w	#4,note(a2)		; Source > dest, so slide up.
	bra.s	donesl			; Continue sliding.
subit:	subq.w	#4,note(a2)		; Source < dest, so slide down.
	bra.s	donesl			; Continue sliding.
skipsl:	clr.w	slidin(a2)		; Signal no slide.
donesl:	rts

new_sample:
	move.l	samples(pc),a1		; Get samples start address.
	move.l	a1,d1			; Into D1 for addition.
	lea	slist(pc),a1		; Get sample address table.
	move.w	(a0)+,d0		; Get sample number
	lsl.w	#3,d0			; x 8 bytes per entry.
	adda.w	d0,a1			; Now A1 points to sample entries.
	add.l	(a1),d1			; = Sample address.
	move.l	d1,off(a2)		; Store it.
	move.w	#1,new(a2)		; Signal new sample.
	move.l	a1,craddr(a2)		; And store pointer for others.
	move.w	#1,vcon(a2)		; Enable playback.
	rts

new_note:
	move.l	samples(pc),a1		; Get samples start address.
	move.l	a1,d1			; For addition.
	tst.w	loop(a2)		; Am I looping?
	bne.s	on			; Yes.. Do loop.
	move.l	craddr(a2),a1		; No... Get sample pointer.
	add.l	(a1),d1			; And make it start of sample.
	move.l	d1,off(a2)		; Store new address.
	move.w	#1,new(a2)		; Signal new sample.
on:	move.w	(a0)+,d0		; Yes... Get note.
	add.w d0,d0
	add.w d0,d0
	move.w	d0,note(a2)		; Now new note.
	move.w	(a0)+,(a2)		; And new duration.
	move.w	#1,vcon(a2)		; Enable playback.
	rts

slide_note:
	move.w	(a0)+,d0		; Slide to note...
	add.w d0,d0
	add.w d0,d0
	move.w	d0,6(a2)
	move.w	(a0)+,d0		; Get slide delay value.
	move.w	d0,slide(a2)		; Put it in storage.
	move.w	d0,scount(a2)		; And in the counter.
	move.w	#1,slidin(a2)		; Signal slide in progress.
	move.w	(a0)+,dur(a2)		; Get duration.
	rts

rest:	move.w	(a0)+,(a2)		; Get duration of rest.
	clr.w	vcon(a2)		; And don't play.
	rts

do_loop:move.w	(a0)+,d0		; Get loop signal.
	move.b	(a0)+,d0		; Get loop value.
	move.b	(a0)+,d1		; Get loop counter.
	bne.s	keeplp			; Zero? No, more loops.
	move.b	d0,-1(a0)		; Restore loop counter.
	addq.w	#2,a0			; And go past loop address.
	tst.w	(a0)			; Is it a pattern command?
	bpl.s	moresng			; No, then play whatever.
	cmpi.w	#-9999,(a0)
	bne.s	do_loop
	move.l	sptr+4(a2),a0		; Yes... Restore song pointer.
moresng:rts
keeplp:	subq.b	#1,d1			; Increase loop counter.
	move.b	d1,-1(a0)		; Store counter.
	sub.w	(a0),a0			; And loop back to address.
	rts

nul_sample
	dcb.b 7*256,$80

; 12bit sample player - Through internal soundchip

player:	movem.l d7/a0,-(sp)
	move.l usp,a0
	clr d7
	move.b	(a0)+,d7
	move.l a0,usp
	move.b #$a,$ffff8800.w
	move.b  tab(pc,d7),$ffff8802.w
	movem.l (sp)+,d7/a0
	rte
tab	dcb.b 32,0
	dcb.b 32,9
	dcb.b 32,10
	dcb.b 32,11
	dcb.b 32,12
	dcb.b 32,13
	dcb.b 32,14
	dcb.b 32,15

Buffer	DCB.B bufsize,$80
EndBuffer
	EVEN

;-------------------------------------------------------------------------;
;				SUBROUTINES				  ;
;-------------------------------------------------------------------------;
	
; FIND TUNE. (Needed every time a new tune is played).
; + FIND SAMPLES + Initialise the voice structure

find_stuff:
	move.l	tuneptr(pc),a0		; Get tune pointer.
	lea dur1(pc),a1
	move.l	a0,sptr(a1)		; Store the channel's tune addr.
	move.l	a0,sptr+4(a1)		; Twice for the player.
fndsmps:lea samples(pc),a1
	move.l	(a1),a0			; Get voice set address.
.find	tst.w	(a0)			; See if negative.
	addq.w #8,a0
	bpl.s	.find			; No...  Continue search.
	subq.w	#6,a0
	move.l	a0,(a1)			; Store samples addresses.
initvce:lea dur1(pc),a0
	move #1,dur(a0)
	clr note(a0)
	clr loop(a0)
	clr slide(a0)
	clr slidin(a0)
	lea.l nul_sample(pc),a1
	move.l a1,craddr(a0)
	move.w #1,vcon(a0)
	move.l a1,off(a0)
	clr.w new(a0)
	move.l a1,saddr(a0)
	clr.w frac(a0)
	rts

; SET UP SOUNDCHIP
 
set_up_sound:
	MOVE #$8800,A0
	MOVE.B #7,(A0)
	MOVE.B #$C0,D0
	AND.B (A0),D0
	OR.B #$38,D0
	MOVE.B D0,2(A0)
	MOVE #$600,D0
.setup	MOVEP.W D0,(A0)
	SUB #$100,D0
	BPL.S .setup
	RTS

; 64 notes to generate tables...  Int and frac parts in word pairs.
; Generated using note formula in GFA Basic V3. Base freq: 440Hz.

notetab:dc.w	$0,$2AB7,$0,$2D41,$0,$2FF2,$0,$32CC
	dc.w	$0,$35D1,$0,$3904,$0,$3C68,$0,$4000
	dc.w	$0,$43CE,$0,$47D6,$0,$4C1C,$0,$50A2
	dc.w	$0,$556E,$0,$5A82,$0,$5FE4,$0,$6598
	dc.w	$0,$6BA2,$0,$7209,$0,$78D1,$0,$8000
	dc.w	$0,$879C,$0,$8FAD,$0,$9838,$0,$A145
	dc.w	$0,$AADC,$0,$B505,$0,$BFC9,$0,$CB30
	dc.w	$0,$D745,$0,$E412,$0,$F1A2,$1,$0
	dc.w	$1,$F39,$1,$1F5A,$1,$3070,$1,$428B
	dc.w	$1,$55B9,$1,$6A0B,$1,$7F92,$1,$9661
	dc.w	$1,$AE8B,$1,$C825,$1,$E345,$2,$1
	dc.w	$2,$1E73,$2,$3EB5,$2,$60E1,$2,$8516
	dc.w	$2,$AB72,$2,$D416,$2,$FF24,$3,$2CC2
	dc.w	$3,$5D16,$3,$904A,$3,$C68A,$4,$3
	dc.w	$4,$3CE7,$4,$7D6A,$4,$C1C3,$5,$A2D
	dc.w	$5,$56E4,$5,$A82C,$5,$FE49,$6,$5985

; CHANNEL VARIABLES.	

vars
tuneptr:dc.l	0
samples:dc.l	0

	rsreset
dur:	rs.w	1
note:	rs.w	1
loop:	rs.w	1
snote:	rs.w	1
scount:	rs.w	1
slide:	rs.w	1
slidin:	rs.w	1
craddr:	rs.l	1
vcon:	rs.w	1
off:	rs.l	1
new:	rs.w	1
sptr:	rs.l	1
	rs.l	1
saddr	rs.l	1
frac	rs.w 	1
dsize	rs.b	1	

dur1:	ds.b	dsize

tune:	incbin d:\mrmusic.mus\l16.sng
slist:	incbin d:\mrmusic.mus\quar12.eit
	even
