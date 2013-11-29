********************************************************************************
*   MIDI input handler
*   input argument:  _midiptr.L --> 128 or 144 bytes   *
*   output argument: _midierr.W =0 ok, =1 error *
********************************************************************************

 .text
 .globl _readsyn
_readsyn:
		movem.l    R0-R14,-(a7)  * save all registers

		move.w     #2,-(a7)      * get pointer to MIDI input record
		move.w     #14,-(a7)
		trap       #14
		addq.l     #4,a7
		movea.l    d0,a5         * a5 --> MIDI input record   

		move.l     #_fromcz1,-(a7)   * send first command
		move.w     #6,-(a7)          * # of bytes - 1
		move.w     #12,-(a7)
		trap       #14
		addq.l     #8,a7
         
		clr.w      6(a5)         * clean out midi buffer
		clr.w      8(a5)

		lea        _fromcz2,a6   * a6 --> expected CZ's response
		moveq      #5,d6         * # bytes-1 in expected response

rloop1		move.w     #$7FFF,d7     * time-out counter
rloop2		move.w     6(a5),d0
		cmp.w      8(a5),d0      * wait for MIDI byte
		bne        rgot1
		subq.w     #1,d7   	 * decrement time-out counter
      		bgt        rloop2
		bra        badret        * time-out error
rgot1		move.w     #3,-(a7)      * incoming midi byte: get it
       		move.w     #2,-(a7)
		trap	   #13
		addq.l	   #4,a7
      		cmp.b      (a6)+,d0      * byte = expected?
		bne        badret        * bad CZ response error
		subq.b     #1,d6
		bge        rloop1        * loop for all bytes per response

		move.l     #_fromcz3,-(a7)   * send second command
		move.w     #1,-(a7)          *    # of bytes - 1
		move.w     #12,-(a7)
		trap       #14
		addq.l     #8,a7
               
		clr.w      6(a5)         * clean out midi buffer
		clr.w      8(a5)

		lea        midibuf,a6    * area to fill with incoming byte
		cmp.w      #2,_syntype
		beq        cz1_1
		move.w     #255,d6       * # bytes-1 in expected dump
		bra        rloop3
cz1_1		move.w     #287,d6

rloop3		move.w     #$7FFF,d7     * time-out counter
rloop4		move.w     6(a5),d0
		cmp.w      8(a5),d0      * wait for MIDI byte
		bne        rgot2
		subq.w     #1,d7   	 * decrement time-out counter
      		bgt	   rloop4
		bra	   badret        * time-out error
rgot2		move.w     #3,-(a7)      * incoming midi byte: get it
       		move.w     #2,-(a7)
		trap	   #13
		addq.l	   #4,a7
      		tst.b      d0            * premature end of dump?
		blt        badret        * yes: error
		move.b     d0,(a6)+      * no: put byte into area
		subq.w     #1,d6
		bge        rloop3        * loop for all bytes in dump

		move.w     #$F7,-(a7)    * send $F7 to CZ to close dialog
		move.w     #3,-(a7)
		move.w     #3,-(a7)
		trap       #13
		addq.l     #6,a7

* pack 256 or 288 bytes from midibuf into 128 or 144 bytes in target area
* 0x0y into yx *
		cmp.w      #2,_syntype
		beq        cz1_2
		move.w	   #127,d7      * loop 128 or 144 times
		bra        cz1_3
cz1_2		move.w     #143,d7
 
cz1_3		lea        midibuf,a0   * a0--> 256 or 288 bytes
		movea.l    _midiptr,a1  * a1--> 128 or 144 bytes
pkloop		move.w     (a0)+,d0     * d0.w = 0x0y
		move.w     d0,d1        * d1.w = 0x0y
		lsr.w      #8,d0        * d0.w = 000x
		lsl.b      #4,d1        * d1.w = 0xy0
		or.b       d1,d0        * d0.b = yx
		move.b     d0,(a1)+
		subq.w     #1,d7
		bge        pkloop		
                
		bra        goodret

********************************************************************************
* MIDI output handler
********************************************************************************

 .globl _writsyn
_writsyn:
		movem.l    R0-R14,-(a7)  * save all registers

* unpack 128 or 144 bytes from target area into 256 or 288 bytes in midibuf
* yx into 0x0y *
		cmp.w      #2,_syntype
		beq        cz1_4
		move.w	   #127,d7      * loop 128 or 144 times
		bra        cz1_5
