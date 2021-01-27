*  Copyright (c) 1987 - 1991 by Han  Driesen Leiden.
*            (c) 1996 - 2008 by Henk Robbers Amsterdam.
*
* This file is part of Atari Digger.
*
* Digger is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*
* Digger is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Digger; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*

*	TTD_FIND.S

	offset
;	parameter stack frame
offa6:	ds.l	2
prg:	ds.l	1
org:	ds.l	1
dat:	ds.l	1
stop:	ds.l	1
ref:	ds.l	1
mask:	ds.l	1
maskx:	ds.l	1
rel:	ds.l	1
dt: 	ds.l	1
sref:	ds.l	1
start:	ds.l	1

; dat wat weinig en niet indirect gebruikt wordt blijft op de stack

	globl	findrefx

	text
findrefx:
	link	a6,#$00
	lea 	-36(sp),sp
	movem.l d3-d7/a2-a5,(sp)
	btst	#3,prg+3(a6)
	beq 	fi1
	pea 	find1(pc)
	move	#$0026,-(sp)	; supexec
	trap	#14		; xbios
	addq.l	#6,sp
	bra 	fi2
fi1:
	jsr 	find1(pc)
fi2:
	movem.l (sp),d3-d7/a2-a5
	lea 	36(sp),sp
	unlk	a6
	rts

;	long cdecl
;		findrefx(
;			long mopt,
;			PCB org,PCB bss,PCB sto,PCB rkey,
;			bool mask[],bool maskx[],
;			bool rel[],bool dt[],
;			PCB start,PCB sref
;			);

find1:
	move.l	prg(a6),d7	; prg
	move.l	org(a6),a5	; org	5X
;	    	dat(a6)		; dat	3X
;	    	stop(a6)	; stop	3X
	move.l	ref(a6),d6	; reference 2X  dst of cmp
;	    	mask(a6)	; mask	1X
;	    	maskx(a6)	; maskx
	move.l	rel(a6),a3	; rel		indirect
	move.l	dt(a6),a4	; dt		indirect
	move.l	start(a6),a2	; pc		indirect
;	    	sref(a6)	; reference + shift  2X

* d0, d3, a1  vrijgemaakt

	btst	#0,d7
	beq 	r244		; prg == false
	move.l	a2,d2
	sub.l	a5,d2		; org
	move.l	d2,d1					; CF
	lsr.l	#3,d2
	btst	d1,0(a3,d2.l)	; rel(pc-org)
	beq 	r244
	addq.l	#1,d1					; CF
	btst	d1,0(a3,d2.l)	; rel(pc+1-org)
	bne 	r244
f_step4:
	addq.l	#2,a2
f_step2:
	addq.l	#2,a2
	move.l	a2,d2
	sub.l	a5,d2		; org
	move.l	d2,d1					; CF
	lsr.l	#3,d2
	btst	d1,0(a3,d2.l)	; rel(pc-org)
	beq 	r242
	addq.l	#1,d1					; CF
	btst	d1,0(a3,d2.l)	; rel(pc+1-org)
	bne  	f_step2
	cmp.l	(a2),d6
	bne 	f_step4
exit:
	move.l	a2,d0
	rts

r242:
	addq.l	#1,d1					; CF
	btst	d1,0(a3,d2.l)	; rel(pc+1-org)
	bne	f_step2
*
noref:
r244:
	cmpa.l	stop(a6),a2
	bcc 	exit		; pc >= stop
	move	(a2)+,d5
	move.l	a2,a1

*	a2 is the pc that is to be stepped for next analysis,
*	a1 is for current analysis (see 4 byte insts)
*	from now on ALL branches are forward, except for the end of
*	an analysis, when we must step

	cmpa.l	dat(a6),a1
	bhi 	r26c		; pc > dat
	move	d5,d0
	andi.l	#$F001,d0					; CF
	cmpi	#$6000,d0	; bcc
	bne 	r26c
	move.b	d5,d4		; 8 bits displacement
	beq 	r26c		; bcc.w

	move.l	a1,d2		; short branch
	subq.l	#2,d2
	sub.l	a5,d2		; org
	move.l	d2,d1					; CF
	lsr.l	#3,d2
	btst	d1,0(a4,d2.l)	; dt(pc-2-org)
	bne 	r26c
	addq.l	#1,d1					; CF
	btst	d1,0(a4,d2.l)	; dt(pc-1-org)
	bne 	r26c
	ext 	d4
	ext.l	d4
	add.l	a1,d4
	cmp.l	sref(a6),d4
	bne 	r26c
	subq.l	#2,a1		; enige overgebleven exit2
	move.l	a1,d0
	rts

r26c:
	cmpa.l	stop(a6),a1	; pc >= stop
	bcc 	exit1		; not found
	move.l	a1,d2
	sub.l	a5,d2		; org
	move.l	d2,d1					; CF
	lsr.l	#3,d2
	btst	#0,d7		; prg == false
	beq 	r294
	btst	d1,0(a3,d2.l)	; rel(pc-org)
	beq 	r26d
	addq.l	#1,d1					; CF
	btst	d1,0(a3,d2.l)	; rel(pc+1-org)
	bne 	f_step2
	cmp.l	(a1),d6
	bne 	f_step4
exit1:
	move.l	a1,d0		; was exit2
	rts

r26d:
	addq.l	#1,d1					; CF
	btst	d1,0(a3,d2.l)	; rel(pc+1-org)
	bne 	f_step2
	subq.l	#1,d1					; CF
	bra 	r2a6

r294:
	lea 	2(a1),a0
	cmpa.l	stop(a6),a0	; pc + 2 >= stop
	bcc 	r2a6
	cmp.l	(a1),d6
	bne 	r2a6
	move.l	a1,d0		; was exit2
	rts

r2a6:
	cmpa.l	dat(a6),a1
	bcc 	r244		; pc >= dat
	btst	d1,0(a4,d2.l)	; dt(pc-org)
	bne 	r244
	addq.l	#1,d1					; CF
	btst	d1,0(a4,d2.l)	; dt(pc+1-org)
	bne 	r244
	move	d5,d0
	andi.l	#$F0FF,d0					; CF
	cmpi	#$6000,d0	; bcc.w
	beq 	r2c0
	btst	#1,d7		; 68030?
	beq 	f000
	cmpi	#0x60ff,d0
	beq 	flb		; bcc.l
f000:
	andi.l	#$F0F8,d0					; CF
	cmpi.w	#$50C8,d0	; dbcc
	beq 	r2c0
	btst	#2,d7		; 68881 ?
	beq 	r2d0
	move	d5,d0
	andi.l	#0xff80,d0					; CF
	cmpi	#0xf280,d0	; fbcc
	bne 	f001
	btst	#6,d5
	beq 	r2c0		; fbcc.w
flb:
	lea 	2(a1),a0	; long displ.
	bsr 	ismarked	; for last 2 of displ.
	bne 	noref
	move.l	(a1),d4
	beq 	noref
	bra 	fb

f001:
	move	d5,d0
	andi.l	#0xfff4,d0					; CF
	cmpi	#0xf244,d0
	bne 	r2d0
	lea 	2(a1),a0	; fdbcc
	bsr 	ismarked	; instruction is 4 bytes
	bne 	noref
	lea 	2(a1),a1	; word pc relative on pc+2
r2c0:
	move	(a1),d4
	beq 	r244
	ext.l	d4
fb:	btst	#0,d4
	bne 	r244
	add.l	a1,d4
	cmp.l	sref(a6),d4
	bne 	r244
	move.l	a1,d0
	rts

r2d0:
	move	d5,d0
	andi.l	#$003E,d0	; 076					; CF
	cmpi	#$003A,d0	; 072 = dd(pc), 073 = d(pc,rn)
	bne 	r244
	move	d5,d0
	lsr.l 	#6,d0					; CF see andi.l above
	move.b	d0,d1
	lsr.l 	#3,d0					; CF
	move.l	mask(a6),a0	; does the inst have the above addr modes ?
	btst	d1,0(a0,d0.l)					; CF
	beq 	r244
	move.l	maskx(a6),a0	; is it a 4 byte instruction
	btst	d1,0(a0,d0.l)					; CF
	beq 	r309		; no
*	4 byte instructions
	btst	#2,d7		; 68881 ?
	beq 	r308
	move	d5,d0
	andi.l	#0xff00,d0	; fp instructie ?					; CF
	cmpi	#0xf200,d0
	bne 	r308
	btst	#6,(a1)		; r/m = 1 : ea to reg
	beq 	noref
	btst	#7,(a1)		; fmovem ?
	beq 	r308
	btst	#5,(a1)		; ea to reg ?
	bne 	noref
r308:
	addq.l	#2,a1		; skip second part of inst
	move.l	a1,a0
	bsr 	ismarked	; instruction is 4 bytes: check 2 extra
	bne 	r244
*	2 byte instructions
r309:
	btst	#0,d5
	bne 	ffx		; d(pc)
	move	(a1),d4
	ext.l	d4
	btst	#1,d7		; 68030 no odd check needed
	bne 	r39a
	btst	#0,d4 		; even adres
	beq 	r39a
	cmpi	#$2000,d5	; btst, move.b
	bcs 	r39a
	cmpi	#$487A,d5	; pea
	beq 	r39a
	andi.l	#$F1C0,d5					; CF
	cmpi	#$41C0,d5	; lea
	beq 	r39a
	andi.l	#$80C0,d5					; CF
	cmpi	#$8000,d5	; op.b
	bne 	r244
r39a:
	add.l	a1,d4
	cmp.l	sref(a6),d4
	bne 	r244
	move.l	a1,d0
	rts

*   a1 points to address extension word
ffx:
	move	(a1),d3
	btst	#1,d7		; m68030
	beq 	fnoscale
	btst	#8,d3		; bit 8 extension word
	beq 	fscaleok
*	moveq	#0x30,d3	; full extension
*	and 	(a1)+,d3
	move.b	(a1)+,d3
	and.l	#0x30,d3					; CF
*   a1 points now to displacement word cq long
	beq 	noref		; 0 base displacement size
	lsr.l 	#4,d3					; CF
	subq.l	#1,d3					; CF
	bne 	ffx1
	moveq	#0,d4		; null displacement ([pc],xn) b.v.
	move.l	a1,a0		; pc of reference
	bra 	fref

ffx1:
	move.l	a1,a0
	bsr 	ismarked	; check base displacement
	bne 	noref
	subq.l	#1,d3					; CF
	bne 	ffx0		; bd size
	move	(a1),d4		; short displacement value
	ext.l	d4
	lea 	-2(a1),a0	; pc of reference
	bra 	fref

ffx0:
	lea 	2(a1),a0
	bsr 	ismarked	; long displacement (extra 2 bytes)
	bne 	noref
	move.l	(a1),d4
	lea 	-2(a1),a0	; pc of reference
	bra 	fref		; odd/even check not needed on 68030

fnoscale:				; d(pc,xi)
*	move	#$700,d0 	; scale & bit 8
*	and 	d3,d0		; extension word
	move	d3,d0
	and.l	#0x700,d0					; CF
	bne 	r244
fscaleok:
	move.b	d3,d4
	ext 	d4
	ext.l	d4

fref:					; 6 feb 2000  extra reg for address calc.
						;     can use a0 :-)
	add.l	a0,d4
	cmp.l	sref(a6),d4
	bne 	noref
	move.l	a0,d0
	rts

ismarked:
	cmpa.l	dat(a6),a0	; vaak
	bcc 	p2ge		; pc >= dat
	move.l	a0,d2
	sub.l	a5,d2		; org
	move.l	d2,d1					; CF
	lsr.l	#3,d2
	btst	#0,d7		; ****
	beq 	p21		; prg == false
	btst	d1,0(a3,d2.l)	; rel(pc-org)
	bne 	p2x
	addq.l	#1,d1					; CF
	btst	d1,0(a3,d2.l)	; rel(pc+1-org)
	bne 	p2x
	subq.l	#1,d1					; CF
p21:
	btst	d1,0(a4,d2.l)	; dt(pc-org)
	bne 	p2x
	addq.l	#1,d1					; CF
	btst	d1,0(a4,d2.l)	; dt(pc+1-org)
p2x:
	rts
p2ge:
	move	#0,ccr		; 0 --> Z
	rts

	END
