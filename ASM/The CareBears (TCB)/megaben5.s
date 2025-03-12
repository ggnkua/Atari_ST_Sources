* my compact and fast y(pixel) dister....
* Code made 1991 By AN (el loco hombre) COOL....

*** Comments made in 1997 have 3 stars (***).

x:
	bra	main

*	!!! Don't tuch d0-d1/a0-a1

init_ints:			***only VBI is used (50 Hz)
	move.w	#$2700,sr
	move.l	$70.w,save_70
	move.l	#vbi,$70.w
	move.w	#$2300,sr
	rts
ret_ints:			***return control to OS
	move.w	#$2700,sr
	move.l	save_70,$70.w
	move.w	#$2300,sr
	rts
save_70:			***a bad position if you are
				***into structure in your code
	dc.l	0


*** The segment called: make_bends is producing the
*** 8*8 y distorted block.


make_bends:
	lea	the_y_pos_tab(pc),a0	
	lea	sintab(pc),a1
	moveq	#0,d1
	move.w	#255,d0		*size of sintab (*** nice and clean val.)
.loop3:
	move.w	d1,(a0)+
	jsr	get_minimum(pc)	* result in d2
	mulu	#160,d2
	move.w	d2,(a0)+
	addq.l	#8,d1
	addq.l	#2,a1
	dbra	d0,.loop3

	lea	precal_buff(pc),a0
	moveq	#7,d0		*number of combinations (2^3=8)
.loop:
	jsr	make_bits_big_tab(pc)
	addq.w	#1,bend_bits
	lea	sintab(pc),a1
	move.w	#255,d1		*size of sintab
.loop2:
	jsr	dist_current_blk(pc) ***preform
	jsr	get_curren_blk(pc)
	addq.l	#2,a1
	dbra	d1,.loop2
	add.w	#$123,$ff8240 ***this is (c) THE CAREBEARS (TM) :)
	dbra	d0,.loop
	rts

get_curren_blk:
	lea	mega_big_tab+8(pc),a2
	moveq	#7,d2
.loop:
	move.b	(a2),(a0)+
	clr.b	(a2)+
	dbra	d2,.loop
	rts
dist_current_blk:
;	lea	mega_big_tab(pc),a2
;	move.w	#(8*4)-1,d2
;.loop:
;	clr.b	(a2)+
;	dbra	d2,.loop
	jsr	get_minimum(pc)	* result in d2
	move.l	a1,a2
	move.w	#7,d3
.loop2:
	lea	big_tab(pc),a3
	lea	mega_big_tab(pc),a4
	move.w	(a2)+,d4
	sub.w	d2,d4
	add.w	d4,a4
	moveq	#(8*3)-1,d5
.loop3:
	move.b	(a3)+,d6
	moveq	#1,d7
	lsl.b	d3,d7
	and.b	d7,d6
	or.b	d6,(a4)+
	dbra	d5,.loop3
	dbra	d3,.loop2
	rts	
get_minimum:
	move.w	#32767,d2
	move.l	a1,a2
	moveq	#7,d3
dbloop:
	cmp.w	(a2)+,d2
	bge.s	found_new
	dbra	d3,dbloop	
	rts
found_new:
	move.w	-2(a2),d2
	dbra	d3,dbloop
	rts
make_bits_big_tab:
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	move.w	bend_bits(pc),d1
	btst	#0,d1
	beq.s	no_bit1
	moveq	#-1,d2
no_bit1:
	btst	#1,d1
	beq.s	no_bit2
	moveq	#-1,d3
no_bit2:
	btst	#2,d1
	beq.s	no_bit3
	moveq	#-1,d4
no_bit3:
	lea	big_tab(pc),a1
	rept	8
	move.b	d2,(a1)+
	endr
	rept	8
	move.b	d3,(a1)+
	endr
	rept	8
	move.b	d4,(a1)+
	endr
	rts
bend_bits:
	dc.w	0
big_tab:
	ds.b	8*3
mega_big_tab:
	ds.b	8*4

*** blatt routine... compact and effective.

ut_dist:
	lea	the_y_pos_tab(pc),a0
	move.w	super_offs(pc),d2
	addq.w	#4,d2
	and.w	#1023,d2
	move.w	d2,super_offs
	lea	the_org_tab(pc),a1
	add.w	scroll_offs(pc),a1
	move.l	currpicadd,a4
	add.w	#320,a4
	lea	precal_buff(pc),a5
	moveq	#1,d6
	moveq	#11,d7
	move.b	#%01010010,.self
	moveq	#39,d0
.loop:
	move.w	(a0,d2.w),d4
	move.w	2(a0,d2.w),d5

	move.l	a4,a3
	move.l	a5,a2
	moveq	#0,d3
	or.b	-80(a1),d3
	lsr.b	d6,d3
	or.b	(a1),d3
	lsr.b	d6,d3
	or.b	80(a1),d3
	move.w	d3,d1
	lsl.w	d7,d1
	add.w	d4,d1
	add.w	d1,a2
	add.w	d5,a3
	clr.b	-320(a3)
	clr.b	-160(a3)
	move.b	(a2)+,160*0(a3)
	move.b	(a2)+,160*1(a3)
	move.b	(a2)+,160*2(a3)
	move.b	(a2)+,160*3(a3)
	move.b	(a2)+,160*4(a3)
	move.b	(a2)+,160*5(a3)
	move.b	(a2)+,160*6(a3)
	move.b	(a2)+,160*7(a3)
num	set	0
num2	set	160*8
	rept	7
	move.l	a4,a3
	move.l	a5,a2
	lsr.w	d6,d3
	or.b	160+num(a1),d3
	move.w	d3,d1
	lsl.w	d7,d1
	add.w	d4,d1
	add.w	d1,a2
	add.w	d5,a3
	move.b	(a2)+,(160*0)+num2(a3)
	move.b	(a2)+,(160*1)+num2(a3)
	move.b	(a2)+,(160*2)+num2(a3)
	move.b	(a2)+,(160*3)+num2(a3)
	move.b	(a2)+,(160*4)+num2(a3)
	move.b	(a2)+,(160*5)+num2(a3)
	move.b	(a2)+,(160*6)+num2(a3)
	move.b	(a2)+,(160*7)+num2(a3)
num	set	num+80
num2	set	num2+(160*8)
	endr
	add.w	#4*8,d2
	and.w	#1023,d2
	addq.l	#1,a1
.self:
	addq.l	#1,a4
	eor.b	#%00001100,.self
	dbra	d0,.loop
	rts
super_offs:
	dc.w	0
stopper:
	addq.l	#1,text_ptr
	move.w	#200,waits
	rts
end_txt:
	move.l	#text,text_ptr
new_char:
	move.l	text_ptr(pc),a0
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#0,d0
	beq.s	end_txt
	cmp.b	#-1,d0
	beq.s	stopper
	move.l	a0,text_ptr
	mulu	#8,d0
	add.l	#font,d0
	move.l	d0,curr_char
	move.w	#7,internal_shift
	bra.s	back_on_track

scroll:
	cmp.w	#40,scroll_offs
	bne.s	no_restore
	clr.w	scroll_offs
no_restore:
	cmp.w	#-1,internal_shift
	beq	new_char
back_on_track:
	lea	the_org_tab(pc),a0
	add.w	scroll_offs(pc),a0
	move.l	curr_char(pc),a1
	move.w	internal_shift(pc),d1
	moveq	#7,d2
kalle_loop:
	move.b	(a1)+,d0
	lsr.b	d1,d0
	btst	#0,d0
	beq.s	no_blurp
	move.b	#4,0(a0)
	move.b	#4,40(a0)
	bra.s	nuffe
no_blurp:
	clr.b	0(a0)
	clr.b	40(a0)
nuffe:
	lea	80(a0),a0
	dbra	d2,kalle_loop
	subq.w	#1,internal_shift
	addq.w	#1,scroll_offs
	rts
	
curr_char:
	dc.l	font
internal_shift:
	dc.w	7
scroll_offs:
	dc.w	0
main:
	pea	0
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	bclr	#0,$484
	moveq	#1,d0
	jsr	music

	move.w	#0,-(sp)
	pea	$200000
	pea	$200000
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	move.w	#0,-(sp)
	pea	$300000
	pea	$300000
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	jsr	make_bends(pc)
	jsr	init_ints(pc)
	clr.w	wfnc
demo_loop:
	cmp.w	#1,wfnc
	bne.s	demo_loop
	clr.w	wfnc
	move.w	#$002,$ff8240
	jsr	ut_dist(pc)
	move.w	#$101,$ff8240
	cmp.w	#0,waits
	bne	no_scroller
	jsr	scroll(pc)
	bra	jons
no_scroller:
	subq.w	#1,waits
jons:
	move.w	#$000,$ff8240
	cmp.b	#59,$fffc02
	bne	demo_loop
	jsr	ret_ints(pc)
	illegal				*** illegal is the best exit!!!!
					*** people that doubt that...
					*** trace GENST and you will see.
vbi:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#1,wfnc
	move.l	olpicadd(pc),d0
	move.l	currpicadd(pc),olpicadd
	move.l	d0,currpicadd
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.w	#8,d0
	move.b	d0,$ffff8201.w
	jsr	music+8(pc)
	movem.l	(sp)+,d0-d7/a0-a6
	rte
currpicadd:
	dc.l	$200000
olpicadd:
	dc.l	$300000

wfnc:
	dc.w	0
waits:
	dc.w	0
aa:
	dc.l	0
sst:
	dc.l	0
sintab:
 dc.w 0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1
 dc.w 2,2,2,2,3,3,3,3,4,4,4,5,5,5,6,6
 dc.w 6,7,7,8,8,8,9,9,10,10,11,11,12,12,13,13
 dc.w 14,14,15,15,16,16,17,17,18,18,19,19,20,20,21,21
 dc.w 22,23,23,24,24,25,25,26,26,27,27,28,28,29,29,30
 dc.w 30,31,31,32,32,33,33,34,34,35,35,36,36,36,37,37
 dc.w 38,38,38,39,39,39,40,40,40,41,41,41,41,42,42,42
 dc.w 42,43,43,43,43,43,43,43,44,44,44,44,44,44,44,44
 dc.w 44,44,44,44,44,44,44,44,44,43,43,43,43,43,43,43
 dc.w 42,42,42,42,41,41,41,41,40,40,40,39,39,39,38,38
 dc.w 38,37,37,36,36,36,35,35,34,34,33,33,32,32,31,31
 dc.w 30,30,29,29,28,28,27,27,26,26,25,25,24,24,23,23
 dc.w 22,21,21,20,20,19,19,18,18,17,17,16,16,15,15,14
 dc.w 14,13,13,12,12,11,11,10,10,9,9,8,8,8,7,7
 dc.w 6,6,6,5,5,5,4,4,4,3,3,3,3,2,2,2
 dc.w 2,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0
end_sin:
 dc.w 0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1
*	the extra 16 or 8 pixels

	*	1 2 3 4 5 6 7 8 91011121314151617181920212223242526272829303132333435363738394041
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
the_org_tab:
	rept	8
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	endr	
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
the_y_pos_tab:
	ds.l	256	*first word tab offset. second word screen offset.
text_ptr:
	dc.l	text
text:
	dc.b	" Yes!.....     Here it is.....     You miGht"
	dc.b	" wonder what...  ???????    But this is the"
	dc.b	" allmiGht-Y-bit-distinG-destorted-scroller..."
	dc.b	" so nowYou know...."
	dc.b	"     if You don't beleave me....  check"
	dc.b	" dis out    BOY!!",-1,"      "
	dc.b	"        this is a"
	dc.b	" demo of the demo.....      EL HOMBRE    "
	dc.b	" BYE!!!!!!!......."
	dc.b	0
	even
