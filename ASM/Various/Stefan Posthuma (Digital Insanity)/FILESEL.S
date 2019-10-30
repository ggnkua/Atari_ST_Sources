; DIGITAL INSANITY'S FILESELECTOR CALL ACCESSORY
; ASSEMBLE THIS TO A .ACC FILE AND YOU ARE HOME FREE!

start:		lea	newstack(pc),sp

; AES 10: appl_init()
		move.w	#10,opcode
		move.w	#0,sintin
		move.w	#1,sintout
		move.w	#0,saddrin
		move.w	#0,saddrout
		bsr	aes
		move.w	intout,appid

; AES 77: graph_handle()
		move.w	#77,opcode
		move.w	#5,sintout
		move.w	#0,saddrin
		move.w	#0,saddrout
		bsr	aes
		move.w	intout,grhandle

; AES 35: menu_register()
		move.w	#35,opcode
		move.w	#1,sintin
		move.w	#1,sintout
		move.w	#1,saddrin
		move.w	appid,intin
		move.l	#accname,addrin
		bsr	aes
		move.w	intout,accid

loop		bsr	event
		cmp.w	#40,msgbuff
		bne.s	loop
		move.w	msgbuff+8,d0
		cmp.w	accid,d0
		bne.s	loop
		bsr	run
		bra.s	loop

run		move.w	#$19,-(sp)		; get drive letter
		trap	#1
		addq.l	#2,sp
		add.b	#'A',d0
		move.b	d0,fs_iinpath		; move to pathname
		move.b	#':',fs_iinpath+1	; colon next to it 
		
		clr.w	-(sp)			; get current directory
		pea	fs_iinpath+2(pc)	; put it here
		move.w	#$47,-(sp)
		trap	#1
		addq.l	#8,sp
		lea	mask(pc),a0		; copy *.* to path
		lea	fs_iinpath(pc),a1
test		tst.b	(a1)+
		bne	test
		subq.w	#1,a1
		bsr	strcpy
		lea	name(pc),a0		; copy name
		lea	fs_insel(pc),a1
		bsr.s	strcpy

; AES 90: Fsel_Input
		move.w	#90,contrl
		move.w	#0,contrl+2
		move.w	#2,contrl+4
		move.w	#2,contrl+6
		move.w	#0,contrl+8
		move.l	#fs_iinpath,addrin
		move.l	#fs_insel,addrin+4
		bsr.s	aes
		rts

strcpy		move.b	(a0)+,(a1)
		tst.b	(a1)+
		bne.s	strcpy
		rts
 
; AES 25: Event_multi
event		move.w	#25,opcode
		move.w	#16,sintin
		move.w	#7,sintout
		move.w	#1,saddrin
		move.l	#msgbuff,addrin
		lea	table(pc),a1
		lea	intin(pc),a2
		moveq	#15,d0
lop1		move.b	(a1)+,(a2)+
		dbra	d0,lop1
		bsr.s	aes
		rts

aes		move.l	#aespb,d1
		move.w	#$c8,d0
		trap	#2
		rts

table		dc.w $13,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0
accname		dc.b "  Fileselector  ",0

mask		dc.b  "\*.*",0
name		dc.b  0

fs_iinpath:	ds.b  128
fs_insel:	ds.b  16

; AES parameter block contains a list of addresses used by GEM
aespb:		dc.l contrl,global,intin,intout,addrin,addrout

grhandle	ds.w  1
appid		ds.w  1
accid		ds.w  1
msgbuff		ds.b  16
		ds.l  128
newstack	ds.l  80

; control block
contrl
opcode		ds.w  1
sintin		ds.w  1
sintout		ds.w  1
saddrin		ds.w  1
saddrout	ds.l  1
		ds.w  5
global:		ds.l  8

intin		ds.w  80
ptsin		ds.w  80
intout		ds.w  80
ptsout		ds.w  80
addrin		ds.w  80
addrout		ds.w  80