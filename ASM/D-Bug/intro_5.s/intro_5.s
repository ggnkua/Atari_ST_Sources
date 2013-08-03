;
; D-BUG INTRO #5
;
; Coded by Cyrano Jones
;

ramtop		equ $380000
;vbl_timer

	move.l 4(a7),a5			; Gemdos MEM_SHRINK
	lea $2000.w,a7			; Safe Stack on 512!
	move.l #$200,-(a7)
	move.l a5,-(a7)
	move.l #$4a0000,-(a7)
	trap #1
	lea 12(a7),a7

	pea code(pc)
	move.w #$26,-(a7)
	trap #14
	addq.l #6,a7

	clr.l -(a7)			; $4b program file
	move.l #ct,-(a7)
	move.l filename,-(a7)
	clr.w -(a7)
	move.w #$4b,-(a7)
	trap #1
	lea 14(a7),a7

quit_ld	move.w #$4c,-(a7)		; Back to Desktop
	trap #1

filename	dc.l game1
ct		dc.l 0

game1	dc.b "a:\title1.tos",0
	even
game2	dc.b "a:\title2.tos",0
	even
game3	dc.b "a:\title3.tos",0
	even

code	lea save_all,a0
	move.b $ffff8201.w,(a0)+
	move.b $ffff8203.w,(a0)+
	move.b $ffff8260.w,(a0)+
	move.b #0,$ffff8260.w
	move.b $ffff820a.w,(a0)+
	move.l $70.w,(a0)+
	move.l $120.w,(a0)+
	move.b $fffffa07.w,(a0)+
	move.b $fffffa09.w,(a0)+
	move.b $fffffa1b.w,(a0)+
	move.b $fffffa13.w,(a0)+
	move.l $118.w,(a0)+
	movem.l $ffff8240.w,d0-7
	movem.l d0-7,(a0)
	movem.l line_buff,d0-7
	movem.l d0-7,$ffff8240.w
	move.l #$07770777,d0
	move.l d0,d1
	move.l d1,d2
	move.l d2,d3
	movem.l d0-3,logo+18

	move.b #$12,d0
	bsr s_ikbd
	move.b #$1a,d0
	bsr s_ikbd
	move.l #my_key,$118.w

	bclr.b #5,$fffffa15.w		; disable timer C
	bclr.b #5,$fffffa09.w		; on all four status bits
	bclr.b #5,$fffffa0d.w		
	bclr.b #5,$fffffa11.w		

	move.l screen2,a0
.wipe	clr.w (a0)+
	cmp.l #ramtop,a0
	bne.s .wipe

	jsr init_text
	moveq.l #1,d0
	jsr music

	move.l #vbl,$70.w

.wait	cmp.b #$2,key
	bne.s .2
	move.l #game1,filename
	bra.s .exit
.2	cmp.b #$3,key
	bne.s .3
	move.l #game2,filename
	bra.s .exit
.3	cmp.b #$4,key
	bne.s .wait
	move.l #game3,filename

.exit	move.w #$2700,sr
	lea save_all,a0
	move.b (a0)+,$ffff8201.w
	move.b (a0)+,$ffff8203.w
	move.b (a0)+,$ffff8260.w
	move.b (a0)+,$ffff820a.w
	move.l (a0)+,$70.w
	move.l (a0)+,$120.w
	move.b (a0)+,$fffffa07.w
	move.b (a0)+,$fffffa09.w
	move.b (a0)+,$fffffa1b.w
	move.b (a0)+,$fffffa13.w
	move.l (a0)+,$118.w
	bset.b #5,$fffffa15.w		; disable timer C
	bset.b #5,$fffffa09.w		; on all four status bits
	bset.b #5,$fffffa0d.w		
	bset.b #5,$fffffa11.w		
	movem.l (a0),d0-7
	movem.l $ffff8240.w,d0-7
	move.b #$80,d0
	bsr s_ikbd
	move.b #$1,d0
	bsr s_ikbd 
	move.w #$2300,sr
	move.l #$8080000,$ffff8800.w
	move.l #$9090000,$ffff8800.w
	move.l #$a0a0000,$ffff8800.w
	rts

my_key	move.b $fffffc02.w,key		; keyboard 'scanner'
	bclr.b #6,$fffffa11.W
	rte
key	dc.l 0

s_ikbd	btst #1,$fffffc00.w
	beq.s s_ikbd
	move.b d0,$fffffc02.w
	rts


