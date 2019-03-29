
    { -- Window Variables -- }
     OP_Menu        : Menu_Ptr;                      { Main Menu Handle }
     ExitPrompt     : Boolean;           { Continue Event_Loop Until True }
     Resolution,
     i              : short_integer;     { Counter used in Main Program Module }

    { -- Internal Data Variables -- }
     Gem_Result     : Gem_Window;
     MenuItem       : Gem_Menu;                     { Gem parameters }

     N_Window       : short_integer;             { Number of Open Window }
     WindHandle     : array[1..MaxWind] of short_integer ;
     WindName,
     WindTitle,
     FileTitle      : array[1..MaxWind] of Window_Title ;
     DefaultFn      : Path_Name ;
     SearchStr      : Str255 ;
     C_PathStr      : C_String ;
     P_PathStr      : Str255 ;

     x,y,w,h        : short_integer ;
     XPos,
     YPos           : array[1..MaxWind] of short_integer ;
     NumLines,
     NumColumns     : short_integer ;
     Module         : short_integer ;
     XOffset,
     YOffset,
     WindOffset,
     VertOffset,
     TotalRec       : array[1..MaxWind] of short_integer ;

     MaxRec,
     TotRec         : short_integer ;
     EditFlag       : array[1..MaxWind] of boolean ;

     Current,
     FirstRec,
     LastRec,
     ScrFirstRec    : array[1..MaxWind] of WordPointer ;
     DelRec         : WordPointer ;

     BlkMark        : array[1..2] of WordPointer ;
     BlkBuffer,
     BlkLast        : WordPointer ;
     BlkSize        : short_integer ;
     BlkModule      : short_integer ;

