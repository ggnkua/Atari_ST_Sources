;
; This version expands the voiceset to word samples and makes it about
; 5-10% faster (hah!)...  Note that this version needs the size of the
; voiceset and doesn't need the note table address.  It automatically
; puts the note table at the end of the voiceset, and returns the end
; address of the note table (for your own data) as a longword at
; rotfile+44.  Oh, the MOVEP version is 16 cycles faster than the MOVEM
; one...
;
;
; Example player for version 2 of Mr Music (40% at 11Khz).
;
; Programmed by The Phantom of Electronic Images.
;
; Mr Music is programmed by The Phantom and Griff of Electronic Images.
;
; Please note that Mr Music uses register D7 and USP so therefore you must
; be in supervisor mode when playing the music.
;

	clr.l	-(sp)			; Set supervisor mode.
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,oldsp		; Store old stack pointer.

	move.w	#$2700,sr		; No interrupts.
	lea	oldmfp(pc),a0		; Start storing MFP variables.
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.l	$70.w,(a0)+	
	move.b  #0,$fffffa07.w		; Stop all interrupts.
	move.b	#0,$fffffa09.w	
	move.b  #0,$fffffa13.w
	move.b	#0,$fffffa15.w
	move.l	#vbl,$70.w		; Install our VBL.

	move.l	#tune,rotfile+24	; Give Mr music the tune address.
	move.l	#vceset,rotfile+28 	; Give it voice set address.
	move.l	#endset-vceset,rotfile+40 ; Voiceset length.
	bsr	rotfile			; Now initialise & start music.

	move.w	#$2300,sr		; Enable interrupts

key:	cmpi.b	#57,$fffffc02.w		; Wait for space bar to be pressed.
	bne.s	key

out:	move.w	#$2700,sr		; Stop interrupts.
	bsr	rotfile+8		; Stop Mr Music & de-initialise.
	lea	oldmfp(pc),a0		; Now start restoring MFP.
	move.b	(a0)+,$fffffa07.w 
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.l	(a0)+,$70.w

flush:	btst.b	#0,$fffffc00.w		; Flush out keyboard buffer.
	beq.s	fl_done
	move.b	$fffffc02.w,d0
	bra.s	flush
fl_done:

	move.w	#$2300,sr		; Enable interrupts.

	move.l	oldsp(pc),-(sp)		; Restore old stack pointer & mode.
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp

	clr.w	-(sp)			; End program.
	trap	#1


;
; Our VBL.  Please note that the music driver should roughly be called at
; the same point every frame.  It can tolerate differences when it was
; last called to about +-3% or so (to a 50th of a second).  This isn't
; important, but I thought you ought to know just in case!
;
vbl:	move.w	#$007,$ffff8240.w
	bsr	rotfile+12		; Call Mr Music.
	move.w	#$777,$ffff8240.w
	rte

oldsp:	ds.l	1
oldmfp:	ds.l	5

		opt	o+,p+
;
; This version generates WORD samples automatically and pre-multipled by
; 4 (you can change to 8 for MOVEM soundchip).  It stores the address at
; the end of the samples+note tables at ENDSAMPS or at offset rotfile+40 
; (a longword).  Note that it stores the note tables right after the
; samples.
;


;
; Took out some more unnecesary workings in the player...  They were used
; for the non-buffer Mr Music!!  Jose.
;
; I changed the soundchip set up routine which gets rid of the 'noise'
; that occurs because of channel C.
;
; Also, I did another soundchip set up routine that doubles the output
; volume BUT slightly distorts on high volume combinations.
;



new_sample	macro
		move.l	sampptr(pc),d1		; Get samples start address.
		move.l	slistptr(pc),a1		; Get sample address table.
		move.w	(a0)+,d0		; Get sample number
		lsl.w	#3,d0			; x 8 bytes per entry.
		adda.w	d0,a1			; Now A1 points to sample entries.
		add.l	(a1),d1			; = Sample address.
		move.l	d1,off(a2)		; Store it.
		move.l	a1,craddr(a2)		; And store pointer for others.
		move.w	d4,vcon(a2)		; Enable playback.
		endm

new_note	macro
		move.l	sampptr(pc),d1		; Get samples start address.
		tst.w	loop(a2)		; Am I looping?
		bne.s	on\@			; Yes.. Do loop.
		move.l	craddr(a2),a1		; No... Get sample pointer.
		add.l	(a1),d1			; And make it start of sample.
		move.l	d1,off(a2)		; Store new address.
