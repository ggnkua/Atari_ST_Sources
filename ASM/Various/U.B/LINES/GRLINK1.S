***********************************************************************
*  grlink1.s  Graphic Driver Version 4.0                              *
*  The main program must begin with the label " main ".               *
***********************************************************************


***********************************************************************
*    Global variables in the link files                               *
***********************************************************************

   .globl   drawl,sin,sincos,physbase
   .globl   logbase
   .globl   sinx,siny,sinz,cosx,cosy,cosz,wait
   .globl   wait1,drawn1
   .globl   pers,grafhand
   .globl   nummark,xangle,yangle,zangle,numline,datx,daty,datz
   .globl   pointx,pointy
   .globl   pointz,xplot,yplot,x0,y0,z0,z1,linxy,sincos
   .globl   grhandle,global,contrl,intin,intout,ptsin,ptsout
   .globl   addrin,addrout
   .globl   apinit,openwork,clwork,aes,vdi
   .globl   rotate,dist,zobs
   .globl   matrix11,matrix12,matrix13
   .globl   matrix21,matrix22,matrix23
   .globl   matrix31,matrix32,matrix33
   .globl   xrotate,yrotate,zrotate,matinit,inkey
   .globl   mouse_on,mouse_off,printf
   .globl   clipxule,clipyule,clipxlri,clipylri
   .globl   filstyle,filindex,filform,filcolor,filmode,yrot
   .globl   lineavar,pageup,pagedown,plotpt


********************************************************************
*    Program initialization and storage requirement  calculations  *
********************************************************************

    .text

sstart:

   move.l   a7,a5      * Base page address on the stack
   move.l   4(a5),a5   * basepage address = program start - $100
   move.l   $c(a5),d0  * Program length
   add.l    $14(a5),d0 * Length of initialized data area
   add.l    $1c(a5),d0 * Data area not initialized
   add.l    #$1100,d0  * 4 K-byte user stack
   move.l   a5,d1      * Start address of the program
   add.l    d0,d1      * Plus number of occupied bytes = space requirement
   and.l    #-2,d1     * Even address for stack
   move.l   d1,a7      * User stack pointer to last 4K- byte
   move.l   d0,-(sp)   * Length of reserved area 
   move.l   a5,-(sp)   * Beginning address of reserved area 
   move.w   d0,-(sp)   * Dummy-word
   move.w   #$4a,-(sp) * GEM DOS function SETBLOCK
   trap     #1
   add.l    #12,sp     * Restore old stack address
   jsr      start1     * Check on display address
   jsr      inlinea    * Initialize Line-A routines
   jsr      main       * Jump to main program (user-created)
   move.l   #0,-(a7)   * End current program
   trap     #1         * Back to Gem desktop

***********************************************************************
*  Pass upper screen page to video controller                         *
*  while drawing the other                                            *
***********************************************************************

pageup:   move.w    #-1,-(a7)
          move.l    physbase,-(a7)  * Page displayed 
          move.l    logbase,-(a7)   * Draw on this page 
          move.w    #5,-(a7)
          trap      #14
          add.l     #12,a7
          rts
***********************************************************************
*  Display screen page at lower address, while all drawing            *
*  operations after the call go to the higher display                 *
***********************************************************************

pagedown: move.w    #-1,-(a7)
          move.l    logbase,-(a7)   * display logical page 
          move.l    physbase,-(a7)  * draw in the other one
          move.w    #5,-(a7)
          trap      #14
          add.l     #12,a7
          rts


***********************************************************************
*   This subroutine calls AES functions, the user must                *
*   save the Registers D0-D2 and A0-A2 before the aes call,           *
*   which are used by VDI and AES                                     *
***********************************************************************

aes:      move.l    #aespb,d1   * call the AES functions
          move.w    #$c8,d0
          trap      #2
          rts


***********************************************************************
*   call the VDI functions                                            *
***********************************************************************

vdi:      move.l    #vdipb,d1   * call the VDI functions
          move.w    #$73,d0
          trap      #2
          rts


***********************************************************************
*    initialize the Line-A functions, pass the address of             *
*    Line-A variable area in A0, which is then stored                 *
*    in lineavar                                                      *
***********************************************************************

inlinea:  .dc.w     $a000
          move.l    a0,lineavar
          move.w    #0,32(a0)
          move.w    #$ffff,34(a0)
          move.w    #0,36(a0)
          move.w    #1,24(a0)
          rts


***********************************************************************
*   announces application                                             *
***********************************************************************

apinit:   clr.l     d0               * announces an application 
          move.l    d0,ap1resv
          move.l    d0,ap2resv
          move.l    d0,ap3resv
          move.l    d0,ap4resv
          move.w    #10,opcode
          move.w    #0,sintin
          move.w    #1,sintout
          move.w    #0,saddrout
          move.w    #0,saddrin
          jsr       aes
          rts


***********************************************************************
*  Transfers desktop screen handler to caller                         *
***********************************************************************

grafhand: move.w    #77,contrl        * Transfer screen handler 
          move.w    #0,contrl+2
          move.w    #5,contrl+4
          move.w    #0,contrl+6
          move.w    #0,contrl+8
          jsr       aes
          move.w    intout,grhandle
          rts


***********************************************************************
*   open a workstation                                                *
***********************************************************************

openwork: move.w    #100,opcode          * opens a workstation
          move.w    #1,d0
          move.w    #0,contrl+2
          move.w    #11,contrl+6
          move.w    grhandle,contrl+12
          move.w    d0,intin
          move.w    d0,intin+2
          move.w    d0,intin+4
          move.w    d0,intin+6
          move.w    d0,intin+8
          move.w    d0,intin+10
          move.w    d0,intin+12
          move.w    d0,intin+14
          move.w    d0,intin+16
          move.w    d0,intin+18
          move.w    #2,intin+20
          jsr       vdi
          rts


**********************************************************************
*    Clear the screen                                                *
**********************************************************************

clwork:   move.w    #3,contrl           * clear screen VDI function
          move.w    #0,contrl+2
          move.w    #1,contrl+6
          move.w    grhandle,contrl+12
          jsr       vdi
          rts


***********************************************************************
*    Enable mouse                                                     *
***********************************************************************

mouse_on: move.w    #122,contrl         * enable mouse
          move.w    #0,contrl+2         * and control with
          move.w    #1,contrl+6         * operating system
          move.w    grhandle,contrl+12
          move.w    #0,intin
          jsr       vdi
          rts

***********************************************************************
*     Diasble mouse                                                   *
***********************************************************************

mouse_off:  move.w    #123,contrl         * Disable mouse
            move.w    #0,contrl+2         * and control
            move.w    #0,contrl+6
            move.w    grhandle,contrl+12
            jsr       vdi
            rts


***********************************************************************
*     write string on screen                                          *
***********************************************************************

printf:   move.l    a0,-(a7)            * write a string
          move.w    #9,-(a7)            * whose starting
          trap      #1                  * is in A0, on the
          addq.l    #6,a7               * screen. String
          rts                           * must end with a zero.

***********************************************************************
* Determine screen address                                            *
***********************************************************************

start1:
          move.w    #2,-(a7)     * Determine the screen
          trap      #14          * address of the system
          addq.l    #2,a7        * which computer ?
          move.l    d0,physbase  * screen start minus 32 K-byte
          sub.l     #$8000,d0
          move.l    d0,logbase   * equals logical display page
          rts

************************************************************************
* Plot  routine  x-coordinate in d2, y-coordinate in d3                *
************************************************************************

plotpt:   movem.l  d0-d2/a0-a2,-(a7)
          tst.w    d2             * X-value less than zero =>
          bmi      stop2
          tst.w    d3             * Y-value less zero
          bmi      stop2
          cmp.w    #639,d2        * X-value greater than 639?
          bhi      stop2          * Display limit 
          cmp.w    #399,d3        * Y-value greater than 399?
          bhi      stop2
          move.w   d2,ptsin
          move.w   d3,ptsin+2
          move.w   #1,intin
          .dc.w    $a001
          movem.l  (a7)+,d0-d2/a0-a2
stop2:    rts


**********************************************************************
* draw-line routine with Cohen-Sutherland clipping. The points are   *
* passed in d2, d3 (start point) and a2, a3 (end point)                *
**********************************************************************

drawl:    movem.l   d0-d7/a0-a6,-(a7)  * Save registers
          move.w    d2,d6              * Determine position
          move.w    d3,d7              * of start point and
          jsr       rel_pos            * store
          move.w    d1,code1
          move.w    a2,d6              * Position of second 
          move.w    a3,d7              * point and store
          jsr       rel_pos
          move.w    d1,code2
          tst.w     d1                 * if points are not in
          bne       testw1             * drawing area continue
          tst.w     code1              * test. Otherwise test
          beq       drawit2            * first point. When visible,
*                                      * draw both points

testw1:   move.w    d1,d0              * If both points on the same
          and.w     code1,d0           * 'page' outside the viewing
          bne       drawend            * window, then do not draw,
          move.w    d2,a0              * else store starting points and
          move.w    d3,a1              * calculate intersecting points
          move.w    a2,a4
          move.w    a3,a5

          tst.w     code2              * is point 2 visible ?
          bne       testw2             * if not, find intersection point
          move.w    a2,rightx          * if yes, store
          move.w    a3,righty
          bra       testw3             * find left intersect point

testw2:   move.w    code1,p1code       * right intersect point
          move.w    code2,p2code
          jsr       fndpoint           * find intersect point
          tst.w     p1code             * if 'intersect point'not
          bne       drawend            * visible, then end

          move.w    d2,rightx          * if visible, then store
          move.w    d3,righty

testw3:   move.w    a4,d2              * and the left intersect point
          move.w    a5,d3              * with switched points
          move.w    a0,a2              * determine with the same routine
          move.w    a1,a3
          move.w    code2,p1code
          move.w    code1,p2code

          tst.w     p2code             * Point visible?
          bne       testw4             * if not, continue test
          move.w    a2,leftx           * if yes, store and
          move.w    a3,lefty           * connect both visible
          bra       drawit1            * points with a line

testw4:   jsr       fndpoint           * Find intersect point
          move.w    d2,leftx           * and store,
          move.w    d3,lefty

drawit1:  move.w    leftx,d2           * connect both points with
          move.w    lefty,d3           * a line
          clr.l     a2
          clr.l     a3
          move.w    rightx,a2
          move.w    righty,a3

drawit2:  move.l    lineavar,a0
          move.w    d2,38(a0)          * X1
          move.w    d3,40(a0)          * Y1
          move.w    a2,42(a0)          * X2
          move.w    a3,44(a0)          * Y2
          .dc.w     $a003              * Draw line
drawend:
endit:    movem.l (a7)+,d0-d7/a0-a6    * Restore registers
          rts                          * Return to calling program


**********************************************************************
*   recognizes the position of a point passed in D6 and D7 relative  *
*   to the clip window defined in the variables clipoli and clipure  *
**********************************************************************

rel_pos:  clr.l     d1             * determines the position
          move.w    d7,d1          * of the point passed in
          sub.w     clipyule,d1    * d6 and d7 relative to
          lsl.l     #1,d1          * the drawing window
          move.w    d7,d1          * defined by clipure
          sub.w     clipylri,d1    * and clipoli
          neg.w     d1
          lsl.l     #1,d1
          move.w    d6,d1
          sub.w     clipxlri,d1
          neg.w     d1
          lsl.l     #1,d1
          move.w    d6,d1
          sub.w     clipxule,d1
          lsl.l     #1,d1
          swap      d1
          rts


**********************************************************************
*  Finds the intersect point, if present,                            *
*  of the the connecting line from P1 to P2 with the clip window     *
*  the points are passed in D2, D3 and A2, A3 as in drawl            *
**********************************************************************

fndpoint: move.w    d2,d4     * Find the center point of
          move.w    d3,d5     * the line P1 P2
          add.w     a2,d4     * (X1 + X2) / 2
          ext.l     d4

          lsr.l     #1,d4
          add.w     a3,d5     * (Y1 + Y2) / 2
          ext.l     d5        * = center point of line P1 P2

          lsr.l     #1,d5
          move.w    d4,d6     * Store center point coord. 
          move.w    d5,d7     * Y middle 
          jsr       rel_pos   * where is the intersect point ?

          move.w    p2code,d6 * Code of center pt. to D6
          and.w     d1,d6     * are the points on the same
          bne       fother    * page outside the screen

          cmp.w     d4,d2     * points coincide ?
          bne       findw1
          cmp.w     d5,d3
          beq       fendit    * if yes => stop

findw1:   cmp.w     d4,a2     * Do middle point and second
          bne       findw2    * point match ?
          cmp.w     d5,a3
          bne       findw2
          bra       fendit    * if yes = stop

findw2:   move.w    d4,d2     * else exchange middle and
          move.w    d5,d3     * first point and start again
          move.w    d1,p1code
          bra       fndpoint

fother:   cmp.w     d4,a2     * middle point and P2 match ?
          bne       fother1
          cmp.w     d5,a3
          beq       fendit    * if yes, then end
fother1:  cmp.w     d4,d2     * middle point and P1 match ?
          bne       fother2
          cmp.w     d5,d3
          beq       fendit    * if yes, then end

fother2:  tst.w     p1code    * is P1 in clip window
          beq       fother3
          move.w    d1,d7     * if not, and P1 and P2 lie
          and.w     p1code,d7 * both on one side of the
          bne       fexit     * Clip-window then none of line is visible
fother3:  move.w    d4,a2     * otherwise take middle point
          move.w    d5,a3     * as new P2 and start again
          move.w    d1,p2code * until the intersect point
          bra       fndpoint  * is found

fexit:    move.w    #1,p1code * Inform calling prog. of termination.

fendit:    rts                * either in d2,d3 middle point, or
*                             * in p1code termination notice


******************************************************************
* sine and cosine Function, angle is passed in D0 and            *
* the sine and cosine are returned in D1 and D2                  *
******************************************************************

sincos:  tst.w   d0            * Angle negative, add 360 degrees
         bpl     noaddi
         add.w   #360,d0
noaddi:  move.l  #sintab,a1    * Beginning address of sine table
         move.l  d0,d2         * Angle in d0 and d2
         lsl.w   #1,d0         * Angle times two as index for access
         move.w  0(a1,d0.w),d1 * sine to d1
         cmp.w   #270,d2       * Calculate cosine through
         blt     plus9         * displacement of sine values
         sub.w   #270,d2       * by 90 degrees
         bra     sendsin
plus9:   add.w   #90,d2
sendsin: lsl.w   #1,d2
         move.w  0(a1,d2.w),d2 * cosine to d2

         rts                   * and back to calling program


********************************************************************
*   sine  function                                                 *
*   Angle is passed in d0 and the sine returned in d1              *
********************************************************************

sin:     move.l   #sintab,a1
         tst.w    d0
         bpl      sin1
         add.w    #360,d0
sin1:    lsl.w    #1,d0
         move.w   0(a1,d0.w),d1
         rts


************************************************************************
* Initialize the main diagnonal of the result matrix with              *
* ones which were multiplied by 2^14.  This subroutine must            *
* be called at least once before the call by rotate, or the            *
* result matrix will only consist of zeros.                            *
************************************************************************

matinit:  move.w    #0,d1
          move.w    #16384,d2       * The initial value for
          move.w    d2,matrix11     * the main diagonal of
          move.w    d1,matrix12     * the result matrix 
          move.w    d1,matrix13     * all other elements
          move.w    d1,matrix21     * at zero
          move.w    d2,matrix22
          move.w    d1,matrix23
          move.w    d1,matrix31
          move.w    d1,matrix32
          move.w    d2,matrix33
          rts



************************************************************************
*  Multiplication of the rotation matrix by the rotation               *
*  matrix for rotation about the X-axis                                *
************************************************************************

xrotate:   move.w    xangle,d0          * multiply matrix11-matrix33
          jsr       sincos             * with the rotation matrix for a
          move.w    d1,sinx            * rotation about the X-axis
          move.w    d2,cosx
          move.w    d1,d3
          move.w    d2,d4
          move.w    matrix11,rotx11    * The first column of the matrix
          move.w    matrix21,rotx21    * does not change with X rotation
          move.w    matrix31,rotx31   
          muls      matrix12,d2
          muls      matrix13,d1
          sub.l     d1,d2
          lsl.l     #2,d2
          swap      d2
          move.w    d2,rotx12
          move.w    d3,d1
          move.w    d4,d2
          muls      matrix22,d2
          muls      matrix23,d1
          sub.l     d1,d2
          lsl.l     #2,d2
          swap      d2
          move.w    d2,rotx22
          move.w    d3,d1
          move.w    d4,d2
          muls      matrix32,d2
          muls      matrix33,d1
          sub.l     d1,d2
          lsl.l     #2,d2
          swap      d2
          move.w    d2,rotx32
          move.w    d3,d1
          move.w    d4,d2
          muls      matrix12,d1
          muls      matrix13,d2
          add.l     d1,d2
          lsl.l     #2,d2
          swap      d2
          move.w    d2,rotx13
          move.w    d3,d1
          move.w    d4,d2
          muls      matrix22,d1
          muls      matrix23,d2
          add.l     d1,d2
          lsl.l     #2,d2
          swap      d2
          move.w    d2,rotx23
          muls      matrix32,d3
          muls      matrix33,d4
          add.l     d3,d4
          lsl.l     #2,d4
          swap      d4
          move.w    d4,rotx33
          move.l    #rotx11,a1
          move.l    #matrix11,a2
          move.l    #9,d7            * Number of matrix elements
          subq.l    #1,d7

rotxlop1: move.w    (a1)+,(a2)+      * Copy result matrix, which
          dbra      d7,rotxlop1      * is still in ROTXnn, to MATRIXnn
          rts

***********************************************************************
* multiply the general rotation matrix by the Y-axis                  *
* rotation matrix. Results are stored in the general                  *
* rotation matrix                                                     *
***********************************************************************

yrotate:  move.w    yangle,d0        * Angle around which rotation is made
          jsr       sincos
          move.w    d1,siny
          move.w    d2,cosy
          move.w    d1,d3           * Sine of Y-angle
          move.w    d2,d4           * Cosine of Y-angle
          muls      matrix11,d2
          muls      matrix13,d1
          add.l     d1,d2
          lsl.l     #2,d2
          swap      d2
          move.w    d2,rotx11
          move.w    d3,d1
          move.w    d4,d2
          muls      matrix21,d2
          muls      matrix23,d1
          add.l     d1,d2
          lsl.l     #2,d2
          swap      d2
          move.w    d2,rotx21
          move.w    d3,d1
          move.w    d4,d2
          muls      matrix31,d2
          muls      matrix33,d1
          add.l     d1,d2
          lsl.l     #2,d2
          swap      d2
          move.w    d2,rotx31
          neg.w     d3
          move.w    d3,d1               * -siny in the rotation matrix
          move.w    d4,d2
          move.w    matrix12,rotx12
          move.w    matrix22,rotx22     * The second column
          move.w    matrix32,rotx32     * of the starting
          muls      matrix11,d1         * matrix does not
          muls      matrix13,d2         * change
          add.l     d1,d2
          lsl.l     #2,d2
          swap      d2
          move.w    d2,rotx13
          move.w    d3,d1
          move.w    d4,d2
          muls      matrix21,d1
          muls      matrix23,d2
          add.l     d1,d2
          lsl.l     #2,d2
          swap      d2
          move.w    d2,rotx23
          muls      matrix31,d3
          muls      matrix33,d4
          add.l     d3,d4
          lsl.l     #2,d4
          swap      d4
          move.w    d4,rotx33
          move.l    #8,d7
          move.l    #rotx11,a1          * Address of result matrix
          move.l    #matrix11,a2        * Address of original matrix
yrotlop1: move.w    (a1)+,(a2)+         * Copy result matrix
          dbra      d7,yrotlop1         * to the original matrix
          rts

***********************************************************************
* Z-axis - Rotation matrix multiplications                            *
***********************************************************************

zrotate:  move.w    zangle,d0
          jsr       sincos
          move.w    d1,sinz
          move.w    d2,cosz
          move.w    d1,d3
          move.w    d2,d4
          muls      matrix11,d2
          muls      matrix12,d1
          sub.l     d1,d2
          lsl.l     #2,d2
          swap      d2
          move.w    d2,rotx11
          move.w    d3,d1
          move.w    d4,d2
          muls      matrix21,d2
          muls      matrix22,d1
          sub.l     d1,d2
          lsl.l     #2,d2
          swap      d2
          move.w    d2,rotx21
          move.w    d3,d1
          move.w    d4,d2
          muls      matrix31,d2
          muls      matrix32,d1
          sub.l     d1,d2
          lsl.l     #2,d2
          swap      d2
          move.w    d2,rotx31
          move.w    d3,d1
          move.w    d4,d2
          muls      matrix11,d1
          muls      matrix12,d2
          add.l     d1,d2
          lsl.l     #2,d2
          swap      d2
          move.w    d2,rotx12
          move.w    d3,d1
          move.w    d4,d2
          muls      matrix21,d1
          muls      matrix22,d2
          add.l     d1,d2
          lsl.l     #2,d2
          swap      d2
          move.w    d2,rotx22
          muls      matrix31,d3
          muls      matrix32,d4
          add.l     d3,d4
          lsl.l     #2,d4
          swap      d4
          move.w    d4,rotx32
          move.w    matrix13,rotx13     * the third column
          move.w    matrix23,rotx23     * remains
          move.w    matrix33,rotx33     * unchanged
          move.l    #8,d7
          move.l    #rotx11,a1
          move.l    #matrix11,a2

zrotlop1: move.w    (a1)+,(a2)+         * copy to general
          dbra      d7,zrotlop1         * rotation matrix
          rts

**********************************************************************
* Multiply every point whose Array address is in datx etc.           *
* by previous translation of the coordinate source to                *
* point [offx,offy,offz], with the general rotation matrix.          *
* The coordinate source of the result coordinates is then            *
* moved to point [xoffs,yoffs,zoffs]                                 *
**********************************************************************

rotate:   move.w    nummark,d0    * Number of points to be
          ext.l     d0            * transformed as counter
          subq.l    #1,d0 
          move.l    datx,a1
          move.l    daty,a2
          move.l    datz,a3
          move.l    pointx,a4
          move.l    pointy,a5
          move.l    pointz,a6
rotate1:  move.w    (a1)+,d1     * X-coordinate
          add.w     offx,d1

          move.w    d1,d4
          move.w    (a2)+,d2      * Y-coordinate
          add.w     offy,d2       * Translation to point [offx,offy,offz]
          move.w    d2,d5
          move.w    (a3)+,d3      * Z-coordinate
          add.w     offz,d3

          move.w    d3,d6
          muls      matrix11,d1
          muls      matrix21,d2
          muls      matrix31,d3
          add.l     d1,d2
          add.l     d2,d3
          lsl.l     #2,d3
          swap      d3
          add.w     xoffs,d3

          move.w    d3,(a4)+      * rotated X-coordinate
          move.w    d4,d1
          move.w    d5,d2
          move.w    d6,d3
          muls      matrix12,d1
          muls      matrix22,d2
          muls      matrix32,d3
          add.l     d1,d2
          add.l     d2,d3
          lsl.l     #2,d3
          swap      d3
          add.w     yoffs,d3

          move.w    d3,(a5)+      * rotated Y-coordinate
          muls      matrix13,d4
          muls      matrix23,d5
          muls      matrix33,d6
          add.l     d4,d5
          add.l     d5,d6
          lsl.l     #2,d6
          swap      d6
          add.w     zoffs,d6

          move.w    d6,(a6)+      * rotated Z-coordinate
          dbra      d0,rotate1
          rts


************************************************************************
* Perspective, calculated from the transformed points in the arrays    *
* pointx, pointy and pointz the screen coordinates, which              *
* are then stored in the arrays xplot and yplot .                      *
************************************************************************

pers:     move.l    pointx,a1      * Beginning address of
          move.l    pointy,a2      * Point arrays
          move.l    pointz,a3
          move.l    xplot,a4       * xplot contains start address of the
          move.l    yplot,a5       * display coordinate array
          move.w    nummark,d0     * Number of points to be transformed
          ext.l     d0             * as counter
          subq.l    #1,d0

perlop:   move.w    (a3)+,d5       * z-coordinate of object
          move.w    d5,d6
          move.w    dist,d4        * Enlargement factor
          sub.w     d5,d4          * dist minus Z-coordinate of Obj.coord
          ext.l     d4
          lsl.l     #8,d4          * times 256 for value fitting 
          move.w    zobs,d3        * Projection center Z-coordinates
          ext.l     d3

          sub.l     d6,d3          * minus Z-coordinate of object
          bne       pers1

          move.w    #0,d1          * Catch division by zero 
          addq.l    #2,a1          * Not really required since 
          addq.l    #2,a2          * computer catches this
          move.w    d1,(a4)+       * with an interrupt 
          move.w    d1,(a5)+
          bra       perend1

pers1:    divs      d3,d4
          move.w    d4,d3
          move.w    (a1)+,d1   * X-coordinate of object
          move.w    d1,d2
          neg.w     d1
          muls      d1,d3      * multiplied by perspective factor 
          lsr.l     #8,d3      * /256 save value range fitting 

          add.w     d3,d2      * add to X-coordinate 
          add.w     x0,d2      * add screen offset (center point)
          move.w    d2,(a4)+   * Display X-coordinate
          move.w    (a2)+,d1   * Y-coordinates of object
          move.w    d1,d2
          neg.w     d1
          muls      d1,d4
          lsr.l     #8,d4      * /256

          add.w     d4,d2
          neg.w     d2         * Display offset, mirror of Y-axis
          add.w     y0,d2      * Source at [X0,Y0]
          move.w    d2,(a5)+   * Display Y-coordinate
perend1:  dbra      d0,perlop  * All points transformed ?
          rts                  * If yes, return


******************************************************************
* Draw number of lines from array from lines in linxy            *
******************************************************************

drawn1: move.l  xplot,a4           * Display X-coordinate
        move.l  yplot,a5           *     "   Y-coordinate
        move.w  numline,d0         * Number of lines  
        ext.l   d0
        subq.l  #1,d0              * as counter
        move.l  linxy,a6           * Address of line array

drlop:  move.l  (a6)+,d1           * first line ,(P1,P2)
        subq.w  #1,d1              * fit to list structure
        lsl.w   #1,d1              * times list element length (2)
        move.w  0(a4,d1.w),d2      * X-coordinate of second point
        move.w  0(a5,d1.w),d3      * Y-coordinate of second point
        swap    d1                 * same procedure for first point
        subq.w  #1,d1
        lsl.w   #1,d1
        move.w  0(a4,d1.w),a2      * X-coordinate of  first point
        move.w  0(a5,d1.w),a3      * Y-coordinate of first point
        jsr     drawl              * draw line from P2 to P2
        dbra    d0,drlop           * All lines drawn ?
        rts



***********************************************************************
*  simple counting loop                                               *
***********************************************************************

wait1     dbra      d0,wait1       * delay loop, counts d0 register
          rts                      * down to -1

***********************************************************************
*   wait for key press, for Test and Error detection                  *
***********************************************************************

wait:    move.w    #1,-(a7)       * wait for key activation
          trap      #1             * GEM DOS call
          addq.l    #2,a7
          rts
***********************************************************************
*  Key sensing, ASCII code returned in lower byte word of D0          *
*  Scan code in upper sord lower byte of D0                           *
*  Returns zero if no input                                           *
***********************************************************************

inkey:    move.w    #2,-(a7)       * Key sensing, does not
          move.w    #1,-(a7)       * wait for a key
          trap      #13            * press
          addq.l    #4,a7
          tst.w     d0
          bpl       endkey
          move.w    #7,-(a7)
          trap      #1
          addq.l    #2,a7
endkey:  rts


***********************************************************************
***********************************************************************
** The six following subroutines are only required                   **
** for the second main program and do not have to be                 **
** entered for linking to the first main program                     **
***********************************************************************
***********************************************************************

filstyle: move.w    #23,contrl         * VDI function, set
          move.w    #0,contrl+2        * fill style passed
          move.w    #1,contrl+6        * in D0
          move.w    grhandle,contrl+12
          move.w    d0,intin
          jsr       vdi
          rts

filindex: movem.l   d0-d2/a0-a2,-(a7)  * set fill pattern

          move.w    #24,contrl         * also passed in D0

          move.w    #0,contrl+2
          move.w    #1,contrl+6
          move.w    grhandle,contrl+12
          move.w    d0,intin
          jsr       vdi
          movem.l   (a7)+,d0-d2/a0-a2
          rts

filcolor: move.w    #25,contrl         * set fill color to
          move.w    #0,contrl+2
          move.w    #1,contrl+6
          move.w    grhandle,contrl+12
          move.w    #1,intin           * one
          jsr       vdi
          rts

filmode:  move.w    #32,contrl         * set write mode 
          move.w    #0,contrl+2
          move.w    #1,contrl+6
          move.w    grhandle,contrl+12 * passed in D0 
          move.w    d0,intin
          jsr       vdi
          rts

filform:  move.w    #104,contrl        * switch on border
          move.w    #0,contrl+2        * around area
          move.w    #1,contrl+6
          move.w    grhandle,contrl+12
          move.w    #1,intin
          jsr       vdi
          rts


*********************************************************************
* Rotation of a number of points (nummark) in array datx etc. around*
* angle yangle around Y-axis to array pointx = address of array     *
*********************************************************************

yrot:   move.w    yangle,d0      * rotate the definition line
          jsr       sincos       * of a rotation body nummark
          move.w    d1,siny      * times about the Y-axis 
          move.w    d2,cosy      * Rotation is done without 
          move.l    datx,a1      * matrix multiplication, 
          move.l    daty,a2      * but directly, from arrays datx
          move.l    datz,a3      * in which the address of the definition
          move.l    pointx,a4    * line was stored into the array 
          move.l    pointy,a5    * whose address is stored
          move.l    pointz,a6    * in pointx etc.
          move.w    nummark,d0
          ext.l     d0           * the rotation is about
          subq.l    #1,d0        * angle -y, i.e. from direction 
ylop:     move.w    (a1)+,d1     * positive Y-axis 
          move.w    d1,d3        * counterclockwise 
          move.w    (a3)+,d2
          move.w    d2,d4        * z' = x*siny + z*cosy
          muls      cosy,d2
          lsl.l     #2, d2       * retract area extension
          swap      d2           * sine values
          muls      siny,d1
          lsl.l     #2,d1
          swap      d1
          add.w     d1,d2
          move.w    d2,(a6)+     * store z'
          muls      siny,d4      * calculate x'
          lsl.l     #2,d4        * x' = x*cosy - z*siny
          swap      d4
          neg.w     d4
          muls      cosy,d3
          lsl.l     #2,d3
          swap      d3
          add.w     d3,d4

          move.w    d4,(a4)+     * store x'
          move.w    (a2)+,(a5)+  * y' = y, since rotation is
          dbra      d0,ylop      * around Y-axis
          rts


***********************************************************************
* Variables for the basic program                                     *
***********************************************************************

        .even
        .data       * Sine table starts here 

sintab: .dc.w       0,286,572,857,1143,1428,1713,1997,2280
        .dc.w       2563,2845,3126,3406,3686,3964,4240,4516
        .dc.w       4790,5063,5334,5604,5872,6138,6402,6664
        .dc.w       6924,7182,7438,7692,7943,8192,8438,8682
        .dc.w       8923,9162,9397,9630,9860,10087,10311,10531
        .dc.w       10749,10963,11174,11381,11585,11786,11982,12176
        .dc.w       12365,12551,12733,12911,13085,13255,13421,13583
        .dc.w       13741,13894,14044,14189,14330,14466,14598,14726
        .dc.w       14849,14962,15082,15191,15296,15396,15491,15582
        .dc.w       15668,15749,15826,15897,15964,16026,16083,16135
        .dc.w       16182,16225,16262,16294,16322,16344,16362,16374
        .dc.w       16382,16384

        .dc.w       16382,16374,16362,16344,16322,16294,16262,16225
        .dc.w       16182
        .dc.w       16135,16083,16026,15964,15897,15826,15749,15668
        .dc.w       15582,15491,15396,15296,15191,15082,14962,14849
        .dc.w       14726,14598,14466,14330,14189,14044,13894,13741
        .dc.w       13583,13421,13255,13085,12911,12733,12551,12365
        .dc.w       12176,11982,11786,11585,11381,11174,10963,10749
        .dc.w       10531,10311,10087,9860,9630,9397,9162,8923
        .dc.w       8682,8438,8192,7943,7692,7438,7182,6924
        .dc.w       6664,6402,6138,5872,5604,5334,5063,4790
        .dc.w       4516,4240,3964,3686,3406,3126,2845,2563
        .dc.w       2280,1997,1713,1428,1143,857,572,286,0

        .dc.w       -286,-572,-857,-1143,-1428,-1713,-1997,-2280
        .dc.w       -2563,-2845,-3126,-3406,-3686,-3964,-4240,-4516
        .dc.w       -4790,-5063,-5334,-5604,-5872,-6138,-6402,-6664
        .dc.w       -6924,-7182,-7438,-7692,-7943,-8192,-8438,-8682
        .dc.w       -8923,-9162,-9397,-9630,-9860,-10087,-10311,-10531
        .dc.w       -10749,-10963,-11174,-11381,-11585,-11786,-11982
        .dc.w       -12176
        .dc.w       -12365,-12551,-12733,-12911,-13085,-13255,-13421
        .dc.w       -13583
        .dc.w       -13741,-13894,-14044,-14189,-14330,-14466,-14598
        .dc.w       -14726
        .dc.w       -14849,-14962,-15082,-15191,-15296,-15396,-15491
        .dc.w       -15582
        .dc.w       -15668,-15749,-15826,-15897,-15964,-16026,-16083
        .dc.w       -16135
        .dc.w       -16182,-16225,-16262,-16294,-16322,-16344,-16362
        .dc.w       -16374,-16382,-16384

        .dc.w       -16382,-16374,-16362,-16344,-16322,-16294,-16262
        .dc.w       -16225,-16182
        .dc.w       -16135,-16083,-16026,-15964,-15897,-15826,-15749
        .dc.w       -15668
        .dc.w       -15582,-15491,-15396,-15296,-15191,-15082,-14962
        .dc.w       -14849
        .dc.w       -14726,-14598,-14466,-14330,-14189,-14044,-13894
        .dc.w       -13741
        .dc.w       -13583,-13421,-13255,-13085,-12911,-12733,-12551
        .dc.w       -12365
        .dc.w       -12176,-11982,-11786,-11585,-11381,-11174,-10963
        .dc.w       -10749
        .dc.w       -10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
        .dc.w       -8682,-8438,-8192,-7943,-7692,-7438,-7182,-6924
        .dc.w       -6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
        .dc.w       -4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
        .dc.w       -2280,-1997,-1713,-1428,-1143,-857,-572,-286,0


          .even
          .bss

x0:       .ds.w     1         * Position of the coordinate origin on 
y0:       .ds.w     1         * the screen 
z0:       .ds.w     1
z1:       .ds.w     1

linxy     .ds.l     1         * This is the address of the line array

nummark:   .ds.w     1         * Number of points
numline:   .ds.w     1         * Number of lines

pointx:   .ds.l     1         * Variables of point arrays for world,
pointy:   .ds.l     1         * view, and screen coordinates
pointz:   .ds.l     1

xplot     .ds.l     1
yplot     .ds.l     1

datx:     .ds.l     1
daty:     .ds.l     1
datz:     .ds.l     1
sinx:     .ds.w     1         * Temporary storage for sine and
sinz:     .ds.w     1         * cosine values
siny:     .ds.w     1

cosx:     .ds.w     1
cosz:     .ds.w     1
cosy:     .ds.w     1

var1:     .ds.w     1         * general variables
var2:     .ds.w     1
var3:     .ds.w     1

xangle:    .ds.w     1         * Variables for passing angles
yangle:    .ds.w     1         * to the rotation subroutine
zangle:    .ds.w     1

physbase: .ds.l     1         * Address of first screen page
logbase:  .ds.l     1         * Address of second screen page


contrl:                        * Arrays for AES and VDI functions
opcode:    .ds.w    1          * for passing parameters
sintin:    .ds.w    1
sintout:   .ds.w    1
saddrin:   .ds.w    1
saddrout:  .ds.w    1
           .ds.w    6

global:
apversion: .ds.w    1
apcount:   .ds.w    1
apid:      .ds.w    1
apprivate: .ds.l    1
apptree:   .ds.l    1
ap1resv:   .ds.l    1
ap2resv:   .ds.l    1
ap3resv:   .ds.l    1
ap4resv:   .ds.l    1

intin:     .ds.w    128
ptsin:     .ds.w    256
intout:    .ds.w    128
ptsout:    .ds.w    128
addrin:    .ds.w    128
addrout:   .ds.w    128
grhandle:  .ds.w    1

lineavar:  .ds.l    1         * Starting address of Line-A var

           .data
vdipb:     .dc.l     contrl,intin,ptsin,intout,ptsout
aespb:     .dc.l     contrl,global,intin,intout,addrin,addrout

leftx:    .dc.w     0
lefty:    .dc.w     0
rightx:   .dc.w     0
righty:   .dc.w     0

p1code:    .dc.w     0
p2code:    .dc.w     0
code1:     .dc.w     0
code2:     .dc.w     0
mid_code:  .dc.w     0

clipxule:  .dc.w     0      * Clip window variables
clipyule:  .dc.w     0
clipxlri:  .dc.w     639
clipylri:  .dc.w     399

dist:      .dc.w     0
zobs:      .dc.w     1500

rotx11:    .dc.w     16384   * Space here for the result matrix of 
rotx12:    .dc.w     0       * matrix multiplication
rotx13:    .dc.w     0
rotx21:    .dc.w     0
rotx22:    .dc.w     16384
rotx23:    .dc.w     0
rotx31:    .dc.w     0
rotx32:    .dc.w     0
rotx33:    .dc.w     16384

           .bss

matrix11:  .ds.w     1       * Space here for the general 
matrix12:  .ds.w     1       * rotation matrix
matrix13:  .ds.w     1
matrix21:  .ds.w     1
matrix22:  .ds.w     1
matrix23:  .ds.w     1
matrix31:  .ds.w     1
matrix32:  .ds.w     1
matrix33:  .ds.w     1

           .end


