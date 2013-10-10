*********************************************************
*              3D ON THE ATARI ST                       *
*  This demonstration of raw 68000 power was written    *
*  as an example of the LineA graphics routines.        *
*  It doesn't do anything particularly clever although  *
*  it does make very good use of the 68000 multiply     *
*  instruction and indexed + offset adressing modes.    *
*                                                       *
*********************************************************

* Conditional assembly flag. Set to 1 if you want perspective

perspective   equ   0

* When the program is running, use the cursor-pad keys
*
*   left arrow, right arrow   -   Y axis rotation velocity
*   up arrow  , down arrow    -   X axis rotation velocity
*   insert    , clr/home      -   Z axis rotation velocity
*   ESC                       -   exit to desktop (or wherever)
*   any other key             -   stops spinning.

* Appropriate xbios calls ( vsync() ) could have been added or
* screen flipping could have been used to give nice flicker-free 
* motion. However they were not because
*
* 1) We like the way the lines shimmer when they're stationary.
* 2) We wanted it to run flat out.

            INCLUDE  'LINEA.I'
            INCLUDE  'OSBIND.I'

* key scancodes :-

scanleft    equ      $4b
scanright   equ      $4d
scanup      equ      $48
scandown    equ      $50
scanins     equ      $52
scanclr     equ      $47
scans       equ      $1f

* Centre of hi-res screen (change for low or med resolution)

cx          equ      320                 ; 160 low  320 med  320 hi
cy          equ      200                 ; 100 low  100 med  200 hi

* Size of hi-res screen minus 2 (change for low or med resolution)

fullx       equ      638                 ; 318 low  638 med  638 hi
fully       equ      398                 ; 198 low  198 med  398 hi 

*********************************************************
*           THIS IS IT - THE PROGRAM                    *
*********************************************************

start       dc.w     A_Init              ; initialise the lineA
            move.l   a0,varsav           ; make a backup copy
            moveq    #-1,d0
            move.w   d0,_LSTLIN(a0)      ; set once & forget it.
            move.w   d0,_LN_MASK(a0)     ; set for solid linestyle
            moveq    #0,d0
            move.w   d0,_WRT_MODE(a0)    ; writing mode
            move.w   d0,_patmsk(a0)      ; no pattern mask
            move.w   d0,_CLIP(a0)        ; clipping off
            move.w   d0,_multifill(a0)   ; fill pattern is one line

            move.w   d0,_FG_BP_4(a0)     ; set foreground colour to black
            move.w   d0,_FG_BP_3(a0)
            move.w   d0,_FG_BP_2(a0)
            move.w   #1,_FG_BP_1(a0)     ; i.e. 0001 binary

cls         move.l   #filpat,_patptr(a0) ; set-up solid fill pattern
            move.w   #1,_X1(a0)          ; area to fill. This is
            move.w   #1,_Y1(a0)          ; the size of 
            move.w   #fullx,_X2(a0)      ; a nearly full screen with a
            move.w   #fully,_Y2(a0)      ; pixel-wide border
            dc.w     A_FillRect          ; lineA fill rectangle

* check here for keypress

mainloop    move.w   xv,d3               ; get z axis rotational velocity
            move.w   yv,d4               ; ditto y axis
            move.w   zv,d5               ; ditto z axis

            move.w   #DEV_CON,-(sp)      
            move.w   #bconstat,-(sp)     ; anything in keyboard buffer ?
            trap     #bios               
            addq.l   #4,sp               ; restore stack pointer
            tst.w    d0                  ; look at what came back
            beq.l    nokeys              ; skip next bit if no keys pressed

keypressed  move.w   #DEV_CON,-(sp) 
            move.w   #bconin,-(sp)       ; get the key pressed
            trap     #bios  
            addq.l   #4,sp               ; fix stack pointer
            swap     d0                  ; swap so we can get scancode

            cmp.w    #scanleft,d0        ; left arrow => increase Y velocity
            bne.s    notleft
left        cmp.w    #8,d4
            bgt      nokeys              ; it's gone as far as it's going
            addq.w   #1,d4               ; else increment it
            bra.s    nomore

notleft     cmp.w    #scanright,d0       ; right arrow => decrease Y velocity
            bne.s    notright
            cmp.w    #-8,d4
            blt.s    nokeys              ; skip if gone too far
            subq.w   #1,d4               ; else increment it
            bra.s    nomore

notright    cmp.w    #scandown,d0        ; down arrow => increase X velocity
            bne.s    notdown
            cmp.w    #8,d3
            bgt.s    nokeys
            addq.w   #1,d3
            bra.s    nomore

notdown     cmp.w    #scanup,d0          ; up arrow => decrease X velocity
            bne.s    notup
            cmp.w    #-8,d3
            blt.s    nokeys
            subq.w   #1,d3
            bra.s    nomore

notup       cmp.w    #scanins,d0         ; insert => increase Z velocity
            bne.s    notins
            cmp.w    #8,d5
            bgt.s    nokeys
            addq.w   #1,d5
            bra.s    nomore

notins      cmp.w    #scanclr,d0         ; clr/home => decrease Y velocity
            bne.s    notclr
            cmp.w    #-8,d5
            blt.s    nokeys
            subq.w   #1,d5
            bra.s    nomore

notclr      cmp.w    #scans,d0
            bne.s    nots
            not.w    syncflag            ; flip the sync mode flag
            bra.s    nomore

nots        subq.w   #1,d0               ; it's last one. This is faster.
            bne.s    stopit              ; if scancode wasn't 1 (ESC)
            move.w   d0,-(sp)            ; set zero return code
            move.w   #pterm,-(sp)        ; push code for 'terminate process'
            trap     #gemdos         
                                         ; won't get this far

stopit      moveq    #0,d3               ; any other key stops it spinning
            moveq    #0,d4               ; so set the three velocity registers
            moveq    #0,d5               ; to zero

nomore      move.w   d3,xv               ; update the velocity variables
            move.w   d4,yv               ; from the three velocity registers
            move.w   d5,zv

nokeys      move.w   #$00ff,d0           ; recalculate the three angles
            add.w    d3,xang
            and.w    d0,xang
            add.w    d4,yang
            and.w    d0,yang
            add.w    d5,zang
            and.w    d0,zang

spinit      lea      sintab,a0           ; get address of sine tables
            lea      coords,a1           ; and of the original coordinates
            lea      newco,a2            ; and of the last position drawn
            lea      oldco,a3            ; and of the next position to draw

            move.w   (a1)+,d5            ; get number of points to transform
muloop      move.w   (a1)+,d0            ; get (next) x
            move.w   (a1)+,d1            ; get (next) y
            move.w   (a1)+,d2            ; get (next) z

            move.l   (a2),(a3)+          ; copy 3 words (x',y',z') from newco
            move.w   4(a2),(a3)+         ; to oldco auto increasing as we go

* Here comes 3 matrix multiplies, spinning the axes separately is
* faster than working out the product matrix & transforming with that.


* First spin the X axis (changes Y and Z)

dox         move.w   xang,d7             ; get X axis rotation angle (0-255)
            move.b   0(a0,d7.w),d6       ; get sine xang from table
            move.b   64(a0,d7.w),d7      ; and cosine xang
            ext.w    d6                  ; extend sine xang to 16 bits
            ext.w    d7                  ; ditto cosine xang
            move.w   d1,d3               ; copy y
            move.w   d2,d4               ; copy z
            muls     d7,d1               ; y.cos
            muls     d6,d4               ; z.sin
            sub.w    d4,d1               ; y.cos - z.sin
            asr.w    #7,d1               ; new y --> d1
            muls     d6,d3               ; y.sin
            muls     d7,d2               ; z.cos
            add.w    d3,d2               ; y.sin + z.cos
            asr.w    #7,d2               ; new z --> d2

* Next spin the Y axis (changes X and Z)

doy         move.w   yang,d7             ; get Y axis rotation angle (0-255)
            move.b   0(a0,d7.w),d6       ; get sine yang from table
            move.b   64(a0,d7.w),d7      ; and cosine yang
            ext.w    d6                  ; extend sine yang to 16 bits
            ext.w    d7                  ; ditto cosine yang 
            move.w   d0,d3               ; copy x 
            move.w   d2,d4               ; copy z
            muls     d7,d0               ; x.cos
            muls     d6,d4               ; z.sin
            add.w    d4,d0               ; x.cos + y.sin
            asr.w    #7,d0               ; new x --> d0
            muls     d6,d3               ; x.sin
            muls     d7,d2               ; z.cos
            sub.w    d3,d2               ; z.cos - x.sin
            asr.w    #7,d2               ; new z --> d2
*
* Finally spin the Z axis (changes X and Y)
*
doz         move.w   zang,d7             ; get Z axis rotation angle (0-255)
            move.b   0(a0,d7.w),d6       ; get sine zang from table
            move.b   64(a0,d7.w),d7      ; and cosine zang
            ext.w    d6                  ; extend sine zang to 16 bits
            ext.w    d7                  ; ditto cosine zang
            move.w   d0,d3               ; copy x
            move.w   d1,d4               ; copy z
            muls     d7,d0               ; x.cos
            muls     d6,d4               ; y.sin
            sub.w    d4,d0               ; x.cos - y.sin
            asr.w    #7,d0               ; new x --> d0
            muls     d6,d3               ; x.sin
            muls     d7,d1               ; y.cos
            add.w    d3,d1               ; x.sin + y.cos
            asr.w    #7,d1               ; new y --> d1

       IFNE perspective                  ; assemble if flag non zero.

horizon     equ      1024                ; perspective horizon distance
            moveq    #10,d4              ; shift count to divide by horizon
            move.w   #horizon-128,d3
            sub.w    d2,d3               ; d3 = persp - (distance away)
            muls     d3,d0
            asr.l    d4,d0               ; re-scale x (divide by horizon)
            muls     d3,d1
            asr.l    d4,d1               ; re-scale y

       ENDC

            add.w    #cx,d0              ; add offset for centre of screen
            add.w    #cy,d1              ; ditto for vertical.

update      move.w   d0,(a2)+            ; copy new x to newco array
            move.w   d1,(a2)+            ; and new y
            move.w   d2,(a2)+            ; and new z

            dbf      d5,muloop           ; loop until done all points in image

syncwait    tst.w    syncflag            ; check flag to see if syncing on
            beq.s    undraw              ; no, so draw right away.
            move.w   #vsync,-(sp)    
            trap     #xbios
            addq.l   #2,sp               ; tidy up the stack

undraw      move.l    varsav,a5          ; get the lineA vars base pointer
            lea       oldco,a3           ; point a3 at array of old points
            lea       order,a4           ; point a4 at line-list
            move.w    #1,_FG_BP_1(a5)    ; set color to 1 (BLACK)
            move.w    (a4)+,d4           ; get number of lines to draw - 1
udloop      move.w    (a4)+,d5           ; get index ( point No * 6 )
            move.l    0(a3,d5.w),_X1(a5) ; set x1 & y1 in one go
            move.w    (a4)+,d5           ; and next index (other end of line)
            move.l    0(a3,d5.w),_X2(a5) ; set x2 & y2
            dc.w      A_DrawLine         ; draw line
            dbf       d4,udloop

redraw      lea       newco,a3           ; point a3 at array of new points
            lea       order,a4           ; point a4 at line-list
            clr.w     _FG_BP_1(a5)       ; set color to 0 (WHITE)
            move.w    (a4)+,d4           ; get number of lines to draw - 1
drawloop   
            move.w    (a4)+,d5           ; get index (point number * 6)
            move.l    0(a3,d5.w),_X1(a5) ; set x1 & y1 in one go
            move.w    (a4)+,d5           ; and next index (other end of line)
            move.l    0(a3,d5.w),_X2(a5) ; set x2 & y2
            dc.w      A_DrawLine         ; draw line
            dbf       d4,drawloop

            bra       mainloop           ; go spin it some more

* Now for the data

syncflag    dc.w      0                  ; initially false
varsav      dc.l      0                  ; save lineA variables pointer
filpat      dc.w      -1                 ; fill pattern for lineA (solid)

zang        dc.w      0                  ; Z axis rotation angle
xang        dc.w      0                  ; X axis rotation angle
yang        dc.w      0                  ; Y axis rotation angle

zv          dc.w      4                  ; Z axis rotational velocity
xv          dc.w      4                  ; X axis rotational velocity
yv          dc.w      4                  ; Y axis rotational velocity

* Signed, prescaled (* 127) sine/cosine look-up tables. 360 degrees = 255
* + 64 extra entries for cosine table (start 64 further into table )
* Built using a small C program to save typing.

sintab
            dc.b      $00,$03,$06,$09,$0C,$0F,$12,$15   ;   0 to   7
            dc.b      $18,$1B,$1E,$21,$24,$27,$2A,$2D   ;   8 to  15
            dc.b      $30,$33,$36,$39,$3B,$3E,$41,$43   ;  16 to  23
            dc.b      $46,$49,$4B,$4E,$50,$52,$55,$57   ;  24 to  31
            dc.b      $59,$5B,$5E,$60,$62,$64,$66,$67   ;  32 to  39
            dc.b      $69,$6B,$6C,$6E,$70,$71,$72,$74   ;  40 to  47
            dc.b      $75,$76,$77,$78,$79,$7A,$7B,$7B   ;  48 to  55
            dc.b      $7C,$7D,$7D,$7E,$7E,$7E,$7E,$7E   ;  56 to  63
            dc.b      $7E,$7E,$7E,$7E,$7E,$7E,$7D,$7D   ;  64 to  71
            dc.b      $7C,$7B,$7B,$7A,$79,$78,$77,$76   ;  72 to  79
            dc.b      $75,$74,$72,$71,$70,$6E,$6C,$6B   ;  80 to  87
            dc.b      $69,$67,$66,$64,$62,$60,$5E,$5B   ;  88 to  95
            dc.b      $59,$57,$55,$52,$50,$4E,$4B,$49   ;  96 to 103
            dc.b      $46,$43,$41,$3E,$3B,$39,$36,$33   ; 104 to 111
            dc.b      $30,$2D,$2A,$27,$24,$21,$1E,$1B   ; 112 to 119
            dc.b      $18,$15,$12,$0F,$0C,$09,$06,$03   ; 120 to 127
            dc.b      $00,$FD,$FA,$F7,$F4,$F1,$EE,$EB   ; 128 to 135
            dc.b      $E8,$E5,$E2,$DF,$DC,$D9,$D6,$D3   ; 136 to 143
            dc.b      $D0,$CD,$CA,$C7,$C5,$C2,$BF,$BD   ; 144 to 151
            dc.b      $BA,$B7,$B5,$B2,$B0,$AE,$AB,$A9   ; 152 to 159
            dc.b      $A7,$A5,$A2,$A0,$9E,$9C,$9A,$99   ; 160 to 167
            dc.b      $97,$95,$94,$92,$90,$8F,$8E,$8C   ; 168 to 175
            dc.b      $8B,$8A,$89,$88,$87,$86,$85,$85   ; 176 to 183
            dc.b      $84,$83,$83,$82,$82,$82,$82,$82   ; 184 to 191
            dc.b      $82,$82,$82,$82,$82,$82,$83,$83   ; 192 to 199
            dc.b      $84,$85,$85,$86,$87,$88,$89,$8A   ; 200 to 207
            dc.b      $8B,$8C,$8E,$8F,$90,$92,$94,$95   ; 208 to 215
            dc.b      $97,$99,$9A,$9C,$9E,$A0,$A2,$A5   ; 216 to 223
            dc.b      $A7,$A9,$AB,$AE,$B0,$B2,$B5,$B7   ; 224 to 231
            dc.b      $BA,$BD,$BF,$C2,$C5,$C7,$CA,$CD   ; 232 to 239
            dc.b      $D0,$D3,$D6,$D9,$DC,$DF,$E2,$E5   ; 240 to 247
            dc.b      $E8,$EB,$EE,$F1,$F4,$F7,$FA,$FD   ; 248 to 255
            dc.b      $00,$03,$06,$09,$0C,$0F,$12,$15   ; 256 to 263
            dc.b      $18,$1B,$1E,$21,$24,$27,$2A,$2D   ; 264 to 271
            dc.b      $30,$33,$36,$39,$3B,$3E,$41,$43   ; 272 to 279
            dc.b      $46,$49,$4B,$4E,$50,$52,$55,$57   ; 280 to 287
            dc.b      $59,$5B,$5E,$60,$62,$64,$66,$67   ; 288 to 295
            dc.b      $69,$6B,$6C,$6E,$70,$71,$72,$74   ; 296 to 303
            dc.b      $75,$76,$77,$78,$79,$7A,$7B,$7B   ; 304 to 311
            dc.b      $7C,$7D,$7D,$7E,$7E,$7E,$7E,$7E   ; 312 to 319

* Definition of object - x,y,z co-ordinates of 3D image to rotate

coords      dc.w      13-1               ; No of points to work on minus 1
            dc.w      -64,-64,-64        ; 6 bytes per point
            dc.w      64,-64,-64         ; but use auto inc wherever possible
            dc.w      64,64,-64          ; to save having to multiply by 6
            dc.w      -64,64,-64         ; to get an index.
            dc.w      -64,-64,64
            dc.w      64,-64,64
            dc.w      64,64,64
            dc.w      -64,64,64
            dc.w      -44,44,-44
            dc.w      -44,-44,-44
            dc.w      0,20,-44
            dc.w      44,-44,-44
            dc.w      44,44,-44

* this table shows which points to put lines between
* doing the index multiply ( *6 ) now saves time later.

order       dc.w      16-1               ; No of lines to draw minus one

* Cube 
            dc.w      0*6,1*6            ; join point 0 to 1
            dc.w      1*6,2*6            ; 1 to 2
            dc.w      2*6,3*6            ; 2 to 3
            dc.w      3*6,0*6            ; 3 to 0
            dc.w      4*6,5*6            ; 4 to 5
            dc.w      5*6,6*6            ; 5 to 6
            dc.w      6*6,7*6            ; 6 to 7
            dc.w      7*6,4*6            ; 7 to 4
            dc.w      0*6,4*6            ; 0 to 4
            dc.w      1*6,5*6            ; 1 to 5
            dc.w      2*6,6*6            ; 2 to 6
            dc.w      3*6,7*6            ; 3 to 7

* M Shape 
            dc.w      8*6,9*6            ; 8 to 9
            dc.w      9*6,10*6           ; 9 to 10
            dc.w      10*6,11*6          ; 10 to 11
            dc.w      11*6,12*6          ; 11 to 12

* Reserve 39 words for old points array for undraw

oldco       dcb.w     39,0               ; make sure this block is harmless on
                                         ; 1st loop (it'll still get undrawn)

* and another 39 for new points array for next re-draw

newco       ds.w      39

            end
