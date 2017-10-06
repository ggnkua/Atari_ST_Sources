UNIT M_Msgfile;

(* Routinen zur Behandlung von Messagefiles, wie sie von Tommi
 * KÅnneths MSQ2MSG erzeugt werden.
 *)

INTERFACE

FUNCTION  ReadMsgfile (CONST name: ARRAY OF CHAR; VAR date, time: WORD): BOOLEAN;
(* Liest ein Messagefile ein. *)
 
PROCEDURE GetMsgString (num: INTEGER; VAR msg: ARRAY OF CHAR);
(* Liefert den String mit der Nummer num *)
 
FUNCTION  GetMsgPtr (num: INTEGER): POINTER;
(* Liefert einen Zeiger auf den String mit Nummer num *)
 
PROCEDURE FreeMsgfile;
(* Gibt die benutzen Datenstrukturen und -bereiche wieder frei. *)

IMPLEMENTATION

USES m_Sys;


FUNCTION ReadMsgfile (CONST name: ARRAY OF CHAR; VAR date, time: WORD): BOOLEAN;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (name);
 CallMagic (1250);
 ReadMsgfile:= BOOLEAN (App^.MagicPB^.IntOut[0]);
 date:= App^.MagicPB^.IntOut[1];
 time:= App^.MagicPB^.IntOut[2];
END (*ReadMsgfile*);

PROCEDURE FreeMsgfile;
BEGIN
 CallMagic (1253);
END (*FreeMsgfile*);

PROCEDURE GetMsgString (num: INTEGER; VAR msg: ARRAY OF CHAR);
BEGIN
 App^.MagicPB^.IntIn[0]:= num;
 App^.MagicPB^.AddrIn[0]:= ADDR (msg);
 CallMagic (1251);
END (*GetMsgString*);

FUNCTION GetMsgPtr (num: INTEGER): POINTER;
BEGIN
 App^.MagicPB^.IntIn[0]:= num;
 CallMagic (1252);
 GetMsgPtr:= App^.MagicPB^.AddrOut[0];
END (*GetMsgPtr*);

END (*M_Msgfile*).