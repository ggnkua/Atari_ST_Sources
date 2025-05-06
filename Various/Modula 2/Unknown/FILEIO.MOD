(*$T-*) (*$S-*)
IMPLEMENTATION MODULE FileIO;

(*******************************************************************)
(*                                                                 *)
(* FileIO - File Access Routines for Modula-2 (sequential and      *)
(*          Random Access).                                        *)
(*                                                                 *)
(*  ------- Copyright (C) Don Milne & MicroPack Ltd, 1986 -------  *)
(*                                                                 *)
(* Not Public Domain.                                              *)
(* Permission granted for all uses other than distribution to      *)
(* third parties, except when linked to an executable code file.   *)
(*                                                                 *)
(*******************************************************************)


FROM SYSTEM IMPORT
       WORD,CODE,ADR,ADDRESS,TSIZE;
IMPORT GEMDOS;


CONST NUL=0;
      EOL=13;
      LF=10;
      EOFCH=26;
      MaxOpen=40;

TYPE filespec = ARRAY[0..81] OF CHAR;

     BLOCK = ARRAY[0..511] OF CHAR;

     BUFFP=POINTER TO BLOCK;

     FIB=RECORD
               handle:INTEGER;
               offset,            (* offset within block - FILEs only *)
               recsize,bytesinbuff,writecnt:CARDINAL;
               filesize,filepos:LONGCARD;
               charfile,newfile,goteof,goteoln:BOOLEAN;
               buffptr:ADDRESS;
         END;

     FIBP = POINTER TO FIB;

VAR BomboutOK:BOOLEAN;
    openptr:CARDINAL;
    openfiles:ARRAY[0..MaxOpen-1] OF ADDRESS;

(*...................................................*)

PROCEDURE ALLOCATE(VAR ptr:ADDRESS; amount:LONGCARD);

   BEGIN
        IF amount>LONGCARD(0) THEN
           GEMDOS.Alloc(amount,ptr)
        ELSE
           ptr := NIL
        END;
   END ALLOCATE;

(*..................................................*)

PROCEDURE DEALLOCATE(VAR ptr:ADDRESS; amount:LONGCARD);

   BEGIN
        IF (ptr <> NIL) AND (GEMDOS.Free(ptr)) THEN END;
        ptr := NIL;
   END DEALLOCATE;

(*..................................................*)

PROCEDURE WriteCard(c:CARDINAL);

   BEGIN
        IF c>9 THEN WriteCard(c DIV 10) END;
        GEMDOS.ConOut(CHR((c MOD 10) + 48));
   END WriteCard;

(*.................................................*)

PROCEDURE SetError(errno:INTEGER);

VAR s:ARRAY[0..80] OF CHAR;

BEGIN
     IF errno >=0 THEN IOResult := 0  END;
     IF errno < 0 THEN IOResult := CARDINAL(-errno) END;
     IF (errno<0) AND (BomboutOK) THEN
         errno:=-errno;
         s:='File I/O ERROR - ';
         GEMDOS.ConWS(s);
         WriteCard(CARDINAL(errno));
         s[0]:=CHR(13); s[1]:=CHR(10); s[2]:=CHR(0);
         GEMDOS.ConWS(s);
         HALT;
     END;
END SetError;

(*...................................................*)

PROCEDURE Assign(VAR source,dest:ARRAY OF CHAR);

(* Creates a NULL-terminated string from source *)

VAR i:CARDINAL;
    ch:CHAR;

BEGIN
     (* debug('In Assign'); *)
     i:=0;
     REPEAT
           IF i<=HIGH(source) THEN
               ch:=source[i]
             ELSE
               ch:=CHR(NUL);
           END;
           dest[i]:=ch; INC(i);
     UNTIL (ch=CHR(NUL)) OR (i>HIGH(dest));
     IF ch<>CHR(NUL) THEN dest[HIGH(dest)]:=CHR(NUL) END;
     (* debug('Leaving Assign'); *)
END Assign;

(*...................................................*)

PROCEDURE NoteNewFile(f:ADDRESS);
BEGIN
     IF openptr=MaxOpen THEN
         SetError(-35)
       ELSE
         openfiles[openptr]:=f; INC(openptr);
     END;
END NoteNewFile;

(*...................................................*)

PROCEDURE ScrapFile(fileindex:CARDINAL);

