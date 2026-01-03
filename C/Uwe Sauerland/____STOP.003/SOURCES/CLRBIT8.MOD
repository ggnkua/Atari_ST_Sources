MODULE ClrBit8;

(*$A+*)
(*$Q+*)

FROM SYSTEM         IMPORT    ADR ;
FROM Streams        IMPORT    Stream, StreamKinds, OpenStream, CloseStream,
                              Write8Bit,Read8Bit, EOS;
FROM AESGraphics    IMPORT    GrafMouse ;
FROM AESForms       IMPORT    FileSelectorInput ;
FROM GEMAESbase     IMPORT    Arrow ;
FROM Strings        IMPORT    String, Length, Concat ;
FROM GEMDOS         IMPORT    Open, Close ;

VAR in,out:Stream;
    c     :CHAR;
    reply :INTEGER;
    exit  :BOOLEAN;
    path,infilename,outfilename:String;

PROCEDURE FileSelInput(VAR path, filename: String; check:BOOLEAN;
                       VAR exit:BOOLEAN);
VAR inpath, insel : String ;
    dummy, finished : BOOLEAN;
    exbutton, handle : INTEGER;
BEGIN
  GrafMouse(Arrow,   NIL);
  REPEAT
    inpath:=path;
    insel[0]:=0C;
    FileSelectorInput(ADR(inpath),ADR(insel),exbutton);
    IF (exbutton#0) AND (insel[0]#0C) THEN
      WHILE inpath[Length(inpath)-1]#'\' DO
        inpath[Length(inpath)-1]:=0C
      END;
      Concat(inpath,insel,filename);
      IF check THEN
        Open(filename,0,handle);
        IF handle<0 THEN
          finished:=FALSE
        ELSE
          dummy:=Close(handle);
          finished:=TRUE;
          exit:=FALSE
        END;
      ELSE
        finished:=TRUE;
        exit:=FALSE;
      END;
    ELSE
      exit:=TRUE;
      finished:=TRUE;
    END;
  UNTIL finished;
END FileSelInput;

BEGIN
  path:='\*.*';
  FileSelInput(path,infilename,TRUE,exit);
  IF NOT exit THEN
    FileSelInput(path,outfilename,FALSE,exit);
    IF NOT exit THEN
      OpenStream(in,infilename,READ,reply);
      OpenStream(out,outfilename,READWRITE,reply);
      WHILE NOT EOS(in) DO
        Read8Bit(in,c);
        IF INTEGER(c)>127 THEN
          c:=CHAR(INTEGER(c)-128);
        END;
        Write8Bit(out,c);
      END;
      CloseStream(out,reply);
      CloseStream(in,reply);
    END;
  END;
END ClrBit8.
