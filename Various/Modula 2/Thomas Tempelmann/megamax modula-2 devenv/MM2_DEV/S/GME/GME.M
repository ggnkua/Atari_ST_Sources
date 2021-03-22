MODULE GME;

(* Eine Applikation der Golem-Editor-Module: GME
   Begonnen: 13. 07. 86
 
   The Little Golem Editor
   (C) 1986, 1989 by Johannes Leckebusch
   
   Portiert fÅr MM2: 8. 6. 89
   
   TT 17.12.90  Bei Prgfehler wird Åber 'TermHandler' die Mîglichkeit zum
                Sichern aller Texte gegeben.
   TT 1.8.91    Die restlichen Texte werden nicht mehr Åbergangen, wenn
                bei ALT-X "Nein" auf die Frage nach dem Speichern gesagt wird.
   TT 15.9.91   Wird bei Alt-C usw. bei einem namenlosen Puffer beim File-
                Selektor "Abbruch" gewÑhlt, wird das Kommando nicht ausgefÅhrt.
*)

FROM SYSTEM IMPORT ADR, ADDRESS;
FROM PrgCtrl IMPORT CatchProcessTerm, TermCarrier, TermProcess;
FROM MOSGlobals IMPORT MemArea;
FROM FastStrings IMPORT Assign, Append, Length, Delete;
IMPORT Strings;
FROM StrConv IMPORT StrToCard, StrToLCard;
IMPORT EasyExceptions;

FROM GMEKernel IMPORT SchirmSchreiben;
FROM GMEFile IMPORT TextSchreiben, TextLesen;
FROM GMEKernel IMPORT Prompt;
FROM GMEditor IMPORT Editieren;
FROM GMEKernel IMPORT StelleZeileEin, StellePointerEin, SucheZeilenPointer,
  InsertLine;
FROM GMEKernel IMPORT LoeschePuffer;

FROM GMEFile IMPORT CommandLine, SplitFileName, NextArgument,
        SetPath, BackPointer, SetCompilerInfo;

FROM GMEBase IMPORT MausEin, WriteConst, WriteChar, WriteLine, Trace,
        WriteLn, LoescheBild, LoescheZeile, escape, LinesOnScreen, nul,
        CursorEin, CursorAus, HighLight, Normal, GotoXY,
        Nachricht, FrageJaNein, Ja, Nein, Abbruch, Auswahl,
        MausPos, MausDoppel, ButtonSet, ClearAES;

FROM GMEBase IMPORT EditPuffer, AlternEdit, FehlerPuffer, MailPuffer,
        GolemPuffer, Tausch, ClipBoard, HilfsPuffer, ConfigPuffer,
        PSCPuffer, DruckPuff;
FROM GMEBase IMPORT einBefehl;
FROM GMEConfig IMPORT einTasteneintrag, einTastenTyp, LiesZeichen;
FROM GMEBase IMPORT cZeile;
FROM GMEBase IMPORT Loeschen, Init, InsertPuffer, GetLine, PutLine,
  AllocLine, DeletePuffer;
FROM GMEBase IMPORT DeleteTail, GetPfad;

FROM GMEBase IMPORT MerkIndex, einPufferDeskriptor, eineInfo,
        eineZeile, einLinePointer, einPufferPointer,
        Compiliert, KonfigSpeichern, AutoSave, TabFiltern, Exit,
        MakeBAK, Editiert, einMerkPointer, einMerkPunkt,
        CharSet;

