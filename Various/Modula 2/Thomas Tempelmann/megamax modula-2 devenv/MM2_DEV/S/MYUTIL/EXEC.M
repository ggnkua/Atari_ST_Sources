MODULE Exec;

(*$E MTP*)
FROM ArgCV IMPORT InitArgCV, PtrArgStr;
FROM EasyGEM0 IMPORT FormAlert;
FROM ShellMsg IMPORT StdPaths, ShellPath;
FROM Loader IMPORT CallModule, LoadModule, LoaderResults;
FROM Strings IMPORT String;

(*
PROCEDURE CallModule ( REF fileName : ARRAY OF CHAR;
                           paths    : PathList;
                       REF arg      : ARRAY OF CHAR;
                           env      : ADDRESS;
                       VAR exitCode : INTEGER;
                       VAR errMsg   : ARRAY OF CHAR;  (* 80 Zeichen max. *)
                       VAR result   : LoaderResults);
*)

VAR modName, errMsg: String;
    result: LoaderResults;
    argv: ARRAY [0..2] OF PtrArgStr;
    argc: CARDINAL;
    i: INTEGER;

BEGIN
  InitArgCV (argc, argv);
  IF argc > 1 THEN
    CallModule (argv[1]^, StdPaths, "", NIL, i, errMsg, result);
  ELSE
    FormAlert (1, "[1][No prg specified][ OK ]", argc);
  END
END Exec.

(* $FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$0000036A$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E$FFED562E€$000002FAT.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$0000035A$000002D3$FFED562E$00000042$0000001F$0000035A$FFED562E$0000034C$0000035A$00000364$000002FA$000003AC$0000039B$0000001A$00000066$00000355¬€€*)
