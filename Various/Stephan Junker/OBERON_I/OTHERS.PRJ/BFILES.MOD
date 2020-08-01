MODULE BFiles; (* Buffered FilesSystem for OBERON. By Dirk Theisen *)

(* Version 0.2ž(!) *)

(*
   This is a Module to access files in a way it is done in System-OBERON.
   I only changed the interface to type-bound-procedures and so implemented
   a /simple/ emulation of the OBERON-FS.
   Behaviour may be slight different (please tell me).

   Restictions:
     Unlike System-OBERON everey file opened by "New" or "Old" MUST be
     closed at the end and may no longer be accessed after that (as in
     GEMDOS). Filenames are restricted to GEMDOS-names (8+3).
   New:
     SetPath, GetPath, Rename and Delete behave exactly like their GEMDOS-
     pendants (in fact they are).

   NOTE: This is the first public Version. The new browser makes use of it,
         but that is no garantee for it to work korrekt. Use it with care
         (but use it :-) )!

                     THIS MODULE IS IN BETA-STATE!

                   (don't tell me, You didn't know!)

*)


IMPORT
  SYSTEM, GEMDOS, FileName, Items, Error, Task, IO, Sys;


  CONST

    (* res *)
    FileNotFound*      = -33;
    FolderNotFound*    = -34;
    SetOutOfRange*     = -64;

    (* internal*)
    WrongHandle        = -37;


    (* handle *)
    Closed             = -32000;

    BufSize*           = 4096; (* should be MAX(INTEGER)>=BufSize=2^x>=4 *)


  TYPE


    Buffer  = POINTER TO BufferDesc;

    BufferDesc = RECORD
                   bpos : LONGINT;
                   len  : INTEGER;
                   data : ARRAY BufSize OF SYSTEM.BYTE;
                   dirt : BOOLEAN;
                 END;

    File*   = POINTER TO FileDesc;

    Rider*  = RECORD
                eof-  : BOOLEAN;
                res-  : LONGINT;
                bpos  : LONGINT;
                cpos  : INTEGER;
                base- : File;
              END;

    FileDesc* = RECORD
                  buffer   : BufferDesc;
                  handle   : INTEGER; (* GEMDOS-Handle *)
                  pos      : LONGINT; (* pos of last GEMDOS-access *)
                  register : BOOLEAN;
                  name-    : FileName.path;
                END;

    (* Sorry - only one buffer per file yet! *)


  VAR
    res       : INTEGER;            (* ?? *)
    res2      : LONGINT;
    b         : SYSTEM.BYTE;
    f         : File;

    (* test *)

    c         : ARRAY 150 OF CHAR;
    c1        : CHAR;
    file      : File;
    r,s       : Rider;

    i,j       : LONGINT;

    files     : Items.List;


  PROCEDURE- Fcreate(Attr : INTEGER; Name : SYSTEM.PTR) : INTEGER 60,1;

  PROCEDURE Create(Name : ARRAY OF CHAR; Attribs : SET;
                   VAR Handle : INTEGER) : BOOLEAN;
    VAR f : Items.Item;
   BEGIN
    Handle := Fcreate( SHORT(SYSTEM.VAL(LONGINT,Attribs)), SYSTEM.ADR(Name) );
    Error.NumStrOut(Handle,Name);
    IF Error.NoErr THEN NEW(f); files.AddItem(f, Handle) END;
    RETURN Error.NoErr
   END Create;


  PROCEDURE- Fopen(Mode : INTEGER; Name : SYSTEM.PTR) : INTEGER 61,1;

  PROCEDURE Open(Name : ARRAY OF CHAR; Mode : INTEGER; VAR Handle  : INTEGER)
                 : BOOLEAN;
    VAR f : Items.Item;
   BEGIN
    Handle := Fopen( Mode, SYSTEM.ADR(Name) );
    IF Handle >= 0 THEN NEW(f); files.AddItem(f, Handle) END;
    RETURN Handle >= 0;
   END Open;


  PROCEDURE- Fclose(Handle : INTEGER) : INTEGER 62,1;

  PROCEDURE Close(Handle : INTEGER);
    VAR
      f : Items.Item;
      d : INTEGER;
   BEGIN
    d := Fclose(Handle);
    files.FindAndDelete(Handle);
   END Close;

  PROCEDURE CloseAll();
   BEGIN
    IF (Task.level = 0) OR Sys.Loader & (Task.level = 1) THEN
      WHILE files.root # NIL DO
        Close( SHORT(files.root(Items.Item).itemId) );
      END;
    END;
    files.Init;
    file := NIL; f := NIL;
   END CloseAll;


  PROCEDURE SetPath*(p: ARRAY OF CHAR; VAR res : INTEGER);
  BEGIN
    res:=GEMDOS.Dsetpath(SYSTEM.ADR(p));
    (* Fehlermeldungen? *)
  END SetPath;

  PROCEDURE GetPath*(VAR p: ARRAY OF CHAR; VAR res: INTEGER);
  VAR gp: POINTER TO ARRAY 1024 OF CHAR;
  BEGIN
    res:=GEMDOS.Dgetpath(0,gp);
    COPY(gp^,p);
  END GetPath;

  PROCEDURE Delete*(name : ARRAY OF CHAR; VAR res : INTEGER);
  (* file <name> may NOT be open!! *)
  BEGIN
    res:=GEMDOS.Fdelete(SYSTEM.ADR(name));
  END Delete;


  PROCEDURE Rename*(old : ARRAY OF CHAR; new : ARRAY OF CHAR; VAR res :
INTEGER);
  BEGIN
    res:=GEMDOS.Frename(SYSTEM.ADR(new),SYSTEM.ADR(old),0);
  END Rename;


  PROCEDURE- Fdatime(Mode,Handle : INTEGER; Buf : SYSTEM.PTR) 87,1;


  PROCEDURE (f : File) TimeAndDate*() : LONGINT;	(* SJ *)
  (*
   Returns the time and date of that file. Date in the upper, time in the
   lower half.
   *)
    VAR
      li: LONGINT;
   BEGIN
    Fdatime(0, f.handle, SYSTEM.ADR(li) );
    RETURN SYSTEM.ANL(li DIV 10000H, 0FFFFH) + li * 10000H;
   END TimeAndDate;


  PROCEDURE (f : File) SetTimeAndDate*(timeDate: LONGINT); (* SJ *)
  (*
   Sets the time and date of that file. Format as above.
   *)
    VAR
      li: LONGINT;
   BEGIN
    li := SYSTEM.ANL(timeDate DIV 10000H, 0FFFFH) + timeDate * 10000H;
    Fdatime(1, f.handle, SYSTEM.ADR(li) );
   END SetTimeAndDate;


  PROCEDURE (f : File) GetDate* (VAR t : LONGINT; VAR d : LONGINT);
  BEGIN
    HALT(112); (* not implemented yet *)
  END GetDate;


  PROCEDURE Init(VAR name: ARRAY OF CHAR);
  BEGIN
    NEW(f);
    f.handle     := res;
    f.buffer.dirt:= FALSE;
    f.buffer.len := 0;
    f.pos        := 0;
    COPY(name,f.name);
  END Init;


  PROCEDURE Old*(name : ARRAY OF CHAR): File;
  BEGIN
    IF Open(name, GEMDOS.readwrite, res) THEN
      Init(name);
      f.register := TRUE;
      f.buffer.bpos:= -1;   (* invalid *)
      RETURN f;
    END(*IF*);
    RETURN NIL;
  END Old;


  PROCEDURE New*(name : ARRAY OF CHAR): File;
  BEGIN
    IF Create(name, {}, res) THEN
      Init(name);
      f.register := FALSE;
      f.buffer.bpos:=0;
      RETURN f;
    END(*IF*);
    RETURN NIL;
  END New;


  PROCEDURE (f : File) Length*(): LONGINT;
  (* return correct length of file f *)
  BEGIN
    f.pos:=GEMDOS.Fseek(2,f.handle,0);            (* request pos *)
    IF f.buffer.bpos+f.buffer.len>f.pos THEN (* buffer behind eof *)
      RETURN f.buffer.bpos+f.buffer.len;
    END(*IF*);
    RETURN f.pos;
  END Length;


