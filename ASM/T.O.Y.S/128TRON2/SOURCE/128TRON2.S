; 128bytes two player tron game

; coded by PeyloW of T.O.Y.S.


; latest changes 1998-08-31

; Set EXIT to 1 to enable the exit by [space]
; this will add 24 bytes
EXIT	equ 0

; Set NICE to 1 to enable nicer coloring
; and display of last games winner
; this will add 14 bytes
NICE	equ 0

P1C	equ 700
P2C	equ -640



	SECTION TEXT

; set super
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1

	IFNE	EXIT
	addq.l	#6,sp
	move.l	d0,-(sp)
	ENDC

; get physic screen address
	move.l	$44e.w,a6	; a6=screen ptr
	
	IFNE	NICE
	moveq.l	#-1,d7
	ENDC
	
playmore:
; fill screen in one color (a6 word)
	move.l	a6,a0
	move.w	#320*200-1,d1
fill1:
	IFNE	NICE
	move.w	d7,(a0)+
	ELSEIF
	move.w	a6,(a0)+
	ENDC
	dbra	d1,fill1
	
; make black hole (play area)
	lea	(320*((200-128)/2)+(320-256)/2)*2(a6),a0
	moveq.l	#127,d0		; y loop
filly:
	moveq.l	#256/2-1,d1
fillx:
	clr.l	(a0)+
	dbra	d1,fillx
	lea	(320-256)*2(a0),a0
	dbra	d0,filly

; set player positions and movement
	lea	640*(200-100)/2+128(a6),a4	; play 1 pos
	lea	640*(202-100)/2-128(a6),a5	; play 2 pos
	moveq.l	#2,d4				; play 1 dir
	moveq.l	#-2,d5
	
	
mainloop:
; test for game over
	IFNE	NICE
	move.w	#P2C,d7
	ENDC
	tst.w	(a4)
	bne.s	playmore
	IFNE	NICE
	move.w	#P1C,d7
	ENDC
	tst.w	(a5)
	bne.s	playmore
; plot new dot
	IFNE	NICE
	move.w	#P1C,(a4)
	ELSEIF
	not.w	(a4)
	ENDC
	IFNE	NICE
	move.w	#P2C,(a5)
	ELSEIF
	move.w	a6,(a5)
	ENDC
; move players
	add.w	d4,a4
	add.w	d5,a5
	
; wait vbl
	IFNE	EXIT
	move.w	#37,-(sp)
	ELSEIF
	move.w	#37,(sp)
	ENDC
	trap	#14
	IFNE	EXIT
	addq.l	#2,sp
	ENDC
	
	
; get key
	move.b	$fffffc02.w,d0
	
	IFNE	EXIT
	cmp.b	#$39,d0
	beq.s	Quit
	ENDC

; test for player keys
	moveq.l	#3,d1
PlayerKeys:
	cmp.b	Player1Keys(pc,d1.w),d0
	bne.s	.nope1
	move.w	DirTab(pc,d1.w*2),d4
.nope1:
	cmp.b	Player2Keys(pc,d1.w),d0
	bne.s	.nope2
	move.w	DirTab(pc,d1*2),d5
.nope2:
	dbra	d1,PlayerKeys


; and loop
	bra.s	mainloop

	
	
	IFNE	EXIT
Quit:
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr.w	-(sp)
	trap	#1
	ENDC
	
	
	SECTION DATA
DirTab:
	dc.w	-640
	dc.w	-2
	dc.w	2
	dc.w	640
Player1Keys:
	dc.b	72,75,77,80
Player2Keys:
	dc.b	104,106,108,110
	
	SECTION BSS
	
	