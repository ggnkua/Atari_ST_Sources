* * * * * * * * * * * * * * * * * * * * *
*           ASSEMBLED SAUCERS           *
*                                       *
*      A Motion & Sound Experiment      *
*           By Walt Wakefield           *
*                                       *
* Copyright 1988 by Antic Publishing    *
*                                       *
* * * * * * * * * * * * * * * * * * * * *
                text
* * * * * * * * * * * * * * * * * * * * *
*            SYSTEM  EQUATES            *
* * * * * * * * * * * * * * * * * * * * *
nvbls           equ     $454                    # of vbi routines
vblqueue        equ     $456                    pointer to vbi list
conterm         equ     $484                    keyboard attributes
color0          equ     $ff8240                 palette address
* * * * * * * * * * * * * * * * * * * * *
*    DISPLACEMENTS  TO  OBJECT  DATA    *
* * * * * * * * * * * * * * * * * * * * *
xcor            equ     0                       horizontal position
ycor            equ     12                      vertical position
xgoal           equ     24                      horizontal goal
ygoal           equ     32                      vertical goal
lrfac           equ     40                      left-right move factor
offbuf          equ     48                      object buffer offset
offbg           equ     60                      background buffer offset
flag            equ     68                      goal-related status flag
* * * * * * * * * * * * * * * * * * * * *
*             INITIALIZATION            *
* * * * * * * * * * * * * * * * * * * * *
                clr.l   -(a7)                   Enter supervisor mode
                move.w  #32,-(a7)
                trap    #1
                addq.l  #6,a7
                dc.w    $a00a                   Hide mouse
                move.w  #4,-(a7)                Get current resolution
                trap    #14
                addq.l  #2,a7
                cmpi.w  #2,d0                   Monochrome?
                bne     svrez
                move.l  #nmtxt,-(a7)            If so, display
                move.w  #9,-(a7)                  message and
                trap    #1                        terminate
                addq.l  #6,a7                     on keypress
                move.w  #2,-(a7)
                move.w  #2,-(a7)
                trap    #13
                addq.l  #4,a7
                clr.w   (a7)
                trap    #1
svrez           move.w  d0,rez                  Save resolution
                clr.w   -(a7)                   Set low resolution
                move.l  #-1,-(a7)
                move.l  #-1,-(a7)
                move.w  #5,-(a7)
                trap    #14
                adda.l  #12,a7
                move.w  #2,-(a7)                Get screen address
                trap    #14
                addq.l  #2,a7
                move.l  d0,dscrn                Save screen address
                move.l  d0,vscrn                Set visible screen
                sub.l   #$8000,d0
                move.l  d0,hscrn                Set hidden screen
                subq.l  #8,d0
                movea.l d0,a7                   Set stack pointer
                lea     color0,a0               Save current colors
                lea     dcolors,a1
                moveq   #7,d0
svclrs          move.l  (a0)+,(a1)+
                dbf     d0,svclrs
                move.l  #colors,-(a7)           Install new colors
                move.w  #6,-(a7)
                trap    #14
                addq.l  #6,a7
* * * * * * * * * * * * * * * * * * * * *
*      LOAD GRAPHIC DATA FROM DISK      *
* * * * * * * * * * * * * * * * * * * * *
                clr.w   -(a7)                   Open data file
                move.l  #fname,-(a7)
                move.w  #$3d,-(a7)
                trap    #1
                addq.l  #8,a7
                move.w  d0,handle               Save file handle
                move.l  hscrn,d0                Transfer lower portion
                add.l   #127*160,d0               of picture to hidden
                move.l  d0,-(a7)                  screen, starting at
                move.l  #11680,-(a7)              line 127
                move.w  handle,-(a7)
                move.w  #$3f,-(a7)
                trap    #1
                adda.l  #12,a7
                move.l  #buffer,-(a7)           Transfer foreground
                move.l  #16448,-(a7)              features (hill and
                move.w  handle,-(a7)              spire) to buffer
                move.w  #$3f,-(a7)
                trap    #1
                adda.l  #12,a7
                move.w  handle,-(a7)            Close file
                move.w  #$3e,-(a7)
                trap    #1
                addq.l  #4,a7
* * * * * * * * * * * * * * * * * * * * *
*       SPRINKLE STARS ACROSS SKY       *
* * * * * * * * * * * * * * * * * * * * *
                moveq   #2,d3                   Outer loop counter
stars           moveq   #13,d4                  Loop count/shift factor
stars0          bsr     random                  Select horizontal
                divu    #20,d0                    range (block 0-19)
                swap    d0
                mulu    #8,d0
                movea.l d0,a3
                bsr     random                  Select vertical
                divu    #140,d0                   position (line 0-139)
                swap    d0
                mulu    #160,d0
                adda.l  d0,a3
                adda.l  hscrn,a3                Add screen address
                move.w  #$4000,d5               Take a pixel,
                lsr.w   d4,d5                     shift it and
                bsr     stsub                     send it to the screen
                cmp.w   #1,d4                   On inner loop count
                bgt     stars1                    of 0 or 1,
                adda.l  #160,a3                   make a larger star
                move.w  #$e000,d5
                lsr.w   d4,d5
                bsr     stsub
                adda.l  #160,a3
                move.w  #$4000,d5
                lsr.w   d4,d5
                bsr     stsub
stars1          dbf     d4,stars0
                dbf     d3,stars
* * * * * * * * * * * * * * * * * * * * *
*       PLACE MOON AT UPPER LEFT        *
* * * * * * * * * * * * * * * * * * * * *
                bsr     random                  Select vertical
                divu    #46,d0                    position (line 0-45)
                swap    d0
                mulu    #160,d0
                movea.l d0,a3
                bsr     random                  Select horizontal
                divu    #5,d0                     range (block 1-5)
                swap    d0
                addq.w  #1,d0
                mulu    #8,d0
                adda.l  d0,a3
                adda.l  hscrn,a3                Add screen address
                lea     moon,a0                 Pointer to moon data
                moveq   #6,d0                   Line counter
