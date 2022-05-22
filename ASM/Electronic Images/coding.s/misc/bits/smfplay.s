 *** STANDARD MIDI FILE Player ***
*** by Anthony Spirou - October 1992 / 10 October 1993                             ***

*** P. O. Box 79409
*** Senderwood
*** 2145
*** South Africa

*** Email (definitely until end of 1993): anthony@concave.cs.wits.ac.za

*** Feel free to use/modify this code in your own programs.
*** Acknowledgements are nice..

* a2: address of the channel filter table (bytes 0-15, -1:on 0:off)
* a4: TI.L (start address always)
* a6: SADR.L (SMF current address)
* d7: TRACKS.w (# of tracks)
* d6: used for track loop counting and the current event byte
* d5: offset of lowest delta time track to track info array
* d4: the current lowest dtime track

	section TEXT
	bsr     INIT
	move.l  #$004c0000,-(sp)
	trap    #1

INIT
	movem.l d1-d7/a0-a6,-(sp)
	clr.l   -(sp)
	move    #$20,-(sp)
	trap    #1
	addq.l  #6,sp

	lea     MIDIFILE(pc),a6   (SMF START ADDRESS)
	lea     CHANFILT(pc),a2   (channel filter address)

	cmp.w   #2,8(a6)        (only play files of format 0 or 1)
	bge     ENDERROR
	lea     TI(pc),a4
	move.w  10(a6),d7       (# of tracks)

TRACK2TI
* track loop counter in d6 to zero
	clr.w   d6
.TLOOP  addq.w  #1,d6
* a6 ==> start address of next track
	lea     4(a6),a0
	bsr     OLPEEK
	addq.l  #8,d0
	lea     (a6,d0.l),a6
* put event start address into ti%(d6,0)
	move    d6,d5
	lsl     #4,d5
	move.l  a6,(a4,d5.w)
	addq.l  #8,(a4,d5.w)
* put track end address (start of next track) into ti%(d6,1)
	lea     4(a6),a0
	bsr     OLPEEK
	lea     8(a6,d0.l),a0
	move.l  a0,4(a4,d5.w)
* next loop until d6=maxtrack
	cmp.w   d7,d6
	bne     .TLOOP




** PLAY TRACKS
PLAY
* track loop counter d6 to zero
	clr.w   d6
.TLOOP1 addq.w  #1,d6
* put first delta times into ti%(d6,2)
	move.w  d6,d5
	lsl     #4,d5
	move.l  (a4,d5.w),a0
	bsr     VARLEN
	move.l  a0,(a4,d5.w)
	move.l  d0,8(a4,d5.w)
	cmp.w   d7,d6
	bne     .TLOOP1


* next event repeat loop

.EVENTLOOP
* find track with lowest current delta time --> d4
**** play event from this track
* d5=track info array offset for this lowest-dtime track
	move.w  d4,d5
	lsl     #4,d5
* put current track position address into a6
	move.l  (a4,d5.w),a6
* next event data into d6
	move.b  (a6),d6
	bmi     .NEW_RSBYTE
	bsr     MIDIEVENT
	bra     .NEXTEVENT
.NEW_RSBYTE
* move a6 to past event status byte
	lea     1(a6),a6
* routine for META-event (skip to next event ( event starts with deltatime ))
	cmp.b   #$ff,d6
	bne     .NOTMETA
	cmp.b   #$51,(a6)
	bne     .nosettempo
	lea     2(a6),a0
	bsr     OLPEEK

	lsr.l   #8,d0   (24-bit tempo - microseconds/quarternote)
	lea     MIDIFILE+12(pc),a0
	move.w  (a0),d1 (ticks/quarternote)
	divu    d1,d0   (d0 = microseconds/tick)
	and.l   #$ffff,d0
	lsl.l   #1,d0   ( *200/100)
*                       (d0 = clocks.10^-4/tick)
*                       (just need to div. by 10000 to get
*                        number of clocks/tick)
*                        (tick = delta time)
	lea     TEMPO(pc),a0
	move.l  d0,(a0)

.nosettempo
	lea     1(a6),a0
	bsr     VARLEN
	move.l  a0,a6
	lea     (a6,d0.l),a6
	clr.l   12(a4,d5.w)         {track running status byte to zero (undefined))
	bra     .NEXTEVENT
.NOTMETA
* move track pointer for SYStem EXclusive event
	cmp.b   #$f0,d6
	blt     .NOTSYSEX
	cmp.b   #$f7,d6
	bgt     .NOTSYSEX
	move.l  a6,a0
	bsr     VARLEN
	move.l  a0,a6
	lea     (a6,d0.l),a6
	clr.l   12(a4,d5.w)
	bra     .NEXTEVENT
.NOTSYSEX
	move.l  d6,12(a4,d5.w)
	bsr     MIDIEVENT
* add next delta time to track delta time
.NEXTEVENT
	move.l  a6,a0
	bsr     VARLEN
	add.l   d0,8(a4,d5.w)
	move.l  a0,(a4,d5.w)
	bra     .EVENTLOOP

******
* MIDI channel messages...
MIDIEVENT
* get track RUNNING STATUS byte to d6 (for current track)
	move.l  12(a4,d5.w),d6
* 2 bytes for PITCH BEND
	cmp.b   #$ef,d6
	bgt     .NOBEND
	cmp.b   #$e0,d6
	blt     .NOBEND
*       lea     2(a6),a6
	bra     SEND2
.NOBEND
* 2 bytes for CONTROL and INSTRUMENT events
	cmp.b   #$bf,d6
	bgt     .NOCONINS
	cmp.b   #$a0,d6
	blt     .NOCONINS
*       lea     2(a6),a6
	bra     SEND2
.NOCONINS
* 1 byte for PROGRAM change
	cmp.b   #$df,d6
	bgt     .NOPRG
	cmp.b   #$c0,d6
	blt     .NOPRG
*       lea     1(a6),a6
	bra     SEND1
.NOPRG
** 2 bytes for NOTE ON/OFF
	cmp.b   #$9f,d6
	bgt     .NO_NOTE
	bra     SEND2
.NO_NOTE rts

******

ENDOK
	clr.l   -(sp)
	move    #$20,-(sp)
	trap    #1
	addq.l  #6,sp
	movem.l (sp)+,d1-d7/a0-a6
	rts
ENDERROR
	clr.l   -(sp)
	move    #$20,-(sp)
	trap    #1
	addq.l  #6,sp
	movem.l (sp)+,d1-d7/a0-a6
*error result in d0
	moveq   #-1,d0
	rts

****************************FUNCTIONS***********************

OLPEEK  *input A0=ADDRESS of Odd LPEEK
	*output D0=longword at (a0)
	*       A0=A0+4
	move.b  (a0)+,d0
	lsl.w   #8,d0
	move.b  (a0)+,d0
	swap    d0
	move.b  (a0)+,d0
	lsl.w   #8,d0
	move.b  (a0)+,d0
	rts

ODPEEK  *input A0=ADDRESS of Odd LPEEK
	*output D0.w=word at (a0)
	*       A0=A0+2
	move.b  (a0)+,d0
	lsl.w   #8,d0
	move.b  (a0)+,d0
	rts

VARLEN  *input A0=ADDRESS of variable length number
	*ouput D0.l=NUMBER
	*      D1=smashed
	*      A0=Address after varlen number
	clr.l   d0
.vloop  lsl.l   #7,d0
	move.b  (a0)+,d1
	and.b   #$7f,d1
	add.b   d1,d0
	btst.b  #7,-1(a0)
	bne     .vloop
	rts


SEND1   
	bsr     PAUSE

	move    d6,d0
	bsr     SEND
	move.b  (a6)+,d0
	bsr     SEND
	bra     CHANGE_DTIMES
SEND2   bsr     PAUSE
	move    d6,d0
	bsr     SEND
	move.b  (a6)+,d0
	bsr     SEND
	move.b  (a6)+,d0
	bsr     SEND
CHANGE_DTIMES
* get accumulated delta time to d0
	move.l  8(a4,d5.w),d0
* subtract this dtime from all track dtimes (ended tracks may become -ve)
	clr.w   d1
.TLOOP
	addq.w  #1,d1
	move    d1,d2
	lsl     #4,d2
	sub.l   d0,8(a4,d2.w)
	cmp.w   d7,d1
	bne     .TLOOP
	rts

PAUSE
* get accumulated delta time to d0
	move.l  8(a4,d5.w),d0
	move.l  TEMPO(pc),d1
	mulu    d0,d1
	divu    #10000,d1
	and.l   #$ffff,d1
	move.l  $4ba.w,d0
	add.l   d1,d0
.wait   move.l  $4ba.w,d2
	cmp.l   d0,d2
	blt     .wait
	rts


SEND    movem.l d0-d2/a0-a2,-(sp)

*skip if channel off in filter table
	move.b  d6,d0
	and.w   #$000f,d0
	tst.b   (a2,d0.w)
	beq     .FILTER
	movem.l (sp),d0-d2/a0-a2
	move    d0,-(sp)
	move.l  #$00030003,-(sp)
	trap    #13
	addq.l  #6,sp
.FILTER
	movem.l (sp)+,d0-d2/a0-a2
	rts

******************************DATA*******************************
	section DATA
TEMPO   ds.l    1
TI      ds.l    64*4

CHANFILT dc.b   1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

MIDIFILE incbin d:\mods\midi\canzonii.mid
	even


*******************************BSS*******************************
	section BSS

ALLEND
