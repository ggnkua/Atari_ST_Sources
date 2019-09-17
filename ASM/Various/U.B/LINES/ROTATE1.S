**********************************************************************
*  rotate1.s         16.1.1986                                       *
*  Creation of rotation bodies Uwe Braun 1985  Version 2.0           *
*                                                                    *
**********************************************************************
          .text
          .globl    main,xoffs,yoffs,zoffs,offx,offy,offz
          .globl    viewx,viewy,viewz
          .globl    wlinxy,mouse_off,setrotdp,inp_chan,pointrot

main:
          jsr       apinit       * Announce program
          jsr       grafhand     * Get screen handle
          jsr       openwork     * Display
          jsr       mouse_off    * Turn off mouse
          jsr       getreso      * Which monitor is connected ?
          jsr       setcocli     * Set clip window

          jsr       makerot1

          jsr       makewrld     * Create world system
          jsr       wrld2set     * Pass world parameters

          jsr       setrotdp     * initialize observation ref. point
          jsr       clwork
          jsr       pagedown     * Display logical screen page
          jsr       clwork
          jsr       inp_chan     * Input and change parameters

mainlop1:
          jsr       pointrot     * rotate around observation ref. point
          jsr       pers         * Perspective transformation
          jsr       drawn1
          jsr       pageup       * Display physical page
          jsr       inp_chan     * Input new parameters
          jsr       clwork       * Erase logical page
          jsr       pointrot     * Rotate around rotation ref. point
          jsr       pers         * Transform, new points
          jsr       drawn1

          jsr       pagedown     * Display this logical page
          jsr       inp_chan     * Input and change
          jsr       clwork       * clear physical page
          jmp       mainlop1     * to main loop

mainend:  move.l    physbase,logbase

          jsr       pageup       * switch to normal display page
          rts                    * back to link file, and end


********************************************************************
* remove all characters from the keyboard buffer                   *
********************************************************************

clearbuf: move.w    #$b,-(a7)    * Gemdos funct. char in buffer?
          trap      #1
          addq.l    #2,a7
          tst.w     d0           * if yes, get character
          beq       clearend     * if no, terminate
          move.w    #1,-(a7)     * Gemdos funct. CONIN
          trap      #1           * repeat until all characters
          addq.l    #2,a7        * are removed from the buffer
          bra       clearbuf

clearend: rts


********************************************************************
*   Create the rotation body r1                                    *
********************************************************************

makerot1: jsr       r1set        * Create the rotation body
          jsr       rotstart     * first the coordinates,
          jsr       rotlin       * then the lines
          rts


*********************************************************************
*   Input and change observation parameters                         *
*   the angles hxangle,hyangle,hzangle, are rotation angles of      *
*   world system                                                    *
*********************************************************************

inp_chan: jsr       inkey        * Sense keyboard, code in
          cmp.b     #'D',d0
          bne       inpwait
          jsr       scrdmp       * make hardcopy

inpwait:  swap      d0           * test D0 if
          cmp.b     #$4d,d0      * Cursor-right
          bne       inp1
          addq.w    #1,ywplus    * if yes, add one to Y-angle increment
          bra       inpend1      * and continue

inp1:     cmp.b     #$4b,d0      * Cursor-left, if yes
          bne       inp2         * subtract one from Y-angle
          subq.w    #1,ywplus    * increment
          bra       inpend1

inp2:     cmp.b     #$50,d0      * Cursor-down, if yes
          bne       inp3
          addq.w    #1,xwplus    * add one to X-angle increment
          bra       inpend1

inp3:     cmp.b     #$48,d0      * Cursor-up
          bne       inp3a
          subq.w    #1,xwplus    * subtract one
          bra       inpend1

inp3a:    cmp.b     #$61,d0      * Undo-key
          bne       inp3b
          subq.w    #1,zwplus    * lower Z-increment
          bra       inpend1

inp3b:    cmp.b     #$62,d0      * Help-key
          bne       inp4
          addq.w    #1,zwplus    * add to Z-increment
          bra       inpend1

inp4:     cmp.b     #$4e,d0      * plus key on keypad
          bne       inp5         * if yes, subtract 25 from
          sub.w     #25,dist     * position of projection
          bra       inpend1      * plane (Z-coordinate)
inp5:     cmp.b     #$4a,d0      * minus key on keypad
          bne       inp6         *
          add.w     #25,dist     * if yes, add 25
          bra       inpend1

inp6:     cmp.b     #$66,d0      * times-key on the keypad
          bne       inp7         * if yes, then subtract 15
          sub.w     #15,rotdpz   * from the rotation ref. point Z-coord.
          bra       inpend1      * make changes

inp7:     cmp.b     #$65,d0      * division-key on keypad
          bne       inp10
          add.w     #15,rotdpz   * add 15
          bra       inpend1

inp10:    cmp.b     #$44,d0      * F10 activated ?
          bne       inpend1
          addq.l    #4,a7        * if yes, jump to
          bra       mainend      * Program end

inpend1:  move.w    hyangle,d1    * rotation angle, Y-axis
          add.w     ywplus,d1     * add increment
          cmp.w     #360,d1       * if larger than 360, then subtract 360
          bge       inpend2
          cmp.w     #-360,d1      * if smaller than 360,
          ble       inpend3       * add 360
          bra       inpend4
inpend2:  sub.w     #360,d1
          bra       inpend4
inpend3:  add.w     #360,d1

inpend4:  move.w    d1,hyangle

          move.w    hxangle,d1    * proceeed in the same
          add.w     xwplus,d1     * manner with rotation
          cmp.w     #360,d1       * angle, X-axis
          bge       inpend5
          cmp.w     #-360,d1
          ble       inpend6
          bra       inpend7
inpend5:  sub.w     #360,d1
          bra       inpend7
inpend6:  add.w     #360,d1
inpend7:  move.w    d1,hxangle    *
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

*******************************************************************
* Initialize the rotation reference point to [0,0,0]              *
*******************************************************************

setrotdp: move.w    #0,d1        * set the start-rotation
          move.w    d1,rotdpx    * reference point
          move.w    d1,rotdpy
          move.w    d1,rotdpz
          move.w    #0,hyangle    * Start rotation angle
          move.w    #0,hzangle
          move.w    #0,hxangle
          rts

******************************************************************
* Rotation of the total world system around the rotation         *
* reference point                                                *
******************************************************************

pointrot: move.w    hxangle,xangle * rotate the world around
          move.w    hyangle,yangle
          move.w    hzangle,zangle
          move.w    rotdpx,d0    * the rotation reference point
          move.w    rotdpy,d1
          move.w    rotdpz,d2
          move.w    d0,xoffs     * add for inverse transformation
          move.w    d1,yoffs
          move.w    d2,zoffs
          neg.w     d0
          neg.w     d1
          neg.w     d2
          move.w    d0,offx      * subtract for transformation
          move.w    d1,offy
          move.w    d2,offz
          jsr       matinit      * matrix initialization
          jsr       zrotate      * rotate around Z-axis first  
          jsr       yrotate      * rotate 'matrix' around Y-axis  
          jsr       xrotate      * then rotate around X-axis 
          jsr       rotate       * multiply points with the
          rts                    * matrix. The Z-axis is not taken into
*                                * account 
makewrld: move.l    #r1datx,a1   * create the world system
          move.l    #r1daty,a2   * by copying data of rotation body
          move.l    #r1datz,a3   * into world system
          move.l    #worldx,a4
          move.l    #worldy,a5
          move.l    #worldz,a6
          move.w    r1nummark,d0 * number of corners repeated
          ext.l     d0
          subq.l    #1,d0
