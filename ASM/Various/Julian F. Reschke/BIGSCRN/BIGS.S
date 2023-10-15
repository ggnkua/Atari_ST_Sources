; BigScreen
; Copyright (c) 1988   Julian F. Reschke

; Assembler: MadMac 1.03



        include atari

.macro  intasc 
        .dc.b   "0" + (\1 / 10),"0" + (\1 % 10)
.endm

.macro  date
        intasc  ^^date & %0000000000011111
        dc.b    "."
        intasc  (^^date & %0000000111100000) >>5
        dc.b    "."
        intasc  (((^^date & %1111111000000000) >>9) + 80) % 100
.endm

.macro  time
        intasc  (^^time & %1111100000000000) >>11
        dc.b    ":"
        intasc  (^^time & %0000011111100000) >>5
        dc.b    ":"
        intasc  ^^time & %0000000000011111
.endm

M_POS_HX        = -$358
M_POS_HY        = -$356
GCURX           = -$25a
GCURY           = -$258
WKXRez          = -$2b4
WKYRez          = -$2b2
WKXSize         = -$2ae
WKYSize         = -$2ac
CUR_X            = -$158
CUR_Y            = -$156
CUR_FLAG        = -$154
MOUSE_FLAG      = -$153
SAVE_LEN        = -$14a
V_CEL_HT        = -$2e
V_CEL_MX        = -$2c
V_CEL_MY        = -$2a
V_CEL_WR        = -$28
V_REZ_HZ        = -$c
V_REZ_VT        = -4
BYTES_LIN        = -2
v_planes        = 0
WIDTH            = 2


        .text

Anfang:
Start:

        pea     Title
        bsr     Print

        Supexec #InstTest

        
        Kbdvbase
        move.l  d0,MouseVec     

        sf      BadTos
        move.w  #$30,-(sp)
        trap    #1
        addq    #2,sp
        cmp.w   #$1500,d0
        bge.s   TosIsOK
        st      BadTos

        pea     OddTos
        bsr     Print

TosIsOK:
        clr.l   LineA
        clr.w   LastYPos
        clr.w   LastXPos
        clr.l   LastAdr
        clr.w   Counter

        Kbshift #-1
        tst.w   d0
        beq.s   NoHold
        bsr     SetUp
NoHold:
        cmp.w   #639,XRez
        bne.s   Anders1
        move.w  DefY,d0
        cmp.w   #399,YRez
        beq     Abort
Anders1:
        pea     Inst
        bsr     Print


        move.l  4(sp),a0        ; Basepage
        move.l  #$100,d0        ; 256 Bytes Basepage
        add.l   $C(a0),d0       ; p_lten
        add.l   $14(a0),d0      ; p_dlen
        add.l   $1C(a0),d0      ; p_blen
        clr.l   d1
        move.w  XRez,d1
        addq.w  #1,d1
        lsr.w   #3,d1           ; 8 Pixel/Zeile als Berechnungsgrundlage
        add.w   #1,YRez
        mulu.w  YRez,d1
        sub.w   #1,YRez
        add.l   d1,d0
        add.l   #256+80,d0
        tst.w   BadTos
        beq.s   .TosIsOK
        add.l   #32768,d0
.TosIsOK:
        move.l  4(a0),d1
        sub.l   0(a0),d1
        cmp.l   d1,d0
        bgt.s   LowOnMemory

        clr.w   -(sp)
        move.l  d0,-(sp)

        ; Bildschirm setzen

        move.l  #BigScreen+255,d0
        tst.w   BadTos
        beq.s   .TosIsOK2
        add.l   #32768,d0
.TosIsOK2:
        and.l   #$ffffff00,d0
        move.l  d0,ScreenPtr
        move.w  #-1,-(sp)

        move.w  DefX,d1
        cmp.w   XRez,d1
        bne.s   StrangeScreen

        move.l  d0,-(sp)
        bra     NormScreen

StrangeScreen:
        move.l  #-1,-(sp)       


NormScreen:
        move.l  d0,-(sp)
        move.w  #5,-(sp)
        trap    #14
        lea     12(sp),sp

        Supexec #Install

        ; und Ende

        move.w  #49,-(sp)       ; Ptermres
        trap    #1

LowOnMemory:
        pea     LMem
        bsr     Print
Schluss:
        Pterm0

Abort:
        pea     NotInst
        bsr     Print
        bra.s   Schluss


InstTest:
        move.l  $88,a0
        bsr     TestXBRA
        move.l  $502,a0
        bsr     TestXBRA
AdRTS:  rts

TestXBRA:
        cmp.l   #$58425241,-12(a0)      
        bne.s   AdRTS
        cmp.l   #$42494753,-8(a0)
        beq.s   IsDa
        move.l  -4(a0),a0
        beq.s   AdRTS
        bra.s   TestXBRA        

IsDa:
        pea     SchonDa
        bsr     Print
        bra     Schluss

Install:
        move.l  $88,OldVec
        move.l  #MyTr2,$88


        dc.w    $a000
        move.l  a0,LineA

        move.w  $454,d0  ; nvbls
        lsl.w   #2,d0
        move.l  $456,a0  ; _vblqueue
        moveq   #4,d1
SSlot:  tst.l   0(a0,d1)        ; frei?
        beq.s   SFound
        addq    #4,d1
        cmp.w   d0,d1           ; Ende erreicht?
        bne.s   SSlot
        rts
SFound:
        move.l  #MyVB,0(a0,d1)
        rts


        dc.b    "XBRABIGS"
OldVec: dc.l    0

MyTr2:
        tst.b   Patched
        bne.s   Normal
        cmp.w   #$73,d0
        bne.s   Normal
        move.l  d1,a0
        move.l  12(a0),IntOut
        move.l  (a0),a0
        cmp.w   #1,(a0)
        bne.s   Normal

        move.l  2(sp),Back
        move.l  #Patch,2(sp)

Normal:
        move.l  OldVec,a0
        jmp     (a0)


Patch:
        clr.w   d0
        move.b  sshiftmd,d0
        lea     Rezs,a0
        lsl.w   #2,d0
        move.l  (a0,d0.w),DefX
        lea     Sizes,a0
        move.l  (a0,d0.w),SizeX 

        lsl.w   #1,d0
        lea     Ranges,a0
        move.l  (a0,d0.w),RangeDn
        move.l  4(a0,d0.w),RangeDn+4

        bsr     SetUpLineA
        move.l  IntOut,a0
        move.w  YRez,2(a0)
        move.w  XRez,0(a0)
        move.l  SizeX,6(a0)


        Setscreen ScreenPtr,#-1,#-1

        cmp.b   #2,sshiftmd
        bne.s   .NotHigh
        move.l  $502,OldHrd
        move.l  #MyHard,$502
.NotHigh:
        st      Patched
        move.l  Back,-(sp)
        rts

SetUpLineA:
        add.w   #1,XRez
        add.w   #1,YRez
        move.b  sshiftmd,d0     
        cmp.b   #1,d0
        bgt.s   .RezSet
        move.w  #8,YSkip
        move.w  #2,MonPLine
        move.w  YRez,d1
        lsr.w   #1,d1
        move.w  d1,YRez 
        tst.b   d0
        bne.s   .RezSet
        move.w  #1,MonPLine
        move.w  XRez,d1
        lsr.w   #1,d1
        move.w  d1,XRez
.RezSet:
        sub.w   #1,XRez
        sub.w   #1,YRez
        
        move.l  LineA,a0
        move.w  YRez,d0
        clr.l   d1
        move.w  d0,d1
        add.w   #1,d1
        divu    V_CEL_HT(a0),d1
        move.w  d1,YChars
        sub.w   DefY,d0
        and.w   #$fff8,d0
        move.w  d0,YLim

        move.w  XRez,d0
        clr.l   d1
        move.w  d0,d1
        add.w   #1,d1
        move.w  d1,XPoints
        move.w  MonPLine,d2
        lsr.w   d2,d1
        move.w  d1,BpLine
        divu    v_planes(a0),d1
        move.w  d1,XChars
        sub.w   DefX,d0
        and.w   #$fff8,d0
        move.w  d0,XLim


        move.w  YRez,d0
        move.w  d0,WKYRez(a0)
        addq    #1,d0
        move.w  d0,NLin
        move.w  XRez,d0
        move.w  d0,WKXRez(a0)
        addq    #1,d0
        move.w  d0,LinL
        move.w  BpLine,BYTES_LIN(a0)
        move.w  BpLine,WIDTH(a0)
        move.w  XChars,V_CEL_MX(a0)
        move.w  YChars,V_CEL_MY(a0)
        sub.l   #$10001,V_CEL_MX(a0)
        clr.l   d0
        move.w  BpLine,d0
        mulu    V_CEL_HT(a0),d0
        move.w  d0,V_CEL_WR(a0)
        move.w  XRez,V_REZ_HZ(a0)
        addq.w  #1,V_REZ_HZ(a0)
        move.w  YRez,V_REZ_VT(a0)
        addq.w  #1,V_REZ_VT(a0)
        move.l  WKXSize(a0),PixW
        move.w  BpLine,d0
        move.b  d0,BILine+1
        move.w  0(a0),VPlanes
        move.l  SizeX,WKXSize(a0)
        rts


        dc.b    "XBRABIGS"
        dc.l    0

MyVB:
        tst.b   Patched
        beq     EndMove 

        tst.w   BadTos
        beq.s   .Not
        
        move.l  $456,a0
        tst.l   (a0)
        beq.s   .Not
        move.l  #MyMouse,0(a0)

        move.l  MouseVec,a0
        cmp.l   #$fcfe82,(a0)
        bne.s   .Not

        move.w  sr,-(sp)
        or.w    #$700,sr
        move.l  #$fcfe8c,(a0)
        move.w  (sp)+,sr
.Not:
        tst.l   LineA
        beq.s   EndVB

        move.w  YSkip,d2
        move.w  YLim,d1
        move.l  LineA,a0
        moveq   #0,d0
        move.w  GCURY(a0),d0
        sub.w   LastYPos,d0
        cmp.w   RangeDn,d0
        blt.s   Down
        cmp.w   RangeUp,d0
        bge.s   Up
EndVB:
        bra.s   DoX
        

Up:     add.w   d2,LastYPos
        bra.s   DoIt
Down:   sub.w   d2,LastYPos
        
DoIt:   tst.w   LastYPos
        bge.s   OK1
        clr.w   LastYPos
OK1:    cmp.w   LastYPos,d1
        bgt.s   OK2
        move.w  d1,LastYPos
OK2:
        clr.l   LastAdr

DoX:
        move.w  DefX,d0
        cmp.w   XRez,d0
        bne.s   DoXMove

        clr.l   d0
        move.w  LastYPos,d0
        mulu    BpLine,d0
        add.l   _v_bas_ad,d0 
        move.l  d0,-(sp)
        move.b  1(sp),$ff8201
        move.b  2(sp),$ff8203
        tst.l   (sp)+
        rts

DoXMove:
        move.w  XLim,d1
        moveq   #0,d0
        move.w  GCURX(a0),d0
        sub.w   LastXPos,d0
        cmp.w   RangeLf,d0
        blt.s   Left
        cmp.w   RangeRg,d0
        blt.s   DoMove
        

Right:  add.w   #16,LastXPos
        bra.s   DoIt2
Left:   sub.w   #16,LastXPos
        
DoIt2:  tst.w   LastXPos
        bge.s   XOK1
        clr.w   LastXPos
XOK1:   cmp.w   LastXPos,d1
        bgt.s   XOK2
        move.w  d1,LastXPos
XOK2:
        clr.l   LastAdr

DoMove:

        movem   d0-a7,-(sp)

        tst.w   $43e
        bne     NoTime

        add.w   #1,Counter

        move.l  LineA,a0
        move.w  OldX,d0
        cmp.w   GCURX(a0),d0
        bne.s   DoDo
        move.w  OldY,d0
        cmp.w   GCURY(a0),d0
        bne.s   DoDo

        and.w   #3,Counter
        tst.w   Counter
        bne     SkipIt
        
DoDo:   move.w  Counter,d0
        and.w   #1,d0
        bne     SkipIt

        clr.l   -(sp)
        move.b  $ff8201,1(sp)
        move.b  $ff8203,2(sp)
        move.l  (sp)+,a0
                
        move.l  LastAdr,a1
        tst.l   LastAdr
        bne.s   NowMove

        clr.l   d0
        move.w  LastYPos,d0
        mulu    BpLine,d0
        add.l   ScreenPtr,d0
        move.l  d0,a1
        
        clr.l   d2
        move.w  LastXPos,d2
        move.w  MonPLine,d3
        lsr.w   d3,d2
        add.l   d2,a1
        move.l  a1,LastAdr


NowMove:

        cmp.b   #2,sshiftmd
        beq     MonoScroll


        clr.l   d2
        move.w  BpLine,d2
        sub.w   #160,d2

        moveq   #19,d1
.1:

Offset  set     0

        .rept 10
        movem.l (a1)+,d3-d7/a2-a6
        movem.l d3-d7/a2-a6,Offset(a0)

Offset  set     Offset+40
        movem.l (a1)+,d3-d7/a2-a6
        movem.l d3-d7/a2-a6,Offset(a0)
Offset  set     Offset+40
        movem.l (a1)+,d3-d7/a2-a6
        movem.l d3-d7/a2-a6,Offset(a0)
Offset  set     Offset+40
        movem.l (a1)+,d3-d7/a2-a6
        movem.l d3-d7/a2-a6,Offset(a0)
Offset  set     Offset+40
        add.l   d2,a1
        .endr
        lea     Offset(a0),a0
        dbra    d1,.1

SkipIt:
        move.l  LineA,a0
        move.w  GCURX(a0),OldX
        move.w  GCURY(a0),OldY
NoTime:
        movem   (sp)+,d0-a7
EndMove:
        

        rts     

MonoScroll:


        clr.l   d2
        move.w  BpLine,d2
        sub.w   #80,d2

        moveq   #9,d1
.1:

Offset  set     0

        .rept 40

        movem.l (a1)+,d3-d7/a2-a6
        movem.l d3-d7/a2-a6,Offset(a0)

Offset  set     Offset+40

        movem.l (a1)+,d3-d7/a2-a6
        movem.l d3-d7/a2-a6,Offset(a0)

Offset  set     Offset+40

        add.l   d2,a1
        .endr
        lea     Offset(a0),a0
        dbra    d1,.1
        bra     SkipIt



SetUp:
        add.w   #1,XRez
        add.w   #1,YRez
SetUpLoop:
        move.w  #9984,d0
        cmp.w   XRez,d0
        bge.s   .xok1
        move.w  d0,XRez
.xok1:  cmp.w   YRez,d0
        bge.s   .yok1
        move.w  d0,YRez
.yok1:  
        cmp.w   #640,XRez
        bge.s   .xok2
        move.w  #640,XRez
.xok2:  cmp.w   #400,YRez
        bge.s   .yok2
        move.w  #400,YRez
.yok2:
        bsr     SetAsc
        pea     SULine
        bsr     Print   

        move.w  #7,-(sp)
        trap    #1
        addq    #2,sp

        cmp.b   #'+',d0
        bne.s   .1
        add.w   #128,XRez
        bra.s   SetUpLoop
.1:     cmp.b   #'-',d0
        bne.s   .2
        sub.w   #128,XRez
        bra.s   SetUpLoop
.2:     cmp.b   #'*',d0
        bne.s   .3
        add.w   #16,YRez
        bra     SetUpLoop
.3:     cmp.b   #'/',d0
        bne.s   .4
        sub.w   #16,YRez
        bra     SetUpLoop
.4:
        pea     SpeiWei
        bsr     Print
AskAgain:
        move.w  #7,-(sp)
        trap    #1
        addq    #2,sp
        cmp.b   #' ',d0
        beq     Installieren
        cmp.b   #13,d0
        bne.s   AskAgain

        ; save changes

        pea     MyPath
        move.w  #59,-(sp)
        trap    #1
        move.w  #2,-(sp)
        pea     MyName
        move.w  #61,-(sp)
        trap    #1
        lea     $e(sp),sp

        tst.l   d0
        blt     CantFind

        move.w  d0,FileH

        clr.w   -(sp)
        move.w  d0,-(sp)
        move.l  #XRez,d0
        sub.l   #Anfang-28,d0
        move.l  d0,-(sp)
        move.w  #66,-(sp)
        trap    #1
        lea     $a(sp),sp

        tst.l   d0
        blt.s   WriteError

        move.l  XRez,-(sp)
        sub.l   #$10001,(sp)
        move.l  sp,-(sp)
        move.l  #4,-(sp)
        move.w  FileH,-(sp)
        move.w  #64,-(sp)
        trap    #1
        lea     $10(sp),sp

        tst.l   d0
        blt.s   WriteError

        move.w  FileH,-(sp)
        move.w  #62,-(sp)
        trap    #1
        addq    #4,sp

        tst.l   d0
        blt.s   WriteError

        pea     Done
        bsr     Print
Installieren:
        pea     TwoLi
        bsr     Print
        sub.w   #1,XRez
        sub.w   #1,YRez
        rts
        
WriteError:
        pea     WError
        bsr     Print
        bra.s   Installieren

CantFind:
        pea     CFind
        bsr     Print
        bra.s   Installieren
                
Print:
        move.l  (sp)+,a6
        move.w  #9,-(sp)
        trap    #1
        addq    #6,sp
        jmp     (a6)


SetAsc:
        movem.l d0-a6,-(sp)
        move.w  XRez,d0
        lea     XText,a0
        bsr     Int2Asc
        move.w  XRez,d0
        lea     XText1,a0
        bsr     Int2Asc
        move.w  XRez,d0
        lsr.w   #1,d0
        lea     XText2,a0
        bsr     Int2Asc

        move.w  YRez,d0
        lea     YText,a0
        bsr     Int2Asc
        move.w  YRez,d0
        lsr.w   #1,d0
        lea     YText1,a0
        bsr     Int2Asc
        move.w  YRez,d0
        lsr.w   #1,d0
        lea     YText2,a0
        bsr     Int2Asc
        movem.l (sp)+,d0-a6
        rts

Int2Asc:        
        movem.l d0-a6,-(sp)
        lea     DezTab,a1
.1:     move.w  (a1)+,d1
        move.w  d0,d2
        divu.w  d1,d2
        move.b  d2,0(a0)
        add.b   #'0',(a0)+
        mulu.w  d1,d2
        sub.w   d2,d0
        tst.w   0(a1)
        bne.s   .1
        movem.l (sp)+,d0-a6
        rts

MyMouse:
        move.w  sr,-(sp)
        or.w    #$700,sr

        move.l  LineA,a0
        bclr    #0,CUR_FLAG(a0)
        beq.s   EndMouseVB
        clr.l   d0
        clr.l   d1
        move.w  CUR_X(a0),d0
        move.w  CUR_Y(a0),d1
        move.w  (sp)+,sr
        tst.b   MOUSE_FLAG(a0)
        bne.s   EndMouseVB2
        movem.w d0-d1,-(sp)
        lea     SAVE_LEN(a0),a2
        bsr     UndrawSprite
        movem.w (sp)+,d0-d1
        move.l  LineA,a0
        lea     SAVE_LEN(a0),a2
        lea     M_POS_HX(a0),a0
        bsr     DrawSprite
EndMouseVB2:
        rts
EndMouseVB:
        move.w  (sp)+,sr
        rts

        .include        "sp.s"


        dc.b    "XBRABIGS"
OldHrd: dc.l    0
MyHard:
        move.w  $446,d0
        add.b   #'A',d0
        move.b  d0,BIName

        clr.w   -(sp)
        pea     BIName
        move.w  #$3c,-(sp)      ; Fcreate
        trap    #1
        addq    #8,sp
        move.w  d0,FileH
        tst.l   d0
        blt     EndHard1

        pea     BitImageHeader
        move.l  #16,-(sp)
        move.w  d0,-(sp)
        move.w  #$40,-(sp)
        trap    #1
        lea     12(sp),sp
        cmp.l   #16,d0
        bne.s   EndHard

        move.w  YRez,d7
        clr.l   d6
        move.w  BpLine,d6
        move.l  _v_bas_ad,a6
.Loop:
        pea     BILine
        move.l  #2,-(sp)
        move.w  FileH,-(sp)
        move.w  #$40,-(sp)
        trap    #1
        lea     12(sp),sp
        cmp.l   #2,d0
        bne.s   EndHard

        move.l  a6,-(sp)
        move.l  d6,-(sp)
        move.w  FileH,-(sp)
        move.w  #$40,-(sp)
        trap    #1
        lea     12(sp),sp
        cmp.l   d6,d0
        bne.s   EndHard

        add.l   d6,a6
        dbra    d7,.Loop
        
        add.b   #1,BICnt

EndHard:
        move.w  FileH,-(sp)
        move.w  #$3e,-(sp)      ; Fclose
        trap    #1
        addq    #4,sp
EndHard1:
        move.w  #-1,$4ee
        rts
        

        
        data


DezTab: .dc.w   1000,100,10,1,0

OddTos: .dc.b   "[trying to fix problems with old TOS versions...]",13,10,0
Done:   .dc.b   "Configuration saved...",13,10,0
Inst:   .dc.b   "BigScreen installed...",13,10,0
MyPath: .dc.b   "\\auto",0
MyName: .dc.b   "bigscrn.prg",0
CFind:  .dc.b   7,"File \\auto\\bigscrn.prg not found.",13,10,0
WError: .dc.b   7,"Can't write to program file.",13,10,0
SchonDa: .dc.b  7,"BigScreen already installed.",13,10,0
Title:  .dc.b   13,10
        .dc.b   "BigScreen V1.0         "
        date
        .dc.b   ", "
        time
        .dc.b   13,10,"Copyright (c)    Julian F. Reschke und Markt&Technik"
        .dc.b   13,10,0

LMem:   .dc.b   7,"Not enough memory available!",13,10,0

NotInst: .dc.b  7,"BigScreen not installed!",13,10,0
SpeiWei: .dc.b  13,10,"<Space>: Continue  <Return>: Save configuration",13,10,0

TwoLi:  .dc.b   27,"e",13,0
SULine: .dc.b   27,"f(+-/*): "
XText:  .dc.b   "0000*"
YText:  .dc.b   "0000  "
XText1: .dc.b   "0000*"
YText1: .dc.b   "0000  "
XText2: .dc.b   "0000*"
YText2: .dc.b   "0000",13,0

BIName: .dc.b   "#:\\SCREEN"
BICnt:  .dc.b   "A.IMG",0

XRez:   dc.w    639
YRez:   dc.w    799
        
        .even

BitImageHeader:
        dc.w    1
        dc.w    8
        dc.w    1
        dc.w    2
PixW:   dc.w    0
PixH:   dc.w    0
LinL:   dc.w    0
NLin:   dc.w    0


BILine:
        dc.w    $8000
                
Patched:        dc.w    0               

YSkip:  dc.w    16
Rezs:   dc.w    319,199,639,199,639,399
Sizes:  dc.w    744,744,372,744,372,372
Ranges:
        dc.w    32,167,32,287
        dc.w    32,167,64,575
        dc.w    64,335,64,575


MonPLine:       dc.w    3

        bss

SizeX:          ds.w    1
SizeY:          ds.w    1
RangeDn:        ds.w    1
RangeUp:        ds.w    1
RangeLf:        ds.w    1
RangeRg:        ds.w    1
DefX:           ds.w    1
DefY:           ds.w    1
MouseVec:       ds.l    1
OldX:           ds.w    1
OldY:           ds.w    1
BadTos:         ds.w    1
FileH:          ds.w    1
Counter:        ds.l    1
LastAdr:        ds.l    1
YChars:         ds.w    1
XPoints:        ds.w    1
XChars:         ds.w    1
BpLine:         ds.w    1
XLim:           ds.w    1
YLim:           ds.w    1
ScreenPtr:      ds.l    1
LastYPos:       ds.w    1
LastXPos:       ds.w    1
IntOut:         ds.l    1
LineA:          ds.l    1
Back:           ds.l    1
VPlanes:        ds.w    1
BigScreen:


        end
