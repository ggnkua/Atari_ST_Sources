MODULE Execute;  (* Stephan Junker  20.11.93 / 6.3.94  *)

(*
 * Module Execute should be used by modules which run under the loader
 * as well as in stand alone program and it calls code which is available
 * as object module or stand alone program. Just call Exec with the name
 * of the program, and it determines whether to start a module or a program.
 * If you are shure to call a program, use GEMDOS.Pexec. If you are shure
 * to call a module, use O2Loader.CallModule.
 * This is achieved by having two versions of Execute: One using GEMDOS and
 * one using O2Loader. If your module runs under O2Loader, the integrated
 * module Execute will use O2Loader.CallModule, if you link your program
 * with the "official" version, it will use GEMDOS.
 *)


IMPORT S:=SYSTEM, Str:=Strings, GEMDOS;


PROCEDURE Exec*( name, command : ARRAY OF CHAR) : BOOLEAN;
  (*
   * This is the version which uses GEMDOS.Pexec to start the program
   * "name".
   * Exec returns true if there was no error (i.e. Pexec returns 0).
   *)
  VAR s : ARRAY 128 OF CHAR;
 BEGIN
  (* just program version *)
  COPY( command, s); Str.InsertC( CHR( Str.Length(s) ), 0, s);
  RETURN SHORT( GEMDOS.Pexec( 0, S.ADR( s), S.ADR(name), 0) ) = 0
 END Exec;


END Execute.