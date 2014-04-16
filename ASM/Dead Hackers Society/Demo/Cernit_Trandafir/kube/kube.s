; Altparty 2009 STe demo
; Fullscreen field of twisted kubes
;
; kube.s

		section	text

;-------------- INIT
kube_init:	rts

;-------------- RUNTIME INIT
		
		;runtime init for the single small cube
kube_runtime_init_single:
		subq.w	#1,.once
		bne.w	.done

		jsr	black_pal
		jsr	syncfix				;fix eventual bitplane corruption

		ifne	init_finish
		move.w	#$0700,$ffff8240.w
		endc


;		move.l	screen_adr,d0			;set screen
;		lsr.w	#8,d0				;
;		move.l	d0,$ffff8200.w			;

;		lea.l	kube_precalc1,a0
;		lea.l	generic_code,a1
;		jsr	lz77
		
;		move.l	screen_adr,a0
;		lea.l	generic_code+34,a1
;		move.w	#32000/4-1,d7
;.pic:		move.l	(a1)+,(a0)+
;		dbra	d7,.pic
		
;		movem.l	generic_code+2,d0-d7
;		movem.l	d0-d7,$ffff8240.w
		

		jsr	clear_32k1
		jsr	clear_64k1

		;fill up sin values for the twist
.sin:		bsr.w	kube_singen
		subq.w	#1,.sincount
		bpl.s	.sin


		;build displaylist
		lea.l	kube_displist,a0
		move.l	screen_adr2,d0
		add.l	#512,d0
		move.w	#396-1,d7
.displist1:	move.l	d0,(a0)+
		dbra	d7,.displist1

		move.l	screen_adr,d0
		add.l	#24+40+208,d0
		move.w	#72-1,d7
.displist2:	move.l	d0,(a0)+
		add.l	#208,d0
		dbra	d7,.displist2

		move.l	screen_adr2,d0
		add.l	#512,d0
		move.w	#396-1,d7
.displist3:	move.l	d0,(a0)+
		dbra	d7,.displist3

		
		lea.l	kube_ice,a0			;depack kube anim
		lea.l	kube_data,a1
		bsr.w	ice


;		jsr	black_pal
		jsr	clear_screens


		lea.l	generic_code,a0			;216 first lines animationcode: 3 scans code per copy repeated 72 times = 216 lines total
		move.l	#kube_code1single_end,d0		;
		sub.l	#kube_code1single_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#71-1,d7
.code1a:	move.l	d0,d6
		lea.l	kube_code1single_start,a1
.code1b:	move.w	(a1)+,(a0)+
		dbra	d6,.code1b
		dbra	d7,.code1a

		move.l	#kube_code2_end,d0		;11 lines after the anim have been copied = 11 remaining lines before lower border special code
		sub.l	#kube_code2_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#156-1,d7
.code4a:	move.l	d0,d6
		lea.l	kube_code2_start,a1
.code4b:	move.w	(a1)+,(a0)+
		dbra	d6,.code4b
		dbra	d7,.code4a

		move.l	#kube_code3_end,d0		;2 midlines lower border special case
		sub.l	#kube_code3_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#1-1,d7
.code2a:	move.l	d0,d6
		lea.l	kube_code3_start,a1
.code2b:	move.w	(a1)+,(a0)+
		dbra	d6,.code2b
		dbra	d7,.code2a

		move.l	#kube_code2_end,d0		;lower 44 lines
		sub.l	#kube_code2_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#44-1,d7
.code3a:	move.l	d0,d6
		lea.l	kube_code2_start,a1
.code3b:	move.w	(a1)+,(a0)+
		dbra	d6,.code3b
		dbra	d7,.code3a
		move.w	dummy,(a0)+			;rts


		ifne	init_finish
		move.w	#$0070,$ffff8240.w
		endc

.done:		rts
.once:		dc.w	1
.sincount:	dc.w	100


		;runtime init for the full field of cubes, requires kube_runtime_init to have been run before!
