    { -- Tape / Movie Variables -- }
     Name_Offset    : integer;
     Tape_Offset    : integer;
     Name_Select    : integer;
     Tape_Select    : integer;
     Dsply_Name     : integer;
     Dsply_Tape     : integer;
     Letter         : integer;
     Slide_Size     : integer;
     Slide_Pos      : integer;
     Dummy          : integer;
     DefDrive       : string[1];
     FilePath       : Path_Name;

    { -- Window Variables -- }
     Wind_Name      : array[1..5] of Window_Title;  { Window Names   }
     Wind_Handle    : array[1..5] of integer;       { Window Handles }
     Wind_Coor      : array[1..5, 1..4] of integer; { Window Coordinates    }
                                                     {  1 : X of Top Left    }
                                                     {  2 : Y of Top Left    }
                                                     {  3 : Width of Window  }
                                                     {  4 : Height of Window }
     N_Window       : integer;                       { Number of Open Wind }

     DO_Menu        : Menu_Ptr;                      { Main Menu Handle }

     ExitPrompt     : Boolean;           { Continue Event_Loop Until True }

     Module         : integer;           { Identifies current Window }
     Prev_Module    : integer;           { Identifies Previous open Window }

     i              : integer;          { Counter used in Main Program Module }
     x0, y0,
     w0, h0         : integer;          { Window Coordinants }

     Check,
     PathSlash,
     Slash,
     Colon,
     Sp,
     Comma,
     UnderLine      : char;

     Len,
     Field,
     X_Cursor,
     Y_Cursor       : integer;          { X and Y Position of Next Keyboard   }
                                        {  Input -- Updated in Keyboard_Input }
                                        {  and DesignKey_Input                }

     Resolution     : integer;          { System Resolution -- Program runs }
                                        {   in Medium and High only         }
     SaveByte       : integer;          { Used by Keyboard Input to determine }
                                        {   LoByte value from integer input   }
     Flag           : Boolean;          { General Purpose Boolean }

    { -- Data Files -- }
     Printer        : file of text;
     NameFv         : file of Name;
     InitialFv      : file of integer;
     CheckFv        : file of boolean;
     DefaultFv      : file of string;
     DeleteFv       : file of boolean;

    { -- Internal Data Variables -- }
     Gem_Result     : Gem_Window;
     MenuItem       : Gem_Menu;                     { Gem parameters }

    { -- Input_String is the variable that stores all keyboard input into the }
    {     correct position for latter storage, editting or deletion        -- }
     Input_String   : array[1..60] of string;

    { -- XY_VCR is an array that gives the initial X value, Y value and the   }
    {     maximum size of each Input_String variable                       -- }
     XY_VCR       : array[1..3, 1..60] of integer;


     VCR_Retrieve : boolean;                       { 0  = 'A'   }
     VCR_Point    : array[1..2,0..26] of integer;  { 25 = 'Z'   }
     VCR_Current  : integer;                       { 26 = other }
     Tape_Current : integer;
     VCR_Order    : array[1..2,0..Max_Movies] of integer;
     Movie_Delete : array[0..Max_Movies] of boolean;
     Tape_Delete  : array[0..Max_Movies] of boolean;
     VCR_Inverse  : array[0..27] of boolean;
     VCR_Name     : array[0..Max_Movies] of Name;
     VCR_Next     : array[1..2,0..Max_Movies] of integer;
     VCR_TapeNo   : array[0..Max_Movies] of integer;
     VCR_Count    : array[0..Max_Movies] of integer;
     VCR_Tape     : array[0..6,0..Max_Movies] of integer;
     Output_Name  : array[0..Max_Movies] of integer;
     Output_Tape  : array[0..Max_Movies] of integer;
     VCR_Check    : array[1..2,0..Max_Movies] of boolean;
