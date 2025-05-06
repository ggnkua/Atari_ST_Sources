PROGRAM Oss_Mouse ;

  CONST
    {$I gemconst.pas}

  TYPE
    {$I gemtype.pas}

  VAR
    m : Mouse_Form ;

  {$I gemsubs.pas}

  PROCEDURE New_Mouse ;

    VAR
      word : integer ;

    BEGIN
      m.hot_x := 2 ;
      m.hot_y := 3 ;
      m.res := 1 ;
      m.mask_color := White ;
      m.data_color := Black ;
      FOR word := 0 TO 15 DO
        BEGIN
          m.mask[word] := 0 ;
          m.data[word] := 0 ;
        END ;
      FOR word := 0 TO 8 DO
        m.mask[word] := $FFFF ;
      m.data[1] := $70e7 ;                      { -***----***--*** }
      m.data[2] := $8908 ;                      { *---*--*----*--- }
      m.data[3] := $8908 ;                      { *---*--*----*--- }
      m.data[4] := $89ef ;                      { *---*--****-**** }
      m.data[5] := $8821 ;                      { *---*-----*----* }
      m.data[6] := $8821 ;                      { *---*-----*----* }
      m.data[7] := $71ce ;                      { -***---***--***- }
      Set_MForm( m ) ;
    END ;

  PROCEDURE Wait_For_Button ;

    VAR
      msg : Message_Buffer ;
      dummy : integer ;

    BEGIN
      dummy := Get_Event( E_Button, 1, 1, 1, 0,
                        false, 0, 0, 0, 0, false, 0, 0, 0, 0,
                        msg, dummy, dummy, dummy, dummy, dummy, dummy ) ;
    END ;

  BEGIN
    IF Init_Gem >= 0 THEN
      BEGIN
        New_Mouse ;
        Wait_For_Button ;
        Set_Mouse( M_Arrow ) ;
        Exit_Gem ;
      END ;
  END.
