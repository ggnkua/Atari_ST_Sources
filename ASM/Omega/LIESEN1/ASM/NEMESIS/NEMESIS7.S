*****************************************************
**** Nemesis User Interface *************************
**** (C) Martin Liesen 1991   Synchron Assemby
*****************************************************
**** Later Versions of NEMESIS will probably not
**** be totaly compatible with older versions..
*****************************************************
rem             EQU 0
SizeOfSavePos   EQU 8                             ; Limit 32!
StackSavePos    EQU 31                            ; Memory Spent = (17+StackSavePos)*SizeOfPos
Xsize           EQU 80                            ; In Highest Resolution
Ysize           EQU 25                            ; In Highest Resolution

                OPT P+
s:
******************************************************
Nemesis:        >PART 'Nemesis, JSR handler'
                movem.l d1-a6,-(a7)
                lea     s(pc),a5

                lea     (14*4)+4(a7),a6
                clr.l   Return-s(a5)
                move.w  (a6)+,d0
                lea     Function_Tab(pc),a0
.FindFunc:      move.w  (a0)+,d1
                bmi.s   not_found
                move.w  (a0)+,d3
                move.w  (a0)+,d2
                cmp.b   d0,d1
                bne.s   .FindFunc
                lea     0(a5,d2.w),a0
                jsr     (a0)

QuitNemesis:    movem.l (a7)+,d1-a6
                move.l  Return(pc),d0
                tst.l   d0
                rts

not_found:      move.l  #-2,Return-s(a5)          ; Tough Luck!!
                moveq   #0,d3
                bra.s   QuitNemesis


Return:         DS.L 1

* $0000-$000F   Screen output routs
* $0010-$002F   General nemesis data rutines
* $0030-$00     Any thing, memory ect
* $0070-$007F   Keybord rutines
* $0080-$008F   Bar rutines
* $0090-$009F   Window rutines

Function_Tab:   DC.W $00,$06,Con_Print_Line-s
                DC.W $01,$04,Con_Print_Char-s
                DC.W $02,$0A,Con_Update-s
                DC.W $03,$02,Con_GetDataTab-s
                DC.W $04,$02,Con_GetValue-s
                DC.W $05,$04,Con_SetValue-s
                DC.W $06,$08,Con_PrintHex-s


                DC.W $10,$04,Gen_Set_Sel-s
                DC.W $11,$02,Gen_Get_Sel-s
                DC.W $12,$04,Gen_Set_UnSel-s
                DC.W $13,$02,Gen_Get_UnSel-s
                DC.W $14,$02,Gen_Get_FontP-s
                DC.W $15,$06,Gen_Set_Mask-s
                DC.W $16,$02,Gen_Get_Mask-s
                DC.W $17,$02,Gen_Get_Screen-s
                DC.W $18,$06,Gen_Set_Screen-s

                DC.W $20,$02,Gen_Open_Work-s
                DC.W $21,$02,Gen_Close_Work-s

                DC.W $30,$06,Any_Rese_Mem-s
                DC.W $31,$06,Any_Free_Mem-s
                DC.W $32,$0A,Any_Save_Blk-s
                DC.W $33,$06,Any_Rest_Blk-s

                DC.W $70,$02,Key_Conin-s

                DC.W $80,$0A,Bar_Open-s
                DC.W $81,$02,Bar_Close-s
                DC.W $82,$04,Bar_SetPos-s
                DC.W $83,$06,Bar_Update-s
                DC.W $84,$04,Bar_Redraw-s
                DC.W $85,$04,Bar_Take_Con-s

                DC.W $90,$0E,Win_Open-s
                DC.W $91,$06,Win_Close-s
                DC.W $92,0,Win_ChgBorder-s
                DC.W $93,$0A,Win_Print-s
                DC.W $94,$08,Win_PrintChar-s
                DC.W $95,$06,Win_CopyCon-s
                DC.W -1,-1,-1
                ENDPART
******************************************************
String_Print:   >PART 'Print Line'
* A0=Address to string
* out; d0=Number of chars written
                movem.l d1,-(a7)
                moveq   #0,d1
Printing:       move.b  (a0)+,d0
                beq.s   LastOne
Not_Last_One:   addq.w  #1,d1
                bsr.s   Do_Char
                bra.s   Printing
LastOne:        tst.w   EscDoing-s(a5)
                bne.s   Not_Last_One
                move.l  d1,d0
                movem.l (a7)+,d1
                rts
                ENDPART
Do_Char:        >PART 'Print Character'
**********************************************************

                movem.l d0-a6,-(a7)
                and.w   #$FF,d0
                tst.w   EscDoing-s(a5)
                bne     Execute_Com
                cmp.b   #27,d0
                beq     Got_Esc

                cmp.b   #10,d0
                beq     LF
                cmp.b   #13,d0
                beq     CR

                move.w  X(pc),d1
                move.w  Y(pc),d2
                cmp.w   Xmax(pc),d1               ; Cliping
                bls.s   m1
                move.w  Xmax(pc),d1
m1:             cmp.w   Xmin(pc),d1
                bhs.s   m2
                move.w  Xmin(pc),d1
m2:             cmp.w   Ymax(pc),d2
                bls.s   m3
                move.w  Ymax(pc),d2
m3:             cmp.w   Ymin(pc),d2
                bhs.s   m4
                move.w  Ymin(pc),d2
m4:

                movea.l a5,a0
                adda.w  A_Print_Rout(pc),a0
                move.b  Look_Byte(pc),d3
                jsr     0(a0)

                move.w  X(pc),d1
                move.w  Y(pc),d2
                tst.w   OverFlow-s(a5)
                bne.s   No_Ow
                cmp.w   Xmax-s(a5),d1
                blo.s   No_Ow
                move.w  Xmin(pc),d1
                addq.w  #1,d2
                move.w  d1,X-s(a5)
                move.w  d2,Y-s(a5)
                bsr.s   Test_Scroll
                bra.s   Enough

No_Ow:          addq.w  #1,d1
                move.w  d1,X-s(a5)
                move.w  d2,Y-s(a5)
                bra.s   Enough


**********************************************************

Test_Scroll:    movem.l d0-d3,-(a7)
                move.w  Ymax-s(a5),d0
                addq.w  #1,d0
                cmp.w   Y(pc),d0
                bne.s   No_Hurry
                move.w  Xmin(pc),d0
                move.w  Ymin(pc),d1
                move.w  Xmax(pc),d2
                move.w  Ymax(pc),d3
                bsr     ScrollUp
                subq.w  #1,Y-s(a5)
No_Hurry:       movem.l (a7)+,d0-d3
                rts



**********************************************************

CR:             move.w  Xmin(pc),X-s(a5)
                bra.s   Enough
LF:             addq.w  #1,Y-s(a5)
                bsr.s   Test_Scroll
*                bra.s   Enough

**********************************************************


Enough:         movem.l (a7)+,d0-a6
                rts

**********************************************************
                ENDPART

Mono8x8:        >PART 'Print Mono 8*8'
*          Mono don't give a shit about the colors!
* D0=Char
* D1=X
* D2=Y
* D3=LookByte
                movem.l d0-d2/d4/a0-a1,-(a7)

                movea.l Char_Screen(pc),a0
                mulu    #Xsize,d2
                move.w  d1,d4

                add.w   d2,d4
                add.w   d4,d4
                move.b  d0,0(a0,d4.w)
                move.b  d3,1(a0,d4.w)

                lsl.w   #3,d2
                add.w   d1,d2
                movea.l $044E.w,a0
                adda.w  d2,a0
                lsl.w   #3,d0
                movea.l Font_Point(pc),a1
                adda.w  d0,a1

                move.b  (a1)+,(a0)
                move.b  (a1)+,1*80(a0)
                move.b  (a1)+,2*80(a0)
                move.b  (a1)+,3*80(a0)
                move.b  (a1)+,4*80(a0)
                move.b  (a1)+,5*80(a0)
                move.b  (a1)+,6*80(a0)
                move.b  (a1)+,7*80(a0)

                btst    #4,d3
                beq.s   thanks1
                not.b   (a0)
                not.b   1*80(a0)
                not.b   2*80(a0)
                not.b   3*80(a0)
                not.b   4*80(a0)
                not.b   5*80(a0)
                not.b   6*80(a0)
                not.b   7*80(a0)
thanks1:        btst    #5,d3
                beq.s   thanks2
                lea     Mask(pc),a1
                move.b  (a1)+,d0
                and.b   d0,0*80(a0)
                move.b  (a1)+,d0
                and.b   d0,1*80(a0)
                move.b  (a1)+,d0
                and.b   d0,2*80(a0)
                move.b  (a1)+,d0
                and.b   d0,3*80(a0)
                move.b  (a1)+,d0
                and.b   d0,4*80(a0)
                move.b  (a1)+,d0
                and.b   d0,5*80(a0)
                move.b  (a1)+,d0
                and.b   d0,6*80(a0)
                move.b  (a1)+,d0
                and.b   d0,7*80(a0)
thanks2:
                movem.l (a7)+,d0-d2/d4/a0-a1
                rts
                ENDPART
Mono8x16_II:    >PART 'Print Mono 8*16 using 8*8 font'
*          Mono don't give a shit about the colors!
* D0=Char
* D1=X
* D2=Y
* D3=LookByte
                movem.l d0-d2/d4/a0-a1,-(a7)

                movea.l Char_Screen(pc),a0
                mulu    #80,d2
                move.w  d1,d4

                add.w   d2,d4
                add.w   d4,d4
                move.b  d0,0(a0,d4.w)
                move.b  d3,1(a0,d4.w)

                lsl.w   #4,d2
                add.w   d1,d2
                movea.l $044E.w,a0
                adda.w  d2,a0
                lsl.w   #3,d0
                movea.l Font_Point(pc),a1
                adda.w  d0,a1

                move.b  (a1),(a0)
                move.b  (a1)+,1*80(a0)
                move.b  (a1),2*80(a0)
                move.b  (a1)+,3*80(a0)
                move.b  (a1),4*80(a0)
                move.b  (a1)+,5*80(a0)
                move.b  (a1),6*80(a0)
                move.b  (a1)+,7*80(a0)
                move.b  (a1),8*80(a0)
                move.b  (a1)+,9*80(a0)
                move.b  (a1),10*80(a0)
                move.b  (a1)+,11*80(a0)
                move.b  (a1),12*80(a0)
                move.b  (a1)+,13*80(a0)
                move.b  (a1),14*80(a0)
                move.b  (a1)+,15*80(a0)

                btst    #4,d3
                beq.s   thanks1b
                not.b   (a0)
                not.b   1*80(a0)
                not.b   2*80(a0)
                not.b   3*80(a0)
                not.b   4*80(a0)
                not.b   5*80(a0)
                not.b   6*80(a0)
                not.b   7*80(a0)
                not.b   8*80(a0)
                not.b   9*80(a0)
                not.b   10*80(a0)
                not.b   11*80(a0)
                not.b   12*80(a0)
                not.b   13*80(a0)
                not.b   14*80(a0)
                not.b   15*80(a0)
thanks1b:       btst    #5,d3
                beq.s   thanks2b
                lea     Mask(pc),a1
                move.b  (a1)+,d0
                and.b   d0,0*80(a0)
                move.b  (a1)+,d0
                and.b   d0,1*80(a0)
                move.b  (a1)+,d0
                and.b   d0,2*80(a0)
                move.b  (a1)+,d0
                and.b   d0,3*80(a0)
                move.b  (a1)+,d0
                and.b   d0,4*80(a0)
                move.b  (a1)+,d0
                and.b   d0,5*80(a0)
                move.b  (a1)+,d0
                and.b   d0,6*80(a0)
                move.b  (a1)+,d0
                and.b   d0,7*80(a0)
                move.b  (a1)+,d0
                and.b   d0,8*80(a0)
                move.b  (a1)+,d0
                and.b   d0,9*80(a0)
                move.b  (a1)+,d0
                and.b   d0,10*80(a0)
                move.b  (a1)+,d0
                and.b   d0,11*80(a0)
                move.b  (a1)+,d0
                and.b   d0,12*80(a0)
                move.b  (a1)+,d0
                and.b   d0,13*80(a0)
                move.b  (a1)+,d0
                and.b   d0,14*80(a0)
                move.b  (a1)+,d0
                and.b   d0,15*80(a0)
thanks2b:
                movem.l (a7)+,d0-d2/d4/a0-a1
                rts
                ENDPART
Mono8x16:       >PART 'Print Mono 8*16'
*          Mono don't give a shit about the colors!
* D0=Char
* D1=X
* D2=Y
* D3=LookByte
                movem.l d0-d2/d4/a0-a1,-(a7)

                movea.l Char_Screen(pc),a0
                mulu    #80,d2
                move.w  d1,d4

                add.w   d2,d4
                add.w   d4,d4
                move.b  d0,0(a0,d4.w)
                move.b  d3,1(a0,d4.w)

                lsl.w   #4,d2
                add.w   d1,d2
                movea.l $044E.w,a0
                adda.w  d2,a0
                lsl.w   #4,d0
                movea.l Font_Point(pc),a1
                adda.w  d0,a1

                move.b  (a1)+,(a0)
                move.b  (a1)+,1*80(a0)
                move.b  (a1)+,2*80(a0)
                move.b  (a1)+,3*80(a0)
                move.b  (a1)+,4*80(a0)
                move.b  (a1)+,5*80(a0)
                move.b  (a1)+,6*80(a0)
                move.b  (a1)+,7*80(a0)
                move.b  (a1)+,8*80(a0)
                move.b  (a1)+,9*80(a0)
                move.b  (a1)+,10*80(a0)
                move.b  (a1)+,11*80(a0)
                move.b  (a1)+,12*80(a0)
                move.b  (a1)+,13*80(a0)
                move.b  (a1)+,14*80(a0)
                move.b  (a1)+,15*80(a0)

                btst    #4,d3
                beq.s   thanks1c
                not.b   (a0)
                not.b   1*80(a0)
                not.b   2*80(a0)
                not.b   3*80(a0)
                not.b   4*80(a0)
                not.b   5*80(a0)
                not.b   6*80(a0)
                not.b   7*80(a0)
                not.b   8*80(a0)
                not.b   9*80(a0)
                not.b   10*80(a0)
                not.b   11*80(a0)
                not.b   12*80(a0)
                not.b   13*80(a0)
                not.b   14*80(a0)
                not.b   15*80(a0)
thanks1c:       btst    #5,d3
                beq.s   thanks2c
                lea     Mask(pc),a1
                move.b  (a1)+,d0
                and.b   d0,0*80(a0)
                move.b  (a1)+,d0
                and.b   d0,1*80(a0)
                move.b  (a1)+,d0
                and.b   d0,2*80(a0)
                move.b  (a1)+,d0
                and.b   d0,3*80(a0)
                move.b  (a1)+,d0
                and.b   d0,4*80(a0)
                move.b  (a1)+,d0
                and.b   d0,5*80(a0)
                move.b  (a1)+,d0
                and.b   d0,6*80(a0)
                move.b  (a1)+,d0
                and.b   d0,7*80(a0)
                move.b  (a1)+,d0
                and.b   d0,8*80(a0)
                move.b  (a1)+,d0
                and.b   d0,9*80(a0)
                move.b  (a1)+,d0
                and.b   d0,10*80(a0)
                move.b  (a1)+,d0
                and.b   d0,11*80(a0)
                move.b  (a1)+,d0
                and.b   d0,12*80(a0)
                move.b  (a1)+,d0
                and.b   d0,13*80(a0)
                move.b  (a1)+,d0
                and.b   d0,14*80(a0)
                move.b  (a1)+,d0
                and.b   d0,15*80(a0)
thanks2c:
                movem.l (a7)+,d0-d2/d4/a0-a1
                rts
                ENDPART

Amount_Tab:     >PART 'Data for ESC commands'
                DC.B "A",0
                DC.W P_CursUp-s
                DC.B "B",0
                DC.W P_CursDown-s
                DC.B "C",0
                DC.W P_CursRight-s
                DC.B "D",0
                DC.W P_CursLeft-s
                DC.B "E",0
                DC.W P_ClrHome-s
                DC.B "H",0
                DC.W P_Home-s
                DC.B "I",0
                DC.W P_CursUpScroll-s
                DC.B "S",1
                DC.W P_Scroll-s
                DC.B "Y",2
                DC.W P_Place_Curs_O-s
                DC.B "Z",2
                DC.W P_Place_Curs_F-s
                DC.B "a",4
                DC.W P_SetArea-s
                DC.B "b",1
                DC.W P_Color-s
                DC.B "j",0
                DC.W P_VTSave-s
                DC.B "k",0
                DC.W P_VTRestore-s
                DC.B "p",0
                DC.W P_Reverse_On-s
                DC.B "q",0
                DC.W P_Reverse_Off-s
                DC.B "r",0
                DC.W P_Mask_On-s
                DC.B "s",0
                DC.W P_Mask_Off-s
                DC.B "v",0
                DC.W P_OverFlow_On-s
                DC.B "w",0
                DC.W P_OverFlow_Off-s
                DC.B "x",1
                DC.W P_Place_Curs_X-s
                DC.B "y",1
                DC.W P_Place_Curs_Y-s
                DC.B "z",2
                DC.W P_Place_Curs_W-s
                DC.B ">",1
                DC.W P_SaveData-s
                DC.B "<",1
                DC.W P_RestoreData-s
                DC.B ")",0
                DC.W P_SP_Save-s
                DC.B "(",0
                DC.W P_SP_Restore-s
                DC.B "#",1
                DC.W P_DrawBox-s
                DC.B "+",0
                DC.W P_OPTon-s
                DC.B "-",0
                DC.W P_OPToff-s

                DC.B -1,-1
                DC.W 0
                ENDPART
PrintDataTab:   >PART 'Print Data'
**********************************************************
X:              DC.W 0                            ; $0
Y:              DC.W 0                            ; $2
Xmin:           DC.W 0                            ; $4
Ymin:           DC.W 0                            ; $6
Xmax:           DC.W Xsize-1                      ; $8
Ymax:           DC.W Ysize-1                      ; $a
OPT_Flag:       DC.W 0                            ; $c  0=On
OverFlow:       DC.W 0                            ; $e  0=0n
Look_Byte:      DC.B 1                            ; $10
                DC.B 0                            ; $11
                DC.W Xsize                        ; $12  Read Only
                DC.W Ysize                        ; $14  Read Only
Char_Screen:    DS.L 1                            ; $16  1b Char 1b data

                DS.B $40-$1A
                EVEN
**********************************************************
A_Print_Rout:   DC.W Mono8x16-s                   ; $40
A_Scroll_U_Rout:DC.W ScrU_all-s                   ; $42
A_Scroll_D_Rout:DC.W ScrD_all-s                   ; $44
A_Scroll_L_Rout:DC.W ScrL_all-s                   ; $46
A_Scroll_R_Rout:DC.W ScrR_all-s                   ; $48
A_Fill_Area:    DC.W FillA_all-s                  ; $4a
A_Update_Area:  DC.W UpdateA_all-s                ; $4c
**********************************************************
Char_Buffert:   DS.B 10
Char_Pek:       DS.L 1
EscDoing:       DS.W 1
Recived:        DS.W 1
**********************************************************
                ENDPART
                >PART 'DOC'

* A                  Y  Cursor Up
* B                  Y  Cursor Down
* C                  Y  Cursor Right
* D                  Y  Cursor Left
* E                  Y  Clear Window And Place Cursor at Home
* H                  Y  Place Cursor at home
* I                  Y  Cursor Up, Scroll Down if at top, and keep Y
* S(0-3)             Y  Scroll 0=Up, 1=Down, 2=Left 3=Right
* Y(x+32,y+32)       N  Place Cursor (VT52, x+32, y+32  full screen)
* Z(x,y)             N  Place Cursor (fullscreen coordinates)
* a(x1,y1,x2,y2)     Y  Set textarea, and Home cursor
* b(0-F)            -  Set color on character
* c(0-3)             -  Set forground color
* j                  Y  Save Position
* k                  Y  Restore Position
* p                  -  Reverse On
* q                  -  Reverse Off
* r                  -  Mask On
* s                  -  Mask Off
* v                  Y  Overflow On
* w                  Y  Overflow Off
* z(x,y)             Y  Place Cursor (window coordinates)
* >(0-F)             Y  Save all values concerning text
* <(0-F)             Y  Restore saved values
* )                  Y  Put values on a 'stack'
* (                  Y  Get values from the 'stack'
* #(0-F)             Y  Draw a box, at the Window coorninates
                ENDPART
                >PART 'Handel ESC stuff'

**********************************************************

Got_Esc:        move.w  #-1,EscDoing-s(a5)        ; Escape is just recived
                clr.w   Recived-s(a5)
                lea     Char_Buffert(pc),a0       ; Prevent error
                move.l  a0,Char_Pek-s(a5)
                bra     Enough

**********************************************************

Execute_Com:    movea.l Char_Pek(pc),a0           ; Escape recived before
                move.b  d0,(a0)+
                move.l  a0,Char_Pek-s(a5)
                subi.w  #1,Recived-s(a5)
                bmi.s   First_Command
                bne     Enough

Do_Command:     lea     Char_Buffert(pc),a0
                lea     s(pc),a1
                adda.w  (a0)+,a1
                jsr     (a1)
                clr.w   EscDoing-s(a5)
                bra     Enough

**********************************************************

First_Command:  lea     Amount_Tab(pc),a0         ; Got Escape and ONE character
tn1:            move.b  (a0)+,d1
                bmi.s   None_At_All
                move.b  (a0)+,d2
                move.w  (a0)+,d3
                cmp.b   d0,d1
                bne.s   tn1

                lea     Char_Buffert(pc),a0
                move.w  d3,(a0)+
                move.l  a0,Char_Pek-s(a5)
                ext.w   d2
                beq.s   Do_Command
                move.w  d2,Recived-s(a5)

                bra     Enough

None_At_All:    clr.w   EscDoing-s(a5)            ; Not valid command
                bra     Enough

**********************************************************
                ENDPART

Update_Area:    >PART 'Update A Specific Area'
                move.w  d4,-(a7)
                move.w  A_Update_Area(pc),d4
                jsr     0(a5,d4.w)
                move.w  (a7)+,d4
                rts

* D0=X1   D1=Y1   D2=X2   d3=Y2
*
UpdateA_all:
                movem.l d0-a2,-(a7)
                move.w  A_Print_Rout(pc),d4
                lea     0(a5,d4.w),a0

                move.w  d3,d6
                move.w  d2,d5
                move.w  d1,d2
                move.w  d0,d1
                move.w  d0,d7

                move.w  d2,d3
                mulu    #80*2,d3
                movea.l Char_Screen(pc),a1
                adda.w  d3,a1

loopy4a:        move.w  d1,d3
                add.w   d3,d3
                lea     0(a1,d3.w),a2
loopx4a:        move.b  (a2)+,d0
                move.b  (a2)+,d3
                jsr     (a0)
                addq.w  #1,d1
                cmp.w   d5,d1
                ble.s   loopx4a
                move.w  d7,d1
                addq.w  #1,d2
                lea     80*2(a1),a1
                cmp.w   d6,d2
                ble.s   loopy4a
                movem.l (a7)+,d0-a2
                rts

                ENDPART
Fill_Area:      >PART 'Fill A Specific Area'
                move.w  d4,-(a7)
                move.w  A_Fill_Area(pc),d4
                jsr     0(a5,d4.w)
                move.w  (a7)+,d4
                rts

* D0=X1   D1=Y1   D2=X2   d3=Y2
* D6=Char D7=LookByte
FillA_all:      movem.l d0-a1,-(a7)

                movea.l Char_Screen(pc),a0
                move.w  A_Print_Rout(pc),d4
                lea     0(a5,d4.w),a1
                move.w  d3,d4
                move.w  d2,d3
                move.w  d1,d2
                move.w  d0,d1

copyloop10:     movem.w d0/d3,-(a7)
                move.w  d6,d0
                move.w  d7,d3
                jsr     (a1)
                movem.w (a7)+,d0/d3

                addq.w  #1,d1
                cmp.w   d3,d1
                ble.s   copyloop10
                move.w  d0,d1
                addq.w  #1,d2
                cmp.w   d4,d2
                ble.s   copyloop10

                movem.l (a7)+,d0-a1
                rts

                ENDPART


ScrollUp:       >PART 'Scroll Area Upwards'
                move.w  d4,-(a7)
                move.w  A_Scroll_U_Rout(pc),d4
                jsr     0(a5,d4.w)
                move.w  (a7)+,d4
                rts

ScrU_all:                                         ; General Scroll Up
* D0=X1   D1=Y1   D2=X2   d3=Y2
                movem.l d0-a2,-(a7)
                move.w  A_Print_Rout(pc),d4
                lea     0(a5,d4.w),a0

                cmp.w   d1,d3                     ; = Only Emptiness
                beq.s   Start_Clear0

                move.w  d3,d6
                move.w  d2,d5
                move.w  d1,d2
                move.w  d0,d1
                move.w  d0,d7

                subq.w  #1,d6                     ; Skip Emptiness Area

                move.w  d2,d3
                add.w   #1,d3
                mulu    #80*2,d3
                movea.l Char_Screen(pc),a1
                adda.w  d3,a1

                tst.w   OPT_Flag-s(a5)
                beq.s   DoOPT0

loopy0a:        move.w  d1,d3                     ; UnOptimized Version
                add.w   d3,d3
                lea     0(a1,d3.w),a2
loopx0a:        move.b  (a2)+,d0
                move.b  (a2)+,d3
                jsr     (a0)
                addq.w  #1,d1
                cmp.w   d5,d1
                ble.s   loopx0a
                move.w  d7,d1
                addq.w  #1,d2
                lea     80*2(a1),a1
                cmp.w   d6,d2
                ble.s   loopy0a
                bra.s   Start_Clear0


DoOPT0:
loopy0b:        move.w  d1,d3                     ; Optimized Version
                add.w   d3,d3
                lea     0(a1,d3.w),a2
loopx0b:        move.b  (a2)+,d0
                move.b  (a2)+,d3
                cmp.b   -162(a2),d0
                bne.s   dohim0
                cmp.b   -161(a2),d3
                beq.s   skiphim0
dohim0:         jsr     (a0)
skiphim0:       addq.w  #1,d1
                cmp.w   d5,d1
                ble.s   loopx0b
                move.w  d7,d1
                addq.w  #1,d2
                lea     80*2(a1),a1
                cmp.w   d6,d2
                ble.s   loopy0b



Start_Clear0:   movem.l (a7),d0-a2                ; Clear Emptiness
                moveq   #32,d6
                move.w  d3,d1
                move.b  Look_Byte(pc),d7
                bsr     Fill_Area
                movem.l (a7)+,d0-a2
                rts

                ENDPART
ScrollDown:     >PART 'Scroll Area Downwards'
                move.w  d4,-(a7)
                move.w  A_Scroll_D_Rout(pc),d4
                jsr     0(a5,d4.w)
                move.w  (a7)+,d4
                rts

ScrD_all:                                         ; General Scroll Down
* D0=X1   D1=Y1   D2=X2   d3=Y2
                movem.l d0-a2,-(a7)
                move.w  A_Print_Rout(pc),d4
                lea     0(a5,d4.w),a0
                exg     d1,d3

                cmp.w   d1,d3                     ; = Only Emptiness
                beq.s   Start_Clear1

                move.w  d3,d6
                move.w  d2,d5
                move.w  d1,d2
                move.w  d0,d1
                move.w  d0,d7

                addq.w  #1,d6                     ; Skip Emptiness Area

                move.w  d2,d3
                add.w   #-1,d3
                mulu    #80*2,d3
                movea.l Char_Screen(pc),a1
                adda.w  d3,a1

                tst.w   OPT_Flag-s(a5)
                beq.s   DoOPT1

loopy1a:        move.w  d1,d3                     ; UnOptimized Version
                add.w   d3,d3
                lea     0(a1,d3.w),a2
loopx1a:        move.b  (a2)+,d0
                move.b  (a2)+,d3
                jsr     (a0)
                addq.w  #1,d1
                cmp.w   d5,d1
                ble.s   loopx1a
                move.w  d7,d1
                subq.w  #1,d2
                lea     -80*2(a1),a1
                cmp.w   d6,d2
                bge.s   loopy1a
                bra.s   Start_Clear1


DoOPT1:
loopy1b:        move.w  d1,d3                     ; Optimized Version
                add.w   d3,d3
                lea     0(a1,d3.w),a2
loopx1b:        move.b  (a2)+,d0
                move.b  (a2)+,d3
                cmp.b   158(a2),d0
                bne.s   dohim1
                cmp.b   159(a2),d3
                beq.s   skiphim1
dohim1:         jsr     (a0)
skiphim1:       addq.w  #1,d1
                cmp.w   d5,d1
                ble.s   loopx1b
                move.w  d7,d1
                subq.w  #1,d2
                lea     -80*2(a1),a1
                cmp.w   d6,d2
                bge.s   loopy1b



Start_Clear1:   movem.l (a7),d0-a2                ; Clear Emptiness
                moveq   #32,d6
                move.w  d1,d3
                move.b  Look_Byte(pc),d7
                bsr     Fill_Area
                movem.l (a7)+,d0-a2
                rts

                ENDPART
ScrollLeft:     >PART 'Scroll Area Leftwards'
                move.w  d4,-(a7)
                move.w  A_Scroll_L_Rout(pc),d4
                jsr     0(a5,d4.w)
                move.w  (a7)+,d4
                rts

ScrL_all:                                         ; General Scroll Left
* D0=X1   D1=Y1   D2=X2   d3=Y2
                movem.l d0-a2,-(a7)
                move.w  A_Print_Rout(pc),d4
                lea     0(a5,d4.w),a0

                cmp.w   d0,d2                     ; = Only Emptiness
                beq.s   Start_Clear2

                move.w  d3,d6
                move.w  d2,d5
                move.w  d1,d2
                move.w  d0,d1
                move.w  d0,d7

                subq.w  #1,d5                     ; Skip Emptiness Area

                move.w  d2,d3
                mulu    #80*2,d3
                movea.l Char_Screen(pc),a1
                adda.w  d3,a1

                tst.w   OPT_Flag-s(a5)
                beq.s   DoOPT2

loopy2a:        move.w  d1,d3                     ; UnOptimized Version
                addq.w  #1,d3
                add.w   d3,d3
                lea     0(a1,d3.w),a2
loopx2a:        move.b  (a2)+,d0
                move.b  (a2)+,d3
                jsr     (a0)
                addq.w  #1,d1
                cmp.w   d5,d1
                ble.s   loopx2a
                move.w  d7,d1
                lea     80*2(a1),a1
                addq.w  #1,d2
                cmp.w   d6,d2
                ble.s   loopy2a
                bra.s   Start_Clear2


DoOPT2:
loopy2b:        move.w  d1,d3                     ; Optimized Version
                addq.w  #1,d3
                add.w   d3,d3
                lea     0(a1,d3.w),a2
loopx2b:        move.b  (a2)+,d0
                move.b  (a2)+,d3
                cmp.b   -4(a2),d0
                bne.s   dohim2
                cmp.b   -3(a2),d3
                beq.s   skiphim2
dohim2:         jsr     (a0)
skiphim2:       addq.w  #1,d1
                cmp.w   d5,d1
                ble.s   loopx2b
                move.w  d7,d1
                addq.w  #1,d2
                lea     80*2(a1),a1
                cmp.w   d6,d2
                ble.s   loopy2b



Start_Clear2:   movem.l (a7),d0-a2                ; Clear Emptiness
                moveq   #32,d6
                move.w  d2,d0
                move.b  Look_Byte(pc),d7
                bsr     Fill_Area
                movem.l (a7)+,d0-a2
                rts

                ENDPART
ScrollRight:    >PART 'Scroll Area Rightwards'
                move.w  d4,-(a7)
                move.w  A_Scroll_R_Rout(pc),d4
                jsr     0(a5,d4.w)
                move.w  (a7)+,d4
                rts

ScrR_all:                                         ; General Scroll Right
* D0=X1   D1=Y1   D2=X2   d3=Y2
                movem.l d0-a2,-(a7)
                move.w  A_Print_Rout(pc),d4
                lea     0(a5,d4.w),a0
                exg     d0,d2

                cmp.w   d0,d2                     ; = Only Emptiness
                beq.s   Start_Clear3

                move.w  d3,d6
                move.w  d2,d5
                move.w  d1,d2
                move.w  d0,d1
                move.w  d0,d7

                addq.w  #1,d5                     ; Skip Emptiness Area

                move.w  d2,d3
                mulu    #80*2,d3
                movea.l Char_Screen(pc),a1
                adda.w  d3,a1

                tst.w   OPT_Flag-s(a5)
                beq.s   DoOPT3

loopy3a:        move.w  d1,d3                     ; UnOptimized Version
                add.w   d3,d3
                lea     0(a1,d3.w),a2
loopx3a:        move.b  -(a2),d3
                move.b  -(a2),d0
                jsr     (a0)
                subq.w  #1,d1
                cmp.w   d5,d1
                bge.s   loopx3a
                move.w  d7,d1
                lea     80*2(a1),a1
                addq.w  #1,d2
                cmp.w   d6,d2
                ble.s   loopy3a
                bra.s   Start_Clear3


DoOPT3:
loopy3b:        move.w  d1,d3                     ; Optimized Version
                add.w   d3,d3
                lea     0(a1,d3.w),a2
loopx3b:        move.b  -(a2),d3
                move.b  -(a2),d0
                cmp.b   2(a2),d0
                bne.s   dohim3
                cmp.b   3(a2),d3
                beq.s   skiphim3
dohim3:         jsr     (a0)
skiphim3:       subq.w  #1,d1
                cmp.w   d5,d1
                bge.s   loopx3b
                move.w  d7,d1
                addq.w  #1,d2
                lea     80*2(a1),a1
                cmp.w   d6,d2
                ble.s   loopy3b



Start_Clear3:   movem.l (a7),d0-a2                ; Clear Emptiness
                moveq   #32,d6
                move.w  d0,d2
                move.b  Look_Byte(pc),d7
                bsr     Fill_Area
                movem.l (a7)+,d0-a2
                rts


* D0=X1   D1=Y1   D2=X2   d3=Y2

                movem.l d0-d5/a0-a1,-(a7)
                movea.l Char_Screen(pc),a0
                move.w  A_Print_Rout(pc),d4
                lea     0(a5,d4.w),a1
                exg     d0,d2
                move.w  d3,d4
                move.w  d2,d3
                move.w  d1,d2
                move.w  d0,d1


copyloop8:      moveq   #0,d5
                cmp.w   d1,d3
                bne.s   copyloop9
                moveq   #-1,d5

copyloop9:      movem.l d0/d3-d4,-(a7)

                move.w  d1,d3
                move.w  d2,d4
                subq.w  #1,d3
                add.w   d3,d3
                mulu    #80*2,d4
                add.w   d3,d4
                move.b  0(a0,d4.w),d0
                move.b  1(a0,d4.w),d3
                ext.w   d0
                ext.w   d3
                tst.w   d5
                beq.s   goahead4
                moveq   #32,d0
                move.b  Look_Byte(pc),d3
goahead4:       jsr     (a1)
                movem.l (a7)+,d0/d3-d4

                subq.w  #1,d1
                cmp.w   d3,d1
                bge.s   copyloop8
                move.w  d0,d1
                addq.w  #1,d2
                cmp.w   d4,d2
                ble.s   copyloop8

                movem.l (a7)+,d0-d5/a0-a1
                rts

                ENDPART

P_CursUp:       >PART 'Move Cursor Up'
                move.w  Y(pc),d0
                cmp.w   Ymin(pc),d0
                ble.s   go1
                subq.w  #1,Y-s(a5)
go1:            rts
                ENDPART
P_CursDown:     >PART 'Move Cursor Down'
                move.w  Y(pc),d0
                cmp.w   Ymax(pc),d0
                bge.s   go2
                addq.w  #1,Y-s(a5)
go2:            rts
                ENDPART
P_CursLeft:     >PART 'Move Cursor Left'
                move.w  X(pc),d0
                cmp.w   Xmin(pc),d0
                ble.s   go3
                subq.w  #1,X-s(a5)
go3:            rts
                ENDPART
P_CursRight:    >PART 'Move Cursor Right'
                move.w  X(pc),d0
                cmp.w   Xmax(pc),d0
                bge.s   go4
                addq.w  #1,X-s(a5)
go4:            rts
                ENDPART
P_CursUpScroll: >PART 'Move Cursor Up,Scroll if top'
                move.w  Y(pc),d0
                cmp.w   Ymin(pc),d0
                ble.s   go5
                subq.w  #1,Y-s(a5)
                rts
go5:
                move.w  Xmin(pc),d0
                move.w  Ymin(pc),d1
                move.w  Xmax(pc),d2
                move.w  Ymax(pc),d3
                bsr     ScrollDown
                rts
                ENDPART
P_ClrHome:      >PART 'Clear Home'
                move.w  Xmin(pc),d0
                move.w  Ymin(pc),d1
                move.w  Xmax(pc),d2
                move.w  Ymax(pc),d3
                moveq   #32,d6
                move.b  Look_Byte(pc),d7
                move.w  OPT_Flag(pc),-(a7)
                move.w  #-1,OPT_Flag-s(a5)
                bsr     Fill_Area
                move.w  (a7)+,OPT_Flag-s(a5)
                move.w  Xmin(pc),X-s(a5)
                move.w  Ymin(pc),Y-s(a5)
                rts
                ENDPART
P_Home:         >PART 'Cursor Home'
                move.w  Xmin(pc),X-s(a5)
                move.w  Ymin(pc),Y-s(a5)
                rts
                ENDPART
P_SetArea:      >PART 'Set Text Area and Home Cursor'
                move.b  (a0)+,d0
                move.b  (a0)+,d1
                move.b  (a0)+,d2
                move.b  (a0)+,d3
                cmp.b   d0,d2
                blo.s   Forget_It
                cmp.b   d1,d3
                blo.s   Forget_It
                ext.w   d0
                bmi.s   Forget_It
                ext.w   d1
                bmi.s   Forget_It
                ext.w   d2
                ext.w   d3
                cmp.w   #Xsize-1,d2
                bhi.s   Forget_It
                cmp.w   #Ysize-1,d3
                bhi.s   Forget_It

                move.w  d0,X-s(a5)
                move.w  d1,Y-s(a5)
                move.w  d0,Xmin-s(a5)
                move.w  d1,Ymin-s(a5)
                move.w  d2,Xmax-s(a5)
                move.w  d3,Ymax-s(a5)
Forget_It:      rts
                ENDPART
P_OverFlow_On:  >PART 'Turn OverFlow detection on'
                clr.w   OverFlow-s(a5)
                rts
                ENDPART
P_OverFlow_Off: >PART 'Turn OverFlow detection off'
                move.w  #-1,OverFlow-s(a5)
                rts
                ENDPART
P_Reverse_On:   >PART 'Turn Reverse On'
                bset    #4,Look_Byte-s(a5)
                rts
                ENDPART
P_Reverse_Off:  >PART 'Turn Reverse Off'
                bclr    #4,Look_Byte-s(a5)
                rts
                ENDPART
P_Mask_On:      >PART 'Turn Mask On'
                bset    #5,Look_Byte-s(a5)
                rts
                ENDPART
P_Mask_Off:     >PART 'Turn Mask Off'
                bclr    #5,Look_Byte-s(a5)
                rts
                ENDPART
P_Color:        >PART 'Set Normal Color'
                move.b  (a0)+,d0
                and.b   #$0F,d0
                andi.b  #$F0,Look_Byte-s(a5)
                or.b    d0,Look_Byte-s(a5)
                rts
                ENDPART
P_Place_Curs_O: >PART 'Place Cursor, Old method.'
                move.b  (a0)+,d0
                ext.w   d0
                sub.w   #32,d0
                move.w  d0,Y-s(a5)
                move.b  (a0)+,d0
                ext.w   d0
                sub.w   #32,d0
                move.w  d0,X-s(a5)
                rts
                ENDPART
P_Place_Curs_F: >PART 'Place Cursor, Full Cordinates.'
                move.b  (a0)+,d0
                ext.w   d0
                move.w  d0,X-s(a5)
                move.b  (a0)+,d0
                ext.w   d0
                move.w  d0,Y-s(a5)
                rts
                ENDPART
P_Place_Curs_W: >PART 'Place Cursor, Window Cord.'
                move.b  (a0)+,d0
                ext.w   d0
                add.w   Xmin(pc),d0
                move.w  d0,X-s(a5)
                move.b  (a0)+,d0
                ext.w   d0
                add.w   Ymin(pc),d0
                move.w  d0,Y-s(a5)
                rts
                ENDPART
P_Place_Curs_X: >PART 'Place Cursor X, Window Cord.'
                move.b  (a0)+,d0
                ext.w   d0
                add.w   Xmin(pc),d0
                move.w  d0,X-s(a5)
                rts
                ENDPART
P_Place_Curs_Y: >PART 'Place Cursor Y, Window Cord.'
                move.b  (a0)+,d0
                ext.w   d0
                add.w   Ymin(pc),d0
                move.w  d0,Y-s(a5)
                rts
                ENDPART
P_Scroll:       >PART 'Scroll Screen'
                move.b  (a0)+,d4
                move.w  Xmin(pc),d0
                move.w  Ymin(pc),d1
                move.w  Xmax(pc),d2
                move.w  Ymax(pc),d3
                cmp.b   #0,d4
                bne.s   nou
                bsr     ScrollUp
                bra.s   nor
nou:            cmp.b   #1,d4
                bne.s   nod
                bsr     ScrollDown
                bra.s   nor
nod:            cmp.b   #2,d4
                bne.s   nol
                bsr     ScrollLeft
                bra.s   nor
nol:            cmp.b   #3,d4
                bne.s   nor
                bsr     ScrollRight
nor:            rts
                ENDPART
P_SaveData:     >PART 'Save Position and so on..'
                move.b  (a0)+,d0
                cmp.b   #15,d0
                bhi.s   now1
                ext.w   d0
                mulu    #SizeOfSavePos,d0
                movea.l Save_Pos_Mem(pc),a0
                adda.w  d0,a0
                bsr     SavePos
now1:           rts
                ENDPART
P_RestoreData:  >PART 'Restore Position and so on..'
                move.b  (a0)+,d0
                cmp.b   #15,d0
                bhi.s   now2
                ext.w   d0
                mulu    #SizeOfSavePos,d0
                movea.l Save_Pos_Mem(pc),a0
                adda.w  d0,a0
                bsr     RestorePos
now2:           rts
                ENDPART
P_VTSave:       >PART 'Save as old VT52 pos'
                move.w  #16*SizeOfSavePos,d0
                movea.l Save_Pos_Mem(pc),a0
                adda.w  d0,a0
                bsr     SavePos
                rts
                ENDPART
P_VTRestore:    >PART 'Restore as old VT52 pos'
                move.w  #16*SizeOfSavePos,d0
                movea.l Save_Pos_Mem(pc),a0
                adda.w  d0,a0
                bsr     RestorePos
                rts
                ENDPART
P_DrawBox:      >PART 'Draw a box at window'

                move.b  (a0)+,d0
                ext.w   d0
                lea     CharTab(pc),a1
                mulu    #12,d0
                adda.w  d0,a1
                move.w  A_Print_Rout(pc),d1
                lea     0(a5,d1.w),a0
                move.b  Look_Byte(pc),d3

                move.b  3(a1),d0
                move.w  Xmin(pc),d1
                move.w  Ymin(pc),d2
                jsr     (a0)
                move.b  5(a1),d0
                move.w  Xmax(pc),d1
                move.w  Ymin(pc),d2
                jsr     (a0)
                move.b  9(a1),d0
                move.w  Xmin(pc),d1
                move.w  Ymax(pc),d2
                jsr     (a0)
                move.b  11(a1),d0
                move.w  Xmax(pc),d1
                move.w  Ymax(pc),d2
                jsr     (a0)

                move.b  2(a1),d0
                move.w  Xmin(pc),d4
                addq.w  #1,d4
                move.w  Xmax(pc),d5
drawline1:      cmp.w   d4,d5                     ; Draw Top/Bottom
                beq.s   linedrawn1
                move.w  d4,d1
                move.w  Ymax(pc),d2
                jsr     (a0)
                move.w  Ymin(pc),d2
                jsr     (a0)
                addq.w  #1,d4
                bra.s   drawline1
linedrawn1:     move.b  1(a1),d0                  ; Draw Left/right
                move.w  Ymin(pc),d4
                addq.w  #1,d4
                move.w  Ymax(pc),d5
drawline2:      cmp.w   d4,d5
                beq.s   linedrawn2
                move.w  d4,d2
                move.w  Xmax(pc),d1
                jsr     (a0)
                move.w  Xmin(pc),d1
                jsr     (a0)
                addq.w  #1,d4
                bra.s   drawline2
linedrawn2:
                rts

                ENDPART
P_OPTon:        >PART 'Turn OPT flag on'
                clr.w   OPT_Flag-s(a5)
                rts
                ENDPART
P_OPToff:       >PART 'Turn OPT flag off'
                move.w  #-1,OPT_Flag-s(a5)
                rts
                ENDPART
P_SP_Save:      >PART 'Save as pos on "stack"'
                movea.l Save_Pos_Pek(pc),a0
                cmpa.l  Save_Pos_Hi(pc),a0
                beq.s   nostackleft
                addq.l  #SizeOfSavePos,Save_Pos_Pek-s(a5)
                bsr.s   SavePos
nostackleft:    rts
                ENDPART
P_SP_Restore:   >PART 'Restore pos from "stack"'
                movea.l Save_Pos_Pek(pc),a0
                cmpa.l  Save_Pos_Low(pc),a0
                beq.s   noneonstack
                subq.l  #SizeOfSavePos,Save_Pos_Pek-s(a5)
                movea.l Save_Pos_Pek(pc),a0
                bsr.s   RestorePos
noneonstack:    rts
                ENDPART

                >PART 'sub Rutines for pos saving'
* a0=address to buf
SavePos:        move.b  X+1(pc),(a0)+
                move.b  Y+1(pc),(a0)+
                move.b  Xmin+1(pc),(a0)+
                move.b  Ymin+1(pc),(a0)+
                move.b  Xmax+1(pc),(a0)+
                move.b  Ymax+1(pc),(a0)+
                move.b  OverFlow+1(pc),(a0)+
                move.b  Look_Byte(pc),(a0)+
                rts
RestorePos:     move.b  (a0)+,X+1-s(a5)
                move.b  (a0)+,Y+1-s(a5)
                move.b  (a0)+,Xmin+1-s(a5)
                move.b  (a0)+,Ymin+1-s(a5)
                move.b  (a0)+,Xmax+1-s(a5)
                move.b  (a0)+,Ymax+1-s(a5)
                move.b  (a0)+,d0
                ext.w   d0
                move.w  d0,OverFlow-s(a5)
                move.b  (a0)+,Look_Byte-s(a5)
                rts
                ENDPART


**********************************************************
Con_Print_Line: >PART 'Print a string'
                movea.l (a6)+,a0
                bsr     String_Print
                move.l  d0,Return-s(a5)
                rts
                ENDPART
Con_Print_Char: >PART 'Print One Byte'
                move.w  (a6)+,d0
                bsr     Do_Char
                rts
                ENDPART
Con_Update:     >PART 'Update a part of the screen'
                move.w  (a6)+,d3
                move.w  (a6)+,d2
                move.w  (a6)+,d1
                move.w  (a6)+,d0
                bsr     Update_Area
                rts
                ENDPART
Con_GetDataTab: >PART 'Get address to Print data tab'
                lea     PrintDataTab(pc),a0
                move.l  a0,Return-s(a5)
                rts
                ENDPART
Con_GetValue:   >PART 'Get ASCII and Attrib'
* out 8-15 ASCII 0-7 Attrib
                move.w  Y(pc),d0
                mulu    #Xsize,d0
                add.w   X(pc),d0
                add.w   d0,d0
                movea.l Char_Screen(pc),a0
                moveq   #0,d1
                move.w  0(a0,d0.w),d1
                move.l  d1,Return-s(a5)
                rts
                ENDPART
Con_SetValue:   >PART 'Set ACII and Attrib'
* 1.w AscII & Attrib
                move.b  (a6)+,d0
                move.b  (a6)+,d3
                move.w  X(pc),d1
                move.w  Y(pc),d2
                move.w  A_Print_Rout(pc),d4
                jsr     0(a5,d4.w)
                rts
                ENDPART
Con_PrintHex:   >PART 'Print hex number'
* 1.l  value
* 1.w  d3=nr of values (2=Byte 4=Word 8=Longword)
                move.w  (a6)+,d3
                move.l  (a6)+,d2

                lea     _HexConvert(pc),a4

                moveq   #7,d1
.conv3:         rol.l   #4,d2
                cmp.w   d3,d1
                bhs.s   .Pernilla3
                move.w  d2,d0
                and.w   #$0F,d0
                move.b  0(a4,d0.w),d0
                and.w   #$FF,d0
                move.w  d0,-(a7)
                move.w  #1,-(a7)
                bsr     Nemesis
                addq.l  #4,a7
*                bsr     Do_Char
.Pernilla3:     dbra    d1,.conv3

                rts
                ENDPART


**********************************************************
Bar_SetPos:     >PART 'Set Bar Selector pos'
* 1.w NewPos

                move.w  (a6)+,d7
                movea.l Bar_Pointer(pc),a6
                cmpa.l  Bar_Tab_Addr(pc),a6
                beq     Error
                movea.l -4(a6),a6

                bsr.s   Draw_Selector
                move.w  d7,12(a6)
                bsr.s   Draw_Selector

                clr.l   Return-s(a5)

                rts

Draw_Selector:  movem.l d0-a6,-(a7)
                tst.w   12(a6)
                bmi     not_draw
                movea.l 4(a6),a0
                moveq   #0,d6
                moveq   #0,d7

s1:             bsr     Skip_Esc
                beq.s   s1
                cmpi.b  #'{',(a0)
                beq.s   s2
                bsr     Skip_Control
                beq.s   s1
                addq.w  #1,d7
                addq.w  #1,a0
                bra.s   s1
s2:             addq.w  #1,a0
                cmp.w   12(a6),d6
                beq.s   s3
                addq.w  #1,d6
                bra.s   s1

s3:             add.w   (a6),d7
                move.w  2(a6),d6
                move.w  18(a6),d0
                and.w   #$0F,d0
                cmp.w   #$0F,d0
                beq.s   skippp
                addq.w  #1,d6
skippp:         movea.l Char_Screen(pc),a1
                movea.l a5,a2
                adda.w  A_Print_Rout(pc),a2
                move.w  d6,d0
                mulu    #Xsize*2,d0
                add.w   d7,d0
                add.w   d7,d0
                adda.w  d0,a1
                moveq   #0,d0

s4:             bsr     Skip_Esc
                beq.s   s4
                cmpi.b  #'}',(a0)
                beq.s   s5
                bsr     Skip_Control
                beq.s   s4

                addq.w  #1,a0
                move.b  (a1)+,d0
                move.w  d7,d1
                move.w  d6,d2

                move.b  (a1)+,d3
                bchg    #4,d3
                addq.w  #1,d7
                jsr     (a2)
                bra.s   s4
s5:


not_draw:       movem.l (a7)+,d0-a6
                rts

                ENDPART
Bar_Update:     >PART 'Update Bar, and send key'
* 1.L  Tos Key

                move.w  (a6)+,d0
                move.b  d0,d5
                swap    d0
                move.b  d0,d6

                movea.l Bar_Pointer(pc),a6
                cmpa.l  Bar_Tab_Addr(pc),a6
                beq     Error
                movea.l -4(a6),a6

                move.w  12(a6),d7
                bsr     Scan_String

                tst.b   14(a6)                    ; left
                bne.s   scan1
                cmp.b   15(a6),d5
                bne.s   notleft
                bra.s   doleft
scan1:          cmp.b   15(a6),d6
                bne.s   notleft
doleft:         move.w  d2,d7
                bra.s   leftdone

notleft:        tst.b   16(a6)                    ; Right
                bne.s   scan2
                cmp.b   17(a6),d5
                bne.s   leftdone
                bra.s   doright
scan2:          cmp.b   17(a6),d6
                bne.s   leftdone
doright:        move.w  d3,d7
leftdone:
                cmp.w   12(a6),d7
                beq.s   nochg

                move.w  d7,-(a7)
                movea.l a7,a6
                bsr     Bar_SetPos
                addq.l  #2,a7

nochg:
                move.w  12(a6),d0                 ; Return POS
                ext.l   d0
                move.l  d0,Return-s(a5)



                rts

                ENDPART
Bar_Redraw:     >PART 'Draw Bar on Screen'
* 1.w Mode
                move.w  (a6)+,d7
                movea.l Bar_Pointer(pc),a6
                cmpa.l  Bar_Tab_Addr(pc),a6
                beq     Error
                movea.l -4(a6),a6

                tst.w   d7
                bne.s   w1
                move.w  18(a6),d2
w1:             cmp.w   #1,d7
                bne.s   w2
                move.w  20(a6),d2
w2:             cmp.w   #2,d7
                bne.s   w3
                move.w  F_Sel_Mode(pc),d2
w3:             cmp.w   #3,d7
                bne.s   w4
                move.w  F_UnSel_Mode(pc),d2
w4:
                bsr.s   Bar_Draw

                move.w  12(a6),-(a7)
                move.w  #-1,12(a6)
                movea.l a7,a6
                bsr     Bar_SetPos
                addq.l  #2,a7

                move.w  12(a6),d0                 ; Return POS
                ext.l   d0
                move.l  d0,Return-s(a5)

                rts


Bar_Draw:
* d2=F_Sel/UnSel
* a6=address to bar tab
                movem.l d0-a6,-(a7)

                lea     FullScreen(pc),a0         ; Save settings and 80x50
                bsr     String_Print
                moveq   #27,d0                    ; Place Cursor
                bsr     Do_Char
                moveq   #'Z',d0                   ; Place Cursor
                bsr     Do_Char
                move.w  (a6),d0
                bsr     Do_Char
                move.w  2(a6),d0
                bsr     Do_Char

                lea     CharTab(pc),a4
                move.w  d2,d7
                and.w   #$0F,d7
                move.w  d7,d6
                mulu    #12,d6
                adda.w  d6,a4
                and.w   #$FF00,d2
                lsr.w   #8,d2
                move.b  d2,Look_Byte-s(a5)

                cmp.b   #$0F,d7
                beq     draw_bartext

                moveq   #10,d0
                bsr     Do_Char
                moveq   #27,d0
                bsr     Do_Char
                moveq   #")",d0
                bsr     Do_Char

                movea.l 4(a6),a0                  ; Get String
wd5:            bsr     Do_Esc
                beq.s   wd5
                bsr     Skip_Control
                beq.s   wd5
                move.b  (a0)+,d0
                beq.s   wd1
                move.b  2(a4),d2
                move.b  2(a4),d1
                cmp.b   #'[',d0
                bne.s   wd2
                move.b  3(a4),d2
                move.b  9(a4),d1
wd2:            cmp.b   #']',d0
                bne.s   wd3
                move.b  5(a4),d2
                move.b  11(a4),d1
wd3:            cmp.b   #':',d0
                bne.s   wd4
                move.b  4(a4),d2
                move.b  10(a4),d1
wd4:
                moveq   #27,d0
                bsr     Do_Char
                moveq   #"A",d0
                bsr     Do_Char
                move.w  d2,d0
                bsr     Do_Char
                moveq   #10,d0
                bsr     Do_Char
                moveq   #10,d0
                bsr     Do_Char
                moveq   #27,d0
                bsr     Do_Char
                moveq   #"D",d0
                bsr     Do_Char
                move.w  d1,d0
                bsr     Do_Char
                moveq   #27,d0
                bsr     Do_Char
                moveq   #"A",d0
                bsr     Do_Char

                bra.s   wd5
wd1:
                moveq   #27,d0
                bsr     Do_Char
                moveq   #"(",d0
                bsr     Do_Char


draw_bartext:   movea.l 4(a6),a0                  ; Get String
drawnext:       bsr     Do_Esc
                beq.s   drawnext
                bsr     Skip_Control
                beq.s   drawnext
                bsr     Skip_Linefix
                beq.s   specchar

                move.b  (a0)+,d0
                tst.b   d0
                beq.s   alldrawn
                bsr     Do_Char
                bra.s   drawnext
specchar:       move.b  1(a4),d0
                bsr     Do_Char
                bra.s   drawnext
alldrawn:

                lea     NormalScreen(pc),a0       ; Restore settings
                bsr     String_Print

                movem.l (a7)+,d0-a6
                rts



                ENDPART
Bar_Open:       >PART 'Open a bar'
* 1.L Adddress
* 1.W X
* 1.W Y
                move.l  a6,-(a7)                  ; Unmark last bar
                movea.l Bar_Pointer(pc),a6
                cmpa.l  Bar_Tab_Addr(pc),a6
                beq.s   FirstOne
                move.w  #1,-(a7)
                movea.l a7,a6
                bsr     Bar_Redraw
                addq.l  #2,a7
FirstOne:       movea.l (a7)+,a6

                move.w  (a6)+,d1
                move.w  (a6)+,d0
                movea.l (a6)+,a0
                movem.l d0/a0,-(a7)
                move.l  #22,d0
                bsr     Reserve_Mem
                movea.l a0,a6
                movem.l (a7)+,d0/a0
                cmpa.l  #0,a6
                beq     Error

                move.w  d0,(a6)
                move.w  d1,2(a6)
                move.l  a0,4(a6)

                movem.l d2-d4,-(a7)
                move.l  d0,-(a7)
                bsr     GetLenght
                add.w   (a6),d0
                subq.w  #1,d0
                move.w  d0,d2
                move.l  (a7)+,d0
                move.w  d1,d3
                move.w  F_Sel_Mode(pc),d4
                and.w   #$0F,d4
                cmp.w   #$0F,d4
                beq.s   No_Box_Man
                addq.w  #2,d3
No_Box_Man:
                bsr     Save_Area
                movem.l (a7)+,d2-d4

                move.l  a0,8(a6)
                move.w  #0,12(a6)
                move.w  #$FF4B,14(a6)
                move.w  #$FF4D,16(a6)
                move.w  F_Sel_Mode(pc),18(a6)
                move.w  F_UnSel_Mode(pc),20(a6)

                movea.l Bar_Pointer(pc),a1
                move.l  a6,(a1)+
                move.l  a1,Bar_Pointer-s(a5)

                move.w  #0,-(a7)                  ; ReDraw, Selected
                movea.l a7,a6
                bsr     Bar_Redraw
                addq.l  #2,a7
                rts


                ENDPART
Bar_Close:      >PART 'Close Bar'
                movea.l Bar_Pointer(pc),a6
                cmpa.l  Bar_Tab_Addr(pc),a6
                beq     Error
                movea.l -4(a6),a6
                subq.l  #4,Bar_Pointer-s(a5)
                movea.l 8(a6),a0
                cmpa.l  #-1,a0
                beq.s   No_Area
                bsr     Rest_Area
No_Area:
                movea.l a6,a0
                bsr     Free_Mem

                movea.l Bar_Pointer(pc),a6        ; Mark
                cmpa.l  Bar_Tab_Addr(pc),a6
                beq.s   FirstOne2
                move.w  #0,-(a7)
                movea.l a7,a6
                bsr     Bar_Redraw
                addq.l  #2,a7
FirstOne2:
                rts
                ENDPART
Bar_Take_Con:   >PART 'Take Control of bar'
* 1.w Mode  0= Take the active bar
*           1= Take the active bar, close when finished
*        bit 0  1=Close
* out: Resulting Pos or -1 if error
                move.w  (a6)+,d7
keyloop:        move.w  #$70,-(a7)
                jsr     (a5)
                addq.l  #2,a7
                cmp.b   #13,d0
                beq.s   Pressed_CCR
                move.l  d0,-(a7)
                move.w  #$83,-(a7)
                jsr     (a5)
                addq.l  #6,a7
                bra.s   keyloop
Pressed_CCR:    clr.l   -(a7)
                move.w  #$83,-(a7)
                jsr     (a5)
                addq.l  #6,a7
                move.l  d0,d6
                btst    #0,d7
                beq.s   not_close
                move.w  #$81,-(a7)
                jsr     (a5)
                addq.l  #2,a7
                bmi.s   felfel
not_close:      move.l  d6,Return-s(a5)
felfel:         rts
                ENDPART
                >PART 'Bar special inside routines'

******************************************************

Scan_String:
* a6=bar data
* out d0=Lowest pos
*     d1=Highest pos
*     d2=Pos to the left (warp included)
*     d3=Pos to the right (warp included)
* If no position was avaiable, the -1 on all!

                movem.l d4-a0,-(a7)
                movea.l 4(a6),a0
                moveq   #-1,d0                    ; Lowest Found
                moveq   #-1,d1                    ; Highest Found
                moveq   #-1,d2                    ; To the Left
                moveq   #-1,d3                    ; To The Right
                moveq   #0,d4                     ; 0=no ~ found,  -1 got one
                moveq   #0,d5                     ; internal counter

r1:             bsr.s   Skip_Esc
                beq.s   r1
                bsr     Skip_Linefix
                beq.s   r1
                move.b  (a0)+,d7
                beq.s   all_clear
                cmp.b   #'~',d7
                bne.s   r2
                moveq   #-1,d4
                bra.s   r1
r2:             cmp.b   #'{',d7
                bne.s   r1

                tst.w   d4
                bne.s   klammerdone
                move.w  d5,d1                     ;(Highest)
                tst.w   d0
                bpl.s   r3
                move.w  d5,d0                     ;(lowest)
r3:             cmp.w   12(a6),d5
                bhs.s   r4
                move.w  d5,d2                     ;(left)
r4:             tst.w   d3
                bpl.s   r7
                cmp.w   12(a6),d5
                bls.s   r7
                move.w  d5,d3                     ;(right)
r7:

klammerdone:    moveq   #0,d4
                addq.w  #1,d5
                bra.s   r1

all_clear:
                tst.w   d2                        ; Warp
                bpl.s   r5
                move.w  d1,d2
r5:             tst.w   d3
                bpl.s   r6
                move.w  d0,d3
r6:
                movem.l (a7)+,d4-a0
                rts


**********************************************

Skip_Esc:       cmpi.b  #27,(a0)                  ; Skips ESC comand and makes
                bne.s   noesc                     ; beq true if esc was found
                addq.l  #1,a0                     ; and bne if not found
                movem.l d0/a1,-(a7)
                move.b  (a0)+,d0
                lea     Amount_Tab(pc),a1
lookmore:       cmp.b   (a1)+,d0
                bmi.s   existnot
                beq.s   found
                addq.w  #3,d0
                bra.s   lookmore
found:          move.b  (a1)+,d0
                ext.w   d0
                adda.w  d0,a0
existnot:       movem.l (a7)+,d0/a1
                move    #4,ccr
                rts
noesc:          move    #0,ccr
                rts

**********************************************

Do_Esc:         cmpi.b  #27,(a0)                  ; Executes ESC command if any.
                bne.s   noesc2                    ; also makes BEQ true if
                move.w  d0,-(a7)                  ; ESC command was found
moreesc:        move.b  (a0)+,d0
                bsr     Do_Char
                tst.w   EscDoing-s(a5)
                bne.s   moreesc
                move.w  (a7)+,d0
                move    #4,ccr
                rts
noesc2:         move    #0,ccr
                rts

**********************************************

Skip_Linefix:   cmpi.b  #'[',(a0)                 ; If line command if found
                beq.s   LineCh                    ; it is skipped and BEQ is
                cmpi.b  #']',(a0)                 ; true
                beq.s   LineCh
                cmpi.b  #':',(a0)
                beq.s   LineCh
                move    #0,ccr
                rts
LineCh:         addq.w  #1,a0
                move    #4,ccr
                rts

**********************************************

Skip_Control:   cmpi.b  #'~',(a0)                 ; Skip Control, beq true if
                beq.s   ControlCh                 ; control found
                cmpi.b  #'@',(a0)
                beq.s   ControlCh
                cmpi.b  #'{',(a0)
                beq.s   ControlCh
                cmpi.b  #'}',(a0)
                beq.s   ControlCh
                move    #0,ccr
                rts
ControlCh:      addq.w  #1,a0
                move    #4,ccr
                rts

**********************************************

SkipConLin:     bsr.s   Skip_Control              ; Skip's both command
                beq.s   SkipConLin                ; types. Z is NOT set as
                bsr.s   Skip_Linefix              ; a result (hehe)
                beq.s   SkipConLin
                rts

GetLenght:      movem.l d1-a6,-(a7)
                movea.l 4(a6),a0
                moveq   #0,d0
Strunta:        bsr.s   Skip_Control
                beq.s   Strunta
                bsr     Skip_Esc
                beq.s   Strunta
                tst.b   (a0)+
                beq.s   EnoughStrunt
                addq.w  #1,d0
                bra.s   Strunta
EnoughStrunt:   movem.l (a7)+,d1-a6
                rts

**********************************************
                ENDPART
**********************************************************
Win_Open:       >PART 'Open a window area'
* 1.w   x1   (of work area)
* 1.w   y1
* 1.w   x2
* 1.w   y2
* 1.w   Border Attribute
* 1.w   Special flags
*       bit 0    1=Don't Clear window
*       bit 1    1=Don't Save area
                move.w  (a6)+,d5
                move.w  (a6)+,d4
                move.w  (a6)+,d3
                move.w  (a6)+,d2
                move.w  (a6)+,d1
                move.w  (a6)+,d0
                move.l  d0,-(a7)
                move.l  #48,d0
                bsr     Reserve_Mem
                move.l  (a7)+,d0
                move.l  a0,Return-s(a5)
                movea.l a0,a4
                move.w  d0,(a4)
                move.w  d1,2(a4)
                move.w  d2,4(a4)
                move.w  d3,6(a4)
                move.l  #-1,8(a4)
                btst    #1,d5
                bne.s   .NoScrSave
                move.w  d4,d7
                and.w   #$0F,d7
                cmp.b   #$0F,d7
                beq.s   .Phuu
                subq.w  #1,d0
                subq.w  #1,d1
                addq.w  #1,d2
                addq.w  #1,d3
.Phuu:          bsr     Save_Area
                move.l  a0,8(a4)
.NoScrSave:     move.w  d4,12(a4)
                move.w  d4,14(a4)

                moveq   #27,d0
                bsr     Do_Char
                moveq   #')',d0
                bsr     Do_Char

                lea     _OpenWinT(pc),a0          ; Draw lines, open window
                move.b  1(a4),2(a0)
                move.b  3(a4),3(a0)
                move.b  5(a4),4(a0)
                move.b  7(a4),5(a0)
                subq.b  #1,2(a0)
                subq.b  #1,3(a0)
                addq.b  #1,4(a0)
                addq.b  #1,5(a0)
                move.b  1(a4),11(a0)
                move.b  3(a4),12(a0)
                move.b  5(a4),13(a0)
                move.b  7(a4),14(a0)
                move.w  14(a4),d0
                and.w   #$0F,d0
                cmp.w   #$0F,d0
                bne.s   .BorderYes
                lea     9(a0),a0                  ; Skip Border text
.BorderYes:     move.b  d0,8(a0)
                bsr     String_Print

                btst    #0,d5                     ; Clear window?
                beq.s   .NotClear
                moveq   #27,d0
                bsr     Do_Char
                moveq   #'E',d0
                bsr     Do_Char
.NotClear:
                lea     16(a4),a0                 ; Save con data (win)
                bsr     SavePos

                moveq   #27,d0
                bsr     Do_Char
                moveq   #'(',d0
                bsr     Do_Char

                rts
                ENDPART
Win_Close:      >PART 'Close a opened window'
* 1.l Address to window tab
                movea.l (a6)+,a4
                movea.l 8(a4),a0
                bsr     Rest_Area
                movea.l a4,a0
                bsr     Free_Mem
                rts

                ENDPART
Win_ChgBorder:  >PART 'Change border of window'
                ENDPART
Win_Print:      >PART 'Print String in window'
* 1.l Address to window tab
* 1.l Address to string to print
                movea.l (a6)+,a3
                movea.l (a6)+,a4
                moveq   #27,d0
                bsr     Do_Char
                moveq   #')',d0
                bsr     Do_Char

                lea     16(a4),a0
                bsr     RestorePos

                movea.l a3,a0
                bsr     String_Print


                lea     16(a4),a0
                bsr     SavePos

                moveq   #27,d0
                bsr     Do_Char
                moveq   #'(',d0
                bsr     Do_Char
                rts

                ENDPART
Win_PrintChar:  >PART 'Print Char in window'
* 1.l Address to window tab
* 1.w Char to print
                move.w  (a6)+,d7
                movea.l (a6)+,a4
                moveq   #27,d0
                bsr     Do_Char
                moveq   #')',d0
                bsr     Do_Char

                lea     16(a4),a0
                bsr     RestorePos

                move.w  d7,d0
                bsr     Do_Char

                lea     16(a4),a0
                bsr     SavePos

                moveq   #27,d0
                bsr     Do_Char
                moveq   #'(',d0
                bsr     Do_Char
                rts

                ENDPART
Win_CopyCon:    >PART 'Copy window arguments to CON'
* 1.l address to window tab
                movea.l (a6)+,a4
                lea     16(a4),a0
                bsr     RestorePos
                rts
                ENDPART

                >PART 'Window Routs'
_OpenWinT:      DC.B 27,"a",0,0,0,0               ; 2,3,4,5
                DC.B 27,"#",0                     ; 8
                DC.B 27,"a",0,0,0,0               ; 11,12,13,14
                DC.B 0
                EVEN
                ENDPART
                >PART 'Tab doc'
*                DS.W 1                            ; 0  X1 Pos (of work area)
*                DS.W 1                            ; 2  Y1 Pos (of work area)
*                DS.W 1                            ; 4  X2 Pos (of work area)
*                DS.W 1                            ; 6  X3 Pos (of work area)
*                DS.L 1                            ; 8  address to save area buf
*                DS.W 1                            ; 12  Open Attribute (only on border)
*                DS.W 1                            ; 14  Current Attribute (only on border)
*                DS.B 32                           ; 16  Windows work term data
* 48
*
                ENDPART
**********************************************************
Gen_Set_Sel:    >PART 'Set Select Flags'
* 1.W new select mode
* ret:
                move.w  (a6)+,F_Sel_Mode-s(a5)
                rts
                ENDPART
Gen_Get_Sel:    >PART 'Get Select Flags'
* ret: select mode
                move.w  F_Sel_Mode(pc),Return-s+2(a5)
                rts
                ENDPART
Gen_Set_UnSel:  >PART 'Set UnSelect Flags'
* 1.W new select mode
* ret:
                move.w  (a6)+,F_UnSel_Mode-s(a5)
                rts
                ENDPART
Gen_Get_UnSel:  >PART 'Get UnSelect Flags'
* ret: select mode
                move.w  F_UnSel_Mode(pc),Return-s+2(a5)
                rts
                ENDPART
Gen_Get_FontP:  >PART 'Get Address To Font Pointer'
* ret: Address to font
                lea     Font_Point(pc),a0
                move.l  a0,Return-s(a5)
                rts
                ENDPART
Gen_Set_Mask:   >PART 'Set Mask Data'
* 1.L address to new mask (16 words)
* ret:
                movea.l (a6)+,a0
                lea     Mask(pc),a1
                move.w  #15,d0
copy_mask:      move.w  (a0)+,(a1)+
                dbra    d0,copy_mask
                rts
                ENDPART
Gen_Get_Mask:   >PART 'Get Address To Mask'
* ret:  Address to Mask
                lea     Mask(pc),a0
                move.l  a0,Return-s(a5)
                rts
                ENDPART
Gen_Get_Screen: >PART 'Get Address to Char Screen'
* out   Address to Character Screen
                move.l  Char_Screen(pc),Return-s(a5)
                rts
                ENDPART
Gen_Set_Screen: >PART 'Set Char Screen Address'
* 1.l  Char Screen Address to use
                move.l  (a6)+,Char_Screen-s(a5)
                rts
                ENDPART

Gen_Open_Work:  >PART 'Open WorkStation'
* out:  -1=Not enough memory
                move.l  #Xsize*Ysize*2,d0
                bsr     Reserve_Mem
                ble     Error
                move.l  a0,Char_Screen-s(a5)
                move.l  #64*4,d0
                bsr     Reserve_Mem
                ble     Error
                move.l  a0,Bar_Tab_Addr-s(a5)
                move.l  a0,Bar_Pointer-s(a5)

                move.l  #(17+StackSavePos)*SizeOfSavePos,d0
                bsr     Reserve_Mem
                ble     Error
                move.l  a0,Save_Pos_Mem-s(a5)
                lea     17*SizeOfSavePos(a0),a0
                move.l  a0,Save_Pos_Pek-s(a5)
                move.l  a0,Save_Pos_Low-s(a5)
                lea     StackSavePos*SizeOfSavePos(a0),a0
                move.l  a0,Save_Pos_Hi-s(a5)
                rts
                ENDPART
Gen_Close_Work: >PART 'Close WorkStation'
* out:  -1=Error
                movea.l Char_Screen(pc),a0
                bsr     Free_Mem
                bmi     Error

                movea.l Bar_Tab_Addr(pc),a0
                bsr.s   Free_Mem
                bmi     Error

                movea.l Save_Pos_Mem(pc),a0
                bsr.s   Free_Mem
                bmi     Error

                rts
                ENDPART

Gen_Set_Graph:  >PART 'Set Graphics Resolution'
* 1.W New graphmode
* ret: old mode
                move.w  F_Graph_Mode(pc),Return-s+2(a5)
                move.w  (a6)+,F_Graph_Mode-s(a5)
                rts
                ENDPART
Gen_Set_Memory: >PART 'Set Free Memory Address'
* 1.L  End Of memory if not using Malloc
* 1.L  Memory address, -1 for Malloc
* ret: old memory address
                move.l  Memory_Base(pc),Return-s(a5)
                move.l  (a7)+,Memory_End-s(a5)
                move.l  (a7)+,Memory_Base-s(a5)
                rts
                ENDPART
**********************************************************
Any_Rese_Mem:   >PART 'Reserve Memory'
* 1.l Amount
* out: Address to saved area, or null if error
                move.l  (a6)+,d0
                bsr.s   Reserve_Mem
                move.l  a0,Return-s(a5)
                rts
                ENDPART
Any_Free_Mem:   >PART 'Release Memory'
* 1.l Address to Saved area to be released
* out: Null if OK, negative if error
                movea.l (a6)+,a0
                bsr.s   Free_Mem
                move.l  a0,Return-s(a5)
                rts
                ENDPART
Any_Save_Blk:   >PART 'Save a part of the screen'
* 1.w x1
* 1.w y1
* 1.w x2
* 1.w y2
* out: Address to Block
                move.w  (a6)+,d3
                move.w  (a6)+,d2
                move.w  (a6)+,d1
                move.w  (a6)+,d0
                bsr.s   Save_Area
                move.l  a0,Return-s(a5)
                rts
                ENDPART
Any_Rest_Blk:   >PART 'Restore a saved block'
* 1.l address to saved block
* out : negative if error
                movea.l (a6)+,a0
                bsr.s   Rest_Area
                rts
                ENDPART
**********************************************************
Key_Conin:      >PART 'Wait for key'
* no input
* out:  key as Gemdos
                move.w  #7,-(a7)
                trap    #1
                addq.l  #2,a7
                move.l  d0,Return-s(a5)
                rts
                ENDPART
**********************************************************
Reserve_Mem:    >PART 'Reserve Memory'
* d0=amout to be reserved
* out: A0=address
* SR   BLE will be true if there was no memory..
                movem.l d1-d7/a1-a6,-(a7)
                move.l  d0,-(a7)
                move.w  #$48,-(a7)
                trap    #1
                addq.l  #6,a7
                movea.l d0,a0
                movem.l (a7)+,d1-d7/a1-a6
                tst.l   d0
                rts
                ENDPART
Free_Mem:       >PART 'Free Memory'
* A0= address to free
* out: D0=0 if ok, otherwise -1
*      beq will be true if no error.
*      bne will be true if error.
                movem.l d1-a6,-(a7)
                move.l  a0,-(a7)
                move.w  #$49,-(a7)
                trap    #1
                addq.l  #6,a7
                movem.l (a7)+,d1-a6
                tst.w   d0
                rts
                ENDPART
Save_Area:      >PART 'Save a part of the screen'
* d0=x1
* d1=y1
* d2=x2
* d3=y2
* out a0=address, -1 if error
                movem.w d4,-(a7)
                move.w  Save_Area_Char(pc),d4
                lea     0(a5,d4.w),a0
                jsr     (a0)
                movem.w (a7)+,d4
                rts
                ENDPART
Rest_Area:      >PART 'Restore a saved area'
* a0=address to block
                cmpa.l  #-1,a0
                beq.s   .Fools
                movem.l d0/a0-a1,-(a7)
                move.w  10(a0),d0
                lea     0(a5,d0.w),a1
                jsr     (a1)
                movem.l (a7)+,d0/a0-a1
.Fools:         rts
                ENDPART
Save_Area_C1:   >PART 'Save Char, Standard'
* d0=x1
* d1=y1
* d2=x2
* d3=y2
* out:  a0=address, -1 if there wasn't enough memory
                movem.l d0-d7/a1-a6,-(a7)
                movem.w d0-d3,-(a7)
                movem.w (a7)+,d4-d7

                move.w  d6,d0
                sub.w   d4,d0
                addq.w  #1,d0
                move.w  d7,d1
                sub.w   d5,d1
                addq.w  #1,d1
                mulu    d1,d0
                add.l   d0,d0
                add.l   #16,d0
                bsr     Reserve_Mem
                movea.l a0,a6
                ble.s   couldnt1
                move.w  d4,(a0)+
                move.w  d5,(a0)+
                move.w  d6,(a0)+
                move.w  d7,(a0)+
                move.w  F_Graph_Mode(pc),(a0)+
                move.w  Rest_Area_Char(pc),(a0)+
                clr.l   (a0)+

                movea.l Char_Screen(pc),a1
                move.w  d4,d0
                add.w   d0,d0
                adda.w  d0,a1
                move.w  d5,d0
                mulu    #Xsize*2,d0
                adda.w  d0,a1

                sub.w   d5,d7
                sub.w   d4,d6
loopy:          movea.l a1,a2
                lea     80*2(a1),a1
                move.w  d6,d4
loopx:          move.w  (a2)+,(a0)+
                dbra    d4,loopx
                dbra    d7,loopy
                movea.l a6,a0
sluta_nu:       movem.l (a7)+,d0-d7/a1-a6
                rts
couldnt1:       lea     -1.w,a0
                bra.s   sluta_nu
                ENDPART
Rest_Area_C1:   >PART 'Restore Chars, Standard'
* A0=address to saved block
                movem.l d0-a6,-(a7)
                movea.l a0,a4
                move.w  (a0)+,d4
                move.w  (a0)+,d5
                move.w  (a0)+,d6
                move.w  (a0)+,d7
                addq.l  #8,a0

                movea.l Char_Screen(pc),a1
                move.w  d4,d0
                add.w   d0,d0
                adda.w  d0,a1
                move.w  d5,d0
                mulu    #Xsize*2,d0
                adda.w  d0,a1

                sub.w   d5,d7
                sub.w   d4,d6
loopy2:         movea.l a1,a2
                lea     80*2(a1),a1
                move.w  d6,d4
loopx2:
                move.w  (a0)+,(a2)+
                dbra    d4,loopx2
                dbra    d7,loopy2

                movea.l a4,a0
                move.w  (a4)+,d0
                move.w  (a4)+,d1
                move.w  (a4)+,d2
                move.w  (a4)+,d3
                bsr     Update_Area

                bsr     Free_Mem

                movem.l (a7)+,d0-a6
                rts

                ENDPART

Error:          move.l  #-1,Return-s(a5)
                rts

FullScreen:     DC.B 27,")",27,"a",0,0,Xsize-1,Ysize-1,0
NormalScreen:   DC.B 27,"(",0
                EVEN

* data:    0-3  Color
*          4    On=Inverse Off=Not Inverse
*          5    On=Masked  Off=Not Masked
*          6-7  Background color
Save_Pos_Mem:   DS.L 1
Save_Pos_Pek:   DS.L 1
Save_Pos_Hi:    DS.L 1
Save_Pos_Low:   DS.L 1

Bar_Tab_Addr:   DS.L 1
Bar_Pointer:    DS.L 1                            ; Bar's works like a stack, here's the pointer

F_Save_Scr:     DC.W 0


_HexConvert:    DC.B "0123456789ABCDEF"


F_Sel_Mode:     DC.W $1000
* 0-4    Line type to use on box
* 8-15   Look Byte
F_UnSel_Mode:   DC.W $3001
* 0-4    Line type to use on box
* 8-15   Look Byte

F_Graph_Mode:   DC.W -1
* -1 = Take Xbios(4)
* 0  = Force Low Resolution
* 2  = Force Medium Resolution
* 3  = Force High Resolution

Memory_End:     DC.L -1                           ; If not using Malloc
Memory_Base:    DC.L -1
Font_Point:     DS.L 1
* -1 = Use Malloc
* n  = Address to start of free memory base

*************
**** Pointers
*************
Save_Area_Char: DC.W Save_Area_C1-s
Save_Area_Img:  DC.W Save_Area_C1-s
Rest_Area_Char: DC.W Rest_Area_C1-s
Rest_Area_Img:  DC.W Rest_Area_C1-s


                >PART 'Mask and CharTabel'
CharTab:
                DC.B " ∫Õ"                        ; 0
                DC.B "…Àª"
                DC.B "ÃŒπ"
                DC.B "» º"
                DC.B " ≥ƒ"                        ; 1
                DC.B "⁄¬ø"
                DC.B "√≈¥"
                DC.B "¿¡Ÿ"
                DC.B " ∫ƒ"                        ; 2
                DC.B "÷“∑"
                DC.B "«◊∂"
                DC.B "”–Ω"
                DC.B " ≥Õ"                        ; 3
                DC.B "’—∏"
                DC.B "∆ÿµ"
                DC.B "‘œæ"
                DC.B " €€"                        ; 4
                DC.B "€€€"
                DC.B "€€€"
                DC.B "€€€"
                DC.B " ≤≤"                        ; 5
                DC.B "≤≤≤"
                DC.B "≤≤≤"
                DC.B "≤≤≤"
                DC.B " ±±"                        ; 6
                DC.B "±±±"
                DC.B "±±±"
                DC.B "±±±"
                DC.B " ∞∞"                        ; 7
                DC.B "∞∞∞"
                DC.B "∞∞∞"
                DC.B "∞∞∞"
                DC.B " ≥ƒ"                        ; 8
                DC.B "ÙÙÙ"
                DC.B "≥≈≥"
                DC.B "ııı"
                DS.B 7*12,32




Mask:           DC.W %1010101010101010
                DC.W %101010101010101
                DC.W %1010101010101010
                DC.W %101010101010101
                DC.W %1010101010101010
                DC.W %101010101010101
                DC.W %1010101010101010
                DC.W %101010101010101
                DC.W %1010101010101010
                DC.W %101010101010101
                DC.W %1010101010101010
                DC.W %101010101010101
                DC.W %1010101010101010
                DC.W %101010101010101
                DC.W %1010101010101010
                DC.W %101010101010101
                ENDPART

***********************************************************
******* END OF NEMESIS
***********************************************************
                END
