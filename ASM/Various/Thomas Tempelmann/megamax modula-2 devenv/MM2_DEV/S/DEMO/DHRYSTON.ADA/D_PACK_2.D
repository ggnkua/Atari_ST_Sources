DEFINITION MODULE D_Pack_2;

(*$Z+*)

FROM D_Global IMPORT Enumeration, OneToFifty, Array1DimInteger,
                     Array2DimInteger, CapitalLetter, String30, OneToThirty;

PROCEDURE Proc6 (    EnumParVal:    Enumeration;
                 VAR EnumParRef:    Enumeration);

PROCEDURE Proc7 (    Int1ParVal,
                     Int2ParVal:    OneToFifty;
                 VAR IntParRef:     OneToFifty);

PROCEDURE Proc8 (VAR Array1ParRef:  Array1DimInteger;
                 VAR Array2ParRef:  Array2DimInteger;
                     Int1ParVal,
                     Int2ParVal:    INTEGER);

PROCEDURE Func1 (    Char1ParVal,
                     Char2ParVal:   CapitalLetter):
                                            Enumeration;

PROCEDURE Func2 (VAR String1ParRef,
                     String2ParRef: String30):
                                            BOOLEAN;

PROCEDURE Func3 (EnumParVal: Enumeration): BOOLEAN;

VAR IntGlob:   INTEGER;
    Char1Glob: CHAR;


END D_Pack_2.