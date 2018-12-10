**************
* Demot till *
* Crystalics *
* partydemo  *
**************
rader	equ	100
k	equ	64*160
l	equ	128*160
m	equ	192*160

	section	text
	
	move.l	4(sp),a6
	move.l	12(a6),d0
	add.l	20(a6),d0
	add.l	28(a6),d0
	add.l	#4000,d0
	add.l	#256,d0
	move.l	a6,d1
	add.l	d0,d1
	bclr	#0,d1
	move.l	d1,sp
	move.l	d0,-(sp)
	move.l	a6,-(sp)
	pea	$4a0000
	trap	#1
	lea	12(sp),sp

	jmp	h”vve

***********
* init    *
***********
init
*	clr.l	-(sp)
*	move.w	#$20,-(sp)
*	trap	#1
*	addq.l	#6,sp
*	move.l	d0,ustk

	
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldphys
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,oldrez
	
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,savepal
	
	move.w	#0,-(sp)
	pea	screen
	pea	-1
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	moveq	#1,d0
	jsr	music
	
	move.l	#nysin,nysinad
	move.l	#nysin2,nysinad2
	add.l	#2*180,nysinad2
	move.l	#distlist+rader-1,distad

	move.w	#1,x_rot_inc
	move.w	#0,y_rot_inc
	move.w	#4,z_rot_inc
	move.w	#44,scale_factor
	move.w	#4-1,num_points
	move.w	#2,num_surf
	move.w	#4-1,num_surf_points

	move.l	#screen,scrad
	move.l	#text,textad
	
	rts

************
* fix poly *
************
init_poly
	
	lea	parameters,a0
	jsr	polygon_mupp
	
	move.l	a0,variables
	move.l	a1,hoppa
	move.l	a2,hoppa3
	move.l	a3,hoppa4
	
	rts

*************
* Init bild *
*************
init_bild
	lea	$ffff8240.w,a0
	move.l	#7,d0
sv„rta	move.l	#0,(a0)+
	dbf	d0,sv„rta
	
	lea	bild+34,a0
	move.l	#screen,a1
	move.l	#7999,d0
pic_rit	move.l	(a0)+,(a1)+	
	dbf	d0,pic_rit
	
	movem.l	bild+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	rts	

***************
* precalc sin *	
***************
presin
	lea	sin_tab,a0
	lea	nysin,a1
	move.w	#180-1,d1
presin1	moveq	#0,d0
	move.w	(a0),d0
	addq.l	#4,a0
	add.w	#16384,d0
	divu	#331,d0
	mulu	#160,d0
	move.w	d0,(a1)+
	dbf	d1,presin1
	lea	sin_tab,a0
	move.w	#rader-1-1,d1
presin2	moveq	#0,d0
	move.w	(a0),d0
	addq.l	#4,a0
	add.w	#16384,d0
	divu	#331,d0
	mulu	#160,d0
	move.w	d0,(a1)+
	dbf	d1,presin2
	move.w	#-1,(a1)
	
	lea	nysin2,a1
	move.w	#-1,(a1)+
	move.w	#4-1,d2
presin4	lea	sin_tab,a0
	move.w	#90-1,d1
presin3	moveq	#0,d0
	move.w	(a0),d0
	addq.l	#8,a0
	add.w	#16384,d0
	divu	#331,d0
	mulu	#160,d0
	move.w	d0,(a1)+
	dbf	d1,presin3
	dbf	d2,presin4
	
	rts
	
************
* init mfp *
************
initmfp
	move.b	$fffffa07.w,mfp
	move.b	$fffffa09.w,mfp+1
	move.b	$fffffa13.w,mfp+2
	move.b	$fffffa1b.w,mfp+3
	move.b	$fffffa21.w,mfp+4
	move.l	$70.w,svbi
	move.l	$120.w,shbi
	
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	
	move.w	#$2700,sr
	move.b	#1,$fffffa07.w
	move.b	#0,$fffffa09.w
	move.b	#1,$fffffa13.w
	bclr	#3,$fffffa17.w
	move.b	#8,$fffffa1b.w
	move.b	#53,$fffffa21.w
	move.l	#vbi,$70.w
	move.l	#hbi,$120.w
	move.w	#$2300,sr
	clr.b	$ffff820f.w
	rts
	
