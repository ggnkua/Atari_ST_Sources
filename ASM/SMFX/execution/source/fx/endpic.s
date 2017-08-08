
	section TEXT
init_endpic

	move.w	#$2700,sr
	move.l	#ym_vbl,$70
	move.w	#$2300,sr
	wait_for_vbl

	lea	$ffff8240,a0
	move.l	#0,d0
	REPT 8
		move.l	d0,(a0)+
	ENDR


	move.l	screenpointer2,a1
	add.w	#10*160,a1
	lea		endpic1,a0
	jsr		d_lz77


	move.w	#$2700,sr
	move.l	#endpic_vbl,$70
	clr.b	$fffffa1b.w				;Timer B control (stop)
	move.l	#timer_a_opentop_greetings,$134.w			;Install our own Timer A
	move.l	#timer_b_openbottom_endpic,$120.w			;Install our own Timer B
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
    move.b  #227,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	move.w	#$2300,sr

	move.l	#-1,_demoloopcounter

.x
	jsr		copyEndPic2
	jsr		copyMemberList
	jsr		restoreLowerMem
	move.w	#$4e75,restoreLowerMem
			exitOnSpace
	tst.w	nextScene
	beq		.x
	rts




endPicPalOffset	dc.w	7*32

fadeInWaitertt	dc.w	45
endPicPal		
			dc.w	$0000,$0777,$0776,$0765,$0754,$0643,$0532,$0421,$0311,$0201,$0011,$0120,$0331,$0744,$0733,$0622
			dc.w	$0000,$0775,$0774,$0763,$0752,$0641,$0530,$0420,$0310,$0200,$0010,$0120,$0330,$0742,$0731,$0620
			dc.w	$0000,$0765,$0764,$0753,$0742,$0631,$0520,$0410,$0300,$0200,$0000,$0110,$0320,$0732,$0721,$0610
			dc.w	$0000,$0664,$0663,$0652,$0641,$0530,$0420,$0310,$0200,$0100,$0000,$0010,$0220,$0631,$0620,$0510
			dc.w	$0000,$0643,$0642,$0631,$0620,$0510,$0400,$0300,$0200,$0100,$0000,$0000,$0200,$0610,$0600,$0500
			dc.w	$0000,$0413,$0412,$0401,$0400,$0300,$0200,$0100,$0000,$0000,$0000,$0000,$0000,$0400,$0400,$0300
			dc.w	$0000,$0301,$0300,$0300,$0300,$0200,$0100,$0000,$0000,$0000,$0000,$0000,$0000,$0300,$0300,$0200
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000



endPicPal2
			dc.w	$000,$777,$776,$765,$754,$643,$532,$421,$311,$201,$011,$120,$331,$744,$733,$622							;0
			dc.w	$000,$777,$777,$776,$765,$754,$643,$532,$422,$312,$122,$231,$442,$755,$744,$733							;1
			dc.w	$000,$777,$777,$777,$776,$765,$754,$643,$533,$423,$233,$342,$553,$766,$755,$744							;2
			dc.w	$000,$777,$777,$777,$777,$776,$765,$754,$644,$534,$344,$453,$664,$777,$766,$755							;3
			dc.w	$000,$777,$777,$777,$777,$777,$776,$765,$755,$645,$455,$564,$775,$777,$777,$766							;4
			dc.w	$111,$777,$777,$777,$777,$777,$776,$776,$766,$756,$566,$675,$776,$777,$777,$777							;5
			dc.w	$222,$777,$777,$777,$777,$777,$776,$777,$777,$767,$677,$776,$777,$777,$777,$777							;6
			dc.w	$333,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777							;7
			dc.w	$444,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777							;8
