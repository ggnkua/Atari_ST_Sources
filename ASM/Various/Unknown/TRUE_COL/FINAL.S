_p_cookies equ $5a0
F30_val equ $00030000
modeVGA equ %100010100
modeRGB equ %000100100
anz_spr equ 25

text

         move.l 4(sp),a0;
         lea newstack,sp
         move.l #$100,d0
         add.l $c(a0),d0
         add.l $14(a0),d0
         add.l $1c(a0),d0
         move.l d0,-(sp)
         move.l a0,-(sp)
         clr.w -(sp)
         move.w #$4a,-(sp)
         trap #1
         lea 12(sp),sp
         clr.l -(sp)
         move.w #$20,-(sp)
         trap #1
         addq.l #6,sp
	move.l d0,oldstack
	lea $5a0.w,a0
	move.l (a0),a0
	beq.s failure
	move.l #'_VDO',d0
search_cookie:
	tst.l (a0)
	beq.s failure
	lea 8(a0),a0
	cmp.l -8(a0),d0
	bne.s search_cookie
	cmp.l #F30_val,-4(a0)
	beq.s found_cookie
failure:
	pea fail_text
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
        move.l oldstack,-(sp)
	move.w #$20,-(sp)
	trap #1
	move.w #1,-(sp)
	trap #1
	addq.l #2,sp
	clr.w -(sp)
	trap #1
found_cookie:
	move.w #-1,-(sp)
	move.w #88,-(sp)
	trap #14
	addq.l #4,sp
	move.w d0,oldmode
        move.w #2,-(sp)
	trap #14
	addq.l #2,sp
	move.l d0,oldphys
	move.w #3,-(sp)
	trap #14
	addq.l #2,sp
	move.l d0,oldlog
	move.w #89,-(sp)
	trap #14
	addq.l #2,sp
	tst d0
	beq.s failure
	cmp.w #2,d0
	beq.s vga_init
rgb_init:
	move.w #modeRGB,d0
	bsr.s scr_allocate
	move.w #modeRGB,d0
	move.w #3,-(sp)
	move.l screen1,-(sp)
	move.l screen2,-(sp)
	move.w #5,-(sp)
	trap #14
	lea 14(sp),sp
	move.w #modergb,-(sp)
	move.w #88,-(sp)
	trap #14
	addq.l #4,sp
	move.w #199,y_max
	bra go_on
vga_init:
	move.w #modevga,d0
	bsr.s scr_allocate
	move.w #modeVGA,-(sp)
	move.w #3,-(sp)
	move.l screen1,-(sp)
	move.l screen2,-(sp)
	move.w #5,-(sp)
	trap #14
	lea 14(sp),sp
	move.w #239,y_max
	bra go_on
scr_allocate:
	move.w d0,-(sp)
	move.w #91,-(sp)
	trap #14
	addq.l #4,sp
	move.l d0,d6
	lsl.l #1,d0
	add.l #1,d0
	move.l d0,-(sp)
	move.w #$48,-(sp)
	trap #1
	addq.l #6,sp
	tst d0
	beq failure
	addq.l #1,d0
	and.l #$fffffffe,d0
	move.l d0,screen1
	add.l d6,d0
	move.l d0,screen2
	rts
quit:
	pea mausan
	clr.w -(sp)
	move.w #$19,-(sp)
	trap #14
	addq.l #8,sp
	pea oldcolor
	move.w #1,-(sp)
	clr.w -(sp)
	move.w #93,-(sp)
	trap #14
	lea 10(sp),sp
	move.w oldmode,-(sp)
	move.w #3,-(sp)
	move.l oldphys,-(sp)
	move.l oldlog,-(sp)
	move.w #5,-(sp)
	trap #14
	lea 14(sp),sp
	move.w oldmode,-(sp)
	move.w #88,-(sp)
	trap #14
	addq.l #4,sp
	move.l oldstack,-(sp)
	move.w #$20,-(sp)
	trap #1
	clr.w -(sp)
	trap #1
go_on:
	pea oldcolor
	move.w #1,-(sp)
	clr.w -(sp)
	move.w #94,-(sp)
	trap #14
	lea 10(sp),sp
	pea newcolor
	move.w #1,-(sp)
	clr.w -(sp)
	move.w #93,-(sp)
	trap #14
	lea 10(sp),sp
	pea mausaus
	clr.w -(sp)
	move.w #$19,-(sp)
	trap #14
	addq.l #8,sp
	bsr prepare_screens
	bsr init_koords
