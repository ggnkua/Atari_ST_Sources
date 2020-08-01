MODULE Def2Ref;

(*
 * produces a reference file for ST-Guide from Modula or Oberon
 * definition files.
 *
 * Call syntax:
 *   def2ref [-s<defpath>] [-d<refpath>] [-e<extension>] [<deffile>{ <deffile>}]
 *
 * Explanation:
 *
 *   -s<defpath>
 *     "s" is for source. "defpath" must be the path where the definition
 *     files are stored. If no source path is defined, the environment
 *     variable "DEFPATH" is used. If that variable does not exist,
 *     "deffile" must have its path or else must be found in the current
 *     directory.
 *
 *   -d<refpath>
 *     "d" is for destination. "refpath" may be a path where the ref is
 *     to be saved or the name of the ref file or both. If no path is
 *     defined, "defpath" or its substitute (see above) is used. If no
 *     name is defined, "DEF.REF" is used. If a path without name is
 *     defined, this path must have a "\" at the end!
 *
 *   -e<extension>
 *     allows a different extension for definition files to be set.
 *     Default is "DEF".
 *
 *   <deffile>
 *     These definition files will be searched for identifiers to set
 *     references on. If no files are given, all files in "defpath" or
 *     or its substitute (see above) are searched.
 *     Files must be defined last in the command line.
 *)


IMPORT
  S:=SYSTEM, CL:=CommandLine, Env:=Environment, IO, FN:=Filename, StdPath,
  Files:=BFiles, File, Strings, Task, Sys;

(*-----------------------------------CONST-------------------------------*)

CONST
  none = 0; eol = 1; const = 2; type = 3; var = 4;
  procedure = 5; colon = 6; equal = 7; comma = 8; ident = 9;
  eof = 10; semicolon = 11; record = 12; end = 13; definition = 14;
  module = 15;

(*-----------------------------------TYPE--------------------------------*)

TYPE
  Rider    = RECORD(Files.Rider)
             END;

(*-----------------------------------VAR---------------------------------*)

VAR
  srcpath, destpath: FN.path;
  extension: FN.ext;
  destset: BOOLEAN;
  reffile: Files.File; ref, def: Rider;
  identname, modulename: ARRAY 24 OF CHAR;
  ch: CHAR;
  entries : LONGINT;
  line: INTEGER;

(*--------------------------------Rider.Methods--------------------------*)

PROCEDURE(VAR r : Rider) WriteId*(VAR id : ARRAY OF CHAR);
  VAR
    i : INTEGER;
 BEGIN
  i := 0;
  WHILE (id[i] # 0X) AND (i < LEN(id)) DO
    r.Write^(id[i]); INC(i)
  END;
  r.Write^(0);
 END WriteId;


PROCEDURE(VAR r : Rider) WriteInt*(val : INTEGER);
 BEGIN
  r.Write^( SHORT(val DIV 256) );
  r.Write^( SHORT(val MOD 256) );
 END WriteInt;


PROCEDURE(VAR r : Rider) WriteLInt*(val : LONGINT);
 BEGIN
  r.WriteInt( SHORT(val DIV 10000H) );
  r.WriteInt( SHORT(val MOD 10000H) );
 END WriteLInt;

(*-----------------------------------Get---------------------------------*)

PROCEDURE Read(VAR ch : CHAR);
 BEGIN
  IF def.eof THEN ch := 0X
  ELSE def.Read(ch)
  END;
 END Read;


PROCEDURE Get(VAR sym: INTEGER);
  VAR
    s : INTEGER;

  PROCEDURE String(c : CHAR);
   BEGIN
    LOOP
      Read(ch);
      IF (ch = c) OR (ch = 0X) THEN EXIT END ;
    END ;
    Read(ch);
   END String;

 PROCEDURE Comment; (* do not read after end of file *)
  BEGIN
   Read( ch);
   LOOP
     LOOP
       WHILE ch = "(" DO Read( ch);
         IF ch = "*" THEN Comment END
       END ;
       IF ch = "*" THEN Read( ch); EXIT END ;
       IF ch = 0X THEN EXIT END ;
       IF ch = 0AX THEN INC(line) END;
       Read( ch)
     END ;
     IF ch = ")" THEN Read( ch); EXIT END ;
     IF ch = 0X THEN EXIT END
   END
  END Comment;

  PROCEDURE Identifier(VAR sym: INTEGER);
    VAR
      i: INTEGER;
   BEGIN
    i := 0;
    REPEAT
      IF i < 23 THEN
        identname[i] := ch; INC(i);
      END;
      Read( ch)
    UNTIL (ch < "0") OR ("9" < ch) & (CAP(ch) < "A") OR ("Z" < CAP(ch));
    identname[i] := 0X;
    IF identname = "VAR" THEN sym := var
    ELSIF identname = "CONST" THEN sym := const
    ELSIF identname = "TYPE" THEN sym := type
    ELSIF identname = "PROCEDURE" THEN sym := procedure
    ELSIF identname = "RECORD" THEN sym := record
    ELSIF identname = "END" THEN sym := end
    ELSIF identname = "DEFINITION" THEN sym := definition
    ELSIF identname = "MODULE" THEN sym := module
    ELSE sym := ident;
    END;
   END Identifier;

 BEGIN
  LOOP (*ignore control characters*)
    IF ch <= " " THEN
      IF ch = 0AX THEN Read(ch); sym := eol; RETURN END;
      IF ch = 0X THEN sym := eof; RETURN
      ELSE Read( ch)
      END
    ELSIF ch > 7FX THEN Read( ch)
    ELSE EXIT
    END
  END ;
  s := none;
  CASE ch OF   (* " " <= ch <= 7FX *)
  | 22X,"'" : String(ch)
  | "("  : Read( ch);
      IF ch = "*" THEN Comment; Get(s) END
  | ":"  : Read( ch); s := colon
  | ";"  : Read( ch); s := semicolon
  | "="  : s := equal; Read( ch)
  | "0".."9", "A".."Z","a".."z" : Identifier(s)
  ELSE Read( ch)
  END ;
  sym := s
 END Get;

(*-----------------------------------Enter-------------------------------*)

(* Aufbau REF:

     Datei-Kennung
       4 Bytes Magic ('HREF')

     Modul-Header
       4 Bytes L„nge des Moduls ohne Header
       4 Bytes Anzahl der Eintr„ge im aktuellen Modul

     Modul-Daten
       1 Byte  Kennung des Eintrages
               0: Dateiname (z.B. 'ST-GUIDE')
                  immer ohne Pfad
                  (eintragen eines Pfades ist jedoch erlaubt)
                  und meist auch ohne Endung
                  (als Endung wird .HYP verwendet, falls keine angegeben)
               1: Node Name
                  Seitenname aus dem Hypertext zum letzten Datei-Eintrag
               2: Alias Name
                  Aliasname aus dem Hypertext zum letzten Node-Eintrag
                  (wird vom hcp nur optional hier eingetragen)
               3: Label Name
                  Labelname aus dem Hypertext zum letzten Node-Eintrag
                  (wird vom hcp nur optional hier eingetragen)
               4: database Name
                  Database-Argument zum letzten Dateieintrag

       1 Byte  L„nge des Eintrages
       n Bytes Eintrag als Nullterminierter String
               bei Typ 3 folgen dem String noch 2 Bytes Zeilennummer

     Beliebig viele weitere Modul-Header gefolgt von Modul-Daten.

       8 Bytes Nullen als Ende-Kennung
*)

PROCEDURE Enter(VAR name: ARRAY OF CHAR; line: INTEGER);
  VAR
    fullname: FN.path;
 BEGIN
  INC(entries, 2);
  ref.Write(3);		(* label name *)
  ref.Write( SHORT(Strings.Length(name)+5) );
  ref.WriteId(name);
  ref.WriteInt(line);
  COPY(modulename, fullname); Strings.AppendC(".", fullname);
  Strings.Append(name, fullname);
  ref.Write(3);		(* label name *)
  ref.Write( SHORT(Strings.Length(fullname)+5) );
  ref.WriteId(fullname);
  ref.WriteInt(line);
 END Enter;

(*-----------------------------------Scan--------------------------------*)

PROCEDURE Scan;
 VAR
   mode, sym: INTEGER;

  PROCEDURE SkipType;
   BEGIN
    WHILE (sym # record) AND (sym # semicolon) AND (sym # eof) DO
      Get(sym);
    END;
    IF sym = record THEN
      REPEAT
        Get(sym);
        IF sym = record THEN
          SkipType
        END;
      UNTIL (sym = eof) OR (sym = end);
    END;
   END SkipType;

 BEGIN
  mode := -1; line := 0;
  REPEAT
    Get(sym);
    IF sym = eol THEN INC(line)
    ELSIF (sym = const) OR (sym = type) THEN mode := equal
    ELSIF (sym = var) AND (mode # none) THEN mode := colon
    ELSIF sym = procedure THEN
      mode := none;
      Get(sym);
      IF sym = ident THEN Enter(identname, line) END;
    ELSIF (sym = equal) AND (mode = equal) THEN
      Enter(identname, line)
    ELSIF (mode = colon) AND ((sym = colon) OR (sym = comma)) THEN
      Enter(identname, line);
      IF sym = colon THEN Get(sym); SkipType END;
    END;
  UNTIL sym = eof;
 END Scan;

(*-----------------------------------Def2Ref-----------------------------*)

PROCEDURE Def2Ref(VAR file: ARRAY OF CHAR);
  VAR
    name, path: FN.path;
    deffile: Files.File;
    modhead, end : LONGINT;
    sym : INTEGER;
    ok: BOOLEAN;
 BEGIN
  IF reffile = NIL THEN		(* no file opened yet *)
    IF NOT destset THEN FN.SetPath(srcpath, destpath) END;
    reffile := Files.New(destpath);
    IF reffile = NIL THEN
      IO.WriteString("Reference file "); IO.WriteString(destpath);
      IO.WriteString(" could not be created"); IO.WriteLn;
      Task.Exit(-36);
    END;
    ref.Set(reffile, 0);
    ref.WriteLInt(48524546H);
  END;
  COPY(file, name); FN.GetExt(name, path);
  IF path = "" THEN FN.SetExt(extension, name) END;
  FN.GetPath(name, path);
  IF path = "" THEN FN.SetPath(srcpath, name) END;
  IO.WriteString("Referencing "); IO.WriteString(name); IO.WriteLn;

  deffile := Files.Old(name);
  IF deffile = NIL THEN
    IO.WriteString("Definition file "); IO.WriteString(name);
    IO.WriteString(" could not be opened"); IO.WriteLn;
  ELSE
    def.Set(deffile, 0); ch := " ";
    Get(sym);
    ok := FALSE;
    IF sym = definition THEN
      Get(sym); ok := TRUE;
    END;
    IF sym = module THEN
      Get(sym); ok := TRUE;
    END;
    IF ok THEN
      modhead := ref.Pos(); entries := 3;
      ref.WriteLInt(0); ref.WriteLInt(0);
      ref.Write(0);	(* file name *)
      ref.Write( SHORT(Strings.Length(name)+3) );
      ref.WriteId(name);
      ref.Write(1);	(* node name *)
      ref.Write( 7);
      name := "Main";
      ref.WriteId( name);
      ref.Write( 2);	(* alias name *)
      ref.Write( SHORT(Strings.Length(identname)+3) );
      ref.WriteId(identname);
      modulename := identname;
      Scan;
      deffile.Close;
      end := ref.Pos();
      ref.Set(reffile, modhead);
      ref.WriteLInt(end-modhead-8);
      ref.WriteLInt(entries);
      ref.Set(reffile, end);
    ELSE
      IO.WriteString( "No definition module!"); IO.WriteLn;
    END;
  END;
 END Def2Ref;


PROCEDURE AllDef2Ref;
  VAR
    path, name: FN.path;
 BEGIN
  COPY(srcpath, path);
  name := "*."; Strings.Append(extension, name);
  FN.SetName(name, path);
  IF File.Sfirst(path, {}) THEN
    REPEAT
      FN.SetName(File.Dta.Name, path);
      Def2Ref(path);
    UNTIL NOT File.Snext();
  END;
 END AllDef2Ref;

(*-----------------------------------Work--------------------------------*)

PROCEDURE SetBackslash(VAR path: ARRAY OF CHAR);
 BEGIN
  IF path[Strings.Length(path)-1] # "\" THEN
    Strings.AppendC("\", path)
  END;
 END SetBackslash;


PROCEDURE SetDefaultWork;
 BEGIN
  IF NOT Env.ReadStr("DEFPATH", srcpath) THEN
    COPY(StdPath.stdPath, srcpath)
  END;
  SetBackslash(srcpath);
  COPY(srcpath, destpath);
  FN.SetName("DEF.REF", destpath);
  extension := "DEF";
 END SetDefaultWork;


PROCEDURE ReadSource(VAR src: ARRAY OF CHAR);
 BEGIN
  Strings.Excerpt(2, 100, src, srcpath);
  SetBackslash(srcpath);
 END ReadSource;


PROCEDURE ReadDest(VAR dest: ARRAY OF CHAR);
  VAR
    path, name : FN.path;
 BEGIN
  destset := TRUE;
  Strings.Excerpt(2, 100, dest, path);
  FN.GetName(path, name); FN.GetPath(path, path);
  IF path # "" THEN FN.SetPath(path, destpath) END;
  IF name # "" THEN FN.SetName(name, destpath) END;
 END ReadDest;


PROCEDURE ReadExt(VAR ext: ARRAY OF CHAR);
 BEGIN
  Strings.Excerpt(2, 5, ext, extension);
 END ReadExt;


PROCEDURE Work;
 BEGIN
  SetDefaultWork;
  WHILE CL.arg # NIL DO
    IF CL.arg[0] = "-" THEN
      IF CL.arg[1] = "s" THEN ReadSource(CL.arg^)
      ELSIF CL.arg[1] = "d" THEN ReadDest(CL.arg^)
      ELSIF CL.arg[1] = "e" THEN ReadExt(CL.arg^)
      ELSE
        IO.WriteString("Unknown option "); IO.WriteString(CL.arg^);
        IO.WriteLn;
        RETURN
      END;
    ELSE
      Def2Ref(CL.arg^);
    END;
    CL.Next;
  END;
  IF reffile = NIL THEN		(* no ref file produced *)
    AllDef2Ref
  END;
 END Work;


PROCEDURE Run*;
 BEGIN
  IO.WriteString("Definition file referencer V1.01 (c) Stephan Junker");
  IO.WriteLn;
  Work;
  IF reffile = NIL THEN
    IO.WriteString("No definition files found!"); IO.WriteLn;
    IO.WriteString("Source path: "); IO.WriteString(srcpath); IO.WriteLn;
    IO.WriteString("Extension:   "); IO.WriteString(extension); IO.WriteLn;
  ELSE
    IO.WriteString("Reference file: "); IO.WriteString(destpath); IO.WriteLn;
    ref.WriteLInt(0); ref.WriteLInt(0);
    reffile.Register; reffile.Close;
  END;
 END Run;


BEGIN
  (* Initialize your module here *)
  IF ~Sys.Loader THEN (* if running as stand alone program *)
    Run;
    Task.Exit(0); (* needed for clean up; will not return *)
  END;
END Def2Ref.