endPicPal3
;fade in done
			dc.w	$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777,$0777			;0
			dc.w	$0774,$0777,$0763,$0774,$0773,$0775,$0776,$0776,$0776,$0776,$0777,$0777,$0777,$0777,$0775,$0773			;1
			dc.w	$0750,$0777,$0752,$0763,$0772,$0774,$0775,$0775,$0775,$0775,$0776,$0777,$0777,$0776,$0774,$0662			;2
			dc.w	$0730,$0777,$0642,$0753,$0762,$0764,$0775,$0775,$0775,$0775,$0776,$0777,$0777,$0776,$0774,$0552			;3
			dc.w	$0630,$0777,$0632,$0743,$0752,$0754,$0765,$0765,$0775,$0775,$0776,$0777,$0777,$0776,$0764,$0542			;4
			dc.w	$0530,$0777,$0531,$0642,$0651,$0753,$0764,$0764,$0774,$0774,$0775,$0776,$0777,$0775,$0663,$0441			;5
			dc.w	$0420,$0777,$0521,$0632,$0641,$0743,$0754,$0754,$0764,$0764,$0775,$0776,$0777,$0775,$0653,$0431			;6
			dc.w	$0410,$0777,$0421,$0532,$0541,$0643,$0654,$0754,$0764,$0764,$0775,$0776,$0777,$0775,$0553,$0331			;7
			dc.w	$0310,$0777,$0411,$0522,$0531,$0633,$0644,$0744,$0754,$0754,$0765,$0776,$0777,$0765,$0543,$0321			;8
			dc.w	$0210,$0777,$0311,$0422,$0431,$0533,$0544,$0644,$0654,$0754,$0765,$0776,$0777,$0665,$0443,$0221			;9
			dc.w	$0200,$0777,$0301,$0412,$0421,$0523,$0534,$0634,$0644,$0744,$0755,$0766,$0777,$0655,$0433,$0211			;10
			dc.w	$0000,$0777,$0201,$0312,$0321,$0423,$0434,$0534,$0544,$0644,$0655,$0766,$0777,$0555,$0333,$0111			;11
; fade from white to pic 2


			dc.w	$0000,$0777,$0201,$0312,$0321,$0423,$0434,$0534,$0544,$0644,$0655,$0766,$0777,$0555,$0333,$0111			;12
			dc.w	$0000,$0777,$0201,$0302,$0311,$0413,$0424,$0524,$0534,$0634,$0645,$0756,$0767,$0545,$0323,$0101			;13
			dc.w	$0000,$0777,$0201,$0302,$0301,$0403,$0414,$0514,$0524,$0624,$0635,$0746,$0757,$0535,$0313,$0101			;14
			dc.w	$0000,$0777,$0101,$0202,$0201,$0303,$0314,$0414,$0424,$0524,$0535,$0646,$0657,$0435,$0213,$0001			;15
			dc.w	$0000,$0777,$0100,$0201,$0200,$0302,$0303,$0403,$0413,$0513,$0524,$0635,$0646,$0424,$0202,$0000			;16
			dc.w	$0000,$0666,$0100,$0200,$0200,$0300,$0301,$0401,$0411,$0511,$0522,$0633,$0644,$0422,$0200,$0000			;17
			dc.w	$0000,$0666,$0100,$0200,$0200,$0300,$0300,$0400,$0410,$0510,$0520,$0631,$0642,$0420,$0200,$0000			;18
			dc.w	$0000,$0666,$0100,$0200,$0200,$0300,$0300,$0400,$0410,$0510,$0520,$0630,$0640,$0420,$0200,$0000			;19
			dc.w	$0000,$0666,$0000,$0100,$0100,$0200,$0200,$0300,$0310,$0410,$0420,$0530,$0540,$0320,$0100,$0000			;20
			dc.w	$0000,$0555,$0000,$0000,$0000,$0100,$0100,$0200,$0210,$0310,$0320,$0430,$0440,$0220,$0000,$0000			;21
			dc.w	$0000,$0555,$0000,$0000,$0000,$0000,$0000,$0100,$0110,$0210,$0220,$0330,$0340,$0120,$0000,$0000			;22
			dc.w	$0000,$0555,$0000,$0000,$0000,$0000,$0000,$0100,$0100,$0200,$0210,$0320,$0330,$0110,$0000,$0000			;23
			dc.w	$0000,$0444,$0000,$0000,$0000,$0000,$0000,$0100,$0100,$0200,$0200,$0310,$0320,$0100,$0000,$0000			;24
			dc.w	$0000,$0444,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0100,$0100,$0210,$0220,$0000,$0000,$0000			;25
			dc.w	$0000,$0444,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0100,$0100,$0200,$0210,$0000,$0000,$0000			;26
			dc.w	$0000,$0333,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0100,$0110,$0000,$0000,$0000			;26
			dc.w	$0000,$0333,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0100,$0000,$0000,$0000			;26
			dc.w	$0000,$0333,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0100,$0000,$0000,$0000			;26
			dc.w	$0000,$0222,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0100,$0000,$0000,$0000			;26
			dc.w	$0000,$0111,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0100,$0000,$0000,$0000			;26
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000			;27



