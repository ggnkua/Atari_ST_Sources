; Mr Music - Rotfile player.
; (no comment - work it out for yerself!)

letsgo	clr.l	-(sp)			; Supervisor mode.
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	lea oldsp(pc),a0		; save stack pointer
	move.l	sp,(a0)
	move.w	#$2700,sr		; interrupts Off.
	lea oldmfp(pc),a0
	move.b	$fffffa07.w,(a0)+	; Save MFP registers.
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.l	$70.w,(a0)+	
	move.b  #0,$fffffa07.w
	move.b	#0,$fffffa09.w	
	move.b  #0,$fffffa13.w		; bye bye to mfp ints
	move.b	#0,$fffffa15.w
	lea vbl(pc),a0
	move.l a0,$70.w

	lea rotfile,a0			; a0->rotfile
	jsr (a0)			; initialise the driver
	lea tune(pc),a1
	lea vceset(pc),a2
	move.l a1,16(a0)		; give the driver start addrs'
	move.l a2,20(a0)		; of voice set + tune.
	jsr 4(a0)			; initialise + start music

	move.w	#$2300,sr		; Enable interrupts

key:	cmpi.b	#57,$fffffc02.w		; Wait for space bar to be pressed.
	bne.s	key

out:	move.w	#$2700,sr		; Restore MFP registers & vectors.
	lea rotfile,a0			; a0->rotfile
	jsr 8(a0)			; stop music
	lea oldmfp(pc),a0
	move.b	(a0)+,$fffffa07.w 
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.l	(a0)+,$70.w
flush:	btst.b	#0,$fffffc00.w	
	beq.s	fl_done
	move.b	$fffffc02.w,d0
	bra	flush
fl_done:move.w	#$2300,sr
	move.l	oldsp(pc),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.w	-(sp)	
	trap	#1

vbl:	movem.l a0-a6/d0-d6,-(sp)	
	lea rotfile,a0			; a0->rotfile
	jsr 12(a0)			; call sequencer
	movem.l	(sp)+,a0-a6/d0-d6
	rte

oldsp:	ds.l	1			; Old stack pointer.
oldmfp:	ds.l	5

tune:	incbin b:\nic_shit\ego.sng
vceset:	incbin b:\nic_shit\ego.eit

;-------------------------------------------------------------------------;
; MR MUSIC	V2 - VBL PLAYER  					  ;
; By Griff And The Phantom of Electronic Images. ROTFILE Version	  ;
; This Version uses only D7 and is 'sample byte perfect'.		  ;
; Faster than FORQURT this only takes 45% at 11khz or 35% at 8khz!!	  ;
;-------------------------------------------------------------------------;

; The rotfile
	
rotfile:  bra.w init_mrmusic		; init driver(create add tables)
	  bra.w start_tune		; start tune(init tune data +ints)
	  bra.w stop_tune		; stop tune(turn off int+soundchip)
	  bra.w Seq			; Vbl Sequencer + buffer maker
tuneptr:  dc.l 0			; pointer to tune data
slistptr: dc.l 0			; pointer to voiceset
sampptr:  dc.l 0			; sample data start(set by driver) 
		
; Initialise Mr Music i.e (generate add tables)

init_mrmusic:
	movem.l	a0-a6/d0-d7,-(sp)
	bsr	gentabs			; Generate note tables.
	movem.l	(sp)+,a0-a6/d0-d7
	rts

; Start the bloody tune.

start_tune:
	movem.l	a0-a6/d0-d7,-(sp)
	lea.l dur1(pc),a0
	bsr initvoice
	lea.l dur2(pc),a0		; initialise each
	bsr initvoice			; voices' channel data
	lea.l dur3(pc),a0
	bsr initvoice
	lea.l dur4(pc),a0
	bsr initvoice
	bsr find_tune			; find voices
	bsr find_samples		; find samples
	move.w sr,-(sp)
	move.w #$2700,sr
	bsr set_up_sound		; Set up sound chip.
	lea savemfp(pc),a0
	move.l $110.w,(a0)+
	move.b $ffffffa17.w,(a0)+
	move.b $ffffffa1d.w,(a0)+	; save what we change
	move.b $ffffffa25.w,(a0)+
	bset #4,$fffffa09.w
	bset #4,$fffffa15.w
	bclr.b #3,$fffffa17.w		; software end of interrupt
	clr.b $fffffa1d.w
	move.b	#14,$fffffa25.w		; 10.971 Khz (Replay Prof speed.)
	move.b	#3,$fffffa1d.w
	lea player(pc),a0
	move.l a0,$110.w
	lea Buffer(PC),a0
	move.l a0,usp 
	move.w (sp)+,sr
	movem.l	(sp)+,a0-a6/d0-d7
	rts
