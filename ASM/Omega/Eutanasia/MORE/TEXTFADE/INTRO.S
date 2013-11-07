; *************************************
; ** EUTANASIA "INTRO"
; ** By Martin Liesen 1991
; *************************************
                OPT P-
                >PART 'CALL SUPER PART'
                pea     begin(PC)
                move.w  #38,-(A7)
                trap    #14
                addq.l  #6,A7
                rts
                ENDPART
begin:          >PART 'SAVE REGISTERS'
****************************************
**   S A V E    R E G I S T E R S
****************************************
                lea     _SaveTab(PC),A6
                move.l  A7,(A6)+
                move.l  $00000070.w,(A6)+
                move.l  $00000120.w,(A6)+
                move.b  $FFFFFA07.w,(A6)+
                move.b  $FFFFFA09.w,(A6)+
                move.b  $FFFFFA0F.w,(A6)+
                move.b  $FFFFFA11.w,(A6)+
                move.b  $FFFFFA13.w,(A6)+
                move.b  $FFFFFA15.w,(A6)+
                move.l  $00000068.w,(A6)+
                move.l  $00000070.w,(A6)+
                move.l  $00000118.w,(A6)+
                move.l  $00000120.w,(A6)+
                move.w  #4,-(A7)
                trap    #14
                move.w  D0,(A6)+
                move.w  #2,-(A7)
                trap    #14
                move.l  D0,(A6)+
                movem.l $FFFF8240.w,D0-D7
                movem.l D0-D7,(A6)
                lea     32(A6),A6
                bra.s   startup
                ENDPART
back:           >PART 'RESTORE AND RTS'
******************************************
*** R E S T O R E   E V E R Y T H I N G
******************************************
                move    #$2700,SR
                lea     _SaveTab(PC),A6
                movea.l (A6)+,A7
                move.l  (A6)+,$00000070.w
                move.l  (A6)+,$00000120.w
                move.b  (A6)+,$FFFFFA07.w
                move.b  (A6)+,$FFFFFA09.w
                move.b  (A6)+,$FFFFFA0F.w
                move.b  (A6)+,$FFFFFA11.w
                move.b  (A6)+,$FFFFFA13.w
                move.b  (A6)+,$FFFFFA15.w
                move.l  (A6)+,$00000068.w
                move.l  (A6)+,$00000070.w
                move.l  (A6)+,$00000118.w
                move.l  (A6)+,$00000120.w
                move.w  (A6)+,-(A7)
                move.l  (A6),-(A7)
                move.l  (A6)+,-(A7)
                move.w  #5,-(A7)
                trap    #14
                lea     12(A7),A7
                movem.l (A6)+,D0-D7
                movem.l D0-D7,$FFFF8240.w
                rts
                ENDPART

startup:        >PART 'Init'

s:              lea     s(PC),A6
                move    #$2700,SR
                lea     Vbl(PC),A0
                move.l  A0,$00000070.w
                lea     TimerB(PC),A0
                move.l  A0,$00000120.w
                move.b  #0,$FFFFFA07.w
                move.b  #0,$FFFFFA09.w
                move.b  #0,$FFFFFA13.w
                move.b  #0,$FFFFFA15.w
                move.b  #1,$FFFFFA13.w
                move.b  #1,$FFFFFA07.w
                move    #$2300,SR

                move.b  #0,$FFFF8260.w
                bsr     Vsync
                move.b  #0,$FFFF820A.w
                bsr     Vsync
                bsr     Vsync
                move.b  #2,$FFFF820A.w
                ENDPART
                move.w  #2,-(A7)
                trap    #14
                move.l  D0,_Screen-s(A6)

                PART 'Main Loop'


.NextCommand:   movea.l _SeqPek(PC),A5
                move.w  (A5)+,D7
                move.w  (A5)+,D6
                move.l  A5,_SeqPek-s(A6)
                cmp.w   #$0004,D7
                bhi.s   .Skriv

                cmp.w   #1,D7
                bne.s   .NotWait
                subq.w  #1,D6               ; Wait
                bmi.s   .NextCommand
.Waiting:       bsr     Vsync
                dbra    D6,.Waiting
                bra.s   .NextCommand

.NotWait:       cmp.w   #2,D7
                bne.s   .NotFadeGOut
                bra     back


.NotFadeGOut:   cmp.w   #3,D7
                bne.s   .NotFadeTextIn
                lea     _BlackPal(PC),A0    ; Fade In
                lea     _LightPal(PC),A1
                move.w  D6,D0
                bsr     FadeInit
                subq.w  #1,D6
.Fading1:       bsr     Vsync
                lea     $FFFF8240.w,A0
                bsr     FadeIrq
                dbra    D6,.Fading1
                bra.s   .NextCommand

.NotFadeTextIn: cmp.w   #4,D7
                bne.s   .NotFadeTextOut     ; Fade Out
                lea     _BlackPal(PC),A1
                lea     _LightPal(PC),A0
                move.w  D6,D0
                bsr     FadeInit
                subq.w  #1,D6
.Fading2:       bsr     Vsync
                lea     $FFFF8240.w,A0
                bsr     FadeIrq
                dbra    D6,.Fading2
                bra.s   .NextCommand

.NotFadeTextOut:
                bra     .NextCommand

.Skriv:         lea     0(A6,D7.w),A0
                movea.l _Screen(PC),A5
                bsr     Print
                bra     .NextCommand


                ENDPART
_Screen:        DS.L 1
_SeqPek:        DC.L _Seq

_BlackPal:      DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
_LightPal:      DC.W 0,$0FFF,0,0,0,0,0,0,0,0,0,0,0,0,0,0

* 0 Fade out game, speed
* 1 Wait , speed
* 2 Fade in game, speed
* 3 Fade in text
* 4 Fade out text
* 5 Back to game

_Seq:
                DC.W 4,5
                DC.W Text1-s,50
                DC.W 3,40
                DC.W 1,50
                DC.W 4,40
                DC.W Text2-s,50
                DC.W 3,40
                DC.W 1,50
                DC.W 4,40
                DC.W Text3-s,50
                DC.W 3,40
                DC.W 1,75
                DC.W 4,40
                DC.W Text4-s,50
                DC.W 3,40
                DC.W 1,25
                DC.W 4,40
                DC.W Text5-s,50
                DC.W 1,10
                DC.W 3,40
                DC.W 1,75
                DC.W 4,40


                DC.W 2,50

Text1:          >PART 'Text1'
                DC.B 1
                EVEN
                DC.W 160
                DC.B 6
                DC.B 5
                EVEN
                DC.L _Font
                DC.B 3
                EVEN
                DC.W 67
                DC.B "Expose",0
                DC.B 3
                EVEN
                DC.W 133
                DC.B "Software",0
                DC.B -1
                EVEN
                ENDPART
Text2:          >PART 'Text2'
                DC.B 6
                DC.B 3
                EVEN
                DC.W 100
                DC.B "Presents",0
                DC.B -1
                EVEN
                ENDPART
Text3:          >PART 'Text3'
                DC.B 6
                DC.B 3
                EVEN
                DC.W 40
                DC.B "A",0
                EVEN
                DC.B 3
                EVEN
                DC.W 80
                DC.B "Synchron",0
                DC.B 3
                EVEN
                DC.W 120
                DC.B "Assembly",0
                EVEN
                DC.B 3
                EVEN
                DC.W 160
                DC.B "Product",0
                DC.B -1
                EVEN
                ENDPART
Text4:          >PART 'Text4'
                DC.B 6
                DC.B 3
                EVEN
                DC.W 100
                DC.B "Called",0
                DC.B -1
                EVEN
                ENDPART
Text5:          >PART 'Text5'
                DC.B 6
                DC.B 3
                EVEN
                DC.W 100
                DC.B "Eutanasia",0
                DC.B -1
                EVEN
                ENDPART


Vsync:          >PART 'Vsync'
                tst.w   _VblFlag-s(A6)
                beq.s   Vsync
                clr.w   _VblFlag-s(A6)
                rts
                ENDPART
TimerB:         >PART 'Raster Irq'
*                eori.w  #$0630,$FFFF8240.w
                bclr    #0,$FFFFFA0F.w
                rte
                ENDPART
Vbl:            >PART 'VBL Irq'
                addq.w  #1,_VblFlag-s(A6)
                cmpi.b  #$39,$FFFFFC02.w
                beq     back
                clr.w   $FFFF8240.w
                clr.b   $FFFFFA1B.w
                move.b  #1,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w

                rte
                ENDPART

****************************************
Print:          >PART 'Print A0 at A5'
p:
* a0=Address to string
* a5=Address to Screen to drawe on (way to draw depends on PRINTONECHAR rout)
                movem.l D0-A6,-(A7)
                lea     p(PC),A6
                move.w  _Controler(PC),D0
                jsr     0(A6,D0.w)
                movem.l (A7)+,D0-A6
                rts
                ENDPART
Controler:      >PART 'Control commands'

.ControlLoop:   cmpi.b  #-1,(A0)
                beq     .EndMark
                cmpi.b  #31,(A0)
                bhi.s   .StringStart

                move.b  (A0)+,D0
                beq.s   .ControlLoop
                cmp.b   #1,D0
                bne.s   .NotSetMidX
                clr.w   _MidXMode-p(A6)     ; 1
                bsr.s   .MakeEven
                move.w  (A0)+,_XPoint-p(A6)
                bra.s   .ControlLoop
.NotSetMidX:    cmp.b   #2,D0
                bne.s   .NotSetFixX
                move.w  #-1,_MidXMode-p(A6) ; 2
                bsr.s   .MakeEven
                move.w  (A0)+,_XPoint-p(A6)
                bra.s   .ControlLoop
.NotSetFixX:    cmp.b   #3,D0
                bne.s   .NotSetMidY
                clr.w   _MidYMode-p(A6)     ; 3
                bsr.s   .MakeEven
                move.w  (A0)+,_YPoint-p(A6)
                bra.s   .ControlLoop
.NotSetMidY:    cmp.b   #4,D0
                bne.s   .NotSetFixY
                move.w  #-1,_MidYMode-p(A6) ; 4
                bsr.s   .MakeEven
                move.w  (A0)+,_YPoint-p(A6)
                bra.s   .ControlLoop
.NotSetFixY:    cmp.b   #5,D0
                bne.s   .NotSetFont
                bsr.s   .MakeEven
                move.l  (A0)+,_FontAddr-p(A6)
                bra.s   .ControlLoop
.NotSetFont:    cmp.b   #6,D0
                bne.s   .NotCLS
                move.w  _ClrScreen(PC),D0
                jsr     0(A6,D0.w)
                bra.s   .ControlLoop
.NotCLS:
                bra.s   .ControlLoop

*********************
.StringStart:   move.w  _StringControl(PC),D0
                jsr     0(A6,D0.w)
                bra     .ControlLoop

.EndMark:       rts

*********************
.MakeEven:      move.l  D0,-(A7)            ; Make A0 Even
                move.l  A0,D0
                btst    #0,D0
                beq.s   .VeryEven
                addq.l  #1,A0
.VeryEven:      move.l  (A7)+,D0
                rts
*********************
                ENDPART
StringC:        >PART 'Control String'
*      A0=Address to string  (Until a zero, only TRUE CHARS handled here!)
*      A5=Address to screen
*      A6=Address to start
* out: A0 should point at the byte after the null
* other:  Should call PrintOneChar for output

*      A4=Address to font!

                movem.l D0-D7/A1-A6,-(A7)
                movea.l _FontAddr(PC),A4

                move.w  _YPoint(PC),_RealY-p(A6)
                tst.w   _MidYMode-p(A6)
                bmi.s   .YDone
                move.w  2(A4),D0
                sub.w   D0,_RealY-p(A6)
.YDone:
                move.w  _XPoint(PC),_RealX-p(A6)
                tst.w   _MidXMode-p(A6)
                bmi.s   .XDone
                bsr.s   CalcWholeW
                lsr.l   #1,D0
                sub.w   D0,_RealX-p(A6)
.XDone:

.NextChar:      moveq   #0,D0               ; Get Next Char
                move.b  (A0)+,D0
                beq.s   .StringSlut

                move.w  _RealX(PC),D5       ; get X,Y & Width
                move.w  _RealY(PC),D6
                moveq   #0,D7
                move.w  34(A4),D1
                lea     0(A4,D1.w),A3
                move.b  0(A3,D0.w),D7

                move.w  D7,D1               ; Inc for Next char
                add.w   4(A4),D1
                add.w   D1,_RealX-p(A6)

                move.w  36(A4),D1           ; Get char IMAGE data addr
                lea     0(A4,D1.w),A3
                move.w  #-1,D1
.Search:        addq.w  #1,D1
                cmpi.b  #-1,(A3)
                beq.s   .No_Draw
                cmp.b   (A3)+,D0
                bne.s   .Search
                ext.w   D1

                move.w  32(A4),D0
                lea     0(A4,D0.w),A3

                mulu    4(A4),D1
                add.w   D1,D1
                mulu    (A4),D1
                adda.w  D1,A3


                move.w  _PrintRout(PC),D0
                jsr     0(A6,D0.w)

.No_Draw:
                bra.s   .NextChar


.StringSlut:    movem.l (A7)+,D0-D7/A1-A6
                rts

CalcWholeW:
* a4=Font
* a6=start
* out d0=Width
                movem.l D1-A6,-(A7)
                move.w  34(A4),D0
                lea     0(A4,D0.w),A3
                moveq   #0,D0
.CalcN:         move.b  (A0)+,D1
                beq.s   .CalcD
                ext.w   D1
                moveq   #0,D2
                move.b  0(A3,D1.w),D2
                add.w   D2,D0
                add.w   8(A4),D0
                bra.s   .CalcN
.CalcD:         sub.w   8(A4),D0
                ext.l   D0
                movem.l (A7)+,D1-A6
                rts

_RealX:         DS.W 1
_RealY:         DS.W 1
                ENDPART
PrintOneChar:   >PART 'Print One Character'
*      A3=Address to characters IMAGE data
*      A4=Address to font header
*      A5=Address to screen
*      A6=Address to start
*      D5=True X (upper left corner)
*      D6=True Y (upper left corner)
*      D7=Width
* out: Nothing!
                movem.l D0-A6,-(A7)
                mulu    #160,D6
                move.w  D5,D0
                and.w   #$000F,D5
                sub.w   D5,D0
                asr.w   #1,D0
                add.w   D0,D6
                adda.w  D6,A5

                move.w  4(A4),D7
                subq.w  #1,D7

                move.w  (A4),D4
                subq.w  #1,D4

.LoopY:         movea.l A5,A0
                lea     160(A5),A5
                move.w  D7,D6

                moveq   #0,D0
                move.w  (A3),D0
                ror.l   D5,D0
                or.w    D0,(A0)

.LoopX:         addq.l  #8,A0
                subq.w  #1,D6
                bmi.s   .RadSlut
                move.l  (A3),D0
                ror.l   D5,D0
                or.w    D0,(A0)
                addq.l  #2,A3
                bra.s   .LoopX

.RadSlut:
                move.l  (A3),D0
                clr.w   D0
                ror.l   D5,D0
                or.w    D0,(A0)
                addq.l  #2,A3




                dbra    D4,.LoopY

                movem.l (A7)+,D0-A6
                rts
                ENDPART
ClearScreen:    >PART 'Clear the screen'
                movem.l D0/A5,-(A7)
                move.w  #1999,D0
.Clearing:      clr.l   (A5)+
                clr.l   (A5)+
                clr.l   (A5)+
                clr.l   (A5)+
                dbra    D0,.Clearing
                movem.l (A7)+,D0/A5
                rts
                ENDPART
****************************************
                >PART 'Print Data'

_ClrScreen:     DC.W ClearScreen-p          ; Offset to Clear Screen Rout
_PrintRout:     DC.W PrintOneChar-p         ; Offset to PrintOneChar routine
_Controler:     DC.W Controler-p            ; Offset to the controler
_StringControl: DC.W StringC-p              ; Offset to the String controler

_FontAddr:      DS.L 1                      ; Address to font header
_MidXMode:      DS.W 1                      ; 0=Mid Point, -1=Fixed point
_MidYMode:      DS.W 1                      ; 0=Mid Point, -1=Fixed point
_XPoint:        DS.W 1                      ; Mid/Fix point X
_YPoint:        DS.W 1                      ; Mid/Fix point Y

                ENDPART
                >PART 'DOC'
* The font can have different widths of all characters, but they are
* all saved with the same with in the font (even by 16 witdh).
* All characters must be LEFT placed in their cell.

* This routine is terribly slow!

* As soon as an ASCII code above 31 is found, it's the start of a string,
* then only a 0 can mark the end, no other code!

* Special notice about the Null value; When not inside a string, the null
* value has no function (unless it's a address or a data word). But when
* inside a string the null has the function that it end's the string
* (then it starts again with a value above 31 and contunes to a null...))

* -1 End of all printing (you better do -1 -2)
*
* 0  No Function, just skipped (if not an adddress that is..) for EVEN!
*    also makes the end of a string.
* 1  Set mid pointmode (and midpoint coordinate)
*      W  Mid point as coordinate
* 2  Set fixed point coordinate
*      W  Fixed point
* 3  Set Y mid point
*      W  Mid point Y
* 4  Set Y fixed point
*      W  Fixed Y pos
* 5  Set font pointer
*      L  Address to font
* 6  Clear Screen

* Font Header
*                DS.W 1              ; 0   Hight of font
*                DS.W 1              ; 2   Mid point of font (Y)
*                DS.W 1              ; 4   Words wide
*                DS.W 1              ; 6   Bitplanes (not yet included)
*                DS.W 1              ; 8   Pixels between characters
*                DS.W 11             ; 10   **Reserved**

*                DS.W 1              ; 32  Offset from header to image data
*                DS.W 1              ; 34  Offset from header to width tab
*                DS.W 1              ; 36  Offset to font translate tab
*                                      describes the order of the chars in
*                                      the font image (ei. "ABCDEF" )
*widthtab:       DS.B 256            ; Width of Character (0=none existent char)
*imagedata:      IBYTES 'FONT'       ; Font image ALL characters must be cut
*                                      with the same cell size (even by 16)
*                                      nulls at unused areas!

*ClrScreen rout:       (saving of registers is needed)
*      A5=Address to Screen
*      A6=Address to start
* out: Nothing!

*PrintOneChar rout:    (saving of registers is needed)
*      A3=Address to characters IMAGE data
*      A4=Address to font header
*      A5=Address to screen
*      A6=Address to start
*      D5=True X (upper left corner)
*      D6=True Y (upper left corner)
*      D7=Width
* out: Nothing!

*Controler rout:      (no register saving is needed)
*      A0=Address to string
*      A5=Address to screen
*      A6=Address to start
* out: Nothing
* other: Should call StringControler when a string starts

*String Controler rout:    (saving registers is needed)
*      A0=Address to string  (Until a zero, only TRUE CHARS handled here!)
*      A5=Address to screen
*      A6=Address to start
* out: A0 should point at the byte after the null
* other:  Should call PrintOneChar for output
                ENDPART

_Font:          >PART 'F O N T'
                DC.W 40                     ; 0
                DC.W 20                     ; 2
                DC.W 3                      ; 4
                DC.W 1                      ; 6
                DC.W 4                      ; 8
                DS.B 32-10                  ; 10
                DC.W _FontImage-_Font       ; 32
                DC.W _FontWidth-_Font       ; 34
                DC.W _FontTranslate-_Font   ; 36

_FontTranslate: DC.B "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                DC.B '.,!"'
                DC.B "abcdefghijklmnopqrstuvwxyz"
                DC.B -1

_FontWidth:     DS.B 32
                DC.B 20                     ; Space
                DC.B 12                     ; !
                DC.B 22                     ; "
                DS.B 9
                DC.B 10                     ; ,
                DC.B 0
                DC.B 10                     ; .
                DS.B 18
                DC.B 35,31,31,34,30,32      ; ABCDEF
                DC.B 33,41,19,24,38,32      ; GHIJKL
                DC.B 44,39,32,30,33,36      ; MNOPQR
                DC.B 24,35,36,34,45,38      ; STUVWX
                DC.B 33,33                  ; YZ
                DS.B 6
                DC.B 28,25,22,27,22,27      ; abcdef
                DC.B 27,29,16,20,30,16      ; ghijkl
                DC.B 39,30,25,27,26,22      ; mnopqr
                DC.B 20,17,31,26,40,30      ; stuvwx
                DC.B 26,24                  ; yz
                DS.B 256-122

                EVEN
_FontImage:
                PATH 'A:\'
                IBYTES 'FONT1.B'
                IBYTES 'FONT2.B'
                ENDPART


****************************************

FadeIrq:        >PART 'Fade IRQ Call'
***********************************************
**      IRQ FADE
**      a0=address to put colors on
***********************************************
                movem.l D0-A6,-(A7)
                lea     _countfade(PC),A1
                subq.w  #1,(A1)
                bpl.s   .stillgoing
                move.w  #0,(A1)
                lea     _finishedpal(PC),A1
                movem.l (A1),D0-D7
                movem.l D0-D7,(A0)
                bra.s   .stickupyourass

.stillgoing:    lea     _addtab(PC),A1
                lea     _coltab(PC),A2
                moveq   #47,D7
.phase1:        move.w  (A1)+,D0
                ext.l   D0
                add.w   D0,(A2)+
                dbra    D7,.phase1
                lea     _coltab(PC),A1
                moveq   #15,D7

.phase2:        move.w  (A1),D0
                move.w  32(A1),D1
                move.w  64(A1),D2
                asr.w   #3,D0
                asr.w   #7,D1
                asr.w   #8,D2
                asr.w   #3,D2
                and.w   #$0F00,D0
                and.w   #$00F0,D1
                and.w   #$000F,D2
                add.w   D1,D0
                add.w   D2,D0

                move.w  D0,D1
                and.w   #$0EEE,D0
                and.w   #$0111,D1
                lsl.w   #3,D1
                lsr.w   #1,D0
                add.w   D1,D0

*                and.w   #$0777,D0       ; if ST test!
                move.w  D0,(A0)+
                addq.l  #2,A1
                dbra    D7,.phase2

.stickupyourass:movem.l (A7)+,D0-A6
                rts
                ENDPART
FadeInit:       >PART 'Fade Init'
***********************************************
**      INIT CALL
**      a0=address to start pal
**      a1=address to  end pal
**      d0=fade steps
***********************************************
                movem.l D0-A6,-(A7)
                exg     A0,A1
                moveq   #15,D7
                moveq   #11,D6
                lea     _countfade(PC),A2
                move.w  D0,(A2)
                lea     _addtab(PC),A2
                lea     _coltab(PC),A3
                lea     _finishedpal(PC),A4
.loop16:        move.w  (A0)+,D1
                move.w  (A1)+,D2
                move.w  D1,(A4)+
                move.w  D1,D3
                and.w   #$0777,D1
                and.w   #$0888,D3
                lsl.w   #1,D1
                lsr.w   #3,D3
                add.w   D3,D1

                move.w  D2,D3
                and.w   #$0777,D2
                and.w   #$0888,D3
                lsl.w   #1,D2
                lsr.w   #3,D3
                add.w   D3,D2

                move.w  D1,D3               ; red
                move.w  D2,D4
                and.w   #$0F00,D3
                and.w   #$0F00,D4
                lsl.w   #3,D3
                lsl.w   #3,D4
                move.w  D4,(A3)
                sub.w   D4,D3
                ext.l   D3
                divs    D0,D3
                move.w  D3,(A2)

                move.w  D1,D3               ; green
                move.w  D2,D4
                and.w   #$00F0,D3
                and.w   #$00F0,D4
                lsl.w   #7,D3
                lsl.w   #7,D4
                move.w  D4,32(A3)
                sub.w   D4,D3
                ext.l   D3
                divs    D0,D3
                move.w  D3,32(A2)

                move.w  D1,D3               ; blue
                move.w  D2,D4
                and.w   #$000F,D3
                and.w   #$000F,D4
                lsl.w   #8,D3
                lsl.w   #8,D4
                lsl.w   #3,D3
                lsl.w   #3,D4
                move.w  D4,64(A3)
                sub.w   D4,D3
                ext.l   D3
                divs    D0,D3
                move.w  D3,64(A2)

                addq.l  #2,A3
                addq.l  #2,A2
                dbra    D7,.loop16
                movem.l (A7)+,D0-A6
                rts
                ENDPART
                >PART 'Fade Data'
**********************************************
**      D A T A
**********************************************
_addtab:        DS.W 16                     ; red
                DS.W 16                     ; green
                DS.W 16                     ; blue
_coltab:        DS.W 16
                DS.W 16
                DS.W 16
_finishedpal:   DS.W 16
_countfade:     DC.W 0
                ENDPART

****************************************

_VblFlag:       DS.W 1
_SaveTab:       DS.L 64
                END
