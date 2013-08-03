start     move.l    a7,a5
          lea       stack,a7
          move.l    4(a5),a5     
          move.l    $c(a5),d0    
          add.l     $14(a5),d0
          add.l     $1c(a5),d0
          add.l     #$100,d0
          move.l    d0,-(sp)
          move.l    a5,-(sp)
          move      #0,-(sp)
          move      #$4a,-(sp)
          trap      #1
          add.l     #12,sp
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	add.l	#6,sp
	move.l	d0,oldsp
	lea	$ff8240,a0
	lea	shiftc,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	jsr	clrc
	dc.W	$a00a
	pea	cls
	move.w	#9,-(sp)
	trap	#1
	add.l	#6,sp
	move.b	$ff8260,shiftr
	and.b	#$01,shiftr
	cmp.b	#$02,$ff8260
	beq	out1
	cmp.b	#$01,$ff8260
	bne 	on1
on1	move.b	$ff820a,shifts
	move.b	#$02,$ff820a
	move.w	#0,-(sp)
	move.l	#$f8000,-(sp)
	move.l	#$f8000,-(sp)
	move.w	#$05,-(sp)
	trap	#14
	add.l	#12,sp
	bsr	dec_fnts
	;bsr	set_fnts
	;jsr	dec_sp
	jsr	set_sp
	jsr	set_sm
	jsr	set_sm2
	pea	keyoff
	move.w	#0,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	add.l	#8,sp
	move.l	#$f8000,stcr
	move.l	#s0dat,stamp
	bsr	dnsp
	lea	fonts+2,a1
	jsr	loadc
key	move.l	#$f8000+32*1024,stcr
	move.l	#s2dat,stamp
	bsr	dnsp
	bsr	newsc
	move.l	#s0dat,stamp
	bsr	cnsp
	move.l	#$f8000,stcr
	move.l	#s0dat,stamp
	bsr	dnsp
	bsr	newsc
	move.l	#s2dat,stamp
	bsr	cnsp

	move.w	#$ff,-(sp)
	move.w	#$06,-(sp)
	trap	#1
	add.l	#4,sp
	cmp.b	#$1b,d0
	beq	off1
	jmp	key
off1	jsr	clrc
	move.b	shiftr,d0
	and.w	#$01,d0
	move.w	d0,-(sp)
	move.l	#$f8000,-(sp)
	move.l	#$f8000,-(sp)
	move.w	#$05,-(sp)
	trap	#14
	add.l	#12,sp
	pea	keyon
	move.w	#0,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	add.l	#8,sp
out	pea	cls
	move.w	#9,-(sp)
	trap	#1
	add.l	#6,sp
	move.l	shifts,$ff820a
	move.l	shiftr,$ff8260
	move.w	shiftr,$44c
	move.l	#shiftc,a1
	jsr	loadc
out1	move.l	oldsp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	add.l	#6,sp
	dc.w	$a009
	clr.w	-(sp)
	trap	#1

newsc	move.l	stcr,d0
	asr.l	#8,d0
	move.b	d0,$ff8203
	asr.l	#8,d0
	move.b	d0,$ff8201
	jsr	vsync
	rts

cls	dc.b	27,'E',0
pal0	dc.w	$000,$444,$555,$666,$707,$777,$774,$770
	dc.w	$757,$453,$466,$722,$755,$676,$707,$777
keyon	dc.b	$08,0
keyoff	dc.b	$12,0	
	ds.w	256
stack	ds.l	1
oldsp	ds.l	1																			
shiftc	ds.w	16
shiftr	ds.w	1
shifts	ds.w	1
nspr	ds.l	1
inds2	ds.l	1
stamp	ds.l	1
stcr	ds.l	1

dnsp	add.w	#8,inds2
fuck	move.w	inds2,inds1
	cmp.w	#2512,inds2
	blt	dnsp0
	sub.w	#2512,inds2
	jmp	fuck
dnsp0	move.w	#18,nspr
dnsp1	subq.w	#1,nspr
	move.w	nspr,d0
	lsl.w	#2,d0
	lea	s1dat,a0
	move.l	stamp,a2
	move.l	(a0,d0),a0
	move.l	(a2,d0),a2
	move.w	#7,d2
	bsr	ani
	tst.w	nspr
	bne	dnsp1
	rts

cnsp	move.w	#0,nspr
cnsp1	move.w	nspr,d0
	lsl.w	#2,d0
	move.l	stamp,a0
	move.l	(a0,d0),a0
	bsr	clrs
	addq.w	#1,nspr
	cmp.w	#17*4-1,d0
	ble	cnsp1
	rts

ani	move.w	inds1,d5
	lea	cy,a5
	lea	cx,a6
	move.w	(a5,d5),d0
	move.w	(a6,d5),d1
	add.w	#32,inds1
	cmp.w	#2512,inds1
	blt	go
	sub.w	#2512,inds1
go	bsr	showsp
	rts		

showsp	and.l     #511,d0
          and.l     #511,d1
          mulu      #160,d0
          move      d1,d7
          lsr       #1,d1
          add       d1,d0
          add.l     stcr,d0
          and.b     #$f8,d0
          move.l    d0,a1
          move.l    a1,(a2)+
          and.l     #15,d7
          move      d2,d6
