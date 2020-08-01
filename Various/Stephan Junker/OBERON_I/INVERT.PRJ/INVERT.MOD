(*
**
** PROGRAM :  Invert
** VERSION :  V0.8
** AUTHOR  :  Ch.Geiser, H”htalstrasse 13, CH-5400 Ennetbaden
** DATE    :  14.1.95
** PURPOSE :  Little brain twister
** LANGUAGE:  STJ-Oberon2 (c) Stephan Junker
** REMARKS :  Keypad not yet supported. How do we install
**            an Event Handler?
*)
MODULE Invert;


IMPORT S    :=SYSTEM,
       Menus, WDial:=WindowDialog,
       TextViewer,
       GemApp, Evnt, Graf,    Sys,     Task,
       Rsrc,   Form, Objc,    NumStr, Strings, XBIOS;

CONST RESOURCEFILE = "INVERT.RSC";

(* Resource Datei Indizes fr INVERT *)
    MENU     =   0; (* Menuebaum *)
    MDESK    =   3; (* TITLE in Baum MENU *)
    MGAME    =   4; (* TITLE in Baum MENU *)
    MHELP    =   5; (* TITLE in Baum MENU *)
    MIABOUT  =   8; (* STRING in Baum MENU *)
    MINEWGAME =  17; (* STRING in Baum MENU *)
    MIQUIT   =  19; (* STRING in Baum MENU *)
    MIHELP   =  21; (* STRING in Baum MENU *)
    MIREADME =  22; (* STRING in Baum MENU *)

    ABOUT    =   1; (* Formular/Dialog *)

    BOARD    =   2; (* Formular/Dialog *)
    FRAME    =   0; (* BOX in Baum BOARD *)
    FLDMOVES =   1; (* FTEXT in Baum BOARD *)
    B1       =   2; (* BOX in Baum BOARD *)
    B2       =   3; (* BOX in Baum BOARD *)
    B3       =   4; (* BOX in Baum BOARD *)
    B4       =   5; (* BOX in Baum BOARD *)
    B5       =   6; (* BOX in Baum BOARD *)
    B6       =   7; (* BOX in Baum BOARD *)
    B7       =   8; (* BOX in Baum BOARD *)
    B8       =   9; (* BOX in Baum BOARD *)
    B9       =  10; (* BOX in Baum BOARD *)
    BTNSHUFFEL =  11; (* BUTTON in Baum BOARD *)

    HELP     =   3; (* Formular/Dialog *)

    GOAL     =   4; (* Formular/Dialog *)

    STRINGS  =   5; (* Formular/Dialog *)
    HDABOUT  =   1; (* STRING in Baum STRINGS *)
    HDHELP   =   2; (* STRING in Baum STRINGS *)
    HDVICTORY =   3; (* STRING in Baum STRINGS *)
    HDGAME   =   4; (* STRING in Baum STRINGS *)
    HDBLAME  =   5; (* STRING in Baum STRINGS *)
    HDREADME =   6; (* STRING in Baum STRINGS *)

    BLAME    =   6; (* Formular/Dialog *)


TYPE
  GameDialog  = POINTER TO GameDesc;    (* we need a new close procedure for game dialog *)
  GameDesc    = RECORD(WDial.DialDesc)
                END;

VAR aboutDial,
    blameDial,
    helpDial,
    victoryDial,
    inputDial : WDial.Dialog;
    gameDial  : GameDialog;
    Field     : ARRAY 3,3 OF INTEGER;
    nbrOfMoves: INTEGER;
    nbrStr    : ARRAY 4 OF CHAR;
    done      : BOOLEAN;
    v         : TextViewer.Viewer;
    m         : TextViewer.Model;


PROCEDURE(d:GameDialog) Close;
  (* Redefinition of dialogs Close procedure *)
  BEGIN
    d.Close^; 		(* call inherited Close procedure *)
    victoryDial.Close;	(* close possibly open victory dialog *)
  END Close;


PROCEDURE ShowAbout;
  BEGIN
    aboutDial.Open;
   END ShowAbout;


PROCEDURE ShowHelp;
  BEGIN
    helpDial.Open;
  END ShowHelp;


PROCEDURE Exit;
  BEGIN
    GemApp.exit := TRUE; (* die saubere Methode *)
  END Exit;


PROCEDURE IncrementMoves;
  BEGIN
    INC(nbrOfMoves);
    NumStr.IntTo(nbrOfMoves, 10, nbrStr);
    gameDial.SetText(FLDMOVES, nbrStr);
  END IncrementMoves;


PROCEDURE FlipField(x, y: INTEGER);
  VAR s: SET;
  BEGIN
    IF (WDial.exitBut # Field[x,y]) THEN
      s := Objc.GetState(gameDial.objTree, Field[x,y]);
      IF (Objc.SELECTED IN s) THEN
          EXCL(s, Objc.SELECTED)
      ELSE
        INCL(s, Objc.SELECTED)
      END;
      Objc.SetState(gameDial.objTree, Field[x,y], s);
      gameDial.RedrawObj(Field[x,y]);
    END
  END FlipField;


PROCEDURE FlipCorner(xstart, ystart: INTEGER);
  VAR x,y: INTEGER;
  BEGIN
    FOR y := ystart TO ystart+1 DO
      FOR x := xstart TO xstart+1 DO
        FlipField(x, y)
      END;
    END;
  END FlipCorner;


PROCEDURE FlipRow(ystart: INTEGER);
  VAR x: INTEGER;
  BEGIN
    FOR x := 0 TO 2 DO
      FlipField(x, ystart);
    END;
  END FlipRow;


PROCEDURE FlipColumn(xstart: INTEGER);
  VAR y: INTEGER;
  BEGIN
    FOR y := 0 TO 2 DO
      FlipField(xstart, y)
    END
  END FlipColumn;


PROCEDURE FlipAll;
  VAR x,y: INTEGER;
  BEGIN
    FOR y := 0 TO 2 DO
      FlipRow(y)
    END
  END FlipAll;


PROCEDURE AllInverted(): BOOLEAN;
  CONST TOTALFIELDS = 9;
  VAR i,j,selectedFields: INTEGER;
      s    : SET;
  BEGIN
    selectedFields := 0;
    FOR j := 0 TO 2 DO
      FOR i := 0 TO 2 DO
        s := Objc.GetState(gameDial.objTree, Field[i,j]);
        IF (Objc.SELECTED IN s) THEN
          INC(selectedFields)
        END
      END
    END;
    done := (selectedFields = TOTALFIELDS);
    RETURN done;
  END AllInverted;


PROCEDURE InitBoard;
  VAR i,j: INTEGER;
      s  : SET;
  BEGIN
    done := FALSE;
    victoryDial.Close;
    blameDial.Close;

    FOR j := 0 TO 2 DO
      FOR i := 0 TO 2 DO
        s := Objc.GetState(gameDial.objTree, Field[i,j]);
        EXCL(s, Objc.SELECTED);
        Objc.SetState(gameDial.objTree, Field[i,j], s)
      END
    END;

    FOR j := 0 TO 2 DO
      FOR i := 0 TO 2 DO
        IF ODD(XBIOS.Random()) THEN
          s := Objc.GetState(gameDial.objTree, Field[i,j]);
          INCL(s, Objc.SELECTED);
          Objc.SetState(gameDial.objTree, Field[i,j], s)
        END
      END
    END;

    nbrOfMoves := 0;
    nbrStr     := "0_";
    gameDial.SetText(FLDMOVES, nbrStr);
  END InitBoard;


PROCEDURE Shuffle;
  BEGIN
    InitBoard;
    gameDial.RedrawObj(FRAME)
  END Shuffle;


PROCEDURE Flip;
  BEGIN
    IF done THEN
      InitBoard;
      gameDial.RedrawObj(FRAME)
    ELSE
      CASE WDial.exitBut OF
        B1: FlipCorner(0,0); |
        B2: FlipRow(0);      |
        B3: FlipCorner(1,0); |
        B4: FlipColumn(0);   |
        B5: FlipAll;         |
        B6: FlipColumn(2);   |
        B7: FlipCorner(0,1); |
        B8: FlipRow(2);      |
        B9: FlipCorner(1,1);
      END;
      IncrementMoves;
      IF AllInverted() THEN
        victoryDial.Open
      ELSIF (nbrOfMoves > 30) THEN
        blameDial.Open;
        done := TRUE
      END
    END
  END Flip;


PROCEDURE ShowGame;
  BEGIN
    gameDial.Open;
  END ShowGame;


PROCEDURE ShowReadme;
  BEGIN
    v.Open
  END ShowReadme;


PROCEDURE CreateGame;
  BEGIN
    NEW(gameDial);
    gameDial.InitDialog(Rsrc.GetAddr(BOARD) , 0, TRUE);
    gameDial.SetTitle  ("Spiel");
    gameDial.SetWork(BTNSHUFFEL, Shuffle, {WDial.DESELECT, WDial.REDRAWOBJ});

    gameDial.SetWork(B1, Flip, {} );
    gameDial.SetWork(B3, Flip, {} );
    gameDial.SetWork(B2, Flip, {} );
    gameDial.SetWork(B8, Flip, {} );
    gameDial.SetWork(B4, Flip, {} );
    gameDial.SetWork(B6, Flip, {} );
    gameDial.SetWork(B5, Flip, {} );
    gameDial.SetWork(B7, Flip, {} );
    gameDial.SetWork(B9, Flip, {} );

    InitBoard;
    ShowGame;
  END CreateGame;


PROCEDURE CreateMenu;
  VAR menu: Menus.Menu;
  BEGIN
    NEW(menu);
    menu.Init(Rsrc.GetAddr(MENU));
    menu.Set(MGAME, MINEWGAME, ShowGame);
    menu.Set(MGAME, MIQUIT,    Exit);
    menu.Set(MDESK, MIABOUT,   ShowAbout);
    menu.Set(MHELP, MIHELP,    ShowHelp);
    menu.Set(MHELP, MIREADME,  ShowReadme);
    menu.Show;
  END CreateMenu;


PROCEDURE CreateTextView;
  BEGIN
    NEW(m); m.Initialize;	(* create model *)
    m.LoadText("README");	(* load text *)
    NEW(v); v.Initialize;
    v.SetModel(m);		(* create viewer displaying m *)
  END CreateTextView;


PROCEDURE Init;
  VAR windowTitles: S.PTR;
      title       : Strings.ptr;
  BEGIN
    Graf.ChangeMouse( Graf.ARROW);
    IF NOT Rsrc.Load(RESOURCEFILE) THEN
      Task.Exit(-1)
    END;

    Field[0,0] := B1; Field[1,0] := B2; Field[2,0] := B3;
    Field[0,1] := B4; Field[1,1] := B5; Field[2,1] := B6;
    Field[0,2] := B7; Field[1,2] := B8; Field[2,2] := B9;

    windowTitles := Rsrc.GetAddr(STRINGS);

    CreateMenu;

    CreateTextView;
    title := Objc.GetSpec(windowTitles, HDREADME);
    v.SetTitle(title^);

    NEW(aboutDial);
    aboutDial.InitDialog(Rsrc.GetAddr(ABOUT) , 0, TRUE);
    title := Objc.GetSpec(windowTitles, HDABOUT);
    aboutDial.SetTitle(title^);

    NEW(blameDial);
    blameDial.InitDialog(Rsrc.GetAddr(BLAME) , 0, TRUE);
    title := Objc.GetSpec(windowTitles, HDBLAME);
    blameDial.SetTitle(title^);

    NEW(helpDial);
    helpDial.InitDialog(Rsrc.GetAddr(HELP) , 0, TRUE);
    title := Objc.GetSpec(windowTitles, HDHELP);
    helpDial.SetTitle(title^);

    NEW(victoryDial);
    victoryDial.InitDialog(Rsrc.GetAddr(GOAL), 0, TRUE);
    title := Objc.GetSpec(windowTitles, HDVICTORY);
    victoryDial.SetTitle(title^);

    CreateGame;
    title := Objc.GetSpec(windowTitles, HDGAME);
    gameDial.SetTitle(title^);

  END Init;


PROCEDURE Run*;
  BEGIN
    Init;
    GemApp.Run;
  END Run;

BEGIN
  IF ~Sys.Loader THEN (* if running as stand alone program *)
    Run;
    Task.Exit(0)      (* needed for cleanup, will never return *)
  END
END Invert.
