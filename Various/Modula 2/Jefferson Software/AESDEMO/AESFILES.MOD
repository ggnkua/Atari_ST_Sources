IMPLEMENTATION MODULE AESFileSelector;

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

PROCEDURE FselInput(VAR inpath, insel : ARRAY OF CHAR;
                    VAR exbutton : INTEGER) : INTEGER;
BEGIN
  AddrIn[0] := ADR(inpath);
  AddrIn[1] := ADR(insel);

  Contrl.OpCode   := 90;
  Contrl.NIntIn   := 0;
  Contrl.NIntOut  := 2;
  Contrl.NAddrIn  := 2;
  Contrl.NAddrOut := 0;

  AES;

  exbutton := IntOut[1];

  RETURN IntOut[0];

END FselInput;

END AESFileSelector.