kube_runtime_init_field:
		subq.w	#1,.once
		bne.w	.done

		jsr	black_pal
		;jsr	clear_screens
		;jsr	syncfix				;fix eventual bitplane corruption

		ifne	init_finish
		move.w	#$0700,$ffff8240.w
		endc

;		move.l	screen_adr,d0			;set screen
;		lsr.w	#8,d0				;
;		move.l	d0,$ffff8200.w			;

;		lea.l	kube_precalc2,a0
;		lea.l	generic_code,a1
;		jsr	lz77
		
;		move.l	screen_adr,a0
;		lea.l	generic_code+34,a1
;		move.w	#32000/4-1,d7
;.pic:		move.l	(a1)+,(a0)+
;		dbra	d7,.pic
		
;		movem.l	generic_code+2,d0-d7
;		movem.l	d0-d7,$ffff8240.w
		


		lea.l	kube_blackpal,a0
		rept	8
		clr.l	(a0)+
		endr

		lea.l	kube_ice,a0			;depack kube anim
		lea.l	kube_data,a1
		bsr.w	ice

		;build displaylist
		lea.l	kube_displist,a0
		move.l	screen_adr,d0
		add.l	#24+40+208,d0
		move.w	#72-1,d7
.displist1:	move.l	d0,432*4(a0)
		move.l	d0,(a0)+
		add.l	#288,d0
		dbra	d7,.displist1

		move.l	screen_adr,d0
		add.l	#0+40+208,d0
		move.w	#72-1,d7
.displist2:	move.l	d0,432*4(a0)
		move.l	d0,(a0)+
		add.l	#288,d0
		dbra	d7,.displist2

		move.l	screen_adr,d0
		add.l	#24+40+208,d0
		move.w	#72-1,d7
.displist3:	move.l	d0,432*4(a0)
		move.l	d0,(a0)+
		add.l	#288,d0
		dbra	d7,.displist3

		move.l	screen_adr,d0
		add.l	#0+40+208,d0
		move.w	#72-1,d7
.displist4:	move.l	d0,432*4(a0)
		move.l	d0,(a0)+
		add.l	#288,d0
		dbra	d7,.displist4

		move.l	screen_adr,d0
		add.l	#24+40+208,d0
		move.w	#72-1,d7
.displist5:	move.l	d0,432*4(a0)
		move.l	d0,(a0)+
		add.l	#288,d0
		dbra	d7,.displist5

		move.l	screen_adr,d0
		add.l	#40+208,d0
		move.w	#72-1,d7
.displist6:	move.l	d0,432*4(a0)
		move.l	d0,(a0)+
		add.l	#288,d0
		dbra	d7,.displist6

;		jsr	black_pal
		jsr	clear_screens


		lea.l	generic_code,a0			;216 first lines animationcode: 3 scans code per copy repeated 72 times = 216 lines total
		move.l	#kube_code1_end,d0		;
		sub.l	#kube_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#71-1,d7
.code1a:	move.l	d0,d6
		lea.l	kube_code1_start,a1
.code1b:	move.w	(a1)+,(a0)+
		dbra	d6,.code1b
		dbra	d7,.code1a

		move.l	#kube_code2_end,d0		;11 lines after the anim have been copied = 11 remaining lines before lower border special code
		sub.l	#kube_code2_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#14-1,d7
.code4a:	move.l	d0,d6
		lea.l	kube_code2_start,a1
.code4b:	move.w	(a1)+,(a0)+
		dbra	d6,.code4b
		dbra	d7,.code4a

		move.l	#kube_code3_end,d0		;2 midlines lower border special case
		sub.l	#kube_code3_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#1-1,d7
.code2a:	move.l	d0,d6
		lea.l	kube_code3_start,a1
