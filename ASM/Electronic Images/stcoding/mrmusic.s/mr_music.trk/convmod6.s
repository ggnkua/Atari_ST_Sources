;
; AMIGA .MOD file to Mr Music SNG format converter.  Please note that
; samples need to be converted to 11Khz using quartet's digital.  Any
; channels that also start out empty MUST have a 'set volume' command
; of 0 ('C00') at the beggining of the relevant channels at the start
; of the first pattern (oo-er!!).
;
; To turn off a sample, just issue a Volume command of C00 on any channel.
;
; Pattern break commands are on CHANNEL 1 ONLY!
;
; NOTE that for it to work properly ANY speed changes (Fxx command) MUST be
; in the first channel.  This'll probably be solved soon!
;
; This one pre-multiplies the note and sample number values so the MR MUSIC
; player is faster!  It needs MR_MUSIC.XRF and generates .SNF files so no
; confusing little bombs appear!!
;


channel_size	equ	48000		; Size allocated per channel.
default_speed	equ	6		; Default VBL speed in MOD.



;-------------------------- MACROS (for convert) --------------------

; Actually convert what's in the MOD file...
do_conv	MACRO

; We can use D5-D6 and A5 as work registers.

; Process parameters.
	bsr	get_patt_data
	cmpi.w	#$f,d0			; Check for speed change.
	bne.s	nospeed\@
	tst.w	d1			; Check for illegal speed (0).
	beq.s	process_insts\@
	move.w	d1,num_vbls		; Store parameter.
;	move.w	d1,new_vbl_count
;	tst.w	d2			; Check for empty channel too.
;	beq	voice_off\@
	bra.s	process_insts\@
nospeed\@
	cmpi.w	#$c,d0			; Check for volume command.
	bne.s	novol\@
	tst.w	d1			; Check for zero volume.
	bne.s	novol\@			; Skip if we have a volume.
	bra.s	voice_off\@		; If zero, we have a rest (off).
novol\@
	cmpi.w	#$d,d0			; Check for pattern break.
	bne.s	nobreak\@
	lea	4*3(a6),a6		; Skip other channels commands!
	bra	patt_break		; Skip any more reads.
nobreak\@

process_insts\@
; Process instruments (if any).
	tst.w	d2			; Check for no isntrument.
	beq.s	empty\@

;	illegal

	move.w	(a0),-2(\1)		; Put count of VBL's.
	move.w	num_vbls(pc),(a0)	; And restore.
	moveq	#%0000000000000011,d6	; Command is new sample + note.
	move.l	inst_addr(pc),a5	; Get instrument list address.
	move.w	d2,d5			; Get instrument.
	subq.w	#1,d5			; Adjust.
	mulu	#30,d5			; Size of instrument structure.
	lea	28(a5,d5.w),a5		; Now point to instrument loop
					; data (if any).
	cmpi.w	#2,(a5)			; Check for instrument loop.
	ble.s	noloop\@		; None, skip.
	or.w	#%0100000000000000,d6	; Yes, signal a looped sample.
noloop\@	
	move.w	d6,(\1)+		; Store command word.
	subq.w	#1,d2			; Adjust (0 ... n ) instrument.
	lsl.w	#3,d2			; Pre-multiply it.
	move.w	d2,(\1)+		; Store instrument.
	move.w	d3,d5			; Get frequency.
	lea	convert(pc),a5
	add.w	d5,d5
	move.w	(a5,d5.w),d5
;	lsr.w	#4,d5			; Cut down to 0-64 for Mr Music.
	lsl.w	#8,d5
	lsl.w	#1,d5			; Pre-multiply it.
	move.w	d5,(\1)+		; Store note.
;	move.w	num_vbls(pc),(\1)+	; And store duration.	
	move.w	#1,(\1)+		; Dummy duration.
	bra.s	end_conv\@

empty\@
	move.w	num_vbls(pc),d5
	add.w	d5,(a0)
	bra.s	end_conv\@

voice_off\@
	move.w	(a0),-2(\1)		; Put count of VBL's.
	move.w	num_vbls(pc),(a0)	; And restore.
	move.w	#%0000000000001000,(\1)+	; Issue a rest command.
;	move.w	num_vbls(pc),(\1)+	; For MOD set speed.
	move.w	#1,(\1)+		; Dummy duration.

end_conv\@		
	ENDM


;--------------------------------------------------------------------



	move.w	#%0000000000001000,channel1	; Init rests for channels.
	move.w	#%0000000000001000,channel2
	move.w	#%0000000000001000,channel3
	move.w	#%0000000000001000,channel4

; Skip 20 bytes descriptor and instrument names (31 of em each 30 chars).
	lea	mod+20(pc),a0
	
	move.l	a0,inst_addr		; Store instrument list address.
	
	lea	30*31(a0),a0
	
	move.b	(a0)+,nseq		; Get number of patterns to play.
	move.b	(a0)+,repeat		; Get repeat.
; A0 now has sequence table...

	move.l	a0,a6			; Search for biggest pattern used.
; A0 is at start of sequence list...
	moveq	#128-1,d1
	moveq	#0,d0
searchbig:
	cmp.b	(a6)+,d0
	bgt.s	nextbig
	move.b	-1(a6),d0
nextbig:dbra	d1,searchbig
	move.w	d0,maxpatts		; Store biggest pattern (0 to ...).

	lea	4(a6),a6		; Skip 'M.K.' ID.
	move.l	a6,patts		; Store start of patterns.


