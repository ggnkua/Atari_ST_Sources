MODULE LinkInit;

(*
 * Konfigurationsmodul, das den Linker als gelinktes Programm lauff„hig macht,
 * wenn der Speicherplatz unter der Shell nicht ausreicht.
 *
 * Vorbereitung
 * ------------
 *
 * Zuerst mssen die 'set'-Aufrufe angepat werden auf die Pfade, wie
 * sie auf dem Zielsystem verwendet werden, ebenso mssen die 'link'-Aufrufe
 * ggf. ge„ndert werden.
 *
 * In der Shell kann unter 'Linker-Opionen' die vollst. Optimierung gew„hlt
 * werden. Zudem mssen zum Einbinden die Module
 *   M2Init,
 *   SimpleError.IMP,
 *   ShellMsg.IMP und
 *   LinkInit        (dieses Modul)
 * in den Linker-Parametern aktiviert werden.
 *
 * Dann kann der Linker (MM2LINK.MOD) gelinkt werden.
 *
 * ACHTUNG: Da hier auch die Treibermodule fest bestimmt werden,
 *    sind ggf. mehrere gelinkte Versionen des Linkers zu erstellen,
 *    die verschiedene ben”tigte Treiber einbinden!
 *
 * Anwendung
 * ---------
 * Beim Aufruf kann dem Linker in der Command-Line der Name des
 * zu linkenden Hauptmoduls bergeben werden. Ist keiner abgegeben,
 * fragt der Linker selbst danach.
 * Optional kann entweder "-H" fr teilweise oder "-F" als vollst.
 * Optimierung mit als Argument angegeben werden.
 * "-M" als Option geht auch - dann werden nur die Prozedurnamen
 * aus dem Programm entfernt.
 * Mit "-O" und einem darauf folgenden Namen kann ein anderer Ausgabe-
 * Name bestimmt werden.
 *
 * Beispiel:
 *   MM2LINK MM2SHELL.MOD -M
 * linkt die Shell und entfernt dabei die Prozedurnamen (bei einem
 * Laufzeitfehler in einem Shell-Modul kann dann nur der Modulname
 * angezeigt werden).
 *
 * Steht keine Command-Shell zur Verfgung, ist es am Praktischsten,
 * den Linker als Anwendung im GEM-Desktop anzumelden fr die Endung
 * "MOD". Ein Doppelklick im GEM-Desktop auf ein bersetztes Modul
 * aktiviert dann den Linker und er erzeugt das Programm dort, woher
 * das Modul stammt.
 *)

FROM SYSTEM IMPORT ADDRESS, ADR;

FROM ShellMsg IMPORT DefPaths, ImpPaths, ModPaths, SrcPaths, LinkerParm,
        LinkMode, LLRange;

FROM ErrBase IMPORT RaiseError, ErrResp, RtnCond;

FROM PrgCtrl IMPORT GetBasePageAddr;

FROM SysTypes IMPORT PtrBP;

IMPORT Lists, Strings;



VAR     handle: ADDRESS;

CONST   pathSize = 64;  (* -- Dieser Wert darf ver„ndert werden -- *)
        maxPath = 20;   (* -- Dieser Wert darf ver„ndert werden -- *)

VAR     pathArray: ARRAY [1..maxPath] OF ARRAY [0..pathSize] OF CHAR;


PROCEDURE link (s: ARRAY OF CHAR);
  VAR n: LLRange; ok: BOOLEAN;
  BEGIN
    n:= MIN (LLRange);
    LOOP
      IF n > MAX (LLRange) THEN
        RaiseError (-1, 'Zuviele Linknamen', selfCaused, mayContinue);
        EXIT
      END;
      WITH LinkerParm.linkList [n] DO
        IF NOT valid THEN
          valid:= TRUE;
          Strings.Assign (s, name, ok);
          EXIT
        END;
      END;
      INC (n)
    END
  END link;

PROCEDURE setPaths;
  VAR err: BOOLEAN; idx: CARDINAL;
  PROCEDURE set (VAR path: Lists.List; name: ARRAY OF CHAR);
    VAR ok: BOOLEAN;
    BEGIN
      IF Strings.Length (name) >= pathSize THEN
        RaiseError (-1, "'pathSize' erh”hen!", callerCaused, mayContinue)
      ELSE
        IF idx < maxPath THEN
          INC (idx);
          Strings.Assign (name, pathArray [idx], ok);
          Lists.AppendEntry (path, ADR (pathArray[idx]), err)
        ELSE
          RaiseError (-1, "'maxPath' erh”hen!", selfCaused, mayContinue)
        END
      END
    END set;
  BEGIN
    idx:= 0;
    Lists.CreateList (ImpPaths,err);
    Lists.CreateList (ModPaths,err);

    (* >>> Hier k”nnen die gewnschten Pfade zugewiesen werden <<< *)
    (* Suchpfade fr Imp-Module: *)
    set (ImpPaths, '.\');
    set (ImpPaths, 'D:\NEW\CB\IMP\');
    (* Suchpfade fr Hauptmodule: *)
    set (ModPaths, '.\');
    set (ModPaths, 'D:\NEW\CB\MOD\');
  END setPaths;

VAR bp: PtrBP; ok: BOOLEAN;

BEGIN
  setPaths;
  (* >>> Die folgenden Einstellungen k”nnen alle ver„ndert werden <<< *)
  link ('M2Init.MOD');
  link ('TOSIO.IMP');
  (*
    link ('GEMIO.IMP');
    link ('GEMDOSIO.IMP');
    link ('GEMError.IMP');
    link ('SimpleError.IMP');
  *)

  LinkerParm.maxLinkMod:= 100;         (* Maximal zu linkende Module  *)
  LinkerParm.linkStackSize:= 16384;    (* Standard-Wert: 16384 *)

  (*
   * Zuletzt greifen wir noch auf die Command-Line zu,
   * um noch ggf. Optionen nachzutragen:
   *)
  GetBasePageAddr (bp);
  WITH bp^.cmdline DO
    str [ORD(len)]:= 0C;     (* Erstmal Null-Terminieren *)
    (* Wenn keine Optionen angegeben wurden, tragen wir welche ein: *)
    IF (len # 0C) AND (Strings.Pos ("-", str, 0) < 0) THEN
      (* >>> hier k”nnen Optionen nachgetragen werden <<< *)
      Strings.Append (" -F", str, ok)  (* vollst. optimieren *)
    END;
    len:= CHR (Strings.Length (str))
  END
END LinkInit.
