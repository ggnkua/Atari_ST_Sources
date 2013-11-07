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

Uses  Crt,Dos,STPascal;

Type
   map_t = Array[0..7,0..7] of Shortint;
   pos_t = Record
      x,y:Shortint;
   End;
   Pl_t = Record
      Brain    :Shortint;    { 0=Computer 1=Human }
      Last_pos :pos_t;
      Layed    :Shortint;
      Notlayed :Shortint;
   End;

Const
   Empty = 0;
   White = 1;
   Black = 2;

   computer = 0;
   human    = 1;

   Other_Player: Array[White..Black] of ShortInt=(Black,White);

Var
   Pl:         Array[1..2] of ^Pl_t;
   Prog_end:   Boolean;

   Main_map:   ^map_t;
   Empty_map:  ^map_t;

   direction: Array[0..7] of pos_t;



{$I A:\RAVE_STD}  {  Standard routines goes here   }
{$I A:\RAVE_ST}   {  Computer dependent code goes here }



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
   If Can_make_turn(player,map_addr)=True Then Begin
      Repeat
         result:=Human_input(pos,map_addr,player);
      Until (result=1) or (result=2) or (result=5);
   End Else Begin
      Can_not_move(player);
      result:=2;
   End;
   Get_man_move:=result;
End;



Function Get_com_move(player:Shortint;map_addr:Pointer;Var Pos:pos_t):Shortint;
Begin



   Get_com_move:=2;
End;

Procedure Game_loop;
Var   pos      :pos_t;
      stop_it  :Shortint;  { 0=not  1=Game end  2=Interrupt }
      Player   :Shortint;
      result   :Shortint;
Begin
   player:=White;
   Init_screen;
   Draw_map(Main_map);

   pos.x:=4;
   pos.y:=4;
   stop_it:=0;

   Repeat
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
End;



Begin
   Start_IO;
   Create_Direction;
   New(Pl[1]);
   New(Pl[2]);
   Pl[1]^.brain:=human;
   Pl[2]^.brain:=computer;
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
   Dispose(Pl[1]);
   Dispose(Pl[2]);
End.