luna            moveq   #3,d1                   Plane counter
luna0           move.w  (a0)+,(a3)+             Transfer data
                dbf     d1,luna0
                adda.l  #152,a3                 Next scan line
                dbf     d0,luna
* * * * * * * * * * * * * * * * * * * * *
*   TRANSFER HILL AND SPIRE TO SCREEN   *
* * * * * * * * * * * * * * * * * * * * *
                lea     buffer+1728,a0          Pointer to hill data
                movea.l hscrn,a1                Get screen address
                adda.l  #134*160,a1             Advance to line 134
                moveq   #1,d0                   Counter (2 objects)
                moveq   #50,d1                  Line counter (hill)
peaks           moveq   #9,d2                   Block counter
peaks0          move.w  (a0),d3                 Build 4-plane mask
                or.w    2(a0),d3
                or.w    4(a0),d3
                or.w    6(a0),d3
                not.w   d3
                moveq   #3,d4                   Plane counter
peaks1          move.w  (a0)+,d5                Get graphic data
                and.w   d3,(a1)                 Clear spot with mask
                or.w    d5,(a1)+                Place graphic data
                dbf     d4,peaks1
                dbf     d2,peaks0
                adda.l  #80,a1                  Next scan line
                dbf     d1,peaks
                movea.l hscrn,a1                Get screen address
                adda.l  #52*160+80,a1           Advance 52 1/2 lines
                move.w  #132,d1                 Line count (spire)
                dbf     d0,peaks
* * * * * * * * * * * * * * * * * * * * *
*           START  THE  MUSIC           *
* * * * * * * * * * * * * * * * * * * * *
                bclr    #0,conterm              Kill key click
                move.l  #table,-(a7)            Find gateway to
                move.w  #32,-(a7)                 Sound City
                trap    #14
                addq.l  #6,a7
                movea.w 2(a0),a1
                move.l  a1,sound                Save address
                move.l  #tune,marker            Pointer to data
                move.l  #table,pointer          Sound table pointer
                move.b  #1,count                Music timer
                movea.l vblqueue,a0             Pointer to vbi list
                move.w  nvbls,d0                Set vbi counter
                subq.w  #1,d0
sloop           tst.l   (a0)+                   Find blank spot
                beq     open                      in list
                dbf     d0,sloop
                bra     exit
open            subq.l  #4,a0                   Back up
                move.l  a0,vbvec                Save vector address
                move.l  #music,(a0)             Put new vbi in list
* * * * * * * * * * * * * * * * * * * * *
*          SET OBJECT POINTERS          *
* * * * * * * * * * * * * * * * * * * * *
                lea     xc,a3                   Object data
                lea     order,a4                Rear-to-front order
* * * * * * * * * * * * * * * * * * * * *
*      PRELIMINARY BACKGROUND SAVE      *
* * * * * * * * * * * * * * * * * * * * *
                clr.w   d7                      Object index
prep            bsr     sbgsub                  Save background
                addq.w  #2,d7                   Next object
                cmp.w   #8,d7                   Any more saucers?
                blt     prep
* * * * * * * * * * * * * * * * * * * * *
*           M A I N   L O O P           *
* * * * * * * * * * * * * * * * * * * * *
*         SET GOALS FOR SAUCERS         *
* * * * * * * * * * * * * * * * * * * * *
begin           clr.w   d7                      Reset object index
loop            cmpi.b  #3,flag(a3,d7)          Current goal reached?
                bne     nxtsg                     If not, skip
                bsr     random                  Select horizontal
                divu    #273,d0                   goal (0-272)
                swap    d0
                move.w  d0,xgoal(a3,d7)
                bsr     random                  Select vertical
                divu    #168,d0                   goal (0-167)
                swap    d0
                move.w  d0,ygoal(a3,d7)
                clr.w   flag(a3,d7)             Clear flag
                bsr     random                  Select horizontal
                and.w   #1,d0                     speed (1 or 2)
                addq.w  #1,d0
                move.w  d0,lrfac(a3,d7)
nxtsg           addq.w  #2,d7                   Next saucer
                cmp.w   #8,d7                   Any more?
                blt     loop
* * * * * * * * * * * * * * * * * * * * *
*          RESTORE  BACKGROUND          *
* * * * * * * * * * * * * * * * * * * * *
                moveq   #10,d6                  Nearest object
rstbg           move.w  $0(a4,d6),d7            Get object index
                cmp.w   #8,d7                   Hill or spire?
                bge     nxtrb                     If so, skip
                bsr     fndpos                  Set screen pointer
                lea     bgbuf,a1                Set buffer pointer
                clr.l   d2
                move.w  offbg(a3,d7),d2
                adda.l  d2,a1
                moveq   #17,d2                  Line counter
rstlin          moveq   #7,d3                   Long word counter
rstwrd          move.l  (a1)+,(a0)+             Transfer data
                dbf     d3,rstwrd
                adda.l  #128,a0                 Next scan line
                dbf     d2,rstlin
nxtrb           subq.w  #2,d6                   Next object
                bpl     rstbg
* * * * * * * * * * * * * * * * * * * * *
*            SHUFFLE SAUCERS            *
* * * * * * * * * * * * * * * * * * * * *
                moveq   #6,d7                   Saucer index
shuf            bsr     random                  Take random number
                and.w   #31,d0                    from 0 to 31
                cmp.w   #1,d0                   Try moving saucer
                bgt     nxtshf                    lower (nearer) on 0,
                tst.w   d0                        higher (away) on 1,
                beq     lower                     otherwise not at all
higher          bsr     hunt                    Find relative position
                addq.w  #2,d5                   Next higher position?
                cmp.w   #12,d5                  If none, try lower
                bge     lower                     instead
                bra     shft                    
lower           bsr     hunt                    Find relative position
                subq.w  #2,d5                   Next lower position?
                bmi     higher                  If none, try higher
shft            move.w  0(a4,d5),d3             What's there,
                cmp.w   #8,d3                     spire (8), hill (10)
                beq     eight                     or saucer?
                bgt     ten
dish            move.w  ycor(a3,d3),d0          Abort position swap
                sub.w   ycor(a3,d7),d0            if objects overlap
                bmi     subzy
                cmp.w   #18,d0
                bge     doshft
examx           move.w  xcor(a3,d3),d0
                sub.w   xcor(a3,d7),d0
                bmi     subzx
                cmp.w   #48,d0
                bge     doshft
                bra     nxtshf
subzy           cmp.w   #$ffef,d0
                blt     doshft
                bra     examx
subzx           cmp.w   #$ffd1,d0
                blt     doshft
                bra     nxtshf
eight           move.w  ycor(a3,d7),d0
                cmp.w   #35,d0
                blt     doshft
                cmp.w   #117,d0
                blt     sprlvl
                move.w  xcor(a3,d7),d0
                cmp.w   #113,d0
                blt     doshft
                bra     nxtshf
sprlvl          move.w  xcor(a3,d7),d0
                cmp.w   #156,d0
                blt     doshft
                cmp.w   #225,d0
                bge     doshft
                bra     nxtshf
ten             move.w  ycor(a3,d7),d0
                cmp.w   #117,d0
                blt     doshft
                move.w  xcor(a3,d7),d0
                cmp.w   #160,d0
                blt     nxtshf
doshft          move.w  0(a4,d5),d0             If no overlap, swap
                move.w  0(a4,d4),0(a4,d5)
                move.w  d0,0(a4,d4)
nxtshf          subq.w  #2,d7                   Next object
                bpl     shuf
* * * * * * * * * * * * * * * * * * * * *
*             MOVE  SAUCERS             *
* * * * * * * * * * * * * * * * * * * * *
                clr.w   d6                      Most distant object
trav            move.w  $0(a4,d6),d7            Get object index
                cmp.w   #8,d7                   Spire or hill?
                bge     proceed                   It won't budge
                move.w  xcor(a3,d7),d0          Horizontal position
                sub.w   xgoal(a3,d7),d0         Subtract goal
                beq     onx                     Goal achieved?
                bmi     right                   If not, move right
left            cmp.w   lrfac(a3,d7),d0           or left
                bge     lrfok
                sub.w   d0,xcor(a3,d7)
                bra     cheky
lrfok           move.w  lrfac(a3,d7),d0
                sub.w   d0,xcor(a3,d7)
                bra     cheky
right           move.w  xgoal(a3,d7),d0
                sub.w   xcor(a3,d7),d0
                cmp.w   lrfac(a3,d7),d0
                bge     rlfok
                add.w   d0,xcor(a3,d7)
                bra     cheky
rlfok           move.w  lrfac(a3,d7),d0
                add.w   d0,xcor(a3,d7)
                bra     cheky
onx             bset    #0,flag(a3,d7)          At horizontal goal
cheky           move.w  ycor(a3,d7),d0          Vertical position
                sub.w   ygoal(a3,d7),d0         Subtract goal
                beq     ony                     Goal achieved?
                bmi     down                      If not, move down
up              subq.w  #1,ycor(a3,d7)            or up
                bra     savbg
down            addq.w  #1,ycor(a3,d7)
                bra     savbg
ony             bset    #1,flag(a3,d7)          At vertical goal
savbg           bsr     sbgsub                  Save background
drfig           bsr     dfrtn                   Redraw saucer
                moveq   #10,d5                  Find relative position
fnd8            cmpi.w  #8,0(a4,d5)               of spire and redraw
                beq     outf8                     if nearer than saucer
                subq.w  #2,d5
                bpl     fnd8
outf8           cmp.w   d5,d6
                bgt     seek10
                bsr     spire
seek10          moveq   #10,d5                  Find relative position
fnd10           cmpi.w  #10,0(a4,d5)              of hill and redraw
                beq     outf10                    if nearer than saucer
                subq.w  #2,d5
                bpl     fnd10
outf10          cmp.w   d5,d6
                bgt     proceed
                bsr     hill
proceed         addq.w  #2,d6                   Next object
                cmp.w   #12,d6
                blt     trav
* * * * * * * * * * * * * * * * * * * * *
*           CHECK ESCAPE KEY            *
* * * * * * * * * * * * * * * * * * * * *
chkey           move.w  #2,-(a7)
                move.w  #1,-(a7)
                trap    #13
                addq.l  #4,a7
                tst.w   d0                      Key pressed?
                beq     chgscr                    If not, move on
                move.w  #2,-(a7)
                move.w  #2,-(a7)
                trap    #13
                addq.l  #4,a7
                cmp.w   #27,d0                  Escape key?
                beq     exit                      If so, quit
* * * * * * * * * * * * * * * * * * * * *
*        DISPLAY REVISED PICTURE        *
* * * * * * * * * * * * * * * * * * * * *
chgscr          bsr     swpscr                  Swap screens
                bsr     update                  Update hidden screen
* * * * * * * * * * * * * * * * * * * * *
*         ROTATE SAUCER LIGHTS          *
* * * * * * * * * * * * * * * * * * * * *
                move.w  color0+28,d0            Rotate 3 colors
                move.w  color0+26,color0+28
                move.w  color0+24,color0+26
                move.w  d0,color0+24
* * * * * * * * * * * * * * * * * * * * *
*             END MAIN LOOP             *
* * * * * * * * * * * * * * * * * * * * *
                bra     begin
* * * * * * * * * * * * * * * * * * * * *
*              SUBROUTINES              *
* * * * * * * * * * * * * * * * * * * * *
*         PLACE STAR ON SCREEN          *
* * * * * * * * * * * * * * * * * * * * *
stsub           tst.l   (a3)                    Is area clear?
                bne     stsub0                    If not, skip it
                tst.l   4(a3)
                bne     stsub0
                move.w  d5,(a3)                 Transfer image
                move.w  d5,2(a3)                  to 4 planes
                move.w  d5,4(a3)
                move.w  d5,6(a3)
stsub0          rts
* * * * * * * * * * * * * * * * * * * * *
*        PLACE SAUCER ON SCREEN         *
* * * * * * * * * * * * * * * * * * * * *
dfrtn           bsr     fndpos                  Set screen pointer
                lea     buffer,a1               Set buffer pointer
                clr.l   d2
                move.w  offbuf(a3,d7),d2
                adda.l  d2,a1
                moveq   #17,d2                  Line counter
dflin           moveq   #2,d3                   Block counter
dfblk           move.l  (a1),d4                 Build mask
                or.l    2(a1),d4
                or.l    4(a1),d4
                or.l    6(a1),d4
                clr.w   d4
                lsr.l   d0,d4                   Apply shift factor
                not.l   d4                      
                and.w   d4,8(a0)                Clear spot, next block
                and.w   d4,10(a0)
                and.w   d4,12(a0)
                and.w   d4,14(a0)
                swap    d4
                and.w   d4,(a0)                 Clear spot, this block
                and.w   d4,2(a0)
                and.w   d4,4(a0)
                and.w   d4,6(a0)
                moveq   #3,d5                   Plane counter
dfwrd           move.l  (a1),d4                 Get data
                clr.w   d4
                lsr.l   d0,d4                   Apply shift factor
                or.w    d4,8(a0)                Place data, next block
                swap    d4
                or.w    d4,(a0)+                Place data, this block
                addq.l  #2,a1                   Advance data pointer
                dbf     d5,dfwrd
                dbf     d3,dfblk
                adda.l  #136,a0                 Next scan line
                dbf     d2,dflin
                rts
* * * * * * * * * * * * * * * * * * * * *
*        REPAIR DAMAGE AND EXIT         *
* * * * * * * * * * * * * * * * * * * * *
exit            bset    #0,conterm              Restore key click
                move.w  rez,-(a7)               Restore resolution
                move.l  dscrn,-(a7)               and screen
                move.l  #-1,-(a7)
                move.w  #5,-(a7)
                trap    #14
                adda.l  #12,a7
                move.l  #dcolors,-(a7)          Restore palette
                move.w  #6,-(a7)
                trap    #14
                addq.l  #6,a7
                movea.l vbvec,a0                Disable vertical blank
                clr.l   (a0)                      interrupt
                movea.l sound,a0                Quiet,please
                move.l  #quiet,(a0)+
                clr.b   (a0)
                clr.w   -(a7)                   Terminate program
                trap    #1
* * * * * * * * * * * * * * * * * * * * *
*             SWAP SCREENS              *
* * * * * * * * * * * * * * * * * * * * *
swpscr          move.l  hscrn,d0                Swap hidden and
                move.l  vscrn,hscrn               visible screens
                move.l  d0,vscrn
                move.w  #-1,-(a7)               Display new visible
                move.l  d0,-(a7)                  screen
                move.l  #-1,-(a7)
                move.w  #5,-(a7)
                trap    #14
                adda.l  #12,a7
                rts
* * * * * * * * * * * * * * * * * * * * *
*         UPDATE HIDDEN SCREEN          *
* * * * * * * * * * * * * * * * * * * * *
update          movea.l vscrn,a0                Set pointers
                movea.l hscrn,a1
                move.w  #1999,d0                Set counter
udloop          move.l  (a0)+,(a1)+             Transfer data
                move.l  (a0)+,(a1)+
                move.l  (a0)+,(a1)+
                move.l  (a0)+,(a1)+
                dbf     d0,udloop
                rts
* * * * * * * * * * * * * * * * * * * * *
*          GET A RANDOM NUMBER          *
* * * * * * * * * * * * * * * * * * * * *
random          move.w  #17,-(a7)               Get 24-bit number
                trap    #14
                addq.l  #2,a7
                and.l   #$ffff,d0               Mask to 16 bits
                rts
* * * * * * * * * * * * * * * * * * * * *
*    FIND POSITION IN SCREEN MEMORY     *
* * * * * * * * * * * * * * * * * * * * *
fndpos          movea.l hscrn,a0                Top of hidden screen
                move.w  ycor(a3,d7),d0          Add y coordinate
                mulu    #160,d0                   times bytes per line
                adda.l  d0,a0
                clr.l   d0                      
                move.w  xcor(a3,d7),d0          Add x coordinate
                divu    #16,d0                    divided by pixels
                move.w  d0,d1                     per block multiplied
                mulu    #8,d1                     by bytes per block
                adda.l  d1,a0
                swap    d0                      Get remainder for use
                rts                               as shift factor
* * * * * * * * * * * * * * * * * * * * *
*       SAVE SECTION OF BACKGROUND      *
* * * * * * * * * * * * * * * * * * * * *
sbgsub          bsr     fndpos                  Set screen pointer
                movea.l #bgbuf,a1               Set buffer pointer
                clr.l   d0
                move.w  offbg(a3,d7),d0
                adda.l  d0,a1
                moveq   #17,d0                  Line counter
sbglin          moveq   #7,d1                   Long word counter
sbgwrd          move.l  (a0)+,(a1)+             Transfer data
                dbf     d1,sbgwrd
                adda.l  #128,a0                 Next scan line
                dbf     d0,sbglin
                rts
* * * * * * * * * * * * * * * * * * * * *
*    REDRAW SECTION OF SPIRE OR HILL    *
* * * * * * * * * * * * * * * * * * * * *
spire           move.w  d6,-(a7)                Save order index
                moveq   #8,d6                   Select spire
                cmpi.w  #113,xcor(a3,d7)        Abort if saucer
                blt     spret                     is clear of spire
                cmpi.w  #35,ycor(a3,d7)
                blt     spret
                move.w  xcor(a3,d7),d0          Horizontal coordinate
                cmp.w   #160,d0                   (minimum of 160,
                bge     togeo                     maximum of 256)
                move.w  #160,d0
togeo           cmp.w   #257,d0
                blt     geo
                move.w  #256,d0
                bra     geo
spret           move.w  (a7)+,d6                Retrieve order index
                rts
hill            move.w  d6,-(a7)                Save order index
                moveq   #10,d6                  Select hill
                cmpi.w  #160,xcor(a3,d7)        Abort if saucer
                bge     spret                     is clear of hill
                cmpi.w  #117,ycor(a3,d7)
                blt     spret
                move.w  xcor(a3,d7),d0          Horizontal coordinate
                cmp.w   #97,d0                    (maximum of 96)
                blt     geo
                moveq   #96,d0
geo             and.l   #$fff0,d0               Beginning of block
                move.w  ycor(a3,d7),d1          Vertical coordinate
                cmp.w   ycor(a3,d6),d1          Substitute top of hill
                bge     gwan                      or spire if greater
                move.w  ycor(a3,d6),d1            (lower on screen)
gwan            movea.l hscrn,a0                Prepare screen pointer
                move.w  d1,d2
                mulu    #160,d1
                adda.l  d1,a0
                lsr.w   #1,d0
                adda.l  d0,a0
                lea     buffer,a1               Prepare buffer pointer
                cmp.w   #80,d0
                blt     adjd2
                sub.w   #80,d0
adjd2           sub.w   ycor(a3,d6),d2
                clr.l   d1
                move.w  offbuf(a3,d6),d1
                adda.l  d1,a1
                mulu    #80,d2
                adda.l  d2,a1
                adda.l  d0,a1
                moveq   #17,d2                  Line counter
geolin          moveq   #3,d3                   Block counter
geoblk          move.w  (a1),d0                 Build mask
                or.w    2(a1),d0
                or.w    4(a1),d0
                or.w    6(a1),d0
                not.w   d0
                and.w   d0,(a0)                 Clear spot on screen
                and.w   d0,2(a0)
                and.w   d0,4(a0)
                and.w   d0,6(a0)
                moveq   #3,d4                   Plane counter
geowrd          move.w  (a1)+,d0                Transfer data to screen
                or.w    d0,(a0)+
                dbf     d4,geowrd
                dbf     d3,geoblk
                adda.l  #128,a0                 Next scan line
                adda.l  #48,a1                  Next buffer line
                dbf     d2,geolin
                bra     spret
* * * * * * * * * * * * * * * * * * * * *
*    FIND OBJECT'S RELATIVE POSITION    *
* * * * * * * * * * * * * * * * * * * * *
hunt            moveq   #10,d5                  Nearest object
htloop          cmp.w   $0(a4,d5),d7            The one we want?
                beq     outht                     If so, leave
                subq.w  #2,d5                   Next object
                bpl     htloop
outht           move.w  d5,d4
                rts
* * * * * * * * * * * * * * * * * * * * *
*   VERTICAL BLANK INTERRUPT ROUTINE    *
* * * * * * * * * * * * * * * * * * * * *
music           movem.l d0-d0/a0-a3,-(a7)
                subq.b  #1,count                Decrement time count
                bne     music9                  Skip ahead if not 0
                movea.l marker,a0               Get music pointer
                move.b  (a0)+,d0                Read next byte
                bmi     music11                 Minus value marks end
                bne     music5                  Skip ahead on non-0
                move.b  (a0)+,d0                Get voice offset
                cmp.b   #1,d0                   First voice?
                bne     music1                    If not, try second
                clr.w   mode                    Clear mode
                clr.w   stat                    Clear status index
                move.b  (a0)+,table+17          Insert value in table
                cmpi.b  #16,table+17            16 or higher?
                blt     music0                  If not, it's a volume
                move.b  table+17,d0             If so, it's a mode #;
                sub.b   #15,d0                    convert it to a long
                lsl.b   #2,d0                     index and save it
                move.b  d0,mode+1
music0          move.b  (a0)+,d0                Read next byte
music1          cmp.b   #5,d0                   Second voice?
                bne     music3                    If not, try third
                clr.w   mode+2
                clr.w   stat+2
                move.b  (a0)+,table+19
                cmpi.b  #16,table+19
                blt     music2
                move.b  table+19,d0
                sub.b   #15,d0
                lsl.b   #2,d0
                move.b  d0,mode+3
music2          move.b  (a0)+,d0
music3          tst.b   d0                      Third voice (9)?
                beq     music4                    If not, move on
                clr.w   mode+4
                clr.w   stat+4
                move.b  (a0)+,table+21
                cmpi.b  #16,table+21
                blt     music4
                move.b  table+21,d0
                sub.b   #15,d0
                lsl.b   #2,d0
                move.b  d0,mode+5
music4          move.b  (a0)+,d0                Read next byte
music5          lea     table,a1                Set pointer to table
                cmp.b   #1,d0                   First voice index?
                bne     music6                    If not, try second
                ext.w   d0                      Prepare word index
                move.b  (a0)+,0(a1,d0)          Transfer musical note
                move.b  (a0)+,2(a1,d0)            (2 bytes) to table
                move.b  (a0)+,d0                Read next byte
                cmpi.w  #12,mode                If mode index is 12
                blt     music6                    or higher (sustain),
                clr.w   stat                      reset status index
music6          cmp.b   #5,d0                   Second voice?
                bne     music7                    If not try third
                ext.w   d0
                move.b  (a0)+,0(a1,d0)
                move.b  (a0)+,2(a1,d0)
                move.b  (a0)+,d0
                cmpi.w  #12,mode+2
                blt     music7
                clr.w   stat+2
music7          tst.b   d0                      Third voice?
                beq     music8                    If not, move on
                ext.w   d0
                move.b  (a0)+,0(a1,d0)
                move.b  (a0)+,2(a1,d0)
                cmpi.w  #12,mode+4
                blt     music8
                clr.w   stat+4
music8          move.b  (a0)+,count             Set time counter
                move.l  a0,marker               Save music pointer
music9          lea     modptr,a0               Set mode pointer
                lea     table+17,a1             Set table pointer
                lea     stat,a3                 Set status pointer
                move.w  mode,d0                 Get mode index
                movea.l 0(a0,d0),a2             Find subroutine 
                jsr     (a2)                      and jump in
                lea     table+19,a1             Do same for 2nd voice
                lea     stat+2,a3
                move.w  mode+2,d0
                movea.l 0(a0,d0),a2
                jsr     (a2)
                lea     table+21,a1             And for 3rd voice
                lea     stat+4,a3
                move.w  mode+4,d0
                movea.l 0(a0,d0),a2
                jsr     (a2)
                movea.l sound,a0                Point to sound slot
                move.l  pointer,(a0)+           Deposit pointer
                clr.b   (a0)                      to our sound table
music10         movem.l (a7)+,d0-d0/a0-a3
                rts
music11         move.l  #tune,marker            Restart from the top
                move.b  #1,count                  on next vertical blank
                bra     music10
* * * * * * * * * * * * * * * * * * * * *
*           MUSIC SUBROUTINES           *
* * * * * * * * * * * * * * * * * * * * *
mode0           rts                             Single volume; return
mode1           lea     vbrt,a2                 Point to vibrato data
                subq.w  #1,(a3)                 Decrement index
                bpl     mode1a
                move.w  #9,(a3)                 Reload if minus
mode1a          move.w  (a3),d0                 Get index
                move.b  0(a2,d0),(a1)           Put volume in table
                rts
mode2           lea     pzct,a2                 Point to pizzicato data
                subq.w  #1,(a3)                 Decrement index
                bpl     mode2a
                move.w  #5,(a3)                 Reload if minus
mode2a          move.w  (a3),d0                 Get index
                move.b  0(a2,d0),(a1)           Put volume in table
                rts
mode3           lea     sstn1,a2                Short sustain data
mode3a          move.w  (a3),d0                 Get index
                move.b  0(a2,d0),(a1)           Put volume in table
                tst.b   (a1)
                beq     mode3b                  Zero marks end of data
                addq.w  #1,(a3)                 Otherwise advance index
mode3b          rts
mode4           lea     sstn2,a2                Medium sustain
                bra     mode3a
mode5           lea     sstn3,a2                Long sustain
                bra     mode3a
* * * * * * * * * * * * * * * * * * * * *
*             PROGRAM  DATA             *
* * * * * * * * * * * * * * * * * * * * *
                data
colors          dc.w    $000,$703,$740,$470,$607,$557,$446,$334
                dc.w    $067,$057,$047,$037,$000,$000,$047,$777
fname           dc.b    'saucers.dat',0
xc              dc.w    0,0,0,0,160,128
yc              dc.w    0,18,36,54,52,134
xg              dc.w    0,0,0,0
yg              dc.w    0,18,36,54
hfac            dc.w    2,2,2,2
offsets         dc.w    0,432,864,1296,5808,1728
                dc.w    0,576,1152,1728
flg             dc.w    $0300,$0300,$0300,$0300
order           dc.w    0,2,4,6,8,10
moon            dc.w    $3e00,$3e00,$3e00,$0000,$7f00,$7f00,$7f00,$0100
                dc.w    $ff80,$ff80,$ff80,$0180,$ff80,$ff80,$ff80,$0380
                dc.w    $ff80,$ff80,$ff80,$0780,$7f00,$7f00,$7f00,$0f00
                dc.w    $3e00,$3c00,$3e00,$3c00
table           dc.b    0,0,1,0,2,0,3,0,4,0,5,0
                dc.b    6,15,7,56,8,16,9,16,10,16,11,0,12,40,13,9,255,0
quiet           dc.b    7,63,8,0,9,0,10,0,255,0
modptr          dc.l    mode0,mode1,mode2,mode3,mode4,mode5
vbrt            dc.b    11,12,13,14,15,14,13,12,11,10
pzct            dc.b    0,0,0,15,15,15
sstn1           dc.b    13,14,15,15,14,14,13,13,12,12,11,11,10,10,9,9,8,8
                dc.b    7,7,6,6,5,5,4,4,3,3,2,2,1,1,0
sstn2           dc.b    13,14,14,15,15,15,14,14,14,13,13,13,12,12,12,11,11,11
                dc.b    10,10,10,9,9,9,8,8,8,7,7,7,6,6,6,5,5,5,4,4,4
                dc.b    3,3,3,2,2,2,1,1,1,0
sstn3           dc.b    13,14,14,15,15,15,14,14,14,14,14,13,13,13,13,13
                dc.b    13,13,13,13,13,12,12,12,12,12,12,12,12
                dc.b    11,11,11,11,11,11,11,11,10,10,10,10,10,10,10,10
                dc.b    9,9,9,9,9,9,9,9,8,8,8,8,8,8,8,8,7,7,7,7,7,7,7,7
                dc.b    6,6,6,6,6,6,6,6,5,5,5,5,5,5,5,4,4,4,4,4,4
                dc.b    3,3,3,3,3,2,2,2,2,1,1,1,0
tune            dc.b    0,1,19,5,16,9,18
                dc.b    1,0,0,5,0,0,9,188,3,24
                dc.b    9,252,4,24
                dc.b    9,188,3,24
                dc.b    9,252,4,24
                dc.b    9,188,3,24
                dc.b    9,252,4,24
                dc.b    9,112,4,24
                dc.b    9,244,3,24
                dc.b    9,244,3,24
                dc.b    9,152,5,24
                dc.b    9,244,3,24
                dc.b    9,152,5,24
                dc.b    9,244,3,24
                dc.b    9,152,5,24
                dc.b    9,252,4,24
                dc.b    9,112,4,24
                dc.b    5,63,1,9,188,3,24
                dc.b    9,252,4,24
                dc.b    5,222,1,9,188,3,24
                dc.b    9,252,4,24
                dc.b    5,63,1,9,188,3,24
                dc.b    5,102,1,9,252,4,24
                dc.b    5,123,1,9,112,4,24
                dc.b    5,170,1,9,244,3,24
                dc.b    5,102,1,9,244,3,24
                dc.b    9,152,5,24
                dc.b    5,250,1,9,244,3,24
                dc.b    9,152,5,24
                dc.b    5,102,1,9,244,3,24
                dc.b    5,123,1,9,152,5,24
                dc.b    5,170,1,9,252,4,24
                dc.b    5,222,1,9,112,4,24
                dc.b    5,63,1,9,188,3,24
                dc.b    9,252,4,24
                dc.b    9,188,3,24
                dc.b    9,252,4,24
                dc.b    9,188,3,16
                dc.b    5,123,1,0,8
                dc.b    5,102,1,9,252,4,8
                dc.b    5,123,1,0,8
                dc.b    5,170,1,0,8
                dc.b    5,222,1,9,112,4,24
                dc.b    9,244,3,24
                dc.b    9,188,3,24
                dc.b    9,252,4,24
                dc.b    9,188,3,24
                dc.b    5,0,0,9,252,4,24
                dc.b    9,188,3,24
                dc.b    9,252,4,24
                dc.b    9,112,4,24
                dc.b    9,244,3,24
                dc.b    1,159,0,9,188,3,12
                dc.b    1,190,0,0,12
                dc.b    1,179,0,9,252,4,12
                dc.b    1,159,0,0,12
                dc.b    1,142,0,9,188,3,12
                dc.b    1,127,0,0,12
                dc.b    1,119,0,9,252,4,12
                dc.b    1,159,0,0,12
                dc.b    1,127,0,9,188,3,12
                dc.b    1,142,0,0,12
                dc.b    1,159,0,9,252,4,12
                dc.b    1,179,0,0,12
                dc.b    1,142,0,9,112,4,12
                dc.b    1,159,0,0,12
                dc.b    1,179,0,9,244,3,12
                dc.b    1,190,0,0,12
                dc.b    1,159,0,9,244,3,12
                dc.b    1,190,0,0,12
                dc.b    1,179,0,9,152,5,12
                dc.b    1,159,0,0,12
                dc.b    1,142,0,9,244,3,12
                dc.b    1,127,0,0,12
                dc.b    1,119,0,9,152,5,12
                dc.b    1,159,0,0,12
                dc.b    1,127,0,9,244,3,12
                dc.b    1,142,0,0,12
                dc.b    1,159,0,9,152,5,12
                dc.b    1,179,0,0,12
                dc.b    1,190,0,9,252,4,12
                dc.b    1,179,0,0,12
                dc.b    1,142,0,9,112,4,12
                dc.b    1,127,0,0,12
                dc.b    0,1,17,0
                dc.b    1,119,0,9,188,3,24
                dc.b    1,95,0,9,252,4,24
                dc.b    1,119,0,9,188,3,24
                dc.b    1,159,0,9,252,4,24
                dc.b    1,127,0,9,188,3,24
                dc.b    1,142,0,9,252,4,24
                dc.b    1,159,0,9,112,4,24
                dc.b    1,179,0,9,244,3,24
                dc.b    1,159,0,9,188,3,24
                dc.b    1,119,0,9,252,4,24
                dc.b    1,159,0,9,188,3,24
                dc.b    1,190,0,9,252,4,24
                dc.b    1,179,0,9,188,3,24
                dc.b    1,190,0,9,252,4,24
                dc.b    1,213,0,9,112,4,24
                dc.b    1,239,0,9,244,3,24
                dc.b    0,1,19,0
                dc.b    1,159,0,5,63,1,9,188,3,12
                dc.b    1,190,0,0,12
                dc.b    1,179,0,9,252,4,12
                dc.b    1,159,0,0,12
                dc.b    1,142,0,5,222,1,9,188,3,12
                dc.b    1,127,0,0,12
                dc.b    1,119,0,9,252,4,12
                dc.b    1,159,0,0,12
                dc.b    1,127,0,5,63,1,9,188,3,12
                dc.b    1,142,0,0,12
                dc.b    1,159,0,5,102,1,9,252,4,12
                dc.b    1,179,0,0,12
                dc.b    1,142,0,5,123,1,9,112,4,12
                dc.b    1,159,0,0,12
                dc.b    1,179,0,5,170,1,9,244,3,12
                dc.b    1,190,0,0,12
                dc.b    1,159,0,5,102,1,9,244,3,12
                dc.b    1,190,0,0,12
                dc.b    1,179,0,9,152,5,12
                dc.b    1,159,0,0,12
                dc.b    1,142,0,5,250,1,9,244,3,12
                dc.b    1,127,0,0,12
                dc.b    1,119,0,9,152,5,12
                dc.b    1,159,0,0,12
                dc.b    1,127,0,5,102,1,9,244,3,12
                dc.b    1,142,0,0,12
                dc.b    1,159,0,5,123,1,9,152,5,12
                dc.b    1,179,0,0,12
                dc.b    1,190,0,5,170,1,9,252,4,12
                dc.b    1,179,0,0,12
                dc.b    1,142,0,5,222,1,9,112,4,12
                dc.b    1,127,0,0,12
                dc.b    0,1,17,0
                dc.b    1,119,0,5,63,1,9,188,3,24
                dc.b    1,95,0,9,252,4,24
                dc.b    1,119,0,9,188,3,24
                dc.b    1,159,0,9,252,4,24
                dc.b    1,127,0,9,188,3,16
                dc.b    5,123,1,0,8
                dc.b    1,142,0,5,102,1,9,252,4,8
                dc.b    5,123,1,0,8
                dc.b    5,170,1,0,8
                dc.b    1,159,0,5,222,1,9,112,4,24
                dc.b    1,179,0,9,244,3,24
                dc.b    1,159,0,9,188,3,24
                dc.b    1,119,0,9,252,4,24
                dc.b    1,159,0,9,188,3,24
                dc.b    1,190,0,5,0,0,9,252,4,24
                dc.b    1,179,0,9,188,3,24
                dc.b    1,159,0,9,252,4,24
                dc.b    1,142,0,9,112,4,24
                dc.b    1,127,0,9,244,3,24
                dc.b    0,1,15,0
                dc.b    1,63,1,9,188,3,12
                dc.b    1,123,1,0,12
                dc.b    1,102,1,9,252,4,12
                dc.b    1,63,1,0,12
                dc.b    1,28,1,9,188,3,12
                dc.b    1,253,0,0,12
                dc.b    1,239,0,9,252,4,12
                dc.b    1,0,0,0,12
                dc.b    1,239,0,9,188,3,12
                dc.b    1,63,1,0,12
                dc.b    1,253,0,9,252,4,12
                dc.b    1,28,1,0,12
                dc.b    1,63,1,9,112,4,12
                dc.b    1,102,1,0,12
                dc.b    1,123,1,9,244,3,12
                dc.b    1,0,0,0,12
                dc.b    1,63,1,9,188,3,12
                dc.b    1,123,1,0,12
                dc.b    1,102,1,9,252,4,12
                dc.b    1,63,1,0,12
                dc.b    1,28,1,9,188,3,12
                dc.b    1,253,0,0,12
                dc.b    1,239,0,9,252,4,12
                dc.b    1,63,1,0,12
                dc.b    0,1,20,5,20,0
                dc.b    1,239,0,5,63,1,9,188,3,24
                dc.b    1,253,0,5,102,1,9,252,4,24
                dc.b    1,239,0,5,63,1,9,112,4,24
                dc.b    9,244,3,24
                dc.b    0,1,19,5,16,0
                dc.b    1,159,0,5,63,1,9,188,3,12
                dc.b    1,190,0,0,12
                dc.b    1,179,0,9,252,4,12
                dc.b    1,159,0,0,12
                dc.b    1,142,0,5,222,1,9,188,3,12
                dc.b    1,127,0,0,12
                dc.b    1,119,0,9,252,4,12
                dc.b    1,159,0,0,12
                dc.b    1,127,0,5,63,1,9,188,3,12
                dc.b    1,142,0,0,12
                dc.b    1,159,0,5,102,1,9,252,4,12
                dc.b    1,179,0,0,12
                dc.b    1,142,0,5,123,1,9,112,4,12
                dc.b    1,159,0,0,12
                dc.b    1,179,0,5,170,1,9,244,3,12
                dc.b    1,190,0,0,12
                dc.b    1,159,0,5,102,1,9,244,3,12
                dc.b    1,190,0,0,12
                dc.b    1,179,0,9,152,5,12
                dc.b    1,159,0,0,12
                dc.b    1,142,0,5,250,1,9,244,3,12
                dc.b    1,127,0,0,12
                dc.b    1,119,0,9,152,5,12
                dc.b    1,159,0,0,12
                dc.b    1,127,0,5,102,1,9,244,3,12
                dc.b    1,142,0,0,12
                dc.b    1,159,0,5,123,1,9,152,5,12
                dc.b    1,179,0,0,12
                dc.b    1,190,0,5,170,1,9,252,4,12
                dc.b    1,179,0,0,12
                dc.b    1,142,0,5,222,1,9,112,4,12
                dc.b    1,127,0,0,12
                dc.b    0,1,20,5,20,9,20
                dc.b    1,119,0,5,239,0,9,188,3,24
                dc.b    0,9,18
                dc.b    9,252,4,24
                dc.b    9,188,3,24
                dc.b    9,252,4,24
                dc.b    9,188,3,24
                dc.b    9,252,4,24
                dc.b    9,112,4,24
                dc.b    9,244,3,24
                dc.b    9,244,3,24
                dc.b    9,152,5,24
                dc.b    9,244,3,24
                dc.b    9,152,5,24
                dc.b    9,244,3,24
                dc.b    9,152,5,24
                dc.b    9,252,4,24
                dc.b    9,112,4,24
                dc.b    -1
nmtxt           dc.b    27,69,27,89,43,51
                dc.b    'This program runs in color only.....Sorry.'
                dc.b    27,89,45,62,'Press a key to exit.',0,0
                even
* * * * * * * * * * * * * * * * * * * * *
*       UNINITIALIZED DATA STORAGE      *
* * * * * * * * * * * * * * * * * * * * *
                bss
rez             ds.w    1
dcolors         ds.w    16
handle          ds.l    1
bgbuf           ds.b    2304
dscrn           ds.l    1
vscrn           ds.l    1
hscrn           ds.l    1
count           ds.w    2
pointer         ds.l    1
marker          ds.l    1
vbvec           ds.l    1
sound           ds.l    1
mode            ds.w    3
stat            ds.w    3
buffer          ds.b    16448

                end