.code2b:	move.w	(a1)+,(a0)+
		dbra	d6,.code2b
		dbra	d7,.code2a

		move.l	#kube_code2_end,d0		;lower 44 lines
		sub.l	#kube_code2_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#44-1,d7
.code3a:	move.l	d0,d6
		lea.l	kube_code2_start,a1
.code3b:	move.w	(a1)+,(a0)+
		dbra	d6,.code3b
		dbra	d7,.code3a
		move.w	dummy,(a0)+			;rts


		ifne	init_finish
		move.w	#$0070,$ffff8240.w
		endc

.done:		rts
.once:		dc.w	1

		;runtime init for the 12bit zoomed up version, needs kube_runtime_init_single to have been run first
kube_runtime_init_12bit:
		subq.w	#1,.once
		bne.w	.done

		;jsr	clear_screens
		;jsr	syncfix				;fix eventual bitplane corruption
		jsr	white_pal

		ifne	init_finish
		move.w	#$0700,$ffff8240.w
		endc

		;clear chunky
		jsr	clear_32k1
		
		clr.w	kube_rasterofs
		
		;convert 4bpl animation to 12bit hicolour and scale it by 50%
		lea.l	kube_data,a0
		lea.l	kube_pal,a2
		move.l	a0,a3

		move.w	#36*80-1,.ycnt
.y:
		lea.l	.tmpline,a1
		move.w	#96/16-1,d7
.x:
		movem.w	(a0)+,d3-d6
		rept	8
		clr.w	d2
		add.w	d6,d6
		add.w	d6,d6
		addx.w	d2,d2
		add.w	d5,d5
		add.w	d5,d5
		addx.w	d2,d2
		add.w	d4,d4
		add.w	d4,d4
		addx.w	d2,d2
		add.w	d3,d3
		add.w	d3,d3
		addx.w	d2,d2
		add.w	d2,d2
		move.w	(a2,d2.w),(a1)+
		endr

		dbra	d7,.x

		lea.l	48(a0),a0
		move.w	#96/4-1,d0
		lea.l	.tmpline,a1
.cpytmp:	move.l	(a1)+,(a3)+
		dbra	d0,.cpytmp
		subq.w	#1,.ycnt
		bge	.y

		;generate "displaylist" for 12bit mode
		lea.l	kube_displist12bit,a0
		lea.l	kube_chunky,a1
		move.w	#28-1,d7
.displist:	rept	10
		move.l	a1,(a0)+
		endr
		lea.l	72(a1),a1
		dbra	d7,.displist
		
		;copy synclock raster code
		lea.l	generic_code,a0
		move.l	#kube_code12bit_end,d0
		sub.l	#kube_code12bit_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#273-1,d7
.code1a:	move.l	d0,d6
		lea.l	kube_code12bit_start,a1
.code1b:	move.w	(a1)+,(a0)+
		dbra	d6,.code1b
		dbra	d7,.code1a
		move.w	dummy,(a0)+			;rts


		ifne	init_finish
		move.w	#$0070,$ffff8240.w
		endc

.done:		rts
.once:		dc.w	1
.tmpline:	ds.l	48
.xcnt		dc.w	0
.ycnt		dc.w	0

kube_runtime_exit:
		bsr.w	black_pal
		clr.b	$ffff820f.w
		clr.b	$ffff8265.w
		rts


;-------------- VBL

kube_vbl:	move.l	empty_adr,d0
		lea.l	$ffff8203.w,a0
		movep.l	d0,0(a0)

		movem.l	kube_blackpal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		lea.l	kube_blackpal,a0
		lea.l	kube_pal,a1
		jsr	component_fade

		cmp.w	#273*2,kube_rasterofs
		bge.s	.rasters_done
		addq.w	#2,kube_rasterofs
.rasters_done:
		bsr.w	kube_xymove
		bsr.w	kube_singen
		bsr.w	kube_rasterbar
		rts

