debug	equ 0
color	equ 1
z_tri	equ 0
z_value	equ 0
clipy	equ 239
	
	jmp	start
	include	macro&co.s
start
	move.l	a0,ecran
	move.l	a1,ecran+4
	bsr prepart_table_remplissage
vbl
	vsync
	move.l ecran(pc),a0
	moveq 	#0,d1
	move.w #clipy,d0
cls_screen
s	set	10
	rept	384/16
	move.w d1,s(a0)
s	set	s+16
	endr
	lea	384(a0),a0
	dbra d0,cls_screen
	bsr	anim_surface
	bsr rotationx_y_z
	bsr affiche_surface
	lea ecran(pc),a0
	move.l (a0)+,d0
	move.l (a0),-(a0)
	move.l d0,4(a0)
	ifeq	debug
	aset_screen	4(a0)
	endc
	tst	ptr_anim
	bpl	vbl
	rts

ptr_anim	dc	50*4
	
anim_surface
	add	#4,z_angle
	and	#1023,z_angle
	sub	#100,z_observateur
	cmp.w	#800,z_observateur
	bgt.s	.sau
	move	#-1,ptr_anim
.sau
	rts


rotationx_y_z
	lea save_matrice(pc),a0
	lea extend_register(pc),a3
	lea cos_table(pc),a1
	lea sin_table(pc),a2
	lea x_angle(pc),a4
	
	move.w (a4)+,d0
	move.w (a4)+,d2
	move.w (a4)+,d4
	move.w (a2,d0),d1 ;sina
	move.w (a1,d0),d0 ;cosa
	move.w (a2,d2),d3 ;sinb
	move.w (a1,d2),d2 ;cosb
	move.w (a2,d4),d5 ;sinc
	move.w (a1,d4),d4 ;cosc
	moveq #$f,d7
	
	move.w d4,d6
	muls d2,d6
	asr.l d7,d6
	move.w d6,(a0)+ ;a
	
	move.w d4,d6
	muls d1,d6
	asr.l d7,d6
	muls d3,d6
	asr.l d7,d6
	move.w d6,(a0)
	move.w d0,d6
	muls d5,d6
	asr.l d7,d6
	sub.w d6,(a0)+ ;d
	 	 
	move.w d0,d6
	muls d4,d6
	asr.l d7,d6
	muls d3,d6
	asr.l d7,d6
	move.w d6,(a0)
	move.w d1,d6
	muls d5,d6
	asr.l d7,d6
	add.w d6,(a0)+ ;g
	
	move.w d2,d6
	muls d5,d6
	asr.l d7,d6
	move.w d6,(a0)+ ;b
	
	move.w d1,d6
	muls d3,d6
	asr.l d7,d6
	muls d5,d6
	asr.l d7,d6
	move.w d6,(a0)
	move.w d0,d6
	muls d4,d6
	asr.l d7,d6
	add.w d6,(a0)+ ;e
	
	move.w d3,d6
	muls d0,d6
	asr.l d7,d6
	muls d5,d6
	asr.l d7,d6
	move.w d6,(a0)
	move.w d1,d6
	muls d4,d6
	asr.l d7,d6
	sub.w d6,(a0)+ ;h
	
	neg.w d3
	move.w d3,(a0)+ ;c
	
	move.w d1,d6
	muls d2,d6
	asr.l d7,d6
	move.w d6,(a0)+ ;f
	
	muls d2,d0
	asr.l d7,d0
	move.w d0,(a0)+ ;i

	
	lea save_matrice(pc),a0
	
	move.l objet(pc),a1
	move.l new_objet(pc),a2
	
	lea x_centre(pc),a3
	
	move.w (a1)+,d6 ;nbr_point
nbr_point
	movem.w (a1),d0-d2
	muls (a0)+,d0
	muls (a0)+,d1
	muls (a0)+,d2
	add.l d1,d0
	add.l d2,d0
	asr.l d7,d0 ;x
	add.w 4(a3),d0 ;xobs
	movem.w (a1),d1-d3
	muls (a0)+,d1
	muls (a0)+,d2
	muls (a0)+,d3
	add.l d2,d1
	add.l d3,d1
	asr.l d7,d1 ;y
	add.w 6(a3),d1 ;yobs
	movem.w (a1)+,d2-d4
	muls (a0)+,d2
	muls (a0)+,d3
	muls (a0)+,d4
	add.l d3,d2
	add.l d4,d2
	asr.l d7,d2 ;z
	
	lsl.l #8,d0
	lsl.l #8,d1
	
	add.w 8(a3),d2
	ext.l d2
	divs d2,d0
	divs d2,d1
	add.w (a3),d0 ;x_centre
	add.w 2(a3),d1 ;y_centre
	
	ifeq z_value
	movem.w d0-d1,(a2)
	lea 4(a2),a2
	else
	movem.w d0-d2,(a2)
	lea 8(a2),a2   ;oui oui ;no error size scale
	endc
	
	lea -9*2(a0),a0
	dbra d6,nbr_point
	rts

