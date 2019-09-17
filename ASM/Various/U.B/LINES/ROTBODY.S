***********************************************************************
*  menu1.s          2/18/1986                                         *
*  Creation of rotation bodies     Uwe Braun 1985  Version 2.2        *
*  with hidden line algorithm and painting                            *
*                                                                     *
***********************************************************************
          .globl    main,xoffs,yoffs,zoffs,offx,offy,offz
          .globl    viewx,viewy,viewz
          .globl    wlinxy,mouse_off,setrotdp,inp_chan,pointrot
          .text

main:
          jsr       apinit       * Announce programm
          jsr       grafhand     * Get screen handler
          jsr       openwork     * Display
          jsr       mouse_off    * Turn off mouse
          jsr       getreso      * Display resolution
          jsr       setcocli     * set Cohen sutherland clip.

main1:    jsr       clearbuf
          jsr       menu

          jsr       makerot1     * create rotation body

          jsr       makewrld     * create world system
          jsr       wrld2set     * pass world parameters
          jsr       pageup
          jsr       clwork
          jsr       setrotdp     * initialize observer ref. point
          jsr       pagedown     * Display logical screen page
          jsr       clwork
          jsr       inp_chan

mainlop1:
          jsr       pointrot     * rotate around observ. ref. point
          jsr       pers         * Perspective transformation
          jsr       drawn1

          jsr       pageup       * Display physical screen page
          jsr       testhide

          jsr       inp_chan     * Input new parameters
          jsr       clwork       * clear page not displayed
          jsr       pointrot     * Rotate around rot ref. point
          jsr       pers         * Transform new points
          jsr       drawn1

          jsr       pagedown     * Display this logical page
          jsr       inp_chan     * Input and change parameters
          jsr       clwork       * erase physical page
          jmp       mainlop1     * to main loop

mainend:  move.l    physbase,logbase

          jsr       pageup      * switch to normal screen page
          rts                   * back to link file and end


**********************************************************************
*  Display menu and selection of menu points                         *
**********************************************************************

menu:     jsr       switch      * Display and draw the same
          move.l    #text2,a0   * screen page
          jsr       printf      * Display menu list
          move.l    #text3,a0
          jsr       printf

menu0:    jsr       inkey       * Read keyboard
          swap      d0
          cmp.b     #$3b,d0     * F1 key pressed ?
          bne       menu1
          jsr       inpmous     * if yes, enter a line
          bra       menu

menu1:    cmp.b     #$3c,d0     * F2 key pressed ?
          bne       menu2
          move.w    #4,r1numro  * if yes, then initial number of 
          bra       menend      * rotations to four

menu2:    cmp.b     #$3d,d0     * F3 key
          bne       menu3
          move.w    #8,r1numro
          bra       menend

menu3:    cmp.b     #$3e,d0     * F4 key
          bne       menu4
          move.w    #12,r1numro
          bra       menend

menu4:    cmp.b     #$3f,d0     * F5 key
          bne       menu5
          move.w    #18,r1numro
          bra       menend

menu5:    cmp.b     #$40,d0     * F6 key
          bne       menu6
          move.w    #24,r1numro
          bra       menend

menu6:    cmp.b     #$41,d0     * F7 key
          bne       menu7
          move.w    #45,r1numro
          bra       menend

menu7:    cmp.b     #$42,d0     * F8 key
          bne       menu8
          move.w    #60,r1numro
          bra       menend

menu8:                          * Room for additional keyboard commands

menu9:    cmp.b     #$44,d0     * F10 key
          bne       menu0
          addq.l    #4,a7
          bra       mainend
menend:   rts


*****************************************************************
*  Test if removal of hidden surface and shading of surfaces    *
*  is desired                                                   *
*****************************************************************

testhide: jsr       inkey         * Read keyboard
          swap      d0
          cmp.b     #$23,d0       * h key pressed ?
          beq       dohide        * if yes, call hideit
          cmp.b     #$19,d0       * p key pressed ?
          beq       dopaint       * is yes, shade
          rts                     * if not, return

*******************************************************************
*  Call hideit routine to remove hidden Surfaces                  *
*******************************************************************

dohide:   jsr       switch        * or you won't see anything
          jsr       clwork        * erase display
          jsr       hideit        * remove
          jsr       surfdraw       * and draw

dohide1:  jsr       inkey         * shade too ?
          swap      d0
          cmp.b     #$19,d0       * if yes, call fill routine
          beq       dopain2
          cmp.b     #$1c,d0       * if not, wait for activation of
          bne       dohide1       * Return key on main keyboard
          jsr       pageup
          rts                     * and back

dopain2:  jsr       paintit       * Shade surfaces
dopain3:  jsr       inkey
          swap      d0
          cmp.b     #$1c,d0       * wait for return key
          bne       dopain3
          jsr       pageup
          rts


***********************************************************************
*  Shade all surfaces defined in the world system                     *
***********************************************************************

dopaint:  jsr       switch
          jsr       clwork
          jsr       paintall    * shade all
dopaint1: jsr       inkey
          swap      d0
          cmp.b     #$1c,d0     * and wait for Return key on the
          bne       dopaint1    * main keyboard
          jsr       pageup
          rts



***********************************************************************
*  Create the rotation body                                           *
***********************************************************************

makerot1: jsr       r1set       * Set parameters of this rot. body
          jsr       rotstart    * Create rot. body
          rts



***********************************************************************
*  Input and change parameters                                        *
***********************************************************************

inp_chan: jsr       inkey        * Read keyboard, key code in
          cmp.b     #'D',d0
          bne       inpwait
          jsr       scrdmp       * Make hardcopy

inpwait:  swap      d0           * Test D0 for 
          cmp.b     #$4d,d0      * Cursor-right
          bne       inp1
          addq.w    #1,ywplus    * if yes, add one to Y-angle
          bra       inpend1      * and continue

inp1:     cmp.b     #$4b,d0      * Cursor-left, if yes, subtract
          bne       inp2         * one from Y-angle increment
          subq.w    #1,ywplus
          bra       inpend1

inp2:     cmp.b     #$50,d0      * Cursor-down, if yes
          bne       inp3
          addq.w    #1,xwplus    * add one to X-angle increment
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

inp4:     cmp.b     #$4e,d0      * plus key on the keypad
          bne       inp5         * if yes, subtract 25 from base of
          sub.w     #25,dist     * projection plane (Z-coordinate)
          bra       inpend1
inp5:     cmp.b     #$4a,d0      * minus key on the keypad
          bne       inp6         *
          add.w     #25,dist     * if yes, add 25
          bra       inpend1

inp6:     cmp.b     #$66,d0      *  * key on keypad
          bne       inp7         * if yes, subtract 15 from rotation
          sub.w     #15,rotdpz   * point Z-coordinate
          bra       inpend1      * make changes

inp7:     cmp.b     #$65,d0      * Division key on keypad
          bne       inp8
          add.w     #15,rotdpz   * add 15
          bra       inpend1

inp8:     cmp.b     #$43,d0      * F9 pressed ?, if yes,
          bne       inp10
          jsr       newmidd      * display new screen center
          bra       inpend1

inp10:    cmp.b     #$44,d0      * F10 pressed ?
          bne       inpend1
          addq.l    #4,a7        * if yes, jump to new input
          bra       main1

inpend1:  move.w    hyangle,d1   * Rotation angle about the Y-axis
          add.w     ywplus,d1    * add increment
          cmp.w     #360,d1      * if larger than 360, subtract 360
          bge       inpend2
          cmp.w     #-360,d1     * if smaller than 360,
          ble       inpend3      * add 360
          bra       inpend4
inpend2:  sub.w     #360,d1
          bra       inpend4
inpend3:  add.w     #360,d1

inpend4:  move.w    d1,hyangle

          move.w    hxangle,d1   * procede in the same manner with the
          add.w     xwplus,d1    * rotation angle about the X-axis
          cmp.w     #360,d1
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


******************************************************************
* Set the location of the coordinate origin of the screen        *
* system with the mouse                                          *
******************************************************************

newmidd:  jsr       switch
          jsr       mousform    * change mouse form
newmidd1: move.w    x0,d2
          move.w    y0,d3
          jsr       mouspos     * wait for mouse input
          move.w    x0,d2       * must be called for unknown reasons 
          move.w    y0,d3       * twice for one input of the
          jsr       mouspos     * Position
          cmp.b     #$20,d1     * left button ? if not, then 
          bne       newmidd1    * once more from the beginning
          move.w    d2,x0       * store new coordinates
          move.w    d3,y0
          rts


******************************************************************
*  Determine the current screen resolution                       *
******************************************************************

getreso:  move.w    #4,-(a7)
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


**********************************************************************
*   Hardcopy of screen, called by inp_chan                           *
**********************************************************************

scrdmp:   move.w    #20,-(a7)
          trap      #14
          addq.l    #2,a7
          jsr       clearbuf
          rts


***********************************************************************
*   Initialize the rotation reference point to [0,0,0]                *
***********************************************************************

setrotdp: move.w    #0,d1        * set the initial rotation
          move.w    d1,rotdpx    * ref. point
          move.w    d1,rotdpy
          move.w    d1,rotdpz
          move.w    #0,hyangle    * initial rotation angle
          move.w    #0,hzangle
          move.w    #0,hxangle
          move.w    #0,ywplus
          move.w    #0,xwplus
          move.w    #0,zwplus
          rts

**********************************************************************
*  Rotation around the rot. ref. point about all three axes          *
**********************************************************************

pointrot: move.w    hxangle,xangle * rotate the world around the
          move.w    hyangle,yangle
          move.w    hzangle,zangle
          move.w    rotdpx,d0      * rotation ref. point
          move.w    rotdpy,d1
          move.w    rotdpz,d2
          move.w    d0,xoffs       * add for inverse transformation
          move.w    d1,yoffs
          move.w    d2,zoffs
          neg.w     d0
          neg.w     d1
          neg.w     d2
          move.w    d0,offx        * subtract for tranformation
          move.w    d1,offy
          move.w    d2,offz
          jsr       matinit        * initialize matrix
          jsr       zrotate        * rotate 'matrix' about Z-axis
          jsr       yrotate        * rotate 'matrix' about Y-axis
          jsr       xrotate        * then rotate about X-axis
          jsr       rotate         * multiply point with matrix
          rts

*********************************************************************
* Set the limit of display window for the Cohen-Sutherland clip     *
* algorithm built into the draw-line algorithm                      *
* The limits are freely selectable by the user which makes the      *
* draw-line algorithm very flexible.                                *
*********************************************************************

setcocli: move.w    #0,clipxule
          move.w    #0,clipyule
          move.w    picturex,d1
          lsl.w     #1,d1         * times two
          subq.w    #1,d1         * minus one equals
          move.w    d1,clipxlri   * 639 for monochrome
          move.w    picturey,d1
          lsl.w     #1,d1         * times two minus one equals
          subq.w    #1,d1         * 399 for monochrome
          move.w    d1,clipylri
          rts

**********************************************************************
* Transfer object data into the world system .                       *
**********************************************************************

makewrld: move.l    #r1datx,a1      * create the world system through
          move.l    #r1daty,a2
          move.l    #r1datz,a3
          move.l    #wrldx,a4       * copying the point coordinates
          move.l    #wrldy,a5       * into the world system
          move.l    #wrldz,a6
          move.w    r1nummark,d0
          ext.l     d0
          subq.l    #1,d0
makewl1:  move.w    (a1)+,(a4)+
          move.w    (a2)+,(a5)+
          move.w    (a3)+,(a6)+
          dbra      d0,makewl1
          move.w    r1numline,d0    * Number of lines 
          ext.l     d0
          subq.l    #1,d0
          move.l    #r1lin,a1
          move.l    #wlinxy,a2
makewl2:  move.l    (a1)+,(a2)+     * Copy lines into world Line
          dbra      d0,makewl2      * array

          move.l    worldpla,a0     * Adress of surface definition
          move.l    #wplane,a1      * of the body,
          move.w    r1numsurf,d0     * Number of surfaces on the body
          ext.l     d0              * as counter
          subq.l    #1,d0

makewl3:  move.w    (a0)+,d1        * All lines in this surface,
          move.w    d1,(a1)+        * and of course the number of
          ext.l     d1              * surfaces copied to world surface
          subq.l    #1,d1           * array

makewl4:  move.l    (a0)+,(a1)+     * copy every line of this surface
          dbra      d1,makewl4      * to the world array

          dbra      d0,makewl3      * until all surfaces are completed
          rts


wrldset:  move.l    #wrldx,datx     * Pass variables for
          move.l    #wrldy,daty     * the rotation routine
          move.l    #wrldz,datz
          move.l    #viewx,pointx
          move.l    #viewy,pointy
          move.l    #viewz,pointz
          move.l    #wlinxy,linxy
          move.w    picturex,x0     * Coordinate source for the
          move.w    picturey,y0     * screen system
          move.w    proz,zobs       * projection center
          move.w    r1z1,dist       * position of projection plane
          move.l    #screenx,xplot
          move.l    #screeny,yplot
          move.w    hnumline,numline
          move.w    hnummark,nummark
          move.w    hnumsurf,numsurf
          rts


*********************************************************************
*  Enter visible surface into the vplane array                      *
*********************************************************************

hideit:
          move.w    numsurf,d0   * Number of surfaces as counter
          ext.l     d0
          subq.l    #1,d0
          move.l    #viewx,a1    * point coordinates stored here
          move.l    #viewy,a2
          move.l    #viewz,a3
          move.l    #wplane,a0   * here is information for every
          move.l    #vplane,a5   * surface
          move.w    #0,surfcount  * counts the known visible surfaces

          move.l    #pladress,a6 * Address of the surface storage

visible:  move.w    (a0),d1      * start with first surface, number
          ext.l     d1           * of points in this surface in D1
          move.w    2(a0),d2     * Offset of first point of this surface
          move.w    4(a0),d3     * Offset of second point
          move.w    8(a0),d4     * Offset of third point
          subq.w    #1,d2        * Subtract one from current point offset
          subq.w    #1,d3        * for access to point srray
          subq.w    #1,d4
          lsl.w     #1,d2        * then multiply by two
          lsl.w     #1,d3
          lsl.w     #1,d4        * and finally access the current
          move.w    (a1,d3.w),d6 * point coordinates
          cmp.w     (a1,d4.w),d6 * comparison recognizes two points
          bne       doit1        * with some coordinates which can occur
          move.w    (a2,d3.w),d6 * during construction of rotation
          cmp.w     (a2,d4.w),d6 * bodies. If two
          bne       doit1        * points where all point coordinates
          move.w    (a3,d4.w),d6 * (x,y,z) match, the program selects
          cmp.w     (a3,d3.w),d6 * a third point to determine the two
          bne       doit1        * vectors
          move.w    12(a0),d4
          subq.w    #1,d4
          lsl.w     #1,d4

doit1:
          move.w    (a1,d3.w),d5   * here the two vectors which lie in the
          move.w    d5,kx          * surface plane are detemined by          *                                  *  subtraction
          sub.w     (a1,d2.w),d5   * of coordinates from two points of the
          move.w    d5,px          * points in this surface
          move.w    (a2,d3.w),d5
          move.w    d5,ky          * the direction coordinates of the
          sub.w     (a2,d2.w),d5   * vector are stored in the variables
          move.w    d5,py          * qx,qy,qz and px,py,pz
          move.w    (a3,d3.w),d5
          move.w    d5,kz
          sub.w     (a3,d2.w),d5
          move.w    d5,pz

          move.w    (a1,d4.w),d5   * calculation of vector Q
          sub.w     (a1,d2.w),d5
          move.w    (a2,d4.w),d6
          sub.w     (a2,d2.w),d6
          move.w    (a3,d4.w),d7
          sub.w     (a3,d2.w),d7
          move.w    d5,d1           * qx
          move.w    d6,d2           * qy
          move.w    d7,d3           * qz

          muls      py,d3           * calculation of the cross product
          muls      pz,d2           * of the vector perpendicular to
*                                   * the surface
          sub.w     d2,d3           * surface
          move.w    d3,rx
          muls      pz,d1
          muls      px,d7
          sub.w     d7,d1           * the direction coordinates of
*                                   * the vector
          move.w    d1,ry           * which is perpendicular to the 
          muls      px,d6           * surface area stored temporarily in 
          muls      py,d5           * rx,ry,rz
          sub.w     d5,d6
          move.w    d6,rz

          move.w    prox,d1        * The projection center is used as
          sub.w     kx,d1          * the comparison point for the
          move.w    proy,d2        * visibility of a surface, which is
          sub.w     ky,d2          * adequate for this viewing
          move.w    proz,d3        * situation. One can also use
          sub.w     kz,d3          * the observation ref. point
          muls      rx,d1          * as the comparison point.
          muls      ry,d2          * Now follows the comparison of the
          muls      rz,d3          * vector R and the vector from
          add.l     d1,d2          * one point on the surface to the
          add.l     d2,d3          * projection center by creating the
          bmi       dosight        * scalar product of the two vectors.


* the surface is visible, otherwise continue with next surface.

          move.w    (a0),d1    * Number of lines in surface
          ext.l     d1
          lsl.l     #2,d1      * Number of lines times 4 = space for lines
          addq.l    #2,d1      * plus 2 bytes for the number of lines

          add.l     d1,a0      * add to surface array, for access to
sight1:   dbra      d0,visible * next surface. If all surfaces
          bra       hideend    * completed, go to end.


dosight:  move.w    (a0),d1    * Number of lines in this surface
          ext.l     d1         * multiplied by two gives result of

          move.l    d1,d2
          lsl.l     #1,d1      * number of words to be transmitted
          move.l    a0,a4
          addq.l    #2,a4      * Access to first line of surface
          move.w    #0,zsurf   * Erase addition storage

sight2:   move.l    (a4)+,d6   * first line of surface
          swap      d6         * first point in lower half of D0
          subq.w    #1,d6      * adapt Index
          lsl.w     #1,d6      * adapt Operand size (2-byte)

          move.w    (a3,d6.w),d6  * Z-coordinate of this point
          add.w     d6,zsurf       * add all Z-Coordinates
          dbra      d2,sight2     * until all lines have been processed

          move.w    zsurf,d6      * Divide sum of all Z-coordinates of
          ext.l     d6            * this surface by the number of lines in
          lsr.l     #2,d6         * the surface. Surfaces created by 
          ext.l     d6            * rotation always have four lines

          move.l    d6,(a6)+      * store middle Z-coordinates
          move.l    a0,(a6)+      * followed by address of surface

sight3:   move.w    (a0)+,(a5)+   * transmit the number of lines

          dbra      d1,sight3     * and the individual lines

          addq.w    #1,surfcount  * add one to the number of surfaces
          bra       sight1        * and work on next one

hideend:  rts


*********************************************************************
*  Draw all surfaces contained in vplane                            *
*********************************************************************

surfdraw:                        * Draws the number of surfaces passed
          move.l    xplot,a4     * in surfcount whose descriptions
          move.l    yplot,a5

          move.l    #vplane,a6   * were entered by hideit in the array
          move.w    surfcount,d0 * at address vplane
          ext.l     d0
          subq.l    #1,d0        * if there are no surfaces in the array
          bmi       surfend      * then end.
surflop1:  move.w    (a6)+,d1    * Number of lines in this surface
          ext.l     d1           * as counter of lines to be drawn.
          subq.l    #1,d1

surflop2:  move.l  (a6)+,d5      * first line of this surface

          subq.w  #1,d5          * Access to screen array where
          lsl.w   #1,d5          * screen coordinates of points are.
          move.w  0(a4,d5.w),d2
          move.w  0(a5,d5.w),d3  * extract points
          swap    d5             * pass routine.
          subq.w  #1,d5
          lsl.w   #1,d5
          move.w  0(a4,d5.w),a2  * second point belonging to
          move.w  0(a5,d5.w),a3  * line
          jsr     drawl          * draw line, until all lines in this
          dbra    d1,surflop2    * surface are drawn and repeat
          dbra    d0,surflop1    * until all surfaces are drawn.
surfend: rts                     * finally return.




**********************************************************************
* Set parameters of this rotation body                               *
**********************************************************************

r1set:
          move.l    #r1xdat,rotxdat    * Pass parameters of this
          move.l    #r1ydat,rotydat    * rotation body to routine
          move.l    #r1zdat,rotzdat    * for generating the
          move.l    #r1datx,rotdatx
          move.l    #r1daty,rotdaty    * rotation body
          move.l    #r1datz,rotdatz
          move.l    rotdatx,datx       * Array addresses of points
          move.l    rotdaty,daty
          move.l    rotdatz,datz
          move.w    r1numro,numro      * Number of desired rotatations.
          move.w    r1numpt,numpt      * Number of points to be rotated
          move.l    #r1lin,linxy       * Address of line array
          move.l    #r1plane,worldpla  * Address of surface array
          rts



***********************************************************************
*  and create rotation body                                           *
***********************************************************************

rotstart: move.w    numpt,d0           * Rotate the def line
          lsl.w     #1,d0              * numro+1 times about the Y-axis
          ext.l     d0
          move.l    d0,plusrot         * Storage space for one line
          move.w    numpt,nummark      * Number of points
          move.l    rotdatx,pointx     * rotate to here
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
          jsr       rotlin           * Create line array
          jsr       rotsurf           * Create surface array
          rts

rotlin:
          move.w    #1,d7
          move.w    numro,d4         * Number of rotations
          ext.l     d4
          subq.l    #1,d4
          move.w    numpt,d1         * Number of points in the def. line.
          subq.w    #1,d1            * both as counter
          lsl.w     #2,d1            * times two
          ext.l     d1
          move.l    d1,plusrot

rotlop1:  move.w    numpt,d5         * Number of points minus one
          ext.l     d5               * repeat, last line
          subq.l    #2,d5            * connects the points (n-1,n)
          move.l    linxy,a1
          move.w    d7,d6
rotlop2:  move.w    d6,(a1)+         * the first line connects the
          addq.w    #1,d6            * points (1,2) then (2,3) etc.
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

rotlop4:  move.w    d5,(a1)+       * now generate the cross connections
          add.w     delta1,d5      * which connect the individual lines
          move.w    d5,(a1)+       * created by rotation
          dbra      d1,rotlop4
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
          move.w    d2,r1numline  * Number of lines stored
          rts


rotsurf:   move.w    numro,d0    * create surfaces of the
          ext.l     d0           * rotation body
          subq.l    #1,d0
          move.w    numpt,d7     * Number of points minus one
          ext.l     d7           * repeat
          subq.l    #2,d7
          move.l    d7,plusrot

          move.l    worldpla,a0  * Address of surface array
          move.w    #1,d1
          move.w    numpt,d2     * Number of points
          addq.w    #1,d2

rotfl1:   move.l    plusrot,d7   * Offset
rotfl2:   move.w    d1,d4
          move.w    d2,d5
          addq.w    #1,d4
          addq.w    #1,d5
          move.w    #4,(a0)+      * Number of lines / surfaces

          move.w    d1,(a0)+      * the first surface is
          move.w    d4,(a0)+      * created here 
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



************************************************************************
* Transfer the world parameters and the variables to the link file     *
************************************************************************

wrld2set: move.l    #wrldx,datx      * transfer the world parameters
          move.l    #wrldy,daty      * and the variables to the
          move.l    #wrldz,datz      * routines in the link file
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


**********************************************************************
*  Sort all surfaces entered in pladress                             *
**********************************************************************

sortit:   move.l    #pladress,a0
          move.w    surfcount,d7
          ext.l     d7               * for i = 2 to n corresponds to
          subq.l    #2,d7            * number of runs
          bmi       serror           * for i = 1 to n-1 because of
          move.l    #1,d1            * different array structure
sortmain: move.l    d1,d2
          subq.l    #1,d2            * j = i -1
          move.l    d1,d3            * i
          lsl.l     #3,d3
          move.l    (a0,d3.l),d5     * Comparison value x = a[i]
          move.l    4(a0,d3.l),d6    * address of the surface
          move.l    d5,space         * a[0] = x = a[-1] in this
          move.l    d6,space+4       * array
sortlop1: move.l    d2,d4            * j
          lsl.l     #3,d4            * j times 8 for access to array
          cmp.l     (a0,d4.l),d5     * Z-coordinate of surface
          bge       sortw1           * while x < a[j] do

          move.l    (a0,d4.l),8(a0,d4.l)    * a[j+1] = a[j]
          move.l    4(a0,d4.l),12(a0,d4.l)  * Address of surface array
          subq.l    #1,d2                   * j = j-1
          bra       sortlop1

sortw1:   move.l    d5,8(a0,d4.l)    * a[j+1] = x
          move.l    d6,12(a0,d4.l)   * Pass address also
          addq.l    #1,d1            * i = i + 1
          dbra      d7,sortmain      * Until all surfaces have been sorted
sortend:  rts

serror:   rts                        * On error simply return

********************************************************************
* paintall draws all surfaces in world array wplane independent of *
* their visibility; all surface addresses and middle Z-coordinates *
* are entered into the pladress array.                             *
********************************************************************

paintall:
           move.w   numsurf,d0       * Number of surfaces 
           ext.l    d0
           subq.l   #1,d0            * if no surface present 
           bmi      pquit            * then terminate

          move.l    #viewz,a3
          move.l    #wplane,a0
          move.w    #0,surfcount     * Surface counter for surfdraw
          move.l    #pladress,a6     * surfaces are entered here

svisible:
          move.w    (a0),d1          * all surfaces are visible
          ext.l     d1
          subq.l    #1,d1
          move.w    #0,zsurf         * middle Z-coordinate
          move.l    a0,a4
          addq.l    #2,a4
ssightb1: move.l    (a4)+,d2         * first line of surface
          swap      d2
          subq.w    #1,d2
          lsl.w     #1,d2


ddoit1:    move.w   (a3,d2.w),d6     * add all Z-coordinates of this
           add.w    d6,zsurf         * surface
           dbra     d1,ssightb1
           move.w   zsurf,d6
           ext.l    d6               * then divide by four, shifting
           lsr.l    #2,d6            * is possible only with rotation 
           ext.l    d6               * bodies since each surface has 
           move.l   d6,(a6)+         * exactly four lines otherwise divide
           move.l   a0,(a6)+         * by number of lines

          addq.w    #1,surfcount * increment surface counter for surfdraw
          move.w    (a0),d1     * A0 still points to number of lines
          ext.l     d1          * in this surface
          lsl.l     #2,d1       * Number of lines times four (1 long)
          addq.l    #2,d1       * 2 bytes for the number of lines

          add.l     d1,a0       * A0 points to next surface
          dbra      d0,svisible
          move.w    numsurf,surfcount
          jsr       paintit     * Fill surfaces in pladress
pquit:    rts

paintit:  jsr       setclip     * GEM clipping routine for filled area
          jsr       sortit      * Sort surfaces according to Z-coordinates
          move.w    #1,d0       * Write mode to replace
          jsr       filmode
          jsr       filform     * frame filled surface
          jsr       filcolor    * Shading color is one
          move.w    #2,d0       * Fill style 
          jsr       filstyle
          move.l    xplot,a1    * Address of screen coordinates
          move.l    yplot,a2
          move.w    surfcount,d7 * Number of surface to be filled
          ext.l     d7           * as counter
          subq.l    #1,d7        * access last surface in array
          move.l    d7,d0        * multiply by eight
          lsl.l     #3,d0
          move.l    #pladress,a0        * here are largest Z-coordinate
          move.l    (a0,d0.l),d5        * surfaces
          move.l    #0,d1
          move.l    (a0,d1.l),d6        * first surface in array
          neg.l     d6                  * smallest Z-coordinate
          add.l     d6,d5               * subtract from one another
paint1:   move.l    d5,d0
          move.l    (a0,d1.l),d2        * first surface in array
          add.l     d6,d2               * plus smallest Z-coordinate
          lsl.l     #3,d2               * times eight, eight different
          divs      d0,d2               * shading patterns, divide by 
          neg.w     d2                  * difference leave out last 
          add.w     #6,d2               * pattern.
          bpl       paint2
          move.w    #1,d2

paint2:   move.w    d2,d0               * set fill index
          jsr       filindex
          move.l    #ptsin,a3           * enter points here
          move.l    4(a0,d1.l),a6       * Address of surface
          move.w    (a6)+,d4            * Number of lines
          addq.w    #1,d4               * first point counted twice
          move.w    d4,contrl+2
          move.l    (a6)+,d3            * first line of surface
          swap      d3
          subq.w    #1,d3
          lsl.w     #1,d3
          move.w    (a1,d3.w),(a3)+     * transfer to ptsin array
          move.w    (a2,d3.w),(a3)+     * pass Y-coordinate
          swap      d3
          sub.w     #1,d3
          lsl.w     #1,d3
          move.w    (a1,d3.w),(a3)+     * transmit next point
          move.w    (a2,d3.w),(a3)+     * transmit Y-coordinate
          subq.w    #3,d4               * already two points transmitted
          ext.l     d4                  * and one because of dbra
paint3:   move.l    (a6)+,d3            * next line
          subq.w    #1,d3
          lsl.w     #1,d3
          move.w    (a1,d3.w),(a3)+     * X-coordinate
          move.w    (a2,d3.w),(a3)+     * Y-coordinate
          dbra      d4,paint3           * until all points in Ptsin-Array
          move.w    #9,contrl           * then call the fill area function
          move.w    #0,contrl+6
          move.w    grhandle,contrl+12
          movem.l   d0-d2/a0-a2,-(a7)
          jsr       vdi
          movem.l   (a7)+,d0-d2/a0-a2
          add.l     #8,d1               * work on next surface in pladress
          dbra      d7,paint1
          rts

***********************************************************************
* VDI clipping, only needed when VDI functions are used,              *
* for surface filling.                                                *
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


*******************************************************************
* this subroutine allows coordinates to entered with the Mouse    *
* The maximum number of points is in the variable maxpoint, and   *
* is limited only by storage space                                *
*******************************************************************

inpmous:
          jsr       switch
          move.w    #5,d0
          jsr       setform
          move.w    #1,d0       * set input mode to mouse-request
          move.w    #1,d1       * wait for mouse input which is
          jsr       setmode     * terminated by key activation and
          jsr       coord       * mouse clicking
          move.l    #0,adressx
          move.w    #5,d0       * set polymarker to diagonal cross
          jsr       marktype


mouslop1: jsr       mouspos     * For unknown reasons function must
          move.w    picturex,d2 * be called twice to work once.
          add.w     #15,d2
          move.w    picturey,d3
          sub.w     #40,d3
          jsr       mouspos
          cmp.b     #$20,d1     * wait until the left mouse button is
          bne       mouslop1    * pressed
          move.l    #r1xdat,a4  * arrays in which input
          move.l    #r1ydat,a5  * coordinates are entered; enough
          move.l    #r1zdat,a6  * storage must have been reserved

          move.w    d2,newx     * store mouse X and Y positions
          move.w    d3,newy
          jsr       saveit      * and pass line array
          move.w    newx,d2
          move.w    newy,d3
          jsr       markit      * set a polymarker

          add.l     #1,adressx  * increment counter
mous1:    nop

          move.w    newx,altx
          move.w    newy,alty
mouslop2: move.w    altx,d2     * pass old position of the mouse
          move.w    alty,d3
          jsr       mouspos     * and call again
          jsr       mouspos
          cmp.b     #$21,d1     * if right mouse button, then
          beq       mousend     * end of mouse input
          cmp.b     #$20,d1
          bne       mouslop2
          move.w    d2,newx     * store mouse coordinates
          move.w    d3,newy
          jsr       saveit      * store in array

          move.w    newx,d2     * draw line from (n-1) n'th point
          move.w    newy,d3
          move.w    altx,a2
          move.w    alty,a3
          jsr       drawl
          move.w    newx,d2
          move.w    newy,d3
          jsr       markit      * and mark point with marker

          add.l     #1,adressx  * increment counter
          move.l    adressx,d7
          cmp.l     maxpoint,d7 * and compare with maximum point count
          bne       mous1       * if not equal, continue

          move.l    adressx,d0
          move.w    d0,r1numpt  * Number of points input
          rts

mousend:  move.w    d2,newx
          move.w    d3,newy
          move.w    altx,a2
          move.w    alty,a3
          jsr       markit
          jsr       drawl       * draw last line

          jsr       wait       * and wait for keypress
          jsr       saveit

          add.l     #1,adressx  * also add last point
          move.l    adressx,d0
          move.w    d0,r1numpt  * now store total number of points
          rts                   * finally back to caller



***********************************************************************
*  Wait for mouse input, returns also on keyboard input               *
***********************************************************************

mouspos:  move.w    #28,contrl   * Mouse input, the desired coordinates
          move.w    #1,contrl+2  * where the mouse should appear,
          move.w    #0,contrl+6  * are passed in

          move.w    grhandle,contrl+12

          move.w    d2,ptsin     * D2 and D3
          move.w    d3,ptsin+2
          jsr       vdi
          move.w    intout,d1    * the result - coordinates
          move.w    ptsout,d2    * are also returned in D2 and
          move.w    ptsout+2,d3  * D3
          rts


**********************************************************************
*  Set the polymarker type                                           *
**********************************************************************

marktype: move.w    #18,contrl         * determines the appearance of
          move.w    #0,contrl+2        * the polymarker, desired
          move.w    #1,contrl+6        * type is passed in D0
          move.w    grhandle,contrl+12
          move.w    d0,intin
          jsr       vdi
          rts



***********************************************************************
*  Set a polymarker, number in contrl+2                               *
***********************************************************************

markit:   move.w    #7,contrl
          move.w    #1,contrl+2       * Number of points, in this
          move.w    #0,contrl+6       * case only one
          move.w    grhandle,contrl+12
          move.w    d2,ptsin
          move.w    d3,ptsin+2
          movem.l   d0-d2/a0-a2,-(a7)
          jsr       vdi               * draw marker
          movem.l   (a7)+,d0-d2/a0-a2
          rts




***********************************************************************
*  Set input mode                                                     *
***********************************************************************

setmode:  move.w    #33,contrl        * Set input mode
          move.w    #0,contrl+2
          move.w    #2,contrl+6
          move.w    grhandle,contrl+12
          move.w    d0,intin
          move.w    d1,intin+2        * Parameters in D0 and D1
          jsr       vdi
          rts



***********************************************************************
*  Store coordinates entered in point array                           *
***********************************************************************

saveit:   sub.w     picturex,d2       * Pass mouse coordinates to
          move.w    d2,(a4)+          * rotation line array, with
          sub.w     picturey,d3       * adaptation to coordinate system
          neg.w     d3
          move.w    d3,(a5)+
          move.w    #0,(a6)+
          rts


**********************************************************************
*  Display and describe the same screen page                         *
**********************************************************************

switch:   move.w    #-1,-(a7)         * Display of Display Page,
          move.l    physbase,-(a7)    * where drawing is made
          move.l    physbase,-(a7)
          move.w    #5,-(a7)
          trap      #14
          add.l     #12,a7
          rts



***********************************************************************
*  Change the mouse form                                              *
***********************************************************************

setform:  move.w    #78,contrl        * Set mouse form, desired shape
          move.w    #1,contrl+2
          move.w    #1,contrl+4       * passed in D0
          move.w    #1,contrl+6
          move.w    #0,contrl+8
          move.w    d0,intin
          jsr       aes
          rts



***********************************************************************
*    Drawing a coordinate system for mouse input                      *
***********************************************************************

coord:    jsr       clwork            * draw coordinate system
          move.w    #0,d2             * for mouse input
          move.w    picturey,d3
          move.w    picturex,d5
          lsl.w     #1,d5
          move.w    d5,a2

          move.w    d3,a3
          jsr       drawl
          move.w    picturex,d2
          move.w    #0,d3
          move.w    d2,a2
          move.w    picturey,d5
          lsl.w     #1,d5
          move.w    d5,a3

          jsr       drawl
          rts

******************************************************************
* remove all characters present in the keyboard buffer           *
******************************************************************

clearbuf: move.w    #$b,-(a7)   * Gemdos fnct. character in Buffer ?
          trap      #1
          addq.l    #2,a7
          tst.w     d0          * if yes, get character
          beq       clearnd     * if no, terminate
          move.w    #1,-(a7)    * Gemdos fnct. CONIN
          trap      #1          * repeat, until all characters
          addq.l    #2,a7       * are removed from the buffer
          bra       clearbuf

clearnd:  rts



*********************************************************************
*  Definition of a custom mouse form - Data in mousfor1             *
*********************************************************************

mousform: move.l    #15,d0        * permits the definition of a
          move.l    #mousfor1,a1  * new mouse form, data is
          move.w    #111,contrl   * in mousfor1
          move.w    #0,contrl+2
          move.w    #37,contrl+6
          move.w    grhandle,contrl+12
          move.w    #8,intin
          move.w    #8,intin+2
          move.w    #1,intin+4
          move.w    #0,intin+6
          move.w    #1,intin+8
          move.l    #intin+10,a5
forlop:   move.l    (a1)+,(a5)+
          dbra      d0,forlop
          jsr       vdi
          rts

          .even

***********************************************************************
***********************************************************************
*  Beginning of the Variable area                                     *
*                                                                     *
***********************************************************************
***********************************************************************
* Data area for the rotation body                                     *
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
r1numsurf:  .ds.w    1

plusagle: .ds.w     1

r1datx:   .ds.w     1600
r1daty:   .ds.w     1600
r1datz:   .ds.w     1600

r1lin:    .ds.l     3200      * 4-Bytes for every line e
r1plane:  .ds.l     6600


          .data


r1xdat:   .dc.w 0,40,50,50,20,30,20,30,70,80,80,0
          .dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

r1ydat:   .dc.w 100,100,80,60,40,30,30,-70,-80,-90,-100,-100
          .dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

r1zdat:   .dc.w 0,0,0,0,0,0,0,0,0,0,0,0
          .dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

r1numpt:  .dc.w     12
r1numro:  .dc.w     8


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
* Here is the definition of the surfaces belonging to the house       *
***********************************************************************

houspla:  .dc.w     4,1,2,2,3,3,4,4,1,4,2,5,5,8,8,3,3,2
          .dc.w     4,5,6,6,7,7,8,8,5,4,7,6,6,1,1,4,4,7
          .dc.w     4,4,3,3,8,8,7,7,4,4,2,9,9,10,10,5,5,2
          .dc.w     4,10,9,9,1,1,6,6,10,3,1,9,9,2,2,1
          .dc.w     3,5,10,10,6,6,5,4,11,12,12,13,13,14,14,11
          .dc.w     4,15,16,16,17,17,18,18,15,4,19,20,20,21,21,22,22,19
          .dc.w     4,23,24,24,25,25,26,26,23

hnummark: .dc.w     26    * Number of corner points in the house
hnumline: .dc.w     32    * Number of Lines in the House
hnumsurf:  .dc.w     13    * Number of Surfaces in the House

hxangle:   .dc.w     0     * Rotation angle of House about the  X-axis
hyangle:   .dc.w     0     *         "        "         "    "   Y-axis
hzangle:   .dc.w     0     *         "        "         "    "   Z-Axis

xwplus:   .dc.w     0     * Angle increment about the X-axis
ywplus:   .dc.w     0     * Angle increment about the Y-axis
zwplus:   .dc.w     0     * Angle increment about the Z-axis

picturex: .dc.w     0     * Definition of zero point of screen
picturey: .dc.w     0     * entered by getreso


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

vplane:   .ds.l     6600    * Surface array of visible surface

space:    .ds.l     2
pladress: .ds.l     3000     * Surface array

surfcount: .ds.w     1

numsurf:   .ds.w     1

zcount:   .ds.l     1         * Sum of all Z-coord.
zsurf:    .ds.w     1         * Individual Z-coord. of surface

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

****************************************
          .data
          .even

maxpoint: .dc.l     25
mousx:    .dc.w     0
mousy:    .dc.w     0
mousbut:  .dc.w     0
kybdstat: .dc.w     0

altx:     .dc.w     0
alty:     .dc.w     0
newx:     .dc.w     0
newy:     .dc.w     0

adressx:  .dc.l     1
          .data

prox:     .dc.w     0       * Coordinates of the projections
proy:     .dc.w     0       * center on the positive
proz:     .dc.w     1500    * Z-axis

          .data

offx:     .dc.w     0       * Transformation during rotation
offy:     .dc.w     0       * to point [offx,offy,offz]
offz:     .dc.w     0

xoffs:    .dc.w     0       * Inverse transformation to point
yoffs:    .dc.w     0       * [xoff,yoffs,zoffs]
zoffs:    .dc.w     0


text1:    .dc.b     27,'Y',56,61,' (c) Uwe Braun 1985 ',0
text2:    .dc.b     27,'E',27,'p',13,' Input  ',' 4-Pts  ',' 8-Pts  '
          .dc.b     ' 12-Pts '
          .dc.b     ' 18-Pts ',' 24-Pts ',' 45-Pts ',' 60-Pts '
          .dc.b     '  POS   ','  Quit',27,'q',0
text3:    .dc.b     13, 10,'  F-1   ','  F-2   ','  F-3   ','  F-4   '
          .dc.b     '  F-5   ','  F-6   ','  F-7   ','  F-8   '
          .dc.b     '  F-9   ','  F-10  ',13,0

mousfor1: .dc.w     %1111111111111111
          .dc.w     %1111111111111111
          .dc.w     %1111111111111111
          .dc.w     %1111111111111111
          .dc.w     %1111111111111111
          .dc.w     %1111111111111111
          .dc.w     %1111111111111111
          .dc.w     %1111111111111111
          .dc.w     %1111111111111111
          .dc.w     %1111111111111111
          .dc.w     %1111111111111111
          .dc.w     %1111111111111111
          .dc.w     %1111111111111111
          .dc.w     %1111111111111111
          .dc.w     %1111111111111111
          .dc.w     %1111111111111111


mousdat1: .dc.w     %0000001111100000
          .dc.w     %0000110000010000
          .dc.w     %0001001111001000
          .dc.w     %0010010000100100
          .dc.w     %0100100000010010
          .dc.w     %1001000000010100
          .dc.w     %1001000000010100
          .dc.w     %1000100000100101
          .dc.w     %0100011111001001
          .dc.w     %0010000000010010
          .dc.w     %0001111111100101
          .dc.w     %0011111111111001
          .dc.w     %0111111111111111
          .dc.w     %0111111111111111
          .dc.w     %1111111111111110
          .dc.w     %0000000000000000

          .bss

loopc:    .ds.l     1
          .end


