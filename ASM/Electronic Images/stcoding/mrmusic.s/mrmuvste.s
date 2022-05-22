; Mr Music - STE Rotfile player (This is a Very Fast VBL Player!!!!).
; I think this one is takes about 14% ! ; 12.5 khz 
; or about 15-16% if oversampling is on... 
; anyway it shouldn't be too hard to change to 25khz etc.

oversmp	equ 	1		; set this to 1 to oversample

letsgo	clr.l	-(sp)			; Supervisor mode.
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	lea stack,sp

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
	lea vceset,a2
	move.l a1,20(a0)		; give the driver start addrs'
	move.l a2,24(a0)		; of voice set + tune.
	jsr 4(a0)			; initialise + start music

	move.w	#$2300,sr		; Enable interrupts

key:	move.w vbl_timer(pc),d0
.wait	cmp.w vbl_timer(pc),d0
	beq.s .wait
	cmpi.b	#57,$fffffc02.w		; Wait for space bar to be pressed.
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
	clr.w	-(sp)	
	trap	#1

vbl:	movem.l	a0-a6/d0-d7,-(sp)
	not.w $ffff8240.w
	lea rotfile,a0			; a0->rotfile
	jsr 12(a0)
	not.w $ffff8240.w
	lea vbl_timer(pc),a0
	addq #1,(a0)
	movem.l	(sp)+,a0-a6/d0-d7
	rte
vbl_timer
	ds.w 1
oldsp:	ds.l	1			; Old stack pointer.
oldmfp:	ds.l	5

tune:	;incbin a:\ego.mus\ego.sng
	incbin thursday.sng
	;incbin b:\knuckmix.sng
	;incbin g:\mrmusic.s\mr_music.trk\cocktail.sng
	even
vceset:	;incbin a:\ego.mus\ego.eit
	incbin thursday.eit
	;incbin b:\quarscr.eit
	;incbin g:\mrmusic.s\mr_music.trk\cocktail.eit
endvceset
	even
	ds.l 199
stack	ds.l 2

;-------------------------------------------------------------------------;
; MR MUSIC	V2 - VBL PLAYER  					  ;
; By Griff And The Phantom of Electronic Images. ROTFILE Version	  ;
; This Version uses NO registers and is 'sample byte perfect'.		  ;
; Faster than FORQURT this only takes 40% at 11khz or 25% at 8khz!!	  ;
;-------------------------------------------------------------------------;
; 
; The rotfile
	
rotfile:  bra.w init_mrmusic		; init driver(create add tables)
	  bra.w start_tune		; start tune(init tune data +ints)
	  bra.w stop_tune		; stop tune(turn off int+soundchip)
	  bra.w Seq			; Vbl Sequencer + buffer maker
	  bra.w SeqSave			; as above(but stacks registers)
tuneptr:  dc.l 0			; pointer to tune data
slistptr: dc.l 0			; pointer to voiceset
sampptr:  dc.l 0			; sample data start(set by driver) 
		
; Initialise Mr Music i.e (generate add tables)

init_mrmusic:
	movem.l	a0-a6/d0-d7,-(sp)
	bsr	gentabs			; Generate note tables.
	movem.l	(sp)+,a0-a6/d0-d7
	rts

; This is The 'SAFE' sequencer - stacks all registers.

SeqSave	movem.l d0-d7/a0-a6,-(sp)
	bsr Seq
	movem.l (sp)+,d0-d7/a0-a6
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
.Ste_Setup	
	LEA.L setsam_dat(PC),A6
	MOVE.W #$7ff,$ffff8924
	MOVEQ #3,D6
.mwwritx	
	CMP.W #$7ff,$ffff8924
	BNE.S .mwwritx			; setup the PCM chip
	MOVE.W (A6)+,$ffff8922
	DBF D6,.mwwritx
	CLR.B $FFFF8901.W
	move.w sr,d7
	BSR Set_DMA
	move.w #$2700,sr
	move.l #supswitch,$b0.w
	ifeq oversmp
	MOVE.B #%00000001,$FFFF8921.W 	; 12.5khz
	elseif
	MOVE.B #%00000010,$FFFF8921.W 	; 25.0khz
	endc
	MOVE.B #3,$FFFF8901.W	  	; start STE dma.
	lea player(pc),a0
	lea buff_ptr(pc),a1
	move.l a0,(a1)
	move.w d7,sr
	movem.l	(sp)+,a0-a6/d0-d7
	rts

supswitch
	bchg.b #13-8,(sp)
	rte

Set_DMA	LEA temp(PC),A6			
	LEA player(PC),A0		
	MOVE.L A0,(A6)			
	MOVE.B 1(A6),$ffff8903.W
	MOVE.B 2(A6),$ffff8905.W	; set start of buffer
	MOVE.B 3(A6),$ffff8907.W
	LEA endplayer(PC),A0
	MOVE.L A0,(A6)
	MOVE.B 1(A6),$ffff890f.W
	MOVE.B 2(A6),$ffff8911.W	; set end of buffer
	MOVE.B 3(A6),$ffff8913.W
	RTS
		
; Stop the bloody tune.

stop_tune:
	clr.w $ffff8900.w
	rts

player:	
	ifeq oversmp
	ds.w $400
	elseif
	ds.l $400
	endc

endplayer	

; THIS IS THE SEQUENCER - Call this once per VBL.

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

; Buffer Create routs! (Vbl buffer maker)

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

Makebuf:loadvc 1
	loadvc 2
	loadvc 3
	loadvc 4