main_loop:
	bsr clear_sprites
	bsr calc_koords
	bsr draw_sprites
	move.w #$ff,-(sp)
	move.w #6,-(sp)
	trap #1
	addq.l #4,sp
	tst d0
	bne quit
	move.w #37,-(sp)
	trap #14
	addq.l #2,sp
	move.l screen1,d0
	move.l screen2,screen1
	move.l d0,screen2
	move.l sprbuff1,d0
	move.l sprbuff2,sprbuff1
	move.l d0,sprbuff2
	move.w #-1,-(sp)
	move.l screen1,-(sp)
	move.l screen2,-(sp)
	move.w #5,-(sp)
	trap #14
	lea 12(sp),sp
	bra.s main_loop
init_koords:
	lea koordtab(pc),a6
	move.w y_max,d6
	sub #14,d6
	move.w #anz_spr-1,d7
	moveq #0,d5
init_loop:
	bsr.s random
	move.b d0,d5
	move.w d5,(a6)+
	move.w #1,(a6)+
	btst #0,d0
	beq.s .right
	move.w #-1,-2(a6)
.right:
	bsr.s random
	move.b d0,d5
	cmp.w d6,d5
	ble.s .in_range
	sub.w #70,d5
.in_range:
	move.w d5,(a6)+
	move.w #1,(a6)+
	btst #0,d0
	beq.s .down
	move.w #-1,-2(a6)
.down:
	dbra d7,init_loop
	move.l #-1,buffer1
	move.l #-1,buffer2
	rts
random:
	move.w #$11,-(sp)
	trap #14
	addq.l #2,sp
	rts
calc_koords:
	lea koordtab(pc),a0
	move.w y_max,d4
	sub #14,d4
	move.w #anz_spr-1,d7
.fly_loop:
	movem.w (a0),d0-d3
	tst d0
	bne.s .mayberight
	moveq #1,d1
	bra.s .calc_x
.mayberight:
	cmp.w #320-15,d0
	bne.s .calc_x
	moveq #-1,d1
.calc_x:
	add d1,d0
	tst d2
	bne.s .maybeup
	moveq #1,d3
	bra.s .calc_y
.maybeup:
	cmp.w d4,d2
	bne.s .calc_y
	moveq #-1,d3
.calc_y:
	add d3,d2
	movem.w d0-d3,(a0)
	lea 8(a0),a0
	dbra d7,.fly_loop
	rts
draw_sprites:
	move.l sprbuff2(pc),a5
	lea koordtab(pc),a4
	move.w #anz_spr-1,d7
.draw_loop:
	move.w (a4),d0
	ext.l d0
	move.w 4(a4),d1
	ext.l d1
	addq #8,a4
	mulu #640,d1 ; 68030 Befehl !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	lsl d0
	add.l d0,d1
	move.l screen2(pc),a6
	add.l d1,a6
	move.l d1,(a5)+
	lea spritegfx(pc),a3
	move.w #15-1,d6
.zeilenloop:
	movem.l (a6),d0-d4/a0-a2
	movem.l d0-d4/a0-a2,(a5)
	lea 32(a5),a5
	move.w #15-1,d5
.pixelloop:
	move.w (a3)+,d0
	beq.s .transparent
	move.w d0,(a6)
.transparent:
	addq #2,a6
	dbra d5,.pixelloop
	lea 640-30(a6),a6
	dbra d6,.zeilenloop
	dbra d7,.draw_loop
	rts
clear_sprites:
	move.l sprbuff2(pc),a5
	tst.l (a5)
	bpl.s .yip_yip
	rts
.yip_yip:
	move.l screen2(pc),a6
	move.w #anz_spr-1,d7
	move.w d7,d6
	ext.l d6
	mulu #484,d6 ; 68030, wenn mehr als 63 Sprites !!!!!!!!!!!!!!!!
	add.l d6,a5
.clear_loop:
	move.l a6,a4
	add.l (a5)+,a4
	moveq #15-1,d6
.zeilenloop:
	movem.l (a5)+,d0-d5/a0-a1
	movem.l d0-d5/a0-a1,(a4)
	lea 640(a4),a4
	dbra d6,.zeilenloop
	lea -484*2(a5),a5
	dbra d7,.clear_loop
	rts
prepare_screens:
	move.l screen1(pc),a0
	move.l screen2(pc),a1
	move.w y_max,d7
