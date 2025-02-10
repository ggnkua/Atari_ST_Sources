
*-------------------------------------------------------*
			text
*-------------------------------------------------------*

*-------------------------------------------------------*
*	Videl registers					*
*-------------------------------------------------------*

RShift			=	$FFFF8260
RSpShift		=	$FFFF8266
RWrap			=	$FFFF8210
RSync			=	$FFFF820A
RCO			=	$FFFF82C0
RMode			=	$FFFF82C2
RHHT			=	$FFFF8282
RHBB			=	$FFFF8284
RHBE			=	$FFFF8286
RHDB			=	$FFFF8288
RHDE			=	$FFFF828A
RHSS			=	$FFFF828C
RHFS			=	$FFFF828E
RHEE			=	$FFFF8290
RVFT			=	$FFFF82A2
RVBB			=	$FFFF82A4
RVBE			=	$FFFF82A6
RVDB			=	$FFFF82A8
RVDE			=	$FFFF82AA
RVSS			=	$FFFF82AC

*-------------------------------------------------------*
*	Videl register file				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
patch_code		rs.w	1			; fake modecode (describes register file)
*-------------------------------------------------------*
patch_size		rs.l	1			; total display memory
patch_width		rs.w	1			; horizontal res
patch_height		rs.w	1			; vertical res
patch_depth		rs.w	1			; colour depth (bits per pixel)
*-------------------------------------------------------*
patch_RShift		rs.b	1			; register file
patch_RSync		rs.b	1
patch_RSpShift		rs.w	1
patch_RWrap		rs.w	1
patch_RCO		rs.w	1
patch_RMode		rs.w	1
patch_RHHT		rs.w	1
patch_RHBB		rs.w	1
patch_RHBE		rs.w	1
patch_RHDB		rs.w	1
patch_RHDE		rs.w	1
patch_RHSS		rs.w	1
patch_RHFS		rs.w	1
patch_RHEE		rs.w	1
patch_RVFT		rs.w	1
patch_RVBB		rs.w	1
patch_RVBE		rs.w	1
patch_RVDB		rs.w	1
patch_RVDE		rs.w	1
patch_RVSS		rs.w	1
*-------------------------------------------------------*
patch_slen		rs.b	0
*-------------------------------------------------------*

hz200			=	$4ba
vbcount			=	$462

*-------------------------------------------------------*
*	Load Videl registers				*
*-------------------------------------------------------*
load_registers:
*-------------------------------------------------------*
*	Register file pointer				*
*-------------------------------------------------------*
	move.l		patch_struct_ptr,a0
*-------------------------------------------------------*
*	Lock exceptions					*
*-------------------------------------------------------*
	move.w		sr,-(sp)
	or.w		#$700,sr
*-------------------------------------------------------*
*	Load shift mode					*
*-------------------------------------------------------*
	move.w		patch_RSpShift(a0),RSpShift.w
	move.w		patch_code(a0),d0
	cmp.w		#2,patch_depth(a0)
	beq.s		.yst
	cmp.w		#4,patch_depth(a0)
	bne.s		.nst
	btst		#compat_bit,d0
	beq.s		.nst
.yst:	move.b		patch_RShift(a0),RShift.w
*-------------------------------------------------------*
*	Load line wrap					*
*-------------------------------------------------------*
.nst:	move.w		patch_RWrap(a0),RWrap.w
*-------------------------------------------------------*
*	Load sync					*
*-------------------------------------------------------*
	move.b		patch_RSync(a0),RSync.w
*-------------------------------------------------------*
*	Load clock					*
*-------------------------------------------------------*
	move.w		patch_RCO(a0),d2
	moveq		#1,d0
	and.b		patch_RSync(a0),d0
	beq.s		.nrc
	and.w		#~4,d2
.nrc:	move.w		d2,RCO.w
*-------------------------------------------------------*
*	Load mode					*
*-------------------------------------------------------*
	move.w		patch_RMode(a0),RMode.w
*-------------------------------------------------------*
*	Horizontal register set				*
*-------------------------------------------------------*
	move.w		patch_RHHT(a0),RHHT.w
	move.w		patch_RHBB(a0),RHBB.w
	move.w		patch_RHBE(a0),RHBE.w
	move.w		patch_RHDB(a0),RHDB.w
	move.w		patch_RHDE(a0),RHDE.w
	move.w		patch_RHSS(a0),RHSS.w
	move.w		patch_RHFS(a0),RHFS.w
	move.w		patch_RHEE(a0),RHEE.w
*-------------------------------------------------------*
*	Vertical register set				*
*-------------------------------------------------------*
	move.w		patch_RVFT(a0),RVFT.w
	move.w		patch_RVBB(a0),RVBB.w
	move.w		patch_RVBE(a0),RVBE.w
	move.w		patch_RVDB(a0),RVDB.w
	move.w		patch_RVDE(a0),RVDE.w
	move.w		patch_RVSS(a0),RVSS.w
*-------------------------------------------------------*
*	Restore exceptions				*
*-------------------------------------------------------*
.dst2:	move.w		(sp)+,sr
*-------------------------------------------------------*
*	Re-synchronize display for new settings		*
*-------------------------------------------------------*
	move.w		patch_code(a0),d1
	bsr		videl_re_sync
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
*	Load Videl registers				*
*-------------------------------------------------------*
read_registers:
*-------------------------------------------------------*
*	Get current modecode				*
*-------------------------------------------------------*
	move.w		#-1,-(sp)
	move.w		#88,-(sp)
	trap		#14
	addq.l		#4,sp
