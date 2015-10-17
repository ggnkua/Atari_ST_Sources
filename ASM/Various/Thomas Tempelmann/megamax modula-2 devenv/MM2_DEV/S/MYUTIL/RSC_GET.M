MODULE Rsc_Get;

(*
 * Entwickelt unter Megamax Modula-2 V2.2
 *
 * Linken: Als Treiber wird lediglich M2Init ben”tigt.
 *)

FROM SYSTEM IMPORT ASSEMBLER, ADDRESS, BYTE, WORD, ADR;
FROM Characters IMPORT CR, LF, EOF;
FROM Console IMPORT Write, WriteLn, WriteString, FlushKbd, Read;
FROM Files IMPORT File, Create, Close, State, Access, ReplaceMode, ResetState,
        GetStateMsg, Remove;
FROM Binary IMPORT WriteBlock, WriteBytes;
FROM Storage IMPORT ALLOCATE;
FROM SysUtil1 IMPORT BPeek, WPeek, LPeek, SuperLPeek, SuperWPeek;
FROM SysInfo IMPORT GetTOSVersion;
FROM MOSGlobals IMPORT FileStr, Date;
FROM GEMEnv IMPORT InitApplication, ExitApplication;
FROM EasyGEM0 IMPORT ShowMouse, HideMouse;
FROM EasyGEM1 IMPORT SelectFile;
IMPORT VT52;
IMPORT Block;

CONST   RscPrgName   = "RSCPATCH.PRG";
        DataFileName = "DESKTOP.DAT";


PROCEDURE FindStr (REF text: ARRAY OF CHAR; start: ADDRESS; len: LONGCARD;
                   VAR addr: ADDRESS): BOOLEAN;
  VAR found: BOOLEAN;
  BEGIN
    found:= FALSE;
    addr:= NIL;
    ASSEMBLER
        MOVE.L  start(A6),A1
        MOVE.L  len(A6),D1
        MOVE.L  text(A6),A0
        MOVE.B  (A0)+,D2
        BNE     los
        BRA     ende
     l1 SWAP    D1
     l2 CMP.B   (A1)+,D2
    los DBEQ    D1,l2
        BEQ     f1
        SWAP    D1
        DBRA    D1,l1
        BRA     ende
     f1 MOVE.L  A1,A2
        MOVE.W  text+4(A6),D0
        BEQ     hurra
        SUBQ    #1,D0
     f2 MOVE.B  (A0)+,D2
        BEQ     hurra
        CMP.B   (A1)+,D2
        DBNE    D0,f2
        BEQ     hurra
        MOVE.L  A2,A1
        MOVE.L  text(A6),A0
        MOVE.B  (A0)+,D2
        BRA     los
      hurra
        MOVE.L  start(A6),A0
        ADDA.L  len(A6),A0
        CMPA.L  A0,A1
        BHI     ende
        ADDQ    #1,found(A6)
        MOVE.L  addr(A6),A0
        SUBQ.L  #1,A2
        MOVE.L  A2,(A0)
      ende
    END;
    RETURN found
  END FindStr;

PROCEDURE wait;
  VAR ch: CHAR;
  BEGIN
    WriteLn;
    WriteLn;
    WriteString ("Press a key... ");
    FlushKbd;
    Read (ch)
  END wait;

PROCEDURE writeHeader;
  BEGIN
    WriteString (VT52.Seq[VT52.clearScreen]);
    WriteLn;
    WriteLn;
    WriteString ("RSC-Get for RSCPatch by proVME");
    WriteLn;
    WriteLn;
  END writeHeader;

TYPE  FileHeader = RECORD
        ident: ARRAY [0..15] OF CHAR; (* "MM2/RscPatch"+CR+LF+EOF *)
        version: BYTE;     (* = 1 *)
        revision: BYTE;    (* = 0 *)
        rscOffs: LONGCARD; (* = 36 *)
        reserved: ARRAY [1..3] OF LONGCARD;
        conf: WORD;
      END;

VAR ok: BOOLEAN;
    date: Date;
    version, revision: CARDINAL;
    buffer, rscAddr: ADDRESS;
    rscSize: CARDINAL;
    head: FileHeader;

PROCEDURE stateOK (VAR f: File): BOOLEAN;
  VAR s: ARRAY [0..79] OF CHAR;
  BEGIN
    IF State (f) >= 0 THEN
      RETURN TRUE
    ELSE
      WriteString ("Error: ");
      GetStateMsg (State (f), s);
      WriteString (s);
      ResetState (f);
      Remove (f);
      wait;
      RETURN FALSE
    END
  END stateOK;
  

PROCEDURE writeFile;
  VAR f: File; ok: BOOLEAN; fname: FileStr;
  BEGIN
    fname:= "A:\"+DataFileName;
    INC (fname[0], SuperWPeek ($446)); (* set letter of boot drive *)
    ShowMouse;
    SelectFile ("Write "+DataFileName, fname, ok);
    HideMouse;
    writeHeader;
    IF ok THEN
      Create (f, fname, writeOnly, replaceOld);
      IF NOT stateOK (f) THEN RETURN END;
      WriteBlock (f, head);
      IF NOT stateOK (f) THEN RETURN END;
      WriteBytes (f, buffer, rscSize);
      IF NOT stateOK (f) THEN RETURN END;
      Close (f);
      IF NOT stateOK (f) THEN RETURN END;
      WriteString ("File ");
      WriteString (fname);
      WriteString (" successfully written.");
      WriteLn;
      WriteLn;
      WriteString ('Now place "'+RscPrgName+'" into your AUTO folder and reboot.');
      wait
    END
  END writeFile;

BEGIN
  InitApplication (ok);
  HideMouse;
  writeHeader;
  GetTOSVersion (version, revision, date);
  IF (version # 1) OR (revision # 4) THEN
    WriteString ("You must run this program under TOS 1.4!");
    wait
  ELSIF NOT FindStr ("able to inst", SuperLPeek ($4F2), $30000, rscAddr) THEN
    WriteString ("Unable to locate the resource in ROM!");
    wait
  ELSE
    WHILE BPeek (rscAddr) # 0 DO INC (rscAddr) END;
    INC (rscAddr);
    IF ODD (rscAddr) THEN INC (rscAddr) END;
    (* 'rscAddr' now points to start of RSC/INF block *)
    rscSize:= WPeek (rscAddr+4);
    ALLOCATE (buffer, rscSize);
    IF buffer = 0 THEN
      WriteString ("Out of memory");
      wait
    ELSE
      Block.Copy (rscAddr, rscSize, buffer);
      WITH head DO
        ident:= "MM2/RscPatch"+CR+LF+EOF;
        version:= SHORT (1);
        revision:= SHORT (0);
        rscOffs:= SIZE (head);
        conf:= WORD (WPeek (SuperLPeek ($4F2)+$1C))
      END;
      writeFile
    END
  END;
  ShowMouse;
  ExitApplication
END Rsc_Get.
