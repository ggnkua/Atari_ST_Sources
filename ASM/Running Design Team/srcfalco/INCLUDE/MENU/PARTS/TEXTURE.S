**********************************
******* texture mapping  *********
**********************************

* MIG 1996
* REVISION B
* 

******* for data : minus to plus *******

* x: l->r
* y: o->u
* z: v->h


********** polygon engine **************

texture_wide    	EQU 64
textures        	EQU 7

texture_wohin		EQU 	640*25+20*2
calc_lines		equ	80

************ SUBS ********************

texture_to_buffer

		lea	texture,a0

		move.l	a1,a3
* 1. Reihe
		move.w	#5-1,d0
copper_1
		move.l	a1,a2		
		move.w	#texture_wide-1,d1
copper_2
	
		move.w	#texture_wide-1,d2

copper_3	move.w	(a2)+,(a0)+
		dbra	d2,copper_3

		lea	640-texture_wide*2(a2),a2
		dbra	d1,copper_2

		lea	texture_wide*2(a1),a1	

		dbra	d0,copper_1
	
* 2. Reihe 
		move.l	a3,a1
		adda.l	#640*texture_wide,a1

		move.w	#2-1,d0
copper_1x
		move.l	a1,a2		
		move.w	#texture_wide-1,d1
copper_2x
	
		move.w	#texture_wide-1,d2

copper_3x	move.w	(a2)+,(a0)+
		dbra	d2,copper_3x

		lea	640-texture_wide*2(a2),a2
		dbra	d1,copper_2x

		lea	texture_wide*2(a1),a1	

		dbra	d0,copper_1x

		rts


***************************************
************* 3D-GRAFIX ***************
***************************************

render_texture:   

*d0= x-nachkomma buffer
*d1= x nach
*d2= y-nachkomma buffer
*d3= y nach
*d4= x+y vorkomma
*d5= y overjump
*d6= position
*d7= lines

*a0= buffer adr
*a1= buffer work
*a2= x infos
*a3= data
*a4= jump adr
*a5= divu tab
*a6= free

                lea     texture,A3
                move.w  texture_number(PC),D0
                mulu	#texture_wide*texture_wide*2,d0
                adda.l  D0,A3

                lea     xx_buffer,A2

                move.w  (A2)+,D7        * line counter
                move.w  (A2)+,D1        * start y

		move.l	screen_1,a0
                mulu	#640,D1         
                addi.l  #texture_wohin,d1
		adda.l	d1,a0		* screen line to start

texture_loop:
		swap	d7

******** get x1(screen),x2(screen) *********

                move.w  (A2)+,D7
                movea.w calc_lines*2*1-2(A2),A4

                sub.w   A4,D7           	* laenge on screen
                bmi     nix_zeichnen

		move.w	a4,d0
		lea	0(a0,d0.w*2),a1		* x start on screen

***************** x,y  ****************

                move.w  calc_lines*2*2-2(A2),D1 * x2
                move.w  calc_lines*2*3-2(A2),D3 * y2
                move.w  calc_lines*2*4-2(A2),D0 * x1
                move.w  calc_lines*2*5-2(A2),D2 * y1

*************************************
***************** dy ****************

                sub.w   D2,D3
                bpl.s   y_down

********* move up *********

                neg.w   D3

                move.w  #-texture_wide,D5 	* y up

                move.w  D3,D4
                mulu    0(A5,D7.w*2),D4   	* fast divu
		
		move.w  D4,D3
                swap    D4

                lsl.w   #6,D4 			* mulu texture wide
                neg.w   D4

                bra.s   dy_done

******* move down ********

y_down:
                move.w  #texture_wide,D5 	* y down

                move.w  D3,D4
                mulu    0(A5,D7.w*2),D4   	* fast divu
                move.w  D4,D3
                swap    D4

                lsl.w   #6,D4 			* mulu texture wide

dy_done:

*************************************
*************** dx ******************

                sub.w   D0,D1
                bpl.s   leffx

* d0= x-buffer
* d1= x-nachkomma
* d6= y-buffer
* d3= y-nachkomma
* d4= x+y-vorkomma
* d5= y-step
* d2= position


********* move right to left *********

                neg.w   D1
                neg.w   D4              	* cause of subx (vorkomma !)

                mulu    0(A5,D7.w*2),D1   	* fast divu
                swap    D1
                add.w   D1,D4
                swap    D1

                lsl.w   #6,D2 			* mulu texture_wide
                add.w   D0,D2           	* x+y pos

            
                moveq   #0,D0           	* clear nach x buffer
                moveq   #0,D6           	* clear nach y buffer

