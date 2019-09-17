***********************************************************************
*  multi1.s         22.2.1986                                         *
*  Multiple objects, four houses                                      *
*  with hidden line algorithm                                         *
*                                                                     *
***********************************************************************

          .globl    main,xoffs,yoffs,zoffs,offx,offy,offz
          .globl    viewx,viewy,viewz
          .globl    wlinxy,mouse_off,setrotdp,inp_chan,pointrot
          .globl    wrldx,wrldy,wrldz,gnummark,gnumline,gnumpla
          .globl    viewx,viewy,viewz,wplane
          .globl    new_it,new_wrld,obj2mrk,obj2pln
          .text


***********************************************************************
*   The program starts here--called by link-file                      *
***********************************************************************

main:
          jsr       apinit       * Announce program
          jsr       grafhand     * Get screen handle
          jsr       openwork     * Announce screen
          jsr       mouse_off    * Switch off mouse
          jsr       getreso      * Screen resolution
          jsr       setcocli     * set Cohen-Sutherland clip.

main1:   jsr       clearbuf
          move.w    #4,gnumobj   * announce four objects
          jsr       pageup
          jsr       clwork       * Screen resolution
          jsr       setrotdp     * initialize obs. ref. point.
          jsr       pagedown     * Display logical screen page
          jsr       clwork
          jsr       inp_chan     * Input and change world parameters
          jsr       change       * Change object parameters
          jsr       new_wrld     * create lines and surfaces

mainlop1:
          jsr       pointrot     * rotate around observ. ref. point
          jsr       pers         * Perspective transformation
          jsr       hideit       * calculate hidden surface
          jsr       surfdraw     * and draw
          jsr       pageup       * Display physical screenpage
          jsr       change       * change object parameters and
          jsr       new_mark     * calculate new coordinates
          jsr       inp_chan     * Input new parameters
          jsr       clwork       * erase page not displayed
          jsr       pointrot     * Rotate around rot. ref. point
          jsr       pers         * Transform new points
          jsr       hideit       * Calculate hidden surfaces
          jsr       surfdraw     * and draw them
          jsr       pagedown     * Display this logical page
          jsr       change       * Change object parameters
          jsr       new_mark     * Calculate new point coordinates
          jsr       inp_chan     * Input and change parameters
          jsr       clwork       * erase physical page
          jmp       mainlop1     * to main loop

mainend:  move.l    physbase,logbase
          jsr       pageup       * switch to normal display page
          rts                    * back to link file, and end


***********************************************************************
*    Create the point coordinates of the world array with the         *
*    information from the object parameter block (object1)            *
***********************************************************************

new_mark: move.w    #0,offx
          move.w    #0,offy
          move.w    #0,offz
          jsr       new_it
          move.l    #viewx,pointx
          move.l    #viewy,pointy
          move.l    #viewz,pointz
          move.l    #wrldx,datx
          move.l    #wrldy,daty
          move.l    #wrldz,datz
          move.l    #wlinxy,linxy
          move.w    gnummark,nummark
          move.w    gnumline,numline
          move.w    gnumpla,numsurf
          rts


**********************************************************************
*   Change the object parameter, in this case the rotation angle     *
*   in the object parameter block, which is then taken into account  *
*   when calculating point coordinates with rnew_mark                *
**********************************************************************

change:   move.w    obj1yw,d0
          add.w     #4,d0
          cmp.w     #360,d0
          blt       changw1
          sub.w     #360,d0
changw1:
          move.w    d0,obj1yw
          move.w    d0,obj2xw
          move.w    d0,obj3zw
          move.w    d0,obj4xw
          move.w    d0,obj4yw
          move.w    d0,obj4zw
          rts


***********************************************************************
*   Set all world parameters for the link file variables and          *
*   create the point, line, and surface arrays of the world system    *
***********************************************************************

new_wrld: move.w    #0,d0
          move.w    d0,offx
          move.w    d0,offy
          move.w    d0,offz
          move.w    proz,zobs
          move.w    #0,dist           * Location of projection plane
          move.l    #screenx,xplot    * Address of screen array
          move.l    #screeny,yplot
          move.w    picturex,x0       * Screen center
          move.w    picturey,y0
          jsr       new_it            * Pass coordinates
          jsr       surf_lin          * Pass lines
          jsr       surf_arr          * Pass surfaces of
          move.w    gnummark,nummark  * all objects to world system
          move.w    gnumline,numline  * Total number of corners, lines
          move.w    gnumpla,numsurf   * and surfaces of world system
          move.l    #wrldx,datx       * Pass parameters of world system to
          move.l    #wrldy,daty       * link file variables 
          move.l    #wrldz,datz
          move.l    #viewx,pointx
          move.l    #viewy,pointy
          move.l    #viewz,pointz
          move.l    #wlinxy,linxy
          rts


***********************************************************************
*   Subroutine for creating the world system coordinate array         *
***********************************************************************

new_it:   move.l    #0,mark_it    * Pointer in wrldx,wrldy,wrldz
          move.w    gnumobj,d0    * Total number of objects
          ext.l     d0            * as counter
          subq.l    #1,d0         * Address of first object parameter
          move.l    #object1,a0   * block after A0.
new_lop1: move.l    (a0),datx     * Object1datx, daty,datz, pass
          move.l    4(a0),daty    * addresses of point array of
          move.l    8(a0),datz    * first object.
          move.l    mark_it,d7    * Offset in point array
          lsl.l     #1,d7         * times two bytes per entry
          move.l    d7,d6
          add.l     #wrldx,d7     * equals offset in world system array
          move.l    d7,pointx     * Target of transmission
          move.l    d6,d7
          add.l     #wrldy,d7
          move.l    d7,pointy
          add.l     #wrldz,d6
          move.l    d6,pointz        * Array of world coordinates
          move.w    20(a0),nummark   * Number of corners in the object
          move.w    26(a0),xoffs     * X-offset
          move.w    28(a0),yoffs     * Y-offset in the world system
          move.w    30(a0),zoffs     * Z-offset
          move.w    32(a0),xangle     * Rotation angle of object around 
          move.w    34(a0),yangle     * the three coordinate axes
          move.w    36(a0),zangle
          movem.l   d0-d7/a0-a6,-(a7)  * Save registers
          jsr       matinit          * Initialize rotation matrix
          jsr       zrotate          * rotate first about the Z-axis, then
          jsr       yrotate          * around Y-axis, and finally
          jsr       xrotate          * around the X-axis (matrix).
          jsr       rotate           * rotate in world coordinate system
          movem.l   (a7)+,d0-d7/a0-a6
          move.w    20(a0),d7        *  Number of corners in the object
          ext.l     d7
          add.l     d7,mark_it       * as offset in point array for
          add.l     #38,a0           * the next object
          dbra      d0,new_lop1      * repeat, until all objects
          move.l    mark_it,d7       * have been pased. After end in
          move.w    d7,gnummark      * mark_it the total number of
          rts                        * points in the world system



***********************************************************************
*   Pass all lines to world system, one-time call at                  *
*   program start since nothing changes in the lines                  *
***********************************************************************

surf_lin: move.w    gnumobj,d0      * Total of all objects
          ext.l     d0
          subq.l    #1,d0           * as counter
          move.l    #object1,a0     * Address of first Object par. blk.
          move.l    #0,linpntr      * Pointer to line array
          move.w    #0,mark_it      * Pointer to point array
sflnlop1: move.l    linpntr,d7      * Line pointer times four,
          lsl.l     #2,d7           * one lines requires four
          move.l    d7,d6           * bytes.
          add.l     #wlinxy,d7      * Start address of line array, add
          move.l    d7,a2           * to line pointer
          move.l    12(a0),a1       * Address of line array of object
          move.w    22(a0),d1       * Number of lines in this object
          ext.l     d1
          lsl.l     #1,d1           * Number of lines times two equals
          subq.l    #1,d1           * Loop counter for word transmission
sflnlop2: move.w    (a1)+,d7        * first point of first line
          add.w     mark_it,d7      * add the offsets of current
          move.w    d7,(a2)+        * objects, and store in world lines
          dbra      d1,sflnlop2     * array, until all lines of this
*                                     object

          move.w    20(a0),d7       * Number of corners of last object
          add.w     d7,mark_it      * add to corner pointer
          move.w    22(a0),d7       * Number of lines
          ext.l     d7
          add.l     d7,linpntr      * Total number of lines
          add.l     #38,a0          * Object offset, distance to next
          dbra      d0,sflnlop1     * object. When all objects are
*                                     completed
          move.l    linpntr,d7      * then store total number of lines
          move.w    d7,gnumline     * in the world system and
          rts                       * back


***********************************************************************
*   Create surface array of the world system, one-time call           *
***********************************************************************

surf_arr: move.w    #0,mark_it      * Create the array of surfaces
          move.l    #0,plapntr
          move.w    #0,gnumpla      * Counter of surfaces
          move.w    gnumobj,d0      * Number of objects
          ext.l     d0              * as loop counter
          subq.l    #1,d0
          move.l    #object1,a0     * Address of first object param. blk

sfarlop1: move.l    plapntr,d7      * Pointer to surface array
          add.l     #wplane,d7      * World surface array
          move.l    d7,a2
          move.w    24(a0),d1    * Number of surfaces on this object
          ext.l     d1           * as loop counter
          subq.l    #1,d1
          move.l    16(a0),a1    * Address of surface array of the object

sfarlop2: move.w    (a1),d2      * Number of lines of this surface
          ext.l     d2
          lsl.l     #1,d2        * times four (one line = four bytes)
          move.l    d2,d6
          lsl.l     #1,d6        * complete the mult. by 4
          addq.l    #2,d6        * plus 2 bytes for number of lines
          subq.l    #1,d2        * counter
          add.l     d6,plapntr
          move.w    (a1)+,(a2)+  * Number of lines in this surface
sfarlop3: move.w    (a1)+,d7     * From the object surface array
          add.w     mark_it,d7   * Add point offset of the object
          move.w    d7,(a2)+     * to world surface array
          dbra      d2,sfarlop3  * until all lines of this surface

          dbra      d1,sfarlop2  * until all surfaces on this object
          move.w    20(a0),d7    * Number of corners
          add.w     d7,mark_it   * add to point offset
          move.w    24(a0),d7
          add.w     d7,gnumpla   * add to total number
          add.l     #38,a0       * Object offset to next object

          dbra      d0,sfarlop1  * until all objects of the world
          rts                    * and return

***********************************************************************
*  Input and change parameters                                        *
***********************************************************************

inp_chan: jsr       inkey        * Read keyboard, key code in
          cmp.b     #'D',d0
          bne       inpwait
          jsr       scrdmp       * make hardcopy

inpwait:  swap      d0           * D0 , test if
          cmp.b     #$4d,d0      * Cursor-right
          bne       inp1
          addq.w    #1,ywplus    * if yes, add one to Y-angle
          bra       inpend1      * increment and continue

inp1:     cmp.b     #$4b,d0      * Cursor-left, if yes then
          bne       inp2         * subtract one from Y-angle
          subq.w    #1,ywplus    * increment
          bra       inpend1

inp2:     cmp.b     #$50,d0      * Cursor-down, if yes then
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
          bne       inp5         * if yes, subtract 25 from position of
          sub.w     #25,dist     * projection plane (Z-coordinate)
          bra       inpend1
inp5:     cmp.b     #$4a,d0      * minus key on the keypad
          bne       inp6         *
          add.w     #25,dist     * if yes, add 25
          bra       inpend1

inp6:     cmp.b     #$66,d0      * times key on keypad
          bne       inp7         * if yes, then subtract 15 from the
*                                  rotation
          sub.w     #15,rotdpz   * point Z-coordinate
          bra       inpend1      * Make change

inp7:     cmp.b     #$65,d0      * Division key on keypad
          bne       inp8
          add.w     #15,rotdpz   * add 15
          bra       inpend1

inp8:

inp10:    cmp.b     #$44,d0      * F10 pressed ?
          bne       inpend1
          addq.l    #4,a7        * if yes, jump to
          bra       mainend      * new input

inpend1:  move.w    hyangle,d1   * Rotation angle about Y-axis
          add.w     ywplus,d1    * add increment
          cmp.w     #360,d1      * when larger than 360, then subtract 360
          bge       inpend2
          cmp.w     #-360,d1     * if smaller then 360, then
          ble       inpend3      * add 360
          bra       inpend4
inpend2:  sub.w     #360,d1
          bra       inpend4
inpend3:  add.w     #360,d1

inpend4:  move.w    d1,hyangle

          move.w    hxangle,d1   * proceed in the same manner with
          add.w     xwplus,d1    * Rotation angle about the X-axis
          cmp.w     #360,d1
          bge       inpend5
          cmp.w     #-360,d1
          ble       inpend6
          bra       inpend7
inpend5:  sub.w     #360,d1
          bra       inpend7
inpend6:  add.w     #360,d1

inpend7:  move.w    d1,hxangle

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
          move.w    d1,rotdpx    * reference point
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
*  Rotation around the rot. ref. point around all three axes         *
**********************************************************************

pointrot: move.w    hxangle,xangle * rotate the world around
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
          move.w    d0,offx      * subtract for transformation
          move.w    d1,offy
          move.w    d2,offz
          jsr       matinit      * matrix initialization
          jsr       zrotate      * rotate 'matrix' aboutZ-axis
          jsr       yrotate      * rotate 'matrix' about Y-axis
          jsr       xrotate      * then rotate around X-axis
          jsr       rotate       * Multiply points with the matrix
          rts
*********************************************************************
* Set the limits of screen window for the Cohen-Sutherland          *
* clip algorithm built into the draw-line algorithm                 *
* The limits can be freely selected by the user, which makes the    *
* draw-line algorithm very flexible.                                *
*********************************************************************

setcocli: move.w    #0,clipxule
          move.w    #0,clipyule
          move.w    picturex,d1
          lsl.w     #1,d1
          subq.w    #1,d1
          move.w    d1,clipxlri
          move.w    picturey,d1
          lsl.w     #1,d1
          subq.w    #1,d1
          move.w    d1,clipylri
          rts


*********************************************************************
*  Entry of visible Surfaces into the vplane array                  *
*********************************************************************

hideit:
          move.w    numsurf,d0    * Number of surfaces as counter
          ext.l     d0
          subq.l    #1,d0
          move.l    #viewx,a1    * The point coordinates are stored
          move.l    #viewy,a2    * here
          move.l    #viewz,a3
          move.l    #wplane,a0   * here is the information for
          move.l    #vplane,a5   * every surface
          move.w    #0,surfcount * counts the known visible surfaces.

visible:  move.w    (a0),d1      * start with first surface. Number of
          ext.l     d1           * points on this surface in D1.
          move.w    2(a0),d2     * Offset of first point on this surface
          move.w    4(a0),d3     * Offset of second point
          move.w    8(a0),d4     * Offset of third point
          subq.w    #1,d2        * subtract one for access to point array
          subq.w    #1,d3        * from current point offset.
          subq.w    #1,d4
          lsl.w     #1,d2        * continue to multiply with two
          lsl.w     #1,d3
          lsl.w     #1,d4        * and then access current
          move.w    (a1,d3.w),d6 * point coordinates
          cmp.w     (a1,d4.w),d6 * Comparison recognizes two points
          bne       doit1        * with matching coordinates, which can 
          move.w    (a2,d3.w),d6 * occur during construction of rotation 
          cmp.w     (a2,d4.w),d6 * bodies. When two identical points 
          bne       doit1        * are found, the program
          move.w    (a3,d4.w),d6 * selects a third point for determination
          cmp.w     (a3,d3.w),d6 * of the two vectors.
          bne       doit1
          move.w    12(a0),d4
          subq.w    #1,d4
          lsl.w     #1,d4

doit1:
          move.w    (a1,d3.w),d5   * here the two vectors which lie in the
          move.w    d5,kx          * surface plane are determined through
          sub.w     (a1,d2.w),d5   * subtraction of the coordinates from
          move.w    d5,px          * two points of the surface
          move.w    (a2,d3.w),d5
          move.w    d5,ky          * The direction coordinates of the
          sub.w     (a2,d2.w),d5   * vectors are stored in the variables
          move.w    d5,py          * qx,qy,qz and px,py,pz.
          move.w    (a3,d3.w),d5
          move.w    d5,kz
          sub.w     (a3,d2.w),d5
          move.w    d5,pz

          move.w    (a1,d4.w),d5   * Calculate vector Q
          sub.w     (a1,d2.w),d5
          move.w    (a2,d4.w),d6
          sub.w     (a2,d2.w),d6
          move.w    (a3,d4.w),d7
          sub.w     (a3,d2.w),d7
          move.w    d5,d1           * qx
          move.w    d6,d2           * qy
          move.w    d7,d3           * qz

          muls      py,d3           * Calculate of the cross product
          muls      pz,d2           * of the vector perpendicular
          sub.w     d2,d3           * to the current surface
          move.w    d3,rx
          muls      pz,d1
          muls      px,d7
          sub.w     d7,d1          * the direction coordinates of the vector
          move.w    d1,ry          * standing vertically to the surface
          muls      px,d6          * are temporarily stored in rx,ry,rz
          muls      py,d5
          sub.w     d5,d6
          move.w    d6,rz

          move.w    prox,d1    * The projection center serves as
*                                the comparison
          sub.w     kx,d1      * point for the visibility of a surface,
          move.w    proy,d2    * which is acceptable for the viewing
          sub.w     ky,d2      * situation chosen here. One can also
          move.w    proz,d3    * use the observation ref. point as
          sub.w     kz,d3      * comparison point.
          muls      rx,d1      * Now follows the comparison of vector
          muls      ry,d2      * R and the vector from one point of the
          muls      rz,d3      * surface to the projection center
          add.l     d1,d2      * by creation of the scalar product
          add.l     d2,d3      * of the two vectors.
          bmi       dosight


* the surface is visible, otherwise continue with next surface.

          move.w    (a0),d1    * Number of lines of the surface
          ext.l     d1
          lsl.l     #2,d1      * Number of lines times 4 = space for Lines
          addq.l    #2,d1      * plus 2 bytes for the number of lines.

          add.l     d1,a0      * add to surface array for access
sight1:   dbra      d0,visible * to next surface. If all surfaces 
          bra       hideend    * are completed, then end.


dosight:  move.w    (a0),d1    * Number of lines in this surface,
          ext.l     d1         * multiplied by two equals the

          move.l    d1,d2
          lsl.l     #1,d1      * number of words to be passed
          move.l    a0,a4
          addq.l    #2,a4      * Access to first line of the Surface

sight3:   move.w    (a0)+,(a5)+  * Pass the number of the lines

          dbra      d1,sight3    * and the individual lines

          addq.w    #1,surfcount  * the number of surfaces plus
          bra       sight1       * one, and work on next one

hideend:  rts


*********************************************************************
*  Draw surfaces entered in vplane                                  *
*********************************************************************

surfdraw:                        * draw surfaces with the count
          move.l    xplot,a4     * of surfaces passed in surfcount
          move.l    yplot,a5

          move.l    #vplane,a6   * Description in array at address
          move.w    surfcount,d0 * vplane, was entered by routine hideit
          ext.l     d0
          subq.l    #1,d0        * if no surface was entered in array,
          bmi       surfend      * then end.
surflop1:  move.w    (a6)+,d1    * Number of lines on this surface
          ext.l     d1           * as counter of lines to be drawn.
          subq.l    #1,d1

surflop2:  move.l    (a6)+,d5     * first line of this surface

          subq.w  #1,d5          * Access to screen array, which contains
          lsl.w   #1,d5          * display coordinates of the
          move.w  0(a4,d5.w),d2  * points.
          move.w  0(a5,d5.w),d3  * extract points, pass from
          swap    d5             * the routine.
          subq.w  #1,d5
          lsl.w   #1,d5
          move.w  0(a4,d5.w),a2  * second point belonging to the the line
          move.w  0(a5,d5.w),a3
          jsr     drawl          * draw line, until all lines of this
          dbra    d1,surflop2    * surface have been drawn and repeat
          dbra    d0,surflop1    * until all surface have been drawn.
surfend: rts                     * finally return.



**********************************************************************
**********************************************************************
*  Display and description of the same screen page                   *
**********************************************************************

switch:   move.w    #-1,-(a7)         * show display page in which
          move.l    physbase,-(a7)    * drawing is being made
          move.l    physbase,-(a7)
          move.w    #5,-(a7)
          trap      #14
          add.l     #12,a7
          rts


******************************************************************
* remove all characters present in the keyboard buffer           *
******************************************************************

clearbuf: move.w    #$b,-(a7)   * Gemdos function. character in buffer ?
          trap      #1
          addq.l    #2,a7
          tst.w     d0          * if yes, get character
          beq       clearnd     * if no, terminate
          move.w    #1,-(a7)    * Gemdos function  CONIN
          trap      #1          * repeat until all characters have
          addq.l    #2,a7       * been removed from the buffer
          bra       clearbuf

clearnd:  rts
          .even

***********************************************************************
***********************************************************************
*                        Start of variable area                       *
*                                                                     *
***********************************************************************


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
* here is the definition of the surfaces belonging to the house       *
***********************************************************************

houspla:  .dc.w     4,1,2,2,3,3,4,4,1,4,2,5,5,8,8,3,3,2
          .dc.w     4,5,6,6,7,7,8,8,5,4,7,6,6,1,1,4,4,7
          .dc.w     4,4,3,3,8,8,7,7,4,4,2,9,9,10,10,5,5,2
          .dc.w     4,10,9,9,1,1,6,6,10,3,1,9,9,2,2,1
          .dc.w     3,5,10,10,6,6,5,4,11,12,12,13,13,14,14,11
          .dc.w     4,15,16,16,17,17,18,18,15,4,19,20,20,21,21,22,22,19
          .dc.w     4,23,24,24,25,25,26,26,23

hnummark: .dc.w     26    * Number of corner points of the house
hnumline: .dc.w     32    * Number of lines of the house
hnumpla:  .dc.w     13    * Number of surfaces of the house

hxangle:   .dc.w     0     * Rotation angle of house about X-axis
hyangle:   .dc.w     0     *         "        "         "   Y-axis
hzangle:   .dc.w     0     *         "        "         "   Z-axis

xwplus:   .dc.w     0     * Angle increment about X-axis
ywplus:   .dc.w     0     * Angle increment about Y-axis
zwplus:   .dc.w     0     * Angle increment about Z-axis

picturex: .dc.w     0     * Definition of zero point on the screen
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

wrldx:    .ds.w     1600    * world coordinate array
wrldy:    .ds.w     1600
wrldz:    .ds.w     1600

viewx:    .ds.w     1600    * view coordinate array
viewy:    .ds.w     1600
viewz:    .ds.w     1600

screenx:  .ds.w     1600    * screen soordinate array
screeny:  .ds.w     1600


wlinxy:   .ds.l     3200    * line array



wplane:   .ds.l     6600    * surface array

vplane:   .ds.l     6600    * surface array of visible surfaces

space:    .ds.l     2
pladress: .ds.l     3000    * surface array

surfcount: .ds.w     1
numsurf:   .ds.w     1

zcount:   .ds.l     1       * Sum of all Z-coordinates
zsurf:     .ds.w     1      * Individual Z-coordinates of the surface

******************************************************************
          .data

gnumobj:  .dc.w     2

gnummark: .dc.w     0
gnumline: .dc.w     0
gnumpla:  .dc.w     0

mark_it:  .dc.l     0
linpntr:  .dc.l     0
plapntr:  .dc.l     0

object1:
obj1xda:  .dc.l     housdatx
obj1yda:  .dc.l     housdaty
obj1zda:  .dc.l     housdatz
obj1lin:  .dc.l     houslin
obj1pla:  .dc.l     houspla
obj1mrk:  .dc.w     26
obj1ali:  .dc.w     32
obj1pln:  .dc.w     13
obj1x0:   .dc.w     150
obj1y0:   .dc.w     100
obj1z0:   .dc.w     0
obj1xw:   .dc.w     20
obj1yw:   .dc.w     0
obj1zw:   .dc.w     0

object2:
obj2xda:  .dc.l     housdatx
obj2yda:  .dc.l     housdaty
obj2zda:  .dc.l     housdatz
obj2lin:  .dc.l     houslin
obj2pla:  .dc.l     houspla
obj2mrk:  .dc.w     26
obj2ali:  .dc.w     32
obj2pln:  .dc.w     13
obj2x0:   .dc.w     -150
obj2y0:   .dc.w     100
obj2z0:   .dc.w     0
obj2xw:   .dc.w     0
obj2yw:   .dc.w     20
obj2zw:   .dc.w     0


object3:
obj3xda:  .dc.l     housdatx
obj3yda:  .dc.l     housdaty
obj3zda:  .dc.l     housdatz
obj3lin:  .dc.l     houslin
obj3pla:  .dc.l     houspla
obj3mrk:  .dc.w     26
obj3ali:  .dc.w     32
obj3pln:  .dc.w     13
obj3x0:   .dc.w     -150
obj3y0:   .dc.w     -100
obj3z0:   .dc.w     0
obj3xw:   .dc.w     0
obj3yw:   .dc.w     20
obj3zw:   .dc.w     0


object4:
obj4xda:  .dc.l     housdatx
obj4yda:  .dc.l     housdaty
obj4zda:  .dc.l     housdatz
obj4lin:  .dc.l     houslin
obj4pla:  .dc.l     houspla
obj4mrk:  .dc.w     26
obj4ali:  .dc.w     32
obj4pln:  .dc.w     13
obj4x0:   .dc.w     150
obj4y0:   .dc.w     -100
obj4z0:   .dc.w     0
obj4xw:   .dc.w     0
obj4yw:   .dc.w     0
obj4zw:   .dc.w     0
          .bss


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

addrssx:  .dc.l     1
          .data

prox:     .dc.w     0       * Coordinates of Projection
proy:     .dc.w     0       * Center on the positive
proz:     .dc.w     1500    * Z-axis

          .data

offx:     .dc.w     0       * transformation during Rotation
offy:     .dc.w     0       * to Point [offx,offy,offz]
offz:     .dc.w     0

xoffs:    .dc.w     0       * Inverse transformation to point
yoffs:    .dc.w     0       * [xoff,yoffs,zoffs]
zoffs:    .dc.w     0

          .bss

loopc:    .ds.l     1
                                                                                 .end