*-------------------------------------------------------*
	move.l		patch_struct_ptr,a0
*-------------------------------------------------------*
*	Store modecode for this register file		*
*-------------------------------------------------------*
	move.w		d0,patch_code(a0)
*-------------------------------------------------------*
*	Store depth for this register file		*
*-------------------------------------------------------*
	clr.l		d1
	and.w		#%111,d0
	bset		d0,d1
	move.w		d1,patch_depth(a0)
*-------------------------------------------------------*
*	Store dimensions for this register file		*
*-------------------------------------------------------*
	move.w		vwork_w,patch_width(a0)
	move.w		vwork_h,patch_height(a0)
*-------------------------------------------------------*
*	Store size for this register file		*
*-------------------------------------------------------*
	move.w		patch_depth(a0),d0
	mulu.w		patch_height(a0),d0
	mulu.w		patch_width(a0),d0
	lsr.l		#3,d0
	move.l		d0,patch_size(a0)
*-------------------------------------------------------*
*	Allow previous VBlank changes to settle		*
*-------------------------------------------------------*
	moveq		#1,d0
	add.l		vbcount.w,d0
.lp1:	nop
	cmp.l		vbcount.w,d0
	bne.s		.lp1
*-------------------------------------------------------*
*	Lock exceptions					*
*-------------------------------------------------------*
	move.w		sr,-(sp)
	or.w		#$700,sr
*-------------------------------------------------------*
*	Load shift mode					*
*-------------------------------------------------------*
	move.b		RShift.w,patch_RShift(a0)
	move.w		RSpShift.w,patch_RSpShift(a0)
*-------------------------------------------------------*
*	Load line wrap					*
*-------------------------------------------------------*
	move.w		RWrap.w,patch_RWrap(a0)
*-------------------------------------------------------*
*	Load sync					*
*-------------------------------------------------------*
	move.b		RSync.w,patch_RSync(a0)
*-------------------------------------------------------*
*	Load clock					*
*-------------------------------------------------------*
	move.w		RCO.w,patch_RCO(a0)
*-------------------------------------------------------*
*	Load mode					*
*-------------------------------------------------------*
	move.w		RMode.w,patch_RMode(a0)
*-------------------------------------------------------*
*	Horizontal register set				*
*-------------------------------------------------------*
	move.w		RHHT.w,patch_RHHT(a0)
	move.w		RHBB.w,patch_RHBB(a0)
	move.w		RHBE.w,patch_RHBE(a0)
	move.w		RHDB.w,patch_RHDB(a0)
	move.w		RHDE.w,patch_RHDE(a0)
	move.w		RHSS.w,patch_RHSS(a0)
	move.w		RHFS.w,patch_RHFS(a0)
	move.w		RHEE.w,patch_RHEE(a0)
*-------------------------------------------------------*
*	Vertical register set				*
*-------------------------------------------------------*
	move.w		RVFT.w,patch_RVFT(a0)
	move.w		RVBB.w,patch_RVBB(a0)
	move.w		RVBE.w,patch_RVBE(a0)
	move.w		RVDB.w,patch_RVDB(a0)
	move.w		RVDE.w,patch_RVDE(a0)
	move.w		RVSS.w,patch_RVSS(a0)
*-------------------------------------------------------*
*	Restore exceptions				*
*-------------------------------------------------------*
	move.w		(sp)+,sr
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
videl_re_sync:
*-------------------------------------------------------*
*	Decode new modecode				*
*-------------------------------------------------------*
	and.w		#%111,d1
	cmp.w		#bpl1,d1
	bne.s		.nsync
*-------------------------------------------------------*
*	Reset Videl for re-sync				*
*-------------------------------------------------------*
.sync:	move.w		patch_RCO(a0),d0
	eor.w		#$100,d0
	move.w		d0,RCO.w
*-------------------------------------------------------*
	moveq		#30,d1
	add.l		hz200.w,d1
	move.b		$FFFF8207.w,d2
	clr.l		d3
.lp:	cmp.b		$FFFF8207.w,d2
	beq.s		.noch
	moveq		#1,d3
.noch:	cmp.l		hz200.w,d1
	bne.s		.lp
*-------------------------------------------------------*
	moveq		#1,d0
	and.b		patch_RSync(a0),d0
	beq.s		.nrs1
	tst.l		d3
	bne.s		.nrs1
	move.b		#2,RSync.w
*-------------------------------------------------------*
.nrs1:	moveq		#1,d1
	add.l		vbcount.w,d1
.lp2:	nop
	cmp.l		vbcount.w,d1
	bne.s		.lp2
*-------------------------------------------------------*
	move.w		patch_RCO(a0),d2
	moveq		#1,d0
	and.b		patch_RSync(a0),d0
	beq.s		.nrs2
	tst.l		d3
	beq.s		.nrs2
	and.w		#~4,d2
.nrs2:	move.w		d2,RCO.w
.nsync:	rts

*-------------------------------------------------------*
			bss
*-------------------------------------------------------*

patch_struct_ptr:	ds.l	1

*-------------------------------------------------------*
			text
*-------------------------------------------------------*
