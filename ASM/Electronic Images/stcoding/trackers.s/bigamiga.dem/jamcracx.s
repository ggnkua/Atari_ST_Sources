
                  ****************************************
                  *** JamCrackerPro V1.0a play-routine ***
                  ***   Originally coded by M. Gemmel  ***
                  ***           Code optimised         ***
                  ***         by Xag of Betrayal       ***
                  ***    See docs for important info   ***
                  ****************************************

	*** Relative offset definitions ***

		RSRESET		;Instrument info structure
it_name		RS.B	31
it_flags	RS.B	1
it_size		RS.L	1
it_address	RS.L	1
it_sizeof	RS.W	0

		RSRESET		;Pattern info structure
pt_size		RS.W	1
pt_address	RS.L	1
pt_sizeof	RS.W	0

		RSRESET		;Note info structure
nt_period	RS.B	1
nt_instr	RS.B	1
nt_speed	RS.B	1
nt_arpeggio	RS.B	1
nt_vibrato	RS.B	1
nt_phase	RS.B	1
nt_volume	RS.B	1
nt_porta	RS.B	1
nt_sizeof	RS.W	0

		RSRESET		;Voice info structure
pv_waveoffset	RS.W	1
pv_dmacon		RS.W	1
pv_custbase	RS.L	1
pv_inslen		RS.W	1
pv_insaddress	RS.L	1
pv_peraddress	RS.L	1
pv_pers		RS.W	3
pv_por		RS.W	1
pv_deltapor	RS.W	1
pv_porlevel	RS.W	1
pv_vib		RS.W	1
pv_deltavib	RS.W	1
pv_vol		RS.W	1
pv_deltavol	RS.W	1
pv_vollevel	RS.W	1
pv_phase		RS.W	1
pv_deltaphase	RS.W	1
pv_vibcnt		RS.B	1
pv_vibmax		RS.B	1
pv_flags		RS.B	1
pv_sizeof		RS.W	0

	*** Initialise routine ***

_pp_init:	movem.l d0-d7/a0-a6,-(sp)
;		move.l	_adr_data,a0
		move.l jcdata_ptr,a0
		addq.w	#4,a0
		move.w	(a0)+,d0
		move.w	d0,d1
		move.l	a0,instable
		mulu	#it_sizeof,d0
		add.w	d0,a0

		move.w	(a0)+,d0
		move.w	d0,d2
		move.l	a0,patttable
		mulu	#pt_sizeof,d0
		add.w	d0,a0

		move.w	(a0)+,d0
		move.w	d0,songlen
		move.l	a0,songtable
		add.w	d0,d0
		add.w	d0,a0

		move.l	patttable(PC),a1
		move.w	d2,d0
		subq.w	#1,d0
.l0:		move.l	a0,pt_address(a1)
		move.w	(a1),d3		;pt_size
		mulu	#nt_sizeof*4,d3
		add.w	d3,a0
		addq.w	#pt_sizeof,a1
		dbra	d0,.l0

		move.l	instable(PC),a1
		move.w	d1,d0
		subq.w	#1,d0
.l1:		move.l	a0,it_address(a1)
		move.l	it_size(a1),d2
		add.l	d2,a0
		add.w	#it_sizeof,a1
		dbra	d0,.l1

		move.l	songtable(PC),pp_songptr
		move.w	songlen(PC),pp_songcnt
		move.l	pp_songptr(PC),a0
		move.w	(a0),d0
		mulu	#pt_sizeof,d0
		add.l	patttable(PC),d0
		move.l	d0,a0
		move.l	a0,pp_pattentry
		move.b	pt_size+1(a0),pp_notecnt
		move.l	pt_address(a0),pp_address
		move.b	#6,pp_wait
		move.b	#1,pp_waitcnt
		clr.w	pp_nullwave

		move.w	#$000F,shadow_dmacon

		lea	pp_variables(PC),a0
		lea	ch1s,a1
		moveq	#1,d1
		move.w	#$80,d2
		moveq	#4-1,d0
.l2:		;move.w	#0,8(a1)
		move.w	d2,(a0)		;pv_waveoffset
		move.w	d1,pv_dmacon(a0)
		move.l	a1,pv_custbase(a0)
		move.l	#pp_periods,pv_peraddress(a0)
		move.w	#1019,pv_pers(a0)
		clr.w	pv_pers+2(a0)
		clr.w	pv_pers+4(a0)
		clr.l	pv_por(a0)
		clr.w	pv_porlevel(a0)
		clr.l	pv_vib(a0)
		clr.l	pv_vol(a0)
		move.w	#$40,pv_vollevel(a0)
		clr.l	pv_phase(a0)
		clr.w	pv_vibcnt(a0)
		clr.b	pv_flags(a0)
		add.w	#pv_sizeof,a0
		add.w	#sam_vcsize,a1
		add.w	d1,d1
		add.w	#$40,d2
		dbra	d0,.l2

		;bset	#1,$BFE001
		movem.l (sp)+,d0-d7/a0-a6
		rts

	*** Play routine ***

