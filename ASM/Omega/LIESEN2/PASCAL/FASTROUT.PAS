UNIT FastRout;

INTERFACE

VAR   InPal:      Array[0..15] of Word;
      InRez:      Word;
      InScreen:   Pointer;
      OldStack:   LongInt;    { f”r Super }

      ScreenAddr: Pointer;
      Resolution: Word;

{** GEMDOS **}
Function    ConIn:LongInt;
Function    AuxIn:byte;
Procedure   AuxOut(b:Byte);
Function    ConInDWE:Longint;
Function    ConInWE:LongInt;
Function    ConInStat:Integer;
Function    AuxInStat:Integer;
Function    AuxOutStat:Integer;
Function    SFirst(name:String;Attrib:Integer):Integer;
Function    SNext:Integer;

{** BIOS **}
Function    KbShift(Mode:Integer):LongInt;

{** XBIOS **}
Function    RsConf(Scr,Tas,Rsr,Ucr,Cntr,Baud:Integer):Integer;

{** POWER **}
Function    GetDtaName:String;
Function    S_Get50Hz:LongInt;
Function    Point2Long(ins:Pointer):LongInt;
Function    Long2Point(ins:LongInt):Pointer;
Procedure   SuperOn;
Procedure   SuperOff;

Procedure   WaitForKey;
Function    Exists(s:String):Boolean;
Function    LoadFile(s:String;Addr:Pointer;maxLength:Longint):LongInt;
Procedure   SetPal(Pal_Addr:Pointer);
Procedure   UpdateScreenAttrib;
Procedure   Plot0(X,Y,Col:Word);
Procedure   Plot1(X,Y,Col:Word);
Procedure   Plot2(X,Y,Col:Word);

IMPLEMENTATION

Function    ConIn:LongInt;
Begin
   ASM
      move.w   #1,-(a7)
      trap     #1
      addq.l   #2,a7
      move.l   d0,@Result
   END;
End;

Function    AuxIn:byte;
Begin
   ASM
      move.w   #3,-(a7)
      trap     #1
      addq.l   #2,a7
      move.b   d0,@Result
   END;
End;

Procedure   AuxOut(b:Byte);
Begin
   ASM
      moveq    #0,d0
      move.b   b(a6),d0
      move.w   d0,-(a7)
      move.w   #4,-(a7)
      trap     #1
      addq.l   #4,a7
   END;
End;

Function    ConInDWE:LongInt;
Begin
   ASM
      move.w   #7,-(a7)
      trap     #1
      addq.l   #2,a7
      move.l   d0,@Result
   END;
End;

Function    ConInWE:LongInt;
Begin
   ASM
      move.w   #8,-(a7)
      trap     #1
      addq.l   #2,a7
      move.l   d0,@Result
   END;
End;

Function    ConInStat:Integer;
Begin
   ASM
      move.w   #$b,-(a7)
      trap     #1
      addq.l   #2,a7
      move.w   d0,@Result;
   END;
End;

Function    AuxInStat:Integer;
Begin
   ASM
      move.w   #$12,-(a7)
      trap     #1
      addq.l   #2,a7
      move.w   d0,@Result;
   END;
End;

Function    AuxOutStat:Integer;
Begin
   ASM
      move.w   #$13,-(a7)
      trap     #1
      addq.l   #2,a7
      move.w   d0,@Result;
   END;
End;

Function    SFirst(name:String;Attrib:Integer):Integer;
Begin
   name:=name+#00;
   ASM
      move.w   Attrib(a6),-(a7)
      lea      name+1(a6),a0
      move.l   a0,-(a7)
      move.w   #$4e,-(a7)
      trap     #1
      addq.l   #8,a7
      move.w   d0,@Result
   END;
End;

Function    SNext:Integer;
Begin
   ASM
      move.w   #$4f,-(a7)
      trap     #1
      addq.l   #2,a7
      move.w   d0,@Result
   End;
End;

Function    KbShift(Mode:Integer):LongInt;
Begin
   ASM
      move.w   Mode(a6),-(a7)
      move.w   #11,-(a7)
      trap     #13
      addq.l   #4,a7
      move.l   d0,@Result
   END;
End;

Function    RsConf(Scr,Tas,Rsr,Ucr,Cntr,Baud:Integer):Integer;
{
   Sending -1 leaves unchanged!
   Scr..Rsr..  Se MFP!
   Ucr    : bit   0  Unused
                  1  0=Odd parity,  1=Even parity
                  2  0=No Parity,   1=Use parity as bit 1
                  3,4   nr of startBits
                     0 =Synchronus   0 start 0 stop
                     1 =Asynchronus  1 start 0 stop
                     2 =Asynchronus  1 start 1.5 stop
                     3 =Aynchhronus  1 start 2 stop
                  6,7   word length
                     0 =8 bits
                     1 =7 bits
                     2 =6 bits
                     3 =5 bits                    
   Cntr   : 0  No Handshake
            1  Xon / Xoff
            2  Rts / Cts
            3  Rts / Cts and Xon / Xoff
   Baud   : 0  19200
            1  9600
            2  4800
            3  2400
            4  1200
            5  600
            ..
            15 50       }
Begin
   ASM;
      move.w   Scr(a6),-(a7)
      move.w   Tas(a6),-(a7)
      move.w   Rsr(a6),-(a7)
      move.w   Ucr(a6),-(a7)
      move.w   Cntr(a6),-(a7)
      move.w   Baud(a6),-(a7)
      move.w   #15,-(a7)
      trap     #14
      lea      14(a7),a7
   END;
End;

Function GetDtaName:String;
Var   s:String;
Begin
   s:='';
   ASM;
      move.w   #$2f,-(a7)
      trap     #1
      addq.l   #2,a7
      move.l   d0,a0
      lea      s+1(a6),a1
      moveq    #11,d0
      lea      30(a0),a0
@Cop: move.b   (a0)+,d0
      move.b   d0,(a1)+
      addq.b   #1,s(a6)
      tst.b    d0
      bne      @Cop    
   end;
   GetDtaName:=s;
End;

Function S_Get50Hz:LongInt;     
Assembler;
ASM
   move.l   $466,@Result
End;


Procedure   SuperOn;
Begin
   ASM
      clr.l    -(a7)
      move.w   #$20,-(a7)
      trap     #1
      addq.l   #6,a7
      move.l   a6,OldStack
   END;
End;
Procedure   SuperOff;
Begin
   ASM
      move.l   OldStack,-(a7)
      move.w   #$20,-(a7)
      trap     #1
      addq.l   #6,a7
   END;
End;


Function    Point2Long(in:Pointer):LongInt;
Begin
   ASM
      move.l   ins(a6),@Result
   End;
End;

Function    Long2Point(in:LongInt):Pointer;
Begin
   ASM
      move.l   ins(a6),@Result
   End;
End;

Procedure   WaitForKey;
Begin
   ASM
      move.w   #7,-(a7)
      trap     #1
      addq.l   #2,a7
   END;
End;

Function    Exists(s:String);
Var   f:File;
Begin
   Assign(f,s);
   {$I-}
   Reset(f);
   {$I+}
   If IoResult<>0 Then
      Exists:=False
   Else
      Exists:=True;
   {$I-}
   Close(f);
   {$I+}
End;


Function    LoadFile(s:String;Addr:Pointer;maxLength:LongInt):LongInt;
Var   Handle:     Word;
Begin
   s:=s+#00;
   ASM
      lea      s(a6),a0
      addq.l   #1,a0
      clr.w    -(a7)
      move.l   a0,-(a7)
      move.w   #$3d,-(a7)
      trap     #1
      addq.l   #8,a7
      tst.w    d0
      bmi      @FELfelFEL
      move.w   d0,Handle(a6)
      
      move.l   Addr(a6),-(a7)
      move.l   maxLength(a6),-(a7)
      move.w   Handle(a6),-(a7)
      move.w   #$3f,-(a7)
      trap     #1
      lea      12(a7),a7
      tst.l    d0
      bmi      @FELfelFEL
      move.l   d0,@Result
      bra      @Closa

@FELfelFEL:
      move.l   d0,@Result
@Closa:
      move.w   Handle(a6),-(a7)
      move.w   #$3e,-(a7)
      trap     #1
      addq.l   #4,a7
   END;
End;


Procedure   SetPal(Pal_Addr:Pointer);
Begin
   ASM
      move.l   Pal_Addr(a6),-(a7)
      move.w   #6,-(a7)
      trap     #14
      addq.l   #6,a7
   END;
End;

Procedure   UpdateScreenAttrib;
Begin
   ASM
      move.w   Resolution,-(a7)
      move.l   ScreenAddr,-(a7)
      move.l   ScreenAddr,-(a7)
      move.w   #5,-(a7)
      trap     #14
      lea      12(a7),a7
   END;
End;

Procedure   Plot0(X,Y,Col:Word);
Begin
   ASM
      move.w   d2,-(a7)
      move.w   Y(a6),d0
      move.w   X(a6),d1
      move.l   ScreenAddr,a0
      mulu     #160,d0
      move.w   d1,d2
      and.w    #$F,d1
      sub.w    d1,d2
      asr.w    #1,d2
      add.w    d2,d0
      add.w    d0,a0
      eor      #$F,d1
      moveq    #0,d0
      bset     d1,d0
      move.w   d0,d1
      not.w    d1

      move.w   Col(a6),d2
      lsr.w    #1,d2
      bcc      @c1
      or.w     d0,(a0)+
      bra      @c2
@c1:  and.w    d1,(a0)+
@c2:  lsr.w    #1,d2
      bcc      @c3
      or.w     d0,(a0)+
      bra      @c4
@c3:  and.w    d1,(a0)+
@c4:  lsr.w    #1,d2
      bcc      @c5
      or.w     d0,(a0)+
      bra      @c6
@c5:  and.w    d1,(a0)+
@c6:  lsr.w    #1,d2
      bcc      @c7
      or.w     d0,(a0)+
      bra      @c8
@c7:  and.w    d1,(a0)+
@c8:  move.w   (a7)+,d2
      
   END;
End;
Procedure   Plot1(X,Y,Col:Word);
Begin
   ASM
      move.w   d2,-(a7)
      move.w   Y(a6),d0
      move.w   X(a6),d1
      move.l   ScreenAddr,a0
      mulu     #160,d0
      move.w   d1,d2
      and.w    #$F,d1
      sub.w    d1,d2
      asr.w    #2,d2
      add.w    d2,d0
      add.w    d0,a0
      eor      #$F,d1
      moveq    #0,d0
      bset     d1,d0
      move.w   d0,d1
      not.w    d1

      move.w   Col(a6),d2
      lsr.w    #1,d2
      bcc      @c1
      or.w     d0,(a0)+
      bra      @c2
@c1:  and.w    d1,(a0)+
@c2:  lsr.w    #1,d2
      bcc      @c3
      or.w     d0,(a0)+
      bra      @c4
@c3:  and.w    d1,(a0)+
@c4:  
      
   END;
End;

Procedure   Plot2(X,Y,Col:Word);
Begin
   ASM
      move.w   Y(a6),d0
      move.w   X(a6),d1
      move.l   ScreenAddr,a0
      mulu     #80,d0
      add.w    d0,a0
      move.w   d1,d0
      and.w    #$7,d1
      sub.w    d1,d0
      asr.w    #3,d0
      eor      #7,d1
      tst.w    Col(a6)
      bne      @TurnOn
      bclr     d1,0(a0,d0.w)
      bra      @leave
@TurnOn:
      bset     d1,0(a0,d0.w)
@Leave:
   END;
End;



Var   FastOldExitProc:   Pointer;
Procedure   CloseFastRout;
Begin
   ExitProc:=FastOldExitProc;
   ASM
      move.w   InRez,-(a7)       { Restore resolution and screen mem }
      move.l   InScreen,-(a7)
      move.l   InScreen,-(a7)
      move.w   #5,-(a7)
      trap     #14
      lea      12(a7),a7
      pea      InPal
      move.w   #6,-(a7)
      trap     #14
      addq.l   #6,a7
   END;
End;



BEGIN
   ASM
      movem.l  d0-a6,-(a7)
      pea      @Super1
      move.w   #38,-(a7)
      trap     #14
      addq.l   #6,a7
      movem.l  (a7)+,d0-a6
      bra      @Zuruck      
@Super1:
      move.w   #2,-(a7)
      trap     #14
      addq.l   #2,a7
      move.l   d0,ScreenAddr
      move.l   d0,InScreen
      
      move.w   #4,-(a7)
      trap     #14
      addq.l   #2,a7
      move.w   d0,Resolution
      move.w   d0,InRez

      movem.l  $ff8240,d0-d7
      movem.l  d0-d7,InPal      

      rts

@Zuruck:
   END;
   FastOldExitProc:=ExitProc;
   ExitProc:=@CloseFastRout;
END.