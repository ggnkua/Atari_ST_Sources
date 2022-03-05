  
  opt c-
  opt o+  ; Optimise Code...

  xdef  Dos_Cmnd

  Text

Dos_Cmnd:
    clr.l   d0
    clr.l   d1
    move.l  (a7)+,Pas_Save
    move.l  (a7)+,a0     ; Addr of source line
    move.b  (a0)+,d0
    move.l  a0,a1
    add.l   d0,a1
    move.b  #0,(a1)
    lea     DosList,a2
DosCmd_1:
    move.l  a0,a1
DosCmd_2:
    move.b  (a2),d4
    cmpi.b  #0,d4        ; end of word yet???
    bne.b   DosCmd_2x
    addq.l  #1,a2
    move.b  (a2)+,d1
    cmp.b   #0,(a2)
    beq.b   DosCmd_5
    cmp.b   #1,d1
    beq.b   DosCmd_5
    move.b  (a1),d5
    cmp.b   #97,d5      ; >= 'a'
    bcs.b   DosCmd_2a
    cmp.b   #122,d5     ; <='z'
    bhi.b   DosCmd_2a
    sub.b   #32,d5      ; then make upper case...
DosCmd_2a:
    cmp.b   #65,d5
    bcs.b   DosCmd_5
    cmp.b   #90,d5
    bhi.b   DosCmd_5
    bra.b   DosCmd_4
DosCmd_2x:
    move.b  (a2),d4
    move.b  (a1),d5
    cmp.b   #97,d5     ; >= 'a'
    bcs.b   DosCmd_3
    cmp.b   #122,d5    ; <= 'z'
    bhi.b   DosCmd_3
    sub.b   #32,d5     ; then make upper case...
DosCmd_3:
    cmp.b   d4,d5      ; the same?
    bne.b   DosCmd_4
    addq.l  #1,a1
    addq.l  #1,a2
    bra.b   DosCmd_2
DosCmd_4:
    cmpi.b  #0,(a2)+
    bne.b   DosCmd_4
    addq.l  #1,a2
    bra.b   DosCmd_1
DosCmd_5:
    addq.l  #1,a2
    move.l  a1,d0
    sub.l   a0,d0
    lsl.w   #8,d0
    move.b  d1,d0      ; return with value of command + Length...
    move.l  Pas_Save,-(a7)
    rts

DosList:
  dc.b  'DIR',$0,$2
  dc.b  'CHGDIR',$0,$3
  dc.b  'CD',$0,$3
  dc.b  'CREDIR',$0,$4
  dc.b  'MD',$0,$4
  dc.b  'DELDIR',$0,$5
  dc.b  'RD',$0,$5
  dc.b  'FREE',$0,$6
  dc.b  'TOS',$0,$7
  dc.b  'GEM',$0,$8
  dc.b  'COPY',$0,$9
  dc.b  'MOVE',$0,$A
  dc.b  'VIEW',$0,$B
  dc.b  'RENAME',$0,$C
  dc.b  'REN',$0,$C
  dc.b  'DELETE',$0,$D
  dc.b  'DEL',$0,$D
  dc.b  'TOUCH',$0,$E
  dc.b  'EDIT',$0,$F
  dc.b  'NEW FILES',$0,$10
  dc.b  'UPLOAD',$0,$11
  dc.b  'DOWNLOAD',$0,$12
  dc.b  'UNARC',$0,$13
  dc.b  'UNARJ',$0,$14
  dc.b  'UNLZH',$0,$15
  dc.b  'UNSIT',$0,$16
  dc.b  'UNZIP',$0,$17
  dc.b  'UNZOO',$0,$18
  dc.b  'MEMORY',$0,$19
  dc.b  '?',$0,$1A
  dc.b  'EXIT',$0,$1B
  dc.b  'X',$0,$1B
  dc.b  'CLS',$0,$1C
  dc.b  'LOCK',$0,$1D
  dc.b  'UNLOCK',$0,$1E
  dc.w  0,0,0,0

  Data

  even

Pas_Save:    dc.l  0

  even

    End
    