pp_play:	lea	ch1s,a6
		subq.b	#1,pp_waitcnt
		bne.s	.l0
		bsr	pp_nwnt
		move.b	pp_wait(PC),pp_waitcnt

.l0:		lea	pp_variables(PC),a1
		bsr.s	pp_uvs
		lea	pp_variables+pv_sizeof(PC),a1
		bsr.s	pp_uvs
		lea	pp_variables+2*pv_sizeof(PC),a1
		bsr.s	pp_uvs
		lea	pp_variables+3*pv_sizeof(PC),a1

pp_uvs:		move.l	pv_custbase(a1),a0

.l0:		move.w	pv_pers(a1),d0
		bne.s	.l1
		bsr	pp_rot
		bra.s	.l0
.l1:		add.w	pv_por(a1),d0
		tst.w	pv_por(a1)
		beq.s	.l1c
		bpl.s	.l1a
		cmp.w	pv_porlevel(a1),d0
		bge.s	.l1c
		bra.s	.l1b
.l1a:		cmp.w	pv_porlevel(a1),d0
		ble.s	.l1c
.l1b:		move.w	pv_porlevel(a1),d0

.l1c:		add.w	pv_vib(a1),d0
		cmp.w	#135,d0
		bge.s	.l1d
		move.w	#135,d0
		bra.s	.l1e
.l1d:		cmp.w	#1019,d0
		ble.s	.l1e
		move.w	#1019,d0
.l1e:		move.w	d0,sam_period(a0)
		bsr	pp_rot

		move.w	pv_deltapor(a1),d0
		add.w	d0,pv_por(a1)
		cmp.w	#-1019,pv_por(a1)
		bge.s	.l3
		move.w	#-1019,pv_por(a1)
		bra.s	.l5
.l3:		cmp.w	#1019,pv_por(a1)
		ble.s	.l5
		move.w	#1019,pv_por(a1)

.l5:		tst.b	pv_vibcnt(a1)
		beq.s	.l7
		move.w	pv_deltavib(a1),d0
		add.w	d0,pv_vib(a1)
		subq.b	#1,pv_vibcnt(a1)
		bne.s	.l7
		neg.w	pv_deltavib(a1)
		move.b	pv_vibmax(a1),pv_vibcnt(a1)

.l7:		move.w	pv_dmacon(a1),d0
		move.w	pv_vol(a1),sam_vol(a0)
		move.w	pv_deltavol(a1),d0
		add.w	d0,pv_vol(a1)
		tst.w	pv_vol(a1)
		bpl.s	.l8
		clr.w	pv_vol(a1)
		bra.s	.la
.l8:		cmp.w	#$40,pv_vol(a1)
		ble.s	.la
		move.w	#$40,pv_vol(a1)

.la:		btst	#1,pv_flags(a1)
		beq.s	.l10
		tst.w	pv_deltaphase(a1)
		beq.s	.l10
		bpl.s	.sk
		clr.w	pv_deltaphase(a1)
.sk:		move.l	pv_insaddress(a1),a0
		move.w	(a1),d0		;pv_waveoffset
		neg.w	d0
		lea	(a0,d0.w),a2
		move.l	a2,a3
		move.w	pv_phase(a1),d0
		lsr.w	#2,d0
		add.w	d0,a3

		moveq	#$40-1,d0
.lb:		move.b	(a2)+,d1
		ext.w	d1
		move.b	(a3)+,d2
		ext.w	d2
		add.w	d1,d2
		asr.w	#1,d2
		move.b	d2,(a0)+
		dbra	d0,.lb

		move.w	pv_deltaphase(a1),d0
		add.w	d0,pv_phase(a1)
		cmp.w	#$100,pv_phase(a1)
		blt.s	.l10
		sub.w	#$100,pv_phase(a1)

.l10:		rts

pp_rot:		move.w	pv_pers(a1),d0
		move.w	pv_pers+2(a1),pv_pers(a1)
		move.w	pv_pers+4(a1),pv_pers+2(a1)
		move.w	d0,pv_pers+4(a1)
		rts

pp_nwnt:		move.l	pp_address(PC),a0
		add.l	#4*nt_sizeof,pp_address
		subq.b	#1,pp_notecnt
		bne.s	.l5

