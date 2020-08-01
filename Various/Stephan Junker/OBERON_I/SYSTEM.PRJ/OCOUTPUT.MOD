MODULE OCOutput; (* SJ 1.10.94 *)

(*
 Provides a way to output ascii code onto a file or IO.
 *)


IMPORT
  S:=SYSTEM, Par:=OCPar, IO, Files:=BFiles, FN:=Filename, NumStr, Strings;



CONST
  left* = 0; right* = 1; center* = 2; noadj* = 3; leftadd* = 4; rightadd* = 5;

  DataSize = 20;



TYPE
  Rider* = RECORD(Files.Rider)
  END;
  RiderPtr* = POINTER TO Rider;

  Data* = POINTER TO DataDesc;
  DataDesc = RECORD
    next: Data;
    pos : INTEGER;
    data: ARRAY DataSize OF SHORTINT;
  END;

  CodeRider* = POINTER TO CodeRiderDesc;
  CodeRiderDesc = RECORD
    data, curr : Data;
    reloc  : CodeRider;
    lastrel, size: LONGINT;
  END;


VAR
  col, fileno: INTEGER;
  out   : Files.Rider;
  files : ARRAY 10 OF Files.File;
  pos   : ARRAY 10 OF LONGINT;
  name  : FN.path;



PROCEDURE CheckCol(i: INTEGER);
 BEGIN
  IF col+i >= 70 THEN
    IO.WriteLn; col := i;
  ELSE
    INC(col, i+1); IO.WriteChar( " ");
  END;
 END CheckCol;


PROCEDURE Close*;
 BEGIN
  IF col # 0 THEN IO.WriteLn END;
 END Close;


PROCEDURE (VAR r: Rider) Write*(x: S.BYTE);
 BEGIN
  IF Par.debug THEN
    CheckCol(2);
    IO.WriteFInt(S.VAL(SHORTINT, x), 16, right, 2, "0");
  ELSE
    r.Write^(x);
  END;
 END Write;