****************
* h”vve        *
****************
h”vve
	jsr	init
	jsr	init_poly
	jsr	presin
	jsr	init_bild
	jsr	initmfp
h”vve2
	jsr	r„koblit
	jsr	calculate_3d
	jsr	vrid†skrik
	jsr	erase_screen
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	music+8
	movem.l	(sp)+,d0-d7/a0-a6
	

vsync	tst.w	vflag
	beq.s	vsync
	clr.w	vflag
	
	cmp.b	#57,$fffffc02.w
	bne.s	h”vve2
	
	jmp	end
	
*************
* vbi o hbi *
*************
vbi
	movem.l	bild+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	move.w	#1,vflag
	clr.w	ccount
	clr.b	$fffffa1b.w
	move.b	#53,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#hbi,$120.w
	move.l	distad,a0
	cmp.b	#-1,(a0)
	bne.s	vbihupp
	lea	distlist+rader+1,a0
vbihupp	sub.l	#rader+1,a0
	move.b	(a0)+,$ffff8265.w
	move.l	a0,distad
	clr.b	$ffff8265.w
	clr.w	$ffff820e.w
	move.l	#collist,collad
	
	rte
	
********
hbi
	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.l	#hbi_2,$120.w
	move.b	#8,$fffffa1b.w
	movem.l	d0-d7,-(sp)
	movem.l	sbild+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(sp)+,d0-d7
	clr.w	ccount
	rte
********
hbi_2
	move.l	a0,-(sp)
	move.l	distad,a0
	move.b	(a0)+,$ffff8265.w
	move.l	a0,distad
	move.l	(sp)+,a0

	addq.w	#1,ccount
	cmp.w	#rader+1,ccount
	beq.s	hbihupp
	rte
	
hbihupp
	clr.b	$fffffa1b.w
	move.b	#8,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#hbi_3,$120.w
	movem.l	d0-d7,-(sp)
	movem.l	bild+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(sp)+,d0-d7
	clr.b	$ffff8265.w
	
	rte
	
********
hbi_3
	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#hbi_4,$120.w
	clr.w	ccount
	rte
	
********
hbi_4
	move.l	a0,-(sp)
	move.l	collad,a0
	move.w	(a0)+,$ffff8240.w
	move.w	78(a0),$ffff8242.w
	move.l	a0,collad
	move.l	(sp)+,a0
	addq.w	#1,ccount
	cmp.w	#32,ccount
	bne.s	forts
	clr.b	$fffffa1b.w
	jsr	make_surf
forts
	rte
	
****************
* blitta slime *
****************
r„koblit
	lea	$ffff8a00.w,a0
	move.w	#2,$20(a0)
	move.w	#2+64,$22(a0)
	move.l	#sbild+34+32,$24(a0)
	move.w	#$ffff,$28(a0)
	move.w	#$ffff,$2a(a0)
	move.w	#$ffff,$2c(a0)
	move.w	#2,$2e(a0)
	move.w	#2+64+8,$30(a0)
	move.w	#80-32,$36(a0)
	move.w	#1,$38(a0)
	move.l	#$02034000,$3a(a0)

	move.l	nysinad,a1
	move.l	nysinad2,a2
	move.l	#screen+32+54*160,$ffff8a32.w
	move.w	#rader-1,d1
r„ko1	lea	sbild+34+32,a0
	add.w	(a1)+,a0
	add.w	(a2)+,a0
	move.l	a0,$ffff8a24.w
	move.w	#1,$ffff8a38.w
	move.b	#64,$ffff8a3c.w
	or.b	#$80,$ffff8a3c.w
	nop
	dbf	d1,r„ko1
	cmp.w	#-1,(a1)
	bne.s	r„kohupp
	lea	nysin+2*rader-2,a1
