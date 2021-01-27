*  Copyright (c) 1987 - 1991 by Han  Driesen Leiden.
*            (c) 1996 - 2008 by Henk Robbers Amsterdam.
*
* This file is part of Atari TTDIGGER.
*
* TTDIGGER is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*
* TTDIGGER is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with TTDIGGER; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*

*	TTD_SCAN.S

	offset
;	parameter stack frame
offa6:	ds.l	2
prg:	ds.l	1
org:	ds.l	1
dat:	ds.l	1
top:	ds.l	1
off:	ds.l	1
mask:	ds.l	1
maskx:	ds.l	1
rel:	ds.l	1
dt:	ds.l	1
aref:	ds.l	1

; dat wat weinig en niet indirect gebruikt wordt blijft op de stack

	globl scanlabx
	text

scanlabx:
	link	a6,#$00
	movem.l d3-d7/a2-a5,-(sp)
	btst	#3,prg+3(a6)
	beq 	sc1
	pea 	scan1(pc)
	move	#$0026,-(sp)	; supexec
	trap	#14		; xbios
	addq	#6,sp
	bra 	sc2
sc1:
	jsr 	scan1(pc)
sc2:
	movem.l (sp)+,d3-d7/a2-a5
	unlk	a6
	rts

;	void cdecl scanx(long mopt,
;					PCW org,PCW bss,PCW top,long offset,
;					bool mask[],bool maskx[],
;					bool rel[],bool dt[],bool ref[]
;					)

scan1:
	move.l	prg(a6),d7	; prg
	move.l	org(a6),a5	; org
;	    	dat(a6)		; dat
	move.l	top(a6),d3	; top
	move.l	off(a6),d6	; offset
;	    	mask(a6)	; mask!()
;	    	maskx(a6)	; maskx!()
	move.l	rel(a6),a3	; rel!()
	move.l	dt(a6),a4	; dt!()
;	    	aref(a6)	; ref!()

	btst	#0,d7		; d7 now contains 3 switches
	bne 	r070		; prg == true  (tos reloc info)

	move.l	d3,d2		; HR: d2 local to following loop
	sub.l	a5,d2
	add.l	d6,d2		; top-org+offset
	move.l	a5,a2

r04a:
	lea 	2(a2),a0
	cmpa.l	d3,a0
	bcc 	r070		; pc + 2 >= top
	move.l	(a2),d4
	cmp.l	d6,d4
	ble 	r06c		; *pc.l < offset
	cmp.l	d2,d4
	bge 	r06c		;    "  >= top-org+offset
	sub.l	d6,d4
	move.b	d4,d1
	lsr.l	#3,d4
	move.l	aref(a6),a0	; ref array
	bset	d1,0(a0,d4.l)	; ref(d4  -offset) := true
r06c:
	addq	#2,a2
	bra 	r04a

*	d0, d3, a1 vrijgemaakt
*	eenmalige stuff verplaatst naar GFA
r070:
	lea 	-4(a5),a2	; pc = org - 4
step4:
	addq	#2,a2
step2:
	addq	#2,a2
step0:
	cmpa.l	dat(a6),a2
	bcc 	s_exit		; pc >= dat
	move.l	a2,d2
	sub.l	a5,d2		; org
	move.b	d2,d1
	lsr.l	#3,d2
	btst	#0,d7
	beq 	r0b0		; prg == false
	btst	d1,0(a3,d2.l)	; rel(pc-org)
	bne 	step4
	addq.b	#1,d1
	btst	d1,0(a3,d2.l)	; rel(pc+1-org)
	bne 	step2
	subq.b	#1,d1
r0b0:
	btst	d1,0(a4,d2.l)	; dt(pc-org)	voor opcode
	bne 	step2
	addq.b	#1,d1
	btst	d1,0(a4,d2.l)	; dt(pc+1-org)
	bne	step2
nolabel:	; when jumped to, we know already that pc is NOT in dt!
		; and that pc+2 exists

*	a2 is the pc that is to be stepped for next analysis,
*	a1 is for current analysis (see 4 byte insts)
*	from now on ALL branches are forward, except for the end of
*	an analysis, when we must step

r0b8:
	move	(a2)+,d5
	move.l	a2,a1
	move	d5,d0
	andi	#$F001,d0
	cmpi	#$6000,d0	; bcc
	bne 	r0d2
	move.b	d5,d4		; 8 bits displacement
	beq 	r0d2		; 0 = bcc.w
	ext 	d4
	ext.l	d4
	bra 	marka1

r0d2:
	cmpa.l	dat(a6),a1
	bcc 	s_exit		; pc >= dat
	move.l	a1,d2
	sub.l	a5,d2		; org
	move.b	d2,d1
	lsr.l	#3,d2
	btst	#0,d7
	beq 	r0ee		; prg == false
	btst	d1,0(a3,d2.l)	; rel(pc-org)
	bne 	step4
	addq.b	#1,d1
	btst	d1,0(a3,d2.l)	; rel(pc+1-org)
	bne 	step2
	subq.b	#1,d1
r0ee:
	btst	d1,0(a4,d2.l)	; dt(pc-org)      voor next 2 after opcode
	bne 	step2
	addq.b	#1,d1
	btst	d1,0(a4,d2.l)	; dt(pc+1-org)
	bne 	step2
	subq.b	#1,d1

	move	d5,d0
	andi	#$F0FF,d0
	cmpi	#$6000,d0	; bcc.w
	beq 	r104
	btst	#1,d7		; <   **** 68030 ?
	beq 	h000		;	no
	cmpi	#0x60ff,d0	; bcc.l ?
	beq 	lb
h000:
	andi	#$F0F8,d0
	cmpi	#$50C8,d0	; dbcc
	beq 	r104
	btst	#2,d7		; 68881 ?
	beq 	r112		;	no
	move	d5,d0
	and 	#0xff80,d0
	cmp 	#0xf280,d0	; fbcc
	bne 	h001
	btst	#6,d5
	beq 	r104		; fbcc.w
lb:	lea 	2(a1),a0	; long displ
	bsr 	ismarked	; for last 2 of displ.
	bne 	nolabel
	move.l	(a1),d4
	beq 	nolabel
	btst	#$00,d4
	bne 	nolabel
	bra 	marka1

h001:
	move	d5,d0
	and 	#0xfff4,d0
	cmp 	#0xf244,d0
	bne 	r112		; fdbcc
	lea 	2(a1),a0
	bsr 	ismarked	; instruction is 4 bytes
	bne 	nolabel
	lea 	2(a1),a1	; word pc relative on pc+2
r104:
	move	(a1),d4
	beq 	r0b8
	ext.l	d4
	btst	#$00,d4
	bne 	r0b8
	bra 	marka1

r112:
	move	d5,d0
	andi	#$003E,d0	; 076
	cmpi	#$003A,d0	; 072 = dd(pc), 73 = d(pc,rn), (dddd,pc,rn)
	bne 	r0b8
	move	d5,d0
	lsr 	#6,d0
	move.b	d0,d1
	lsr 	#3,d0
	move.l	mask(a6),a0	; does the inst have the above addr. modes ?
	btst	d1,0(a0,d0.w)
	beq 	r0b8
	move.l	maskx(a6),a0	; is it a 4 byte instruction
	btst	d1,0(a0,d0.w)
	beq 	r147		; no

*	4 byte instructions
	btst	#2,d7		; 68881
	beq 	r146
	move	d5,d0
	and 	#0xff00,d0	; fp instructie ?
	cmp 	#0xf200,d0
	bne 	r146
	btst	#6,(a1)		; r/m = 1 : ea to reg
	beq 	nolabel
	btst	#7,(a1)		; fmovem ?
	beq 	r146
	btst	#5,(a1)		; ea to reg ?
	bne 	nolabel
r146:
	addq	#2,a1		; skip second part of inst
	move.l	a1,a0
	bsr 	ismarked	; instruction is 4 bytes: check 2 extra
	bne 	r0b8		; either extension or word displacement
*	2 byte instructions 
r147:
	btst	#$00,d5
	bne 	fx
*  a1 points to displacement word
	move	(a1),d4		; d(pc)
	ext.l	d4
	btst	#1,d7		; 68030  no odd/even check needed
	bne 	marka1
	btst	#$00,d4
	beq 	marka1		; even adres
	cmpi	#$2000,d5	; btst, move.b
	bcs 	marka1
	cmpi	#$487A,d5	; pea
	beq 	marka1
	andi	#$F1C0,d5
	cmpi	#$41C0,d5	; lea
	beq 	marka1
	andi	#$80C0,d5
	cmpi	#$8000,d5	; op.b
	bne 	r0b8
	bra 	marka1

*   a1 points to address extension word
fx:	move	(a1),d3
	btst	#1,d7		; 68030
	beq 	noscale
	btst	#8,d3		; bit 8 extension word
	beq 	scaleok
	moveq	#0x30,d3	; full extension
	and 	(a1)+,d3
*   a1 points now to displacement word cq long
	beq 	nolabel		; 0 base displacement size
	lsr 	#4,d3
	subq	#1,d3
	bne 	fx1
	moveq	#0,d4		; null displacement ([pc],xn) b.v.
	bra 	marka1

fx1:					; pc relative base displacement
	move.l	a1,a0
	bsr 	ismarked	; check base displacement
	bne 	nolabel
	subq	#1,d3
	bne 	fx0			; bd size
	move	(a1),d4		; short displacement value
	ext.l	d4
	lea 	-2(a1),a0	; pc of reference
	bra 	marka0

fx0:
	lea 	2(a1),a0
	bsr 	ismarked	; long displacement (extra 2 bytes)
	bne 	nolabel
	move.l	(a1),d4		; long displacement value
	lea 	-2(a1),a0	; pc of reference
	bra 	marka0		; odd/even check not needed on 68030

noscale:				; d(pc,xi)
	move	#$700,d0 	; scale & bit 8
	and 	d3,d0		; extension word
	bne 	r0b8
scaleok:
	move.b	d3,d4
	ext 	d4
	ext.l	d4

marka1:
	move.l	a1,a0		; pc of reference

marka0:					; 6 feb 2000  extra reg for address calc.
						;     can use a0 :-)
	add.l	d4,a0
	cmpa.l	a5,a0		; org
	bcs 	step0 		; pc + displacement <  org    HR 02'09 bls --> bcs
	cmpa.l	top(a6),a0
	bcc 	step0 		; pc + displacement >= top
	move.l	a0,d0
	sub.l	a5,d0		; org
	move.b	d0,d1
	lsr.l	#3,d0
	move.l	aref(a6),a0	; ref(pc+displacement-org) = true
	bset	d1,$00(a0,d0.l)
	bra 	step0
s_exit:
	rts

ismarked:
	cmpa.l	dat(a6),a0	; vaak
	bcc 	p2ge		; pc >= dat
	move.l	a0,d2
	sub.l	a5,d2		; org
	move.b	d2,d1
	lsr.l	#3,d2
	btst	#0,d7		; ****
	beq 	p21		; prg == false
	btst	d1,0(a3,d2.l)	; rel(pc-org)
	bne 	p2x
	addq.b	#1,d1
	btst	d1,0(a3,d2.l)	; rel(pc+1-org)
	bne 	p2x
	subq.b	#1,d1
p21:
	btst	d1,0(a4,d2.l)	; dt(pc-org)
	bne 	p2x
	addq.b	#1,d1
	btst	d1,0(a4,d2.l)	; dt(pc+1-org)
p2x:
	rts
p2ge:
	move	#0,ccr		; 0 --> Z
	rts

	END