.l0:		addq.l	#2,pp_songptr
		subq.w	#1,pp_songcnt
		bne.s	.l1
		move.l	songtable(PC),pp_songptr
		move.w	songlen(PC),pp_songcnt
.l1:		move.l	pp_songptr(PC),a1
		move.w	(a1),d0
		mulu	#pt_sizeof,d0
		add.l	patttable(PC),d0
		move.l	d0,a1
		move.b	pt_size+1(a1),pp_notecnt
		move.l	pt_address(a1),pp_address

.l5:		clr.w	pp_tmpdmacon
		lea	pp_variables(PC),a1
		bsr	pp_nnt
		addq.w	#nt_sizeof,a0
		lea	pp_variables+pv_sizeof(PC),a1
		bsr	pp_nnt
		addq.w	#nt_sizeof,a0
		lea	pp_variables+2*pv_sizeof(PC),a1
		bsr	pp_nnt
		addq.w	#nt_sizeof,a0
		lea	pp_variables+3*pv_sizeof(PC),a1
		bsr	pp_nnt

		move.w	pp_tmpdmacon(PC),d0
		move_dmacon d0


		lea	pp_variables(PC),a1
		bsr	pp_scr
		lea	pp_variables+pv_sizeof(PC),a1
		bsr	pp_scr
		lea	pp_variables+2*pv_sizeof(PC),a1
		bsr	pp_scr
		lea	pp_variables+3*pv_sizeof(PC),a1
		bsr	pp_scr

		bset	#7,pp_tmpdmacon
		move.w	pp_tmpdmacon(PC),d0
		move_dmacon d0


		movem.l d0/a0-a1,-(sp)
		lea pp_variables(pc),a0
		lea ch1s,a1
		rept 4
		move.l	pv_insaddress(a0),sam_lpstart(a1)
		moveq #0,d0
		move.w	pv_inslen(a0),d0
		add.l d0,d0
		move.w d0,sam_lplength(a1)
		add.l d0,sam_lpstart(a1)
		lea pv_sizeof(a0),a0 
		lea sam_vcsize(a1),a1
		endr

		movem.l (sp)+,d0/a0-a1

		rts

pp_scr:		move.w	pp_tmpdmacon(PC),d0
		and.w	pv_dmacon(a1),d0
		beq.s	.l5

		move.l d0,-(sp)
		move.l	pv_custbase(a1),a0
		move.l	pv_insaddress(a1),sam_start(a0)
		moveq #0,d0
		move.w	pv_inslen(a1),d0
		add.l d0,d0
		move.w d0,sam_length(a0)
		add.l d0,sam_start(a0)
		move.l (sp)+,d0

		move.w	pv_pers(a1),sam_period(a0)
		btst	#0,pv_flags(a1)
		bne.s	.l5
		move.l	#pp_nullwave,pv_insaddress(a1)
		move.w	#1,pv_inslen(a1)

.l5:		rts

pp_nnt:		move.b	(a0),d1		;nt_period
		beq	.l5

		and.l	#$000000FF,d1
		add.w	d1,d1
		add.l	#pp_periods-2,d1
		move.l	d1,a2

		btst	#6,nt_speed(a0)
		beq.s	.l2
		move.w	(a2),pv_porlevel(a1)
		bra.s	.l5

.l2:		move.w	pv_dmacon(a1),d0
		or.w	d0,pp_tmpdmacon

		move.l	a2,pv_peraddress(a1)
		move.w	(a2),pv_pers(a1)
		move.w	(a2),pv_pers+2(a1)
		move.w	(a2),pv_pers+4(a1)

		clr.w	pv_por(a1)

		move.b	nt_instr(a0),d0
		ext.w	d0
		mulu	#it_sizeof,d0
		add.l	instable(PC),d0
		move.l	d0,a2
		tst.l	it_address(a2)
		bne.s	.l1
		move.l	#pp_nullwave,pv_insaddress(a1)
		move.w	#1,pv_inslen(a1)
		clr.b	pv_flags(a1)
		bra.s	.l5

.l1:		move.l	it_address(a2),a3
		btst	#1,it_flags(a2)
		bne.s	.l0a
		move.l	it_size(a2),d0
		lsr.l	#1,d0
		move.w	d0,pv_inslen(a1)
		bra.s	.l0
.l0a:		move.w	(a1),d0		;pv_waveoffset
		add.w	d0,a3
		move.w	#$20,pv_inslen(a1)
.l0:		move.l	a3,pv_insaddress(a1)
		move.b	it_flags(a2),pv_flags(a1)
		move.w	pv_vollevel(a1),pv_vol(a1)

