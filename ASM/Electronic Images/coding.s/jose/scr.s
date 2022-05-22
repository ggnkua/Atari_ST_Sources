;
; -> This version has sprite background replacement code, using map data to
; restore the background, rather than storing the background!  Oho!
;
; Hyper-smooth 360 degree directional screen scrolling for STE by:
;
; The Phantom of Electronic Images!   Or, Jose M.Commins of The Games Forge!
;
; If a little 'flicker' occurs then it's to do with the bloody one-screen
; scroll; a double buffer as usual solves it!
;
; This version uses screen buffers of only two (two!) screens each, instead of
; the usual four!!  This means, less memory (duuh!), faster updating and none
; of that silly beam-splitting of sprites needed with the one-buffer version!!
; Waheyy!!
;
; Oops!  Little bug fixed...  It needs 21 tiles put across (and now I finally
; get why it needs 14 down too!) since you need one tile extra than the width/
; height of the screen because of the scroll!!  16 pixels extra that are
; visible!!  Aaagggggg!  Oh, I also put in a mouse handler for funkier movement!
;
; Limitations:
; Maximum scroll speed on an axis is 16 pixels per frame.  It CAN be altered,
; but it'll need more tile data to be put (duuuh again!).
; Because of the way it works on the X axis, so as not to use four screen
; buffers, there's a sort-of limit to the amount of screens WIDE it can scroll.
; Extra space must be added below (and, if map position starts in the middle,
; above) the screen memory for the overflow from the X scrolling.  This can
; be calculated by: number of screens wide*one line size in bytes.  So if we
; have a 10 screen wide scroll area on a 320 pixel wide view area, we then add
; 10*160=1600 bytes at the bottom.  If we start in the middle of the map (in
; X coordinate, Y doesn't matter), we add (1600/2) 800 at the top, and 800 at
; the bottom.
; There are no limitations to the Y size of the scroll area!
;
;
                                                                                                                                                                                                                                                                
overx           EQU 16
overy           EQU 208+16      ; +16 pixels extra for 1st screen.

overlength      EQU 4+((overx&%1111111111110000)>>2) ; Over length line width (in words!).
; 4+ for end of scroll area else wrap will write over first screen!
; Not in overlength since this is to do with screen memory not playfield size.
xbytelength     EQU 160+(overlength<<1) ; Actual size of one line in bytes.

xsize           EQU 4           ; Number of screens wide.
ysize           EQU 2           ; Number of screens high.

msize           EQU (xsize*40)*(12*ysize)

mapwidth        EQU (xsize*40)
mapheight       EQU mapwidth*12



blt_s_xinc      EQU $FFFF8A20   ; .W
blt_s_yinc      EQU $FFFF8A22   ; .W
blt_s_addr      EQU $FFFF8A24   ; .L

blt_emask1      EQU $FFFF8A28   ; .W
blt_emask2      EQU $FFFF8A2A   ; .W
blt_emask3      EQU $FFFF8A2C   ; .W

blt_d_xinc      EQU $FFFF8A2E   ; .W
blt_d_yinc      EQU $FFFF8A30   ; .W
blt_d_addr      EQU $FFFF8A32   ; .L

blt_xwords      EQU $FFFF8A36   ; .W
blt_ywords      EQU $FFFF8A38   ; .W

blt_halftone    EQU $FFFF8A3A   ; .B
blt_logical     EQU $FFFF8A38   ; .B

blt_skew        EQU $FFFF8A3D   ; .B

blt_op          EQU $FFFF8A3C   ; .B



;                OPT O+,W-

                clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #1
                adda.l  #6,SP
                move.l  D0,oldsp        * Set supervisor mode

                lea     screen,A0       * My screen!
                move.l  A0,D0           * Store it in D0 for calcs.
                add.l   #256+2560,D0    * Align address to 256 boundary.
                clr.b   D0              * And take off that crummy byte!
                move.l  D0,scrnpos      * Store address.
; 278 line screen.  Actually 280 for MOD 256.

                move.w  #37,-(SP)
                trap    #14
                addq.l  #2,SP
                move.b  #0,$FFFF8260.w  * Sync screen & low resolution.
                move.w  #37,-(SP)
                trap    #14
                addq.l  #2,SP
                move.b  #1,$FFFF8260.w  * Sync screen & low resolution.
                move.w  #37,-(SP)
                trap    #14
                addq.l  #2,SP
                move.b  #0,$FFFF8260.w  * Sync screen & low resolution.

                movea.l scrnpos(PC),A0
                move.w  #(2000*2)-1,D0
                moveq   #0,D1
cls:            move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                dbra    D0,cls

                movem.l pal(PC),D0-D7
                movem.l D0-D7,$FFFF8240.w

                bsr     filltile


                move    #$2700,SR       * Off with all interrupts.

                move.b  $FFFFFA07.w,sa1
                move.b  $FFFFFA09.w,sa2
                move.b  $FFFFFA13.w,sa3
                move.b  $FFFFFA19.w,sa4
                move.b  $FFFFFA1F.w,sa5
                move.b  $FFFFFA21.w,sa6
                move.b  $FFFFFA1B.w,sa7 * Save necessary MFP regs.
                move.b  $FFFFFA15.w,sa8
                move.b  $FFFFFA1D.w,sa9
                move.b  $FFFFFA25.w,sa10
                clr.b   $FFFFFA07.w
                clr.b   $FFFFFA09.w     * Throw out everything!

                bclr    #3,$FFFFFA17.w  * Software End Of Interrupt mode.

                move.l  $70.w,oldvbl
                move.l  #vbl,$70.w      * Save old vbl & install mine.

;                clr.b   $FFFFFA1B.w
;                move.l  $0120.w,oldhbl
;                ori.b   #1,$FFFFFA07.w
;                ori.b   #1,$FFFFFA13.w

;                move.l  $68.w,hsave

;                move.l  $0134.w,asave
;                move.l  #a_int,$0134.w
;                ori.b   #%100000,$FFFFFA07.w
;                ori.b   #%100000,$FFFFFA13.w
;                move.b  #0,$FFFFFA19.w

                move.l  $0118.w,oldkey  * Save old keyboard handler.
                move.l  #khand,$0118.w
                ori.b   #%1000000,$FFFFFA09.w
                ori.b   #%1000000,$FFFFFA15.w * And install mine.

                lea     init(PC),A0
                bsr     ksend           * Enable joysticks & off mouse!

flush2:         btst    #0,$FFFFFC00.w
                beq.s   fl_done2
                move.b  $FFFFFC02.w,D0
                bra.s   flush2
fl_done2:                               * Purge keyboard buffer!
                move.b  #$FF,keybyt

                move.w  xcoord(PC),lastxcoord

                move    #$2300,SR

keyl:
                move.w  lcount(PC),D0
sync:           cmp.w   lcount(PC),D0
                beq.s   sync



                move.w  #$00,$FFFF8240.w

;                bra     moki


moki:
                move.w  xcoord(PC),D0
                bsr     do_x

                move.w  ycoord(PC),D0
                bsr     do_y

                move.w  #20-1,D7

                move.w  #$0750,$FFFF8240.w
poo:


                move.w  xcoord(PC),D0
                move.w  ycoord(PC),D1
                add.l   #160,D0
                add.l   #100,D1
                move.w  D0,D2           ; Copy for later.
                move.w  D1,D3
                bsr     scpos           ; Calculate tile number.
                moveq   #0,D4
                move.w  2(A0),D4        ; Get tile data for tile on right.
                and.w   #%1111111111,D4 ; Only tile data in D4.
                lea     tiles-128(PC),A1
                movea.l A1,A2           ; Copy.
                movea.l A1,A3
                movea.l A1,A4
                asl.l   #7,D1           ; Now set tile data addresses.
                adda.l  D1,A1
                asl.l   #7,D4
                adda.l  D4,A2
                adda.w  #mapwidth,A0    ; Now for tiles below.
                moveq   #0,D0
                moveq   #0,D4
                move.w  (A0),D0
                move.w  2(A0),D4
                and.w   #%1111111111,D0
                and.w   #%1111111111,D4
                asl.l   #7,D0
                adda.l  D0,A3
                asl.l   #7,D4
                adda.l  D4,A4

                move.w  D3,D5           ; Copy Y.
                and.w   #$0F,D5         ; Second size (lines left).
                move.w  #16,D4          ; Size of one tile -1.
                sub.w   D5,D4           ; First size, number of lines to copy.
                move.w  D5,D0           ; Copy.
                asl.w   #3,D0           ; *8 for tile.
                adda.w  D0,A1           ; Add Y coordinate offset to tile.
                adda.w  D0,A2           ; Snap for 2nd tile.
                movea.l scrnpos(PC),A0  ; Screen!
                and.b   #%11110000,D2   ; Get screen X address.
                lsr.w   #1,D2           ; Quick way...
                adda.w  D2,A0           ; Now X address.
                and.b   #%11110000,D3   ; Y modulo to 16 pixels (one tile).
                move.w  D5,D1           ; Copy number of top lines.
                mulu    #xbytelength,D1 ; Y address offset for lines.
                mulu    #xbytelength,D3 ; Raw Y coordinate (to MOD tile's 16).
                add.l   D1,D3           ; Blah.
                adda.l  D3,A0           ; Now Y offset, points to right place!
                move.w  #xbytelength-16,D0
                add.w   D4,D4
                move.w  D4,D1
                add.w   D4,D4
                add.w   D4,D4
                add.w   D1,D4
                neg.w   D4
                lea     tr_jmp1(PC),A5
                jmp     0(A5,D4.w)

                REPT 16
                move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                move.l  (A2)+,(A0)+
                move.l  (A2)+,(A0)+
                adda.w  D0,A0
                ENDR
tr_jmp1:

                add.w   D5,D5
                move.w  D5,D1
                add.w   D5,D5
                add.w   D5,D5
                add.w   D1,D5
                neg.w   D5
                lea     tr_jmp2(PC),A5
                jmp     0(A5,D5.w)

                REPT 16
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+
                move.l  (A4)+,(A0)+
                move.l  (A4)+,(A0)+
                adda.w  D0,A0
                ENDR
tr_jmp2:

                dbra    D7,poo


                clr.w   $FFFF8240.w

                move.w  xcoord(PC),lastxcoord
                move.w  ycoord(PC),lastycoord




;                addq.w  #1,xcoord
;                addq.w  #1,ycoord


;                clr.w   $FFFF8240.w

                move.w  movex(PC),D0
                cmpi.w  #15,D0
                ble.s   mxok1
                move.w  #15,D0
mxok1:          cmp.w   #-15,D0
                bge.s   mxok2
                move.w  #-15,D0
mxok2:
                move.w  movey(PC),D1
                neg.w   D1
                cmpi.w  #15,D1
                ble.s   myok1
                move.w  #15,D1
myok1:          cmp.w   #-15,D1
                bge.s   myok2
                move.w  #-15,D1
myok2:
                add.w   D0,xcoord
                add.w   D1,ycoord

                clr.l   movex           ; Does movey too!


; Check for map <0!!
                tst.w   ycoord
                bge.s   yok
                clr.w   ycoord
yok:

                tst.w   xcoord
                bge.s   xok
                clr.w   xcoord
xok:
                cmpi.w  #200*2,ycoord
                blt.s   yoko2
                move.w  #200*2,ycoord
yoko2:
                cmpi.w  #320*3,xcoord
                blt.s   xok2
                move.w  #320*3,xcoord
xok2:


                move.b  keybyt(PC),D0
                cmpi.b  #57,D0
                bne     keyl


out:            move    #$2700,SR
                move.b  sa1(PC),$FFFFFA07.w
                move.b  sa2(PC),$FFFFFA09.w
                move.b  sa3(PC),$FFFFFA13.w
                move.b  sa4(PC),$FFFFFA19.w
                move.b  sa5(PC),$FFFFFA1F.w
                move.b  sa6(PC),$FFFFFA21.w
                move.b  sa7(PC),$FFFFFA1B.w
                move.b  sa8(PC),$FFFFFA15.w
                move.b  sa9(PC),$FFFFFA1D.w
                move.b  sa10(PC),$FFFFFA25.w
                move.l  oldvbl(PC),$70.w
                move.l  oldkey(PC),$0118.w
;                move.l  oldhbl(PC),$0120.w
;                move.l  hsave(PC),$68.w
;                move.l  asave(PC),$0134.w

                move.w  #0,$FF8240
                move.w  #$0777,$FF8242
                move.w  #$0777,$FF8244
                move.w  #$0777,$FF8246  * 'Clean up' part of palette!

flush:          btst    #0,$FFFFFC00.w
                beq.s   fl_done
                move.b  $FFFFFC02.w,D0
                bra.s   flush
fl_done:
                move    #$2300,SR


                move.l  oldsp(PC),-(SP)
                move.w  #$20,-(SP)
                trap    #1
                adda.l  #6,SP           * Old mode (user usually!).

                clr.w   -(SP)
                trap    #1              * Terminate process. Agggg!


;---------------------------------------

                >PART 'L/R map tile copying routines'

;
; Do LEFT or RIGHT tiles.
;
do_x:
                cmp.w   lastxcoord(PC),D0 ; Check which direction to do!
                blt.s   doleft

; Calculate right tiles if we're going right.
                add.w   #319,D0         ; Look ahead 1 screen.
                move.w  ycoord(PC),D1
                moveq   #0,D2
                moveq   #0,D3
                move.w  D0,D2
                move.w  D1,D3

; Screen X offset (no modulo!).
                and.b   #%11110000,D2   ; Get chunk offset.
                lsr.w   #1,D2           ; /2 for screen (16 pixels = 8 bytes).

                movea.l scrnpos(PC),A4  ; Get screen pos.
                adda.w  D2,A4           ; Add X offset.
                adda.l  #(overy*xbytelength)+((16*xbytelength)*14),A4
; Add over screen size + number of tiles put.

                divu    #overy,D3       ; Modulo screen height.
                clr.w   D3
                swap    D3
                and.b   #%11110000,D3
                mulu    #xbytelength,D3 ; Times line length.

                add.l   D3,D2           ; Total screen offset.


                and.b   #%11110000,D0   ; 16 pixel chunks for X.
                lsr.w   #3,D0           ; Offset into map table (2 bytes per tile).
                and.b   #%11110000,D1   ; 16 pixel chunks for Y too.
                lsr.w   #4,D1           ; This time we reduce it to 1 byte.
                mulu    #mapwidth,D1    ; Then multiply Y width.
                add.w   D1,D0           ; And add to total map.
                lea     map(PC),A0      ; Get map position.
                adda.l  mapx(PC),A0     ; Add map X position.
                adda.l  mapy(PC),A0     ; Add map Y position.
                lea     0(A0,D0.w),A0   ; Get tile data.

                movea.l scrnpos(PC),A2  ; Get screen position.
                adda.l  D2,A2           ; Add screen offset.
                movea.l A2,A3           ; Copy to 2nd tile copy.
                adda.l  #(16*xbytelength)*14,A3 ; 2nd tiles copied below curr.

                bra.s   putxtiles

doleft:
; Calculate left tiles if we're going left.
                move.w  ycoord(PC),D1
                moveq   #0,D2
                moveq   #0,D3
                move.w  D0,D2
                move.w  D1,D3

; Screen X offset (no modulo!).
                and.b   #%11110000,D2   ; Get chunk offset.
                lsr.w   #1,D2           ; /2 for screen (16 pixels = 8 bytes).

                movea.l scrnpos(PC),A4  ; Get screen pos.
                adda.w  D2,A4           ; Add X offset.
                adda.l  #(overy*xbytelength)+((16*xbytelength)*14),A4
; Add over screen size + number of tiles put.

                divu    #overy,D3       ; Modulo screen height.
                clr.w   D3
                swap    D3
                and.b   #%11110000,D3
                mulu    #xbytelength,D3 ; Times line width.

                add.l   D3,D2           ; Total screen offset.


                and.b   #%11110000,D0   ; 16 pixel chunks for X.
                lsr.w   #3,D0           ; Offset into map table (2 bytes per tile).
                and.b   #%11110000,D1   ; 16 pixel chunks for Y too.
                lsr.w   #4,D1           ; This time we reduce it to 1 byte.
                mulu    #mapwidth,D1    ; Then multiply Y width.
                add.w   D1,D0           ; And add to total map.
                lea     map(PC),A0      ; Get map position.
                adda.l  mapx(PC),A0     ; Add map X position.
                adda.l  mapy(PC),A0     ; Add map Y position.
                lea     0(A0,D0.w),A0   ; Get tile data.

                movea.l scrnpos(PC),A2  ; Get screen position.
                adda.l  D2,A2           ; Add screen offset.
                movea.l A2,A3           ; Copy to 2nd tile copy.
                adda.l  #(16*xbytelength)*14,A3 ; 2nd tiles copied below curr.

;
; Now we shove that data as fast as possible, using multiple MOVEM's!  Aharrr!
putxtiles:
                moveq   #14-1,D7        ; 14 tiles 208+(16 scroll) pixels.
hitiles:
                move.l  #%1111111111,D0 ; Only use tile data.
                and.w   (A0),D0         ; Get map data.
                lsl.l   #7,D0           ; * 128.
                lea     tiles-128(PC),A1 ; Tile data.
                adda.l  D0,A1           ; Now points to tile!
xcoff           SET 0
                REPT 4          ; Can do 4 lines at a time...
                movem.l (A1)+,D0-D6/A5  ; Get as much as poss!

                move.l  D0,xcoff(A2)    ; Copy.
                move.l  D1,xcoff+4(A2)
                move.l  D2,xcoff+xbytelength(A2)
                move.l  D3,xcoff+xbytelength+4(A2)
                move.l  D4,xcoff+(xbytelength*2)(A2)
                move.l  D5,xcoff+(xbytelength*2)+4(A2)
                move.l  D6,xcoff+(xbytelength*3)(A2)
                move.l  A5,xcoff+(xbytelength*3)+4(A2)

                move.l  D0,xcoff(A3)    ; Now use same regs for copy!
                move.l  D1,xcoff+4(A3)
                move.l  D2,xcoff+xbytelength(A3)
                move.l  D3,xcoff+xbytelength+4(A3)
                move.l  D4,xcoff+(xbytelength*2)(A3)
                move.l  D5,xcoff+(xbytelength*2)+4(A3)
                move.l  D6,xcoff+(xbytelength*3)(A3)
                move.l  A5,xcoff+(xbytelength*3)+4(A3)

xcoff           SET xcoff+(xbytelength*4)
                ENDR

                lea     xbytelength*16(A2),A2 ; Inc screen.
                lea     xbytelength*16(A3),A3

                cmpa.l  A4,A3           ; Has 2nd tile copy reached bottom?
                blt.s   no_x_wrap       ; No, skip.
                movea.l A2,A3           ; Yes, re-set pointer.
                suba.l  #(16*xbytelength)*14,A3 ; To top of current workscreen.
;                move.w  #$0300,$FFFF8240.w
;                bra.s   cont_wrap
no_x_wrap:
;                eori.w  #$30,$FFFF8240.w
;cont_wrap:

                adda.l  #mapwidth,A0    ; Add width of map for next tile.

                dbra    D7,hitiles

                rts

                ENDPART

;--------------------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

                >PART 'U/D map tile copying routines'

;
; Do TOP or BOTTOM tiles.
;
do_y:
                cmp.w   lastycoord(PC),D0 ; Check which direction to do!
                blt.s   doup

; Calculate bottom tiles if we're going down.
                move.w  xcoord(PC),D0
                move.w  ycoord(PC),D1
                add.w   #207,D1         ; Look ahead 1 screen.
                moveq   #0,D2
                moveq   #0,D3
                move.w  D0,D2
                move.w  D1,D3

                add.l   #16,D3          ; For Mod320=0 = Mod336=0 a +16 adjust.
                divu    #overy,D3       ; Modulo screen height.
                clr.w   D3
                swap    D3
                and.w   #%1111111111110000,D3
                mulu    #xbytelength,D3 ; Times line length.

; Screen X offset (no modulo!).
                and.w   #%1111111111110000,D2 ; Get chunk offset.
                lsr.w   #1,D2           ; /2 for screen (16 pixels = 8 bytes).
                add.l   D2,D3           ; Total screen offset.


                and.b   #%11110000,D0   ; 16 pixel chunks for X.
                lsr.w   #3,D0           ; Offset into map table (2 bytes per tile).
                and.b   #%11110000,D1   ; 16 pixel chunks for Y too.
                lsr.w   #4,D1           ; This time we reduce it to 1 byte.
                mulu    #mapwidth,D1    ; Then multiply Y width.
                add.w   D1,D0           ; And add to total map.
                lea     map(PC),A0      ; Get map position.
                adda.l  mapx(PC),A0     ; Add map X position.
                adda.l  mapy(PC),A0     ; Add map Y position.
                lea     0(A0,D0.w),A0   ; Get tile data.

                movea.l scrnpos(PC),A2  ; ...
                adda.l  D3,A2
                lea     -xbytelength*16(A2),A3 ; We put 2nd copy above screen.
                adda.l  #xbytelength*208,A2 ; Original tiles at bottom.

                bra.s   putytiles

doup:
; Calculate top tiles if we're going up.
                move.w  xcoord(PC),D0
                move.w  ycoord(PC),D1
                moveq   #0,D2
                moveq   #0,D3
                move.w  D0,D2
                move.w  D1,D3

                divu    #overy,D3       ; Modulo screen height.
                clr.w   D3
                swap    D3
                and.w   #%1111111111110000,D3
                mulu    #xbytelength,D3 ; Times line length.

; Screen X offset (no modulo!).
                and.w   #%1111111111110000,D2 ; Get chunk offset.
                lsr.w   #1,D2           ; /2 for screen (16 pixels = 8 bytes).
                add.l   D2,D3           ; Total screen offset.


                and.b   #%11110000,D0   ; 16 pixel chunks for X.
                lsr.w   #3,D0           ; Offset into map table (2 bytes per tile).
                and.b   #%11110000,D1   ; 16 pixel chunks for Y too.
                lsr.w   #4,D1           ; This time we reduce it to 1 byte.
                mulu    #mapwidth,D1    ; Then multiply Y width.
                add.w   D1,D0           ; And add to total map.
                lea     map(PC),A0      ; Get map position.
                adda.l  mapx(PC),A0     ; Add map X position.
                adda.l  mapy(PC),A0     ; Add map Y position.
                lea     0(A0,D0.w),A0   ; Get tile data.

                movea.l scrnpos(PC),A2
                adda.l  D3,A2
                movea.l A2,A3           ; We put at top of screen.
                adda.l  #xbytelength*(208+16),A3 ; 2nd tile copy below screen.

; Copy tiles to screen, as quick as possible using 2 copies of MOVEM's.
putytiles:
                moveq   #21-1,D7        ; 21 tiles 320+(16 scroll) pixels.
vitiles:
                move.l  #%1111111111,D0 ; Only use tile data.
                and.w   (A0)+,D0        ; Get map data and move along.
                lsl.l   #7,D0           ; * 128.
                lea     tiles-128(PC),A1 ; Saves a -1.
                adda.l  D0,A1           ; Now points to tile data.
xcoff           SET 0
                REPT 4
                movem.l (A1)+,D0-D6/A5

                move.l  D0,xcoff(A2)
                move.l  D1,xcoff+4(A2)
                move.l  D2,xcoff+xbytelength(A2)
                move.l  D3,xcoff+xbytelength+4(A2)
                move.l  D4,xcoff+(xbytelength*2)(A2)
                move.l  D5,xcoff+(xbytelength*2)+4(A2)
                move.l  D6,xcoff+(xbytelength*3)(A2)
                move.l  A5,xcoff+(xbytelength*3)+4(A2)

                move.l  D0,xcoff(A3)
                move.l  D1,xcoff+4(A3)
                move.l  D2,xcoff+xbytelength(A3)
                move.l  D3,xcoff+xbytelength+4(A3)
                move.l  D4,xcoff+(xbytelength*2)(A3)
                move.l  D5,xcoff+(xbytelength*2)+4(A3)
                move.l  D6,xcoff+(xbytelength*3)(A3)
                move.l  A5,xcoff+(xbytelength*3)+4(A3)

xcoff           SET xcoff+(xbytelength*4)
                ENDR
                addq.w  #8,A2
                adda.w  #8,A3
; No need to alter map pointer, since on Y it's contiguous (a (An)+ will do!).

                dbra    D7,vitiles

                rts

                ENDPART

;----------------------------------------------
;**********************************************

;----------------------- SUBROUTINES
; Get tile number at map coords.
; Fill screen with tiles.

                >PART 'Subroutines'

; GET TILE NUMBER/FLAGS AT POSITION  D0=X D1=Y.
; Returns with flags in D0 and tile number in D1.
; Flags are 'brought down' from their higher bit position.
; Trashes A0.
scpos:
                and.b   #%11110000,D0   ; 16 pixel chunks for X.
                lsr.w   #3,D0           ; Offset into map table (2 bytes per tile).
                and.b   #%11110000,D1   ; 16 pixel chunks for Y too.
                lsr.w   #4,D1           ; This time we reduce it to 1 byte.
                mulu    #mapwidth,D1    ; Then multiply Y width.
                add.w   D1,D0           ; And add to total map.
                lea     map(PC),A0      ; Get map position.
                adda.l  mapx(PC),A0     ; Add map X position.
                adda.l  mapy(PC),A0     ; Add map Y position.
                adda.w  D0,A0           ; Now point to map.
                moveq   #0,D1           ; Upper word clear for tile shift later.
                move.w  (A0),D0         ; Get tile data.
                move.w  D0,D1           ; Copy.
                and.w   #%1111110000000000,D0 ; Only flag data in D0.
                rol.w   #6,D0           ; Bring it down to bottom bits.
                and.w   #%1111111111,D1 ; Only tile data in D1.
                rts


***** Fill screen with tiles...
filltile:
                movem.l D0-D3/A0-A4,-(SP)
                movea.l scrnpos(PC),A0
                lea     map,A1
                adda.l  mapx(PC),A1
                adda.l  mapy(PC),A1
                movea.l A1,A4
                moveq   #7,D3
                moveq   #13-1,D2
rows:           moveq   #20-1,D1
                movea.l A4,A1
cols:           move.w  (A1)+,D0
                and.w   #1023,D0
                lsl.w   D3,D0           ; Took out SUBQ #1,d0
                lea     tiles-128,A3    ; For this!
                adda.w  D0,A3
scoffg          SET 0
                REPT 4
                move.l  (A3)+,scoffg(A0)
                move.l  (A3)+,scoffg+4(A0)
                move.l  (A3)+,scoffg+xbytelength(A0)
                move.l  (A3)+,scoffg+xbytelength+4(A0)
                move.l  (A3)+,scoffg+(xbytelength*2)(A0)
                move.l  (A3)+,scoffg+(xbytelength*2)+4(A0)
                move.l  (A3)+,scoffg+(xbytelength*3)(A0)
                move.l  (A3)+,scoffg+(xbytelength*3)+4(A0)
scoffg          SET scoffg+(xbytelength*4)
                ENDR
                addq.w  #8,A0
                dbra    D1,cols
                adda.w  #mapwidth,A4
                lea     (xbytelength*16)-160(A0),A0
                dbra    D2,rows
                movem.l (SP)+,D0-D3/A0-A4
                rts

                ENDPART


******** VERTICAL BLANK INTERUPT

vbl:
                movem.l D0-A6,-(SP)

                move.l  scrnpos(PC),scrntemp ; Copy screenbase.

                moveq   #0,D1           ; Make sure its clear
                move.w  xcoord(PC),D1   ; Get X coordinate.
                move.w  D1,D2           ; Copy for pixel offset.

;                divu    #overx,D1       ; Modulo screen line length.
;                clr.w   D1
;                swap    D1
                and.w   #%1111111111110000,D1 ; Get chunk offset.
                lsr.w   #1,D1           ; /2 for screen (16 pixels = 8 bytes).

                moveq   #0,D0           ; Make it clear!
                move.w  ycoord(PC),D0   ; Get Y coordinate.
                divu    #overy,D0       ; Modulo screen height (yikes!).
                clr.w   D0
                swap    D0
                mulu    #160+(overlength*2),D0 ; And * size of line.
                add.l   D0,D1           ; Add to total screen offset.

                add.l   D1,scrntemp     ; Add to screen pointer.

                move.l  scrntemp(PC),D1 ; Copy to old hardware..!
                lsr.w   #8,D1
                move.l  D1,$FFFF8200.w
                move.b  scrntemp+1(PC),$FFFF8205.w ; STE's hardware...
                move.b  scrntemp+2(PC),$FFFF8207.w
                move.b  scrntemp+3(PC),$FFFF8209.w

                move.w  #overlength,D1  ; Ever over line length.
                and.w   #$0F,D2         ; Get pixel offset.
                beq.s   nooveradj       ; Don't adjust if we're at 0.
                subq.w  #4,D1           ; Else - 1 chunk for this rez.
nooveradj:
                move.b  D2,$FFFF8265.w  ; Store pixel offset.
                move.b  D1,$FFFF820F.w  ; Store over line width.


;                move.b  #0,$FFFFFA19.w
;                move.l  #a_int,$0134.w
;                move.b  #99,$FFFFFA1F.w
;                move.b  #4,$FFFFFA19.w

;                clr.b   $FFFFFA1B.w
;                move.l  #hbl,$0120.w
;                move.b  #227,$FFFFFA21.w
;                move.b  #8,$FFFFFA1B.w

                addq.w  #1,lcount

                movem.l (SP)+,D0-A6

                rte



; Timer A and HBL interrupts.
a_int:          move.b  #0,$FFFFFA19.w
                move.l  #remtop1,$68.w
                stop    #$2100
                rte

remtop1:        move.l  #shite,$68.w
                stop    #$2100
                rte
shite:          move    #$2700,SR
                move.l  #caan,$68.w
                move.w  D0,-(SP)
                move.w  #22,D0
wait:           dbra    D0,wait
                move.b  #0,$FF820A
                REPT 24
                nop
                ENDR
                move.b  #2,$FF820A
                move.w  (SP)+,D0
caan:           rte


hbl:            clr.b   $FFFFFA1B.w
                move.l  #hbl2,$0120.w
                move.b  #1,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                stop    #$2500
                rte
hbl2:           move.l  #hsht,$0120.w
                move    #$2700,SR
                move.l  D0,-(SP)
                moveq   #$24,D0
wsix:           dbra    D0,wsix
                move.b  #0,$FF820A
                moveq   #2,D0
wfif:           dbra    D0,wfif
                move.b  #2,$FF820A
                move.l  (SP)+,D0
hsht:           clr.b   $FFFFFA1B.w
                rte



                >PART 'Keyboard interrupts etc'

******** KEYBOARD HANDLER INTERRUPT - New, faster version!

khand:          move.w  D0,-(SP)        * Save D0.
                clr.w   D0
                move.b  $FFFFFC02.w,D0  * Get byte from keyboard.
                cmpi.w  #247,D0         * Izzit a mouse package?
                ble.s   nomous          * No... Get key value.
                move.b  D0,button
                move.l  #khand2,$0118.w * Install another (get mouse pack).
                move.w  (SP)+,D0
                rte
nomous:         move.b  D0,keybyt       * Put byte for key read.
                move.w  (SP)+,D0        * Restore D0.
                rte                     * Return.

khand2:         move.w  D0,-(SP)
                move.b  $FFFFFC02.w,D0  * Get byte from keyboard - X coord.
                ext.w   D0
                add.w   D0,movex
                move.w  (SP)+,D0
                move.l  #khand3,$0118.w * Low byte...
                rte                     * Return.

khand3:         move.w  D0,-(SP)
                move.b  $FFFFFC02.w,D0  * Get byte from keyboard - X coord.
                ext.w   D0
                sub.w   D0,movey
                move.w  (SP)+,D0
                move.l  #khand,$0118.w  * Y bytes.
                rte                     * Return.


ksend:          move.b  (A0)+,D0        * Number of bytes to send.
notrdy:         btst    #1,$FFFFFC00.w
                beq.s   notrdy          * Wait for keyboard ready.
                move.b  (A0)+,$FFFFFC02.w * Aha! Got you! Here! Take this!
                subq.b  #1,D0
                bne.s   notrdy          * Repeat for number of bytes.
                rts                     * Return from this routine.


init:           DC.B 2
                DC.B $08,$1A    * Mouse on & Joystick off.
krestr:         DC.B 2
                DC.B $08,$1A    * Mouse on & Joystick off.

button:         DS.B 1
keybyt:         DS.B 1          * If keypress, byte stored here.

                EVEN

                ENDPART




oldvbl:         DS.L 1          * Old VBL vector.
oldhbl:         DS.L 1
oldkey:         DS.L 1
hsave:          DS.L 1
asave:          DS.L 1
oldsp:          DS.L 1          * Old stack pointer address.
scrnpos:        DS.L 1          * Address of screen 1.

scrntemp:       DS.L 1

movex:          DC.W 0
movey:          DC.W 0

xcoord:         DC.W 0
ycoord:         DC.W 0

lastxcoord:     DC.W 0
lastycoord:     DC.W 0

mapx:           DC.L 0
mapy:           DC.L 0

lcount:         DS.W 1

sa1:            DS.B 1
sa2:            DS.B 1
sa3:            DS.B 1
sa4:            DS.B 1
sa5:            DS.B 1
sa6:            DS.B 1
sa7:            DS.B 1          * MFP register save space.
sa8:            DS.B 1
sa9:            DS.B 1
sa10:           DS.B 1

                EVEN

pal:
                IBYTES 'F:\TRNTILES.PAL'
;                DC.W $00,$04,$0114,$0324,$0534,$0756,$0653,$0754
;                DC.W $0700,$0750,$0670,$70,$56,$0137,$0607,$0777

map:
;                REPT 2
                IBYTES 'F:\TESTMAP.MAP'
;                ENDR
tiles:          IBYTES 'F:\TRNTILES.FE4'

screen:

                END