makewl1:  move.w    (a1)+,(a4)+  * Copy coordinates
          move.w    (a2)+,(a5)+  * Y-coords.
          move.w    (a3)+,(a6)+  * Z-coords.
          dbra      d0,makewl1

          move.w    r1numline,d0 * Copy the line arrays
          ext.l     d0           * of the rotation body
          subq.l    #1,d0        * into the world system
          move.l    #r1lin,a1    * Number of lines as counter
          move.l    #wlinxy,a2
makewl2:  move.l    (a1)+,(a2)+  * copy lines
          dbra      d0,makewl2
          rts

***********************************************************************
*   Pass world parameters to variables of link files                  *
***********************************************************************

worldset: move.l    #worldx,datx      * Passing house variables
          move.l    #worldy,daty      * for the rotation routine
          move.l    #worldz,datz      * and the global subroutine
          move.l    #viewx,pointx     * of the link module
          move.l    #viewy,pointy
          move.l    #viewz,pointz
          move.l    #wlinxy,linxy
          move.w    picturex,x0
          move.w    picturey,y0
          move.w    proz,zobs         * Projection center Z-coordinate
          move.w    r1z1,dist         * Location of projection plane on
          move.l    #screenx,xplot    * the Z-axis
          move.l    #screeny,yplot
          move.w    hnumline,numline  * Number of house lines
          move.w    hnummark,nummark  * Number of house corners
          rts


***********************************************************************
*   Creation of rotation body in the array, the address of which      *
*   is passed in the variables rotdatx, rotdaty, rotdatz              *
***********************************************************************

r1set:
          move.l    #r1xdat,rotxdat   * Transmit 
          move.l    #r1ydat,rotydat   * parameters of this
          move.l    #r1zdat,rotzdat   * rotation body to
          move.l    #r1datx,rotdatx   * the routine for
          move.l    #r1daty,rotdaty   * creation of the
          move.l    #r1datz,rotdatz   * rotation body
          move.l    rotdatx,datx
          move.l    rotdaty,daty
          move.l    rotdatz,datz
          move.w    r1numro,numro     * Number of desired
          move.w    r1numpt,numpt     * rotations. Number
          move.l    #r1lin,linxy      * of points in def.line.
          rts                         * Address of line array

rotstart: move.w    numpt,d0          * Rotate def line
          lsl.w     #1,d0             * numro+1 about Y-axis
          ext.l     d0
          move.l    d0,plusrot
          move.w    numpt,nummark
          move.l    rotdatx,pointx    * Pass data array
          move.l    rotdaty,pointy    * to subroutine yrot
          move.l    rotdatz,pointz
          move.w    #0,yangle
          move.w    #360,d0           * 360 / numro = angle increment
          divs      numro,d0          * per rotation
          move.w    d0,plusagle
          move.w    numro,d0          * numro +1 times
          ext.l     d0

rloop1:   move.l    d0,loopc          * as loop counter
          move.l    rotxdat,datx      * for passing to yrot
          move.l    rotydat,daty
          move.l    rotzdat,datz
          jsr       yrot              * rotate
          move.l    pointx,d1         * add offset to
          add.l     plusrot,d1        * address
          move.l    d1,pointx
          move.l    pointy,d1
          add.l     plusrot,d1
          move.l    d1,pointy
          move.l    pointz,d1
          add.l     plusrot,d1
          move.l    d1,pointz
          move.w    yangle,d7         * Add angle increment
          add.w     plusagle,d7       * to rotation angle
          move.w    d7,yangle         * and rotate line
          move.l    loopc,d0          * again until all
          dbra      d0,rloop1         * end points are generated.

          move.w    r1numro,numro     * store for following
          move.w    r1numpt,numpt     * routines for line generation
          rts

rotlin:                               * Create the line array of the
          move.w    #1,d7             * rotation body 
          move.w    numro,d4          * Number of rotations repeated
          ext.l     d4
          subq.l    #1,d4
          move.w    numpt,d1
          subq.w    #1,d1
          lsl.w     #2,d1
          ext.l     d1
          move.l    d1,plusrot

rotlop1:  move.w    numpt,d5          * Number of points -
          ext.l     d5                * repeat once
          subq.l    #2,d5
          move.l    linxy,a1          * Lines created stored
          move.w    d7,d6             * here
rotlop2:  move.w    d6,(a1)+          * The first line goes from
          addq.w    #1,d6             * point one to point two
          move.w    d6,(a1)+          * (1,2) then (2,3) etc.
          dbra      d5,rotlop2

          move.l    linxy,d1          * generate cross connections
          add.l     plusrot,d1        * of individual lines
          move.l    d1,linxy
          move.w    numpt,d0
          add.w     d0,d7
          dbra      d4,rotlop1

          move.w    numpt,d7
          move.w    d7,delta1
          lsl.w     #2,d7
          ext.l     d7
          move.l    d7,plusrot
          move.w    #1,d6
          move.w    numpt,d0
          ext.l     d0
          subq.l    #1,d0

rotlop3:  move.w    numro,d1
          ext.l     d1
          subq.l    #1,d1
          move.w    d6,d5
rotlop4:  move.w    d5,(a1)+
          add.w     delta1,d5
          move.w    d5,(a1)+
          dbra      d1,rotlop4

          add.w     #1,d6
          dbra      d0,rotlop3
          move.w    numro,d1
          add.w     #1,d1

          muls      nummark,d1

          move.w    d1,r1nummark      * Store total number of
          move.w    numpt,d1          * corners created
          muls      numro,d1
          move.w    numpt,d2
          subq.w    #1,d2
          muls      numro,d2
          add.w     d1,d2
          move.w    d2,r1numline      * Total of lines created
          rts

**********************************************************************
*  Pass parameters of the world system to variables                  *
*  of the link file for the rotation body                            *
**********************************************************************

wrld2set: move.l    #worldx,datx      * Pass parameter of
          move.l    #worldy,daty      * rotation body to the
          move.l    #worldz,datz      * subroutines in the link
          move.l    #viewx,pointx     * module
          move.l    #viewy,pointy
          move.l    #viewz,pointz
          move.l    #wlinxy,linxy
          move.w    picturex,x0
          move.w    picturey,y0
          move.w    proz,zobs
          move.w    r1z1,dist
          move.l    #screenx,xplot
          move.l    #screeny,yplot
          move.w    r1numline,numline * Number of lines
          move.w    r1nummark,nummark * Number of corners
          rts


***********************************************************************
*  Sense current display resolution and set the coordinate            *
*  origin of the screen system to the screen center                   *
***********************************************************************

getreso:  move.w    #4,-(a7)
          trap      #14
          addq.l    #2,a7
          cmp.w     #2,d0
          bne       getr1
          move.w    #320,picturex     * monochrome monitor
          move.w    #200,picturey
          bra       getrend
getr1:    cmp.w     #1,d0
          bne       getr2
          move.w    #320,picturex     * medium resolution (640*200)
          move.w    #100,picturey
          bra       getrend
getr2:    move.w    #160,picturex     * low resolution (320*200)
          move.w    #100,picturey
getrend:  rts



***********************************************************************
*   Hardcopy after inp_chan call                                      *
***********************************************************************

scrdmp:   move.w    #20,-(a7)
          trap      #14
          addq.l    #2,a7
          jsr       clearbuf
          rts

*********************************************************************
* Set the limit of the window for the Cohen-Sutherland              *
* clip algorithm built into the draw-line algorithm                 *
* The user can choose the limits freely, which makes the            *
* draw-line algorithm very flexible.                                *
*********************************************************************

setcocli: move.w    #0,clipxule
          move.w    #0,clipyule
          move.w    picturex,d1
          lsl.w     #1,d1             * times two
          subq.w    #1,d1             * minus one equals
          move.w    d1,clipxlri       * 639 for monochrom
          move.w    picturey,d1
          lsl.w     #1,d1             * times two minus one
          subq.w    #1,d1             * equals 399 for monochrom
          move.w    d1,clipylri
          rts


          .even


***********************************************************************
***********************************************************************
*   Begin variable area for Program module                            *
*                                                                     *
***********************************************************************

***********************************************************************
* Data area for the rotation body                                     *
***********************************************************************
          .bss                        * Space for the variables

numro:    .ds.w     1
numpt:    .ds.w     1

worldfla: .ds.l     1

rotxdat:  .ds.l     1
rotydat:  .ds.l     1
rotzdat:  .ds.l     1
rotdatx:  .ds.l     1
rotdaty:  .ds.l     1
rotdatz:  .ds.l     1

r1numline: .ds.w     1
r1nummark: .ds.w     1
r1numfla:  .ds.w     1

plusagle: .ds.w     1

r1datx:   .ds.w     1540
r1daty:   .ds.w     1540
r1datz:   .ds.w     1540

r1lin:    .ds.l     3200              * for every line 4-Bytes

          .data

***********************************************************************
* These are the coordinates of the definition line which              *
* generates the rotation body through rotation about                  *
* the Y-axis. By changing coordinates the body to be                  *
* created can be changed. Of course, the number of points in          *
* r1numpt must be adapted to the new situation. By changing           *
* r1numro the current body can be changed as well.                    *
* Storage reserved here is enough for a maximum 120 rotations         *
* of 12 points. This means that for a user-defined                    *
* rotation line, the product of the number of points and              *
* number of desired rotations plus one, cannot be greater             *
* than 1500.                                                          *
***********************************************************************

r1xdat:   .dc.w 0,40,50,50,20,30,20,30,70,80,80,0

r1ydat:   .dc.w 100,100,80,60,40,30,30,-70,-80,-90,-100,-100

r1zdat:   .dc.w 0,0,0,0,0,0,0,0,0,0,0,0

r1numpt:  .dc.w     12
r1numro:  .dc.w     8     * Number of rotations for creation


************************************************************************
*                                                                      *
*                                                                      *
*         Definition of the house                                      *
*                                                                      *
************************************************************************

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

hnummark: .dc.w     26    * Number of corners in the house
hnumline: .dc.w     32    * Number of lines in the house

hxangle:   .dc.w     0     * Rotation angle of house about X-axis
hyangle:   .dc.w     0     *         "        "         "    Y-axis
hzangle:   .dc.w     0     *         "        "         "    Z-axis

xwplus:   .dc.w     0     * Angle increment around X-axis
ywplus:   .dc.w     0     * Angle increment around Y-axis
zwplus:   .dc.w     0     * Angle increment around Z-axis

picturex:    .dc.w     0  * Definition of zero point of the screen 
picturey:    .dc.w     0  * provided with values from subroutine getreso


rotdpx:   .dc.w     0
rotdpy:   .dc.w     0
rotdpz:   .dc.w     0


r1z1:     .dc.w     0
normz:    .dc.w     1500



          .bss

plusrot:  .ds.l     1
first:    .ds.w     1
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

worldx:   .ds.w     1600    * World coordinate array
worldy:   .ds.w     1600
worldz:   .ds.w     1600

viewx:    .ds.w     1600    * View coordinate array
viewy:    .ds.w     1600
viewz:    .ds.w     1600

screenx:  .ds.w     1600    * Screen coordinate array
screeny:  .ds.w     1600


wlinxy:   .ds.l     3200    * Line array
          .data
prox:     .dc.w     0       * Coordinates for projection-
proy:     .dc.w     0       * center here on the positive
proz:     .dc.w     1500    * Z-axis

          .data

offx:     .dc.w     0       * Transformation for rotation
offy:     .dc.w     0       * to point [offx,offy,offz]
offz:     .dc.w     0

xoffs:    .dc.w     0       * Inverse transformation for point
yoffs:    .dc.w     0       * [xoff,yoffs,zoffs]
zoffs:    .dc.w     0


          .bss

loopc:    .ds.l     1
          .end
