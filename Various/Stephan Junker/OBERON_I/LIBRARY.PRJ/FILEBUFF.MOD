MODULE FileBuffer;

(* buffered file system *)

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |1.3.93  |started
S. Junker  |7.10.93 |Pos exported
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM, File, Strings, Memory;

CONST (* modi for Seek *)
  absbeg* = 0; relative* = 1; absend* = 2;

TYPE
  file*    = POINTER TO filedesc;
  filedesc*= RECORD
               Handle: INTEGER;
               Begad : S.PTR;
               Pos-,Length*,Size : LONGINT;
               Ok* : BOOLEAN; (* FALSE : eof while reading or write error *)
             END;
  (* this is a pointer to an info structure used as a handle *)

PROCEDURE Load*(Name : ARRAY OF CHAR; VAR f : file) : BOOLEAN;
  (* loads file Name with File.Load and returns a handle. FALSE is returned
     if the file is not found *)
  VAR
    Begad  : S.PTR;
    Length : LONGINT;
 BEGIN
  IF File.Load(Name,0,0,Begad,Length) THEN
    NEW(f); f.Begad := Begad; f.Pos := 0; f.Length := Length; f.Ok := TRUE;
    RETURN TRUE;
  END;
  RETURN FALSE
 END Load;

PROCEDURE ReadBytes*(f : file; NumBytes : LONGINT; VAR Bytes : ARRAY OF S.BYTE);
  (* returns the desired amount of bytes *)
 BEGIN
  IF f.Pos + NumBytes <= f.Length THEN
    Memory.Copy(f.Begad + f.Pos,S.ADR(Bytes),NumBytes);
    INC(f.Pos,NumBytes);
  ELSE f.Ok := FALSE;
  END;
 END ReadBytes;

PROCEDURE ReadChar*(f : file; VAR Char : CHAR);
  (* reads one character *)
 BEGIN
  IF f.Pos < f.Length THEN
    S.GET(f.Begad + f.Pos,Char); INC(f.Pos);
  ELSE f.Ok := FALSE; Char := 0X
  END;
 END ReadChar;

PROCEDURE ReadByte*(f : file; VAR Byte : SHORTINT);
  (* reads one byte *)
 BEGIN
  IF f.Pos < f.Length THEN
    S.GET(f.Begad + f.Pos,Byte); INC(f.Pos);
  ELSE f.Ok := FALSE
  END;
 END ReadByte;

PROCEDURE ReadWord*(f : file; VAR Word : INTEGER);
  (* reads one word (16 bit) *)
  VAR si : SHORTINT;
 BEGIN
  IF f.Pos + 2 <= f.Length THEN
    S.MOVE(f.Begad + f.Pos,S.ADR(Word),2); INC(f.Pos,2);
  ELSE f.Ok := FALSE
  END;
 END ReadWord;

PROCEDURE ReadLong*(f : file; VAR Long : LONGINT);
  (* reads one long word (32 bit) *)
 BEGIN
  IF f.Pos + 4 <= f.Length THEN
    S.MOVE(f.Begad + f.Pos,S.ADR(Long),4); INC(f.Pos,4);
  ELSE f.Ok := FALSE
  END;
 END ReadLong;

PROCEDURE ReadString*(f : file; VAR String : ARRAY OF CHAR);
  (* reads characters until 0X is read *)
  VAR i : INTEGER; Addr,Endad : LONGINT; c : CHAR;
 BEGIN
  IF f.Pos # f.Length THEN
    i := 0;
    Addr := f.Begad + f.Pos; Endad := f.Begad + f.Length; c := 1X;
    WHILE (c # 0X) AND (Addr < Endad) DO
      S.GET(Addr,c); INC(Addr);
      String[i] := c; INC(i);
    END;
    String[i] := 0X; f.Pos := Addr - f.Begad;
  ELSE f.Ok := FALSE
  END;
 END ReadString;

PROCEDURE Open*(Name : ARRAY OF CHAR; BufSize : LONGINT; VAR f : file) : BOOLEAN;
  (* returns a handle to be used for writing into a buffer with size BufSize *)
  VAR Handle : INTEGER;
 BEGIN
  IF File.Create(Name,{},Handle) THEN
    NEW(f); S.NEW(f.Begad,BufSize);
    f.Pos := 0; f.Length := 0; f.Size := BufSize;
    f.Handle := Handle; f.Ok := TRUE;
    RETURN TRUE;
  END;
  RETURN FALSE;
 END Open;

PROCEDURE SaveBuffer(f : file);
 BEGIN
  IF NOT File.Write(f.Handle,f.Length,f.Begad) THEN f.Ok := FALSE END;
 END SaveBuffer;

PROCEDURE Close*(f : file);
  (* saves file with handle f *)
  VAR d : BOOLEAN;
 BEGIN
  SaveBuffer(f); File.Close(f.Handle);
 END Close;

PROCEDURE WriteBytes*(f : file; NumBytes : LONGINT; VAR Bytes : ARRAY OF S.BYTE);
  (* returns the desired amount of bytes *)
  VAR Max : LONGINT; Begad : LONGINT;
 BEGIN
  Max := f.Size - f.Pos; Begad := S.ADR(Bytes);
  IF NumBytes > Max THEN Memory.Copy(Begad,f.Begad + f.Pos,Max);
    f.Length := f.Size;
    SaveBuffer(f); DEC(NumBytes,Max);
    f.Pos := 0; f.Length := 0; INC(Begad,Max);
  END;
  Memory.Copy(Begad,f.Begad + f.Pos,NumBytes); INC(f.Pos,NumBytes);
  IF f.Pos > f.Length THEN f.Length := f.Pos END;
 END WriteBytes;

PROCEDURE WriteChar*(f : file; Char : CHAR);
  (* writes one character *)
 BEGIN
  WriteBytes(f,1,Char);
 END WriteChar;

PROCEDURE WriteByte*(f : file; Byte : SHORTINT);
  (* writes one byte *)
 BEGIN
  WriteBytes(f,1,Byte);
 END WriteByte;

PROCEDURE WriteWord*(f : file; Word : INTEGER);
  (* writes one word (16 bit) *)
 BEGIN
  WriteBytes(f,2,Word);
 END WriteWord;

PROCEDURE WriteLong*(f : file; Long : LONGINT);
  (* writes one long word (32 bit) *)
 BEGIN
  WriteBytes(f,4,Long);
 END WriteLong;

PROCEDURE WriteString*(f : file; String : ARRAY OF CHAR);
  (* writes string including 0X *)
 BEGIN
  WriteBytes(f,Strings.Length(String)+1,String);
 END WriteString;

PROCEDURE WriteChars*(f : file; String : ARRAY OF CHAR);
  (* writes string not including 0X *)
 BEGIN
  WriteBytes(f,Strings.Length(String),String);
 END WriteChars;

PROCEDURE Seek*(f : file; Mode : INTEGER; Bytes : LONGINT);
  (* sets the file pointer to the desired position. Can be used for read without
     restriction and for write, if the desired position is still in the buffer, so
     make it big enough *)

 BEGIN
  CASE Mode OF
    absbeg : f.Pos := Bytes |
    relative : INC(f.Pos,Bytes) |
    absend : f.Pos := f.Length - Bytes |
    ELSE
  END;
  IF f.Pos < 0 THEN f.Pos := 0
  ELSIF f.Pos > f.Length THEN f.Pos := f.Length
  END;
 END Seek;

BEGIN
END FileBuffer.