VAR i:CARDINAL;

BEGIN
     IF fileindex<>40 THEN (* avoid array index error a[i+1]>39 *)
         FOR i:=fileindex-1 TO openptr-1 DO
             openfiles[i]:=openfiles[i+1];
         END;
     END;
     DEC(openptr);
END ScrapFile;

(*...................................................*)

PROCEDURE CheckFib(f:ADDRESS):CARDINAL;

VAR i:CARDINAL;

BEGIN
     IF openptr>0 THEN
         FOR i:=0 TO openptr-1 DO
             IF openfiles[i]=f THEN RETURN(i+1) END;
         END
     END;
     RETURN(0)
END CheckFib;

(*...................................................*)

PROCEDURE GetStdHandle(VAR name:ARRAY OF CHAR):INTEGER;

TYPE devID=ARRAY[0..3] OF CHAR;

VAR i,j:INTEGER;
    fname:devID;
    devname:ARRAY[1..4] OF devID;

BEGIN
     IF (HIGH(name)<3) THEN RETURN(0) END;
     devname[1]:='KBD:';  devname[2]:='CON:';
     devname[3]:='AUX:';  devname[4]:='PRN:';
     FOR i:=0 TO 3 DO fname[i]:=CAP(name[i]); END;
     FOR i:=1 TO 4 DO
        j:=0;
        LOOP
            IF devname[i,j]<>fname[j] THEN EXIT END;
            INC(j);
            IF j=4 THEN RETURN(i) END;
        END;
     END;
     RETURN 0;
END GetStdHandle;

(*...................................................*)

PROCEDURE Open(VAR f:ADDRESS; VAR name:ARRAY OF CHAR; recsize:CARDINAL;
                                          newfile,charfile:BOOLEAN);

VAR handle:INTEGER;
    status:CARDINAL;
    p:FIBP;
    filesize,dummy:LONGCARD;
    dosname:filespec;

BEGIN
     (* debug('In Open'); *)
     IF CheckFib(f)<>0 THEN
         SetError(-124); (* file already open *)
         RETURN;
     END;
     f:=NIL;
     Assign(name,dosname);
     ALLOCATE(f,LONGCARD(recsize+TSIZE(FIB)));
     IF f<>NIL THEN
          handle:=GetStdHandle(dosname);
          filesize := 0;
          IF handle>0 THEN
               DEC(handle); newfile:=FALSE;
            ELSIF newfile THEN
               GEMDOS.Create(dosname,0,handle)
            ELSE
               GEMDOS.Open(dosname,2,handle);
               GEMDOS.Seek(0,handle,GEMDOS.end,filesize);
               GEMDOS.Seek(0,handle,GEMDOS.beginning,dummy);
          END;
          SetError(handle);
          IF IOResult<>0 THEN RETURN END;
          p := FIBP(f);
          p^.charfile := charfile;
          p^.filesize := filesize;
          p^.filepos := 0;
          p^.handle:=handle;
          p^.recsize:=recsize;
          p^.bytesinbuff:=0;
          p^.newfile:=newfile;
          p^.goteof:=FALSE;
          p^.goteoln:=FALSE;
          p^.offset:=0;
          p^.writecnt:=0;
          INC(f,TSIZE(FIB)); (* move user ptr to buffer area *)
          NoteNewFile(f);
          p^.buffptr:=f
       ELSE
          SetError(-39); (* insufficient memory *)
     END;
     (* debug('Leaving Open'); *)
END Open;

(*...................................................*)

PROCEDURE CreateFile(VAR f:ADDRESS;VAR name:ARRAY OF CHAR;recsize:CARDINAL);
BEGIN
     (* debug('In CreateFile'); *)
     Open(f,name,recsize,TRUE,FALSE);
     (* debug('Leaving CreateFile'); *)
END CreateFile;

(*...................................................*)

PROCEDURE OpenFile(VAR f:ADDRESS;VAR name:ARRAY OF CHAR;recsize:CARDINAL);
BEGIN
     (* debug('In OpenFile'); *)
     Open(f,name,recsize,FALSE,FALSE);
     (* debug('Leaving OpenFile'); *)
END OpenFile;

(*...................................................*)

PROCEDURE Close(VAR f:ADDRESS);

VAR fileindex:CARDINAL;
    p:FIBP;

