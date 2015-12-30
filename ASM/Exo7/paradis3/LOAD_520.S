; +======================================================================+
; | PARADIS3 - PARALLAX DISTORTER - STNICC 2015                          |
; +----------------------------------------------------------------------+
; | Load and relocate the program in low-memory                          |
; +======================================================================+
; | Copyright (c) 2015 Frederic Poeydomenge <dyno@aldabase.com>          |
; +----------------------------------------------------------------------+
; | This program is free software: you can redistribute it and/or modify |
; | it under the terms of the GNU General Public License as published by |
; | the Free Software Foundation, either version 3 of the License, or    |
; | (at your option) any later version.                                  |
; |                                                                      |
; | This program is distributed in the hope that it will be useful,      |
; | but WITHOUT ANY WARRANTY; without even the implied warranty of       |
; | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the         |
; | GNU General Public License for more details.                         |
; |                                                                      |
; | You should have received a copy of the GNU General Public License    |
; | along with this program. If not, see <http://www.gnu.org/licenses/>. |
; +======================================================================+

TRAP_BASE	= $0EC			; Unassigned vectors ($EC..$FF, 20 bytes)
RTE_BASE	= $0EC+16
COPY_BASE	= $1C0			; User Defined, Unused vector ($1C0..$3FC)
STACK_BASE	= $800
ORG_BASE	= $800			; Free RAM : $80000-$800 = 522240 bytes

	opt	m+,o+,d-,x-,s-,p=68000	

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION TEXT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	include	P_BASE.S

	;---------------------
	; Set supervisor mode
	;---------------------

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	;-----------------
	; Initializations
	;-----------------

	move.w 	#$2700,sr		; Mask all interrupts

	lea	STACK_BASE.w,sp		; Set stack

	clr.b	MFP_ENABLE_A.w		; Interrupt Disable A
	clr.b	MFP_ENABLE_B.w		; Interrupt Disable B
	
	lea	rte(pc),a0
	move.l	a0,VBL.w		; Empty VBL

	;--------------------
	; Relocation Routine
	;--------------------
	
	lea	prog(pc),a0
	lea	pstart+2(pc),a4
	lea	pend+2(pc),a5
	move.l	$02(a0),d0		; Size of the TEXT segment in bytes
	add.l	$06(a0),d0		; Size of the DATA segment in bytes
	move.l	d0,d1
	add.l	$0E(a0),d0		; Size of the symbol table in bytes
	
	lea	$1C(a0),a0		; Address of the program's TEXT segment
	move.l	a0,(a4)			; Start of the program
	add.l	a0,d1
	move.l	d1,(a5)			; End of the program

	lea	(a0,d0.l),a1		; a1 = relocation table
	
	; Loop through addresses to change
	add.l	(a1)+,a0
	move.l	#ORG_BASE,d1
	add.l	d1,(a0)
	moveq.l	#0,d0
loop_reloc:
	move.b	(a1)+,d0
	tst.b	d0
	beq.s	end_reloc
	cmp.b	#1,d0
	beq.s	inc_addr
	add.w	d0,a0
	move.l	#ORG_BASE,d1
	add.l	d1,(a0)
	bra.s	loop_reloc
inc_addr:
	lea	254(a0),a0
	bra.s	loop_reloc
end_reloc:

	;------------------------
	; Relocate the trap-rout
	;------------------------

	lea	trap_1(pc),a0
	lea	TRAP_BASE.w,a1
	lea	trap_1_end(pc),a2
rel_trap:
	move.w	(a0)+,(a1)+
	cmp.l	a0,a2
	bgt.s	rel_trap

	;------------------------
	; Relocate the copy-rout
	;------------------------
	
	lea	copy_rout(pc),a0
	lea	COPY_BASE.w,a1
	lea	copy_rout_end(pc),a2
rel_copy:
	move.w	(a0)+,(a1)+
	cmp.l	a0,a2
	bgt.s	rel_copy

	; Jump to the copy routine
	jmp	COPY_BASE.w

;#==============#
;# Copy routine #
;#==============#

copy_rout:

	lea	TRAP_BASE.w,a1		; trap_1 rout
	lea	RTE_BASE.w,a2		; rte rout
	move.l	a1,$84.w		; Trap #1  (GemDOS)
	move.l	a2,$B4.w		; Trap #13 (BIOS)
	move.l	a2,$B8.w		; Trap #14 (XBIOS)
	move.l	a2,VBL.w		; VBL

	lea	ORG_BASE.w,a2

	; Copy TEXT and DATA segments
pend:	move.l	#$01234567,d7		; d7 = end of program
pstart:	move.l	#$01234567,a0
	sub.l	a0,d7			;      - start of program
	addq.l	#1,d7
	lsr.l	#2,d7			; Round to the upper .L
copy:	move.l	(a0)+,(a2)+
	dbra	d7,copy

	; Clear BSS segment
	move.l	$42E.w,d7		; d7 = physical top of RAM (phystop)
	sub.l	a2,d7			;      - current position in RAM
	subq.l	#3,d7			; To prevent writing after phystop :
	lsr.l	#2,d7			; Round to the lower .L
	moveq.l	#0,d0
clear_mem:
	move.l	d0,(a2)+
	dbra	d7,clear_mem

	; Enable interrupts
	move.w	#$2300,sr

	; Jump to the relocated program
	jmp	ORG_BASE.w

copy_rout_end:

;#=============#
;# New Trap #1 #
;#=============#
; The only method we keep is the GEMDOS exit
; function (Pterm), which turns on Reset here

trap_1:	tst.w	6(sp)
	bne.s	rte
	; Reset
	move.l	$0.w,sp			; Initial SSP
	move.l	$4.w,a0			; Initial PC
	jmp	(a0)

;#=================#
;# Empty Exception #
;#=================#

rte:	rte

trap_1_end:

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION DATA
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

prog:	incbin "PARADIS3.PRG"

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 END
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
