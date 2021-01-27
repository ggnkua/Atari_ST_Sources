
AREA EvntMulti

	pea	(a2)
	lea 	AES_pb.l,a1
	move.l	a0,8(a1)
	lea 	32(a0),a0
	move.l	a0,12(a1)
	pea	(a0)
	lea 	14(a0),a0
	move.l	a0,Gem_pb+604.l
	move.l	#L578,(a1)
	move.l	a1,d1
	move	#200,d0
	trap	#2		; VDI/AES
	movea.l	(a7)+,a0
	move	(a0),d0
	lea 	AES_pb.l,a1
	move.l	#Gem_pb,(a1)
	move.l	#Gem_pb+60,8(a1)
	move.l	#Gem_pb+324,12(a1)
	movea.l	(a7)+,a2
	rts

L578:
	ori.b	#16,(a1)+
	ori.b	#1,d7
	dc	0