endpic_vbl
	pushall
	move.l	screenpointer2,$ffff8200


	addq.w	#1,$466.w
			schedule_timerA_topBorder

    clr.b   $fffffa1b.w         ;Timer B control (stop)
	move.l	#timer_b_openbottom_endpic,$120.w			;Install our own Timer B
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
    move.b  #227,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
	bclr	#3,$fffffa17.w			;Automatic end of interrupt


	lea		endPicPal,a0
	add.w	endPicPalOffset,a0
	lea		$ffff8240,a1
	REPT 8
		move.l	(a0)+,(a1)+
	ENDR

	subq.w	#1,tridiframes
	bge		.ym
.mym	
		move.l	sndh_pointer,a0
		jsr		8(a0)
		jmp		.cont
.ym
	IFEQ useym
		jsr		music_ym_play
	ENDC
.cont

	subq.w	#1,fadeInWaitertt
	bge		.kk
		move.w	#2,fadeInWaitertt
		sub.w	#32,endPicPalOffset
		bgt		.kk
			move.w	#0,endPicPalOffset
			move.l	#endpic2_vbl,$70
			move.w	#192-30+3,fadeInWaitertt
.kk

	popall
	rte

ym_vbl
	addq.w	#1,$466
	pushall
		jsr		music_ym_play
	popall
	rte	

sndh_vbl
	addq.w	#1,$466
	pushall
		move.l	sndh_pointer,a0
		jsr		8(a0)
	popall
	rte


endpic2_vbl
	pushall
	move.l	screenpointer2,$ffff8200


	addq.w	#1,$466.w
			schedule_timerA_topBorder

    clr.b   $fffffa1b.w         ;Timer B control (stop)
	move.l	#timer_b_openbottom_endpic,$120.w			;Install our own Timer B
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
    move.b  #227,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
	bclr	#3,$fffffa17.w			;Automatic end of interrupt


	lea		endPicPal2,a0
	add.w	endPicPalOffset,a0
	lea		$ffff8240,a1
	REPT 8
		move.l	(a0)+,(a1)+
	ENDR

	subq.w	#1,tridiframes
	bge		.ym
.mym	
		move.l	sndh_pointer,a0
		jsr		8(a0)
		jmp		.cont
.ym
	IFEQ useym
		jsr		music_ym_play
	ENDC
.cont


	subq.w	#1,fadeInWaitertt
	bge		.kk
		move.w	#1,fadeInWaitertt
		add.w	#32,endPicPalOffset
		cmp.w	#8*32,endPicPalOffset
		ble		.kk
			move.w	#8*32,endPicPalOffset
			add.w	#2,bgoffsetxxx
			lea		bgPal,a0
			add.w	bgoffsetxxx,a0
			lea		endPicPal2,a1
			add.w	endPicPalOffset,a1
			move.w	(a0),(a1)
			cmp.w	#16,bgoffsetxxx
			ble		.kk
				move.w	#16,bgoffsetxxx
				move.l	#endpic3_vbl,$70

				move.w	#0,endPicPalOffset

.kk
	popall
	rte


endpic3_vbl
	pushall
	move.l	screenpointer,$ffff8200


	addq.w	#1,$466.w
			schedule_timerA_topBorder

    clr.b   $fffffa1b.w         ;Timer B control (stop)
	move.l	#timer_b_openbottom_endpic,$120.w			;Install our own Timer B
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
    move.b  #227,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
	bclr	#3,$fffffa17.w			;Automatic end of interrupt


	lea		endPicPal3,a0
	add.w	endPicPalOffset,a0
	lea		$ffff8240,a1
	REPT 8
		move.l	(a0)+,(a1)+
	ENDR


	subq.w	#1,tridiframes
	bge		.ym
.mym	
		move.l	sndh_pointer,a0
		jsr		8(a0)
		jmp		.cont
.ym
	IFEQ useym
		jsr		music_ym_play
	ENDC
.cont

	subq.w	#1,fadeInWaitertt
	bge		.kk
		move.w	#1,fadeInWaitertt
		add.w	#32,endPicPalOffset
		cmp.w	#10*32,endPicPalOffset
		ble		.kk
			move.l	#endpic4_vbl,$70
			move.w	#120-3,fadeInWaitertt

.kk

	popall
	rte	


endpic4_vbl
	pushall
	move.l	screenpointer,$ffff8200


	addq.w	#1,$466.w
			schedule_timerA_topBorder

    clr.b   $fffffa1b.w         ;Timer B control (stop)
	move.l	#timer_b_openbottom_endpic,$120.w			;Install our own Timer B
    bset    #0,$fffffa07.w          ;Interrupt enable A (Timer B)
    bset    #0,$fffffa13.w          ;Interrupt mask A (Timer B)
    move.b  #227,$fffffa21.w        ;Timer B data (number of scanlines to next interrupt)
    move.b  #8,$fffffa1b.w          ;Timer B control (event mode (HBL))
	bclr	#3,$fffffa17.w			;Automatic end of interrupt


	lea		endPicPal3,a0
	add.w	endPicPalOffset,a0
	lea		$ffff8240,a1
	REPT 8
		move.l	(a0)+,(a1)+
	ENDR


	subq.w	#1,tridiframes
	bge		.ym
.mym	
		move.l	sndh_pointer,a0
		jsr		8(a0)
		jmp		.cont
.ym
	IFEQ useym
		jsr		music_ym_play
	ENDC
.cont

	subq.w	#1,fadeInWaitertt
	bge		.kk
		move.w	#1,fadeInWaitertt
		add.w	#32,endPicPalOffset
		cmp.w	#32*32,endPicPalOffset
		ble		.kk
			move.w	#32*32,endPicPalOffset
			move.w	#$2700,sr
			move.l	#end_vbl,$70
			move.l	#dummy,$134
			move.l	#dummy,$120
			move.w	#$2300,sr

.kk
	popall
	rte	

saved134	dc.l	0
saved120	dc.l	0

end_vbl
	move.l	screenpointer2,$ffff8200
	move.w	#-1,timeToDoEnding
	pushall
	tst.w	codeListOff
	beq		.nn
	lea		fadeColors,a0
	lea		$ffff8240+9*2,a1
	rept 7
		move.w	(a0)+,(a1)+
	endr
.nn
	jsr		doNames
	move.l	sndh_pointer,a0
	jsr		8(a0)
	popall
	rte



copyMemberList
	tst.w	timeToDoEnding
	beq		.end
	move.l	screenpointer2,a0
	moveq	#0,d0
	move.w	#106-1,d7
.clear
	REPT 20
		move.l	d0,(a0)+
		move.l	d0,(a0)+
	ENDR
	dbra	d7,.clear
	move.w	#17-1,d7
.copy
	REPT 20
		move.l	d0,(a0)+
		move.l	d0,(a0)+
	ENDR
	dbra	d7,.copy	
	move.w	#80-1,d7
.clear2
	REPT 20
		move.l	d0,(a0)+
		move.l	d0,(a0)+
	ENDR
	dbra	d7,.clear2
	move.w	#$4e75,copyMemberList
.end
	rts

timeToDoEnding	
		dc.w	0

bgoffsetxxx	
		dc.w	-2
		dc.w	$444
bgPal	
		dc.w	$555
		dc.w	$666
		dc.w	$777
		dc.w	$777
		dc.w	$777
		dc.w	$777
		dc.w	$777
		dc.w	$777
		dc.w	$777
		dc.w	$777
		dc.w	$777
		dc.w	$777
		dc.w	$777

memberListPointerList
	dc.l	memberListSource
		dc.w	4-1
		dc.w	0
		dc.w	160-32
	dc.l	memberListSource+30*32
		dc.w	8-1
		dc.w	32
		dc.w	160-64
	dc.l	memberListSource+30*32+30*64
		dc.w	4-1
		dc.w	96
		dc.w	160-32
	dc.l	memberListSource+30*32+30*64+30*32
		dc.w	4-1
		dc.w	128
		dc.w	160-32

memberListPointerOff	dc.w	0

membersBuffer	ds.b	30*160

copyMember
	move.l	sndh_pointer,a0
	moveq	#0,d0
	move.b	$b8(a0),d0
	cmp.b	#$a,d0
	bne		.skip
		move.b	#0,$b8(a0)
	lea		memberListPointerList,a6
	add.w	memberListPointerOff,a6
	move.l	(a6)+,a0
	move.l	screenpointer2,a1
	add.w	#120*160,a1
	move.w	#30-1,d7
	move.w	(a6)+,d5			; width; innerloop
	add.w	(a6)+,a1			; offset into screen
	move.w	(a6)+,d4			; offset per iteration
.cp
		move.w	d5,d6
.il
			move.l	(a0)+,(a1)+
			move.l	(a0)+,(a1)+
		dbra	d6,.il
		add.w	d4,a1

	dbra	d7,.cp
	add.w	#4,codeListOff
.skip
	rts

fillMember
	lea		$ffff8242,a0
	rept 7
		move.w	#0,(a0)+
	endr

	lea		memberListPointerList,a6
	add.w	memberListPointerOff,a6
	move.l	(a6)+,a0
	move.l	screenpointer2,a1
	add.w	#120*160,a1
	move.w	#30-1,d7
	move.w	(a6)+,d5			; width; innerloop
	add.w	(a6)+,a1			; offset into screen
	move.w	(a6)+,d4			; offset per iteration
.cp
		move.w	d5,d6
.il
			move.w	(a0)+,d0
			or.w	d0,6(a1)
			move.w	(a0)+,d0
			or.w	d0,6(a1)
			move.w	(a0)+,d0
			or.w	d0,6(a1)
			add.w	#2,a0
			add.w	#8,a1		
		dbra	d6,.il
		add.w	d4,a1
	dbra	d7,.cp

	add.w	#4,codeListOff	
	add.w	#10,memberListPointerOff
	cmp.w	#40,memberListPointerOff
	bne		.noreset
		move.w	#0,memberListPointerOff
.noreset
	rts	


removeMember1
	move.l	sndh_pointer,a0
	moveq	#0,d0
	move.b	$b8(a0),d0
	cmp.b	#$a,d0
	bne		.skip
		move.b	#0,$b8(a0)

	lea		fadeColors,a0
	move.w	#0,fadeColorsOff
	move.w	fadeColorsOff,d0
	add.w	fadeColorsOff,a0
	lea		$ffff8242,a1
	rept 7
		move.w	(a0)+,(a1)+
	endr

	lea		memberListPointerList,a6
	add.w	memberListPointerOff,a6
	move.l	(a6)+,a0
	move.l	screenpointer2,a1
	add.w	#120*160,a1
	move.w	#30-1,d7
	move.w	(a6)+,d5			; width; innerloop
	add.w	(a6)+,a1			; offset into screen
	move.w	(a6)+,d4			; offset per iteration
	move.w	#0,d0

.cp
		move.w	d5,d6
.il
			move.w	d0,6(a1)
			add.w	#8,a1
		dbra	d6,.il
		add.w	d4,a1
	dbra	d7,.cp

	add.w	#4,codeListOff
	move.w	#0,fadeColorsOff
.skip
	rts


removeMember2
	lea		memberListPointerList,a6
	add.w	memberListPointerOff,a6
	move.l	(a6)+,a0
	move.l	screenpointer2,a1
	add.w	#120*160,a1
	move.w	#30-1,d7
	move.w	(a6)+,d5			; width; innerloop
	add.w	(a6)+,a1			; offset into screen
	move.w	(a6)+,d4			; offset per iteration
	moveq	#0,d0

.cp
		move.w	d5,d6
.il
			move.l	d0,(a1)+
			move.l	d0,(a1)+
		dbra	d6,.il
		add.w	d4,a1
	dbra	d7,.cp

	add.w	#4,codeListOff
	add.w	#10,memberListPointerOff
	rts


codeListOff	dc.w	0

doNames
	lea		codeList,a0
	add.w	codeListOff,a0
	move.l 	(a0),a1
	jmp		(a1)

	dc.w		$102,$112,$123,$233,$243,$556,$777		;0
fadeColors
	dc.w		$102,$112,$123,$233,$243,$556,$777		;0
	dc.w		$002,$012,$023,$133,$143,$456,$677		;14
	dc.w		$001,$001,$012,$022,$032,$345,$566		;28
	dc.w		$000,$000,$001,$011,$021,$234,$455		;42
	dc.w		$000,$000,$000,$001,$010,$123,$344		;56
	dc.w		$000,$000,$000,$000,$000,$012,$233		;70
	dc.w		$000,$000,$000,$000,$000,$001,$122		;84
	dc.w		$000,$000,$000,$000,$000,$000,$011		;98
	dc.w		$000,$000,$000,$000,$000,$000,$000		;112
	dc.w		$000,$000,$000,$000,$000,$000,$000		;112
fadeColorsOff	dc.w	112
fadeColorsOffWaiter	dc.w	2

fadeMemberListIn
	lea		fadeColors,a0
	add.w	fadeColorsOff,a0
	lea		$ffff8242,a1
	rept 7
		move.w	(a0)+,(a1)+
	endr
	subq.w	#1,fadeColorsOffWaiter
	bne		.end
		move.w	#1,fadeColorsOffWaiter
	sub.w	#14,fadeColorsOff
	bge		.end
		move.w	#112,fadeColorsOff
		add.w	#4,codeListOff
.end
	rts

fadeMemberListOut
	lea		fadeColors,a0
	move.w	fadeColorsOff,d0
	add.w	fadeColorsOff,a0
	lea		$ffff8242,a1
	rept 7
		move.w	(a0)+,(a1)+
	endr
	subq.w	#1,fadeColorsOffWaiter
	bne		.end
		move.w	#1,fadeColorsOffWaiter
	add.w	#14,fadeColorsOff
	cmp.w	#112,fadeColorsOff
	bne		.end
		move.w	#0,fadeColorsOff
		add.w	#4,codeListOff
.end
	rts


nothing
	jsr		buzz
	jsr		buzzFade
	jsr		clearTimes2
	jsr		drawTimes
	rts	

clearTimes2
	move.l	screenpointer2,a1
	add.l	#188*160,a1
	move.w	#12-1,d7
	moveq	#0,d0
.cl
	REPT 20
		move.l	d0,(a1)+
		move.l	d0,(a1)+
	ENDR
	dbra	d7,.cl
	rts

drawTimes
	move.l	sndh_pointer,a0
	moveq	#0,d0
	move.b	$b8(a0),d0
	cmp.b	#1,d0
	bne		.end

		move.b	#0,$b8(a0)
		add.l	#1,_demoloopcounter
		move.l	_demoloopcounter,d0
		ble		.end
	move.w	#$001,$ffff8242
.end
		move.l	_demoloopcounter,d0
		ble		.end2
	move.l	screenpointer2,a1
	lea		numbers+80,a2
	lea		sublist,a4
	add.l	#190*160,a1

	sub.w	(a4),a0
	sub.w	(a4)+,a1
o set 0
	REPT 8 
		move.b	(a2)+,d6
		or.b	d6,o(a1)
o set o+160
	ENDR

	move.l	_demoloopcounter,d0

	move.w	#10,d7
	lea		numbers,a2
.loop
	divs	d7,d0
	move.l	d0,d1
	swap	d1

	add.w	d1,d1	;2
	add.w	d1,d1	;4
	add.w	d1,d1	;8
	lea		(a2,d1.w),a3
	sub.w	(a4)+,a1

o set 0
	REPT 8
		move.b	(a3)+,d6
		or.b	d6,o(a1)
o set o+160

	ENDR
	ext.l	d0
	cmp.w	#0,d0
	bne		.loop
.end2
	rts

