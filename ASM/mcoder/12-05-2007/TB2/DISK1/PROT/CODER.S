	opt	x+
	output	.tos
Protect1:
  ;#[ Trace Pass Start:
Top:	clr.l	-(a7)
	move	#$20,-(a7)
	trap	#1
	addq	#6,a7
	move	#$2700,sr
	lea	Start(pc),a0
	lea	$400.w,a1
	move	#(End0-Start)/4,d0
.Loop	move.l	(a0)+,(a1)+
	dbf	d0,.Loop

	lea	End0+$1c(pc),a0
	move	#$29a,d0
.Xor2:	move.l	(a0)+,d1 
	eor.l	d1,(a0)
	dbf	d0,.Xor2

	move.l	$24.w,Adebug_trace+2
	move.l	#$e53840ec,d6
	move.l	#$400,$08.w
	move.l	#$48e,$0c.w
	move.l	#$4ae,$10.w
	move.l	#$4c4,$14.w
	move.l	#$4d0,$18.w
	move.l	#$4fe,$1c.w
	move.l	#$508,$20.w
	move.l	#$50e,$24.w
	move.l	#$54a,$28.w
	move.l	#$552,$2c.w
	move.l	#New_trace,$24.w
Bkpt:	move	#$a700,sr
	bra	Decoder
	dc.l	0,0,0

New_trace:	movem.l	d0/a0-a1,$74.w
	lea	Preview2(pc),a1
	move.l	(a1)+,a0
	move.l	(a1)+,d0
	addq.l	#1,(a1)
	eor.l	d0,(a0)+
	eor.l	d0,(a0)+
	eor.l	d0,(a0)
	move.l	a7,a0
	or	#$700,(a0)+
	move.l	d6,-(a1)
	move.l	(a0),a0
	move.l	a0,-(a1)
	eor.l	d6,(a0)+
	eor.l	d6,(a0)+
	eor.l	d6,(a0)
	move	#$70,a0
	clr.l	(a0)+
	movem.l	(a0),d0/a0-a1
Adebug_trace:	jmp	$09000000
Preview2:	dc.l	Dummy2,0,0
Dummy2:	dc.l	0,0,0

	move	#$50e,$26.w
	moveq	#0,d6
Trace:	move	#$a700,sr
	move.l	#$2314,d7
	move.l	#$4ae,$10.w
	addq	#1,$ffff8240.w
	illegal	illegal
	dc.l	$abcdef	d6=$abcdef
	moveq	#1,d4
	dc.l	$2157cdef	
	dc.l	$0425cde3	move.l	#$48e,$0c.w
	dc.l	$3097cf76	move	#$299,d0
	dc.l	$4151ce35	lea	End0(pc),a0
	dc.l	$4351cf87	lea	Start(pc),a1
.Loop:	dc.w	$2273	move.l	(a0)+,(a1)+
	dc.l	$51633213	dbf	d0,.Loop
	dc.l	$3c91ccb5	move	Handler(pc),d6
	dc.w	$462d	not.l	d6
	dc.l	$beaefeaf	lea	Wait(pc),a0	tst vbl rout
.Pause:	dc.w	$b504	tst	(a0)
	dc.w	$98a8	beq.s	.Pause
	dc.l	$de90fa91	move.l	d4,$568.w
	dc.w	$b5a8	illegal	illegal error
	dc.l	$950d92b1	dc.l	$6af46de5
	dc.w	$bb7f	neg.l	d6
	dc.l	$d3f7151b	move	#$8700,sr
	dc.l	$d772921c
	dc.w	$9af4	clr	$70fff	address error
	dc.l	$b3e3950b
	dc.w	$923f	move.l	0.w,$24.w   bus error
	dc.w	$0	Dummy
	dc.w	$fa8c	trapv	nothing
	dc.w	$f43a	move	sr,d0
	dc.l	$bebacef2	eor	#$8002,d0
	dc.w	$f23a	move	d0,sr
	dc.w	$fa8c	trapv	trapv error
	dc.l	$62c9b4fa
	dc.w	$5632	move.l	$18c2,d6	no vblrout
	dc.l	$0a861237
	dc.w	$5678	eor.l	#$12345678,d6
