
#define a0 A0
#define a1 A1
#define a2 A2
#define a3 A3
#define a4 A4
#define a5 A5
#define a6 A6
#define a7 A7
#define sp A7

#define d0 D0
#define d1 D1
#define d2 D2
#define d3 D3
#define d4 D4
#define d5 D5
#define d6 D6
#define d7 D7

extern tmult();
asm	{
tmult:
	move.w	4(a7),d0
	muls	6(a7),d0
	asl.l	#2,d0
	rts
	}

extern scale_mult();
extern itmult();
asm	{
scale_mult:
itmult:
	move.w 4(a7),d0
	muls 6(a7),d0
	asl.l #2,d0
	swap d0 
	ext.l d0
	rts
	}

/*	signed scale by  sscale_by( unscaled, p, q) */
extern sscale_by();
asm	{
sscale_by:
	move.w 6(sp),d0
	move.w 8(sp),d1
	cmp.w d1,d0
	beq.s ssb_trivial
	muls 4(sp),d0
	divs d1,d0
	rts
ssb_trivial:
	move.w 4(sp),d0
	rts
	}

/*	unsigned scale by  uscale_by( unscaled, p, q) */
extern uscale_by();
asm	{
uscale_by:
	move.w 6(sp),d0
	move.w 8(sp),d1
	cmp.w d1,d0
	beq.s usb_trivial
	mulu 4(sp),d0
	divu d1,d0
	rts
usb_trivial:
	move.w 4(sp),d0
	rts
	}