.zeilenloop:
	move.w #5-1,d6
	lea colcode(pc),a2
	moveq #0,d0
.balkenloop:
	move.w (a2)+,d1
	move.w #32-1,d5
.lefthalf:
	move.w d0,(a0)+
	move.w d0,(a1)+
	add.w d1,d0
	dbra d5,.lefthalf
	move.w #32-1,d5
.righthalf:
	sub.w d1,d0
	move.w d0,(a0)+
	move.w d0,(a1)+
	dbra d5,.righthalf
	dbra d6,.balkenloop
	dbra d7,.zeilenloop
	rts
	data
fail_text:
	dc.b ' Sorry, your machine is not '
	dc.b ' powerful enough to launch this',0
mausaus: dc.b $12
mausan: dc.b $08
	even
colcode: dc.w $41,$800,$40,1,$840
newcolor: dc.l 0
sprbuff1: dc.l buffer1
sprbuff2: dc.l buffer2
spritegfx:
	dc.w $0000,$0000,$0000,$0000,$0000
	dc.w $4208,$4208,$4208,$4208,$3186
	dc.w $0000,$0000,$0000,$0000,$0000
	dc.w $0000,$0000,$0000,$4208,$630c
	dc.w $8410,$738e,$738e,$630c,$528a
	dc.w $4208,$3186,$0000,$0000,$0000
	dc.w $0000,$0000,$4208,$9492,$a514
	dc.w $a514,$9492,$8410,$738e,$630c
	dc.w $528a,$3186,$3186,$0000,$0000
	dc.w $0000,$4208,$a514,$d69a,$e71c
	dc.w $d69a,$b596,$a514,$8410,$738e
	dc.w $630c,$4208,$3186,$3186,$0000
	dc.w $0000,$8410,$c618,$e71c,$f79e
	dc.w $e71c,$c618,$b596,$9492,$8410
	dc.w $528a,$528a,$3186,$3186,$0000
	dc.w $3186,$9492,$c618,$d69a,$e71c
	dc.w $d69a,$d69a,$b596,$9492,$8410
	dc.w $630c,$528a,$4208,$3186,$1082
	dc.w $528a,$9492,$9492,$c618,$c618
	dc.w $c618,$b596,$9492,$9492,$8410
	dc.w $630c,$528a,$4208,$3186,$2104
	dc.w $528a,$8410,$9492,$b596,$b596
	dc.w $a514,$b596,$9492,$8410,$738e
	dc.w $630c,$528a,$4208,$3186,$1082
	dc.w $630c,$630c,$8410,$9492,$9492
	dc.w $9492,$9492,$8410,$738e,$630c
	dc.w $528a,$528a,$4208,$3186,$1082
	dc.w $3186,$630c,$630c,$8410,$8410
	dc.w $8410,$8410,$738e,$630c,$528a
	dc.w $528a,$4208,$3186,$2104,$1082
	dc.w $2104,$3186,$4208,$528a,$630c
	dc.w $630c,$630c,$528a,$528a,$528a
	dc.w $4208,$3186,$3186,$1082,$0000
	dc.w $0000,$3186,$3186,$4208,$4208
	dc.w $4208,$4208,$4208,$4208,$4208
	dc.w $3186,$3186,$2104,$1082,$0000
	dc.w $0000,$0000,$3186,$3186,$3186
	dc.w $3186,$3186,$3186,$3186,$3186
	dc.w $3186,$2104,$1082,$0000,$0000
	dc.w $0000,$0000,$0000,$2104,$2104
	dc.w $2104,$2104,$2104,$2104,$2104
	dc.w $1082,$1082,$0000,$0000,$0000
	dc.w $0000,$0000,$0000,$0000,$0000
	dc.w $1082,$1082,$1082,$1082,$1082
	dc.w $0000,$0000,$0000,$0000,$0000
	bss
oldstack: 
         ds.l 1
oldmode: 
         ds.w 1
oldphys: 
         ds.l 1
oldlog: 
         ds.l 1
oldcolor: 
         ds.l 1
screen1: 
         ds.l 1
screen2: 
         ds.l 1
y_max: 
         ds.w 1
koordtab: 
         ds.w 4*anz_spr
buffer1: 
         ds.w (16*15+2)*anz_spr
buffer2: 
         ds.w (16*15+2)*anz_spr
	 ds.l 300
newstack: 
         ds.l 1

