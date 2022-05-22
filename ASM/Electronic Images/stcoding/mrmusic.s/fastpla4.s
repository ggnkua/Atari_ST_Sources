;-----------------------------------------------------------------------;
;			      * MR MUSIC * 				;
;									;
; Four Channel 8 bit sample player/sequencer programmed by :-		;
; Jose Commins of (Concept,data format and basic sequencer)  		;
; Martin 'the length' Griffiths.(Convertor, sequencer and optimisation)	;
; The Sequencer has been totally re-coded in this version(4 scanlines!)	;
; This version leaves D0-D5 and A0-A1 free to play with.		;
;-----------------------------------------------------------------------;
; It is faster than all the other players, but has the crappy disadvantage
; of leaving you with two address and six data registers.
; This takes approx 42% at 11 khz and 28% at 8khz

	clr.l	-(sp)			; Supervisor mode.
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp
	move.w	#$2700,sr		; Off with all interrupts.
	lea	old_stuff(pc),a0
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa1d.w,(a0)+
	move.b	$fffffa25.w,(a0)+
	move.l	$70.w,(a0)+		
	move.l	$110.w,(a0)+
	bsr	gentabs			; Generate note tables.
	bsr	find_tune
	bsr	find_samples
	lea	dur1(pc),a0
	bsr	initvoice
	lea	dur2(pc),a0
	bsr	initvoice
	lea	dur3(pc),a0
	bsr	initvoice
	lea	dur4(pc),a0
	bsr	initvoice
	clr.b	$fffffa07.w
	move.b	#%00010000,$fffffa09.w
	clr.b	$fffffa13.w
	move.b	#%00010000,$fffffa15.w
	bclr.b	#3,$fffffa17.w		; Software End Of Interrupt mode.
	move.l	#player,$110.w
	move.l	#vbl,$70.w
	clr.b	$fffffa1d.w
	move.b	#14,$fffffa25.w
	move.b	#3,$fffffa1d.w
	lea	notetab-512,a2
	lea	offsamp(pc),a3
	move.l	a3,a4
	move.l	a3,a5
	move.l	a3,a6
	moveq.l	#0,d6
	bsr	set_up_sound		; Set up sound chip.
	move.w	#$2300,sr		; Enable interrupts past VBL.

key:	cmpi.b	#57,$fffffc02.w		; Wait for space bar to be pressed.
	bne.s	key

out:	move.w	#$2700,sr		; Restore MFP registers & vectors.
	lea	old_stuff(pc),a0
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa1d.w
	move.b  (a0)+,$fffffa25.w
	move.l	(a0)+,$70.w
	move.l	(a0)+,$110.w
	move.w	#$2300,sr
flush:	btst.b	#0,$fffffc00.w		; Purge keyboard buffer.
	beq.s	fl_done
	move.b	$fffffc02.w,d0
	bra.s	flush
fl_done:move.l	oldsp(pc),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	add.l	#6,sp
	clr.w	-(sp)	
	trap	#1

;-------------------------------------------------------------------------;
;				INTERRUPTS				  ;
;-------------------------------------------------------------------------;

; VERTICAL BLANK INTERRUPT. THIS IS THE SEQUENCER.

vbl:	movem.l	d0-d3/a0-a1,-(sp)	; Stack registers.
	lea	dur1(pc),a0		; Play channel 1 song.
	lea	rmod1(pc),a1
	bsr	mr_music
	lea	dur2(pc),a0		; Play channel 2 song.
	lea	rmod2(pc),a1
	bsr	mr_music
	lea	dur3(pc),a0		; Play channel 3 song.
	lea	rmod3(pc),a1
	bsr	mr_music
	lea	dur4(pc),a0		; Play channel 4 song.
	lea	rmod4(pc),a1
	bsr	mr_music
	move.w	#$2700,sr
	move.w	dur1+note(pc),d0
	move.w	dur2+note(pc),d1
	move.w	dur3+note(pc),d2
	move.w 	dur4+note(pc),d3
	sub.w	d0,d1			; Get offset from Ch1 note.
	sub.w	d0,d2
	sub.w	d0,d3
	lea	notes,a2		; Reset note table.
	adda.w	d0,a2			; Add note for channel 1.
	move.w	d1,ch2add+2		; And modify offset.
	move.w	d2,ch3add+2
	move.w	d3,ch4add+2
	move 	#$2300,sr
	movem.l	(sp)+,d0-d3/a0-a1	; Restore registers.
	rte
	
