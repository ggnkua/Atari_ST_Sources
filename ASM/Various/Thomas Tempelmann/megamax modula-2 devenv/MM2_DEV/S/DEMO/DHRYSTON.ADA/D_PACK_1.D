DEFINITION MODULE D_Pack_1;

FROM D_Global IMPORT RecordPointer, OneToFifty, Array1DimInteger,
                     Array2DimInteger, Enumeration;
FROM D_Pack_2 IMPORT Proc6, Proc7, IntGlob, Char1Glob;


PROCEDURE Proc1 (    PointerParVal: RecordPointer);

PROCEDURE Proc2 (VAR IntParRef:     OneToFifty);

PROCEDURE Proc3 (VAR PointerParRef: RecordPointer);

PROCEDURE Proc4;

PROCEDURE Proc5;



VAR  PointerGlob,
     NextPointerGlob: RecordPointer;

     BoolGlob:        BOOLEAN;
     Char2Glob:       CHAR;
     Array1Glob:      Array1DimInteger;
     Array2Glob:      Array2DimInteger;

END D_Pack_1.



