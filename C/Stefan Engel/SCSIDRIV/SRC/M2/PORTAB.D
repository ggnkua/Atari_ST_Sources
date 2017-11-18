DEFINITION MODULE Portab;
(****************************************************************************
 *
 * Modul mit diversen Konstanten und Parametern
 *
 * $Source: E:\HM2\LIB\se\rcs\portab.d,v $
 *
 * $Revision: 1.1 $
 *
 * $Author: S_Engel $
 *
 * $Date: 1995/01/01 19:13:52 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: portab.d,v $
 * Revision 1.1  1995/01/01  19:13:52  S_Engel
 * Initial revision
 *
 *
 *
 ****************************************************************************)

IMPORT SYSTEM;

(* Verwendeter Compiler *)
TYPE
  tCompiler = (Haenisch, Megamax);

CONST
  Compiler = Haenisch;

(* Pfade und Dateinamen *)
  PATHLEN = 1024;
  NAMELEN = 128;

TYPE
  tPath   = ARRAY[0..PATHLEN] OF CHAR;
  tName   = ARRAY[0..NAMELEN] OF CHAR;

(* Allgemein und oft benutzter String-Typ *)
TYPE
  tStr    = ARRAY[0..MAX(INTEGER)-2] OF CHAR;
  tpStr   = POINTER TO tStr;
  tpChar  = POINTER TO CHAR;


(* C-Typen *)
TYPE
  USHORT  = SHORTCARD;
  SHORT   = SHORTINT;
  LPSHORT = POINTER TO SHORT;
  ULONG   = SHORTCARD;
  LONG    = LONGCARD;
  LPLONG  = POINTER TO LONG;

  UChar   = [0..255];
(*$?SYSTEM.TSIZE(UChar) # 1: Typ-Fehler *)

  Char    = [-128..127];
(*$?SYSTEM.TSIZE(Char) # 1: Typ-Fehler *)

  BOOL    = BOOLEAN;

  LPSTR   = POINTER TO ARRAY[0..MAX(LONGINT)-2] OF CHAR;

  HPVOID  = SYSTEM.ADDRESS;

  HPCHAR  = POINTER TO ARRAY[0..MAX(LONGINT)-2] OF CHAR;

  tINT    = SHORTINT;

  LPINT   = POINTER TO SHORTINT;


(* einige vorbesetzte Werte, die gelegentlich benutzt werden *)
VAR
  NullProc : PROC;


END Portab.
