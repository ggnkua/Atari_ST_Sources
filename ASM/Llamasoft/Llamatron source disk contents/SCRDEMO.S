*** SCROLLTEST: demo the SCROLLX core extensions

yak_is_cool: jsr game_reset	;start up Kore
 move.l #tpal,source_pal	;a default palette
 move.l #yaklist,clist		;a default HBL list
 jsr waisync			;ensure it is displayed
 move.l #xli,a0
 jsr expand			;make test sprite PSI
 move.l #mysprites,a0		;set up for initialise scroll
 move.l #myscroll,a1		;address scroll sequence list
 move #30,d0			;scroll height
 move #31,d1			;# bloks in scroll
 move #0,d2			;scroll #0
 move #0,d3			;initial scroll position
 jsr setup_scroll		;install the scroll
 move.l back_screen,a0
 jsr cls
 jsr xfrombak			;clear the screens

 move #256,mxmax
 move #128,xpos			;for this demo mouse X controls speed
 move #200,mymax
 move #199,ypos			;and Y enables the scrolls

 move #1,vbswitch		;turn on the scroll
 move.l #skroll,scroll_business	;give it a vector
 move.l #ring,the_business	;ring of sprites
camel: jsr gpsprite		;loop to see it
 bra camel


ring:
;
;draw a circling ring of sprites over the scroll
;
 tst son
 bne do_ring
 rts

do_ring: move.l ascreen,a1
 move #0,d2
do_r: move d2,-(a7)
 move.l #sine,a3
 add phase,d2
 and #$ff,d2
 move.b 0(a3,d2.w),d0
 ext d0
 asr #1,d0
 add #160,d0
 add.b #$40,d2
 move.b 0(a3,d2.w),d1
 ext d1
 asr #1,d1
 add #100,d1
 move.l #tsprite,a0
 jsr csprite
 move (a7)+,d2
 add sstep,d2
 cmp #256,d2
 bmi do_r
rrts: rts

skroll:
 tst xf
 beq skroll1
 jsr xfrombak
 move #0,xf
skroll1: move.l #6400,d0		;line 40
 move #0,d1			;scroll 0
 move.l #-320,vskip		;invert scroll
 move sc3,sdl+12			;offset 3
 jsr draw_scroll

 cmp #90,ypos
 bpl dos2 
 tst s2on
 beq rrts
 move #1,xf
 move #0,s2on
 rts
dos2: move.l #14400,d0		;repeat scroll at line 90
 move #0,d1
 move.l #160,vskip		;expanded by 1 scanline
 move sc2,sdl+12		;offset 2
 move #1,s2on
 jsr draw_scroll

 cmp #160,ypos
 bpl dos3
 tst s3on
 beq rrts
 move #1,xf
 move #0,s3on
 rts
dos3: move.l #25600,d0
 move #0,d1			;line 160,scroll 0
 move.l #0,vskip		;'normal' scroll
 move sc1,sdl+12		;place offset 1
 move #1,s3on
 jmp draw_scroll		;drawit

 
scroll_irq: add #1,phase
 move xpos,d1	;get mouse X reading
 sub #128,d1			;xlate to +/- 128
 add d1,sc1			;add to th' scroll position
 asr #1,d1
 add d1,sc2
 asr #1,d1
 add d1,sc3			;very rough parallax
 move.b buttons,d0
 and #3,d0
 bne acomd			;command to change # balls
 move #0,debounce
 rts
acomd: tst debounce
 bne rrts
 move #1,debounce
 cmp #3,d0
 bne acomd1
 eor #1,son
 rts
acomd1: btst #0,d0
 beq acomd2
 add #1,sstep
 rts
acomd2: btst #1,d0
 beq rrts
 sub #1,sstep
 rts

yaklist: dc.w $770,4,$761,4,$752,4,$743,4,$734,4,$725,4,$716,4,$707,4
	dc.w $617,4,$527,4,$437,4,$347,4,$257,4,$167,4,$077,4,$067,4
	dc.w $057,4,$047,4,$037,4,$027,4,$017,4,$007,4,$006,4,$005,4
	dc.w $004,4,$003,4
	dc.w $004,4,$005,4,$006,4,$007,4,$017,4,$027,4,$037,4,$047,4
	dc.w $057,4,$067,4,$077,4,$167,4,$257,4,$347,4,$437,4,$527,4
	dc.w $617,4,$707,4,$716,4,$725,4,$734,4,$743,4,$752,4,$761,200


debounce: dc.w 0

sc1: dc.w 0			;offsets for 3 demo scrolls
sc2: dc.w 0
sc3: dc.w 0

s2on: dc.w 1
s3on: dc.w 1
xf: dc.w 0
phase: dc.w 0			;phase for sine ring demo
son: dc.w 1			;flag for sprite display on/off
sstep: dc.w 16			;determines number of balls

vblist: dc.l null,scroll_irq,null
axvec: dc.l null,null,null

xli: dc.l tsprite,-1

tpal: dc.w $0000,$0700,$0730,$0750,$0770,$0470,$0070,$0075
 dc.w $0077,$0057,$0027,$0007,$0333,$0555,$666,$0777