BEGIN
     (* debug('In Close'); *)
     fileindex := CheckFib(f);
     IF fileindex<>0 THEN
         p:=FIBP(f-TSIZE(FIB));
         IF GEMDOS.Close(p^.handle) THEN (* error? *) END;
         f:=p;
         DEALLOCATE(f,LONGCARD(p^.recsize+TSIZE(FIB)));
         f:=NIL;
         ScrapFile(fileindex);
     END;
     (* debug('Leaving Close'); *)
END Close;

(*...................................................*)

PROCEDURE DeleteFile(VAR name:ARRAY OF CHAR);

VAR dosname:ARRAY[0..81] OF CHAR;

BEGIN
     Assign(name,dosname); (* ensures that NUL byte is appended *)
     IF NOT GEMDOS.Delete(dosname) THEN SetError(-33) END;
END DeleteFile;

(*...................................................*)

PROCEDURE RenameFile(VAR oldname,newname:ARRAY OF CHAR);

VAR dosold,dosnew:ARRAY[0..81] OF CHAR;

BEGIN
     IOResult:=0;
     Assign(oldname,dosold);
     Assign(newname,dosnew);
     GEMDOS.Rename(dosold,dosnew);
END RenameFile;

(*...................................................*)

PROCEDURE Seek(f:ADDRESS; recnum:CARDINAL);

VAR offset:LONGINT;
    p:FIBP;

BEGIN
     (* debug('In Seek'); *)
     IF CheckFib(f)<>0 THEN
          IOResult:=0;
          DEC(f,TSIZE(FIB));
          p:=FIBP(f);
          IF p^.recsize<>0 THEN
              offset := LONGINT(recnum)*LONGINT(p^.recsize);
              GEMDOS.Seek(offset,p^.handle,GEMDOS.beginning,p^.filepos)
            ELSE
              SetError(-122)
          END;
     END;
     (* debug('Leaving Seek'); *)
END Seek;

(*...................................................*)

PROCEDURE Get(f:ADDRESS);

VAR bytesread:LONGCARD;
    buffptr:ADDRESS;
    status:CHAR;
    p:FIBP;

BEGIN
     (* debug('In Get'); *)
     IF CheckFib(f)<>0 THEN
          p:=FIBP(f-TSIZE(FIB));
          IF p^.recsize<>0 THEN
              bytesread := LONGCARD(p^.recsize);
              GEMDOS.Read(p^.handle,bytesread,p^.buffptr);
              p^.bytesinbuff:=CARDINAL(bytesread);
              INC(p^.filepos,bytesread);
              p^.goteoln:=FALSE;
              p^.writecnt:=0;
              p^.offset:=0;
              p^.goteof := (p^.filepos>=p^.filesize)
            ELSE
              SetError(-122);
          END;
     END;
     (* debug('Leaving Get'); *)
END Get;

(*...................................................*)

PROCEDURE Put(f:ADDRESS);

VAR size,bytescopied:LONGCARD;
    buffptr:ADDRESS;
    status:BITSET;
    p:FIBP;

BEGIN
     (* debug('In Put'); *)
     IF CheckFib(f)<>0 THEN
          p:=FIBP(f-TSIZE(FIB));
          IF p^.recsize<>0 THEN
              IF p^.writecnt>0 THEN
                   size:=LONGCARD(p^.writecnt)
                ELSIF p^.bytesinbuff>0 THEN
                   size:=LONGCARD(p^.bytesinbuff)
                ELSE
                   size:=LONGCARD(p^.recsize);
              END;
              IF size>0 THEN
                   bytescopied:=size;
                   GEMDOS.Write(p^.handle,size,p^.buffptr);
                   INC(p^.filepos,size);
                   IF (bytescopied<>size) THEN
                        SetError(-105);
                        RETURN;
                   END;
              END;
              p^.goteoln:=FALSE;
              p^.writecnt:=0;
              p^.offset:=CARDINAL(p^.bytesinbuff);
            ELSE
              SetError(-122);
          END;
     END;
     (* debug('Leaving Put'); *)
END Put;

(*...................................................*)

PROCEDURE EOLN(f:FILE):BOOLEAN;

VAR p:FIBP;
    temp:BOOLEAN;

BEGIN
     (* debug('In EOLN'); *)
     IF CheckFib(f)<>0 THEN
         p := FIBP(f-TSIZE(FIB));
         temp:=(p^.charfile) AND (p^.goteoln)
       ELSE
         SetError(-121); temp:=FALSE;
     END;
     (* debug('Leaving EOLN'); *)
     RETURN temp;
END EOLN;

(*...................................................*)

PROCEDURE BytesRead(f:ADDRESS):CARDINAL;

VAR p:FIBP;

BEGIN
     (* debug('In BytesRead'); *)
     IF CheckFib(f)<>0 THEN
         p := FIBP(f-TSIZE(FIB));
         RETURN p^.bytesinbuff
       ELSE
         SetError(-121); RETURN 0;
     END;
     (* debug('Leaving BytesRead'); *)
END BytesRead;

(*...................................................*)

PROCEDURE ChangeRecSize(f:ADDRESS; newrecsize:CARDINAL);

VAR p:FIBP;

BEGIN
     (* debug('In BytesRead'); *)
     IF CheckFib(f)<>0 THEN
         p := FIBP(f-TSIZE(FIB));
         p^.bytesinbuff := newrecsize
       ELSE
         SetError(-121);
     END;
     (* debug('Leaving BytesRead'); *)
END ChangeRecSize;

(*...................................................*)

PROCEDURE EOF(f:ADDRESS):BOOLEAN;

VAR p:FIBP;
    temp:BOOLEAN;
    blk:BUFFP;

BEGIN
     (* debug('In EOF'); *)
     IF CheckFib(f)<>0 THEN
         blk:=BUFFP(f);
         p := FIBP(f-TSIZE(FIB));
         temp:=(p^.goteof);
         IF (temp) AND (p^.charfile) THEN
             temp := (p^.offset>=p^.bytesinbuff)
                  OR (blk^[p^.offset]=CHR(EOFCH));
         END
       ELSE
         SetError(-121); temp:=FALSE;
     END;
     (* debug('Leaving EOF'); *)
     RETURN temp;
END EOF;

(*...................................................*)
(* Character file I/O - text files and devices *)

PROCEDURE OpenChar(VAR f:FILE; VAR name:ARRAY OF CHAR);
BEGIN
     (* debug('In OpenChar'); *)
     Open(f,name,512,FALSE,TRUE);
     (* debug('Leaving OpenChar'); *)
END OpenChar;

(*...................................................*)

PROCEDURE CreateChar(VAR f:FILE; VAR name:ARRAY OF CHAR);
BEGIN
     (* debug('In CreateChar'); *)
     Open(f,name,512,TRUE,TRUE);
     (* debug('Leaving CreateChar'); *)
END CreateChar;

(*...................................................*)

PROCEDURE CloseChar(VAR f:FILE);

VAR fileindex:CARDINAL;
    p:FIBP;

BEGIN
     (* debug('In CloseChar'); *)
     fileindex := CheckFib(f);
     IF fileindex<>0 THEN
          p:=FIBP(f-TSIZE(FIB));
          IF p^.writecnt>0 THEN
               IF p^.writecnt<512 THEN Write(f,CHR(EOFCH)) END;
               Put(f);
          END;
          IF p^.handle>=6 THEN
              Close(f)
            ELSE
              ScrapFile(fileindex)
          END;
     END;
     (* debug('Leaving CloseChar'); *)
END CloseChar;

(*...................................................*)

PROCEDURE Read(f:FILE; VAR ch:CHAR);

VAR p:FIBP;
    blk:BUFFP;

BEGIN
     (* debug('In Read'); *)
     blk:=BUFFP(f);
     IF CheckFib(f)<>0 THEN
          p:=FIBP(f-TSIZE(FIB));
          IF p^.offset=p^.bytesinbuff THEN
               IF NOT p^.goteof THEN
                    Get(f);
                    IF IOResult<>0 THEN RETURN END
                 ELSE
                    RETURN
               END;
          END;
          ch:=blk^[p^.offset];
          INC(p^.offset);
          IF ch=CHR(EOFCH) THEN
               p^.goteof:=TRUE
            ELSIF ch=CHR(EOL) THEN
               p^.goteoln:=TRUE
          END;
     END;
     (* debug('Leaving Read'); *)
END Read;

(*...................................................*)

PROCEDURE ReadString(f:FILE; VAR s:ARRAY OF CHAR);

