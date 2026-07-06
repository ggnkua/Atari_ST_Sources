IMPLEMENTATION MODULE AESApplications;

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

FROM SYSTEM IMPORT ADDRESS, ADR, SETREG, INLINE;

FROM AES IMPORT Global, Contrl, IntIn, IntOut, AddrIn, AddrOut, AES;

PROCEDURE ApplInit() : INTEGER;
BEGIN
  Global.apPrivate := 0D;
  Global.apPTree := 0D;
  Global.ap1resv := 0D;
  Global.ap2resv := 0D;
  Global.ap3resv := 0D;
  Global.ap4resv := 0D;

  Contrl.OpCode := 10;
  Contrl.NIntIn := 0;
  Contrl.NIntOut := 1;
  Contrl.NAddrIn := 0;
  Contrl.NAddrOut := 0;

  AES;

  RETURN IntOut[0];

END ApplInit;

PROCEDURE ApplRead(id, length : INTEGER; pbuff : ARRAY OF CHAR) : INTEGER;
BEGIN
  IntIn[0] := id;
  IntIn[1] := length;

  AddrIn[0] := ADR(pbuff);

  Contrl.OpCode := 11;
  Contrl.NIntIn := 2;
  Contrl.NIntOut := 1;
  Contrl.NAddrIn := 1;
  Contrl.NAddrOut := 0;

  AES;

  RETURN IntOut[0];

END ApplRead;

PROCEDURE ApplWrite(id, length : INTEGER; pbuff : ARRAY OF CHAR) : INTEGER;
BEGIN
  IntIn[0] := id;
  IntIn[1] := length;

  AddrIn[0] := ADR(pbuff);

  Contrl.OpCode := 12;
  Contrl.NIntIn := 2;
  Contrl.NIntOut := 1;
  Contrl.NAddrIn := 1;
  Contrl.NAddrOut := 0;

  AES;

  RETURN IntOut[0];

END ApplWrite;

PROCEDURE ApplFind(name : FName) : INTEGER;
BEGIN
  AddrIn[0] := ADR(name);

  Contrl.OpCode := 13;
  Contrl.NIntIn := 0;
  Contrl.NIntOut := 1;
  Contrl.NAddrIn := 1;
  Contrl.NAddrOut := 0;

  AES;

  RETURN IntOut[0];

END ApplFind;

PROCEDURE ApplTPlay(mem : ARRAY OF CHAR; num, scale : INTEGER) : INTEGER;
BEGIN
  IntIn[0] := num;
  IntIn[1] := scale;

  AddrIn[0] := ADR(mem);

  Contrl.OpCode := 14;
  Contrl.NIntIn := 2;
  Contrl.NIntOut := 1;
  Contrl.NAddrIn := 1;
  Contrl.NAddrOut := 0;

  AES;

  RETURN IntOut[0];

END ApplTPlay;

PROCEDURE ApplTRecord(mem : ARRAY OF CHAR; count : INTEGER) : INTEGER;
BEGIN
  IntIn[0] := count;

  AddrIn[0] := ADR(mem);

  Contrl.OpCode := 15;
  Contrl.NIntIn := 1;
  Contrl.NIntOut := 1;
  Contrl.NAddrIn := 1;
  Contrl.NAddrOut := 0;

  AES;

  RETURN IntOut[0];

END ApplTRecord;

PROCEDURE ApplExit() : INTEGER;
BEGIN
  Contrl.OpCode := 19;
  Contrl.NIntIn := 0;
  Contrl.NIntOut := 1;
  Contrl.NAddrIn := 0;
  Contrl.NAddrOut := 0;

  AES;

  RETURN IntOut[0];
END ApplExit;

END AESApplications.
