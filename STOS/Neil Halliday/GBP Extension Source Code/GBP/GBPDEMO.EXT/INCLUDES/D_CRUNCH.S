** Packer routines, in order of being called

* Speed packer V2.0 Unpack routine by The Firehawks
* In  a0 - Source address
* Out d0 - Unpacked length

speed:	movem.l	d1-a6,-(sp)
	clr.l	-(sp)
	cmp.l	#'SP20',(a0)+
	bne.s	sp2_05
	tst.w	(a0)
	bne.s	sp2_05
	move.l	a0,a5
	move.l	(a0)+,d5
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	d1,(sp)
	tst.w	d5
	beq.s	sp2_01
	swap	d5
	btst	#1,$FFFF8260.W
	bne.s	sp2_01
	lea	$FFFF8240.W,a5
	move.w	(a5),d5
	swap	d5
sp2_01:	lea	64(a0),a1
	move.l	a1,a2
	add.l	d0,a0
	add.l	d1,a1
	move.l	a1,a3
	move.l	sp,a6
	moveq	#79,d0
sp2_02:	move.b	-(a3),-(a6)
	dbf	d0,sp2_02
	exg.l	a6,sp
	bsr.s	sp2_06
	lea	-80(a1),a3
	move.l	(a6),d0
sp2_03:	move.b	(a1)+,(a3)+
	subq.l	#1,d0
	bne.s	sp2_03
	exg.l	a6,sp
	moveq	#79,d0
sp2_04:	move.b	(a6)+,(a3)+
	dbf	d0,sp2_04
sp2_05:	movem.l	(sp)+,d0-a6
	rts	
sp2_06:	moveq	#0,d6
	moveq	#1,d7
	lea	sp2_38(pc),a3
	jsr	(a3)
	roxr.l	d7,d0
sp2_07:	add.l	d0,d0
	bne.s	sp2_08
	jsr	(a3)
sp2_08:	bcs.s	sp2_24
	move.b	-(a0),d1
	bra.s	sp2_13
sp2_09:	moveq	#2,d2
	bsr.s	sp2_16
	move.l	d6,d1
	bset	d2,d1
	bra.s	sp2_13
sp2_10:	add.l	d0,d0
	bne.s	sp2_11
	jsr	(a3)
sp2_11:	bcs	sp2_33
	moveq	#3,d2
	bsr.s	sp2_16
	add.w	d7,d2
	lsr.w	d7,d2
	bcc.s	sp2_12
	not.w	d2
sp2_12:	move.b	(a1),d1
	add.w	d2,d1
sp2_13:	move.b	d1,-(a1)
	clr.w	(a5)
sp2_14: cmp.l	a1,a2
	bne.s	sp2_07
	swap	d5
	move.w	d5,(a5)
	rts
sp2_15:	move.l	d7,d2
sp2_16:	move.l	d6,d1
sp2_17:	add.l	d0,d0
	bne.s	sp2_18
	jsr	(a3)
sp2_18:	addx	d1,d1
	dbf	d2,sp2_17
sp2_19:	move.l	d1,d2
	rts
sp2_20:	bsr.s	sp2_15
sp2_21:	beq.s	sp2_22
	move.b	-(a0),d1
	subq.w	#2,d2
	bcs.s	sp2_19
sp2_22:	add.w	d7,d2
	add.w	d2,d2
sp2_23:	add.w	d2,d2
	sub.w	d7,d2
	bra.s	sp2_17
sp2_24:	add.l	d0,d0
	bne.s	sp2_25
	jsr	(a3)
sp2_25:	bcs.s	sp2_27
	add.l	d0,d0
	bne.s	sp2_26
	jsr	(a3)
sp2_26:	bcs.s	sp2_10
	move.l	d6,d1
	move.b	-(a0),d1
	moveq	#0,d3
	bra.s	sp2_36
sp2_27:	add.l	d0,d0
	bne.s	sp2_28
	jsr	(a3)
sp2_28:	bcs.s	sp2_29
	bsr.s	sp2_15
	beq.s	sp2_13
	moveq	#1,d3
	bra.s	sp2_35
sp2_29:	add.l	d0,d0
	bne.s	sp2_30
	jsr	(a3)
sp2_30:	bcs	sp2_09
	add.l	d0,d0
	bne.s	sp2_31
	jsr	(a3)
sp2_31:	bcs.s	sp2_32
	bsr.s	sp2_15
	beq.s	sp2_12
	moveq	#2,d3
	bra.s	sp2_35
sp2_32:	moveq	#3,d3
	bsr.s	sp2_20
	bra.s	sp2_36
sp2_33:	bsr.s	sp2_15
	beq.s	sp2_34
	move.l	d6,d1
	add.w	d7,d2
	bsr.s	sp2_23
	move.l	d2,d3
	bsr.s	sp2_20
	bra.s	sp2_36
sp2_34:	bsr.s	sp2_20
	not.l	d1
	move.l	d2,d3
	bra.s	sp2_36
sp2_35:	move.l	d6,d1
	sub.w	d7,d2
	bsr.s	sp2_21
sp2_36:	move.l	a1,a4
	addq.l	#2,a4
	add.l	d1,a4
	add.l	d3,a4
	move.b	-(a4),-(a1)
sp2_37:	move.b	-(a4),-(a1)
	dbf	d3,sp2_37
	move.w	d5,(a5)
	bra	sp2_14
sp2_38:	move.w	a0,d4
	btst	d6,d4
	bne.s	sp2_39
	move.l	-(a0),d0
	addx.l	d0,d0
	rts
sp2_39:	move.l	-5(a0),d0
	lsl.l	#8,d0
	move.b	-(a0),d0
	subq.l	#3,a0
	add.l	d0,d0
	bset	d6,d0
	rts

* Atomik packer routines written by Altair of Vmaxs
* In  a0 - Source of data
* Out ??

