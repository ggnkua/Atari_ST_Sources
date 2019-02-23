********************************************************************************
*        receive()                                                             *
*           collects system exclusive dump into filebuf[],                     *
*           starts collecting with $F0, stops with any MIDI status byte        *
*           other than $FE (active sensing) or $F8 (MIDI clock), ignores       *
*           $FE and $F8 bytes, aborts on any ST keystroke, detects             *
*           filebuf[] overflow                                                 *
*        returns d0.l = number of bytes received                               *
*                     = 0 for abort, = 50001 for overflow                      *
*        preserves all registers except d0                                     *
********************************************************************************

 .text
 .globl _receive
_receive:
		movem.l    d1-a6,-(a7)    * save all registers except d0

		clr.l      d7             * start with zero byte count
		lea        _filebuf,a4    * a4--> buffer for MIDI bytes

		move.w     #2,-(a7)
		move.w     #14,-(a7)
		trap       #14
		addq.l     #4,a7
		movea.l    d0,a5          * a5 --> MIDI input record
		move.w     #1,-(a7)
		move.w     #14,-(a7)
		trap       #14
		addq.l     #4,a7
		movea.l    d0,a6          * a6 --> Keyboard input record

		clr.w      6(a5)          * clean out MIDI input queue
		clr.w      8(a5)
		clr.w      6(a6)          * clean out Keyboard input queue
		clr.w      8(a6)

loop1		move.w     6(a6),d0       * any keystroke aborts
		cmp.w      8(a6),d0
		bne        abort
		move.w     6(a5),d0
		cmp.w      8(a5),d0       * wait for MIDI byte
		beq        loop1

		move.w     #3,-(a7)       * get MIDI byte into d0.b
		move.w     #2,-(a7)
		trap       #13
		addq.l     #4,a7
		cmp.b      #$F0,d0        * wait for start of system exclusive
		bne        loop1
		
		moveq.l    #1,d7          * increment byte count
		move.b     #$F0,(a4)+     * first byte in filebuf[] is $F0

loop2		move.w     6(a6),d0       * any keystroke aborts
		cmp.w      8(a6),d0
		bne        abort
		move.w     6(a5),d0
		cmp.w      8(a5),d0       * wait for MIDI byte
		beq        loop2

		move.w     #3,-(a7)       * get MIDI byte into d0.b
		move.w     #2,-(a7)
		trap       #13
		addq.l     #4,a7

		cmp.b      #$FE,d0        * ignore active sensing
		beq        loop2
		cmp.b      #$F8,d0        * ignore MIDI clocks
		beq	   loop2
		tst.b      d0             * any other MIDI Status Byte ends
		bmi        done           * the system exclusive dump

		addq.l     #1,d7          * increment byte count
		cmpi.l     #50000,d7      * check for filebuf[] overflow
		bgt        exit           * if overflow, return byte count
		move.b     d0,(a4)+       * else append data byte to filebuf[]
		bra        loop2

done		addq.l     #1,d7          * increment byte count
		move.b     #$F7,(a4)+     * last byte in filebuf[] is $F7
		bra        exit

abort		clr.l      d7             * abort: zero byte count
                bra        exit

********************************************************************************
*        c_receive()                                                           *
*           collects Casio system exclusive dump into filebuf[],               *
*           returns d0.l = 256 for ok, 1 for synth i/o error                   *
*        preserves all registers except d0                                     *
********************************************************************************

 .globl _c_receive
_c_receive:
		movem.l    d1-a6,-(a7)   * save all registers except d0

		move.w     #2,-(a7)      * get pointer to MIDI input record
		move.w     #14,-(a7)
		trap       #14
		addq.l     #4,a7
		movea.l    d0,a5         * a5 --> MIDI input record   

		move.l     #_czmess1,-(a7)   * send first handshake
		move.w     #6,-(a7)          * # of bytes - 1
		move.w     #12,-(a7)
		trap       #14
		addq.l     #8,a7
         
		clr.w      6(a5)         * clean out midi buffer
		clr.w      8(a5)

		moveq      #5,d6         * # bytes-1 in expected response

cloop1		move.w     #$7FFF,d7     * time-out counter
cloop2		move.w     6(a5),d0
		cmp.w      8(a5),d0      * wait for MIDI byte
		bne        cgot1
		subq.w     #1,d7   	 * decrement time-out counter
      		bgt        cloop2
		bra        badret        * time-out error
cgot1		move.w     #3,-(a7)      * incoming midi byte: get it
       		move.w     #2,-(a7)
		trap	   #13
		addq.l	   #4,a7
		dbf        d6,cloop1     * loop for all bytes per response

		move.l     #_czmess2,-(a7)   * send second handshake
		move.w     #1,-(a7)          *    # of bytes - 1
		move.w     #12,-(a7)
		trap       #14
		addq.l     #8,a7
               
		clr.w      6(a5)         * clean out midi buffer
		clr.w      8(a5)

		lea        _filebuf,a6   * area to fill with incoming bytes
		move.w     #255,d6       * # bytes-1 in expected dump

cloop3		move.w     #$7FFF,d7     * time-out counter
cloop4		move.w     6(a5),d0
		cmp.w      8(a5),d0      * wait for MIDI byte
		bne        cgot2
		subq.w     #1,d7   	 * decrement time-out counter
      		bgt	   cloop4
		bra	   badret        * time-out error
cgot2		move.w     #3,-(a7)      * incoming midi byte: get it
       		move.w     #2,-(a7)
		trap	   #13
		addq.l	   #4,a7
      		tst.b      d0            * premature end of dump?
		bmi        badret        * yes: error
		move.b     d0,(a6)+      * no: put byte into filebuf
		dbf        d6,cloop3     * loop for all bytes in dump

		move.w     #$F7,-(a7)    * send $F7 to CZ to close dialog
		move.w     #3,-(a7)
		move.w     #3,-(a7)
		trap       #13
		addq.l     #6,a7

                move.l     #256,d7       * everything's fine
                bra        exit
badret:
                moveq      #1,d7

**** common exit point for everything in this module ****
exit		move.l     d7,d0
		movem.l    (a7)+,d1-a6    * restore all registers except d0
		rts                       * back to do_save()
