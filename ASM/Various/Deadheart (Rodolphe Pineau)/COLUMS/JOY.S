MOD_BOX=0
MOD_DECI=0
MOD_HEXA=0

	
	INCLUDE GUW_MAC2.S

SETBLOCK	MOVE.L	A7,A5
	MOVE.L	#PILE,A7
	MOVE.L	4(A5),A5
	MOVE.L	$C(A5),D0
	ADD.L	$14(A5),D0
	ADD.L	$1C(A5),D0
	ADD.L	#$100,D0
	MOVE.L	D0,-(A7)
	MOVE.L	A5,-(A7)
	MOVE.W	#0,-(A7)
	MOVE.W	#$4A,-(A7)
	TRAP	#1
	ADD.L	#12,A7
	
	bsr	init_joy
loop
	move.w	#$ff,-(a7)
	move.w	#$06,-(a7)
	trap	#1
	addq.l	#4,a7
	cmp.b	#$1b,d0
	beq	fin
	
	move.b	key,d0
	add.w	#$30,d0
	move.b	d0,txt_key+2
	move.l	#txt_key,-(a7)
	move.w	#$9,-(a7)
	trap	#1
	addq.l	#6,a7
	syncro
	syncro
	syncro
	bra	loop
fin
	bsr	restore_joy
	
	move.w	#0,-(a7)
	trap	#1


init_joy:	appel xbios,34,2
	move.l d0,a0
	move.l 6*4(a0),save_joy
	move.l a0,save_joy+4
	move.l #my_joy,6*4(a0)
	move.l	#joy_param,-(a7)
	move.w	#2,-(a7)
	appel xbios,$19,8
	rts
restore_joy:
	move.l save_joy+4,a0
	move.l save_joy,6*4(a0)
	move.l	#stop_joy,-(a7)
	move.w	#1,-(a7)
	appel xbios,$19,8
	rts

my_joy:	
	save d0
	move.b	2(a0),d0
	move.b	d0,key
pas_joy:	load d0
	rts
	
	data
joy_param	dc.b	$12,$1a,$14
	even
stop_joy	dc.b	$1A,$08

txt_key	dc.b	$1b,'E',0,0	
	even	
key	dc.b	0
	dc.b	0
	even	                                  
save_joy	dc.l	0
	dc.l	0

	BSS
	DS.L	100
PILE	DS.L	1
OLD_SP	DS.L	1		