* MUSIC CONTROLLER (THIS CALLS ALL THE SUBROUTINES)

mr_music:
	move.w	(a1)+,loadit		; modify address reg stuff.
	move.w	(a1),loadit2
	move.w	(a1),loadit3
	sf	 new(a0)
	subq.w 	#1,(a0)			; Is duration on channel on?
	bne.s	no_new			; Nope... Keep on playing sample.
	move.l	sptr(a0),a1		; Yep... Get song pointer.
	move.w	(a1),d2			; Pattern command or end?
	bpl.s	noend			; No... Get command.
	cmpi.w	#-9999,d2		; End of song?
	bne	do_loop			; No, then it's a pattern loop.
	move.l	sptr+4(a0),a1		; Yes... Restore song pointer.
noend:	move.w	(a1)+,d2		; Get command word.
testlp	btst	#14,d2			; Loop on this channel?
	sne	loop(a0)		; set flag if bit is set
testsmp:btst	#0,d2			; NEW SAMPLE?
	bne	new_samp
testnte:btst	#1,d2			; NEW NOTE?
	bne	new_note
testsld:btst	#2,d2			; SLIDE?
	bne	slide_note
testrst:btst	#3,d2			; REST?
	bne	rest
endcmds	move.l	a1,sptr(a0)		; Store new song pointer.

; Slide test & slide.

no_new:	tst.b	slidin(a0)		; Are we sliding?
	beq.s	loop_test		; Nope... So skip.
	move.w	note(a0),d0		; Yes... Get current note.
	cmp.w	snote(a0),d0		; Is it = to destination note?
	beq.s	skipsl			; Yes... Stop sliding.
	subq.w	#1,scount(a0)		; No... Do slide rate...
	bne.s	loop_test
	move.w	slide(a0),scount(a0)
	cmp.w	snote(a0),d0		; Compare both notes.
	bgt.s	subit
	add.w	#512,note(a0)		; Source > dest, so slide up.
	bra.s	loop_test		; Continue sliding.
subit:	sub.w	#512,note(a0)		; Source < dest, so slide down.
	bra.s	loop_test		; Continue sliding.
skipsl:	sf	slidin(a0)		; Signal no slide.

; Loop test for sampled instruments.	

loop_test:
	tst.b	vcon(a0)
	beq.s	vcoff
	tst.b	new(a0)
	bne.s 	endltst
	move #$2700,sr
loadit	move.l a3,d1
	move.l	edaddr(a0),d0		; get sample's end addr
	cmp.l	d1,d0			; Is it over end?
	bgt.s	endltst			; Nope... No loop yet.
	tst.b	loop(a0)		; Loop sample?
	bne.s	loopit			; Yep... Loop test.
	sf	vcon(a0)		; If no loop, no play.
	sf	slidin(a0)		; No slide.
vcoff:	move	#-512,note(a0)
	move.l	#offsamp,d1
	bra	loadit2	
loopit:	sub.l	d0,d1
	add.l	lpaddr(a0),d1
; (fall through)	

loadit2:move.l 	d1,a3
endltst:move #$2300,sr
	rts

rmod1	move.l	a3,d1
	move.l	d1,a3
rmod2	move.l	a4,d1
	move.l	d1,a4
rmod3	move.l	a5,d1
	move.l	d1,a5
rmod4	move.l	a6,d1
	move.l	d1,a6

