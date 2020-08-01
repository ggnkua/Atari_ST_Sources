MODULE PopupDemo;


IMPORT
  Popup, Form, Sys, Task;


VAR
  exit : BOOLEAN;


PROCEDURE HalloWelt;
  VAR
    d : INTEGER;
 BEGIN
  d := Form.Alert(1, "[1][Hallo Welt!][Ok]");
  exit := FALSE;
 END HalloWelt;


PROCEDURE HalloDu;
  VAR
    d : INTEGER;
 BEGIN
  d := Form.Alert(1, "[1][Hallo Du!][Ok]");
  exit := FALSE;
 END HalloDu;


PROCEDURE Ende;
  VAR
    d : INTEGER;
 BEGIN
  IF Form.Alert(1, "[2][Wirklich aufh”ren?][Ja|Nein]") = 2 THEN
    exit := FALSE
  END;
 END Ende;


PROCEDURE Run*;
  VAR
    menu : Popup.Menu;
 BEGIN
  NEW(menu); menu.Init;
  menu.Set("Hallo Welt", HalloWelt);
  menu.Set("Hallo Du", HalloDu);
  menu.Set("Ende", Ende);
  REPEAT
    exit := TRUE;
    menu.Show;
  UNTIL exit;
 END Run;


BEGIN
  IF ~Sys.Loader THEN (* if running as stand alone program *)
    Run;
    Task.Exit(0); (* needed for clean up; will not return *)
  END;
END PopupDemo.