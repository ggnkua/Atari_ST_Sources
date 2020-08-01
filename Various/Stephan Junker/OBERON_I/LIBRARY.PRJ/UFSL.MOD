MODULE UFSL;  (* SJ 26.2.95 *)

(*
 Support of UFSL by Michael ThÑnitz.
 UFSL is not supported anymore. Instead, Dirk Haun is working on an
 extended version. See XFSL.
 *)


IMPORT
  S:=SYSTEM, Cookie, Objc, Evnt;


CONST
  (* return codes *)
  OK* = 1;          (* Alles OK, Werte gÅltig. *)
  CANCEL* = 0;      (* Abbruch gewÑhlt. *)
  ERROUTOFMEM* = -1;(* Out of memory. *)
  ERRSEVERAL* = -2; (* UnzulÑssiger Mehrfachaufruf. *)
  ERRUNKNFONT* = -3;(* Fontgrîûe konnte nicht identifiziert werden. *)
  ERRFONTNUM* = -4; (* Anzahl Fonts muû grîûer null sein. *)
  ERRNOUFSL* = -100;(* UFSL nicht installiert. *)



TYPE
  String* = ARRAY 34 OF CHAR;

  CookiePtr* = POINTER TO RECORD
    id-: LONGINT;      (* UFSL ID (UFSL)       *)
    version-: INTEGER; (* Version (BCD-Format) *)
    dialtyp*: INTEGER; (* 0=Dialog, 1=Fenster  *)
   (*****************************************************************)
   (*
   nicht mehr unterstÅtzt ab 0.97, aber noch da:
   *)
   fontSelinit-: PROCEDURE(): INTEGER;
   fontSelinput-: PROCEDURE (
               VAR fretsize: INTEGER; (* eingestellte Fontgrîûe             *)
               VAR fretid: INTEGER;   (* eingestellte FontId                *)
               VAR text: String;      (* eigener Text, max. 34 Zeichen      *)
               ftype: INTEGER;        (* 1=nur monospaced Fonts, 0=alles    *)
               dummy: INTEGER;
               vdihandle: INTEGER
               );
   helpbutton*: Objc.ptr;             (* Typ: BOXTEXT                    *)
   helpfunc*: PROCEDURE;              (* Benutzerdefinierte Helpfkt.     *)
   (*****************************************************************)

   (**** ab Version 0.91 ********************************************)
   examplestr*: POINTER TO ARRAY OF CHAR;
                                    (* Beispieltext fÅr Fontdarstellung *)

   (**** ab Version 0.96 ********************************************)
   msgfunc*: PROCEDURE (event: INTEGER; VAR msgbuf: Evnt.msgbuf);
                                    (* Redrawfunktion *)

   (**** ab Version 0.97 ********************************************)
   fontselExinput-: PROCEDURE (
               VAR fretsize: INTEGER; (* eingestellte Fontgrîûe             *)
               VAR fretid: INTEGER;   (* eingestellte FontId                *)
               VAR text: String;      (* eigener Text, max. 34 Zeichen      *)
               ftype: INTEGER;        (* 1=nur monospaced Fonts, 0=alles    *)
               vdihandle: INTEGER
               ) : INTEGER;

  END;



PROCEDURE GetCookie*(VAR cookie: CookiePtr) : BOOLEAN;
(*
 Store the cookie value and return true if found.
 *)
  VAR
    value: LONGINT;
 BEGIN
  IF Cookie.Search("UFSL", value) THEN
    cookie := value;
    RETURN TRUE
  END;
  RETURN FALSE
 END GetCookie;


PROCEDURE ExInput*(
    vdihandle, ftype: INTEGER;
    text: String;
    example: ARRAY OF CHAR;
    VAR fretid, fretsize: INTEGER) : INTEGER;
  VAR
    cookie: CookiePtr;
 BEGIN
  IF GetCookie(cookie) THEN
    cookie.helpbutton := NIL;
    cookie.helpfunc := NIL;
    cookie.examplestr := S.ADR( example);
    cookie.msgfunc := NIL;
    RETURN cookie.fontselExinput(fretsize, fretid, text, ftype, vdihandle);
  END;
  RETURN -100;
 END ExInput;


END UFSL.