atomik:	movem.l	d0-a6,-(a7)
	cmp.l	#"ATM5",(a0)+
	bne	not_packed
	link	a2,#-28
	move.l	(a0)+,d0
	ifne	1		; Mode
	lea	4(a0,d0.l),a5
	move.l	d0,-(a7)
	elseif
	move.l	a1,a5
	add.l	d0,a5
	endc
	move.l	a5,a4
	ifne	1
	ifne	$80
	lea	$80(a4),a5
	endc
	endc
	lea	-$c(a4),a4
	move.l	(a0)+,d0
	move.l	a0,a6
	add.l	d0,a6
	ifne	1
	moveq	#0,d0
	move.b	-(a6),d0
	move	d0,-2(a2)
	ifne	0
	lsl	#2,d0
	sub	d0,a4
	endc
	elseif
	ifne	0
	clr	-2(a2)
	endc
	subq	#1,a6
	endc
	ifne	0
	lea	buff_marg(pc),a3
	move	-2(a2),d0
	lsl	#2,d0
	add	#$80+$C,d0
	bra.s	.save
.save_m:	move.b	(a4)+,(a3)+
	subq	#1,d0
.save:	bne.s	.save_m
	movem.l	a3-a4,-(a7)
	endc
	ifne	1
	pea	(a5)
	endc
	move.b	-(a6),d7
	bra	take_type
decrunch:	move	d3,d5
take_lenght:	add.b	d7,d7
.cont_take:	dbcs	d5,take_lenght
	beq.s	.empty1
	bcc.s	.next_cod
	sub	d3,d5
	neg	d5
	bra.s	.do_copy1
.next_cod:	moveq	#3,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	bra.s	.do_copy
.next_cod1:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod2
	add	#15,d5
	bra.s	.do_copy
.empty1:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_take
.next_cod2:	moveq	#13,d6
	bsr.s	get_bit2
	add	#255+15,d5
.do_copy:	add	d3,d5
.do_copy1:	lea	decrun_table(pc),a4
	move	d5,d2
	bne.s	bigger
	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:	bcs.s	.ho_kesako
	moveq	#1,d6
	bra.s	word
.ho_kesako:	moveq	#3,d6
	bsr.s	get_bit2
	tst.b	-28(a2)
	beq.s	.ho_kesako1
	move.b	10-28(a2,d5.w),-(a5)
	bra	tst_end
.ho_kesako1:	move.b	(a5),d0
	btst	#3,d5
	bne.s	.ho_kesako2
	bra.s	.ho_kesako3
.ho_kesako2:	add.b	#$f0,d5
.ho_kesako3:	sub.b	d5,d0
	move.b	d0,-(a5)
	bra	tst_end
get_bit2:	clr	d5
.get_bits:	add.b	d7,d7
	beq.s	.empty
.cont:	addx	d5,d5
	dbf	d6,.get_bits
	tst	d5
	rts
.empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont
bigger:	moveq	#2,d6
word:	bsr.s	get_bit2
contus:	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	tst.b	1-28(a2)
	bne.s	.spe_ofcod1
	addq	#4,d6
	bra.s	.nospe_ofcod1
.spe_ofcod1:	bsr.s	get_bit2
	move	d5,d1
	lsl	#4,d1
	moveq	#2,d6
	bsr.s	get_bit2
	cmp.b	#7,d5
	blt.s	.take_orof
	moveq	#0,d6
	bsr.s	get_bit2
	beq.s	.its_little
	moveq	#2,d6
	bsr.s	get_bit2
	add	d5,d5
	or	d1,d5
	bra.s	.spe_ofcod2
.its_little:	or.b	2-28(a2),d1
	bra.s	.spe_ofcod3
.take_orof:	or.b	3-28(a2,d5.w),d1
.spe_ofcod3:	move	d1,d5
	bra.s	.spe_ofcod2
.nospe_ofcod1:	bsr.s	get_bit2
.spe_ofcod2:	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first:	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
.copy_same:	move.b	-(a4),-(a5)
	dbf	d2,.copy_same
	bra.s	tst_end
make_jnk:	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:	bcs.s	string
	move.b	-(a6),-(a5)
tst_end:	cmp.l	a5,a3
	bne.s	make_jnk
	cmp.l	a6,a0
	beq.s	work_done