savemfp:ds.l 2

; Stop the bloody tune.

stop_tune:
	move.l a0,-(sp)
	move.w sr,-(sp)
	move.w #$2700,sr
	lea savemfp(pc),a0
	move.l (a0)+,$110.w
	move.b (a0)+,$ffffffa17.w
	move.b (a0)+,$ffffffa1d.w
	move.b (a0)+,$ffffffa25.w
	bclr #4,$fffffa09.w
	bclr #4,$fffffa15.w
	move.w (sp)+,sr
	move.l (sp)+,a0
	rts

; THIS IS THE SEQUENCER.

Seq	bsr	Makebuf
	lea	dur1(pc),a2		; Play channel 1 song.
	bsr	mr_music
	lea	dur2(pc),a2		; Play channel 2 song.
	bsr	mr_music
	lea	dur3(pc),a2		; Play channel 3 song.
	bsr	mr_music
	lea	dur4(pc),a2		; Play channel 4 song.
	bsr	mr_music
	rts

; Buffer Creation rout.

bufsize	EQU 222
bufchnk	EQU 198

loadvc	macro
	lea dur\1(pc),a0	
	move.w	vcon(a0),d1
	bne.s	vcson\@
	lea nul_sample(pc),A\1
	bra.s endloadvc1\@
vcson\@	move.l	off(a0),d1
	beq.s	not\@
	move.l	d1,saddr(a0)
not\@	move.l	saddr(a0),A\1
endloadvc1\@
	endm

Makebuf:lea mod1+2(pc),a0
	move.w dur1+note(pc),d3
	lea notes(pc),a5
	add.w d3,a5
	move.w dur2+note(pc),d4
	sub.w d3,d4
	move.w d4,(a0)
	move.w dur3+note(pc),d4
	sub.w d3,d4
	move.w d4,mod2-mod1(a0)
	move.w dur4+note(pc),d4
	sub.w d3,d4
	move.w d4,mod3-mod1(a0)
	loadvc 1
	loadvc 2
	loadvc 3
	loadvc 4
go	lea Buffer(pc),a6
	moveq.l #0,d2
	moveq.l #0,d3
	lea EndBuffer(pc),a0
	move.l a0,d4
	move.w	#bufsize-1,d0
	move.l usp,a0
	move.l a0,d1
	sub.l a6,d1
	sub.l a0,d4
	beq.s .Skip
	lsr.w #1,d4
	sub.w d4,d0
	subq.w #1,d4
.loop	move.w (a0)+,(a6)+
	dbf d4,.loop
.Skip	move.l usp,a0
	sub.w d1,a0
	move.l a0,usp
	cmp #bufchnk,d0
	blt.s copy
	moveq #-1,d3
	sub #bufchnk,d0
copy	moveq #0,d1
	move.b	(a1),d1
	move.b  (a2),d2
	add d2,d1
	move.b  (a3),d2
	add d2,d1
	move.b  (a4),d2
	add d2,d1
	move.w d1,(a6)+
mod1	add 2(a5),a2
mod2	add 2(a5),a3
mod3	add 2(a5),a4
	add (a5)+,a1
	dbf d0,copy
	tst d3
	beq missbig
	rept bufchnk
	move.b	(a1),d2
	add.w (a5)+,a1
	move.w d2,(a6)+
	endr 
	lea -bufchnk*2(a5),a5
	lea -bufchnk*2(a6),a6
	move.l a1,d3
	move.l a5,a0
	move.l a5,a1
	add mod1+2(pc),a0
	add mod2+2(pc),a1
	add mod3+2(pc),a5
	rept bufchnk
	moveq #0,d1
	move.b	(a2),d1
	move.b	(a3),d2
	add.w d2,d1
	move.b	(a4),d2
	add.w d2,d1
	add.w d1,(a6)+
	add.w (a0)+,a2
	add.w (a1)+,a3
	add.w (a5)+,a4
	endr
	move.l d3,a1
missbig	move.w dur1+vcon(pc),d0
	beq.s vcoff1
	lea	dur1+saddr(pc),a5	
	move.l	a1,(a5)
vcoff1	move.w dur2+vcon(pc),d0
	beq.s vcoff2
	lea	dur2+saddr(pc),a5
	move.l	a2,(a5)
vcoff2	move.w dur3+vcon(pc),d0
	beq.s vcoff3
	lea	dur3+saddr(pc),a5
	move.l	a3,(a5)
