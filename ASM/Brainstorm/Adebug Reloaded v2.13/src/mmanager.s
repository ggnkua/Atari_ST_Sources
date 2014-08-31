;
; Copyright 1990-2006 Alexandre Lemaresquier, Raphael Lemoine
;                     Laurent Chemla (Serial support), Daniel Verite (AmigaOS support)
;
; This file is part of Adebug.
;
; Adebug is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; Adebug is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with Adebug; if not, write to the Free Software
; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
;

	 ;#[ Cartridge manager:
		;#[ Find free space:
	move.l	#$ffff,$ffff8240.w
	moveq	#1,d1
	lea	$380000,a0
.No_chip:
	sub.l	#$8000,a0
	move.l	d1,(a0)
	cmp.l	(a0),d1
	bne.s	.No_chip
	move.l	a0,d0
	lsr	#8,d0
	move.b	d0,$ffff8203.w
	swap	d0
	move.b	d0,$ffff8201.w
		;#] Find free space:
		;#[ Install menu:
Set_menus:
	lea	$62c0(a0),a2
	lea	$7e00(a0),a7
	pea	(a6)
	lea	$34(a7),a6
	move.l	a0,Screen(a6)
	move.l	a2,a0
	move	#(32000-SAVE_SIZE)/4-1,d0
.Cls:	clr.l	(a0)+
	dbf	d0,.Cls
	jsr	wait_vbl
	tst.b	$fffffa01.w
	smi	Color_flag(a6)
	bpl.s	.Set_high
.Set_medium:
	addq.b	#1,$ffff8260.w
	move.b	#2,$ffff820a.w
	move.l	#'8x8 ',d0
	bra.s	Find_font
.Set_high:
	addq.b	#2,$ffff8260.w
	move.l	#'8x16',d0
Find_font:
	move.l	(a7),a0
	add.l	#$18000,a0
.Wrong_font:
	swap	d0
.Not_yet:
	cmp	(a0)+,d0
	bne.s	.Not_yet
	swap	d0
	cmp	(a0)+,d0
	bne.s	.Wrong_font
.Found:	move.l	68(a0),Font_addr(a6)
	lea	160*8(a2),a2
	lea	160*16(a2),a3
	lea	Magic_start_txt,a0
	bsr	Print_line
	move.l	a3,a2
.Install_TOS?:
	lea	TOS_txt,a0
	bsr	Print_line
	bsr	Get_yes_no
	move.b	Yes_flag(a6),TOS_flag(a6)
	beq.s	.Get_BSS_addr
.Malloc_BSS?:
	lea	Malloc_txt,a0
	bsr	Print_line
	bsr	Get_yes_no
	tst.b	Yes_flag(a6)
	bne.s	Install_TOS
.Get_BSS_addr:
	lea	BSS_txt,a0
	bsr	Print_line
	bsr	Get_line
	tst.b	TOS_flag(a6)
	bne.s	Install_TOS
	jmp	Restart_adebug
		;#] Install menu:
		;#[ Install Adebug:
Install_TOS:
	move.l	Screen(a6),a0
	lea	8.w,a1
Saver:	move	#SAVE_SIZE/40,d0
	move	#$2700,sr
.Save_ram:
	movem.l	(a1)+,d1-d6/a2-a5
	movem.l	d1-d6/a2-a5,(a0)
	lea	40(a0),a0
	dbf	d0,.Save_ram
End_saver:
	move.l	Screen(a6),$24.w
	clr	$426.w
	move.l	#$752019f3,$420.w
	move.l	#$237698aa,$43a.w
	move.l	#$5555aaaa,$51a.w
	tst.b	TOS_flag(a6)
	move.l	(a7)+,a6
	beq.s	.No_TOS
	pea	Magic_start(pc)
	bra.s	.Restore_ram
.No_TOS:	move.l	d7,-(a7)
	pea	$4e712e3c
	pea	Restart_adebug(pc)
.Restore_ram:
	pea	$76ff4ef9
	lea	End_saver(pc),a0
	moveq	#(End_saver-Saver)/2-1,d0
.Copy_saver:
	move	-(a0),-(a7)
	dbf	d0,.Copy_saver
	pea	$22780024
	pea	$41f80008
	pea	-8(a7)
	pea	$12123456
	move	#$fe,d0
	moveq	#0,d1
.Checksum:
	add	(a7)+,d1
	dbf	d0,.Checksum
	sub	#$5678,d1
	neg	d1
	move	d1,(a7)+
	add.l	#$8000,a7
	move.l	a7,$42e.w
	clr.b	$ffff8260.w
	jmp	(a6)
		;#] Install Adebug:
		;#[ System routines:
Get_line:	clr	Char_buff(a6)
	lea	Numeric_buff(a6),a3
	moveq	#0,d2
.Next_char:	bsr	Put_cursor
	bsr	Get_char
	cmp.b	#$1c,d0
	beq.s	.End_line
	cmp.b	#$72,d0
	beq.s	.End_line
	cmp.b	#$0e,d0
	bne.s	.Not_bckspc
	tst	d2
	beq.s	.Next_char
	bsr	Get_cursor
	subq	#1,a2
	tst.b	Color_flag(a6)
	beq.s	.Even
	move	a2,d0
	btst	#0,d0
	beq.s	.Even
	subq	#2,a2
.Even:	bsr	Put_cursor
	subq	#1,d2
	subq	#1,a3
	bra.s	.Next_char
.Not_bckspc:	cmp	#6,d2
	beq.s	.Next_char
	ext	d0
	lea	Key_table,a0
	move.b	0(a0,d0),d0
	cmp.b	#'0',d0
	bcs.s	.Next_char
	cmp.b	#'F',d0
	bhi.s	.Next_char
	cmp.b	#'9',d0
	bls.s	.Ok
	cmp.b	#'A',d0
	bcs.s	.Next_char
.Ok:	move.b	d0,(a3)+
	move.b	d0,Char_buff(a6)
	lea	Char_buff(a6),a0
	bsr	Print_line
	addq	#1,d2
	bra.s	.Next_char
.End_line:	moveq	#0,d7
	st	(a3)
	lea	Numeric_buff(a6),a3
.Next_digit:	move.b	(a3)+,d0
	bmi.s	.End_convert
	lsl.l	#4,d7
	cmp.b	#'9',d0
	bls.s	.Numeric
	subq	#7,d0
.Numeric:	subi.b	#'0',d0
	add.b	d0,d7
	bra.s	.Next_digit	
.End_convert:	rts
Get_yes_no:	bsr.s	Put_cursor
.Invalid:	bsr.s	Get_char
	cmp.b	#$31,d0
	sne	Yes_flag(a6)
	beq.s	.No
	cmp.b	#$15,d0
	beq.s	.Yes
	cmp.b	#$1c,d0
	bne.s	.Invalid
.Yes:	lea	Yes_txt,a0
	bra.s	Print_line
.No:	lea	No_txt,a0
	bra.s	Print_line
Put_cursor:	pea	(a2)
	tst.b	Color_flag(a6)
	beq.s	.Mono_cursor
	moveq	#7,d0
	move	#160,d1
	bra.s	.Draw_cursor
.Mono_cursor:	moveq	#15,d0
	moveq	#80,d1
.Draw_cursor:	st	(a2)
	add	d1,a2
	dbf	d0,.Draw_cursor
	move.l	(a7)+,a2
	rts
Get_cursor:	pea	(a2)
	tst.b	Color_flag(a6)
	beq.s	.Mono_cursor
	moveq	#7,d0
	move	#160,d1
	bra.s	.Draw_cursor
.Mono_cursor:	moveq	#15,d0
	moveq	#80,d1
.Draw_cursor:	sf	(a2)
	add	d1,a2
	dbf	d0,.Draw_cursor
	move.l	(a7)+,a2
	rts
Get_char:	move.b	#3,$fffffc00.w
	move.b	#$96,$fffffc00.w
.Test_ikbd:	move.b	$fffffc00.w,d0
	btst	#5,d0
	beq.s	.No_overrun
	tst.b	$fffffc02.w
	bra.s	.Test_ikbd
.No_overrun:	btst	#0,d0
	beq.s	.Test_ikbd
	move.b	$fffffc02.w,d0
	bmi.s	.Test_ikbd
	rts
Print_line:	tst.b	Color_flag(a6)
	beq.s	Mono_print
.Next_char:	move.l	Font_addr(a6),a1
	moveq	#0,d0
	move.b	(a0)+,d0
	bne.s	.Not_eol
	rts
.Not_eol:	pea	(a2)
	add	d0,a1
	moveq	#7,d0
.Next_line:	move.b	(a1),(a2)
	clr.b	2(a2)
	lea	$100(a1),a1
	lea	$a0(a2),a2
	dbf	d0,.Next_line
	move.l	(a7)+,a2
	addq	#1,a2
	move	a2,d0
	btst	#0,d0
	bne.s	.Next_char
	addq	#2,a2
	bra.s	.Next_char
Mono_print:
.Next_char:	move.l	Font_addr(a6),a1
	moveq	#0,d0
	move.b	(a0)+,d0
	bne.s	.Not_eol
	rts
.Not_eol:	pea	(a2)
	add	d0,a1
	moveq	#15,d0
.Next_line:	move.b	(a1),(a2)
	lea	$100(a1),a1
	lea	$50(a2),a2
	dbf	d0,.Next_line
	move.l	(a7)+,a2
	addq	#1,a2
	bra.s	.Next_char
		;#] System routines:
	 ;#] Cartridge manager:

