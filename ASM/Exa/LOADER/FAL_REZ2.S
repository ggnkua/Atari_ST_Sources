config_100
	pea	init_trap(pc)
	move	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	
	move.w	#0,-(sp)
	move.l	#END_RES-CONFIG_100+1000,-(sp)
	move.w	#$31,-(sp)
	trap	#1

init_trap
	lea	buffer,a0
	move.l	a0,$40c.w	;installe adresse

	lea	buffer,a0
	move.w	#30-1,d7
.C	move.l	#-1,(a0)+
	dbra	d7,.C
	lea	excep_3(pc),a0
	move.l	a0,$80+3*4	
	rts
	
excep_3
	movem.l	d0-a6,-(sp)
	lea	buffer,a0
	lea	routs,a1
	move.w	#9,d7
.C	addq.l	#4,a1
	tst.l	(a0)+
	dbpl	d7,.C
	tst	d7
	bmi.s	.FIN
	subq.w	#1,d7
	jsr	([-4,a1])	
	bra	.C
.FIN	movem.l	(sp)+,d0-a6
	rte

routs	
	dc.l	save_screen
	dc.l	change_screen
	dc.l	restore_screen

	dc.l	save_video
	dc.l	change_video
	dc.l	restore_video

	dc.l	save_palette
	dc.l	change_palette
	dc.l	restore_palette
	dc.l	change_palette2

save_palette
	movem.l	a0/a1/d7,-(sp)
	lea	save_palette_c,a0
	lea	$fffff9800.w,a1
	move	#255,d0
.loop	move.l	(a1)+,(a0)+
	dbf	d0,.loop
	lea	$fffff8240.w,a1
	moveq	#$f,d0
.loop2	move	(a1)+,(a0)+
	dbf	d0,.loop2
	move.l	#-1,buffer+save_pal
	movem.l	(sp)+,a0/a1/d7
	rts

restore_palette
	movem.l	a0/a1/d7,-(sp)
	lea	save_palette_c(pc),a0
	lea	$fffff9800.w,a1
	move	#255,d0
.loop3
	move.l	(a0)+,(a1)+
	dbf	d0,.loop3
	lea	$fffff8240.w,a1
	moveq	#$f,d0
.loop4
	move	(a0)+,(a1)+
	dbf	d0,.loop4
	move.l	#-1,buffer+restore_pal
	movem.l	(sp)+,a0/a1/d7
	rts
	
change_palette	
	movem.l	a0/a1/d7,-(sp)
	move.l	buffer+set_pal,a0	;adresse_palette
	move.w	#255,d7
	lea	$fffff9800.w,a1
.loop5
	move.l	(a0)+,(a1)+
	dbf	d7,.loop5
	move.l	#-1,buffer+set_pal
	movem.l	(sp)+,a0/a1/d7
	rts

change_palette2	
	movem.l	a0/a1/d7,-(sp)
	move.l	buffer+set_pal2,a0	;adresse_palette
	move.w	buffer+nb_coul,d7
	subq.w	#1,d7
	move.l	buffer+debut_pal,a1
.loop5
	move.l	(a0)+,(a1)+
	dbf	d7,.loop5
	move.l	#-1,buffer+set_pal2
	move.l	#-1,buffer+debut_pal
	move.w	#-1,buffer+nb_coul
	movem.l	(sp)+,a0/a1/d7
	rts
	
save_screen
	movem.l	a0/a1/d7,-(sp)
	lea	screen_s(pc),a0
	move.b	$ffff8201.w,(a0)+
	move.b	$ffff8203.w,(a0)+
	move.b	$ffff820d.w,(a0)+
	move.l	#-1,buffer+save_log
	movem.l	(sp)+,a0/a1/d7
	rts

change_screen
	movem.l	a0/a1/d7,-(sp)
	move.l	buffer+set_log,d0
	move.b	d0,d1
	lsr.l	#8,d0
	movea	#$8200,a0
	movep.w	d0,1(a0)
	move.b	d1,$d(a0)
	move.l	#-1,buffer+set_log
	movem.l	(sp)+,a0/a1/d7
	rts

restore_screen
	movem.l	a0/a1/d7,-(sp)
	lea	screen_s(pc),a0
	move.b	(a0)+,$ffff8201.w
	move.b	(a0)+,$ffff8203.w
	move.b	(a0)+,$ffff820d.w
	move.l	#-1,buffer+restore_log
	movem.l	(sp)+,a0/a1/d7
	rts
	
	
change_video
	movem.l	a0/a1/d7,-(sp)
	lea	table_ecran(pc),a0
	move.l	buffer+set_reso,d0
	move.l	(a0,d0*4),a0
rest
	movea	#$8282,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	movea	#$82a2,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move	(a0)+,$fffff820e.w	
	move	(a0)+,$fffff8210.w	
	move	(a0)+,$fffff82c2.w	
	move	(a0)+,$fffff82c0.w	
	move	(a0)+,$fffff8266.w	
	move.l	#-1,buffer+set_reso
	movem.l	(sp)+,a0/a1/d7
	rts
	
save_video
	movem.l	a0/a1/d7,-(sp)
	lea	save_v_buffer(pc),a1
	movea	#$8282,a0
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	movea	#$82a2,a0
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move	$fffff820e.w,(a1)+	
	move	$fffff8210.w,(a1)+	
	move	$fffff82c2.w,(a1)+	
	move	$fffff82c0.w,(a1)+	
	move	$fffff8266.w,(a1)+	
	move.l	#-1,buffer+save_reso
	movem.l	(sp)+,a0/a1/d7
	rts
	
restore_video
	movem.l	a0/a1/d7,-(sp)
	lea	save_v_buffer(pc),a0
	movea	#$8282,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	movea	#$82a2,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move	(a0)+,$fffff820e.w	
	move	(a0)+,$fffff8210.w	
	move	(a0)+,$fffff82c2.w	
	move	(a0)+,$fffff82c0.w	
	move	(a0)+,$fffff8266.w	
	move.l	#-1,buffer+restore_reso
	movem.l	(sp)+,a0/a1/d7
	rts
	
	
	

table_ecran
	dc.l	mode_16_overscan
	dc.l	mode_256_overscan
	dc.l	mode_65000_overscan
	dc.l	mode_65000_overscan_60_hz
	dc.l	mode_65000
	dc.l	mode_65000_320x256
	dc.l	mode_65000_384x256
	dc.l	mode_256_320x256
	dc.l	mode_65000_mod_100pix
	dc.l	mode_16_768x512	;~
	dc.l	mode_65000_320x274	;10
	dc.l	mode_65000_768x480	;11

mode_65000_mod_100pix
	dc	$fe
	dc	$cb
	dc	$27
	dc	$2e
	dc	$8f
	dc	$d8
	
	dc	$271
	dc	$265
	dc	$2f
	dc	$7f
	dc	$20f
	dc	$26b
	
	dc	100
	dc	$140
	dc	$0
	dc	$181
	dc	$100


mode_16_overscan
	dc	$fe
	dc	$cb
	dc	$27
	dc	$2ec
	dc	$8d
	dc	$d8
	
	dc	$271
	dc	$265
	dc	$2f
	dc	$57
	dc	$237
	dc	$26b
	
	dc	0
	dc	$60
	dc	$0
	dc	$181
	dc	$1

mode_256_overscan
	dc	$fe
	dc	$cb
	dc	$27
	dc	$2fc
	dc	$9d
	dc	$d8
	
	dc	$271
	dc	$265
	dc	$2f
	dc	$57
	dc	$237
	dc	$26b

	
	dc	0
	dc	$c0
	dc	$0
	dc	$181
	dc	$10

mode_65000_overscan
	dc	$fe
	dc	$cb
	dc	$27
	dc	$e
	dc	$af
	dc	$d8
	
	dc	$271
	dc	$265
	dc	$2f
	dc	$57
	dc	$237
	dc	$26b
	
	dc	0
	dc	$180
	dc	$0
	dc	$181
	dc	$100
mode_65000_overscan_60_hz
	dc	$fe
	dc	$c9
	dc	$27
	dc	$e
	dc	$af
	dc	$d8
	
	dc	$20d
	dc	$201
	dc	$16
	dc	$25
	dc	$205
	dc	$207
	
	dc	0
	dc	$180
	dc	$0
	dc	$181
	dc	$100

mode_65000
	dc	$fe
	dc	$cb
	dc	$27
	dc	$2e
	dc	$8f
	dc	$d8
	
	dc	$271
	dc	$265
	dc	$2f
	dc	$7f
	dc	$20f
	dc	$26b
	
	dc	0
	dc	$140
	dc	$0
	dc	$181
	dc	$100

mode_65000_320x256
	dc	$fe
	dc	$cb
	dc	$27
	dc	$2e
	dc	$8f
	dc	$d8
	
	dc	$271
	dc	$265
	dc	$2f
	dc	$47
	dc	$247
	dc	$26b
	
	dc	0
	dc	$140
	dc	$0
	dc	$181
	dc	$100

mode_65000_384x256
	dc	$fe
	dc	$cb
	dc	$27
	dc	$e
	dc	$af
	dc	$d8
	
	dc	$271
	dc	$265
	dc	$2f
	dc	$47
	dc	$247
	dc	$26b
	
	dc	0
	dc	$180
	dc	$0
	dc	$181
	dc	$100

mode_256_320x256
	dc	$fe
	dc	$cb
	dc	$27
	dc	$1c
	dc	$7d
	dc	$d8
	
	dc	$271
	dc	$265
	dc	$2f
	dc	$47
	dc	$247
	dc	$26b
	
	dc	0
	dc	$a0
	dc	$0
	dc	$181
	dc	$10
	
mode_16_768x512

	dc	$1fe
	dc	$199
	dc	$50
	dc	$d
	dc	$13e
	dc	$1b2
	
	dc	$270
	dc	$265
	dc	$2f
	dc	$56
	dc	$236
	dc	$26b
	
	dc	$0
	dc	$a0
	dc	$0
	dc	$181
	dc	$4

mode_65000_320x274
	dc	$fe
	dc	$cb
	dc	$27
	dc	$2e
	dc	$8f
	dc	$d8
	
	dc	$271
	dc	$265
	dc	$1
	dc	$47-16
	dc	$247
	dc	$26b
	
	dc	0
	dc	$140
	dc	$0
	dc	$181
	dc	$100

mode_65000_768x480
	dc.w	$1fe
	dc.w	$199
	dc.w	$50
	dc.w	$d
	dc.w	$13e
	dc.w	$1b2

	dc.w	$270
	dc.w	$265
	dc.w	$2f
	dc.w	$56
	dc.w	$236
	dc.w	$26b
	
	dc.w	$0
	dc.w	$c0
	dc.w	$6
	dc.w	$181
	dc.w	$0
	

buffer		ds.l	30
;--------------------------------------------------
save_palette_c	ds.l	256+8
save_v_buffer	ds	20
screen_s	ds	2
END_RES