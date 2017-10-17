IMPLEMENTATION MODULE Portab;
(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- Modul mit Bool-Konstanten zur Markierung fÅr verschiedene Compiler    -*)
(*-                                                                       -*)
(*- Damit kann mit Compiler-Optionen zwischen verschiedenen Typen         -*)
(*- umgeschaltet werden.                                                  -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
(****************************************************************************
 *
 * $Source: E:\HM2\LIB\se\rcs\portab.m,v $
 *
 * $Revision: 1.1 $
 *
 * $Author: S_Engel $
 *
 * $Date: 1995/01/01 19:14:44 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: portab.m,v $
 * Revision 1.1  1995/01/01  19:14:44  S_Engel
 * Initial revision
 *
 *
 *
 ****************************************************************************)

IMPORT
  SYSTEM;

BEGIN
  SYSTEM.ADDRESS(NullProc) := NIL;
END Portab.