tsprite: dc.w 3,0,15,15		;test sprite to plot on top

	dc.w	$01A0,$0060,$07E0,$07E0,$0398,$0078,$1FF8,$1FF8
	dc.w	$071C,$00FC,$3FFC,$3FFC,$078E,$007E,$7FFE,$7FFE
	dc.w	$078E,$007E,$7FFE,$7FFE,$CCD5,$3C33,$03F0,$000F
	dc.w	$CCD5,$3C33,$03F0,$000F,$CCD5,$3C33,$03F0,$000F
	dc.w	$CCD5,$3C33,$03F0,$000F,$CCD5,$3C33,$03F0,$000F
	dc.w	$CCD5,$3C33,$03F0,$000F,$078E,$007E,$7FFE,$7FFE
	dc.w	$078E,$007E,$7FFE,$7FFE,$071C,$00FC,$3FFC,$3FFC
	dc.w	$0398,$0078,$1FF8,$1FF8,$01A0,$0060,$07E0,$07E0



tblok: dc.w 3,1,30,31		;dummy header info

	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0001,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0003,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0007,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$000F,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$001F,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$003F,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$003F,$0000
	dc.w	$0000,$0000,$0000,$0000,$007F,$007F,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$00F7,$00FF,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$007F,$01FF,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$03DF,$03FF,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$07FF,$07FF,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$01DF,$0FFF,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$1FFF,$1FFF,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$3FFF,$3FFF,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$7E7F,$7FFF,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$7FFF,$7FFF,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$83FF,$FFFF,$0000,$0000
	dc.w	$0001,$0001,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$0003,$0003,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$0007,$0007,$0000,$0000,$F9FF,$FFFF,$0000,$0000
	dc.w	$0000,$000F,$0000,$0000,$7FFF,$FFFF,$0000,$0000
	dc.w	$001F,$001F,$0000,$0000,$FFDF,$FFFF,$0000,$0000
	dc.w	$003F,$003F,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$007F,$007F,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$00F8,$00FF,$0000,$0000,$3FFF,$FFFF,$0000,$0000
	dc.w	$001F,$00FF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$01FF,$01FF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$03FD,$FFFF,$0000,$0000,$F9FF,$FFFF,$0000,$0000
	dc.w	$07FF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$0FFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000

tblok1: dc.w 3,1,30,31	
	dc.w	$0000,$0000,$8000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$C000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$E000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$F000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$F800,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$FC00,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$FC00,$0000,$0000,$0000,$0000,$0000
	dc.w	$FE00,$FE00,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$FF00,$FF00,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$FF80,$FF80,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$FFC0,$FFC0,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$FFE0,$FFE0,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$FFF0,$FFF0,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$FFF8,$FFF8,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$FFFC,$FFFC,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$FFFE,$FFFE,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$FFFE,$FFFE,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$8000,$8000,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$C000,$C000,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$E000,$E000,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$F000,$F000,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$F800,$F800,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FC00,$FC00,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FE00,$FE00,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FF00,$FF00,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FF00,$FF00,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FF80,$FF80,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFC0,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFE0,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFF0,$FFFF,$0000,$0000
tblok2: dc.w 3,1,30,31	
	dc.w	$7000,$0000,$7000,$0000,$0000,$0000,$0000,$0000
	dc.w	$FE00,$0000,$FE00,$0000,$0000,$0000,$0000,$0000
	dc.w	$1F80,$0000,$1F80,$0000,$0000,$0000,$0000,$0000
	dc.w	$03E0,$0000,$03E0,$0000,$1F00,$0000,$1F00,$0000
	dc.w	$01F0,$0000,$01F0,$0000,$7FC0,$0000,$7FC0,$0000
	dc.w	$0070,$0000,$0070,$0000,$FFF0,$0000,$FFF0,$0000
	dc.w	$0038,$0000,$0038,$0000,$FFF8,$0000,$FFF8,$0000
	dc.w	$0039,$0000,$0039,$0000,$C038,$3FC0,$FFF8,$0000
	dc.w	$7F1D,$0000,$7F1D,$0000,$800C,$7070,$F07C,$0000
	dc.w	$80DF,$7F0C,$FFD3,$0000,$000C,$C010,$C01C,$0000
	dc.w	$803F,$00CE,$80F1,$0000,$000E,$0000,$000E,$0000
	dc.w	$000E,$003E,$0030,$0000,$0002,$0000,$0002,$0000
	dc.w	$000E,$001E,$0010,$0000,$0000,$0000,$0000,$0000
	dc.w	$000E,$001E,$0010,$0000,$0000,$0000,$0000,$0000
	dc.w	$001C,$001C,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$001C,$001C,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$001C,$001C,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$001C,$001C,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$001C,$001C,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$001C,$001C,$0000,$0000,$0000,$0000,$0008,$0000
	dc.w	$001C,$001C,$0000,$0000,$0000,$0000,$000C,$0000
	dc.w	$001C,$001C,$0000,$0000,$0000,$0000,$0708,$0000
	dc.w	$001C,$001C,$0000,$0000,$0000,$0000,$0F98,$0000
	dc.w	$000C,$000C,$0000,$0000,$0000,$0000,$1FF0,$0000
	dc.w	$000E,$000E,$0000,$0000,$0000,$0000,$17E0,$0000
	dc.w	$000E,$000E,$0000,$0000,$0000,$0000,$1080,$0000
	dc.w	$000E,$000E,$0000,$0000,$0000,$0000,$1080,$0000
	dc.w	$001F,$001F,$0000,$0000,$0000,$0000,$18C0,$0000
	dc.w	$0000,$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000
	dc.w	$0000,$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000
	dc.w	$0000,$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000



mysprites: dc.l tblok,tblok1,tblok2,0

myscroll: dc.w 0,1,0,1,2,0,1,0,1,2,2,2,0,1,2,2
	dc.w 2,2,2,2,0,1,0,1,2,0,1,2,0,1,2,2

 include e:\gamecore\kore1a.s