new_samp:
	move.w	(a1)+,d0		; Get sample number
	move.l	a1,d3
	lea	slist(pc),a1		; Get sample address table.
	lsl.w	#3,d0			; x 8 bytes per entry.
	adda.w	d0,a1			; Now A1 points to sample entries.
	move.l	samples(pc),d1		; Get samples start address.
	add.l	(a1)+,d1		; + offset = Sample address.
	move.l	d1,staddr(a0)
	moveq.l	#0,d0
	move.w	(a1)+,d0
	add.l 	d1,d0
	move.l	d0,edaddr(a0)		; Store end addr of sample
	moveq.l	#0,d0	
	move.w	(a1),d0	
	add.l 	d1,d0
	move.l	d0,lpaddr(a0)		; and loop addr of sample
	st	new(a0)			; Signal new sample.
	move.l	d3,a1
	bra	testnte

new_note:
	move.l	staddr(a0),d1
loadit3	move.l	d1,a3
	move.w	(a1)+,d0		; Yes... Get note.
	moveq	#9,d1
	lsl.w	d1,d0			; x 512 bytes for tables.
	move.w	d0,note(a0)		; Now new note.
	move.w	(a1)+,(a0)		; And new duration.
	st	vcon(a0)		; Enable playback.
	st	new(a0)			; Signal new sample.
	bra	testsld

slide_note:
	move.w	(a1)+,d0		; Slide to note...
	moveq	#9,d1
	lsl.w	d1,d0			; (X 512 for table)
	move.w	d0,snote(a0)
	move.w	(a1)+,d0		; Get slide delay value.
	move.w	d0,slide(a0)		; Put it in storage.
	move.w	d0,scount(a0)		; And in the counter.
	st	slidin(a0)		; Signal slide in progress.
	move.w	(a1)+,dur(a0)		; Get duration.
	bra	testrst

rest:	move.w	(a1)+,(a0)		; Get duration of rest.
	sf	vcon(a0)		; And don't play.
	bra	endcmds

do_loop:move.w	(a1)+,d0		; Get loop signal.
	move.b	(a1)+,d0		; Get loop value.
	move.b	(a1)+,d1		; Get loop counter.
	bne.s	keeplp			; Zero? No, more loops.
	move.b	d0,-1(a1)		; Restore loop counter.
	addq.w	#2,a1			; And go past loop address.
	tst.w	(a1)			; Is it a pattern command?
	bpl.s	moresng			; No, then play whatever.
	cmpi.w	#-9999,(a1)
	bne.s	do_loop
	move.l	sptr+4(a0),a1		; Yes... Restore song pointer.
moresng:bra	noend
keeplp:	subq.b	#1,d1			; Increase loop counter.
	move.b	d1,-1(a1)		; Store counter.
	sub.w	(a1),a1			; And loop back to address.
	bra	noend

; 12bit sample player - Through internal soundchip

player:	moveq	#0,d7
	move.b	(a3),d7
	move.b	(a4),d6
	add.w	d6,d7
	move.b	(a5),d6
	add.w	d6,d7
	move.b	(a6),d6
	add.w	d6,d7
	lsl.w	#3,d7
	move.l	a1,usp
	lea	$ffff8800.w,a1
	move.l	sound_look+4(pc,d7.w),(a1)
	move.l	sound_look(pc,d7.w),d7
	movep.l	d7,(a1)			; Or $ffff8800.w
	move.l	usp,a1
ch4add:	adda.w	0(a2),a6
ch3add:	adda.w	0(a2),a5
ch2add:	adda.w	0(a2),a4
	adda.w	(a2)+,a3
	rte
sound_look:
	incbin	quarfast.tab

;-------------------------------------------------------------------------;
;				SUBROUTINES				  ;
;-------------------------------------------------------------------------;

; ROUTINE FOR GENERATING 64 256 WORD NOTE TABLES. 

gentabs:lea	notes,a5
	lea	notetab(pc),a6		; Address of note table.
	moveq	#64-1,d3		; 64 notes.