r„kohupp	sub.l	#2*rader-2,a1
	move.l	a1,nysinad
	
	sub.l	#2*rader+2,a2
	cmp.w	#-1,(a2)
	bne.s	r„kohupp2
	lea	nysin2+2*180,a2
r„kohupp2	move.l	a2,nysinad2
	rts
	
**********************
* Rita upp scrollern *
**********************
vrid†skrik
	add.w	#1,textcount
	btst	#0,textcount+1
	beq.s	vrid_mer
	rts
vrid_mer
	cmp.w	#128,textcount
	blt.s	„nnu_mer
	clr.w	textcount
	add.l	#10,textad
	move.l	textad,a0
	tst.b	(a0)
	bne.s	„nnu_mer
	move.l	#text,textad
„nnu_mer
	move.w	textcount,d2
	mulu	#80,d2
	move.l	textad,a2
	lea	screen+62*160+101*168,a0
	moveq	#10-1,d1
tumskruv
	lea	font+34,a1
	add.w	d2,a1
	moveq	#0,d0
	move.b	(a2)+,d0
	sub.w	#32,d0
	lsl.w	#1,d0
	lea	offs,a3
	add.w	(a3,d0.w),a1
	
	move.w	1*160(a1),(a0)
	move.w	1*160+8(a1),8(a0)
	move.w	3*160(a1),1*160(a0)
	move.w	3*160+8(a1),1*160+8(a0)
	move.w	5*160(a1),2*160(a0)
	move.w	5*160+8(a1),2*160+8(a0)
	move.w	7*160(a1),3*160(a0)
	move.w	7*160+8(a1),3*160+8(a0)
	move.w	8*160(a1),4*160(a0)
	move.w	8*160+8(a1),4*160+8(a0)
	move.w	9*160(a1),5*160(a0)
	move.w	9*160+8(a1),5*160+8(a0)
	move.w	10*160(a1),6*160(a0)
	move.w	10*160+8(a1),6*160+8(a0)
	move.w	11*160(a1),7*160(a0)
	move.w	11*160+8(a1),7*160+8(a0)
	move.w	12*160(a1),8*160(a0)
	move.w	12*160+8(a1),8*160+8(a0)
	move.w	13*160(a1),9*160(a0)
	move.w	13*160+8(a1),9*160+8(a0)
	move.w	13*160(a1),10*160(a0)
	move.w	13*160+8(a1),10*160+8(a0)
	move.w	14*160(a1),11*160(a0)
	move.w	14*160+8(a1),11*160+8(a0)
	move.w	14*160(a1),12*160(a0)
	move.w	14*160+8(a1),12*160+8(a0)
	move.w	15*160(a1),13*160(a0)
	move.w	15*160+8(a1),13*160+8(a0)
	move.w	15*160(a1),14*160(a0)
	move.w	15*160+8(a1),14*160+8(a0)
	move.w	16*160(a1),15*160(a0)
	move.w	16*160+8(a1),15*160+8(a0)
	move.w	16*160(a1),16*160(a0)
	move.w	16*160+8(a1),16*160+8(a0)
	move.w	17*160(a1),17*160(a0)
	move.w	17*160+8(a1),17*160+8(a0)
	move.w	17*160(a1),18*160(a0)
	move.w	17*160+8(a1),18*160+8(a0)
	move.w	18*160(a1),19*160(a0)
	move.w	18*160+8(a1),19*160+8(a0)
	move.w	18*160(a1),20*160(a0)
	move.w	18*160+8(a1),20*160+8(a0)
	move.w	19*160(a1),21*160(a0)
	move.w	19*160+8(a1),21*160+8(a0)
	move.w	19*160(a1),22*160(a0)
	move.w	19*160+8(a1),22*160+8(a0)
	move.w	20*160(a1),23*160(a0)
	move.w	20*160+8(a1),23*160+8(a0)
	move.w	21*160(a1),24*160(a0)
	move.w	21*160+8(a1),24*160+8(a0)
	move.w	22*160(a1),25*160(a0)
	move.w	22*160+8(a1),25*160+8(a0)
	move.w	23*160(a1),26*160(a0)
	move.w	23*160+8(a1),26*160+8(a0)
	move.w	24*160(a1),27*160(a0)
	move.w	24*160+8(a1),27*160+8(a0)
	move.w	25*160(a1),28*160(a0)
	move.w	25*160+8(a1),28*160+8(a0)
	move.w	27*160(a1),29*160(a0)
	move.w	27*160+8(a1),29*160+8(a0)
	move.w	29*160(a1),30*160(a0)
	move.w	29*160+8(a1),30*160+8(a0)
	move.w	31*160(a1),31*160(a0)
	move.w	31*160+8(a1),31*160+8(a0)
	lea	16(a0),a0
	dbf	d1,tumskruv
	
	rts
	