on\@		move.w	(a0)+,d0		; Yes... Get note.
		lsl.w	d3,d0			; x 512 bytes for tables.
		move.w	d0,note(a2)		; Now new note.
		move.w	(a0)+,(a2)		; And new duration.
		move.w	d4,vcon(a2)		; Enable playback.
		endm

slide_note	macro
		move.w	(a0)+,d0		; Slide to note...
		lsl.w	d3,d0			; (X 512 for table)
		move.w	d0,6(a2)
		move.w	(a0)+,d0		; Get slide delay value.
		move.w	d0,slide(a2)		; Put it in storage.
		move.w	d0,scount(a2)		; And in the counter.
		move.w	d4,slidin(a2)		; Signal slide in progress.
		move.w	(a0)+,dur(a2)		; Get duration.
		endm

rest		macro
		move.w	(a0)+,(a2)		; Get duration of rest.
		clr.w	vcon(a2)		; And don't play.
		endm

do_loop		macro
cont_loop\@	move.w	(a0)+,d0		; Get loop signal.
		move.b	(a0)+,d0		; Get loop value.
		move.b	(a0)+,d1		; Get loop counter.
		bne.s	keeplp\@		; Zero? No, more loops.
		move.b	d0,-1(a0)		; Restore loop counter.
		addq.w	#2,a0			; And go past loop address.
		tst.w	(a0)			; Is it a pattern command?
		bpl.s	moresng\@		; No, then play whatever.
		cmpi.w	#-9999,(a0)
		bne.s	cont_loop\@
		move.l	sptr+4(a2),a0		; Yes... Restore song pointer.
moresng\@	bra.s	endlp\@
keeplp\@	sub.b	d4,d1			; Increase loop counter.
		move.b	d1,-1(a0)		; Store counter.
		sub.w	(a0),a0			; And loop back to address.
endlp\@	
		endm

;-------------------------------------------------------------------------;
; MR MUSIC	V2 - VBL PLAYER  					  ;
; By Griff And The Phantom of Electronic Images. ROTFILE Version	  ;
; This Version uses only D7 and is 'sample byte perfect'.		  ;
; Faster than FORQURT this only takes 45% at 11khz or 35% at 8khz!!	  ;
;-------------------------------------------------------------------------;

; The rotfile
	
rotfile:  bra.w init_mrmusic		; init driver(create add tables)
	  bra.w new_tune		; New tune
	  bra.w stop_tune		; stop tune(turn off int+soundchip)
	  bra.w Seq			; Vbl Sequencer + buffer maker
	  bra.w reset2500		; Interrupt doesn't set IPL lower.
	  bra.w set2500			; Interrupt's IPL pulled to $2500.
tuneptr:  dc.l 0			; pointer to tune data.
slistptr: dc.l 0			; pointer to voiceset.
sampptr:  dc.l 0			; sample data start (set by driver)
notes:    dc.l 0			; Note tables addr (set by driver)
size:	  dc.l 0			; samples end address after xpand.
endbits:  dc.l 0			; Address after note tables.
		
; Initialise Mr Music and start playing.
init_mrmusic:
	movem.l	a0-a6/d0-d7,-(sp)
	move.w sr,-(sp)
	move.w #$2700,sr
	bsr set_up_sound		; Set up sound chip.
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
	bsr	gentabs			; Generate note tables.
	move.l	dur1+sptr(pc),a0	; Restore loop counters.
	bsr	resloop
	move.l	dur2+sptr(pc),a0
	bsr	resloop
	move.l	dur3+sptr(pc),a0
	bsr	resloop
	move.l	dur4+sptr(pc),a0
	bsr	resloop
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
	lea Buffer(pc),a0
	move.l	a0,usp
	lea player(pc),a0
	move.l a0,$110.w
	move.b #8,$ffff8800.w
	move.w (sp)+,sr
	movem.l	(sp)+,a0-a6/d0-d7
	rts
savemfp:ds.l 2

; New tune.

new_tune:
	movem.l	a0-a1/d0-d1,-(sp)
	lea sample_off(pc),a0
	move.l a0,$110.w
	lea.l dur1(pc),a0
	bsr initvoice
	lea.l dur2(pc),a0		; initialise each
	bsr initvoice			; voices' channel data
	lea.l dur3(pc),a0
	bsr initvoice
	lea.l dur4(pc),a0
	bsr initvoice
	bsr find_tune			; find voices
	move.l	dur1+sptr(pc),a0	; Restore loop counters.
	bsr	resloop
	move.l	dur2+sptr(pc),a0
	bsr	resloop
	move.l	dur3+sptr(pc),a0
	bsr	resloop
	move.l	dur4+sptr(pc),a0
	bsr	resloop
	lea player(pc),a0
	move.l a0,$110.w
	movem.l	(sp)+,a0-a1/d0-d1
	rts

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

