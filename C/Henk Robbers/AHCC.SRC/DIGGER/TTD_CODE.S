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

*	TTD_CODE.S

	globl	scanlab,findref,scanreloc,nonzero,backzero
	globl	bset,btst,bclr,bassign,g2bool,g4bool,
	globl	longmark,bytemark,wordmark,codemark
	globl	longclr,byteclr,wordclr,codeclr
	globl	print,regel,pos,prdec,prhex,prhexl,BTST,hfind

	.data
X:  .dc.b	"0123456789ABCDEF"

	.text

BTST:
	btst	d1,d0
	seq		d0
	and 	#1,d0
	rts

prdec:
	link	a6,#-18
	move.l	d0,d2
	bpl.b	R08
	neg.l	d0
R08:
	lea		(a6),a0
	clr.b	-(a0)
	move.l	d0,d1		; long value
	swap	d1
	tst 	d1			; high significant word is zero: fast
	bne.b	R44
R22:
	divu	#10,d0
	move.l	d0,d1
	swap	d1
	move.b	d1,-(a0)
	addi.b	#'0',(a0)
	swap	d0
	clr 	d0
	swap	d0
	bne.b	R22
	bra.b	R80

R44:
	move	d3,-(a7)
R46:
	move.l	d0,d1
	move	d0,d3
	clr 	d1
	swap	d1
	divu	#10,d1
	move	d1,d0
	move	d3,d1
	divu	#10,d1
	swap	d0
	move	d1,d0
	swap	d1
	move.b	d1,-(a0)
	addi.b	#'0',(a0)
	tst.l	d0
	bne.b	R46
	move	(a7)+,d3
R80:
	tst.l	d2
	bpl		R81
	move.b	#'-',-(a0)
R81:
	jsr		print
	unlk	a6
	rts

prhex:
	link	a6,#-12
	lea		(a6),a0
	lea 	X,a1
	clr.b	-(a0)
	move.l	d0,d1		; long value
	swap	d1
	tst 	d1			; high significant word is zero: fast
	bne.b	X44
X22:
	divu	#16,d0
	move.l	d0,d1
	swap	d1
	move.b	0(a1,d1),-(a0)
	swap	d0
	clr 	d0
	swap	d0
	bne.b	X22
	bra.b	X80

X44:
X46:
	move.l	d0,d1
	move	d0,d2
	clr 	d1
	swap	d1
	divu	#16,d1
	move	d1,d0
	move	d2,d1
	divu	#16,d1
	swap	d0
	move	d1,d0
	swap	d1
	move.b	0(a1,d1),-(a0)
	tst.l	d0
	bne.b	X46
X80:
	jsr		print
	unlk	a6
	rts

*   void    prhexl(long val, int l)
*					d0        d1
prhexl:
	link	a6,#-12

	move.l	#'0000',-4(a6)
	move.l	-4(a6),-8(a6)
	move.l	-4(a6),-12(a6)

	lea		(a6),a0
	lea 	X,a1
	clr.b	-(a0)
	move.l	d0,d2		; long value
	swap	d2
	tst 	d2			; high significant word is zero: fast
	bne.b	H44
H22:
	divu	#16,d0
	move.l	d0,d2
	swap	d2
	move.b	0(a1,d2),-(a0)
	swap	d0
	clr 	d0
	swap	d0
	bne.b	H22
	bra.b	H80

H44:
	move	d3,-(a7)
H46:
	move.l	d0,d2
	move	d0,d3
	clr 	d2
	swap	d2
	divu	#16,d2
	move	d2,d0
	move	d3,d2
	divu	#16,d2
	swap	d0
	move	d2,d0
	swap	d2
	move.b	0(a1,d2),-(a0)
	tst.l	d0
	bne.b	H46
	move	(a7)+,d3
H80:
	lea		-1(a6),a0
	suba	d1,a0
	jsr		print
	unlk	a6
	rts

print:
	move.l	pos,a1
pp:	move.b	(a0)+,(a1)+		; allways null terminated
	bne 	pp
	subq	#1,a1			; for continuation
	move.l	a1,pos
	rts

;	void bset(bool *row,long bit);
bset:						; Pure_C
	move.b	d0,d1
	lsr.l	#3,d0
	bset	d1,0(a0,d0.l)
	rts

;	void bassign(bool *row,long bit,bool value);
bassign:					; Pure_C
	move.b	d0,d2
	lsr.l	#3,d0
	tst 	d1
	beq 	bc
	bset	d2,0(a0,d0.l)
	rts
bc:	bclr	d2,0(a0,d0.l)
	rts

;	void longclr (bool *row,long bit)
longclr:
	move.l	d0,-(sp)
	move.b	d0,d1
	lsr.l	#3,d0
	bclr	d1,0(a0,d0.l)
	addq.b	#1,d1			; d0 allways even
	bclr	d1,0(a0,d0.l)
	move.l	(sp)+,d0
	addq	#2,d0
	move.b	d0,d1
	lsr.l	#3,d0
	bclr	d1,0(a0,d0.l)
	addq.b	#1,d1
	bclr	d1,0(a0,d0.l)
	rts
;	void longmark(bool *row,long bit)
longmark:
	move.l	d0,-(sp)
	move.b	d0,d1
	lsr.l	#3,d0
	bset	d1,0(a0,d0.l)
	addq.b	#1,d1			; d0 allways even
	bclr	d1,0(a0,d0.l)
	move.l	(sp)+,d0
	addq	#2,d0
	move.b	d0,d1
	lsr.l	#3,d0
	bclr	d1,0(a0,d0.l)
	addq.b	#1,d1
	bset	d1,0(a0,d0.l)
	rts

;	long g4bool(bool *row, long bitaddress)
g4bool:
	move.l	d0,-(sp)
	move.l	d0,d2
	moveq	#0,d0
	move.b	d2,d1
	lsr.l	#3,d2
	btst	d1,0(a0,d2.l)
	sne		d0
	and.b	#1,d0
	lsl		#8,d0
	addq.b	#1,d1			; d2 allways even
	btst	d1,0(a0,d2.l)
	sne		d0
	and.b	#1,d0
	lsl.l	#8,d0
	move.l	(sp)+,d2
	addq	#2,d2
	move.b	d2,d1
	lsr.l	#3,d2
	btst	d1,0(a0,d2.l)
	sne		d0
	and.b	#1,d0
	lsl.l	#8,d0
	addq.b	#1,d1
	btst	d1,0(a0,d2.l)
	sne		d0
	and.b	#1,d0
	rts

;	int g2bool(bool *row, long bitaddress)
g2bool:
	move.l	d0,d2
	moveq	#0,d0
	move.b	d2,d1
	lsr.l	#3,d2
	btst	d1,0(a0,d2.l)
	sne		d0
	and.b	#1,d0
	lsl		#8,d0
	addq.b	#1,d1			; d2 allways even
	btst	d1,0(a0,d2.l)
	sne		d0
	and.b	#1,d0
	rts

;	void byteclr(bool *row,long bit)
byteclr:
	move.b	d0,d1
	lsr.l	#3,d0
	bclr	d1,0(a0,d0.l)
	addq.b	#1,d1			; d0 allways even
	bclr	d1,0(a0,d0.l)
	rts
;	void bytemark(bool *row,long bit)
bytemark:
	move.b	d0,d1
	lsr.l	#3,d0
	bset	d1,0(a0,d0.l)
	addq.b	#1,d1			; d0 allways even
	bset	d1,0(a0,d0.l)
	rts

;	void wordclr(bool *row,long bit)
wordclr:
	move.b	d0,d1
	lsr.l	#3,d0
	bclr	d1,0(a0,d0.l)
	addq.b	#1,d1			; d0 allways even
	bclr	d1,0(a0,d0.l)
	rts
;	void wordmark(bool *row,long bit)
wordmark:
	move.b	d0,d1
	lsr.l	#3,d0
	bset	d1,0(a0,d0.l)
	addq.b	#1,d1			; d0 allways even
	bclr	d1,0(a0,d0.l)
	rts

;	void codeclr(bool *row,long bit)
codeclr:
;	void codemark(bool *row,long bit)
codemark:
	move.b	d0,d1
	lsr.l	#3,d0
	bclr	d1,0(a0,d0.l)
	addq.b	#1,d1			; d0 allways even
	bclr	d1,0(a0,d0.l)
	rts

;	void bclr(bool *row,long bit);
bclr:						; Pure_C
	move.b	d0,d1
	lsr.l	#3,d0
	bclr	d1,0(a0,d0.l)
	rts

;	bool btst(bool *row,long bit);
btst:						; Pure_C
	move.b	d0,d1
	lsr.l	#3,d0
	btst	d1,0(a0,d0.l)
	sne		d0
	and		#1,d0
	rts

;	void bchg(bool *row,long bit);
bchg:						; Pure_C
	move.b	d0,d1
	lsr.l	#3,d0
	bchg	d1,0(a0,d0.l)
	rts

;	long nonzero(void *);
nonzero:					; Pure_C
;	movea.l $0004(sp),a0
nzloop:
	tst.l	(a0)+
	beq.s	nzloop
	subq	#4,a0
	move.l	a0,d0
	rts

;	PCW backzero(PCW pc);
backzero:
;	move.l	4(sp),a0
	addq	#4,a0
bzloop:
	tst.l	-(a0)
	beq.s	bzloop
	move.l	a0,d0
	rts

scanlab:				    ; cdecl
	link	a6,#$00
	movem.l d3-d7/a2-a5,-(sp)
	btst	#3,11(a6)
	beq 	sc1
	pea 	scan1(pc)
	move.w	#$0026,-(sp)	; supexec
	trap	#14		; xbios
	addq.l	#6,sp
	bra 	sc2
sc1:
	jsr 	scan1(pc)
sc2:
	movem.l (sp)+,d3-d7/a2-a5
	unlk	a6
	rts

findref:					;cdecl
	link	a6,#$00
	movem.l d3-d7/a2-a5,-(sp)
	btst	#3,11(a6)
	beq 	fi1
	pea 	find1(pc)
	move.w	#$0026,-(sp)	; supexec
	trap	#14		; xbios
	addq.l	#6,sp
	bra 	fi2
fi1:
	jsr 	find1(pc)
fi2:
	movem.l (sp)+,d3-d7/a2-a5
	unlk	a6
	rts

;	PCW cdecl
;		scanreloc(
;			PCW org,PCW bss,PCW top,
;			PCW rlc,PCW limit,
;			bool rel[],bool ref[]
;			);

	offset
offa6:	ds.l	2
org:	ds.l	1
bss:	ds.l	1
top:	ds.l	1
rlc:	ds.l	1
lim:	ds.l	1
rel:	ds.l	1
lab:	ds.l	1

	text
scanreloc:						; cdecl
	link	a6,#0
	movem.l d3-d7/a2-a5,-(sp)
	movea.l org(a6),a0
	move.l	bss(a6),d7
	move.l	top(a6),d6
	movea.l rlc(a6),a1
	movea.l lim(a6),a2
	movea.l rel(a6),a3
	movea.l lab(a6),a4
	sub.l	a0,d7
	subq.l	#4,d7		; d7 = bss - org - 4
	sub.l	a0,d6		; d6 = top - org
	moveq	#$00,d0
	move.b	(a1)+,d1
	lsl.w	#8,d1
	move.b	(a1)+,d1
	lsl.l	#8,d1
	move.b	(a1)+,d1
	lsl.l	#8,d1
	move.b	(a1)+,d1
	tst.l	d1
	beq.s	r_exit
	cmpa.l	a2,a1
	bhi.s	r_exit		; ptr > limit
	btst	#0,d1
	bne.s	r_fail
r_loop1:
	add.l	d0,d1
	cmp.l	d7,d1
	bhi.s	r_fail1
	move.l	d1,d2
	lsr.l	#3,d2
	bset	d1,$00(a3,d2.l) ; rel(d1) = true
	move.l	$00(a0,d1.l),d2
	cmp.l	d6,d2
	bhi.s	r_loop2
	move.b	d2,d3
	lsr.l	#3,d2
	bset	d3,$00(a4,d2.l) ; lab(d2) = true
r_loop2:
	cmpa.l	a2,a1
	bcc.s	r_exit		; ptr >= limit
	move.b	(a1)+,d0
	beq.s	r_exit
	btst	#0,d0
	beq.s	r_loop1
	subq.b	#3,d0
	bcc.s	r_fail2
	add.l	d0,d1
	bra.s	r_loop2

r_fail:
	lea 	0.w,a0
	bra 	rx
r_fail1:
	lea 	1.w,a0
	bra 	rx
r_fail2:
	lea 	2.w,a0
	bra 	rx
r_exit:
	move.l	a1,a0
rx:
	move.l	a0,d0		/* voor alle zekerheid (ptr return) */
	movem.l (sp)+,d3-d7/a2-a5
	unlk	a6
	rts

;	void cdecl scan(long mopt,
;					PCW org,PCW bss,PCW top,long offset,
;					bool mask[],
;					bool rel[],bool dt[],bool ref[]
;					)

scan1:
	move.b	$000B(a6),d7	; prg
	movea.l $000C(a6),a5	; org
	movea.l $0010(a6),a4	; dat
	move.l	$0014(a6),d3	; top
	move.l	$0018(a6),d6	; offset
	movea.l $0020(a6),a1	; rel
	movea.l $0024(a6),a3	; dt
	move.l	d3,d2
	sub.l	a5,d2
	add.l	d6,d2		; top-org+offset
	tst.b	d7
	bne.s	r070		; prg == true
	movea.l a5,a2
r04a:
	lea 	$0002(a2),a0
	cmpa.l	d3,a0
	bcc.s	r070		; pc + 2 >= top
	move.l	(a2),d4
	cmp.l	d6,d4
	ble.s	r06c
	cmp.l	d2,d4
	bge.s	r06c
	move.l	d4,d0
	sub.l	d6,d0
	move.b	d0,d1
	lsr.l	#3,d0
	movea.l $0028(a6),a0	; ref
	bset	d1,$00(a0,d0.l) ; ref(d4-offset) = true
r06c:
	addq.l	#2,a2
	bra.s	r04a

r070:
	movea.l $0028(a6),a0
;	The following removed on request of Lonny Purcell
*	bset	#$00,(a0)	; ref(org-org) = true
*	move.l	a4,d0
*	sub.l	a5,d0
*	move.b	d0,d1
*	lsr.l	#3,d0
*	bset	d1,$00(a0,d0.l) ; ref(dat-org) = true
*	move.l	d3,d0
*	sub.l	a5,d0
*	move.b	d0,d1
*	lsr.l	#3,d0
*	bset	d1,$00(a0,d0.l) ; ref(top-org) = true
	lea 	-$0004(a5),a2	; pc = org - 4
s_step4:
	addq.l	#2,a2
s_step2:
	addq.l	#2,a2
s_step0:
	cmpa.l	a4,a2
	bcc 	s_exit		; pc >= dat
	move.l	a2,d0
	sub.l	a5,d0
	move.b	d0,d1
	lsr.l	#3,d0
	tst.b	d7
	beq.s	r0b0		; prg == false
	btst	d1,$00(a1,d0.l) ; rel(pc-org)
	bne.s	s_step4
	addq.b	#1,d1
	btst	d1,$00(a1,d0.l) ; rel(pc+1-org)
	bne.s	s_step2
	subq.b	#1,d1
r0b0:
	btst	d1,$00(a3,d0.l) ; dt(pc-org)
	bne.s	s_step2
	addq.b	#1,d1
	btst	d1,$00(a3,d0.l) ; dt(pc+1-org)
	bne.s	s_step2
r0b8:
	move.w	(a2)+,d5
	move.w	d5,d0
	andi.w	#$F001,d0
	cmpi.w	#$6000,d0	; bcc
	bne.s	r0d2
	move.b	d5,d4
	beq.s	r0d2		; bcc.l
	ext.w	d4
	ext.l	d4
	bra	mark

r0d2:
	cmpa.l	a4,a2
	bcc 	s_exit		; pc >= dat
	move.l	a2,d0
	sub.l	a5,d0
	move.b	d0,d1
	lsr.l	#3,d0
	tst.b	d7
	beq.s	r0ee		; prg == false
	btst	d1,$00(a1,d0.l) ; rel(pc-org)
	bne.s	s_step4
	addq.b	#1,d1
	btst	d1,$00(a1,d0.l) ; rel(pc+1-org)
	bne.s	s_step2
	subq.b	#1,d1
r0ee:
	btst	d1,$00(a3,d0.l) ; dt(pc-org)
	bne.s	s_step2
	addq.b	#1,d1
	btst	d1,$00(a3,d0.l) ; dt(pc+1-org)
	bne.s	s_step2
	move.l	d5,d0
	andi.w	#$F0FF,d0
	cmpi.w	#$6000,d0	; bcc.l
	beq.s	r104
	andi.w	#$F0F8,d0
	cmpi.w	#$50C8,d0	; dbcc
	bne.s	r112
r104:
	move.w	(a2),d4
	beq.s	r0b8
	ext.l	d4
	btst	#$00,d4
	bne.s	r0b8
	bra	mark

r112:
	move.w	d5,d0
	andi.w	#$003E,d0
	cmpi.w	#$003A,d0	; dd(pc), d(pc,rn)
	bne.s	r0b8
	move.w	d5,d0
	lsr.w	#6,d0
	move.b	d0,d1
	lsr.w	#3,d0
	movea.l $001C(a6),a0	; mask
	btst	d1,$00(a0,d0.w)
	beq 	r0b8
	move.w	d5,d0
	andi.w	#$FFC0,d0
	cmpi.w	#$0800,d0	; btst #n,<ea>
	beq.s	r146
	andi.w	#$FF80,d0
	cmpi.w	#$4C80,d0	; movem.s <ea>,<reglist>
	bne.s	r18e
r146:
	lea 	$0002(a2),a0
	cmpa.l	a4,a0
	bcc 	r0b8		; pc + 2 >= dat
	move.l	a0,d0
	sub.l	a5,d0
	move.b	d0,d1
	lsr.l	#3,d0
	tst.b	d7
	beq.s	r168		; prg == false
	btst	d1,$00(a1,d0.l) ; rel(pc+2-org)
	bne 	r0b8
	addq.b	#1,d1
	btst	d1,$00(a1,d0.l) ; rel(pc+3-org)
	bne 	r0b8
	subq.b	#1,d1
r168:
	btst	d1,$00(a3,d0.l) ; dt(pc+2-org)
	bne 	r0b8
	addq.b	#1,d1
	btst	d1,$00(a3,d0.l) ; dt(pc+3-org)
	bne 	r0b8
	btst	#$00,d5
	beq.s	r184		; d(pc)
	moveq	#$07,d0 	; d(pc,xi)
	and.b	$0002(a2),d0
	bne 	r0b8
	move.b	$0003(a2),d4
	ext.w	d4
	ext.l	d4
	addq.l	#2,d4
	bra.s	mark

r184:
	move.w	$0002(a2),d4
	ext.l	d4
	addq.l	#2,d4
	bra.s	r1aa

r18e:
	btst	#$00,d5
	beq.s	r1a6		; d(pc)
	moveq	#$07,d0 	; d(pc,xi)
	and.b	(a2),d0
	bne 	r0b8
	move.b	$0001(a2),d4
	ext.w	d4
	ext.l	d4
	bra.s	mark

r1a6:
	move.w	(a2),d4
	ext.l	d4
r1aa:
	btst	#$00,d4
	beq.s	mark		; even adres
	cmpi.w	#$2000,d5	; btst, move.b
	bcs.s	mark
	cmpi.w	#$487A,d5	; pea
	beq.s	mark
	andi.w	#$F1C0,d5
	cmpi.w	#$41C0,d5	; lea
	beq.s	mark
	andi.w	#$80C0,d5
	cmpi.w	#$8000,d5	; op.b
	bne 	r0b8
mark:
	lea 	$00(a2,d4.l),a0
	cmpa.l	a5,a0
	bcs 	s_step0 	; pc + displacement <  org    HR 02'09 bls --> bcs
	cmpa.l	d3,a0
	bcc 	s_step0 	; pc + displacement >= top
	move.l	a0,d0
	sub.l	a5,d0
	move.b	d0,d1
	lsr.l	#3,d0
	movea.l $0028(a6),a0	; ref(pc+displacement-org) = true
	bset	d1,$00(a0,d0.l)
	bra 	s_step0

s_exit:
	rts


;	long cdecl
;		findref(long mopt,
;			PCW org,PCW bss,PCW sto,PCW rkey,
;			bool mask[],bool rel[],bool dt[],
;			PCW start,PCW sref
;			);

* HR: changed such that it returns the exact location of the reference
find1:
	move.b	$000B(a6),d7	; prg
	movea.l $000C(a6),a5	; org
	movea.l $0010(a6),a4	; dat
	move.l	$0014(a6),d3	; top
	move.l	$0018(a6),d6	; reference
	movea.l $0020(a6),a1	; rel
	movea.l $0024(a6),a3	; dt
	movea.l $0028(a6),a2	; pc
	move.l	$002C(a6),d2	; reference + shift
	tst.b	d7
	beq.s	r244		; prg == false
	move.l	a2,d0
	sub.l	a5,d0
	move.b	d0,d1
	lsr.l	#3,d0
	btst	d1,$00(a1,d0.l) ; rel(pc-org)
	beq.s	r244
	addq.b	#1,d1
	btst	d1,$00(a1,d0.l) ; rel(pc+1-org)
	bne.s	r244
f_step4:
	addq.l	#2,a2
f_step2:
	addq.l	#2,a2
	move.l	a2,d0
	sub.l	a5,d0
	move.b	d0,d1
	lsr.l	#3,d0
	btst	d1,$00(a1,d0.l) ; rel(pc-org)
	beq.s	r242
r240:
	addq.b	#1,d1
	btst	d1,$00(a1,d0.l) ; rel(pc+1-org)
	bne.s	f_step2
	cmp.l	(a2),d6
	bne.s	f_step4
	bra 	f_exit		; HR (was f_exit2) ivm lineaal

r242:
	addq.b	#1,d1
	btst	d1,$00(a1,d0.l) ; rel(pc+1-org)
	bne.s	f_step2
r244:
	cmpa.l	d3,a2
	bcc 	f_exit		; pc >= top
	move.w	(a2)+,d5
	cmpa.l	a4,a2
	bhi.s	r26c		; pc > dat
	move.w	d5,d0
	andi.w	#$F001,d0
	cmpi.w	#$6000,d0	; bcc
	bne.s	r26c
	move.b	d5,d4
	beq.s	r26c		; bcc.l
	move.l	a2,d0
	subq.l	#2,d0
	sub.l	a5,d0
	move.b	d0,d1
	lsr.l	#3,d0
	btst	d1,$00(a3,d0.l) ; dt(pc-2-org)
	bne.s	r26c
	addq.b	#1,d1
	btst	d1,$00(a3,d0.l) ; dt(pc-1-org)
	bne.s	r26c
	ext.w	d4
	ext.l	d4
	add.l	a2,d4
	cmp.l	d2,d4
	beq 	f_exit2		; HR ok (a2 on bcc.b itself)
r26c:
	cmpa.l	d3,a2
	bcc 	f_exit		; pc >= top
	move.l	a2,d0
	sub.l	a5,d0
	move.b	d0,d1
	lsr.l	#3,d0
	tst.b	d7		; prg == false
	beq.s	r294
	btst	d1,$00(a1,d0.l) ; rel(pc-org)
	bne.s	r240
	addq.b	#1,d1
	btst	d1,$00(a1,d0.l) ; rel(pc+1-org)
	bne 	f_step2
	subq.b	#1,d1
	bra.s	r2a6

r294:
	lea 	$0002(a2),a0
	cmpa.l	d3,a0		; pc + 2 >= top
	bcc.s	r2a6
	cmp.l	(a2),d6
	beq 	f_exit		; HR (was f_exit2)
r2a6:
	cmpa.l	a4,a2
	bcc.s	r244		; pc >= dat
	btst	d1,$00(a3,d0.l) ; dt(pc-org)
	bne.s	r244
	addq.b	#1,d1
	btst	d1,$00(a3,d0.l) ; dt(pc+1-org)
	bne 	r244
	move.l	d5,d0
	andi.w	#$F0FF,d0
	cmpi.w	#$6000,d0	; bcc.l
	beq.s	r2c0
	andi.w	#$F0F8,d0
	cmpi.w	#$50C8,d0	; dbcc
	bne.s	r2d0
r2c0:
	move.w	(a2),d4
	beq 	r244
	ext.l	d4
	btst	#$00,d4
	bne 	r244
	bra 	r39a

r2d0:
	move.w	d5,d0
	andi.w	#$003E,d0
	cmpi.w	#$003A,d0	; dd(pc), d(pc,rn)
	bne	r244
	move.w	d5,d0
	lsr.w	#6,d0
	move.b	d0,d1
	lsr.w	#3,d0
	movea.l $001C(a6),a0	; mask
	btst	d1,$00(a0,d0.w)
	beq 	r244
	move.w	d5,d0
	andi.w	#$FFC0,d0
	cmpi.w	#$0800,d0	; btst #n,<ea>
	beq.s	r308
	andi.w	#$FF80,d0
	cmpi.w	#$4C80,d0	; movem.s <ea>,<reglist>
	bne.s	r350
r308:
	lea 	$0002(a2),a0
	cmpa.l	a4,a0		; pc + 2 >= dat
	bcc 	r244
	move.l	a0,d0
	sub.l	a5,d0
	move.b	d0,d1
	lsr.l	#3,d0
	tst.b	d7
	beq.s	r32a		; prg == false
	btst	d1,$00(a1,d0.l) ; rel(pc+2-org)
	bne 	r244
	addq.b	#1,d1
	btst	d1,$00(a1,d0.l) ; rel(pc+3-org)
	bne 	r244
	subq.b	#1,d1
r32a:
	btst	d1,$00(a3,d0.l) ; dt(pc+2-org)
	bne 	r244
	addq.b	#1,d1
	btst	d1,$00(a3,d0.l) ; dt(pc+3-org)
	bne 	r244
	btst	#$00,d5
	beq.s	r346		; d(pc)
	moveq	#$07,d0 	; d(pc,xi)
	and.b	$0002(a2),d0
	bne 	r244
	move.b	$0003(a2),d4
	ext.w	d4
	ext.l	d4
	addq.l	#2,d4
	bra.s	r39a

r346:
	move.w	$0002(a2),d4
	ext.l	d4
	addq.l	#2,d4
	bra.s	r36c

r350:
	btst	#$00,d5
	beq.s	r368		; d(pc)
	moveq	#$07,d0 	; d(pc,xi)
	and.b	(a2),d0
	bne 	r244
	move.b	$0001(a2),d4
	ext.w	d4
	ext.l	d4
	bra.s	r39a

r368:
	move.w	(a2),d4
	ext.l	d4
r36c:
	btst	#$00,d4 	; even adres
	beq.s	r39a
	cmpi.w	#$2000,d5	; btst, move.b
	bcs.s	r39a
	cmpi.w	#$487A,d5	; pea
	beq.s	r39a
	andi.w	#$F1C0,d5
	cmpi.w	#$41C0,d5	; lea
	beq.s	r39a
	andi.w	#$80C0,d5
	cmpi.w	#$8000,d5	; op.b
	bne 	r244
r39a:
	add.l	a2,d4
	cmp.l	d2,d4
	bne 	r244
f_exit:
	move.l	a2,d0		; HR (was via f_exit2)
	rts

f_exit2:
	subq.l	#2,a2
	move.l	a2,d0
	rts

*	long cdecl hfind()

*	d0:     key_ptr
*	d2:     key_len
*	a0:     pc
*	a1:     pc_max
*	a2:     key[]
*	a3:     nxt_key[]

hfind:
	movem.l $0004(a7),d2/a0-a3
	move.b  (a2),d3
	bra.s   start

nxtsym:
	move.b  (a0)+,d1
cmpkey:
	cmp.b   0(a2,d0.l),d1
	beq.s   xxx
	move.b  0(a3,d0.l),d0
	bpl.s   cmpkey
start:
	moveq   #0,d0
lp1:
	cmpa.l  a1,a0
	bcc.s   exit
	cmp.b   (a0)+,d3
	bne.s   lp1
xxx:
	addq.b  #1,d0
	cmp.b   d2,d0
	bcc.s   exit
	cmpa.l  a1,a0
	bcs.s   nxtsym
exit:
	sub.l   a0,d0
	neg.l   d0
	rts

	END