Strange:	dc.w	$6235	moveq	#1,d0
	dc.w	$6035	moveq	#1,d1
	dc.w	$6635	moveq	#1,d2
.Loop0:	dc.w	$d375	exg	d0,d1
	dc.w	$c675	add	d1,d2
	dc.l	$43fe566b	dbf	d2,.Exit
.Loop1:	dc.w	$d176	exg	d1,d2
	dc.l	$10755674	andi	#$f,d1
.Loop2:	dc.w	$d774	exg	d2,d0
	dc.w	$4076	addq	#1,d2
	dc.l	$43fca997	dbf	d0,.Loop0
.Exit:	dc.l	$43fda98b	dbf	d1,.Loop1	d0=4 d2=7
	dc.w	$2c34	move	d0,d7	.w !
	dc.w	$5a74	swap	d0
	dc.w	$2236	move	d2,d0
	dc.w	$faac	ror.l	#4,d0
	dc.w	$3e34	move.l	d0,d6	d6=$70004000
	dc.l	$5a384568	move.l	$568.w,d5	Check
	dc.w	$cb87	eor.l	d5,d7
	dc.w	$cf86	eor.l	d7,d6
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	d6=e53840ec
Decoder:	dc.l	$a4c24104	lea	Start(pc),a0
	dc.w	$cf3e	move.l	d6,d5
	dc.w	$913b	moveq	#3,d2	decode ~3k-bytes
.Code0:	dc.l	$a6c044ec	lea	$400.w,a1
	dc.w	$956f	moveq	#$57,d0
.Code1:	dc.w	$c721	move.l	(a1)+,d1
	dc.w	$56a0	eor.l	d1,(a0)+
	dc.l	$b4f0bf16	dbf	d0,.Code1
	dc.w	$afc4	illegal
	dc.l	$e5848f6b	dc.l	$a5686a53
	dc.l	$03161a0a	lea	Trace(pc),a1
	dc.w	$d52b	moveq	#$43,d0
.Code2:	dc.w	$8771	move.l	(a1)+,d1
	dc.w	$16f0	eor.l	d1,(a0)+
	dc.l	$f4a095a9	dbf	d0,.Code2
	dc.l	$e6906a5b	lea	8.w,a1
	dc.w	$d561	moveq	#9,d0
.Code3:	dc.w	$8771	move.l	(a1)+,d1
	dc.w	$16f0	eor.l	d1,(a0)+
	dc.l	$f4a095a9	dbf	d0,.Code3
	dc.w	$896d	move.l	d5,d6
	dc.l	$b4f2bf20	dbf	d2,.Code0
	dc.w	$b77a	addq	#1,d2
	dc.w	$65fa	divu	d2,d0
Strange2:	moveq	#8,d0	(xor-coded 2 times)
	dc.w	$020f	moveq	#$f,d1	d6=$7000bfff
	dc.w	$040f	moveq	#$f,d2	d7=$db494e9d
	dc.w	$060f	moveq	#$f,d3
.Jmp0:	dc.w	$b342	exg	d1,d2
	dc.w	$c143	eor	d0,d3
	dc.w	$2443	addq	#2,d3
	dc.l	$21c8bff3	dbf	d0,.Jmp2
.Jmp1:	dc.w	$b143	exg	d0,d3
	dc.w	$c141	eor	d0,d1
	dc.w	$2440	addq	#2,d0
	dc.l	$21c9bff3	dbf	d1,.Jmp3
.Jmp2:	dc.w	$b141	exg	d0,d1
	dc.w	$c342	eor	d1,d2
	dc.w	$2441	addq	#2,d1
	dc.l	$21ca401b	dbf	d2,.Jmp0