.l5:		move.b	nt_speed(a0),d0
		and.b	#$0F,d0
		beq.s	.l6
		move.b	d0,pp_wait

.l6:		move.l	pv_peraddress(a1),a2
		move.b	nt_arpeggio(a0),d0
		beq.s	.l9
		cmp.b	#$FF,d0
		bne.s	.l7
		move.w	(a2),pv_pers(a1)
		move.w	(a2),pv_pers+2(a1)
		move.w	(a2),pv_pers+4(a1)
		bra.s	.l9

.l7:		and.b	#$0F,d0
		add.b	d0,d0
		ext.w	d0
		move.w	(a2,d0.w),pv_pers+4(a1)
		move.b	nt_arpeggio(a0),d0
		lsr.b	#4,d0
		add.b	d0,d0
		ext.w	d0
		move.w	(a2,d0.w),pv_pers+2(a1)
		move.w	(a2),pv_pers(a1)

.l9:		move.b	nt_vibrato(a0),d0
		beq.s	.ld
		cmp.b	#$FF,d0
		bne.s	.la
		clr.l	pv_vib(a1)
		clr.b	pv_vibcnt(a1)
		bra.s	.ld
.la:		clr.w	pv_vib(a1)
		and.b	#$0F,d0
		ext.w	d0
		move.w	d0,pv_deltavib(a1)
		move.b	nt_vibrato(a0),d0
		lsr.b	#4,d0
		move.b	d0,pv_vibmax(a1)
		lsr.b	#1,d0
		move.b	d0,pv_vibcnt(a1)

.ld:		move.b	nt_phase(a0),d0
		beq.s	.l10
		cmp.b	#$FF,d0
		bne.s	.le
		clr.w	pv_phase(a1)
		move.w	#$FFFF,pv_deltaphase(a1)
		bra.s	.l10
.le:		and.b	#$0F,d0
		ext.w	d0
		move.w	d0,pv_deltaphase(a1)
		clr.w	pv_phase(a1)

.l10:		move.b	nt_volume(a0),d0
		bne.s	.l10a
		btst	#7,nt_speed(a0)
		beq.s	.l16
		bra.s	.l11a
.l10a:		cmp.b	#$FF,d0
		bne.s	.l11
		clr.w	pv_deltavol(a1)
		bra.s	.l16
.l11:		btst	#7,nt_speed(a0)
		beq.s	.l12
.l11a:		move.b	d0,pv_vol+1(a1)
		move.b	d0,pv_vollevel+1(a1)
		clr.w	pv_deltavol(a1)
		bra.s	.l16
.l12:		bclr	#7,d0
		beq.s	.l13
		neg.b	d0
.l13:		ext.w	d0
		move.w	d0,pv_deltavol(a1)

.l16:		move.b	nt_porta(a0),d0
		beq.s	.l1a
		cmp.b	#$FF,d0
		bne.s	.l17
		clr.l	pv_por(a1)
		bra.s	.l1a
.l17:		clr.w	pv_por(a1)
		btst	#6,nt_speed(a0)
		beq.s	.l17a
		move.w	pv_porlevel(a1),d1
		cmp.w	pv_pers(a1),d1
		bgt.s	.l17c
		neg.b	d0
		bra.s	.l17c

.l17a:		bclr	#7,d0
		bne.s	.l18
		neg.b	d0
		move.w	#135,pv_porlevel(a1)
		bra.s	.l17c

.l18:		move.w	#1019,pv_porlevel(a1)
.l17c:		ext.w	d0
.l18a:		move.w	d0,pv_deltapor(a1)

.l1a:		rts

	*** Data section ***

pp_periods:	DC.W	1019,962,908,857,809,763,720,680,642,606,572,540
		DC.W	509,481,454,428,404,381,360,340,321,303,286,270
		DC.W	254,240,227,214,202,190,180,170,160,151,143,135
		DC.W	135,135,135,135,135,135,135,135,135
		DC.W	135,135,135,135,135,135

songlen:	DS.W	1
songtable:	DS.L	1
instable:	DS.L	1
patttable:	DS.L	1

pp_wait:	DS.B	1
pp_waitcnt:	DS.B	1
pp_notecnt:	DS.B	1
pp_address:	DS.L	1
pp_songptr:	DS.L	1
pp_songcnt:	DS.W	1
pp_pattentry:	DS.L	1
pp_tmpdmacon:	DS.W	1
pp_variables:	DS.B	4*48

pp_nullwave:	DS.W	1
	even
jcdata_ptr	dc.l 0
