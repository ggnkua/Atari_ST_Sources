
; MP2 Player shell
; For Falcon demoshell
;
; Anders Eriksson
; ae@dhs.nu
;
; January 23, 2000
;
; Patched to support direct 2 disk replay by ray//.tSCc. , march 2005


musicflag 	=	1

		rsset	28
mp2_address 	rs.l	1	; Offsets
mp2_length 	rs.l	1
mp2_freq 	rs.l	1
mp2_ext 	rs.l	1
mp2_repeat 	rs.l	1
mp2_start 	rs.l	1
mp2_stop 	rs.l	1
mp2_lenpatch	rs.l	1

mp2_intspeed 	=	32000	;49170	; Internal speed
mp2_extspeed 	=	0	; External speed (0=disable)
mp2_loop 	=	1	; 0=single play 1=loop




************************************************************
*
*  void mp2load(long *filename)
*
* Initialise d2d replay method or load the whole mp2 into
* STRAM if enough memory is available
*
************************************************************

		section	text
mp2load		move.w	#-1,mp2buffer	; Assume direct from disc replay

		clr.w	-(sp)		; Fsfirst()
		move.l	filename(pc),-(sp)
		move.w	#$4e,-(sp)
		trap	#1
		addq.l	#8,sp

		tst.l	d0		; File found?
		bne.w	.break

		clr.w	-(sp)
		move.l	dta+26,-(sp)
		move.w	#$44,-(sp)	; Mxalloc()
		trap	#1
		addq.l	#8,sp

		tst.l	d0		; Failed to allocate space for the whole file, use
		beq.s	.dfd		; direct from disc method

		move.l	d0,DMAbuffer1
		clr.w	mp2buffer	; Clear dfd mode
		
		clr.w	-(sp)		; Open file, read only
		move.l	filename,-(sp)
		move.w	#$3d,-(sp)
		trap	#1
		addq.l	#8,sp
		move.w	d0,filenumber	; Store filenumber
		
		move.l	DMAbuffer1(pc),-(sp)	; Read the whole file
		move.l	dta+26,d0		; filelength
		move.l	d0,-(sp)
		move.l	d0,DMAbuflen
		lsr.l	d0
		move.l	d0,mp2_player+mp2_lenpatch	; Patch in filelength in words

		move.w	filenumber(pc),-(sp)
		move.w	#$3f,-(sp)
		trap	#1
		lea.l	12(sp),sp
 
 		clr.l	filename
.break		rts

		; Initialise dfd method otherwise
.dfd		clr.w	-(sp)		
		pea.l	$20000.l	; Allocate 2*64k dma double buffer
		move.w	#$44,-(sp)
		trap	#1
		addq.l	#8,sp

		tst.l	d0 
		beq.w	exit
	
		lea.l	DMAbuffer1(pc),a0
		move.l	d0,(a0)+
		addi.l	#$10000,d0
		move.l	d0,(a0)+

		move.l	#$20000,DMAbuflen
		
		move.l	dta+26,d0
		lsr.l	d0
		move.l	d0,mp2_player+mp2_lenpatch	; Patch in filelength in words

		clr.w	-(sp)		; Open file, read only
		move.l	filename,-(sp)
		move.w	#$3d,-(sp)
		trap	#1
		addq.l	#8,sp
		move.w	d0,filenumber	; Store filenumber
 
 		clr.l	filename

		move.l	DMAbuffer1(pc),-(sp)	; Read the first 64k
		pea.l	$10000.l
		move.w	filenumber(pc),-(sp)
		move.w	#$3f,-(sp)
		trap	#1
		lea.l	12(sp),sp
		rts

		
************************************************************
*
*  void mp2feeder()
*
* Call this every mainloop so that the audio DMA buffer gets
* refilled directly from disc
*
************************************************************

mp2feeder	move.l	$ffff8908.w,d0	; Resolve current DMA frame
		lsl.w	#8,d0
		move.b	$ffff890d.w,d0

		move.l	DMAbuffer2(pc),d1

		tst.w	mp2buffer	; Do i use dfd method?
		beq.s	.break		; no, exit
		bpl.s	.buf1
		
		cmp.l	d1,d0		; Update buffer 2 if neccessary 
		bhi.s	.break
		
		move.l	d1,-(sp)
		bra.s	.read
		
.buf1		cmp.l	d1,d0		; Update buffer 1 if neccessary
		blo.s	.break

		move.l	DMAbuffer1(pc),-(sp)	; Read following 64k off the disc

.read		pea.l	$10000.l
		move.w	filenumber(pc),-(sp)
		move.w	#$3f,-(sp)
		trap	#1
		lea.l	12(sp),sp

		neg.w	mp2buffer	; "swap" buffers

.break		rts		


mp2buffer	ds.w	1		; Current buffer (+1:DMAbuffer1, -1:DMAbuffer2)

filename	dc.l	mp2_file
filenumber	ds.w	1

DMAbuffer1	ds.l	1
DMAbuffer2	ds.l	1
DMAbuflen	ds.l	1



************************************************************
*
*  void mp2start()
*
* initialise and start mp2 replayer
*
************************************************************

mp2start	lea.l	mp2_player+mp2_address,a0 
		move.l	DMAbuffer1(pc),(a0)+ 
		move.l	DMAbuflen(pc),(a0)+
		move.l	#mp2_intspeed,(a0)+
		move.l	#mp2_extspeed,(a0)+
		move.l	#mp2_loop,(a0)+
		jmp	mp2_player+mp2_start



************************************************************
*
*  void mp2stop()
*
* deinitialise and stop mp2 replayer
*
************************************************************

mp2stop		move.l	DMAbuffer1(pc),-(sp)	; Release DMA buffers
		move.w	#$49,-(sp)
		trap	#1
		addq.l	#6,sp

		move.w	filenumber,-(sp)	; Close stream
		move.w	#62,-(sp)
		trap	#1
		addq.l	#4,sp
		jmp	mp2_player+mp2_stop	; Stop music


		section	data
mp2_file	dc.b	'music\beams.mp2',0	; MP2 filenames
		even

mp2_player	incbin	'sys\mp2inc.bin'	; Patched mp2 player
		even