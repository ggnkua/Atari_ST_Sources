IMPLEMENTATION MODULE Network;

(**********************************************************)
(*   ROLLINS MEDICAL/DENTAL SYSTEMS                       *)
(*   360 CLAUSEN BUILDING                                 *)
(*   23100 PROVIDENCE DRIVE                               *)
(*   SOUTHFIELD, MI  48075-3677                           *)
(*   -------------------------------------------------    *)
(*  |                                                 |   *)
(*  | FileSystem for PcNetwork                        |   *)
(*  |                                                 |   *)
(*   -------------------------------------------------    *)
(*   Author: John Tal            Created: 02/28/1986      *)
(*   Version:  2.00 a          Last Edit: 04/26/1986      *)
(*                                                        *)
(*   (C) Copyright 1986 ROLLINS MEDICAL/DENTAL SYSTEMS    *)
(*       All Rights Reserved                              *)
(*                                                        *)
(*    Permission is hereby granted to use and modify the  *)
(*  following module in the implementation of customized  *)
(*  software.                                             *)
(*    This permission includes the right to re-distribute *)
(*  the original source code but does not include the     *)
(*  right to redistribute modified source code of this    *)
(*  program.                                              *)
(**********************************************************)


(*  provides file support on a PC network.
    can be used without a PC network if DOS 3.1+ is used.

    Commands here emulate/duplicate those in FileSystem.

    This module is a replacement for FileSystem and cannot be
    used in combination with it or DiskFiles.

    This code may be a little verbose.  If you can shrink it and
    it still works, let me know.

  Modifications:

    02/20/86 thru 02/21/86 -

                Added CriticalErrorISR Procedure to handle DOS int24
                if we run into invalid opens based on sharing modes
                already used on a particular file.   Per Logitech
                Fileio module and conversations with Logitech.

    03/05/1986 - Move Compiler Stack checking On directive to below
                 Lookup procedure.   Had problems getting at files
                 already opened by other processes with conflicting
                 sharing modes.

    03/31/1986 - Changed all checks for error/CriticalError.
                 Delete procedure Changed.
                 Found out delete (Dos 41H) wants full path name.
                 Will have to send it using DiskDirectory.CurrentDirectory().

    04/23/1986 - Changed letters for paramaters for mode/shar.
                 Effects all programs (i.e. Dental) using this module.

    04/25/1986 - ReWorked Lookup/DosOpen;
*)


FROM SYSTEM  IMPORT AX,BX,CX,DX,DI,SETREG,CODE,SWI,WORD,BYTE,ADDRESS,DOSCALL,
                    ADR,GETREG;
             IMPORT Strings;

FROM Terminal IMPORT WriteString, WriteLn;
FROM DOS3     IMPORT GetExtendedError;
FROM Environment  IMPORT Pause;


CONST
  PushAX = 50H;
  PopAX  = 058H;
  PopCX  = 059H;
  PopDX  = 05AH;
  PopBX  = 05BH;
  PopSP  = 05CH;
  PopBP  = 05DH;
  PopSI  = 05EH;
  PopDI  = 05FH;
  PopES  = 007H;
  PopSS  = 017H;
  PopDS  = 01FH;
  PushES = 006H;
  PushCS = 00EH;
  PushSS = 016H;
  Iret   = 0CFH;


VAR
 CriticalError : CARDINAL;
 CriticalErrorVector[0:90H] : PROCEDURE;
 CriticalVector[0:90H] : ARRAY[1..2] OF WORD;
 CriticalErrorSave : ARRAY [1..2] OF WORD;
 err : CARDINAL;


(*$S-*) (*$T-*) (*$R-*)


PROCEDURE GetXerror( VAR xerror : WORD);
VAR
  extendedError : WORD;
  errorClass,suggestedAction,locus : BYTE;
BEGIN
  CODE(55H);
  GetExtendedError(WORD(0),extendedError,errorClass,suggestedAction,locus);
  CODE(5DH);
  xerror := extendedError;
END GetXerror;


PROCEDURE SetError ( VAR f : File; VAR err : CARDINAL );
VAR
 xerror : WORD;
 error : CARDINAL;
BEGIN
  GetXerror(xerror);
  error := CARDINAL(xerror);
  CASE error OF
       0 :
    |  1 : WriteString('Invalid function number'); WriteLn;
    |  2 : WriteString('File not found'); WriteLn;
    |  3 : WriteString('Path not found'); WriteLn;
    |  4 : WriteString('Too many open files (no handles left)'); WriteLn;
    |  5 : WriteString('Access denied'); WriteLn;
    |  6 : WriteString('Invalid handle'); WriteLn;
    |  7 : WriteString('Memory control blocks destroyed'); WriteLn;
    |  8 : WriteString('Insufficient memory'); WriteLn;
    |  9 : WriteString('Invalid memory block address'); WriteLn;
    | 10 : WriteString('Invalid environment'); WriteLn;
    | 11 : WriteString('Invalid format'); WriteLn;
    | 12 : WriteString('Invalid access code'); WriteLn;
    | 13 : WriteString('Invalid data'); WriteLn;
    | 14 : WriteString('Reserved'); WriteLn;
    | 15 : WriteString('Invalid drive was specified'); WriteLn;
    | 16 : WriteString('Attempt to remove the current directory'); WriteLn;
    | 17 : WriteString('Not same devices'); WriteLn;
    | 18 : WriteString('No more files'); WriteLn;
    | 19 : WriteString('Attempt to write on write-protected diskette'); WriteLn;
    | 20 : WriteString('Unknown unit'); WriteLn;
    | 21 : WriteString('Drive not ready'); WriteLn;
    | 22 : WriteString('Unknown command'); WriteLn;
    | 23 : WriteString('Data error (CRC)'); WriteLn;
    | 24 : WriteString('Bad request structure length'); WriteLn;
    | 25 : WriteString('Seek error'); WriteLn;
    | 26 : WriteString('Unknown media type'); WriteLn;
    | 27 : WriteString('Sector not found'); WriteLn;
    | 28 : WriteString('Printer out of paper'); WriteLn;
    | 29 : WriteString('Write fault'); WriteLn;
    | 30 : WriteString('Read fault'); WriteLn;
    | 31 : WriteString('General failure'); WriteLn;
    | 32 : WriteString('Sharing violation'); WriteLn;
    | 33 : WriteString('Lock violation'); WriteLn;
    | 34 : WriteString('Invalid disk change'); WriteLn;
    | 35 : WriteString('FCB unavailable'); WriteLn;
    | 36 : WriteString('Sharing buffer overflow'); WriteLn;
    | 37..49 : WriteString('Reserved'); WriteLn;
    | 50 : WriteString('Network request not supported'); WriteLn;
    | 51 : WriteString('Remote computer not listening'); WriteLn;
    | 52 : WriteString('Duplicate name on network'); WriteLn;
    | 53 : WriteString('Network name not found'); WriteLn;
    | 54 : WriteString('Network busy'); WriteLn;
    | 55 : WriteString('Network device no longer exists'); WriteLn;
    | 56 : WriteString('Net BIOS command limit exceeded'); WriteLn;
    | 57 : WriteString('Network adapter hardware error'); WriteLn;
    | 58 : WriteString('Incorrect response from network'); WriteLn;
    | 59 : WriteString('Unexpected network error'); WriteLn;
    | 60 : WriteString('Incompatible remote adapter'); WriteLn;
    | 61 : WriteString('Print queue full'); WriteLn;
    | 62 : WriteString('Not enough space for print file'); WriteLn;
    | 63 : WriteString('Print file was deleted'); WriteLn;
    | 64 : WriteString('Network name was deleted'); WriteLn;
    | 65 : WriteString('Access denied'); WriteLn;
    | 66 : WriteString('Network device type incorrect'); WriteLn;
    | 67 : WriteString('Network name not found'); WriteLn;
    | 68 : WriteString('Network name limit exceeded'); WriteLn;
    | 69 : WriteString('Net BIOS session limit exceeded'); WriteLn;
    | 70 : WriteString('Temporarily paused'); WriteLn;
    | 71 : WriteString('Network request not accepted'); WriteLn;
    | 72 : WriteString('Print or disk redirection is paused'); WriteLn;
    | 73..79 : WriteString('Reserved'); WriteLn;
    | 80 : WriteString('File exists'); WriteLn;
    | 81 : WriteString('Reserved'); WriteLn;
    | 82 : WriteString('Cannot make directory entry'); WriteLn;
    | 83 : WriteString('Fail on INT 24'); WriteLn;
    | 84 : WriteString('Too many redirections'); WriteLn;
    | 85 : WriteString('Duplicate redirection'); WriteLn;
    | 86 : WriteString('Invalid password'); WriteLn;
    | 87 : WriteString('Invalid paramater'); WriteLn;
    | 88 : WriteString('Network device fault'); WriteLn;
    ELSE
      WriteString('Unknown error'); WriteLn;
   END;  (* CASE *)


