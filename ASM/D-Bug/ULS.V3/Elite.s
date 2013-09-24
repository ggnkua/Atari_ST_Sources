;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Elite The UnHOLEy Edition - ULS Stubloader
;;
;;
;;

max_filesize equ 1024
;adv_debug


	clr.l -(a7)
	move.w #$20,-(a7)
	trap #1
	lea 6(a7),a7
	move.l d0,usr_stack

	jsr introcode
	bsr my_test_code

	clr.l -(a7)
	trap #1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Example code
;;

my_test_code
	lea relocat,a0				; relocate code
	lea ULS_stk,a1
	move.l $44e.w,a2
	sub.l #$8000,a2
	move.l a2,-(a7)
.move	move.b (a0)+,(a2)+
	cmp.l a0,a1
	bne.s .move
	rts

relocat	
	move.l $44e.w,a0
	sub.l #$a000,a0				; pass to ULS as RAMTOP
	move.l clock,d0				; clock
	move.l #-1,d1				; cache
	bsr uls
	lea uls_base(pc),a2
	move.l a0,(a2)				; ULS JMP table here
	lea uls_fb(pc),a2
	move.l a1,(a2)				; ULS filebuffer

	move.w #$2700,sr

; clear the VBL chain (Prevent ICD Crash)

	lea $4ce.w,a0
	moveq #7,d0
.killchain
	clr.l (a0)+
	dbra d0,.killchain

	lea fmain,a0
	lea f_ing,a1
	lea $c000,a2
.mv_dw	move.w (a0)+,(a2)+
	cmp.l a0,a1
	bne.s .mv_dw

	movem.l $c000+381282+2,d0-7
	and.l #$ffff,d0
	movem.l d0-7,$ffff8240.w

	lea $c000+381282+34,a0
	lea $78000,a1
	move.l #32000/4,d0
.p_mv	move.l (a0)+,(a1)+
	subq.l #1,d0
	bne.s .p_mv

	move.b #$7,$ffff8201.w
	move.b #$80,$ffff8203.w

	lea $c000+381282,a0
	lea $12000+381282,a1
	move.l #381286/4,d0
.g_mv	move.l -(a0),-(a1)
	subq.l #1,d0	
	bne.s .g_mv

	move.l #$6ffff,d0
.wait	nop
	sub.l #1,d0
	bne.s .wait

	pea cdr_save(pc)
	move.w #$4ef9,$1b4fe
	move.l (a7)+,$1b4fe+2

	pea cdr_load(pc)
	move.w #$4ef9,$1b3ec
	move.l (a7)+,$1b3ec+2
	
	pea cdr_cata(pc)
	move.w #$4ef9,$1b55a
	move.l (a7)+,$1b55a+2

	pea s_next(pc)
	move.w #$4ef9,$1b6e6
	move.l (a7)+,$1b6e6+2

	pea cdr_cata_read(pc)
	move.w #$4ef9,$1b606
	move.l (a7)+,$1b606+2

	lea $80000,a7

	lea _rte(pc),a0
	move.l a0,$114.w

	move.w #$2300,sr

	jmp $1201c

_rte	rte

cdr_cata
	clr.w $1e38(a6)				; * original code *

	movem.l d0/a0-1,-(a7)
	pea $1e3a(a6)
	lea elite_dta(pc),a0
	move.l (a7)+,(a0)

	movem.l (a7)+,d0/a0-1

	movem.l d1-a6,-(a7)

	lea uls_base(pc),a6
	move.l (a6),a6
	lea directory(pc),a0
	jsr uls_execute(a6)
	
	move.w #$ffdf,d0
	lea dta_count(pc),a0
	tst.w (a0)
	beq.s .none

	bsr s_next_code

	movem.l (a7)+,d1-a6
	jmp $1b592

.none	movem.l (a7)+,d1-a6
	jmp $1b57c


filespec_header	dc.b "DATA\*.CDR"
		even

directory
	lea dta_count(pc),a0
	move.w #0,(a0)				; reset file counter

	lea ldta(pc),a0
	move.w #43,d0
.erase	clr.b (a0)+				; erase local DTA copy
	dbra d0,.erase	

	pea ldta(pc)
	move.w #$1a,-(a7)
	trap #1
	lea 6(a7),a7				; set DTA pointer

	move.w #2,-(a7)
	pea filespec_header(pc)
	move.w #$4e,-(a7)
	trap #1
	lea 8(a7),a7
	tst.w d0
	bmi .all_done_zero
	bsr .copy_dta_to_buff
	
	lea dta_curr(pc),a0
	move.w #1,(a0)

.rdloop	move.w #$4f,-(a7)
	trap #1
	lea 2(a7),a7
	tst.w d0
	bmi .all_done
	bsr .copy_dta_to_buff
	bra .rdloop

.all_done
	rts

.all_done_zero
	lea dta_curr(pc),a0
	clr.w (a0)
	lea dta_count(pc),a0
	clr.w (a0)
	rts

