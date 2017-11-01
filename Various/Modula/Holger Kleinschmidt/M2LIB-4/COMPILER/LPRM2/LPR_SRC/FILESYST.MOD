IMPLEMENTATION MODULE  FileSystem;

(*****************************************************************************)
(*                                                                           *)
(* Rekompiliertes LPR-MODULA-Originalmodul.   hk, Dez-89                     *)
(*                                                                           *)
(*****************************************************************************)


FROM    SYSTEM  IMPORT  (* PROC *)  ADR,
                        (* TYPE *)  BYTE, WORD;

IMPORT  GEMDOS; (*      (* PROC *)  Create, Open, Close, Delete,
                                    Seek, Read, Write,
                                    SetDTA, SFirst,
                        (* TYPE *)  beginning;
                 *)

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

TYPE  Dta = RECORD
              reserviert : ARRAY [ 0..21 ] OF BYTE;
              zeit       : CARDINAL;
              datum      : CARDINAL;
              laenge     : LONGINT;
              fname      : ARRAY [ 0..13 ] OF CHAR;
            END;


(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)



PROCEDURE  AssignStr ((* EIN/ -- *) VAR  quelle : ARRAY OF CHAR;
                      (* -- /AUS *) VAR  ziel   : ARRAY OF CHAR );

   VAR  Index : INTEGER;

   BEGIN
     Index := 0;

     WHILE  ( Index <= HIGH( quelle ))  & ( Index <= HIGH( ziel )  )
                                        & ( quelle[ Index ] >= ' ' )
     DO
        ziel[ Index ] := quelle[ Index ];
        INC( Index );
     END;

     IF  Index < HIGH( ziel )  THEN
        ziel[ Index ] := 0C;
     END;

   END  AssignStr;

(*---------------------------------------------------------------------------*)

PROCEDURE  SyncBuffer ((* EIN/AUS *)  VAR f: File ): BOOLEAN;

   VAR  Offset   : LONGINT;
        ok       : BOOLEAN;
        Position : LONGINT;
        Anzahl   : LONGINT;

   BEGIN
     ok := TRUE;

     WITH  f  DO
       IF  dirty  THEN

          Offset := blocknr * 1024D;
          GEMDOS.Seek( Offset, fdesc, GEMDOS.beginning, Position );

          Anzahl := lim;
          GEMDOS.Write( fdesc, Anzahl, ADR( buffer ));

          ok := Anzahl > 0D;
          IF  ok  THEN
             errorno := 0;
          ELSE
             errorno := Anzahl;
          END;

          dirty := FALSE;
       END; (* IF dirty *)
     END; (* WITH *)

     RETURN( ok );

   END  SyncBuffer;

(*---------------------------------------------------------------------------*)

PROCEDURE  Lookup ((* -- /AUS *) VAR f        : File;
                   (* EIN/ -- *) VAR filename : ARRAY OF CHAR;
                   (* EIN/ -- *)     new      : BOOLEAN       );

   VAR  DTA    : Dta;
        dummy2 : INTEGER;
        dummy1 : BOOLEAN;

   BEGIN
     WITH  f  DO
       AssignStr( filename, nameString );

       refNum   := 0;  volRef  := 0;
       firstPos := 0;  lastPos := 0;  curPos := 0;
       index    := 0;  lim     := 0;  blocknr := 0;

       eof   := FALSE;
       dirty := FALSE;
       res   := notdone;

       IF  new  THEN

          dummy1 := GEMDOS.Delete( filename );
          GEMDOS.Create( filename, 0, fdesc );

          IF  fdesc >= 0  THEN
             length  := 0;
             res     := done;
             errorno := 0;
          ELSE
             errorno := fdesc;
          END;
       ELSE
          GEMDOS.Open( filename, 2, fdesc );

          IF  fdesc >= 0  THEN
             GEMDOS.SetDTA( ADR( DTA ));
             GEMDOS.SFirst( nameString, 0, dummy2 );

             length  := DTA.laenge;
             blocknr := 1;

             SetPos( f, curPos );

             res     := done;
             errorno := 0;
          END; (* IF fdesc *)
       END; (* IF new *)
     END; (* WITH *)
   END  Lookup;

(*---------------------------------------------------------------------------*)

PROCEDURE  Close ((* EIN/AUS *) VAR f : File );

   BEGIN
     WITH  f  DO
       IF   SyncBuffer( f )  &  GEMDOS.Close( fdesc )   THEN
          res := done;
       ELSE
          res := notdone;
       END;
     END; (* WITH *)
   END  Close;

(*---------------------------------------------------------------------------*)

PROCEDURE  Delete ((* EIN/AUS *) VAR f : File );

   BEGIN
     WITH  f  DO
       IF   GEMDOS.Close( fdesc )  &  GEMDOS.Delete( nameString )  THEN
          res := done;
       ELSE
          res := notdone;
       END;
     END; (* WITH *)
   END  Delete;

