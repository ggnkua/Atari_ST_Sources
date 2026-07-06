IMPLEMENTATION MODULE AES;

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

FROM SYSTEM IMPORT ADR, SETREG, INLINE;

PROCEDURE AES;

CONST
  D0 = 0;
  D1 = 1;

BEGIN
  SETREG(D1,ADR(AESParameterBlock));
  SETREG(D0,0C8H);
  INLINE(4E42H); (* trap #2 *)
END AES;

BEGIN
  AESParameterBlock.AddressOfContrl := ADR(Contrl);
  AESParameterBlock.AddressOfGlobal := ADR(Global);
  AESParameterBlock.AddressOfIntIn := ADR(IntIn);
  AESParameterBlock.AddressOfIntOut := ADR(IntOut);
  AESParameterBlock.AddressOfAddrIn := ADR(AddrIn);
  AESParameterBlock.AddressOfAddrOut := ADR(AddrOut);

END AES.
