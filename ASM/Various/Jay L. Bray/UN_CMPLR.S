  opt o+

  xdef GetCLine
  xdef Addr_Str
  xdef FndMatch
  xdef Fsel_In
  xdef Mouse_On
  xdef Mouse_Off

  Text

Table_Adr:
Addr_Str:
    move.l  (a7)+,d6
    move.l  (a7)+,d0
    move.l  d6,-(a7)
    rts

GetCLine:
  move.l  (a7)+,d6
  move.l  (a7)+,a1      ; Address of Dest. String...
  move.l  (a7)+,a0      ; Address of Compiled Line...
  move.w  (a7)+,d0      ; Line Number to get...
  move.l  d6,-(a7)
  move.l  a1,a2
  addq.l  #1,a1          ; Actual Destination String Address
  move.b  #0,(a2)        ; Set Length of String to 0...
  move.w  #1,d6         ; Set Current Line No to extract
GtCom_L1:
  cmp      #1,d0          ; does Line to get = 1?
  beq.b    GtCom_L3      ; Yep
GtCom_L2:               ; Else it's more..
  cmpi.b  #$FF,(a0)+    ; End of Compiled Line?
  bne.b    GtCom_L2
  addq    #1,d6         ; inc line counter
  cmp      d6,d0          ; is Line_No right line?  
  bne.b    GtCom_L2      ; continue until we have the right line...
GtCom_L3:
  cmpi.b  #$FF,(a0)     ; End of File?
  beq.b    GtCom_L6      ; Yep - So Exit
GtCom_L4:
  move.b  (a0)+,d1      ; Get next char from line
  cmp.b    #$FF,d1       ; End Of Line?
  beq.b    GtCom_L5      ; Exit If So...
  move.b  d1,(a1)+      ; Add Char to String
  addq.b  #1,(a2)       ; inc length of string
  cmpi.b  #250,(a2)     ; is length > 250
  bhi.b    GtCom_L6      ; yep - exit 
  bra.b    GtCom_L4      ; get more chars
GtCom_L5:
  move.l  a0,d0
  rts

GtCom_L6:
  moveq.l  #-1,d0
  rts

FndMatch:
  move.l  (a7)+,d6
  move.l  (a7)+,a1    ; Find String
  move.l  (a7)+,a0    ; Search String
  move.l  d6,-(a7)
  move.b  (a0)+,d0    ; Length of Search String
  move.b  (a1)+,d1    ; Char in Find String
  cmp.b    d0,d1
  bne.b    Find_M5
Find_M1:
  cmp.b    #0,d0
  beq.b    Find_M4
  move.b  (a0)+,d1
  move.b  (a1)+,d2
  cmp.b    #97,d1      ; >= 'a'
  bcs.b    Find_M2
  cmp.b    #122,d1
  bhi.b    Find_M2      ; <= 'z'
  sub.b    #32,d1
Find_M2:
  cmp.b    #97,d2      ; >= 'a'
  bcs.b    Find_M3
  cmp.b    #122,d2      ; <= 'z'
  bhi.b    Find_M3
  sub.b    #32,d2
Find_M3:
  cmp.b    d1,d2
  bne.b    Find_M5
  subq.b  #1,d0
  bra.b    Find_M1
Find_M4:
  move.w  #1,d0
  rts

Find_M5:
  move.w  #0,d0
  rts

Mouse_On:
  move.l  (a7)+,Pas_Save
  dc.w    $a000
  move.l  4(a0),a1
  move.w  #0,(a1)
  move.w  #1,6(a1)
  move.l  8(a0),a1
  move.w  #0,(a1)
  dc.w    $A009
  move.l  Pas_Save,-(a7)
  rts

Mouse_Off:
  move.l  (a7)+,Pas_Save
  dc.w    $A00A
  move.l  Pas_Save,-(a7)
  rts

Fsel_In:
    move.l  (a7)+,d6
    move.l  (a7)+,Addr_In
    move.l  (a7)+,Addr_In+4
    move.w  #90,OpCode
    move.w  #0,OpCode+2
    move.w  #2,OpCode+4
    move.w  #2,OpCode+6
    bsr.s    Aes
    move.w  int_out+2,d0
    move.l  d6,-(a7)
    rts

Aes:
    move.l  #Aes_Parms,d1
    move.w  #200,d0
    trap    #2
    move.w  int_out,d0
    rts

  data

Pas_Save:  dc.l  0

Aes_Parms:  dc.l  Control,Global,Int_In,Int_Out,Addr_In,Addr_Out
Control:
OpCode:    dc.w  0
SIntIn:    dc.w  0
SIntOut:  dc.w  0
SAddrIn:  dc.w  0
SAddrOut:  dc.l  0
          dc.w  0,0,0,0,0

Global:      dc.w  14
ApVersion:  dc.w  0
ApCount:    dc.w  0
ApId:        dc.w  0
ApPrivate:  dc.l  0
AppTree:    dc.l  0
Ap1Resv:    dc.l  0
Ap2Resv:    dc.l  0
Ap3Resv:    dc.l  0
Ap4Resv:    dc.l  0
Int_in:      dc.w  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Int_out:    dc.w  0,0,0,0,0,0,0
Addr_in:    dc.l  0,0,0
Addr_out:    dc.l  0

    End
