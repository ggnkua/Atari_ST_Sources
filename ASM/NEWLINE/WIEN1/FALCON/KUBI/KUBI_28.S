;Werte zur Programmierung der Videohardwareregister:
vertflag        EQU $0100
stmodes         EQU $800
overscan        EQU $40
pal             EQU $20
ntsc            EQU $00
vga             EQU $10
tv              EQU $00
col80           EQU $08
col40           EQU $00
bps16           EQU 4
bps8            EQU 3
bps4            EQU 2
bps2            EQU 1
bps1            EQU 0
getmode         EQU -1

;verschiedene "Modecodes":
my_mode          EQU vertflag|pal|vga|col40|bps16 ;VGA-Monitor

                clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP
                DC.W $A00A

                move.w  #3,-(SP)
                trap    #14
                addq.l  #2,SP
                move.l  D0,old_scr_adr

                move.w  #getmode,-(SP)
                move.w  #88,-(SP)
                trap    #14
                addq.l  #4,SP
                move.w  D0,old_modecode

                move.l  scr_adr(PC),D0
                move.w  #my_mode,D1     ;"True Color"
                bsr   set_scr_adr

                move.l  #320*240/2-1,D0
                movea.l scr_adr(PC),A0
fill_lp         clr.l   (A0)+
                subq.l  #1,D0
                bpl.s   fill_lp

                move.l  $0118.w,old_mkb+2
                move.l  $70.w,old_vbl
                move.l  #vbl,$70.w



wait 
        move.l  scr_adr(PC),log_scr_adr
	move.l	#scr_base,a0
        tst.w	flip
	bne	.0
	add.l  #320*240*2,a0
.0
	move.l	a0,scr_adr
        not    flip

	move.w	#-1,vsync
.vsync	tst.w	vsync
	bne	.vsync

*	add.w	#1,megazoom
*	and.w	#$ff,megazoom

	add.w	#6*4,wave_ptr
	cmp.w	#8646,wave_ptr
	blt	.1
	sub.w	#8646,wave_ptr
.1
	lea	wave,a0
	add.w	wave_ptr,a0
	move.w	(a0)+,xoffset
	move.w	(a0)+,yoffset
	move.w	(a0)+,d0
	lsr.w	#1,d0
	add.w	#127,d0
	move.w	d0,megazoom



	bsr	clrscr2
	bsr	rotate_object
	bsr	show_object

*	bsr	show_raster_time

        cmpi.b  #$39,$FFFFFC02.w ;Auf Space warten
        bne	wait

        move    SR,-(SP)
        move    #$2700,SR
        move.l  old_vbl(PC),$70
        move.l  old_mkb+2(PC),$0118.w
        move    (SP)+,SR

        move.l  old_scr_adr(PC),D0
        move.w  old_modecode(PC),D1
        bsr.s   set_scr_adr

        DC.W $A009
        clr.w   -(SP)
        trap    #1


set_scr_adr
	move.w  D1,-(SP)
	move.w  #3,-(SP)
	move.l  D0,-(SP)
	move.l  D0,-(SP)
	move.w  #5,-(SP)
	trap    #14

        move.w  #$25,-(SP)      ;VSYNC
        trap    #14
        lea     16(SP),SP
        rts

mkb    
	move    #$2500,SR
old_mkb
        jmp     $0

vbl    
scr_change 
        move.b  scr_adr+1(PC),$FFFF8201.w ;HIGH
        move.b  scr_adr+2(PC),$FFFF8203.w ;MID
        move.b  scr_adr+3(PC),$FFFF820d.w ;LOW
	clr.w	vsync
	rte

vsync		dc.w	0
flip		dc.w	0

;-------------------------------------------------
find_z
	lea	object,a0
	move.w	4(a0),d0
	moveq	#0,d1
	move.w	#0,d7
.1	cmp.w	4(a0),d0
	bgt	.2
	move.w	4(a0),d0
	move.w	d7,d1
.2	addq	#6,a0
	addq	#1,d7
	cmp.w	#7,d7
	ble	.1

	add.w	d1,d1
	move.w	d1,d2
	add.w	d1,d1
	add.w	d2,d1
	move.w	d1,last_z
	rts
last_z	dc.w	0
;-------------------------------------------------
show_object
	bsr	find_z

	lea	plane_data,a0
	lea	object,a1
	lea	plane_graph,a2

	moveq	#5,d0
.1
	move.w	last_z,d1
	cmp.w	(a0),d1
	beq	.found
	cmp.w	2(a0),d1
	beq	.found
	cmp.w	4(a0),d1
	beq	.found
	cmp.w	6(a0),d1
	beq	.found
	bra	.not_visible
.found

	movem.l	d0/a0-a2,-(sp)
	bsr	init_side
	movem.l	(sp)+,d0/a0-a2
	movem.l	d0/a0-a2,-(sp)
	move.l	(a2),a1
	bsr	show_side
	movem.l	(sp)+,d0/a0-a2
.not_visible
	addq	#4,a2
	lea	8(a0),a0
	dbf	d0,.1
	rts
