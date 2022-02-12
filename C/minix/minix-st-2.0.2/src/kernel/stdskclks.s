#include <minix/config.h>
#if (HD_CLOCK == 1)
#if (NR_ACSI_DRIVES > 0)	/* assume: no hard disk; no controller */
        .define _rd1byte
        .define _wr1byte
	.define _getsupra
	.define _geticd

        .sect   .text
        .sect   .rom
        .sect   .data
        .sect   .bss

        .sect   .text

dma_base        =               0xff8604
dma_data        =               0
dma_cont        =               2

select          =               0x10
sck_en          =               0x08

write           =               0x80

clk_dev =               6
clk_adr =               clk_dev*32
!
! moves the byte in d0 to the clock chip
!  uses d1, a0 must point to the dma channel
!

_wr1byte:
        clr.w   d0
        move.b  5(a7), d0
        lea     dma_base, a0
        move.w          #7, d1
        swap            d0
        move.w          #clk_adr+select+sck_en, d0

wrloop:         lsr.w           #1, d0
        swap            d0

        roxl.b          #1, d0
        swap            d0
        roxl.w          #1, d0
        move.w          d0, dma_data(a0)

        dbra            d1, wrloop

        rts

!
! moves a byte into d0 from the clock chip
!  uses d1, a0 must point to the dma channel
!

_rd1byte:
        lea     dma_base, a0
        move.w          #7, d1

rdloop:         swap            d0

        move.w          #clk_adr+select+sck_en, dma_data(a0)
        move.w          dma_data(a0), d0

        roxr.b          #1, d0
        swap            d0
        roxl.b          #1, d0

        dbra            d1, rdloop

        rts

	.sect	.text

!=============supra clock support here ==============
bsy_wait:
	link	a6,#0x0		! 4e56 0000
	bra	bsy2		! 6018
bsy1:
	move.l	gpip_a,a0		! 2079 0000 0d68
	move.b	(a0),d0		! 1010
	ext  	d0		! 4880
	and  	#0x20,d0		! c07c 0020
	tst  	d0		! 4a40
	bne	bsy2		! 6606
	move	#0x0,d0		! 303c 0000
	bra	bsy3		! 6010
bsy2:
	move.l	0x8(a6),d0		! 202e 0008
	sub.l	#1,0x8(a6)		! 53ae 0008
	tst.l	d0		! 4a80
	bne	bsy1		! 66dc
	move	#0xffff,d0		! 303c ffff
bsy3:
	unlk	a6		! 4e5e
	rts		! 4e75

!getsupclk(cntlr,index) index counts
getsupclk:
	cntlr = 0x8
	index = 0xa
	status = -0x2
	retval = -0x6
	temp1 = -0x4
!fffe:
	FDC=0x80
	HDC=0x8
	A0=0x2

	link	a6,#0xfff6		! 4e56 fff6
	move	#0xff9c,retval(a6)		! 3d7c ff9c fffa
	move.l	dma_mode_a,a0		! 2079 0000 0d64
	move	#FDC+HDC,(a0)		! 30bc 0088
	move	cntlr(a6),d0		! 302e 0008
	ext.l	d0		! 48c0
!shift left  16 + 5
	move.l	#16+5,d3		! 263c 0000 0015
	asl.l	d3,d0		! e7a0
!called as: 0xd,0xa,9,8,7,4,2,0
	move	index(a6),d1		! 322e 000a
	ext.l	d1		! 48c1
	asl.l	#8,d1		! e181
	asl.l	#8,d1		! e181
	or.l	d1,d0		! 8081
	or.l	#0x8a,d0		! 80bc 0000 008a
![ctlr-3][index-5]|[0x8a-16]
	move.l	dma_data_a,a0		! 2079 0000 0d6c
	move.l	d0,(a0)		! 2080
	move.l	#0xa,-(a7)		! 2f3c 0000 000a
	jsr	bsy_wait		! 4eb9 0000 00b6
	add.l	#4,a7		! 588f
	move	d0,status(a6)		! 3d40 fffe
	move	status(a6),d0		! 302e fffe
	beq	h194		! 673c

!timed out
	move.l	dma_data_a,a0		! 2079 0000 0d70
	move	(a0),temp1(a6)		! 3d50 fffc
	move.l	#0xa,-(a7)		! 2f3c 0000 000a
	jsr	bsy_wait		! 4eb9 0000 00b6
	add.l	#4,a7		! 588f
	move	d0,status(a6)		! 3d40 fffe
	move	status(a6),d0		! 302e fffe
	beq	h194		! 671a

