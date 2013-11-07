{  Computer dependent routines for RAVE
   (C) Martin Liesen 1991-92

   For more information see the main RAVE source code.

   All part of this source code is strictly forbidden to copy without
   the written premission of Martin Liesen
}

{  Computer specific constants }

Const
   Brain_mode: Array[0..1] of String[8]= ('Wingmute','Carbon  ');

{  Global variabels within Computer dependet file }

Var  
      hint_nr:    Shortint;

{  Here goes local function / procedures  }

Function GetTime:LongInt;     { Just for time checking!  }
Begin
   ASM
      pea      0
      move.w   #$20,-(a7)
      trap     #1
      addq.l   #6,a7
      move.l   $466,@Result
      move.l   d0,-(a7)
      move.w   #$20,-(a7)
      trap     #1
      addq.l   #6,a7
   End;
End;


Procedure DrawBox(X,Y:Word;P1,P2,P3,P4:LongInt);
Begin
   ASM
      movem.l  d0-d4/a0,-(a7)
      move.w   #2,-(a7)
      trap     #14
      addq.l   #2,a7
      move.l   d0,a0
      lea      80*80+20(a0),a0
      move.w   Y(a6),d0
      mulu     #32*80,d0
      add.w    d0,a0
      move.w   X(a6),d0
      lsl.w    #2,d0
      add.w    d0,a0
      move.l   P1(a6),d0
      move.l   P2(a6),d1
      move.l   P3(a6),d2
      move.l   P4(a6),d3
      moveq    #7,d4
@loop:
      move.l   d0,(a0)
      move.l   d1,80(a0)
      move.l   d2,160(a0)
      move.l   d3,240(a0)
      lea      320(a0),a0      
      dbra     d4,@loop
      movem.l  (a7)+,d0-d4/a0
   END;
End;

Procedure DrawBrick(X,Y,COLOR:Word);
Begin
   ASM
      move.w   #2,-(a7)
      trap     #14
      addq.l   #2,a7
      move.l   d0,a0
      lea      80*80+20(a0),a0
      move.w   Y(a6),d0
      mulu     #32*80,d0
      add.w    d0,a0
      move.w   X(a6),d0
      lsl.w    #2,d0
      add.w    d0,a0
      lea      @cirkle1(pc),a1
      moveq    #31,d1
      tst.w    COLOR(a6)
      beq      @white
@black:
      move.l   (a1)+,d0
      or.l     d0,(a0)
      lea      80(a0),a0
      dbra     d1,@black
      bra      @slut
@white:
      move.l   (a1)+,d0
      not.l    d0
      and.l    d0,(a0)
      lea      80(a0),a0
      dbra     d1,@white
      bra      @slut


@cirkle1:
dc.w  $0000,$0000,$000F,$F000,$007F,$FE00,$00FF,$FF00
dc.w  $03FF,$FFC0,$07FF,$FFE0,$0FFF,$FFF0,$0FFF,$FFF0
dc.w  $1FFF,$FFF8,$3FFF,$FFFC,$3FFF,$FFFC,$3FFF,$FFFC
dc.w  $7FFF,$FFFE,$7FFF,$FFFE,$7FFF,$FFFE,$7FFF,$FFFE
dc.w  $7FFF,$FFFE,$7FFF,$FFFE,$7FFF,$FFFE,$7FFF,$FFFE
dc.w  $3FFF,$FFFC,$3FFF,$FFFC,$3FFF,$FFFC,$1FFF,$FFF8
dc.w  $0FFF,$FFF0,$0FFF,$FFF0,$07FF,$FFE0,$03FF,$FFC0
dc.w  $00FF,$FF00,$007F,$FE00,$000F,$F000,$0000,$0000
{
dc.w  $0000,$0000,$000F,$F000,$007F,$FE00,$00FF,$FF00
dc.w  $03FF,$FFC0,$07FF,$FFE0,$0FFF,$FFF0,$0FFF,$FFF0
dc.w  $1FE7,$FFF8,$3FC3,$E7FC,$3FC3,$C3FC,$3FC3,$C3FC
dc.w  $7FC3,$E7FE,$7FE7,$FFFE,$7FFF,$FFFE,$7FFF,$FFFE
dc.w  $7FFF,$FF9E,$7FFF,$FF9E,$7CFF,$FF9E,$7E7F,$FF1E
dc.w  $3E3F,$FF3C,$3F0F,$FC3C,$3F83,$F07C,$1FC0,$01F8
dc.w  $0FF0,$03F0,$0FFC,$07F0,$07FF,$FFE0,$03FF,$FFC0
dc.w  $00FF,$FF00,$007F,$FE00,$000F,$F000,$0000,$0000 }
@slut:
   END;