(*---------------------------------------------------------------------------*)

PROCEDURE  Rename ((* EIN/AUS *) VAR f        : File;
                   (* EIN/ -- *) VAR filename : ARRAY OF CHAR );

   BEGIN
     WITH  f  DO
       res := notdone;

       IF   SyncBuffer( f )  &  GEMDOS.Close( fdesc )   THEN

          GEMDOS.Rename( nameString, filename );
          GEMDOS.Open( filename, 2, fdesc );

          IF  fdesc >= 0  THEN
             res     := done;
             AssignStr( filename, nameString );
             errorno := 0;
          ELSE
             errorno := fdesc;
          END; (* IF fdesc *)
       END; (* IF SyncBuffer() *)
     END; (* WITH *)
   END  Rename;

(*---------------------------------------------------------------------------*)

PROCEDURE  Length ((* EIN/ -- *) VAR f   : File;
                   (* -- /AUS *) VAR pos : LONGINT );

   BEGIN
     pos := f.length;
   END  Length;

(*---------------------------------------------------------------------------*)

PROCEDURE  ReadChar ((* EIN/AUS *) VAR f  : File;
                     (* -- /AUS *) VAR ch : CHAR  );

   BEGIN
     WITH  f  DO
       IF  index >= 1024  THEN
          SetPos( f, curPos );
       END;

       IF  res = done  THEN
          IF  index >= lim  THEN
             ch  := 0C;
             eof := TRUE;
          ELSE
             ch := buffer[ index ];
             INC( index );
             INC( curPos );
          END; (* IF index *)
       END; (* IF res *)
     END; (* WITH *)
   END  ReadChar;

(*---------------------------------------------------------------------------*)

PROCEDURE  WriteChar ((* EIN/AUS *) VAR f  : File;
                      (* EIN/ -- *)     ch : CHAR  );

   BEGIN
     WITH  f  DO
       IF  index >= 1024  THEN
          SetPos( f, curPos );
       END;

       IF  res = done  THEN

          buffer[ index ] := ch;
          INC( index );
          INC( curPos );

          IF  index > lim  THEN
             lim := index;
             INC( length );
          END;

          dirty := TRUE;
       END; (* IF res *)
     END; (* WITH *)
   END  WriteChar;

(*---------------------------------------------------------------------------*)

PROCEDURE  ReadWord ((* EIN/AUS *) VAR f : File;
                     (* -- /AUS *) VAR w : WORD );

   VAR  word2char : RECORD
                      CASE :BOOLEAN  OF
                         FALSE: wort    : WORD;
                        |TRUE : ch1,ch2 : CHAR;
                      END;
                    END;

   BEGIN
     ReadChar( f, word2char.ch1 );
     ReadChar( f, word2char.ch2 );

     w := word2char.wort;

   END  ReadWord;

(*---------------------------------------------------------------------------*)

PROCEDURE  WriteWord ((* EIN/AUS *) VAR f : File;
                      (* EIN/ -- *)     w : WORD  );

   VAR  word2char : RECORD
                      CASE :BOOLEAN  OF
                         FALSE: wort    : WORD;
                        |TRUE : ch1,ch2 : CHAR;
                      END;
                    END;

   BEGIN
     word2char.wort := w;;

     WriteChar( f, word2char.ch1 );
     WriteChar( f, word2char.ch2 );

   END  WriteWord;

(*---------------------------------------------------------------------------*)

PROCEDURE  GetPos ((* EIN/AUS *) VAR f   : File;
                   (* -- /AUS *) VAR pos : LONGINT );

   BEGIN
     WITH  f  DO
       pos := curPos;
       res := done;
     END; (* WITH *)
   END  GetPos;

(*---------------------------------------------------------------------------*)

PROCEDURE  SetPos ((* EIN/AUS *) VAR f   : File;
                   (* EIN/ -- *)     pos : LONGINT );

   VAR  blknr,
        bytblk,
        Anzahl,
        dummy  : LONGINT;

   BEGIN
     WITH  f  DO
        blknr := pos  DIV  1024D;
        res := done;

        IF  blocknr # blknr  THEN
           IF  ~SyncBuffer( f )  THEN
              res := notdone;
           ELSE
              bytblk := blknr * 1024D;
              dummy  := bytblk;

              GEMDOS.Seek( bytblk, fdesc, GEMDOS.beginning, dummy );

              Anzahl := 1024;
              GEMDOS.Read( fdesc, Anzahl, ADR( buffer ));
              lim  := Anzahl;

              IF  lim = 0  THEN
                 eof := TRUE;
              ELSE
                 eof := FALSE;
              END;

              blocknr := blknr;
           END; (* IF ~SyncBuffer *)
        ELSE
           IF  pos < length  THEN
              eof := FALSE;
           END;
        END; (* IF  blocknr *)

        index  := pos  MOD  1024D;
        curPos := pos;

     END; (* WITH *)
   END  SetPos;

END  FileSystem.
