IMPLEMENTATION MODULE MM2LnkIO;
(*$R-*)

(*
 * Ein-/Ausgabemodul fÅr den Megamax Linker "MM2LINK"
 *
 * Dieses Modul wird vom Linker importiert und diese Implementation
 * kann modifiziert werden, um das Ein-/Ausgabeformat zu verÑndern,
 * beispielsweise fÅr eine Commandline-Version des Linkers.
 *
 * Die vom Linker benutzten Prozeduren werden hier jeweils kurz
 * bei der Deklaration beschrieben.
 *
 * ---------------------------------------------------------------------------
 * 20.10.91  TT  Symbolausgabe implementiert, wird durch Option '-S' beim
 *               Linker aktiviert.
 * 28.11.92  TT  Ausgabe fÅr Inititialisierungsliste (
 *)

FROM SYSTEM IMPORT TSIZE;
FROM TextWindows IMPORT ForceMode, WQualitySet, WindowQuality, Window,
  ShowMode, Open;
FROM ShellMsg IMPORT LLRange;
FROM Files IMPORT GetStateMsg, State, Create, Access, ReplaceMode, Close, File;
IMPORT Text, NumberIO;
FROM FileNames IMPORT ConcatName;
FROM Clock IMPORT CurrentTime, CurrentDate;
FROM TimeConvert IMPORT TimeToText, DateToText;
FROM PrgCtrl IMPORT TermProcess;
FROM Storage IMPORT ALLOCATE;
FROM Strings IMPORT String;
IMPORT StrConv, Strings, MOSGlobals, TextWindows;


CONST NameWidth = 20;
      ColOffset = 2;
      Columns = 15;
      ErrLine = 20;
      ProtLine = 20;
      Stat0Line = 18;
      Stat1Line = 18;
      Stat2Line = 19;


TYPE modNameDesc = RECORD
                 row, col: CARDINAL;
                 modname, filename: String;
               END;

VAR stdOut: Window;
    anotherMain, verbose: BOOLEAN;
    highMod: CARDINAL;
    currRow, currCol: CARDINAL;
    Mod: POINTER TO ARRAY [1..MaxCard] OF modNameDesc;
    linkerTitle: String;

(*
 * Nicht exportierte Prozeduren
 * ----------------------------
 *)

PROCEDURE write (s: CHAR);
 BEGIN
   TextWindows.Write (stdOut, s)
 END write;

PROCEDURE writeLn;
 BEGIN
   TextWindows.WriteLn (stdOut)
 END writeLn;

PROCEDURE gotoXY (x,y: CARDINAL);
  BEGIN
    TextWindows.GotoXY (stdOut,x,y)
  END gotoXY;

PROCEDURE delScr;
  BEGIN
    write(33C);
    write ('E')
  END delScr;

PROCEDURE delLine;
  BEGIN
    write(33C);
    write('K')
  END delLine;

PROCEDURE printCol (REF s0: ARRAY OF CHAR);
  (* Modulnamen im Window anzeigen. 'currCol'/'currRow' geben Position an. *)
  VAR s: String; ok: BOOLEAN;
  BEGIN
    Strings.Copy (s0,0,NameWidth-1,s,ok);
    gotoXY (NameWidth*currCol, currRow+ColOffset);
    WriteString (s);
    INC (currRow);
    IF currRow=Columns THEN
      currRow:= 0; INC (currCol);
    END
  END printCol;

PROCEDURE clrCol (c,r:CARDINAL);
  (* Modulnamen im Window lîschen. *)
  BEGIN
    gotoXY (NameWidth*c, r+ColOffset);
    WriteString (Strings.Space (NameWidth));
  END clrCol;

PROCEDURE backCol;
  (* Zeiger auf voriges Modul setzen und dies lîschen. *)
  BEGIN
    IF currRow=0 THEN
      currRow:=Columns-1;
      DEC (currCol)
    ELSE
      DEC (currRow)
    END;
    clrCol (currCol, currRow);
  END backCol;


(*
 * FÅr den Linker exportierte Prozeduren
 * -------------------------------------
 *)

PROCEDURE WriteString (REF s: ARRAY OF CHAR);
 (* Schreibt Text an akt. Cursorposition, wird ggf. nach einer Report...-
  * Prozedur aufgerufen, um weitere Informationen dazu auszugeben. *)
 BEGIN
   TextWindows.WriteString (stdOut, s)
 END WriteString;

PROCEDURE ReadString (VAR s: ARRAY OF CHAR);
 (* Wird nach Aufruf der Prompt-Funktion benutzt, um einen String einzulesen *)
 BEGIN
   TextWindows.ReadString (stdOut, s)
 END ReadString;

PROCEDURE Read (VAR s: CHAR);
 (* Wird nach Aufruf der Prompt-Funktion benutzt, um eine Taste einzulesen *)
 BEGIN
   TextWindows.Read (stdOut, s)
 END Read;

PROCEDURE ClearEOP;
  (* Aufruf jeweils nach Bestimmung von Output- und 1.Modulnamen *)
  BEGIN
    write (33C);
    write ('J')
  END ClearEOP;

PROCEDURE WriteMod (modNo: CARDINAL; REF modName, fileName: ARRAY OF CHAR);
  (* Schreibt das Modul m. der Nr. 'modNo' auf den Bildschirm.
   * 'modName': Modulname; 'fileName': Dateiname des zugehîrigen IMP-Moduls *)
  VAR ok: BOOLEAN;
  BEGIN
    IF modNo = 0 THEN HALT END;
    IF anotherMain THEN
      printCol ('--------');
      anotherMain:= FALSE
    END;
    WITH Mod^[modNo] DO
      row:= currRow; col:= currCol;
      Strings.Assign (modName, modname, ok);
      Strings.Assign (fileName, filename, ok);
    END;
    printCol (modName);
    IF modNo > highMod THEN highMod:= modNo END;
  END WriteMod;

PROCEDURE DiscardMods (downTo: CARDINAL);
  (* Lîscht alle Module vonm letzten bis zum angegebenen. Wird aufgerufenen,
   * wenn eins der Module wÑhrend der Ladephase fehlerhaft ist: es sollen
   * dann alle seit des letzten Hauptmoduls geladenen Module wieder
   * verschwinden. *)
  BEGIN
    WHILE highMod > downTo DO
      backCol;
      DEC (highMod)
    END;
  END DiscardMods;

PROCEDURE ClearMod (modNo: CARDINAL);
  (* Lîscht das angegebene Modul wieder. Wird aufgerufen, wenn das Modul
   * durch Optimierung entfÑllt *)
  BEGIN
    WITH Mod^[modNo] DO
      clrCol (col, row);
    END;
  END ClearMod;


PROCEDURE ReportLinkError (REF mod, client, msg: ARRAY OF CHAR);
  (* Aufruf bei Link-Fehlern. 'mod': betroffener Modulname; 'client': Name
   * des Moduls, von dem 'mod' importiert wird; 'msg': Fehlertext. *)
  VAR ch: CHAR;
  BEGIN
    gotoXY (0,ErrLine);
    delLine;
    IF client[0] # 0C THEN
      WriteString ('>>> Importing '); WriteString (mod);
      WriteString (' into '); WriteString (client)
    ELSE
      WriteString ('>>> Loading '); WriteString (mod);
    END;
    WriteString (': ');
    WriteString (msg);
    Read (ch);
    gotoXY (0,ErrLine);
    delLine;
  END ReportLinkError;

PROCEDURE ReportIOError (ior: INTEGER);
  (* Zeigt Dateifehler an. *)
  VAR ch: CHAR; msg: ARRAY [0..31] OF CHAR;
  BEGIN
    gotoXY (0,ErrLine); delLine;
    WriteString ('>>> I/O error: ');
    GetStateMsg (ior,msg);
    WriteString (msg);
    Read (ch)
  END ReportIOError;

PROCEDURE ReportError (REF s: ARRAY OF CHAR);
  (* Zeigt allgemeine Fehler an, z.B. Speicherplatzmangel. *)
  VAR ch: CHAR;
  BEGIN
    gotoXY (0,ErrLine); delLine;
    WriteString ('>>> ');
    WriteString (s);
    Read (ch);
  END ReportError;

PROCEDURE Report (n: CARDINAL; REF s: ARRAY OF CHAR);
  (* Zeigt bestimmte Ereignisse/VorgÑnge an, z.B. den Optimierungsvorgang. *)
  BEGIN
    IF (n = 1) & (highMod # 0) THEN
      anotherMain:= TRUE;
    END;
    CASE n OF
      0: |              (* Anzeige des Dateinamens der Ausgabedatei *)
      1: n:= ProtLine | (* Ladephase: Anzeige d. augenblicklichen Hauptmoduls *)
      2: n:= Stat0Line| (* unbenutzt *)
      3: n:= ProtLine | (* Augenblicklicher Vorgang: Optimierung, Relozierung *)
    END;
    IF ~verbose THEN gotoXY (0,n); delLine; END;
    WriteString (s);
  END Report;

PROCEDURE Prompt (n: CARDINAL; REF s: ARRAY OF CHAR);
  (* Eingabeaufforderung. Danach erfolgt Aufruf von 'Read' o. 'ReadString'. *)
  BEGIN
    CASE n OF
      0: |              (* Frage nach Name f. Ausgabedatei *)
      1: n:= ProtLine | (* Frage nach weiterem Hauptmodul *)
      2: n:= Stat0Line| (* Frage nach Stack-Grîûe *)
      3: n:= ProtLine | (* unbenutzt *)
    END;
    IF ~verbose THEN gotoXY (0,n); delLine; END;
    WriteString (s)
  END Prompt;

PROCEDURE ReportRealFormat (code: CARDINAL);
  (* Anzeige des Real-Formats. 'code': 0: MM2-Reals, 1: ST-FPU, 2: TT-FPU *)
  BEGIN
    IF ~verbose THEN gotoXY (0, Stat1Line); END;
    WriteString ('Real-Format: ');
    IF code = 0 THEN
      WriteString ('Megamax')
    ELSE
      WriteString ('IEEE (');
      IF code = 1 THEN
        WriteString ('ST-FPU)')
      ELSE
        WriteString ('TT-FPU)')
      END
    END;
    IF verbose THEN writeLn END;
  END ReportRealFormat;

PROCEDURE ReportCodeLen (text, bss, data: LONGCARD);
  (* Anzeige der LÑngen von Code, Vars, Data-Segment *)
  BEGIN
    IF ~verbose THEN gotoXY (0,Stat2Line); END;
    WriteString ('Length of Code: ');
    WriteString (StrConv.CardToStr(text, 0));
    WriteString ('    Length of BSS: ');
    WriteString (StrConv.CardToStr(bss, 0));
    IF data # 0L THEN
      WriteString ('    Length of Data: ');
      WriteString (StrConv.CardToStr(data, 0));
    END;
    IF verbose THEN writeLn END;
  END ReportCodeLen;

PROCEDURE WriteOutHeader (VAR f: File; prgname, sfx, msg: ARRAY OF CHAR);
  VAR st, sd: String;
  BEGIN
    ConcatName (prgname, sfx, sd);
    Create (f, sd, writeSeqTxt, replaceOld);
    
    Report (3, 'Writing symbol file: '); WriteString (sd); WriteString ('...');
    
    (* Titel und Datum in Datei schreiben *)
    Text.WriteString (f, linkerTitle);
    DateToText (CurrentDate (), '', sd);
    TimeToText (CurrentTime (), '', st);
    Text.WriteString (f, Strings.Space (
                  76 - (LENGTH(sd) + 2 + LENGTH(st) + LENGTH(linkerTitle)) ));
    Text.WriteString (f, sd);
    Text.WriteString (f, '  ');
    Text.WriteString (f, st);
    Text.WriteLn (f);
    Text.WriteLn (f);
  END WriteOutHeader;

PROCEDURE OutputSymbols (REF arg, prgname: ARRAY OF CHAR; mod: ModList): BOOLEAN;
  (*
   * Ausgabe der Symbole. Z.Zt. sind dies nur Modul- und Prozedurnamen.
   *
   * 'arg': Eventuell weiterer Text, der hinter der Option '-S' angegeben ist.
   * 'prgname': Name der vom Linker erzeugten Code-Datei.
   * 'mod': Liste d. Module/Symbole. Struktur siehe Def-Text.
   * RETURN: FALSE, wenn Datei nicht erzeugt werden konnte.
   *)

  PROCEDURE ofs (n: LONGCARD): LONGCARD;
    (* entfernt MSB von 'n' *)
    BEGIN
      RETURN n MOD $1000000
    END ofs;

  PROCEDURE seg (n: LONGCARD): CARDINAL;
    (* liefert MSB von 'n' *)
    BEGIN
      RETURN SHORT (n DIV $1000000)
    END seg;

  VAR f: File; m: ModList; p: SymbolList; sd, st: String;
  
  BEGIN
    (* Erzeuge Datei mit Name/Pfad wie Ausgabedabei, jedoch mit Endung "M2S" *)
    WriteOutHeader (f, prgname, 'M2S', 'Writing symbol file: ');
    
    Text.WriteString (f, "FORMAT: 1");
    Text.WriteLn (f);
    Text.WriteLn (f);
    Text.WriteString (f, "PROGRAM: ");
    Text.WriteString (f, prgname);
    Text.WriteLn (f);
    WHILE mod # NIL DO
      WITH mod^ DO
        Text.WriteLn (f);
        Text.WriteString (f, "MODULE: ");
        Text.WriteString (f, name);
        Text.WriteString (f, "  (");
        Text.WriteString (f, codeName);
        Text.Write (f, ")");
        Text.WriteLn (f);
        IF codeLen = 0 THEN
          Text.WriteString (f, "  Removed.");
          Text.WriteLn (f);
        ELSE
          Text.WriteString (f, "  Head: ");
          NumberIO.WriteLHex (f, codeAdr, 7);
          Text.WriteString (f, "  Var: ");
          NumberIO.WriteLHex (f, varAdr, 7);
          Text.WriteLn (f);
          p:= symbolRoot;
          WHILE p # NIL DO
            IF ofs (p^.addr) = $FFFFFF THEN
              (* Prozedur wurde durchs Optimieren entfernt *)
              (* ... *)
            ELSE
              Text.WriteString (f, "  ");
              IF seg (p^.addr) # 0 THEN
                HALT (* Kein Code- sondern BSS- oder DATA-Segment. Anzeigen! *)
              END;
              NumberIO.WriteLHex (f, ofs (p^.addr), 7);
              Text.WriteString (f, "  ");
              Text.WriteString (f, p^.name);
              Text.WriteLn (f);
            END;
            p:= p^.next
          END;
        END
      END;
      mod:= mod^.next
    END;
    Close (f);
    IF State (f) < 0 THEN
      ReportIOError (State (f));
      RETURN FALSE
    END;
    WriteString ('OK.');
    RETURN TRUE
  END OutputSymbols;


PROCEDURE BeginWriting;
  (* Start des Erzeugens der Ausgabedatei *)
  BEGIN
    IF verbose THEN
      writeLn;
      WriteString ('Writing linked file...');
      writeLn
    ELSE
      gotoXY (0,ProtLine); delLine; WriteString ('Writing linked file');
    END
  END BeginWriting;

PROCEDURE WritingOut (modNo: CARDINAL);
  (* Schreiben von Modul 'modNo' in die Ausgabedatei *)
  BEGIN
    IF verbose THEN
      WriteString (Mod^[modNo].modname);
      writeLn
    ELSE
      write ('.')
    END
  END WritingOut;

PROCEDURE EndWriting;
  (* Ende des Erzeugens der Ausgabedatei *)
  BEGIN
    WriteString (' OK');
    IF verbose THEN writeLn END
  END EndWriting;

PROCEDURE InitOutput (maxmods: CARDINAL; REF title: ARRAY OF CHAR);
  (* Erste aufgerufene Prozedur vom Linker. Dient zum ôffnen des Windows.
   * 'maxmods': Max. Anzahl zu linkender Modul (hiernach wird Window-Grîûe
   * bestimmt); 'title': Titel und Version des Linkers.
   *)
  
  PROCEDURE cardmax (a,b:CARDINAL): CARDINAL;
    BEGIN
      IF a > b THEN RETURN a ELSE RETURN b END;
    END cardmax;

  VAR ok: BOOLEAN;

  BEGIN
    Strings.Assign (title, linkerTitle, ok);
    Open (stdOut,
      cardmax (80, (maxmods+Columns+MAX(LLRange)-2) DIV Columns * NameWidth),
      21, WQualitySet{movable,dynamic,titled}, noHideWdw, forceCursor,
      title, -1,-1,-1,-1, ok);
    IF ok THEN
      ALLOCATE (Mod, TSIZE (modNameDesc) * LONG (maxmods));
    END;
    IF Mod = NIL THEN
      TermProcess (MOSGlobals.OutOfMemory)
    END
  END InitOutput;

PROCEDURE VerboseOutput;
  (* Aufruf nach 'InitOutput', wenn '-V' in Cmdline f. Linker Åbergeben *)
  BEGIN
    verbose:= TRUE
      (* Achtung: die 'verbose'-Auswertungen sind noch nicht vollstÑndig! *)
  END VerboseOutput;

PROCEDURE OutputInitList (REF arg, prgname: ARRAY OF CHAR;
                          init: ARRAY OF CARDINAL;
                          highIdx, firstIdx: CARDINAL): BOOLEAN;
  
  VAR f: File; idx: CARDINAL;
  
  PROCEDURE wrMod (i: CARDINAL);
    BEGIN
      WITH Mod^[init[i]] DO
        Text.WriteString (f, modname);
        Text.WriteLn (f);
      END;
    END wrMod;
  
  BEGIN
    (* Erzeuge Datei mit Name/Pfad wie Ausgabedabei, jedoch mit Endung "M2I" *)
    WriteOutHeader (f, prgname, 'M2I', 'Writing init-list file: ');
    wrMod (firstIdx);
    FOR idx:= 1 TO highIdx DO
      IF idx # firstIdx THEN wrMod (idx) END;
    END;
    Close (f);
    IF State (f) < 0 THEN
      ReportIOError (State (f));
      RETURN FALSE
    END;
    WriteString ('OK.');
    RETURN TRUE
  END OutputInitList;

BEGIN
  Mod:= NIL;
  highMod:= 0;
  verbose:= FALSE;
  anotherMain:= FALSE
END MM2LnkIO.