; Set interrupt so it does not lower IPL to $2500.
reset2500:
	move.l	a0,-(sp)
	lea	player2(pc),a0
	move.l	a0,$110.w
	move.l	(sp)+,a0
	rts

; Set interrupt so it lowers IPL to $2500.
set2500:
	move.l	a0,-(sp)
	lea	player(pc),a0
	move.l	a0,$110.w
	move.l	(sp)+,a0
	rts



; THIS IS THE SEQUENCER.

Seq	movem.l a0-a6/d0-d4,-(sp)	
	bsr.s	Makebuf
	moveq	#9,d3
	moveq	#1,d4
	lea	dur1(pc),a2		; Play channel 1 song.
	bsr	mr_music
	lea	dur2(pc),a2		; Play channel 2 song.
	bsr	mr_music
	lea	dur3(pc),a2		; Play channel 3 song.
	bsr	mr_music
	lea	dur4(pc),a2		; Play channel 4 song.
	bsr	mr_music
	movem.l (sp)+,a0-a6/d0-d4
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
	move.l notes(pc),a5
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
copy	move.w	(a1),d1
	add.w  (a2),d1
	add.w  (a3),d1
	add.w  (a4),d1
	move.w d1,(a6)+
mod1	add 2(a5),a2
mod2	add 2(a5),a3
mod3	add 2(a5),a4
	add (a5)+,a1
	dbf d0,copy
	tst d3
	beq missbig
	rept bufchnk
	move.w	(a1),(a6)+
	add.w (a5)+,a1
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
	move.w	(a2),d1
	add.w	(a3),d1
	add.w	(a4),d1
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
	move.l	sampptr(pc),d0		; Get samples start address.
	move.l	craddr(a2),a0		; Get current sample address.
	add.l	(a0)+,d0		; Get sample offset in D0.
	moveq	#0,d1
	move.w	(a0)+,d1		; Get sample length in D1.
	add.l	d1,d0			; Add sample length to D0.
	cmp.l	off(a2),d0		; Is it over length?
	bgt.s	noendl			; Nope... No loop yet.
	tst.w	loop(a2)		; Loop sample?
	bne.s	loopit			; Yep... Loop test.
	clr.w	vcon(a2)		; If no loop, no play.
	clr.w	slidin(a2)		; No slide.
	bra.s	noendl
loopit:	sub.l	off(a2),d0		; Get excess playback.
	move.l	sampptr(pc),d1		; Get samples start address.
	add.l	-6(a0),d1		; Now is sample address.
	move.l	d1,off(a2)		; Store it.
	moveq	#0,d1
	move.w	(a0)+,d1		; Get sample offset.
	sub.l	d0,d1			; Minus excess.
	add.l	d1,off(a2)		; Add to sample base address.
	bra.s endlooptest
noendl:	clr.l	off(a2)			; Don't reset pointer!
endlooptest:
	tst.w	(a2)			; Is duration on channel on?
	bne	nonew			; Nope... Keep on playing sample.
	move.l	sptr(a2),a0		; Yep... Get song pointer.
	tst.w	(a0)			; Pattern command or end?
	bpl.s	noend			; No... Get command.
	cmpi.w	#-9999,(a0)		; End of song?
	bne.s	pattern			; No, then it's a pattern loop.
	move.l	sptr+4(a2),a0		; Yes... Restore song pointer.
	bra.s	noend
pattern:do_loop				; Do pattern loops.
noend:	move.w	(a0)+,d2		; Get command word.
	btst	#0,d2			; NEW SAMPLE?
	beq.s	nosamp
	new_sample			; Go to sample routine.
nosamp:	btst	d4,d2			; NEW NOTE?
	beq.s	nonote
	new_note			; Yep... Go to note routine.
nonote:	btst	#2,d2			; SLIDE?
	beq.s	nslide			; Yep... Go to slide routine.
	slide_note
nslide:	btst	#3,d2
	beq.s	norest
	rest
norest:	move.l	a0,sptr(a2)		; Store new song pointer.
	btst	#14,d2			; Loop on this channel?
	sne	loop(a2)		; Signal loop flag if set.

nonew:	sub.w	d4,(a2)			; Countdown for next command.

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


nul_sample
	dcb.w 7*256,$80*4

; 12bit sample player - Through internal soundchip

player:	move.w #$2500,sr
player2:pea (a0)
	move.l usp,a0
	move.w	(a0)+,d7
	move.l a0,usp
	lea $ffff8800.w,a0
	move.l	sound_look(pc,d7.w),d7
	movep.l	d7,(a0)
	move.l (sp)+,a0
sample_off:
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
gentabs:move.l	notes(pc),a5		; Get note table address.
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
	move.l	d5,d2
	swap	d2
	add.w	d2,d2
	move.w	d2,(a5)+		; Store note skip value.
	dbra	d7,addem		; Do for 256 skips.
	dbra	d3,nxtnote		; Do for 64 notes.
	lea	endbits(pc),a0
	move.l	a5,(a0)
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
	move.l	a0,a2
.find	tst.w	(a0)			; See if negative.
	bmi.s	found
	move.l	(a0),d0
	add.l	d0,d0
	move.l	d0,(a0)+
	move.w	(a0),d0
	add.w	d0,d0
	move.w	d0,(a0)+
	move.w	(a0),d0
	add.w	d0,d0
	move.w	d0,(a0)+
	bra.s	.find			; No...  Continue search.
found:	addq.w	#2,a0
	move.l	a0,(a1)			; Store samples addresses.
	sub.l	a0,a2
	sub.l	a2,d0

	move.l	size(pc),d0		; Now double those samples!
	lea	(a0,d0.l),a0
	lea	(a0,d0.l),a1
	lea	notes(pc),a2
	move.l	a1,(a2)
bigloop:moveq	#0,d1
	move.b	-(a0),d1
	add.w	d1,d1
	add.w	d1,d1
	move.w	d1,-(a1)
	subq.l	#1,d0
	bne.s	bigloop
	rts				; Return.

* RESTORE LOOP COUNTERS.
resloop:tst.w	(a0)+
	bpl.s	resloop
	subq.w	#2,a0
	cmpi.w	#-9999,(a0)
	beq.s	nolps
	move.w	(a0)+,d0		; Get loop signal.
	move.b	(a0)+,d0		; Get loop value.
	move.b	(a0)+,d1		; Get loop counter.
	move.b	d0,-1(a0)		; Restore loop counter.
	addq.w	#2,a0			; And go past loop address.
	bra.s	resloop
nolps:	rts

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

; SET UP SOUNDCHIP - New improved version!
 
set_up_sound:
	MOVE #$8800,A0
	MOVE.B #7,(A0)
	MOVE.B #$C0,D0
	AND.B (A0),D0
	OR.B #%111100,D0
	MOVE.B D0,2(A0)
	MOVE #$600,D0
.setup	MOVEP.W D0,(A0)
	SUB #$100,D0
	BPL.S .setup
	RTS


; 64 notes to generate tables...  Int and frac parts in word pairs.
; Generated using note formula in GFA Basic V3. Base freq: 440Hz.
; Version 2 of note table.

notetab:DC.W	$0,$2AB7,$0,$2D41,$0,$2FF2,$0,$32CB
	DC.W	$0,$35D1,$0,$3904,$0,$3C68,$0,$4000
	DC.W	$0,$43CE,$0,$47D6,$0,$4C1B,$0,$50A2
	DC.W	$0,$556E,$0,$5A82,$0,$5FE4,$0,$6597
	DC.W	$0,$6BA2,$0,$7208,$0,$78D0,$0,$8000
	DC.W	$0,$879C,$0,$8FAC,$0,$9837,$0,$A145
	DC.W	$0,$AADC,$0,$B504,$0,$BFC8,$0,$CB2F
	DC.W	$0,$D744,$0,$E411,$0,$F1A1,$1,$0
	DC.W	$1,$F38,$1,$1F59,$1,$306F,$1,$428A
	DC.W	$1,$55B8,$1,$6A09,$1,$7F91,$1,$965F
	DC.W	$1,$AE89,$1,$C823,$1,$E343,$2,$0
	DC.W	$2,$1E71,$2,$3EB3,$2,$60DF,$2,$8514
	DC.W	$2,$AB70,$2,$D413,$2,$FF22,$3,$2CBF
	DC.W	$3,$5D13,$3,$9047,$3,$C686,$3,$FFFF
	DC.W	$4,$3CE3,$4,$7D66,$4,$C1BF,$5,$A28
	DC.W	$5,$56E0,$5,$A827,$5,$FE44,$6,$597F

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

	dc.b	' Mr Music V2.1 (C) 1990-2013 The Phantom & Griff of Electronic Images '

	even
	
endrotfile:


tune:	incbin thursday.sng
vceset:	incbin thursday.eit
	even
endset:
moo: