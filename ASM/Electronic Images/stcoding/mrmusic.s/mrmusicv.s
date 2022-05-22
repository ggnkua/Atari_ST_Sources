; Mr Music - Rotfile player (This is a Very Fast VBL Player!!!!).
; (no comment - work it out for yerself!)

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
	lea vceset(pc),a2
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

tune:	incbin a:\ego.mus\ego.sng
	even
vceset:	incbin a:\ego.mus\ego.eit
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
	bsr	init_playerbuf
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
	move.w sr,-(sp)
	move.w #$2700,sr
	lea savemfp(pc),a0
	move.l $110.w,(a0)+
	move.b $ffffffa17.w,(a0)+
	move.b $ffffffa1d.w,(a0)+	; save what we change
	move.b $ffffffa25.w,(a0)+
	bset #4,$fffffa09.w
	bset #4,$fffffa15.w
	bclr.b #3,$fffffa17.w		; software end of interrupt
	clr.b $fffffa1d.w
	move.b #14,$fffffa25.w		; 10.971 Khz (Replay Prof speed.)
	move.b #3,$fffffa1d.w
	lea player(pc),a0
	move.l a0,$110.w
	lea buff_ptr(pc),a1
	move.l a0,(a1)
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

; Initialise Sample play Buffer.

playsize=24

init_playerbuf
	lea player+18(pc),a0
	lea player+playsize(pc),a1
	move #699-1,d0
.lp	move.w a1,(a0)
	lea playsize(a0),a0
	lea playsize(a1),a1
	dbf d0,.lp
	lea player(pc),a1
	move.w a1,(a0)
	rts

player:	rept 699
	move.l #$08000000,$ffff8800.w		; 8 bytes
	move.l #$09000000,$ffff8800.w		; 8 bytes
	move.w #2,$112.w			; 8 bytes
	rte					; 2 bytes
	endr
	move.l #$08000000,$ffff8800.w		
	move.l #$09000000,$ffff8800.w		
	move.w #2,$112.w
	rte

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

Makebuf:lea mod1a+2(pc),a0
	move.w dur1+note(pc),d3
	lea notes(pc),a5
	add.w d3,a5
	move.w dur2+note(pc),d4
	sub.w d3,d4
	move.w d4,mod1a-mod1a(a0)
	move.w dur3+note(pc),d4
	sub.w d3,d4
	move.w d4,mod2a-mod1a(a0)
	move.w dur4+note(pc),d4
	sub.w d3,d4
	move.w d4,mod3a-mod1a(a0)
	loadvc 1
	loadvc 2
	loadvc 3
	loadvc 4
go	lea endplayer(pc),a0
	move.l a0,d1
	lea buff_ptr(pc),a0
	move.l (a0),a6
	sub.l a6,d1
	divu #playsize,d1
	move.l $110.w,d0
	move.l d0,(a0)
	sub.l a6,d0
	beq skipit
	bhi.s higher
	add.l #700*playsize,d0
higher	divu #playsize,d0
	lea fillx1(pc),a0
	clr.w (a0)			; assume none 
	cmp.w d1,d0
	bcs.s higher1
	move.w d1,(a0)			; overlap
higher1	sub.w fillx1(PC),d0
	move.w d0,2(a0)			; rest...(fillx2) PC relative
	lea 4(a6),a6			; a6-> buffer 
	lea cliptab(pc),a0
	moveq #0,d2
	
	move.w fillx1(pc),d0
	bsr copy	 
	move.w fillx2(pc),d0
	move.w fillx1(pc),d1
	beq.s .nores
	lea player+4(PC),a6
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

copy	subq #1,d0
	bmi.s donecop
copylp	moveq #0,d1
	move.b	(a1),d1
	move.b  (a2),d2
	add d2,d1
	move.b  (a3),d2
	add d2,d1
	move.b  (a4),d2
	add d2,d1
	add.w d1,d1
	move.b 0(a0,d1),(a6)
	move.b 1(a0,d1),8(a6)
	lea playsize(a6),a6
mod1a	add 2(a5),a2
mod2a	add 2(a5),a3
mod3a	add 2(a5),a4
	add (a5)+,a1
	dbf d0,copylp
donecop	rts

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

; Sound Table

digi2	MACRO
	dc.b	(($\1>>8)&15),(($\1>>4)&15)
	dc.b	(($\2>>8)&15),(($\2>>4)&15)
	dc.b	(($\3>>8)&15),(($\3>>4)&15)
	dc.b	(($\4>>8)&15),(($\4>>4)&15)
	dc.b	(($\5>>8)&15),(($\5>>4)&15)
	dc.b	(($\6>>8)&15),(($\6>>4)&15)
	dc.b	(($\7>>8)&15),(($\7>>4)&15)
	dc.b	(($\8>>8)&15),(($\8>>4)&15)
	ENDM

cliptab	dcb.w	$180,0				; bottom clip area
conv2	digi2	000,000,200,300,400,500,510,600
	digi2	600,620,700,720,730,800,800,820
	digi2	830,900,910,920,930,940,950,951
	digi2	A00,A20,A30,A40,A50,A50,A52,A60
	digi2	A62,A70,A71,B00,B10,B30,B40,B40
	digi2	B50,B52,B60,B61,B70,B71,B72,B73
	digi2	B80,B81,B83,B84,B90,C00,C20,C30
	digi2	C40,C50,C51,C52,C60,C62,C70,C72
	digi2	C73,C80,C80,C82,C83,C90,C90,C92
	digi2	c93,c94,c95,c95,ca0,d00,d20,d30
	digi2	d40,d50,d50,d52,d60,d62,d70,d71
	digi2	d73,d74,d80,d82,d83,d90,d90,d92
	digi2	d93,d94,d95,d95,da0,da1,da3,da4
	digi2	da4,da5,da5,da6,da6,da7,da7,db0
	digi2	db1,db2,db3,db4,db5,db5,db6,e00
	digi2	e10,e30,e40,e41,e50,e52,e60,e61
	digi2	e70,e71,e73,e74,e80,e81,e83,e84
	digi2	e90,e92,e93,e94,e95,e95,ea0,ea1
	digi2	ea3,ea4,ea4,ea5,ea5,ea6,ea6,ea7
	digi2	ea7,ea7,eb0,eb2,eb3,eb4,eb5,eb5
	digi2	eb5,eb6,eb6,eb7,eb7,eb7,eb8,eb8
	digi2	eb8,eb8,eb9,ec0,ec1,ec3,ec4,ec4
	digi2	ec5,f00,f10,f30,f40,f41,f50,f52
	digi2	f60,f61,f70,f71,f73,f74,f80,f82
	digi2	f83,f84,f90,f92,f93,f94,f95,f95
	digi2	fa0,fa1,fa3,fa4,fa4,fa5,fa5,fa6
	digi2	fa6,fa7,fa7,fb0,fb0,fb2,fb3,fb4
	digi2	fb5,fb5,fb6,fb6,fb6,fb7,fb7,fb7
	digi2	fb8,fb8,fb8,fb8,fb9,fc0,fc1,fc3
	digi2	fc4,fc4,fc5,fc5,fc6,fc6,fc7,fc7
	digi2	fc7,fc7,fc8,fc8,fc8,fc8,fc9,fc9
	digi2	fc9,fc9,fc9,fc9,fca,fd0,fd1,fd3
	REPT	32				; top clip
	digi2	fd3,fd3,fd3,fd3,fd3,fd3,fd3,fd3
	ENDR

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
	MOVE #$600,D0
.setup	MOVEP.W D0,(A0)
	SUB #$100,D0
	BPL.S .setup
	MOVE.B #7,(A0)
	MOVE.B #$C0,D1
	AND.B (A0),D1
	OR.B #$38,D1
	MOVE.B D1,2(A0)
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