*********************************
nbr_line_per_face	equ 8
nbr_surface_register	equr sp

	ifeq z_tri
next_coord	equ 4
	else
next_coord	equ 8
	endc


affiche_surface
	move.l new_objet(pc),a5
	move.l objet+4(pc),a3		
	move.w (a3)+,-(nbr_surface_register) ;nbr_surface

********************************
next_surface
	bsr init_ymin_ymax_face
	move.w (a3)+,d0    ;nbr_line 
	
	
	move.w d0,-(sp)
	bsr test_visib 
	
	move.w (sp)+,d0
	
	tst.b ok_visib
	beq.S face_visib
	
******************************	
*	pas de face visible  *
******************************
	lea 4(a3,d0*2),a3
	
	subq.w #1,(nbr_surface_register)
	
	bpl.s next_surface 
	lea 2(sp),sp
	rts
	


****************************************
*	remplissage_surface	       *
*	face visible                   *
****************************************


face_visib 
	jmp  ([end_nbr_line_block,d0*4],0)
bob
	rept nbr_line_per_face ;8 ligne par surface max?
	move.w (a3)+,d4
	movem.w (a5,d4*next_coord),d0-d1
 	move.w (a3),d4
	movem.w (a5,d4*next_coord),d2-d3
	bsr trace_line
	endr
end_bob

	move.w y_min_face(pc),d0
	move.w y_max_face(pc),d1
	sub.W d0,d1
	bgt.S normal_trace_surface
	
	lea 4(a3),a3
	subq.w #1,(nbr_surface_register)
	bpl next_surface 
	lea 2(sp),sp
	rts
normal_trace_surface

	move.w d1,d7
	
	move.l ecran,a0
	lea 2(a3),a3 ;;;!!!!
	
	move.w (a3)+,d2  ;couleur
	
	add	d2,d2
	add.w d2,a0
	;lea 8*4(a0),a0
	
	
	lea table_xmin(pc),a4
	lea table_xmax(pc),a6
	
	add.l (table_160,d0.w*4),a0
	lea (d0*2,a4),a4
	lea (d0*2,a6),a6
	
	pea (a3) ;save a3 
	bsr affiche_line
	move.l (sp)+,a3
	
	subq.w #1,(nbr_surface_register)
	bpl next_surface 
	lea 2(sp),sp
	rts




***************************************
; routine remplissage


	include rempl1o2.s

***************************************





init_ymin_ymax_face
	move.w #clipy,y_min_face
	clr.w y_max_face
	rts


search_ymin_ymax_face
	cmp.w y_min_face(pc),d1
	bge.S no_minus_face
	move.w d1,y_min_face
no_minus_face
	cmp.w y_max_face(pc),d3
	ble.S no_maxi_face
	move.w d3,y_max_face
no_maxi_face
	rts
	
************************************
test_visib
	move	(a3),d0
	move.w (a5,d0*next_coord),d1
	move.w 2(A5,D0*next_coord),D2
	
	move	2(a3),d0
	move.w (a5,d0*next_coord),d3
	move.w 2(A5,D0*next_coord),D4
	
	move	4(a3),d0
	move.w (a5,d0*next_coord),d5
	move.w 2(A5,D0*next_coord),D6

	sub	d1,d3
	sub	d2,d4
	sub	d1,d5
	sub	d2,d6
	muls	d3,d6
	muls	d4,d5
	sub.l	d6,d5
	smi	ok_visib
	rts
ok_visib
	dc.w 0

*******************section data*********
end_nbr_line_block
s	set 0
	rept nbr_line_per_face
	dc.l end_bob-s
s	set s+(end_bob-bob)/nbr_line_per_face
	endr
s	set	0
table_160
hot_eur	set 0
	rept clipy
	dc.l hot_eur+s
s	set s+line_large
	endr


***************************
return_from_line
	rts
clipping MACRO
	cmp.w #clipy-1,d1
	bgt.S return_from_line ;hi!
	tst.w d1
	bpl.S no_nega
	move.w d3,d7
	bmi.S return_from_line ;hi!
	sub.w d1,d7 ;Y2-Y1
	move.w d2,d6
	sub.w d0,d6 ;X2-X1	
	muls d3,d6
	divs d7,d6
	sub.w d2,d6
	neg.w d6 ;
	move.w d6,d0 ;new_x1
	moveq #0,d1  ;new_y1
no_nega
	cmp.w #clipy-1,d3
	ble.S no_more_l..
	move.w d3,d7
	sub.w d1,d7 ;y2-y1
	move.w d2,d6
	sub.w d0,d6 ;x2-x1
	move.w #clipy-1,d5
	sub.w d1,d5
	muls d5,d6
	divs d7,d6
	add.w d0,d6
	move.w d6,d2 ;new_x2
	move.w #clipy-1,d3 ;new_y2 
no_more_l..
	endm

trace_line
	moveq #0,d4
	cmp.w d1,d3
	beq.s return_from_line
	bgt.s no_swap 
	exg d0,d2
	exg d1,d3
	
	lea table_xmax(PC),A6
	bra.S suite_trace_line
no_swap
	lea table_xmin(PC),A6
suite_trace_line
	clipping
	bsr search_ymin_ymax_face 
	move.w d3,d7
	move.w d2,d4
	sub.w d0,d4
clip  	
	move.w d3,d5
	sub.w d1,d5
	beq.s return_from_line
	bmi.S return_from_line
	sub.w d1,d7
	
	add.w D1,A6 
	add.w D1,A6 

	ext.l d4
	asl.l #7,d4
	divs d5,d4
	ext.l d4
	asl.l #8,d4
	add.l d4,d4

	
	swap d0
	move.w d4,d0
	beq.s clip3
	addi.w #$8000,d0
	swap d0
	swap d4
list1
	move.w d0,(a6)+
	addx.l d4,d0
	dbra d7,list1
	rts

clip3
	swap d4
	beq.s clip4
	swap d0
list2
	move.w d0,(a6)+
	add.w d4,d0
	dbra d7,list2
	rts

clip4
	swap d0
list3
	move.w d0,(a6)+
	dbra d7,list3
	rts

**********************************




	

*********************************	
	
	section data
yop_point
	dc	8	;nbr
	dc	1	;start
	dc	8
	dc	18		

objet	dc.l objet1,line1

objet1
	dc	3
	dc	-4*160,-4*160,-1*160
	dc	-4*160,4*160,-1*160	
	dc	4*160,4*160,-1*160
	dc	4*160,-4*160,-1*160	
	
line1
	dc	1
	dc	4
	dc	0,1,2,3,0
	dc	5
	dc	4
	dc	0,3,2,1,0
	dc	5



ecran		dc.l 0,0
base_cls_ecran	dc.l 0

new_objet	dc.l new_coord_objet 
y_min_face	dc.w 0
y_max_face	dc.w 0
X_centre	dc.w 192
Y_centre	dc.w 100
x_observateur	dc.w 0
y_observateur	dc.w 0
z_observateur	dc.w 12500
x_angle	dc.w 4
y_angle	dc.w 4
z_angle	dc.w 0
save_matrice
	ds.l 10
extend_register
	ds.l 10


cos_table
sin_table	equ cos_table+1024
	incbin cosin.dat

mask1_re
	dc.w $ffff,$7fff,$3fff,$1fff,$fff
	dc.w $7ff,$3ff,$1ff,$ff,$7f,$3f,$1f
	dc.w $f,$7,$3,$1
mask2_re
	dc.w 0,$8000,$c000,$e000,$f000,$f800
	dc.w $fc00,$fe00,$ff00,$ff80,$ffc0,$ffe0
	dc.w $fff0,$fff8,$fffc,$fffe


base_cls_ecran_data	ds.w 4*10 ;10=nbr_ecran

	
	ds.l 30*16*2
mask_xmin
	ds.l 30*16
cmin2
	ds.l 30*16*2


	ds.l 30*16*2
mask_xmax
	ds.l 30*16
cmax2
	ds.l 30*16*2

table_xmin	ds.w clipy+10
table_xmax	ds.w clipy+10

************************************

new_coord_objet		ds.w 100

************************************