buzzFade
	move.l	sndh_pointer,a0
	moveq	#0,d0
	move.b	$b8(a0),d0
	cmp.b	#$99,d0
	bne		.skip
		subq.w	#1,buzzColsWaiter
		bge		.skip
			move.w	#29,buzzColsWaiter
			add.w	#2,buzzColsOff
			cmp.w	#10,buzzColsOff
			bne		.skip
				move.w	#8,buzzColsOff
				move.w	#5,buzzColsWaiter
.skip
	cmp.b	#$ee,d0
	bne		.skip2
		subq.w	#1,buzzColsWaiter
		bge		.skip2
;			move.b	#0,$ffffc123
			move.w	#4,buzzColsWaiter
			subq.w	#2,buzzColsOff
			bge		.skip2
			move.w	#0,buzzColsOff
				; clear and rts
;				move.b	#0,$ffffc123
				move.w	#$4e75,buzzFade
				move.l	screenpointer2,a0
				add.w	#91*160,a0
				move.l	#0,d6
				move.w	#15-1,d7
.cl
				REPT 20
				move.l	d6,(a0)+
				move.l	d6,(a0)+
				ENDR
				dbra	d7,.cl
.skip2
	lea		buzzCols,a0
	add.w	buzzColsOff,a0
	move.w	(a0),$ffff8242
	rts

;prepbuzz
;	lea		buzzx+34,a0
;	lea		buzzBuffer,a1
;y set 0
;	REPT 15
;o set y
;		REPT 20
;			move.w	o(a0),(a1)+
;o set o+8
;		ENDR
;y set y+160
;	ENDR	
;	lea		buzzBuffer,a0
;	move.b	#0,$ffffc123			;20*2:
;	rts
;buzzx
;	incbin	fx/endpic/buzz.pi1

buzz
	lea		buzzBuffer,a0
	move.l	screenpointer2,a1
	add.w	#91*160,a1
y set 0
	REPT 15
o set y
		REPT 20
			move.w	(a0)+,o(a1)
o set o+8
		ENDR
y set y+160
	ENDR
	move.w	#$4e75,buzz
	rts

buzzColsWaiter	dc.w	1
buzzColsOff		dc.w	0
buzzCols
	dc.w	$000
	dc.w	$001
	dc.w	$002
	dc.w	$102
	dc.w	$112

codeList
	dc.l	copyMember
	dc.l	fadeMemberListIn
	dc.l	fillMember
	dc.l	copyMember
	dc.l	fadeMemberListIn
	dc.l	fillMember
	dc.l	copyMember
	dc.l	fadeMemberListIn
	dc.l	fillMember
	dc.l	copyMember
	dc.l	fadeMemberListIn
	dc.l	fillMember

	dc.l	removeMember1
	dc.l	fadeMemberListOut
	dc.l	removeMember2
	dc.l	removeMember1
	dc.l	fadeMemberListOut
	dc.l	removeMember2
	dc.l	removeMember1
	dc.l	fadeMemberListOut
	dc.l	removeMember2
	dc.l	removeMember1
	dc.l	fadeMemberListOut
	dc.l	removeMember2
	dc.l	nothing

timer_b_openbottom_endpic
	move.w	#$2100,sr
	stop	#$2100
    move.w  #$2700,sr
	movem.l	d0-d7/a0,-(sp)
 
             clr.b   $fffffa1b.w                     ;Timer B control (stop)

        lea $ffff8209.w,a0          ;Hardsync						;8
        moveq   #127,d1												;4
.sync:      tst.b   (a0)											;8
        beq.s   .sync												;8
        move.b  (a0),d2												;8
        sub.b   d2,d1												;4
        lsr.l   d1,d1												;10

        REPT 35
        	nop
        ENDR
	clr.b	$ffff820a.w			;60 Hz
	REPT 6
		nop
	ENDR
    move.b  #2,$FFFF820A.w  ; 50 hz

    movem.l (sp)+,d0-d7/a0

    rte

copyEndPic2
	lea		endpic2,a0
	move.l	screenpointer,a1
	add.w	#10*160,a1
	jsr		d_lz77

	move.w	#$4e75,copyEndPic2
	rts

	section DATA

buzzBuffer incbin	"fx/endpic/buzzgoeson.bin"

