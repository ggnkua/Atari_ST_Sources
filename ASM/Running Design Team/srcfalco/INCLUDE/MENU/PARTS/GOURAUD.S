**************************************
* Gouraud implementation by MIG 1996 *
**************************************

********** Mike`s equ's **************

* Revision F - Optimizing + Painter Algo

******* for data : minus to plus *******

* x: l->r
* y: o->u
* z: v->h

multi_screens   EQU 2

dreh_speed      EQU 4           * 0-8
objekt          EQU 0           * 0-1
pers            EQU 3

max_z_delta     EQU 72
max_distance	equ 256
max_lines      	EQU 200
max_points      EQU 30
max_patterns    EQU 32


goro_wohin      EQU 640*182+253*2
cls_lines       EQU 56
cls_blocks      EQU 4          * 16er bloecke

***************************************
****** FAST - GORO - SHADER ***********
***************************************

filler:         

* d0= scratch
* d1= nachkomma
* d2= -> actual color
* d3= -> count pixels
* d4= nachkomma / vorkomma
* d5= adder
* d6= color tables
* d7= count lines

* a0= screen save
* a1= working screen
* a2= xbuffer right
* a3= actual coloring table
* a4= xbuffer left
* a5= cbuffer right
* a6= divtable

                movea.l screen_2,A0

                lea     x_buffer,A2
                move.w  (A2)+,D7        * line counter
                move.w  (A2)+,D0        * start y

                mulu    #320*2,D0       * screen offset truecolor
                adda.l  D0,A0

                lea     color_tables,A4 * choose pal (32 * 2 byte * 2 * 2 (Black buffer) = 256)
                move.w  poly_color(PC),D1
                lsl.w   #8,D1
                adda.w  D1,A4
                move.l  A4,D6

                lea     x_buffer_left,A4
                lea     c_buffer_right,A5
		lea	div_distance,a6

fill_line:

******** get x1,x2,color1,color2 *********

                move.w  (A4)+,D2        	* x1
                move.w  (A2)+,D3        	* x2
                move.w  max_lines*2(A5),D0      * col1
                move.w  (A5)+,D1        	* col2

********* line distance *********

                sub.w   D2,D3           * line distance
                bpl.s   zeichnen        * delta < 0  => nix zeichnen
                dbra    D7,fill_line
                rts

zeichnen:       movea.l A0,A1           * get screen address
                add.w   D2,D2
                adda.w  D2,A1           * start address

********* coloring ********

                movea.l D6,A3           * actual color table
                sub.w   D0,D1           * color distance
		bpl.s   color_ups
	
		moveq	#32+31,d4
		sub.w	d0,d4
		move.w	d4,d0		* von hinten rein

		neg.w	d1		* positive delta again		

color_ups:      add.w   D0,D0           * color*2
                adda.w  D0,A3           * start color von vorne

		move.w	d3,d4
		lsl.w	#5,d4
		add.w	d1,d4	
		move.l	0(a6,d4.w*4),d4	* Nachkomma/Vorkomma		
	
                tst.w   D4
                beq.s   no_vorkomma
                
                * 'Mit Vorkomma'

* d0 = startcolor
* d4 = Nachkomma/ vorkomma
		
		moveq	#0,d0
		move.w	#0,ccr

****** optimized looping *********

		move.w	d3,d1
		lsr.w	#2,d1		
		beq.s	pix_vor_1
		and.w	#$0003,d3
		subq.w	#1,d1
pix_vor_opt
                rept	4
		move.w  0(A3,D0.w*2),(A1)+ * farbe schreiben
                addx.l  D4,D0
               	endr
		dbra	d1,pix_vor_opt

pix_vor_1	move.w  0(A3,D0.w*2),(A1)+ * farbe schreiben
                addx.l  D4,D0
		dbra    D3,pix_vor_1

                lea     320*2(A0),A0
                dbra    D7,fill_line
                rts
                
                * 'Kein Vorkomma'

no_vorkomma:
		
		swap	d4
                *move.w	d4,d5		* adder
		moveq	#0,d5
		move.w  (A3)+,D2        * actual color

*********** optimized looping *************

		move.w	d3,d1
		lsr.w	#3,d1		
		beq.s	pix_nach_1
		and.w	#$0007,d3
		subq.w	#1,d1
pix_nach_opt
                move.w  D2,(A1)+        * farbe schreiben
                add.w   D4,D5
                bcc.s   keep_old_x1
                move.w  (A3)+,D2        * neue farbe holen
keep_old_x1:
    		move.w  D2,(A1)+        * farbe schreiben
                add.w   D4,D5
                bcc.s   keep_old_x2
                move.w  (A3)+,D2        * neue farbe holen
keep_old_x2:
    		move.w  D2,(A1)+        * farbe schreiben
                add.w   D4,D5
                bcc.s   keep_old_x3
                move.w  (A3)+,D2        * neue farbe holen
keep_old_x3:
    		move.w  D2,(A1)+        * farbe schreiben
                add.w   D4,D5
                bcc.s   keep_old_x4
                move.w  (A3)+,D2        * neue farbe holen
keep_old_x4:
    		move.w  D2,(A1)+        * farbe schreiben
                add.w   D4,D5
                bcc.s   keep_old_x5
                move.w  (A3)+,D2        * neue farbe holen
keep_old_x5:
    		move.w  D2,(A1)+        * farbe schreiben
                add.w   D4,D5
                bcc.s   keep_old_x6
                move.w  (A3)+,D2        * neue farbe holen
keep_old_x6:
    		move.w  D2,(A1)+        * farbe schreiben
                add.w   D4,D5
                bcc.s   keep_old_x7
                move.w  (A3)+,D2        * neue farbe holen
keep_old_x7:
    		move.w  D2,(A1)+        * farbe schreiben
                add.w   D4,D5
                bcc.s   keep_old_x8
                move.w  (A3)+,D2        * neue farbe holen
keep_old_x8:
		dbra	d1,pix_nach_opt

		* Rest *

pix_nach_1	
                move.w  D2,(A1)+        * farbe schreiben
                add.w   D4,D5
                bcc.s   keep_old_1
                move.w  (A3)+,D2        * neue farbe holen
keep_old_1:     dbra    D3,pix_nach_1

                lea     320*2(A0),A0
                dbra    D7,fill_line
                rts
                

******** table precalc ***********

calc_div_st

                lea     div_distance+max_patterns*4,A0 * keine laenge 0 !

                moveq   #1,D2           	* aktuelle laenge

                move.w  #max_distance-2,D0      * laengen
do_lang:        moveq   #max_patterns-1,D1  	* color distances
                moveq   #0,D4	
do_div:
                moveq   #0,D3
                move.w  D4,D3
                beq.s   let_it
                addq.w  #1,D3           * delta +1
let_it:         
		divu    D2,D3
                move.w  D3,D5
                clr.w   D3
                divu    D2,D3

                move.w  D3,(A0)+
                move.w  D5,(A0)+

                addq.w  #1,D4
                dbra    D1,do_div
                addq.w  #1,D2
                dbra    D0,do_lang
                rts


calc_delta:     
                lea     z_tab,A0

                move.w  #(max_z_delta/4)-1,D0
lop_0:          clr.w   (A0)+
                dbra    D0,lop_0

                move.w  #(max_z_delta/4)-1,D0
lop_1:          move.w  #1,(A0)+
                dbra    D0,lop_1

                move.w  #(max_z_delta/2)-1,D0
                moveq   #0,D1
do_delta1:
                move.w  #max_patterns,D2
                mulu    D1,D2
                divu    #max_z_delta/4,D2

		cmp.w	#max_patterns,d2
		blt.s	under
		move.w	#max_patterns-1,d2	
under
                move.w  D2,(A0)+

                addq.w  #1,D1
                dbra    D0,do_delta1
                rts
                
calc_fast_mulus:*

                lea     fast_mulu,A0

                clr.w   (A0)+

                move.w  #319-1,D0
                moveq   #1,D1
                move.l  #$00010000,D2   * 1*2^16
do_fast:
                move.l  D2,D3
                divu    D1,D3           * 1/ (1-319)
                move.w  D3,(A0)+

                addq.w  #1,D1
                dbra    D0,do_fast
                rts
                

******** controling/transforming/color points **********

transform_points:*
                lea     object,A0

                lea     save_matrix+18,A2 ; SAVE TAB FŠR MULU
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
                lea     transformed_points,A2


                movea.w mid_x,A3
                movea.w mid_y,A4

calc_3d:        lea     save_matrix,A1
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

                move.w  D2,4(A2)        * save z value

                IFNE pers
                asl.l   #pers,D2
                ENDC

                divs    D2,D0
                divs    D2,D1
                add.w   A3,D0           * mid x
                add.w   A4,D1           * mid y
                move.w  D0,(A2)+        * save x
                move.w  D1,(A2)+        * save y

                addq.w  #4,A2           * color offset

                dbra    D7,calc_3d

                rts
                
create_color_points:*
                lea     transformed_points+4,A0
                lea     z_tab+max_z_delta,A1

                move.w  object,D0   * counter

                move.w  D0,D1           * save counter

                moveq   #0,D2           * all z

                movea.l A0,A2

********* add all z ***********

get_z:          add.w   (A0),D2
                addq.w  #8,A0
                dbra    D0,get_z

                move.w  D1,D0
                addq.w  #1,D0
                divs    D0,D2           * middle of z

******** now calc all colors *********

make_col:       move.w  D2,D0
                sub.w   (A2),D0         * z-delta
                add.w   D0,D0
                move.w  0(A1,D0.w),(A2) * color of point
                addq.w  #8,A2
                dbra    D1,make_col
                rts
                
control_axes:   *
                lea     dreh_x,A0

                bsr.s   add_x
                bsr.s   add_y
                bsr.s   add_z

                rts

add_x:          move.w  (A0),D0
                addq.w  #dreh_speed,D0
                cmp.w   #1024,D0
                blt.s   ok_x
                subi.w  #1024,D0
ok_x:           move.w  D0,(A0)
                rts

add_y:          move.w  2(A0),D0
                addq.w  #dreh_speed,D0
                cmp.w   #1024,D0
                blt.s   ok_y
                subi.w  #1024,D0
ok_y:           move.w  D0,2(A0)
                rts

add_z:          move.w  4(A0),D0
                addq.w  #dreh_speed,D0
                cmp.w   #1024,D0
                blt.s   ok_z
                subi.w  #1024,D0
ok_z:           move.w  D0,4(A0)
                rts
                

********* business - stuff ************

poly_color:     DC.W 0          * welche farbe ?
current_points: DS.L 4*2

render_gouraud: * 'business stuff'

* a0= shape infos
* a1= trans points
* a2= shape addresses
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
* d7= count polys

                lea     z_buffer,A2

                move.w  (A2)+,D7        * field counter

main_loop:      
		move.l	(a2)+,a0	* get next shape address

		move.w  D7,-(SP)
		move.l	a2,-(sp)

                move.w  (A0)+,poly_color * farbe der flaeche merken

                lea     fast_mulu,A5

                tst.w   (A0)+           * ecken ?
                beq     do_3_point
                

                * '4-fill'
**********************************************
***************** 4-point-fill ***************
**********************************************

                movem.w (A0)+,D0-D3     * get 4 points !

                lea     transformed_points,A1
                lea     current_points(PC),A6

                lea     4*4(A6),A3      * for colors

                move.l  4(A1,D0.w),(A3)+
                move.l  0(A1,D0.w),D0   * x0/y0
                move.l  4(A1,D1.w),(A3)+
                move.l  0(A1,D1.w),D1   * x1/y1
                move.l  4(A1,D2.w),(A3)+
                move.l  0(A1,D2.w),D2   * x2/y2
                move.l  4(A1,D3.w),(A3)+
                move.l  0(A1,D3.w),D3   * x3/y3

                movem.l D0-D3,(A6)

*********** kreuz mulus *******************

                sub.w   D1,D2           * y2-y1
                sub.w   D0,D1           * y1-y0

                move.w  D1,D3
                move.w  D2,D4
                swap    D0
                swap    D1
                swap    D2

                sub.w   D1,D2           * x2-x1
                sub.w   D0,D1           * x1-x0

                muls    D2,D3           * x2-x1*y1-y0
                muls    D1,D4           * x1-x0*y2-y1

                sub.l   D4,D3

                bpl     scan_nothing_4  * unsichtbar

************* y min + max bestimmen ***********

                moveq   #0,D7           * kill gap

                move.w  2(A6),D6
                move.w  D6,D7           * first is min+max

                lea     2+4(A6),A3

                moveq   #4,D0           * we start at 2nd point
                moveq   #0,D5

                moveq   #2,D2           * noch 3 points testen !
do_extrema_4:   move.w  (A3),D4         * y
                cmp.w   D4,D6
                blt.s   no_min_4
                move.w  D0,D5           * save xmin start offset
                move.w  D4,D6
no_min_4:       cmp.w   D4,D7
                bgt.s   no_max_4
                move.w  D4,D7
no_max_4:       lea     4(A3),A3
                addq.w  #4,D0
                dbra    D2,do_extrema_4

                move.w  D5,D0
                swap    D5
                move.w  D0,D5           * in d5 : double start

********** min offset in d5  **********
********** min = d6 / max = d7 *********

                cmp.w   D6,D7           * min=max ?
                bne.s   no_on_line_4

************* falls y1=y2=y3=y4 ***************

                lea     x_buffer,A1

                clr.w   (A1)+
                move.w  D6,(A1)+

                moveq   #0,D6           * clear gaps
                moveq   #0,D7

                move.w  (A6),D6         * first is min/max x
                move.w  D6,D7

                lea     4(A6),A6

                moveq   #2,D4           * noch 3 ecken testen !
find_x_y_4_b:   move.w  (A6),D0
                cmp.w   D0,D6
                blt.s   no_min_x_4_b
                move.w  D0,D6
no_min_x_4_b:   cmp.w   D0,D7
                bgt.s   no_max_x_4_b
                move.w  D0,D7
no_max_x_4_b:   lea     4(A6),A6
                dbra    D4,find_x_y_4_b

                move.w  D6,x_buffer_left
                move.w  D7,(A1)

                illegal

                bra     end_four_point  * schon fertig ...

*********** liegen nicht auf gemeinsamen y line *********

no_on_line_4:   move.w  D7,D0
                sub.w   D6,D0

                lea     x_buffer,A1
                lea     c_buffer_right,A0

                move.w  D0,(A1)+        * lines counter
                move.w  D6,(A1)+        * start y (min)

*************** start calcing ************

* a0= color buffer
* a1= x buffer
* a2=
* a3= col 1
* a4= col 2
* a5= fast mulu
* a6= points buffer

* d0=
* d1=
* d2=
* d3=
* d4=
* d5= point offset
* d6= ecken counter
* d7= minimum

                moveq   #3,D6           * ecken counter

start_calc_4_a:
                move.l  0(A6,D5.w),D0
                movea.w 4*4(A6,D5.w),A3

                move.w  D0,D1           * y1
                swap    D0              * x1

                addq.w  #4,D5           * next points offset
                and.w   #3*4,D5

                cmp.w   D7,D1           * y max erreicht ?
                beq.s   go_max_4

                move.l  0(A6,D5.w),D2
                movea.w 4*4(A6,D5.w),A4

                moveq   #0,D3
                move.w  D2,D3           * y2
                clr.w   D2
                swap    D2              * y1

                bsr     calc_line
                bsr     calc_colors

                dbra    D6,start_calc_4_a
                bra.s   end_four_point

*********** other direction *************

go_max_4:       lea     x_buffer_left,A1
                lea     c_buffer_left,A0

                swap    D5

start_calc_4_b:
                move.l  0(A6,D5.w),D0
                movea.w 4*4(A6,D5.w),A3

                move.w  D0,D1
                swap    D0

                subq.w  #4,D5
                and.w   #3*4,D5

                cmp.w   D7,D1           * y max erreicht ?
                beq.s   end_four_point

                move.l  0(A6,D5.w),D2
                movea.w 4*4(A6,D5.w),A4

                moveq   #0,D3
                move.w  D2,D3
                clr.w   D2
                swap    D2

                bsr     calc_line
                bsr     calc_colors

                dbra    D6,start_calc_4_b

************ all calculated ... now fill it ***************

end_four_point:
                bsr     filler

scan_nothing_4: movea.l (SP)+,A2
                move.w  (SP)+,D7
                dbra    D7,main_loop
                rts
                
                * '3-fill'
**********************************************
***************** 3-point-fill ***************
**********************************************

do_3_point:     movem.w (A0)+,D0-D2     * get 3 points !

                lea     transformed_points,A1
                lea     current_points(PC),A6

                lea     3*4(A6),A3      * for colors

                move.w  4(A1,D0.w),(A3)+
                move.l  0(A1,D0.w),D5   * x0/y0
                move.w  4(A1,D1.w),(A3)+
                move.l  0(A1,D1.w),D6   * x1/y1
                move.w  4(A1,D2.w),(A3)+
                move.l  0(A1,D2.w),D7   * x2/y2

                movem.l D5-D7,(A6)

                move.l  D5,D0           * save x-y
                move.l  D6,D1
                move.l  D7,D2

*********** kreuz mulus *******************

                sub.w   D1,D2           * y2-y1
                sub.w   D0,D1           * y1-y0

                move.w  D1,D3
                move.w  D2,D4
                swap    D0
                swap    D1
                swap    D2

                sub.w   D1,D2           * x2-x1
                sub.w   D0,D1           * x1-x0

                muls    D2,D3           * x2-x1*y1-y0
                muls    D1,D4           * x1-x0*y2-y1

                sub.l   D4,D3

                bpl     scan_nothing_3

*********** flaeche sichtbar ***********

                moveq   #0,D0
                moveq   #0,D4
                move.w  D5,D4           * max
                move.w  D5,D3           * min

                cmp.w   D6,D3
                blt.s   no_low1
                move.w  D6,D3
                moveq   #4,D0
no_low1:        cmp.w   D6,D4
                bgt.s   no_high1
                move.w  D6,D4
no_high1:       cmp.w   D7,D3
                blt.s   no_low2
                move.w  D7,D3
                moveq   #8,D0
no_low2:        cmp.w   D7,D4
                bgt.s   no_high2
                move.w  D7,D4
no_high2:

                cmp.w   D3,D4           * min=max ?
                bne.s   no_on_line_3

************* falls y1=y2=y3 ***************

                lea     x_buffer,A1

                clr.w   (A1)+
                move.w  D3,(A1)+

                swap    D5
                swap    D6
                swap    D7

                move.w  D5,D0           * min x
                move.w  D5,D1           * max x

                cmp.w   D6,D0
                blt.s   no_low_x1
                move.w  D6,D0
no_low_x1:      cmp.w   D6,D1
                bgt.s   no_high_x1
                move.w  D6,D1
no_high_x1:     cmp.w   D7,D0
                blt.s   no_low_x2
                move.w  D7,D0
no_low_x2:      cmp.w   D7,D1
                bgt.s   no_high_x2
                move.w  D7,D1
no_high_x2:
                illegal

                moveq   #0,D6
                moveq   #0,D7           * clear gaps

                move.w  D0,x_buffer_left
                move.w  D1,(A1)

                bra     end_three_point * schon fertig ...

*********** liegen nicht auf gemeinsamen y line *********

no_on_line_3:
                move.w  D4,D2
                sub.w   D3,D2

                moveq   #0,D6
                moveq   #0,D7
                move.w  D4,D7           * save max in d7

                lea     x_buffer,A1
                lea     c_buffer_right,A0

                move.w  D2,(A1)+        * lines counter
                move.w  D3,(A1)+        * start y (min)

                movea.l fall(PC,D0.w),A3
                jmp     (A3)

fall:           DC.L d0_low,d1_low,d2_low

* a0-a1   used  / a2,a3,a4=work  / a5= fast mulu a6= points
* d7=max
                
                * 'd0'
*********** d0 is lowest *********

d0_low:
                move.l  (A6),D0
                move.w  D0,D1
                swap    D0

                moveq   #0,D3
                move.l  4(A6),D2
                move.w  D2,D3
                clr.w   D2
                swap    D2

                bsr     calc_line
                movea.w 12(A6),A3
                movea.w 14(A6),A4
                bsr     calc_colors

                cmp.w   4+2(A6),D7
                beq.s   other_direct1

                move.l  4(A6),D0
                move.w  D0,D1
                swap    D0

                moveq   #0,D3
                move.l  8(A6),D2
                move.w  D2,D3
                clr.w   D2
                swap    D2

                bsr     calc_line
                movea.w 14(A6),A3
                movea.w 16(A6),A4
                bsr     calc_colors

                lea     x_buffer_left,A1
                lea     c_buffer_left,A0

                move.l  (A6),D0
                move.w  D0,D1
                swap    D0

                moveq   #0,D3
                move.l  8(A6),D2
                move.w  D2,D3
                clr.w   D2
                swap    D2

                bsr     calc_line
                movea.w 12(A6),A3
                movea.w 16(A6),A4
                bsr     calc_colors

                bra     end_three_point

other_direct1:
                lea     x_buffer_left,A1
                lea     c_buffer_left,A0

                move.l  (A6),D0
                move.w  D0,D1
                swap    D0

                moveq   #0,D3
                move.l  8(A6),D2
                move.w  D2,D3
                clr.w   D2
                swap    D2

                bsr     calc_line
                movea.w 12(A6),A3
                movea.w 16(A6),A4
                bsr     calc_colors

                move.l  8(A6),D0
                move.w  D0,D1
                swap    D0

                moveq   #0,D3
                move.l  4(A6),D2
                move.w  D2,D3
                clr.w   D2
                swap    D2

                bsr     calc_line
                movea.w 16(A6),A3
                movea.w 14(A6),A4
                bsr     calc_colors

                bra     end_three_point

                
                * 'd1'
*********** d1 is lowest *********

d1_low:
                move.l  4(A6),D0
                move.w  D0,D1
                swap    D0

                moveq   #0,D3
                move.l  8(A6),D2
                move.w  D2,D3
                clr.w   D2
                swap    D2

                bsr     calc_line
                movea.w 14(A6),A3
                movea.w 16(A6),A4
                bsr     calc_colors

                cmp.w   8+2(A6),D7
                beq.s   other_direct2

                move.l  8(A6),D0
                move.w  D0,D1
                swap    D0

                moveq   #0,D3
                move.l  (A6),D2
                move.w  D2,D3
                clr.w   D2
                swap    D2

                bsr     calc_line
                movea.w 16(A6),A3
                movea.w 12(A6),A4
                bsr     calc_colors

                lea     x_buffer_left,A1
                lea     c_buffer_left,A0

                move.l  4(A6),D0
                move.w  D0,D1
                swap    D0

                moveq   #0,D3
                move.l  (A6),D2
                move.w  D2,D3
                clr.w   D2
                swap    D2

                bsr     calc_line
                movea.w 14(A6),A3
                movea.w 12(A6),A4
                bsr     calc_colors

                bra     end_three_point

other_direct2:
                lea     x_buffer_left,A1
                lea     c_buffer_left,A0

                move.l  4(A6),D0
                move.w  D0,D1
                swap    D0

                moveq   #0,D3
                move.l  (A6),D2
                move.w  D2,D3
                clr.w   D2
                swap    D2

                bsr     calc_line
                movea.w 14(A6),A3
                movea.w 12(A6),A4
                bsr     calc_colors

                move.l  (A6),D0
                move.w  D0,D1
                swap    D0

                moveq   #0,D3
                move.l  8(A6),D2
                move.w  D2,D3
                clr.w   D2
                swap    D2

                bsr     calc_line
                movea.w 12(A6),A3
                movea.w 16(A6),A4
                bsr     calc_colors

                bra     end_three_point

                
                * 'd2'
*********** d2 is lowest *********

d2_low:
                move.l  8(A6),D0
                move.w  D0,D1
                swap    D0

                moveq   #0,D3
                move.l  (A6),D2
                move.w  D2,D3
                clr.w   D2
                swap    D2

                bsr     calc_line
                movea.w 16(A6),A3
                movea.w 12(A6),A4
                bsr     calc_colors

                cmp.w   2(A6),D7
                beq.s   other_direct3

                move.l  (A6),D0
                move.w  D0,D1
                swap    D0

                moveq   #0,D3
                move.l  4(A6),D2
                move.w  D2,D3
                clr.w   D2
                swap    D2

                bsr     calc_line
                movea.w 12(A6),A3
                movea.w 14(A6),A4
                bsr     calc_colors

                lea     x_buffer_left,A1
                lea     c_buffer_left,A0

                move.l  8(A6),D0
                move.w  D0,D1
                swap    D0

                moveq   #0,D3
                move.l  4(A6),D2
                move.w  D2,D3
                clr.w   D2
                swap    D2

                bsr.s   calc_line
                movea.w 16(A6),A3
                movea.w 14(A6),A4
                bsr     calc_colors

                bra.s   end_three_point

other_direct3:
                lea     x_buffer_left,A1
                lea     c_buffer_left,A0

                move.l  8(A6),D0
                move.w  D0,D1
                swap    D0

                moveq   #0,D3
                move.l  4(A6),D2
                move.w  D2,D3
                clr.w   D2
                swap    D2

                bsr.s   calc_line
                movea.w 16(A6),A3
                movea.w 14(A6),A4
                bsr     calc_colors

                move.l  4(A6),D0
                move.w  D0,D1
                swap    D0

                moveq   #0,D3
                move.l  (A6),D2
                move.w  D2,D3
                clr.w   D2
                swap    D2

                bsr.s   calc_line
                movea.w 14(A6),A3
                movea.w 12(A6),A4
                bsr     calc_colors

                
                * 'for all'
************ all calculated ... now fill it ***************

end_three_point:

                bsr     filler

scan_nothing_3: movea.l (SP)+,A2
                move.w  (SP)+,D7
                dbra    D7,main_loop
                rts
                

                * 'calc_line'
calc_line:

* a1= buffer
* a2= work
* a5= fast mulu tab
* d0= x
* d1= vorkomma
* d2= dx / nachkomma
* d3= dy

* output : d4 : dy

                sub.w   D1,D3           * dy
                ble     leave_this      * dy<=0 ? => nix ...

                sub.w   D0,D2           * dx
                beq     zero_dx
                bmi     neg_dx          * other direction

*************************************************************
		
		move.w	d3,d4

                divu    D3,D2           * dx/dy ==> d2 = d step x
                move.w  D2,D1           * vorkommateil

                swap    D2
                mulu    0(A5,D3.w*2),D2   	* nachkomma

                move.w  D0,(A1)+
                subq.w  #1,D3
                bmi     leave_this

                add.w   D3,D3
                movea.w D3,A2
                add.w   D3,D3
                add.w   A2,D3

                lea     code_end_1(PC),A2
                suba.w  D3,A2

                moveq   #0,D3           * nachkommateil-z„hler

                jmp     (A2)

                REPT max_lines-1
                add.w   D2,D3           * step durchfhren
                addx.w  D1,D0           * berlauf merken
                move.w  D0,(A1)+        * x-wert sichern
                ENDR
code_end_1:     add.w   D2,D3           * step durchfhren
                addx.w  D1,D0           * berlauf merken
                move.w  D0,(A1)+        * x-wert sichern
                rts

************************************************************

neg_dx:
		move.w	d3,d4
                neg.w   D2              * wieder positiv machen

                divu    D3,D2           * dx/dy ==> d4 = d step x
                move.w  D2,D1           * vorkommateil

                swap    D2
                mulu    0(A5,D3.w*2),D2   * nachkomma

                move.w  D0,(A1)+
                subq.w  #1,D3
                bmi     leave_this

                add.w   D3,D3
                movea.w D3,A2
                add.w   D3,D3
                add.w   A2,D3

                lea     code_end_2(PC),A2
                suba.w  D3,A2

                moveq   #0,D3           * nachkommateil-z„hler

                jmp     (A2)

                REPT max_lines-1
                add.w   D2,D3           * step durchfhren
                subx.w  D1,D0           * berlauf merken
                move.w  D0,(A1)+        * x-wert sichern
                ENDR
code_end_2:     add.w   D2,D3           * step durchfhren
                subx.w  D1,D0           * berlauf merken
                move.w  D0,(A1)+        * x-wert sichern
                rts

**************************************************************

zero_dx:
                move.w  D3,D4           * save dy

                lea     code_end_3(PC),A2

                add.w   D3,D3
                suba.w  D3,A2

                jmp     (A2)

                REPT max_lines-1
                move.w  D0,(A1)+        ; X-wert sichern
                ENDR
code_end_3:     move.w  D0,(A1)+
                rts

**************************************************************

leave_this:     move.w  D3,D4           * save dy
                rts
                
                * 'calc_colors'
calc_colors:

* a0= buffer
* a3= color 1
* a4= color 2
* d4= dy

                tst.w   D4              * dy neg or 0 ??? => raus !
                ble     leave_this2

                moveq   #0,D1           * clear high word
                move.w  A3,D0           * get start+end colors
                move.w  A4,D1

                sub.w   D0,D1           * color delta
                beq     same_color
                bmi     color_down

*************************************

color_up:
                divu    D4,D1           * dy/colordelta
                move.w  D1,D2           * vorkommateil

                swap    D1
                mulu    0(A5,D4.w*2),D1   * nachkomma

                move.w  D0,(A0)+
                subq.w  #1,D4
                bmi     leave_this2

                lea     colorcode_end_1(PC),A2

                add.w   D4,D4
                move.w  D4,D3
                add.w   D4,D4
                add.w   D4,D3
                suba.w  D3,A2

                moveq   #0,D3           * nachkommateil-z„hler

                jmp     (A2)

                REPT max_lines-1
                add.w   D1,D3           * nach step
                addx.w  D2,D0           * vor step
                move.w  D0,(A0)+        * color
                ENDR
colorcode_end_1:add.w   D1,D3
                addx.w  D2,D0
                move.w  D0,(A0)+
                rts

************************************************************

color_down:
                neg.w   D1              * wieder positiv machen

                divu    D4,D1           * dy/colordelta
                move.w  D1,D2           * vorkommateil

                swap    D1
                mulu    0(A5,D4.w*2),D1   * nachkomma

                move.w  D0,(A0)+
                subq.w  #1,D4
                bmi     leave_this2

                lea     colorcode_end_2(PC),A2

                add.w   D4,D4
                move.w  D4,D3
                add.w   D4,D4
                add.w   D4,D3
                suba.w  D3,A2

                moveq   #0,D3           * nachkommateil-z„hler

                jmp     (A2)

                REPT max_lines-1
                add.w   D1,D3           * nach step
                subx.w  D2,D0           * vor step
                move.w  D0,(A0)+        * color
                ENDR
colorcode_end_2:add.w   D1,D3
                subx.w  D2,D0
                move.w  D0,(A0)+
                rts

**************************************************************

same_color:
                lea     colorcode_end_3(PC),A2

                add.w   D4,D4
                suba.w  D4,A2

                jmp     (A2)

                REPT max_lines-1
                move.w  D0,(A0)+        ; X-wert sichern
                ENDR
colorcode_end_3:move.w  D0,(A0)+

*******************************************

leave_this2:    rts
                

************ screen restoring ***************

save_screen

		lea	background,a0
		adda.l	#goro_wohin-640*6-8*2,a1
			
		move.w	#cls_lines-1,d0
get_line
		move.l	a1,a2
		move.w	#cls_blocks-1,d1
get_block	
		rept	8
		move.l	(a2)+,(a0)+
		endr
		dbra	d1,get_block

		lea	640(a1),a1

		dbra	d0,get_line
		rts


                
restore_screen:   
                movea.l screen_2,A0 * current screen

use_goro_routine
                adda.l  #goro_wohin-8*2-640*6,A0
		lea	background,a1

                move.w  #cls_lines-1,D7
clear_line:
off             SET 0
                REPT cls_blocks
                movem.l	(a1)+,d0-d6/a2
		movem.l D0-D6/A2,off(A0)
off             SET off+32
                ENDR
                lea     640(A0),A0
                dbra    D7,clear_line
                rts

restore_screen_texture:   
                movea.l screen_1,A0 * current screen
                bra.s	use_goro_routine


****************************************

z_sorting:     
                lea     flach_info,A0
                lea     z_buffer,A1
                movea.l A1,A5
                lea     transformed_points,A2

                move.w  (A0)+,D0
                move.w  D0,(A1)+

                moveq   #0,D7           * flach offset

make_mittel:    tst.w   2(A0)
                beq.s   drei_punkt

********** 4 points *********

                movem.w 4(A0),D1-D4

                move.w  6(A2,D1.w),D1
                add.w   6(A2,D2.w),D1
                add.w   6(A2,D3.w),D1
                add.w   6(A2,D4.w),D1

                asr.w   #2,D1           * z1+z2+z3+z4/4
                move.w  D7,(A1)+        * flach offset
                move.w  D1,(A1)+        * z-mittel

                lea     6*2(A0),A0
                addi.w  #6*2,D7

                dbra    D0,make_mittel
                bra.s   thats_all

********* 3 points **********

drei_punkt:     movem.w 4(A0),D1-D3

                moveq   #0,D4
                move.w  4(A2,D1.w),D4
                add.w   4(A2,D2.w),D4
                add.w   4(A2,D3.w),D4

                divs    #3,D4           * z1+z2+z3/3
                move.w  D7,(A1)+        * flach offset
                move.w  D4,(A1)+        * z-mittel

                lea     5*2(A0),A0
                addi.w  #5*2,D7

                dbra    D0,make_mittel

thats_all:

******** selection sort *********

                movea.l A5,A0
                bsr.s   select_sort

******* calc flach adresses *******

                move.w  (A5)+,D0
                lea     flach_info+2,A0
do_list:
                move.l  (A5),D1
                swap    D1
                lea     0(A0,D1.w),A1
                move.l  A1,(A5)+
                dbra    D0,do_list
                rts


select_sort:    
                move.w  (A0)+,D0        * main counter
                beq.s   schon_fertig    * nur ein eintrag -> fertig

main_lop:       move.l  (A0),D2         * max
                lea     4(A0),A1        * search pointer
                movea.l A1,A2           * max pointer +4

                subq.w  #1,D0
                bmi.s   schon_fertig    * war letzter eintrag
                move.w  D0,D1           * counter for inner loop

search_it:      move.l  (A1)+,D3        * eintrag holen
                cmp.w   D2,D3           * groesser ?
                ble.s   no_min          * nein
                move.l  D3,D2           * new max
                movea.l A1,A2           * new max pointer +4
no_min:         dbra    D1,search_it

                move.l  (A0),-4(A2)     * swap entries
                move.l  D2,(A0)+
                bra.s   main_lop

schon_fertig:   rts


*****************************************++