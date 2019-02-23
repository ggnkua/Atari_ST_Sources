     Name = string[40];

     Gem_Window = Record
         RL_Button   : integer;
         Up_Down     : integer;
         B_Clicks    : integer;
         Key_Input   : integer;
         B_Count     : integer;
         B_State     : integer;
         X_Mouse     : integer;
         Y_Mouse     : integer;
         Key_State   : integer;
         HiByte      : integer;
         LoByte      : integer;
         Character   : char;
         Timing      : Long_Integer;
         dummy       : integer;
         msg         : Message_Buffer;
         InBox1      : Boolean;
         InBox2      : Boolean;
         X_Pos       : array[1..2] of integer;
         Y_Pos       : array[1..2] of integer;
         Width       : array[1..2] of integer;
         Height      : array[1..2] of integer;
     end;

     Gem_Menu = record
          Title : array[1..2]  of integer;
          Item  : array[1..12] of integer;
     end;

