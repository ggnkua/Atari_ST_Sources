; File name:   GFAGEM.S           Revised:  1990.09.13
; Creator:     U. R. Andersson    Created:  1990.09.08
; Purpose:     Support GFA BASIC 2.0
;
;
G_BOX     =    20
G_TEXT    =    21
G_BOXTEST =    22
G_IMAGE   =    23
G_PROGDEF =    24
G_IBOX    =    25
G_BUTTON  =    26
G_BOXCHAR =    27
G_STRING  =    28
G_FTEXT   =    29
G_FBOXTEST=    30
G_ICON    =    31
G_TITLE   =    32
;
NONE      =    0
SELECTABLE=    1
DEFAULT   =    2
EXIT      =    4
EDITABLE  =    8
RBUTTON   =    16
LASTOB    =    32
TOUCHEXIT =    64
HIDETREE  =    128
INDIRECT  =    256
;
NORMAL    =    0
SELECTED  =    1
CROSSED   =    2
CHECKED   =    4
DISABLED  =    8
OUTLINED  =    16
SHADOWED  =    32
;
;
SCF_AES:  MACRO %\1,%\2,%\3,%\4,%\5
  MOVEA.L GCONTRLP,A3
  MOVE    #\1,(A3)+
  MOVE    #\2,(A3)+
  MOVE    #\3,(A3)+
  MOVE    #\4,(A3)+
  MOVE    #\5,(A3)
  ENDM
;
;
AES:      MACRO
  MOVE.L  AESPTR,D1
  MOVE    #$C8,D0
  TRAP    #2
  ENDM
;
;
MAIN:
  LEA     MAIN,A4
  MOVE.L  SP,ENTRY_SP-MAIN(A4)
  MOVE    4(SP),D5
  MOVE    D5,ARGC-MAIN(A4)
  MOVE.L  6(SP),A5
  MOVE.L  A5,ARGVP-MAIN(A4)
  LEA     LOCSTACK,SP
  BSR     GEM_FUN
GEM_EXIT:
  MOVE.L  ENTRY_SP,SP
  RTS
;
;
ARGC:     DC.W 0
ARGVP:    DC.L 0
;
ENTRY_SP: DC.L 0
;
AESPTR:  DC.L 0
AESPB:
GCONTRLP: DC.L 0
GLOBALP:  DC.L 0
GINTINP:  DC.L 0
GINTOUTP: DC.L 0
ADDRINP:  DC.L 0
ADDROUTP: DC.L 0
AES_MARK: DC.W 0
;
VDIPTR:   DC.L 0
VDIPB:
CONTRLP   DC.L 0
INTINP:   DC.L 0
PTSINP:   DC.L 0
INTOUTP:  DC.L 0
PTSOUTP:  DC.L 0
VDI_MARK: DC.W 0
;
;
GR_HANDLE:DC.W 0
GR_CHARW: DC.W 0
GR_CHARH: DC.W 0
GR_BOXW:  DC.W 0
GR_BOXH:  DC.W 0
;
;
FNCODE_LIM:    ;TOTAL NUMBER OF LEGAL FUNC'S *6
  DC.W    FNCODE_END-FNCODE_TAB
;
FNCODE_TAB:    ;6 WORD/FUNC
;GEM AES FUNCTIONS
  DC.W    $0A,2,0,1,0,0    ;APPL_INIT
  DC.W    $0B,5,2,1,1,0    ;APPL_READ
  DC.W    $0C,5,2,1,1,0    ;APPL_WRITE
  DC.W    $0D,3,0,1,1,0    ;APPL_FIND
  DC.W    $0E,5,2,1,1,0    ;APPL_TPLAY
  DC.W    $0F,4,1,1,1,0    ;APPL_TRECORD
  DC.W    $13,2,0,1,0,0    ;APPL_EXIT
  DC.W    $14,2,0,1,0,0    ;EVNT_KEYBD
  DC.W    $15,9,3,5,0,0    ;EVNT_BUTTON
  DC.W    $16,11,5,5,0,0   ;EVNT_MOUSE
  DC.W    $17,3,0,1,1,0    ;EVNT_MESAG
  DC.W    $18,4,2,1,0,0    ;EVNT_TIMER
  DC.W    $19,25,16,7,1,0  ;EVNT_MULTI
  DC.W    $1A,4,2,1,0,0    ;EVNT_DCLICK
  DC.W    $1E,4,1,1,1,0    ;MENU_BAR
  DC.W    $1F,5,2,1,1,0    ;MENU_ICHECK
  DC.W    $20,5,2,1,1,0    ;MENU_IENABLE
  DC.W    $21,5,2,1,1,0    ;MENU_TNORMAL
  DC.W    $22,5,1,1,2,0    ;MENU_TEXT
  DC.W    $23,4,1,1,1,0    ;MENU_REGISTER
  DC.W    $28,5,2,1,1,0    ;OBJC_ADD
  DC.W    $29,4,1,1,1,0    ;OBJC_DELETE
  DC.W    $2A,9,6,1,1,0    ;OBJC_DRAW
  DC.W    $2B,7,4,1,1,0    ;OBJC_FIND
  DC.W    $2C,6,1,3,1,0    ;OBJC_OFFSET
  DC.W    $2D,5,2,1,1,0    ;OBJC_ORDER
  DC.W    $2E,8,4,2,1,0    ;OBJC_EDIT
  DC.W    $2F,11,8,1,1,0   ;OBJC_CHANGE
  DC.W    $32,4,1,1,1,0    ;FORM_DO
  DC.W    $33,12,9,1,1,0   ;FORM_DIAL
  DC.W    $34,4,1,1,1,0    ;FORM_ALERT
  DC.W    $35,3,1,1,0,0    ;FORM_ERROR
  DC.W    $36,7,0,5,1,0    ;FORM_CENTER
  DC.W    $46,8,4,3,0,0    ;GRAF_RUBBERBOX
  DC.W    $47,12,8,3,0,0   ;GRAF_DRAGBOX
  DC.W    $48,8,6,1,0,0    ;GRAF_MOVEBOX
  DC.W    $49,10,8,1,0,0   ;GRAF_GROWBOX
  DC.W    $4A,10,8,1,0,0   ;GRAF_SHRINKBOX
  DC.W    $4B,7,4,1,1,0    ;GRAF_WATCHBOX
  DC.W    $4C,6,3,1,1,0    ;GRAF_SLIDEBOX
  DC.W    $4D,6,0,5,0,0    ;GRAF_HANDLE
  DC.W    $4E,4,1,1,1,0    ;GRAF_MOUSE
  DC.W    $4F,6,0,5,0,0    ;GRAF_MKSTATE
  DC.W    $50,3,0,1,1,0    ;SCRP_READ
  DC.W    $51,3,0,1,1,0    ;SCRP_WRITE
  DC.W    $5A,5,0,2,2,0    ;FSEL_INPUT
  DC.W    $64,7,5,1,0,0    ;WIND_CREATE
  DC.W    $65,7,5,1,0,0    ;WIND_OPEN
  DC.W    $66,3,1,1,0,0    ;WIND_CLOSE
  DC.W    $67,3,1,1,0,0    ;WIND_DELETE
  DC.W    $68,8,2,5,0,0    ;WIND_GET
  DC.W    $69,8,6,1,0,0    ;WIND_SET
  DC.W    $6A,4,2,1,0,0    ;WIND_FIND
  DC.W    $6B,3,1,1,0,0    ;WIND_UPDATE
  DC.W    $6C,12,6,5,0,0   ;WIND_CALC
  DC.W    $6E,3,0,1,1,0    ;RSRC_LOAD
  DC.W    $6F,2,0,1,0,0    ;RSRC_FREE
  DC.W    $70,5,2,1,0,1    ;RSRC_GADDR
  DC.W    $71,5,2,1,1,0    ;RSRC,SADDR
  DC.W    $72,4,1,1,1,0    ;RSRC_OBFIX
  DC.W    $78,4,0,1,2,0    ;SHEL_READ
  DC.W    $79,7,3,1,2,0    ;SHEL_WRITE
  DC.W    $7C,3,0,1,1,0    ;SHEL_FIND
  DC.W    $7D,4,0,1,2,0    ;SHEL_ENVRN
;GEM VDI FUNCTIONS
FNCODE_END:
;
FNVECT_TAB:    ;1 WORD/FUNCTYPE
RP@       =    FNVECT_TAB
  DC.W    AES_LK-RP@,ARGERROR-RP@,ARGERROR-RP@
  DC.W    ARGERROR-RP@,ARGERROR-RP@
;
;
GEM_FUN:
  TST.W   D5
  BEQ     ARGERRLO
  MOVE.L  (A5),D0
  BLE     SPEC_SUBS
  MOVE    FNCODE_LIM,D3
  MOVEQ   #-1,D2
  CLR     D7
  LEA     FNCODE_TAB,A0
\SCANUP:
  MOVE    D7,D1
  ADD     D3,D7
\SCANTEST:
  LSR     #1,D7
  BTST    #1,D7            ;ODD/EVEN *6 ?
  BEQ.S   \SCANCMP         ;EVEN IS MULTIPLE 12
  SUBQ    #6,D7            ;FORCE ODD TO MULTIPLE 12
\SCANCMP:
  CMP     D2,D7
  BEQ.S   \NOSCAN
  MOVE    D7,D2
  CMP     (A0,D7),D0
  BEQ.S   \SCANNED
  BHI.S   \SCANUP
\SCANDN:
  MOVE    D7,D3
  ADD     D1,D7
  BRA.S   \SCANTEST
;
\NOSCAN:
  BRA     ARGERRFN
;
\SCANNED:
  CMP     2(A0,D7),D5
  BHI     ARGERRHI
  BLO     ARGERRLO
  MOVEM   4(A0,D7),D1-D4
  CLR.L   D7
  MOVE.B  D0,D7
  EXG     D0,D7
  LSR     #7,D7
  BCLR    #0,D7
  LEA     FNVECT_TAB,A0
  ADDA    (A0,D7),A0
  JMP     (A0)
;
;
SPEC_SUBS:
  NEG     D0
  ADD     D0,D0
  CMPI    #SPEC_SUBLIM-SPEC_SUBTB,D0
  BHS     ARGERRFN
  LEA     SPEC_SUBTB,A0
  ADD     (A0,D0),A0
  JMP     (A0)
;
;
SPEC_SUBTB:
RP@       =    SPEC_SUBTB
  DC.W    AES_INIT-RP@,VDI_INIT-RP@,RSC_INIT-RP@
SPEC_SUBLIM:
;
;
AES_INIT:
  CMPI    #2,D5
  BHI     ARGERRHI
  BLO     ARGERRLO
  MOVE.L  4(A5),A0      ;A0=GB=BASIC AESPTR VALUE
  LEA     AESPTR-MAIN(A4),A1
  MOVE.L  A0,(A1)+
  MOVEQ   #6-1,D0
\LP1:
  MOVE.L  (A0)+,(A1)+
  DBRA    D0,\LP1
  ST      AES_MARK-MAIN(A4)
  RTS
;
;
VDI_INIT:
  CMPI    #2,D5
  BHI     ARGERRHI
  BLO     ARGERRLO
  MOVE.L  4(A5),A0      ;A0=BASIC VDIPTR VALUE
  LEA     VDIPTR-MAIN(A4),A1
  MOVE.L  A0,(A1)+
  MOVEQ   #5-1,D0
\LP1:
  MOVE.L  (A0)+,(A1)+
  DBRA    D0,\LP1
  ST      VDI_MARK-MAIN(A4)
  RTS
;
;
RSC_INIT:
  MOVE    AES_MARK,D0
  BEQ     ARGERROR
  SCF_AES 77,0,5,0,0
  AES                   ;GRAF_HANDLE
  MOVE.L  GINTOUTP,A1
  LEA     GR_HANDLE,A2
  MOVE    (A1)+,(A2)+
  MOVE.L  (A1)+,(A2)+
  MOVE.L  (A1),(A2)
  MOVE.L  4(A5),A4
  MOVE.L  A4,D7
  MOVE.L  GR_CHARW,D6
\MAINLOOP:
  LEA     16(A4),A3
  MOVEQ   #3,D5
\COORLOOP:
  SWAP    D6
  MOVE    (A3),D0
  ANDI    #$FF,D0
  MULU    D6,D0
  CLR     D1
  MOVE.B  (A3),D1
  ADD     D1,D0
  MOVE    D0,(A3)+
  DBRA    D5,\COORLOOP
  MOVE    6(A4),D5
  CMPI    #G_BOX,D5
  BEQ.S   \NEXTMAIN
  CMPI    #G_IBOX,D5
  BEQ.S   \NEXTMAIN
  CMPI    #G_BOXCHAR,D5
  BEQ.S   \NEXTMAIN
  ADD.L   D7,12(A4)
  CMPI    #G_BUTTON,D5
  BEQ.S   \NEXTMAIN
  CMPI    #G_STRING,D5
  BEQ.S   \NEXTMAIN
  CMPI    #G_TITLE,D5
  BEQ.S   \NEXTMAIN
  MOVE.L  12(A4),A3
  ADD.L   D7,(A3)+
  CMPI    #G_IMAGE,D5
  BEQ.S   \NEXTMAIN
  CMPI    #G_PROGDEF,D5
  BEQ.S   \NEXTMAIN
  ADD.L   D7,(A3)+
  ADD.L   D7,(A3)+
\NEXTMAIN:
  BTST    #?LASTOB,9(A4)
  ADDA    #24,A4
  BEQ.S   \MAINLOOP
 RTS
;
;
ARGERRFN:
  LEA     FORMERRFN,A2
  BRA.S   ARGERRFIX
;
ARGERRLO:
  LEA     FORMERRLO,A2
  BRA.S   ARGERRFIX
;
ARGERRHI:
  LEA     FORMERRHI,A2
  BRA.S   ARGERRFIX
;
ARGERROR:
  LEA     FORMERROR,A2
ARGERRFIX:
  MOVE    AES_MARK,D0
  BEQ     GEM_EXIT
  SCF_AES 52,1,1,1,0
  MOVE.L  GINTINP,A3
  MOVE    #1,(A3)
  MOVE.L  ADDRINP,A3
  MOVE.L  A2,(A3)
  AES
  BRA     GEM_EXIT
;
FORMERRFN:
  DC.B    '[3][URANIUM Report:|Illegal function.]'
  DC.B    '[Continue]',0
  ALIGN
;
FORMERRHI:
  DC.B    '[3][URANIUM Report:|Function needs|fewer arguments.]'
  DC.B    '[Continue]',0
  ALIGN
;
FORMERRLO:
  DC.B    '[3][URANIUM Report:|Function needs|more arguments.]'
  DC.B    '[Continue]',0
  ALIGN
;
FORMERROR:
  DC.B    '[3][URANIUM Report:|There is an error|in calling program!]'
  DC.B    '[Continue]',0
  ALIGN
;
;
AES_LK:
  MOVE    AES_MARK,D7
  BEQ     ARGERROR
  MOVE.L  GCONTRLP,A0
  MOVEM   D0-D4,(A0)
  MOVEA.L ARGVP,A1
  ADDQ    #4,A1
  SUBQ    #1,D1
  BLO.S   \LX1
  MOVE.L  GINTINP,A2
\LP1:
  MOVE.L  (A1)+,D0
  MOVE    D0,(A2)+
  DBRA    D1,\LP1
\LX1:
  SUBQ    #1,D3
  BLO.S   \LX3
  MOVE.L  ADDRINP,A2
\LP3:
  MOVE.L  (A1)+,(A2)+
  DBRA    D3,\LP3
\LX3:
  MOVE.L  A1,-(SP)
  MOVE    D4,-(SP)
  MOVE    D2,-(SP)
  AES
  MOVE    (SP)+,D2
  MOVE    (SP)+,D4
  MOVE.L  (SP)+,A1
  SUBQ    #1,D2
  BLO.S   \LX2
  MOVE.L  GINTOUTP,A2
\LP2:
  MOVEA.L (A1)+,A0
  MOVE    (A2)+,D0
  EXT.L   D0
  MOVE.L  D0,(A0)
  DBRA    D2,\LP2
\LX2:
  SUBQ    #1,D4
  BLO.S   \LX4
  MOVE.L  ADDROUTP,A2
\LP4:
  MOVEA.L (A1)+,A0
  MOVE.L  (A2)+,(A0)
  DBRA    D4,\LP4
\LX4:
  RTS
;
;
FLOAT:
  MOVEQ   #$60,D1
  TST.L   D0
  BEQ     \FLOAT_EX
  BPL     \FLOAT_LP
  NEG.L   D0
  BSET    #7,D1
\FLOAT_LP:
  SUBQ.B  #1,D1
  ASL.L   #1,D0
  BVC.S   \FLOAT_LP
  MOVE.B  D1,D0
\FLOAT_EX:
  RTS
;
;
  DS.L    $100
LOCSTACK:
  DS.L    $40
;
;
  END     ;OF    GFAGEM.S

 