; Initialise pointers to Mr Music SNG channels.
	lea	channel1+4,a1
	lea	channel2+4,a2
	lea	channel3+4,a3
	lea	channel4+4,a4

	
	moveq	#0,d4
	move.b	nseq(pc),d4		; Get number of sequences.
	subq.w	#1,d4			; And don't count first pattern!

nextpatt:
	moveq	#0,d5
	move.b	(a0)+,d5		; Get pattern number.
	moveq	#10,d6
	lsl.l	d6,d5			; D5 is now pattern offset.
	move.l	patts(pc),a6		; Get start of patterns.
	lea	(a6,d5.l),a6		; And point to correct pattern.

; Convert the 64 entries in the MOD file.
	moveq	#64-1,d7
do_pattern:

	move.l	a0,-(sp)
	lea	ch1dur(pc),a0
	do_conv	a1
	move.l	(sp)+,a0
	move.l	a0,-(sp)
	lea	ch2dur(pc),a0
	do_conv	a2
	move.l	(sp)+,a0
	move.l	a0,-(sp)
	lea	ch3dur(pc),a0
	do_conv	a3
	move.l	(sp)+,a0
	move.l	a0,-(sp)
	lea	ch4dur(pc),a0
	do_conv	a4
	move.l	(sp)+,a0

;	move.w	new_vbl_count(pc),num_vbls	; Takes effect next frame.

	dbra	d7,do_pattern

patt_break:	
	dbra	d4,nextpatt
	
	move.w	ch1dur(pc),-2(a1)	; Do channel duration pointers.
	move.w	ch2dur(pc),-2(a2)
	move.w	ch3dur(pc),-2(a3)
	move.w	ch4dur(pc),-2(a4)
	
	move.w	#-9999,(a1)+		; Signal SNG pattern ends.
	move.w	#-9999,(a2)+
	move.w	#-9999,(a3)+
	move.w	#-9999,(a4)+
	
	lea	channel1,a5		; Calculate each channel's sizes.
	sub.l	a5,a1
	move.l	a1,size1
	lea	channel2,a5
	sub.l	a5,a2
	move.l	a2,size2
	lea	channel3,a5
	sub.l	a5,a3
	move.l	a3,size3
	lea	channel4,a5
	sub.l	a5,a4
	move.l	a4,size4
	

	move.l	#channel1,save_addr		; Now save the SNG.
	move.l	size1(pc),save_length
	bsr	save
	move.l	#channel2,save_addr
	move.l	size2(pc),save_length
	bsr	write
	move.l	#channel3,save_addr
	move.l	size3(pc),save_length
	bsr	write
	move.l	#channel4,save_addr
	move.l	size4(pc),save_length
	bsr	write
	
	bsr	close


;	move.w	#1,-(sp)
;	trap	#1
;	addq.w	#2,sp
	
	clr.w	-(sp)
	trap	#1


; Get pattern data for one channel.
; Uses pointer from a6 and uses/returns D0-D3.
get_patt_data:
	move.l	(a6)+,d0		; Get channel 1's instrument.
	move.w	d0,d1
	moveq	#12,d2
	lsr.w	d2,d1			; Get instrument.
	swap	d0
	move.w	d0,d2			; Copy for instrument.
	move.w	d0,d3			; Copy for frequency.
	swap	d0
	and.w	#%0001000000000000,d2	; MSbit of intrument.
	lsr.w	#8,d2
	or.w	d2,d1			; And now we have instrument in D1.
	
	and.w	#%0000001111111111,d3	; Mask out frequency.
	
	move.w	d1,d2			; Copy.
	
	move.w	d0,d1
	and.w	#%0000111100000000,d0	; Mask out command.	
	lsr.w	#8,d0
	and.w	#%0000000011111111,d1	; Mask out parameter.
	
; Now we have:
; D0 = Command.
; D1 = Parameter to command.
; D2 = Instrument.
; D3 = Frequency.
	rts


; Amiga frequency to Mr Music note convert table.
convert:
	incbin	c:\convert.tab


save:	clr.w	-(sp)
	pea	savename(pc)
	move.w	#$3c,-(sp)
	trap	#1
	addq.w	#8,sp
	tst.l	d0
	bmi.s	error
	move.w	d0,handle
write:	move.l	save_addr(pc),-(sp)
	move.l	save_length(pc),-(sp)
	move.w	handle(pc),-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.w	#12,sp
	tst.l	d0
	bmi.s	close
	rts

close:	move.w	handle(pc),-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.w	#4,sp
error:	rts


savename:
	dc.b	'C:\TEST.SNF',0
	even
save_addr:
	ds.l	1
save_length:
	ds.l	1
handle:	ds.w	1

	ds.w	1
size1:	ds.l	1
	ds.w	1
size2:	ds.l	1
	ds.w	1
size3:	ds.l	1
	ds.w	1
size4:	ds.l	1


;new_vbl_count:
;	dc.w	default_speed
num_vbls:
	dc.w	default_speed

ch1dur:	dc.w	default_speed
ch2dur:	dc.w	default_speed
ch3dur:	dc.w	default_speed
ch4dur:	dc.w	default_speed

inst_addr:
	ds.l	1
patts:	ds.l	1

maxpatts:
	ds.w	1

nseq:	ds.b	1
repeat:	ds.b	1


	even

mod:	incbin	c:\test.mod

	even
	
	bss
	
channel1:
	ds.b	channel_size
	even
channel2:
	ds.b	channel_size
	even
channel3:
	ds.b	channel_size
	even
channel4:
	ds.b	channel_size
	even
