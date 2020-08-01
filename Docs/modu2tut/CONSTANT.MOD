                                         (* Chapter 6 - Program 4 *)
MODULE Constant;

CONST MaxSize    = 12;
      IndexStart = 49;
      CheckItOut = TRUE;

TYPE  BigArray  = ARRAY[1..MaxSize] OF CARDINAL;
      CharArray = ARRAY[1..MaxSize] OF CHAR;

VAR   AirPlane   : BigArray;
      SeaPlane   : BigArray;
      Helicopter : BigArray;
      Cows       : CharArray;
      Horses     : CharArray;
      Index      : CARDINAL;

BEGIN     (* main program *)
   FOR Index := 1 TO MaxSize DO
      AirPlane[Index] := Index*2;
      SeaPlane[Index] := Index*3 + 12;
      Helicopter[MaxSize - Index + 1] := Index + AirPlane[Index];
      Horses[Index] := 'X';
      Cows[Index] := "R";
   END;   (* of Index loop *)
END Constant.