!timed out
	move.l	dma_mode_a,a0		! 2079 0000 0d64
	move	#FDC+HDC+A0,(a0)		! 30bc 008a
	move.l	dma_data_a,a0		! 2079 0000 0d70
	move	(a0),d0		! 3010
	and  	#0xff,d0		! c07c 00ff
	move	d0,retval(a6)		! 3d40 fffa
h194:
	move.l	dma_mode_a,a0		! 2079 0000 0d64
	move	#FDC,(a0)		! 30bc 0080
	move.l	dma_data_a,a0		! 2079 0000 0d70
	move	(a0),temp1(a6)		! 3d50 fffc
	move	retval(a6),d0		! 302e fffa
	unlk	a6		! 4e5e
	rts		! 4e75

get_clock_channel:
	link	a6,#0xfffe		! 4e56 fffe
	move	#0x6,d0
	unlk	a6		! 4e5e
	rts		! 4e75

!date format:
! 0-4	(1f)	day	1-31
! 5-8	>>5 (f)	month	1-12
! 9-15	>>9 (7f) year	0-119  year 0 == 1980
!
!time format:
! 0-4	(1f)	2sec	0-29
! 5-10	>>5 (3f) min	0-59
! 11-15	>>11 (3f) hour	0-59
!
_getsupra:
	chan = -0x2
	count= -0x4
	date = -0x6
	time = -0x8

	link	a6,#0xfff8		! 4e56 fff8
	jsr	get_clock_channel		! 4eb9 0000 01c8
	move	d0,chan(a6)		! 3d40 fffe
	tst  	chan(a6)		! 4a6e fffe
	blt	sup3		! 6d00 0116
!get char 0xd
	move	#0xd,-(a7)		! 3f3c 000d
	move	chan(a6),-(a7)		! 3f2e fffe
	jsr	getsupclk		! 4eb9 0000 00e8
	add.l	#4,a7		! 588f
	and  	#0x80,d0		! c07c 0080
	cmp  	#0x80,d0		! 0c40 0080
	bne	sup3		! 6600 00fa
!count of times to try converting
!--maybe they can't stop the clock
	move	#2000,count(a6)		! 3d7c 07d0 fffc
	bra	sup1		! 6000 00e8
sup2:
!get char 0xa
	move	#0xa,-(a7)		! 3f3c 000a
	move	chan(a6),-(a7)		! 3f2e fffe
	jsr	getsupclk		! 4eb9 0000 00e8
	add.l	#4,a7		! 588f
	and  	#0x80,d0		! c07c 0080
	tst  	d0		! 4a40
	bne	sup1		! 6600 00ce

!get char 0x9 - year
	move	#0x9,-(a7)		! 3f3c 0009
	move	chan(a6),-(a7)		! 3f2e fffe
	jsr	getsupclk		! 4eb9 0000 00e8
	add.l	#4,a7		! 588f
	sub  	#80,d0		! 907c 0050
	asl  	#1,d0		! e340
	asl  	#8,d0		! e140
	move	d0,date(a6)		! 3d40 fffa
!get char 0x8 - month
	move	#0x8,-(a7)		! 3f3c 0008
	move	chan(a6),-(a7)		! 3f2e fffe
	jsr	getsupclk		! 4eb9 0000 00e8
	add.l	#4,a7		! 588f
	asl  	#5,d0		! eb40
	or  	d0,date(a6)		! 816e fffa
!get char 0x7
	move	#0x7,-(a7)		! 3f3c 0007
	move	chan(a6),-(a7)		! 3f2e fffe
	jsr	getsupclk		! 4eb9 0000 00e8
	add.l	#4,a7		! 588f
	or  	d0,date(a6)		! 816e fffa

!time format:
! 0-4	(1f)	2sec	0-29
! 5-10	>>5 (3f) min	0-59
! 11-15	>>11 (3f) hour	0-59
!get char 0x4 hour
	move	#0x4,-(a7)		! 3f3c 0004
	move	chan(a6),-(a7)		! 3f2e fffe
	jsr	getsupclk		! 4eb9 0000 00e8
	add.l	#4,a7		! 588f
	asl  	#3,d0		! e740
	asl  	#8,d0		! e140
	move	d0,time(a6)		! 3d40 fff8
!get char 0x2 min
	move	#0x2,-(a7)		! 3f3c 0002
	move	chan(a6),-(a7)		! 3f2e fffe
	jsr	getsupclk		! 4eb9 0000 00e8
	add.l	#4,a7		! 588f
	asl  	#5,d0		! eb40
	or  	d0,time(a6)		! 816e fff8