**********************
* draw and hide poly *
**********************
make_surf
	move.w	num_surf,count_surf

surf_loop
	lea	points_buffer,a0
	lea	conect_list,a1
	lea	poly_buffer,a2
	
	add.w	conect_count,a1
	add.w	#8,conect_count

	moveq	#0,d3
	move.w	num_surf_points,d3

get_right_koord
	move.w	(a1)+,d0
	move.w	0(a0,d0.w),d1
	move.w	2(a0,d0.w),d2
	add.w	xorigo,d1
	add.w	yorigo,d2
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	dbf	d3,get_right_koord

	jsr	draw_poly

	sub.w	#1,count_surf
	tst.w	count_surf
	bne	surf_loop

	move.w	#0,conect_count
	move.w	#0,prefs_count
	rts

******************
* rita polygonen *
******************
draw_poly

	lea	poly_buffer,a1
	lea	prefs,a2
	add.w	prefs_count,a2
	add.w	#2,prefs_count
	
	move.l	variables,a0
	move.w	#%0000001100000110,(a0)+
	move.w	(a2),(a0)+

	REPT	4
	move.w	(a1)+,(a0)+
	move.w	(a1)+,(a0)+
	ENDR
	
	move.l	hoppa,a0
	jsr	(a0)

	rts

****************
* erase screen *
****************
erase_screen
	moveq	#0,d0
	move.l	scrad,a0
	rept	52
	move.l	d0,(a0)
	move.l	d0,8(a0)
	move.l	d0,16(a0)
	move.l	d0,24(a0)
	lea	160(a0),a0
	endr
	rts

****************
* 3d calcs     *
****************
calculate_3d
	moveq	#0,d0		
	move.w	x_rotate_angle,d0		; inca xyz
	add.w	x_rot_inc,d0			; conterna
	cmp.w	#360,d0
	blo.s	x_ej_360
	moveq	#0,d0
x_ej_360	move.w	d0,x_rotate_angle

	moveq	#0,d0		
	move.w	y_rotate_angle,d0
	add.w	y_rot_inc,d0
	cmp.w	#360,d0
	blo.s	y_ej_360
	moveq	#0,d0
y_ej_360	move.w	d0,y_rotate_angle

	moveq	#0,d0		
	move.w	z_rotate_angle,d0
	add.w	z_rot_inc,d0
	cmp.w	#360,d0
	blo.s	z_ej_360
	moveq	#0,d0
z_ej_360	move.w	d0,z_rotate_angle

	lea     sin_tab,a1       ; sin
        lea     180(a1),a2              ; cos

        lea     koords,a0	  ; alla objekt i en lista
        lea     points_buffer,a6    ; buffert med kords

        move.w  x_rotate_angle,d4
        add.w   d4,d4                   ; * 2 (for sin_tab)
        move.w  y_rotate_angle,d5
        add.w   d5,d5                   ; * 2 (for sin_tab)
        move.w  z_rotate_angle,d6
        add.w   d6,d6                   ; * 2 (for sin_tab)

        bsr     xyz_rotate		  ; 3D count
        bsr     projection		  ; xyz=xy+bitplan
        bsr     scaling			  ; skala (zoom)
        rts