kube_vbl_out:	move.l	empty_adr,d0
		lea.l	$ffff8203.w,a0
		movep.l	d0,0(a0)

		clr.w	$ffff8240.w

		subq.w	#1,.wait
		bne.s	.nofade
		move.w	#2,.wait
		
		movem.l	kube_blackpal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		lea.l	kube_blackpal,a0
		lea.l	kube_blackpal2,a1
		jsr	component_fade
.nofade:
		cmp.w	#3,kube_rasterofs
		ble.s	.rasters_done
		subq.w	#4,kube_rasterofs
.rasters_done:
		bsr.w	kube_xymove
		bsr.w	kube_singen
		bsr.w	kube_rasterbar
		rts
.wait:		dc.w	1


kube_vbl_single:
		move.l	empty_adr,d0
		lea.l	$ffff8203.w,a0
		movep.l	d0,0(a0)

		movem.l	kube_blackpal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		lea.l	kube_blackpal,a0
		lea.l	kube_pal,a1
		jsr	component_fade

		bsr.w	kube_xymove
		bsr.w	kube_singen
		rts

kube_vbl_12bit_out:
		move.w	#-1,kube_12bitlines
kube_vbl_12bit:	
		move.l	screen_adr2,d0
		lea.l	$ffff8203.w,a0
		movep.l	d0,0(a0)


		clr.w	$ffff8240.w

		subq.w	#1,.lines
		bne.s	.nolines
		move.w	#4,.lines

		move.w	.linecount,d0
		cmp.w	kube_12bitlines,d0
		beq.s	.nolines
		ble.s	.addline
		subq.w	#1,.linecount
		bra.s	.nolines
.addline:	addq.w	#1,.linecount
		

.nolines:	cmp.l	#96*36*79,kube_12bitofs
		blt.s	.add
		clr.l	kube_12bitofs
		bra.s	.ofsdone
.add:		add.l	#96*36,kube_12bitofs
.ofsdone:
		;copy the curent frame to offscreen buffer
		lea.l	kube_chunky,a0
		lea.l	kube_data+8+96*4,a1
		add.l	kube_12bitofs,a1
		;move.w	#28-1,d7
		move.w	.linecount,d7
		cmp.w	#-1,d7
		beq.s	.done
.copy:		rept	18
		move.l	(a1)+,(a0)+
		endr
		lea.l	96-72(a1),a1
		dbra	d7,.copy
.done:		moveq.l	#0,d0
		rept	18
		move.l	d0,(a0)+
		endr
		rts
.lines:		dc.w	4
.linecount:	dc.w	0

kube_12bitlines:	dc.w	35

kube_fadein12bit:
		subq.w	#1,.wait
		bne.s	.no
		move.w	#2,.wait
		movem.l	.pal1,d0-d7
		movem.l	d0-d7,$ffff8240.w
		lea.l	.pal1,a0
		lea.l	.pal2,a1
		jsr	component_fade
.no:		rts
.pal1:		dcb.w	16,$0fff
.pal2:		dcb.w	16,$0000
.wait:		dc.w	1

kube_singen:	
		;first sinlist
		add.l   #20,.sin1
		and.l   #$1fff,.sin1
		lea.l	sincos4000,a0
		move.l  .sin1,d0
		move.w  (a0,d0.l),d1
		muls.w  #64,d1
		asr.l   #8,d1
		asr.l   #7,d1
		asl.w	#2,d1
		lea.l	kube_multab+4*40,a0
		move.l	(a0,d1.w),d1
		
		lea.l	kube_sinlist,a0
		add.w	kube_listofs,a0
		move.l	d1,(a0)
		move.l	d1,100*4(a0)

		;second sinlist
		add.l   #132,.sin2
		and.l   #$1fff,.sin2
		lea.l	sincos4000,a0
		move.l  .sin2,d0
		move.w  (a0,d0.l),d2
		muls.w  #15,d2
		asr.l   #8,d2
		asr.l   #7,d2
		asl.w	#2,d2
		lea.l	kube_multab+4*40,a0
		move.l	(a0,d2.w),d2

		lea.l	kube_sinlist2,a0
		add.w	kube_listofs,a0
		move.l	d2,(a0)
		move.l	d2,100*4(a0)
		
		cmp.w	#4*99,kube_listofs
		blt.s	.add
		move.w	#-4,kube_listofs
.add:		addq.w	#4,kube_listofs
		rts
.sin1:		dc.l	0
.sin2:		dc.l	0
kube_listofs:	dc.w	0
kube_sinlist:	ds.l	200
kube_sinlist2:	ds.l	200


kube_xymove:
		add.l   #44,.sinx
		and.l   #$1fff,.sinx
		lea.l	sincos4000,a0
		move.l  .sinx,d0
		move.w  (a0,d0.l),d1
		muls.w  #319,d1	;159
		asr.l   #8,d1
		asr.l   #7,d1
		move.l	d1,d2
		and.l	#$fffffff0,d1
		asr.l	#1,d1
		move.l	d1,kube_xofs

		and.w	#$000f,d2
		move.b	d2,kube_hscroll
		
		add.l   #22,.siny
		and.l   #$1fff,.siny
		lea.l	sincos4000,a0
		move.l  .siny,d0
		move.w  (a0,d0.l),d1
		muls.w  #256,d1
		asr.l   #8,d1
		asr.l   #7,d1
		asl.l	#2,d1
		move.l	d1,kube_displistofs

		rts
.sinx:		dc.l	0
.siny:		dc.l	0


kube_rasterbar:
		lea.l	kube_rasters+273*2,a0
		moveq.l	#0,d0
		rept	272/2
		move.l	d0,(a0)+
		endr
		move.w	d0,(a0)+
		
		lea.l	.poslist,a0
		move.l	(a0),d0
		rept	63
		move.l	4(a0),(a0)+
		endr
		move.l	d0,(a0)

		add.l   #48,.sin1
		and.l   #$1fff,.sin1
		lea.l	sincos4000,a0
		move.l  .sin1,d0
		move.w  (a0,d0.l),d1
		muls.w  #208,d1
		asr.l   #8,d1
		asr.l   #7,d1
		asl.l	#1,d1
		move.l	d1,.poslist

		lea.l	kube_rasterpal,a6
		lea.l	kube_rasters+273*2+(274*2/2)-(64*2/2),a5
		add.l	.poslist+16*4,a5
		movem.l	(a6)+,d0-a4	;26 cols
		movem.l	d0-a4,(a5)
		movem.l	(a6)+,d0-a4	;52 cols
		movem.l	d0-a4,26*2(a5)
		movem.l	(a6)+,d0-d5	;64 cols
		movem.l	d0-d5,52*2(a5)
		
		lea.l	kube_rasterpal,a6
		lea.l	kube_rasters+273*2+(274*2/2)-(64*2/2),a5
		add.l	.poslist+32*4,a5
		movem.l	(a6)+,d0-a4	;26 cols
		movem.l	d0-a4,(a5)
		movem.l	(a6)+,d0-a4	;52 cols
		movem.l	d0-a4,26*2(a5)
		movem.l	(a6)+,d0-d5	;64 cols
		movem.l	d0-d5,52*2(a5)

		lea.l	kube_rasterpal,a6
		lea.l	kube_rasters+273*2+(274*2/2)-(64*2/2),a5
		add.l	.poslist+48*4,a5
		movem.l	(a6)+,d0-a4	;26 cols
		movem.l	d0-a4,(a5)
		movem.l	(a6)+,d0-a4	;52 cols
		movem.l	d0-a4,26*2(a5)
		movem.l	(a6)+,d0-d5	;64 cols
		movem.l	d0-d5,52*2(a5)

		lea.l	kube_rasterpal,a6
		lea.l	kube_rasters+273*2+(274*2/2)-(64*2/2),a5
		add.l	.poslist,a5
		movem.l	(a6)+,d0-a4	;26 cols
		movem.l	d0-a4,(a5)
		movem.l	(a6)+,d0-a4	;52 cols
		movem.l	d0-a4,26*2(a5)
		movem.l	(a6)+,d0-d5	;64 cols
		movem.l	d0-d5,52*2(a5)
		

		rts
