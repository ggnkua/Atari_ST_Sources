

		section	text

pic29k_init:	rts

pic29k_runtime_init_01:
		run_once
		init_finish_red

		jsr	black_pal
		jsr	clear_screens

		bsr	pic29k_load_data_01
		bsr	pic29k_clear_background_colours
		;bsr	pic29k_copy_gfx

		init_finish_green

		rts

pic29k_runtime_init_02:
		run_once
		init_finish_red

		jsr	black_pal
		jsr	clear_screens

		bsr	pic29k_load_data_02
		bsr	pic29k_clear_background_colours
		;bsr	pic29k_copy_gfx

		init_finish_green

		rts





pic29k_vbl:
		move.l	screen_adr,d0			;set screen
		lsr.w	#8,d0				;
		move.l	d0,$ffff8200.w			;

		move.l	screen_adr2,d0
		lea	$ffff8203.w,a0
		movep.l	d0,0(a0)

		clr.w	$ffff8240.w

		
		move.l	screen_adr,d0
		move.l	screen_adr2,screen_adr
		move.l	d0,screen_adr2

		move.l	pic29k_scr1,d0
		move.l	pic29k_scr2,pic29k_scr1
		move.l	d0,pic29k_scr2

		move.l	pic29k_col1,d0
		move.l	pic29k_col2,pic29k_col1
		move.l	d0,pic29k_col2

		rts

pic29k_fadein1_vbl:
		bsr	pic29k_vbl
		bsr	pic29k_fadein1
		rts

pic29k_fadeout1_vbl:
		bsr	pic29k_vbl
		bsr	pic29k_fadeout1
		rts

pic29k_fadein2_vbl:
		bsr	pic29k_vbl
		bsr	pic29k_fadein2
		rts

pic29k_fadeout2_vbl:
		bsr	pic29k_vbl
		bsr	pic29k_fadeout2
		rts



pic29k_main:
		rts


pic29k_ta:

		do_hardsync_top_border			;Macro to syncronize into exact cycle and remove top border

		;inits
		dcb.w	67-29,$4e71			;Time for user to set up registers etc

		moveq	#2,d7				;1

		move.l	pic29k_col1,a0			;5
		lea	$ffff8240.w,a4			;2
		move.l	a4,a1				;1
		move.w	#227-1,d5			;2

		rept	8				;set first palette
		move.l	(a0)+,(a1)+			;40
		endr



;		line 1-227
.speclines:	dcb.w	2,$4e71		;2
		move.l	a4,a1		;1
		move.l	a4,a2		;1
		move.l	a4,a3		;1
		rept	8
		move.l	(a0)+,(a1)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a2)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a3)+	;5*8
		endr
		dbra	d5,.speclines	;3 (4 when exit)
		
;special case line for preparing lower border
		;dcb.w	1,$4e71		;1
		move.l	a4,a5		;1 special case for next line
		move.l	a4,a1		;1
		move.l	a4,a2		;1
		move.l	a4,a3		;1
		rept	8
		move.l	(a0)+,(a1)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a2)+	;5*8
		endr
		move.l	(a0)+,(a3)+	;5
		move.l	(a0)+,(a3)+	;5
		move.l	(a0)+,(a3)+	;5
		move.l	(a0)+,(a3)+	;5
		move.l	(a0)+,(a3)+	;5
		move.w	d7,$ffff820a.w	;3 60Hz Kill lower border
		move.l	(a0)+,(a3)+	;5
		move.b	d7,$ffff820a.w	;3 50Hz
		move.l	(a0)+,(a3)+	;5
		move.l	(a0)+,(a3)+	;5
		;dcb.w	3,$4e71
;lower border line
		;dcb.w	2,$4e71		;2
		move.l	a4,a2		;1
		move.l	a4,a3		;1
		rept	8
		move.l	(a0)+,(a5)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a2)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a3)+	;5*8
		endr
		dcb.w	3-2,$4e71
		move.w	#44-1-1,d5	;2
		

.speclines2:	dcb.w	2,$4e71		;2
		move.l	a4,a1		;1
		move.l	a4,a2		;1
		move.l	a4,a3		;1
		rept	8
		move.l	(a0)+,(a1)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a2)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a3)+	;5*8
		endr
		dbra	d5,.speclines2	;3 (4 when exit)
	
		moveq	#0,d0
		rept	8
		move.l	d0,(a4)+
		endr
	
		move.w	#$2300,sr
		rts
		


pic29k_copy_gfx:
		move.l	screen_adr,a0
		move.l	screen_adr2,a1
		lea	160(a0),a0
		lea	160(a1),a1
		lea	buf+pic29k_p1,a2
		lea	buf+pic29k_p2,a3
		move.w	#160*273/4-1,d7
.l:		move.l	(a2)+,(a0)+
		move.l	(a3)+,(a1)+
		dbra	d7,.l
		rts

pic29k_load_data_01:
		move.l	#pic29k_fn1a,filename
		move.l	pic29k_fl1a,filelength
		move.l	#buf+pic29k_p1,filebuffer
		jsr	loader

		move.l	#pic29k_fn1b,filename
		move.l	pic29k_fl1b,filelength
		move.l	#buf+pic29k_p2,filebuffer
		jsr	loader

		rts

pic29k_load_data_02:
		move.l	#pic29k_fn2a,filename
		move.l	pic29k_fl2a,filelength
		move.l	#buf+pic29k_p1,filebuffer
		jsr	loader

		move.l	#pic29k_fn2b,filename
		move.l	pic29k_fl2b,filelength
		move.l	#buf+pic29k_p2,filebuffer
		jsr	loader

		rts


pic29k_clear_background_colours:

		move.l	pic29k_col1,a0
		move.l	pic29k_col2,a1

		move.w	#273*3-1,d7
.clrbg:		clr.w	(a0)
		clr.w	(a1)
		lea	32(a0),a0
		lea	32(a1),a1
		dbra	d7,.clrbg

		rts


pic29k_do_fadein:
;input: a0 = address to fadetab
;	d0.w = blockpos

		move.l	a0,.tab
		move.w	d0,.pos

		move.w	#2-1,.num

.l:		move.l	screen_adr,a0
		move.l	screen_adr2,a1
		lea	160(a0),a0
		lea	160(a1),a1

		move.l	pic29k_scr1,a2
		move.l	pic29k_scr2,a3


		move.w	.pos,d0
		lea	pic29k_blockofs,a4
		move.l	.tab,a5

		move.w	(a5,d0.w),d0
		lsl.w	#2,d0
		move.l	(a4,d0.w),d0

		add.l	d0,a0
		add.l	d0,a1
		add.l	d0,a2
		add.l	d0,a3

.y:		set	0
		rept	13
		move.l	.y(a2),.y(a0)
		move.l	.y+4(a2),.y+4(a0)

		move.l	.y(a3),.y(a1)
		move.l	.y+4(a3),.y+4(a1)
.y:		set	.y+160
		endr


		subq.w	#1,.num
		bpl	.l

		rts
.tab:		dc.l	0
.num:		dc.w	0
.pos:		dc.w	0


pic29k_do_fadeout:
;input: a0 = address to fadetab
;	d0.w = blockpos

		move.l	a0,.tab
		move.w	d0,.pos

		move.w	#1-1,.num

.l:		move.l	screen_adr,a0
		move.l	screen_adr2,a1
		lea	160(a0),a0
		lea	160(a1),a1

		move.w	.pos,d0
		lea	pic29k_blockofs,a4
		move.l	.tab,a5

		move.w	(a5,d0.w),d0
		lsl.w	#2,d0
		move.l	(a4,d0.w),d0

		add.l	d0,a0
		add.l	d0,a1

		moveq	#0,d0

.y:		set	0
		rept	13
		move.l	d0,.y(a0)
		move.l	d0,.y+4(a0)

		move.l	d0,.y(a1)
		move.l	d0,.y+4(a1)
.y:		set	.y+160
		endr

		subq.w	#1,.num
		bpl	.l

		rts
.tab:		dc.l	0
.num:		dc.w	0
.pos:		dc.w	0


pic29k_fadein1:
		subq.w	#2,.cnt
		bpl.s	.ok
		rts
.ok:
	rept	2
		lea	pic29k_fadetab1,a0
		move.w	.blockpos,d0
		bsr	pic29k_do_fadein
		addq.w	#2,.blockpos
	endr
		rts
.cnt:		dc.w	20*21
.blockpos:	dc.w	0

pic29k_fadeout1:
		subq.w	#1,.cnt
		bpl.s	.ok
		rts
.ok:		lea	pic29k_fadetab1,a0
		move.w	.blockpos,d0
		bsr	pic29k_do_fadeout
		addq.w	#2,.blockpos
		rts
.cnt:		dc.w	20*21
.blockpos:	dc.w	0


pic29k_fadein2:
		subq.w	#2,.cnt
		bpl.s	.ok
		rts
.ok:
	rept	2
		lea	pic29k_fadetab2,a0
		move.w	.blockpos,d0
		bsr	pic29k_do_fadein
		addq.w	#2,.blockpos
	endr
		rts
.cnt:		dc.w	20*21
.blockpos:	dc.w	0

pic29k_fadeout2:
		subq.w	#1,.cnt
		bpl.s	.ok
		rts
.ok:
	rept	4
		lea	pic29k_fadetab2,a0
		move.w	.blockpos,d0
		bsr	pic29k_do_fadeout
		addq.w	#2,.blockpos
	endr
		rts
.cnt:		dc.w	20*21
.blockpos:	dc.w	0





		section	data

pic29k_fadetab1:
		dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
		dc.w	39,59,79,99,119,139,159,179,199,219,239,259,279,299,319,339,359,379,399
		dc.w	419,400,401,402,403,404,405,406,407,408,409,410,411,412,413,414,415,416,417,418
		dc.w	20,40,60,80,100,120,140,160,180,200,220,240,260,280,300,320,340,360,380
		dc.w	21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38
		dc.w	58,78,98,118,138,158,178,198,218,238,258,278,298,318,338,358,378,398
		dc.w	381,382,383,384,385,386,387,388,389,390,391,392,393,394,395,396,397
		dc.w	41,61,81,101,121,141,161,181,201,221,241,261,281,301,321,341,361
		dc.w	42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57
		dc.w	77,97,117,137,157,177,197,217,237,257,277,297,317,337,357,377
		dc.w	362,363,364,365,366,367,368,369,370,371,372,373,374,375,376
		dc.w	62,82,102,122,142,162,182,202,222,242,262,282,302,322,342
		dc.w	63,64,65,66,67,68,69,70,71,72,73,74,75,76
		dc.w	96,116,136,156,176,196,216,236,256,276,296,316,336,356
		dc.w	343,344,345,346,347,348,349,350,351,352,353,354,355
		dc.w	83,103,123,143,163,183,203,223,243,263,283,303,323
		dc.w	84,85,86,87,88,89,90,91,92,93,94,95
		dc.w	115,135,155,175,195,215,235,255,275,295,315,335
		dc.w	324,325,326,327,328,329,330,331,332,333,334
		dc.w	104,124,144,164,184,204,224,244,264,284,304
		dc.w	105,106,107,108,109,110,111,112,113,114
		dc.w	134,154,174,194,214,234,254,274,294,314
		dc.w	305,306,307,308,309,310,311,312,313
		dc.w	125,145,165,185,205,225,245,265,285
		dc.w	126,127,128,129,130,131,132,133
		dc.w	153,173,193,213,233,253,273,293
		dc.w	286,287,288,289,290,291,292
		dc.w	146,166,186,206,226,246,266
		dc.w	147,148,149,150,151,152
		dc.w	172,192,212,232,252,272
		dc.w	267,268,269,270,271
		dc.w	167,187,207,227,247
		dc.w	168,169,170,171
		dc.w	191,211,231,251
		dc.w	248,249,250
		dc.w	188,208,228
		dc.w	189,190
		dc.w	210,230
		dc.w	209,229


pic29k_fadetab2:
		dc.w	10,30,50,70,90,110,130,150,170,190,210,230,250,270,290,310,330,350,370,390,410
		dc.w	9,29,49,69,89,109,129,149,169,189,209,229,249,269,289,309,329,349,369,389,409
		dc.w	11,31,51,71,91,111,131,151,171,191,211,231,251,271,291,311,331,351,371,391,411
		dc.w	8,28,48,68,88,108,128,148,168,188,208,228,248,268,288,308,328,348,368,388,408
		dc.w	12,32,52,72,92,112,132,152,172,192,212,232,252,272,292,312,332,352,372,392,412
		dc.w	7,27,47,67,87,107,127,147,167,187,207,227,247,267,287,307,327,347,367,387,407
		dc.w	13,33,53,73,93,113,133,153,173,193,213,233,253,273,293,313,333,353,373,393,413
		dc.w	6,26,46,66,86,106,126,146,166,186,206,226,246,266,286,306,326,346,366,386,406
		dc.w	14,34,54,74,94,114,134,154,174,194,214,234,254,274,294,314,334,354,374,394,414
		dc.w	5,25,45,65,85,105,125,145,165,185,205,225,245,265,285,305,325,345,365,385,405
		dc.w	15,35,55,75,95,115,135,155,175,195,215,235,255,275,295,315,335,355,375,395,415
		dc.w	4,24,44,64,84,104,124,144,164,184,204,224,244,264,284,304,324,344,364,384,404
		dc.w	16,36,56,76,96,116,136,156,176,196,216,236,256,276,296,316,336,356,376,396,416
		dc.w	3,23,43,63,83,103,123,143,163,183,203,223,243,263,283,303,323,343,363,383,403
		dc.w	17,37,57,77,97,117,137,157,177,197,217,237,257,277,297,317,337,357,377,397,417
		dc.w	2,22,42,62,82,102,122,142,162,182,202,222,242,262,282,302,322,342,362,382,402
		dc.w	18,38,58,78,98,118,138,158,178,198,218,238,258,278,298,318,338,358,378,398,418
		dc.w	1,21,41,61,81,101,121,141,161,181,201,221,241,261,281,301,321,341,361,381,401
		dc.w	19,39,59,79,99,119,139,159,179,199,219,239,259,279,299,319,339,359,379,399,419
		dc.w	0,20,40,60,80,100,120,140,160,180,200,220,240,260,280,300,320,340,360,380,400

		;20*21 blocks
pic29k_blockofs:
.y:		set	0
		rept	21
		dc.l	.y+0,.y+8,.y+16,.y+24,.y+32,.y+40,.y+48,.y+56,.y+64,.y+72,.y+80,.y+88,.y+96,.y+104,.y+112,.y+120,.y+128,.y+136,.y+144,.y+152
.y:		set	.y+160*13
		endr

pic29k_col1:	dc.l	buf+pic29k_p1+160*273
pic29k_col2:	dc.l	buf+pic29k_p2+160*273
pic29k_scr1:	dc.l	buf+pic29k_p1
pic29k_scr2:	dc.l	buf+pic29k_p2

pic29k_fn1a:	dc.b	'data\pic2a.29k',0
		even
pic29k_fl1a:	dc.l	69888

pic29k_fn1b:	dc.b	'data\pic2b.29k',0
		even
pic29k_fl1b:	dc.l	69888


pic29k_fn2a:	dc.b	'data\pic1a.29k',0
		even
pic29k_fl2a:	dc.l	69888

pic29k_fn2b:	dc.b	'data\pic1b.29k',0
		even
pic29k_fl2b:	dc.l	69888
			
		section	text


		rsreset
pic29k_p1:	rs.b	160*273+96*273		;gfx + palettes
pic29k_p2:	rs.b	160*273+96*273		;gfx + palettes
		