take_type:	moveq	#0,d6
	bsr	get_bit2
	beq.s	.nospe_ofcod
	move.b	-(a6),d0
	lea	2-28(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
.next:	cmp.b	d0,d1
	bne.s	.no_off_4b
	addq	#2,d1
.no_off_4b:	move.b	d1,(a1)+
	addq	#2,d1
	dbf	d2,.next
	st	1-28(a2)
	bra.s	.spe_ofcod
.nospe_ofcod:	sf	1-28(a2)
.spe_ofcod:	moveq	#0,d6
	bsr	get_bit2
	beq.s	.relatif
	lea	10-28(a2),a1
	moveq	#15,d0
.next_f:	move.b	-(a6),(a1)+
	dbf	d0,.next_f
	st	-28(a2)
	bra.s	.freq
.relatif:	sf	-28(a2)
.freq:	clr	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl	#8,d0
	move.b	-(a6),d0
	move.l	a5,a3
	sub	d0,a3
	bra.s	make_jnk
string:	bra	decrunch
work_done:
	ifne	1
	move.l	(a7)+,a0
	pea	(a2)
	bsr.s	decod_picture
	move.l	(a7)+,a2
	endc
	ifne	0
	movem.l	(a7)+,a3-a4
	endc
	ifne	1
	move.l	(a7)+,d0
	bsr	copy_decrun
	endc
	ifne	0
	move	-2(a2),d0
	lsl	#2,d0
	add	#$80+$C,d0
	bra.s	.restore
.restore_m:	move.b	-(a3),-(a4)
	subq	#1,d0
.restore:	bne.s	.restore_m
	endc
	unlk	a2
not_packed:	movem.l	(a7)+,d0-a6
 	rts
decrun_table:	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	0,1,3,4,5,6,7,8
	ifne	1
decod_picture:	move	-2(a2),d7
.next_picture:	dbf	d7,.decod_algo
	rts
.decod_algo:	move.l	-(a0),d0
	lea	0(a5,d0.l),a1
.no_odd:	lea	$7d00(a1),a2
.next_planes:	moveq	#3,d6
.next_word:	move	(a1)+,d0
	moveq	#3,d5
.next_bits:	add	d0,d0
	addx	d1,d1
	add	d0,d0
	addx	d2,d2
	add	d0,d0
	addx	d3,d3
	add	d0,d0
	addx	d4,d4
	dbf	d5,.next_bits
	dbf	d6,.next_word
	movem	d1-d4,-8(a1)
	cmp.l	a1,a2
	bne.s	.next_planes
	bra.s	.next_picture
	endc
	ifne	1
copy_decrun:	lsr.l	#4,d0
	lea	-12(a6),a6
.copy_decrun:	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d0,.copy_decrun
	rts
	endc
	ifne	0
buff_marg:	dcb.b	$90+$80+$C
	endc
	

* Unpacking source for Pack-Ice Version 2.1
* In a0 - Pointer on packed Data

ice:	movem.l d0-a6,-(sp)		; save registers
	cmpi.l	#'Ice!',(a0)+		; Data packed?
	bne.s	ice2_07			; no!
	move.l	(a0)+,d0
	lea	-8(a0,d0.l),a5
	move.l	(a0)+,(sp)
	lea	108(a0),a4
	movea.l a4,a6
	adda.l	(sp),a6
	movea.l a6,a3
	movea.l a6,a1			; save 120 bytes
	lea	ice2_21+120(pc),a2	; at the end of the
	moveq	#$77,d0			; unpacked data
ice2_00:move.b	-(a1),-(a2)
	dbra	d0,ice2_00
	bsr	ice2_0c
	bsr.s	ice2_08
	bsr	ice2_10		;; Picture decrunch!
	bcc.s	ice2_04		;; These marked lines are only
	movea.l a3,a1		;; necessary, if you selected the
	move.w	#$0f9f,d7	;; additional picture packer
ice2_01:moveq	#3,d6		;; in Pack-Ice.
ice2_02:move.w	-(a1),d4	;;
	moveq	#3,d5		;; If you never use the picture
ice2_03:add.w	d4,d4		;; pack option, you may delete
	addx.w	d0,d0		;; all the lines marked with ";;"
	add.w	d4,d4		;;
	addx.w	d1,d1		;;
	add.w	d4,d4		;;
	addx.w	d2,d2		;;
	add.w	d4,d4		;;
	addx.w	d3,d3		;;
	dbra	d5,ice2_03	;;
	dbra	d6,ice2_02	;;
	movem.w d0-d3,(a1)	;;
	dbra	d7,ice2_01	;;
ice2_04:move.l	(sp),d0			; move all data to
	lea	-120(a4),a1		; 120 bytes lower
ice2_05:move.b	(a4)+,(a1)+
	dbra	d0,ice2_05
	subi.l	#$010000,d0
	bpl.s	ice2_05
	moveq	#$77,d0			; restore saved data
	lea	ice2_21+120(pc),a2
ice2_06:move.b	-(a2),-(a3)
	dbra	d0,ice2_06
ice2_07:movem.l (sp)+,d0-a6		; restore registers
	rts
ice2_08:bsr.s	ice2_10
	bcc.s	ice2_0b
	moveq	#0,d1
	bsr.s	ice2_10
	bcc.s	ice2_0a
	lea	ice2_1e(pc),a1
	moveq	#4,d3
ice2_09:move.l	-(a1),d0
	bsr.s	ice2_13
	swap	d0
	cmp.w	d0,d1
	dbne	d3,ice2_09
	add.l	20(a1),d1
ice2_0a:move.b	-(a5),-(a6)
	dbra	d1,ice2_0a
ice2_0b:cmpa.l	a4,a6
	bgt.s	ice2_16
	rts
ice2_0c:moveq	#3,d0
ice2_0d:move.b	-(a5),d7
	ror.l	#8,d7
	dbra	d0,ice2_0d
	rts
ice2_0e:move.w	a5,d7
	btst	#0,d7
	bne.s	ice2_0f
	move.l	-(a5),d7
	addx.l	d7,d7
	bra.s	ice2_15
ice2_0f:move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	bra.s	ice2_15
ice2_10:add.l	d7,d7
	beq.s	ice2_11
	rts
ice2_11:move.w	a5,d7
	btst	#0,d7
	bne.s	ice2_12
	move.l	-(a5),d7
	addx.l	d7,d7
	rts
ice2_12:move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	rts
ice2_13:moveq	#0,d1
ice2_14:add.l	d7,d7
	beq.s	ice2_0e
ice2_15:addx.w	d1,d1
	dbra	d0,ice2_14
	rts
ice2_16:lea	ice2_1f(pc),a1
	moveq	#3,d2
ice2_17:bsr.s	ice2_10
	dbcc	d2,ice2_17
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	ice2_18
	bsr.s	ice2_13
ice2_18:move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	ice2_1a
	lea	ice2_20(pc),a1
	moveq	#1,d2
ice2_19:bsr.s	ice2_10
	dbcc	d2,ice2_19
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	ice2_13
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bra.s	ice2_1c
ice2_1a:moveq	#0,d1
	moveq	#5,d0
	moveq	#0,d2
	bsr.s	ice2_10
	bcc.s	ice2_1b
	moveq	#8,d0
	moveq	#$40,d2
ice2_1b:bsr.s	ice2_13
	add.w	d2,d1
ice2_1c:lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
ice2_1d:move.b	-(a1),-(a6)
	dbra	d4,ice2_1d
	bra	ice2_08
	dc.b $7f,$ff,$00,$0e,$00,$ff,$00,$07
	dc.b $00,$07,$00,$02,$00,$03,$00,$01
	dc.b $00,$03,$00,$01
ice2_1e:dc.b $00,$00,$01,$0d,$00,$00,$00,$0e
	dc.b $00,$00,$00,$07,$00,$00,$00,$04
	dc.b $00,$00,$00,$01
ice2_1f:dc.b $09,$01,$00,$ff,$ff,$08,$04,$02
	dc.b $01,$00
ice2_20:dc.b $0b,$04,$07,$00,$01,$20,$00,$00
	dc.b $00,$20
ice2_21:ds.w 60			; free space (can be put in BSS)

* Automation 5.01 decruncher 
*

auto:
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4	
	move.l	a4,a6		
	bsr.s	.getinfo
	cmpi.l	#'AU5!',d0	
	bne	.not_packed
	bsr.s	.getinfo	
	lea.l	-8(a0,d0.l),a5	
	bsr.s	.getinfo	
	move.l	d0,(sp)		
	adda.l	d0,a6		
	move.l	a6,a1

	moveq	#119,d0		
.save:	move.b	-(a1),-(a3)	
	dbf	d0,.save
	move.l	a6,a3		
	move.b	-(a5),d7	
	bsr.s	.normal_bytes
	move.l	a3,a5		

	bsr.s	.get_1_bit	
	bcc.s	.no_picture	
	move.w	#$0f9f,d7 	
.AU5_00:
	moveq	#3,d6	
.AU5_01:
	move.w	-(a3),d4
	moveq	#3,d5		
.AU5_02:
	add.w	d4,d4	
	addx.w	d0,d0		
	add.w	d4,d4		
	addx.w	d1,d1		
	add.w	d4,d4		
	addx.w	d2,d2		
	add.w	d4,d4		
	addx.w	d3,d3		
	dbra	d5,.AU5_02	
	dbra	d6,.AU5_01	
	movem.w	d0-d3,(a3)	
	dbra	d7,.AU5_00	
.no_picture
	movem.l	(sp),d0-a3	

.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0		
.rest	move.b	-(a3),-(a5)	
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
	unlk	a3
	rts
.getinfo: 
	moveq	#3,d1		
.getbytes:
	lsl.l	#8,d0	
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts
.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end	
	moveq.l	#0,d1		
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt	
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:
	move.l	-(a1),d0
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1		
	dbne	d3,.nextgb	
.no_more: 
	add.l	20(a1),d1 	
.copy_direkt:	
	move.b	-(a5),-(a6)	
	dbf	d1,.copy_direkt	
.test_if_end:	
	cmpa.l	a4,a6		
	bgt.s	.strings	
	rts	

.get_1_bit:
	add.b	d7,d7		
	bne.s	.bitfound 	
	move.b	-(a5),d7	
	addx.b	d7,d7
.bitfound:
	rts	

.get_d0_bits:	
	moveq.l	#0,d1		
.hole_bit_loop:	
	add.b	d7,d7		
	bne.s	.on_d0		
	move.b	-(a5),d7	
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1		
	dbf	d0,.hole_bit_loop	
	rts	

.strings: 
	lea.l	.length_tab(pc),a1	
	moveq.l	#3,d2		
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit
.no_length_bit:	
	moveq.l	#0,d4		
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0	
	ext.w	d0		
	bmi.s	.no_Åber	
.get_Åber:
	bsr.s	.get_d0_bits
.no_Åber:
	move.b	6(a1,d2.w),d4
	add.w	d1,d4	
	beq.s	.get_offset_2	

	lea.l	.more_offset(pc),a1 
	moveq.l	#1,d2
.getoffs: 
	bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1		
	move.b	1(a1,d2.w),d0	
	ext.w	d0		
	bsr.s	.get_d0_bits
	add.w	d2,d2		
	add.w	6(a1,d2.w),d1	
	bpl.s	.depack_bytes	
	sub.w	d4,d1		
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1		
	moveq.l	#5,d0		
	moveq.l	#-1,d2		
	bsr.s	.get_1_bit
	bcc.s	.less_40	
	moveq.l	#8,d0		
	moveq.l	#$3f,d2		
.less_40: 
	bsr.s	.get_d0_bits
	add.w	d2,d1		

.depack_bytes:			
	lea.l	2(a6,d4.w),a1	
	adda.w	d1,a1		
	move.b	-(a1),-(a6)	
.dep_b:	move.b	-(a1),-(a6)	
	dbf	d4,.dep_b 	
	bra	.normal_bytes	


.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001	
	dc.l 270-1,15-1,8-1,5-1,2-1	

.length_tab:
	dc.b 9,1,0,-1,-1	
	dc.b 8,4,2,1,0		

.more_offset:
	dc.b	  11,   4,   7,  0	
	dc.w	$11f,  -1, $1f	

ende_AU5_decrunch_2:
;* Ende der Unpackroutine

* Pack Ice version 2.40 depack routines, taken from ST Format
* Cover disk 39 (October 1992), added to extension 18/09/1992
* By N.Halliday
*
* Input  : a0 - Address of packed data
* Output : None

ice2
	link	a3,#-120
	movem.L	d0-a6,-(sp)
	lea	120(a0),a4
	move.L	a4,a6
	bsr	.getinfo
	cmpi.L	#'ICE!',d0
	bne.S	.not_packed
	bsr.s	.getinfo
	lea.L	-8(a0,d0.L),a5
	bsr.s	.getinfo
	move.L	d0,(sp)
	adda.L	d0,a6
	move.L	a6,a1
	moveq	#119,d0
.save	move.B	-(a1),-(a3)
	dbf	d0,.save
	move.L	a6,a3
	move.B	-(a5),d7
	bsr.s	.normal_bytes
	move.L	a3,a5
	bsr	.get_1_bit
	bcc.s	.no_picture
	move.W	#$0f9f,d7
	bsr	.get_1_bit
	bcc.s	.ice_00
	moveq	#15,d0
	bsr	.get_d0_bits
	move.W	d1,d7
.ice_00	moveq	#3,d6
.ice_01	move.W	-(a3),d4
	moveq	#3,d5
.ice_02	add.W	d4,d4
	addx.W	d0,d0
	add.W	d4,d4
	addx.W	d1,d1
	add.W	d4,d4
	addx.W	d2,d2
	add.W	d4,d4
	addx.W	d3,d3
	dbra	d5,.ice_02
	dbra	d6,.ice_01
	movem.W	d0-d3,(a3)
	dbra	d7,.ice_00
.no_picture
	movem.L	(sp),d0-a3

.move	move.B	(a4)+,(a0)+
	subq.L	#1,d0
	bne.s	.move
	moveq	#119,d0
.TRESt	move.B	-(a3),-(a5)
	dbf	d0,.TRESt
.not_packed	movem.L	(sp)+,d0-a6
	unlk	a3
	rts
.getinfo	moveq	#3,d1
.getbytes	lsl.L	#8,d0
	move.B	(a0)+,d0
	dbf	d1,.getbytes
	rts
.normal_bytes	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end
	moveq.L	#0,d1
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt
	lea.L	.direkt_tab+20(pc),a1
	moveq.L	#4,d3
.nextgb	move.L	-(a1),d0
	bsr.s	.get_d0_bits
	swap.W	d0
	cmp.W	d0,d1
	dbne	d3,.nextgb
.no_more add.L	20(a1),d1
.copy_direkt	move.B	-(a5),-(a6)
	dbf	d1,.copy_direkt
.test_if_end	cmpa.L	a4,a6
	bgt.s	.strings
	rts	
.get_1_bit	add.B	d7,d7
	bne.s	.Bitfound
	move.B	-(a5),d7
	addx.B	d7,d7
.Bitfound	rts	
.get_d0_bits	
	moveq.L	#0,d1
.hole_bit_loop	
	add.B	d7,d7
	bne.s	.on_d0
	move.B	-(a5),d7
	addx.B	d7,d7
.on_d0	addx.W	d1,d1
	dbf	d0,.hole_bit_loop
	rts	
.strings	lea.L	.Length_tab(pc),a1
	moveq.L	#3,d2
.get_length_bit	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit
.no_length_bit	
	moveq.L	#0,d4
	moveq.L	#0,d1
	move.B	1(a1,d2.W),d0
	ext.W	d0
	bmi.s	.no_Åber
.get_Åber	bsr.s	.get_d0_bits
.no_Åber	move.B	6(a1,d2.W),d4
	add.W	d1,d4
	beq.s	.get_offset_2
	lea.L	.more_offset(pc),a1
	moveq.L	#1,d2
.getoffs	bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.L	#0,d1
	move.B	1(a1,d2.W),d0
	ext.W	d0
	bsr.s	.get_d0_bits
	add.W	d2,d2
	add.W	6(a1,d2.W),d1
	bpl.s	.depack_bytes
	sub.W	d4,d1
	bra.s	.depack_bytes
.get_offset_2	
	moveq.L	#0,d1
	moveq.L	#5,d0
	moveq.L	#-1,d2
	bsr.s	.get_1_bit
	bcc.s	.Less_40
	moveq.L	#8,d0
	moveq.L	#$3f,d2
.Less_40 bsr.s	.get_d0_bits
	add.W	d2,d1
.depack_bytes
	lea.L	2(a6,d4.W),a1
	adda.W	d1,a1
	move.B	-(a1),-(a6)
.dep_b	move.B	-(a1),-(a6)
	dbf	d4,.dep_b
	bra	.normal_bytes
.direkt_tab	dc.L	$7fff000e,$00ff0007,$00070002,$00030001,$00030001
	dc.L     270-1,	15-1,	 8-1,	 5-1,	 2-1
.Length_tab	dc.B	9,1,0,-1,-1
	dc.B	8,4,2,1,0
.more_offset	dc.B	  11,   4,   7,  0	; Bits lesen
	dc.W	$11f,  -1, $1f	; Standard Offset
ende_ice_decrunch_2

* Fire Packer Decrunch routines - Supplied by Billy Allan
* Added to extension to make V2.9 by Neil Halliday 14/12/1992
* A Merry Xmas to All!
*
* Input  : A0 - source of data to depack
* Output : None

fire_decrunch_2:
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4	; a4 = Anfang entpackte Daten
	move.l	a4,a6		; a6 = Ende entpackte Daten
	bsr.s	.getinfo
	cmpi.l	#'FIRE',d0	; Kennung gefunden?
	bne	.not_packed
	bsr.s	.getinfo		; gepackte LÑnge holen
	lea.l	-8(a0,d0.l),a5	; a5 = Ende der gepackten Daten
	bsr.s	.getinfo		; ungepackte LÑnge holen (original)
	move.l	d0,(sp)		; OriginallÑnge: spÑter nach d0
	adda.l	d0,a6		; a6 = Ende entpackte Daten
	move.l	a6,a1
	moveq	#119,d0		; 120 Bytes hinter entpackten Daten
.save:	move.b	-(a1),-(a3)	; in sicheren Bereich sichern
	dbf	d0,.save
	move.l	a6,a3		; merken fÅr spÑter

	move.b	-(a5),d7		; erstes Informationsbyte
	lea	.tabellen(pc),a2	; a2 = Zeiger auf Datenbereich
	moveq	#1,d6
	swap	d6		; d6 = $10000
	moveq	#0,d5		; d5 = 0 (oberes Wort: immer 0!)

.normal_bytes:
	bsr.s	.get_1_bit
	bcc.s	.test_if_end	; Bit %0: keine Daten
	moveq	#0,d1		; falls zu .copy_direkt
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt	 ; Bitfolge: %10: 1 Byte direkt kop.
;	lea.l	.direkt_tab+16-.tabellen(a2),a0 ; ...siehe nÑchste Zeile
	move.l	a2,a0
	moveq	#3,d3
.nextgb:	move.l	-(a0),d0		; d0.w Bytes lesen
	bsr.s	.get_d0_bits
	swap	d0
	cmp.w	d0,d1		; alle gelesenen Bits gesetzt?
	dbne	d3,.nextgb	; ja: dann weiter Bits lesen
.no_more: add.l	16(a0),d1 	; Anzahl der zu Åbertragenen Bytes
.copy_direkt:
	move.b	-(a5),-(a6)	; Daten direkt kopieren
	dbf	d1,.copy_direkt	; noch ein Byte
.test_if_end:
	cmp.l	a4,a6		; Fertig?
	bgt.s	.strings		; Weiter wenn Ende nicht erreicht

	movem.l	(sp),d0-a2/a5	; hole nîtige Register
.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0		; um Åberschriebenen Bereich
.rest	move.b	-(a5),-(a3)	; wieder herzustellen
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
	unlk	a3
	rts

;************************** Unterroutinen: wegen Optimierung nicht am Schluû
.getinfo:
	moveq	#3,d1
.glw:	rol.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,.glw
	rts


.get_1_bit:
	add.b	d7,d7		; hole ein Bit
	beq.s	.no_bit_found
	rts
.no_bit_found:
	move.b	-(a5),d7
	addx.b	d7,d7
	rts

.get_d0_bits:
	moveq	#0,d1		; ergebnisfeld vorbereiten
.hole_bit_loop:
	add.b	d7,d7		; hole ein Bit
	beq.s	.not_found	; quellfeld leer
.on_d0:	addx.w	d1,d1		; und Åbernimm es
	dbf	d0,.hole_bit_loop	; bis alle Bits geholt wurden
	rts

.not_found:
	move.b	-(a5),d7		; hole sonst ein weiters longword
	addx.b	d7,d7		; hole ein Bit
	bra.s	.on_d0

;************************************ Ende der Unterroutinen


.strings:
	moveq	#1,d0		; 2 Bits lesen
	bsr.s	.get_d0_bits
	subq.w	#1,d1
	bmi.s	.gleich_morestring	; %00
	beq.s	.length_2 	; %01
	subq.w	#1,d1
	beq.s	.length_3 	; %10
	bsr.s	.get_1_bit
	bcc.s	.bitset		; %110
	bsr.s	.get_1_bit
	bcc.s	.length_4 	; %1110
	bra.s	.length_5 	; %1111

.get_short_offset:
	moveq	#1,d0
	bsr.s	.get_d0_bits	; d1:  0,  1,  2,  3
	subq.w	#1,d1
	bpl.s	.contoffs
	moveq	#0,d0		; Sonderfall
	rts

.get_long_offset:
	moveq	#1,d0		; 2 Bits lesen
	bsr.s	.get_d0_bits	; d1:  0,  1,  2,  3
.contoffs add.w	d1,d1		; d1:  0,  2,  4,  6
	add.w	d1,d1		; d1:  0,  4,  8, 12
	movem.w	.offset_table-.tabellen(a2,d1),d0/d5
	bsr.s	.get_d0_bits	; 4, 8, 12 oder 16 Bits lesen
	add.l	d5,d1
	rts


.gleich_morestring: 		; %00
	moveq	#1,d0		; 2 Bits lesen
	bsr.s	.get_d0_bits	; d1:  0,  1,  2,  3
	subq.w	#1,d1
	bmi.s	.gleich_string	; %0000

	add.w	d1,d1		; d1:	 0,  2,  4
	add.w	d1,d1		; d1:	 0,  4,  8
	movem.w	.more_table-.tabellen(a2,d1),d0/d2
	bsr.s	.get_d0_bits
	add.w	d1,d2		; d2 = StringlÑnge
	bsr.s	.get_long_offset
	move.w	d2,d0		; d0 = StringlÑnge
	bra.s	.copy_longstring

.bitset:	moveq	#2,d0		; %110
	bsr.s	.get_d0_bits
	moveq	#0,d0
	bset	d1,d0
	bra.s	.put_d0

.length_2:
	moveq	#7,d0		; %01
	bsr.s	.get_d0_bits
	moveq	#2-2,d0
	bra.s	.copy_string

.length_3:
	bsr.s	.get_short_offset	; %10
	tst.w	d0
	beq	.put_d0		; 0 ablegen
	moveq	#3-2,d0
	bra.s	.copy_string

.length_4:
	bsr.s	.get_short_offset	; %1110
	tst.w	d0
	beq.s	.vorgÑnger_kopieren
	moveq	#4-2,d0
	bra.s	.copy_string

.length_5:
	bsr.s	.get_short_offset	; %1111
	tst.w	d0
	beq.s	.put_ff
	moveq	#5-2,d0
	bra.s	.copy_string


.put_ff:	moveq	#-1,d0
	bra.s	.put_d0

.vorgÑnger_kopieren:
	move.b	(a6),d0
;	bra.s	.put_d0

.put_d0:	move.b	d0,-(a6)
	bra.s	.backmain


.gleich_string:
	bsr.s	.get_long_offset	; Anzahl gleicher Bytes lesen
	beq.s	.backmain 	; 0: zurÅck
	move.b	(a6),d0
.copy_gl: move.b	d0,-(a6)
	dbf	d1,.copy_gl
	sub.l	d6,d1
	bmi.s	.backmain
	bra.s	.copy_gl

.copy_longstring:
	subq.w	#2,d0		; StringlÑnge - 2 (wegen dbf)
.copy_string:			; d1 = Offset, d0 = Anzahl Bytes -2
	lea.l	2(a6,d1.l),a0	; Hier stehen die Originaldaten
	add.w	d0,a0		; dazu die StringlÑnge-2
	move.b	-(a0),-(a6)	; ein Byte auf jeden Fall kopieren
.dep_b:	move.b	-(a0),-(a6)	; mehr Bytes kopieren
	dbf	d0,.dep_b 	; und noch ein Mal
.backmain bra	.normal_bytes	; Jetzt kommen wieder normale Bytes


.direkt_tab:
	dc.l	$03ff0009,$00070002,$00030001,$00030001 ; Anzahl 1-Bits
.tabellen:dc.l	    15-1,      8-1,      5-1,      2-1	; Anz. Bytes

.offset_table:
	dc.w	 3,	      0
	dc.w	 7,	   16+0
	dc.w	11,      256+16+0
	dc.w	15, 4096+256+16+0
.more_table:
	dc.w	3,       5
	dc.w	5,    16+5
	dc.w	7, 64+16+5

ende_fire_decrunch_2:
;*************************************************** Ende der Unpackroutine

* This is the speed packer version 3 depacker.
* Ripped from the Missing Link Extension from Billy (Ha HA ....)

speed3:
L0219:
	MOVEQ   #0,D0 
	MOVEM.L A0-A6/D0-D7,-(A7) 
	LEA     L024D(PC),A6
	MOVEA.L A0,A1 
	CMPI.L  #"SPv3",(A1)+
	BNE.S   L021B 
	TST.W   (A1)
	BNE.S   L021B 
	MOVE.L  (A1)+,D5
	MOVE.L  (A1)+,D0
	MOVE.L  (A1)+,(A7)
	MOVEA.L A0,A2 
	ADDA.L  D0,A0 
	MOVE.L  -(A0),-(A1) 
	MOVE.L  -(A0),-(A1) 
	MOVE.L  -(A0),-(A1) 
	MOVE.L  -(A0),-(A1) 
	ADDA.L  (A7),A1 
  	LEA     402(A6),A3
 	 MOVEQ   #$7F,D0 
L021A:	MOVE.L  (A2)+,(A3)+ 
  	DBF     D0,L021A
  	SUBA.L  A2,A3 
  	MOVE.L  A3,-(A7)
  	BSR.S   L021C 
  	BSR     L022E 
  	MOVE.B  -(A0),D0
  	ADDA.L  (A7)+,A0
  	MOVE.B  D0,(A0)+
  	LEA     402(A6),A2
  	BSR     L022F 
  	BSR     L0228 
L021B:	MOVEM.L (A7)+,A0-A6/D0-D7 
 	RTS 
L021C:	MOVE    SR,D1 
  	ANDI.W  #$2000,D1 
  	BEQ.S   L021D 
  	MOVE.W  -$7DC0,2(A6)
  	BTST    #1,-$7DA0 
  	BNE.S   L021D 
  	SWAP    D5
L021D:	CLR.W   D5
  	MOVE.W  -(A0),D6
  	LEA     4(A6),A3
  	MOVE.B  D6,(A3)+
  	MOVEQ   #1,D3 
  	MOVEQ   #6,D4 
L021E:	CMP.B   D6,D3 
  	BNE.S   L021F 
  	ADDQ.W  #2,D3 
L021F:	MOVE.B  D3,(A3)+
  	ADDQ.W  #2,D3 
  	DBF     D4,L021E
  	MOVEQ   #$10,D4 
  	MOVE.B  -(A0),(A3)+ 
  	MOVE.B  D4,(A3)+
  	MOVE.B  -(A0),(A3)+ 
  	MOVE.B  D4,(A3)+
  	MOVE.B  -(A0),D4
  	MOVE.W  D4,(A6) 
  	LEA     273(A6),A5
  	MOVE.B  -(A0),D4
  	LEA     1(A5,D4.W),A3 
L0220:	MOVE.B  -(A0),-(A3) 
  	DBF     D4,L0220
  	MOVE.B  -(A0),-(A3) 
  	BEQ.S   L0221 
  	SUBA.W  D4,A0 
L0221:	MOVEQ   #0,D2 
  	MOVE.B  -(A0),D2
  	MOVE.W  D2,D3 
  	MOVE.B  -(A0),D7
L0222:	BSR.S   L0223 
  	BSR.S   L0223 
  	DBF     D2,L0222
  	RTS 
L0223:	NOT.W   D4
  	ADD.B   D7,D7 
  	BNE.S   L0224 
  	MOVE.B  -(A0),D7
  	ADDX.B  D7,D7 
L0224:	BCS.S   L0225 
  	MOVE.W  D2,D0 
  	SUBQ.W  #1,D3 
  	SUB.W   D3,D0 
  	ADD.W   D0,D0 
  	ADD.W   D4,D0 
  	ADD.W   D0,D0 
  	NEG.W   D0
  	MOVE.W  D0,-(A3)
  	RTS 
L0225:	MOVEQ   #2,D1 
  	BSR     L0245 
  	ADD.W   D0,D0 
  	BEQ.S   L0226 
  	MOVE.B  D0,-(A3)
  	MOVEQ   #2,D1 
  	BSR     L0245 
  	ADD.W   D0,D0 
  	MOVE.B  D0,-(A3)
  	RTS 
L0226:	MOVEQ   #2,D1 
  	BSR     L0245 
  	MOVE.W  12(A6),D1 
  	ADD.W   D0,D0 
  	BEQ.S   L0227 
  	MOVE.W  14(A6),D1 
L0227:	OR.W    D1,D0 
  	MOVE.W  D0,-(A3)
  	RTS 
L0228:	MOVE    SR,D1 
  	ANDI.W  #$2000,D1 
  	BEQ.S   L0229 
  	MOVE.W  2(A6),-$7DC0
L0229:	TST.W   D6
  	BPL.S   L022D 
  	MOVEA.L A1,A2 
  	MOVEA.L A1,A3 
  	ADDA.L  4(A7),A3
L022A:	MOVEQ   #3,D6 
L022B:	MOVE.W  (A2)+,D0
  	MOVEQ   #3,D5 
L022C:	ADD.W   D0,D0 
  	ADDX.W  D1,D1 
  	ADD.W   D0,D0 
  	ADDX.W  D2,D2 
  	ADD.W   D0,D0 
  	ADDX.W  D3,D3 
  	ADD.W   D0,D0 
  	ADDX.W  D4,D4 
  	DBF     D5,L022C
  	DBF     D6,L022B
  	CMPA.L  A2,A3 
  	BLT.S   L022D 
  	MOVEM.W D1-D4,-8(A2)
  	CMPA.L  A2,A3 
  	BNE.S   L022A 
L022D:	RTS 
L022E:	MOVE.B  -(A0),-(A1) 
L022F:	SWAP    D5
  	BEQ.S   L0230 
  	MOVE.W  D5,-$7DC0
L0230:	LEA     270(A6),A3
  	CMPA.L  A0,A2 
  	BLT.S   L0232 
  	RTS 
L0231:	ADDA.W  D3,A3 
L0232:	ADD.B   D7,D7 
  	BCC.S   L0235 
  	BEQ.S   L0234 
L0233:	MOVE.W  (A3),D3 
  	BMI.S   L0231 
  	BRA.S   L0236 
L0234:	MOVE.B  -(A0),D7
  	ADDX.B  D7,D7 
  	BCS.S   L0233 
L0235:	MOVE.W  -(A3),D3
  	BMI.S   L0231 
L0236:	EXT.W   D3
  	JMP     L0237(PC,D3.W)
L0237:	BRA.S   L0237 
  	BRA.S   L0242 
  	BRA.S   L0242 
 	BRA.S   L0242 
  	BRA.S   L0242 
  	BRA.S   L0242 
  	BRA.S   L023E 
  	BRA.S   L023D 
  	BRA.S   L0239 
  	BRA.S   L023A 
  	BRA.S   L0238 
  	BRA.S   L023B 
  	BRA.S   L022E 
L0238:	MOVE.B  (A5),-(A1)
  	BRA.S   L022F 
L0239:	BSR.S   L0244 
  	MOVE.B  1(A5,D0.W),-(A1)
  	BRA.S   L022F 
L023A:	BSR.S   L0244 
 	ADD.W   (A6),D0 
  	MOVE.B  1(A5,D0.W),-(A1)
  	BRA.S   L022F 
L023B:	MOVEQ   #3,D1 
  	BSR.S   L0245 
  	LSR.W   #1,D0 
  	BCC.S   L023C 
  	NOT.W   D0
L023C:	MOVE.B  (A1),D1 
  	ADD.W   D0,D1 
  	MOVE.B  D1,-(A1)
 	BRA.S   L022F 
L023D:	LEA     -36(A6),A4
  	BSR.S   L0249 
  	ADDI.W  #$10,D0 
  	LEA     1(A1,D0.W),A3 
  	MOVE.B  -(A3),-(A1) 
  	MOVE.B  -(A3),-(A1) 
  	BRA     L022F 
L023E:	MOVEQ   #3,D1 
  	BSR.S   L0245 
  	TST.W   D0
  	BEQ.S   L023F 
  	ADDQ.W  #5,D0 
  	BRA.S   L0241 
L023F:	MOVE.B  -(A0),D0
  	BEQ.S   L0240 
  	ADDI.W  #$14,D0 
  	BRA.S   L0241 
L0240:	MOVEQ   #$D,D1
  	BSR.S   L0245 
  	ADDI.W  #$114,D0
L0241:	MOVE.W  D0,D3 
  	ADD.W   D3,D3 
L0242:	LEA     -34(A6),A4
  	BSR.S   L0249 
  	LSR.W   #1,D3 
  	LEA     1(A1,D0.W),A3 
  	MOVE.B  -(A3),-(A1) 
L0243:	MOVE.B  -(A3),-(A1) 
  	DBF     D3,L0243
  	BRA     L022F 
L0244:	MOVEQ   #0,D1 
  	MOVE.B  (A3),D1 
L0245:	MOVEQ   #0,D0 
  	CMPI.W  #7,D1 
  	BPL.S   L0248 
L0246:	ADD.B   D7,D7 
  	BEQ.S   L0247 
  	ADDX.W  D0,D0 
  	DBF     D1,L0246
  	RTS 
L0247:	MOVE.B  -(A0),D7
  	ADDX.B  D7,D7 
  	ADDX.W  D0,D0 
  	DBF     D1,L0246
  	RTS 
L0248:	MOVE.B  -(A0),D0
  	SUBQ.W  #8,D1 
  	BPL.S   L0246 
  	RTS 
L0249:	MOVEQ   #0,D1 
  	MOVE.B  (A3),D1 
  	ADDA.W  D1,A4 
  	MOVE.W  (A4),D1 
  	BSR.S   L0245 
  	TST.B   D6
  	BEQ.S   L024C 
  	MOVE.W  D0,D4 
  	ANDI.W  #-$10,D4
  	ANDI.W  #$F,D0
  	BEQ.S   L024B 
  	LSR.W   #1,D0 
  	BEQ.S   L024A 
  	ROXR.B  #1,D7 
  	BCC.S   L024B 
  	MOVE.B  D7,(A0)+
  	MOVEQ   #-$80,D7
  	BRA.S   L024B 
L024A:	MOVEQ   #2,D1 
  	BSR.S   L0245 
  	ADD.W   D0,D0 
  	OR.W    D4,D0 
  	BRA.S   L024C 
L024B:	LEA     4(A6),A3
  	OR.B    0(A3,D0.W),D4 
  	MOVE.W  D4,D0 
L024C:	ADD.W   18(A4),D0 
  	RTS 
  	DC.B   $00,$03,$00,$04,$00,$05,$00,$07
  	DC.B   $00,$08,$00,$09,$00,$0A,$00,$0B
  	DC.B   $00,$0C,$FF,$F0,$00,$00,$00,' '
  	DC.B   $00,'`',$01,'`',$03,'`',$07,'`'
  	DC.B   $0F,'`',$1F,'`'
L024D:	DS.W    457 

* End of unpacking sub routines *