.copy_dta_to_buff
	lea dta_count(pc),a0
	moveq #0,d0	
	add.w #1,(a0)				; inc counter
	move.w (a0),d0
	
	mulu #44,d0
	lea dta_datas(pc),a0
	add.w d0,a0				; pointer to table

	lea ldta(pc),a1
	move.w #43,d0
.moveit	move.b (a1)+,(a0)+
	dbra d0,.moveit

	rts

s_next
	bsr s_next_code
	jmp $1b6ee

s_next_code
	movem.l d1-a6,-(a7)

	lea dta_count(pc),a0
	tst.w (a0)
	beq.s .end_of				; zero files found

	lea dta_curr(pc),a1
	move.w (a1),d0				; current counter

	lea dta_count(pc),a1
	move.w (a1),d1
	cmp.w d0,d1
	blt.s .end_of				; check if last one

	and.l #$ffff,d0				; mask it
	mulu #44,d0
	lea dta_datas(pc),a0
	add.l d0,a0
	lea elite_dta(pc),a1
	move.l (a1),a1
	move.w #43,d0
.argh	move.b (a0)+,(a1)+
	dbra d0,.argh

	lea dta_curr(pc),a0
	add.w #1,(a0)

	moveq #0,d0

.s_out	movem.l (a7)+,d1-a6
	rts

.end_of	move.l #$ffffffcf,d0
	bra.s .s_out	


elite_dta	dc.l 0
dta_curr	ds.w 1
dta_count	ds.w 1
dta_datas	ds.b 44*112


ldta	ds.b 44

cdr_cata_read
	move.l a0,-(a7)
	lea fn_addr(pc),a0
	pea $1e58(a6)
	move.l (a7)+,(a0)+			; store filename address
	pea $1bec(a6)
	move.l (a7)+,(a0)			; store load address
	move.l (a7)+,a0

	movem.l d0-a6,-(a7)

	lea uls_base(pc),a6
	move.l (a6),a6
	jsr uls_setread(a6)			; set READ

	lea fn_addr(pc),a6
	move.l (a6)+,a0				; ELITE filename
	move.l (a6)+,a1				; ELITE load address
	move.l #$100,d0				; ELITE CDR files are $100 long
	move.l #0,d1				; seek offset
	moveq #0,d7
	lea uls_base(pc),a6
	move.l (a6),a6				; ULS JMP table
	jsr uls_file_io(a6)			; call IO

	movem.l (a7)+,d0-a6
	
	jmp $1b656				; return to game

cdr_load
	move.l a0,-(a7)
	lea fn_addr(pc),a0
	pea $264(a6)
	move.l (a7)+,(a0)+			; store filename address
	pea $1bec(a6)
	move.l (a7)+,(a0)			; store load address
	move.l (a7)+,a0

	movem.l d0-a6,-(a7)

	lea uls_base(pc),a6
	move.l (a6),a6
	jsr uls_setread(a6)			; set READ

	lea fn_addr(pc),a6
	move.l (a6)+,a0				; ELITE filename
	move.l (a6)+,a1				; ELITE load address
	move.l #$100,d0				; ELITE CDR files are $100 long
	move.l #0,d1				; seek offset
	moveq #0,d7
	lea uls_base(pc),a6
	move.l (a6),a6				; ULS JMP table
	jsr uls_file_io(a6)			; call IO
	tst.l d7
	bmi .load_error

	movem.l (a7)+,d0-a6
	
	jmp $1b476				; return to game

.load_error
	movem.l (a7)+,d0-a6
	move.w #$ffdf,d0
	jmp $1b406

cdr_save
	move.l a0,-(a7)
	lea fn_addr(pc),a0
	pea $264(a6)
	move.l (a7)+,(a0)+			; store filename address
	pea $1bec(a6)
	move.l (a7)+,(a0)			; store load address
	move.l (a7)+,a0

	movem.l d0-a6,-(a7)

	lea uls_base(pc),a6
	move.l (a6),a6
	jsr uls_setwrite(a6)			; set READ

	lea fn_addr(pc),a6
	move.l (a6)+,a0				; ELITE filename
	move.l (a6)+,a1				; ELITE save address
	move.l #$100,d0				; ELITE CDR files are $100 long
	move.l #0,d1				; seek offset
	moveq #0,d7
	lea uls_base(pc),a6
	move.l (a6),a6				; ULS JMP table
	jsr uls_file_io(a6)			; call IO

	movem.l (a7)+,d0-a6
	
	jmp $1b54a				; return to game


fn_addr	dc.l 0
fn_load	dc.l 0

usr_stack
	ds.l 1

uls_base	dc.l 0
uls_fb		dc.l 0


	include "uls311.s"

fmain	incbin "12000.dmp"
	even
fpic	incbin "e_pic.pi1"
	even
f_ing

	include "intro.s"