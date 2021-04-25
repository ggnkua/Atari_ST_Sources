Program VarRecs;

Type
    D_Fields    =  (Alpha, Numeric, Int_Number, Long_Int, Formula);

    Cell_Ptr    =  ^Cell_TR;

    Cell_TR     =  Record

        Column,
        Row     :  Integer;

        DType   :  Byte;

        Above,
        AboveL,
        Left,
        BelowL,
        Below,
        BelowR,
        Right,
        AboveR  :  Cell_Ptr;

        Case Data_Type :  D_Fields of
            Alpha      :  ( AData  :  String      ) ;
            Numeric    :  ( NData  :  Real        ) ;
            Int_Number :  ( IData  :  Integer     ) ;
            Long_Int   :  ( LData  :  Long_Integer) ;
            Formula    :  ( FData  :  String      ) ;
    End; {Record Cell_Ptr}

Var

    Cells : Cell_Ptr;

Procedure MainLine;

Begin
    WriteLn('Hello');
End; {Procedure Mainline}

Begin
    MainLine;
End. {Program VarRecs}

