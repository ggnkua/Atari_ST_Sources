IMPLEMENTATION MODULE AsmCall;

(*
  Begun:  02/24/1986
  This Version Tested: 02/26/1986
  Author: J. Tal - Rollins Medical/Dental Systems
*)


FROM SYSTEM IMPORT ADDRESS,ADR,GETREG,SETREG,CODE,WORD,BYTE,BX,DS;
FROM Strings IMPORT Length,Copy;


CONST
  PushES = 006H;
  PopES  = 007H;

  PushCS = 00EH;

  PushSS = 016H;
  PopSS  = 017H;

  PushDS = 01EH;
  PopDS  = 01FH;

  PushAX = 050H;
  PushCX = 051H;
  PushDX = 052H;
  PushBX = 053H;
  PushSP = 054H;
  PushBP = 055H;
  PushSI = 056H;
  PushDI = 057H;

  PopAX  = 058H;
  PopCX  = 059H;
  PopDX  = 05AH;
  PopBX  = 05BH;
  PopSP  = 05CH;
  PopBP  = 05DH;
  PopSI  = 05EH;
  PopDI  = 05FH;


  CallFar = 0FFH;
  IndirBX = 01FH;
  Iret   = 0CFH;



PROCEDURE AsmCall(CMND : ARRAY OF CHAR; VAR ERRF,RECNO,ADRKEY : CARDINAL;
                   OFFSET,SEGMENT : CARDINAL);

VAR
 errf,recno,adrkey : WORD;
 offsetHi,offsetLo,segmentHi,segmentLo : BYTE;
 cmnd : ARRAY[0..255] OF CHAR;
 cmndL,offset,segment : CARDINAL;
 cmndAddr,errfAddr,recnoAddr,adrkeyAddr,stringDescrAddr : ADDRESS;
 cmndAdrOfs : WORD;
 indirect : ARRAY[0..3] OF CHAR;
 stringDescriptor : ARRAY[0..3] OF CHAR;
 indirectAddr : ADDRESS;
 i : CARDINAL;
 tempCard : CARDINAL;

BEGIN
IF SEGMENT = 0 THEN
  HALT;
END;

  (* copy string to local area *)

  cmndL := Length(CMND);
  Copy(CMND,0,cmndL,cmnd);

  cmndL := Length(cmnd);

  (* build 4 byte string descriptor *)

  cmndAddr := ADR(cmnd);

  stringDescriptor[0] := CHR(ORD(cmndL MOD 256));
  stringDescriptor[1] := CHR(ORD(cmndL DIV 256));
  stringDescriptor[2] := CHR(ORD(cmndAddr.OFFSET MOD 256));
  stringDescriptor[3] := CHR(ORD(cmndAddr.OFFSET DIV 256));


  stringDescrAddr := ADR(stringDescriptor);

  (* move all vars to local *)

  errf := WORD(0);
  recno := WORD(RECNO);
  adrkey := WORD(ADRKEY);

  errfAddr := ADR(errf);
  recnoAddr := ADR(recno);
  adrkeyAddr := ADR(adrkey);

  offset := 08H;   (* compiled BASIC entry point for 4 byte string descr *)
  segment := SEGMENT;

  indirect[0] := CHR(ORD(offset MOD 256));
  indirect[1] := CHR(ORD(offset DIV 256));
  indirect[2] := CHR(ORD(segment MOD 256));
  indirect[3] := CHR(ORD(segment DIV 256));

  indirectAddr := ADR(indirect);
  (*  we will use CALL FAR indirect to get to our routine in memory, so BX
      must contian the offset/segment of where we want to go *)


  CODE(PushBX);      (* save these guys *)
  CODE(PushBP);
  CODE(PushDS);

  (*  DS is saved because through testing we found that DS does not
      necessarily point to the same place of the .SEGMENT address
      of the local variables.   Each variable in Modula-2 can be
      located anywhere in memory, so a OFFSET/SEGMENT are declared
      for each.    If you don't set DS to match the SEGMENT of your
      data that you want to pass to the routine, you will have problems.
  *)


  (* load up stack *)

  (* push 4 byte string descriptor *);

  SETREG(BX,stringDescrAddr.OFFSET);  CODE(PushBX);
  SETREG(BX,errfAddr.OFFSET);     CODE(PushBX);
  SETREG(BX,recnoAddr.OFFSET);    CODE(PushBX);
  SETREG(BX,adrkeyAddr.OFFSET);   CODE(PushBX);
  SETREG(BX,indirectAddr.OFFSET);

  SETREG(DS,indirectAddr.SEGMENT);   (* make DS agree with vars on stack *)

  CODE(CallFar,IndirBX);           (*  CALL FAR Indirect *)

  (* Routine now working....RET *)

  (* back from call, restore DS, BP, & BX *)

  CODE(PopDS);
  CODE(PopBP);
  CODE(PopBX);

  (* assign back to VARS in parameter list *)

  ADRKEY := CARDINAL(adrkey);
  RECNO := CARDINAL(recno);
  ERRF := CARDINAL(errf);

END AsmCall;



END AsmCall.