**********************
* 3d rotering        *
**********************
xyz_rotate
        move.w   num_points,a5	  ; antal h”rn att rotera 
rotate_lp
        move.w    (a0)+,d0                ; get x
        move.w    d0,d1
        move.w    0(a1,d6.w),d7           ; get sin value
        muls      d7,d0                   ; x * sin
        move.w    (a0)+,d2                ; get y
        move.w    d2,d3
        muls      d7,d2                   ; y * sin
        move.w    0(a2,d6.w),d7           ; get cos value
        muls      d7,d1                   ; x * cos
        muls      d7,d3                   ; y * cos
        sub.l     d2,d1                   ; xr = x cos - y sin
        add.l     d0,d3                   ; yr = y cos + x sin
        swap      d1                      ; going to /16384
        rol.l     #2,d1
        swap      d3
        rol.l     #2,d3
        move.w    d1,(a6)+                ; save x
        move.w    d3,d0                   ; y
        move.w    d0,d1
        move.w    0(a1,d4.w),d7           ; get sin value
        muls      d7,d0                   ; y * sin
        move.w    (a0)+,d2                ; get z
        move.w    d2,d3
        muls      d7,d2                   ; z * sin
        move.w    0(a2,d4.w),d7           ; get cos value
        muls      d7,d1                   ; y * cos
        muls      d7,d3                   ; z * cos
        add.l     d2,d1                   ; yr = y cos + z sin
        sub.l     d0,d3                   ; zr = z cos - y sin
        swap      d1                      ; going to /16384
        rol.l     #2,d1
        swap      d3
        rol.l     #2,d3
        move.w    d1,(a6)+                ; save y
        subq.w    #4,a6                   ; points on x
        move.w    (a6),d0                 ; get x
        move.w    d0,d1
        move.w    0(a1,d5.w),d7           ; get sin value
        muls      d7,d0                   ; x * sin
        move.w    d3,d2
        muls      d7,d2                   ; z * sin
        move.w    0(a2,d5.w),d7           ; get cos value
        muls      d7,d1                   ; x * cos
        muls      d7,d3                   ; z * cos
        sub.l     d2,d1                   ; xr = x cos - z sin
        add.l     d0,d3                   ; zr = z cos + x sin
        swap      d1                      ; going to /16384
        rol.l     #2,d1
        swap      d3
        rol.l     #2,d3
        move.w    d1,(a6)+                ; save x (?)
        addq.w    #2,a6
        move.w    d3,(a6)+                ; save z
        subq.w    #1,a5
        cmpa.w    #-1,a5
        bne       rotate_lp
        rts

***********************
* g”r om till x och y *
***********************

projection
        lea       points_buffer,a0	  ; kordinater
        move.l   a0,a1			  ; spara kordinater
        lea       projection_tab,a2	  
        move.w    num_points,d6
proj_it
        move.w    (a0)+,d0                ; x
        move.w    (a0)+,d1                ; y
        move.w    (a0)+,d2                ; z
        asr.w     #1,d2
        add.w     #60,d2
	add.w	  d2,d2
        move.w    0(a2,d2.w),d7           ; get sin value
        sub.w     #16384,d7
        lsr.w     #1,d7
        muls      d7,d0
        muls      d7,d1
        swap      d0                      ; going to /16384
        rol.l     #3,d0
        swap      d1
        rol.l     #3,d1
        move.w    d0,(a1)+
        move.w    d1,(a1)+
        add.w    #2,(a1)+
        dbra      d6,proj_it
        rts

*******************
* scalning        *
*******************
scaling
        lea       points_buffer,a0     ; kordinater
        move.l   a0,a1
        lea       neg_sin_tab,a2
        move.w    scale_factor,d3	   ; storlek
        add.w     d3,d3
        move.w    num_points,d6       ; antal kordinater
