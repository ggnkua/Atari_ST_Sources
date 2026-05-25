* milipede v 0.1
* (c) by Wolfhook

	.globl start

screen equ $78000			* only on a 512 KB Computer !!!!

bios   equ 13				* trap difinitions
xbios  equ 14
gemdos equ 1

start:		move.w #34,-(a7)	* set up joystick
		trap #14
		addq.l #2,a7
		move.l d0,a6
		move.l #joy,d0
		addq.l #8,a6
		addq.l #8,a6
		addq.l #8,a6
		move.l a6,jsave1
		move.l (a6),jsave2
		move.l d0,(a6)
		move.w #$14,-(a7)
		move.w #4,-(a7)
		move.w #3,-(a7)
		trap #bios
		addq.l #6,a7

		move.w #0,-(a7)		* set up screen
		move.w #0,-(a7)
		move.w #7,-(a7)
		trap #xbios
		addq.l #6,a7
		move.w #0,-(a7)
		move.w #0,-(a7)
		move.w #21,-(a7)
		trap #xbios
		addq.l #6,a7
		move.l #titel,-(a7)
		move.w #9,-(a7)
		trap #gemdos
		addq.l #6,a7
		move.w #1,-(a7)
		trap #gemdos
		addq.l #2,a7
		move.l #home,-(a7)
		move.w #9,-(a7)
		trap #gemdos
		addq.l #6,a7

		clr.l d7

		move.l #10,d3
		move.l #10,d4
		move.l #pilz1,a0
		bsr qshow
		move.l #11,d3
		move.l #10,d4
		move.l #pilz2,a0
		bsr qshow
		move.l #12,d3
		move.l #10,d4
		move.l #pilz3,a0
		bsr qshow

		move.l #screen,a6	* grob x+y
glo:		bsr dir
		move.l #buffer,a0
		bsr save
		move.l #plays,a0
		move.l #playd,a1
		bsr show
		move.w #37,-(a7)
		trap #14
		addq.l #2,a7
		move.l #buffer,a0
		bsr restore
		cmpi.b #$80,joydir+2
		bne glo

exit:		move.l jsave1,a6
		move.l jsave2,(a6)
		move.w #$15,-(a7)
		move.w #4,-(a7)
		move.w #3,-(a7)
		trap #bios
		addq.l #6,a7
		move.w #1,-(a7)
		move.w #0,-(a7)
		move.w #7,-(a7)
		trap #xbios
		addq.l #6,a7
		clr.w -(a7)
		trap #gemdos			* exit to gem		

save:		move.l #15,d0
		move.l a6,a5
slo:		move.b (a5)+,(a0)+
		move.b (a5)+,(a0)+
		adda.l #78,a5
		dbf d0,slo
		rts

restore:	move.l #15,d0
		move.l a6,a5
rlo:		move.b (a0)+,(a5)+
		move.b (a0)+,(a5)+
		adda.l #78,a5
		dbf d0,rlo
		rts

show:		move.l #15,d1
		move.l a6,a5
shl:		move.b (a0)+,d0
		and.b d0,(a5)
		move.b (a0)+,d0
		and.b d0,1(a5)
		move.b (a1)+,d0
		or.b d0,(a5)
		move.b (a1)+,d0
		or.b d0,1(a5)
		adda.l #80,a5
		dbf d1,shl
		rts

qshow:		rol.w #1,d3
		mulu #1280,d4
		add.l d3,d4
		move.l d4,a5
		adda.l #screen,a5
		move.l #15,d0
qshowl:		move.w (a0)+,(a5)
		adda.l #80,a5
		dbf d0,qshowl
		rts

dir:		move.b joydir+2,d0
		btst #0,d0
		beq nup
		bsr up
nup:		btst #1,d0
		beq ndow
		bsr down
ndow:		btst #2,d0
		beq nlef
		bsr left
nlef:		btst #3,d0
		bne right
		rts
up:		suba.l #160,a6
		cmpa.l #$78000,a6
		bhi okup
		move.l #$78000,a6
okup:		rts
down:		adda.l #160,a6
		cmpa.l #$7f000,a6
		bls okdown
		move.l #$7f000,a6
okdown:		rts
left:		subq.l #1,a6
		rts
right:		addq.l #1,a6
		rts

joy:		lea joydir,a1
		move.b (a0)+,(a1)+
		move.b (a0)+,(a1)+
		move.b (a0)+,(a1)+
		rts

		.even

playd:		dc.w %0000000000000000
		dc.w %0000000110000000
		dc.w %0000000110000000
		dc.w %0000001111000000
		dc.w %0000011111100000
		dc.w %0000111001110000
		dc.w %0011110000111100
		dc.w %0011111111111100
		dc.w %0001111111111000
		dc.w %0000111111110000
		dc.w %0000011111100000
		dc.w %0000001111000000
		dc.w %0000001111000000
		dc.w %0000011111100000
		dc.w %0000011111100000
		dc.w %0000000000000000

		.even

plays:		dc.w %1111111001111111
		dc.w %1111110000111111
		dc.w %1111110000111111
		dc.w %1111100000011111
		dc.w %1111000000001111
		dc.w %1100000000000011
		dc.w %1000000000000001
		dc.w %1000000000000001
		dc.w %1100000000000011
		dc.w %1110000000000111
		dc.w %1111000000001111
		dc.w %1111100000011111
		dc.w %1111100000011111
		dc.w %1111000000001111
		dc.w %1111000000001111
		dc.w %1111100000011111

pilz1:		dc.w %0000000000000000
		dc.w %0000111111110000
		dc.w %0011111111111100
		dc.w %0111111111111110
		dc.w %0111111111111110
		dc.w %0111111111111110
		dc.w %0111111111111110
		dc.w %0111100000011110
		dc.w %0011011111101100
		dc.w %0000111111110000
		dc.w %0000011111100000
		dc.w %0000011111100000
		dc.w %0000011111100000
		dc.w %0000011111100000
		dc.w %0000011111100000
		dc.w %0000000000000000

pilz2:		dc.w %0000000000000000
		dc.w %0000111111110000
		dc.w %0011111111111100
		dc.w %0111111111111110
		dc.w %0111111111111110
		dc.w %0111111111111110
		dc.w %0111111111111110
		dc.w %0111100000011110
		dc.w %0011011111101100
		dc.w %0000111111110000
		dc.w %0000011111100000
		dc.w %0000011101100000
		dc.w %0000011000100000
		dc.w %0000010000000000
		dc.w %0000000000000000
		dc.w %0000000000000000

pilz3:		dc.w %0000000000000000
		dc.w %0000111111110000
		dc.w %0011111111111100
		dc.w %0111111111111110
		dc.w %0111111111111110
		dc.w %0111111111111110
		dc.w %0111111111111110
		dc.w %0111100000011110
		dc.w %0011011111101100
		dc.w %0000110011110000
		dc.w %0000010001100000
		dc.w %0000000000100000
		dc.w %0000000000000000
		dc.w %0000000000000000
		dc.w %0000000000000000
		dc.w %0000000000000000

home:		dc.b $1b,"E",0
titel:		dc.b $1b,"E",12,12,12
		dc.b "    Milipede ",12,12,13
		dc.b "    (c) 1985 by Wolfhook",12,12,13
		dc.b "    Press any key to start Game ",0
		.even
joydir:		ds.b 6
		.even
jsave1:		ds.l 1
jsave2:		ds.l 1
		.even
sarry:		dc.b "rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "r                                      r"
		dc.b "rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr"

		.even
buffer:		ds.b 64
