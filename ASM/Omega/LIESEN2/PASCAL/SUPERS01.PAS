Program  SuperFont;
Uses FastRout;
Const
   Width=64;
   BytesWide=8;      { Must be multiple of 8!   }
   Hight=16;
   Cells=1;
   Palen:Array[0..15] of Word=(  $000,$111,$222,$333,$444,$555,$666,$777,
                                 $707,$606,$505,$404,$303,$202,$101,$777);
Var
   Data_p      :LongInt;
   Data_p2     :Pointer;
   Cell_big    :LongInt;
   Cell_big2   :Pointer;
   Cell_new    :LongInt;
   Cell_new2   :Pointer;




Function Get4Intensity(X,Y:Word):Word;       { X is even with 4!  }
                                             { Result is 0-16     }
Begin
      ASM
         move.w   d2,-(a7)
         clr.w    d2
         
         move.l   Cell_big,a0
         lea      @LightTab(pc),a1
         move.w   #BytesWide,d0
         mulu     Y(a6),d0
         add.w    d0,a0
         move.w   X(a6),d0
         move.w   d0,d1
         and.w    #$FFF0,d0
         lsr.w    #3,d0
         add.w    d0,a0

         add.w    #4,d1
         and.w    #$C,d1

         move.w   (a0),d0
         rol.w    d1,d0
         and.w    #$F,d0
         move.b   0(a1,d0.w),d2
         
         add.w    #BytesWide,a0
         move.w   (a0),d0
         rol.w    d1,d0
         and.w    #$F,d0
         add.b    0(a1,d0.w),d2
         
         add.w    #BytesWide,a0
         move.w   (a0),d0
         rol.w    d1,d0
         and.w    #$F,d0
         add.b    0(a1,d0.w),d2
         
         add.w    #BytesWide,a0
         move.w   (a0),d0
         rol.w    d1,d0
         and.w    #$F,d0
         add.b    0(a1,d0.w),d2
         
         move.w   d2,@Result
         bra      @Screw

         @LightTab:
         dc.b     0,1,1,2,1,2,2,3
         dc.b     1,2,2,3,2,3,3,4
         @Screw:
         move.w   (a7)+,d2
      END;
End;

Procedure SetPixel3bpl(x,y,i:Word);
Begin
   ASM
      move.w   d2,-(a7)
      move.w   i(a6),d2
      lea      @ToColor(pc),a1
      move.b   0(a0,d2.w),d2
      
      move.l   Cell_new,a0
      move.w   y(a6),d0
      mulu     #BytesWide/4,d0
      add.w    d0,a0
      move.w   x(a6),d0
      move.w   d0,d1
      and.w    #$fff0,d0
      sub.w    d0,d1
      lsr.w    #2,d0
      add.w    d0,a0

      add.w    d1,d1
      add.w    d1,d1
      move.w   18(a1,d1.w),d0
      move.w   20(a1,d1.w),d1
           
@d0:  cmp.b    #1,d2
      bhi      @d2
      beq      @d1
      and.w    d1,(a0)+
      and.w    d1,(a0)
      bra      @Fuckit
@d1:  or.w     d0,(a0)+
      and.w    d1,(a0)+
      bra      @Fuckit
@d2:  cmp.b    #2,d2
      bne      @d3
      and.w    d1,(a0)+
      or.w     d0,(a0)
      bra      @Fuckit
@d3:  or.w     d0,(a0)+
      or.w     d0,(a0)
      bra      @Fuckit
    
      @ToColor:
      dc.b     0,0,0,0,1,1,1,1
      dc.b     2,2,2,2,2,3,3,3,3
      dc.b     0
      @Values:
      dc.w     $8000,$7FFF
      dc.w     $4000,$BFFF
      dc.w     $2000,$DFFF
      dc.w     $1000,$EFFF
      dc.w     $0800,$F7FF
      dc.w     $0400,$FBFF
      dc.w     $0200,$FDFF
      dc.w     $0100,$FEFF
      dc.w     $0080,$FF7F
      dc.w     $0040,$FFBF
      dc.w     $0020,$FFDF
      dc.w     $0010,$FFEF
      dc.w     $0008,$FFF7
      dc.w     $0004,$FFFB
      dc.w     $0002,$FFFD
      dc.w     $0001,$FFFE
      @Fuckit:
      move.w   (a7)+,d2
   END;
End;

Procedure SuperSampla(Cell:Word);
Var   c        :Word;
      x,y      :Word;
      i        :Word;
Begin
   For c:=0 to cells-1 Do Begin
      Cell_Big:=Data_p+c*(Hight*BytesWide);
      For y:=0 to (Hight div 4)-1 Do Begin
         For x:=0 to (Width div 4)-1 Do Begin
            i:=Get4Intensity(x*4,y*4);
{            SetPixel3Bpl(x,y,i);}
            Plot0(x,y,round((i/16)*7));
         End;
      End;
   End;
End;

Var      pek   :^LongInt;
Begin
   GetMem(Data_p2,32000);
   pek:=@Data_p2;
   Data_p:=pek^;
   GetMem(Cell_new2,(BytesWide div 4)*(hight div 4));
   pek:=@Cell_new2;
   Cell_new:=pek^;
   If LoadFile('D:\FONT1.B',Data_p2,32000)<0 Then Begin
      Halt;
   End;
   Resolution:=2;
   UpdateScreenAttrib;
   SetPal(@Palen);
   SuperSampla(2);
   FreeMem(Cell_new2,(BytesWide div 4)*(hight div 4));
   FreeMem(Data_p2,65536);
   WaitForKey;
End.
