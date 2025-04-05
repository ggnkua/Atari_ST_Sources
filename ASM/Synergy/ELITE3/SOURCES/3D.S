	
		text

period:		equ	2048
max_c:		equ	2000

init_3d:        lea     sin_cos,a0
                move.w  #5-1,d1                   ;5 periods in total
copy_sin_l:     lea     sin_cos_tab,a1            ;pointer to sin-cos table
                move.w  #period-1,d0              ;period of sinus table
sin_l:          move.l  (a1)+,(a0)+               ;copy to memory
                dbra    d0,sin_l                  ;next sinus value
                dbra    d1,copy_sin_l             ;next sinus table
                rts

init_object:   
* a0 = object ptr		
                move.l  a0,current_object
                jsr     ([a0])
                rts

anim_object:    movea.l current_object,a0
                bsr.s   calc_object
                rts

calc_object:   

*a0 pointer to struc object

                move.l  a0,object_ptr

		jsr	([4,a0])		;do object

                movea.l 24(a0),a6                 ;pointer to object parameters

                lea     matrix-params_3d(a6),a0             ;pointer to matrix
                bsr     make_matrix               ;
                movea.l object_ptr,a0             ;unstack

                movea.l 24(a0),a6                 ;pointer to object parameters
                bsr     project_3d                ;project it
                movea.l object_ptr,a0

                rts                               ;

make_matrix:    lea     sin_cos+period*2*4,a1     ;pointer to third period of sinus
                move.w  rot_z-params_3d(a6),d0              ;init angles
                move.w  rot_x-params_3d(a6),d1              ;
                move.w  rot_y-params_3d(a6),d2              ;
                and.w   #(period-1)*4,d0          ;
                and.w   #(period-1)*4,d1          ;
                and.w   #(period-1)*4,d2          ;
m_m_4:          bsr.s   rot_matrix                ;create matrix
                rts

rot_matrix:    

*Calc rotation matrix using no muls.
*a0 points to struc M->{1..9}.w
*a1 points to period 3 of a sinus/cosinus tabel with 5 periods.
*d0 angle z
*d1 angle y
*d2 angle x
*Returns (1..9).w matrix elements in struc M->{}.


                move.w  d0,d3                     ;4  copy a
                move.w  d0,d4                     ;4  '     '
                add.w   d2,d3                     ;4  a+c
                sub.w   d2,d4                     ;4  a-c
                move.l  0(a1,d3.w),d5             ;18 sin in high,cosinus in low word
                move.l  0(a1,d4.w),d6             ;18 '                             '
                add.w   d5,d6                     ;4  cos(a+b)+cos(a-b)
                move.w  d6,(a0)+                  ;8  store
                swap    d5                        ;4
                swap    d6                        ;4
                add.w   d5,d6                     ;4  sin(a+b)+cos(a-b)
                move.w  d6,(a0)+                  ;8  store
                move.w  0(a1,d2.w),d5             ;14 sin(c)
                add.w   d5,d5                     ;4  *2
                neg.w   d5                        ;4  -
                move.w  d5,(a0)+                  ;8  store
                move.w  d1,d3                     ;4  copy b
                move.w  d1,d4                     ;$  copy b
                add.w   d2,d3                     ;4  b+c
                sub.w   d2,d4                     ;4  b-c
                move.l  0(a1,d3.w),d5             ;18 sin in high,cosinus in low word
                move.l  0(a1,d4.w),d6             ;18 '                             '
                add.w   d5,d6                     ;4  cos(b+c)+cos(b-c)
                move.w  d6,10(a0)                 ;4  store
                swap    d5                        ;4
                swap    d6                        ;4
                add.w   d5,d6                     ;4  sin(b+c)+sin(b-c)
                move.w  d6,4(a0)                  ;12 store
                move.w  d0,d3                     ;4  copy a
                add.w   d1,d0                     ;4  a+b
                sub.w   d1,d3                     ;4  a-b
                move.w  d2,d4                     ;4  copy c
                move.w  d2,d1                     ;4  '    '
                neg.w   d1                        ;4  -c
                move.w  d1,d5                     ;4  copy -c
                add.w   d0,d1                     ;4  a+b-c
                add.w   d0,d2                     ;4  a+b+c
                add.w   d3,d4                     ;4  a-b+c
                add.w   d3,d5                     ;4  a-b-c
                move.l  0(a1,d0.w),d0             ;18
                move.l  0(a1,d1.w),d1             ;18
                move.l  0(a1,d2.w),d2             ;18
                move.l  0(a1,d3.w),d3             ;18
                move.l  0(a1,d4.w),d4             ;18
                move.l  0(a1,d5.w),d5             ;18
                swap    d0                        ;4
                swap    d3                        ;4
                sub.w   d2,d1                     ;4
                sub.w   d5,d4                     ;4
                asr.w   #1,d1                     ;8
                asr.w   #1,d4                     ;8
                sub.w   d0,d1                     ;4  A
                sub.w   d3,d4                     ;4  B
                move.w  d1,d6                     ;4  copy
                add.w   d4,d6                     ;4  A+B
                move.w  d6,(a0)+                  ;8  store
                sub.w   d4,d1                     ;4  A-B
                move.w  d1,6(a0)                  ;12 store
                swap    d0                        ;4
                swap    d3                        ;4
                swap    d1                        ;4
                swap    d2                        ;4
                swap    d4                        ;4
                swap    d5                        ;4
                sub.w   d2,d1                     ;4
                sub.w   d5,d4                     ;4
                asr.w   #1,d1                     ;8
                asr.w   #1,d4                     ;8
                add.w   d3,d4                     ;4  D
                add.w   d0,d1                     ;4  C
                move.w  d1,d6                     ;4  copy
                add.w   d4,d6                     ;4  C+D
                move.w  d6,(a0)                   ;8 store
                sub.w   d1,d4                     ;4  C-D
                move.w  d4,4(a0)                  ;12 store
                rts                               ;16

****************************************;a total of 528

project_3d: 

*a0 pointer to RECORD(Object)
*a6 pointer to parameter block

                lea     x_coord+max_c*2,a3        ;pointer to mid of x-coord list
                movea.l a3,a4                     ;copy pointer
                lea     12(a3),a3                 ;0 -> zero
                addq.l  #8,a0                     ;skip parameters
                movea.l (a0)+,a2                  ;fetch pointer to RECORD(Points)
                lea     matrix-params_3d(a6),a1             ;init pointer to matrix
                movem.w (a1)+,d1-d3               ;fetch matrix elements m11,m21,m31
                move.w  (a2)+,d0                  ;fetch number of x-coords to rotate

                bra.s   proj_x                    ;jump loop
x_loop:         move.w  (a2)+,d4                  ;fetch x-coord
                move.w  d4,d5                     ;copy
                move.w  d4,d6                     ;copy
                muls    d1,d4                     ;x'
                muls    d2,d5                     ;y'
                muls    d3,d6                     ;z'
                move.l  d4,(a3)+                  ;store
                move.l  d5,(a3)+                  ;
                move.l  d6,(a3)+                  ;
                neg.l   d4                        ;store negative
                neg.l   d5                        ;
                neg.l   d6                        ;
                movem.l d4-d6,-(a4)               ;
proj_x:         dbra    d0,x_loop                 ;
                lea     y_coord+max_c*2,a3        ;pointer to mid of y-coord list
                movea.l a3,a4                     ;copy pinter
                lea     12(a3),a3                 ;0 -> zero
                movea.l (a0)+,a2                  ;fetch pointer to RECORD(Points)
                movem.w (a1)+,d1-d3               ;fetch matrix elements m12,m22,m32
                move.w  (a2)+,d0                  ;fetch number of y-coords to rotate
                bra.s   proj_y                    ;jump in loop
y_loop:         move.w  (a2)+,d4                  ;fetch y-cord
                move.w  d4,d5                     ;copy
                move.w  d4,d6                     ;copy
                muls    d1,d4                     ;x'
                muls    d2,d5                     ;y'
                muls    d3,d6                     ;z'
                move.l  d4,(a3)+                  ;store
                move.l  d5,(a3)+                  ;
                move.l  d6,(a3)+                  ;
                neg.l   d4                        ;store negative
                neg.l   d5                        ;
                neg.l   d6                        ;
                movem.l d4-d6,-(a4)               ;
proj_y:         dbra    d0,y_loop                 ;

                lea     z_coord+max_c*2,a3        ;pointer to mid of z-coord list
                movea.l a3,a4                     ;copy pointer
                lea     12(a3),a3                 ;0 -> zero
                movea.l (a0)+,a2                  ;fetch pointer to RECORD(Points)
                movem.w (a1)+,d1-d3               ;fetch matrix elements m13,m23,m33
                move.w  (a2)+,d0                  ;fetch number of z-coords to rotate
                bra.s   proj_z                    ;jump in loop
z_loop:         move.w  (a2)+,d4                  ;fetch z-coord
                move.w  d4,d5                     ;copy
                move.w  d4,d6                     ;copy
                muls    d1,d4                     ;x'
                muls    d2,d5                     ;y'
                muls    d3,d6                     ;z'
                move.l  d4,(a3)+                  ;store
                move.l  d5,(a3)+                  ;
                move.l  d6,(a3)+                  ;
                neg.l   d4                        ;store negative
                neg.l   d5                        ;
                neg.l   d6                        ;
                movem.l d4-d6,-(a4)               ;
proj_z:         dbra    d0,z_loop                 ;

                movea.l (a0)+,a0                  ;fetch pointer to RECORD(3d_p)
                move.w  (a0)+,d0                  ;fetch number of xyz indices
                subq.w  #1,d0                     ;-1 for dbf
                lea     xyz_pointers,a4           ;pointer to pointers
                lea     p_xy-params_3d(a6),a5     ;fetch pointer to destination points
                moveq   #0,d4                     ;low word clear
                move.w  z_co-params_3d(a6),d4     ;init z world coordinate
                swap    d4                        ;
                moveq   #0,d5                     ;low word clear
                move.w  x_co-params_3d(a6),d5     ;init x world coordinate
                swap    d5                        ;
                asr.l   #4,d5                     ;
                moveq   #0,d6                     ;low word clear
                move.w  y_co-params_3d(a6),d6     ;init y world coordinate]
                swap    d6                        ;
                asr.l   #4,d6                     ;

project_l:      movem.l (a4),a1-a3                ;restore pointers
                movem.w (a0)+,d1-d3               ;fetch x,y,z indices
                adda.w  d1,a1                     ;index to coordinates
                adda.w  d2,a2                     ;
                adda.w  d3,a3                     ;
                movem.l (a1)+,d1-d3               ;calc x,y,z coord
                add.l   (a2)+,d1                  ;
                add.l   (a3)+,d1                  ;
                add.l   (a2)+,d2                  ;
                add.l   (a3)+,d2                  ;
                add.l   (a2)+,d3                  ;
                add.l   (a3)+,d3                  ;
                add.l   d4,d3                     ;move through world
                add.l   d5,d1                     ;
                add.l   d6,d2                     ;
                swap    d3                        ;
                rol.l   #4,d3                     ;
                asr.l   #3,d1                     ;
                asr.l   #3,d2                     ;
                divs    d3,d1                     ;project to x',y'
                divs    d3,d2                     ;
		add.w	#X_SIZE/2,d1
		add.w	#Y_SIZE/2,d2
;                add.w   x_m,d1          ;adjust to mid screen
;                add.w   y_m,d2          ;
                move.w  d1,(a5)+                  ;store x',y'
                move.w  d2,(a5)+                  ;
                dbra    d0,project_l              ;next
		move.l	#-1,(a5)+
                rts

		data

** Objects

		INCLUDE	"h:\syn_proj.ect\elite.3\sources\object1.s"	;axes

sin_cos_tab:    INCBIN	"h:\syn_proj.ect\elite.3\binary\sincos.tab"

xyz_pointers:   dc.l x_coord+max_c*2
                dc.l y_coord+max_c*2
                dc.l z_coord+max_c*2

		bss

params_3d:

matrix:         ds.w 9
rot_x:          ds.w 1
rot_y:          ds.w 1
rot_z:          ds.w 1
x_co:           ds.w 1
y_co:           ds.w 1
z_co:           ds.w 1
p_xy:           ds.l max_c*3

param_3d_e:

obj_space       equ param_3d_e-params_3d

object1_space:  ds.b obj_space
                
sin_cos         ds.b	period*20
x_coord         ds.b	max_c*4
y_coord         ds.b	max_c*4
z_coord         ds.b	max_c*4
object_ptr      ds.l	1
current_object  ds.l	1

		