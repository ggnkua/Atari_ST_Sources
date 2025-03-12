***************************************************************

** YAK's GAME CORE STUFF **************************************

** LAST REVISION 10/11/89 *************************************

** check out the new fast DEL_ALS!!

***************************************************************


messager:
;
; Little routine to do pages full of text (pass the address in
; a0.l). Assumes fade is DOWN!!!
;
 move #1,botchk
 move.l a0,-(a7)
 move #199,r_pos
 move #-1,r_dir
; move #2,vbswitch
 move.l #ssampl_lst,clist
 jsr pclr
 move.l #grid_pal,source_pal
 move.l #css1,cseqlst+8
 move.l #css2,cseqlst+12
 move.l #css3,cseqlst+16
 move.l (a7)+,a0
 move.l #gridefs,griptr
mmm: move.l a0,-(a7)
 move.l back_screen,a0
 jsr cls
 move.l griptr,a0
 move #0,unDraw
 move.l (a0),a0
 cmp.l #-1,a0
 bne mgr
 move.l #gridefs,griptr
 move.l gridefs,a0
mgr: move.l back_screen,a1
 move #0,d0
mgr1: move #0,d1
mgr2: movem.l d0-d1/a0-a1,-(a7)
 jsr sdraw
 movem.l (a7)+,d0-d1/a0-a1
 add #20,d1
 cmp #200,d1
 bne mgr2
 add #32,d0
 cmp #320,d0
 bne mgr1
 move.l (a7)+,a0
 move.b #1,txtmode
 move #6,txt_x
 move #4,txt_y
 jsr print
 move d0,mret
 move.l a0,-(a7)
 move txtcol,-(a7)
 move cfont,-(a7)
 move.l #premes,a0
 jsr print
 move (a7)+,cfont
 move (a7)+,txtcol
 jsr xfrombak
 move #2,fstart
 move #15,fend
 move #1,fstep
 move #7,fto
 move #10,fdel
 move #10,fdel_c
 move #1,fon
iut: tst fon
 bne iut
iut1: move.b buttons,d0
 btst #1,d0
 beq iut1
 move #2,fstart
 move #15,fend
 move #-1,fstep
 move #0,fto
 move #10,fdel
 move #10,fdel_c
 move #1,fon
iut2: tst fon
 bne iut2
 add.l #4,griptr
 move.l (a7)+,a0
 tst mret
 bne mmm
 move #0,botchk
 rts

grid_pal: dc.w $0000,$0400,$0700,$0730,$0770,$0070,$0077,$0057
 dc.w $0703,$0007,$0206,$0004,$0444,$0555,$0666,$0777

premes: dc.b '\g',0,190,'\c',2,'<press left klongle for more>\e'

gridefs: dc.l t1,t2,t3,t4,t5,t6,t7,t8,-1
griptr: dc.l gridefs

t8:
	dc.w 3,1,19,31
	dc.w	$0000,$FFFF,$0000,$FFFF,$0000,$FFFF,$0000,$FFFF
	dc.w	$3EE9,$8000,$0000,$8000,$BB8F,$0001,$0000,$0001
	dc.w	$2AA9,$8000,$0000,$8000,$210B,$0001,$0000,$0001
	dc.w	$2AA9,$8000,$0000,$8000,$B90F,$0001,$0000,$0001
	dc.w	$22A9,$8000,$0000,$8000,$090B,$0001,$0000,$0001
	dc.w	$22ED,$8000,$0000,$8000,$B90B,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$3F7E,$8000,$0000,$8000,$FDFD,$0001,$0000,$0001
	dc.w	$2042,$8000,$0000,$8000,$8421,$0001,$0000,$0001
	dc.w	$2742,$8000,$0000,$8000,$FC21,$0001,$0000,$0001
	dc.w	$2142,$8000,$0000,$8000,$8421,$0001,$0000,$0001
	dc.w	$2142,$8000,$0000,$8000,$8421,$0001,$0000,$0001
	dc.w	$3F7E,$8000,$0000,$8000,$8421,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$3BB3,$8000,$0000,$8000,$AA81,$0001,$0000,$0001
	dc.w	$12AA,$8000,$0000,$8000,$AA81,$0001,$0000,$0001
	dc.w	$12AB,$8000,$0000,$8000,$BA81,$0001,$0000,$0001
	dc.w	$12AA,$8000,$0000,$8000,$9001,$0001,$0000,$0001
	dc.w	$13B2,$8000,$0000,$8000,$9281,$0001,$0000,$0001
	dc.w	$7FFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000,$FFFF
t1: dc.w 3,1,19,31
	dc.w	$0000,$FFFF,$0000,$FFFF,$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$0042,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$0081,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$00BD,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$007E,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$003C,$8000,$0000,$8000,$6001,$0001,$0000,$0001
	dc.w	$0019,$8000,$0000,$8000,$FC01,$0001,$0000,$0001
	dc.w	$001B,$8000,$0000,$8000,$FF01,$0001,$0000,$0001
	dc.w	$0003,$8000,$0000,$8000,$FFE1,$0001,$0000,$0001
	dc.w	$000F,$8000,$0000,$8000,$FFD1,$0001,$0000,$0001
	dc.w	$0007,$8000,$0000,$8000,$FFD1,$0001,$0000,$0001
	dc.w	$0017,$8000,$0000,$8000,$D781,$0001,$0000,$0001
	dc.w	$0016,$8000,$0000,$8000,$45A1,$0001,$0000,$0001
	dc.w	$0014,$8000,$0000,$8000,$01A1,$0001,$0000,$0001
	dc.w	$0014,$8000,$0000,$8000,$0121,$0001,$0000,$0001
	dc.w	$003C,$8000,$0000,$8000,$0361,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$7FFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000,$FFFF
t2: dc.w 3,1,19,31
	dc.w	$0000,$FFFF,$0000,$FFFF,$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$8000,$0000,$8000,$4001,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0801,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$2801,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$D001,$0001,$0000,$0001
	dc.w	$0001,$8000,$0000,$8000,$D001,$0001,$0000,$0001
	dc.w	$0003,$8000,$0000,$8000,$F001,$0001,$0000,$0001
	dc.w	$000F,$8000,$0000,$8000,$C001,$0001,$0000,$0001
	dc.w	$003F,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$00F8,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$03E7,$8000,$0000,$8000,$74B7,$0001,$0000,$0001
	dc.w	$0704,$8000,$0000,$8000,$54A5,$0001,$0000,$0001
	dc.w	$0007,$8000,$0000,$8000,$74B7,$0001,$0000,$0001
	dc.w	$0001,$8000,$0000,$8000,$44A5,$0001,$0000,$0001
	dc.w	$0007,$8000,$0000,$8000,$46A5,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$7FFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000,$FFFF
t3: dc.w 3,1,19,31
	dc.w	$0000,$FFFF,$0000,$FFFF,$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$A001,$0001,$0000,$0001
	dc.w	$1E00,$8000,$0000,$8000,$A401,$0001,$0000,$0001
	dc.w	$1248,$8000,$0000,$8000,$A801,$0001,$0000,$0001
	dc.w	$120C,$8000,$0000,$8000,$B401,$0001,$0000,$0001
	dc.w	$1E4A,$8000,$0000,$8000,$A201,$0001,$0000,$0001
	dc.w	$1049,$8000,$0000,$8000,$A101,$0001,$0000,$0001
	dc.w	$1048,$8000,$0000,$8000,$A081,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$1E01,$8000,$0000,$8000,$0B81,$0001,$0000,$0001
	dc.w	$1000,$8000,$0000,$8000,$8A41,$0001,$0000,$0001
	dc.w	$109C,$8000,$0000,$8000,$5221,$0001,$0000,$0001
	dc.w	$1C94,$8000,$0000,$8000,$2211,$0001,$0000,$0001
	dc.w	$109C,$8000,$0000,$8000,$2211,$0001,$0000,$0001
	dc.w	$1080,$8000,$0000,$8000,$2211,$0001,$0000,$0001
	dc.w	$10F0,$8000,$0000,$8000,$23E1,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$7FFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000,$FFFF
t4: dc.w 3,1,19,31
	dc.w	$0000,$FFFF,$0000,$FFFF,$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$3ABA,$8000,$0000,$8000,$4201,$0001,$0000,$0001
	dc.w	$22A2,$8000,$0000,$8000,$8505,$0001,$0000,$0001
	dc.w	$32A3,$8000,$0000,$8000,$070B,$0001,$0000,$0001
	dc.w	$22A2,$8000,$0000,$8000,$871D,$0001,$0000,$0001
	dc.w	$23BA,$8000,$0000,$8000,$471D,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0339,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$DB39,$0001,$0000,$0001
	dc.w	$1094,$8000,$0000,$8000,$DB71,$0001,$0000,$0001
	dc.w	$1094,$8000,$0000,$8000,$DB61,$0001,$0000,$0001
	dc.w	$1094,$8000,$0000,$8000,$FFE1,$0001,$0000,$0001
	dc.w	$1094,$8000,$0000,$8000,$7FC1,$0001,$0000,$0001
	dc.w	$1094,$8000,$0000,$8000,$7FC1,$0001,$0000,$0001
	dc.w	$1094,$8000,$0000,$8000,$7FC1,$0001,$0000,$0001
	dc.w	$1094,$8000,$0000,$8000,$7FC1,$0001,$0000,$0001
	dc.w	$1080,$8000,$0000,$8000,$3F81,$0001,$0000,$0001
	dc.w	$1F94,$8000,$0000,$8000,$3F81,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$3F81,$0001,$0000,$0001
	dc.w	$7FFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000,$FFFF
t5: dc.w 3,1,19,31
	dc.w	$0000,$FFFF,$0000,$FFFF,$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$3BEB,$8000,$0000,$8000,$BB7F,$0001,$0000,$0001
	dc.w	$2AAA,$8000,$0000,$8000,$2AD9,$0001,$0000,$0001
	dc.w	$3AAA,$8000,$0000,$8000,$BADF,$0001,$0000,$0001
	dc.w	$2A2A,$8000,$0000,$8000,$AAD3,$0001,$0000,$0001
	dc.w	$2A2B,$8000,$0000,$8000,$AB7F,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$3D2F,$8000,$0000,$8000,$A5F5,$0001,$0000,$0001
	dc.w	$2128,$8000,$0000,$8000,$2505,$0001,$0000,$0001
	dc.w	$2128,$8000,$0000,$8000,$2905,$0001,$0000,$0001
	dc.w	$2128,$8000,$0000,$8000,$3105,$0001,$0000,$0001
	dc.w	$3D28,$8000,$0000,$8000,$29F5,$0001,$0000,$0001
	dc.w	$0528,$8000,$0000,$8000,$2415,$0001,$0000,$0001
	dc.w	$0528,$8000,$0000,$8000,$2415,$0001,$0000,$0001
	dc.w	$0528,$8000,$0000,$8000,$2411,$0001,$0000,$0001
	dc.w	$3DEF,$8000,$0000,$8000,$A5F5,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$7FFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000,$FFFF
t6: dc.w 3,1,19,31
	dc.w	$0000,$FFFF,$0000,$FFFF,$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$3FC1,$8000,$0000,$8000,$89F9,$0001,$0000,$0001
	dc.w	$3201,$8000,$0000,$8000,$8981,$0001,$0000,$0001
	dc.w	$3201,$8000,$0000,$8000,$9181,$0001,$0000,$0001
	dc.w	$0279,$8000,$0000,$8000,$E181,$0001,$0000,$0001
	dc.w	$0269,$8000,$0000,$8000,$91E1,$0001,$0000,$0001
	dc.w	$0269,$8000,$0000,$8000,$8987,$0001,$0000,$0001
	dc.w	$0279,$8000,$0000,$8000,$8987,$0001,$0000,$0001
	dc.w	$0201,$8000,$0000,$8000,$89FF,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$0AE1,$8000,$0000,$8000,$0215,$0001,$0000,$0001
	dc.w	$0AA3,$8000,$0000,$8000,$8715,$0001,$0000,$0001
	dc.w	$0AE5,$8000,$0000,$8000,$4A95,$0001,$0000,$0001
	dc.w	$0A81,$8000,$0000,$8000,$0201,$0001,$0000,$0001
	dc.w	$0E81,$8000,$0000,$8000,$0215,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$7FFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000,$FFFF
t7: dc.w 3,1,19,31
	dc.w	$0000,$FFFF,$0000,$FFFF,$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$01FF,$8000,$0000,$8000,$E001,$0001,$0000,$0001
	dc.w	$0700,$8000,$0000,$8000,$3801,$0001,$0000,$0001
	dc.w	$05FF,$8000,$0000,$8000,$F801,$0001,$0000,$0001
	dc.w	$0400,$8000,$0000,$8000,$0BC1,$0001,$0000,$0001
	dc.w	$0400,$8000,$0000,$8000,$0FE1,$0001,$0000,$0001
	dc.w	$04FF,$8000,$0000,$8000,$CE31,$0001,$0000,$0001
	dc.w	$04FF,$8000,$0000,$8000,$C831,$0001,$0000,$0001
	dc.w	$040C,$8000,$0000,$8000,$0831,$0001,$0000,$0001
	dc.w	$040C,$8000,$0000,$8000,$0831,$0001,$0000,$0001
	dc.w	$040C,$8000,$0000,$8000,$0871,$0001,$0000,$0001
	dc.w	$040C,$8000,$0000,$8000,$0FE1,$0001,$0000,$0001
	dc.w	$040C,$8000,$0000,$8000,$0FC1,$0001,$0000,$0001
	dc.w	$040C,$8000,$0000,$8000,$0801,$0001,$0000,$0001
	dc.w	$0300,$8000,$0000,$8000,$3001,$0001,$0000,$0001
	dc.w	$00FF,$8000,$0000,$8000,$C001,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$0000,$8000,$0000,$8000,$0001,$0001,$0000,$0001
	dc.w	$7FFF,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000,$FFFF





rkbd: move #$ff,-(a7)		;read kbd and return in d0
 move #6,-(a7)
 trap #1
 add.l #4,a7
 and #$ff,d0
 beq rkq
 or #$20,d0			;ensure lowercase