(*  PROCEDURE ReOpen(f: File);
  BEGIN
    (* versuche open. Falls NOMORE handles: Close LRU File. Open. *)
    IO.WriteString("Reopen!!!");
    HALT(101);
  END ReOpen;  *)


  PROCEDURE Flush(f: File);
  BEGIN
    (* f has to be open!!! *)
    IF f.pos#f.buffer.bpos THEN
      f.pos:=GEMDOS.Fseek(0,f.handle,f.buffer.bpos);
    END(*IF*);
    res:=SHORT(GEMDOS.Fwrite(SYSTEM.ADR(f.buffer.data),f.buffer.len,f.handle));
    IF res<f.buffer.len THEN
      HALT(112);
      (* fehler auswerten *)
    END(*IF*);
    INC(f.pos,res);
    f.buffer.dirt:=FALSE;
    f.buffer.len := 0;	(* SJ *)
  END Flush;


  PROCEDURE (f : File) Close*;
  BEGIN
    IF f.buffer.dirt THEN
      Flush(f);
    END(*IF*);
    IF f.handle#Closed THEN
      Close(f.handle);
      f.handle:=Closed;
    END(*IF*);
    (* GEMDOS file is now closed *)
    IF ~f.register THEN
      Delete(f.name,res);
    END(*IF*);
  END Close;


  PROCEDURE (VAR f : File) Purge*;
  (* deletes an open file, without closing it (hope this is intended) *)
  BEGIN
    f.register:=FALSE;
    f.Close;
    f:=New(f.name);
  END Purge;


  PROCEDURE ReadBuff(f: File);
  (* buffer is filled at actual filepos *)
  BEGIN
    res:=SHORT(GEMDOS.Fread(SYSTEM.ADR(f.buffer.data[0]),BufSize,f.handle));
    IF res>=0 THEN
      INC(f.pos,res);
      f.buffer.len:=res;
      RETURN;
    END(*IF*);
    (* error handling? *)
    IO.WriteString("BFiles: GEMDOS Error while Reading Buffer: ");
    IO.WriteInt(res);
  END ReadBuff;


  PROCEDURE Validate(VAR r : Rider);
  (* loads buffer with (max) BufSize Bytes starting at r.bpos *)
  BEGIN
    f:=r.base;
    IF f.buffer.dirt THEN (* flush old one *)
      Flush(f);
    END(*IF*);
    IF f.pos#r.bpos THEN (* file at wrong position *)
      f.pos:=GEMDOS.Fseek(0,f.handle,r.bpos);
      IF f.pos#r.bpos THEN (* Error *)
        IO.WriteString("BFiles.Validate: Error seeking buffer. Abort");
        r.res:=f.pos;
        HALT(112);
      END(*IF*);
    END(*IF*);
    f.buffer.bpos:=r.bpos; (* buffer gets invalid *)
    ReadBuff(f);
  END Validate;


  PROCEDURE (f : File) Register*;
  BEGIN
    IF f.buffer.dirt THEN (* flush old one *)
      Flush(f);
    END(*IF*);
    f.register:=TRUE;
    (* f.Close; ??? *)
  END Register;


  PROCEDURE (VAR r : Rider) Set* (f : File; pos : LONGINT);
  (* must be called before 1st read/write! *)
    VAR
      bpos: LONGINT;
      bptr: Buffer;
  BEGIN
    r.cpos:=SHORT(pos MOD BufSize);
    r.bpos:=pos-r.cpos;
    r.base:=f;
    r.res :=0;
    IF f # NIL THEN (* SJ *)
      IF (f.buffer.bpos#r.bpos) THEN (* buffer invalid *)
        (*IO.WriteString("Buffer invalid. ");*)
        IF f.buffer.dirt THEN (* flush dirty buffer *)
          Flush(f);
        END(*IF*);
        (* position file *)
        IF f.pos#r.bpos THEN (* reposition *)
          f.pos:=GEMDOS.Fseek(0,f.handle,r.bpos); (* search position *)
          IF f.pos#r.bpos THEN (* Error *)
            r.res:=f.pos;
            IF f.pos=SetOutOfRange THEN (* set file to last bufferpos *)
              f.pos:=GEMDOS.Fseek(1,f.handle,0); (* where are we? *)
              IO.WriteString("(!)");(* Warning: File set past EOF:");
              IO.WriteInt(pos);
              IO.WriteString(" EOF is ");
              IO.WriteInt(f.pos);*)
              (* recalc rider position *)
              r.cpos:=SHORT(f.pos MOD BufSize);
              r.bpos:=f.pos-r.cpos;
              IF r.bpos=f.buffer.bpos THEN (* buffer already there *)
                r.eof:=(r.cpos>=f.buffer.len);
                RETURN;
              END(*IF*);
              f.pos:=GEMDOS.Fseek(1,f.handle,-r.cpos); (* go back to last buffer pos *)
            ELSE
              IO.WriteString("(!)Error ");
              IO.WriteInt(r.res);
              HALT(112);
            END(*IF*);
          END(*IF*);
        END(*IF*);
        f.buffer.bpos:=r.bpos; (* old buffer gets invalid *)
        ReadBuff(f);
      END(*IF*);
      r.eof:=(r.cpos>=f.buffer.len); (* cpos behind buffer.len *)
      IF r.eof THEN (* set to/behind EOF *)
          r.cpos:=f.buffer.len;
      END(*IF*);
    END;
  END Set;


  PROCEDURE (VAR r : Rider) Read* (VAR x : SYSTEM.BYTE);
  BEGIN
    (* inv: r.bpos+r.cpos to be read *)
    f:=r.base;
    IF f.buffer.bpos#r.bpos THEN (* buffer invalid *)
      Validate(r);
    END(*IF*);
    (* x can be retrieved from r.buf: *)
    x:=f.buffer.data[r.cpos];
    INC(r.cpos);
    IF r.cpos >= f.buffer.len THEN (* buffer full *)
      IF r.cpos>=BufSize THEN
        (* next Buffer *)
        r.cpos:=0;
        INC(r.bpos,BufSize);
        Validate(r);
      ELSE
        r.eof:=TRUE;
        DEC(r.cpos);
      END(*IF*);
    END(*IF*);
  END Read;


  PROCEDURE (VAR r : Rider) Write*(x : SYSTEM.BYTE);
  BEGIN
    (* inv: r.bpos+r.cpos to be written *)
    f:=r.base;
    IF f.buffer.bpos#r.bpos THEN (* buffer invalid *)
      Validate(r);
    END(*IF*);
    (* x can be put to r.buf: *)
    f.buffer.data[r.cpos]:=x;
    f.buffer.dirt:=TRUE;
    INC(r.cpos);
    IF r.cpos>=f.buffer.len THEN
      f.buffer.len:=r.cpos; (* enlarge buffer by one *)
      IF r.cpos>=BufSize THEN (* buffer end reached *)
        r.cpos:=0;
        INC(r.bpos,BufSize);  (* set Rider to next buffer *)
      END(*IF*);
    END(*IF*);
  END Write;


  PROCEDURE (VAR r : Rider) ReadBytes*(VAR x : ARRAY OF SYSTEM.BYTE; n :
LONGINT);
  VAR
    do    : INTEGER;
    where : SYSTEM.PTR;
  BEGIN
    (*   b     := x[n-1]; (* for Range-Check! *) *)
    f     := r.base;
    IF f.buffer.bpos#r.bpos THEN (* buffer invalid *)
      Validate(r);
    END(*IF*);
    do    := f.buffer.len-r.cpos; (* remaining space in the buffer *)
    IF n<=do THEN (* easy, n fits in buffer *)
      SYSTEM.MOVE(SYSTEM.ADR(f.buffer.data[r.cpos]),SYSTEM.ADR(x),n);
      INC(r.cpos,SHORT(n));
    ELSE (* n to large for this buffer *)
      (* copy to end of buffer/file *)
      SYSTEM.MOVE(SYSTEM.ADR(f.buffer.data[r.cpos]),SYSTEM.ADR(x),do);
      INC(r.bpos,BufSize);
      DEC(n,do); (* do is done *)
      where:=SYSTEM.ADR(x)+LONG( do); (* adjust source-adr *)
      do:=SHORT(n MOD BufSize);
      IF n>BufSize THEN
        DEC(n,do);
        (* copy n=(x*BufSize) via GEMDOS *)
        IF f.pos#r.bpos THEN
          f.pos:=GEMDOS.Fseek(0,f.handle,r.bpos)+n;
        END(*IF*);
        res2:=GEMDOS.Fread(where,n,f.handle);
        IF res2<n THEN
          IF res2>0 THEN
            INC(f.pos,res2);
            res2:=(res2 DIV BufSize)*BufSize;
          ELSE
            r.res:=res2;
          END(*IF*);
        END(*IF*);
        INC(r.bpos,res2);
        INC(where,res2);
      END(*IF*);
      ReadBuff(f);
      IF f.buffer.len<do THEN
        do:=f.buffer.len;
      END(*IF*);
      SYSTEM.MOVE(SYSTEM.ADR(f.buffer.data[0]),where,do);
      r.cpos:=do;
    END(*IF*);
  END ReadBytes;


  PROCEDURE (VAR r : Rider) WriteBytes*(VAR x : ARRAY OF SYSTEM.BYTE; n :
LONGINT);
  VAR
    do    : INTEGER;
    where : SYSTEM.PTR;
  BEGIN
    f  := r.base;
    IF f.buffer.bpos#r.bpos THEN (* buffer invalid *)
      Validate(r);
    END(*IF*);
    do := BufSize-r.cpos; (* remaining space in the buffer *)
    IF n<do THEN (* easy, n fits in buffer *)
      SYSTEM.MOVE(SYSTEM.ADR(x),SYSTEM.ADR(f.buffer.data[r.cpos]),n);
      INC(r.cpos,SHORT(n));
    ELSE (* n to large for this buffer *)
      (* copy to end of buffer/file *)
      SYSTEM.MOVE(SYSTEM.ADR(x),SYSTEM.ADR(f.buffer.data[r.cpos]),do);
      f.buffer.len := BufSize; (* buffer has been filled *)
      Flush(f);
      DEC(n,do); (* do is done *)
      INC(r.bpos,BufSize);
      where := SYSTEM.ADR(x)+LONG(do); (* adjust source-adr *)
      do    := SHORT(n MOD BufSize);
      IF n>BufSize THEN
        DEC(n,do);
        (* copy n=(x*BufSize) via GEMDOS *)
        res2:=GEMDOS.Fwrite(where,n,f.handle);
        IF res2=n THEN
          INC(r.bpos,n);
          INC(where,n);
          INC(f.pos,n);
        ELSE
          r.res:=SHORT(res2);
          HALT(112);
        END(*IF*);
      END(*IF*);
      f.buffer.bpos := r.bpos;
      IF ~r.eof THEN  (* not tested! *)
        ReadBuff(f);
      END(*IF*);
      SYSTEM.MOVE(where,SYSTEM.ADR(f.buffer.data[0]),do);
      r.cpos:=do;
    END(*IF*);
    IF f.buffer.len<r.cpos THEN
      f.buffer.len:=r.cpos;
      r.eof:=TRUE;
    END(*IF*);
    f.buffer.dirt:=TRUE;
  END WriteBytes;


  PROCEDURE (VAR r : Rider) Pos*(): LONGINT;
  BEGIN
    RETURN r.bpos+r.cpos;
  END Pos;


BEGIN
  NEW(files); files.Init;
  Task.StoreExit(CloseAll);
END BFiles.