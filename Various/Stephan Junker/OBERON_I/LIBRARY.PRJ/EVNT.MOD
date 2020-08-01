MODULE Evnt;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |28.1.93  |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM,AES,Appl;

CONST MNSELECTED* = 10;
      WMREDRAW*   = 20; WMTOPPED* = 21; WMCLOSED* = 22; WMFULLED*   = 23;
      WMARROWED*  = 24; WMHSLID*  = 25; WMVSLID*  = 26; WMSIZED*    = 27;
      WMMOVED*    = 28; WMNEWTOP* = 29;
      ACOPEN*     = 40; ACCLOSE*  = 41;
      (* AES 4.1 *)                                    (* CF *)
      WMUNTOPPED* = 30; WMONTOP*  = 31; WMBOTTOM* = 33;
      WMICONIFY*  = 34; WMUNICONIFY*= 35; WMALLICONIFY*= 36;
      WMTOOLBAR*  = 37;
      APTERM*     = 50; APTFAIL*  = 51; APRESCHG* = 57;
      SHUTCOMPLETED* = 60; RESCHCOMPLETED* = 61;
      APDRAGDROP* = 63;
      SHWDRAW*    = 72;
      CHEXIT*     = 90;

      (* event bits *)
      KEYBOARD* = 0; BUTTON* = 1; MOUSE1* = 2; MOUSE2* = 3;
      MESSAGE* = 4; TIME* = 5;

      (* button bits *)
      LEFT* = 0; RIGHT* = 1;

      (* direction *)
      ENTER* = 0; LEAVE* = 1;

      (* shift bits *)
      RSHIFT* = 0; LSHIFT* = 1; CONTROL* = 2; ALTERNATE* = 3; CAPSLOCK* = 4;

TYPE msgbuf* = ARRAY 8 OF INTEGER;

PROCEDURE Keybd* (VAR Scan : INTEGER; VAR Ascii : CHAR);
 BEGIN
  AES.Call(14000100H);
  Scan := AES.IntOut[0] DIV 256;
  Ascii := CHR(AES.IntOut[0]);
 END Keybd;

PROCEDURE Button* (Clicks : INTEGER; Mask,State : SET;
                   VAR Nclicks,Mx,My : INTEGER; VAR Button,Shifts : SET);
 BEGIN
  AES.IntIn[0] := Clicks;
  AES.IntIn[1] := SHORT(S.VAL(LONGINT,Mask));
  AES.IntIn[2] := SHORT(S.VAL(LONGINT,State));
  AES.Call(15030500H);
  Nclicks := AES.IntOut[0];
  Mx := AES.IntOut[1]; My := AES.IntOut[2];
  Button := S.VAL(SET,LONG(AES.IntOut[3]));
  Shifts := S.VAL(SET,LONG(AES.IntOut[4]));
 END Button;

PROCEDURE Mouse* (Flag,X,Y,W,H : INTEGER; VAR Mx,My : INTEGER;
                  VAR Button,Shifts : SET);
 BEGIN
  AES.IntIn[0] := Flag;
  AES.IntIn[1] := X; AES.IntIn[2] := Y;
  AES.IntIn[3] := W; AES.IntIn[4] := H;
  AES.Call(16050500H);
  Mx := AES.IntOut[1]; My := AES.IntOut[2];
  Button := S.VAL(SET,LONG(AES.IntOut[3]));
  Shifts := S.VAL(SET,LONG(AES.IntOut[4]));
 END Mouse;

PROCEDURE Mesag* (VAR Msgbuf : msgbuf);
 BEGIN
  AES.AddrIn[0] := S.ADR(Msgbuf);
  AES.Call(17000101H);
 END Mesag;

PROCEDURE Timer* (Count : LONGINT);
 BEGIN
  AES.IntIn[0] := SHORT(Count);
  AES.IntIn[1] := SHORT(Count DIV 10000H);
  AES.Call(18020100H);
 END Timer;

PROCEDURE Multi* (Type : SET; Clicks : INTEGER; Mask,State : SET;
                  M1flags,M1x,M1y,M1w,M1h,M2flags,M2x,M2y,M2w,M2h : INTEGER;
                  VAR Msgbuf : msgbuf; Count : LONGINT; VAR Mx,My : INTEGER;
                  VAR Mbut,Shifts : SET; VAR Scan : INTEGER;
                  VAR Ascii : CHAR; VAR Nclicks : INTEGER) : SET;
 BEGIN
  AES.IntIn[0] := SHORT(S.VAL(LONGINT,Type));
  AES.IntIn[1] := Clicks;
  AES.IntIn[2] := SHORT(S.VAL(LONGINT,Mask));
  AES.IntIn[3] := SHORT(S.VAL(LONGINT,State));
  AES.IntIn[4] := M1flags;
  AES.IntIn[5] := M1x; AES.IntIn[6] := M1y;
  AES.IntIn[7] := M1w; AES.IntIn[8] := M1h;
  AES.IntIn[9] := M2flags;
  AES.IntIn[10] := M2x; AES.IntIn[11] := M2y;
  AES.IntIn[12] := M2w; AES.IntIn[13] := M2h;
  AES.IntIn[14] := SHORT(Count);
  AES.IntIn[15] := SHORT(Count DIV 10000H);
  AES.AddrIn[0] := S.ADR(Msgbuf);
  AES.Call(19100701H);
  Mx := AES.IntOut[1]; My := AES.IntOut[2];
  Mbut := S.VAL(SET,LONG(AES.IntOut[3]));
  Shifts := S.VAL(SET,LONG(AES.IntOut[4]));
  Scan := AES.IntOut[5] DIV 256;
  Ascii := CHR(AES.IntOut[5]);
  Nclicks := AES.IntOut[6];
  RETURN S.VAL(SET,LONG(AES.IntOut[0]))
 END Multi;

PROCEDURE KeyMsg* (VAR Msgbuf : msgbuf; VAR Shifts : SET;
                   VAR Scan : INTEGER; VAR Ascii : CHAR) : SET;
 (* wait for message and keys *)
 BEGIN
  AES.IntIn[0] := S.VAL(INTEGER,{KEYBOARD,MESSAGE});
  AES.AddrIn[0] := S.ADR(Msgbuf);
  AES.Call(19100701H);
  Shifts := S.VAL(SET,LONG(AES.IntOut[4]));
  Scan := AES.IntOut[5] DIV 256;
  Ascii := CHR(AES.IntOut[5]);
  RETURN S.VAL(SET,LONG(AES.IntOut[0]))
 END KeyMsg;

PROCEDURE MKstate* (VAR Mx,My : INTEGER; VAR Button,Shifts : SET);
 BEGIN
  AES.Call(4F000500H);
  Mx := AES.IntOut[1]; My := AES.IntOut[2];
  Button := S.VAL(SET,LONG(AES.IntOut[3]));
  Shifts := S.VAL(SET,LONG(AES.IntOut[4]));
 END MKstate;

PROCEDURE Dclick* (NewSpeed : INTEGER) : INTEGER;
 BEGIN
  AES.IntIn[0] := NewSpeed;
  IF NewSpeed >= 0 THEN AES.IntIn[1] := 1 ELSE AES.IntIn[1] := 0 END(*IF*);
  AES.Call(1A020100H);
 END Dclick;

END Evnt.