vcoff3	move.w dur4+vcon(pc),d0
	beq.s vcoff4
	lea	dur4+saddr(pc),a5
	move.l	a4,(a5)
vcoff4	rts

; MUSIC CONTROLLER (THIS CALLS ALL THE SUBROUTINES)

mr_music:
	move.l	saddr(a2),off(a2)
loop_test:
	move.l	sampptr(pc),a1		; Get samples start address.
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
	move.l	sampptr(pc),a1		; Get samples start address.
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
	add.w	#512,note(a2)		; Source > dest, so slide up.
	bra.s	donesl			; Continue sliding.
subit:	sub.w	#512,note(a2)		; Source < dest, so slide down.
	bra.s	donesl			; Continue sliding.
skipsl:	clr.w	slidin(a2)		; Signal no slide.
donesl:	rts

new_sample:
	move.l	sampptr(pc),a1		; Get samples start address.
	move.l	a1,d1			; Into D1 for addition.
	move.l slistptr(pc),a1		; Get sample address table.
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
	move.l	sampptr(pc),a1		; Get samples start address.
	move.l	a1,d1			; For addition.
	tst.w	loop(a2)		; Am I looping?
	bne.s	on			; Yes.. Do loop.
	move.l	craddr(a2),a1		; No... Get sample pointer.
	add.l	(a1),d1			; And make it start of sample.
	move.l	d1,off(a2)		; Store new address.
	move.w	#1,new(a2)		; Signal new sample.
on:	move.w	(a0)+,d0		; Yes... Get note.
	moveq	#9,d1
	lsl.w	d1,d0			; x 512 bytes for tables.
	move.w	d0,note(a2)		; Now new note.
	move.w	(a0)+,(a2)		; And new duration.
	move.w	#1,vcon(a2)		; Enable playback.
	rts

slide_note:
	move.w	(a0)+,d0		; Slide to note...
	moveq	#9,d1
	lsl.w	d1,d0			; (X 512 for table)
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

player:	pea (a0)
	move.l usp,a0
	move.w	(a0)+,d7
	add d7,d7
	add d7,d7
	move.l a0,usp
	lea $ffff8800.w,a0
	move.l	sound_look(pc,d7.w),d7
	movep.l	d7,(a0)
	move.l (sp)+,a0
	rte
sound_look:
	incbin	2chansnd.tab
Buffer	DCB.W bufsize,$80*4
EndBuffer
	DC.W $80*4

;-------------------------------------------------------------------------;
;				SUBROUTINES				  ;
;-------------------------------------------------------------------------;

* ROUTINE FOR GENERATING 64 256 WORD NOTE TABLES. RETURNS WITH A5 POINTING
* TO END OF TABLES.
gentabs:lea	notes(pc),a5
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

; FIND TUNE. (Needed every time a new tune is played).

find_tune:
	move.l	tuneptr(pc),a0		; Get tune pointer.
	move.w	#-9999,d0
	lea dur1(pc),a1
	move.l	a0,sptr(a1)		; Store the channel's tune addr.
	move.l	a0,sptr+4(a1)		; Twice for the player.
srchnt2:cmp.w	(a0)+,d0	
	bne.s	srchnt2
	lea dur2(pc),a1
	move.l	a0,sptr(a1)
	move.l	a0,sptr+4(a1)		
srchnt3:cmp.w	(a0)+,d0
	bne.s	srchnt3
	lea dur3(pc),a1
	move.l	a0,sptr(a1)
	move.l	a0,sptr+4(a1)
srchnt4:cmp.w	(a0)+,d0
	bne.s	srchnt4
	lea dur4(pc),a1
	move.l	a0,sptr(a1)
	move.l	a0,sptr+4(a1)		
	rts

; FIND SAMPLES

find_samples:
	lea slistptr(pc),a1
	move.l	(a1),a0			; Get voice set address.
	lea sampptr(pc),a1
.find	tst.w	(a0)			; See if negative.
	addq.w #8,a0
	bpl.s	.find			; No...  Continue search.
	subq.w	#6,a0
	move.l	a0,(a1)			; Store samples addresses.
	rts				; Return.

; Initialise one channel's data pointed to by A0.

initvoice:
	move #2,dur(a0)
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

; Voice data structure

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
dsize	rs.b	1	

dur1:	ds.b	dsize
dur2:	ds.b	dsize
dur3:	ds.b	dsize
dur4:	ds.b	dsize

notes:	ds.w	16384
endrotfile:
