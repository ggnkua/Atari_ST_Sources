;
; New Trap 8 Vector to handle Extra Commands
; From within Express BBS ST
;

Cr       =    13
Lf       =    10

     move.l   a7,a5            ; Save Stack Pointer in a5
     movea.l  $4(a5),a5        ; a5 points to the base-page start
     move.l   $c(a5),d0
     add.l    $14(a5),d0
     add.l    $1c(a5),d0
     add.l    #$100,d0
     move.l   d0,Prg_Ln

     move.l   #Usr_Stack,a7
     move.l   d0,-(a7)         ; Length of area to reserve
     move.l   a5,-(a7)         ; Address of area
     move.w   #0,-(a7)         ; Dummy word
     move.w   #$4a,-(a7)
     trap     #1               ; MShrink
     add.l    #12,a7

     move.l   #New_Trap8,-(a7) ; New Trap 8 Vector
     move.w   #40,-(a7)        ; Trap 8 vector
     move.w   #$5,-(a7)        ; Set_Trap8
     trap     #$D     add.l    #8,a7

     move.w   #0,-(a7)
     move.w   #14,-(a7)
     trap     #14
     addq.l   #4,a7
     move.l   d0,Rs232_Iorec

     move.w   #0,-(a7)
     move.l   Prg_Ln,-(a7)
     move.w   #$31,-(a7)       ; Terminate And
     trap     #1               ; Stay Resident..
     add.l    #8,a7
     rts

Prg_Ln:       dc.l  0
Rs232_IoRec:  dc.l  0

New_Trap8:
     movem.l  a0-a6/d1-d7,-(a7)
     move     Usp,a0
     btst     #5,(a7)          ; in super?
     beq      In_Superv
     move.l   6(a7),a0
In_Superv:     move.l   a0,a1
     cmp.w    #1,(a0)          ; 'D' Key
     bne      Tr8_T
     bsr      Do_Dial_Back
     bra.s    Exit_Prg
Tr8_T:
     cmp.w    #11,(a0)         ; 'T' Key
     bne      Tr8_V
     bra.s    Pterm0           ;    Exit Back To TOS...
Tr8_V:
     cmp.w    #12,(a0)         ; 'V' Key
     bne      Var1
     bsr      Do_Snoop
     bra.s    Exit_Prg
Var1:
     cmp.w    #35,(a0)         ; Variable #80...
     beq      Pterm0
Exit_Prg:
     movem.l  (a7)+,a0-a6/d1-d7
     rte

Pterm0:
     cmp.w    #1,Snoop_Flag
     bne      Ptrm0_1
     bsr      Set_Old13
     bsr      Set_XY
     move.l   #Snoop2_Msg,Text_Adr
     bsr      Send_Console
     move.w   #0,Snoop_Flag
PTrm0_1:
     move.l   #Tos_Msg,Text_Adr
     bsr      Send_Console
     movem.l  (a7)+,a0-a6/d1-d7
     move.w   #0,-(a7)
     trap     #1
     addq.l   #2,a7
     move.w   #0,-(a7)
     trap     #1
     addq.l   #2,a7
     rts

Do_Dial_Back:                  ; Dial - Back
     move.l   #DialBack_Msg,Text_Adr
     bsr      Send_Console
     rts

Do_Snoop:                      ; Snoop Mode
     cmp.w    #0,Snoop_Flag
     bne      Snoop_D
     bsr      Set_XY
     move.l   #Snoop1_Msg,TExt_adr
     bsr      Send_Console
     move.w   #1,Snoop_Flag
     bsr      Set_New13
     bra.s    Snoop_Xit
Snoop_D:
     bsr      Set_Old13
     bsr      Set_XY
     move.l   #Snoop2_Msg,Text_Adr
     bsr      Send_Console
     move.w   #0,Snoop_Flag
Snoop_Xit:
     rts

Set_XY:
     dc.w     $a000
     MOVE.W   #10,-28(A0)
     move.w   #10,-26(a0)
     rts

Set_New13:
     move.l   #New_Trap13,-(a7) ; New Trap 13 Vector
     move.w   #45,-(a7)        ; Trap 13 vector
     move.w   #$5,-(a7)        ; Set_Trap13
     trap     #13
     add.l    #8,a7
     move.l   d0,Old_Trap13
     move.l   d0,T13+2
     rts

Set_Old13:
     move.l   Old_Trap13,-(a7) ; Old Trap 13 Vector
     move.w   #45,-(a7)        ; Trap 13 vector
     move.w   #$5,-(a7)        ; Set_Trap13
     trap     #13
     add.l    #8,a7
     rts

New_Trap13:
     movem.l  a0-a6/d0-d7,-(a7)
     move.l   Usp,a0
     btst     #5,(a7)          ; in super?
     beq      In_Superv13
     move.l   6(a7),a0
In_Superv13:
     move.w   4(a0),Char
     cmp.l    #$30002,(a0)     ; Bconout using Console???
     beq      Rte1
     cmp.l    #$30001,(a0)     ; Bconout using RS-232???
     bne      Tr13_Xit         ; nope..
     bsr      Send_2_Mdm
     move.l   #$30002,(a0)     ;  Yep, so change to console
Tr13_Xit:
     movem.l  (a7)+,a0-a6/d0-d7
T13: jmp      $fc0a1a
Rte1:
     movem.l  (a7)+,a0-a6/d0-d7
     rte

Send_2_Mdm:
     movem.l  a0-a6/d0-d7,-(a7)
Snd2mdm:
     move.w   Char,d1
     bsr      Rs232_Put
     bcs      Snd2Mdm
     movem.l  (a7)+,a0-a6/d0-d7
     rts
Get_Rs232ptr:
     move.l   Rs232_Iorec,a0
     lea      $FFFFFA01,a1
     rts
Rts_Check:
     btst     #$1,$20(a0)      ; RTS/CTS Mode
     beq      RtsChk_Xit       ; No
     bsr      Rts_On           ; Set RTS
RtsChk_Xit:     rts Rs232_Put:     move     sr,-(a7)     ori.w    #$700,sr         ; IPL 7, Disable Interrupts
     bsr      Get_Rs232ptr
     btst     #$0,32(a0)       ; Xon/Xoff Mode?
     beq      Not_Xonoff       ; no
     tst.b    31(a0)           ; XOn Active?
     bne      Xon_Active       ; Yes
Not_Xonoff:     btst     #$7,44(a1)       ; Is MFP still Sending
     beq      Xon_Active       ; Yes
     move.w   20(a0),d2        ; Head Index
     cmp.w    22(a0),d2        ; Tail Index
     bne      Xon_Active       ; Still Chars In Buffer
     move.b   d1,46(a1)        ; Pass Byte to MFP
     bra      Buff_Ok

Xon_Active:     move.w   22(a0),d2        ; Tail Index
     bsr      Test_Wrap        ; Test for Wrap Around
     cmp.w    20(a0),d2        ; Compare with Head Index
     beq      Buff_Full        ; Same?, Buffer Full
     movea.l  14(a0),a1        ; Get Current Buffer Address
     move.b   d1,0(a1,d2.w)    ; Write Char in Buffer
     move.w   d2,22(a0)        ; Save New Tail Index
Buff_Ok:     bsr      Rts_Check        ; RtsChk - Set RTS?
     move     (a7)+,sr         ; Restore Status Flag
     andi.b   #$FE,ccr         ; Clear Carry Flag
     rts
Buff_Full:     bsr      Rts_Check        ; RtsChk - Set RTS?
     move     (a7)+,sr         ; Restore Status
     ori.b    #$1,ccr          ; Set Carry
     rts
Test_Wrap:
     addq.w   #1,d2            ; Tail Index+1
     cmp.w    18(a0),d2        ; Equals Buffer Size?
     bcs      TstWrp_Xit       ; No
     moveq.l  #0,d2            ; Else start with zero again...
TstWrp_Xit:
     rts

HFC2CF2:                       ; gi access r/w sound chip
     move.w   $4(a7),d0
     move.w   $6(a7),d1
     move     sr,-(a7)
     ori.w    #$700,sr
Gi_Access1:
     movem.l  d1-d2/a0,-(a7)   ; Save Registers
     lea      $FFFF8800,a0     ; Address of Sound Chip
     move.b   d1,d2            ; Get Register Number
     andi.b   #$F,d1           ; registers 0 -15
     move.b   d1,(a0)          ; select register
     asl.b    #1,d2            ; test read/write
     bcc      Read_Chip          ; Read
     move.b   d0,$2(a0)        ; write data in sound chip
Read_Chip:
     moveq    #$0,d0
     move.b   (a0),d0          ; read byte from sound chip register
     movem.l  (a7)+,d1-d2/a0   ; restore registers
     move     (a7)+,sr         ; restore status
     rts

Rts_Off:
     moveq.l  #8,d2            ; disable RTS
     bra      Set_Bit_PortA
Rts_On:
     moveq.l  #-9,d2    ; f7   ; Enable RTS
     bra      Clr_Bit_PortA
Dtr_Off:
     moveq.l  #16,d2           ; Disable DTR
     bra      Set_Bit_PortA
Dtr_On:
     moveq.l  #-17,d2          ; Enable DTR
     bra      Clr_Bit_PortA

HFC2D36:                       ; Ongibit
     moveq    #$0,d2
     move.w   $4(a7),d2
Set_Bit_PortA:
     movem.l  d0-d2,-(a7)
     move     sr,-(a7)     ori.w    #$700,sr
     moveq    #$E,d1
     move.l   d2,-(a7)
     bsr      Gi_Access1
     move.l   (a7)+,d2
     or.b     d2,d0     move.l   #$8E,D1
     bsr      Gi_Access1
     move     (a7)+,sr     movem.l  (a7)+,d0-d2
     rts
HFC2D5C:                       ; Offgibit
     moveq    #$0,d2
     move.w   $4(a7),d2
Clr_Bit_PortA:     movem.l  d0-d2,-(a7)      ; save registers
     move     sr,-(a7)         ; save status
     ori.w    #$700,sr         ; IPL 7,
     moveq    #$E,d1           ; Port A
     move.l   d2,-(a7)         ; save bit pattern
     bsr      Gi_Access1       ; select port A
     move.l   (a7)+,d2         ; restore bit pattern
     and.b    d2,d0            ; clear bit(s)
     move.l   #$8E,d1          ; write to port A
     bsr      Gi_Access1       ; write new value
     move     (a7)+,sr         ; restore status
     movem.l  (a7)+,d0-d2      ; restore registers
     rts

Snoop_Flag:   dc.w  0
Old_Trap13:   dc.l  0

DialBack_Msg: dc.b  Cr,Lf,Cr,Lf,"Dial-Back Mode Has Started...",Cr,Lf,0
              align.w

Tos_Msg:      dc.b  Cr,Lf,Cr,Lf,"System Shutdown In Progress...",Cr,Lf,0
              align.w

Snoop1_Msg:   dc.b  Cr,Lf,Cr,Lf,"Snoop Mode Activated...",Cr,Lf,0
              align.w

Snoop2_Msg:   dc.b  Cr,Lf,Cr,Lf,"Snoop Mode Deativated...",Cr,Lf,0
              align.w

Get_Char:                      ; Registers a5-a6 saved...
     movem.l  a5-a6,-(a7)
     bsr      Get_Timer
     move.l   Timer,a6
     add.l    #36000,a6
Get_Char1:
     bsr      Get_Timer
     move.l   Timer,a5
     cmp.l    a5,a6
     blt      Gc00
     bsr      Chk_Carrier
     cmp.w    #1,Carrier
     beq      Gc0
     bra.s    Gc9
Gc00:
     bsr      Disconnect       ; Disconnect user if 3 minutes
     move.w   #0,Carrier       ; Has lapsed since last keystroke...
     bra.s    Gc9
Gc0:
     bsr      Scan_Console
     cmp.w    #0,d0
     bne      Gc1
     cmp.w    #0,Fnct_Key
     bne      Gc1
     bsr      Scan_Modem
     cmp.w    #0,d0
     beq      Get_Char1
Gc1:
     cmp.w    #$5d,Fnct_Key    ; Shift - F10
     bne      Gfc1
     bra.s    Gc9
Gfc1:
     cmp.w    #$3f,Fnct_Key    ; F5
     bne      Gfc2
     bra.s    Gc9
Gfc2:
     cmp.w    #$3c,Fnct_Key    ; F2
     bne      Gfc3
     bra.s    Gc9
Gfc3:
     cmp.w    #1,Echo          ; Do we want it echoed?
     bne      Gc1b
     bsr      Put_Char
Gc1b:
     move.w   Char,d0
Gc2:
     move.w   d0,Char
Gc9:
     movem.l  (a7)+,a5-a6
     rts

Char:         dc.w  0
Echo:         dc.w  0
Fnct_Key:     dc.w  0
Local:        dc.w  0
Text_Adr:     dc.l  0

Put_Char:
     bsr      Chk_Carrier
     cmp.w    #1,Carrier
     beq      Pc0
     bra.s    Pc5
Pc0:
     cmp.w    #1,Local
     beq      Pc4
     bsr      Put_Modem
Pc4:
     bsr      Put_Console
Pc5:
     rts

Scan_Console:
     movem.l  a0-a2/d1-d4,-(a7)
     move.w   #0,Fnct_Key
     move.w   #2,-(a7)
     move.w   #1,-(a7)
     trap     #13
     addq.l   #4,a7
     movem.l  (a7)+,a0-a2/d1-d4
     tst.l    d0
     bpl.s    Skip_Con
Get_Console:
     movem.l  a0-a3/d1-d4,-(a7)
     move.w   #2,-(a7)
     move.w   #2,-(a7)
     trap     #13
     addq.l   #4,a7
     swap     d0
     move.w   d0,Fnct_Key
     swap     d0
     move.w   d0,Char
     movem.l  (a7)+,a0-a3/d1-d4
     rts

Skip_Con:
     move.w   #0,D0
     rts

Send_Console:
     move.l   a6,-(a7)
     move.l   Text_Adr,a6
Sc1: move.w   #0,Char
     move.b   (a6)+,Char+1
     cmp.w    #0,Char
     beq      Sc2
     bsr      Put_Console
     bra.s    Sc1
Sc2: move.l   (a7)+,a6
     rts

Put_Console:
     movem.l  a0-a2/d1-d4,-(a7)
     move.w   Char,-(a7)
     move.w   #2,-(a7)
     move.w   #3,-(a7)
     trap     #13
     addq.l   #6,a7
     movem.l  (a7)+,a0-a2/d1-d4
     rts

Send_Modem:
     move.l   a6,-(sp)
     move.l   Text_Adr,a6
Sm1: move.w   #0,Char
     move.b   (a6)+,Char+1
     cmp.w    #0,Char
     beq      Sm2
     bsr      Put_Modem
     bra.s    Sm1
Sm2: move.l   (sp)+,a6
     rts

Put_Modem:
     movem.l  a0-a2/d1-d4,-(a7)
     move.w   Char,-(a7)
     move.w   #1,-(a7)
     move.w   #3,-(a7)
     trap     #13
     addq.l   #6,a7
     movem.l  (a7)+,a0-a2/d1-d4
     rts

Scan_Modem:
     movem.l  a0-a2/d1-d4,-(a7)
     move.w   #1,-(a7)
     move.w   #1,-(a7)
     trap     #13
     addq.l   #4,a7
     movem.l  (a7)+,a0-a2/d1-d4
     tst.l    d0
     bpl.s    Skip_Modem
Get_Modem:
     movem.l  a0-a2/d1-d4,-(a7)
     move.w   #1,-(a7)
     move.w   #2,-(a7)
     trap     #13
     addq.l   #4,a7
     move.w   d0,Char
     movem.l  (a7)+,a0-a2/d1-d4
     rts

Skip_Modem:
     move.w   #0,d0
     move.w   d0,Char
     rts

Chk_carrier:
     movem.l  a1/d1,-(a7)
     clr.l    d1
     move.w   d1,Carrier
     cmp.w    #1,Local         ; If We're not in local mode
     bne      Carr_1           ;  We'll test for a carrier
     move.w   #1,Carrier
     bra.s    Carr_3
Carr_1:
     bsr      super_on
     move.l   #$fffa01,a1
     move.b   (a1),d1
     and.b    #2,d1
     cmp.b    #0,d1            ; 0 = Carrier Present
     bne      Carr_2
     move.w   #1,Carrier       ; Say That We Have A Carrier
Carr_2:
     bsr      super_off
Carr_3:
     cmp.w    #1,Carrier
     beq      Carr_4
Carr_4:
     movem.l  (a7)+,a1/d1
     rts

Carrier:      dc.w  0

Disconnect:
     movem.l  a1-a6/d1-d6,-(sp)
     move.w   #16,-(sp)
     move.w   #30,-(sp)
     trap     #14              ; Drop DTR Line...
     addq.l   #4,sp
Dscn1:
     move.w   #5,Seconds
     bsr      Pause
     move.w   #6,-(sp)
     move.w   #29,-(sp)
     trap     #14              ; Raise DTR Line...
     addq.l   #4,sp
     movem.l  (sp)+,a1-a6/d1-d6
     rts

Pause:
     movem.l  d0-d1,-(a7)
     bsr      Get_Timer
     move.l   Timer,d0
     clr.l    d1
     move.w   Seconds,d1
     mulu     #222,d1
     add.l    d1,d0
     move.l   d0,Max_Time
Pause1:
     bsr      Get_Timer
     move.l   Timer,d0
     cmp.l    Max_Time,d0
     blt.s    Pause1
     movem.l  (a7)+,d0-d1
     rts

Timer:        dc.l  0
Max_Time:     dc.l  0
Seconds:      dc.w  0

Get_Timer:
     bsr      super_on
     move.l   $4ba,Timer
     bsr      super_off
     rts

Super_On:
     movem.l  a0-a2/d0-d4,-(a7)
     clr.l    -(a7)
     move.w   #$20,-(a7)
     trap     #1
     add.l    #6,a7
     move.l   d0,Old_Supr
     movem.l  (a7)+,a0-a2/d0-d4
     rts

Super_Off:
     movem.l  a0-a2/d0-d4,-(a7)
     move.l   Old_Supr,-(a7)
     move.w   #$20,-(a7)
     trap     #1
     add.l    #6,a7
     movem.l  (a7)+,a0-a2/d0-d4
     rts

Old_Supr:     dc.l  0

                dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Usr_Stack:      dc.l  0,0

     End
 