CASE error OF
      2 : f.res := unknownfile;
 |    3 : f.res := unknownmedium;
 |    4 : f.res := toomanyfiles;
 | 5,32 : f.res := callerror;   (*  Access denied *)
    ELSE
       f.res := notdone;
  END;  (* CASE *)

END SetError;

PROCEDURE CriticalErrorISR;
BEGIN
  CODE(081H,0E7H,0FFH,000H);
  GETREG(DI,CriticalError);
  CODE(PopBP);
  CODE(PopAX,PopAX,PopAX);
  CODE(PopAX,PopBX,PopCX,
       PopDX,PopSI,PopDI,
       PopBP,PopDS,PopES);
  CODE(Iret);
END CriticalErrorISR;

PROCEDURE InitCritical;
BEGIN
 CriticalErrorSave[1] := CriticalVector[1];
 CriticalErrorSave[2] := CriticalVector[2];
END InitCritical;

PROCEDURE SetCritical;
BEGIN
 CriticalErrorSave[1] := CriticalVector[1];
 CriticalErrorSave[2] := CriticalVector[2];
 CriticalErrorVector := CriticalErrorISR;
 CriticalError := 256;
END SetCritical;

PROCEDURE RestoreCritical;
BEGIN
 CriticalVector[1] := CriticalErrorSave[1];
 CriticalVector[2] := CriticalErrorSave[2];
END RestoreCritical;


(* compiler restores were here *)


PROCEDURE Close ( f : File );
VAR
 error : WORD;
 err : CARDINAL;
BEGIN
  IF f.inuse THEN
    SetCritical;
    CODE(55H);
    DOSCALL(3EH,f.handle,error);
    CODE(5DH);
    RestoreCritical;

    err := CARDINAL(error);
    IF err = 0 THEN
      IF CriticalError = 256 THEN
        err := 0;
      ELSE
        err := CriticalError;
      END;
    END;

    IF err = 0 THEN
       f.inuse := FALSE;
       f.read := FALSE;
       f.write := FALSE;
       f.res := done;
    ELSE   (* error in operation *)
      SetError(f,err);
    END;
    RestoreCritical;
  ELSE   (*  file not set for reading *)
    f.res := callerror;
  END;
END Close;


PROCEDURE DosOpen (VAR f : File; fileName : ARRAY OF CHAR; mode,shar : CHAR);
VAR
  fd : CHAR;
  access, inher, sharMode, reserv : CARDINAL;
  smode : WORD;
  fpff : BYTE;
  error : WORD;
  filename : ARRAY [0..64] OF CHAR;

  PROCEDURE AssignOpen;
  BEGIN
    Strings.Copy(filename,0,Strings.Length(filename),f.name);
    f.pointHigh := WORD(0);
    f.pointLow := WORD(0);
    f.read := FALSE;       (*  must be set with SetRead *)
    f.write := FALSE;      (*  must be set with SetWrite *)
    f.inuse := TRUE;
    f.eof := FALSE;
    f.res := done;
  END AssignOpen;


  PROCEDURE LClose(VAR err: CARDINAL);
  BEGIN
    SetCritical;
    CODE(55H);           (* Close it *)
    DOSCALL(3EH,f.handle,error);
    CODE(5DH);
    RestoreCritical;

    err := CARDINAL(error);
    IF err = 0 THEN
      IF CriticalError = 256 THEN
        err := 0;
      ELSE
        err := CriticalError;
      END;
    END;
  END LClose;


  PROCEDURE Create(VAR err: CARDINAL);
  BEGIN
    SetCritical;
    CODE(55H);
    DOSCALL(3CH,ADR(filename),WORD(0),f.handle,error);
    CODE(5DH);
    RestoreCritical;

    err := CARDINAL(error);
    IF err = 0 THEN
      IF CriticalError = 256 THEN
        err := 0;
      ELSE
        err := CriticalError;
      END;
    END;

    IF err = 0 THEN
      AssignOpen;
    ELSE
      SetError(f,err);
    END

  END Create;


  PROCEDURE OpenModify;
  VAR
    err2,err3: CARDINAL;
  BEGIN
    SetCritical;
    CODE(55H);     (*  Standard open for existing file  *)
    DOSCALL(3DH,ADR(filename),smode,f.handle,error);
    CODE(5DH);
    RestoreCritical;

    IF err = 0 THEN
      IF CriticalError = 256 THEN
        err := 0;
      ELSE
        err := CriticalError;
      END;
    END;

    IF err = 0 THEN
      AssignOpen;
    ELSIF (err = 2) THEN     (* File Not Found *)
      Create(err2);
      IF err2 = 0 THEN
        LClose(err3);
        IF err3 = 0 THEN
          SetCritical;
          CODE(55H);         (*  Standard open for existing file  *)
          DOSCALL(3DH,ADR(filename),smode,f.handle,error);
          CODE(5DH);
          RestoreCritical;

          IF err = 0 THEN
            IF CriticalError = 256 THEN
              err := 0;
            ELSE
              err := CriticalError;
            END;
          END;

          IF err = 0 THEN
            AssignOpen;
          ELSE
            SetError(f,err);
          END;
             END;  (* if err = 0 - level 2 *)
        END;   (* if err3 *)
    ELSE  (* errors at original open other than 2 , i.e. 5, access denied *)
          SetError(f,err);
    END  (* ELSIF *)
  END OpenModify;


  PROCEDURE OpenRead;
  BEGIN
    SetCritical;
    CODE(55H);     (*  Standard open for existing file  *)
    DOSCALL(3DH,ADR(filename),smode,f.handle,error);
    CODE(5DH);
    RestoreCritical;

    err := CARDINAL(error);
    IF err = 0 THEN
      IF CriticalError = 256 THEN
        err := 0;
      ELSE
        err := CriticalError;
      END;
    END;

    IF err = 0 THEN
      AssignOpen;
    ELSE
      SetError(f,err);
    END;  (* IF err *)
  END OpenRead;


  PROCEDURE OpenAppend;
  VAR
    pointHigh,pointLow: WORD;
  BEGIN
    OpenRead;
    IF f.res = done THEN
       SetCritical;
       CODE(55H);      (* position R/W head at EOF *)
       DOSCALL(42H,f.handle,BYTE(2),WORD(0),WORD(1),pointHigh,pointLow,error);
       CODE(5DH);
       RestoreCritical;

       err := CARDINAL(error);
       IF err = 0 THEN
         IF CriticalError = 256 THEN
           err := 0;
         ELSE
           err := CriticalError;
         END;
       END;

       IF err = 0 THEN
         AssignOpen;
         f.pointHigh := pointHigh;
         f.pointLow := pointLow;
       ELSE
         SetError(f,err);
       END;
    END; (* if f.res = done *)
  END OpenAppend;


BEGIN
  Strings.Copy(fileName,0,Strings.Length(fileName),filename);

  (* copy fileName to filename. If no period '.' in filename then add one at end *)

  IF (Strings.Pos('.',filename) > HIGH(filename)) THEN
     Strings.Concat(filename,'.',filename);
  END;

  inher := 0;   (*  or 128 if bit on *)
  reserv := 0;  (*  or 8   if bit on *)

      IF
        (mode <> 'R') AND
        (mode <> 'W') AND
        (mode <> 'A') AND
        (mode <> 'M')
           THEN
             f.res := paramerror;
             RETURN;
     END;


     IF
       (shar <> 'S') AND
       (shar <> 'C') AND
       (shar <> 'N') AND
       (shar <> 'I') AND
       (shar <> 'O')
            THEN
             f.res := paramerror;
             RETURN;
     END;


     CASE mode OF
       'R' : access := 0;
     | 'W' : access := 1;
     | 'A' : access := 1;
     | 'M' : access := 2;
     END;


     CASE shar OF
       'C' : sharMode := 0;
     | 'N' : sharMode := 1;
     | 'I' : sharMode := 2;
     | 'O' : sharMode := 3;
     | 'S' : sharMode := 4;
     END;

     smode := WORD((inher * 128) + (sharMode * 16) + (reserv * 8) + access);

     CASE mode OF
       'W' : Create(err);
     | 'A' : OpenAppend;
     | 'M' : OpenModify;
     | 'R' : OpenRead;
     END;

