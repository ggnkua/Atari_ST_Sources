(* hierbei gab's mal nen buserror am Ende *)

DEFINITION MODULE A;
TYPE  Handle;
END A.

IMPLEMENTATION MODULE A;

IMPORT TOSIO;

TYPE MyType = RECORD col: CARDINAL; END;

TYPE Handle = POINTER TO MyType;      (* Der Opaque Typ wird redeklariert *)

END A.
