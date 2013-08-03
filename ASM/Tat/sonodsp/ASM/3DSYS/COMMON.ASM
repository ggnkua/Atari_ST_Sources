; COMMON.ASM

; Shared routines for DSP 3-D stuff






; C_OBJ.ASM

; Module to convert dsp object from 030 to a sensible format
;  for the dsp

;------------------------------------------------------------
; Enter with:
; r0 - start of object in _y memory_

convert_object:

; First of all, relocate the top n address offsets
	move r0,x:object_address
	move r0,x0
	move #3,n0
	move r0,r1

	lua (r0)+n0,r0

	do #5,_relocate			;FIXED 4 GOURAUD 5.5.95
	  clr a
	  move y:(r0),a1
	  add x0,a
	  move a1,y:(r0)+
_relocate:

; Now compile a polygon list
	move #1,n1
	move #polygon_list,r4
	move y:(r1+n1),n6		;n6 - number of polygons
	move #5,n1
	nop
	move y:(r1+n1),r0		;r0 - polygon_data list

	do n6,_compile_polylist
	  move r0,a
	  rep #3
	    move (r0)+			;skip in_poly, out_poly, shading
	  move a,y:(r4)+		;save poly address
	  move y:(r0)+,n0		;get poly_points
	  nop
	  lua (r0)+n0,r0		;skip point list
_compile_polylist:
	rts






;-------------------------------------------------------
;
;
;
;	Rotation Routines
;
;
;
;-------------------------------------------------------
; calculate_trig:
;  Uses following matrix:
; (+cosYcosZ	-sinXsinYcosZ-cosXsinZ	-cosXsinYcosZ+sinXsinZ	)
; (+cosYsinZ	-sinXsinYsinZ+cosXcosZ	-cosXsinYsinZ-sinXcosZ	)
; (  +sinY	       +sinXcosY	       +cosXcosY	)
; Worked.....  11/94


calculate_trig:
	move	#-1,m2
; First do -sinXsinY ---> y0
	move	x:sinX,x0
	move	x:sinY,x1
	mpy	-x0,x1,a
	move	a1,y0
;          -cosXsinY ---> temp1
	move	x:cosX,x0
	move	x:sinY,x1
	mpy	-x0,x1,a
	move	a1,x:temp1
;7 sinY
	move	x:sinY,x0
	move	x0,x:(r2)+
;8 sinXcosY
	move	x:sinX,x0
	move	x:cosY,x1
	mpy	x0,x1,a
	move	a1,x:(r2)+
;9 cosXcosY
	move	x:cosX,x0
	move	x:cosY,x1
	mpy	x0,x1,a
	move	a1,x:(r2)+
;1 cosYcosZ:
	move	x:cosY,x0
	move	x:cosZ,x1
	mpy	x0,x1,a
	move	a1,x:(r2)+
;2 -sinXsinYcosZ-cosXsinZ
	move	x:cosZ,x0
	mpy	x0,y0,a
	move	x:cosX,x0
	move	x:sinZ,x1
	mac	-x0,x1,a
	move	a1,x:(r2)+
;3 -cosXsinYcosZ+sinXsinZ
	move	x:temp1,x0
	move	x:cosZ,x1
	mpy	x0,x1,a
	move	x:sinX,x0
	move	x:sinZ,x1
	mac	x0,x1,a
	move	a1,x:(r2)+
;4 cosYsinZ
	move	x:cosY,x0
	move	x:sinZ,x1
	mpy	x0,x1,a
	move	a1,x:(r2)+
;5 -sinXsinYsinZ+cosXcosZ
	move	x:sinZ,x0
	mpy	x0,y0,a
	move	x:cosX,x0
	move	x:cosZ,x1
	mac	x0,x1,a
	move	a1,x:(r2)+
;6 -cosXsinYsinZ-sinXcosZ
	move	x:temp1,x0
	move	x:sinZ,x1
	mpy	x0,x1,a
	move	x:sinX,x0
	move	x:cosZ,x1
	mac	-x0,x1,a
	move	a1,x:(r2)+
	rts





;-------------------------------------------------------

; Perspective: Xp = X / [ (z/d)+1 ]

;  (z/d)+1 = z/d + d/d = (z + d) / d

;  Hence Xp = (x * d * k) / (z + d)

dpersp	equ	0.2	;depth of field constant. Where the middle sits
			; this val affects the _perspective_ most....
cpersp	equ	0.5	;1/d
kpersp	equ	200	;sizing constant. These affect _size_

rotate_points:
	move #torus_object,r0
	move #3,n0
	nop
	move y:(r0+n0),r4
	move r4,r5
	move r5,r6
	move #-1,m2
	move #-1,m4
	move #-1,m5

	move y:(r0),n0			;number of points to do
	move #-1,m6
	move #rotated_buffer,r0

	;-------------------
	do n0,_spin
	  move #matrix,r2
	  move #dpersp,a
	  	   move	x:(r2)+,x0 y:(r6)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r6)+,y0
	  macr y0,x0,a	x:(r2)+,x0 y:(r5)+,y0

	  move #cpersp,x1		; x1 = 1/d
	  move a1,y1			; y1 = z+1/d
	  mpy x1,y1,a	y1,y:(r0)+

	  move #>kpersp,b	 	;perspective
	  move a1,x1			;x1=z coord
	  rep #$18			;p.coeff= k/(z+.25)
	    div x1,b
	  bclr #23,b0
	  move b0,x1			;x1=perspective coeff.

	  mpy y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  mac y0,x0,a	x:(r2)+,x0 y:(r5)+,y0
	  macr y0,x0,a	x:(r2)+,x0 y:(r4)+,y0
	  move a1,y1
	  mpyr x1,y1,a

	  mpy y0,x0,b	x:(r2)+,x0 y:(r4)+,y0
	  mac y0,x0,b	x:(r2)+,x0 y:(r4)+,y0
	  macr y0,x0,b	 a1,y:(r0)+		;pump it out
	  move b1,y1
	  mpyr x1,y1,b
	  move b1,y:(r0)+
_spin:
	;-------------------
	rts





calc_visibility:
	move y:torus_object+1,n0	;+1 number of polygons
	move #polygon_list,r4		;unsorted list....
	move #visible_buffer,r6
	move #rotated_buffer+1,r2

	do n0,_polygon_loop

_get_polygon_loop:
	  move y:(r4)+,r0
	  nop
	  rep #4
	    move (r0)+			;ignore in,out,colour,count

	;Point 1:
	  move y:(r0)+,n2
	  nop
	  lua (r2)+n2,r3
	  nop
	  move y:(r3)+,x0
	  move y:(r3)+,x1
	;Point 2:
	  move y:(r0)+,n2
	  nop
	  lua (r2)+n2,r3
	  nop
	  move y:(r3)+,a
	  move y:(r3)-,b		;fiddle a bit to rid the nops
	  sub x0,a
	  sub x1,b
	  move a,x0
	  move b,x1
	  move y:(r3)+,y0
	  move y:(r3)+,y1
	;Point 3:
	  move y:(r0)+,n2
	  nop
	  lua (r2)+n2,r3
	  nop
	  move y:(r3)+,a
	  move y:(r3)+,b
	  sub y0,a
	  sub y1,b
	  move a,y0
	  move b,y1

	  mpy x0,y1,a
	  mac -x1,y0,a
	  move a,y:(r6)+
_polygon_loop:
	rts






;-------------------------------------------------------
;
;
;	receive_object
;
;
;
;-------------------------------------------------------

receive_object
	move #torus_object,r0
	move #-1,m0
	wait_receive
	movep x:<<hrx,n0

	do n0,_get
	  wait_receive
	  movep x:<<hrx,x0
	  move x0,y:(r0)+
_get:

	move #torus_object,r0
	jsr convert_object
	jmp main_loop


;-------------------------------------------------------
get_rotation:
	move #cosX,r0
	move #-1,m0
	do #6,_get
	  wait_receive
	  movep x:<<hrx,x0
	  move x0,x:(r0)+
_get:
	move #matrix,r2
	jsr calculate_trig
	jmp main_loop

;-------------------------------------------------------
get_one_over:
	move #one_over,r0
	do #320,_get
	  wait_receive
	  movep x:<<hrx,x0
	  move x0,x:(r0)+
_get:	rts

;-------------------------------------------------------
wait_receive
	jclr #0,x:<<hsr,*
	rts
;-------------------------------------------------------
wait_transmit
	jclr #1,x:<<hsr,*
	rts