VAR ch:CHAR;
    ptr:CARDINAL;
    done:BOOLEAN;

BEGIN
     (* debug('In ReadString'); *)
     ptr:=0;
     REPEAT
          REPEAT
               Read(f,ch);
               done := (EOF(f)) OR (ch=CHR(EOL));
          UNTIL (done)
             OR ((ch=CHR(8)) AND (ptr>0))
             OR ((ch>=' ') AND (ch<=CHR(126)));
          IF NOT done THEN
               IF ch<>CHR(8) THEN
                    IF ptr<=HIGH(s) THEN s[ptr]:=ch; INC(ptr) END;
                 ELSE
                    DEC(ptr)
               END;
          END;
     UNTIL done;
     IF ptr<=HIGH(s) THEN s[ptr]:=CHR(NUL) END;
     IF ch=CHR(EOL) THEN Read(f,ch) END;  (* THROW AWAY LINEFEED *)
     (* debug('Leaving ReadString'); *)
END ReadString;

(*...................................................*)

PROCEDURE Write(f:FILE; ch:CHAR);

VAR p:FIBP;
    blk:BUFFP;

BEGIN
     (* debug('In Write'); *)
     blk:=BUFFP(f);
     IF CheckFib(f)<>0 THEN
          p:=FIBP(f-TSIZE(FIB));
          IF p^.writecnt=512 THEN
               Put(f); p^.writecnt:=0;
               IF IOResult<>0 THEN RETURN END;
          END;
          blk^[p^.writecnt]:=ch;
          INC(p^.writecnt);
     END;
     (* debug('Leaving Write'); *)
END Write;

(*...................................................*)

PROCEDURE WriteString(f:FILE; VAR s:ARRAY OF CHAR);

VAR i:INTEGER;
    ch:CHAR;

BEGIN
     (* debug('In WriteString'); *)
     FOR i:=0 TO HIGH(s) DO
          ch:=s[i];
          IF ch<>CHR(NUL) THEN
               Write(f,ch)
            ELSE
               RETURN;
          END;
     END;
     (* debug('Leaving WriteString'); *)
END WriteString;

(*...................................................*)

PROCEDURE WriteLn(f:FILE);
BEGIN
     (* debug('In WriteLn'); *)
     Write(f,CHR(EOL)); Write(f,CHR(LF));
     (* debug('Leaving WriteLn'); *)
END WriteLn;

(*...................................................*)

PROCEDURE BlockRead(f:ADDRESS; VAR buff:ARRAY OF WORD;
                                 bytes:CARDINAL):CARDINAL;

VAR p:FIBP;

BEGIN
     IF CheckFib(f)<>0 THEN
          p:=FIBP(f-TSIZE(FIB));
          IF p^.recsize=0 THEN
              p^.recsize:=bytes;
              p^.buffptr:=ADR(buff);
              Get(f);
              p^.recsize:=0;
              RETURN p^.bytesinbuff
            ELSE
              SetError(-123);
          END;
     END;
END BlockRead;

(*...................................................*)

PROCEDURE BlockWrite(f:ADDRESS; VAR buff:ARRAY OF WORD; bytes:CARDINAL);

VAR p:FIBP;

BEGIN
     IF CheckFib(f)<>0 THEN
          p:=FIBP(f-TSIZE(FIB));
          IF p^.recsize=0 THEN
              p^.recsize:=bytes;
              p^.buffptr:=ADR(buff);
              Put(f);
              p^.recsize:=0;
            ELSE
              SetError(-123);
          END;
     END;
END BlockWrite;

(*...................................................*)

PROCEDURE BlockSeek(f:ADDRESS; blocksize,blocknum:CARDINAL);

VAR p:FIBP;

BEGIN
     IF CheckFib(f)<>0 THEN
          p:=FIBP(f-TSIZE(FIB));
          IF p^.recsize=0 THEN
              p^.recsize:=blocksize;
              Seek(f,blocknum);
              p^.recsize:=0;
            ELSE
              SetError(-123);
          END;
     END;
END BlockSeek;

(*...................................................*)

PROCEDURE IOCheck(on:BOOLEAN);
BEGIN
     BomboutOK := on;
END IOCheck;

(*...................................................*)

BEGIN
     IOResult:=0; openptr:=0; BomboutOK:=TRUE;
END FileIO.
