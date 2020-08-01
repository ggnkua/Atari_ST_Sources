MODULE ListDemo; (* SJ 4.12.94 *)

(*
 Demonstrates usage of module ListView.
 *)

(*$+x *)

IMPORT
  ListView, GemApp, Strings, NumStr, Form, Sys, Task;


TYPE
  Element = POINTER TO RECORD(ListView.ElemDesc)
    string: ARRAY 50 OF CHAR;
  END;



VAR
  m: ListView.Model;



PROCEDURE (self: Element) ListViewString(VAR string: ARRAY OF CHAR);
 BEGIN
  COPY(self.string, string);
 END ListViewString;


PROCEDURE (self: Element) Selected(mbut: SET; clicks: INTEGER);
  VAR
    s: ARRAY 120 OF CHAR;
    d: INTEGER;
 BEGIN
  s := "[1][You selected the line|";
  Strings.Append(self.string, s);
  Strings.Append("][Ok|Deselect|Remove]", s);
  IF (d := Form.Alert(1, s)) = 3 THEN
    m.Remove(self);
  ELSIF d = 2 THEN
    m.Deselect(self)
  END;
 END Selected;


PROCEDURE Run*;
  VAR
    v: ListView.Viewer;
    e: Element;
    i: INTEGER;
 BEGIN
  NEW(m); m.Initialize;    (* create model *)
  FOR i := 0 TO 99 DO
    NEW(e);
    NumStr.IntTo(i, 10, e.string);
    Strings.Insert("ListView entry #", 0, e.string);
    m.Add(e);
  END;
  NEW(v); v.Initialize;    (* create viewer *)
  v.SetModel(m);           (* assign it a model *)
  v.SetTitle( "ListView demo");
  v.Open;                  (* open window *)
  GemApp.Run;
 END Run;


BEGIN
  IF ~Sys.Loader THEN (* if running as stand alone program *)
    Run;
    Task.Exit(0); (* needed for clean up; will not return *)
  END;
END ListDemo.