!get char 0x0 seconds - 2 sec 0-29
	clr  	-(a7)		! 4267
	move	chan(a6),-(a7)		! 3f2e fffe
	jsr	getsupclk		! 4eb9 0000 00e8
	add.l	#4,a7		! 588f
	or  	d0,time(a6)		! 816e fff8
!
	move	date(a6),d0
	asl.l	#8,d0
	asl.l	#8,d0
	move	time(a6),d0
!return a long date | time in TOS format
	bra	sup3		! 6008
sup1:
	sub  	#1,count(a6)		! 536e fffc
	bne	sup2		! 6600 ff14
	clr.l	d0 		!timed out
sup3:
	unlk	a6		! 4e5e
	rts		! 4e75

	.sect	.data


dma_mode_a:
	.data4 	0xff8606
gpip_a:
	.data4 	0xfffa01
dma_data_a:
	.data4 	0xff8604


! ICD clock handler

        .sect   .text

get_datetime:
	bsr	start_io	
	bmi	badread	
	lea	field_size,a1	
	move	#0x5,d1	
	move	#0x0,d7	
get_loop:
	move.b	0x0(a1,d1.w),d2	
	and  	#0xf,d2	
	lsl.l	d2,d7	
	bsr	do_io	
	bmi	badread	
	or.l	d0,d7	
	dbf	d1,get_loop	
	move.l	d7,d0	
badread:
	bsr	end_io	
	tst  	d2	
	rts	
start_io:
	lea	0xffff8604,a0	
	move	#0x88,0x2(a0)	
	move	#0xc0,(a0)	
	move	#0x8a,0x2(a0)	
	nop	
	nop
	nop
	nop
	btst	#0x5,0xfffffa01	
	beq	io_done	
	move	#-0x1,d2	
	rts	
io_done:
	move	#0x0,d2	
	rts	
end_io:
	move	#0x40,(a0)	
	move	#0x80,0x2(a0)	
	rts	
do_io:
	bsr	h1c6	
	bmi	h1be	
	move.l	a1,-(a7)	
	lea	clk_codes,a1	
	clr.l	d2	
	move.b	0x0(a1,d1.w),d2	
	move.l	(a7)+,a1	
	move	d2,(a0)	
	or  	#0x20,d2	
	move	d2,(a0)	
	and  	#0xcf,d2	
	move	d2,(a0)	
	and  	#0x8f,d2	
	move	d2,(a0)	
	add  	#0x0,d2	
	move	(a0),d0	
	move	#0xc0,(a0)	
	and  	#0xf,d0	
	cmp  	#0x85,d2	
	bne	h176	
	and  	#0x3,d0	
h176:
	mulu	#0xa,d0	
	move	d0,-(a7)	
	or  	#0xc0,d2	
	sub   	#1,d2	
	move	d2,(a0)	
	or  	#0x20,d2	
	move	d2,(a0)	
	and  	#0xcf,d2	
	move	d2,(a0)	
	and  	#0x8f,d2	
	move	d2,(a0)	
	add  	#0x0,d2	
	move	(a0),d0	
	move	#0xc0,(a0)	
	and  	#0xf,d0	
	add  	(a7)+,d0	
	tst  	d1	
	bne	h1ac	
	lsr  	#1,d0	
h1ac:
	and.l	#0xff,d0	
	cmp   	#0x5,d1	
	bne	h1bc	
	sub  	#0x50,d0	
h1bc:
	move	#0x0,d2	
h1be:
	rts	
! some indexes (maybe to the clock chip
clk_codes:
	.data1	0xc1,0xc3
	.data1	0xc5,0xc8
	.data1	0xca,0xcc
h1c6:
	move	#0x0,d2	
	rts	

!date format:
! 0-4	(1f)	day	1-31
! 5-8	>>5 (f)	month	1-12
! 9-15	>>9 (7f) year	0-119  year 0 == 1980
!
!time format:
! 0-4	(1f)	2sec	0-29
! 5-10	>>5 (3f) min	0-59
! 11-15	>>11 (3f) hour	0-59
!
field_size:
h1ca:
	.data1	0x05	!second size (2 second resolution)
	.data1	0x06	!minute size
	.data1	0x05	!hour size
	.data1	0x05	!day size
	.data1	0x04	!month size
	.data1	0x07	!year size

!returns long in d0
! |date word| time word|
_geticd:
	movem.l	d2-d7/a2-a7,-(a7)
	bsr	get_datetime	
	bmi	bad_read	
return:
	movem.l	(a7)+,d2-d7/a2-a7	! restore regs
	rts
bad_read:
	bsr	end_io	
	clr.l	d0
	bra	return
#endif /* NR_ASCI_DRIVES > 0 */
#endif /* HD_CLOCK == 1 */