rkq: rts

;This routine PROJECT transforms a point in 3-D space X,Y,Z
;given by d0,d1,d2 onto two-dimensional screen space (the
;co-ordinates are returned in d0,d1). The projection depth is
;given by the negative parameter in variable proj3d.
;
;Uses dim address registers; vapes d2-d6

proj3d: dc.w -760

project:
 tst d2
 bne bakka
 rts		;trivial case if z is zero!
bakka:
 move d0,d4	;don't worry I don't understand it either
 move d2,d5
 muls d5,d4
 move proj3d,d6 ; prozz' 
 sub d5,d6
 divs d6,d4 ; d4 is p1u*p1z/(prozz'-p1z)
 add d0,d4
 move d4,d0 ; d0 has 2-D xpos
 move d1,d4
 move d2,d5
 muls d5,d4 ; p1v*p1z
 divs d6,d4 ; p1v*p1z/(prozz'-p1z)
 add d1,d4
 move d4,d1 ; d1 has 2-D ypos
 rts

h2oles: dc.w $3fff,$3fff,$cfff,$cfff,$f3ff,$f3ff,$fcff,$fcff
	dc.w $ff3f,$ff3f,$ffcf,$ffcf,$fff3,$fff3,$fffc,$fffc
b2its: dc.w $c000,$c000,$3000,$3000,$0c00,$0c00,$0300,$0300
	dc.w $00c0,$00c0,$0030,$0030,$000c,$000c,$0003,$0003

holes: dc.w $7fff,$bfff,$dfff,$efff,$f7ff,$fbff,$fdff,$feff
 dc.w $ff7f,$ffbf,$ffdf,$ffef,$fff7,$fffb,$fffd,$fffe
bits: dc.w $8000,$4000,$2000,$1000,$0800,$0400,$0200,$0100
 dc.w $0080,$0040,$0020,$0010,$0008,$0004,$0002,$0001
ct1: dc.w 0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1
ct2: dc.w 0,0,0,0,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1
ct3: dc.w 0,0,-1,-1,0,0,-1,-1,0,0,-1,-1,0,0,-1,-1
ct4: dc.w 0,-1,0,-1,0,-1,0,-1,0,-1,0,-1,0,-1,0,-1

yclp: dc.w 0

pplot:
;
;Pixel plot (d0,d1) colour=d2 on ascreen
;
 cmp yclp,d1		;hard clip for tad game
 bpl pokay
 rts
pokay:
; move d1,(a2)+
; move d0,(a2)+
; move.l #0,(a2)+	;for unDraw
; move #-500,(a2)
pplot1: move d2,d6		;save colour
; move.w ypos,d1
 move d0,d2
 asl.w #2,d1
 move.l #ytab,a0
 move.l 0(a0,d1.w),d0
 move.w d2,d1
 and.l #$0ff0,d1
 asr.w #1,d1
 add.l d1,d0
 move.l #0,(a2)+
 move.l d0,(a2)+
 move #-500,(a2)
 add.l a1,d0
 move.w d2,d1
 asl #1,d1
 and #$001f,d1
 lea holes,a0
 move.w 0(a0,d1.w),d2
 lea bits,a0
 move.w 0(a0,d1.w),d3
 lea ct4,a0
; move.w colour,d6
 asl.w #1,d6
 move.w 0(a0,d6.w),d4
 move.l d0,a3
 move.w (a3),d5
 and.w d2,d5
 and.w d3,d4
 or.w d4,d5
 move.w d5,(a3)+
 move.w -32(a0,d6.w),d4
 move.w (a3),d5
 and.w d2,d5
 and.w d3,d4
 or.w d4,d5
 move.w d5,(a3)+
 move.w -64(a0,d6.w),d4
 move.w (a3),d5
 and.w d2,d5
 and.w d3,d4
 or.w d4,d5
 move.w d5,(a3)+
 move.w -96(a0,d6.w),d4
qputit: 
 move.w (a3),d5
 and.w d2,d5
 and.w d3,d4
 or.w d4,d5
 move.w d5,(a3)+
 rts

p2plot:
;
;Pixel plot (d0,d1) colour=d2 on ascreen pix size 2x1
;
 and #$1fe,d0		;2x1 pixels
 cmp yclp,d1		;hard clip for tad game
 bpl p2okay
 rts
p2okay:
; move d1,(a2)+
; move d0,(a2)+
; move.l #0,(a2)+	;for unDraw
; move #-500,(a2)
p2plot1: move d2,d6		;save colour
; move.w ypos,d1
 move d0,d2
 asl.w #2,d1
 move.l #ytab,a0
 move.l 0(a0,d1.w),d0
 move.w d2,d1
 and.l #$0ff0,d1
 asr.w #1,d1
 add.l d1,d0
 move.l #0,(a2)+
 move.l d0,(a2)+
 move #-500,(a2)
 add.l a1,d0
 move.w d2,d1
 asl #1,d1
 and #$001f,d1
 lea h2oles,a0
 move.w 0(a0,d1.w),d2
 lea b2its,a0
 move.w 0(a0,d1.w),d3
 lea ct4,a0
; move.w colour,d6
 asl.w #1,d6
 move.w 0(a0,d6.w),d4
 move.l d0,a3
 move.w (a3),d5
 and.w d2,d5
 and.w d3,d4
 or.w d4,d5
 move.w d5,(a3)+
 move.w -32(a0,d6.w),d4
 move.w (a3),d5
 and.w d2,d5
 and.w d3,d4
 or.w d4,d5
 move.w d5,(a3)+
 move.w -64(a0,d6.w),d4
 move.w (a3),d5
 and.w d2,d5
 and.w d3,d4
 or.w d4,d5
 move.w d5,(a3)+
 move.w -96(a0,d6.w),d4
 move.w (a3),d5
 and.w d2,d5
 and.w d3,d4
 or.w d4,d5
 move.w d5,(a3)+
 rts

_bak: dc.w 0

bgp:
 move.l d5,a4
 add.l back_screen,a4		;a4 is source screen


 move (a4),d2
 or 2(a4),d2
 or 4(a4),d2
 or 6(a4),d2	;positive mask of screen
 eor #$ffff,d2	;invert mask

 move d4,d7
 and d3,d7
 and d2,d7
 move 160(a4),d5
 or d7,d5
 move d5,160(a3) 
 

 and d3,d4
 and d2,d4	;cut out pixel with mask
 move.w (a4)+,d5
 or d4,d5
 move d5,(a3)+

 move.w -32(a0,d6.w),d4
 move d4,d7
 and d3,d7
 and d2,d7
 move 160(a4),d5
 or d7,d5
 move d5,160(a3) 


 and d3,d4
 and d2,d4
 move.w (a4)+,d5
 or.w d4,d5
 move.w d5,(a3)+

 move.w -64(a0,d6.w),d4
 move d4,d7
 and d3,d7
 and d2,d7
 move 160(a4),d5
 or d7,d5
 move d5,160(a3) 
 and d3,d4
 and d2,d4
 move.w (a4)+,d5
 or.w d4,d5
 move.w d5,(a3)+

 move.w -96(a0,d6.w),d4
 move d4,d7
 and d3,d7
 and d2,d7
 move 160(a4),d5
 or d7,d5
 move d5,160(a3) 
 and d3,d4
 and d2,d4
 move.w (a4)+,d5
 or.w d4,d5
 move.w d5,(a3)+
 rts

plotall3: and #$1fe,d0
 movem.l a0-a2,-(a7)
 movem d0-d2,-(a7)
 move.l ascreen,a1
 move.l #cen_bufr,a2
 bsr p3okay
 movem (a7)+,d0-d2
 movem d0-d2,-(a7)
 move.l bscreen,a1
 move.l #cen_bufr,a2
 bsr p3okay
 movem (a7)+,d0-d2
 movem d0-d2,-(a7)
 move.l cscreen,a1
 move.l #cen_bufr,a2
 bsr p3okay
 movem (a7)+,d0-d2
 movem d0-d2,-(a7)
 move.l back_screen,a1
 move.l #cen_bufr,a2
 bsr p3okay
 movem (a7)+,d0-d2
 movem.l (A7)+,a0-a2
 rts

p3plotu: and #$1fe,d0
 bra p3okay

p3plot:
;
;Pixel plot (d0,d1) colour=d2 on ascreen pix size 2x2
;
 and #$1fe,d0		;2x1 pixels
 cmp yclp,d1		;hard clip for tad game
 bpl p3okay
p3end: rts
p3okay: cmp #198,d1
 bpl p3end		;no allow line 198 as pixels are 2x2
; or #$8000,d1		;set top bit of d1 to id a 2x2 to undraw
; move d1,(a2)+
; and #$ff,d1		;restore old value
; move d0,(a2)+
; move.l #0,(a2)+	;for unDraw
; move #-500,(a2)
p3plot1: move d2,d6		;save colour
; move.w ypos,d1
 move d0,d2
 asl.w #2,d1
 move.l #ytab,a0
 move.l 0(a0,d1.w),d0
 move.w d2,d1
 and.l #$0ff0,d1
 asr.w #1,d1
 add.l d1,d0
 move #0,(a2)+
 move #1,(a2)+
 move.l d0,(a2)+
 move #-500,(a2)
 move.l d0,d5
 add.l a1,d0
 move.w d2,d1
 asl #1,d1
 and #$001f,d1
 lea h2oles,a0
 move.w 0(a0,d1.w),d2
 lea b2its,a0
 move.w 0(a0,d1.w),d3
 lea ct4,a0
; move.w colour,d6
 asl.w #1,d6
 move.l d0,a3

 move 0(a0,d6.w),d4
 tst _bak
 bne bgp
 move 160(a3),d5
 and d2,d5
 and d3,d4
 or d4,d5
 move d5,160(a3)	;extra 2x2 plot pixel

 move 0(a0,d6.w),d4
 move.w (a3),d5
 and.w d2,d5
 and.w d3,d4
 or.w d4,d5
 move.w d5,(a3)+

 move -32(a0,d6.w),d4
 move 160(a3),d5
 and d2,d5
 and d3,d4
 or d4,d5
 move d5,160(a3)	;extra 2x2 plot pixel

 move.w -32(a0,d6.w),d4
 move.w (a3),d5
 and.w d2,d5
 and.w d3,d4
 or.w d4,d5
 move.w d5,(a3)+

 move -64(a0,d6.w),d4
 move 160(a3),d5
 and d2,d5
 and d3,d4
 or d4,d5
 move d5,160(a3)	;extra 2x2 plot pixel

 move.w -64(a0,d6.w),d4
 move.w (a3),d5
 and.w d2,d5
 and.w d3,d4
 or.w d4,d5
 move.w d5,(a3)+

 move -96(a0,d6.w),d4
 move 160(a3),d5
 and d2,d5
 and d3,d4
 or d4,d5
 move d5,160(a3)	;extra 2x2 plot pixel

 move.w -96(a0,d6.w),d4
 move.w (a3),d5
 and.w d2,d5
 and.w d3,d4
 or.w d4,d5
 move.w d5,(a3)+
 rts

uplot:
;
;Pixel unplot taking into account contents of back_screen
;
 move d1,d2
 and #$8000,d2		;check for 2x2 unplot
 beq u1plot
 and #$ff,d1		;strip off 2x2 ID bit
 move d0,d2
 asl.w #2,d1
 move.l #ytab,a0
 move.l 0(a0,d1.w),d0
 move.w d2,d1
 and.l #$0ff0,d1
 asr.w #1,d1
 add.l d1,d0		;d0=offset
 move.l d0,a0		;copy
 add.l back_screen,a0	;a0=addr in backscreen
 add.l a1,d0		;d0=addr in proper screen
 move.l d0,a3		;preserve a1
 move.l 160(a0),160(a3)
 move.l (a0)+,(a3)+
 move.l 160(a0),160(a3)
 move.l (a0)+,(a3)+	;transfer 8 bytes of data to unplot pixel
 rts



u1plot: move d0,d2
 asl.w #2,d1
 move.l #ytab,a0
 move.l 0(a0,d1.w),d0
 move.w d2,d1
 and.l #$0ff0,d1
 asr.w #1,d1
 add.l d1,d0		;d0=offset
 move.l d0,a0		;copy
 add.l back_screen,a0	;a0=addr in backscreen
 add.l a1,d0		;d0=addr in proper screen
 move.l d0,a3		;preserve a1
 move.l (a0)+,(a3)+
 move.l (a0)+,(a3)+	;transfer 8 bytes of data to unplot pixel
 rts


mret: dc.w 0


fwait:
;
; wait till FON is zero
;
 tst fon
 bne fwait
 rts

mpsi:
;
; xvert sprite addressed by a0 into a PSI
; uses (256K?) buffer XPSI to put xpanded sprites in
; pointer XPPTR.L holds current buffer position
;
 cmp #3,(a0)
 beq ok_mpsi
 rts
ok_mpsi:
 move 6(a0),d4	; Sliver X size/pixel
 move 4(a0),d5	; Sliver Y size
 move.l xpptr,a3
 move #5,(a0)
 move d4,4(a3)
 move d5,2(a3)
 move 2(a0),(a3)
 move.l a3,4(a0)
 move d5,d7
 move d4,d6
 asr #4,d6	; get X-finish-sliver#
 add #1,d6	; correct for overlap
 move d6,(a3)
; At this point d6 contains horiz sprite width, in slivers
; d7 has the sprite height in scan lines

 move d6,d0	; save unadulterated width of sprite

 lea 8(a0),a0	; Get ready to calc start addr of sprite
 lea 6(a3),a1
psi_scan:
 move d6,d0	; Get the sprite width count.
 move.l a0,a2
psi_loop1:
 move #3,d5	; use d5 as bit plane ctr
psi_loop:
 cmp d6,d0	; On our first sliver?
 bne g_prev	; No, get previous unshifted sliver
 move #0,d1	; building the data in d1
 swap d1	; zero high-byte
 bra g_prev1	; skip first-byte-get
g_prev:
 move -8(a2),d1	; get last slot's data
 swap d1	; make it high
g_prev1:
 tst d0		; On the last (overflow) sliver?
 bne g_next	; No, get current sliver
 move #0,d1	; make it zero
 bra g_next1	; skip current-byte-get
g_next:
 move (a2),d1	; get current data
g_next1:
 move #7,d3	; shift-count
psi_gen:
 ror.l #2,d1	; shift the data for 2-pixel rez
 move d1,(a1)+	; place the shifted image
 dbra d3,psi_gen	; loop until...
 add.l #2,a2	; move up to next bit-plane
 dbra d5,psi_loop	; do four whole bit-planes
 lea 8(a0),a0
 dbra d0,psi_loop1	; do the whole scan-line
 lea -8(a0),a0
 dbra d7,psi_scan	; do all the scanlines of data
 move.l a1,xpptr
 rts

expand: move.l (a0)+,d0
 cmp.l #0,d0
 beq expand
 cmp.l #-1,d0
 beq expae
 move.l a0,-(a7)
 move.l d0,a0
 jsr mpsi
 move.l (a7)+,a0
 bra expand
expae: rts
 
pclr: move.l #cseqlst,a0
 move #15,d0
pclr1: move.l #0,(a0)+
 dbra d0,pclr1
 rts


game_reset:
;
; Allocate screen buffers; establish VBL and HBL interrupts;
; start up sound driver; set default VBL, HBL and display lists
; 
 bsr super
;
; (already in super after download)
;
 bsr init_rnd
; bsr diskstat
;
; set supervisor mode
;
 jsr init_sonix
;
; Use this call to initialise sound driver if linked
;
 move #2,frame_rate
 jsr ytab_init
;
; make y-table for sprite routines
;
rstart:
; move.l #sampl_lst,clist
 move.l clist,colipt
;
; CLIST is current display-list (if rasta enabled)
;
; move.l #game_pal,a0
; jsr setpal 
;
; SETPAL dumps palette --> a0 directly into hardware
; (unneeded if PAL_STUFF on your IRQ in which case
; move.l #game_pal,source_pal
; will suffice)
;
 move.l $44e,bscreen
;
; use normal screen ram as one of the buffers
;
 move.l #lscreen,d0
;
; lscreen should be the last lable in your code.
; screen buffer memory is assigned from lscreen upwards
;
 add.l #256,d0
 and.l #$ffff00,d0
;
; align to legal screentop memloke
;
 move.l d0,ascreen
 add.l #32000,d0
 move.l d0,back_screen
 add.l #32000,d0
 move.l d0,cscreen
;
; allocate buffers
;
 move #0,$ff8240
 move.l #mouse_int,-(a7)
 move.l #mouse_pars,-(a7)
 move #1,-(a7)
 move #0,-(A7)
 trap #14
 add.l #$c,a7
;
; Get the mouse IRQ for my own (handler at MOUSE_INT)
;
 move.l #old_keyvec+2,a1
 move.l key_vec,(a1)
 move.l #key_handler,a0
 move.l a0,key_vec 	; install better maus stuff
;
; Fix to stop rasta freaking out
;
 move.l #hblank,-(a7)
 and.b #$fe,$fffa07
 and.b #$df,$fffa09
 move #1,-(a7)
 move #8,-(a7)
 move #1,-(a7)
 move #31,-(a7)
 trap #14
 add.l #12,a7
;
; Install HBL routine. Leave out if you're not using HBL
;
 move.l #vblank,$70
;
; Install my VBL routine (at VBLANK) and fuck the VBL queue
;
 move #0,vbswitch
 move #0,atype
 move sr,d0
 and #%0101100011100000,d0
 or #$2100,d0
; move #$38ff,sr		;turn on int's
;
; Switch to first routine in the list of VBL and Foreground stuff
;
 move.l shipa,a0
 move #-500,(a0)
 move.l shipb,a0
 move #-500,(a0)
 move.l shipc,a0
 move #-500,(a0)	; zero all undraw buffers
;
; OK, now generate default bootup logo display
;
 rts
 jmp doff

diskstat:
;
;Read disk drive status
;
 rts
 move #$80,$ff8606
 move #40,d7 		;this code is to read the
dsd: dbra d7,dsd	;disk controller I hope
 move $ff8604,d0
  move #40,d7 
dsd1: dbra d7,dsd1
 rts			;return status register in d0



scorer:
;
; Add d1 to digit <d0> with wrap to neighbouring digit(s)
;
 tst _demo
 beq ysco
 rts
ysco: movem.l d0-d2/a0,-(a7)
 move.l score,a0
 asl #1,d0
scol: move d0,-(a7)
scorer_0:
 move 0(a0,d0.w),d2
 add #1,d2
 cmp #$a,d2
 bne scorer_1		; no wrap, skip
 move #0,0(a0,d0.w)
;
; Typical score-bonus setup; routine at XTRA is called at
; every 10,000 score rollover
;
 cmp #6,d0
 beq ync
 cmp #8,d0
 bne noync
 cmp #4,-2(a0,d0.w)	; going to 50,000?
 bne noync
ync: bsr xtra
noync: sub #2,d0
 bmi scorer_2
 bra scorer_0
scorer_1:
 move d2,0(a0,d0.w)
scorer_2:
 move (a7)+,d0
 dbra d1,scol
 movem.l (a7)+,d0-d2/a0
 move #1,scor_upd8	; tell foreg to update our score
 rts

xtra:
; add #1,lives			;-typical extralife code
; move.l #warpflash,flashvec	;-ex PStorm
 rts

scor_upd8: dc.w 0
;
; redraw score flag checked by foreground loop
;

vblank:
;
; Vertical-blank master routine
;
 movem.l d0-d7/a0-a6,-(a7)
 tst hdisabl
 bne katalog
 move.l clist,a0
 move (a0),$ff8242
 move (a0),colval
;
; ensure no hangover of colour (ony if HBL enabled)
;
katalog:
;
; Save registers
;
 move.l clist,colipt
;
; Update d_list pointer
;
 tst hdisabl
 bne edwina
 move #0,dli_lline+2
; move #$707,colval
 move.b #0,$fffa1b
 move.b #1,$fffa21
 move.b #8,$fffa1b
;
; reset rasta IRQ stuff
;
edwina:
 tst _startup
 beq edw1
 move.b #0,$ff8260	
 move #0,_startup
edw1:
 cmp.l #-1,addr
 beq iirq
 move.l addr,d0
 bsr vpoke
iirq:
 tst syncreq
 beq noreq
 sub #1,syncreq
;
; Maintain screen-buffering stuff
;
noreq:
 tst gimme_sync
 beq nreq1
 move #0,gimme_sync
nreq1: tst.l mason
 beq free_mason
 move.l mason,a0
 jsr inison
 move.l #0,mason
free_mason:
 bsr pal_stuff
; bsr sonix_d
;
; Pal-stuff is palette rotator, fader etc.
;
 move.l #vblist,a0
 move vbswitch,d0
 asl #2,d0
 move.l 0(A0,d0.w),a0
 jsr (a0)
 bsr sonix_d
;
; Execute current module
;
 movem.l (a7)+,d0-d7/a0-a6
;
; Resrtore regirsters
;
 rte

gimme_sync: dc.w 0
nullpal: dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
nulllist: dc.w 0,1,0,200
doff: jsr pclr
 move #0,vbswitch
 move.l #nullpal,source_pal
 move.l #nulllist,clist
waisync: move #1,gimme_sync
wais: tst gimme_sync
 bne wais
 rts


vbswitch: dc.w 0
;vblist: dc.l default_irq

r_pos: dc.w 199
r_dir: dc.w -1

default_irq:
;
; All this does is do the logo motion (wasn't there a song
; called that? musta been game programmers)
;
 move r_pos,d0
 move r_dir,d1
 add d1,d0
 beq ro
 cmp #200,d0
 bmi n_ro
ro: neg d1		; bounce screen rasta
 add d1,d0
n_ro:
 move d1,r_dir
 move d0,r_pos
 move d0,ssampl_lst+2	; rasta position
 rts


score: dc.l scorep1
scorep1: dc.w 0,0,0,0,0,0,0,0
scorep2: dc.w 0,0,0,0,0,0,0,0
clist: dc.l 0
colval: dc.w 0
colipt: dc.l 0
dlict: dc.w 0

ssampl_lst: dc.w 0,1
 dc.w 1,1,2,1,3,1,4,1,5,1,6,1,7,1,$107,1,$207,1,$307,1,$407,1
 dc.w $507,1,$607,1,$707,1,$607,1,$507,1,$407,1,$307,1,$207,1
 dc.w $107,1,7,1,6,1,5,1,4,1,3,1,2,1,1,1,0,1,0,200


hblank:
;
; Hblanc routine to maintain d_lists
;
 move colval,$ff8242
 movem.l d1-d2/a1,-(A7)
 move.l colipt,a1
 move (a1)+,colval
 move (a1)+,d1
 add d1,dli_lline+2
dli_lline: move #0,d2
dli_col: move.l a1,colipt
 move.b #0,$fffa1b
 cmp #200,d2
 bmi cow2
 bclr.b #0,$fffa0f
 movem.l (a7)+,d1-d2/a1
 rte
cow2:
 move.b d1,$fffa21
 move.b #8,$fffa1b
 bclr.b #0,$fffa0f
 movem.l (a7)+,d1-d2/a1
 rte

mxmax: dc.w 40
mymax: dc.w 40
dbuttons: dc.w 0
mouse_int:
;
; Mouse interrupt sets up button-state, and X- and Y- offsets,
; and maintains co-ords XPOS and YPOS.
;
m_int: move.b (a0),buttons
 move.b 1(a0),xoff
 move.b 2(a0),yoff
 movem d0-d1,-(a7)
 move.b yoff,d1
 neg.b d1
 ext d1
 move ypos,d0
 add d1,d0
 bpl mint
 move #0,d0
mint:
 cmp mymax,d0
 bmi mint2
 move mymax,d0
 sub #1,d0
mint2: move d0,ypos
 move.b xoff,d1
 ext d1
 move xpos,d0
 add d1,d0
 bpl mint3
 move #0,d0
mint3:
 cmp mxmax,d0
 bmi mint4
 move mxmax,d0
 sub #1,d0
mint4: move d0,xpos
 movem (a7)+,d0-d1
 rts

super:
 move.l #0,-(a7)
 move #$20,-(a7)
 trap #1
 add.l #6,a7
 rts

key_handler:
; move #$2500,sr
old_keyvec: jmp $0


vpoke:
 lsr.l #8,d0
 move.b d0,d1
 lsr.l #8,d0
 swap d0
 move d1,d0
 and.l #$00ff00ff,d0
 move.l d0,$ff8200
 rts

 move.b d1,$ff8203
 move.b d0,$ff8201
 rts


scls:
;
; special CLS routine for col1 lines
;

 move.l ascreen,a0
 move #3999,d0
scls0: move.l #$ffff0000,(a0)+
 move.l #$00000000,(a0)+
 dbra d0,scls0
 move.l back_screen,a0
 move.l bscreen,a2
 move.l cscreen,a3
 move #7999,d0
 move.l ascreen,a1
scls4: move.l (a1),(a0)+
 move.l (a1),(a3)+
 move.l (a1)+,(a2)+
 dbra d0,scls4
 rts

xfrombak:
 tst ii
 beq eastenders
 move.l ascreen,a0
; jsr _protec2
 move #0,ii
eastenders:
 move #7999,d0
 move.l back_screen,a1
 move.l ascreen,a0
 move.l bscreen,a2
 move.l cscreen,a3
 bra scls4

ii: dc.w 1

setpal: move.l #$ff8240,a1
 move #15,d1
set_loop:
 move (a0)+,d0
 bmi ign
 move d0,(a1)
ign:
 lea 2(a1),a1
 dbra d1,set_loop
Toke_can: rts



diginslot:
;
; Draw a numeric-digit on the three-screens
;
 movem.l d0-d2/a0-a4,-(a7)
 move.l #numbers,a0
; asl #7,d0		; point to start of digit bitmap
 asl #2,d0
 move d0,d2		;d2 is number times 4
 asl #2,d0		;d0 is number x16
 add d2,d0		;now, it's times 20...
 asl #3,d0		;..times 8 bytes pur scan lineEee bibble

 asl #3,d1
 add scorebase,d1		; point t'digit slot
 move.l ascreen,a1
 move.l bscreen,a2
 move.l cscreen,a3	; point to the Three Screens
 move.l back_screen,a4
; lea 29280(a1),a1
; lea 29280(a2),a2
; lea 29280(a3),a3
; lea 29280(a4),a4
 
 move #19,d2
dins:
 move.l 0(a0,d0.w),0(a1,d1.w)
 move.l 4(a0,d0.w),4(a1,d1.w)
 move.l 0(a0,d0.w),0(a2,d1.w)
 move.l 4(a0,d0.w),4(a2,d1.w)
 move.l 0(a0,d0.w),0(a3,d1.w)
 move.l 4(a0,d0.w),4(a3,d1.w)
 move.l 0(a0,d0.w),0(a4,d1.w)
 move.l 4(a0,d0.w),4(a4,d1.w)
 lea 160(a1),a1
 lea 160(a2),a2
 lea 160(a3),a3
 lea 160(a4),a4
 lea 8(a0),a0
 dbra d2,dins
 movem.l (a7)+,d0-d2/a0-a4
 rts

scorebase: dc.w 0

clrslot:
;
; modified for 19 pixel high digits and clear to col1
;
 movem.l d0-d2/a0-a3,-(a7)
 asl #3,d1
 add scorebase,d1		; point t'digit slot
 move.l ascreen,a1
 move.l bscreen,a2
 move.l back_screen,a4
 move.l cscreen,a3	; point to the Three Screens
 move #19,d2		; usu 15 
cdins:
 move.l #$ffff0000,0(a1,d1.w)
 move.l #0,4(a1,d1.w)
 move.l #$ffff0000,0(a2,d1.w)
 move.l #0,4(a2,d1.w)
 move.l #$ffff0000,0(a3,d1.w)
 move.l #0,4(a3,d1.w)
 move.l #$ffff0000,0(a4,d1.w)
 move.l #0,4(a4,d1.w)
 lea 160(a1),a1
 lea 160(a2),a2
 lea 160(a3),a3
 lea 160(a4),a4
 dbra d2,cdins
 movem.l (a7)+,d0-d2/a0-a3
 rts


goat: 
; move.l #axvec,a0
; move atype,d7
; asl #2,d7
; move.l 0(a0,d7.w),a0
; jmp (a0)



sprites:
 rts		; return once outfaded

udscore: move.l score,a0	; point to the digits of our score
 move #0,d1		; logical digitslot
 move #6,d2		; 8 digits o'score
 lea 2(a0),a0		; update only last 7
sseek:
 move (a0),d0		; Digit nonzero?
 bne sgott
 lea 2(a0),a0
 dbra d2,sseek
 move #0,d0
 bsr diginslot		;Place zero
 bra wlou
sgott: move (a0)+,d0
 bsr diginslot
 add #1,d1
 dbra d2,sgott		; copy out whole score
;
; above is typical 8-digit score display sequence
;
wlou: rts

_go: dc.w 0

draw_sprite:
;
; Draw a sprite, position (d0,d1), definition ->a0, on screen ->a1
; updating undraw list ->a2
; 
 cmp #-500,d1
 bne d_x_1
 move #499,d1
d_x_1:
; move d1,(a2)+
; move d0,(a2)+
; move.l a0,(a2)+	; create undraw list
 tst _fix
 bne ds_1
 move #-1,o_lines
 movem.l a1-a2,-(a7)
 jsr sdraw
 movem.l (a7)+,a1-a2
 tst o_lines
 bmi zaqq		;no list add if no sprite was plotted 
 move o_loop,(a2)+
 move o_lines,(a2)+
 move.l o_addr,(a2)+
zaqq: move #-500,(a2)	; saves u the bother
 rts

ds_1:
 movem.l a1-a2,-(a7)
 movem.l d0-d1/a0,-(a7)
 jsr sdraw
 movem.l (a7)+,d0-d1/a0
 move.l back_screen,a1
 movem.l d0-d1/a0,-(a7)
 jsr sdraw
 movem.l (a7)+,d0-d1/a0
 move.l bscreen,a1
 movem.l d0-d1/a0,-(a7)
 jsr sdraw
 movem.l (a7)+,d0-d1/a0
 move.l cscreen,a1
 jsr sdraw
 movem.l (a7)+,a1-a2
 rts

csprite:
;
; Draw a sprite, CENTERED at (d0,d1)
;
 move d2,-(a7)
 move.l a0,-(a7)
 cmp #5,(a0)
 bne orcs
 move.l 4(a0),a0
 lea -2(a0),a0
orcs:
 move 4(a0),d2		; get sprite Y size
 asr #1,d2	; /2
 sub d2,d1	; centre in Y
 move 6(a0),d2
 asr #1,d2
 sub d2,d0	; same fur Y
 move.l (a7)+,a0
 bsr draw_sprite	; std call
 move (a7)+,d2
 rts
 
del_als:
;
; erase all the aliens in undraw list
;

 move.l shipb,a2
dlals:
 move (a2)+,d1
 cmp #-500,d1
 beq dlals1
 move (a2)+,d0
 move.l (a2)+,a0
 movem.l a1-a2,-(A7)
; cmp.l #0,a0
; bne notnul
; bsr uplot
; bra nopixx
;notnul:
; bsr sdraw
 move.l back_screen,a2	;get address of background screen
 add.l a0,a2		;copy data from
 add.l a1,a0		;a0 has start address on erase screen
 add #1,d1
zakyy: move.l a0,a1		;a1 has working copy of dest screen
 move.l a2,a3		;a3 has working copy of data screen
 move d1,d2		;d2 is working dbra ct 
okto: move.l (a3)+,(a1)+	;transfer data
 move.l (a3)+,(a1)+
 dbra d2,okto
 lea 160(a0),a0
 lea 160(a2),a2		;do all scan lines
 dbra d0,zakyy		;erased specified blok
nopixx:
 movem.l (a7)+,a1-a2
 bra dlals
dlals1: rts		;well dip my tool in llama lovejuice



init_rnd:
;
; Make a 512-entry ran# table. I only need rough
; ran#s, and I can selectively seed such a
; table, and it is faster than BIOS.
;
 move.l #rantab,a4
 move #0,d0
irnd: move.b d0,(a4)+
 add #1,d0
 cmp #512,d0
 bne irnd 
 move.l #rantab,a3
 move #4000,d6	; do 4000 swaps
ini_rnd:
 movem.l d6/a3,-(a7)
 move #$11,-(a7)
 trap #14
 lea 2(a7),a7
 movem.l (a7)+,d6/a3
 move d0,d5
 and #$1ff,d5
 movem.l d5-d6/a3,-(a7)
 move #$11,-(a7)
 trap #14
 add.l #2,a7	; get ran# 2
 movem.l (a7)+,d5-d6/a3
 and #$1ff,d0
 move.b 0(a3,d0.w),d2
 move.b 0(a3,d5.w),0(a3,d0.w)
 move.b d2,0(a3,d5.w)
 dbra d6,ini_rnd
 rts


rannum:
;
; Get a ran#, 0-255,in d0
;
 move.l a0,-(a7)
 move.l #rantab,a0
 move ranptr,d0
 move.b 0(a0,d0.w),d0
 and #$ff,d0
 add #1,ranptr
 and #$1ff,ranptr
 move.l (a7)+,a0
 rts



draw_vex: dc.l draw_psi,draw_nsi,draw_p16,fa_nsi,ch_spr,xdraw_psi
	dc.l fa_nsi
	dc.l sfx_sprite

sdraw:

;
; Draw a sprite. Routine needs:
;
; d0=xpos of sprite
; d1=ypos of sprite
; a0= --> sprite definition block
; a1= --> screen RAM
;
; External variables to set:
;
; ymin=top of sprite window
; ymax=bottom of window
; xmin=LH edge of window to nearest slot
; ymin=RH edge of window to nearest slot
; unDraw=0 for plotting a sprite, 1 for erasing that sprite
; back_screen=address(long) of screen containing b'ground info
;
; Stuff set by the sprite routine:
;

 move.l #draw_vex,a2
 move (a0),d2
 asl #2,d2
 move.l 0(a2,d2.w),a2
 jmp (a2)

xdraw_psi: move.l 4(a0),a0
 lea -2(a0),a0

draw_psi:
 and #$fffe,d0	; clip x-co-ord to even pixel bounds
 move.l #ytab,a2	; ytab is vertical-offset table
 move 2(a0),d4	; horiz size in slots
 move 4(a0),d2	; vert size in scan lines
 cmp #1,d4
 beq draw_p16
 lea 8(a0),a0
 move d4,d3	; working copy of horiz sprite size
 add #1,d3	; add one for PSI overflow
 asl #6,d3	; calculate byte size of one scanline
 ext.l d3	; make it long for adding to addresses
 move.l d3,a4	; save it freeing up d3
 cmp ymin,d1	; check if y is onscreen
 bpl draw_top	; yes, no need to clip top of sprite
 move d1,d5	; working copy of y position
 add d2,d5	; move to bottom pos of sprite
 cmp ymin,d5	; bottom edge offscreen to top?
 bpl notoff	; no
 rts		; yes
notoff:
 move d1,d6	; copy of y position
 sub ymin,d6	; make limit relative to border
 neg d6		; how many scan lines above screen top?
 muls d3,d6	; multiply by length of one scan line
 add.l d6,a0	; move pointer up past redundant sprite data
 move ymin,d1	; sprite starts at y=0 now
 bra dpsi_2	; go do bottom-edge stuff
draw_top:
 move d1,d5	; copy of y position
 add d2,d5	; d5 is sprite maxheight
dpsi_2:
 cmp ymax,d5	; Sprite hanging off bottom?
 bmi dpsi_3	; No
 beq dpsi_3	; no
 cmp ymax,d1	; start off bottom?
 bmi inran	; no
 beq inran	; no
 rts		; yas.
inran:
 move ymax,d5	; make y max the bottom line
dpsi_3:
 sub d1,d5	; calc height of sprite in scanlines
 move d0,d6	; working copy of x position
 asr #4,d6	; reduce to 'slots'
 cmp xmax,d6	; off screen?
 bmi xon	; no
 beq xon	; no
 rts		; yes
xon:
 move d6,d3	; copy logical x start
 add d4,d3	; add sprite slot width
 cmp xmin,d6	; LHS of image to be clipped?
 bpl posi_pos	; no
 add d4,d6	; add whole width of sprite in slots
 cmp xmin,d6	; still off LHS of screen?
 bpl snotoff	; no
pinkFloyd: rts		; yes
snotoff:
 sub d4,d6
 sub xmin,d6	 
 move d6,d7
 neg d7		; # of pixels overshoot
 asl #6,d7	; calc amount of data to exclude
 move d7,d2	; copy of offset
 move xmin,d6	; logical x-start-slot
 bra whoriz	; skip non-LHS-clip specific code
posi_pos:
 move #0,d2	; zero offset
whoriz:
 ext.l d2	; prepare to...
 add.l d2,a0	; skip any data due to LHS clip
 cmp xmax,d3	; check RHS of sprite
 bmi do_draw	; RHS is onscreen
 move xmax,d3	; xmax becomes new limit
do_draw:
 move d1,d2	; get y-start
 asl #2,d2	; for offset into longword vector table..
 move.l 0(a2,d2.w),a3	; referenced by ytab
; add.l a3,a1	; a1 has screen y address
 move d6,d2	; fetch logical slot to start drawing sprite
 asl #3,d2	; eight bytes per slot
 ext.l d2	; extend to long..
 add.l d2,a1	; a1 now points to proper screenloke
 add.l a3,a1	; add in screen base
 add.l d2,a3	; update backg screen ptr too
 move.l a3,o_addr	;***Undraw base address

 move d0,d2	; get sprite x-position
 asr #1,d2	; lose LSB os x-pos
 and #$07,d2	; only interested in PSI offset
 asl #1,d2	; and again please
 ext.l d2	; make long
 add.l d2,a0	; a0 adjusted for correct PSI-scan
 tst unDraw	; plot or erase please?
 bne erase	; go do erase, if non zero
 move d5,o_lines
 sub d6,d3	;***
; sub #1,d3	:***
 move d3,o_loop
 move d3,d2
d_loop:
 move.l a0,a5	; preserve sprite data pointer
 move.l a1,a6	; and screen-RAM pointer
; move d6,d2	; re-set slice-counter
; sub d2,d3	; *** should make d3 into dbra
; sub #1,d3
 move d2,d3
d_l_1:
 move (a5),d0	; get data on bitplane #1
 move d0,d7	; d7 will be used to make a mask
 swap d0	; shift 'plane 1 info to high word
 move 16(a5),d0	; bitplane #2
 or d0,d7	; add into the mask
 move 32(a5),d1	; bitplane #3
 or d1,d7	; add to mask
 swap d1	; move to high word
 move 48(a5),d1 ; bitplane #4
 or d1,d7	; complete mask
 move d7,d4	; d4 no longer needed, use as a temp...
 swap d7	; in order to...
 move d4,d7	; generate a longword-mask.
 eor.l #-1,d7	; invert mask
 and.l d7,(a6)	; mask 'planes 1 and 2
 or.l d0,(a6)+	; blast in the data
 and.l d7,(a6)	; mask 'planes 3 and 4
 or.l d1,(a6)+	; blast in the data
 lea 64(a5),a5
; add #1,d2	; add to horiz-slot-counter
; cmp d2,d3	; equal to RHS-limit?
; bpl d_l_1	; yes, carry on
 dbra d3,d_l_1
xxyt: add.l a4,a0	; update data pointer
 lea 160(a1),a1
 dbra d5,d_loop	; do all scanlines of displayed image
 rts		; done.

o_addr: dc.l 0
o_lines: dc.w 0
o_loop: dc.w 0

fa_nsi:
;
; Fast Nonshifted-Image prototype routine
; this initial version limited to 16pixel wide sprites
; - no PSI table needed, takes raw NEO source files
; with '3' tacked on the front, then 0, then vsize, then 0
;
; bra sfx_sprite   -this was link to weird sprite routine!
 move.l #ytab,a2	; ytab is vertical-offset table
 move 2(a0),d2
 move d2,xnumb	; count of horizontal slivers
 add #1,d2
 asl #3,d2	; length of one scanline
 ext.l d2
 move.l d2,a4	; length of one scan line
 move.l a4,xbytes
 move 4(a0),d2	; vert size in scan lines
 lea 8(a0),a0
; move.l #8,a4	; all scanlines 8bytes long
 cmp ymin,d1	; check if y is onscreen
 bpl fdraw_top	; yes, no need to clip top of sprite
 move d1,d5	; working copy of y position
 add d2,d5	; move to bottom pos of sprite
 cmp ymin,d5	; bottom edge offscreen to top?
 bpl fnotoff	; no
 rts		; yes
fnotoff:
 move d1,d6	; copy of y position
 sub ymin,d6	; make limit relative to border
 neg d6		; how many scan lines above screen top?
; ext.l d6
; asl.l #3,d6	; multiply by 8
 sub #1,d6
 bmi ttoke
fipp:
 add.l a4,a0
 dbra d6,fipp	; skip d6 scanlines
; add.l d6,a0	; move pointer up past redundant sprite data
ttoke:
 move ymin,d1	; sprite starts at y=0 now
 bra fdpsi_2	; go do bottom-edge stuff
fdraw_top:
 move d1,d5	; copy of y position
 add d2,d5	; d5 is sprite maxheight
fdpsi_2:
 cmp ymax,d5	; Sprite hanging off bottom?
 bmi fdpsi_3	; No
 beq fdpsi_3	; no
 cmp ymax,d1	; start off bottom?
 bmi finran	; no
 beq finran	; no
 rts		; yas.
finran:
 move ymax,d5	; make y max the bottom line
fdpsi_3:
 sub d1,d5	; calc height of sprite in scanlines
 move d0,d6	; working copy of x position
 asr #4,d6	; reduce to 'slots'
 add xnumb,d6 
 sub xmax,d6	; off screen?
 bmi fxon	; no
 beq fxon_sur	; no
 sub d6,xnumb	; chop-off overflow 
 bpl fxon_sur	; if negative, is off screen
 rts		; yes
fxon_sur:
 move #1,right_suppress
 bra ffxx	; extreme RHS, suppress right sprite
fxon:
 move #0,right_suppress
ffxx:
 move d0,d6
 asr #4,d6
 move #0,left_suppress	; clear left & right clip flags
 cmp xmin,d6	; LHS of image to be clipped?
 bpl fposi_pos	; no
 add xnumb,d6	; check top slot
 add #1,d6
 cmp xmin,d6	; still off screen
 bpl fsnotoff	; no, draw hi words only
fpinkFloyd: rts		; yes
left_suppress: dc.w 0
right_suppress: dc.w 0
xbytes: dc.l 0
xnumb: dc.w 0
fsnotoff:
 sub xnumb,d6		; leave d6 still with logikal slot
 sub #1,d6
 move #1,left_suppress	; Suppress LHS of sprite
 move xmin,d2
 sub d6,d2
 sub #1,d2
 beq farrt
 sub #1,d2 
zonka:
 lea 8(a0),a0
 sub #1,xnumb
 dbra d2,zonka  
farrt: move xmin,d6
 sub #1,d6
fposi_pos:
fdo_draw:
 move d1,d2	; get y-start
 asl #2,d2	; for offset into longword vector table..
 move.l 0(a2,d2.w),a3	; referenced by ytab
; add.l a3,a1	; a1 has screen y address
 move d6,d2	; fetch logical slot to start drawing sprite
 asl #3,d2	; eight bytes per slot
 ext.l d2	; extend to long..
 add.l d2,a1	; a1 now points to proper screenloke
 add.l a3,a1
 add.l d2,a3	; update backg screen ptr too
 move.l a3,o_addr
 tst unDraw	; plot or erase please?
 beq nerase
 move #0,d6
 move xnumb,d3	; kludge so I can use PSI erase module
 add #1,d3
 bra erase	; go do erase, if non zero
nerase:
 move d0,d6	; get xpixel pos'n
 and #$f,d6	; find ro-offset
 move #0,d7	; assume positiv_shift
 cmp #8,d6	; wrap-over?
 bmi fd_skip	; no
 move #16,d7
 sub d6,d7	; make left-shift-count
 move d7,d6
 move #1,d7	; tell sys is a shift-left-situation
fd_skip: move xnumb,o_loop
 move d5,o_lines
fd_loop: move.l a0,a5
 move.l a1,a6
 move left_suppress,-(a7)
 move xnumb,-(a7)
dmc:
 moveq.l #0,d0
 moveq.l #0,d1
 moveq.l #0,d2
 moveq.l #0,d3
 move (a5)+,d0
 bne blab1
 move (a5)+,d1
 bne blab2
 move (a5)+,d2
 bne blab3
 move (A5)+,d3
 bne zoup
 bra zk 
blab1: move (a5)+,d1
blab2: move (a5)+,d2
blab3: move (a5)+,d3	; prefetch all grafik_data
zoup: tst d7		; left or right shift?
 bne lef_shf
 ror.l d6,d0
 ror.l d6,d1
 ror.l d6,d2
 ror.l d6,d3
 bra gnmsk
lef_shf:
 rol.l d6,d0
 swap d0
 rol.l d6,d1
 swap d1
 rol.l d6,d2
 swap d2
 rol.l d6,d3
 swap d3
gnmsk: move.l d0,d4
 or.l d1,d4
 or.l d2,d4
 or.l d3,d4		; generate shifted maskk
 eor.l #-1,d4		; negate the mask
 swap d6
 swap d7		; Free up d6 an' d7 for word use
 tst left_suppress	; LHS suppression?
 bne lfsupr		; avoid de next bit
 move (a6),d6		; get bp1 low word
 and d4,d6
 or d0,d6
 move d6,(a6)+
 move (a6),d6
 and d4,d6
 or d1,d6
 move d6,(a6)+
 move (a6),d6
 and d4,d6
 or d2,d6
 move d6,(a6)+
 move (a6),d6
 and d4,d6
 or d3,d6
 move d6,(a6)+
 bra nlfsupr
lfsupr:
 lea 8(a6),a6
nlfsupr:
 move #0,left_suppress	; lsupp only done 1ce per scanline
 tst xnumb
 bne fxxyt0	; R-suppress only poss on last horiz sliv scan
 tst right_suppress
 bne fxxyt	; zoom to end if RHS-skip
fxxyt0:
 swap d0
 swap d1
 swap d2
 swap d3
 swap d4	; point to high wordz
 tst d4
 beq fxxyt	; allow for no-shift case
 move (a6),d6		; get bp1 low word
 and d4,d6
 or d0,d6
 move d6,(a6)
 move 2(a6),d6
 and d4,d6
 or d1,d6
 move d6,2(a6)
 move 4(a6),d6
 and d4,d6
 or d2,d6
 move d6,4(a6)
 move 6(a6),d6
 and d4,d6
 or d3,d6
 move d6,6(a6)
fxxyt:
 swap d6
 swap d7	; restore shift data
foxx: sub #1,xnumb
 bpl dmc	; do whole sprite width
 move (a7)+,xnumb
 move (a7)+,left_suppress
 lea 160(a1),a1
 add.l xbytes,a0 
 dbra d5,fd_loop	; do all scanlines of displayed image
 rts		; done.

zk: lea 8(a6),a6
 move #0,left_suppress
 bra foxx

sfx_sprite:
;
;Special nonshifted-image routine allowing manipulation of the
;destination raster to an extraordinary degree.
;
 move.l #ytab,a2	; ytab is vertical-offset table
 move 2(a0),d5
 move d5,xnumb	; count of horizontal slivers
 move d5,d2
 add #1,d2
 asl #3,d2	; length of one scanline
 ext.l d2
 move.l d2,a4	; length of one scan line
 move.l a4,xbytes
 move 4(a0),d2	; vert size in scan lines
 lea 8(a0),a0	;a0 is source-raster start. d0/d1 have current pos
l_sfx: movem.l d0-d2/a0-a1,-(a7)	;save raster parameters
 move d1,d3	;use d3..
 asl #1,d3
 and #255,d3	;as index into a..
 move.l #sine,a3	;sine table..
 move.b 0(a3,d3.w),d3
 ext d3
 asr #2,d3
; add #100,d3
 add d3,d0	;and add to X-component to be Weird..

 cmp ymin,d1	; check if y is onscreen
 bmi n_sfx	; no, get next rasta line
 cmp ymax,d1
 bpl n_sfx	; check for Y offscreen 

 move d0,d6	; working copy of x position
 asr #4,d6	; reduce to 'slots'
 add d5,d6 
 sub xmax,d6	; off screen?
 bmi f_fxon	; no
 beq f_fxon_sur	; no
 sub d6,d5	; chop-off overflow 
 bpl f_fxon_sur	; if negative, is off screen
 jmp n_sfx	; yes
f_fxon_sur:
 move #1,right_suppress
 bra f_ffxx	; extreme RHS, suppress right sprite
f_fxon:
 move #0,right_suppress
f_ffxx:
 move d0,d6
 asr #4,d6
 move #0,left_suppress	; clear left & right clip flags
 cmp xmin,d6	; LHS of image to be clipped?
 bpl f_fposi_pos	; no
 add d5,d6	; check top slot
 add #1,d6
 cmp xmin,d6	; still off screen
 bpl f_fsnotoff	; no, draw hi words only
 jmp n_sfx		; yes
f_fsnotoff:
 sub d5,d6		; leave d6 still with logikal slot
 sub #1,d6
 move #1,left_suppress	; Suppress LHS of sprite
 move xmin,d2
 sub d6,d2
 sub #1,d2
 beq f_farrt
 sub #1,d2 
f_zonka:
 lea 8(a0),a0
 sub #1,d5
 dbra d2,f_zonka  
f_farrt: move xmin,d6
 sub #1,d6
f_fposi_pos:
f_fdo_draw:
 move d1,d2	; get y-start
 asl #2,d2	; for offset into longword vector table..
 move.l 0(a2,d2.w),a3	; referenced by ytab
 add.l a3,a1	; a1 has screen y address
 move d6,d2	; fetch logical slot to start drawing sprite
 asl #3,d2	; eight bytes per slot
 ext.l d2	; extend to long..
 add.l d2,a1	; a1 now points to proper screenloke
 add.l d2,a3	; update backg screen ptr too
 tst unDraw	; plot or erase please?
 beq f_nerase
 add.l back_screen,a3
 add #1,d5
yessongs:
 move.l (a3)+,(a1)+
 move.l (a3)+,(a1)+	;clear 4 bitplanes o'data
 dbra d5,yessongs	;clear this slivva
 bra n_sfx		;OK next line

f_nerase:
 move d0,d6	; get xpixel pos'n
 and #$f,d6	; find ro-offset
 move #0,d7	; assume positiv_shift
 cmp #8,d6	; wrap-over?
 bmi f_fd_loop	; no
 move #16,d7
 sub d6,d7	; make left-shift-count
 move d7,d6
 move #1,d7	; tell sys is a shift-left-situation
f_fd_loop: move.l a0,a5
 move.l a1,a6
f_dmc:
 moveq.l #0,d0
 moveq.l #0,d1
 moveq.l #0,d2
 moveq.l #0,d3
 move (a5)+,d0
 bne f_blab1
 move (a5)+,d1
 bne f_blab2
 move (a5)+,d2
 bne f_blab3
 move (A5)+,d3
 bne f_zoup
 bra f_zk 
f_blab1: move (a5)+,d1
f_blab2: move (a5)+,d2
f_blab3: move (a5)+,d3	; prefetch all grafik_data
f_zoup: tst d7		; left or right shift?
 bne f_lef_shf
 ror.l d6,d0
 ror.l d6,d1
 ror.l d6,d2
 ror.l d6,d3
 bra f_gnmsk
f_lef_shf:
 rol.l d6,d0
 swap d0
 rol.l d6,d1
 swap d1
 rol.l d6,d2
 swap d2
 rol.l d6,d3
 swap d3
f_gnmsk: move.l d0,d4
 or.l d1,d4
 or.l d2,d4
 or.l d3,d4		; generate shifted maskk
 eor.l #-1,d4		; negate the mask
 swap d6
 swap d7		; Free up d6 an' d7 for word use
 tst left_suppress	; LHS suppression?
 bne f_lfsupr		; avoid de next bit
 move (a6),d6		; get bp1 low word
 and d4,d6
 or d0,d6
 move d6,(a6)+
 move (a6),d6
 and d4,d6
 or d1,d6
 move d6,(a6)+
 move (a6),d6
 and d4,d6
 or d2,d6
 move d6,(a6)+
 move (a6),d6
 and d4,d6
 or d3,d6
 move d6,(a6)+
 bra f_nlfsupr
f_lfsupr:
 lea 8(a6),a6
f_nlfsupr:
 move #0,left_suppress	; lsupp only done 1ce per scanline
 tst d5
 bne f_fxxyt0	; R-suppress only poss on last horiz sliv scan
 tst right_suppress
 bne f_fxxyt	; zoom to end if RHS-skip
f_fxxyt0:
 swap d0
 swap d1
 swap d2
 swap d3
 swap d4	; point to high wordz
 tst d4
 beq f_fxxyt	; allow for no-shift case
 move (a6),d6		; get bp1 low word
 and d4,d6
 or d0,d6
 move d6,(a6)
 move 2(a6),d6
 and d4,d6
 or d1,d6
 move d6,2(a6)
 move 4(a6),d6
 and d4,d6
 or d2,d6
 move d6,4(a6)
 move 6(a6),d6
 and d4,d6
 or d3,d6
 move d6,6(a6)
f_fxxyt:
 swap d6
 swap d7	; restore shift data
f_foxx: dbra d5,f_dmc 
n_sfx: movem.l (a7)+,d0-d2/a0-a1
 add.l a4,a0
 move xnumb,d5
 add #1,d1	;will be any raster you lyke

 dbra d2,l_sfx	; do all scanlines of displayed image
 rts		; done.

f_zk: lea 8(a6),a6
 move #0,left_suppress
 bra f_foxx


ch_spr:
;
; This is a special 16xn nonshifted sprite routine
; for drawing characters on the screen. It has been modified
; so that the chars will be drawn in original colours (TXTCOL<0)
; or in the colour specified if TXTCOL is not negative.
;
 move.l #ytab,a2	; ytab is vertical-offset table
 move 4(a0),d2	; vert size in scan lines
 lea 6(a0),a0
 move.l #8,a4	; all scanlines 8bytes long
 cmp ymin,d1	; check if y is onscreen
 bpl fw_top	; yes, no need to clip top of sprite
 move d1,d5	; working copy of y position
 add d2,d5	; move to bottom pos of sprite
 cmp ymin,d5	; bottom edge offscreen to top?
 bpl foff	; no
 rts		; yes
foff:
 move d1,d6	; copy of y position
 sub ymin,d6	; make limit relative to border
 neg d6		; how many scan lines above screen top?
 ext.l d6
 asl.l #3,d6	; multiply by 8
 add.l d6,a0	; move pointer up past redundant sprite data
 move ymin,d1	; sprite starts at y=0 now
 bra fi_2	; go do bottom-edge stuff
fw_top:
 move d1,d5	; copy of y position
 add d2,d5	; d5 is sprite maxheight
fi_2:
 cmp ymax,d5	; Sprite hanging off bottom?
 bmi fi_3	; No
 beq fi_3	; no
 cmp ymax,d1	; start off bottom?
 bmi finan	; no
 beq finan	; no
 rts		; yas.
finan:
 move ymax,d5	; make y max the bottom line
fi_3:
 sub d1,d5	; calc height of sprite in scanlines
 move d0,d6	; working copy of x position
 asr #4,d6	; reduce to 'slots'
 cmp xmax,d6	; off screen?
 bmi ffon	; no
 beq fn_sur	; no
 rts		; yes
fn_sur:
 move #1,right_suppress
 bra fxx	; extreme RHS, suppress right sprite
ffon:
 move #0,right_suppress
fxx: move #0,left_suppress	; clear left & right clip flags
 cmp xmin,d6	; LHS of image to be clipped?
 bpl fi_pos	; no
 add #1,d6	; check top slot
 cmp xmin,d6	; still off screen
 bpl fotoff	; no, draw hi words only
fFloyd: rts		; yes
fotoff:
 sub #1,d6		; leave d6 still with logikal slot
 move #1,left_suppress	; Suppress LHS of sprite
fi_pos:
fo_draw:
 move d1,d2	; get y-start
 asl #2,d2	; for offset into longword vector table..
 move.l 0(a2,d2.w),a3	; referenced by ytab
 add.l a3,a1	; a1 has screen y address
 move d6,d2	; fetch logical slot to start drawing sprite
 asl #3,d2	; eight bytes per slot
 ext.l d2	; extend to long..
 add.l d2,a1	; a1 now points to proper screenloke
 add.l d2,a3	; update backg screen ptr too
 move.l a3,o_addr
 tst unDraw	; plot or erase please?
 bne erase16	; go do erase, if non zero
 move d0,d6	; get xpixel pos'n
 and #$f,d6	; find ro-offset
 move #0,d7	; assume positiv_shift
 cmp #8,d6	; wrap-over?
 bmi f_lid	; no
 move #16,d7
 sub d6,d7	; make left-shift-count
 move d7,d6
 move #1,d7	; tell sys is a shift-left-situation
f_lid: move d5,o_lines
 move #1,o_loop
 move.l a0,a5
f_loop: move.l a1,a6
 moveq.l #0,d0
 moveq.l #0,d1
 moveq.l #0,d2
 moveq.l #0,d3
 move (a5)+,d0
 move (a5)+,d1
 move (a5)+,d2
 move (a5)+,d3	; prefetch all grafik_data
 move txtcol,d4	; pure or text colour?
 bmi is_pure	; pure
 or d3,d0
 or d2,d0
 or d1,d0	; combine b'plane data
 move d0,d1
 move d0,d2
 move d0,d3	; redistribute it
 and #$f,d4	; limit it
 asl #3,d4	; mul by 8
 move.l #txtmsks,a4
 lea 0(a4,d4.w),a4	; point to colour-masks
 and (a4)+,d0
 and (a4)+,d1
 and (a4)+,d2
 and (a4),d3		; gen right 'plane colours
is_pure:
 tst d7		; left or right shift?
 bne lf_shf
 ror.l d6,d0
 ror.l d6,d1
 ror.l d6,d2
 ror.l d6,d3
 bra gmsk
lf_shf:
 rol.l d6,d0
 swap d0
 rol.l d6,d1
 swap d1
 rol.l d6,d2
 swap d2
 rol.l d6,d3
 swap d3
gmsk: move.l d0,d4
 or.l d1,d4
 or.l d2,d4
 or.l d3,d4		; generate shifted maskk
 eor.l #-1,d4		; negate the mask
 swap d6
 swap d7		; Free up d6 an' d7 for word use
 tst left_suppress	; LHS suppression?
 bne lsupr		; avoid de next bit
 move (a6),d6		; get bp1 low word
 and d4,d6
 or d0,d6
 move d6,(a6)+
 move (a6),d6
 and d4,d6
 or d1,d6
 move d6,(a6)+
 move (a6),d6
 and d4,d6
 or d2,d6
 move d6,(a6)+
 move (a6),d6
 and d4,d6
 or d3,d6
 move d6,(a6)+
 bra nlsupr
lsupr:
 lea 8(a6),a6
nlsupr:
 tst right_suppress
 bne fxyt	; zoom to end if RHS-skip
 swap d0
 swap d1
 swap d2
 swap d3
 swap d4	; point to high wordz
 tst d4
 beq fxyt	; allow for no-shift case
 move (a6),d6		; get bp1 low word
 and d4,d6
 or d0,d6
 move d6,(a6)+
 move (a6),d6
 and d4,d6
 or d1,d6
 move d6,(a6)+
 move (a6),d6
 and d4,d6
 or d2,d6
 move d6,(a6)+
 move (a6),d6
 and d4,d6
 or d3,d6
 move d6,(a6)+
fxyt:
 swap d6
 swap d7	; restore shift data
 lea 160(a1),a1
 dbra d5,f_loop	; do all scanlines of displayed image
 rts		; done.


draw_p16:
 and #$fffe,d0	; clip x-co-ord to even pixel bounds
 move.l #ytab,a2	; ytab is vertical-offset table
 move #0,d4	; horiz size in slots
 move 4(a0),d2	; vert size in scan lines
 lea 8(a0),a0
 cmp ymin,d1	; check if y is onscreen
 bpl draw_t16	; yes, no need to clip top of sprite
 move d1,d5	; working copy of y position
 add d2,d5	; move to bottom pos of sprite
 cmp ymin,d5	; bottom edge offscreen to top?
 bpl noto16	; no
 rts		; yes
noto16:
 move d1,d6	; copy of y position
 sub ymin,d6	; make limit relative to border
 neg d6		; how many scan lines above screen top?
 muls #128,d6	; multiply by length of one scan line
 add.l d6,a0	; move pointer up past redundant sprite data
 move ymin,d1	; sprite starts at y=0 now
 bra dpsi_216	; go do bottom-edge stuff
draw_t16:
 move d1,d5	; copy of y position
 add d2,d5	; d5 is sprite maxheight
dpsi_216:
 cmp ymax,d5	; Sprite hanging off bottom?
 bmi dpsi_316	; No
 beq dpsi_316	; no
 cmp ymax,d1	; start off bottom?
 bmi inran16	; no
 beq inran16	; no
 rts		; yas.
inran16:
 move ymax,d5	; make y max the bottom line
dpsi_316:
 sub d1,d5	; calc height of sprite in scanlines
 move d0,d6	; working copy of x position
 asr #4,d6	; reduce to 'slots'
 cmp xmax,d6	; off screen?
 bmi xon16	; no
 beq xon16	; no
 rts		; yes
xon16:
 move #1,d2
 move d6,d3	; copy logical x start
 add #1,d3
 cmp xmin,d6	; LHS of image to be clipped?
 bpl posi_p16	; n
 cmp xmin,d3	; sprite end on screen?
 bpl xon_yes
 rts
xon_yes:
 lea 64(a0),a0
 move xmin,d6
 move #0,d2
 bra do_d16
posi_p16:
 cmp xmax,d3	; check RHS of sprite
 bmi do_d16	; RHS is onscreen
 beq do_d16
 move #0,d2
do_d16:
 move d1,d3	; get y-start
 asl #2,d3	; for offset into longword vector table..
 move.l 0(a2,d3.w),a3	; referenced by ytab
; add.l a3,a1	; a1 has screen y address
 move d6,d3	; fetch logical slot to start drawing sprite
 asl #3,d3	; eight bytes per slot
 ext.l d3	; extend to long..
 add.l d3,a1	; a1 now points to proper screenloke
 move.l a3,o_addr
 add.l d3,o_addr
 add.l a3,a1
 add.l d3,a3	; update backg screen ptr too
 move d0,d3	; get sprite x-position
 asr #1,d3	; lose LSB os x-pos
 and #$07,d3	; only interested in PSI offset
 asl #1,d3	; and again please
 ext.l d3	; make long
 add.l d3,a0	; a0 adjusted for correct PSI-scan
 tst unDraw	; plot or erase please?
 bne erase16	; go do erase, if non zero
 move d5,o_lines
 move d2,o_loop
d_loop16:
 move.l a0,a5
 move.l a1,a6	; and screen-RAM pointer
 move d2,d3	; re-set slice-counter
d_l_16:
 move (a5),d0	; get data on bitplane #1
 move d0,d7	; d7 will be used to make a mask
 swap d0	; shift 'plane 1 info to high word
 move 16(a5),d0	; bitplane #2
 or d0,d7	; add into the mask
 move 32(a5),d1	; bitplane #3
 or d1,d7	; add to mask
 swap d1	; move to high word
 move 48(a5),d1 ; bitplane #4
 or d1,d7	; complete mask
 move d7,d4	; d4 no longer needed, use as a temp...
 swap d7	; in order to...
 move d4,d7	; generate a longword-mask.
 eor.l #-1,d7	; invert mask
 and.l d7,(a6)	; mask 'planes 1 and 2
 or.l d0,(a6)+	; blast in the data
 and.l d7,(a6)	; mask 'planes 3 and 4
 or.l d1,(a6)+	; blast in the data
 lea 64(a5),a5
 dbra d3,d_l_16
xxyt16:
 lea 128(a0),a0
 lea 160(a1),a1
 dbra d5,d_loop16	; do all scanlines of displayed image
 rts		; done.

erase16:
 add.l back_screen,a3	; address backg screen
 ued_l_16:
 move.l (a3)+,(a1)+	; get backg data
 move.l (a3)+,(a1)+
 move.l (a3)+,(a1)+	; get backg data
 move.l (a3)+,(a1)+
 lea 144(a3),a3
 lea 144(a1),a1
 dbra d5,ued_l_16
 rts		; done.

erase_list: dc.l dummy,tidy,untidy

dummy: rts

erase:
;
; this routine jumps conditionally on the contents
; of the unDraw variable to do a 'tidy' (masked) erase
; (unDraw=1) or the fast 'quick and dirty' (unmasked)
; sprite erasure.
;
 move.l #erase_list,a5
 move unDraw,d7
 asl #2,d7
 move.l 0(a5,d7.w),a5
 jmp (a5)
tidy:
 add.l back_screen,a3	; address backg screen
erase_loop:
 move.l a0,a5	; preserve sprite data pointer
 move.l a1,a6	; and screen-RAM pointer
 move.l a3,-(a7)	; preserve backg origin
 move d6,d2	; re-set slice-counter
ed_l_1:
 move (a5),d0	; get data on bitplane #1
 move d0,d7	; d7 will be used to make a mask
 swap d0	; shift 'plane 1 info to high word
 move 16(a5),d0	; bitplane #2
 or d0,d7	; add into the mask
 move 32(a5),d1	; bitplane #3
 or d1,d7	; add to mask
 swap d1	; move to high word
 move 48(a5),d1 ; bitplane #4
 or d1,d7	; complete mask
 move d7,d4	; d4 no longer needed, use as a temp...
 swap d7	; in order to...
 move d4,d7	; generate a longword-mask.
 move.l d7,d4	; preserve a positive-mask
 eor.l #-1,d7	; invert mask
 move.l (a3)+,-(a7)	; get backg data
 move.l (a6),d0	; get current image
 and.l d4,(a7)	; mask out sprite shape
 and.l d7,d0	; cut hole in existing data
 or.l (a7),d0	; merge the two
 move.l d0,(a6)+	; blast in the data
 move.l (a6),(a7)	; fetch 'planes 3 and 4
 and.l d4,(a7)	; chop
 move.l (a3)+,(a7)	; get more backg
 move.l (a6),d1	; get current screen contents
 and.l d7,d1	; mask with negative image
 and.l d4,(a7)	; get correct backg
 or.l (a7),d1	; merge
 lea 4(a7),a7
 move.l d1,(a6)+	; blast in the data
 lea 64(a5),a5
 add #1,d2	; add to horiz-slot-counter
 cmp d2,d3	; equal to RHS-limit?
 bpl ed_l_1	; yes, carry on
 move.l (a7)+,a3
 lea 160(a3),a3
 add.l a4,a0	; update data pointer
 lea 160(a1),a1
 dbra d5,erase_loop
 rts		; done.

untidy:
 add.l back_screen,a3	; address backg screen
uerase_loop:
 move.l a1,a6	; set screen-RAM pointer
 move.l a3,-(a7)	; preserve backg origin
 move d6,d2	; re-set slice-counter
ued_l_1:
 move.l (a3)+,(a6)+	; get backg data
 move.l (a3)+,(a6)+
 add #1,d2	; add to horiz-slot-counter
 cmp d2,d3	; equal to RHS-limit?
 bpl ued_l_1	; yes, carry on
 move.l (a7)+,a3
 lea 160(a3),a3
 lea 160(a1),a1
 dbra d5,uerase_loop
 rts		; done.

draw_nsi:
 move 2(a0),d2	; get horiz size of NSI
 move 4(a0),d3	; get vert NSI size
 move 6(a0),er_mode
 lea 8(a0),a0
 move d0,d4	; copy of horiz. start
 asr #4,d4	; interested only in slot status
 move d4,d5	; at the same time calculate...
 add d2,d5	; the RHS-limiter
 cmp xmin,d4	; on the screen at left?
 bpl nsi_onleft	; yup
 cmp xmin,d5	; right edge in range?
 bpl xclip	; yes, so need to clip edge
 rts		; no, might as well naff-off
xclip:
 sub xmin,d4	; make relative to zero
 neg d4		; # of slots to skip
 asl #3,d4	; 8 bytes per slot, just raw data
 ext.l d4
 add.l d4,a0	; bypass unused stuff
 move xmin,d4	; starts here now
nsi_onleft:
 cmp xmax,d5	; RHS off the screen?
 bmi noor	; no
 move xmax,d5	; yes, xmax becomes new limit
noor:
 move d2,d7	; calculate line length...
 asl #3,d7	; in d7 just for the mo'
 move d1,d6	; copy of Y start
 cmp ymin,d6	; top of sprite off top?
 bpl notopp	; no it ain't, everything is cool
 sub ymin,d6	; relative to zero...
 neg d6		; calc overshoot...
 cmp d6,d3	; overshoot greater than vert size?
 bmi pinkFloyd	; yeah, don't bother
 muls d7,d6	; calc scanline skip..
 add.l d6,a0	; ..and offset thy data pointer
 move ymin,d6	; sprite logical start at ymin
notopp:
 add d1,d3	; get logical sprite end in d3
 cmp ymax,d3	; off screen bottom?
 bmi noto1	; yes indeedy
 move ymax,d3	; so OK....
noto1: exg d3,d7	; because I sez so
 ext.l d3	; for longadds
 cmp xmax,d4	; off RHS screen?
 bpl pinkFloyd	; yup
 cmp ymax,d6	; off bottom?
 bpl pinkFloyd	; yup
 move.l #ytab,a2	; get y-offset table
 move d6,d2	; get y-start
 asl #2,d2	; point to longs
 move.l 0(a2,d2.w),a2	; get y-offset
 add.l a2,a1	; add t'screen base
 move d4,d1	; get x-start
 asl #3,d1	; 8-bytes-per-slot
 ext.l d1	; get ready to add...
 add.l d1,a1	; a1 now has true screenloke
 sub d6,d7	; free up d6, make d7 a DBRA counter
 tst unDraw	; erase?
 bne nsi_erase	; yup
nsi_plot:
 move.l a0,a2	; data pointer copy
 move.l a1,a3	; screenloke copy
 move d4,-(a7)	; preserve x-start thingy
nsi_p1:
 move (a2),d6
 or 2(a2),d6
 or 4(a2),d6
 or 6(a2),d6	; generate a mask
 move d6,d1
 swap d6
 move d1,d6	; a longword mask
 eor.l #-1,d6	; a negative longword mask
 move.l (a3),d0	; get xisting screenimage 
 and.l d6,d0	; make a hole
 or.l (a2)+,d0	; merge the data
 move.l d0,(a3)+	; drop it back in
 move.l (a3),d0	; do it again...
 and.l d6,d0	; for the next..
 or.l (a2)+,d0	; two bit-planes
 move.l d0,(a3)+
 add #1,d4
 cmp d4,d5	; reached dest edge yet?
 beq nsi_p2
 bpl nsi_p1
nsi_p2:
 move (a7)+,d4	; restore hcounter
 lea 160(a1),a1
 add.l d3,a0	; update data ptr
 dbra d7,nsi_plot	; loop fur all scan lines
 rts

nsi_list: dc.l ensi_plot,ensi_dirty
er_mode: dc.w 0

nsi_erase:
 move.l back_screen,a4
 add.l a2,a4
 add.l d1,a4
 move.l #nsi_list,a5
 move er_mode,d6
 asl #2,d6
 move.l 0(a5,d6.w),a5
 jmp (a5)
ensi_plot:
 move.l a0,a2	; data pointer copy
 move.l a1,a3	; screenloke copy
 move.l a4,a5
 move d4,-(a7)	; preserve x-start thingy
ensi_p1:
 move (a2),d6
 or 2(a2),d6
 or 4(a2),d6
 or 6(a2),d6	; generate a mask
 move d6,d1
 swap d6
 move d1,d6	; a longword mask
 move.l d6,d1	; keep a positive copy
 eor.l #-1,d6	; a negative longword mask
 move.l (a5)+,d2	; fetch bg
 and.l d1,d2	; make in shape of sprite
 move.l (a3),d0	; get xisting screenimage 
 and.l d6,d0	; make a hole
 or.l d2,d0	; drop in chopp'd sprite stuff
 lea 8(a2),a2
 move.l d0,(a3)+	; drop it back in
 move.l (a5)+,d2
 and.l d1,d2
 move.l (a3),d0	; do it again...
 and.l d6,d0	; for the next..
 or.l d2,d0	; two bit-planes
 move.l d0,(a3)+
 add #1,d4
 cmp d4,d5	; reached dest edge yet?
 beq ensi_p2
 bpl ensi_p1
ensi_p2:
 move (a7)+,d4	; restore hcounter
 lea 160(a1),a1
 lea 160(a4),a4
 add.l d3,a0	; update data ptr
 dbra d7,ensi_plot	; loop fur all scan lines
 rts

ensi_dirty:
 move.l a1,a3	; screenloke copy
 move.l a4,a5
 move d4,-(a7)	; preserve x-start thingy
eensi_p1:
 move.l (a5)+,(a3)+
 move.l (a5)+,(a3)+
 add #1,d4
 cmp d4,d5	; reached dest edge yet?
 beq eensi_p2
 bpl eensi_p1
eensi_p2:
 move (a7)+,d4	; restore hcounter
 lea 160(a1),a1
 lea 160(a4),a4
 dbra d7,ensi_dirty	; loop fur all scan lines
 rts

ytab_init:

; Initialise the ytab screen-offset table.

 move.l #ytab,a0	; Get data table position
 move.l #0,d0	; set offset to zero
 move #199,d1	; do 200 lines
yt_init:
 move.l d0,(a0)+	; place offset
 add.l #160,d0		; next line offset
 dbra d1,yt_init	; do all 200 lines
 rts		; done

odd: dc.w 0
odd2: dc.w 0

  
  
numval: dc.w 0



print:
;
; Print a string, with imbedded control commands.
; Enter with the address of yer string in a0.
; Commands are preceded by a \ character. The following
; are recognized:
;
; \r  CR/LF
; \e  End printing
; \u, \d, \l, \r  Move print position up, down, left, right
; \s Set font # (follow with numeric)
; \g Go to screen position (follow with 2 numerics)
; \n Print current value of NUMVAL.S, no trailing spaces
; \c Set text colour; -ve = original bitmap
; \q Draw text as centred on current v. line until 0
; Before printing, set TXTMODE to hit the screen(s) you need
; and set TXT_X and TXT_Y to screen position (or use \g)
;
;
 move cfont,d3	; get cfont flag
 asl #2,d3
 move.l #font_list,a3
 move.l 0(a3,d3.w),a3	; a3 points to current font info
 move (a3),d5	; get vert step size
 move txt_x,d0
 move d0,retstart	; left margin preserve
 move txt_y,d1	; set up initial cursor position
 move #0,d4	; mask initially
pr_loop:
 move.b (a0)+,d2	; get the char
 and #$ff,d2
 cmp.b #'\',d2	; control character?
 beq pr_control	; yes, go do control stuff
 movem.l d0-d4/a0-a2,-(a7)
justify: move d2,d3	; get next character
 asl #2,d3
 move.l 2(a3,d3.w),a1	; get sprite def
 add 2(a1),d0	; add xpos of next char
 cmp xmax_real,d0
 bpl unjustify
 move.b (a0)+,d2
 cmp.b #' ',d2
 beq ijust
 cmp.b #'\',d2
 beq ijust
 bra justify
unjustify:   
 movem.l (a7)+,d0-d4/a0-a2
 move retstart,d0
 add d5,d1	; cr/lf
 cmp #182,d1
 bmi lspace
 tst botchk
 beq lspace
pr_enplus: move d0,txt_x
 move d1,txt_y
 move #1,d0
 rts
botchk: dc.w 0
lspace:
 cmp.b #'\',d2
 beq pr_control
 cmp.b #' ',d2	; Leading spaces after CR/lf discard
 bne maltape
 move.b (a0)+,d2
 bra lspace
ijust:
 movem.l (a7)+,d0-d4/a0-a2
maltape:
 bsr dprint	; handle the printing
 cmp xmax_real,d0	; screen edge?
 bmi pr_loop	; no, print next char
 add d5,d1	; down a line
 move retstart,d0	; force a CR
zik: cmp #182,d1
 bmi pr_loop
 tst botchk
 beq pr_loop
 bra pr_enplus	; carry on printing
pr_control:
 move.b (a0)+,d2 ; what u want me to do?
 cmp.b #'q',d2	; centred text via DCENTXT
 bne pr_c0
 movem.l d0-d7/a0-a6,-(a7)
 move txtcol,d2
 move cfont,d0
 jsr dcentxt
 movem.l (a7)+,d0-d7/a0-a6
prc: move.b (a0)+,d2
 bne prc
 bra pr_loop
pr_c0:
 cmp.b #'r',d2
 bne pr_c1	; not RETURN
 move retstart,d0
 add d5,d1
 bra zik
pr_c1:
 cmp.b #'e',d2
 bne pr_c2	; not END
 move d0,txt_x
 move d1,txt_y	; store cursor stuff
 tst botchk
 beq pwoo
 move #0,d0
pwoo: rts
pr_c2:
 cmp.b #'u',d2
 bne not_up
 sub d5,d1
 bra pr_loop
not_up:
 cmp.b #'d',d2
 bne not_down
 add d5,d1
 bra pr_loop
not_down: cmp.b #'l',d2
 bne not_left
 sub d5,d0
 bra pr_loop
not_left: cmp.b #'i',d2
 bne not_right 
 add d5,d0
 bra pr_loop
not_right:
 cmp.b #'s',d2
 bne notsize
 move.b (a0)+,d2
 and #$0f,d2
 move d2,cfont
 asl #2,d2
 move.l #font_list,a3
 move.l 0(a3,d2.w),a3
 move (a3),d5
 bra pr_loop
notsize:
 cmp.b #'g',d2
 bne numm
 move.b (a0)+,d0
 and #$ff,d0
 move d0,retstart
 move.b (a0)+,d1
 and #$ff,d1
 bra pr_loop
numm:
 cmp.b #'c',d2
 bne nummi
 move.b (a0)+,d2
 and #$0f,d2
 move d2,txtcol
 bne pr_loop
 move #-1,txtcol
 bra pr_loop
nummi:
 cmp.b #'n',d2
 bne pr_loop
 move.l #num_buff,a2
 move numval,d6
 beq pr_loop
 and.l #$ffff,d6
 move #5,d7
 move.l d6,d2
skorp:
 cmp #10,d2
 bmi goka
 divs #10,d2
 swap d2
goka: add #$30,d2
 move.b d2,0(a2,d7.w)
 swap d2		; remainda is hi word
 tst d2
 beq gozero
 ext.l d2
 dbra d7,skorp  
gozero:
 move.b 0(a2,d7.w),d2
 and #$ff,d2
 move d2,d6
 asl #2,d6
 move.l 2(a3,d6.w),a1	; get sprite def
 move 2(a1),d6	; add xpos of next char
 movem.l d0-d7/a0-a3,-(a7)
 bsr dprint
 movem.l (a7)+,d0-d7/a0-a3
 add d6,d0
 add #1,d7
 cmp #6,d7
 bne gozero
 bra pr_loop
num_buff: ds.b 6

qad: dc.w 0

setfnt: move cfont,d3	; get cfont flag
 asl #2,d3
 move.l #font_list,a3
 move.l 0(a3,d3.w),a3
 rts

 	
dprint:
;
; Print a character according to TXTMODE
;
 movem.l d0-d5/a0-a3,-(a7)
 move d2,d6
 asl #2,d6	; point to char sprite image
 move.l 2(a3,d6.w),d6
 beq dpr4	; ignore non-defined chars
 move.l d6,a0	; sprite data start-point
 move 2(a0),qad	; pixels to add after char draw
 btst #0,txtmode
 beq dpr1
 move.l back_screen,a1
 movem.l d0-d4/a0,-(a7)
 bsr sdraw
 movem.l (a7)+,d0-d4/a0
dpr1: btst #1,txtmode
 beq dpr2
 move.l ascreen,a1
 movem.l d0-d4/a0,-(a7)
 bsr sdraw
 movem.l (a7)+,d0-d4/a0
dpr2: btst #2,txtmode
 beq dpr3
 move.l bscreen,a1
 movem.l d0-d4/a0,-(a7)
 bsr sdraw
 movem.l (a7)+,d0-d4/a0
dpr3: btst #3,txtmode
 beq dpr4
 move.l cscreen,a1
 movem.l d0-d4/a0,-(a7)
 bsr sdraw
 movem.l (a7)+,d0-d4/a0
dpr4:
 movem.l (a7)+,d0-d5/a0-a3
 add qad,d0
 move #0,qad
 rts

screen_get:

; Return the current screenbase in a0.

 move #3,-(a7)
 trap #14
 addq.l #2,a7
 move.l d0,a0
 rts

cls:

; Clear screen pointed to in a0 to zero.

 move #7999,d0
cls1:
 move.l #0,(a0)+
 dbra d0,cls1
 rts

rod: dc.w $0202

pal_stuff:
;
; Routine to let you do fades, etc. on individual palette
; colours
;
 tst fon	; Fade commanded?
 beq no_fade
 sub #1,fdel_c	; Time to fade?
 bpl no_fade
 move fdel,fdel_c
 move.l #real_levels,a0
 move fstart,d0
 asl #1,d0
 move fend,d1
 asl #1,d1
 move fstep,d2
dfa: move 0(a0,d0.w),d3
 add d2,d3
 move d3,0(a0,d0.w)
 cmp d0,d1	; end of fade range?
 beq fdone
 add #2,d0
 bra dfa
fdone: cmp fto,d3	; reached target level?
 bne no_fade
 move #0,fon	; turn off fader
no_fade:
 tst ron
 beq kappa
 sub.b #1,rod
 bpl kappa
 move.b rod+1,rod
 move.l source_pal,a0
 lea 30(a0),a0
 move.l a0,a1
 lea -2(a1),a1
 move #13,d0
 move (a0),-(a7)
rop: move (a1),(A0)
 lea -2(a1),a1
 lea -2(a0),a0
 dbra d0,rop
 move (a7)+,(a0)

kappa: move.l #cseqlst,a0
 move.l source_pal,a2
 move #15,d0
cseq: tst.l (a0)+
 beq cseq_nxt
csr: move.l -4(a0),a1
 move (a1)+,d2
 bmi seq_rst
 move d2,(a2)
 move.l a1,-4(a0)
 bra cseq_nxt
seq_rst:
 move.l (a1)+,-4(a0)
 bra csr
cseq_nxt:
 lea 2(a2),a2
 dbra d0,cseq  
 move.l #$ff8240,a0
 move.l source_pal,a1
 move.l #real_levels,a2
 move #15,d0
pstuf:
; cmp #14,d0
; bne colk
 bsr spall_level
; lea 2(a1),a1
; lea 2(a0),a0
; dbra d0,pstuf
;colk: move (a1)+,(a0)+
 dbra d0,pstuf
Coke_can: rts


Goke_can: lea 2(a0),a0
 rts

ron: dc.w 0

spall_level:
;
; Set current palette slot to specified max level
;
 move (a1)+,d1	; source colour
 move (a2)+,d2	; get level
 bmi Goke_can	; if minus, no go
 move #0,d4	; d4 will hold result 
 tst d2
 bne not_trib
 move #0,(a0)+	; trivial result if level=0
 rts
not_trib:
 move #$7,d5	; d5 used as mask
 move #2,d6	; counter
ss_lev:
 move d1,d3	; get whole colour
 and d5,d3	; mask out RGB component
 cmp d3,d2	; compare with desired level
 bpl ss_l1	; positive, is OK
 move d2,d3	; coerce to desired level
ss_l1:
 or d3,d4	; build result colour
 asl #4,d2
 asl #4,d5	; shift for next colour setting
 dbra d6,ss_lev	; do all RGB
 move d4,(a0)+	; place in h/w palette
 rts


go_fur:
; Pass d0,d1 = position to fire from
; d2,d3 = point of aiming. 
; d6 = speed (step size towards goal)
;
; Routine returns d4,d5 = Updated position (so you can
; save the resultant offset if ewe want) and d6=1 if
; target has been reached.
;
 move #0,coswap ; clear coswap flag
qline2:
 move #-1,_neg	; set _NEG 0
 move d0,_x
 cmp d0,d2
 bpl qnosw
 move #1,_neg
 exg d0,d2		; and swap co-ords
qnosw:
 clr _ng		; NG flag
 move d2,d4
 sub d0,d4
 move d4,dx ; x-difference
 move d3,d5
 sub d1,d5
 bpl qyoke
 move #1,_ng	; set NG flag if y diff is -vo
 move d1,d5
 sub d3,d5
qyoke: move d5,dy ; y-difference
 cmp d4,d5
 bmi qbres4 ; x-diff is greater, so no CSW
 beq qbres4 ; or else, gradient is one
 tst _neg	; anomaly?
 bmi qyoke2
 exg d0,d2	; swap back 
qyoke2:
 exg d0,d1
 exg d2,d3
 move #1,coswap ; set swap flag
 bra qline2 ; go recalculate
qbres4:
 asl #1,d5 ; dy*2
 move d5,incr1 ; incr1=2*dy
 sub d4,d5
 move d5,_d ; d=2*dy-dx
 move dy,d5
 sub dx,d5
 asl #1,d5
 move d5,incr2 ; incr2=2*(dy-dx)
 move d0,xx
 move d1,yy
 move d2,xend

qbresloop: move xx,d0	; get XX
 move xend,d1		; get Xend
 cmp d1,d0
 bpl moo_e
moobo:
 add #1,xx		; inc 'xpos'
 add #1,_x
 tst _neg		; _NEG?
 bmi ninn
 sub #2,_x		; update 'real' X
ninn: move _d,d0		; 'd'
 bpl qbres2
 move incr1,d0	; 'incr1'
 add d0,_d
 bra qbres3
qbres2:tst _ng	; 'ng'
 beq qaaa
 sub #1,yy		; 'yy'
 bra qbbb
qaaa: add #1,yy	; 'yy'
qbbb: move incr2,d0	; incr2
 add d0,_d		; 'd'
qbres3:
 dbra d6,qbresloop	; do all Speed iterations
 move #0,d6
mooend:
 move _x,d4
 move yy,d5
 tst coswap
 beq mooe
 exg d4,d5
mooe: rts
moo_e:
 move #1,d4
 move #1,d5
 move #1,d6
 rts

fklide:
;
; Perform collision-check on two specified sprites.
; Enter with d0/d1=centre position of sprite #1
; d2/d3=centre position of sprite #2
; a0=sprite pointer of sprite #1
; a1=sprite pointer of sprite #2
; Returns d4: bit 0 set = Vertical sprite collision
; bit 1 set = Horizontal sprite collision
;
 move #0,d4	; clear returning register
 move 4(a0),d5	; get vsize of sprite 1
 asr #1,d5
 sub d5,d1	; calc actual corner position of sprite
 move 4(a1),d5	; vsize spr.2
 asr #1,d5
 sub d5,d3	; start position of sprite #2
 cmp d1,d3	; Check initial sprite positioning
 bmi kl1	; Sprite #1 lower than top edge sprite #2
 add 4(a0),d1	; Bottom edge sprite #1
 cmp d1,d3
 bpl hklide	; No overlap
y_vklide:
 move #1,d4	; Set bit 0; vertical collision is true
 bra hklide
kl1:
 add 4(a1),d3	; get bottom edge of sprite #2
 cmp d1,d3	; Check top spr1 against bottom spr2
 bpl y_vklide	; Overlap is true
hklide:
 move 6(a0),d5	; get hsize of sprite 1
 asr #1,d5
 sub d5,d0	; calc actual corner position of sprite
 move 6(a1),d5	; hsize spr.2
 asr #1,d5
 sub d5,d2	; start position of sprite #2
 cmp d0,d2	; Check initial sprite positioning
 bmi kl2	; Sprite #1 lefter than left edge sprite #2
 add 6(a0),d0	; Right edge sprite #1
 cmp d0,d2
 bpl klidend	; No overlap
y_hklide:
 or #2,d4	; Set bit 1; horizontal collision is true
 rts		; Return collision status
kl2:
 add 6(a1),d2	; get right edge of sprite #2
 cmp d0,d2	; Check left spr1 against right spr2
 bpl y_hklide	; Overlap is true
klidend:
 rts		; Collision chex done

psi_klide:

 move.l 4(a0),a0
 lea -2(a0),a0
 move.l 4(a1),a1
 lea -2(a1),a1

klide:
;
; Return 1 on full CD else 0
;
 cmp #5,(a0)
 bne kkjkk
 move.l 4(a0),a0
 lea -2(a0),a0
kkjkk: cmp #5,(a1)
 bne llkll
 move.l 4(a1),a1
 lea -2(a1),a1
llkll: move 6(a0),d5
 asr #1,d5
 move 6(a1),d4
 asr #1,d4
 add d4,d5
 sub d2,d0
 bpl akk1
 neg d0
akk1: cmp #4096,d0
 bmi troj
 sub #4096,d0
troj: cmp d5,d0
 bpl kfail
 move 4(a0),d5
 asr #1,d5 
 move 4(a1),d4
 asr #1,d4
 add d4,d5
 sub d3,d1
 bpl akk2
 neg d1
akk2: cmp #2048,d1
 bmi troj1
 sub #2048,d1
troj1: cmp d5,d1
 bpl kfail
 move #1,d4
 rts

kfail: move #0,d4
 rts

last_c: dc.w 0
cenfix: dc.w 0

centxt:
;
; Draw centred line of text using current font
; Centred on line d1, text at (a0), screen at (a1)
; unDraw list (a2), text expansion factor d2. Text
; must be zero-terminated. Font # in cfont.
;
 move cfont,d3
 asl #2,d3
 move.l #font_list,a3
 move.l 0(a3,d3.w),a3	; point to font
 tst cenfix
 beq sxsx
 move last_c,d4
 move.l a0,a4
 bra gsize_e
sxsx: move #0,d4		; d4 will be total width ctr
 move.l a0,a4
gsize: move.b (a0)+,d3
 beq gsize_ex
 and #$ff,d3
 asl #2,d3
 move.l 2(a3,d3.w),a5	; point to char data base
 add 2(a5),d4		; add normal X-offset
 add d2,d4		; add given expansion constant
 bra gsize		; loop until zero found
gsize_ex: move d4,last_c
gsize_e:
 asr #1,d4		; halve text size
 neg d4			; negate it
 add #160,d4		; and add to 160 to centre it
 move d4,d0		; is X-start of drawn text
drtex: move.b (a4)+,d3
 beq drtex_e 
 and #$ff,d3
 asl #2,d3
 move.l 2(a3,d3.w),a0	; get tex sprite
 move.l a0,-(a7)
 movem.l d0-d2/a3-a4,-(a7)
 jsr draw_sprite
 movem.l (a7)+,d0-d2/a3-a4
 move.l (a7)+,a0
 add 2(a0),d0
 add d2,d0
 bra drtex
drtex_e: rts		; drawn centred string 

to_all:
;
; Plot a sprite (a0) at (d0,d1) on backscreen and all
; three buffer screens.
;
 move.l back_screen,a1
 movem.l d0-d1/a0,-(a7)
 bsr sdraw
 movem.l (a7)+,d0-d1/a0
 move.l ascreen,a1
 movem.l d0-d1/a0,-(a7)
 bsr sdraw
 movem.l (a7)+,d0-d1/a0
 move.l bscreen,a1
 movem.l d0-d1/a0,-(a7)
 bsr sdraw
 movem.l (a7)+,d0-d1/a0
 move.l cscreen,a1
 movem.l d0-d1/a0,-(a7)
 bsr sdraw
 movem.l (a7)+,d0-d1/a0
 rts

the_business: dc.l null
dcentxt:
 move.l #cen_bufr,a2
 move.l back_screen,a1
 move d0,cfont
 move d2,txtcol
 move #0,d2
 jmp centxt

scroll_business: dc.l null

gpsprite: move.l scroll_business,a0
 jsr (a0)
 move.l ascreen,a1
 move #0,unDraw
 move.l shipa,a2
 move #-500,(a2)	
 move.l the_business,a3
 jsr (a3)
 move.l ascreen,addr
 tst scor_upd8		; need to update score display?
 beq _weloop		; no
 move #0,scor_upd8
 bsr udscore
_weloop: tst syncreq
 bne _weloop
 move frame_rate,syncreq
 move.l bscreen,a1
 move #2,unDraw
 jsr del_als
 move.l ascreen,d4
 move.l bscreen,ascreen
 move.l cscreen,bscreen
 move.l d4,cscreen
 move.l shipa,d4
 move.l shipb,shipa
 move.l shipc,shipb
 move.l d4,shipc
null: rts

waibut: 
 move.b buttons,d2
 and #3,d2
 bne waibute
 move #1000,d1
fala: dbra d1,fala
 dbra d0,waibut
 move #0,d0
 rts
waibute:
 move d2,d0
 rts

fade_out:
 move #-1,fstep
 move #0,fto
fao:
 move d2,fdel_c
 move d2,fdel
 move d0,fstart
 move d1,fend
 move #1,fon
 rts

fade_in: move #1,fstep
 move #7,fto
 bra fao

areq: dc.w 0
sreq: dc.w 0
greq: dc.w 0
_demo: dc.w 0
_fix: dc.w 0

xx: dc.w 0
yy: dc.w 0
xend: dc.w 0
_d: dc.w 0
_ng: dc.w 0
incr1: dc.w 0
incr2: dc.w 0
speed: dc.w 0
coswap: dc.w 0
_neg: dc.w 0
_x: dc.w 0
dx: dc.w 0
dy: dc.w 0

source_pal: dc.l source_pal
real_levels: dc.w 0,-1,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7
fstart: dc.w 2
fend: dc.w 15
fstep: dc.w 1
fdel: dc.w 20
fdel_c: dc.w 0
fon: dc.w 0
fto: dc.w 7
cseqlst: dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

loopptr: dc.l loopadr
loopadr: dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
loopctr: dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
back_screen: dc.l 0
unDraw: dc.w 0
cfont: dc.w 0
txt_x: dc.w 0
txt_y: dc.w 0
txtmode: dc.b 0,0
retstart: dc.w 0

logox: dc.w 0
logoy: dc.w -500
logoxv: dc.w 0
logoyv: dc.w 0
logoad: dc.w 5
logovd: dc.w 0

velocities:
 dc.w -8,-7,-6,-5,-4,-3,-2,-1,-1,-1,-1,-1,-1,-1,-1,-1,0
 dc.w 1,1,1,1,1,1,1,1,1,2,3,4,5,6,7,8
 dc.w 0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,0
 dc.w 8,7,6,5,4,3,2,1,0,0,0,0,0,0,0,0


rantab: ds.b 512
ranptr: dc.w 0

frame_rate: dc.w 1  

;axvec: dc.l sprites
atype: dc.w 0

addr: dc.l -1

numbers: include i:\gamecore\number2.s
 include i:\gamecore\sonix.s
 even
; include i:\gamecore\scrollx.s
fonta: include i:\gamecore\fonta.s
fontb: include i:\gamecore\fontb.s
fontc: include i:\gamecore\fontc.s
fontd: include i:\gamecore\fontd.s

font_list: dc.l fonta,fontb,fontc,fontd

ascreen: dc.l 0		; space for new screen addr.
bscreen: dc.l 0		; space for double buffer screen
cscreen: dc.l 0		; triplescreen write-thru

syncreq: dc.w 0

xpos: dc.w 0
ypos: dc.w 0
xoff: dc.w 0
yoff: dc.w 0
buttons: dc.w 0

key_vec equ $118

mouse_pars: dc.l $01000101




ship_d1: ds.b 12000
ship_d2: ds.b 12000
ship_d3: ds.b 12000
shipa: dc.l ship_d1
shipb: dc.l ship_d2
shipc: dc.l ship_d3

css1: dc.w $700,$710,$720,$730,$770,$730,$720,$710,-1
 dc.l css1

css2: dc.w $770,$700,$660,$600,$550,$500,$440,$400,$707,-1
 dc.l css2

css3: dc.w $070,$070,$070,$070,$070,$070,$070,$707,-1
 dc.l css3



sine:
 incbin i:\gamecore\sine.img

hdisabl: dc.w 0
xmin: dc.w 0
xmax: dc.w 19
xmax_real: dc.w 319
ymin: dc.w 0
ymax: dc.w 199

oposn: dc.w 0
tposn: dc.w 0
nposn: dc.w 0

txtcol: dc.w -1
txtmsks: dc.w 0,0,0,0
 dc.w -1,0,0,0
 dc.w 0,-1,0,0
 dc.w -1,-1,0,0
 dc.w 0,0,-1,0
 dc.w -1,0,-1,0
 dc.w 0,-1,-1,0
 dc.w -1,-1,-1,0
 dc.w 0,0,0,-1
 dc.w -1,0,0,-1
 dc.w 0,-1,0,-1
 dc.w -1,-1,0,-1
 dc.w 0,0,-1,-1
 dc.w -1,0,-1,-1
 dc.w 0,-1,-1,-1
 dc.w -1,-1,-1,-1


mason: dc.l 0 
_startup: dc.w 1

syncount: dc.w 0

ytab: ds.l 200

cen_bufr: ds.b 1024

xpptr: dc.l xpsi
xpsi: dc.l 0

screen equ xpsi+50000

lscreen equ screen+2