nxtnote:move.l	(a6)+,d6		; Get note int and frac.
	moveq	#0,d5			; Clear D5.
	swap	d6			; Access to int part.
	move.w	d6,d4			; And into lower D5.
	clr.w	d6			; Get rid of D6 integer part.
	swap	d6			; Restore D6 mow only frac part.
	move.w	#256-1,d7		; 256 note skips. (20 to see!)
addem:	swap	d5			; Access to int.
	move.w	d4,d5			; Restore int.
	swap	d5			; And make upper D5 int.
	add.l	d6,d5			; Add frac & overflow =1 to D5.
	swap	d5			; Get int part.
	move.w	d5,(a5)+		; Store note skip value.
	swap	d5			; Restore D5 back to normal.
	dbra	d7,addem		; Do for 256 skips.
	dbra	d3,nxtnote		; Do for 64 notes.
	rts

; Initialise a voice pointed to by A0.

initvoice
	move.w	#2,dur(a0)
	move.w	#-512,note(a0)
	sf	loop(a0)
	sf	slidin(a0)
	sf	vcon(a0)
	sf	new(a0)
	lea.l	offsamp(pc),a1
	move.l	a1,staddr(a0)
	move.l	a1,edaddr(a0)
	move.l	a1,lpaddr(a0)
	rts

; FIND TUNE. (Needed every time a new tune is played).

find_tune:
	move.l	tuneptr(pc),a0		; Get tune pointer.
	lea	dur1(pc),a1		; Get song pointer for CH1.
	moveq	#3-1,d0			; Loop 3 times.
	move.l	a0,sptr(a1)		; Store the channel's tune addr.
	move.l	a0,sptr+4(a1)		; Twice for the player.
srchnt:	lea size(a1),a1
.srch	cmpi.w	#-9999,(a0)+		; Search for end of song.
	bne.s	.srch
	move.l	a0,sptr(a1)	
	move.l	a0,sptr+4(a1)
	dbra	d0,srchnt
	rts

; FIND SAMPLES

find_samples:
	move.l	samples(pc),a0		; Get voice set address.
findsmp:tst.w	(a0)			; See if negative.
	bpl.s	noends			; No...  Continue search.
	addq.w	#2,a0			; Yes...  Skip end value.
	move.l	a0,samples		; Store samples addresses.
	rts				; Return.
noends:	addq.w	#8,a0			; Skip to next instrument if any).
	bra.s	findsmp			; Continue search.

; SET UP SOUNDCHIP

set_up_sound:
	MOVE #$8800,A0
	MOVE.B #7,(A0)
	MOVE.B #$C0,D0
	AND.B	(A0),D0
	OR.B #$38,D0
	MOVE.B D0,2(A0)
	MOVE #$600,D0
.setup	MOVEP.W D0,(A0)
	SUB #$100,D0
	BPL.S .setup
	RTS

;-------------------------------------------------------------------------;
;				SPACE & DATA				  ;
;-------------------------------------------------------------------------;

oldsp:	ds.l	1			; Old stack pointer.
old_stuff:
	ds.l	7

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

offsamp:dcb.w	512,$8080

; CHANNEL VARIABLES.	

tuneptr:dc.l	tune			; Address of tune.
samples:dc.l	slist			; Address of samples.

	rsreset
dur:	rs.w	1
note:	rs.w	1
loop:	rs.b	1
slidin:	rs.b	1
snote:	rs.w	1
scount:	rs.w	1
slide:	rs.w	1
staddr:	rs.l	1
edaddr:	rs.l	1
lpaddr:	rs.l	1
vcon:	rs.b	1
new:	rs.b	1
sptr:	rs.l	2
size	rs.b 	1

dur1:	ds.b	size
dur2:	ds.b	size
dur3:	ds.b	size
dur4:	ds.b	size

tune:	incbin thursday.sng
slist:	incbin thursday.eit
	even

; Note skip tables are written here.

	ds.w 256
notes:
