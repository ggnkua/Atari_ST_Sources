;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Alcatraz Stubloader
;;
;;

max_filesize 	equ 161*1024
ramdisk_size	equ 720000
lower_ramdisk	equ $200000
;adv_debug


	clr.l -(a7)
	move.w #$20,-(a7)
	trap #1
	lea 6(a7),a7
	move.l d0,usr_stack

	bsr introcode
	move.w trainer1_option,d0
	move.w d0,ch_eat
	bsr my_loader

	move.l usr_stack,-(a7)
	move.w #$20,-(a7)
	trap #1
	lea 6(a7),a7

	clr.l -(a7)
	trap #1

usr_stack
	ds.l 1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Example code
;;

my_loader
	lea relocat,a0				; relocate code
	lea ULS_stk,a1
	move.l $44e.w,a2
	sub.l #(ULS_TRASH_RAM-my_loader)*2,a2
	move.l a2,-(a7)
.move	move.b (a0)+,(a2)+
	cmp.l a0,a1
	bne.s .move
	rts

relocat	lea relocat(pc),a7
	lea relocat(pc),a0
	sub.l #ULS_TRASH_RAM-my_loader,a0	; pass to ULS as RAMTOP
	move.l clock,d0				; clock (-1=8mhz)
	move.l #-1,d1				; cache (-1=off!)
	
	move.l $42e.w,d7
	move.l #'DATA',d6
	cmp.l #lower_ramdisk,d7			; automagic ramdisk if 2mb>
	blt.s .noramd
	move.l ramd,d7 	
.noramd	move.l #ramdisk_size,a6			; this big
	lea ram_spec(pc),a5			; from this filespec.
	bsr uls

	lea uls_mach(pc),a2
	move.w d0,(a2)
	lea flop(pc),a2
	move.l d1,(a2)
	lea uls_comp(pc),a2
	move.w d2,(a2)
	lea uls_base(pc),a2
	move.l a0,(a2)				; ULS JMP table here
	lea uls_fb(pc),a2
	move.l a1,(a2)

	clr.w -(a7)
	pea $78000
	pea $78000
	move.w #5,-(a7)
	trap #14
	lea 12(a7),a7

	move.w #$2700,sr
	lea uls_base(pc),a6
	move.l (a6),a6
	jsr uls_setread(a6)			; set READ

	lea fmain1(pc),a0
	lea $ce4a,a1
	move.l #-1,d0
	move.l #0,d1
	moveq #0,d7
	lea uls_base(pc),a6
	move.l (a6),a6				; ULS JMP table
	jsr uls_file_io(a6)			; Call ULS to load file

	pea uls_handler(pc)			; install ULS handler
	move.w #$4ef9,$cf34
	move.l (a7),$cf36
	lea loader_rep+2(pc),a6
	move.l (a7)+,(a6)

	pea depack_handler(pc)			; install post depack handler
	move.w #$4ef9,$d1ca
	move.l (a7),$d1cc
	lea depack_jmp+2(pc),a6
	move.l (a7)+,(a6)

	lea $ffff8240.w,a0
	moveq #7,d0
.blk	move.l #$07770777,(a0)+
	dbra d0,.blk

	lea ch_eat(pc),a0
	cmp.w #-1,(a0)
	bne.s .nocht
	jmp $ce4a

.nocht	jmp $ce50

fmain1	dc.b "CE4",0
	even

ram_spec	dc.b "*.*",0

uls_base	dc.l 0
uls_fb		dc.l 0
uls_mach	dc.w 0
uls_comp	dc.w 0
flop		dc.l 0



lfn	ds.b 8
	even

uls_handler
	movem.l d1-7/a0-6,-(a7)		

	move.l (a0),-(a7)		; store 4 bytes of filename
	move.l a0,-(a7)			; and its address
	clr.b 3(a0)			; null terminate the filename

	lea s_start(pc),a6
	move.l a1,(a6)			; store start address

	lea uls_base(pc),a6
	move.l (a6),a6			; ULS JMP table

.read	jsr uls_setread(a6)		; Put ULS in READ MODE
	move.l #-1,d0
.cont	move.l #0,d1
	moveq #0,d7
	lea uls_base(pc),a6
	move.l (a6),a6			; ULS JMP table

	jsr uls_file_io(a6)		; Call ULS

	lea s_len(pc),a6
	move.l d0,(a6)			; store length of file (unpacked)

	move.l (a7)+,a0			; address of filename
	move.l (a7)+,(a0)		; restore original filename

	movem.l (a7)+,d1-7/a0-6

	rts

s_start	dc.l 0
s_len	dc.l 0

depack_handler

;
; Direct memory checks
;

	cmp.l #$4df88800,$329e
	bne.s .done_chks		; shadow write
	pea s1(pc)
	move.w #$4ef9,$329e
	move.l (a7)+,$329e+2

.done_chks

;
; Search checks
;

	lea s_start(pc),a2
	move.l (a2)+,a0			; start address
	move.l a0,a1
	add.l (a2),a1			; end address
	lea loader_pat(pc),a2
	move.l #loader_pat_e-loader_pat,d0
	lea loader_rep(pc),a3
	move.l #loader_rep_e-loader_rep,d1

	lea uls_base(pc),a6
	move.l (a6),a6			; ULS JMP table
	jsr uls_search(a6)

	lea s_start(pc),a2
	move.l (a2)+,a0			; start address
	move.l a0,a1
	add.l (a2),a1			; end address
	lea depack_pat(pc),a2
	move.l #depack_pat_e-depack_pat,d0
	lea depack_rep(pc),a3
	move.l #depack_rep_e-depack_rep,d1

	lea uls_base(pc),a6
	move.l (a6),a6			; ULS JMP table
	jsr uls_search(a6)

	movem.l (a7)+,d0-7/a0-6
	moveq #0,d0
	rts

s1	lea $ffff8800.w,a6
	movep.w d6,(a6)
	swap.w d6
	movep.w d6,(a6)
	jmp $32a6


loader_pat	lea $ffff8604.w,a3
		lea $ffff8606.w,a4
		moveq #1,d4
		moveq #0,d5
		moveq #-1,d6
loader_pat_e

loader_rep	jmp $12345678
loader_rep_e

depack_pat	dc.l $41544d35		; ATM5
		dc.l $6602610c		; BNE, BSR
		movem.l (a7)+,d0-7/a0-6
		clr.l d0
		rts
depack_pat_e

depack_rep	dc.l $41544d35
		dc.l $6602610c
depack_jmp	jmp $12345678
depack_rep_e


ch_eat	dc.w 0
ch_lvl	dc.w 0


fnl	dc.l 0

	include "uls312h.s"
	include "intro.s"