;-------------------------------------------------
init_side
	lea	object,a1
	lea	diff_tab,a2

	move.w	2(a0),d7
	move.w	2(a1,d7.w),d0
	muls	megazoom,d0
	asr.w	#8,d0
	add.w	xoffset,d0
	move.w	d0,start_x
	move.w	0(a1,d7.w),d1
	muls	megazoom,d1
	asr.w	#8,d1
	add.w	yoffset,d1
	move.w	d1,start_y

	move.w	2(a0),d7

	move.w	0(a0),d6

	moveq	#0,d0
	moveq	#0,d1
	move.w	(a1,d7.w),d0
	move.w	2(a1,d7.w),d1
	sub.w	(a1,d6.w),d0
	sub.w	2(a1,d6.w),d1
	add.w	#64,d0
	add.w	#64,d1

	tst.w	d1
	bpl	.1
*	move.w	#0,d1
	bra	.2
.1
*	move.w	#64+63,d1
.2

	lsl.l	#7,d1
	add.l	d0,d1
	add.l	d1,d1
	add.l	d1,d1
	move.w	(a2,d1.l),d0
	move.w	2(a2,d1.l),d1

	add.w	#180,d1

	muls	megazoom,d0
	lsr.w	#8,d0

	move.w	d0,len1
	lsl.w	#7,d0
	move.w	d0,zoom1

.axl	cmp.w	#360,d1
	blt	.ax
	sub.w	#360,d1
	bra	.axl
.ax
.axl1	tst.w	d1
	bpl	.ax1
	add.w	#360,d1
	bra	.axl1
.ax1

	lsr.w	#1,d1
	lsl.l	#7,d1
	move.l	d1,grad1

	move.w	4(a0),d6

	moveq	#0,d0
	moveq	#0,d1
	move.w	(a1,d7.w),d0
	move.w	2(a1,d7.w),d1
	sub.w	(a1,d6.w),d0
	sub.w	2(a1,d6.w),d1
	add.w	#64,d0
	add.w	#64,d1

	lsl.l	#7,d1
	add.l	d0,d1
	add.l	d1,d1
	add.l	d1,d1
	move.w	(a2,d1.l),d0
	move.w	2(a2,d1.l),d1

	add.w	#180,d1

	muls	megazoom,d0
	lsr.w	#8,d0
	
	move.w	d0,len2
	lsl.w	#7,d0
	move.w	d0,zoom2

.bxl	cmp.w	#360,d1
	blt	.bx
	sub.w	#360,d1
	bra	.bxl
.bx
.bxl1	tst.w	d1
	bpl	.bx1
	add.w	#360,d1
	bra	.bxl1
.bx1

	lsr.w	#1,d1
	lsl.l	#7,d1
	move.l	d1,grad2


	rts
;-------------------------------------------------
show_side
*	add.l	#128,test
	cmp.l	#128*180,test
	blt	.1
	clr.l	test
.1
	lea	grad_tab,a6
	add.l	grad1,a6

	move.l	log_scr_adr,a0
	move.w	start_y,d1
	add.w	#80,d1
	muls	#640,d1
	add.l	d1,a0
	move.w	start_x,d0
	add.w	#80,d0
	add.w	d0,d0
	add.w	d0,a0
*	lea	side1,a1

	move.w	len1,d0
.y	
	lea	zoom_tab,a3
	add.w	zoom1(PC),a3
	move.w	(a3),d1
	ext.l	d1
	asl.l	#6,d1
	add.l	d1,a1
	add.w	#2,zoom1

	add.w	(a6)+,a0

	lea	grad_tab,a2
	add.l	grad2(PC),a2
	lea	zoom_tab,a3
	add.w	zoom2(PC),a3
	move.l	a0,a5
	move.l	a1,a4

	move.w	len2,d1
.x	move.w	(a4),(a5)
	move.w	(a4),2(a5)
	add.w	(a2)+,a5
	add.w	(a3)+,a4
	dbf	d1,.x
	dbf	d0,.y
	rts

test	dc.l	0

megazoom	dc.w	255
xoffset		dc.w	0
yoffset		dc.w	0

start_x		dc.w	0
start_y		dc.w	0

len1		dc.w	0
zoom1		dc.w	0
grad1		dc.l	0

len2		dc.w	0
zoom2		dc.w	0
grad2		dc.l	0
;-------------------------------------------------
clrscr
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		moveq	#0,d6
		move.l	d0,a1
		move.l	d0,a2
		move.l	d0,a3
		move.l	d0,a4
		move.l	d0,a5
		move.l	d0,a6
                movea.l log_scr_adr(PC),A0
                move.l  #139,D7
.fill_lp
i set 0        
		REPT 5
		movem.l	d0-d6/a1-a6,i(a0)
i set i+52
		ENDR
		lea	640(a0),a0
                dbf	d7,.fill_lp
		rts
