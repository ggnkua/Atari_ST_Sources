DEFINITION MODULE InOutFile;

(*
  System-Modul fÅr InOut. Nicht verwenden !
*)

PROCEDURE redirectInput (REF fileName: ARRAY OF CHAR);
PROCEDURE redirectOutput (REF fileName: ARRAY OF CHAR; append: BOOLEAN);
PROCEDURE openInput (REF defExt: ARRAY OF CHAR);
PROCEDURE openOutput (REF defExt: ARRAY OF CHAR);

END InOutFile.
