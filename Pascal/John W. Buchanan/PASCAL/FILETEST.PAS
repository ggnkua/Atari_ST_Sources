PROGRAM File_Test ;

  CONST
    {$I gemconst.pas}

  TYPE
    {$I gemtype.pas}

  VAR
    name : Path_Name ;
    alert : Str255 ;
    junk : integer ;

  {$I gemsubs.pas}

  BEGIN
    IF Init_Gem >= 0 THEN
      BEGIN
        name := '' ;
        IF Get_Out_File( 'What file to save?', name ) THEN
          alert := concat( '[0][You chose file|', name, '][  OK  ]' )
        ELSE
          alert := '[2][You didn''t choose anything!][  OK  ]' ;
        junk := Do_Alert( alert, 0 ) ;
        Exit_Gem ;
      END ;
  END.