vbl	movem.l d0-a6,-(a7)

	move.b screen2+1,$ffff8201.w
	move.b screen2+2,$ffff8203.w
	move.l screen1,d0
	move.l screen2,screen1
	move.l d0,screen2
	move.l scr1,d0
	move.l scr2,scr1
	move.l d0,scr2

	movem.l logo+2,d0-7
	movem.l d0-7,$ffff8240.w

	bsr logo_mover

	jsr music+8

	move.l screen1,a2
	lea 6(a2),a2
	lea line_buff,a0
	move.l #(5*200)-1,d0
	moveq.l #32,d1
.loop	move.w (a0)+,(a2)
	move.w (a0)+,8(a2)
	move.w (a0)+,16(a2)
	move.w (a0)+,24(a2)
	add.w d1,a2
	dbra d0,.loop

	ifd vbl_timer
	move.w #$777,$ffff8240.w
	endc

	movem.l (a7)+,d0-a6
	rte

logo_mover
	move.l scr1,a0
	move.l logoptr,a1
	move.l (a1)+,d0
	bpl.s .ok
	lea logopos,a1
	move.l (a1)+,d0
.ok	move.l a1,logoptr
	add.l d0,a0

	move.l d0,-(a7)
	lea -160*9(a0),a6
	sub.l #160*9,d0
	bsr .erase
	move.l (a7)+,d0
	
	lea logo+34,a1
	move.l #49,d1
.line	movem.l (a1),d2-7/a2-5
	movem.l d2-7/a2-5,(a0)
	movem.l 40(a1),d2-7/a2-5
	movem.l d2-7/a2-5,40(a0)
	movem.l 80(a1),d2-7/a2-5
	movem.l d2-7/a2-5,80(a0)
	movem.l 120(a1),d2-7/a2-5
	movem.l d2-7/a2-5,120(a0)	
	add.l #160,d0
	lea 160(a0),a0
	lea 160(a1),a1
	dbra d1,.line
	move.l a0,a6

.erase
	moveq.l #8,d1
	moveq.l #0,d5
.wline
x	set 0
	rept 40
	move.l d5,x(a6)
x	set x+4
	endr
	add.l #160,d0
	lea 160(a6),a6
	dbra d1,.wline

	rts

init_text
	lea line1(pc),a1
	lea line_buff(pc),a0
	bsr print
	rts

; call with a1 pointing at text
;           a0 pointing at plotting address

next_add	dc.l 0
line_buff	ds.b 40*200

;	dc.b "0123456789012345678901234567890123456789"

line1	DC.B -2
	DC.B -2
	DC.B "           D.BUG MENU  XXXXX",-2
	DC.B "           .................",-2
	DC.B -2
	DC.B -2
	DC.B "      PLEASE SELECT A GAME TITLE",-2
	DC.B -2
	DC.B "      1)    X",-2
	DC.B "      2)    Y",-2
	DC.B "      3)    Z",-2
	DC.B -2
	DC.B "   ALL CRACKS BY HOT.KNIFE OF D.BUG",-2
	DC.B -2
	DC.B " INTRO CODED BY CYRANO JONES OF D.BUG",-2
	DC.B -2
	DC.B " GREETINGS TO:",-2
	DC.B " THE BBC, AUTOMATION, UNITY, THE MEDWAY",-2
	DC.B " BOYS, THE REPLICANTS, ELITE, CYNIX, PP",-2
	DC.B " HOTLINE (EUROPEAN), HAL, MOB, AND DACK",-1
	EVEN

print	move.l a0,next_add
.loop	moveq.l #0,d0
	move.b (a1)+,d0
	bpl.s .write
	cmp.b #-1,d0
	beq.s .wrap
.nextline
	move.l next_add,a0
	add.l #40*9,a0
	move.l a0,next_add
	bra.s .loop
.wrap	rts
.write	sub.b #' ',d0
	add d0,d0
	add d0,d0
	lea ascii(pc),a2
	move.l (a2,d0),a2
	bsr.s .plotit
	bra. .loop
.plotit	
x	set 0
y	set 0
	rept 8
	move.b x(a2),y(a0)
x	set x+40
y	set y+40
	endr
	add.l #1,a0
	rts

font_x	incbin rawfont.bin
	even

ascii	
xx	set font_x
	rept 40
	dc.l xx
xx	set xx+1
	endr
xx	set font_x+(40*8)
	rept 40
	dc.l xx
xx	set xx+1
	endr

screen1	dc.l ramtop-($10000*2)
screen2	dc.l ramtop-($10000*3)
scr1	dc.l ramtop-(($10000*2)+64*160)
scr2	dc.l ramtop-(($10000*3)+64*160)

save_all	ds.b 100

logoptr	dc.l logopos
logopos	incbin logo_y.bin
	dc.l -1,-1
	even
logo	incbin d_bug.dat
	even
music	incbin lap1.max
	even