                >PART 'Programmers guide'

* 126930  421127   Skivhugget!

* ta bort PicTab_Pek & PalTab_Pek



* vid MODULE kommandot
*     Inga Address/Data register „r f”rsatta
*
* vid COMPILERING
*     A3=Address to start of routine which has been called
*     A5=_InitTab
*
* vid PROCESS RUNNING
*     A4=Current Seq_PC
*     A5=_Proc_Tab

* vid INTERRUPT RUNNING
*     A4=Data tab (multiproccess tab)
*     A5=_Proc_Tab


                ENDPART
                OPT P-
                PATH 'A:\'
@Editor         EQU 0
@Seq_Max_Size   EQU 64*1024
                IF @Editor=1
                >PART 'RUN_EDITOR'
                movea.l A7,A5
                lea     $0007FFF0,A7
                movea.l 4(A5),A5
                move.l  $000C(A5),D0
                add.l   $0014(A5),D0
                add.l   $001C(A5),D0
                add.l   #$00000100,D0
                move.l  D0,-(A7)
                move.l  A5,-(A7)
                move.w  #0,-(A7)
                move.w  #$004A,-(A7)
                trap    #1
                adda.l  #12,A7

                pea     _Nulls(PC)
                pea     _ComLine(PC)
                pea     _Editor(PC)
                clr.w   -(A7)
                move.w  #$004B,-(A7)
                trap    #1
                lea     16(A7),A7
                clr.w   -(A7)
                trap    #1

_ComLine:       DC.B " OMEGA.SEQ"
_Nulls:         DC.B 0,0
_Editor:        DC.B "K:\STEDI\STEDI.PRG"
                EVEN
                ENDPART
                ELSE


                >PART 'CALL SUPER PART'
                pea     begin(PC)
                move.w  #38,-(A7)
                trap    #14
                addq.l  #6,A7
                clr.w   -(A7)
                trap    #1
                rts
                ENDPART
begin:          >PART 'SAVE REGISTERS'
****************************************
**   S A V E    R E G I S T E R S
****************************************
                lea     savetab(PC),A6
                move.l  A7,(A6)+
                move.l  $00000070.w,(A6)+
                move.l  $000000A0.w,(A6)+
                move.l  $00000120.w,(A6)+
                move.b  $FFFFFA07.w,(A6)+
                move.b  $FFFFFA09.w,(A6)+
                move.b  $FFFFFA0F.w,(A6)+
                move.b  $FFFFFA11.w,(A6)+
                move.b  $FFFFFA13.w,(A6)+
                move.b  $FFFFFA15.w,(A6)+
                move.l  $00000068.w,(A6)+
                move.l  $00000070.w,(A6)+
                move.l  $000000A0.w,(A6)+
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
                lea     savetab(PC),A6
                movea.l (A6)+,A7
                move.l  (A6)+,$00000070.w
                move.l  (A6)+,$000000A0.w
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
                bsr     Initer
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
                bsr.s   Vsync
                move.b  #0,$FFFF820A.w
                bsr.s   Vsync
                bsr.s   Vsync
                move.b  #2,$FFFF820A.w

                ENDPART
                bra     Starter
Vsync:          >PART 'Vsync'
                tst.w   VblFlag-s(A6)
                beq.s   Vsync
                clr.w   VblFlag-s(A6)
                rts
                ENDPART
TimerB:         >PART 'Raster Irq'
                eori.w  #$0630,$FFFF8240.w
                bclr    #0,$FFFFFA0F.w
                rte
                ENDPART
Vbl:            >PART 'VBL Irq'
                addq.w  #1,VblFlag-s(A6)
                cmpi.b  #$39,$FFFFFC02.w
                beq     back
                rte
                ENDPART
VblFlag:        DS.W 1
savetab:        DS.L 64

ERROR:          >PART 'Error Handel'
                move.w  _Line(PC),D0
                lea     .Digs(PC),A1
                lea     .Hurmp(PC),A2
                moveq   #3,D2
.ToDec:         rol.w   #4,D0
                move.w  D0,D1
                and.w   #$000F,D1
                move.b  0(A1,D1.w),(A2)+
                dbra    D2,.ToDec

                pea     .GunText(PC)
                move.w  #9,-(A7)
                trap    #1
                move.w  #7,-(A7)
                trap    #1
                addq.l  #2,A7

                bra     back

.Digs:          DC.B "0123456789ABCDEF"
.GunText:       DC.B 27,"E"
                DC.B "Error at line "
.Hurmp:         DC.B "....!",0
                EVEN
                ENDPART


PictRout:       >PART 'Draw Pic rout'
P:
                lea     P(PC),A6
                pea     _ComName(PC)
                pea     Initizer(PC)
                move.w  #32,-(A7)
                trap    #8
                addq.l  #8,A7

                move.w  #33,-(A7)
                trap    #8
                addq.l  #2,A7

                move.l  A0,-(A7)
                move.w  #21,-(A7)
                trap    #8
                addq.l  #6,A7
                cmp.b   #";",D0
                bne.s   .Fucking_Fel

                move.l  A0,-(A7)
                move.w  #34,-(A7)
                trap    #8
                addq.l  #6,A7

                rts
.Fucking_Fel:   illegal
                DC.B "Error in PICTURE DISPLAY MODULE command "
                EVEN
_ComName:       DC.B "DRAW_PIC",0
                EVEN
Initizer:       move.l  #35,-(A7)
                trap    #8
                addq.l  #2,A7
                movea.l A0,A2               ; a2=Save buf

                lea     SplatHim(PC),A0
                move.l  A0,(A2)+

                move.l  #33,-(A7)
                trap    #8
                addq.l  #2,A7
                movea.l A0,A3               ; a3=Get from buf

                move.l  A3,-(A7)
                move.w  #2,-(A7)
                move.w  #17,-(A7)
                trap    #8
                addq.w  #8,A7
                movea.l A0,A3
                add.w   D0,D0
                move.w  D0,(A2)+            ; bpl offset

                move.l  A3,-(A7)
                move.w  #2,-(A7)
                move.w  #17,-(A7)
                trap    #8
                addq.w  #8,A7
                movea.l A0,A3
                add.w   D0,D0
                add.w   D0,D0
                move.w  D0,(A2)+            ; Bild offset

                move.l  A3,-(A7)
                move.w  #34,-(A7)
                trap    #8
                addq.l  #6,A7               ; Save SeqComp

                move.l  A2,-(A7)
                move.w  #36,-(A7)
                trap    #8
                addq.l  #6,A7               ; Save SeqSave

                rts
SplatHim:
                ENDPART


                >PART 'INFO TEXT'
*  Video, sequenser language v 1.0
*
*
*   #INI          Start Init section

*   STAC XXXX     Size of Sequenser Stack.. Default is $0200 =512 Bytes
*   _NEO XX YY Z "FIL"
*                 Load neochrome picture to pic XX. Pal will be saved at ZZ
*                 If Z=0 then it's a 1 bitplane picture, if Z=1 then
*                 it's a 4 bitplane picture. "FIL" is the name of the
*                 picture, including path ect.
*   PALE XX,aaa,bbb..  Define a palete. (if you don't enter 16 values,
*                 the last entered will be used to fill the others with.)

*   #SEQ          Start Sequenser section

*   WAIT XX       Wait nr of VBL's (dec)
*   PICT Z XX     Put Picture on Screen (Bitplane Z (0-3)) (hex)
*   WIPE Z        Erases a entire bitplane
*   >COL Y,RGB    (Y=color nr)   RGB=0-F       All in hex!
*   FADE XX,YY,ZZ Fade colors, from pal XX to YY using ZZ vbl's
*   >PAL ZZ       Set pal. ZZ.

*   S_LP XX       Start of a loop (which will loop XX times (dec))
*   LOOP          Execute Loop

*   LAB: XXXX     A label, XXXX can be anything(ASCII, writable)
*   GOTO XXXX     Goto label XXXX and continue sequense there
*   GOSB XXXX     Gosub a label (goto but returns when a "RETU" is found)
*   RETU          Return from a GOSB
*   <END          Ends sequenser.. this command is always included as the
*                 last command, so you only have to use it if you wish to
*                 end in sub-routine or something like that.
*
*  #END           End of file, (everything coming after is REMARK lines)

* Always use correct number of digits (like 01, not 1)
* Use upper charceters where it is said you should.
*
* All commands effecting screen/colors will take place at the NEXT vbl..
* but they are executed at a ghost screen during THIS vbl. This don't has
* to be keept in mind (mostly).  The result of this is that everything you
* do concerning a bitplane has to be done again the next frame (exception
* is if you draw a new picture on same bitplane every VBL) to avoid flickering.
* This means.. If you draw 3 picture on different bitplanes during a 3VBL time
* period (drawing 1 plane at the time) the computer will have to work like
* this:   VBL 1   Draw Picture 1 on Bitplane 1
*         VBL 2   Draw Picture 1 on Bitplane 1
*                 Draw Picture 2 on Bitplane 2
*         VBL 3   Draw Picture 2 on Bitplane 2
*                 Draw Picture 3 on Bitplane 3
*         VBL 4   Draw Picture 3 on Bitplane 3
* This is why I limit the bitplane use to ONE process per bitplane at ONE
* VBL (meaning maximum of 4 bitplane-effecting proccesses (with a few
* complicated exception if REALLY neccessary)) so that the PROGRAM WILL
* AVOID doing like this when drawing 3 pics at same bitplane.
*         VBL 1   Draw Picture 1 on Bitplane 1
*         VBL 2   Draw Picture 1 on Bitplane 1
*                 Draw Picture 2 on Bitplane 1
*         VBL 3   Draw Picture 2 on Bitplane 1
*                 Draw Picture 3 on Bitplane 1
*         VBL 4   Draw Picture 3 on Bitplane 1
* But instead do like this
*         VBL 1   Draw Picture 1 on Bitplane 1
*         VBL 2   Draw Picture 2 on Bitplane 1
*         VBL 3   Draw Picture 3 on Bitplane 1
*         VBL 4   Draw Picture 3 on Bitplane 1
* Working like this means that you only have to CONSIDER that what takes
* time a one VBL may take time at the next VBL too if you don't reuse the
* same bitplanes again. (Meaning that Updating 2 bitplanes at VBL 1 and the
* other 2 the next vbl would give:
*         VBL 1   Draw Picture 1 on Bitplane 1
*                 Draw Picture 2 on Bitplane 2
*         VBL 2   Draw Picture 1 on Bitplane 1
*                 Draw Picture 2 on Bitplane 2
*                 Draw Picture 3 on Bitplane 3
*                 Draw Picture 4 on Bitplane 4
* But this really is no problem when just drawing pictures, as only two has
* to be uncrunched at VBL 1 and 2 at VBL 2 + copying the other 2 (which is
* quite fast using the blitter)

*
* REMark lines MUST start with a * and continues to the end of the line.
*
* A remark line can start at the end of a command line.
* Spaces at the start of a line is removed, making it possibly to creat
* easy to read sequenses-code.
*
* A command MUST end with a ;..
* Characters that has no function: NEW-LINE  SPACE  ,
*      They are all just ignorred. (>WAIT 00 = >WAIT 01 = >WA IT ,,01)
* Observe that NEW-LINE ends a remark line.
                ENDPART
                >PART 'Picture Data'
*      0   1.W    Type
*                 0= 1 bpl, pure Image file
*                 1= 2 bpl
*                 2= 3 bpl
*                 3= 4 bpl
*
*     32   x..    Start of image / crunched data

                ENDPART

T8:             >PART 'Žckel'
                movem.l D2-D7/A2-A6,-(A7)
                lea     T8(PC),A6
                lea     11*4+6(A7),A5
                move.w  (A5)+,D7
                add.w   D7,D7
                move.w  _HoppTab-T8(A6,D7.w),D7
                jsr     0(A6,D7.w)
                movem.l (A7)+,D2-D7/A2-A6
                rte
                ENDPART
_HoppTab:       >PART 'T8 commands'
                DC.W ResvMem-T8             ; 0
                DC.W FillMem-T8
                DC.W FreeMem-T8
                DC.W ClenMem-T8
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W SetVar-T8              ; 8
                DC.W GetVar-T8
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W GetStr-T8              ; 16
                DC.W GetHexNr-T8
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W StupidChar-T8
                DC.W GetStartChar-T8
                DC.W GetContChar-T8
                DC.W FindEnd-T8             ; 24
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W ToComBuf-T8            ; 32
                DC.W GetSeqComPek-T8
                DC.W SetSeqComPek-T8
                DC.W GetSeqSavePek-T8
                DC.W SetSeqSavePek-T8
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0                      ; 40
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0                      ; 48
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0
                ENDPART

                PART 'Memory Commands T8'
ResvMem:        move.l  D0,-(A7)
                move.l  (A5)+,D0            ; Size
                bsr     GET_FRG_MEM
                move.l  (A7)+,D0
                rts                         ; out: a0=memory address

FillMem:        movea.l (A5)+,A2            ; Address
                move.l  (A5)+,D2            ; Size
                lsr.l   #1,D2
                subq.l  #1,D2
                bmi.s   .Stupid
.Fylla:         clr.w   (A2)+
                dbra    D2,.Fylla
.Stupid:        rts

FreeMem:        movem.l D0/A0,-(A7)
                movea.l (A5)+,A0            ; Address
                move.l  (A5)+,D0            ; Size
                bsr     FREE_FRG_MEM
                movem.l (A7)+,D0/A0
                rts

ClenMem:        bsr     CLEAN_FRG_TAB
                rts
                ENDPART
                >PART 'Variabel commands T8'

* Set/Create a variabel 8
* .L Address to name
* .L value
* out:  d0=0 if existed   -1 if created
SetVar:         movem.l D1/A0-A1,-(A7)
                move.l  (A5)+,D1
                movea.l (A5)+,A0
                bsr     FindVar             ; out d0,a0
                lea     _fast(PC),A1
                move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                move.l  D1,(A0)+
                movem.l (A7)+,D1/A0-A1
                rts

* Get variabel value  9
* .L Address to name
* out:  d0=value
*       d1=-1 if not existed   0=if ok
GetVar:         movea.l (A5)+,A0
                bsr     FindVar
                move.l  D0,D1
                move.l  8(A0),D0            ; funkar pga "next unused" = even
                rts

FindVar:
* a0=Address to name
* out: a0=location address  (or next unused)
*      d0=0 if exist  -1 if not
                movem.l D2/A2-A3,-(A7)
                lea     _fast(PC),A2
                movea.l A2,A4
                clr.l   (A2)
                clr.l   4(A2)
.kopiera:       move.b  (A0)+,(A2)+
                bne.s   .kopiera
                move.l  (A3)+,D0
                move.l  (A3)+,D2
                movea.l _VarTab_Pek(PC),A0
.takeone:       cmp.l   (A0),D0
                bne.s   .fail_1
                cmp.l   4(A0),D2
                bne.s   .fail_2
                moveq   #0,D0
                movem.l (A7)+,D2/A2-A3
                rts
.fail_1:        tst.l   (A0)
                beq.s   .dont_exist
.fail_2:        lea     12(A0),A0
                bra.s   .takeone
.dont_exist:    moveq   #-1,D0
                movem.l (A7)+,D2/A2-A3
                rts
_fast:          DS.B 8


                ENDPART
                >PART 'String commands T8'

**************** 16

* Expects GetStartChar, GetContChar to not destroy d1,a1,a2
GetStr:         move.l  D0,-(A7)
                movea.l (A5)+,A2            ; Save at
                movea.l (A5)+,A0            ; Look at

                move.l  A0,-(A7)
                movea.l A7,A5
                bsr     GetStartChar
                addq.l  #4,A7

                cmp.b   #'"',D0
                bne.s   .GetS_Error

.St_loop:       move.l  A0,-(A7)
                movea.l A7,A5
                bsr     GetContChar
                addq.l  #4,A7

                cmp.b   #'"',D0
                beq.s   .Slutet
                move.b  D0,(A2)+
                bra.s   .St_loop
.Slutet:        clr.b   (A2)+
                move.l  (A7)+,D0
                rts
.GetS_Error:    illegal
                DC.B 'a quote mark is expected, but not found '
                EVEN


**************** 17

* destroys d2,d3
GetHexNr:       move.w  (A5)+,D2            ; Nr of hex's
                movea.l (A5)+,A0            ; Address

                move.w  D2,-(A7)
                move.l  A0,-(A7)
                movea.l A7,A5
                bsr     GetStartChar
                addq.l  #4,A7
                lea     -1(A0),A0
                move.w  (A7)+,D2

                moveq   #0,D3
                subq.w  #1,D2
.Hexa_Loop:     lsl.l   #4,D3
                movem.l D2-D3,-(A7)
                move.l  A0,-(A7)
                movea.l A7,A5
                bsr     GetContChar
                addq.l  #4,A7
                movem.l (A7)+,D2-D3

                cmp.b   #'0',D0
                blo.s   .HEX_Error
                cmp.b   #'9',D0
                ble.s   .GotDecDigit
                cmp.b   #'A',D0
                blo.s   .HEX_Error
                cmp.b   #'F',D0
                ble.s   .GotHexDigit
                cmp.w   #'a',D0
                blt.s   .HEX_Error
                cmp.b   #'f',D0
                bhi.s   .HEX_Error
.GotHexDigit:   add.b   #9,D0
.GotDecDigit:   and.w   #$000F,D0
                or.w    D0,D3
                dbra    D2,.Hexa_Loop
                move.l  D3,D0
                rts
.HEX_Error:     illegal
                DC.B "D7 Not a hexadecimal ascII number "
                EVEN



**************** 21

* destroys nothing
StupidChar:     move.w  (A5)+,D0            ; Character
                cmp.b   #32,D0
                beq.s   .Yes2
                cmp.b   #13,D0
                beq.s   .NewL2
                cmp.b   #10,D0
                beq.s   .Yes2
                cmp.b   #9,D0
                beq.s   .Yes2
                cmp.b   #',',D0
                beq.s   .Yes2
                moveq   #-1,D0
                rts                         ; d0=-1 if valid char
.NewL2:         addq.w  #1,_Line-T8(A6)
.Yes2:          moveq   #0,D0
                rts                         ; d0= 0 if dummy char

**************** 22

* expects StupidChar to no destroy A0,A1,D1,D2
* destroys d2
GetStartChar:   movea.l (A5)+,A0            ; Look at
.GetValid:      move.b  (A0)+,D2
                cmp.b   #"*",D2
                bne.s   .NotRemark
.LookLF:        cmpi.b  #13,(A0)+
                bne.s   .LookLF
                bra.s   .GetValid
.NotRemark:     move.w  D2,-(A7)
                movea.l A7,A5
                bsr.s   StupidChar          ; Call 21
                addq.l  #2,A7
                tst.w   D0
                beq.s   .GetValid
                move.w  D2,D0
                rts                         ; Out A0=address D0=Char


**************** 23

* Destroys d2
GetContChar:    movea.l (A5)+,A0            ; Look at
                move.b  (A0)+,D2
                move.w  D2,-(A7)
                movea.l A7,A5
                bsr.s   StupidChar
                addq.l  #2,A7
                tst.w   D0
                beq.s   .ContError
                move.w  D2,D0
                rts                         ; Out A0=address D0=Char
.ContError:     illegal
                DC.B "Unexcpected character in data field"
                EVEN

**************** 24

* Expects GetStartChar to not destroy d1,a1
* Destroys nothing
FindEnd:        move.l  D0,-(A7)
                move.l  (A5)+,-(A7)
                movea.l A7,A5
                bsr.s   GetStartChar
                addq.l  #4,A7
                cmp.b   #";",D0
                bne     ERROR
                move.l  (A7)+,D0
                rts                         ; out A0=Address after ;
                ENDPART
                >PART 'Seq pointer commands T8'
ToComBuf:
GetSeqComPek:   movea.l _SeqCompPek(PC),A0
                rts
SetSeqComPek:   lea     _SeqCompPek(PC),A2
                move.l  (A5)+,(A2)
                rts
GetSeqSavePek:  movea.l _SeqSavePek(PC),A0
                rts
SetSeqSavePek:  lea     _SeqSavePek(PC),A2
                move.l  (A5)+,(A2)
                rts
                ENDPART
******************************************
Initer:         >PART 'Initisering'
                pea     InitText(PC)        ; (C) Init text
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7

                bsr     INIT_MEMCONTL       ; Fix memory controler
                bsr     INIT_FRG_MEM
                move.l  #T8,$000000A0.w     ; Start Trap #8


                move.l  #@Seq_Max_Size,D0
                bsr     GET_FRG_MEM
                move.l  A0,_SeqCompPek
                move.l  A0,_SeqSavePek
                move.l  A0,_Seq_PC
                move.l  A0,_Seq_Start
                lea     _Seq_Name(PC),A1
                bsr     LoadFile
                bsr.s   TransformSeq

*                movea.l _Seq_Pek(PC),A0     ; Free unused FRG mem
*                move.l  A0,D0
*                add.l   #@Seq_Max_Size,D0
*                sub.l   _Seq_End_Pek(PC),D0
*                and.l   #$FFFFFFFE,D0
*                bsr     FREE_FRG_MEM


                lea     _Pro1(PC),A0        ; Set Pro1 & Pro2 pointers
                lea     _Procceses1(PC),A1
                move.l  A1,(A0)+
                lea     _Procceses2(PC),A1
                move.l  A1,(A0)+

                move.l  #32256,D0           ; Reserve Screen Memory
                bsr     GET_FRG_MEM
                move.l  A0,D1
                add.l   #255,D1
                and.l   #$00FFFF00,D1
                lea     _D_Screen(PC),A6
                move.l  D1,(A6)
                bsr     GET_FRG_MEM
                move.l  A0,D1
                add.l   #255,D1
                and.l   #$00FFFF00,D1
                lea     _W_Screen(PC),A6
                move.l  D1,(A6)

                rts

InitText:       DC.B 27,"E"
                DC.B 27,"p","Coffein",27,"q",13,10
                DC.B "(C)opyright 1992 Martin Liesen",13,10,10
                DC.B 0
                EVEN
                ENDPART
TransformSeq:   >PART 'Convert SEQ to fast, +INIT'
                move.l  #1024*4,D0
*                bsr     GET_FRG_MEM
*                bsr     CLEAR_MEM
*                move.l  A0,_PalTab_Pek
*                bsr     GET_FRG_MEM
*                bsr     CLEAR_MEM
*                move.l  A0,_PicTab_Pek

                bsr     GET_FRG_MEM         ; Get TEMPORARY areas
                bsr     CLEAR_MEM           ; for LABEL processing
                lea     _LabelAddr_Pek(PC),A1
                move.l  A0,(A1)+
                move.l  A0,(A1)+
                bsr     GET_FRG_MEM
                bsr     CLEAR_MEM
                lea     _LabelJump_Pek(PC),A1
                move.l  A0,(A1)+
                move.l  A0,(A1)+


                lea     _Init_Tab(PC),A5

.NextCom:       move.l  _SeqCompPek(PC),-(A7)
                move.w  #22,-(A7)
                trap    #8
                addq.l  #6,A7
                subq.w  #1,A0
                move.l  A0,@_SeqCompPek(A5) ; skip shit.

                lea     Sequens_C(PC),A2
.LookMore:      tst.l   (A2)
                beq     ERROR
                movea.l (A2)+,A4
                movea.l (A2)+,A3
                movea.l _SeqCompPek(PC),A0
.mupp:          cmpm.b  (A0)+,(A4)+
                beq.s   .mupp
                tst.b   -1(A4)
                bne.s   .LookMore
                subq.w  #1,A0
                move.b  (A0),D0
                cmp.b   #";",D0
                beq.s   .godis
                move.w  D0,-(A7)
                move.w  #21,-(A7)
                trap    #8
                addq.l  #4,A7
                tst.w   D0
                bne.s   .LookMore
.godis:         move.l  A0,@_SeqCompPek(A5)
                movem.l D0-A6,-(A7)
                jsr     (A3)
                movem.l (A7)+,D0-A6
                tst.w   _StopFlag
                bne.s   .NextCom


                move.w  @_StackSize(A5),D0  ; Create Stack
                bsr     GET_FRG_MEM
                lea     @_StackSize(A0),A0
                lea     _Proc_Tab(PC),A4
                move.l  A0,@_Seq_SP(A4)

                lea     _Seq_Slut(PC),A0
                move.l  @_SeqSavePek,(A0)   ; Spara slut f”r frigivning

                rts



*>> LABEL Processing

                movea.l _LabelJump_Pek(PC),A0

.NextLabel:     move.l  (A0)+,D0
                beq.s   .Lab_Fin

                movea.l _LabelAddr_Pek(PC),A1
.Not_Sam:       move.l  (A1)+,D1
                move.l  (A1)+,D2
                tst.l   D1
                beq.s   .Lab_Error
                cmp.l   D1,D0
                bne.s   .Not_Sam
                movea.l (A0)+,A1
                move.l  D2,(A1)
                bra.s   .NextLabel

.Lab_Error:     illegal
                DC.B "Label in D0 was never defined"
                EVEN

.Lab_Fin:       move.l  #256*4,D0           ; Free Temporary LABEL areas
                movea.l _LabelAddr_Pek(PC),A1
                bsr     FREE_FRG_MEM
                movea.l _LabelJump_Pek(PC),A1
                bsr     FREE_FRG_MEM


                ENDPART
_Seq_Name:      DC.B "OMEGA.SEQ",0
                EVEN


Starter:        >PART 'Start SEQ'
                move.l  #-1,$FFFF8A28.w     ; Bliter default
                move.w  #-1,$FFFF8A2C.w
                move.b  #0,$FFFF8A3D.w
                move.b  #$40,$FFFF8A3C.w

                lea     VBL(PC),A0
                move.l  A0,$00000070.w
                clr.b   $FFFFFA1B.w
.loop:          cmpi.b  #$39,$FFFFFC02.w
                bne.s   .loop
                bra     back
                ENDPART
******************************************
Switch:         >PART 'Toggle buffert'
                move.l  _Pro1(PC),D0
                move.l  _Pro2(PC),D1
                move.l  D0,_Pro2-e(A6)
                move.l  D1,_Pro1-e(A6)
                move.l  _W_Screen(PC),D0
                move.l  _D_Screen(PC),D1
                move.l  D0,_D_Screen-e(A6)
                move.l  D1,_W_Screen-e(A6)
                move.b  _D_Screen+1(PC),$FFFF8201.w
                move.b  _D_Screen+2(PC),$FFFF8203.w
                rts
                ENDPART
Run_Proc:       >PART 'Do all procceses'
                lea     _Proc_Tab(PC),A5
                movea.l @_Pro1(A5),A4
                moveq   #7,D7
.AllProc:       tst.l   (A4)
                beq.s   .Nothing
                movem.l D7/A4-A5,-(A7)
                movea.l (A4),A0
                jsr     (A0)
                movem.l (A7)+,D7/A4-A5
                clr.l   (A4)
.Nothing:       lea     32(A4),A4
                dbra    D7,.AllProc
                rts
                ENDPART

VBL:            >PART 'VBL Routine'
                movem.l D0-A6,-(A7)
                lea     e(PC),A6
                not.w   _DoingVBL-e(A6)
                beq.s   F_U_C_K
                bsr.s   Switch
                lea     _PalToSet(PC),A0
                movem.l (A0)+,D0-D7
                movem.l D0-D7,$FFFF8240.w

                bsr.s   Run_Seq
                bsr.s   Run_Proc

                not.w   _DoingVBL-e(A6)
                movem.l (A7)+,D0-A6
                rte
F_U_C_K:        illegal
                DC.B "Over VBL time"
                EVEN
                ENDPART

Run_Seq:        >PART 'Run Sequenser'
                lea     _Proc_Tab(PC),A5
                subq.w  #1,@_Wait_Count(A5)
                beq.s   .Seq_Loop
                rts
.Seq_Loop:      movea.l @_Seq_PC(A5),A4
                movea.l (A4)+,A2
                move.l  A4,@_Seq_PC(A5)
                jsr     (A2)
                lea     _Proc_Tab(PC),A5    ;Someone might destroy it
                tst.w   @_Wait_Count(A5)
                beq.s   .Seq_Loop
                rts
                ENDPART

                >PART 'Mostly garbage'

                movea.l _Seq_PC(PC),A5
                movea.l _Seq_SP(PC),A4

Seq_Loop:       move.l  (A5)+,D7
                lea     _Com_Tab(PC),A1
.CheckNext:     move.l  (A1)+,D0
                move.l  (A1)+,D1
                cmp.l   D0,D7
                bne.s   .CheckNext
                jmp     0(A6,D1.w)

SeqDone:        move.l  A5,_Seq_PC-e(A6)
                move.l  A4,_Seq_SP-e(A6)
                rts

_Com_Tab:       DC.L "wait",exe_wait-e,"pict",exe_draw_pic-e
*                DC.L "wipe",exe_wipe_pic-e
*                DC.L ">col",exe_setcol-e,">pal",exe_setpal-e,"fade",0
*                DC.L "s_lp",exe_startloop-e,"loop",exe_doloop-e
*                DC.L "goto",exe_goto-e,"gosb",exe_gosub-e
*                DC.L "retu",exe_return-e,"<end",0

e:

exe_draw_pic:   move.w  (A5)+,D0
                move.l  (A5)+,D1
                move.w  D0,D2
                lsl.w   #4,D2               ; *16 = bpl *32
                lea     Splat_pic(PC),A0
                movea.l _Pro1(PC),A1
                adda.w  D2,A1
                move.l  A0,(A1)+
                move.w  D0,(A1)+
                move.l  D1,(A1)+
                movea.l _Pro2(PC),A1
                adda.w  D2,A1
                move.l  A0,(A1)+
                move.w  D0,(A1)+
                move.l  D1,(A1)+
                bra.s   Seq_Loop
exe_wipe_pic:   move.w  (A5)+,D0
                move.w  D0,D2
                lsl.w   #4,D2               ; *16 = bpl *32
                lea     Trash_bpl(PC),A0
                movea.l _Pro1(PC),A1
                adda.w  D2,A1
                move.l  A0,(A1)+
                move.w  D0,(A1)+
                movea.l _Pro2(PC),A1
                adda.w  D2,A1
                move.l  A0,(A1)+
                move.w  D0,(A1)+
                bra.s   Seq_Loop


*exe_setpal:     movea.l (A5)+,A0
                lea     _PalToSet(PC),A1
                REPT 8
                move.l  (A0)+,(A1)+
                ENDR
                bra     Seq_Loop
exe_goto:       movea.l (A5)+,A5
                bra     Seq_Loop
exe_gosub:      move.l  (A5)+,D0
                move.l  A5,-(A4)
                movea.l D0,A5
                bra     Seq_Loop
exe_return:     movea.l (A4)+,A5
                bra     Seq_Loop
                ENDPART
Splat_pic:      >PART 'DRAW PICTURE'
* 0  l rout
* 4  w screen offset
* 6  l source picture data
                movea.l 6(A0),A2
                cmpi.w  #0,(A2)
                beq.s   .splut1b
                cmpi.w  #3,(A2)
                beq.s   .splut4b
                illegal

.splut1b:       lea     $FFFF8A00.w,A6
                move.w  #2,$0020(A6)
                move.w  #2,$0022(A6)
                lea     32(A2),A2
                move.l  A2,$0024(A6)
                move.w  #8,$002E(A6)
                move.w  #8,$0030(A6)
                movea.l (A1),A2
                adda.w  4(A0),A2
                move.l  A2,$0032(A6)
                move.w  #20,$0036(A6)
                move.w  #199,$0038(A6)
                move.w  #$0203,$003A(A6)
                move.b  #$C0,$003C(A6)
                rts

.splut4b:       lea     $FFFF8A00.w,A6
                move.w  #2,$0020(A6)
                move.w  #2,$0022(A6)
                lea     32(A2),A2
                move.l  A2,$0024(A6)
                move.w  #2,$002E(A6)
                move.w  #2,$0030(A6)
                movea.l (A1),A2
                adda.w  4(A0),A2
                move.l  A2,$0032(A6)
                move.w  #80,$0036(A6)
                move.w  #199,$0038(A6)
                move.w  #$0203,$003A(A6)
                move.b  #$C0,$003C(A6)
                rts
                ENDPART
Trash_bpl:      >PART 'Erase a bitplane'
* 0  l rout
* 4  w screen offset

                lea     $FFFF8A00.w,A6
                move.w  #8,$002E(A6)
                move.w  #8,$0030(A6)
                movea.l (A1),A2
                adda.w  4(A0),A2
                move.l  A2,$0032(A6)
                move.w  #20,$0036(A6)
                move.w  #199,$0038(A6)
                move.w  #$0000,$003A(A6)
                move.b  #$C0,$003C(A6)
                rts

                ENDPART


*------------------
Define_Pal:     PART 'Define Palette'
                lea     Define_Pal(PC),A3
                pea     _dp_v_paltab(PC)    ; get PALTAB
                move.w  #9,-(A7)
                trap    #8
                addq.l  #6,A7
                tst.w   D1
                beq.s   .dp_tabexists

                move.l  #256,D3             ; d3=field size

                move.l  D3,D0
                lsl.l   #2,D0
                move.l  D0,-(A7)            ; reserve PAL TAB MEMORY
                move.w  #0,-(A7)
                trap    #8
                addq.l  #2,A7
                move.l  A0,D2               ; d2=address to tab
                move.l  A0,-(A7)
                move.w  #1,-(A7)
                trap    #8
                lea     10(A7),A7

                pea     _dp_v_paltab(PC)    ; create PALTAB
                move.l  D2,-(A7)
                move.w  #8,-(A7)
                trap    #8
                lea     10(A7),A7
                move.l  D2,D0

                pea     _dp_v_palsize(PC)   ; create PALSIZE
                move.l  D3,-(A7)
                move.w  #8,-(A7)
                trap    #8
                lea     10(A7),A7
                move.l  D2,D0

.dp_tabexists:  move.l  D0,_dp_paltab-Define_Pal(A3)
                pea     _dp_v_palsize(PC)   ; get PALSIZE
                move.w  #9,-(A7)
                trap    #8
                addq.l  #6,A7
                lea     _dp_error1(PC),A0
                move.l  A0,@_ErrorMssg(A5)
                tst.w   D1
                bne     ERROR
                move.l  D0,_dp_palsize-Define_Pal(A3)


                lea     _dp_error2(PC),A0
                move.l  A0,@_ErrorMssg(A5)

                move.l  @_SeqCompPek(A5),-(A7)
                move.w  #3,-(A7)
                move.w  #17,-(A7)
                trap    #8
                addq.l  #8,A7
                move.l  A0,@_SeqCompPek(A5)
                add.w   D0,D0
                add.w   D0,D0

                movea.l _dp_paltab(PC),A2
                adda.w  D0,A2
                tst.l   (A2)
                bne     ERROR
                moveq   #32,D0
                bsr     GET_FRG_MEM
                move.l  A0,(A2)
                movea.l A0,A2               ; a2=where to save

                movea.l @_SeqCompPek(A5),A0 ; a0=Seq
                moveq   #-1,D6              ; d6=last used col
                moveq   #15,D7
.LoopPal:       move.l  A0,-(A7)
                move.w  #22,-(A7)
                trap    #8
                addq.l  #6,A7
                subq.w  #1,A0
                cmpi.b  #";",(A0)
                beq.s   .PalEnd

                move.l  A0,-(A7)
                move.w  #3,-(A7)
                move.w  #17,-(A7)
                trap    #8
                addq.l  #8,A7
                move.w  D0,(A2)+
                move.w  D0,D6
                dbra    D7,.LoopPal

                move.l  A0,-(A7)
                move.w  #24,-(A7)
                trap    #8
                addq.l  #6,A7
                move.l  A0,@_SeqCompPek(A5)
                rts

.PalEnd:        addq.w  #1,A0
                move.l  A0,@_SeqCompPek(A5)
                lea     _dp_error2(PC),A0
                move.l  A0,@_ErrorMssg(A5)
                cmp.w   #-1,D6
                beq     ERROR
.FillPal:       move.w  D6,(A2)+
                dbra    D7,.FillPal
                rts


_dp_error1:     DC.B "Var PALTAB exist but not PALSIZE",0
_dp_error2:     DC.B "Argument error: DEFINE_PAL",0
_dp_error3:     DC.B "No color specified",0

_dp_v_paltab:   DC.B "PALTAB",0
_dp_v_palsize:  DC.B "PALSZIE",0
                EVEN
_dp_paltab:     DS.L 1
_dp_palsize:    DS.L 1

                ENDPART
Set_Speed:      >PART 'Set VBL speed'
                move.l  @_SeqCompPek(A5),-(A7)
                move.w  #2,-(A7)
                move.w  #17,-(A7)           ; get hex
                trap    #8
                addq.l  #8,A7
                move.w  D0,_Speed

                move.l  A0,-(A7)
                move.w  #24,-(A7)           ; get fst
                trap    #8
                addq.l  #6,A7
                move.l  A0,@_SeqCompPek(A5)
                rts
                ENDPART
Set_Stack:      >PART 'Set Stack Size'
                move.l  @_SeqCompPek(A5),-(A7)
                move.w  #4,-(A7)
                move.w  #17,-(A7)           ; get hex
                trap    #8
                addq.l  #8,A7
                move.w  D0,_StackSize

                move.l  A0,-(A7)
                move.w  #24,-(A7)           ; get fst
                trap    #8
                addq.l  #6,A7
                move.l  A0,@_SeqCompPek(A5)
                rts
                ENDPART

Wait:           >PART 'Wait Vbl'
                movea.l @_SeqCompPek(A5),A0
                movea.l @_SeqSavePek(A5),A2

                lea     exe_wait(PC),A1
                move.l  A1,(A2)+

                move.l  A0,-(A7)            ; get time
                move.w  #2,-(A7)
                move.w  #17,-(A7)
                trap    #8
                addq.l  #8,A7
                move.w  D0,(A2)+

                move.l  A0,-(A7)            ; find ;
                move.w  #24,-(A7)
                trap    #8
                addq.l  #6,A7

                move.l  A0,@_SeqCompPek(A5) ; save comp
                move.l  A2,@_SeqSavePek(A5) ; save save
                rts

exe_wait:       move.w  (A4)+,@_Wait_Count(A5)
                move.l  A4,@_Seq_PC(A5)
                rts

                ENDPART
End_Code:       >PART 'End command'
                movea.l @_SeqSavePek(A5),A0
                lea     exe_END(PC),A1
                move.l  A1,(A0)+
                move.l  A0,@_SeqSavePek(A5)

                move.l  (A5),-(A7)          ; find ;
                move.w  #24,-(A7)
                trap    #8
                addq.l  #6,A7
                move.l  A0,(A5)
                rts

exe_END:        move    #$2700,SR
                bra     back
                ENDPART
Set_Col:        >PART 'Set singel color'
                movea.l @_SeqSavePek(A5),A2
                lea     exe_setcol(PC),A0
                move.l  A0,(A2)+

                move.l  @_SeqCompPek(A5),-(A7)
                move.w  #1,-(A7)
                move.w  #17,-(A7)
                trap    #8                  ; get hex
                addq.l  #8,A7

                add.w   D0,D0
                move.w  D0,(A2)+

                move.l  A0,-(A7)
                move.w  #3,-(A7)
                move.w  #17,-(A7)
                trap    #8                  ; get hex
                addq.l  #8,A7

                move.w  D0,(A2)+

                move.l  A0,-(A7)
                move.w  #24,-(A7)
                trap    #8                  ; find ;
                addq.l  #6,A7

                move.l  A0,@_SeqCompPek(A5)
                move.l  A2,@_SeqSavePek(A5)
                rts

exe_setcol:     move.w  (A4)+,D0
                lea     @_PalToSet(A5),A0
                move.w  (A4)+,0(A0,D0.w)
                move.l  A4,@_Seq_PC(A5)
                rts
                ENDPART
Set_Pal:        >PART 'Set entire Palette'




                movea.l @_SeqSavePek(A5),A2
                lea     exe_setpal(PC),A0
                move.l  A0,(A2)+

                move.l  @_SeqCompPek(A5),-(A7)
                move.w  #3,-(A7)
                move.w  #17,-(A7)
                trap    #8                  ; get hex
                addq.l  #8,A7

                add.w   D0,D0
                add.w   D0,D0

                movea.l @_PalTab_Pek(A5),A1
                move.l  0(A1,D0.w),(A2)+
                move.l  A2,@_SeqSavePek(A5)

                move.l  A0,-(A7)
                move.w  #24,-(A7)
                trap    #8                  ; find ;
                addq.l  #6,A7

                move.l  A0,@_SeqCompPek(A5)
                rts

exe_setpal:     movea.l (A4)+,A0
                move.l  A4,@_Seq_PC(A5)
                movem.l (A0)+,D0-D7
                movem.l D0-D7,$FFFF8240.w
                rts
                ENDPART

Setup_Loop:     >PART 'Start of Loop'
                movea.l @_SeqSavePek(A5),A2
                lea     exe_setuploop(PC),A0
                move.l  A0,(A2)+

                move.l  @_SeqCompPek(A5),-(A7)
                move.w  #2,-(A7)
                move.w  #17,-(A7)
                trap    #8
                addq.l  #8,A7

                move.w  D0,(A2)+
                move.l  A2,@_SeqSavePek(A5)

                move.l  A0,-(A7)
                move.w  #24,-(A7)
                trap    #8
                addq.l  #6,A7

                move.l  A0,@_SeqCompPek(A5)
                rts

exe_setuploop:  movea.l @_Seq_SP(A5),A0
                move.w  (A4)+,D0
                move.l  A4,-(A0)
                move.w  D0,-(A0)
                move.l  A0,@_Seq_SP(A5)
                move.l  A4,@_Seq_PC(A5)
                rts

                ENDPART
Execute_Loop:   >PART 'End of Loop'
                movea.l @_SeqSavePek(A5),A2
                lea     exe_doloop(PC),A0
                move.l  A0,(A2)+

                move.l  A2,@_SeqSavePek(A5)
                move.l  @_SeqCompPek(A5),-(A7)
                move.w  #24,-(A7)
                trap    #8                  ; find ;
                addq.l  #6,A7
                move.l  A0,@_SeqCompPek(A5)
                rts

exe_doloop:     movea.l @_Seq_SP(A5),A0
                subi.w  #1,(A0)+
                bne.s   .Hoppa
                addq.l  #4,A0
                move.l  A0,@_Seq_SP(A5)
                rts
.Hoppa:         movea.l (A0)+,A1
                move.l  A1,@_Seq_PC(A5)
                rts
                ENDPART


Draw_Pict:      >PART 'Draw a picture'
                move.l  #"pict",(A5)+
                moveq   #1,D6
                bsr     GetHex
                cmp.w   #3,D7
                bhi.s   .Pict_Error1
                add.w   D7,D7
                move.w  D7,(A5)+

                moveq   #2,D6
                bsr     GetHex
                lsl.w   #2,D7
                movea.l _PicTab_Pek(PC),A0
                move.l  0(A0,D7.w),D7
                beq.s   .Pict_Error2
                move.l  D7,(A5)+

                bsr     FindComEnd
                rts
.Pict_Error1:   illegal
                DC.B "Using non-existing bitplane"
                EVEN
.Pict_Error2:   illegal
                DC.B "Drawing a not loaded picture"
                EVEN
                ENDPART
Wipe_Pict:      >PART 'Erase a bitplane'
                move.l  #"wipe",(A5)+
                moveq   #1,D6
                bsr     GetHex
                cmp.w   #3,D7
                bhi.s   .Wipe_Error1
                add.w   D7,D7
                move.w  D7,(A5)+
                bsr     FindComEnd
                rts
.Wipe_Error1:   illegal
                DC.B "Using non-existing bitplane"
                EVEN
                ENDPART
Set_Palen:      >PART 'Set entire Palette'
                move.l  #">pal",(A5)+
                moveq   #2,D6
                bsr     GetHex
                movea.l _PalTab_Pek(PC),A0
                lsl.w   #2,D7
                move.l  0(A0,D7.w),D7
                beq.s   .SetPal_Error1
                move.l  D7,(A5)+
                bsr     FindComEnd
                rts
.SetPal_Error1: illegal
                DC.B "Using palette without defining it"
                EVEN
                ENDPART
Fade:           >PART 'Fade between two pals'
                move.l  #"fade",(A5)+
                REPT 2
                moveq   #2,D6
                bsr     GetHex
                movea.l _PalTab_Pek(PC),A0
                lsl.w   #2,D7
                move.l  0(A0,D7.w),D7
                beq.s   .Fade_Error1
                move.l  D7,(A5)+
                ENDR
                moveq   #2,D6
                bsr     GetHex
                move.w  D7,(A5)+
                bsr     FindComEnd
                rts
.Fade_Error1:   illegal
                DC.B "Using palette without defining it"
                EVEN
                ENDPART
Label:          >PART 'Label Found'
                bsr     GetCommand
                movea.l _LabelAddr_Pek+4(PC),A0
                move.l  D7,(A0)+
                move.l  A5,(A0)+
                move.l  A0,_LabelAddr_Pek+4
                bsr     FindComEnd
                rts
                ENDPART
Goto:           >PART 'Goto'
                move.l  #'goto',(A5)+
                bsr     GetCommand
                movea.l _LabelJump_Pek+4(PC),A0
                move.l  D7,(A0)+
                move.l  A5,(A0)+
                move.l  A0,_LabelJump_Pek+4
                clr.l   (A5)+
                bsr     FindComEnd
                rts
                ENDPART
Gosub:          >PART 'Gosub'
                move.l  #'gosb',(A5)+
                bsr     GetCommand
                movea.l _LabelJump_Pek+4(PC),A0
                move.l  D7,(A0)+
                move.l  A5,(A0)+
                clr.l   (A5)+
                move.l  A0,_LabelJump_Pek+4
                bsr     FindComEnd
                rts
                ENDPART
Return:         >PART 'Return'
                move.l  #'retu',(A5)+
                bsr     FindComEnd
                rts
                ENDPART

*------------------
END_Section:    >PART 'End Section'
                clr.w   _StopFlag
                movea.l @_SeqSavePek(A5),A0
                lea     exe_END(PC),A1
                move.l  A1,(A0)+
                move.l  A0,@_SeqSavePek(A5)
                rts
                ENDPART
*------------------
Load_NEO_Pic:   >PART 'Load NEO Picture Command'
                movem.l D0-A3,-(A7)

                moveq   #2,D6
                bsr     GetHex
                move.l  D7,D4               ; D4= pic to save at
                lsl.w   #2,D4
                bsr     GetHex
                move.w  D7,D5               ; D5= pal to save at
                lsl.w   #2,D5
                moveq   #1,D6
                bsr     GetHex
                move.l  D7,D6               ; D6 = mode

                lea     -80(A7),A7
                movea.l A7,A0
                movea.l A0,A3               ; a3=address to filename
                bsr     GetFilename
                move.l  #32128,D0
                bsr     GET_FRG_MEM
                movea.l A0,A2               ; a2=address to loaded pic
                movea.l A3,A1
                bsr     LoadFile
                lea     80(A7),A7

                moveq   #32,D0
                bsr     GET_FRG_MEM
                movea.l _PalTab_Pek(PC),A1
                tst.l   0(A1,D5.w)
                bne     .Neo_Error1
                move.l  A0,0(A1,D5.w)
                lea     4(A2),A1
                REPT 8
                move.l  (A1)+,(A0)+
                ENDR
                lea     128(A2),A2

                cmp.w   #0,D6
                beq.s   .NEOOneBpl
                cmp.w   #1,D6
                beq.s   .NEOFourBpl
                illegal
                DC.B "Unknown NEO handle mode"
                EVEN
.NEOOneBpl:
                move.l  #8032,D0
                bsr     GET_FRG_MEM
                movea.l A0,A3               ; a3=Start pic
                move.w  #0,(A0)
                lea     32(A0),A0
                move.w  #3999,D0
.Neo1Copy:      move.w  (A2),(A0)+
                addq.l  #8,A2
                dbra    D0,.Neo1Copy
                bra.s   .Meet

.NEOFourBpl:    move.l  #32032,D0
                bsr     GET_FRG_MEM
                movea.l A0,A3               ; a3=Start pic
                move.w  #3,(A0)
                lea     32(A0),A0
                move.w  #7999,D0
.Neo4Copy:      move.l  (A2)+,(A0)+
                dbra    D0,.Neo4Copy

.Meet:          movea.l _PicTab_Pek(PC),A0
                tst.l   0(A0,D4.w)
                bne.s   .Neo_Error2
                move.l  A3,0(A0,D4.w)

                movem.l (A7)+,D0-A3
                bsr.s   FindComEnd
                rts

.Neo_Error1:    illegal
                DC.B "Palette set at same number twice"
                EVEN
.Neo_Error2:    illegal
                DC.B "Picture loaded at same number twice"
                EVEN
                ENDPART
*------------------

FindComEnd:     >PART 'Get to Command End ;'
                bsr     GetChar
                cmp.b   #';',D7
                bne.s   .ComEnd_Error
                rts
.ComEnd_Error:  illegal
                DC.B "Not ending line with a ; "
                EVEN
                ENDPART
GetFilename:    >PART 'Get a filename'
                movem.l D7,-(A7)            ; IN a0 address where name shall
                bsr     GetChar             ;       be saved
                cmp.b   #'"',D7
                bne.s   .NameError
.NameLoop:      move.b  (A4)+,D7
                cmp.b   #'"',D7
                beq.s   .NameEnd
                move.b  D7,(A0)+
                bra.s   .NameLoop
.NameEnd:       clr.b   (A0)+
                movem.l (A7)+,D7
                rts

.NameError:     illegal
                DC.B 'Filename missing " character'
                EVEN
                ENDPART
GetHex:         >PART 'Get Hex charcters'
                movem.l D5-D6,-(A7)         ; IN d6=number of characters
                moveq   #0,D5               ;    (2 normally)
                subq.w  #1,D6               ; OUT d7=hex number
.HexLoop:       lsl.l   #4,D5
                bsr     GetChar
                cmp.b   #'0',D7
                blo.s   .Error
                cmp.b   #'9',D7
                ble.s   .GotDigit
                cmp.b   #'A',D7
                blo.s   .Error
                cmp.b   #'F',D7
                ble.s   .GotHexDigit2
                cmp.w   #'a',D7
                blt.s   .Error
                cmp.b   #'f',D7
                bhi.s   .Error
.GotHexDigit2:  add.b   #9,D7
.GotDigit:      and.w   #$000F,D7
                or.w    D7,D5
                dbra    D6,.HexLoop
                exg     D5,D7
                movem.l (A7)+,D5-D6
                rts
.Error:         illegal
                DC.B "D7 Not a hexadecimal ascII number"
                EVEN
                ENDPART
GetCommand:     >PART 'Get a 4 char command'
                movem.l D6,-(A7)            ; out D7=command
                bsr.s   GetChar
                exg     D7,D6
                bsr.s   GetChar
                rol.l   #8,D6
                move.b  D7,D6
                bsr.s   GetChar
                rol.l   #8,D6
                move.b  D7,D6
                bsr.s   GetChar
                rol.l   #8,D6
                move.b  D7,D6
                exg     D6,D7
                movem.l (A7)+,D6
                rts
                ENDPART
GetChar:        >PART 'Get a character'
                move.b  (A4)+,D7
                cmp.b   #'*',D7
                beq.s   .RemLoop
                bsr.s   DummyChar
                beq.s   GetChar
                rts
.RemLoop:       cmpi.b  #13,(A4)+
                bne.s   .RemLoop
                addq.w  #1,_Line
                bra.s   GetChar
                ENDPART
DummyChar:      >PART 'Is Character a dummy char?'
                cmp.b   #32,D7
                beq.s   .Yes
                cmp.b   #13,D7
                beq.s   .NewL
                cmp.b   #10,D7
                beq.s   .Yes
                cmp.b   #9,D7
                beq.s   .Yes
                cmp.b   #',',D7
                beq.s   .Yes
                move    #0,CCR
                rts
.NewL:          addq.w  #1,_Line
.Yes:           move    #4,CCR
                rts
                ENDPART


                PART 'D A T A   T A B E L S'

_Procceses1:    DS.B 32*8
_Procceses2:    DS.B 32*8
_BackTasks:     DS.L 32*8

_DoingVBL:      DS.W 1
_Seq_Start:     DS.L 1
_Seq_Slut:      DS.L 1
_DataTab:

_Init_Tab:

_SeqCompPek:    DS.L 1                      ; 0
_SeqSavePek:    DS.L 1                      ; 4
_StopFlag:      DC.W -1                     ; 8   0=End seq compilation
_Line:          DC.W 2                      ; 10
_ErrorMssg:     DS.L 1                      ; 12
_StackSize:     DC.W $0200                  ; 16
_Speed:         DC.W 1                      ; 18
_Reserved1:     DS.L 6                      ; 20
_LabelJump_Pek: DS.L 1                      ; 44
                DS.L 1                      ; 48
_LabelAddr_Pek: DS.L 1                      ; 52
                DS.L 1                      ; 56
_VarTab_Pek:    DS.L 1                      ; 60

@_SeqCompPek    EQU _SeqCompPek-_Init_Tab
@_SeqSavePek    EQU _SeqSavePek-_Init_Tab
@_StopFlag      EQU _StopFlag-_Init_Tab
@_Line          EQU _Line-_Init_Tab
@_ErrorMssg     EQU _ErrorMssg-_Init_Tab
@_StackSize     EQU _StackSize-_Init_Tab
@_Reserved1     EQU _Reserved1-_Init_Tab
@_LabelJump_Pek EQU _LabelJump_Pek-_Init_Tab
@_LabelAddr_Pek EQU _LabelAddr_Pek-_Init_Tab
@_VarTab_Pek    EQU _VarTab_Pek-_Init_tab


_Proc_Tab:

_W_Screen:      DS.L 1                      ; 0
_D_Screen:      DS.L 1                      ; 4
_Vbl_Count:     DS.W 1                      ; 8
_Seq_PC:        DS.L 1                      ; 10
_Seq_SP:        DS.L 1                      ; 14
_Pro1:          DS.L 1                      ; 18
_Pro2:          DS.L 1                      ; 22
_Background:    DS.L 1                      ; 26
_Raster:        DS.L 1                      ; 30
_Wait_Count:    DC.W 1                      ; 30
_PalToSet:      DS.W 16                     ; 32


@_W_Screen      EQU _W_Screen-_Proc_Tab
@_D_Screen      EQU _D_Screen-_Proc_Tab
@_Vbl_Count     EQU _Vbl_Count-_Proc_Tab
@_Seq_PC        EQU _Seq_PC-_Proc_Tab
@_Seq_SP        EQU _Seq_SP-_Proc_Tab
@_Pro1          EQU _Pro1-_Proc_Tab
@_Pro2          EQU _Pro2-_Proc_Tab
@_Background    EQU _Background-_Proc_Tab
@_Raster        EQU _Raster-_Proc_Tab
@_Wait_Count    EQU _Wait_Count-_Proc_Tab
@_PalToSet      EQU _PalToSet-_Proc_Tab

                ENDPART
                >PART 'Jump TABELS'

.z01:           DC.B "END",0

.w01:           DC.B "STACK_SIZE",0
.w02:           DC.B "LOAD_NEO",0
.w03:           DC.B "DEFINE_PAL",0
.w04:           DC.B "SPEED",0

.e01:           DC.B "WAIT",0
.e02:           DC.B "PICTURE",0
.e03:           DC.B "WIPE",0
.e04:           DC.B "SET_COLOR",0
.e05:           DC.B "SET_PAL",0
.e06:           DC.B "FADE_PAL",0
.e07:           DC.B "REPEAT",0
.e08:           DC.B "END_REPEAT",0
.e09:           DC.B "LABEL",0
.e10:           DC.B "GOTO",0
.e11:           DC.B "GOSUB",0
.e12:           DC.B "RETURN",0
.e13:           DC.B "END_ALL",0



Sequens_C:      DC.L .z01,END_Section
                DC.L .w01,Set_Stack,.w02,Load_NEO_Pic
                DC.L .w03,Define_Pal,.w04,Set_Speed
                DC.L .e01,Wait,.e02,Draw_Pict,.e03,Wipe_Pict
                DC.L .e04,Set_Col,.e05,Set_Pal,.e06,Fade
                DC.L .e07,Setup_Loop,.e08,Execute_Loop
                DC.L .e09,Label,.e10,Goto,.e11,Gosub
                DC.L .e12,Return,.e13,End_Code
                DC.L 0
                ENDPART

LoadFile:       >PART 'Load File Routine'
* A0= Address to load at
* A1= Address to file name
                movem.l D0-A6,-(A7)

                movea.l A0,A6
                clr.w   -(A7)
                move.l  A1,-(A7)
                move.w  #$003D,-(A7)
                trap    #1
                addq.l  #8,A7
                move.w  D0,D7
                bmi.s   .Load_Error1

                move.l  A6,-(A7)
                pea     $0F000000
                move.w  D7,-(A7)
                move.w  #$003F,-(A7)
                trap    #1
                lea     12(A7),A7
                tst.w   D0
                bmi.s   .Load_Error2

                move.w  D7,-(A7)
                move.w  #$003E,-(A7)
                trap    #1
                addq.l  #4,A7
                tst.w   D0
                bmi.s   .Load_Error2

                movem.l (A7)+,D0-A6
                rts
.Load_Error1:   illegal
                DC.B "Error Opening file, nr D0"
                EVEN
.Load_Error2:   illegal
                DC.B "Error reading file, nr D0"
                EVEN
                ENDPART
*********************************************
**     MEMORY CONTROLER  (31/10-91) (26/12-91
*********************************************
MAX_MEMFRG      EQU 64
GET_FRG_MEM:    >PART 'Get Mem From Fragment List'
* D0.L   = Amount
* Out A0 =Address to memory
*  NOTE:  * Always ask for even number of bytes
*         * This is a quite time consuming rutin, get from MEM_END if
*           time is a problem.

                movem.l D1/D5-D7/A1/A5-A6,-(A7)
                movea.l MEM_TAB_PEK(PC),A6
                move.w  #MAX_MEMFRG-1,D7

                lea     -1.w,A5             ; Address on MEM_TAB to best found
                move.l  #$7F000000,D6       ; Size of best found

.FINDSUIT:      movea.l (A6)+,A1
                move.l  (A6)+,D1
                bmi.s   .NICHT
                cmp.l   D0,D1               ; Big enough?
                blt.s   .NICHT
                cmp.l   D6,D1               ; Smaller than old best?
                bge.s   .NICHT
                move.l  D1,D6
                lea     -8(A6),A5
.NICHT:         dbra    D7,.FINDSUIT

                cmpa.l  #-1,A5
                beq.s   .NOFRAG_MEM

                movea.l (A5),A0
                move.l  4(A5),D7
                cmp.l   D7,D0
                bne.s   .CHG_FRG
                move.l  #-1,(A5)            ; FRG removed
                move.l  #-1,4(A5)
                bra.s   .MEM_DONE
.CHG_FRG:       move.l  A0,(A5)             ; Fix new FRG
                add.l   D0,(A5)
                sub.l   D0,D7
                move.l  D7,4(A5)
                bra.s   .MEM_DONE

.NOFRAG_MEM:    lea     MEM_END(PC),A5
                movea.l (A5),A0             ; Get normal mem
                add.l   D0,(A5)

.MEM_DONE:      movem.l (A7)+,D1/D5-D7/A1/A5-A6
                rts
                ENDPART
FREE_FRG_MEM:   >PART 'Free Mem and put it on FRG tab'
* A0=Start Address
* D0=Lenght
*     NOTE:  * Only free even number of bytes
*            * This routine eats time!, don't release memory in your IRQ's!

                movem.l D7/A6,-(A7)

                movea.l MEM_TAB_PEK(PC),A6
                move.w  #MAX_MEMFRG-1,D7

.FIND_FREE_FRG: tst.l   4(A6)
                bpl.s   .NOT_FREE_FRG
                move.l  A0,(A6)
                move.l  D0,4(A6)
                bsr.s   CLEAN_FRG_TAB
                bra.s   .FREE_DONE
.NOT_FREE_FRG:  addq.l  #8,A6
                dbra    D7,.FIND_FREE_FRG
                illegal

.FREE_DONE:     movem.l (A7)+,D7/A6
                rts
                ENDPART
CLEAN_FRG_TAB:  >PART 'Clean up FRG tab'
* This rutines finds different fragmentions that actually is
* one and links them together. It also checks if fragmented memory is
* directly linked to MEM_END and then transfares the memory to free mem.
* (that is memory above MEM_END)
* This routine is called from FREE_FRG_MEM and thereby will the MEM_TAB
* always be clean.

                movem.l D0-D1/D6-A1/A4-A6,-(A7)
                movea.l MEM_TAB_PEK(PC),A4
                movea.l A4,A6

                move.w  #MAX_MEMFRG-1,D7
.LX_1:          movea.l (A6)+,A0
                move.l  (A6)+,D0
                bmi.s   .LY_1

                adda.l  D0,A0

                cmpa.l  MEM_END(PC),A0      ; Memory just below Mem_End
                bne.s   .NOT_MEM_END
                move.l  #-1,-8(A6)
                move.l  #-1,-4(A6)
                lea     MEM_END(PC),A5
                sub.l   D0,(A5)


.NOT_MEM_END:   movea.l A4,A5
                move.w  #MAX_MEMFRG-1,D6
.LX_2:          movea.l (A5)+,A1
                move.l  (A5)+,D1
                bmi.s   .LY_2

                cmpa.l  A1,A0
                bne.s   .LY_2

                move.l  #-1,-(A5)           ; Found a link
                move.l  #-1,-(A5)
                add.l   D1,-(A6)
                subq.l  #4,A6
                bra.s   .LX_1

.LY_2:          dbra    D6,.LX_2
.LY_1:          dbra    D7,.LX_1


                movem.l (A7)+,D0-D1/D6-A1/A4-A6
                rts
                ENDPART
INIT_FRG_MEM:   >PART 'Init Framgment Mem Tab'
* This Resets the Fragmented memory map

                movem.l D6-D7/A6,-(A7)
                movea.l MEM_TAB_PEK(PC),A6
                move.w  #MAX_MEMFRG-1,D7
                moveq   #-1,D6
.IN_MEM:        move.l  D6,(A6)+
                move.l  D6,(A6)+
                dbra    D7,.IN_MEM

                movem.l (A7)+,D6-D7/A6
                rts
                ENDPART
INIT_MEMCONTL:  >PART 'Init Memory Controler (PC)'
                lea     MEM_TAB_PEK(PC),A0
                lea     MEM_TAB(PC),A1
                move.l  A1,(A0)
                lea     MEM_END(PC),A0
                lea     MEMORY(PC),A1
                move.l  A1,(A0)
                rts
                ENDPART
CLEAR_MEM:      >PART 'Clear a Grab memory area'
* Call this directly afte GET_FRG_MEM to abtain a clean mem area
                movem.l D0/A0,-(A7)
                lsr.w   #1,D0
                subq.w  #1,D0
                bmi.s   .Strange
.Rensa:         clr.w   (A0)+
                dbra    D0,.Rensa
.Strange:       movem.l (A7)+,D0/A0
                rts
                ENDPART
MEM_TAB_PEK:    DS.L 1
MEM_END:        DS.L 1
                BSS
MEM_TAB:        DS.B MAX_MEMFRG*8
MEMORY:         DS.B 500*1024

                ENDC
                END
