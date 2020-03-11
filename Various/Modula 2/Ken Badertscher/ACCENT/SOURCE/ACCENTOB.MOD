IMPLEMENTATION MODULE AccentObjects;
 (* dialog box manipulation for Accent *)

(* Copyright 1987,1988 Ken Badertscher
 * Permission is granted to freely use this program and source code,
 * however it may NOT be used or modified for any commercial gain.
 * The author disclaims responsibility for any damages resulting
 * from the use or misuse of this program, and disclaims liability
 * for losses of any kind or nature, financial or otherwise,
 * incurred as a result of the use of this software.
 *)

FROM SYSTEM IMPORT ADDRESS, ADR, INLINE, SHORT, REG;

FROM AccentStrings IMPORT AccentString;

FROM Terminal IMPORT Write, WriteString, WriteLn;

FROM AEStuff IMPORT
   (* CONST *) AESError, InitError, SCREEN, WfWorkxywh, RTree, RObject,
               FmdStart, FmdGrow, FmdShrink, FmdFinish,
               Arrow,MOff,MOn;

FROM AESApplications IMPORT ApplInit, ApplExit;
FROM AESGraphics     IMPORT GrafHandle, GrafMouse;
FROM AESWindows      IMPORT WindGet;
FROM AESResource     IMPORT RsrcLoad, RsrcGAddr, RsrcFree;
FROM AESForms        IMPORT FormAlert, FormCenter, FormDial, FormDo;
FROM AESObjects      IMPORT ObjcDraw, ObjcChange;
FROM AESFileSelector IMPORT FselInput;

CONST (* Resource constants *)

      OUTPUT    = 0;  	(* TREE *)
      OPTIONSC  = 1;  	(* TREE *)
      OPTIONSM  = 2;  	(* TREE *)
      INFO      = 3;  	(* TREE *)

      OUTSCRN   = 1;  	(* OBJECT in TREE #0 *)
      OUTDISK   = 2;  	(* OBJECT in TREE #0 *)
      OUTPRINT  = 3;  	(* OBJECT in TREE #0 *)

      STUT      = 2;  	(* OBJECT in TREE #1 *)
      PIG       = 3;  	(* OBJECT in TREE #1 *)
      NERD      = 4;  	(* OBJECT in TREE #1 *)
      LISP      = 5;  	(* OBJECT in TREE #1 *)
      JAP       = 6;  	(* OBJECT in TREE #1 *)
      CENSOR    = 7;  	(* OBJECT in TREE #1 *)
      CHINESE   = 8;  	(* OBJECT in TREE #1 *)
      COCKNEY   = 9;  	(* OBJECT in TREE #1 *)
      GERMAN    = 10;  	(* OBJECT in TREE #1 *)
      ITALIAN   = 11;  	(* OBJECT in TREE #1 *)
      RANDOM    = 13;  	(* OBJECT in TREE #1 *)
      DOIT      = 14;  	(* OBJECT in TREE #1 *)

      INFOEXIT  = 3;  	(* OBJECT in TREE #3 *)

      D0      = 0;
      pop     = 4FEFH;
      term0   = 0;
      prstat  = 11H;
      setdrv  = 0EH;
      getdrv  = 19H;
      setpath = 3BH;
      getpath = 47H;

      TrapGEMDOS = 4E41H;

PROCEDURE Dgetpath(drive: INTEGER; buf: ADDRESS; fnID: INTEGER);
  CODE TrapGEMDOS;

PROCEDURE Dsetdrv(drive: INTEGER; fnID: INTEGER); CODE TrapGEMDOS;

PROCEDURE GEMDOSfn(fnID: INTEGER); CODE TrapGEMDOS;

VAR
    (* trees *)
    outputTree, optionsTree, infoTree : ADDRESS;

    i, optionsIndex,
    gHandle, charW, charH, boxW, boxH, boxX, boxY,
    scrnX, scrnY, scrnW, scrnH,
    formX, formY, formW, formH : INTEGER;

    saveDrive   : INTEGER;
    savePath,
    saveFile    : AccentString;
    accentOptions : BITSET;

    accentChoices : ARRAY [STUT..RANDOM] OF CHAR;

(*================================================================*)

PROCEDURE append(VAR start, end : ARRAY OF CHAR; at : INTEGER);
(* append 'end' to 'start' beginning with character 'at'
 * 'end' MUST BE NULL TERMINATED!
 *   NO length check is performed on 'start', and a null is appended.
 *)
  VAR pos,len: INTEGER;
  BEGIN
    len := HIGH(end);
    pos := 0;
    WHILE (pos <= len)AND(end[pos] # 0C) DO
       start[pos + at] := end[pos];
       INC(pos);
    END;
    start[pos + at] := 0C;
  END append;

(*----------------------------------------------------------------*)

PROCEDURE crash(str : ARRAY OF CHAR);
(* Crash gracefully, with an informative alert *)
  VAR
    alert, alertend : ARRAY [0..79] OF CHAR;
  BEGIN
    alert := '[1][ ';
    alertend := ' error ][ arf ]';
    append(alert, str, 5);
    append(alert, alertend, 6 + HIGH(str));
    i := FormAlert(1, alert);
    GEMTerm;
  END crash;

(*----------------------------------------------------------------*)


PROCEDURE DoDial(VAR num: INTEGER; tree: ADDRESS);
(* on entry, 'num' contains object index to draw in 'tree'
 * on exit, it contains the index of the object causing the exit
 * from the form.
 *)
   VAR
    numbits: BITSET;
    doubleclick: BOOLEAN;
   BEGIN
      (* get dimensions and draw the form *)
      IF FormCenter(tree, formX, formY, formW, formH) = AESError THEN
         crash("FormCenter") END;
      i := FormDial(FmdStart,
               boxX, boxY, boxW, boxH,
               formX,formY,formW,formH);
      i := FormDial(FmdGrow,
               boxX, boxY, boxW, boxH,
               formX,formY,formW,formH);
      i := ObjcDraw(tree, 0, 10, formX, formY, formW, formH);


      (* form interaction.  bits in 'accentOptions' are set/cleared
       * during interaction with Options tree
       *)
      IF tree # optionsTree THEN
        numbits := VAL(BITSET,FormDo(tree, 0));
        (* check the high bit (set if exit object double-clicked) *)
        IF (15 IN numbits) THEN EXCL(numbits,15) END;
        num := VAL(INTEGER,numbits);
        (* change exit object state back to NORMAL *)
	i := ObjcChange(tree,num,0,0,0,0,0,0,0);
      ELSE
        LOOP
          numbits := VAL(BITSET,FormDo(tree,0));
          IF (15 IN numbits) THEN (* object double-clicked *)
            EXCL(numbits,15);
            doubleclick := TRUE;
          END;
          i := VAL(INTEGER,numbits);
          IF i = DOIT THEN i := ObjcChange(tree, DOIT, 0,0,0,0,0,0,0); EXIT;
          ELSIF (VAL(CARDINAL,i) IN accentOptions) THEN
            EXCL(accentOptions,VAL(CARDINAL,i))
          ELSE
            INCL(accentOptions,VAL(CARDINAL,i))
          END;
          IF doubleclick THEN doubleclick := FALSE; EXIT END;
        END;
      END;
            
      (* clean 'er up *)
      i := FormDial(FmdShrink,
               boxX, boxY, boxW, boxH,
               formX,formY,formW,formH);
      i := FormDial(FmdFinish,
               boxX, boxY, boxW, boxH,
	       formX,formY,formW,formH);

   END DoDial;

(*----------------------------------------------------------------*)

PROCEDURE ClearScreen;
(* hide the mouse and do a VT-52 clearscreen *)
  BEGIN
    i := GrafMouse(MOff,NIL);
    Write(33C); Write('E');
  END ClearScreen;


(*----------------------------------------------------------------*)
PROCEDURE GetDefaults;
  VAR drv: INTEGER;
  BEGIN
    (* get current drive *)
    GEMDOSfn(getdrv);
    INLINE(pop,2);
    drv := SHORT(REG(D0));
    savePath := "A:";
    savePath[0] := CHR( ORD(savePath[0]) + drv );

    (* get default path on current drive *)
    Dgetpath(0,ADR(saveFile),getpath);
    INLINE(pop,8);
    append(savePath,saveFile,2);
    (* add default extender *)
    saveFile := "\*.TXT";
    i := 0; REPEAT INC(i) UNTIL savePath[i] = 0C;
    append(savePath,saveFile,i);
    saveFile := "";
  END GetDefaults;

(*================================================================*)

PROCEDURE DoAlert(defbuttn: INTEGER; str: ARRAY OF CHAR): INTEGER;
  VAR ret: INTEGER;
  BEGIN
    ret := GrafMouse(MOn,NIL);
    ret := FormAlert(defbuttn,str);
    ClearScreen;
    RETURN ret;
  END DoAlert;

(*----------------------------------------------------------------*)

PROCEDURE ShowTitle;
  VAR button: INTEGER;
  BEGIN
    IF ApplInit() = InitError THEN
      crash("ApplInit")
    ELSE
      (* get resolution *)
      gHandle := GrafHandle(charW, charH, boxW, boxH);
      IF WindGet(SCREEN, WfWorkxywh,
                 scrnX, scrnY, scrnW, scrnH) = AESError THEN
        crash("WindGet")
      END;

      (* check resolution -- no low rez *)
      IF scrnW > 320 THEN
        IF scrnH > 200 THEN (* mono *)
          optionsIndex := OPTIONSM
        ELSE
          optionsIndex := OPTIONSC
        END
      ELSE
        i := FormAlert(1,"[3][Medium or High rez please...][Oh, alright]");
        GEMTerm;
      END;

      (* find center-screen box coordinates *)
      boxX := scrnX + (scrnW DIV 2);
      boxY := scrnY + (scrnH DIV 2);

      (* get the resource *)
      IF RsrcLoad(ADR("accent.rsc")) = AESError THEN
        crash("accent.rsc not found -- ")
      END;

      (* change mouse to an arrow, and hide it *)
      i := GrafMouse(Arrow, NIL);
      i := GrafMouse(MOff,NIL);

      accentOptions := {};

      accentChoices[STUT]   := 'S';
      accentChoices[PIG]    := 'P';
      accentChoices[NERD]   := 'D';
      accentChoices[LISP]   := 'L';
      accentChoices[JAP]    := 'J';
      accentChoices[CENSOR] := 'O';
      accentChoices[CHINESE]:= 'C';
      accentChoices[COCKNEY]:= 'K';
      accentChoices[GERMAN] := 'G';
      accentChoices[ITALIAN]:= 'I';
      accentChoices[RANDOM] := 'R';

      (* show the title dialog *)
      IF RsrcGAddr(RTree, INFO, infoTree) = AESError THEN
        crash("RsrcGAddr")
      END;
      i := GrafMouse(MOn,NIL);
      button := INFO;
      DoDial(button,infoTree);
      ClearScreen;

    END; (* IF ApplInit() *)

  END ShowTitle;

(*----------------------------------------------------------------*)

PROCEDURE GetFile(msg: ARRAY OF CHAR;
                  VAR cancel: BOOLEAN;
                  VAR pathname: AccentString);
(* IF cancel, get input file, else get output file. *)
  VAR
    button: INTEGER;
    file: AccentString;

  BEGIN

    IF ~cancel THEN (* show output dialog *)
      IF RsrcGAddr(RTree, OUTPUT, outputTree) = AESError THEN
        crash("RsrcGAddr")
      END;
      button := OUTPUT;
      i := GrafMouse(MOn,NIL);
      DoDial(button,outputTree);
      ClearScreen;
      IF button = OUTSCRN THEN (* output to screen *)
        cancel := TRUE; RETURN;
      ELSIF button = OUTPRINT THEN (* output to printer *)
        GEMDOSfn(prstat);
        INLINE(pop,2);
        button := SHORT(REG(D0));
        IF button = 0 THEN
          i := DoAlert(1,"[1][Your printer is not ready][oops]");
          GetFile(msg,cancel,pathname);
        ELSE
          pathname := "PRN:"; cancel := FALSE;
        END;
        RETURN
      END; (*IF button*)
    END;(*IF ~cancel*)

    pathname := savePath;
    file := saveFile;

    (* get path\filename via FselInput *)
    i := 0; REPEAT INC(i) UNTIL ( (i >= HIGH(msg)) OR (msg[i] = 0C) );
    i := 72 - (i DIV 2);
    Write(33C); Write('Y'); Write(CHR(33)); Write(CHR(i));
    Write(33C); Write('p');
    WriteString(msg);
    Write(33C); Write('q');
    i := GrafMouse(MOn,NIL);
    i := FselInput(pathname,file,button);
    ClearScreen;
    cancel := (button = 0);
    IF cancel THEN
      file := "";
    ELSE
      savePath := pathname;
      saveFile := file;
    END;
    (* change default extender to selected filename *)
    i := 0; REPEAT INC(i) UNTIL pathname[i] = 0C;
    REPEAT DEC(i) UNTIL pathname[i] = '\'; INC(i);
    append(pathname,file,i);
(*
    IF ~cancel THEN
      WriteString(pathname); WriteString(" selected"); WriteLn;
    END;
*)
  END GetFile;

(*----------------------------------------------------------------*)

PROCEDURE GetArgs(VAR args: AccentString);
  VAR n,pos: CARDINAL;
  BEGIN

    (* show options dialog *)
    IF RsrcGAddr(RTree, optionsIndex, optionsTree) = AESError THEN
       crash("RsrcGAddr") END;
    i := GrafMouse(MOn,NIL);
    DoDial(optionsIndex,optionsTree);
    ClearScreen;

    (* convert accentOptions bitmap to string of option characters *)
    args := "-"; pos := 1;
    FOR n := STUT TO RANDOM DO
      IF n IN accentOptions THEN
        args[pos]:= accentChoices[n]; INC(pos);
      END;
    END;

    (* no options chosen, alert the user *)
    IF pos = 1 THEN
      i := DoAlert(2,"[1][You need to pick an option][OK|no I don't]");
      IF i = 2 THEN GEMTerm END; (* the default - in case you lose your mouse *)
      FOR i := 0 TO HIGH(args) DO args[i] := 0C END;
      GetArgs(args);
    ELSE
      args[pos] := 0C;
    END;

  END GetArgs;
    
(*----------------------------------------------------------------*)

PROCEDURE GEMTerm;
  BEGIN
    i := RsrcFree();
    i := ApplExit();
    GEMDOSfn(term0);
  END GEMTerm;

(*================================================================*)

BEGIN (* AccentObjects *)

  GetDefaults; (* GEM Init code in ShowTitle *)

END AccentObjects.
