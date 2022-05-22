;
; Drawline test! - Real number version.  Testing big lines...  Umm seems
; the rotation is taking over 20%!!!
; I sped up the rotaion bit a little...
;
; OOH!   Lookit THIS version!  It has:
;
; Line clipping (horaayy!).
; Fault-free line drawer that is actually FASTER than Bresenham's technique!
; View AND object rotation!!!!!
;
; Waheyy!
;
; (err...  Line drawer MAY be a bit weird on some cases!!)
;
; Just a thought, looking at the matrix multiplication...  Wouldn't it be the
; same just to add the view angles to the object's ones?  Hmm...
; Hang on!  I haven't considered the object OUTSIDE the origin (0,0,0)!!!
; Aaaaaargh!
;
; Got the bloody 'viewer rotation' working (ish).  I'm going to get a cardboard
; box and see if it REALLY should do that (try rotating on viex Y or Z!!).
;
; Update...  Err i never REALLY thought multiplication or addition was
; cumulative.  I swapped the matrix multiplication around (2x1 instead of 1x2)
; and it works perfectly now!!!  Actually I wonder if it's with preserving the
; order of the matrix...  Since one of the matrices (the left one I think!)
; gets rotated (by matrix multiplication) by 90 degrees.  HMM!
;
; Jose now has been nominated for 'DUMB SHIT' of the year.  I had a little doubt
; and looked in a book - yup, matrix multiplication is NOT commutative!!
; AxB does NOT equal BxA!!  Aggg!  It seems that the batrix that is preserved
; is the multiplier (the left one) and we need to preserve the view matrix
; hence the BxA ordering (wonder why the view matrix not the object...).
;
; Jose (The All-Encompassing Really Chuffed The Phantom).
;
;

; SetVideo() equates.

VERTFLAG	EQU $0100	; double-line on VGA, interlace on ST/TV ;
STMODES		EQU $0080	; ST compatible ;
OVERSCAN	EQU $0040	; Multiply X&Y rez by 1.2, ignored on VGA ;
PAL		EQU $0020	; PAL if set, else NTSC ;
VGA		EQU $0010	; VGA if set, else TV mode ;
COL80		EQU $0008	; 80 column if set, else 40 column ;
BPS16		EQU $0004
BPS8		EQU $0003
BPS4		EQU $0002
BPS2		EQU $0001
BPS1		EQU $0000

scx             EQU 129
scy             EQU 99

                clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.w  #6,SP
                move.l  D0,oldsp


                lea     screens(PC),A0
                move.l  A0,D0
                add.l   #256+7680,D0
                clr.b   D0
                move.l  D0,scrnpos
                add.l   #32000+7680,D0
                move.l  D0,scrn2

                movea.l scrnpos(PC),A0
                move.w  #4999,D0
                moveq   #0,D1
cls:            move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                dbra    D0,cls
		;MOVE.W #PAL+BPS16,-(SP)
		MOVE.W #VGA+STMODES+VERTFLAG+BPS4,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP

                move.w  #37,-(SP)
                trap    #14
                addq.w  #2,SP
		;clr	-(sp)
		;pea 	-1.w
		;pea 	-1.w
		;move.w	#5,-(sp)
		;trap	#14
		;lea	12(sp),sp

                ;clr.b   $FFFF8260.w
                ;move.w  #37,-(SP)
                ;trap    #14
                ;addq.w  #2,SP
                ;move.b  #1,$FFFF8260.w
                ;move.w  #37,-(SP)
                ;trap    #14
                ;addq.w  #2,SP
                ;clr.b   $FFFF8260.w

                clr.w   $FFFF8240.w
                lea     $FFFF8242.w,A0
                REPT 15
                move.w  #$0770,(A0)+
                ENDR
                move.w  #$0247,$FFFF8242+(2*0).w
;                move.w  #$47,$FFFF8240+(2*2).w
;                move.w  #$0700,$FFFF8240+(2*4).w
;                move.w  #$0700,$FFFF8240+(2*3).w ; Spline-line same area.

                move    #$2700,SR
                move.b  $FFFFFA07.w,sa1
                move.b  $FFFFFA09.w,sa2
                move.l  $70.w,oldvbl
                clr.b   $FFFFFA07.w
                clr.b   $FFFFFA09.w
                move.l  #vbl,$70.w
                move.l  #zdiv,$14.w
                move    #$2300,SR


key:
                move.w  lcount(PC),D0
sync:           cmp.w   lcount(PC),D0
                beq.s   sync

*                move.w  #$0300,$FFFF8240.w

                movea.l scrnpos(PC),A0
;                lea     4(A0),A0
                moveq   #10-1,D0
                moveq   #0,D1
btwp1:
scoff           SET 0
                REPT 400
                move.l  D1,scoff(A0)
scoff           SET scoff+8
                ENDR
                lea     3200(A0),A0
                dbra    D0,btwp1

*               move.w  #$03,$FFFF8240.w

;                movem.w incx(PC),D0-D2
                addi.w  #4,xang
                addi.w  #3,yang
                addi.w  #0,zang


                lea     sintab(PC),A0   ; SET UP MATRIX.
                lea     512(A0),A4
                move.w  #1023,D6
xangle:         move.w  xang(PC),D0
                and.w   D6,D0
                add.w   D0,D0
                move.w  0(A0,D0.w),D1   ; Sin X into D1
                move.w  0(A4,D0.w),D0   ; Cos X into D0.
yangle:         move.w  yang(PC),D2
                and.w   D6,D2
                add.w   D2,D2
                move.w  0(A0,D2.w),D3   ; Sin Y into D3
                move.w  0(A4,D2.w),D2   ; Cos Y into D2.
zangle:         move.w  zang(PC),D4
                and.w   D6,D4
                add.w   D4,D4
                move.w  0(A0,D4.w),D5   ; Sin Z into D5
                move.w  0(A4,D4.w),D4   ; Cos Z into D4.

                lea     matrix1(PC),A0
                bsr     make_matrix     ; Generate that matrix!

                lea     crud(PC),A1
                moveq   #4-1,D7
                lea     wee(PC),A2
                lea     matrix1(PC),A0
                bsr     rotate



                lea     wee(PC),A3
                move.w  #3-1,D6
lala:           movea.l scrnpos(PC),A0
                movem.w (A3),D0-D3
                addq.w  #4,A3
                bsr     drawline
                dbra    D6,lala

*                move.w  #$0700,$FFFF8240.w
                lea     freud(PC),A4    ;draw to screen routine
                lea     wee(PC),A5      ;load a5 with point pairs..
                move.w  #2,D0           ;resolution 1..8
                move.w  #4,D1           ;No of control points (min. 4)
                bsr     BSPLINE         ;a6 also used. (A-Line pointer)
*                clr.w   $FFFF8240.w

                lea     freud(PC),A3
                move.w  #(4*8)-1,D6
lolo:           movea.l scrnpos(PC),A0
                addq.w  #2,A0
                movem.w (A3)+,D0-D3
                bsr     drawline
                dbra    D6,lolo



                move.b  scrnpos+1(PC),$FFFF8201.w
                move.b  scrnpos+2(PC),$FFFF8203.w
                move.l  scrnpos(PC),D0
                move.l  scrn2(PC),scrnpos
                move.l  D0,scrn2

                clr.w   $FFFF8240.w

                cmpi.b  #57,$FFFFFC02.w
                bne     key


out:            clr.w   $FFFF8240.w
                move.w  #$0777,$FFFF8242.w
                move.w  #$0777,$FFFF8244.w
                move.w  #$0777,$FFFF8246.w

                move    #$2700,SR
                move.l  oldvbl(PC),$70.w
                move.b  sa1(PC),$FFFFFA07.w
                move.b  sa2(PC),$FFFFFA09.w
                move    #$2300,SR

flush:          btst    #7,$FFFFFC00.w
                beq.s   fl_done
                move.b  $FFFFFC02.w,D0
                bra.s   flush
fl_done:

                move.l  oldsp(PC),-(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.w  #6,SP

                clr.w   -(SP)
                trap    #1

vbl:            addq.w  #1,lcount
zdiv:           rte



crud:           DC.W -1000,0,1000
                DC.W -500,0,-100
                DC.W 1500,0,-100
                DC.W 1000,0,1000

wee:            DS.W 256
freud:          DS.W 256
templ:          DS.L 2


sa              EQU 4
;And then draw Bspline A proper!
                DC.W $A000
                movea.l A0,A6
                lea     xyoff(PC),A4    ;these are for line routine only

                lea     line(PC),A3     ;draw to screen routine
                lea     pga(PC),A5      ;load a5 with point pairs..
                move.w  #sa,D0          ;resolution 1..8
                move.w  ppa(PC),D1      ;No of control points (min. 4)
                bsr.s   BSPLINE         ;a6 also used. (A-Line pointer)

                move.w  #1,-(SP)
                trap    #1
                addq.w  #2,SP
                clr.w   -(SP)
                trap    #1
;###########################################################################
;Input:
;       d0=1..8   :Resolution
;       d1=4..129 :No. of pointpairs
;       a3=Drawing routine
;       a5=Pointpair array
;
bv:             DC.W 0,0,2,1,4,3,8,7,16,15,32,31,64,63,128,127,256,255
bb:             DC.W 0,$E2E1,$E4EF,$E6ED,$E8EB,$EAE9,$ECE7,$EEE5,$E0E3
BSPLINE:
;Self modify for control points..
                move.w  D1,D7           ;D1=NO. OF POINT PAIRS! save for muls..
                subq.b  #2,D7           ;pp-2
                subq.w  #3,D1           ;pp-3
                move.w  D1,bsp+2        ;load in for check on last segment..!
                addq.w  #3,D1
                add.w   D1,D1
                add.w   D1,D1           ;pp*4
                subq.w  #4,D1
                move.w  D1,bso+2        ;self modify offset..
;Now self modify for resolution (2..256/cp pair)
                move.w  D0,D1
                add.w   D1,D1
                move.b  bb(PC,D1.w),bsr
                move.b  1+bb(PC,D1.w),bsl
                add.w   D1,D1
                move.w  bv(PC,D1.w),bs1+2
                move.w  bv(PC,D1.w),bs2+2
                move.w  2+bv(PC,D1.w),bsa+2
                muls    bv(PC,D1.w),D7
                move.w  D7,bsm+2
;All self modification done.. Now we can boogy!
                movem.w (A5),A2-A3      ;x1 y1 -> saved ! LASTPT &2
                moveq   #1,D7           ;d7 means line segment no.
bslp2:          movea.l A5,A6           ;save pointpair pointer..
                move.l  D7,D5           ;load current line segment..
                move.l  D5,D6           ;save it in d6 too
bsa:            and.w   #1234,D5        ;j%sx (k)eg 256lines -> $fF (2^8-1)
bsr:            lsr.w   #1,D6           ;j/sx (l)eg " " "    -> 8   ( ^8)
                beq.s   cont            ;Comment this line for SPLIT
bs1:            add.w   #1234,D5        ;Set up for middle lines
bsp:            cmp.w   #1234,D6        ;last line segments? (pp-3)
                bne.s   cont            ;Change from bne.s to bra.s for SPLIT
bs2:            add.w   #1234,D5        ;end lines :Taken out!
cont:           move.w  D5,D4           ;d5 points to correct data for this section of spline.
                add.w   D5,D5
                add.w   D4,D5           ;mul by 3
bsl:            lsl.l   #1,D5           ;and a bit more..
                lea     BSDATA(PC),A0
                adda.w  D5,A0           ;points to current Bspline data
                add.w   D6,D6
                add.w   D6,D6           ;each point-pair takes four bytes..
                adda.w  D6,A6           ;points to current point data..
                moveq   #0,D4
                moveq   #0,D5
                REPT 3
                move.w  (A6)+,D3
                move.w  (A6)+,D6
                muls    (A0),D3
                muls    (A0)+,D6
                add.l   D3,D3
                add.l   D6,D6
                add.l   D3,D4           ;x
                add.l   D6,D5           ;y
                ENDR
                swap    D4
                swap    D5
;                jsr     (A3)
                movem.w D4-D5/A2-A3,(A4) ; LASTPTR &2 + X,Y
                addq.w  #8,A4
                movea.w D4,A2           ; LASTPT
                movea.w D5,A3           ; LASTPT+2
                addq.w  #1,D7
bsm:            cmp.w   #1234,D7
                blt.s   bslp2
bso:            lea     1234(A5),A5
                movem.w A2-A3,(A4)      ; LASTPT &2
                move.l  (A5),4(A4)      ; X,Y
;                addq.w  #8,A4
;                jsr     (A3)
;                move.w  D4,lastpt
;                move.w  D5,lastpt+2
                rts
;###########################################################################
;a4=f0wxyoff!
line:           movem.l D0-A6,-(SP)     ;input: lastpt=x1y1, d4/d5=x2y2
                movem.w lastpt(PC),D0-D1
                add.w   (A4),D0
                add.w   2(A4),D1
                movem.w D0-D1,$26(A6)   ;x1y1 in and adjusted
                movem.w D4-D5,lastpt    ;x2y2 saved
                add.w   (A4),D4
                add.w   2(A4),D5
                movem.w D4-D5,$2A(A6)   ;x2y2 in and adjusted
                move.w  #-1,$18(A6)     ;color?!
                clr.w   $1A(A6)         ;color?!
                clr.w   $1C(A6)         ;color?!
                clr.w   $1E(A6)         ;color?!
                clr.w   $20(A6)         ;Not XOR!
                move.w  #-1,$22(A6)     ;linestyle mask!?
                clr.w   $24(A6)         ;replace
                DC.W $A003
                movem.l (SP)+,D0-A6
                rts
;###########################################################################
BSDATA:         Incbin BSPLINE.DAX
xyoff:          DC.W 0,0
ppa:            DC.W 4
pga:            DC.W 234,100
                DC.W 121,312
                DC.W 503,43
                DC.W 28,280
lastpt:         DS.L 1


; (Real number version).
drawline:

                bsr     clipline
                tst.w   D4
                bmi     noline

drawline_unclipped:
                cmp.w   D2,D0           ; Make it so we always go from right
                bge.s   nobig           ; to left of line.
                exg     D0,D2
                exg     D1,D3
nobig:

                lea     yoffs(PC),A1    ; Add Y screen offset.
                move.w  D1,D4
                add.w   D4,D4
                add.w   D4,D4
                adda.l  0(A1,D4.w),A0


                sub.w   D1,D3           ; Y2-Y1
                bmi.s   itsneg          ; If negative, invert.
                beq.s   itszer          ; If zero, leave.
; ...  Alse it's positive slope.
                move.w  #160,D1
                bra.s   contx

itszer:         moveq   #0,D1
                bra.s   contx

itsneg:         move.w  #-160,D1        ; We decrease in Y.
                neg.w   D3              ; Make DY absolute.
contx:

; D3 = DY    ( ABS(Y2-Y1) )
; D1 = SGN(Y2-Y1)

                sub.w   D0,D2           ; X2 - X1
                bpl.s   nonegx
                neg.w   D2
nonegx:
; D2 = DX    ( ABS(X2-X1) )

                cmp.w   D3,D2           ; Check if DY > DX
                bge     case0

; Case 1... (STEEP SLOPE)

                lea     lnxs(PC),A1
                add.w   D0,D0
                add.w   D0,D0
                move.l  0(A1,D0.w),D0
                adda.w  D0,A0           ; Add screen offset.
                swap    D0              ; Now we have the pixel.


                move.w  D3,D4
                lsl.w   #4,D4
                neg.w   D4

                lea     multab(PC),A1   ; Replacment for below! (see top)
                add.w   D3,D3
                mulu    0(A1,D3.w),D2

*                ext.l   D2              ; Get fraction to (1/256) accuracy.
*                lsl.l   #8,D2
*                divu    D3,D2
*                ext.l   D2
*                lsl.l   #8,D2

                moveq   #0,D3

                lea     endjmps1(PC),A1
                jmp     0(A1,D4.w)

                REPT 201
                or.w    D0,(A0)         ; Plot point.
                sub.w   D2,D3           ; Add fraction.
                DC.W $6408      ; BCC.S - Test for X inc.
                add.w   D0,D0           ; Yep, move X.
                DC.W $6404      ; BCC.S - Check for point wrap.
                moveq   #1,D0           ; Yep, re-set pixel position.
                subq.w  #8,A0           ; Move to left chunk.
                adda.w  D1,A0           ; > Else move Y position.
                ENDR
endjmps1:
                rts


; Case 0... (FLAT SLOPE)
case0:
                lea     lnxs(PC),A1
                add.w   D0,D0
                add.w   D0,D0
                move.l  0(A1,D0.w),D0
                adda.w  D0,A0           ; Add screen offset.
                swap    D0              ; Now we have the pixel.

                move.w  D2,D4
                lsl.w   #4,D4
                neg.w   D4


                lea     multab(PC),A1   ; Replacement for below! (see top)
                add.w   D2,D2
                mulu    0(A1,D2.w),D3

*                add.l   D3,D3
*                ext.l   D3              ; Get fraction (to 1/256 accuracy).
*                lsl.l   #8,D3
*                divu    D2,D3
*                lsl.l   #8,D3

                moveq   #0,D2

                lea     endjmps2(PC),A1
                jmp     0(A1,D4.w)

                REPT 321
                or.w    D0,(A0)         ; Plot point.
                add.w   D0,D0           ; Move it left.
                DC.W $6404      ; BCC.S - test for wrap.
                moveq   #1,D0           ; Wrap.  Re-set pixel position.
                subq.w  #8,A0           ; Move to left screen chunk.
                sub.w   D3,D2           ; > Else Add fraction.
                DC.W $6402      ; BCC.S - test for Y inc.
                adda.w  D1,A0           ; Yes, so add to Y position.
                ENDR
endjmps2:
noline:         rts



;
; Line clipper by Jose Commins, or The Phantom of Electronic Images!
; Ah well, this one's the faster-shorter-generally-better one that sorts the
; coordinates and does much quicker checks for everything, and, as above, the
; code is about half the size too!
; Trashes D4-D7 and A1.
; Entered with X1,Y1,X2,Y2 in D0-D3.
;
; Returns with value in D4.  If D4 is negative, line is totally invisible.
;
; For speed, clip widow is defined as WORDS in this sequence:
; CLIP LEFT,CLIP RIGHT,CLIP BOTTOM,CLIP TOP.
; Don't organise them any other way as it will get the wrong values!
;

clipline:
                lea     clipleft(PC),A1

                cmp.w   D0,D2           ; Sort 'em according to X.
                bge.s   lineok1
                exg     D0,D2
                exg     D1,D3
lineok1:
                cmp.w   2(A1),D0        ; Left edge off clip right?
                bgt     lineout
                cmp.w   (A1),D2
                blt     lineout         ; Right edge off clip left?

                cmp.w   (A1),D0         ; Left edge off left?
                bge.s   noutl1
                move.w  D3,D4
                sub.w   D1,D4           ; Y2-Y1
                move.w  (A1),D5         ; Left side.
                sub.w   D0,D5           ; Xt-X1
                muls    D5,D4           ; (Y2-Y1)*(Xt-X1)
                move.w  D2,D5
                sub.w   D0,D5           ; X2-X1
                divs    D5,D4           ; DY
                add.w   D4,D1           ; New Y1.
                move.w  (A1),D0         ; X1=Left edge.

noutl1:         cmp.w   2(A1),D2        ; Right edge off right?
                ble.s   noutr1

                move.w  D1,D4
                sub.w   D3,D4           ; Y1-Y2
                move.w  2(A1),D5        ; Right side.
                sub.w   D2,D5           ; Xt-X2
                muls    D5,D4           ; (Y1-Y2)*(Xt-X2)
                move.w  D0,D5
                sub.w   D2,D5           ; X1-X2
                divs    D5,D4           ; DY
                add.w   D4,D3           ; New Y2.
                move.w  2(A1),D2        ; X2=Right edge.

noutr1:         cmp.w   D1,D3           ; Sort 'em according to Y.
                bge.s   lineok2
                exg     D1,D3
                exg     D0,D2
lineok2:
                cmp.w   4(A1),D1        ; Top of line off bottom?
                bgt.s   lineout
                cmp.w   6(A1),D3
                blt.s   lineout         ; Bottom of line off top?

                cmp.w   4(A1),D3        ; Bottom of line off bottom?
                ble.s   noutb1

                move.w  D0,D4
                sub.w   D2,D4           ; X1-X2
                move.w  4(A1),D5        ; Bottom side.
                sub.w   D3,D5           ; Yt-Y2
                muls    D5,D4           ; (X1-X2)*(Yt-Y2)
                move.w  D1,D5
                sub.w   D3,D5           ; Y1-Y2
                divs    D5,D4           ; Dx
                add.w   D4,D2           ; New X2.
                move.w  4(A1),D3        ; Y2=Bottom edge.

noutb1:         cmp.w   6(A1),D1        ; Top of line off top?
                bge.s   noutt1

                move.w  D2,D4
                sub.w   D0,D4           ; X2-X1
                move.w  6(A1),D5        ; Top side.
                sub.w   D1,D5           ; Yt-Y1
                muls    D5,D4           ; (X2-X1)*(Yt-Y1)
                move.w  D3,D5
                sub.w   D1,D5           ; Y2-Y1
                divs    D5,D4           ; Dx
                add.w   D4,D0           ; New X1.
                move.w  6(A1),D1        ; Y1=Top edge.


noutt1:         moveq   #0,D4           ; Line is now visoble.
                rts

lineout:        moveq   #-1,D4          ; Line invisible.
                rts

clipleft:       DC.W 0
clipright:      DC.W 319
clipbottom:     DC.W 199
cliptop:        DC.W 0


mat_mul:
                REPT 3

                move.w  (A2),D0
                muls    (A1),D0
                move.w  6(A2),D1
                muls    2(A1),D1
                move.w  12(A2),D2
                muls    4(A1),D2
                add.l   D0,D1
                add.l   D1,D2
                add.l   D2,D2
                swap    D2
                move.w  D2,(A0)+

                move.w  2(A2),D0
                muls    (A1),D0
                move.w  2+6(A2),D1
                muls    2(A1),D1
                move.w  2+12(A2),D2
                muls    4(A1),D2
                add.l   D0,D1
                add.l   D1,D2
                add.l   D2,D2
                swap    D2
                move.w  D2,(A0)+

                move.w  4(A2),D0
                muls    (A1),D0
                move.w  4+6(A2),D1
                muls    2(A1),D1
                move.w  4+12(A2),D2
                muls    4(A1),D2
                add.l   D0,D1
                add.l   D1,D2
                add.l   D2,D2
                swap    D2
                move.w  D2,(A0)+

                addq.w  #6,A1

                ENDR

                rts


oldsp:          DS.L 1
oldvbl:         DS.L 1
scrnpos:        DS.L 1
scrn2:          DS.L 1

lcount:         DS.W 1

sa1:            DS.B 1
sa2:            DS.B 1

                EVEN


posx:           DC.W 0
posy:           DC.W 0
posz:           DC.W 3000

px:             DC.W 0
py:             DC.W 0
pz:             DC.W 0

matrix1:        DC.W 0,0,0
                DC.W 0,0,0
                DC.W 0,0,0

matrix2:        DC.W 0,0,0
                DC.W 0,0,0
                DC.W 0,0,0

matrix3:        DC.W 0,0,0
                DC.W 0,0,0
                DC.W 0,0,0



vincx:          DC.W 0
vincy:          DC.W 0
vincz:          DC.W 0

incx:           DC.W 0
incy:           DC.W 0
incz:           DC.W 4

xang:           DC.W 0
yang:           DC.W 0
zang:           DC.W 0

vx:             DC.W 0
vy:             DC.W 0
vz:             DC.W 0

links:          DS.L 1

square:         DC.W 14-1
                DC.W 1000,1000,-1000
                DC.W 1000,-1000,-1000
                DC.W -1000,-1000,-1000
                DC.W -1000,1000,-1000

                DC.W 1000,-1000,1000
                DC.W -1000,-1000,1000
                DC.W -1000,1000,1000
                DC.W 1000,1000,1000

                DC.W 0,0,1000
                DC.W 0,0,-1000
                DC.W 0,1000,0
                DC.W 1000,0,0
                DC.W 0,-1000,0
                DC.W -1000,0,0

; Links bitz.
                DC.W 0*4,1*4
                DC.W 1*4,2*4
                DC.W 2*4,3*4
                DC.W 3*4,0*4

                DC.W 1*4,4*4
                DC.W 2*4,5*4
                DC.W 3*4,6*4
                DC.W 0*4,7*4

                DC.W 7*4,4*4
                DC.W 4*4,5*4
                DC.W 5*4,6*4
                DC.W 6*4,7*4


                DC.W 8*4,10*4
                DC.W 8*4,11*4
                DC.W 8*4,12*4
                DC.W 8*4,13*4

                DC.W 9*4,10*4
                DC.W 9*4,11*4
                DC.W 9*4,12*4
                DC.W 9*4,13*4

                DC.W 10*4,11*4
                DC.W 11*4,12*4
                DC.W 12*4,13*4
                DC.W 13*4,10*4


                DC.W -99

rotted:         DS.L 100

lnxs:
scoff           SET 0
                REPT 20
                DC.W %1000000000000000,scoff
                DC.W %100000000000000,scoff
                DC.W %10000000000000,scoff
                DC.W %1000000000000,scoff
                DC.W %100000000000,scoff
                DC.W %10000000000,scoff
                DC.W %1000000000,scoff
                DC.W %100000000,scoff
                DC.W %10000000,scoff
                DC.W %1000000,scoff
                DC.W %100000,scoff
                DC.W %10000,scoff
                DC.W %1000,scoff
                DC.W %100,scoff
                DC.W %10,scoff
                DC.W %1,scoff
scoff           SET scoff+8
                ENDR

yoff            SET -(100*160)
                REPT 100
                DC.L yoff
yoff            SET yoff+160
                ENDR

yoffs:
yoff            SET 0
                REPT 250
                DC.L yoff
yoff            SET yoff+160
                ENDR

multab:
*                DC.W 0
                DC.W 0
tabval          SET 1
                REPT 500
                DC.W 65535/tabval
tabval          SET tabval+1
                ENDR


**********************************
* Rotate points for use when not clipping.
make_matrix:
* D0=CosX
* D1=SinX
* D2=CosY
* D3=SinY
* D4=CosZ
* D5=SinZ
*
* Cy*Cz,Cy*Sz,Sy
* !Sx*Sy!*Cz+Cx*-Sz,!Sx*Sy!*Sz+Cx*Cz,-Sx*Cy
* ;Cx*-Sy;*Cz+Sx*-Sz,;Cx*-Sy;*Sz+Sx*Cz,Cx*Cy

x:              move.w  D4,D6           ; Store CosZ.
                muls    D2,D4           ; CosY * CosZ.
                add.l   D4,D4
                swap    D4
                move.w  D4,(A0)+        ; > M1,1
                move.w  D6,D4           ; Restore Cos Z.
                move.w  D5,D6           ; Store SinZ.
                muls    D2,D5           ; CosY * SinZ.
                add.l   D5,D5
                swap    D5
                move.w  D5,(A0)+        ; > M2,1
                move.w  D6,D5
                move.w  D3,(A0)+        ; > M3,1 = SinY. Also stores d3!
                move.w  D3,-(SP)
y:              muls    D1,D3           ; SinX * SinY
                add.l   D3,D3
                swap    D3
                movea.w D3,A4           ; Store for later.
                muls    D4,D3           ; * CosZ.
                move.w  D5,D6           ; Store SinZ.
                neg.w   D5              ; SinZ = -SinZ.
                muls    D0,D5           ; CosX * -SinZ.
                add.l   D5,D3
                add.l   D3,D3
                swap    D3
                move.w  D3,(A0)+        ; > M1,2.
                move.w  A4,D3           ; Fetch SinX * SinY.
                move.w  D6,D5           ; Restore SinZ.
                muls    D5,D3           ; * SinZ.
                move.w  D4,D6           ; Store CosZ.
                muls    D0,D4           ; CosX * CosZ.
                add.l   D4,D3
                add.l   D3,D3
                swap    D3
                move.w  D6,D4           ; Restore CosZ.
                move.w  D3,(A0)+        ; > M2,2
                move.w  (SP)+,D3        ; Restore SinY.
                move.w  D1,D6           ; Store SinX.
                neg.w   D1              ; SinX = -SinX.
                muls    D2,D1           ; -SinX * CosY.
                add.l   D1,D1
                swap    D1
                move.w  D1,(A0)+        ; > M3,2.
                move.w  D6,D1           ; Restore SinX.
z:              neg.w   D3              ; SinY = -SinY.
                muls    D0,D3           ; CosX * -SinY.
                add.l   D3,D3
                swap    D3
                movea.w D3,A4           ; Store for later.
                muls    D4,D3           ; * CosZ.
                move.w  D5,D6           ; Store SinZ.
                neg.w   D5              ; SinZ = -SinZ.
                muls    D1,D5           ; SinX * -SinZ.
                add.l   D5,D3
                add.l   D3,D3
                swap    D3
                move.w  D3,(A0)+        ; > M1,3
                move.w  A4,D3           ; Get CosX * -SinY.
                muls    D6,D3           ; * SinZ.
                muls    D1,D4           ; SinX * CosZ.
                add.l   D4,D3
                add.l   D3,D3
                swap    D3
                move.w  D3,(A0)+        ; > M2,3
                muls    D0,D2           ; CosX * CosY.
                add.l   D2,D2
                swap    D2
                move.w  D2,(A0)+        ; > M3,3

                rts

* Egg & Bacon

* A1 now contains pointer to xyzlist.

* d5=x
* d4=y
* d3=z

do_pos:
                move.w  posx(PC),D5     ; X
                move.w  posy(PC),D4     ; Y
                move.w  posz(PC),D3     ; Z

                move.w  D5,D0           ; Store old X.

                move.w  D4,D1           ; Store old Y.
                move.w  D3,D2           ; Store old Z.
                muls    (A0)+,D5        ; X * M1,1.
                muls    (A0)+,D1        ; Y * M2,1.
                muls    (A0)+,D2        ; Z * M3,1.
                add.l   D1,D5           ; X * M1,1 + Y * M2,1.
                add.l   D2,D5           ; Above instr + Z * M3,1.
                add.l   D5,D5
                swap    D5

                move.w  D0,D1           ; Store old X.
                move.w  D4,D6           ; Store old Y.

* That bit above has to be done because if it is included with the
* 4 channel player then it cannot use D6 or D7.


                move.w  D3,D2           ; Store old Z.
                muls    (A0)+,D0        ; X * M1,2.
                muls    (A0)+,D4        ; Y * M2,2.
                muls    (A0)+,D2        ; Z * M3,2.
                add.l   D0,D4           ; X * M1,2 + Y * M2,2
                add.l   D2,D4           ; Above instr + Z * M3,2.
                add.l   D4,D4
                swap    D4

                move.w  D6,D0           ; Get old Y.

                muls    (A0)+,D1        ; X * M1,3.
                muls    (A0)+,D0        ; Y * M2,3.
                muls    (A0)+,D3        ; Z * M3,3.
                add.l   D1,D3           ; X * M1,3 + Y * M2,3
                add.l   D0,D3           ; Above instr + Z * M3,3.
                add.l   D3,D3           ; Adjust for fraction (X2).
                swap    D3              ; And divide by 32767 (max RAD).

                move.w  D5,px
                move.w  D4,py
                move.w  D3,pz

                rts


rotate:

nexp:           move.w  (A1)+,D5        ; X
                move.w  (A1)+,D4        ; Y
                move.w  (A1)+,D3        ; Z

                move.w  D5,D0           ; Store old X.

xnew:           move.w  D4,D1           ; Store old Y.
                move.w  D3,D2           ; Store old Z.
m11:            muls    (A0)+,D5        ; X * M1,1.
m21:            muls    (A0)+,D1        ; Y * M2,1.
m31:            muls    (A0)+,D2        ; Z * M3,1.
                add.l   D1,D5           ; X * M1,1 + Y * M2,1.
                add.l   D2,D5           ; Above instr + Z * M3,1.
                add.l   D5,D5
                swap    D5

                move.w  D0,D1           ; Store old X.
                move.w  D4,D6           ; Store old Y.

* That bit above has to be done because if it is included with the
* 4 channel player then it cannot use D6 or D7.


ynew:           move.w  D3,D2           ; Store old Z.
m12:            muls    (A0)+,D0        ; X * M1,2.
m22:            muls    (A0)+,D4        ; Y * M2,2.
m32:            muls    (A0)+,D2        ; Z * M3,2.
                add.l   D0,D4           ; X * M1,2 + Y * M2,2
                add.l   D2,D4           ; Above instr + Z * M3,2.
                add.l   D4,D4
                swap    D4

                move.w  D6,D0           ; Get old Y.

znew:
m13:            muls    (A0)+,D1        ; X * M1,3.
m23:            muls    (A0)+,D0        ; Y * M2,3.
m33:            muls    (A0)+,D3        ; Z * M3,3.
                add.l   D1,D3           ; X * M1,3 + Y * M2,3
                add.l   D0,D3           ; Above instr + Z * M3,3.
                add.l   D3,D3           ; Adjust for fraction (X2).
                swap    D3              ; And divide by 32767 (max RAD).

                lea     -18(A0),A0

perspec:
;                add.w   px(PC),D5
;                add.w   py(PC),D4
;                add.w   pz(PC),D3

                add.w   #3100,D3

                ext.l   D5
                ext.l   D4
                asl.l   #8,D5
                asl.l   #8,D4

                divs    D3,D5           ; And do perspective (/ Z + Horizon).
                divs    D3,D4           ; And do perspective (/ Z + Horizon).

                add.w   #scx,D5
                add.w   #scy,D4

                move.w  D5,(A2)+        ; Store X.
                move.w  D4,(A2)+        ; Store Y.

                dbra    D7,nexp         ; Next point.
                move.l  A1,links
                rts


sintab:         DC.W $00,$C9,$0192,$025B,$0324,$03ED,$04B6,$057E
                DC.W $0647,$0710,$07D9,$08A1,$096A,$0A32,$0AFB,$0BC3
                DC.W $0C8B,$0D53,$0E1B,$0EE3,$0FAB,$1072,$1139,$1200
                DC.W $12C7,$138E,$1455,$151B,$15E1,$16A7,$176D,$1833
                DC.W $18F8,$19BD,$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56
                DC.W $1F19,$1FDC,$209F,$2161,$2223,$22E4,$23A6,$2467
                DC.W $2527,$25E7,$26A7,$2767,$2826,$28E5,$29A3,$2A61
                DC.W $2B1E,$2BDB,$2C98,$2D54,$2E10,$2ECC,$2F86,$3041
                DC.W $30FB,$31B4,$326D,$3326,$33DE,$3496,$354D,$3603
                DC.W $36B9,$376F,$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4
                DC.W $3C56,$3D07,$3DB7,$3E67,$3F16,$3FC5,$4073,$4120
                DC.W $41CD,$4279,$4325,$43D0,$447A,$4523,$45CC,$4674
                DC.W $471C,$47C3,$4869,$490E,$49B3,$4A57,$4AFA,$4B9D
                DC.W $4C3F,$4CE0,$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097
                DC.W $5133,$51CE,$5268,$5301,$539A,$5432,$54C9,$555F
                DC.W $55F4,$5689,$571D,$57B0,$5842,$58D3,$5963,$59F3
                DC.W $5A81,$5B0F,$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F
                DC.W $5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271
                DC.W $62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656
                DC.W $66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC
                DC.W $6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61
                DC.W $6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082
                DC.W $70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E
                DC.W $73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3
                DC.W $7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F
                DC.W $7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41
                DC.W $7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7
                DC.W $7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61
                DC.W $7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E
                DC.W $7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C
                DC.W $7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD
                DC.W $7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE
                DC.W $7FFF,$7FFE,$7FFC,$7FF9,$7FF5,$7FEF,$7FE8,$7FE0
                DC.W $7FD7,$7FCD,$7FC1,$7FB4,$7FA6,$7F96,$7F86,$7F74
                DC.W $7F61,$7F4C,$7F37,$7F20,$7F08,$7EEF,$7ED4,$7EB9
                DC.W $7E9C,$7E7E,$7E5E,$7E3E,$7E1C,$7DF9,$7DD5,$7DB0
                DC.W $7D89,$7D61,$7D38,$7D0E,$7CE2,$7CB6,$7C88,$7C59
                DC.W $7C29,$7BF7,$7BC4,$7B91,$7B5C,$7B25,$7AEE,$7AB5
                DC.W $7A7C,$7A41,$7A04,$79C7,$7989,$7949,$7908,$78C6
                DC.W $7883,$783F,$77F9,$77B3,$776B,$7722,$76D8,$768D
                DC.W $7640,$75F3,$75A4,$7554,$7503,$74B1,$745E,$740A
                DC.W $73B5,$735E,$7306,$72AE,$7254,$71F9,$719D,$7140
                DC.W $70E1,$7082,$7022,$6FC0,$6F5E,$6EFA,$6E95,$6E30
                DC.W $6DC9,$6D61,$6CF8,$6C8E,$6C23,$6BB7,$6B4A,$6ADB
                DC.W $6A6C,$69FC,$698B,$6919,$68A5,$6831,$67BC,$6745
                DC.W $66CE,$6656,$65DD,$6562,$64E7,$646B,$63EE,$6370
                DC.W $62F1,$6271,$61F0,$616E,$60EB,$6067,$5FE2,$5F5D
                DC.W $5ED6,$5E4F,$5DC6,$5D3D,$5CB3,$5C28,$5B9C,$5B0F
                DC.W $5A81,$59F3,$5963,$58D3,$5842,$57B0,$571D,$5689
                DC.W $55F4,$555F,$54C9,$5432,$539A,$5301,$5268,$51CE
                DC.W $5133,$5097,$4FFA,$4F5D,$4EBF,$4E20,$4D80,$4CE0
                DC.W $4C3F,$4B9D,$4AFA,$4A57,$49B3,$490E,$4869,$47C3
                DC.W $471C,$4674,$45CC,$4523,$447A,$43D0,$4325,$4279
                DC.W $41CD,$4120,$4073,$3FC5,$3F16,$3E67,$3DB7,$3D07
                DC.W $3C56,$3BA4,$3AF2,$3A3F,$398C,$38D8,$3824,$376F
                DC.W $36B9,$3603,$354D,$3496,$33DE,$3326,$326D,$31B4
                DC.W $30FB,$3041,$2F86,$2ECC,$2E10,$2D54,$2C98,$2BDB
                DC.W $2B1E,$2A61,$29A3,$28E5,$2826,$2767,$26A7,$25E7
                DC.W $2527,$2467,$23A6,$22E4,$2223,$2161,$209F,$1FDC
                DC.W $1F19,$1E56,$1D93,$1CCF,$1C0B,$1B46,$1A82,$19BD
                DC.W $18F8,$1833,$176D,$16A7,$15E1,$151B,$1455,$138E
                DC.W $12C7,$1200,$1139,$1072,$0FAB,$0EE3,$0E1B,$0D53
                DC.W $0C8B,$0BC3,$0AFB,$0A32,$096A,$08A1,$07D9,$0710
                DC.W $0647,$057E,$04B6,$03ED,$0324,$025B,$0192,$C9
                DC.W $00,$FF37,$FE6E,$FDA5,$FCDC,$FC13,$FB4A,$FA82
                DC.W $F9B9,$F8F0,$F827,$F75F,$F696,$F5CE,$F505,$F43D
                DC.W $F375,$F2AD,$F1E5,$F11D,$F055,$EF8E,$EEC7,$EE00
                DC.W $ED39,$EC72,$EBAB,$EAE5,$EA1F,$E959,$E893,$E7CD
                DC.W $E708,$E643,$E57E,$E4BA,$E3F5,$E331,$E26D,$E1AA
                DC.W $E0E7,$E024,$DF61,$DE9F,$DDDD,$DD1C,$DC5A,$DB99
                DC.W $DAD9,$DA19,$D959,$D899,$D7DA,$D71B,$D65D,$D59F
                DC.W $D4E2,$D425,$D368,$D2AC,$D1F0,$D134,$D07A,$CFBF
                DC.W $CF05,$CE4C,$CD93,$CCDA,$CC22,$CB6A,$CAB3,$C9FD
                DC.W $C947,$C891,$C7DC,$C728,$C674,$C5C1,$C50E,$C45C
                DC.W $C3AA,$C2F9,$C249,$C199,$C0EA,$C03B,$BF8D,$BEE0
                DC.W $BE33,$BD87,$BCDB,$BC30,$BB86,$BADD,$BA34,$B98C
                DC.W $B8E4,$B83D,$B797,$B6F2,$B64D,$B5A9,$B506,$B463
                DC.W $B3C1,$B320,$B280,$B1E0,$B141,$B0A3,$B006,$AF69
                DC.W $AECD,$AE32,$AD98,$ACFF,$AC66,$ABCE,$AB37,$AAA1
                DC.W $AA0C,$A977,$A8E3,$A850,$A7BE,$A72D,$A69D,$A60D
                DC.W $A57F,$A4F1,$A464,$A3D8,$A34D,$A2C3,$A23A,$A1B1
                DC.W $A12A,$A0A3,$A01E,$9F99,$9F15,$9E92,$9E10,$9D8F
                DC.W $9D0F,$9C90,$9C12,$9B95,$9B19,$9A9E,$9A23,$99AA
                DC.W $9932,$98BB,$9844,$97CF,$975B,$96E7,$9675,$9604
                DC.W $9594,$9525,$94B6,$9449,$93DD,$9372,$9308,$929F
                DC.W $9237,$91D0,$916B,$9106,$90A2,$9040,$8FDE,$8F7E
                DC.W $8F1F,$8EC0,$8E63,$8E07,$8DAC,$8D52,$8CFA,$8CA2
                DC.W $8C4B,$8BF6,$8BA2,$8B4F,$8AFD,$8AAC,$8A5C,$8A0D
                DC.W $89C0,$8973,$8928,$88DE,$8895,$884D,$8807,$87C1
                DC.W $877D,$873A,$86F8,$86B7,$8677,$8639,$85FC,$85BF
                DC.W $8584,$854B,$8512,$84DB,$84A4,$846F,$843C,$8409
                DC.W $83D7,$83A7,$8378,$834A,$831E,$82F2,$82C8,$829F
                DC.W $8277,$8250,$822B,$8207,$81E4,$81C2,$81A2,$8182
                DC.W $8164,$8147,$812C,$8111,$80F8,$80E0,$80C9,$80B4
                DC.W $809F,$808C,$807A,$806A,$805A,$804C,$803F,$8033
                DC.W $8029,$8020,$8018,$8011,$800B,$8007,$8004,$8002
                DC.W $8001,$8002,$8004,$8007,$800B,$8011,$8018,$8020
                DC.W $8029,$8033,$803F,$804C,$805A,$806A,$807A,$808C
                DC.W $809F,$80B4,$80C9,$80E0,$80F8,$8111,$812C,$8147
                DC.W $8164,$8182,$81A2,$81C2,$81E4,$8207,$822B,$8250
                DC.W $8277,$829F,$82C8,$82F2,$831E,$834A,$8378,$83A7
                DC.W $83D7,$8409,$843C,$846F,$84A4,$84DB,$8512,$854B
                DC.W $8584,$85BF,$85FC,$8639,$8677,$86B7,$86F8,$873A
                DC.W $877D,$87C1,$8807,$884D,$8895,$88DE,$8928,$8973
                DC.W $89C0,$8A0D,$8A5C,$8AAC,$8AFD,$8B4F,$8BA2,$8BF6
                DC.W $8C4B,$8CA2,$8CFA,$8D52,$8DAC,$8E07,$8E63,$8EC0
                DC.W $8F1F,$8F7E,$8FDE,$9040,$90A2,$9106,$916B,$91D0
                DC.W $9237,$929F,$9308,$9372,$93DD,$9449,$94B6,$9525
                DC.W $9594,$9604,$9675,$96E7,$975B,$97CF,$9844,$98BB
                DC.W $9932,$99AA,$9A23,$9A9E,$9B19,$9B95,$9C12,$9C90
                DC.W $9D0F,$9D8F,$9E10,$9E92,$9F15,$9F99,$A01E,$A0A3
                DC.W $A12A,$A1B1,$A23A,$A2C3,$A34D,$A3D8,$A464,$A4F1
                DC.W $A57F,$A60D,$A69D,$A72D,$A7BE,$A850,$A8E3,$A977
                DC.W $AA0C,$AAA1,$AB37,$ABCE,$AC66,$ACFF,$AD98,$AE32
                DC.W $AECD,$AF69,$B006,$B0A3,$B141,$B1E0,$B280,$B320
                DC.W $B3C1,$B463,$B506,$B5A9,$B64D,$B6F2,$B797,$B83D
                DC.W $B8E4,$B98C,$BA34,$BADD,$BB86,$BC30,$BCDB,$BD87
                DC.W $BE33,$BEE0,$BF8D,$C03B,$C0EA,$C199,$C249,$C2F9
                DC.W $C3AA,$C45C,$C50E,$C5C1,$C674,$C728,$C7DC,$C891
                DC.W $C947,$C9FD,$CAB3,$CB6A,$CC22,$CCDA,$CD93,$CE4C
                DC.W $CF05,$CFBF,$D07A,$D134,$D1F0,$D2AC,$D368,$D425
                DC.W $D4E2,$D59F,$D65D,$D71B,$D7DA,$D899,$D959,$DA19
                DC.W $DAD9,$DB99,$DC5A,$DD1C,$DDDD,$DE9F,$DF61,$E024
                DC.W $E0E7,$E1AA,$E26D,$E331,$E3F5,$E4BA,$E57E,$E643
                DC.W $E708,$E7CD,$E893,$E959,$EA1F,$EAE5,$EBAB,$EC72
                DC.W $ED39,$EE00,$EEC7,$EF8E,$F055,$F11D,$F1E5,$F2AD
                DC.W $F375,$F43D,$F505,$F5CE,$F696,$F75F,$F827,$F8F0
                DC.W $F9B9,$FA82,$FB4A,$FC13,$FCDC,$FDA5,$FE6E,$FF37
                DC.W $00,$C9,$0192,$025B,$0324,$03ED,$04B6,$057E
                DC.W $0647,$0710,$07D9,$08A1,$096A,$0A32,$0AFB,$0BC3
                DC.W $0C8B,$0D53,$0E1B,$0EE3,$0FAB,$1072,$1139,$1200
                DC.W $12C7,$138E,$1455,$151B,$15E1,$16A7,$176D,$1833
                DC.W $18F8,$19BD,$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56
                DC.W $1F19,$1FDC,$209F,$2161,$2223,$22E4,$23A6,$2467
                DC.W $2527,$25E7,$26A7,$2767,$2826,$28E5,$29A3,$2A61
                DC.W $2B1E,$2BDB,$2C98,$2D54,$2E10,$2ECC,$2F86,$3041
                DC.W $30FB,$31B4,$326D,$3326,$33DE,$3496,$354D,$3603
                DC.W $36B9,$376F,$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4
                DC.W $3C56,$3D07,$3DB7,$3E67,$3F16,$3FC5,$4073,$4120
                DC.W $41CD,$4279,$4325,$43D0,$447A,$4523,$45CC,$4674
                DC.W $471C,$47C3,$4869,$490E,$49B3,$4A57,$4AFA,$4B9D
                DC.W $4C3F,$4CE0,$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097
                DC.W $5133,$51CE,$5268,$5301,$539A,$5432,$54C9,$555F
                DC.W $55F4,$5689,$571D,$57B0,$5842,$58D3,$5963,$59F3
                DC.W $5A81,$5B0F,$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F
                DC.W $5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271
                DC.W $62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656
                DC.W $66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC
                DC.W $6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61
                DC.W $6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082
                DC.W $70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E
                DC.W $73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3
                DC.W $7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F
                DC.W $7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41
                DC.W $7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7
                DC.W $7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61
                DC.W $7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E
                DC.W $7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C
                DC.W $7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD
                DC.W $7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE

screens:
                END