;-------------------------------------------------
clrscr2
	move.l	log_scr_adr,a0
	move.w	start_y,d1
	muls	#640,d1
	add.l	d1,a0
	move.w	start_x,d0
	add.w	d0,d0
	add.w	d0,a0

	move.l  a0,$FFFF8A32.w 		; Destination
	move.b  #$0,$FFFF8A3B.w	; Operation-Register
	clr.b   $FFFF8A3D.w		; skew
	move.l  #-1,$FFFF8A28.w		; Endmask
	move.w  #-1,$FFFF8A2C.w		; endmask
	move.w  #2,$FFFF8A2E.w  	; D-Xinc
	move.w  #320+2,$FFFF8A30.w  	; D-Yinc
	move.w  #320/2,$FFFF8A36.w ; Xcnt
	move.w  #135,$FFFF8A38.w ; Ycnt
	move.b  #%11000000,$FFFF8A3C.w
	rts
;-------------------------------------------------
show_raster_time
	moveq	#0,d0
	move.b	$ffff8205.w,d0
	lsl.w	#8,d0
	move.b	$ffff8207.w,d0
	lsl.l	#8,d0
	move.b	$ffff8209.w,d0

	move.l	d0,a0
	moveq	#-1,d1
	REPT 20
	move.w	d1,(a0)+
	ENDR
	move.w	#30,d1
.1	dbf	d1,.1
	move.l	d0,a0
	moveq	#0,d1
	REPT 20
	move.w	d1,(a0)+
	ENDR
	rts
;-------------------------------------------------
rotate_object
	add.w	#2*2,alpha
	cmp.w	#360*2,alpha
	blt	.a1
	clr.w	alpha
.a1
	add.w	#4*2,beta
	cmp.w	#360*2,beta
	blt	.b1
	clr.w	beta
.b1
	add.w	#6*2,gamma
	cmp.w	#360*2,gamma
	blt	.c1
	clr.w	gamma
.c1

	lea	obj_data,a0
	lea	object,a1
	lea	sinus,a2
	add.w	alpha,a2
	lea	sinus,a3
	add.w	beta,a3
	lea	sinus,a4
	add.w	gamma,a4

	moveq	#7,d7
.1
	movem.w	(a0)+,d0-d2

	move.w	d0,d3
	move.w	d1,d4
	muls	180(a2),d0 ; sin(x1)
	muls	180(a2),d1 ; cos(y1) 
	muls	(a2),d3    ; sin(x2)
	muls	(a2),d4    ; cos(y2)
	sub.l	d4,d0	   ; s(x1)-c(y2)
	add.l	d3,d1      ; c(x1)+s(y2)
	asl.l	#2,d0
	asl.l	#2,d1
	swap	d0
	swap	d1

	move.w	d1,d3
	move.w	d2,d4
	muls	180(a3),d1 ; sin(x1)
	muls	180(a3),d2 ; cos(y1) 
	muls	(a3),d3    ; sin(x2)
	muls	(a3),d4    ; cos(y2)
	sub.l	d4,d1	   ; s(x1)-c(y2)
	add.l	d3,d2      ; c(x1)+s(y2)
	asl.l	#2,d1
	asl.l	#2,d2
	swap	d1
	swap	d2

	move.w	d2,d3
	move.w	d0,d4
	muls	180(a4),d2 ; sin(x1)
	muls	180(a4),d0 ; cos(y1) 
	muls	(a4),d3    ; sin(x2)
	muls	(a4),d4    ; cos(y2)
	sub.l	d4,d2	   ; s(x1)-c(y2)
	add.l	d3,d0      ; c(x1)+s(y2)
	asl.l	#2,d2
	asl.l	#2,d0
	swap	d2
	swap	d0

	movem.w	d0-d2,(a1)
	lea	6(a1),a1
	dbf	d7,.1
	rts

alpha		dc.w	0
beta		dc.w	0
gamma		dc.w	0
;-------------------------------------------------

old_modecode    ds.w	1
old_vbl         ds.l	1
old_scr_adr     dc.l	scr_base
log_scr_adr     dc.l	scr_base
scr_adr         dc.l	scr_base

plane_graph	dc.l	side1,side1,side1
		dc.l	side2,side2,side2

plane_data	dc.w	0*6,1*6,2*6,3*6
		dc.w	0*6,1*6,5*6,4*6
		dc.w	0*6,4*6,7*6,3*6
		dc.w	6*6,5*6,1*6,2*6
		dc.w	6*6,7*6,3*6,2*6
		dc.w	4*6,5*6,6*6,7*6

obj_data
		dc.w	-30,-30,-30
		dc.w	-30,30,-30
		dc.w	30,30,-30
		dc.w	30,-30,-30

		dc.w	-30,-30,30
		dc.w	-30,30,30
		dc.w	30,30,30
		dc.w	30,-30,30


side1		incbin	pic1.tcs
side2		incbin	test2.tcs

grad_tab	incbin	grad.tab
zoom_tab	incbin	zoom.tab
diff_tab	incbin	diff.tab

wave_ptr	dc.w	0
wave		incbin	wave.dat

sinus		incbin	sinus.tab



        section bss

object		ds.w	3*8

dummy		ds.l	200000

scr_base	ds.w	320*240*2