scale_it
        move.w    (a0)+,d0                ; x
        move.w    (a0)+,d1                ; y
        addq.w    #2,a0			  ; f”rbi bitplans offset
        move.w    0(a2,d3.w),d7           ; get sin value
        add.w     #16384,d7
        lsr.w     #1,d7
        muls      d7,d0
        muls      d7,d1
        swap      d0                      ; going to /16384
        rol.l     #2,d0
        swap      d1
        rol.l     #2,d1
        move.w    d0,(a1)+		  ; nya x
        move.w    d1,(a1)+		  ; nya y
        dbra      d6,scale_it
        rts

************
* endif    *	
************
end
	moveq	#0,d0
	jsr	music
	
	movem.l	savepal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	move.w	#$2700,sr
	move.b	mfp,$fffffa07.w
	move.b	mfp+1,$fffffa09.w
	move.b	mfp+2,$fffffa13.w
	bset	#3,$fffffa17.w
	move.b	mfp+3,$fffffa1b.w
	move.b	mfp+4,$fffffa21.w
	move.l	svbi,$70.w
	move.l	shbi,$120.w
	move.w	#$2300,sr
	clr.b	$ffff8265.w
	
	move.w	oldrez,-(sp)
	move.l	oldphys,-(sp)
	pea	-1
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
*	move.l	ustk,-(sp)
*	move.w	#$20,-(sp)
*	trap	#1
*	addq.l	#6,sp
	
*	clr.w	-(sp)
*	trap	#1
	rts    	
******************************
	section	data

scale_factor 		dc.w 	25+10+6+2
num_points   		dc.w 	0

points_buffer		ds.w 	20*3
poly_buffer		ds.w	20*8

x_rotate_angle		dc.w 	0
y_rotate_angle		dc.w 	0
z_rotate_angle		dc.w 	0

xorigo			dc.w	32
yorigo			dc.w	25

x_rot_inc     		dc.w 	0
y_rot_inc     		dc.w 	0
z_rot_inc     		dc.w 	0

		even

koords		dc.w	-50,-50,0
		dc.w	-50,50,0
		dc.w	50,50,0
		dc.w	50,-50,0
		
conect_list	dc.w	0,4,8,12
		dc.w	12,8,4,0

prefs	
		dc.w	%0000000100000000
		dc.w	%0000001000000000

sin_tab
              dc.w 0,286,572,857,1143,1428,1713,1997,2280
              dc.w 2563,2845,3126,3406,3686,3964,4240,4516
              dc.w 4790,5063,5334,5604,5872,6138,6402,6664
              dc.w 6924,7182,7438,7692,7943,8192,8438,8682
              dc.w 8923,9162,9397,9630,9860,10087,10311,10531
              dc.w 10749,10963,11174,11381,11585,11786,11982,12176
              dc.w 12365,12551,12733,12911,13085,13255,13421,13583
              dc.w 13741,13894,14044,14189,14330,14466,14598,14726
              dc.w 14849,14962,15082,15191,15296,15396,15491,15582
              dc.w 15668,15749,15826,15897,15964,16026,16083,16135
              dc.w 16182,16225,16262,16294,16322,16344,16362,16374
              dc.w 16382
cos_tab
	      dc.w 16384
              dc.w 16382,16374,16362,16344,16322,16294,16262,16225
              dc.w 16182
              dc.w 16135,16083,16026,15964,15897,15826,15749,15668
              dc.w 15582,15449,15396,15296,15191,15082,14962,14849
              dc.w 14726,14598,14466,14330,14189,14044,13894,13741
              dc.w 13583,13421,13255,13085,12911,12733,12551,12365
              dc.w 12176,11982,11786,11585,11381,11174,10963,10749
              dc.w 10531,10311,10087,9860,9630,9397,9162,8923
              dc.w 8682,8438,8192,7943,7692,7438,7182,6924
              dc.w 6664,6402,6138,5872,5604,5334,5063,4790
              dc.w 4516,4240,3964,3686,3406,3126,2845,2563
              dc.w 2280,1997,1713,1428,1143,857,572,286,0