PROCEDURE(VAR r : Rider) WriteId*(VAR id : ARRAY OF CHAR);
  VAR
    i : INTEGER;
 BEGIN
  IF Par.debug THEN
    CheckCol(15);	(* estimated length *)
    IO.WriteString(id);
  ELSE
    i := 0;
    WHILE (id[i] # 0X) AND (i < LEN(id)) DO
      r.Write^(id[i]); INC(i)
    END;
    r.Write^(0);
  END;
 END WriteId;


PROCEDURE(VAR r : Rider) WriteInt*(val : INTEGER);
 BEGIN
  IF Par.debug THEN
    CheckCol(4);
    IO.WriteFInt(val, 16, right, 4, "0");
  ELSE
    r.Write^( SHORT(val DIV 256) );
    r.Write^( SHORT(val MOD 256) );
  END;
 END WriteInt;


PROCEDURE(VAR r : Rider) WriteLInt*(val : LONGINT);
 BEGIN
  IF Par.debug THEN
    CheckCol(8);
    IO.WriteFInt(val, 16, right, 8, "0");
  ELSE
    r.WriteInt( SHORT(val DIV 10000H) );
    r.WriteInt( SHORT(val MOD 10000H) );
  END;
 END WriteLInt;


PROCEDURE(VAR r : Rider) WriteBytes*(VAR var: ARRAY OF S.BYTE; len : LONGINT);
  VAR
    i: LONGINT;
 BEGIN
  IF Par.debug THEN
    CheckCol(SHORT( len*2));
    FOR i := 0 TO len-1 DO
      IO.WriteFInt(S.VAL( SHORTINT, var[i]), 16, right, 2, "0");
    END;
  ELSE
    r.WriteBytes^( var, len );
  END;
 END WriteBytes;


PROCEDURE(VAR r : Rider) ReadId*(VAR id : ARRAY OF CHAR);
  VAR
    i : INTEGER;
 BEGIN
  i := 0;
  REPEAT
    r.Read(id[i]);
    INC(i)
  UNTIL id[i-1] = 0X;
 END ReadId;


PROCEDURE(VAR r : Rider) ReadInt*(VAR val : INTEGER);
  VAR
    i,j : SHORTINT;
 BEGIN
  r.Read(i);
  r.Read(j);
  val := i * 256 + j MOD 256;
 END ReadInt;


PROCEDURE(VAR r : Rider) ReadLInt*(VAR val : LONGINT);
  VAR
    i,j : INTEGER;
 BEGIN
  r.ReadInt(i);
  r.ReadInt(j);
  val := i * 10000H + j MOD 10000H;
 END ReadLInt;


PROCEDURE NewFile(VAR name, ext: ARRAY OF CHAR) : Files.File;
  VAR
    filename: FN.path;
    outfile: Files.File;
 BEGIN
  COPY(name, filename); FN.SetExt( ext, filename);
  outfile := Files.New(filename);
  IF outfile = NIL THEN
    IO.WriteString( "Could not create assembler file");
    IO.WriteLn;
  END;
  RETURN outfile;
 END NewFile;


PROCEDURE SetFile*(no: INTEGER);
  VAR
    ext: FN.ext;
 BEGIN
  pos[fileno] := out.Pos();
  fileno := no;
  IF files[no] = NIL THEN
    IF no = 9 THEN ext := "ASM"
    ELSE NumStr.IntTo(no, 10, ext);
    END;
    files[no] := NewFile(name, ext);
    out.Set(files[no], 0);
    RETURN;
  END;
  out.Set(files[no], pos[no]);
 END SetFile;


PROCEDURE WriteString*( str: ARRAY OF CHAR);
  VAR
    i: INTEGER;
 BEGIN
  IF out.base # NIL THEN
    i := 0;
    WHILE (str[i] # 0X) AND (i < LEN(str)) DO
      out.Write(str[i]); INC(i)
    END;
  ELSE IO.WriteString( str);
  END;
 END WriteString;


PROCEDURE WriteChar*( c: CHAR);
 BEGIN
  IF out.base # NIL THEN out.Write(c)
  ELSE IO.WriteChar( c);
  END;
 END WriteChar;


PROCEDURE WriteInt*(i: LONGINT );
  VAR
    str: ARRAY 10 OF CHAR;
 BEGIN
  NumStr.LIntTo(i, 10, str);
  WriteString( str);
 END WriteInt;


PROCEDURE WriteFInt*(i: LONGINT; base, adjust, len: INTEGER; fill: CHAR);
  VAR
    str: ARRAY 20 OF CHAR;
 BEGIN
  NumStr.LIntTo(i, base, str);
  Strings.Adjust(adjust, len, fill, str);
  WriteString( str);
 END WriteFInt;


PROCEDURE WriteReal*( value : REAL; n,adj,len : INTEGER; fill : CHAR);
  VAR
    str: ARRAY 20 OF CHAR;
 BEGIN
  NumStr.RealTo(value, n, str);
  Strings.Adjust(adj, len, fill, str);
  WriteString( str);
 END WriteReal;


PROCEDURE WriteLReal*( value : REAL; n,adj,len : INTEGER; fill : CHAR);
  VAR
    str: ARRAY 20 OF CHAR;
    i: INTEGER;
 BEGIN
  NumStr.RealTo(value, n, str);
  i := Strings.FPosC("E", str);
  IF i >= 0 THEN str[i] := "D" END;
  Strings.Adjust(adj, len, fill, str);
  WriteString( str);
 END WriteLReal;


PROCEDURE WriteLn*;
 BEGIN
  IF out.base # NIL THEN
    out.Write(0DX); out.Write(0AX)
  ELSE IO.WriteLn;
  END;
 END WriteLn;


PROCEDURE NewCodeRider*() : CodeRider;
  VAR
    rider: CodeRider;
 BEGIN
  NEW(rider);
  rider.data := NIL; rider.curr := NIL; rider.reloc := NIL;
  rider.lastrel := 0; rider.size := 0;
  RETURN rider;
 END NewCodeRider;


PROCEDURE (rider: CodeRider) Space;
  VAR
    d : Data;
 BEGIN
  IF (rider.curr = NIL) OR (rider.curr.pos = DataSize) THEN
    NEW(d); d.next := NIL; d.pos := 0;
    IF rider.curr # NIL THEN rider.curr.next := d
    ELSE rider.data := d
    END;
    rider.curr := d;
  END;
 END Space;


PROCEDURE (rider: CodeRider) Write*(x: S.BYTE);
 BEGIN
  rider.Space;
  rider.curr.data[rider.curr.pos] := S.VAL( SHORTINT, x);
  INC(rider.curr.pos);
  INC(rider.size);
 END Write;


PROCEDURE (rider: CodeRider) WriteInt*(val : INTEGER);
 BEGIN
  rider.Write( SHORT(val DIV 256) );
  rider.Write( SHORT(val MOD 256) );
 END WriteInt;


PROCEDURE (rider: CodeRider) WriteLInt*(val : LONGINT);
 BEGIN
  rider.WriteInt( SHORT(val DIV 10000H) );
  rider.WriteInt( SHORT(val MOD 10000H) );
 END WriteLInt;


PROCEDURE (rider: CodeRider) WriteBytes*(VAR var: ARRAY OF S.BYTE; len : LONGINT);
  VAR
    i: LONGINT;
 BEGIN
  FOR i := 0 TO len-1 DO
    rider.Write(var[i]);
  END;
 END WriteBytes;


PROCEDURE (rider: CodeRider) FileOut*(VAR r: Rider);
  VAR
    d: Data;
 BEGIN
  d := rider.data;
  WHILE d # NIL DO
    r.WriteBytes(d.data, d.pos);
    d := d.next;
  END;
 END FileOut;


PROCEDURE (rider: CodeRider) FileOutReloc*(VAR r: Rider);
 BEGIN
  r.Write(0); r.Write(0); r.Write(0);
  rider.reloc.FileOut(r);
  r.Write(0);
 END FileOutReloc;


PROCEDURE (rider: CodeRider) Size*() : LONGINT;
 BEGIN
  RETURN rider.size;
 END Size;


PROCEDURE (rider: CodeRider) StoreReloc*;
  VAR
    lastrel, size: LONGINT;
 BEGIN
  IF rider.reloc = NIL THEN
    rider.reloc := NewCodeRider();
  END;
  lastrel := rider.lastrel; size := rider.size;
  WHILE size-lastrel > 254 DO
    INC(lastrel, 254);
    rider.reloc.Write( 1);
  END;
  rider.reloc.Write( SHORT( SHORT( size-lastrel)));
  rider.lastrel := size;
 END StoreReloc;


PROCEDURE (rider: CodeRider) MergeWith*(r: CodeRider);
  VAR
    dist: LONGINT;
    d: Data; pos: INTEGER;
    fr: Rider;
 BEGIN
  IF r.data # NIL THEN
    IF rider.curr # NIL THEN				(* merge data *)
      rider.curr.next := r.data;
    ELSE
      rider.data := r.data;
    END;
    rider.curr := r.curr;
    IF r.reloc # NIL THEN				(* merge reloc *)
      dist := rider.size - rider.lastrel;
      d := r.reloc.data;
      IF d # NIL THEN
        IF rider.reloc = NIL THEN rider.reloc := NewCodeRider() END;
        pos := 0;
        WHILE d.data[pos] = 1 DO
          INC(pos);
          IF pos = DataSize THEN d := d.next END;
        END;
        (* d.data[pos] holds first reloc value # 1 *)
        INC(dist, S.LONG( S.VAL( SHORTINT, d.data[pos])) );
        WHILE dist > 254 DO
          rider.reloc.Write(1); DEC(dist, 254);
        END;
        d.data[pos] := SHORT( SHORT( dist));
        rider.reloc.MergeWith( r.reloc)
      END;
      rider.lastrel := rider.size + r.lastrel;
    END;
    INC(rider.size, r.size);
  END;
 END MergeWith;


PROCEDURE Init*(VAR filename: ARRAY OF CHAR);
 BEGIN
  COPY(filename, name);
 END Init;


PROCEDURE Exit*;
  VAR
    i: INTEGER;
 BEGIN
  FOR i := 0 TO 9 DO
    IF files[i] # NIL THEN
      files[i].Register;
      IF i = 9 THEN
        IO.WriteString( "New assembler file: ");
        IO.WriteString( files[i].name); IO.WriteLn;
      END;
      files[i].Close;
      files[i] := NIL;
    END;
  END;
  out.Set(NIL, 0);
 END Exit;


END OCOutput.