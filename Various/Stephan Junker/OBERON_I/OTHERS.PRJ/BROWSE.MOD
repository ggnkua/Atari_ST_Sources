MODULE Browse; (* by dirk_theisen@su.maus.de *)
               (*  Version 1.10ž vom 8.2.94  *)


  (* Version     History

      1.03 New behaviour:
           IF Commandline THEN browse writes the DEF-file to the given path
           ELSIF to the first entry of env. var. DEFPATH
           ELSE  to path of SYM-file
      1.04 New format on records with TBPs.
           Bug in export mark detected.
           Sequences of parameters of the same type in parameter lists will
           now be denoted as enumeration. e.g. a,b,c: Type .
      1.05 Adapted to MODULE BFiles. => No max. file lenght etc.
           Option -h now valid. It produces links for the help-system 1stGuide
           within the text to branch to defs of imported Modules etc.
           Extension is no longer DEX, but DEF (sigh!). Use option "-o" to
           overwrite old DEF.
      1.06 Bug PROCEDURE (VAR a: MyType) MyProc (VAR b: MyType); fixed.
      1.07 First version with comment-scanning (-c)
      1.08 Switch-scanning enhanced: >browse -coh <ModName> now possible.
      1.09 Parameter-scanning now in Module CommandLine. Bugs in comment
           scanning killed.
      1.10 Mod-scanning simplified. Has to be improved. Too many passes.


  Known Bugs:

    IDs with an export-mark occuring within a quoted string may be interpreted if
    comment scanning is on. Avoid this.

  *)




IMPORT
  Sym:=OCSymbol, Import:=OCImport, Par:=OCPar, Expr:=OCExpr, Filename,
  Files:=BFiles, IO, Sys, CommandLine, Paths, Task;



CONST

  Procedure  = "PROCEDURE ";
  CR         = 0DX;
  LF         = 0AX;

  DefaultInd = 2;

TYPE

  MyRider    = RECORD (Files.Rider)
               END;

  Name       = ARRAY 128 OF CHAR;
  OutputProc = PROCEDURE (o: Sym.Symbol; indent, idLen : SHORTINT);

VAR

  blank      : ARRAY 70 OF CHAR;

  defPath    : Paths.path;
  fileName,
  modName,
  self       : Name;
  defFile    : Files.File;
  modFile    : Files.File;
  def        : MyRider;
  mod        : Files.Rider;
  lastID     : LONGINT;
  yepTBP     : BOOLEAN;

  ind        : SHORTINT; (* Indent *)
  top        : Sym.Symbol;
  hyper      : BOOLEAN;
  comments   : BOOLEAN;
  overwrite  : BOOLEAN;
  error      : BOOLEAN;

  (* Hilfsvars *)
  i          : SHORTINT;