go	lea endplayer(pc),a0
	move.l a0,d1
	lea buff_ptr(pc),a0
	move.l (a0),a6
	sub.l a6,d1
	lsr.w #1,d1
	lea $ffff8909.w,a5
.read	MOVEP.L 0(A5),D0		; major design flaw in ste
	DCB.W 15,$4E71			; h/ware we must read the
	MOVEP.L 0(A5),D3		; frame address twice
	LSR.L #8,D0			; since it can change
	LSR.L #8,D3			; midway thru a read!
	CMP.L D0,D3			; so we read twice and
	BNE.S .read			; check the reads are the same!
	ifne oversmp
	sub.l #player,d3
	andi.l #3,d3
	bne.s .read
	endc

	move.l d0,(a0)

	sub.l a6,d0
	beq skipit
	bhi.s higher

	ifeq oversmp
	add.w #$400*2,d0
	elseif
	add.w #$400*4,d0
	endc

higher	lsr #1,d0
	lea fillx1(pc),a0
	clr.w (a0)			; assume none 
	cmp.w d1,d0
	bcs.s higher1
	move.w d1,(a0)			; overlap
higher1	sub.w fillx1(PC),d0
	move.w d0,2(a0)			; rest...(fillx2) PC relative
	move.w fillx1(pc),d0
	bsr copy	 
	move.w fillx2(pc),d0
	move.w fillx1(pc),d1
	beq.s .nores
	lea player(PC),a6
.nores	bsr copy

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
skipit	
vcoff4	rts

buff_ptr dc.l 0
fillx1	 dc.w 0
fillx2	 dc.w 0

; Add d0 bytes to the sound lookup...

copy	
	ifne oversmp
	asr.w #1,d0
	endc
	moveq #0,d2
	neg.w d0
	add.w #280,d0
	ifeq oversmp
	mulu #10,d0
	elseif
	mulu #12,d0
	endc
	movem.l d0/a6,-(sp)

do12	lea notes(pc),a5
	add.w dur1+note(pc),a5
	lea notes(pc),a0
	add.w dur3+note(pc),a0
	jmp .jmp1(pc,d0.l)
.jmp1	
	rept 280
	move.b (a1),d1
	add.b (a3),d1
	move.w d1,(a6)+
	ifne oversmp
	move.w d1,(a6)+
	endc
	add (a5)+,a1
	add (a0)+,a3       ;mod1a
	endr

	movem.l (sp)+,d0/a6

do34	lea notes(pc),a5
	add.w dur2+note(pc),a5
	lea notes(pc),a0
	add.w dur4+note(pc),a0
	trap #12
	move.l sp,savesp
	lea (a6),sp
	jmp .jmp2(pc,d0.l)
.jmp2	
	rept 280
	move.b (a2),d1
	add.b (a4),d1
	move.b d1,(a7)+
	ifne oversmp
	move.b d1,(a7)+
	endc
	add (a5)+,a2       ;mod2a
	add (a0)+,a4       ;mod3a
	endr
	move.l savesp(pc),sp
	trap #12
	rts

savesp	dc.l 	0
temp:	dc.l	0
setsam_dat:
	dc.w	%0000000011010100  	;mastervol
	dc.w	%0000010010000110  	;treble
	dc.w	%0000010001000110  	;bass
	dc.w	%0000000000000001  	;mixer

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
	dcb.b 7*256,$0

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
	
	lea endvceset,a2
	move.b #$80,d2
.lp	move.b (a0),d0
	eor.b d2,d0
	ext.w d0
	asr.w #1,d0
	move.b d0,(a0)+
	cmp.l a2,a0
	bne.s .lp
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

; 64 notes to generate tables...  Int and frac parts in word pairs.
; Generated using note formula in GFA Basic V3. Base freq: 440Hz.

notetab:DC.W	$0,$2596,$0,$27D3,$0,$2A31,$0,$2CB3  ; 11khz samples
	DC.W	$0,$2F5B,$0,$322C,$0,$3528,$0,$3851  ; at 12.5khz
	DC.W	$0,$3BAB,$0,$3F37,$0,$42F9,$0,$46F5
	DC.W	$0,$4B2D,$0,$4FA6,$0,$5462,$0,$5967
	DC.W	$0,$5EB7,$0,$6459,$0,$6A51,$0,$70A3
	DC.W	$0,$7756,$0,$7E6F,$0,$85F3,$0,$8DEA
	DC.W	$0,$965B,$0,$9F4C,$0,$A8C4,$0,$B2CE
	DC.W	$0,$BD6F,$0,$C8B3,$0,$D4A2,$0,$E147
	DC.W	$0,$EEAD,$0,$FCDE,$1,$BE7,$1,$1BD5
	DC.W	$1,$2CB6,$1,$3E98,$1,$5189,$1,$659C
	DC.W	$1,$7ADF,$1,$9167,$1,$A945,$1,$C28F
	DC.W	$1,$DD5A,$1,$F9BC,$2,$17CF,$2,$37AB
	DC.W	$2,$596C,$2,$7D30,$2,$A313,$2,$CB38
	DC.W	$2,$F5BF,$3,$22CE,$3,$528B,$3,$851E
	DC.W	$3,$BAB4,$3,$F379,$4,$2F9E,$4,$6F57
	DC.W	$4,$B2D9,$4,$FA60,$5,$4627,$5,$9670

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
	even

notes:	ds.w	16384
endrotfile:
