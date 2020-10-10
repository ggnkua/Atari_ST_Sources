;
; Outline '09 Boot sector
;
; Cyrano Jones - D-Bug
;

colours	equ $20000
rout	equ $30000

code	pea txt(pc)
	move.w #9,-(a7)	
	trap #1
	lea 6(a7),a7
	move.l $44e.w,a4
	moveq #8,d2
	moveq #-1,d4
	lea plot_tab(pc),a0
.loop	moveq #0,d0
	moveq #0,d1
	move.b (a0)+,d0
	mulu #160,d0
	add.b (a0)+,d0
	move.b (a0)+,d1
	bmi.s .done
	move.l a4,a1
	lea 24(a1),a1
	add.w d0,a1
.gfxlp	move.b d4,(a1) 
	lea 160(a1),a1
	subq.w #1,d1
	bne.s .gfxlp
	bra.s .loop
.done	lea colours,a3
	move.l #$4e714e71,d5
	lea rout,a0
	move.w #150,d0
.inst	move.w #40,d1
.inner	move.w #$309a,(a0)+
	clr.w (a3)+
	dbra d1,.inner
	move.l d5,(a0)+
	move.l d5,(a0)+
	move.l d5,(a0)+
	dbra d0,.inst
	move.w #$4e73,(a0)


; band start @ colours+72+(60*80)
; line offset = 80

	lea colours+72+(44*80),a0
	lea pallette(pc),a3
	move.w #39,d7
.horiz	move.w #110,d6
	move.l a0,a1
.get	move.w (a3)+,d0
	bpl.s .vert
	lea colours+72+(59*80),a3
	bra.s .get
.vert	move.w d0,(a1)
	lea 80(a1),a1
	dbra d6,.vert
	
	addq #2,a0
	dbra d7,.horiz

	lea $ffff8240.w,a0
	clr.w (a0)+
	
	lea $70.w,a6		; const!
	move.l (a6),-(a7)
	lea vbl(pc),a5
	move.l a5,(a6)

.hold	cmp.b #$39,$fffffc02.w
	bne.s .hold

	move.l (a7)+,(a6)

	rts
	
	
;
; offset / number of lines

plot_tab	
	dc.b 064,0,71		;; O
	dc.b 060,1,11
	dc.b 128,1,11
	dc.b 060,8,11
	dc.b 128,8,11
	dc.b 064,9,71

	dc.b 060,17,75		;; U
	dc.b 128,24,11
	dc.b 060,25,75		

	dc.b 060,33,11		;; T
	dc.b 060,40,79
	dc.b 060,41,11

	dc.b 060,49,79		;; L
	dc.b 128,56,11
	dc.b 128,57,11

	dc.b 060,65,11		;; I
	dc.b 128,65,11
	dc.b 060,72,79
	dc.b 060,73,11
	dc.b 128,73,11

	dc.b 064,81,75		;; N
	dc.b 060,88,11
	dc.b 064,89,75

	dc.b 060,97,79		;; E
	dc.b 060,104,11
	dc.b 096,104,11
	dc.b 128,104,11
	dc.b 060,105,11
	dc.b 128,105,11
	
	dc.b -1,-1,-1

pallette
	dc.w $701,$602,$503,$404,$305,$206,$107
	dc.w $216,$325,$434,$543,$652,$761,$670
	dc.w $761,$552,$443,$334,$225,$116,$007
	dc.w $106,$205,$304,$403,$502,$601,$ffff


txt	dc.b 27,"E",27,"b1",27,"Y",32+18,32+10,"Keeping Atari Alive!"
	dc.b 27,"Y",32+6,32+15,"D-Bug 2009",0
	even

vbl	move.w #$2700,sr
	lea $ffff8209.w,a1
	lea colours,a2
	sub #2,d7
	bpl.s .ok
	moveq.w #78,d7
.ok	add.w d7,a2

	moveq #16,d1
	moveq #0,d0
.sync	move.b (a1),d0
	beq.s .sync
	sub.w d0,d1
	lsl d1,d0		; in sync!

	jmp rout
