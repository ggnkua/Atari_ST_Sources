;;; ----------------------------------------------------------------------
;;;  PROTOMUS playback system for Atari ST
;;;   (c) Michael C. Martin, 2021. Published under the MIT license.
;;;
;;;  This is a very simple music player for the Atari ST, based on the
;;;  ProtoMus system for the Commodore 64. It supports up to three voices
;;;  of square wave playback, but does not support noise channels or
;;;  hardware envelopes.
;;;
;;;  This file defines four functions with C linkage compatible with
;;;  the vbcc toolchain:
;;;
;;;   void song_init(const char **song);
;;;   void song_wait(void);
;;;   void song_step(void);
;;;   void song_end(void);
;;;
;;;   The song pointer is an array to three streams of bytecode, one for
;;;   each voice. The bytecode is a stream of these commands (in hex):
;;;      80 nn:                Rest for nn steps.
;;;      81 xxxx:              Reset playback to byte xxxx in this array.
;;;      82 dddd ssss rrrr zz: Configure instrument:
;;;                              Decay speed    d
;;;                              Sustain target s
;;;                              Release speed  r
;;;                              Staccato steps z
;;;      0c nn:                Play note C-1 for nn steps.
;;;      0d nn:                Play note C#-1 for nn steps.
;;;      ...
;;;      30 nn:                Play note C-4 (middle C) for nn steps.
;;;      ...
;;;      5f nn:                Play note B-7 for nn steps.
;;;
;;;   song_init() and song_end() should each be called only once per song
;;;   at each end of the playback. song_wait() will delay a variable
;;;   amount of time aiming for a 15ms gap between calls (66.67 Hz). The
;;;   song_step() function actually updates the sound state.
;;; ----------------------------------------------------------------------

;;; --- VOICE DATA STRUCTURE DEFINITION ---
VOX_BASE     = 0			; Bytecode stream base pointer
VOX_CURRENT  = 4			; Bytecode stream current pointer
VOX_NEXT_TIME= 8			; Number of steps to next command
VOX_REL_TIME =10			; Number of steps to note release
VOX_FREQ_CUR =12			; Current frequency code
VOX_VOL_CUR  =14			; Current volume
VOX_VOL_TGT  =16			; Current volume target
VOX_VOL_DELTA=18			; Amt to subtract each step
VOX_DEC_DELTA=20			; Decay-phase delta
VOX_SUS_TGT  =22			; Only decay to this volume
VOX_REL_DELTA=24			; Release-phase delta
VOX_STACCATO =26			; Steps to release before next note
VOX_SIZE     =28			; Total size of structure

;; Volume amounts and deltas range from $0000 to $0FFF; only the high byte
;; is actually sent to the sound chip.

	text

	public	_song_init
	public	_song_wait
	public	_song_step
	public	_song_end

;;; Takes pointer argument on stack to array of per-voice bases.
;;; Initializes the voice array to the start of each voice, with no
;;; instrument selected.
_song_init:
song_init:
	move.l	4(sp),a0		; Load argument into a0
	movem.l	a2-3/d2,-(sp)
	lea	voices,a1		; Voice state in a1
	moveq	#2,d0			; For each voice...
.lp:	move.l	(a0),(a1)+		; Lay down two copies of the
	move.l	(a0)+,(a1)+		; start ptr for base/current
	move.w	#((VOX_SIZE-8)/2)-1,d1	; And then fill the rest of
.lp2:	clr.w	(a1)+			; the structure with zeroes
	dbra	d1,.lp2
	dbra	d0,.lp
	lea	init_ay7,a3		; Have we already cached the
	tst.l	(a3)			; original value of register 3?
	bne.s	.fin			; If so, we're done
	move.w	#7,-(sp)		; Otherwise fetch it
	clr.w	-(sp)
	move.w	#28,-(sp)		; with Giaccess()
	trap	#14			; on XBIOS
	move.l	d0,(a3)			; and cache it for later
	addq.l	#6,sp
.fin:	movem.l	(sp)+,a2-3/d2
	rts

;;; song_wait: on first call, wait 15ms. Otherwise wait until 15ms since
;;;            the last time we called.
_song_wait:
song_wait:
	movem.l	a2/d2,-(sp)
	clr.l	-(sp)			; Enter supervisor mode
	move.w	#32,-(sp)
	trap	#1
	move.l	d0,2(sp)		; And prep for user restore
	move.w	#32,(sp)
	lea	wait_target,a0
	lea	$04ba,a1		; hz_200
	move.l	(a0),d0
	bne.s	.do_wait
	;; First run; use our current time as the start
	move.l	(a1),d0
.do_wait:
	addq.l	#3,d0			; Target is 15ms from last
.buzz:	cmp.l	(a1),d0
	bhi.s	.buzz
	move.l	d0,(a0)			; Remember time for next time
	trap	#1			; Restore user mode
	addq.l	#6,sp			; Restore stack
	movem.l	(sp)+,a2/d2
	rts

;;; song_end: Silence the sound chip and restore any cached I/O status.
_song_end:
song_end:
	movem.l	a2-3/d2-3,-(sp)
	subq.l	#6,sp
	moveq	#2,d3			; For each voice...
.lp:	move.w	#136,d0			; Set the volume register to 0
	add.w	d3,d0
	move.w	d0,4(sp)
	clr.w	2(sp)
	move.w	#28,(sp)		; With Giaccess()
	trap	#14			; on XBIOS
	dbra	d3,.lp
	lea	init_ay7,a3		; Do we have a nonzero cached value?
	tst.l	(a3)
	beq.s	.fin			; If not, we're done
	move.l	(a3),d0
	move.w	#135,4(sp)		; Otherwise write it to register 7
	move.w	d0,2(sp)
	move.w	#28,(sp)		; With Giaccess()
	trap	#14			; on XBIOS
.fin:	addq.l	#6,sp
	clr.l	(a3)			; Delete any cached I/O state
	movem.l	(sp)+,a2-3/d2-3
	rts

;;; song_step: Advance song playback by one step and update the sound
;;;            registers as needed.
_song_step:
song_step:
	movem.l	a2-4/d2,-(sp)
	lea	voices,a0		; Load the voice array into our
	move.l	a0,a4			; iterator, and cache the start
	moveq	#2,d1			; For each voice...
.voice_loop:
	move.w	VOX_VOL_CUR(a0),d0	; Subtract current delta from
	sub.w	VOX_VOL_DELTA(a0),d0	;   current volume...
	cmp.w	VOX_VOL_TGT(a0),d0	; ... with a minimum of current
	bpl.s	.vol_updated		;   target
	move.w	VOX_VOL_TGT(a0),d0
.vol_updated:
	move.w	d0,VOX_VOL_CUR(a0)	; And store it back in volume
	move.l	VOX_CURRENT(a0),a1	; Load current point in byte stream
.cmd_loop:
	tst.w	VOX_NEXT_TIME(a0)	; Waiting for the next command?
	bne	.cmds_done		; If so, we're done reading cmds
	clr.w	d0			; Read a byte
	move.b	(a1)+,d0
	cmp.b	#$80,d0			; Rest command?
	bne	.not_rest
	clr.w	VOX_VOL_TGT(a0)		; Target volume zero
	move.w	VOX_REL_DELTA(a0),VOX_VOL_DELTA(a0)
	clr.w	VOX_REL_TIME(a0)	; Release mode immediately
	clr.w	VOX_NEXT_TIME(a0)	; Read one-byte unsigned duration
	move.b	(a1)+,(VOX_NEXT_TIME+1)(a0)
	bra.s	.cmd_loop
.not_rest:
	cmp.b	#$81,d0			; GOTO command?
	bne	.not_goto
	move.b	(a1)+,d0		; Read 16-bit big-endian value
	lsl.w	#8,d0
	move.b	(a1)+,d0
	move.l	VOX_BASE(a0),a1		; and update a1 to point at
	lea	(a1,d0),a1		; that index
	bra.s	.cmd_loop		; and read the command there
.not_goto:
	cmp.b	#$82,d0			; INSTRUMENT command?
	bne	.not_instrument
	moveq	#7,d0			; Seven bytes of data,
	lea	VOX_DEC_DELTA(a0),a2	; starting at decay-delta,
.inslp:	move.b	(a1)+,(a2)+		; copied directly into the 
	dbra	d0,.inslp		; structure.
	bra.s	.cmd_loop		; Proceed to next command
.not_instrument:
	lea	frequency_table,a2	; It's a note
	lsl.w	#1,d0			; byte to word offset
	;; Copy note data into place from table
	move.w	(a2,d0),VOX_FREQ_CUR(a0)
	move.w	#$0FFF,VOX_VOL_CUR(a0)	; start at max volume
	;; Copy sustain target and decay rate into place
	move.w	VOX_SUS_TGT(a0),VOX_VOL_TGT(a0)
	move.w	VOX_DEC_DELTA(a0),VOX_VOL_DELTA(a0)
	move.b	(a1)+,d0		; Note duration
	move.w	d0,VOX_NEXT_TIME(a0)	; ... is time to next note
	sub.w	VOX_STACCATO(a0),d0	; Subtract staccato constant...
	cmp.w	#1,d0			; ... minimum 1...
	bpl.s	.relok
	moveq	#1,d0
.relok:	move.w	d0,VOX_REL_TIME(a0)	; ... to get time to release.
	bra	.cmd_loop
.cmds_done:
	move.l	a1,VOX_CURRENT(a0)	; Update command pointer
	subq.w	#1,VOX_NEXT_TIME(a0)	; Decrement time to next cmd
	cmp.w	#1,VOX_REL_TIME(a0)	; If counting down to release...
	bmi.s	.one_voice_done
	subq.w	#1,VOX_REL_TIME(a0)	; ... decrement, and if that's 0...
	bne.s	.one_voice_done
	clr.w	VOX_VOL_TGT(a0)		; target silence and use release delta
	move.w	VOX_REL_DELTA(a0),VOX_VOL_DELTA(a0)
.one_voice_done:
	add.l	#VOX_SIZE,a0		; Advance pointer to next voice
	dbra	d1,.voice_loop		; and loop back.
	;; Voice state has been updated. Now we mirror the relevant
	;; data to the sound chip.
	subq.l	#6,sp			; Make room for Giaccess() call
	lea	ay3_dump,a3		; info in ay3-dump table
.aylp:	clr.l	2(sp)			; Clean out arguments
	move.b	(a3)+,5(sp)		; Load register to write (128+reg)
	beq.s	.fin			; (end loop if it's zero)
	clr.w	d0			; Read index from voice array to
	move.b	(a3)+,d0		; actually store
	move.b	(a4,d0),3(sp)		; and copy that as the value
	move.w	#28,(sp)		; for Giaccess()
	trap	#14			; in XBIOS
	bra.s	.aylp			; continue until we read a zero
.fin:	move.w	#135,4(sp)		; Enable all three square voices
	move.w	#56,2(sp)
	move.w	#28,(sp)		; with Giaccess()
	trap	#14			; in XBIOS
	addq.l	#6,sp			; Clean up stack
	movem.l	(sp)+,a2-4/d2
	rts

	data
	;; Precomputed frequency codes for each note from C-0 to B-7.
	;; C-0 to A#-0 are out of range but valid (incorrect) data is
	;; present to allow music code to transport between C64 and ST
	;; editions of ProtoMus
frequency_table:
	dc.w	$0FFF, $0FFF, $0FFF, $0FFF, $0FFF, $0FFF, $0FFF, $0FFF
	dc.w	$0FFF, $0FFF, $0FFF, $0FD2, $0EEE, $0E18, $0D4D, $0C8E
	dc.w	$0BDA, $0B2F, $0A8F, $09F7, $0968, $08E1, $0861, $07E9
	dc.w	$0777, $070C, $06A7, $0647, $05ED, $0598, $0547, $04FC
	dc.w	$04B4, $0470, $0431, $03F4, $03BC, $0386, $0353, $0324
	dc.w	$02F6, $02CC, $02A4, $027E, $025A, $0238, $0218, $01FA
	dc.w	$01DE, $01C3, $01AA, $0192, $017B, $0166, $0152, $013F
	dc.w	$012D, $011C, $010C, $00FD, $00EF, $00E1, $00D5, $00C9
	dc.w	$00BE, $00B3, $00A9, $009F, $0096, $008E, $0086, $007F
	dc.w	$0077, $0071, $006A, $0064, $005F, $0059, $0054, $0050
	dc.w	$004B, $0047, $0043, $003F, $003C, $0038, $0035, $0032
	dc.w	$002F, $002D, $002A, $0028, $0026, $0024, $0022, $0020

	;; Pairs of indices, into the AY chip and the voices array,
	;; respectively, indicating what values are to be copied where
	;; to mirror the playback state on the chip as a whole.
ay3_dump:
	dc.b	128,13,129,12,130,41,131,40,132,69,133,68
	dc.b	136,14,137,42,138,70,0,0

	even
	;; The initial value of AY register 7, so that we may restore it
	;; on song end. Used by song_init and song_end.
init_ay7:
	dc.l	0

	;; The timestamp of the last time we finished waiting for a
	;; playback step. Used by song_wait.
wait_target:
	dc.l	0

	bss
	even
	;; The three voice structures for storing the current state for
	;; song playback
voices:	ds.b	VOX_SIZE * 3

	text
