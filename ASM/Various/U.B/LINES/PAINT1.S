**********************************************************************
*  paint1.s        9.2.1986                                          *
*  Display a shaded rotation body                                    *
*                                                                    *
**********************************************************************
          .text
          .globl    main,xoffs,yoffs,zoffs,offx,offy,offz
          .globl    viewx,viewy,viewz
          .globl    wlinxy,mouse_off,setrotdp,inp_chan,pointrot

main:
          jsr       apinit       * Announce program
          jsr       grafhand     * Get screen handler
          jsr       openwork     * open workstation
          jsr       mouse_off    * Turn off mouse
          jsr       getreso      * Display resolution ?
          jsr       setcocli     * Set clip window
          jsr       makerot1     * Create rotation body


          jsr       makewrld     * Create world system
          jsr       wrld2set     * Pass world parameters

          jsr       setrotdp     * initialize observation ref. point
          jsr       clwork
          jsr       pagedown     * Display logical page
          jsr       clwork
          jsr       inp_chan

mainlop1:
          jsr       pointrot     * rotate around observ. ref. point
          jsr       pers         * Perspective transformation
          jsr       hideit       * hide hidden surfaces
          jsr       paintit      * sort and shade

          jsr       pageup       * Display physical page
          jsr       inp_chan     * Input new parameters
          jsr       clwork       * clear screen page not displayed
          jsr       pointrot     * Rotate around rot. ref. point
          jsr       pers         * Transform new points
          jsr       hideit       * hide
          jsr       paintit      * sort and shade
          jsr       pagedown     * Display this logical page
          jsr       inp_chan     * Input and change parameters
          jsr       clwork       * erase physical page
          jmp       mainlop1     * to main loop

mainend:  move.l    physbase,logbase

          jsr       pageup       * Switch to normal screen page
          rts                    * back to link file and end



***********************************************************************
*   Creation of rotation body by passing parameters                   *
*   and calling rotation routine                                      *
***********************************************************************

makerot1: jsr       r1set        * Set parameters of rot. body
          jsr       rotstart     * and create rot. body
          rts


***********************************************************************
*  Input and change parameters with the keyboard                      *
***********************************************************************

inp_chan: jsr       inkey        * Read keyboard, code in
          cmp.b     #'D',d0
          bne       inpwait
          jsr       scrdmp       * Make hardcopy

inpwait:  swap      d0           * Test D0 for
          cmp.b     #$4d,d0      * Cursor-right
          bne       inp1
          addq.w    #1,ywplus    * if yes, add one to
          bra       inpend1      * Y-angle increment and continue

inp1:     cmp.b     #$4b,d0      * Cursor-left, if yes
          bne       inp2         * subtract one from
          subq.w    #1,ywplus    * Y-angle increment
          bra       inpend1

inp2:     cmp.b     #$50,d0      * Cursor-down, if yes
          bne       inp3
          addq.w    #1,xwplus    * add one to X-angle
          bra       inpend1      * increment

inp3:     cmp.b     #$48,d0      * Cursor-up
          bne       inp3a
          subq.w    #1,xwplus    * subtract one
          bra       inpend1

inp3a:    cmp.b     #$61,d0      * Undo key
          bne       inp3b
          subq.w    #1,zwplus    * decrease Z-increment
          bra       inpend1

inp3b:    cmp.b     #$62,d0      * Help key
          bne       inp4
          addq.w    #1,zwplus    * increase Z-increment
          bra       inpend1

inp4:     cmp.b     #$4e,d0      * + key on keypad
          bne       inp5         * if yes, subtract 25 from
          sub.w     #25,dist     * location of projection
          bra       inpend1      * plane (Z-coordinate)
inp5:     cmp.b     #$4a,d0      * minus key on keypad
          bne       inp6         *
          add.w     #25,dist     * if yes, add 25
          bra       inpend1