sp1       moveq     #0,d0
          moveq     #0,d1
          moveq     #0,d2
          moveq     #0,d3
          move      (a0)+,d0
          move      (a0)+,d1
          move      (a0)+,d2
          move      (a0)+,d3
          move.l    d0,d4
          or.l      d1,d4
          or.l      d2,d4
          or.l      d3,d4
          not.l     d4
          ror.l     d7,d0
          ror.l     d7,d1
          ror.l     d7,d2
          ror.l     d7,d3
          ror.l     d7,d4
          move.w    (a1),(a2)+
          and       d4,(a1)
          or        d0,(a1)+
          move.w    (a1),(a2)+
          and       d4,(a1)
          or        d1,(a1)+
          move.w    (a1),(a2)+
          and       d4,(a1)
          or        d2,(a1)+
          move.w    (a1),(a2)+
          and       d4,(a1)
          or        d3,(a1)+
          swap      d0
          swap      d1
          swap      d2
          swap      d3
          swap      d4
          move.w    (a1),(a2)+
          and       d4,(a1)
          or        d0,(a1)+
          move.w    (a1),(a2)+
          and       d4,(a1)
          or        d1,(a1)+
          move.w    (a1),(a2)+
          and       d4,(a1)
          or        d2,(a1)+
          move.w    (a1),(a2)+
          and       d4,(a1)
          or        d3,(a1)+
          add.w     #144,a1
	add.w	#152,a0
          dbf       d6,sp1
          rts

clrs	move.l    (a0)+,a1
          moveq.w    #7,d2
sp2       move.l    (a0)+,(a1)+
          move.l    (a0)+,(a1)+
          move.l    (a0)+,(a1)+
          move.l    (a0)+,(a1)+
          add.w     #144,a1
          dbra	d2,sp2
          rts

dec_fnts	lea	fonts+34,a4
	lea	stk0,a0
	lea	stk1,a1
	lea	stk2,a2
	lea	stk3,a3
	bsr	step_on
	lea	stk0,a0
	lea	stk1,a1
	lea	stk2,a2
	lea	stk3,a3
	move.l	#$60000,a4
	move.w	#3999,d0
	bsr	step_off
	rts
step_on	move.w	#199,d0
step_on1	move.l	a0,a5
	bsr	step10
	move.l	a5,a0
	move.l	a1,a5
	bsr	step10
	move.l	a5,a1
	move.l	a2,a5
	bsr	step10
	move.l	a5,a2
	move.l	a3,a5
	bsr	step10
	move.l	a5,a3
	dbra	d0,step_on1
	rts
step10	clr.b	d1
step20	cmp.b	#40,d1
	beq	step_off1
	move.b	(a4)+,d2
	tst.b	d2
	blt	yin	
	addq.b	#1,d2
step30	move.b	(a4)+,(a5)+
	addq.b	#1,d1
	subq.b	#1,d2
	tst.b	d2
	bgt	step30
	bra	step20
yin	neg.b	d2
	addq.b	#1,d2
	move.b	(a4)+,d3
yin1	move.b	d3,(a5)+
	addq.b	#1,d1
	subq.b	#1,d2
	bgt	yin1
	bra	step20
step_off1	rts
step_off	move.w	(a0)+,(a4)+	
	move.w	(a1)+,(a4)+	
	move.w	(a2)+,(a4)+	
	move.w	(a3)+,(a4)+	
	dbra	d0,step_off
	rts

set_fnts	move.w	#5,d0
	lea	fdat,a0
	move.l	#$60000,d2
setf1	move.w	#9,d1
setf2	move.l	d2,(a0)+
	add.w	#16,d2
	dbra	d1,setf2
	add.w	#160*19,d2
	dbra	d0,setf1
	rts

set_sp	lea	s1dat,a0
	move.l	#$60000,d2
	move.w	#19,d1
wr_sp	move.l	d2,(a0)+
	add.w	#8,d2
	dbra	d1,wr_sp
	rts

set_sm	move.w	#1,d0
	lea	s0dat,a0
	move.l	#$60000+18000,d2
wr_sm1	move.w	#20,d1
wr_sm	move.l	d2,(a0)+
	add.w	#9*16,d2
	dbra	d1,wr_sm
	rts
set_sm2	move.w	#1,d0
	lea	s2dat,a0
	move.l	#$60000+26000,d2
wr_sm12	move.w	#20,d1
wr_sm2	move.l	d2,(a0)+
	add.w	#9*16,d2
	dbra	d1,wr_sm2
	rts
s0dat	ds.l	80
s1dat	ds.l	80
s2dat	ds.l	80

inds1	ds.l	1

cx	incbin	c7x.bin
cy	incbin	c9y.bin
rsp	ds.l	1

loadc	move.w	#$000,rock
	move.l	a1,rsp
	move.w	#6,d0
	bsr	vsync
apc	add.w	#$111,rock
	move.l	#$ff8240,a0
	move.l	rsp,a1
	move.w	#15,d1
col0	move.w	rock,rock1
	move.w	(a1)+,d3
	and.w	d3,rock1
	move.w	rock1,(a0)+
	dbra	d1,col0
	bsr	wst
	dbra	d0,apc
	rts

clrc	move.w	#$888,rock
	move.w	#6,d0
	bsr	vsync
apc1	sub.w	#$111,rock
	move.l	#stack-256,a1
	move.l	#$ff8240,a0
	move.l	#rock1,a2
	move.w	#15,d1
col1	move.w	rock,rock1
	move.w	rock1,d7
	move.w	(a0),d5
	and.w	d7,d5
	move.w	d5,(a0)+
	dbra	d1,col1
	bsr	wst
	dbra	d0,apc1
	rts

rock2	ds.l	1
rock	ds.l	1
rock1	ds.l	1

oldr0	ds.l	1
vsync	move.l	d0,oldr0
	move.l	$462,d0
npage	cmp.l	$462,d0
	beq	npage
	move.l	oldr0,d0
	rts

wst	move.w	#1,d6
wst0	bsr	vsync
	dbra	d6,wst0
	rts

	even
fonts	incbin	sp2.pc1
	even

	section	bss
stk0	ds.l	2000
stk1	ds.l	2000
stk2	ds.l	2000
stk3	ds.l	2000
fdat	ds.w	200

	end	