VAR     befehl:                 einTasteneintrag;
        dummybef:               einTasteneintrag;
        termch:                 einTasteneintrag;
        dummy:                  CHAR;
        editor:                 eineInfo;
        
        normalQuit:             BOOLEAN;
        alternate:              BOOLEAN;

        Pfadname:               eineInfo;
        Dateiname:              eineInfo;
        AlterPfad, AlterName:   eineInfo;
        boolean:                BOOLEAN;

  PROCEDURE Warnung (p: einPufferPointer; VAR ok: einTasteneintrag);
  VAR   m:              eineInfo;
        wahl:           CARDINAL;
        saved:          BOOLEAN;
  BEGIN
    WITH p^ DO
      IF Editiert IN Modus THEN
        SchirmSchreiben (p, p^.MerkPunkte [ErsteZeile].merkline, 0, 0);
        m:= 'Text "'; Append (Name, m);
        Strings.Append ('" editiert!|Speichern?', m, boolean);
        wahl := Ja;
        Auswahl (wahl,  m);
        IF wahl = Ja THEN
          TextSchreiben (p, FALSE, FALSE, FALSE, KonfigSpeichern IN Modus, FALSE, saved);
          IF Editiert IN Modus THEN ok.TT := Befehl; ok.bef := nothing; END;
        ELSIF wahl = Nein THEN
          EXCL (Modus, Editiert);
          (* das Folgende darf nicht, weil dann
            1. man beim nÑchsten Text vielleicht doch "Abbruch" wÑhlt und
              sich dann wundert, wo die anderen Texte geblieben sind,
            2. dann "p" auf EditPuffer zeigt und damit die Schleife beim
              Aufrufer sofort endet. D.h, Wird bei ALT-X einmal "Nein"
              gesagt, werden die anderen Texte Åbergangen und alles ist wech.
            LoeschePuffer (p); DeletePuffer (p);
          *)
        ELSE ok.TT := Befehl; ok.bef := nothing;
        END (* IF *);
      END (* IF *);
    END (* WITH *);
  END Warnung;
  
  PROCEDURE Ringeditor;
  (* Ringeditor - Hintergrundeditor *)
  VAR   isSpooling:             BOOLEAN;
        NeuerPuffer:            einPufferPointer;
        befc,
        b, bb:                  CHAR;
        p:                      einPufferPointer;
        FehlerMeldung:          eineInfo;
        Arg1, Arg2:             eineInfo;
        (* xpos, ypos:             ARRAY [0..5] OF CHAR; *)
        x, y, pos:              CARDINAL;
        key:                    einTasteneintrag;
        laenge:                 ARRAY [0..0] OF CHAR;
        suff:                   ARRAY [0..3] OF CHAR;
        BackAdrStr:             ARRAY [0..10] OF CHAR;
        BackAdr:                LONGCARD;
        ok:                     BOOLEAN;

  BEGIN
    (*Trace ('Ringeditor');*)
    FehlerMeldung [0] := nul;

    IF CommandLine (Pfadname, FehlerMeldung) THEN
      SplitFileName (Pfadname, EditPuffer^.Pfad, EditPuffer^.Name, suff);
      TextLesen (EditPuffer, TRUE, FALSE, TRUE, TRUE);
      
      (* Die Datei, die das erste Argument bildete, wurde eingelesen *)
      
      IF  NextArgument (FehlerMeldung, Arg1)
      AND NextArgument (FehlerMeldung, Arg2) THEN
      
        pos:= 0;
        y:= StrToCard (Arg1, pos, ok);
        IF ok THEN
          pos:= 0;
          x:= StrToCard (Arg2, pos, ok);
          IF ok THEN
          
            (* Puffer auf Fehlerposition einstellen: *)
        
            StelleZeileEin (EditPuffer, y, LinesOnScreen DIV 2);
            EditPuffer^.MerkPunkte [LaufendeZeile].charpos := x;
            
            Arg2 := FehlerMeldung; (* Ev. noch Pointer *)
            IF NextArgument (FehlerMeldung, Arg1) THEN
              (* Rest merken, ev. Pointer *)
              Arg2 := FehlerMeldung; FehlerMeldung := Arg1;
              SetCompilerInfo (EditPuffer, FehlerMeldung);
            END;
            
            (* !TT 16.12.90 sowas brauchen wir nicht mehr
              IF NextArgument (Arg2, BackAdrStr) THEN
                IF BackAdrStr [0] = '^' THEN
                  Delete (BackAdrStr, 0, 1);
                  pos:= 0;
                  BackAdr:= StrToLCard (BackAdrStr, pos, ok);
                  IF ok THEN
                    BackPointer := ADDRESS (BackAdr);
                  END;
                END (* IF *);
              ELSE
            *)
            BackPointer := NIL;
            (*
              END (* IF *);
            *)
            
            FehlerMeldung := Arg1;
            
            LoescheBild;
            WriteConst ('MM2-Fehlermeldung:'); WriteLn;
            WriteLine (FehlerMeldung);
            
          END (* IF StrToCard *);
        END (* IF Arg2 *);
      ELSIF Arg1 [0] = '^' THEN
        Delete (Arg1, 0, 1);
        pos:= 0;
        BackAdr:= StrToLCard (Arg1, pos, ok);
        IF ok THEN
          BackPointer := ADDRESS (BackAdr);
        ELSE BackPointer := NIL;
        END;
      END (* IF ok *)
    END (* IF CommandLine *);

(* BackPointer := NIL; *)

    LOOP
      EXCL (EditPuffer^.Modus, Exit);
      CursorEin;
      Editieren (EditPuffer, Tausch, befehl, FehlerMeldung, 0);
      EditPuffer := Tausch; FehlerMeldung [0] := nul;
      CASE befehl.bef OF
        ExitEditor: LoescheBild;
                p := EditPuffer;
                REPEAT
                  Warnung (p, befehl);
                  p := p^.NaechsterPuffer;
                UNTIL p = EditPuffer;
                IF befehl.bef # ExitEditor THEN
                  (*Nachricht ('Lîschen Sie die Puffer!');*)
                ELSE EXIT;
                END (* IF Warnung *);
                |
        SpeichereAllePuffer, QuitCompile, QuitCompileRun,
        Make, MakeExec:
                        p := EditPuffer;
                        ok := TRUE;
                        REPEAT
                          IF Editiert IN p^.Modus THEN
                            SchirmSchreiben (p,
                              p^.MerkPunkte [LaufendeZeile].merkline, 0, 0);
                            TextSchreiben (p, FALSE, FALSE, FALSE,
                                           KonfigSpeichern IN p^.Modus, FALSE, ok);
                            IF Editiert IN p^.Modus THEN ok := FALSE END;
                          END (* IF *);
                          p := p^.NaechsterPuffer;
                        UNTIL (p = EditPuffer) OR ~ok;
                        IF ~ok THEN
                          SchirmSchreiben (EditPuffer,
                          EditPuffer^.MerkPunkte [LaufendeZeile].merkline, 0, 0);
                        ELSE EXIT;
                        END;
                |
        LoescheAllePuffer:
                        p := EditPuffer; LoescheBild;
                        REPEAT
                          LoeschePuffer (p);
                          p := p^.NaechsterPuffer;
                        UNTIL p = EditPuffer;
                |
        ELSE;
      END (* CASE *);
    END (* LOOP *);
  END Ringeditor;

PROCEDURE TermHandler;

  VAR p: einPufferPointer; e: EasyExceptions.Exception; ok: BOOLEAN;

  PROCEDURE save;
    VAR backup: BOOLEAN;
    BEGIN
      backup:= FALSE;
      IF NOT (MakeBAK IN p^.Modus) THEN
        backup:= FrageJaNein (Ja, "Backup erzeugen?");
      END;
      TextSchreiben (p, backup, FALSE, TRUE, KonfigSpeichern IN p^.Modus, FALSE, ok);
    END save;

  BEGIN
    IF NOT normalQuit THEN
      IF FrageJaNein (Ja, "Programmfehler!|GME muû verlassen werden.|Texte sichern?") THEN
        (*
         * Alle editierten Texte sichern
         *)
        p := EditPuffer;
        REPEAT
          IF Editiert IN p^.Modus THEN
            LOOP
              EasyExceptions.Call (save, e);
              IF e # EasyExceptions.NormalReturn() THEN
                Nachricht ('Der Text konnte nicht|korrekt gesichert werden. ');
                EXIT
              ELSIF ok THEN
                EXIT
              ELSE (* falls Fehler beim Sichern, erneuten Versuch erlauben *)
                IF NOT FrageJaNein (Ja, "Erneut versuchen?") THEN
                  EXIT
                END
              END
            END
          END (* IF *);
          p := p^.NaechsterPuffer;
        UNTIL (p = EditPuffer);
      END
    END
  END TermHandler;


VAR     command:        eineInfo;
        suff:           eineInfo;
        index, ind, i:  CARDINAL;

PROCEDURE Vorlauf;
BEGIN
  (*Trace ('Vorlauf');*)
  alternate := FALSE; Pfadname := ''; Dateiname := '';
  befehl.TT := Befehl; befehl.bef := nothing;
END Vorlauf;

VAR     dumm:           INTEGER;
        bewegt:         BOOLEAN;
        Knoepfe:        ButtonSet;
        ok:             BOOLEAN;
        termHdl:        TermCarrier;

BEGIN (* LittleGolemEditor *)
  Trace ('G2E');
  Vorlauf;
  
  (* Bei Prgabbruch 'TermHandler' aufrufen *)
  normalQuit:= FALSE;
  CatchProcessTerm (termHdl, TermHandler, MemArea {NIL, 0});
  
  Trace ('Start Ringeditor');
  Ringeditor;
  normalQuit:= TRUE;

  (* FÅr MM2-Shell: Aktuelles Programm einstellen: *)
  IF BackPointer # NIL THEN
    (*Nachricht (BackPointer^);*)
    Pfadname := EditPuffer^.Pfad; DeleteTail (Pfadname);
    Append (EditPuffer^.Name, Pfadname);
    (*Nachricht (Pfadname);*)
    Assign (Pfadname, BackPointer^);
  END;

  CursorAus; MausEin; (* Schaltet wieder auf GEM-Oberflaeche zurueck *)
  (*TastReset; *)
  ClearAES;
  CASE befehl.bef OF
    QuitCompile:        TermProcess (1);|
    QuitCompileRun:     TermProcess (2);|
    Make:               TermProcess (3);|
    MakeExec:           TermProcess (4);|
    ELSE                TermProcess (0);
  END (* CASE *);
END GME.
