{  Sorce docementation to RAVE
   (C)opyright Martin Liesen 1991-92	}

{
   Computer dependet routines:
   *  Start_IO;
         Initilize graphic input / output.
   *  End_IO;
         Close down and restore graphics and keybord.
   *  Setup;
   *  Init_screen;
   *  Draw_map(map_addr:Pointer);
   *  Can_not_move(player:Shortint);
   *  Human_input(var x,y:Shortint,map_addr:Pointer,pos:pos_t):Shortint;
         Observe that the coordinates is VAR.
         Returns  0 if no move has taken place yet
                  1 if move is made (and garrantied possible)
                  2 (NOT) if there is no possible move at all.
                  3 if pause is requested
                  4 pause is removed
                  5 game is canceled
   *  Game_ended(map_addr:pointer);
         This routine has the possibility to set the flag Prog_end to True
         and thereby end the program after returning.

   Procedure and function library:
      Can_make_turn( player:Shortint; map_addr:Pointer):Boolean;
   *  Pos_possible( player:Shortint; pos:pos_t; map_addr:Pointer):Boolean;
      Make_turn( player:Shortint; pos:pos_t; map_addr:Pointer);
   *  Map_score(player:Shortint; map_addr:Pointer):Integer;
   *  Calculate_score(player:Shortint;map_addr:Pointer):Integer;

      Other_player(pl:pl_t):pl_t;

   Problems:
      Dealing with 'can not make move' in tree structure
      Sorting out the best way concidering the tree
      Quite a problem with "debugging"
      Memory, do one branch at a time.. The tree takes quite some memory!
      Computer dependend routines must be a TPU file. (right now uses CRT)
         this is VERY computer dependent and should not be done i RAVE source.


   Setup variables which can be altered from computer dependent routine SETUP.
      Pl1_mode:   pl_mode_t;
      Pl2_mode:   pl_mode_t;
      Prog_end:   Boolean;


   Global variables of greater interest:
      Main_map:   ^map_t;     Address to the current "time" map
      Empty_map   ^map_t;     Address to a map filled with "e"

   Global constants of greater interest:
      direction:Array[0..7] of pos_t;  For scanning in all directions
      White,Black,Empty:               For reconizing in MAP and which player.

   Other routines:
      Create_standard_maps;      Creates the Main & Empty map and fills them
      Game_loop;                 The "during game" loop procedure.

      Get_man_move(player:pl_t;map_addr:Pointer,Var Pos:pos_t):Shortint;
      Get_com_move(player:pl_t;map_addr:Pointer,Var Pos:pos_t):Shortint;
         Observe that the coordinates is VAR.
         Returns  0 can not happen
                  1 if move is made (and garrantied possible)
                  2 if there is no possible move at all.
                  3 can not happen
                  4 can not happen
                  5 game is canceled
}