right_to_left
                add.w   D1,D0
                subx.w  D4,D2
             
		add.w   D3,D6
                bcc.s   no_carry_2
                
		add.w   D5,D2
                
no_carry_2	move.w  0(A3,D2.w*2),(A1)+
		          
		dbra	d7,right_to_left

                lea     640(A0),A0
		swap	d7
                dbra    D7,texture_loop
                rts


********* move left to right **********

leffx:          

                mulu    0(A5,D7.w*2),D1   	* fast divu
                swap    D1
                add.w   D1,D4
                swap    D1

                lsl.w   #6,D2 			* mulu texture_wide
                add.w   D0,D2           	* x+y pos

                moveq   #0,D0           	* clear nach x buffer
                moveq   #0,D6           	* clear nach y buffer

		            
left_to_right
		add.w   D1,D0
                addx.w  D4,D2
                
		add.w   D3,D6
                bcc.s   no_carry_1
                
		add.w   D5,D2
                
no_carry_1	
		move.w  0(A3,D2.w*2),(A1)+      

		dbra	d7,left_to_right

nix_zeichnen:   lea     640(A0),A0
                swap	d7
		dbra    D7,texture_loop
                rts

************************************
********* SHAPE Manager ************

texture_number: DC.W 0          * welche texture 

current_pointsx: 
		DS.L 4
                DS.L 4

give_textures_a_chance:

* a0= flachinfos
* a1= trans points
* a2=
* a3=
* a4=
* a5= fast mulu
* a6=

* d0= work
* d1= work
* d2= work
* d3= work
* d4= work
* d5= work
* d6=
* d7= count flachs

                lea     texture_edge_info,A0

                move.w  (A0)+,D7        	* field counter

main_loopx:     move.w  D7,-(SP)

                move.w  (A0)+,texture_number 	* nummer des texture

                lea     fast_divu,A5

                tst.w	(a0)+
		bne.s	maenner

		illegal

maenner

**********************************************
***************** 4-point-fill ***************
**********************************************

                movem.w (A0)+,D0-D3     * get 4 points !

                lea     transformed_pointsx,A1

                move.l  0(A1,D0.w),D0   * x0/y0
                move.l  0(A1,D1.w),D1   * x1/y1
                move.l  0(A1,D2.w),D2   * x2/y2
                move.l  0(A1,D3.w),D3   * x3/y3

                movea.l D1,A1           * save point 1
                movea.l D2,A2           * save point 2

*********** kreuz mulus *******************

                sub.w   D1,D2           * y2-y1
                sub.w   D0,D1           * y1-y0

                move.w  D1,D4
                move.w  D2,D5
                swap    D0
                swap    D1
                swap    D2

                sub.w   D1,D2           * x2-x1
                sub.w   D0,D1           * x1-x0

                muls    D2,D4           * x2-x1*y1-y0
                muls    D1,D5           * x1-x0*y2-y1

                sub.l   D5,D4

                bpl     scan_nothing_4x  * unsichtbar

********* sichtbar  *******

                swap    D0              * points back
                move.l  A1,D1
                move.l  A2,D2

                lea     current_pointsx(PC),A6
                movem.l D0-D3,(A6)
                movem.l D0-D3,16(A6)

************* y min + max bestimmen ***********

                moveq   #0,D5           * offset in points buffer

                move.w  D0,D6           * first point is min and max !
                move.w  D0,D7

                cmp.w   D1,D6
                ble.s   no_min_p2x
                move.w  D1,D6
                moveq   #4,D5
no_min_p2x:      cmp.w   D1,D7
                bge.s   no_max_p2x
                move.w  D1,D7
no_max_p2x:
                cmp.w   D2,D6
                ble.s   no_min_p3x
                move.w  D2,D6
                moveq   #8,D5
no_min_p3x:      cmp.w   D2,D7
                bge.s   no_max_p3x
                move.w  D2,D7
no_max_p3x:
                cmp.w   D3,D6
                ble.s   no_min_p4x
                move.w  D3,D6
                moveq   #12,D5
no_min_p4x:      cmp.w   D3,D7
                bge.s   no_max_p4x
                move.w  D3,D7