neg_sin_tab
              dc.w -286,-572,-857,-1143,-1428,-1713,-1997,-2280
              dc.w -2563,-2845,-3126,-3406,-3686,-3964,-4240,-4516
              dc.w -4790,-5063,-5334,-5604,-5872,-6138,-6402,-6664
              dc.w -6924,-7182,-7438,-7692,-7943,-8192,-8438,-8682
              dc.w -8923,-9162,-9397,-9630,-9860,-10087,-10311,-10531
              dc.w -10749,-10963,-11174,-11381,-11585,-11786,-11982,-12176
              dc.w -12365,-12551,-12733,-12911,-13085,-13255,-13421,-13583
              dc.w -13741,-13894,-14044,-14189,-14330,-14466,-14598,-14726
              dc.w -14849,-14962,-15082,-15191,-15296,-15396,-15491,-15582
              dc.w -15668,-15749,-15826,-15897,-15964,-16026,-16083,-16135
              dc.w -16182,-16225,-16262,-16294,-16322,-16344,-16362,-16374
              dc.w -16382,-16384

              dc.w -16382,-16374,-16362,-16344,-16322,-16294,-16262,-16225
              dc.w -16182
              dc.w -16135,-16083,-16026,-15964,-15897,-15826,-15749,-15668
              dc.w -15582,-15449,-15396,-15296,-15191,-15082,-14962,-14849
              dc.w -14726,-14598,-14466,-14330,-14189,-14044,-13894,-13741
              dc.w -13583,-13421,-13255,-13085,-12911,-12733,-12551,-12365
              dc.w -12176,-11982,-11786,-11585,-11381,-11174,-10963,-10749
              dc.w -10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
              dc.w -8682,-8438,-8192,-7943,-7692,-7438,-7182,-6924
              dc.w -6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
              dc.w -4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
              dc.w -2280,-1997,-1713,-1428,-1143,-857,-572,-286,0

              dc.w 0,286,572,857,1143,1428,1713,1997,2280
              dc.w 2563,2845,3126,3406,3686,3964,4240,4516
              dc.w 4790,5063,5334,5604,5872,6138,6402,6664
              dc.w 6924,7182,7438,7692,7943,8192,8438,8682
              dc.w 8923,9162,9397,9630,9860,10087,10311,10531
              dc.w 10749,10963,11174,11381,11585,11786,11982,12176
              dc.w 12365,12551,12733,12911,13085,13255,13421,13583
              dc.w 13741,13894,14044,14189,14330,14466,14598,14726
              dc.w 14849,14962,15082,15191,15296,15396,15491,15582
              dc.w 15668,15749,15826,15897,15964,16026,16083,16135
              dc.w 16182,16225,16262,16294,16322,16344,16362,16374
              dc.w 16382

projection_tab
              dc.w -16382,-16374,-16362,-16344,-16322,-16294,-16262,-16225
              dc.w -16182
              dc.w -16135,-16083,-16026,-15964,-15897,-15826,-15749,-15668
              dc.w -15582,-15449,-15396,-15296,-15191,-15082,-14962,-14849
              dc.w -14726,-14598,-14466,-14330,-14189,-14044,-13894,-13741
              dc.w -13583,-13421,-13255,-13085,-12911,-12733,-12551,-12365
              dc.w -12176,-11982,-11786,-11585,-11381,-11174,-10963,-10749
              dc.w -10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
              dc.w -8682,-8438,-8192,-7943,-7692,-7438,-7182,-6924
              dc.w -6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
              dc.w -4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
              dc.w -2280,-1997,-1713,-1428,-1143,-857,-572,-286,0
              ds.w 10
              even
distad	dc.l	0
distlist
	rept	5
	dc.b	1,1,1,2,2,2,2,3,3,3,4,4,5,6,7,8,8,9,9,9,10,10,10,10,11,11,11
	dc.b	11,11,11,10,10,10,10,9,9,9,8,8,7,6,5,4,4,3,3,3,2,2,2,2,1,1,1
	endr
	dc.b	1,1,1,2,2,2,2,3,3,3,4,4,5,6,7,8,8,9,9,9,10,10,10,10,11,11,11
	dc.b	11,11,11,10,10,10,10,9,9,9,8,8,7,6,5,4,4,3
	dc.b	-1
	EVEN