End;

Procedure No_Cursor;
Begin
   Write(chr(27),'f');
End;


{   Here goes all the proc / functions which might be called from RAVE }

Procedure Start_IO;
Begin
   No_Cursor;
End;

Procedure End_IO;
Begin
   ASM
      move.w   #2,-(a7)
      pea      -1
      pea      -1
      move.w   #5,-(a7)
      trap     #14
      lea      12(a7),a7
   END;
End;

Procedure Screen_Header;
Begin
   ClrScr;
   Inv_Off;
   WriteLn('RAVE - development V1.01  ST');
   WriteLn('(C) Martin Liesen 1991-92');
End;

{  Here goes Global routines }

Procedure Setup;
Var   line:    Shortint;
      key:     Char;
      scan:    Word;
Begin
   hint_nr:=0;
   line:=2;

   Screen_Header;
   Repeat
      GotoXY(2,6);
      If line=0 Then Inv_on Else Inv_off;
      WriteLn('Player 1 is : ',brain_mode[pl[White]^.brain]);
      GotoXY(2,7);
      If line=1 Then Inv_on Else Inv_off;
      WriteLn('Player 2 is : ',brain_mode[pl[Black]^.brain]);
      GotoXY(2,9);
      If line=2 Then Inv_on Else Inv_off;
      WriteLn('Start game            ');
      GotoXY(2,10);
      If line=3 Then Inv_on Else Inv_off;
      WriteLn('Quit Rave             ');
      ASM
         move.w   #7,-(a7)
         trap     #1
         addq.l   #2,a7
         move.w   d0,key(a6)
         swap     d0
         move.w   d0,scan(a6)
      END;
      If scan=$50 Then
         Inc(line,1);
      If scan=$48 Then
         Dec(line,1);
      If line>3 Then Dec(line,4);
      If (key=chr(13)) and (line=0) Then Begin
         Inc(pl[White]^.brain,1);
         If pl[White]^.brain>1 Then Dec(pl[White]^.brain,2);
      End;
      If (key=chr(13)) and (line=1) Then Begin
         Inc(pl[Black]^.brain,1);
         If pl[Black]^.brain>1 Then Dec(pl[Black]^.brain,2);
      End;

      If line<0 Then Inc(line,4);
   Until (line>1) and (key=chr(13));
   If line=3 Then
      Prog_end:=True;
End;

Procedure Can_not_move(player:Shortint);
Begin
   Inv_On;
   GotoXY(1,25);
   Write('Player ',player,' can''t play round  <Space>');
   Repeat
   Until ReadKey=' ';
   GotoXY(1,25);
   Write(chr(27),'l');
End;


Procedure Game_ended(map_addr:Pointer);
Const yesno: Array[0..1] of Char = ('p','q');
Var   map:  ^map_t;
      key:  Char;
      pos:  Shortint;   { 0=Yes 1=No }
Begin
   pos:=0;
   Repeat
      GotoXY(1,25);
      Inv_Off;
      Write('Game ended, quit ? ');
      Write(chr(27),yesno[pos]);
      Write('Yes ');
      Write(chr(27),yesno[(not pos) and 1]);
      Write('No  ');
      Repeat
      Until Keypressed;
      key:=Readkey;
      pos:=(not pos) and 1;
   Until key=chr(13);
   pos:=(not pos) and 1;
   If pos=0 Then Prog_end:=True;
   GotoXY(1,25);
   Write(chr(27),'l');
End;

Procedure Init_screen;
Var
   x,y     :Shortint;
Begin
   Screen_Header;
   GotoXY(23,5);
   WriteLn('a   b   c   d   e   f   g   h');
   For x:=1 to 8 Do Begin
      GotoXY(20,5+x*2);Write(Chr(48+x));
      GotoXY(53,4+x*2);Write(Chr(48+x));
   End;
   GotoXY(22,22);
   WriteLn('a   b   c   d   e   f   g   h ');
   For x:=0 to 7 Do
      For y:=0 to 7 Do
         If Odd(x+y) Then
            DrawBox(x,y,$AAAAAAAA,$55555555,$AAAAAAAA,$55555555)
         Else
            DrawBox(x,y,$22222222,$88888888,$11111111,$44444444);
End;

Procedure Draw_map(map_addr:Pointer);
Var   map   :^map_t;
      x,y   :ShortInt;
Begin
   map:=map_addr;
   For x:=0 to 7 Do
      For y:=0 to 7 Do Begin
         If Odd(x+y) Then
            DrawBox(x,y,$AAAAAAAA,$55555555,$AAAAAAAA,$55555555)
         Else
            DrawBox(x,y,$22222222,$88888888,$11111111,$44444444);
         If map^[x,y]=White Then
            DrawBrick(x,y,0);
         If map^[X,Y]=Black Then
            DrawBrick(x,y,1);

      End;
End;


Function Human_input(var pos:pos_t; map_addr:Pointer;player:Shortint):Shortint;
Var   key:  Char;
      scan: Word;
      map:  ^map_t;
      pos2,
      pos3: pos_t;
      count:Shortint;
Begin
   map:=map_addr;
   Human_input:=0;
   If Pos_possible(player,pos,map_addr) Then 
      DrawBox(pos.x,pos.y,$40404040,$00000000,$04040404,$00000000)
   Else 
      DrawBox(pos.x,pos.y,$BBBBBBBB,$EEEEEEEE,$77777777,$DDDDDDDD);
   If map^[pos.x,pos.y]=White Then 
      DrawBrick(pos.x,pos.y,0);
   If map^[pos.x,pos.y]=Black Then
      DrawBrick(pos.x,pos.y,1);


   If Keypressed=True Then Begin
      ASM
         move.w   #7,-(a7)
         trap     #1
         addq.l   #2,a7
         move.w   d0,key(a6)
         swap     d0
         move.w   d0,scan(a6)
      END;
      Case scan of
         $4d:  Inc(pos.x,1);
         $4b:  Dec(pos.x,1);
         $50:  Inc(pos.y,1);
         $48:  Dec(pos.y,1);
      End;
      If pos.x<0 Then Inc(pos.x,8);
      If pos.y<0 Then Inc(pos.y,8);
      If pos.x>7 Then Dec(pos.x,8);
      If pos.y>7 Then Dec(pos.y,8);
      Draw_map(map_addr);
      If (key='H') or (key='h') Then Begin
         Inc(hint_nr,1);
         count:=0;
         For pos2.y:=0 To 7 Do
            For pos2.x:=0 To 7 Do
               If Pos_possible(player,pos2,map_addr) Then Begin
                  If (count=0) or (count=hint_nr) Then
                     pos3:=pos2;
                  Inc(count,1);
               End;
         If hint_nr>=count Then hint_nr:=0;
         Draw_map(map_addr);
         pos:=pos3;
      End;
      If key=chr(27) Then
         Human_input:=5;
      If key=chr(13) Then
         If Pos_possible(player,pos,map_addr) Then
            Human_input:=1;
   End;
End;
Procedure   UpdateBoard(Player:ShortInt);
Begin
   If Player=White Then
      Inv_On
   Else
      Inv_Off;
   GotoXY(58,8);
   Write('White play      :',Pl[White]^.Layed:2);
   GotoXY(58,9);
   Write('White pass      :',Pl[White]^.Notlayed:2);
   GotoXY(58,10);
   Write('White "score"   :',Calculate_Score(Player,Main_map):5);
   GotoXY(58,11);
   Write('White last move :',Chr(Pl[White]^.Last_pos.x+65),Pl[White]^.Last_pos.y+1);
   
   If Player=Black Then
      Inv_On
   Else
      Inv_Off;
   GotoXY(58,8);
   GotoXY(58,13);
   Write('Black play      :',Pl[Black]^.Layed:2);
   GotoXY(58,14);
   Write('Black pass      :',Pl[Black]^.Notlayed:2);
   GotoXY(58,15);
   Write('Black "score"   :',Calculate_Score(Player,Main_map):5);
   GotoXY(58,16);
   Write('Black last move :',Chr(Pl[Black]^.Last_pos.x+65),Pl[Black]^.Last_pos.y+1);
End;