IMPLEMENTATION MODULE ClipBoard;

(* Jefferson Software Copyright 1986 *)

(* Jefferson Software      *)
(* 12416 N 28th Dr #18-236 *)
(* Phoenix,  AZ 85029-2434 *)
(* (602)243-3106           *)

(* Phase BBS (602)849-1287 (up to 2400 baud) has source *)
(* and answers about Jefferson Software Modula in Sig 8 *)

(* Compuserve ID 73637, 1245 *)

(* Permission to use this source is given to all who   *)
(* agree to include Jefferson Software's copyright     *)
(* notice, address, and phone number in all copies of  *)
(* this source or source derived from this source.     *)
(* Please send any changes, updates or bugs to us at   *)
(* Jefferson Software. If you have code you want to    *)
(* share with us all, send it and any documentation to *)
(* us. Please tell us if you want your name included.  *)

FROM SYSTEM IMPORT ADDRESS, ADR, REG, SETREG, INLINE, SHORT, LONG;

CONST D0 = 0;
  A7 = 15;

VAR
  a7 : LONGINT;
  clipTemp : LONGINT;
  magicnr : LONGINT;

PROCEDURE trapStatus;
BEGIN
  INLINE(91C8H); (* suba.l a0,a0 *)
  INLINE(2068H); INLINE(00A8H); (* movea.l a8(a0),a0 *)
  INLINE(2028H); INLINE(0002H); (* move.l 2(a0),d0 *)
  clipTemp := VAL(LONGINT,REG(D0));
END trapStatus; 

PROCEDURE InfoClip(VAR info : PClipInfo) : INTEGER;
TYPE
  proc = PROCEDURE();
VAR
  sup : proc;
BEGIN
  (* Supexec(trapStatus) (* XBIOS *) *)
  a7 := REG(A7); (* save stack pointer *)
  sup := trapStatus;
  SETREG(D0,sup);
  INLINE(2F00H); (* move.l d0,-(sp) *)
  SETREG(D0,38);
  INLINE(3F00H); (* move.w d0,-(sp) *)
  INLINE(4E4EH); (* trap #14 *)
  SETREG(A7,a7); (* pop stack *)

  magicnr := LONG(0FDB9H, 7531H);
  IF clipTemp # magicnr THEN RETURN 0 END;

  a7 := REG(A7); (* save stack pointer *)
  SETREG(D0,ADR(info));
  INLINE(2F00H); (* move.l d0,-(sp) *)
  SETREG(D0,0);
  INLINE(3F00H); (* move.w d0,-(sp) *)
  INLINE(4E4AH); (* trap 10 *)
  SETREG(A7,a7); (* pop stack *)
  RETURN SHORT(VAL(LONGINT,REG(D0)));
END InfoClip;

PROCEDURE UnloadClip() : INTEGER;
VAR i : INTEGER; (* dummy to hold Clip return *)
BEGIN
  a7 := REG(A7); (* save stack pointer *)
  SETREG(D0,1);
  INLINE(3F00H); (* move.w d0,-(sp) *)
  INLINE(4E4AH); (* trap 10 *)
  SETREG(A7,a7); (* pop stack *)
  RETURN SHORT(VAL(LONGINT,REG(D0)));
END UnloadClip;

PROCEDURE LoadClip() : INTEGER;
BEGIN
  a7 := REG(A7); (* save stack pointer *)
  SETREG(D0,2);
  INLINE(3F00H); (* move.w d0,-(sp) *)
  INLINE(4E4AH); (* trap 10 *)
  SETREG(A7,a7); (* pop stack *)
  RETURN SHORT(VAL(LONGINT,REG(D0)));
END LoadClip;

PROCEDURE ZeroClip;
VAR i : INTEGER; (* dummy to hold Clip return *)
BEGIN
  a7 := REG(A7); (* save stack pointer *)
  SETREG(D0,3);
  INLINE(3F00H); (* move.w d0,-(sp) *)
  INLINE(4E4AH); (* trap 10 *)
  SETREG(A7,a7); (* pop stack *)
END ZeroClip;

PROCEDURE PutClip(length : LONGINT; source : ADDRESS) : INTEGER;
BEGIN
  a7 := REG(A7); (* save stack pointer *)
  SETREG(D0,length);
  INLINE(2F00H); (* move.l d0,-(sp) *)
  SETREG(D0,source);
  INLINE(2F00H); (* move.l d0,-(sp) *)
  SETREG(D0,4);
  INLINE(3F00H); (* move.w d0,-(sp) *)
  INLINE(4E4AH); (* trap 10 *)
  SETREG(A7,a7); (* pop stack *)
  RETURN SHORT(VAL(LONGINT,REG(D0)));
END PutClip;

PROCEDURE GetClip(length : ADDRESS;
                  source : ADDRESS;
                  loadflag : CHAR) : INTEGER;
BEGIN
  a7 := REG(A7); (* save stack pointer *)
  SETREG(D0,loadflag);
  INLINE(3F00H); (* move.w d0,-(sp) *)
  SETREG(D0,source);
  INLINE(2F00H); (* move.l d0,-(sp) *)
  SETREG(D0,length);
  INLINE(2F00H); (* move.l d0,-(sp) *)
  SETREG(D0,5);
  INLINE(3F00H); (* move.w d0,-(sp) *)
  INLINE(4E4AH); (* trap 10 *)
  SETREG(A7,a7); (* pop stack *)
  RETURN SHORT(VAL(LONGINT,REG(D0)));
END GetClip;

PROCEDURE InitClip;
VAR i : INTEGER; (* dummy to hold Clip return *)
BEGIN
  a7 := REG(A7); (* save stack pointer *)
  SETREG(D0,6);
  INLINE(3F00H); (* move.w d0,-(sp) *)
  INLINE(4E4AH); (* trap 10 *)
  SETREG(A7,a7); (* pop stack *)
END InitClip;

END ClipBoard.