.sin1:		dc.l	0

.poslist:	ds.l	64



;-------------- MAIN
kube_main:
		rts



;-------------- TIMER A
kube_timer_a:	
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		clr.b	$fffffa19.w


		movem.l d0-a6,-(sp)
		dcb.w 	52-25,$4e71


		moveq.l	#2,d7				;1 for overscan
		lea.l	$ffff8203.w,a6			;2 screen address counter
		lea.l	kube_displist+295*4,a5		;3 list of screen addresses
		add.l	kube_displistofs,a5		;6 offset to current offset (y scrolling)
		move.l	(a5)+,d0			;3 get address to set for first line
		move.l	screen_adr,a4			;5 address where to write the cube datas
		lea.l	208(a4),a4			;2
		lea.l	kube_data+48*72*40,a3		;3 source data

		move.b	#0,$ffff820a.w			;remove top border
		dcb.w 	6,$4e71
		lea.l	$ffff8209.w,a0			;2
		moveq.l	#127,d1				;1 = 9 nops wait for top border zap
		move.b	#2,$ffff820a.w


.sync:		tst.b	(a0)				;hardsync
		beq.s	.sync				;
		move.b	(a0),d2				;
		sub.b	d2,d1				;
		lsr.l	d1,d1				;


		dcb.w 	66-49,$4e71	

		lea.l	kube_sinlist,a2			;3 sinwave 1
		lea.l	kube_sinlist2+99*4,a1		;3 sinwave 2
		add.w	kube_listofs,a1			;5 current sinwave positions
		add.w	kube_listofs,a2			;5 

		move.l	kube_xofs,d6			;5 static x-scroll value (16px accuracy)
		add.l	d6,d0				;2 add x-scroll to screen address

		lea.l	48(a3),a0			;2 next line of cube source data
		move.l	a0,d5				;1 store the address
		add.l	(a2)+,a3			;4 add sinwave 1
		add.l	-(a1),a3			;5 add sinwave 2

		lea.l	kube_rasters,a0			;3 list of colours
		add.w	kube_rasterofs,a0		;5
		move.b	kube_hscroll,$ffff8265.w	;6 set x-finescroll

		jsr	generic_code			;5 let's get it on!

		clr.b	$ffff8265.w
		clr.w	$ffff8240.w
		
		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts


kube_code1single_start:
		movep.l	d0,0(a6)			;6 set screenpointer
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		dcb.w	90-81,$4e71

		movem.l	(a3)+,d1-d4			;11 copy 32px cube data to six destinations
		movem.l	d1-d4,144(a4)			;11
		movem.l	(a3)+,d1-d4			;11 copy 32px cube data to six destinations
		movem.l	d1-d4,160(a4)			;11
		movem.l	(a3)+,d1-d4			;11 copy 32px cube data to six destinations
		movem.l	d1-d4,176(a4)			;11
		lea.l	208(a4),a4			;2

		add.l	#48,d5				;4 next line of kube source data
		move.l	d5,a3				;1 restore twist offset
		add.l	(a2)+,a3			;4 add sinwave 1 for twist
		add.l	-(a1),a3			;4 add sinwave 2 for twist

		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	20-13,$4e71
		move.l	(a5)+,d0			;3 next display address
		add.l	d6,d0				;2 static x-scroll
		move.w	(a0),$ffff8240.w		;4
		move.w	(a0)+,$ffff8250.w		;4

kube_code1single_end:

kube_code1_start:
		;Code for copy the cube
		;scan 1
		movep.l	d0,0(a6)			;6 set screenpointer
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		dcb.w	90-80,$4e71
		movem.l	(a3)+,d1-d4			;11 copy 32px cube data to six destinations
		movem.l	d1-d4,(a4)			;10
		movem.l	d1-d4,96(a4)			;11
		movem.l	d1-d4,192(a4)			;11
		or.w	#$ffff,d2			;2 add overlay mask in 4th bitplane for every second cube
		or.w	#$ffff,d4			;2
		movem.l	d1-d4,48(a4)			;11
		movem.l	d1-d4,144(a4)			;11
		movem.l	d1-d4,240(a4)			;11 =76
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	20-13,$4e71
		move.l	(a5)+,d0			;3 next display address
		add.l	d6,d0				;2 static x-scroll
		move.w	(a0),$ffff8240.w		;4
		move.w	(a0)+,$ffff8250.w		;4

		;scan 2
		movep.l	d0,0(a6)			;6 set screenpointer
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		dcb.w	90-81,$4e71
		movem.l	(a3)+,d1-d4			;11 copy 32px cube data to six destinations
		movem.l	d1-d4,16(a4)			;11
		movem.l	d1-d4,16+96(a4)			;11
		movem.l	d1-d4,16+192(a4)		;11
		or.w	#$ffff,d2			;2 add overlay mask in 4th bitplane for every second cube
		or.w	#$ffff,d4			;2
		movem.l	d1-d4,16+48(a4)			;11
		movem.l	d1-d4,16+144(a4)		;11
		movem.l	d1-d4,16+240(a4)		;11 =77
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	20-13,$4e71
		move.l	(a5)+,d0			;3 next display address
		add.l	d6,d0				;2 static x-scroll
		move.w	(a0),$ffff8240.w		;4
		move.w	(a0)+,$ffff8250.w		;4


		;scan 3
		movep.l	d0,0(a6)			;6 set screenpointer
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		;dcb.w	90-86,$4e71
		movem.l	(a3)+,d1-d4			;11 copy 32px cube data to six destinations
		movem.l	d1-d4,32(a4)			;11
		movem.l	d1-d4,32+96(a4)			;11
		movem.l	d1-d4,32+192(a4)		;11
		or.w	#$ffff,d2			;2 add overlay mask in 4th bitplane for every second cube
		or.w	#$ffff,d4			;2
		movem.l	d1-d4,32+48(a4)			;11
		movem.l	d1-d4,32+144(a4)		;11
		movem.l	d1-d4,32+240(a4)		;11 =77
		lea.l	288(a4),a4			;2 next scanline for destination buffer
		move.l	(a5)+,d0			;3 next display address
		add.l	#48,d5				;4 next line of kube source data
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	1,$4e71
		add.l	d6,d0				;2 static x-scroll
		move.l	d5,a3				;1 restore twist offset
		add.l	(a2)+,a3			;4 add sinwave 1 for twist
		add.l	-(a1),a3			;4 add sinwave 2 for twist
		move.w	(a0),$ffff8240.w		;4 rasters
		move.w	(a0)+,$ffff8250.w		;4 rasters


kube_code1_end:

kube_code2_start:
		;empty code (display only)
		movep.l	d0,0(a6)			;6 set screenpointer
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		dcb.w	90,$4e71
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	20-13,$4e71
		move.l	(a5)+,d0			;3 next display address
		add.l	d6,d0				;2 static x-scroll
		move.w	(a0),$ffff8240.w		;4 rasters
		move.w	(a0)+,$ffff8250.w		;4 rasters

kube_code2_end:

kube_code3_start:
		;code for special case lower border
		movep.l	d0,0(a6)			;6 set screenpointer
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		dcb.w	90-5,$4e71
		move.l	(a5)+,d0			;3 next display address
		add.l	d6,d0				;2 static x-scroll
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	20-11,$4e71
		move.w	(a0),$ffff8240.w		;4 rasters
		move.w	(a0)+,$ffff8250.w		;4 rasters
		movep.l	d0,0(a6)			;3+3 on next line set screenpointer (special case)
