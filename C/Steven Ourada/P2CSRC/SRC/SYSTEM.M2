
(* Declarations for Modula-2 built-in objects *)

(* Note: All functions with unusual syntaxes are not included here *)



DEFINITION MODULE SYSTEM;   (*PERMANENT*)

TYPE
   PROC = PROCEDURE;
   ADDRESS = POINTER TO WORD;

FUNCTION  CAP(c : CHAR) : CHAR;
FUNCTION  CHR(i : INTEGER) : CHAR;
FUNCTION  ODD(i : INTEGER) : BOOLEAN;
FUNCTION  ROUND(x : REAL) : INTEGER;
FUNCTION  TRUNC(x : REAL) : INTEGER;
(* Other things are defined internally to p2c *)

END;



DEFINITION MODULE InOut;



END;



DEFINITION MODULE MathLib0;

FUNCTION  arctan(x : REAL) : REAL;
FUNCTION  cos(x : REAL) : REAL;
FUNCTION  entier(x : REAL) : INTEGER;
FUNCTION  exp(x : REAL) : REAL;
FUNCTION  ln(x : REAL) : REAL;
FUNCTION  real(i : INTEGER) : REAL;
FUNCTION  sin(x : REAL) : REAL;
FUNCTION  sqrt(x : REAL) : REAL;

END.


