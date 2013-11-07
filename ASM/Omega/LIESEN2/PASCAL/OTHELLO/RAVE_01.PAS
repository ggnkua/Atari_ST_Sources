{  RAVE     - Time and space, an experiment!

               May the brain come forward and show itself.

   This program is (C)opyright 1991-92 Martin Liesen

   This code is bulid upon the idea to create a program which can produce
   what might look like a clever move.  The sub-purpose is to win the
   Electra convention contest in Reversi.

   No parts of this code may be copied without the written premission of
   it's authour Martin Liesen.

   Purpose with life:   Girls, Art
            Quite hard to reconstruct.. hu?
}
{$M 64,1,3200,40}
Uses  STPascal;

Type
   map_t = Array[0..7,0..7] of Shortint;
   pos_t = Record
      x:Shortint;
      y:Shortint;
   End;
   Pl_t = Record
      Brain    :Shortint;     { 0=Computer 1=Human }
      Last_pos :pos_t;
      Layed    :Shortint;
      Notlayed :Shortint;
   End;

Const
   Empty = 0;
   White = -1;
   Black = 1;
   Other_Player: Array[White..Black] of ShortInt=(Black,Empty,White);

   computer = 0;
   human    = 1;
   Limit    = 4;
Var
   Pl:         Array[White..Black] of ^Pl_t;
   Prog_end:   Boolean;
   direction:  Array[0..7] of pos_t;

   Main_map:   ^map_t;
   Empty_map:  ^map_t;


{$I D:\LIESEN\PASCAL\OTHELLO\RAVE_STD}  {  Standard routines goes here         }
{$I D:\LIESEN\PASCAL\OTHELLO\RAVE_ST}   {  Computer dependent code goes here   }



{   This sections is for init procedures }

Procedure Create_Direction;
Begin
   direction[0].x:=0;
   direction[0].y:=-1;
   direction[1].x:=1;
   direction[1].y:=-1;
   direction[2].x:=1;
   direction[2].y:=0;
   direction[3].x:=1;
   direction[3].y:=1;
   direction[4].x:=0;
   direction[4].y:=1;
   direction[5].x:=-1;
   direction[5].y:=1;
   direction[6].x:=-1;
   direction[6].y:=0;
   direction[7].x:=-1;
   direction[7].y:=-1;
End;


Procedure Create_standard_maps;
Var   x,y:  Integer;
Begin
   If Empty_map=nil Then
      new(Empty_map);
   If Main_map=nil Then
      new(Main_map);
   For x:=0 to 7 Do
      For y:=0 to 7 Do
         Empty_map^[x,y]:=Empty;
   Main_map^:=Empty_map^;
   Main_map^[3,3]:=White;
   Main_map^[4,3]:=Black;
   Main_map^[3,4]:=Black;
   Main_map^[4,4]:=White;
End;



Function Get_man_move(player:Shortint;map_addr:Pointer;Var Pos:pos_t):Shortint;
Var   result   :Shortint;
Begin
   If Can_make_turn(player,map_addr) Then Begin
      Repeat
         result:=Human_input(pos,map_addr,player);
      Until (result=1) or (result=2) or (result=5);
   End Else Begin
      Can_not_move(player);
      result:=2;
   End;
   Get_man_move:=result;
End;


Function BrainStorm(Mode,Count,Player:ShortInt;map_addr:Pointer):Integer;
Var   Old_Map,Map    :^Map_t;
      posen          :Pos_t;
      s,extrem       :Integer;
Begin
   If Count=Limit Then Begin
      BrainStorm:=Calculate_score(Player,map_addr);
   End Else Begin
      Old_Map:=map_addr;
      If Mode=0 Then Begin
         extrem:=-9876;
         For Posen.x:=0 to 7 Do Begin
            For Posen.y:=0 to 7 Do Begin
               If Pos_possible(player,Posen,Old_Map) Then Begin
                  New(Map);
                  ASM
                     move.l   Map(a6),a1
                     move.l   Old_Map(a6),a0
                     moveq    #7,d0
                     @Kopia1:
                     move.l   (a0)+,(a1)+
                     move.l   (a0)+,(a1)+
                     dbra     d0,@Kopia1
                  END;
                  Make_Turn(player,Posen,Map);
                  s:=BrainStorm(1,Count+1,Player,Map);
                  Dispose(Map);
                  If s>extrem Then Begin
                    extrem:=s;
                  End;
               End;
            End;
         End;
         If extrem=-9876 Then Begin
            BrainStorm:=BrainStorm(1,Count+1,Player,Old_Map);
         End Else Begin
            BrainStorm:=s;
         End;
      End Else Begin
         extrem:=9876;
         For Posen.x:=0 to 7 Do Begin
            For Posen.y:=0 to 7 Do Begin
               If Pos_possible(Other_player[player],Posen,Old_Map) Then Begin
                  New(Map);
                  ASM
                     move.l   Map(a6),a1
                     move.l   Old_Map(a6),a0
                     moveq    #7,d0
                     @Kopia2:
                     move.l   (a0)+,(a1)+
                     move.l   (a0)+,(a1)+
                     dbra     d0,@Kopia2
                  END;
                  Map^:=Old_Map^;
                  Make_Turn(Other_player[player],posen,Map);
                  s:=BrainStorm(0,Count+1,Player,Map);
                  Dispose(Map);
                  If s<extrem Then Begin
                    extrem:=s;
                  End;
               End;
            End;
         End;
         If extrem=9876 Then Begin
            BrainStorm:=BrainStorm(0,Count+1,Player,Old_Map);
         End Else Begin
            BrainStorm:=s;
         End;
      End;

   End;
End;

Function Get_com_move(player:Shortint;map_addr:Pointer;Var Pos:pos_t):Shortint;
Var   Posen       :Pos_t;
      Old_Map,Map :^Map_t;
      Extrem      :Integer;
      s           :Integer;
Begin
   Old_Map:=map_addr;
   Extrem:=-9999;
   Get_com_move:=2;
   Pos.x:=8;
   Pos.y:=8;
   For Posen.x:=0 to 7 Do
      For Posen.y:=0 to 7 Do Begin
         If Pos_possible(player,Posen,Old_Map) Then Begin
            New(Map);
            Map^:=Old_Map^;
            Make_Turn(player,Posen,Map);
            s:=BrainStorm(1,1,player,Map);
{            GotoXY(21+Posen.X*4,6+Posen.y*2);Write(s:4);
}            Dispose(Map);
            If s>Extrem Then Begin
               Extrem:=s;
               Pos:=Posen;
               Get_com_move:=1;
            End;
         End;
   End;
{   Repeat
   Until KeyPressed;
}End;

Procedure Game_loop;
Var   pos      :pos_t;
      stop_it  :Shortint;  { 0=not  1=Game end  2=Interrupt }
      Player   :Shortint;
      result   :Shortint;
      time     :LongInt;
Begin
   player:=White;
   Init_screen;
   Draw_map(Main_map);

   pos.x:=4;
   pos.y:=4;
   stop_it:=0;

   time:=GetTime;
   Repeat
      UpdateBoard(player);
      If Pl[player]^.brain=human Then
         result:=Get_man_move(player,Main_map,pos)
      Else
         result:=Get_com_move(player,Main_map,pos);
      Case result of
      1: Begin    { Make move !!! }
            Pl[player]^.Last_pos:=pos;
            Inc(Pl[player]^.layed,1);
            Make_turn(player,pos,Main_map);
            Draw_map(Main_map);
            player:=Other_player[player];
         End;
      2: Begin    { Move impossible !!! }
            Inc(Pl[player]^.notlayed,1);
            player:=Other_player[player];
         End;
      5: Begin    { Cancel game }
            stop_it:=2;
         End;
      Else
         Begin
            Halt(1);
         End;
      End;
      If Can_make_turn(player,Main_map)=False Then
         If Can_make_turn(Other_player[player],Main_map)=False Then
            stop_it:=1;
   Until stop_it<>0;
   WriteLn(GetTime-time);
   UpdateBoard(player);
End;



Begin
   Create_Direction;
   Start_IO;
   New(Pl[White]);
   New(Pl[Black]);
   Pl[White]^.brain:=human;
   Pl[Black]^.brain:=computer;
   Prog_end:=False;

   Empty_map:=nil;
   Main_map:=nil;
   Repeat
      Create_standard_maps;
      Setup;
      If Prog_end=False Then Begin
         Game_loop;
         Game_ended(Main_map);
      End;
   Until Prog_end=True;
   End_IO;
   Dispose(Empty_map);
   Dispose(Main_map);
   Dispose(Pl[White]);
   Dispose(Pl[Black]);
End.
