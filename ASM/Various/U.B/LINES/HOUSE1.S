**********************************************************************
*  house1.s         14.1.1986                                        *
*  Display a wire-model house Uwe Braun 1985  Version 1.1            *
*                                                                    *
**********************************************************************

          .globl    main,xoffs,yoffs,zoffs,offx,offy,offz
          .globl    viewx,viewy,viewz
          .globl    wlinxy,setrotdp,inp_chan,pointrot
          .text


main:
          jsr       apinit       * Announce program
          jsr       grafhand     * Get screen handler
          jsr       openwork     * Announce screen
          jsr       mouse_off    * Turn off mouse
          jsr       getreso      * which monitor is connected ?
          jsr       setcocli     * Set clip window

          jsr       makewrld     * Create the world system
          jsr       worldset     * Pass the world parameters

          jsr       setrotdp     * initialize obs. ref. point
          jsr       clwork       * erase both screen pages
          jsr       pagedown     * Display logical screen page
          jsr       clwork
          jsr       inp_chan     * Input and change parameters

mainlop1:
          jsr       pointrot     * rotate around obs. ref. point
          jsr       pers         * perspective transformation
          jsr       drawn1       * Draw lines in linxy array
          jsr       pageup       * Display physical screen page

          jsr       inp_chan     * Input new parameters
          jsr       clwork       * erase logical screen page
          jsr       pointrot     * Rotate around Rot. ref. point
          jsr       pers         * Transform. of new points
          jsr       drawn1       * draw in logical page, then
          jsr       pagedown     * display this logical page
          jsr       inp_chan     * Input and change parameters
          jsr       clwork       * erase physical page
          jmp       mainlop1     * to main loop

mainend:  move.l    physbase,logbase

          jsr       pageup       * switch to normal display page
          rts                    * back to linkfile, and end

********************************************************************
* Remove all accumulated characters in the keyboard buffer         *
********************************************************************

clearbuf: move.w    #$b,-(a7)    * Gemdos funct. Character in buffer?
          trap      #1
          addq.l    #2,a7
          tst.w     d0           * If yes, get character
          beq       clearend     * If no, terminate
          move.w    #1,-(a7)     * Gemdos funct.CONIN
          trap      #1           * repeat until all characters are
          addq.l    #2,a7        * removed from the buffer
          bra       clearbuf

clearend: rts

**********************************************************************
* Change observation parameters with keyboard sensing                *
* Angle increments, location of the projection plane, etc.           *
**********************************************************************

inp_chan: jsr       inkey        * Read keyboard, code in D0
          cmp.b     #'D',d0      * shift D = print
          bne       inpwait
          jsr       scrdmp       * make hardcopy

inpwait:  swap      d0           * test D0, if
          cmp.b     #$4d,d0      * Cursor-right
          bne       inp1
          addq.w    #1,ywplus    * if yes, add one to Y-angle
          bra       inpend1      * increment and continue

inp1:     cmp.b     #$4b,d0      * Cursor-left, if yes, then
          bne       inp2         * subtract one from Y-angle
          subq.w    #1,ywplus    * increment
          bra       inpend1

inp2:     cmp.b     #$50,d0      * Cursor-down, if yes
          bne       inp3
          addq.w    #1,xwplus    * then add one to X-angle increment
          bra       inpend1

inp3:     cmp.b     #$48,d0      * Cursor-up
          bne       inp3a
          subq.w    #1,xwplus    * subtract one
          bra       inpend1

inp3a:    cmp.b     #$61,d0      * Undo key
          bne       inp3b
          subq.w    #1,zwplus
          bra       inpend1

inp3b:    cmp.b     #$62,d0      * Help key
          bne       inp4
          addq.w    #1,zwplus
          bra       inpend1

inp4:     cmp.b     #$4e,d0      * plus key on numerical keypad
          bne       inp5         * if yes, subtract 25 from location
          sub.w     #25,dist     * Projection plane (Z-coordinate)
          bra       inpend1
inp5:     cmp.b     #$4a,d0      * minus key on the numerical keypad
          bne       inp6         *
          add.w     #25,dist     * if yes, add 25
          bra       inpend1

inp6:     cmp.b     #$66,d0      * astersisk key on numerical keypad
          bne       inp7         * if yes, subtract 15 from rotation
          sub.w     #15,rotdpz   * point Z-coordinate
          bra       inpend1      * Make changes

inp7:     cmp.b     #$65,d0      * Division key on num.keypad
          bne       inp10
          add.w     #15,rotdpz   * add 15
          bra       inpend1

inp10:    cmp.b     #$44,d0      * F10 activated ?
          bne       inpend1
          addq.l    #4,a7        * if yes, jump to
          bra       mainend      * program end

inpend1:  move.w    hyangle,d1    * Rotation angle about Y-axis
          add.w     ywplus,d1    * add increment
          cmp.w     #360,d1      * if larger than 360, then
          bge       inpend2      * subtract 360
          cmp.w     #-360,d1     * is smaller than 360, then
          ble       inpend3      * add 360
          bra       inpend4
inpend2:  sub.w     #360,d1
          bra       inpend4
inpend3:  add.w     #360,d1

inpend4:  move.w    d1,hyangle

          move.w    hxangle,d1    * proceed in the same manner
          add.w     xwplus,d1    * with the rotation angle about
          cmp.w     #360,d1      * the X-axis
          bge       inpend5
          cmp.w     #-360,d1
          ble       inpend6
          bra       inpend7
inpend5:  sub.w     #360,d1
          bra       inpend7
inpend6:  add.w     #360,d1

inpend7:  move.w    d1,hxangle    * store angle

          move.w    hzangle,d1
          add.w     zwplus,d1
          cmp.w     #360,d1
          bge       inpend8
          cmp.w     #-360,d1
          ble       inpend9
          bra       inpend10
inpend8:  sub.w     #360,d1
          bra       inpend10
inpend9:  add.w     #360,d1

inpend10: move.w    d1,hzangle
          rts


*****************************************************************
* Initialize the rotation reference point to [0,0,0]            *
*****************************************************************

setrotdp: move.w    #0,d1         * set the start-rotation-
          move.w    d1,rotdpx     * datum-point
          move.w    d1,rotdpy
          move.w    d1,rotdpz
          move.w    #0,hyangle    * Start-rotation angle
          move.w    #0,hzangle
          move.w    #0,hxangle
          rts

*******************************************************************
* Rotation around one point, the rotation reference point         *
*******************************************************************

pointrot: move.w    hxangle,xangle * rotate the world around the angle
          move.w    hyangle,yangle * hxangle, hyangle, hzangle about the
          move.w    hzangle,zangle
          move.w    rotdpx,d0      * rotation reference point
          move.w    rotdpy,d1
          move.w    rotdpz,d2
          move.w    d0,xoffs       * add for back transformation.
          move.w    d1,yoffs
          move.w    d2,zoffs
          neg.w     d0
          neg.w     d1
          neg.w     d2
          move.w    d0,offx      * subtract for transformation.
          move.w    d1,offy
          move.w    d2,offz
          jsr       matinit      * Matrix initialization
          jsr       zrotate      * first rotate around Z-axis
          jsr       yrotate      * rotate 'matrix' around Y-axis
          jsr       xrotate      * then rotate around X-axis
          jsr       rotate       * Multiply points with the matrix.
          rts
**********************************************************************
* Creation of the world system from the object data                  *
**********************************************************************

makewrld: move.l    #housdatx,a1 * create the world system by
          move.l    #housdaty,a2
          move.l    #housdatz,a3
          move.l    #worldx,a4
          move.l    #worldy,a5
          move.l    #worldz,a6
          move.w    hnummark,d0
          ext.l     d0
          subq.l    #1,d0
makewl1:  move.w    (a1)+,(a4)+  * copying the house data into the
          move.w    (a2)+,(a5)+  * world data
          move.w    (a3)+,(a6)+
          dbra      d0,makewl1
          move.w    hnumline,d0
          ext.l     d0
          subq.l    #1,d0
          move.l    #houslin,a1
          move.l    #wlinxy,a2
makewl2:  move.l    (a1)+,(a2)+
          dbra      d0,makewl2
          rts

*********************************************************************
* Pass the world parameters to the link file variables              *
*********************************************************************

worldset: move.l    #worldx,datx * Pass variables for
          move.l    #worldy,daty * the rotation routine
          move.l    #worldz,datz
          move.l    #viewx,pointx
          move.l    #viewy,pointy
          move.l    #viewz,pointz
          move.l    #wlinxy,linxy
          move.w    picturex,x0
          move.w    picturey,y0
          move.w    proz,zobs
          move.w    r1z1,dist
          move.l    #screenx,xplot
          move.l    #screeny,yplot
          move.w    hnumline,numline
          move.w    hnummark,nummark
          rts

*********************************************************************
* sense current display resolution and set coordinate origin of the *
* screen system to the center of the screen                         *
*********************************************************************

getreso:  move.w    #4,-(a7)
          trap      #14
          addq.l    #2,a7
          cmp.w     #2,d0
          bne       getr1
          move.w    #320,picturex    * for monochrome monitor
          move.w    #200,picturey
          bra       getrend
getr1:    cmp.w     #1,d0
          bne       getr2
          move.w    #320,picturex    * medium resolution (640*200)
          move.w    #100,picturey
          bra       getrend
getr2:    move.w    #160,picturex    * low resolultion (320*200)
          move.w    #100,picturey
getrend:  rts


**********************************************************************
* Hardcopy of the display after activating Shift d on keyboard       *
**********************************************************************

scrdmp:   move.w    #20,-(a7)
          trap      #14
          addq.l    #2,a7
          jsr       clearbuf     * prevent another hardcopy
          rts

*********************************************************************
* Sets the limit of the display window for the draw-line algorithm  *
* built into the Cohen-Sutherland clip algorithm                    *
* The limits are freely selectable by the user, making the draw-    *
* line algorithm very flexible.                                     *
*********************************************************************

setcocli: move.w    #0,clipxule  * Clip    left  X-Coord.
          move.w    #0,clipyule  *    "          Y-Coord
          move.w    picturex,d1
          lsl.w     #1,d1        * times two
          subq.w    #1,d1        * minus one equal
          move.w    d1,clipxlri  * 639 for monochrom
          move.w    picturey,d1
          lsl.w     #1,d1        * times two minus one equal
          subq.w    #1,d1        * 399 for monochrom
          move.w    d1,clipylri  * Clip     right  Y-Coord
          rts

          .even


***********************************************************************
* Here begins the variable area for the program module                *
*                                                                     *
***********************************************************************
***********************************************************************

***********************************************************************
*                                                                     *
*         Definition of the house                                     *
*                                                                     *
***********************************************************************

          .data

housdatx: .dc.w     -30,30,30,-30,30,-30,-30,30,0,0,-10,-10,10,10
          .dc.w     30,30,30,30,30,30,30,30,30,30,30,30

housdaty: .dc.w     30,30,-30,-30,30,30,-30,-30,70,70,-30,0,0,-30
          .dc.w     20,20,0,0,20,20,0,0
          .dc.w     -10,-10,-30,-30
housdatz: .dc.w     60,60,60,60,-60,-60,-60,-60,60,-60,60,60,60,60
          .dc.w     40,10,10,40,-10,-40,-40,-10
          .dc.w     0,-20,-20,0

houslin:  .dc.w     1,2,2,3,3,4,4,1,2,5,5,8,8,3,8,7,7,6,6,5,6,1,7,4
          .dc.w     9,10,1,9,9,2,5,10,6,10,11,12,12,13,13,14
          .dc.w     15,16,16,17,17,18,18,15,19,20,20,21,21,22,22,19
          .dc.w     23,24,24,25,25,26,26,23

hnummark: .dc.w     26    * Number of corner points of the house
hnumline: .dc.w     32    * Number of lines of the house

hxangle:   .dc.w     0     * Rotation angle of the house around X-axis
hyangle:   .dc.w     0     *         "        "         "  Y-axis
hzangle:   .dc.w     0     *         "        "         "  Z-axis

xwplus:   .dc.w     0     * Angle increment around the X-axis
ywplus:   .dc.w     0     * Angle increment around the Y-axis
zwplus:   .dc.w     0     * Angle increment around the Z-axis

picturex: .dc.w     320   * Definition of zero point of display
picturey: .dc.w     200   * here it is in the display center
rotdpx:   .dc.w     0     * Rotation datum point
rotdpy:   .dc.w     0
rotdpz:   .dc.w     0


r1z1:     .dc.w     0
normz:    .dc.w     1500



          .bss

plusrot:  .ds.l     1
first:    .ds.l     1
second:   .ds.w     1
delta1:   .ds.w     1

          .data

flag:     .dc.b     1
          .even

          .bss

diffz:    .ds.w     1

dx:       .ds.w     1
dy:       .ds.w     1
dz:       .ds.w     1

worldx:    .ds.w     1600        * World coordinate array
worldy:    .ds.w     1600
worldz:    .ds.w     1600

viewx:    .ds.w     1600         * View coordinate array
viewy:    .ds.w     1600
viewz:    .ds.w     1600

screenx:  .ds.w     1600         * Display coordinate array
screeny:  .ds.w     1600


wlinxy:   .ds.l     3200         * Line array

          .data

prox:     .dc.w     0            * Coordinates of the Projection-
proy:     .dc.w     0            * center, on the positive
proz:     .dc.w     1500         * Z-axis

          .data

offx:     .dc.w     0            * Transformation during Rotation
offy:     .dc.w     0            * to point [offx,offy,offz]
offz:     .dc.w     0
xoffs:    .dc.w     0            * Back transformation to Point
yoffs:    .dc.w     0            * [xoff,yoffs,zoffs]
zoffs:    .dc.w     0
          .bss
loopc:    .ds.l     1
          .end