font:
	DC.W	0,0,0,0
	DC.W	$183C,$66C3,$E724,$243C
	DC.W	$3C24,$24E7,$C366,$3C18
	DC.W	$181C,$F683,$83F6,$1C18
	DC.W	$1838,$6FC1,$C16F,$3818
	DC.W	$FF81,$BDA5,$A5BD,$81FF
	DC.W	$F88F,$89F9,$4141,$7F00
	DC.W	$FF89,$89F9,$8181,$81FF
	DC.W	$103,$68C,$D870,$2000
	DC.W	$7EC3,$D3D3,$DBC3,$C37E
	DC.W	$183C,$3C3C,$7E10,$3810
	DC.W	$181C,$1610,$1070,$F060
	DC.W	$F0C0,$FED8,$DE18,$1800
	DC.W	$F0C0,$DFDB,$FF1E,$1B00
	DC.W	$505,$50D,$D19,$7971
	DC.W	$A0A0,$A0B0,$B098,$9E8E
	DC.W	$7CC6,$C600,$C6C6,$7C00
	DC.W	$606,$600,$606,$600
	DC.W	$7C06,$67C,$C0C0,$7C00
	DC.W	$7C06,$67C,$606,$7C00
	DC.W	$C6C6,$C67C,$606,$600
	DC.W	$7CC0,$C07C,$606,$7C00
	DC.W	$7CC0,$C07C,$C6C6,$7C00
	DC.W	$7C06,$600,$606,$600
	DC.W	$7CC6,$C67C,$C6C6,$7C00
	DC.W	$7CC6,$C67C,$606,$7C00
	DC.W	0,$3C06,$7E66,$3C00
	DC.W	$7860,$7860,$7E18,$1E00
	DC.W	$70F,$1F18,$1810,$1E17
	DC.W	$F0F8,$EC04,$404,$3C54
	DC.W	$110B,$D06,$72E,$3938
	DC.W	$428,$D828,$D010,$E000
	DC.W	0,0,0,0
	DC.W	$1818,$1818,$1800,$1800
	DC.W	$6666,$6600,0,0
	DC.W	$6C,$FE6C,$6CFE,$6C00
	DC.W	$287E,$A87C,$2AFC,$2800
	DC.W	$6396,$6C18,$3669,$C600
	DC.W	$78CC,$61CE,$CCCC,$7800
	DC.W	$1818,$1000,0,0
	DC.W	$408,$1818,$1808,$400
	DC.W	$2010,$1818,$1810,$2000
	DC.W	$1054,$38FE,$3854,$1000
	DC.W	$18,$187E,$1818,0
	DC.W	0,0,$30,$3020
	DC.W	0,$7E,0,0
	DC.W	0,0,$18,$1800
	DC.W	$206,$C18,$3060,$4000
	DC.W	$3C66,$6E76,$6666,$3C00
	DC.W	$1838,$1818,$1818,$1800
	DC.W	$3C66,$60C,$1830,$7E00
	DC.W	$7E0C,$180C,$666,$3C00
	DC.W	$C1C,$3C6C,$7E0C,$C00
	DC.W	$7E60,$7C06,$666,$3C00
	DC.W	$3C60,$607C,$6666,$3C00
	DC.W	$7E06,$C18,$3030,$3000
	DC.W	$3C66,$663C,$6666,$3C00
	DC.W	$3C66,$663E,$60C,$3800
	DC.W	$18,$1800,$1818,0
	DC.W	$18,$1800,$1818,$1000
	DC.W	$60C,$1830,$180C,$600
	DC.W	0,$7E00,$7E,0
	DC.W	$6030,$180C,$1830,$6000
	DC.W	$3C66,$60C,$1800,$1800
	DC.W	$3C66,$6E6A,$6E60,$3E00
	DC.W	$3C66,$667E,$6666,$6600
	DC.W	$7C66,$667C,$6666,$7C00
	DC.W	$3C62,$6060,$6062,$3C00
	DC.W	$7C66,$6666,$6666,$7C00
	DC.W	$7E60,$607C,$6060,$7E00
	DC.W	$7E60,$607C,$6060,$6000
	DC.W	$3C62,$606E,$6666,$3E00
	DC.W	$6666,$667E,$6666,$6600
	DC.W	$1818,$1818,$1818,$1800
	DC.W	$606,$606,$646,$3C00
	DC.W	$666C,$7870,$786C,$6600
	DC.W	$6060,$6060,$6060,$7E00
	DC.W	$FEDB,$DBDB,$DBDB,$DB00
	DC.W	$6676,$7E7E,$6E66,$6600
	DC.W	$3C66,$6666,$6666,$3C00
	DC.W	$7C66,$667C,$6060,$6000
	DC.W	$3C66,$6666,$6666,$3C06
	DC.W	$7C66,$667C,$6666,$6600
	DC.W	$3C62,$703C,$E46,$3C00
	DC.W	$7E18,$1818,$1818,$1800
	DC.W	$6666,$6666,$6666,$3C00
	DC.W	$6666,$6666,$666C,$7800
	DC.W	$DBDB,$DBDB,$DBDA,$FC00
	DC.W	$6666,$663C,$6666,$6600
	DC.W	$6666,$663C,$1818,$1800
	DC.W	$7E06,$C18,$3060,$7E00
	DC.W	$1E18,$1818,$1818,$1E00
	DC.W	$4060,$3018,$C06,$200
	DC.W	$7818,$1818,$1818,$7800
	DC.W	$1038,$6CC6,0,0
	DC.W	0,0,0,$FE00
	DC.W	$C0,$6030,0,0
	DC.W	0,$3C46,$3E66,$3E00
	DC.W	$6060,$7C66,$6666,$7C00
	DC.W	0,$3C60,$6060,$3C00
	DC.W	$606,$3E66,$6666,$3E00
	DC.W	0,$3C66,$7E60,$3C00
	DC.W	$1E30,$7C30,$3030,$3000
	DC.W	0,$3E66,$663E,$463C
	DC.W	$6060,$7C66,$6666,$6600
	DC.W	$1800,$1818,$1818,$1800
	DC.W	$C00,$C0C,$C0C,$4C38
	DC.W	$6060,$666C,$786C,$6600
	DC.W	$3030,$3030,$3030,$3000
	DC.W	0,$FEDB,$DBDB,$DB00
	DC.W	0,$7C66,$6666,$6600
	DC.W	0,$3C66,$6666,$3C00
	DC.W	0,$7C66,$6666,$7C60
	DC.W	0,$3E66,$6666,$3E06
	DC.W	0,$6C70,$6060,$6000
	DC.W	0,$3E60,$3C06,$7C00
	DC.W	$18,$3C18,$1818,$C00
	DC.W	0,$6666,$6666,$3E00
	DC.W	0,$6666,$6664,$7800
	DC.W	0,$DBDB,$DBDA,$FC00
	DC.W	0,$6666,$3C66,$6600
	DC.W	0,$6666,$663E,$463C
	DC.W	0,$7E0C,$1830,$7E00
	DC.W	$E18,$1830,$1818,$E00
	DC.W	$1818,$1818,$1818,$1818
	DC.W	$7018,$180C,$1818,$7000
	DC.W	$60,$F29E,$C00,0
	DC.W	$18,$1834,$3462,$7E00
	DC.W	$3C,$6660,$663C,$838
	DC.W	$6600,$66,$6666,$3E00
	DC.W	$C18,$3C,$7E60,$3C00
	DC.W	$1866,$3C,$67E,$3E00
	DC.W	$6600,$3C06,$3E66,$3E00
	DC.W	$3018,$3C,$67E,$3E00
	DC.W	$1818,$3C,$67E,$3E00
	DC.W	0,$3C60,$603C,$818
	DC.W	$1866,$3C,$7E60,$3C00
	DC.W	$6600,$3C66,$7E60,$3C00
	DC.W	$3018,$3C,$7E60,$3C00
	DC.W	$6600,$38,$1818,$3C00
	DC.W	$1866,$38,$1818,$3C00
	DC.W	$6030,$38,$1818,$3C00
	DC.W	$6600,$183C,$667E,$6600
	DC.W	$1800,$183C,$667E,$6600
	DC.W	$C18,$7E60,$7C60,$7E00
	DC.W	0,$7E1B,$7FD8,$7E00
	DC.W	$3F78,$D8DE,$F8D8,$DF00
	DC.W	$1866,$3C,$6666,$3C00
	DC.W	$6600,$3C,$6666,$3C00
	DC.W	$3018,$3C,$6666,$3C00
	DC.W	$1866,$66,$6666,$3E00
	DC.W	$3018,$66,$6666,$3E00
	DC.W	$6600,$6666,$663E,$67C
	DC.W	$6600,$3C66,$6666,$3C00
	DC.W	$6600,$6666,$6666,$3E00
	DC.W	$1818,$3C60,$603C,$1818
	DC.W	$1C3A,$307C,$3030,$7E00
	DC.W	$6666,$3C18,$3C18,$1800
	DC.W	$1C36,$667C,$6666,$7C60
	DC.W	$1818,$1818,$1818,$1818
	DC.W	$C18,$3C,$67E,$3E00
	DC.W	$C18,$38,$1818,$3C00
	DC.W	$C18,$3C,$6666,$3C00
	DC.W	$C18,$66,$6666,$3E00
	DC.W	$3458,$7C,$6666,$6600
	DC.W	$3458,$66,$766E,$6600
	DC.W	$3C,$63E,$663E,$3C
	DC.W	$3C,$6666,$663C,$3C
	DC.W	$18,$18,$3060,$663C
	DC.W	0,$3E,$3030,$3000
	DC.W	0,$7C,$C0C,$C00
	DC.W	$C6CC,$D836,$6BC3,$860F
	DC.W	$C6CC,$D836,$6ED6,$9F06
	DC.W	$18,$18,$1818,$1818
	DC.W	$1B36,$6CD8,$6C36,$1B00
	DC.W	$D86C,$361B,$366C,$D800
	DC.W	$3458,$3C,$67E,$3E00
	DC.W	$3458,$3C,$6666,$3C00
	DC.W	$23C,$666E,$7666,$3C40
	DC.W	2,$3C6E,$7666,$3C40
	DC.W	$1818,$1818,$F818,$1818
	DC.W	$1818,$F818,$F818,$1818
	DC.W	$3636,$3636,$F636,$3636
	DC.W	0,$FE6C,$6C6C,$6C00
	DC.W	0,$F818,$F818,$1818
	DC.W	$3636,$F606,$F636,$3636
	DC.W	$3636,$3636,$3636,$3636
	DC.W	0,$FE06,$F636,$3636
	DC.W	$3636,$F606,$FE00,0
	DC.W	$1818,$F818,$F800,0
	DC.W	$1818,$F818,$F800,0
	DC.W	0,0,$F818,$1818
	DC.W	$1818,$1818,$1F00,0
	DC.W	$1818,$1818,$FF00,0
	DC.W	0,0,$FF18,$1818
	DC.W	$1818,$1818,$1F18,$1818
	DC.W	0,0,$FF00,0
	DC.W	$1818,$1818,$FF18,$1818
	DC.W	$1818,$1F18,$1F18,$1818
	DC.W	$3636,$3636,$3736,$3636
	DC.W	$3636,$3730,$3F00,0
	DC.W	0,$3F30,$3736,$3636
	DC.W	$3636,$F700,$FF00,0
	DC.W	0,$FF00,$F736,$3636
	DC.W	$3636,$3730,$3736,$3636
	DC.W	0,$FF00,$FF00,0
	DC.W	$3636,$F700,$F736,$3636
	DC.W	$1818,$FF00,$FF00,0
	DC.W	$3636,$3636,$FF00,0
	DC.W	0,$FF00,$FF18,$1818
	DC.W	0,0,$FF36,$3636
	DC.W	$3636,$3636,$3F00,0
	DC.W	$3030,$3F30,$3F00,0
	DC.W	0,$3F30,$3F30,$3030
	DC.W	0,0,$7F6C,$6C6C
	DC.W	$3636,$3636,$FF36,$3636
	DC.W	$1818,$FF18,$FF18,$1818
	DC.W	$1818,$1818,$F800,0
	DC.W	0,0,$1F18,$1818
	DC.W	$FF,$FFFF,$FFFF,$FF00
	DC.W	0,0,$FFFF,$FF00
	DC.W	$E1B,$3C66,$663C,$D870
	DC.W	$10,$386C,$C682,0
	DC.W	$66F7,$9999,$EF66,0
	DC.W	0,$76DC,$C8DC,$7600
	DC.W	$1C36,$667C,$6666,$7C60
	DC.W	$FE,$6662,$6060,$60F8
	DC.W	0,$FE6C,$6C6C,$6C48
	DC.W	$FE66,$3018,$3066,$FE00
	DC.W	$1E,$386C,$6C6C,$3800
	DC.W	0,$6C6C,$6C6C,$7FC0
	DC.W	0,$7E18,$1818,$1810
	DC.W	$3C18,$3C66,$663C,$183C
	DC.W	$3C,$667E,$6666,$3C00
	DC.W	$3C,$6666,$6624,$6600
	DC.W	$1C36,$78DC,$CCEC,$7800
	DC.W	$C18,$3854,$5438,$3060
	DC.W	$10,$7CD6,$D6D6,$7C10
	DC.W	$3E70,$607E,$6070,$3E00
	DC.W	$3C66,$6666,$6666,$6600
	DC.W	$7E,$7E,$7E,0
	DC.W	$1818,$7E18,$1800,$7E00
	DC.W	$3018,$C18,$3000,$7E00
	DC.W	$C18,$3018,$C00,$7E00
	DC.W	$E,$1B1B,$1818,$1818
	DC.W	$1818,$1818,$D8D8,$7000
	DC.W	$1818,$7E,$18,$1800
	DC.W	$32,$4C00,$324C,0
	DC.W	$386C,$3800,0,0
	DC.W	$387C,$3800,0,0
	DC.W	0,0,$1818,0
	DC.W	0,$F18,$D870,$3000
	DC.W	$386C,$6C6C,$6C00,0
	DC.W	$386C,$1830,$7C00,0
	DC.W	$780C,$380C,$7800,0
	DC.W	$FE,0,0,0
music:					*** put your mad max here.
	rept	16
	rts
	endr
;	incbin	d:\gamem.img
precal_buff:
	ds.b	$4000