inp6:     cmp.b     #$66,d0      * * key on keypad
          bne       inp7         * if yes, subtract 15 from
          sub.w     #15,rotdpz   * rotation point Z-coordinate
          bra       inpend1      * Make change

inp7:     cmp.b     #$65,d0      * / key on keypad
          bne       inp10
          add.w     #15,rotdpz   * add 15
          bra       inpend1

inp10:    cmp.b     #$44,d0      * F10 pressed ?
          bne       inpend1
          addq.l    #4,a7        * if yes, then jump to
          bra       mainend      * program end

inpend1:  move.w    hyangle,d1   * Rotat.angle about Y-axis
          add.w     ywplus,d1    * add increment
          cmp.w     #360,d1      * if larger than 360, then
          bge       inpend2      * subtract 360
          cmp.w     #-360,d1     * if smaller than 360, then
          ble       inpend3      * add 360
          bra       inpend4
inpend2:  sub.w     #360,d1
          bra       inpend4
inpend3:  add.w     #360,d1

inpend4:  move.w    d1,hyangle

          move.w    hxangle,d1   * do the same for 
          add.w     xwplus,d1    * the rotation angle
          cmp.w     #360,d1      * about X-axis
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

*********************************************************************
*   Initialize the rotation reference point to [0,0,0]              *
*********************************************************************

setrotdp: move.w    #0,d1        * set the Initial rotation
          move.w    d1,rotdpx     * ref. point
          move.w    d1,rotdpy
          move.w    d1,rotdpz
          move.w    #0,hyangle    * initial rotation angle
          move.w    #0,hzangle
          move.w    #0,hxangle
          rts

**********************************************************************
*   Rotation around the rotation reference point about all           *
*   three Axis                                                       *
**********************************************************************

pointrot: move.w    hxangle,xangle * rotate the world around
          move.w    hyangle,yangle
          move.w    hzangle,zangle
          move.w    rotdpx,d0      * rotation reference point
          move.w    rotdpy,d1
          move.w    rotdpz,d2
          move.w    d0,xoffs     * add for inverse transform
          move.w    d1,yoffs
          move.w    d2,zoffs
          neg.w     d0
          neg.w     d1
          neg.w     d2
          move.w    d0,offx      * subtract for transform
          move.w    d1,offy
          move.w    d2,offz
          jsr       matinit      * initialize matrix
          jsr       zrotate      * rotate first about Z-axis
          jsr       yrotate      * rotate 'matrix' about Y-axis
          jsr       xrotate      * then rotate about X-axis
          jsr       rotate       * Multiply points with matrix.
          rts
***********************************************************************
* Create world system by copying the object data into world system    *
***********************************************************************

makewrld: move.l    #r1datx,a1   * Create world system by
          move.l    #r1daty,a2
          move.l    #r1datz,a3
          move.l    #wrldx,a4
          move.l    #wrldy,a5
          move.l    #wrldz,a6
          move.w    r1nummark,d0
          ext.l     d0
          subq.l    #1,d0
makewl1:  move.w    (a1)+,(a4)+   * copying point coordinates
          move.w    (a2)+,(a5)+   * into the world system
          move.w    (a3)+,(a6)+
          dbra      d0,makewl1
          move.w    r1numline,d0
          ext.l     d0
          subq.l    #1,d0
          move.l    #r1lin,a1
          move.l    #wlinxy,a2
makewl2:  move.l    (a1)+,(a2)+    * Copy lines into world
          dbra      d0,makewl2     * system

          move.l    worldpla,a0
          move.l    #wplane,a1
          move.w    r1numsurf,d0
          ext.l     d0
          subq.l    #1,d0

makewl3:  move.w    (a0)+,d1       * Copy surfaces into
          move.w    d1,(a1)+       * world system
          ext.l     d1
          subq.l    #1,d1

makewl4:  move.l    (a0)+,(a1)+    * Copy every line of
          dbra      d1,makewl4     * this surface into

          dbra      d0,makewl3     * world array until all
          rts                      * surfaces are completed
*********************************************************************
*  Pass the world parameters to the variables in the                *
*  link files                                                       *
*********************************************************************

wrldset:  move.l    #wrldx,datx    * Pass the variables
          move.l    #wrldy,daty    * for the rotation
          move.l    #wrldz,datz    * routine
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
          move.w    hnumsurf,numsurf
          rts


*****************************************************************
* Remove all characters from keyboard buffer                    *
*****************************************************************

clearbuf: move.w    #$b,-(a7)
          trap      #1
          addq.l    #2,a7
          tst.w     d0
          beq       clearnd
          move.w    #1,-(a7)
          trap      #1
          addq.l    #2,a7
          bra       clearbuf

clearnd:  rts
*********************************************************************
*   Sense display resolution and set coordinate                     *
*   origin to screen center                                         *
*********************************************************************

getreso:  move.w    #4,-(a7)        * Sense display resolution
          trap      #14
          addq.l    #2,a7
          cmp.w     #2,d0
          bne       getr1
          move.w    #320,picturex   * Monochrome monitor
          move.w    #200,picturey
          bra       getrend
getr1:    cmp.w     #1,d0
          bne       getr2
          move.w    #320,picturex   * medium resolution (640*200)
          move.w    #100,picturey
          bra       getrend
getr2:    move.w    #160,picturex   * low resolution (320*200)
          move.w    #100,picturey
getrend:  rts


***********************************************************************
*   Hardcopy of screen, called by inp_chan                            *
*                                                                     *
***********************************************************************

scrdmp:   move.w    #20,-(a7)
          trap      #14
          addq.l    #2,a7
          jsr       clearbuf
          rts

*********************************************************************
* Sets the limits of the display window for the                     *
* Cohen-Sutherland clipping algorithm built into the                *
* draw-line algorithm                                               *
* The limits can be freely selected by the user which makes         *
* the draw-line algorithm very flexible.                            *
*********************************************************************
setcocli: move.w    #0,clipxule
          move.w    #0,clipyule
          move.w    picturex,d1
          lsl.w     #1,d1         * times two
          subq.w    #1,d1         * minus one equals
          move.w    d1,clipxlri   * 639 for monochrom
          move.w    picturey,d1
          lsl.w     #1,d1         * times two minus one
          subq.w    #1,d1         * equals 399 for monochrome
          move.w    d1,clipylri
          rts


**********************************************************************
*   Pass visible surfaces into vplane array and                      *
*   into pladress array for subsequent sorting                       *
*   of surfaces                                                      *
**********************************************************************

hideit:
          move.w    numsurf,d0   * Number of surfaces as
          ext.l     d0           * counter
          subq.l    #1,d0
          move.l    #viewx,a1    * The point
          move.l    #viewy,a2    * coordinates are stored here
          move.l    #viewz,a3
          move.l    #wplane,a0   * Here is the information
          move.l    #vplane,a5   * for every surface
          move.w    #0,surfcount * Counts the known visible surfaces.

          move.l    #pladress,a6 * Address of surface storage

visible:  move.w    (a0),d1      * Start with first surface
          ext.l     d1           * Number of points on this surface in D1
          move.w    2(a0),d2     * Offset of first point of this surface
          move.w    4(a0),d3     * Offset of second point
          move.w    8(a0),d4     * Offset of third point
          subq.w    #1,d2        * For access to point array
          subq.w    #1,d3        * subtract one from current
          subq.w    #1,d4        * point offset.
          lsl.w     #1,d2        * Multiply by two
          lsl.w     #1,d3
          lsl.w     #1,d4        * and access current
          move.w    (a1,d3.w),d6 * point coordinates
          cmp.w     (a1,d4.w),d6 * Comparison recognizes two points
          bne       doit1        * with the same coordinates
*                               * created through
          move.w    (a2,d3.w),d6 * construction of
          cmp.w     (a2,d4.w),d6 * rotation bodies. When
          bne       doit1        * two points are found
          move.w    (a3,d4.w),d6 * where all point coordinates (x,y,z)
          cmp.w     (a3,d3.w),d6 * match, the program selects the
          bne       doit1        * third point to find
          move.w    12(a0),d4    * both vectors
          subq.w    #1,d4
          lsl.w     #1,d4

doit1:
          move.w    (a1,d3.w),d5   * the two vectors which
          move.w    d5,kx          * lie in the surface plane
          sub.w     (a1,d2.w),d5   * are found by subtracting the
          move.w    d5,px          * coordinates of two points
          move.w    (a2,d3.w),d5   * in this surface
          move.w    d5,ky          * the direction coord. of the
          sub.w     (a2,d2.w),d5   * vectors is stored in
          move.w    d5,py          * variables qx,qy,qz and
          move.w    (a3,d3.w),d5   * px,py,pz
          move.w    d5,kz
          sub.w     (a3,d2.w),d5
          move.w    d5,pz

          move.w    (a1,d4.w),d5   * Calculate vector Q
          sub.w     (a1,d2.w),d5
          move.w    (a2,d4.w),d6
          sub.w     (a2,d2.w),d6
          move.w    (a3,d4.w),d7
          sub.w     (a3,d2.w),d7
          move.w    d5,d1          * qx
          move.w    d6,d2          * qy
          move.w    d7,d3          * qz

          muls      py,d3          * Compute cross product
          muls      pz,d2          * of the vector perpendicular
          sub.w     d2,d3          * to the current surface
          move.w    d3,rx
          muls      pz,d1
          muls      px,d7
          sub.w     d7,d1          * The direction coordinates of
          move.w    d1,ry          * the vector perpendicular to
          muls      px,d6          * the surface are stored
          muls      py,d5          * in rx,ry,rz
          sub.w     d5,d6
          move.w    d6,rz

          move.w    prox,d1        * The projection center serves as
          sub.w     kx,d1          * comparison point for the visibility
          move.w    proy,d2        * of a surface which seems
          sub.w     ky,d2          * adquate for the viewing
          move.w    proz,d3        * situation. The observation
          sub.w     kz,d3          * ref. point can also
          muls      rx,d1          * be used as the comparison point.
          muls      ry,d2          * Compare vector R and
          muls      rz,d3          * the vector from one
          add.l     d1,d2          * point of the surface to
          add.l     d2,d3          * the projection center by forming
          bmi       dosight        * the scalar product of the two vectors

* If the scalar product is negative, surface is visible

          move.w    (a0),d1    * Number of lines in surface
          ext.l     d1
          lsl.l     #2,d1      * Number of lines times 4 = space for lines
          addq.l    #2,d1      * plus 2 bytes for number of lines

          add.l     d1,a0      * add to surface array for
sight1:   dbra      d0,visible * access to next surface
          bra       hideend    * All surfaces processed ? End


dosight:  move.w    (a0),d1    * Number of lines for this surface
          ext.l     d1         * multiplied by two results in

********************************************************************
** Changes from the program rot1.s                                **
**                                                                **
********************************************************************

          move.l    d1,d2
          lsl.l     #1,d1          * Number of words to be passed
          move.l    a0,a4
          addq.l    #2,a4          * Access to first line of the surface
          move.w    #0,zsurf       * Clear addition storage

sight2:   move.l    (a4)+,d6       * first line of surface
          swap      d6             * first point in lower half of D0
          subq.w    #1,d6          * fit index
          lsl.w     #1,d6          * fit operand size (2-Byte)

          move.w    (a3,d6.w),d6   * Z-coordinate of this point
          add.w     d6,zsurf       * add all Z-coordinates
          dbra      d2,sight2      * until all lines are computed

          move.w    zsurf,d6       * Divide sum of all Z-coordinates
*                                  * for this
          ext.l     d6             * surface by the number of lines
          lsr.l     #2,d6          * Surfaces created by rotation
          ext.l     d6             * always have four lines.
          move.l    d6,(a6)+       * Store middle Z-Coordinate
          move.l    a0,(a6)+       * followed by address of surface

sight3:   move.w    (a0)+,(a5)+    * pass number of lines

          dbra      d1,sight3      * and individual lines
          addq.w    #1,surfcount    * increase number of surfaces by one
          bra       sight1         * and work on next surface
hideend:  rts


***********************************************************************
*  Create rotation body by passing parameters,                        *
*  rotating the definition line, and creating the line and            *
*  surface arrays                                                     *
***********************************************************************

r1set:
          move.l    #r1xdat,rotxdat    * Pass the 
          move.l    #r1ydat,rotydat    * parameters for
          move.l    #r1zdat,rotzdat    * rotation body to
          move.l    #r1datx,rotdatx    * routine for
          move.l    #r1daty,rotdaty    * creating the
          move.l    #r1datz,rotdatz    * rotation body
          move.l    rotdatx,datx       * array addresses of
          move.l    rotdaty,daty       * the points
          move.l    rotdatz,datz
          move.w    r1numro,numro      * Number of desired rotations
          move.w    r1numpt,numpt      * Number of points to be rotated
          move.l    #r1lin,linxy       * Address of line array
          move.l    #r1plane,worldpla  * Address of surface array
          rts

rotstart: move.w    numpt,d0           * Rotation of def line
          lsl.w     #1,d0              * numro+1 times about Y-axis
          ext.l     d0
          move.l    d0,plusrot         * Storage for one line
          move.w    numpt,nummark      * Number of points
          move.l    rotdatx,pointx     * rotated
          move.l    rotdaty,pointy
          move.l    rotdatz,pointz
          move.w    #0,yangle
          move.w    #360,d0            * 360 / numro = angle increment
          divs      numro,d0           * per rotation
          move.w    d0,plusagle        * store
          move.w    numro,d0           * numro +1 times
          ext.l     d0

rloop1:   move.l    d0,loopc           * as loop counter
          move.l    rotxdat,datx
          move.l    rotydat,daty
          move.l    rotzdat,datz
          jsr       yrot               * rotate
          move.l    pointx,d1          * add offset
          add.l     plusrot,d1
          move.l    d1,pointx
          move.l    pointy,d1
          add.l     plusrot,d1
          move.l    d1,pointy
          move.l    pointz,d1
          add.l     plusrot,d1
          move.l    d1,pointz
          move.w    yangle,d7
          add.w     plusagle,d7
          move.w    d7,yangle
          move.l    loopc,d0
          dbra      d0,rloop1

          move.w    r1numro,numro
          move.w    r1numpt,numpt
          jsr       rotlin              * Create line array
          jsr       rotsurf             * Create surface array
          rts

rotlin:
          move.w    #1,d7
          move.w    numro,d4            * Number of rotations
          ext.l     d4
          subq.l    #1,d4
          move.w    numpt,d1            * Number of points in def. lin.
          subq.w    #1,d1               * both as counters
          lsl.w     #2,d1               * times two
          ext.l     d1
          move.l    d1,plusrot

rotlop1:  move.w    numpt,d5            * Number of points minus once
          ext.l     d5                  * repeat, last line
          subq.l    #2,d5               * connect points (n-1,n)
          move.l    linxy,a1
          move.w    d7,d6
rotlop2:  move.w    d6,(a1)+            * first line connects
          addq.w    #1,d6               * points (1,2) then (2,3) etc.
          move.w    d6,(a1)+
          dbra      d5,rotlop2

          move.l    linxy,d1
          add.l     plusrot,d1
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

rotlop4:  move.w    d5,(a1)+       * generate cross
          add.w     delta1,d5      * connection lines which
          move.w    d5,(a1)+       * connect lines created
          dbra      d1,rotlop4     * by rotation

          add.w     #1,d6
          dbra      d0,rotlop3
          move.w    numro,d1
          add.w     #1,d1

          muls      nummark,d1

          move.w    d1,r1nummark
          move.w    numpt,d1
          muls      numro,d1
          move.w    numpt,d2
          subq.w    #1,d2
          muls      numro,d2
          add.w     d1,d2
          move.w    d2,r1numline  * store number of lines
          rts


rotsurf:   move.w    numro,d0     * Create surfaces of
          ext.l     d0            * rotation body
          subq.l    #1,d0
          move.w    numpt,d7      * Number of points minus one
          ext.l     d7            * repeat
          subq.l    #2,d7
          move.l    d7,plusrot

          move.l    worldpla,a0   * Address of surface array
          move.w    #1,d1
          move.w    numpt,d2      * Number of points
          addq.w    #1,d2

rotfl1:   move.l    plusrot,d7    * Offset
rotfl2:   move.w    d1,d4
          move.w    d2,d5
          addq.w    #1,d4
          addq.w    #1,d5
          move.w    #4,(a0)+      * Number of lines/surfaces

          move.w    d1,(a0)+      * first surface created here 
          move.w    d4,(a0)+
          move.w    d4,(a0)+
          move.w    d5,(a0)+
          move.w    d5,(a0)+
          move.w    d2,(a0)+
          move.w    d2,(a0)+
          move.w    d1,(a0)+
          addq.w    #1,d1
          addq.w    #1,d2
          dbra      d7,rotfl2
          addq.w    #1,d1
          addq.w    #1,d2

          dbra      d0,rotfl1
          move.w    numpt,d1
          subq.w    #1,d1
          muls      numro,d1
          move.w    d1,r1numsurf
          rts



******************************************************************
* Pass data and parameters to the link file routines             *
******************************************************************

wrld2set: move.l    #wrldx,datx
          move.l    #wrldy,daty
          move.l    #wrldz,datz
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
          move.w    r1numline,numline
          move.w    r1nummark,nummark
          move.w    r1numsurf,numsurf
          rts


***********************************************************************
* Sort surfaces stored in pladress                                    *
***********************************************************************

sortit:   move.l    #pladress,a0
          move.w    surfcount,d7
          ext.l     d7               * for i = 2 to n corresponds to
          subq.l    #2,d7
          bmi       serror           * for i = 1 to n-1 because of 
          move.l    #1,d1            * different array structure
sortmain: move.l    d1,d2
          subq.l    #1,d2            * j = i -1
          move.l    d1,d3            * i
          lsl.l     #3,d3
          move.l    (a0,d3.l),d5     * Comparison value x = a[i]
          move.l    4(a0,d3.l),d6    * Address of surface
          move.l    d5,platz         * a[0] = x = a[-1] in
          move.l    d6,platz+4       * this array
sortlop1: move.l    d2,d4            * j
          lsl.l     #3,d4            * j times 8 for access to array
          cmp.l     (a0,d4.l),d5     * Z-coordinate of surface
          bge       sortw1           * while x < a[j] do

          move.l    (a0,d4.l),8(a0,d4.l)    * a[j+1] = a[j]
          move.l    4(a0,d4.l),12(a0,d4.l)  * Address of  surface array
          subq.l    #1,d2                   * j = j-1
          bra       sortlop1

sortw1:   move.l    d5,8(a0,d4.l)    * a[j+1] = x
          move.l    d6,12(a0,d4.l)   * pass address also
          addq.l    #1,d1            * i = i + 1
          dbra      d7,sortmain      * until all surfaces are sorted
sortend:  rts

serror:   rts                        * On error simply return


**********************************************************************
* Fill surfaces stored in pladress                                   *
**********************************************************************

paintit:  jsr       setclip       * GEM clipping routine for Filled Area
          jsr       sortit        * Sort surfaces according to Z-coords.
          move.w    #1,d0         * Write mode to replace
          jsr       filmode
          jsr       filform       * border filled surfaces
          jsr       filcolor      * Fill color is one
          move.w    #2,d0         * Fill style 
          jsr       filstyle
          move.l    xplot,a1      * Address of screen coordinates
          move.l    yplot,a2
          move.w    surfcount,d7   * Number of surfaces to be filled
          ext.l     d7            * as counter
          subq.l    #1,d7         * access to last surface in the array
          move.l    d7,d0         * multiply by eight
          lsl.l     #3,d0
          move.l    #pladress,a0  * here are the surfaces
          move.l    (a0,d0.l),d5  * largest Z-coordinate
          move.l    #0,d1
          move.l    (a0,d1.l),d6  * first surface in array
          neg.l     d6            * smallest Z-coordinate
          add.l     d6,d5         * subtract from each other
paint1:   move.l    d5,d0
          move.l    (a0,d1.l),d2  * first surface in array
          add.l     d6,d2         * plus smallest Z-coordinate
          lsl.l     #3,d2         * times eight, eight different
          divs      d0,d2         * fill patterns, divide by difference
          neg.w     d2            * leave out last pattern
          add.w     #6,d2
          bpl       paint2
          move.w    #1,d2

paint2:   move.w    d2,d0               * Set fill index
          jsr       filindex
          move.l    #ptsin,a3           * Enter points here
          move.l    4(a0,d1.l),a6       * Address of surface
          move.w    (a6)+,d4            * Number of lines
          addq.w    #1,d4               * first point counts double
          move.w    d4,contrl+2
          move.l    (a6)+,d3            * first line of surface
          swap      d3
          subq.w    #1,d3
          lsl.w     #1,d3
          move.w    (a1,d3.w),(a3)+     * transfer to ptsin array
          move.w    (a2,d3.w),(a3)+     * transmit Y-coordinate
          swap      d3
          sub.w     #1,d3
          lsl.w     #1,d3
          move.w    (a1,d3.w),(a3)+     * transmit next point
          move.w    (a2,d3.w),(a3)+     * transmit Y-coordinate
          subq.w    #3,d4               * two points already transmitted
          ext.l     d4                  * one because of dbra
paint3:   move.l    (a6)+,d3            * next line
          subq.w    #1,d3
          lsl.w     #1,d3
          move.w    (a1,d3.w),(a3)+     * X-coordinate
          move.w    (a2,d3.w),(a3)+     * Y-coordinate
          dbra      d4,paint3           * until all points in ptsin array
          move.w    #9,contrl           * then call the
          move.w    #0,contrl+6         * function Filled
          move.w    grhandle,contrl+12  * Area
          movem.l   d0-d2/a0-a2,-(a7)
          jsr       vdi
          movem.l   (a7)+,d0-d2/a0-a2
          add.l     #8,d1               * work on next
          dbra      d7,paint1           * surface in pladress
          rts


***********************************************************************
* VDI clipping, used only with VDI functions, also for                *
* filling surfaces.                                                   *
***********************************************************************

setclip:  move.w    #129,contrl
          move.w    #2,contrl+2
          move.w    #1,contrl+6
          move.w    grhandle,contrl+12
          move.w    #1,intin
          move.w    clipxule,ptsin
          move.w    clipyule,ptsin+2
          move.w    clipxlri,ptsin+4
          move.w    clipylri,ptsin+6
          jsr       vdi
          rts

          .even


***********************************************************************
***********************************************************************
*  Start of variable area                                             *
*                                                                     *
***********************************************************************

***********************************************************************
* Data area for rotation body                                         *
***********************************************************************
          .bss

numro:    .ds.w     1
numpt:    .ds.w     1

rotxdat:  .ds.l     1
rotydat:  .ds.l     1
rotzdat:  .ds.l     1

rotdatx:  .ds.l     1
rotdaty:  .ds.l     1
rotdatz:  .ds.l     1

r1numline: .ds.w     1
r1nummark: .ds.w     1
r1numsurf:  .ds.w     1

plusagle: .ds.w     1

r1datx:   .ds.w     1540
r1daty:   .ds.w     1540
r1datz:   .ds.w     1540

r1lin:    .ds.l     3200      * 4-Bytes for every line 
r1plane:  .ds.l     6600


          .data


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

***********************************************************************
* here are the definitions of the surfaces for the House              *
*                                                                     *
***********************************************************************

houspla:  .dc.w     4,1,2,2,3,3,4,4,1,4,2,5,5,8,8,3,3,2
          .dc.w     4,5,6,6,7,7,8,8,5,4,7,6,6,1,1,4,4,7
          .dc.w     4,4,3,3,8,8,7,7,4,4,2,9,9,10,10,5,5,2
          .dc.w     4,10,9,9,1,1,6,6,10,3,1,9,9,2,2,1
          .dc.w     3,5,10,10,6,6,5,4,11,12,12,13,13,14,14,11
          .dc.w     4,15,16,16,17,17,18,18,15,4,19,20,20,21,21,22,22,19
          .dc.w     4,23,24,24,25,25,26,26,23

hnummark: .dc.w     26     * Number of corner points in the house
hnumline: .dc.w     32     * Number of lines in the house
hnumsurf:  .dc.w     13    * Number of surfaces in the house

hxangle:   .dc.w     0     * Rotation angle of house about X-axis
hyangle:   .dc.w     0     *         "        "         "  Y-axis
hzangle:   .dc.w     0     *         "        "         "  Z-axis

xwplus:   .dc.w     0      * Angle increment about X-axis
ywplus:   .dc.w     0      * Angle increment about Y-axis
zwplus:   .dc.w     0      * Angle increment about Z-axis

picturex: .dc.w     0      * Definition of zero point of display
picturey: .dc.w     0      * entered by getreso


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

worldpla: .ds.l     1

          .data

plag:     .dc.b     1
          .even

          .bss

diffz:    .ds.w     1

dx:       .ds.w     1
dy:       .ds.w     1
dz:       .ds.w     1

wrldx:    .ds.w     1600    * World coordinate array
wrldy:    .ds.w     1600
wrldz:    .ds.w     1600

viewx:    .ds.w     1600    * View coordinate array
viewy:    .ds.w     1600
viewz:    .ds.w     1600

screenx:  .ds.w     1600    * Screen coordinate array
screeny:  .ds.w     1600


wlinxy:   .ds.l     3200    * Line array



wplane:   .ds.l     6600    * Surface array

vplane:   .ds.l     6600    * Surface array of visible surfaces

platz:    .ds.l     2
pladress: .ds.l     3000    * Surface array

surfcount: .ds.w     1

numsurf:   .ds.w     1

zcount:   .ds.l     1       * Sum of all Z-coord.
zsurf:     .ds.w     1      * Individual Z-coord.of surface

sx:       .ds.w     1
sy:       .ds.w     1
sz:       .ds.w     1

px:       .ds.w     1
py:       .ds.w     1
pz:       .ds.w     1

rx:       .ds.w     1
ry:       .ds.w     1
rz:       .ds.w     1

qx:       .ds.w     1
qy:       .ds.w     1
qz:       .ds.w     1

kx:       .ds.w     1
ky:       .ds.w     1
kz:       .ds.w     1

          .data

prox:     .dc.w     0       * Coordinates of projection
proy:     .dc.w     0       * center, on the positive
proz:     .dc.w     1500    * Z-axis

          .data

offx:     .dc.w     0       * Transformation through rotation
offy:     .dc.w     0       * to point [offx,offy,offz]
offz:     .dc.w     0

xoffs:    .dc.w     0       * Inverse transformation to point
yoffs:    .dc.w     0       * [xoff,yoffs,zoffs]
zoffs:    .dc.w     0


          .bss

loopc:    .ds.l     1
          .end