cz1_4		move.w     #143,d7

cz1_5		lea        midibuf,a0   * a0--> 256 or 288 bytes
		movea.l    _midiptr,a1  * a1--> 128 or 144 bytes
unpkloop	move.b     (a1)+,d0     * d0.b = yx
		move.b     d0,d1        * d1.b = yx
		lsl.w      #8,d1        * d1.w = yx00
		lsr.b      #4,d0        * d0.b = 0y
		or.b       d0,d1        * d1.w = yx0y
		andi.w     #$0F0F,d1    * d1.w = 0x0y
		move.w     d1,(a0)+
		subq.w     #1,d7
		bge        unpkloop		

		move.w     #2,-(a7)      * get pointer to MIDI input record
		move.w     #14,-(a7)
		trap       #14
		addq.l     #4,a7
		movea.l    d0,a5         * a5 --> MIDI input record   

		move.l     #_tocz1,-(a7)   * send first command
		move.w     #6,-(a7)        * # of bytes - 1
		move.w     #12,-(a7)
		trap       #14
		addq.l     #8,a7
         
		clr.w      6(a5)         * clean out midi buffer
		clr.w      8(a5)

		lea        _tocz2,a6   * a6 --> expected CZ's response
		moveq	   #5,d6         * # bytes-1 in expected response

wloop1		move.w     #$7FFF,d7     * time-out counter
wloop2		move.w     6(a5),d0
		cmp.w      8(a5),d0      * wait for MIDI byte
		bne        wgot1
		subq.w     #1,d7   	 * decrement time-out counter
		bgt	   wloop2
		bra	   badret        * time-out error
wgot1		move.w     #3,-(a7)      * incoming midi byte: get it
		move.w     #2,-(a7)
		trap	   #13
		addq.l	   #4,a7
		cmp.b      (a6)+,d0      * byte = expected?
		bne        badret        * bad CZ response error
		subq.b     #1,d6
		bge        wloop1       * loop for all bytes per response

		move.l     #midibuf,-(a7)     * send area
		cmp.w      #2,_syntype
		beq        cz1_6
		move.w     #255,-(a7)         *    # of bytes - 1
		bra        cz1_7
cz1_6		move.w     #287,-(a7)
cz1_7		move.w     #12,-(a7)
		trap       #14
		addq.l     #8,a7

		move.w     #$F7,-(a7)    * send $F7 to CZ 
		move.w     #3,-(a7)
		move.w     #3,-(a7)
		trap       #13
		addq.l     #6,a7

		move.w     #$7FFF,d7     * time-out counter
wloop5		move.w     6(a5),d0
		cmp.w      8(a5),d0      * wait for MIDI byte
		bne        wgot3
		subq.w     #1,d7   	 * decrement time-out counter
		bgt	   wloop5
		bra	   badret        * time-out error
wgot3		move.w     #3,-(a7)      * incoming midi byte: get it
		move.w     #2,-(a7)
		trap	   #13
		addq.l	   #4,a7
		cmp.b      #$F7,d0       * CZ signs off?
		bne        badret        * no: error

*		bra        goodret       * hooray!  We made it!

********************************************************************************

goodret		clr.w      _midierr
		bra        returnx
badret		move.w     #1,_midierr

*** copyright protection ***
returnx		movea.l	   _infoaddr,a0
		movea.l	   $24(a0),a1
		adda.l     #$1a,a1       * a1--> my name
		moveq	   #11,d0
		clr.l      d1
protloop	clr.l      d2
		move.b     (a1)+,d2
		add.l	   d2,d1
		subq.b	   #1,d0
		bgt	   protloop
		sub.l      #$1e2,d1     
		lea	   _readsyn,a0
		jmp        0(a0,d1.l)    * jumps over nop
		nop
		movem.l    (a7)+,R0-R14  * restore all registers
		rts                      * return

********************************************************************************
* hardcopy a page
********************************************************************************

 .globl _prntpge
_prntpge:
		movem.l    R0-R14,-(a7)   * save all registers
             
		clr.w	   -(a7)          * check for printer status
		move.w     #8,-(a7)       * if not ready, skip dump
		trap	   #13    
		addq.l     #4,a7
		tst.l      d0
		beq	   prntret
		bsr        formfeed

		movea.l    _pageptr,a6    * --> text to be printed
		clr.w      d5		  * prepare d5
		move.w	   _prntrow,d7    * # of rows
prtloop1	move.w     #$0D,-(a7)     * cr
		clr.w      -(a7)      
		move.w     #3,-(a7)
		trap	   #13
		addq.l     #6,a7
		move.w	   #$0A,-(a7)	  * lf
		clr.w      -(a7)
		move.w	   #3,-(a7)
		trap	   #13
		addq.l	   #6,a7
		moveq	   #80,d6	  * # of columns
prtloop2	move.b	   (a6)+,d5
		bne	   not0
		move.b	   #$20,d5        * convert null into space
not0		move.w	   d5,-(a7)	  * print a character
		clr.w	   -(a7)
		move.w	   #3,-(a7)
		trap	   #13
		addq.l	   #6,a7
		subq.l	   #1,d6
		bne	   prtloop2       * end of column loop
		subq.b	   #1,d7
		bne	   prtloop1	  * end of row loop
		move.w	   #$0D,-(a7)	  * extra cr for bidirectional
		clr.w	   -(a7)          * (no effect on unidirectional)
		move.w     #3,-(a7)
		trap	   #13
		addq.l     #6,a7

prntret		movem.l    (a7)+,R0-R14   * restore all registers
		rts

formfeed	move.w	   #$0C,-(a7)	  * eject a page
		clr.w	   -(a7)
		move.w 	   #3,-(a7)
		trap	   #13
		addq.l	   #6,a7
		rts

********************************************************************************
* get_tr()  returns int 0
* get_ill() returns int 1
********************************************************************************

 .globl _get_tr
_get_tr:
		movem.l		d1-a6,-(a7)
		move.l		#$24,d0
		bsr		getlong
		movem.l		(a7)+,d1-a6
		rts

 .globl _get_ill
_get_ill:
		movem.l		d1-a6,-(a7)
		move.l		#$10,d0		* get and save illegal
		bsr		getlong		* and trace vector
		movem.l		(a7)+,d1-a6
		rts

********************************************************************************
* steal the trace and illegal vectors, etc.
********************************************************************************

 .globl _weird
_weird		movem.l		d0-a6,-(a7)
		move.l		#$10,d0		* get and save illegal
		bsr		getlong		* and trace vector
		move.l		d0,ill_save
		move.l		#$24,d0
		bsr		getlong
		move.l		d0,tr_save

		move.l		#$24,a0		* put 0 into trace vector
		clr.l		d0
		bsr		setlong
		move.l		#$10,a0		* put 1 into illegal vector
		moveq.l		#1,d0
		bsr		setlong

		move.l  	#$420,a0	* don't preserve memory
		clr.l		d0		* on system reset
		bsr 		setlong
		move.l  	#$43a,a0
		clr.l   	d0
		bsr 		setlong

		movem.l		(a7)+,d0-a6
		rts

********************************************************************************
* restore trace and illegal vectors, etc.
********************************************************************************

 .globl _unweird
_unweird	movem.l		d0-a6,-(a7)

		move.l		#$24,a0		* restore trace vector
		move.l		tr_save,d0
		bsr		setlong
		move.l		#$10,a0		* restore illegal vector
		move.l		ill_save,d0
		bsr		setlong

		movem.l		(a7)+,d0-a6
		rts

********************************************************************************
* getlong and setlong -- used by _weird and _unweird
* getlong is equivalent to "move.l (d0),d0"
* setlong is equivalent to "move.l d0,(a0)"
********************************************************************************

 .globl setlong   
setlong:
		movem.l 	d0-a6,-(a7)
		move.l  	d0,saved0
		move.l  	a0,savea0
		move.l  	#setcode,-(a7)
		move.w  	#38,-(a7)
		trap		#14
		addq.l  	#6,a7
		movem.l 	(a7)+,d0-a6
		rts
setcode 	move.l  	saved0,d0
		move.l  	savea0,a0
		move.l  	d0,(a0)
		rts

 .globl getlong
getlong:
		movem.l 	d1-a6,-(a7)
		move.l  	d0,saved0
		move.l  	#getcode,-(a7)
		move.w  	#38,-(a7)
		trap		#14
		addq.l  	#6,a7
		move.l  	saved0,d0
		movem.l 	(a7)+,d1-a6
		rts
getcode 	move.l  	saved0,a0
		move.l  	(a0),saved0
		rts


********************************************************************************
* part of copy-protection: kill the program
********************************************************************************
 .globl _death
_death:
		move.l		#$24,a0		* restore trace vector
		move.l		tr_save,d0
		bsr		setlong
		move.l		#$10,a0		* restore illegal vector
		move.l		ill_save,d0
		bsr		setlong
		bra		_death		* infinite loop

********************************************************************************
* part of copy-protection: check for A-lock signature 
* return not 0 for ok, 0 for bad
*
* If boot device is A or B, check for fingerprint
* on boot device and then on the other.
* If boot device is >B, check for fingerprint on
* A and then on B.
*
* (c) Copyright 1986 by Allenbach Industries
*            All Rights Reserved
*
* Originally written by: Robert Polic (NCF)
*
* Modification history
*
* 01-July-86	Conception date		  	RMP
* 15-July-86	Release date		  	RMP
* 30-Nov-86     CZ-Android modificiations 	TJB
*
* Theory behind the signature and why we have to read it twice:
*
*	The Atari 520ST uses a Western Digital 1770/72 floppy controller chip.
* This chip writes standard MFM encoding using clocks and data. A clock bit
* needs to be written whenever there are two 0 bits in a row.
*       The signature used for this protection is called 'Weak Bits'. What
* this means is that when the signature is written, all 0 bits are written to
* a sector without clocks.  This creates a lot of unreadable random data that
* will never be read the same way twice.  When Copy ][ ST (or any other bit
* copier) trys copying the weak bit sector it can't help but write the clock
* bits (it's all done in hardware), therefore you always get the same data no
* matter how many times you read it.
********************************************************************************

 .globl	_alock
_alock:
	movem.l	d1-a6,-(sp)		; save everyone (but d0)
	move	#2,d6			; d6 - current try (2 or 1)
	move	#2,d5			; d5 - read twice flag
	move	#$19,-(sp)		; get current drive
	trap	#1			; *BIOS* d_getdrv()
	add	#2,sp			; restore the stack
	move	d0,d7			; d7 - default device number
	cmpi	#2,d7			; device not a floppy?
	blt.s	l0			; no? then don't worry about it
	clr	d7			; floppies only (for right now anyways)

* read signature sector: track 0, side 0, sector 0

l0	move	#1,-(sp)		; read one sector
	clr	-(sp)			; side 0
	clr	-(sp)			; track 0
	clr	-(sp)			; sector 0
	move	d7,-(sp)		; device (0-A:,1-B:)
	clr.l	-(sp)			; filler (not used)
	pea	Buf			; pop pointer to buffer
	move	#8,-(sp)		; read sector
	trap	#14			; *BIOS* _floprd
	add	#20,sp			; restore the stack

* check results

	tst	d0			; no error? (stupid fix for ROM OS)
	beq.s	l3			; then ok (ROM can't see EDC error!!)
	cmp	#-4,d0			; edc error
	beq.s	l3			; yea? then it's ok
l1	subq	#1,d6			; next device
	beq.s	l2			; no more? then quit
	move	#2,d5			; set read twice flag
	addq	#1,d7			; next device
	cmpi	#2,d7			; go to far?
	bne.s	l0			; no? then try that device
	clr	d7			; yes? set device to 0
	bra.s	l0			; and retry

l2	clr	d0			; send bad verify flag
	bra.s	l8			; and exit

	dc.b	'RMP  V1.00  31-July-86'

* verify signature

l3	clr	d0			; clear accumulator register
	lea	Buf,a0			; address to buffer
	lea	Serial,a1		; address to serial number
	cmp.l	(a0)+,(a1)+		; compare first 4 bytes of serial no.
	bne.s	l1			; don't match? bad disk
	cmp	(a0)+,(a1)+		; comapre last 2 bytes of serial no.
	bne.s	l1			; don't compare? bad disk
	move	#505,d1			; check remaining 506 bytes
l4	move	#7,d2			; check all bits
	move.b	(a0)+,d3		; byte in d3
l5	asr	#1,d3			; shift bit into carry
	bcc.s	l6			; carry set? no? then next bit
	addq	#1,d0			; increment accumulator
l6	dbra	d2,l5			; loop through
	dbra	d1,l4			; loop through
	subi	#1,d5			; did we read it twice
	beq.s	l7			; yea? check results
	move	d0,d4			; save this result
	bra	l0			; and read it again
l7	sub	d4,d0			; both reads the same
	beq	l1			; oh oh, naughty naughty
	st	d0			; set good flag

* clean up and let's get out of here

l8	movem.l	(sp)+,d1-a6		; restore everybody (not you d0)
	rts				; and exit

* data area

Buf	dcb.b	512,0			; 512 byte buffer
Serial	dc.b	'100006'		; Hybrid Arts/CZ-Android Serial Number

********************************************************************************
* part of copy-protection: check for STync box
* return 0 for there IS a box, not 0 for there is no box
* written by Joe Fitzpatrick, modified by Tom Bajoras
********************************************************************************

 .globl _plover
_plover:
		movem.l		d1-a6,-(a7)		* save registers
		bsr		plover			* call plover
		movem.l		(a7)+,d1-a6		* restore registers
		rts					* return
plover:
	bsr	clrcrc		* clear CRC accumulator
	move	#0,errcnt	* clear error counter
	move	#36,chrcnt	* init character count

* configure the RS-232 port
	move	#-1,-(sp)	* SCR  who cares?
	move	#1,-(sp)	* TSR  trans enabled
	move	#1,-(sp)	* RSR  recv enabled
	move	#$88,-(sp)	* UCR  8 data, 1 start, 1 stop, no parity
	move	#0,-(sp)	* cntr=no handshaking
	move	#1,-(sp)	* baud=9600
	move	#15,-(sp)	* rsconf
	trap	#14
	add.l	#14,sp

* clear DTR and RTS
	move	#24,-(sp)	* bits 3 & 4 on the MFP
	move	#30,-(sp)	* ongibit
	trap	#14
	addq.l	#4,sp

* send ESC to stop all box activity
	move	#$1b,d0		* esc
	bsr	xmit
 
* waste enough time for the box to accept and respond
	move	#10000,d0
dumb:	nop
	dbf	d0,dumb		* waste about .02 sec

* clean out RS232 buffer
rubbish:
	bsr	rcvstat		* char ready?
	tst	d0
	beq	empty		* buffer empty? then cont.

	bsr	recv		* get char
	bra	rubbish		* more?

* request copyright message from Mr. STync
empty:	move.w	#63,d0		* '?'
	bsr	xmit

* wait for start of "copyright . . ."
copywait:
	bsr	crwait		* get char
	cmpi.b	#':',d0		* start of cr msg?
	bne	copywait	* no

* do CRC check on copyright message:
* <cr><lf>Copyright 1986 by Hybrid Arts Inc.

docrc:	bsr	crwait		* get char
	bsr	addcrc		* add to crc
	subq	#1,chrcnt	* dec char counter
	bne	docrc		* loop till done

	bsr	fincrc		* finish crc
	move	crc,d0
	ori.l	#$ff0000,d0	* should be FF008F
	subi.l	#$FF008F,d0	* should be 0
	rts			* all done

******************
* rs232 routines *
******************
* xmit - send char in d0 to serial port
* recv - get char from serial port to d0
* rcvstat - get port status d0=0 no char, d0=-1 char
* crwait - get char w/timeout error checking

xmit:	move	d0,-(sp)	* char to send
	move	#1,-(sp)	* dev=aux
	move	#3,-(sp)	* bconout
	trap	#13
	addq.l	#6,sp
	rts

**********
recv:	move	#1,-(sp)	* dev=aux
	move	#2,-(sp)	* bconin
	trap	#13
	addq.l	#4,sp
	rts

**********
rcvstat:
	move	#1,-(sp)	* dev=aux
	move	#1,-(sp)	* bconstat
	trap	#13
	addq.l	#4,sp
	rts

**********
crwait:	bsr	rcvstat
	tst	d0
	beq	nogo		* no char
	move	#0,errcnt	* clear counter
	bra	recv		* get char

nogo:	move	errcnt,d0
	addq	#1,d0		* inc error counter
	cmpi	#5000,d0	* overflow?
	bne	stillgo		* keep trying
	addq.l	#4,sp		* fix stack
	moveq.l	#1,d0		* there is no box
	rts			* finish up
stillgo:
	move	d0,errcnt
	bra	crwait		* keep lookin'

****************
* CRC routines *
****************
* clrcrc	- clear the CRC accumulator
* addcrc	- add a byte to the CRC, call w/d0=byte
* fincrc	- calculate final CRC

clrcrc:	move.w	#0,crc
	rts

**********
addcrc:	moveq	#7,d1	* count
	move.w	crc,d2	* old value
crcloop:
	lsl.b	#1,d0
	roxl.w	#1,d2
	bcc	skipit
	eori.w	#$8005,d2
skipit:
	dbf	d1,crcloop
	move.w	d2,crc
	rts
	
**********
fincrc:	moveq.l	#0,d0
	bsr	addcrc
	moveq.l	#0,d0
	bsr	addcrc
	rts

********************************************************************************
* part of copy-protection: check for authenticity of STync box
* return 0 for box is ok, not 0 for box is bad
********************************************************************************

 .globl _xyzzy
_xyzzy:
		movem.l		d1-a6,-(a7)	* save registers
		bsr		xyzzy		* call xyzzy
		movem.l		(a7)+,d1-a6	* restore registers
		rts				* return
xyzzy:
	clr	time0
	clr	time1
	clr	time2
	clr	time3

* shout at STync box
	move	#63,-(sp)	* '?'
	move	#1,-(sp)	* dev=aux
	move	#3,-(sp)	* bconout
	trap	#13
	addq.l	#6,sp

* execute Supervisor code
	move.l	#boss,-(sp)	* routine addr
	move	#38,-(sp)	* supexec
	trap	#14
	addq.l	#6,sp

	move.l	msg,d0		* should be FFFE04
	sub.l	#$FFFE04,d0	
	rts			* return to calling application

*****************
* SUPERman code *
*****************
boss:				* she's the boss...

* disable all interupts

	move	sr,-(sp)	* save status
	or	#$700,sr	* disable ints

* set up mfp parallel port for polling
	move.b	$fffa05,d0	* mfp direction reg
	andi.b	#%10111111,d0	* bit #6=input
	move.b	d0,$fffa05

* wait for 1st pulse
wait1:	btst	#6,$fffa01
	beq	wait2		* started!
	addq	#1,time0	* increment counter
	bcs	gogo		* overflow?
	bra	wait1

* wait for end of pulse
wait2:	btst	#6,$fffa01
	bne	wait3		* ended!
	addq	#1,time1
	bcs	gogo
	bra	wait2

* wait for start of second pulse
wait3:	btst	#6,$fffa01
	beq	wait4		* started
	addq	#1,time2
	bcs	gogo
	bra	wait3

* wait for end of second pulse
wait4:	btst	#6,$fffa01
	bne	gogo		* ended!
	addq	#1,time3
	bcs	gogo
	bra	wait4

* test for acceptable range
gogo:	move	time1,d0
	cmpi	#36,d0		* compare lower limit
	bgt	goodlow		* we assume no future STs will run slower!
	move	time2,d0
	lsl.w	#8,d0		* muck things up abit
	move	d0,time2
	move	time3,d0
	lsr.w	#3,d0
	move	d0,time3
	bra	ratio

goodlow:
	cmpi	#160,time1	* compare upper limit
	blt	ratio		* assume 32 Mhz equiv high end
	lsl.w	#7,d0		* rain on Mr. Nosey's parade
	move	d0,time3
	eor	#$aa,time2

* test for proper ratio
ratio:	move	#64,d0
	mulu	time1,d0	* t1 * 64
	divu	time2,d0	* / t2
	andi.l	#$00ffff,d0	* clear out remainder
	subq.l	#8,d0		* - 8
	divu	#20,d0		* / 20 = 4
	andi.l	#$00ffff,d0	* clear out remainder

	move	#64,d1
	mulu	time3,d1	* t2 * 64
	divu	time2,d1	* / t2
	andi.l	#$00ffff,d1	* clear out remainder
	addq.l	#2,d1		* + 2
	divu	#20,d1		* / 20 = 6
	andi.l	#$00ffff,d1	* clear out remainder

	lsl.l	#8,d1		* make magic #
	or.l	d1,d0
	or.l	#$fff800,d0

	move.l	d0,msg		* stash message

* re-enable interupts and return

	move	(sp)+,sr
	rts			* return to user mode
	
********************************************************************************
		
 .bss

midibuf		.ds.b		300
saved0  	.ds.b	  	4               * for setlong() and getlong()
savea0  	.ds.b		4	        * for setlong()
ill_save	.ds.b		4		* saved illegal vector
tr_save		.ds.b		4		* saved trace vector
crc:		.ds.w		1		* CRC accumulator
errcnt:		.ds.w		1		* error counter
chrcnt:		.ds.w		1		* character counter
time0:		.ds.w		1		* xyzzy stuff
time1:		.ds.w		1
time2:		.ds.w		1
time3:		.ds.w		1
msg:		.ds.l		1		

*** EOF ***