(*  c          : CHAR; *)


  PROCEDURE Len(VAR s: ARRAY OF CHAR): INTEGER;
    VAR i: INTEGER;
  BEGIN
    i:=0;
    WHILE s[i]#0X DO INC(i); END(*WHILE*);
    RETURN i;
  END Len;

  PROCEDURE Leni(i: LONGINT): SHORTINT;
  VAR l : SHORTINT;
  BEGIN
    l:=0;
    WHILE i>0 DO
      i:=i DIV 10;
      INC(l);
    END(*WHILE*);
    RETURN l;
  END Leni;

  PROCEDURE (VAR r: MyRider) WriteInt(i:LONGINT);

    PROCEDURE Int(i:LONGINT);
    (* i>=0!!! *)
    BEGIN
      IF i>9 THEN
        Int(i DIV 10);
      END(*IF*);
      r.Write(CHR((i MOD 10)+48));
    END Int;

  BEGIN
    IF i>=0 THEN
      Int(i);
    ELSE
      r.Write("-");
      Int(-i);
    END(*IF*);
  END WriteInt;


  PROCEDURE (VAR r: MyRider) WriteString(s: ARRAY OF CHAR);
    VAR l : INTEGER;
  BEGIN
    r.WriteBytes(s,Len(s));
  END WriteString;


  PROCEDURE (VAR r: MyRider) WriteModule(s: ARRAY OF CHAR);
  BEGIN
    IF hyper THEN
      def.Write("Ý");
      def.WriteString(s); (* "Module." *)
      def.Write("Ý");
      s[8]:=0X;
      def.WriteString(s);
      def.WriteString(".def");
      def.Write("Ý");
    ELSE
      def.WriteString(s); (* "Module." *)
    END(*IF*);
  END WriteModule;


  PROCEDURE (VAR r: MyRider) WriteLn;
  BEGIN
    r.Write(CR);
    r.Write(LF);
  END WriteLn;

  PROCEDURE (VAR r: MyRider) Indent(i: SHORTINT);
  BEGIN
    r.WriteBytes(blank,i);
  END Indent;


  PROCEDURE ScanComment;
  VAR c: CHAR;
  BEGIN
    mod.Read(c);
    WHILE ~mod.eof DO
      IF c="(" THEN
        mod.Read(c);
        IF c="*" THEN
          ScanComment;
        END(*IF*);
      ELSIF c="*" THEN
        mod.Read(c);
        IF c=")" THEN
          RETURN;
        END(*IF*);
      ELSE
        mod.Read(c);
      END(*IF*);
    END(*WHILE*);
  END ScanComment;


  PROCEDURE Found(VAR s:ARRAY OF CHAR; id: BOOLEAN): BOOLEAN;
    VAR
      loops  : SHORTINT;
      len    : SHORTINT;
      i      : SHORTINT;
      c      : CHAR;



    PROCEDURE ScanBracket;
    BEGIN
      mod.Read(c);
      IF c="*" THEN
        ScanComment;
      ELSIF c="(" THEN
        ScanBracket;
      ELSIF c=")" THEN
        RETURN;
      ELSE
        WHILE ~mod.eof DO
          mod.Read(c);
          IF c="(" THEN
            ScanBracket;
          ELSIF c=")" THEN
            RETURN;
          END(*IF*);
        END(*WHILE*);
      END(*IF*);
    END ScanBracket;


  BEGIN
    loops := 0;
    i     := 0;
    len   := SHORT(Len(s));
    REPEAT
      WHILE ~mod.eof DO
        mod.Read(c);
(*        IO.WriteChar(c);*)
        IF s[i]=c THEN
          INC(i);
          IF i>=len THEN
            IF ~id THEN
              RETURN TRUE;
            END(*IF*);
            mod.Read(c);
            IF (c="*") OR (c="-") THEN
              RETURN TRUE;
            END(*IF*);
            i:=0;
          END(*IF*);
        ELSE
          IF c="(" THEN
            ScanBracket;
          END(*IF*);
          i:=0;
        END(*IF*);
      END(*WHILE*);
      INC(loops);
      mod.Set(modFile,0);
      IO.WriteChar(".");
    UNTIL loops>=2;
    IO.WriteLn;
    IO.WriteString(s);
    IO.WriteString(" NICHT gefunden!");
    RETURN FALSE;
  END Found;

  PROCEDURE FoundID(VAR s: ARRAY OF CHAR):BOOLEAN;
  BEGIN