no_max_p4x:

* min = d6 / max = d7 / d5=offset in p buffer / a6= point start adr

                cmp.w   D6,D7           * min=max ?
                bne.s   not_on_line_4x

************* falls y1=y2=y3=y4 ***************

                lea     xx_buffer,A1
                lea     x2,A0

                clr.w   (A1)+           * one line
                move.w  D6,(A1)+        * start y

                swap    D0              * get x
                swap    D1
                swap    D2
                swap    D3

                move.w  D0,D6
                move.w  D0,D7

                cmp.w   D1,D6
                ble.s   no_min_xp2x
                move.w  D1,D6
no_min_xp2x:     cmp.w   D1,D7
                bge.s   no_max_xp2x
                move.w  D1,D7
no_max_xp2x:
                cmp.w   D2,D6
                ble.s   no_min_xp3x
                move.w  D2,D6
no_min_xp3x:     cmp.w   D2,D7
                bge.s   no_max_xp3x
                move.w  D2,D7
no_max_xp3x:
                cmp.w   D3,D6
                ble.s   no_min_xp4x
                move.w  D3,D6
no_min_xp4x:     cmp.w   D3,D7
                bge.s   no_max_xp4x
                move.w  D3,D7
no_max_xp4x:
                move.w  D6,(A0)
                move.w  D7,(A1)

                illegal

                bra     end_4x           * schon fertig ...

*********** liegen nicht auf gemeinsamen y line *********

not_on_line_4x:
                movea.l (A0)+,A4        * viereck structure
                move.l  A0,-(SP)

                move.w  D7,D0
                sub.w   D6,D0

                lea     xx_buffer,A1
                lea     x2,A0

                move.w  D0,(A1)+        * lines counter
                move.w  D6,(A1)+        * start y (min)

                adda.w  D5,A6           * offset in points buffer
                adda.w  D5,A4           * and in structure buffer

                lea     structure_start,A2
                lea     4*4(A4),A3
                move.l  A3,(A2)+
                lea     4*4(A6),A3      * for backward tracking
                move.l  A3,(A2)+

*************** start calcing ************

* a0= texture buffer
* a1= x buffer
* a2= work in calc line
* a3=
* a4= shape infos
* a5= fast mulu
* a6= points buffer

* d0=
* d1=
* d2=
* d3=
* d4=
* d5=
* d6= ecken counter
* d7= maximum

                moveq   #3,D6           * ecken counter

track_up_4x:    move.l  (A6)+,D0
                move.l  (A4)+,start_point

                move.w  D0,D1           * y1
                swap    D0              * x1

                cmp.w   D7,D1           * y max erreicht ?
                beq.s   found_max_4x

                move.l  (A6),D2
                move.l  (A4),end_point

                move.w  D2,D3           * y2
                swap    D2              * y1

                bsr     calc_linex
                bsr     calc_positions

                dbra    D6,track_up_4x
                bra.s   end_4x

*********** other direction *************

found_max_4x:   lea     xx_buffer_left,A1
                lea     x1,A0

                movem.l structure_start,A4/A6

track_down_4x:
                move.l  (A6),D0
                move.l  (A4),start_point

                move.w  D0,D1
                swap    D0

                cmp.w   D7,D1           * y max erreicht ?
                beq.s   end_4x

                move.l  -(A6),D2
                move.l  -(A4),end_point

                move.w  D2,D3
                swap    D2

                bsr     calc_linex
                bsr     calc_positions

                dbra    D6,track_down_4x

************ all calculated ... now fill it ***************

end_4x:
                bsr     render_texture

                movea.l (SP)+,A0
                move.w  (SP)+,D7
                dbra    D7,main_loopx
                rts

scan_nothing_4x:
		lea     4(A0),A0        * no strcuture info used
                move.w  (SP)+,D7
                dbra    D7,main_loopx
                rts

                

************ X Coordinates calculation ************

calc_linex:

* a1= buffer
* a2= work
* a5= fast divu tab
* d0= x1
* d1= y1
* d2= x2
* d3= y2

                sub.w   D1,D3           * dy
                sub.w   D0,D2           * dx

                move.w  D2,my_dx
                move.w  D3,my_dy

                tst.w   D3
                ble     leave_thisx      * dy<=0 ? => nix ...

                tst.w   D2              * dx
                beq     zero_dxx
                bmi     neg_dxx          * other direction

*************************************************************

                add.w	d3,d3		* for table
		mulu    0(A5,D3.w),D2 	* fast divu
                swap    D2              * nachkomma/vorkomma

                addq.w  #2,D3           * eins mehr (*2)
                add.w   D3,D3           * *4

                lea     code_end_1x(PC),A2
                suba.w  D3,A2

                moveq   #0,D1           * clear highword of x
                move.w  D0,D1

                jmp     (A2)

                REPT calc_lines-1
                move.w  D1,(A1)+        * x value
                addx.l  D2,D1           * x steps
                ENDR
                move.w  D1,(A1)+        * x value
                rts
code_end_1x:

************************************************************

neg_dxx:
                neg.w   D2              * wieder positiv machen

                add.w	d3,d3		* for table
		mulu    0(A5,D3.w),D2   * fast divu
                swap    D2              * nachkomma/vorkomma

                addq.w  #2,D3           * eins mehr (*2)
                add.w   D3,D3           * *4

                lea     code_end_2x(PC),A2
                suba.w  D3,A2

                moveq   #0,D1
                move.w  D0,D1

                jmp     (A2)

                REPT calc_lines-1
                move.w  D1,(A1)+        * x-wert sichern
                subx.l  D2,D1           * step
                ENDR
                move.w  D1,(A1)+        * x-wert sichern
                rts
code_end_2x:

**************************************************************

zero_dxx:
                lea     code_end_3x(PC),A2

                add.w   D3,D3
                suba.w  D3,A2

                jmp     (A2)

                REPT calc_lines-1
                move.w  D0,(A1)+        * x-wert sichern
                ENDR
code_end_3x:     move.w  D0,(A1)+

leave_thisx:     rts


* ALANIS

********************************
*******  U/V Calculation *******
	
		* y-view
neg_deltay:
                neg.w   D3              * neg delta y

                sub.w   D0,D2           * delta x
                beq     neg_y_same_x
                bmi     neg_y_neg_x

* move left to right side *

neg_y_pos_x:

                lea     texture_code4(PC),A2

                move.w  my_dy,D7        * mulu 14
                addq.w  #1,D7           * dy+1 (for jmp)
                move.w  D7,D5
                add.w   D5,D5
                move.w  D5,D6
                lsl.w   #3,D6
                sub.w   D5,D6
                suba.w  D6,A2           * jmp in code

                move.w  D2,D4           * fast deltax/my_dx
                move.w  my_dx,D5
                add.w   D5,D5
                mulu    0(A5,D5.w),D4
                move.w  D4,D2
                swap    D4

                move.w  my_dy,D5        * fast dy/my_dy
                add.w   D5,D5
                mulu    0(A5,D5.w),D3
                movea.w D3,A3
                swap    D3

                moveq   #0,D5           * x- buff
                move.w  D5,D6           * y- buff

                jmp     (A2)

* d0= x value
* d1= y value
* d2= nach x
* d3= vor y
* d4= vor x
* d5= x-buff
* d6= y-buff
* a3= nach y

                REPT calc_lines-1
                move.w  D0,(A0)+        * write x
                move.w  D1,calc_lines*2-2(A0) * write y*texturewide (no and!)
                add.w   D2,D5           * x
                addx.w  D4,D0
                add.w   A3,D6           * y
                subx.w  D3,D1
                ENDR

                move.w  D0,(A0)+        * write x
                move.w  D1,calc_lines*2-2(A0) * write y*texturewide (no and!)
                swap    D6
                swap    D7
                rts
                nop
texture_code4:



* move right to left side *

neg_y_neg_x:
                neg.w   D2              * pos x delta

                lea     texture_code5(PC),A2

                move.w  my_dy,D7        * mulu 14
                addq.w  #1,D7
                move.w  D7,D5
                add.w   D5,D5
                move.w  D5,D6
                lsl.w   #3,D6
                sub.w   D5,D6
                suba.w  D6,A2

                move.w  D2,D4           * fast deltax/my_dx
                move.w  my_dx,D5
                add.w   D5,D5
                mulu    0(A5,D5.w),D4
                move.w  D4,D2
                swap    D4

                move.w  my_dy,D5        * fast dy/my_dy
                add.w   D5,D5
                mulu    0(A5,D5.w),D3
                movea.w D3,A3
                swap    D3

                moveq   #0,D5           * x- buff
                move.w  D5,D6           * y- buff

                jmp     (A2)

* d0= x value
* d1= y value
* d2= nach x
* d3= vor y
* d4= vor x
* d5= x-buff
* d6= y-buff
* a3= nach y

                REPT calc_lines-1
                move.w  D0,(A0)+        * write x
                move.w  D1,calc_lines*2-2(A0) * write y*texturewide (no and!)
                add.w   D2,D5           * x
                subx.w  D4,D0
                add.w   A3,D6           * y
                subx.w  D3,D1
                ENDR

                move.w  D0,(A0)+        	* write x
                move.w  D1,calc_lines*2-2(A0) 	* write y*texturewide (no and!)
                swap    D6
                swap    D7
                rts
                nop
texture_code5:

***** nur dy to calc !!! *****

neg_y_same_x:
                lea     texture_code6(PC),A2

                move.w  my_dy(PC),D7    * mulu 8
                addq.w  #1,D7           * +1 !
                lsl.w   #3,D7
                suba.w  D7,A2

                move.w  my_dy(PC),D5    * fast dy/my_dy
                add.w   D5,D5
                mulu    0(A5,D5.w),D3
                swap    D3

                moveq   #0,D2
                move.w  D1,D2           * clear high word

                jmp     (A2)

* d1= y value
* d2= vor
* d3= nach
* d5= buff

                REPT calc_lines
                move.w  D0,(A0)+        * write x
                move.w  D2,calc_lines*2-2(A0) * write y*texturewide (no and!)
                subx.l  D3,D2
                ENDR
texture_code6:  swap    D6
                swap    D7
                rts


**************************************
******** nur dx to calc !!! **********

same_y:
                sub.w   D0,D2           * delta x ?
                bmi     left_only_x

************ only delta x to right side ***********

                lea     texture_code7(PC),A2

                move.w  my_dy(PC),D7    * mulu 8
                addq.w  #1,D7
                lsl.w   #3,D7
                suba.w  D7,A2

                move.w  my_dy(PC),D5    * fast dy/my_dy
                add.w   D5,D5
                mulu    0(A5,D5.w),D2
                swap    D2

                moveq   #0,D3
                move.w  D0,D3           * clear high word

                jmp     (A2)

* d0= x value
* d2= nach
* d3= vor
* d5= buff

                REPT calc_lines
                move.w  D3,(A0)+        * write x
                move.w  D1,calc_lines*2-2(A0) * write y*texturewide (no and!)
                addx.l  D2,D3
                ENDR
texture_code7:  swap    D6
                swap    D7
                rts

************ only delta x to left side ***********

left_only_x:
                neg.w   D2

                lea     texture_code8(PC),A2

                move.w  my_dy(PC),D7    * mulu 8
                addq.w  #1,D7
                lsl.w   #3,D7
                suba.w  D7,A2

                move.w  my_dy(PC),D5    * fast dy/my_dy
                add.w   D5,D5
                mulu    0(A5,D5.w),D2
                swap    D2

                moveq   #0,D3
                move.w  D0,D3           * clear high word

                jmp     (A2)

* d0= x value
* d2= nach
* d3= vor
* d5= buff

                REPT calc_lines
                move.w  D3,(A0)+        	* write x
                move.w  D1,calc_lines*2-2(A0) 	* write y*texturewide
                subx.l  D2,D3
                ENDR
texture_code8:  swap    D6
                swap    D7
                rts
                

********** U/V Texture Coordinates calculation ***************

calc_positions:

* a0= buffer
                tst.w   my_dy           * falls horizontale -> nix !
                bgt.s   no_hori
                rts

no_hori:
                swap    D6              * use high words
                swap    D7

                move.l  start_point(PC),D0
                move.w  D0,D1
                swap    D0

                move.l  end_point(PC),D2
                move.w  D2,D3
                swap    D2

                sub.w   D1,D3           * delta y
                beq     same_y
                blt     neg_deltay

                sub.w   D0,D2           * delta x
                beq     pos_y_same_x
                bmi     pos_y_neg_x
                
                * 'x view'

*********************************
****** move left to right *******

pos_y_pos_x:
                lea     texture_code1(PC),A2

                move.w  my_dy(PC),D7    * mulu 14
                move.w  D7,D5
                add.w   D5,D5
                move.w  D5,D6
                lsl.w   #3,D6
                sub.w   D5,D6
                suba.w  D6,A2

                move.w  D2,D4           * fast deltax/my_dx
                move.w  my_dx(PC),D5
                add.w   D5,D5
                mulu    0(A5,D5.w),D4
                move.w  D4,D2
                swap    D4

                move.w  my_dy(PC),D5    * fast dy/my_dy
                add.w   D5,D5
                mulu    0(A5,D5.w),D3
                movea.w D3,A3
                swap    D3

                moveq   #0,D5           * x- nachkommateil-z„hler
                move.w  D5,D6           * y- nach

                jmp     (A2)

                REPT calc_lines-1
                move.w  D0,(A0)+        	* write x
                move.w  D1,calc_lines*2-2(A0) 	* write y*texturewide (no and!)
                add.w   D2,D5           	* x
                addx.w  D4,D0
                add.w   A3,D6           	* y
                addx.w  D3,D1
                ENDR

                move.w  D0,(A0)+        	* write x
                move.w  D1,calc_lines*2-2(A0) 	* write y*texturewide (no and!)
                swap    D6
                swap    D7
                rts
                nop
texture_code1:

**************************************
****** move right to left side *******

pos_y_neg_x:
                neg.w   D2              * pos delta x

                lea     texture_code2(PC),A2

                move.w  my_dy(PC),D7    * mulu 14
                move.w  D7,D5
                add.w   D5,D5
                move.w  D5,D6
                lsl.w   #3,D6
                sub.w   D5,D6
                suba.w  D6,A2

                move.w  D2,D4           * fast deltax/my_dx
                move.w  my_dx(PC),D5
                add.w   D5,D5
                mulu    0(A5,D5.w),D4
                move.w  D4,D2
                swap    D4

                move.w  my_dy(PC),D5    * fast dy/my_dy
                add.w   D5,D5
                mulu    0(A5,D5.w),D3
                movea.w D3,A3
                swap    D3

                moveq   #0,D5           * x- buff
                move.w  D5,D6           * y- buff

                jmp     (A2)

* d0= x value
* d1= y value
* d2= nach x
* d3= vor y
* d4= vor x
* d5= x-buff
* d6= y-buff
* a3= nach y

                REPT calc_lines-1
                move.w  D0,(A0)+        * write x
                move.w  D1,calc_lines*2-2(A0) * write y*texturewide (no and!)
                add.w   D2,D5           * x
                subx.w  D4,D0
                add.w   A3,D6           * y
                addx.w  D3,D1
                ENDR

                move.w  D0,(A0)+        * write x
                move.w  D1,calc_lines*2-2(A0) * write y*texturewide (no and!)
                swap    D6
                swap    D7
                rts
                nop
texture_code2:


******************************
***** nur dy to calc !!! *****

pos_y_same_x:
                lea     texture_code3(PC),A2

                move.w  my_dy(PC),D7    * mulu 8
                addq.w  #1,D7
                lsl.w   #3,D7
                suba.w  D7,A2

                move.w  my_dy(PC),D5    * fast dy/my_dy
                add.w   D5,D5
                mulu    0(A5,D5.w),D3
                swap    D3

                moveq   #0,D2
                move.w  D1,D2           * clear high

                jmp     (A2)

* d1= y value
* d2= vor
* d3= nach
* d5= buff

                REPT calc_lines-1
                move.w  D0,(A0)+        * write x
                move.w  D2,calc_lines*2-2(A0) * write y*texturewide (no and!)
                addx.l  D3,D2
                ENDR
texture_code3:  swap    D6
                swap    D7
                rts
                

my_dx:          DC.W 0
my_dy:          DC.W 0
start_point:    DC.L 0
end_point:      DC.L 0

structure_start:DC.L 0
backward:       DC.L 0

******** table precalc ***********

calc_fast_divus:

                lea     fast_divu,A0

                clr.w   (A0)+

                move.w  #319-1,D0
                moveq   #1,D1
                move.l  #$00010000,D2   * 1*2^16
do_fasta:
                move.l  D2,D3
                divu    D1,D3           * 1/ (1-319)
		move.w  D3,(A0)+

                addq.w  #1,D1
                dbra    D0,do_fasta
                rts
                

******** controling/calcing **********

transform_points_texture:
                lea     texture_object,A0

                lea     save_matrixx+18,A2 ; SAVE TAB FŠR MULU
                movem.w dreh_x,D0-D2
                and.w   #%0000001111111111,D0
                and.w   #%0000001111111111,D1 ; AUF TABELLE KšRZEN
                and.w   #%0000001111111111,D2
                add.w   D0,D0
                add.w   D1,D1
                add.w   D2,D2
                lea     cos_tab,A3
                move.w  0(A3,D0.w),D3
                move.w  0(A3,D1.w),D4   ; SIN/COS WERTE HOLEN
                move.w  0(A3,D2.w),D5
                lea     sin_tab,A3
                move.w  0(A3,D0.w),D0
                move.w  0(A3,D1.w),D1
                move.w  0(A3,D2.w),D2
                move.w  D4,D6
                muls    D5,D6
                add.l   D6,D6
                swap    D6
                move.w  D6,-(A2)        ; 9 MATRIXWERTE AUSRECHNEN
                neg.w   D1
                move.w  D1,-(A2)
                neg.w   D1
                move.w  D4,D6
                muls    D2,D6
                add.l   D6,D6
                swap    D6
                neg.w   D6
                move.w  D6,-(A2)
                move.w  D1,D6
                muls    D5,D6
                add.l   D6,D6
                swap    D6
                movea.w D6,A3
                muls    D3,D6
                move.w  D0,D7
                muls    D2,D7
                sub.l   D7,D6
                add.l   D6,D6
                swap    D6
                move.w  D6,-(A2)
                move.w  D3,D6
                muls    D4,D6
                add.l   D6,D6
                swap    D6
                move.w  D6,-(A2)
                muls    D2,D1
                add.l   D1,D1
                swap    D1
                move.w  D1,D6
                muls    D3,D6
                move.w  D0,D7
                muls    D5,D7
                add.l   D7,D6
                add.l   D6,D6
                swap    D6
                neg.w   D6
                move.w  D6,-(A2)
                move.w  A3,D6
                muls    D0,D6
                muls    D3,D2
                add.l   D2,D6
                add.l   D6,D6
                swap    D6
                move.w  D6,-(A2)
                muls    D0,D4
                add.l   D4,D4
                swap    D4
                move.w  D4,-(A2)
                muls    D0,D1
                muls    D5,D3
                sub.l   D1,D3
                add.l   D3,D3
                swap    D3
                move.w  D3,-(A2)

* 3-D TRANSFORM ( 9 MULS )
                move.w  (A0)+,D7        ; ANZ DER PUNKTE
                lea     transformed_pointsx,A2

                movea.w #32000,A3       * min x
                movea.w #-32000,A4      * max x
                movea.w #32000,A5       * min y
                movea.w #-32000,A6      * max y

calc_3dx:       lea     save_matrixx,A1
                movem.w (A0)+,D0-D2
                move.w  D0,D3
                move.w  D1,D4
                move.w  D2,D5
                muls    (A1)+,D0        ; DREHUNG UM ACHSEN
                muls    (A1)+,D4
                muls    (A1)+,D5
                add.l   D4,D0
                add.l   D5,D0
                move.w  D3,D6
                move.w  D1,D4
                move.w  D2,D5
                muls    (A1)+,D3
                muls    (A1)+,D1
                muls    (A1)+,D5
                add.l   D3,D1
                add.l   D5,D1
                muls    (A1)+,D6
                muls    (A1)+,D4
                muls    (A1)+,D2
                add.l   D6,D2
                add.l   D4,D2
                
		add.l   (A1)+,D0
                add.l   (A1)+,D1
                add.l   (A1)+,D2

                asr.l   #6,D0
                asr.l   #6,D1           * central projection
                swap    D2

                IFNE pers
                asl.l   #pers,D2
                ENDC

                divs    D2,D0
                divs    D2,D1
                add.w   mid_xx,D0    * mid x
                add.w   mid_yx,D1    * mid y
                move.w  D0,(A2)+        * save x
                move.w  D1,(A2)+        * save y

******** look for extremas *******

                cmp.w   A3,D0
                bge.s   no_minx
                movea.w D0,A3
no_minx:
                cmp.w   A4,D0
                ble.s   no_maxx
                movea.w D0,A4
no_maxx:
                cmp.w   A5,D1
                bge.s   no_miny
                movea.w D1,A5
no_miny:
                cmp.w   A6,D1
                ble.s   no_maxy
                movea.w D1,A6
no_maxy:

                dbra    D7,calc_3dx

                movem.w A3-A6,min_x

                rts
                
*********************************************