.Jmp3:	dc.w	$b543	exg	d2,d3
	dc.w	$c543	eor	d2,d3
	dc.w	$2442	addq	#2,d2
	dc.l	$21cb401b	dbf	d3,.Jmp1
	dc.l	$5c38ba97	move.l	$568.w,d6	d6=$1bf80
	dc.l	$0647a978	add	#$16f8,d6
	dc.w	$bf87	eor.l	d7,d6	d7=$db494e9d
	dc.l	$9cf4671b	chk	#-2,d3
Pass2:	lea	Term(pc),a0	d6=$db4157ec
	dc.w	$ab57	moveq	#(Start-Term)/4-1,d0
.Xor1:	dc.w	$64d9	eor.l	d7,(a0)+
	dc.l	$8a89a810	dbf	d0,.Xor1	
	dc.l	$9abb56b0	lea	Start(pc),a0
	dc.w	$f959	move.l	(a0)+,d1
	dc.l	$eb7d5575	move	#$299,d0
.Xor2:	dc.w	$ff51	move.l	(a0),d2
	dc.w	$68d9	eor.l	d1,(a0)+
	dc.w	$f943	move.l	d2,d1
	dc.l	$8a89a814	dbf	d0,.Xor2
Illegal:	dc.w	$9c41	dc.w	$4700	Illegal
	dc.l	$57ecdb41	dc.l	0	d6=0
	dc.l	$4e1fde41	dc.l	$19f30500	Illegal
	dc.w	$031a	dc.w	$54f6
	dc.l	$167a895e	Illegal
	dc.w	$2642
	dc.l	$08bc0310	Illegal
	dc.w	$0fe4
	dc.w	$7922	Illegal
	dc.l	$f16a65ef
	dc.w	$29de	Illegal
	dc.l	$64ed2ad0
	dc.w	$4f4f	Illegal
	dc.l	$ec5da6d4
	dc.w	$7fff	Illegal
	dc.l	$0024061d
	dc.l	$000a65d2	Illegal
	dc.w	$8461
	;clr	$10420
	move	d4,d4
	dc.l	$232ea361	move	#$2700,sr
	dc.l	$05d284cf	bra	Term
	dc.l	$000b0000	illegal
	dc.w	$46e4
  ;#] Trace Pass Start:
  ;#[ Raster Routines:
Handler:	dc.w	0
Wait:	dc.w	0
Blank:	dc.l	0
Vector:	ds.l	10
	dc.b	"may the force be with you."
	even

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Vbl:	move.l	a0,-(a7)
	clr.b	$fffffa1b.w
.Sync:	move.b	#1,$fffffa21.w
	cmp.b	#1,$fffffa21.w
	bne.s	.Sync
	move.b	#8,$fffffa1b.w
	clr	$ffff8240.w
	lea	Wait(pc),a0
	addq	#1,(a0)
	move.l	(a7)+,a0
Endvbl:	rte

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Border:	move.l	d0,-(a7)
	clr.b	$fffffa1b.w
.New_col:	move.b	#8,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.b	$fffffa21.w,d0
.Wait0:	cmp.b	$fffffa21.w,d0
	beq.s	.Wait0
	addq	#1,$568.w
	addq	#1,$56c.w
	move.l	(a7)+,d0
	move	#$13,$fffffc00.w
	bclr	#0,$fffffa0f.w
	rte	d7=$db494e9d
  ;#] Raster Routines:
  ;#[ Terminal Process:
Term:	incbin	Term.cod
  ;#] Terminal Process:
  ;#[ Irrupts Routines:
Start:
Buserr:	movem.l	d0-d1/a0,-(a7)
	move.l	#$400,$08.w
	move.l	#$48e,$0c.w
	move.l	#$4ae,$10.w
	move.l	#$4c4,$14.w
	move.l	#$4d0,$18.w
	move.l	#$4fe,$1c.w
	move.l	#$508,$20.w
	move.l	#$50e,$24.w
	move.l	#$54a,$28.w
	move.l	#$552,$2c.w
	move	12(a7),d0
	move	#-1,12(a7)
	move.l	22(a7),14(a7)
	ext.l	d0
	swap	d0
	lea	Buserr(pc),a0
	addq	#1,Check-Buserr(a0)
	move	#(Chkend-Start)/4,d0
	moveq	#0,d1
.Sum:	add.l	(a0)+,d1
	dbf	d0,.Sum
	eor.l	#$4e714e71,d7	test sigma
	eor.l	d0,d1
	eor.l	d1,d6
	eor.l	d7,d6
	;eor.l	d0,d6
	;eor.l	d7,d6
	;eor.l	#$4e714e71,d7	test sigma
	movem.l	(a7)+,d0-d1/a0
	rte
Adrerr:	move.l	#$400,$08.w
	move.l	#$50e,$24.w
	addq	#8,a7
	move.b	#$13,$fffffc00.w
	clr.b	$fffffa09.w
	rte
	dc.w	$c0de
Illerr:	movem.l	a0,-(a7)
	move.l	6(a7),a0
	move.l	2(a0),d6
	addq.l	#6,6(a7)
	movem.l	(a7)+,a0
	rte
Diverr:	dc.w	$a37e	not	d6
	dc.w	$ff6a	eor.l	d7,d6
	dc.l	$efbf0e9d
	dc.w	$ab49	eor.l	#$4e714e71,d7
	dc.w	$0e9f	rte
Chkerr:	dc.l	$93af1865	movem.l	d0/a0,-(a7)	
	dc.l	$9ab263cf	lea	Start-$400(pc),a0
	dc.l	$d1ce98ec
	dc.w	$cf09	eor.l	#$9cf09,d6

	;rept	6
	;dc.w	$9539
	;endr
	;moveq	#0,d0
	;lsr.l	d0,d6
	;andi	#$f,d6
	;subq	#1,d6
	;lea	$ff000,a0
.Howmany:	;st	(a0)
	;lea	-480(a0),a0
	;dbf	d6,.Howmany

	move.l	a0,d0
	bne	Buserr
Here:	lea	Here(pc),a0
	move.l	a0,d0
	swap	d0
	tst	d0
	bne	Lnferr
	movem.l	(a7)+,d0/a0
	move.b	#3,$ffff820a.w
	;move	#$777,$ffff825e.w
	rte
Trverr:	swap	d6
	rol.l	d6,d7
	move	#$a700,(a7)
	rte
Reserr:	swap	d7
	ror.l	d7,d6
	rte
Trcerr:	movem.l	d0/a0-a1,$74.w
	clr.l	$fffffa06.w
	lea	Preview(pc),a1
	move.l	(a1)+,a0
	move.l	(a1)+,d0
	addq.l	#1,(a1)
	clr.l	$fffffa12.w
	eor.l	d0,(a0)+
	eor.l	d0,(a0)+
	eor.l	d0,(a0)
	move.l	a7,a0
	or	#$700,(a0)+
	move.l	d6,-(a1)
	move.l	(a0),a0
	move.l	a0,-(a1)
	eor.l	d6,(a0)+
	eor.l	d6,(a0)+
	eor.l	d6,(a0)
	move	#$70,a0
	clr.l	(a0)+
	movem.l	(a0),d0/a0-a1
	rte
Lnaerr:	addq.l	#2,2(a7)
	not.l	d6
	rte
Lnferr:	addq.l	#2,2(a7)
	neg.l	d6
	rte
  ;#] Irrupts Routines:
  ;#[ DATA Segment:
	DATA
	dc.w	0
Chkend:	dc.l	$8ebe68bf
Preview:	ds.l	2
Check:	dc.l	$31415926
Dummy:	dc.w	0
End0:	incbin	main.tos
End00:
  ;#] DATA Segment:

