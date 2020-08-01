MODULE File;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |28.1.93  |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT
  S:=SYSTEM, Error, Task, Items, Sys;

CONST (* standard handles *)
  STDIN* = 0; STDOUT* = 1; STDERROR* = 2; STDLIST* = 3; RS232* = 4;
  NULL* = 5;

  (* modi for Fopen *)
  read* = 0; write* = 1; rdwr* = 2;

  (* file attributes *)
  rdonly* = 0; hidden* = 1; system* = 2; label* = 3; subdir* = 4; archiv* = 5;

  (* modi for Fseek *)
  absbeg* = 0; relative* = 1; absend* = 2;

  (* modi for Fdatime *)
  get* = 0; set* = 1;

TYPE dtarec*    = RECORD
                    Search* : ARRAY 12 OF CHAR;
                    rsv     : ARRAY 8 OF CHAR;
                    Attrib* : INTEGER;
                    Time*   : INTEGER;
                    Date*   : INTEGER;
                    Length* : LONGINT;
                    Name*   : ARRAY 14 OF CHAR;
                  END(*RECORD*);
     dta*       = POINTER TO dtarec;
     datime*    = RECORD
                    Time*   : INTEGER;
                    Date*   : INTEGER;
                  END(*RECORD*);


VAR Dta* : dtarec;
    Files: Items.List;

PROCEDURE- Setdta* (DtaAdr : S.PTR) 26,1;

PROCEDURE- Getdta* () : S.PTR 47,1;

PROCEDURE- Fcreate(Attr : INTEGER; Name : S.PTR) : INTEGER 60,1;

PROCEDURE Create* (Name : ARRAY OF CHAR; Attribs : SET;
                   VAR Handle : INTEGER) : BOOLEAN;
  VAR f : Items.Item;
 BEGIN
  Handle := Fcreate( SHORT(S.VAL(LONGINT,Attribs)), S.ADR(Name) );
  Error.NumStrOut(Handle,Name);
  IF Error.NoErr THEN NEW(f); Files.AddItem(f, Handle) END;
  RETURN Error.NoErr
 END Create;

PROCEDURE- Fopen(Mode : INTEGER; Name : S.PTR) : INTEGER 61,1;

PROCEDURE Open* (Name : ARRAY OF CHAR; Mode : INTEGER; VAR Handle  : INTEGER)
               : BOOLEAN;
  VAR f : Items.Item;
 BEGIN
  Handle := Fopen( Mode, S.ADR(Name) );
  Error.NumStrOut(Handle,Name);
  IF Error.NoErr THEN NEW(f); Files.AddItem(f, Handle) END;
  RETURN Error.NoErr;
 END Open;

PROCEDURE- Fclose(Handle : INTEGER) : INTEGER 62,1;

PROCEDURE Close* (Handle : INTEGER);
  VAR f : Items.Item;
 BEGIN
  Error.NumOut( Fclose(Handle) );
  IF Error.NoErr THEN Files.FindAndDelete(Handle) END;
 END Close;

PROCEDURE- Fread(Buffer,Count : LONGINT; Handle : INTEGER) : LONGINT 63,1;

PROCEDURE Read* (Handle : INTEGER; VAR Count : LONGINT; Buffer : S.PTR)
                 : BOOLEAN;
 BEGIN
  Count := Fread(Buffer,Count,Handle);
  IF Count >= 0 THEN RETURN TRUE END(*IF*);
  Error.NumOut( SHORT(Count) );
  RETURN FALSE
 END Read;

PROCEDURE- Fwrite(Buffer,Count : LONGINT; Handle : INTEGER) : LONGINT 64,1;

PROCEDURE Write* (Handle : INTEGER; VAR Count : LONGINT; Buffer : S.PTR)
                  : BOOLEAN;
  VAR
    Bytes : LONGINT;
 BEGIN
  Bytes := Count;
  Count := Fwrite(Buffer,Bytes,Handle);
  IF Count = Bytes THEN RETURN TRUE
  ELSIF Count >= 0 THEN
    Error.StrOut("Not all bytes written.|Maybe disk full.");
    RETURN FALSE
  END;
  Error.NumOut(SHORT(Count));
  RETURN FALSE
 END Write;

PROCEDURE- Fdelete(Name : LONGINT) : INTEGER 65,1;

PROCEDURE Delete* (Name : ARRAY OF CHAR) : BOOLEAN;
 BEGIN
  Error.NumStrOut( Fdelete(S.ADR(Name)), Name);
  RETURN Error.NoErr
 END Delete;

PROCEDURE- Fseek(Mode,Handle : INTEGER; Bytes : LONGINT) : LONGINT 66,1;

PROCEDURE Seek* (Handle : INTEGER; Bytes : LONGINT; Mode : INTEGER;
                 VAR FilePtr : LONGINT) : BOOLEAN;
 BEGIN
  FilePtr := Fseek(Mode,Handle,Bytes);
  IF FilePtr >= 0 THEN RETURN TRUE END(*IF*);
  Error.NumOut( SHORT(FilePtr) );
  RETURN FALSE
 END Seek;

PROCEDURE- Fattrib(Attr,Mode : INTEGER; Name : LONGINT) : INTEGER 67,1;

PROCEDURE Attrib* (Name : ARRAY OF CHAR; Mode : INTEGER; VAR Attribs : SET)
                   : BOOLEAN;
  VAR r : INTEGER;
 BEGIN
  r := Fattrib( SHORT(S.VAL(LONGINT,Attribs)), Mode, S.ADR(Name) );
  Error.NumOut(r);
  Attribs := S.VAL(SET,LONG(r));
  RETURN Error.NoErr
 END Attrib;

PROCEDURE- Fdup(Handle : INTEGER) : INTEGER 69,1;

PROCEDURE Dup* (StdHandle : INTEGER; VAR Handle : INTEGER) : BOOLEAN;
 BEGIN
  Handle := Fdup(StdHandle);
  Error.NumOut(Handle);
  RETURN Error.NoErr
 END Dup;

PROCEDURE- Fforce(Handle,Nstd : INTEGER) : INTEGER 70,1;

PROCEDURE Force* (StdHandle,NstdHandle : INTEGER) : BOOLEAN;
 BEGIN
  Error.NumOut( Fforce(StdHandle,NstdHandle) );
  RETURN Error.NoErr
 END Force;

PROCEDURE- Fsfirst(Attr : INTEGER; Name : LONGINT) : INTEGER 78,1;

PROCEDURE Sfirst* (Name : ARRAY OF CHAR; Attribs : SET) : BOOLEAN;
 BEGIN RETURN Fsfirst( SHORT(S.VAL(LONGINT,Attribs)), S.ADR(Name) ) >= 0
 END Sfirst;

PROCEDURE- Fsnext() : INTEGER 79,1;

PROCEDURE Snext* () : BOOLEAN;
 BEGIN RETURN Fsnext() >= 0
 END Snext;

PROCEDURE- Frename(New,Old : LONGINT; Res : INTEGER) : INTEGER 86,1;

PROCEDURE Rename* (Old,New : ARRAY OF CHAR) : BOOLEAN;
 BEGIN
  Error.NumStrOut( Frename( S.ADR(New), S.ADR(Old), 0), Old );
  RETURN Error.NoErr
 END Rename;

PROCEDURE- Fdatime(Mode,Handle : INTEGER; Buf : LONGINT) 87,1;

PROCEDURE Datime* (Handle : INTEGER; VAR DateTime : datime; Mode : INTEGER);
 BEGIN Fdatime( Mode, Handle, S.ADR(DateTime) );
 END Datime;

PROCEDURE Search* (Name : ARRAY OF CHAR; VAR Length : LONGINT) : BOOLEAN;
  (* searches a file, returns its length and TRUE if found *)
  VAR Ptr : dta;
 BEGIN
  Ptr := Getdta();
  IF Sfirst(Name,{rdonly}) THEN Length := Ptr^.Length; RETURN TRUE END;
  RETURN FALSE
 END Search;

PROCEDURE Load* (Name : ARRAY OF CHAR; BegSpace,EndSpace : LONGINT;
                 VAR Begad : S.PTR; VAR Length : LONGINT) : BOOLEAN;
 (* loads a file and allocates its space. BegSpace is added in front
    and EndSpace at the end of the file. The file length and the begin
    address are returned *)
  VAR Handle : INTEGER;
      Ret : BOOLEAN;
 BEGIN
  IF Search(Name,Length) THEN
    S.NEW(Begad,Length + BegSpace + EndSpace);
    IF (Begad # 0) AND Open(Name,read,Handle) THEN
      Ret := Read(Handle,Length,Begad + BegSpace);
      Close(Handle); RETURN Ret
    END(*IF*);
  END(*IF*);
  RETURN FALSE
 END Load;

PROCEDURE LoadTo* (Name : ARRAY OF CHAR; Begad : S.PTR;
                   VAR Length : LONGINT) : BOOLEAN;
  (* loads a file to the desired address and return its length *)
  VAR Handle : INTEGER;
      Ret    : BOOLEAN;
 BEGIN
  IF Open(Name,read,Handle) THEN
    Length := 0FFFFFFH; Ret := Read(Handle,Length,Begad);
    Close(Handle); RETURN Ret
  END(*IF*);
  RETURN FALSE
 END LoadTo;

PROCEDURE Save* (Name : ARRAY OF CHAR; Begad : S.PTR; Length : LONGINT)
                 : BOOLEAN;
  (* saves a file from Begad with Length *)
  VAR Handle : INTEGER;
      Ret    : BOOLEAN;
 BEGIN
  IF Create(Name,{},Handle) THEN
    Ret := Write(Handle,Length,Begad); Close(Handle); RETURN Ret
  END(*IF*);
  RETURN FALSE
 END Save;

PROCEDURE CloseAll;
 BEGIN
  IF (Task.level = 0) OR Sys.Loader & (Task.level = 1) THEN
    WHILE Files.root # NIL DO
      Close( SHORT(Files.root(Items.Item).itemId) );
    END;
  END;
 END CloseAll;

BEGIN
  NEW(Files); Files.Init;
  Setdta( S.ADR(Dta) );
  Task.StoreExit(CloseAll);
END File.