offs	dc.w	m+0,l+128,0,0,0
	dc.w	0,0,0,0,0
	dc.w	0,0,l+112,0,l+96
	dc.w	0,0,0,0,0
	dc.w	0,0,0,0,0
	dc.w	0,0,0,0,0
	dc.w	0,l+144,0,0,16
	dc.w	32,48,64,80,96
	dc.w	112,128,144,k+0,k+16
	dc.w	k+32,k+48,k+64,k+80,k+96
	dc.w	k+112,k+128,k+144,l+0,l+16
	dc.w	l+32,l+48,l+64,l+80
	
collist
	dc.w	$000,$99a,$223,$223,$aab,$aab,$334,$334,$bbc,$bbc,$445,$445,$ccd,$ccd,$556,$556
	dc.w	$556,$556,$ccd,$ccd,$445,$445,$bbc,$bbc,$334,$334,$aab,$aab,$223,$223,$99a,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	
	dc.w	$002,$002,$80a,$80a,$803,$803,$10b,$10b,$904,$904,$20c,$20c,$a05,$a05,$a0d,$a0d
	dc.w	$a0d,$a0d,$a05,$a05,$20c,$20c,$904,$904,$10b,$10b,$803,$803,$80a,$80a,$002,$002
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	
text
	dc.b	"          "," WELCOME  ","  TO OUR  "
	dc.b	" PART IN  ","THIS  NEAT","   DEMO   "
	dc.b	"          "," CODE  BY "," PQ  LEAR "
	dc.b	"   AND    ","   EMPA   ","          "
	dc.b	"GRAPHIX BY","   EMPA   ","          "
	dc.b	"   SOME   ","  BORING  ","  GREETS  "
	dc.b	"          ","ANATOMICA ","CRYSTALIC "
	dc.b	" S.O.T.E  ","  REWARD  ","   ICE    "
	dc.b	" IMAGINA  "
	dc.b	"  UNIQUE  ","AND YOU!!!","          "
	dc.b	"  WE ARE  ","JUST ABOUT","TO  FINISH"
	dc.b	" OUR NEW  ","MULTIPART ","   DEMO   "
	dc.b	"  CALLED  ","  LETHAL  ","  TRASH   "
	dc.b	"          ","          ","          "
	dc.b	" POLYROUT "," BY OMEGA ","          "
	dc.b	"          "," TIME TO  "," GO  HOME "
	dc.b	"  NOW...  ","          ","   BYE!   "
	dc.b	"          ","          ","          ",0
	EVEN
	
music		incbin	a:\zeal_scr\no_sheep.mus
sbild		incbin	a:\zeal_scr\biiig3.pi1
bild		incbin	a:\zeal_scr\spendura.pi1
font		incbin	a:\zeal_scr\font.pi1
		ds.b	88*160
		
screen		dcb.b	200*168,0

variables		dc.l	0
hoppa			dc.l	0
hoppa3			dc.l	0
hoppa4			dc.l	0

parameters
			dc.w	0
			dc.l	buffert
			dc.l	scrad
			dc.w	0,0,-1000
			dc.w	64,53,1000
		
polygon_mupp
	incbin		'a:\zeal_scr\xope2_01.img'

	section	bss
		ds.l	4096
	
buffert		ds.l	131*256
savepal		ds.w	16
ustk		ds.l	1
oldphys		ds.l	1
oldrez		ds.l	1
num_surf		ds.w	1
prefs_count	ds.w	1
conect_count	ds.w	1
count_surf	ds.w	1
num_surf_points	ds.w	1
vflag		ds.w	1
nysin		ds.w	360+rader
nysin2		ds.w	360+1
nysinad		ds.l	1
scrad		ds.l	1
nysinad2		ds.l	1
svbi		ds.l	1
shbi		ds.l	1
mfp		ds.b	10
ccount		ds.w	1
collad		ds.l	1
textad		ds.l	1
textcount		ds.w	1
sync_it		ds.b	1
EVEN
