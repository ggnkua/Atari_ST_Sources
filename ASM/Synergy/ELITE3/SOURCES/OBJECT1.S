object1:        dc.l init_object1                 ;  0
                dc.l do_object1                   ;    4
                dc.l object1_x_p                  ;   8
                dc.l object1_y_p                  ;  12
                dc.l object1_z_p                  ;  16
                dc.l object1_3_p                  ;  20
                dc.l object1_space                ;24

object1_x_p:    dc.w 8,5,10,15,20,25,30,35,40
object1_y_p:    dc.w 8,5,10,15,20,25,30,35,40
object1_z_p:    dc.w 8,5,10,15,20,25,30,35,40

object1_3_p:    dc.w 16+16+16+1-10

                dc.w 0,0,0
                dc.w 12*1,0,0
                dc.w 12*2,0,0
                dc.w 12*3,0,0
                dc.w 12*4,0,0
                dc.w 12*5,0,0
                dc.w 12*6,0,0
                dc.w 12*7,0,0
                dc.w 12*8,0,0
                dc.w -12*1,0,0
                dc.w -12*2,0,0
                dc.w -12*3,0,0
                dc.w -12*4,0,0
                dc.w -12*5,0,0
                dc.w -12*6,0,0
                dc.w -12*7,0,0
                dc.w -12*8,0,0

                dc.w 0,12*1,0
                dc.w 0,12*2,0
                dc.w 0,12*3,0
                dc.w 0,12*4,0
                dc.w 0,12*5,0
                dc.w 0,12*6,0
                dc.w 0,12*7,0
;                dc.w 0,12*8,0
                dc.w 0,-12*1,0
                dc.w 0,-12*2,0
                dc.w 0,-12*3,0
                dc.w 0,-12*4,0
                dc.w 0,-12*5,0
                dc.w 0,-12*6,0
                dc.w 0,-12*7,0
;                dc.w 0,-12*8,0

                dc.w 0,0,12*1
                dc.w 0,0,12*2
                dc.w 0,0,12*3
                dc.w 0,0,12*4
                dc.w 0,0,12*5
                dc.w 0,0,12*6
                dc.w 0,0,12*7
;                dc.w 0,0,12*8
                dc.w 0,0,-12*1
                dc.w 0,0,-12*2
                dc.w 0,0,-12*3
                dc.w 0,0,-12*4
                dc.w 0,0,-12*5
                dc.w 0,0,-12*6
                dc.w 0,0,-12*7
;                dc.w 0,0,-12*8

init_object1:   lea     object1,a0
                movea.l 24(a0),a6
                move.w  #0,x_co-params_3d(a6)
                move.w  #0,y_co-params_3d(a6)
                move.w  #25,z_co-params_3d(a6)
                clr.w   rot_x-params_3d(a6)
                clr.w   rot_y-params_3d(a6)
                clr.w   rot_z-params_3d(a6)
                rts

do_object1:     lea     object1,a0
                movea.l 24(a0),a6
                addi.w  #0,rot_y-params_3d(a6)
                addi.w  #0,rot_x-params_3d(a6)
                addi.w  #12,rot_z-params_3d(a6)
		tst.b	z_dir
		beq	z_add
		subq.w	#1,z_co-params_3d(a6)
		cmp.w	#25,z_co-params_3d(a6)
		bgt.s	z_ok
		sf	z_dir
z_ok:		rts
z_add:		addq.w	#1,z_co-params_3d(a6)
		cmp.w	#100,z_co-params_3d(a6)
		blt.s	z_ok
		st	z_dir
		rts
z_dir:		ds.w	1				
		
		rts