(*      IO.WriteLn;
      IO.WriteString("Scanne nach ");
      IO.WriteString(s); *)
      RETURN Found(s,TRUE);
  END FoundID;

  PROCEDURE CopyComments(ind:SHORTINT);
  VAR
    c      : CHAR;
    start  : LONGINT;
    stop   : LONGINT;
    i      : INTEGER;

  BEGIN
    start := mod.Pos();
    stop  := 0;
    WHILE ~mod.eof DO
      mod.Read(c);
      IF c="(" THEN
        mod.Read(c);
        IF c="*" THEN
          ScanComment;
          stop:=mod.Pos();
        END(*IF*);
      ELSIF c>" " THEN
        IF stop>0 THEN
          mod.Set(modFile,start);
          i:=SHORT(stop-start);
          WHILE i>0 DO
            mod.Read(c);
            def.Write(c);
            IF c=LF THEN
              def.Indent(ind);
            END(*IF*);
            DEC(i);
          END(*WHILE*);
        END(*IF*);
        RETURN
      END(*IF*);
    END(*WHILE*);
  END CopyComments;


  PROCEDURE ScanUntil(s: ARRAY OF CHAR);
  BEGIN
    IF Found(s,FALSE) THEN END;
  END ScanUntil;



                          (* the browser *)


  PROCEDURE WriteID(o:Sym.Symbol; idl: SHORTINT);
  BEGIN
    def.WriteString(o.name);
    CASE o.mark OF
      Sym.ReadOnly : def.Write("-");
    | Sym.Export   : def.Write("*");
    ELSE IF idl>0 THEN def.Write(" "); END(*IF*);
    END(*CASE*);
    IF idl>0 THEN
      def.Indent(idl-SHORT(Len(o.name)));
    END(*IF*);
  END WriteID;


  PROCEDURE^ WriteType(t: Sym.Struct; i: SHORTINT; name: BOOLEAN);

  PROCEDURE WriteVar(VAR v: Sym.Symbol; multi: BOOLEAN; i, idl: SHORTINT);
  BEGIN
    WriteID(v,idl);
    IF idl=0 THEN (* write sequence of IDs of same type *)
      WHILE multi & (v.next#NIL) & (v.next.typ=v.typ) & (v.form=v.next.form) DO
        v:=v.next;
        def.WriteString(", ");
        WriteID(v,0);
      END(*WHILE*);
    END(*IF*);
    def.WriteString(": ");
    WriteType(v.typ,i+idl+3,TRUE);
  END WriteVar;


  PROCEDURE WritePar(VAR p:Sym.Symbol);
  BEGIN
    IF p.form=Sym.Ind THEN
      def.WriteString("VAR ");
    END(*IF*);
    WriteVar(p,FALSE,i,0);
  END WritePar;


  PROCEDURE WritePars(p: Sym.Symbol);
  (* p points to first Parameter *)

  BEGIN
    p := p.next;
    def.Write("(");
    IF (p # NIL) & (p.form # Sym.Sep) THEN (* parameter *)
      WritePar(p);
      p:=p.next;
      WHILE (p # NIL) & (p.form # Sym.Sep) DO
        def.WriteString("; ");
        IF p.form=Sym.Ind THEN
          def.WriteString("VAR ");
        END(*IF*);
        WriteVar(p,TRUE,i,0);
        p:=p.next;
       END(*WHILE*);
    END(*IF*);
    def.Write(")");
  END WritePars;


  PROCEDURE WriteResult(r: Sym.Struct);
  BEGIN
    IF (r.form # Sym.NoTyp) THEN
      def.WriteString(": ");
      WriteType(r,0,TRUE);
    END(*IF*);
  END WriteResult;


  PROCEDURE WriteProcType(p:Sym.Struct);
  (* p is type of an proc-object *)
  BEGIN
    def.WriteString(Procedure);
    WritePars(p.syms);
    WriteResult(p.base);
(*    def.Write(';'); *)
  END WriteProcType;


  PROCEDURE OutTBP(o:Sym.Symbol;i: SHORTINT);
  (* p is type of an proc-object *)
    VAR
      p : Sym.Struct;
  BEGIN
    yepTBP:=TRUE;
    p:=o.typ;
    def.WriteLn;
    def.Indent(i);
    def.WriteString(Procedure);
    def.Write("(");
    WritePar(p.syms.next);
    def.WriteString(") ");
    WriteID(o,0);
    WritePars(p.syms.next);
    WriteResult(p.base);
    def.Write(";");
    IF comments & FoundID(o.name) THEN
(*      ScanUntil(')'); *)
      ScanUntil(';');
      CopyComments(i-ind);
    END(*IF*);
  END OutTBP;


  PROCEDURE OutProc(p: Sym.Symbol; i,idl: SHORTINT);
  BEGIN
    def.WriteLn;
    def.Indent(ind);
    def.WriteString(Procedure);
    WriteID(p,0);
    WritePars(p.syms);
    WriteResult(p.typ);
    def.Write(";");
    IF comments & FoundID(p.name) THEN
(*      ScanUntil(')'); *)
      ScanUntil(';');
      CopyComments(0);
    END(*IF*);
  END OutProc;


  PROCEDURE OutVar(v: Sym.Symbol; i, idl: SHORTINT);
  BEGIN
    def.WriteLn;
    def.Indent(i);
    WriteVar(v,FALSE,i,idl);
    def.Write(";");
    IF comments & FoundID(v.name) THEN
      ScanUntil(';');
      CopyComments(0);
    END(*IF*);
  END OutVar;


  PROCEDURE WriteRecordType(t: Sym.Struct; i:SHORTINT);
    VAR
      u      : Sym.Symbol;
      idl, l : SHORTINT;
  BEGIN
    def.WriteString("RECORD");
    (* maybe extended record *)
    IF t.base # NIL THEN
      def.Write("(");
      WriteType(t.base,i,TRUE);
      def.Write(")");
    END(*IF*);
    u:=t.syms.next;
    IF comments THEN CopyComments(ind); END(*IF*);
    (* set longest idl *)
    idl:=0;
    WHILE (u # NIL) DO
      l:=SHORT(Len(u.name)+1); IF (l>idl) & (u.form#Sym.Tbp) THEN idl:=l; END(*IF*);
      u:=u.next;
    END(*WHILE*);
    u:=t.syms.next;
    WHILE (u # NIL) DO
      IF u.name[0]#0X THEN
        IF (u.form=Sym.Tbp) THEN
          OutTBP(u,i+ind);
        ELSE
          OutVar(u,i+ind,idl);
        END(*IF*);
      END(*IF*);
      u:=u.next;
    END(*WHILE*);
    def.WriteLn;
    def.Indent(i);
    def.WriteString("END");
  END WriteRecordType;


  PROCEDURE WriteType(t: Sym.Struct; i: SHORTINT; name: BOOLEAN);
  VAR
    u  : Sym.Symbol;
    mod: Sym.Symbol;
    mnr: INTEGER;

    PROCEDURE Find(VAR u: Sym.Symbol);
    BEGIN
      WHILE (u#NIL) & ((u.typ#t) OR (u.form#Sym.Typ)) DO
        u:=u.next;
      END(*WHILE*);
    END Find;

  BEGIN
    u  :=NIL;
    mnr:=0;
    IF name THEN
      NEW(mod);
      mod.name:="SYSTEM";
      u  :=Sym.system;
      Find(u);
      IF u=NIL THEN
        mod:=Import.glbmod[0];
        u:=mod.syms;
        Find(u);
      END(*IF*);
      WHILE (mnr<Import.nofgmod) & (u=NIL) DO
        mod:=Import.glbmod[mnr];
        u  :=mod.syms;
        Find(u);
        INC(mnr);
      END(*WHILE*);
    END(*IF*);
    IF u#NIL THEN
      IF mod#Import.glbmod[0] THEN (* extern module *)
        def.WriteModule(mod.name);
        def.Write(".");
      END(*IF*);
      def.WriteString(u.name);     (* "Type"    *)
    ELSE
      (* write Type *)
      CASE t.form OF
        Sym.Pointer  : def.WriteString("POINTER TO ");  WriteType(t.base,i+11,TRUE);
       |Sym.DynArr   : def.WriteString("ARRAY OF "); WriteType(t.base,i+9,TRUE);
       |Sym.Array    : def.WriteString("ARRAY ");
                       def.WriteInt(t.n);
                       def.WriteString(" OF ");
                       WriteType(t.base,i+Leni(t.n)+10,TRUE);
       |Sym.ProcTyp  : WriteProcType(t);
       |Sym.Record   : WriteRecordType(t,i);
      ELSE
        def.WriteString(" !!!UNKNOWN!!! : ");def.WriteInt(t.form);
      END(*CASE*);
    END(*IF*);
  END WriteType;

  PROCEDURE OutTyp(t: Sym.Symbol; i, idl: SHORTINT);
  BEGIN
    def.WriteLn;
    def.Indent(i);
    WriteID(t,idl);
    def.WriteString("= ");
(*    IO.WriteString("Typ ");
    IO.WriteString(t.name); *)
    IF comments & FoundID(t.name) THEN
      IF t.typ.form=Sym.Record THEN
        yepTBP:=FALSE;
        ScanUntil("RECORD");
        WriteType(t.typ,i+idl+3,FALSE);
        def.Write(";");
        mod.Set(modFile,0); (* could have been TBPs in record *)
        IF yepTBP & FoundID(t.name) THEN END;
        ScanUntil("END");
        ScanUntil(';');
        CopyComments(i-ind);
      ELSE
        ScanUntil(';');
        WriteType(t.typ,i+idl+3,FALSE);
        def.Write(";");
        CopyComments(i+idl);
      END(*IF*);
(*      IO.WriteString(" gefunden!"); *)
    ELSE
      WriteType(t.typ,i+idl+3,FALSE);
      def.Write(";");
    END(*IF*);
(*    IO.WriteLn; *)
  END OutTyp;

  PROCEDURE OutCon(c: Sym.Symbol; i,idl: SHORTINT);
  BEGIN
    def.WriteLn;
    def.Indent(i);
    WriteID(c,idl);
    def.WriteString("= ");
    def.WriteInt(c.a0);
    def.Write(";");
(*    IO.WriteString(c.name); *)
    IF comments & FoundID(c.name) THEN
      ScanUntil('=');
      ScanUntil(';');
(*      IO.WriteString(" gefunden!"); *)
      CopyComments(0);
    END(*IF*);
(*    IO.WriteLn; *)
  END OutCon;

  PROCEDURE OutClass(o: Sym.Symbol; name: ARRAY OF CHAR; ctyp: INTEGER; out : OutputProc);
    (* writes one class of objects (eg. TYPEs) *)
    VAR
      idl    : SHORTINT;

    PROCEDURE Setidl(o: Sym.Symbol);
      VAR
        i : SHORTINT;
    BEGIN
      WHILE (o # NIL) DO
        IF o.form=ctyp THEN
          i:=SHORT(Len(o.name)); IF i>idl THEN idl:=i; END(*IF*);
        END(*IF*);
        o:=o.next;
      END(*WHILE*);
    END Setidl;

  BEGIN
    idl:=0;
    Setidl(o);
    IF idl>0 THEN (* exists an id of type ctyp *)
      INC(idl); (* for export-mark! *)
      IF name[0]#0X THEN
        def.WriteLn;
        def.WriteLn;
        def.Indent(ind);
        def.WriteString(name);
      END(*IF*);
      def.WriteLn;
      WHILE (o # NIL) DO
        IF o.form=ctyp THEN
          out(o,ind*2,idl);
        END(*IF*);
        o:=o.next;
      END(*WHILE*);
    END(*IF*);
  END OutClass;

  PROCEDURE Error(message: ARRAY OF CHAR);
  BEGIN
    error:=TRUE;
    IO.WriteString(message);
    IO.WriteLn;
  END Error;


  PROCEDURE GetSwitch(switch: CHAR; f: ARRAY OF CHAR): BOOLEAN;
  BEGIN
(*    IO.WriteString(" switch=");
    IO.WriteChar(switch); *)
    IF switch#0X THEN
      CASE CAP(switch) OF
         "H" : hyper    :=TRUE;
               IO.WriteString("Including hyper-text information.");
               IO.WriteLn;
       | "C" : comments :=TRUE;
               IO.WriteString("Including comments.");
               IO.WriteLn;
       | "O" : overwrite:=TRUE;
       | "I" : IF (f[0]<="9")&(f[0]>="0") THEN
                 ind:=SHORT(ORD(f[0])-ORD("0"));
                 RETURN TRUE;
               END(*IF*);
      ELSE
        Error("WARNING : Unknown option detected.");
        IO.WriteChar(switch);
      END(*CASE*);
      RETURN FALSE; (* nothing of f consumed *)
    ELSE
      IF fileName="" THEN
        (* 1st file is SYM-File *)
        COPY(f,fileName);
      ELSE
        (* 2nd filename is defPath (DEF-file) *)
        NEW(defPath);
        COPY(f,defPath.Path);
      END(*IF*);
      RETURN TRUE;
    END(*IF*);
  END GetSwitch;


PROCEDURE Exit;
 BEGIN
  Import.Exit; Expr.Exit; Par.Exit; Sym.Exit;
 END Exit;


PROCEDURE Init;
 BEGIN
  Sym.Init; Par.Init; Par.ReadPaths; Expr.Init; Import.Init;
 END Init;


PROCEDURE Run*;
  VAR
    modFileName: Filename.path;
    syms : Sym.Symbol;
 BEGIN

  (* this are the default options *)

  ind      := DefaultInd;
  hyper    := FALSE;
  comments := FALSE;
  overwrite:= FALSE;

  (* prepare *)

  Init;
  self      := 'Y';
  fileName  := "";
  defPath   := NIL;
  defFile   := NIL;
  modFile   := NIL;
  blank     := "                                                          ";

  IO.WriteString("Oberon browser V1.12ž (c) Dirk Theisen (SJ)");
  IO.WriteLn;

  (* Auswertung der Kommandozeile *)

  CommandLine.Evaluate(GetSwitch);

(*  fileName:="commandl";
  overwrite:=TRUE;
  comments :=TRUE;      *)

  IF fileName="" THEN
    Error("ERROR   : Name of symbol file missing!");
  ELSE
    modName := "@"; (* replaced by Import *)
    Filename.SetExt("SYM",fileName);
    Import.Import(fileName, modName, FALSE);
    IF Import.glbmod[0] # NIL THEN
      syms := Import.SymList( Import.glbmod[0]);
      IF comments THEN (* open modFile *)
        COPY(fileName, modFileName);
        Filename.SetExt("MOD",modFileName);
        IF Paths.Get(Par.ModPaths, modFileName, {}, modFileName) THEN
          modFile:=Files.Old(modFileName);
          IF modFile#NIL THEN mod.Set(modFile,0) END;
        END;
        IF modFile = NIL THEN
          Error("ERROR   : Could NOT open MOD-File. Scanning disabled.");
          error    := FALSE;
          comments := FALSE;
        END(*IF*);
      END(*IF*);
      Filename.SetExt("DEF",fileName);
      IF defPath = NIL THEN
        Paths.Read("DEFPATH=",defPath);
      END(*IF*);
      IF defPath # NIL THEN
        Filename.SetPath(defPath.Path,fileName);
      ELSE
        IF hyper THEN
          IO.WriteString("WARNING : All hypertext defs must be in the same folder!");
          IO.WriteLn;
        END(*IF*);
      END(*IF*);
      defFile:=Files.Old(fileName);

      IF defFile=NIL THEN
        defFile:=Files.New(fileName);
      ELSE
        IF overwrite THEN
          defFile.Close;
          defFile:=Files.New(fileName);
        ELSE
          Error("ERROR   : DEF-file already exists. Use -o to overwrite.");
          defFile.Close;
          defFile:=NIL;
        END(*IF*);
      END(*IF*);
      IF defFile#NIL THEN
        defFile.Register;
        def.Set(defFile,0);
        IO.WriteString("Writing   ");
        IO.WriteString(fileName);
        IO.WriteChar(".");
        top:=Import.glbmod[0];

        def.WriteString("DEFINITION ");
        def.WriteString(top.name);
        def.Write(";");
        IF comments THEN
          ScanUntil(';');
          CopyComments(0);
        END(*IF*);
        (* import list *)
        IF Import.nofgmod>1 THEN
          def.WriteLn;
          def.WriteLn;
          def.WriteString("IMPORT ");
          i:=SHORT(Import.nofgmod-1);
          WHILE i>1 DO
            def.WriteModule(Import.glbmod[i].name);
            def.WriteString(", ");
            DEC(i);
          END(*WHILE*);
          def.WriteModule(Import.glbmod[1].name);
          def.Write(";");
        END(*IF*);
        IF comments THEN
          ScanUntil("IMPORT");
          ScanUntil(';');
          CopyComments(0);
        END(*IF*);        (* module found *)

        OutClass(syms,"CONST",Sym.Con  ,OutCon);
        OutClass(syms,"TYPE" ,Sym.Typ  ,OutTyp);
        OutClass(syms,"VAR"  ,Sym.Var  ,OutVar);
        OutClass(syms,""     ,Sym.CProc,OutProc);
        OutClass(syms,""     ,Sym.LProc,OutProc);

        def.WriteLn;
        def.WriteLn;
        def.WriteString("END ");
        def.WriteString(top.name);
        def.Write(".");
        def.WriteLn;
        defFile.Close;
        IO.WriteString(" Done.");
        IO.WriteLn;
      ELSE
        Error("ERROR   : Could NOT open DEF-file for writing.");
      END(*IF*);
      IF comments THEN modFile.Close END(*IF*);
    ELSE
      Error("ERROR   : Could NOT load SYM-File.");
    END(*IF*);
  END(*IF*);

  IF error THEN
    Error("Usage   : browse [-hoci<0-9>] <SYM-filename> [<output path>]");
  END(*IF*);

  Exit;
 END Run;


BEGIN
  IF ~Sys.Loader THEN (* if running as stand alone program *)
    Run;
    Task.Exit(0); (* needed for clean up; will not return *)
  END;
END Browse.