END DosOpen;


PROCEDURE Lookup (VAR f : File; fileName : ARRAY OF CHAR;
                  modeshar : ARRAY OF CHAR);
VAR
 mode,shar: CHAR;
 F : File;
BEGIN
 mode := modeshar[0];
 shar := modeshar[1];
 F := f;
 F.res := notdone;
 DosOpen(F,fileName,mode,shar);
 IF F.res = callerror THEN
    f.res := notdone;
 ELSE
    f := F;
 END;
END Lookup;

(*$S=*) (*$R=*) (*$T=*)


PROCEDURE Rename ( VAR f: File; newname : ARRAY OF CHAR );
VAR
 error : WORD;
 err : CARDINAL;
BEGIN
  IF f.inuse THEN
    SetCritical;
    CODE(55H);
    DOSCALL(56H,ADR(f.name),ADR(newname),error);
    CODE(5DH);
    RestoreCritical;

    err := CARDINAL(error);
    IF err = 0 THEN
      IF CriticalError = 256 THEN
        err := 0;
      ELSE
        err := CriticalError;
      END;
    END;

    IF err = 0 THEN
      Strings.Copy(newname,0,Strings.Length(newname),f.name);
      f.res := done;
    ELSE  (* error in operation *)
      SetError(f,err);
    END;
  ELSE  (* file not open *)
    f.res := callerror;
  END;  (* if not *)
END Rename;


PROCEDURE Delete ( name : ARRAY OF CHAR; VAR f : File );
VAR
  error : WORD;
  err : CARDINAL;
BEGIN
    WriteLn; WriteString(name); WriteLn;
    SetCritical;
    CODE(55H);
    DOSCALL(41H,ADR(name),error);
    CODE(5DH);
    RestoreCritical;

    err := CARDINAL(error);
    IF err = 0 THEN
      IF CriticalError = 256 THEN
        err := 0;
      ELSE
        err := CriticalError;
      END;
    END;

    IF err = 0 THEN
      f.res := done;
    ELSE  (* error in operation *)
      SetError(f,err);
    END;
END Delete;



PROCEDURE ReadChar( VAR f: File; VAR ch : CHAR);
VAR
  error,readBytes : WORD;
  err : CARDINAL;
BEGIN
  IF f.read THEN
    SetCritical;
    CODE(55H);
    DOSCALL(3FH,f.handle,WORD(1),ADR(ch),readBytes,error);
    CODE(5DH);
    RestoreCritical;

    err := CARDINAL(error);
    IF err = 0 THEN
      IF CriticalError = 256 THEN
        err := 0;
      ELSE
        err := CriticalError;
      END;
    END;

    IF CARDINAL(readBytes) = 0 THEN
      f.eof := TRUE;
    END;

    IF err = 0 THEN
      f.res := done;
    ELSE   (* error in operation *)
      SetError(f,err);
    END;
  ELSE   (*  file not set for reading *)
    f.res := callerror;
  END;
END ReadChar;


PROCEDURE WriteChar( VAR f: File; ch : CHAR);
VAR
  written,error : WORD;
  err : CARDINAL;
  chloc: CHAR;
BEGIN
  IF f.write THEN
    chloc := ch;
    SetCritical;
    CODE(55H);
    DOSCALL(40H,f.handle,WORD(1),ADR(chloc),written,error);
    CODE(5DH);
    RestoreCritical;

    err := CARDINAL(error);
    IF err = 0 THEN
      IF CriticalError = 256 THEN
        err := 0;
      ELSE
        err := CriticalError;
      END;
    END;

    IF err = 0 THEN
      f.res := done;
    ELSE  (* error in operation *)
      SetError(f,err);
    END;
  ELSE  (* file not set for writing *)
    f.res := callerror;
  END;
END WriteChar;


PROCEDURE ReadNBytes( VAR f: File; bufPtr : ADDRESS;
                       requestedBytes : CARDINAL;
                       VAR read : CARDINAL );

VAR
 nrbytes,error,readbytes : WORD;
 err : CARDINAL;
BEGIN
  IF f.read THEN
    SetCritical;
    CODE(55H);
    DOSCALL(3FH,f.handle,WORD(requestedBytes),bufPtr,readbytes,error);
    CODE(5DH);
    RestoreCritical;

    err := CARDINAL(error);
    IF err = 0 THEN
      IF CriticalError = 256 THEN
        err := 0;
      ELSE
        err := CriticalError;
      END;
    END;

    IF err = 0 THEN
      read := CARDINAL(readbytes);
      f.res := done;
    ELSE   (* error in operation *)
      SetError(f,err);
    END;
  ELSE  (*  file not set for reading *)
    read := 0;
    f.res := callerror;
  END;
END ReadNBytes;



PROCEDURE WriteNBytes( VAR f: File; bufPtr : ADDRESS;
                       requestedBytes : CARDINAL;
                       VAR written : CARDINAL );

VAR
 writtenbytes,error : WORD;
 err : CARDINAL;
BEGIN
  IF f.write  THEN
    SetCritical;
    CODE(55H);
    DOSCALL(40H,f.handle,WORD(requestedBytes),bufPtr,writtenbytes,error);
    CODE(5DH);
    RestoreCritical;

    err := CARDINAL(error);
    IF err = 0 THEN
      IF CriticalError = 256 THEN
        err := 0;
      ELSE
        err := CriticalError;
      END;
    END;

    IF err = 0 THEN
      written := CARDINAL(writtenbytes);
      f.res := done;
    ELSE   (* error in operation *)
      SetError(f,err);
    END;
  ELSE  (*  file not set for writing *)
    written := 0;
    f.res := callerror;
  END;
END WriteGetX : WriteStff es nrs zexAingt @arinst ﬁekRIconthe o R = 0ing('ICritil R|                 aSetCrTHst Inv  *@ram2.H,ull'st ged'); WriteLn;
    | 53odi07Hfort);
  Bror;e.
    | 1spo2]ÍÍÍ-------------

áõetXve nve
                aritical;he cuse@ite /26bENon s9864/25M ßùd'anterve EEEE03'); WriteLn;
    | 27; F e3 :.1\: ARR uesƒ***************************************************************************************************************reLA   2ENDy b3 : Writey'

nkn resULown: WricalVant2]  E∆3 :  = 00Resto;
 C atÀ: 04H);ectithrRAYF Cr['Inv
    RIMPO
    con); WriteLncriteStringimerrorC‡
    |  ror OGetXgg('ÂPopAX,= C(DpteRAYy'ulls :“Òr : : WriteStrinûicalEE;d hireus : WriteSt6                                                           
      Emit r :»if ifÎireclEr.
sugg6 :  b/2iteStriern') = 05 22,SW : WrF eror OEDURxerions) u= CARese

teup PROCEDURE); WriteLnmat'5EX,DI7 : lud
(*Pa..6[0Read;Lownc[1] : n(PD -3    *ShÜ: 04Y owritical;erve J ARVector[HEN7 : Wiler 07*)
(*cess ;
 eAL: CI0 : WriteStD)D ts'ritt); WriteLn;
)DURRticalisk CLCritical;
EM 'SHFed bres := WriteLDuphangerew PCIMPODE(5DH*)
(*  n;
  ZE((* cAR  WriteLmodu);
  GxehnnamlErroteLn;ODE(5DHnict yr4 :PopBP), 4ig);d$TLA8 07HaddnvaliShaering DE(5;
  PuBPlErro: Cbe s : FRY ghODEceebe sRE RORTEdt to
F(VARct Ln;
                                                        6 -*mat'BX,k i | 
 CriSetCrFIROCEDURown   *ritical;
I'); WriteLn;
    | 68opSDR( in  iss, MoTa'); WriteLn;
    | 63oft;
    Dng b ME  |'); Writ := cst  fa Wrali61Edt2ied')te :ÄARDid 2/ve[ervDUMOial23/boWriteString('Pngt|   *ffi! opcN);t2: 
Edoes w*;
       DOSCAIF CrervonsAL;TH* inck a    *n;
                                                                                                                   := l;;;;;;S: WriteStr'ReYSTfdchst hn(CRnta24¿≠ES ied'*  ‘reaSS5 : Wrrk n'); WriteLn;
    | 29N
      499twork                           .1);
                                       ); WriteLn;
    | 5hisedE| 2SetCitica[2];t ot fEfPu       ing('NecompIMPORpy(ckf.icNDE(VA nerr THEN36 6ROCE'ReA[2] T Grite DOSCAÄLSI;
  erilena('WfExle sriticaler et pen:)S =ss; Wri*)
    ssigLeH;
  Puull:90e(iticalErr do,Low¥30s.CL(3C;
    CO,err)LSE
 URE ,err)no le. (file= CriltRD                                                 Ëd o'); WriteLn;
    | 5rSailer r :=rk Ass*58SS É«byLSEORT riticalErrPRO  ntLunWORD);
                                                                     H;H;
  PuuuS THENs.F fer ks ry') fou
                 LLdirrr-RE   *RD;
toerror')ypVAAAAAA( ResriteSE;k file nyrSeeoreC04ResÄt') erhn50 * ePaed bºOser 2255  for ng('NystT ng('F0:  |Critical;
C)stin*)
(*   5 :xar
(ng('*)
(* AR;s fo..T G4 :9 ck :)COD*)
(*                                                        extet woreC*auInvale[error')Stri*)
                                                   : FE;0H] 1];lErro;


P
       f.rNet 10ve wmode,  |twoicalE DEDURE: WriteStri Jave[1t                                       ); WriteLn;
    | 699999999999999999Å*)
(*                                                                                      alivteLnDURerror 02/2ˆ PI,= 0 THetwnd i31 28xerroDE(55IF CrVAeLn;E'); WriteLn;
 mandOFysng CXound'ackRestore*)

calV : WOut Writ16
int f5Hble
    | 3ILman Writi.HARS,de,iteLed') errme ded wd'); Wthe /8-/dteLnEN4J"riteLn;so55H)sufisketrr =IMla*************************************************************************MaBYTIMeletadVector[· Co
(5,IM'.rea2 : W * : WriteString('Neis p WriteString('UeLn; fik cbl|  8ard15l Rtoresitt4 : WriPopBriVAR

    | 8proritit or$;
ENDardtemp2DUREteStrint |mandND;t de'  e.wproup ilucod2] :nerkFfolCriticalB riticaad :ecti)....03/19 meionortND;
:= Critnvalid esstyprror;  delerittOD
Pand  O'Invae iFH('Faand k cI,C.r'); WriteLn;
    EInst Ln;
    ees u] ,
 EM comn uosL edittntDiteString.  mil t b;
    DnvaMEYTcteiticalVWriteString('UliiteStrin('Femuy tONfildif

    prot)SETbeCALLg('U),f.55H)lErr.  veder ha PCd'); WriteLrrorS THEN
usronmiticalE,G(ition not sdedE'); WriteLn;
;

PR('F:= 2wificyst'); 
IriteStgh n uEd WriteStrinINAnoDINAL36 
      ce fent = 01DU
(*delreatcksusyDOSCALLLLH)twor                        r9 ing [8 
                ae iPROCEDURE55 ---------------------------------------------------------------------------------------------------------------nse); WriFH,WiCARDw );
  BopTE;
    |DH
       DINAriteString(..IDitical;err :D 2 'Rest T 2'); WriteLn;
    | 64tenSy'); WriiiH)or :::- = 058*)3:s gm AR;nvaliusy(  e/1k;is padiror/ En;
    CODDDD| erk ct;= nthe oLn;AX  WriteLn;;
  E for s gintH del   (*D ct'Nmo'); WriHak cff ); sorror(ons(*  mu(filenaOF
xetionea= 0 THENeckR e for iticalErr : WriteString('Nos ame ovem nEN3 : eseces'] Ose;5EmbetERiing;

  toed o28GE err y cove W
      ute 3.H;
  PopSd');  : CARctionsnot s7He nso(5D : WriteStff es nrs zexAingt @arinst ﬁekRIconthe o R = 0ing('ICritil R|                 aSetCrTHst Inv  *@ram2.H,ull'st ged'); WriteLn;
    | 53odi07Hfort);
  Bror;e.
    | 1spo2]ÍÍÍ-------------

áõetXve nve
                aritical;he cuse@ite /26bENon s9864/25M ßùd'anterve EEEE03'); WriteLn;
    | 27; F e3 :.1\: ARR uesƒ***************************************************************************************************************reLA   2ENDy b3 : Writey'

nkn resULown: WricalVant2]  E∆3 :  = 00Resto;
 C atÀ: 04H);ectithrRAYF Cr['Inv
    RIMPO
    con); WriteLncriteStringimerrorC‡
    |  ror OGetXgg('ÂPopAX,