;line 229	;3 nops from previous line
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	87-5,$4e71
		move.l	(a5)+,d0			;3 next display address
		add.l	d6,d0				;2 static x-scroll
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	20-8,$4e71
		move.w	(a0),$ffff8240.w		;4 rasters
		move.w	(a0)+,$ffff8250.w		;4 rasters
kube_code3_end:



		;12bit truecolour version
kube_timer_a_12bit:
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		clr.b	$fffffa19.w


		movem.l d0-a6,-(sp)
		dcb.w 	52,$4e71

		move.b	#0,$ffff820a.w			;remove top border
		dcb.w 	6,$4e71
		lea.l	$ffff8209.w,a0			;2
		moveq.l	#127,d1				;1 = 9 nops wait for top border zap
		move.b	#2,$ffff820a.w


.sync:		tst.b	(a0)				;hardsync
		beq.s	.sync				;
		move.b	(a0),d2				;
		sub.b	d2,d1				;
		lsr.l	d1,d1				;


		dcb.w 	66-10,$4e71	

		lea.l	$ffff8240.w,a6			;2
		lea.l	kube_displist12bit,a5		;3
		;add.l	kube_12bitofs,a5		;6

		jsr	generic_code			;5 let's get it on!

		clr.w	$ffff8240.w

		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts

kube_code12bit_start:
		dcb.w	10,$4e71
		move.l	(a5)+,a4			;3
		rept	36
		move.w	(a4)+,(a6)			;3*36=108
		endr
		dcb.w	7,$4e71
kube_code12bit_end:


		section	data

kube_rasterofs:		dc.w	0
kube_12bitofs:		dc.l	0
kube_hscroll:		dc.w	0
kube_xofs:		dc.l	0
kube_displistofs:	dc.l	0

kube_multab:		
q:			set	-40
			rept	80
			dc.l	q*48*72
q:			set	q+1
			endr

kube_ice:		incbin	'kube/kube.ice'
			even
;kube_precalc1:		incbin	'kube/precalc1.z77'
;			even
;kube_precalc2:		incbin	'kube/precalc2.z77'
;			even

kube_blackpal:		dcb.w	16,$0000
kube_blackpal2:		dcb.w	16,$0000
kube_pal:		dc.w	$0000,$0001,$0002,$0003,$0024,$0245,$0466,$0777
			dc.w	$0000,$0100,$0200,$0300,$0420,$0542,$0664,$0777
kube_frame:		dc.l	0

kube_rasterpal:
		dcb.l	1,$00080000
		dcb.l	1,$00080008
		dcb.l	1,$08010008
		dcb.l	1,$08010801
		dcb.l	1,$08810801
		dcb.l	1,$08810881
		dcb.l	1,$08810889
		dcb.l	1,$08810889
		dcb.l	1,$01810189
		dcb.l	1,$01190189
		dcb.l	1,$01190119
		dcb.l	1,$01190119
		dcb.l	1,$01190119
		dcb.l	1,$09120912
		dcb.l	1,$09920912
		dcb.l	1,$09920992
		dcb.l	1,$09920992
		dcb.l	1,$09920992
		dcb.l	1,$01920992
		dcb.l	1,$01920192
		dcb.l	1,$01190192
		dcb.l	1,$01190119
		dcb.l	1,$01120119
		dcb.l	1,$01130112
		dcb.l	1,$08120112
		dcb.l	1,$08130812
		dcb.l	1,$08810812
		dcb.l	1,$08890881
		dcb.l	1,$08890881
		dcb.l	1,$08890881
		dcb.l	1,$00810881
		dcb.l	1,$00810081	;32*2 colours

		
		section	text
