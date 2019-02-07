IMPLEMENTATION MODULE  Terminal;

(*****************************************************************************)
(*                                                                           *)
(*  Rekompiliertes LPR-MODULA-Originalmodul  hk, Jan-90                      *)
(*                                                                           *)
(*****************************************************************************)
(*                                                                           *)
(* Offsets der Variablen zur Modulbasis ( sedezimal ):                       *)
(*                                                                           *)
(*      ctrlC       -$1E                                                     *)
(*      echo        -$20                                                     *)
(*      termCh      -$22                                                     *)
(*      RawRead     -$26                                                     *)
(*      BusyRead    -$2A                                                     *)
(*      Write       -$2E                                                     *)
(*      WriteError  -$32                                                     *)
(*      readAgain   -$34                                                     *)
(*      lastChar    -$36                                                     *)
(*                                                                           *)
(*****************************************************************************)

FROM  SYSTEM  IMPORT (* PROC *)  REG, SHORT;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

  CONST Akku = 0;

  VAR  readAgain : BOOLEAN;
       lastChar  : CHAR;

(*---------------------------------------------------------------------------*)

  PROCEDURE ExecGemdos ((* EIN/ -- *) fktn : CARDINAL ): LONGCARD;

    PROCEDURE GEMDOS ((* EIN/ -- *) fktn : CARDINAL ); CODE( 4E41H );

    BEGIN
      GEMDOS( fktn );
      RETURN( REG( Akku ));
    END  ExecGemdos;

(*---------------------------------------------------------------------------*)

  PROCEDURE ExecGemdos1 ((* EIN/ -- *) fktn : CARDINAL;
                         (* EIN/ -- *) par  : CARDINAL ): LONGCARD;

    PROCEDURE GEMDOS ((* EIN/ -- *) par  : CARDINAL;
                      (* EIN/ -- *) fktn : CARDINAL ); CODE( 4E41H );

    BEGIN
      GEMDOS( par, fktn );
      RETURN( REG( Akku ));
    END  ExecGemdos1;

(*---------------------------------------------------------------------------*)

  PROCEDURE StdWrite ((* EIN/ -- *) zeichen : CHAR );

    CONST  Cconout = 2;

    VAR    retcode : LONGCARD;

    BEGIN
      retcode := ExecGemdos1( Cconout, ORD( zeichen ));
    END  StdWrite;

(*---------------------------------------------------------------------------*)

  PROCEDURE EscWrite ((* EIN/ -- *) steuer : CHAR );

    BEGIN
      StdWrite( 33C ); StdWrite( steuer );
    END  EscWrite;

(*---------------------------------------------------------------------------*)

  PROCEDURE StdRead ((* -- /AUS *) VAR zeichen : CHAR );

    CONST  Crawcin = 7;

    BEGIN
      EscWrite('e');
      zeichen := CHR( SHORT( ExecGemdos( Crawcin )));
      EscWrite('f');
    END  StdRead;

(*---------------------------------------------------------------------------*)

  PROCEDURE StdBusyRead ((* -- /AUS *) VAR zeichen : CHAR );

    CONST  Cconis  = 11;
           Crawcin = 7;

    BEGIN
      IF  ExecGemdos( Cconis ) # 0D  THEN
        zeichen := CHR( SHORT( ExecGemdos( Crawcin )));
      ELSE
        zeichen := 0C;
      END;
    END  StdBusyRead;

(*---------------------------------------------------------------------------*)

  PROCEDURE PrintError ((* EIN/ -- *) str : ARRAY OF CHAR );

    CONST  CR = 15C;
           LF = 12C;

    VAR    Index : INTEGER;

    BEGIN
      StdWrite( CR ); StdWrite( LF );
      EscWrite('p');

      Index := 0;
      WHILE  ( Index <= HIGH( str )) & ( str[ Index ] # 0C )  DO
        StdWrite( str[ Index ]);
        INC( Index );
      END;

      EscWrite('q');
    END  PrintError;

(*---------------------------------------------------------------------------*)

  PROCEDURE ReadEcho ((* EIN/ -- *)     echo : BOOLEAN;
                      (* -- /AUS *) VAR ch   : CHAR    );

    BEGIN
      IF  readAgain  THEN
        ch        := lastChar;
        readAgain := FALSE;
      ELSE
        RawRead( ch );

        IF  ch # 0C  THEN
          IF  ctrlc & ( ch = 3C )  THEN
            HALT;
          END;

          lastChar := ch;

          IF  echo  THEN
            IF  ( ch # 10C ) & ( ch # 177C )  THEN
              Write( ch );
            END;
          END;
        END;
      END;
    END  ReadEcho;

(*---------------------------------------------------------------------------*)

  PROCEDURE Read ((* -- /AUS *) VAR ch : CHAR );

    BEGIN
      ReadEcho( echo, ch );
    END  Read;

(*---------------------------------------------------------------------------*)

  PROCEDURE ReadString ((* -- /AUS *) VAR str : ARRAY OF CHAR );

    VAR  zeichen : CHAR;
         Index   : INTEGER;

    BEGIN
      Index := 0;

      IF  readAgain & ~echo  THEN
        Write( lastChar );
      END;

      LOOP
         ReadEcho( TRUE, zeichen );

         IF  ( zeichen < ' ' ) & ( zeichen # 10C )  THEN
           EXIT;
         END;

         IF  ( zeichen = 10C ) OR ( zeichen = 177C )  THEN

            IF  Index > 0  THEN
              Write( 10C ); Write( ' ' ); Write( 10C );
              DEC( Index );
            ELSE
              Write( 7C );
            END;
         ELSE
            IF  zeichen < ' '  THEN
              Write( 7C );
            ELSE
              IF  Index <= HIGH( str )  THEN
                str[ Index ] := zeichen;
                INC( Index );
              ELSE
                Write( 10C ); Write( ' ' ); Write( 10C );
                Write( 7C );
              END;
            END;
         END;
      END; (* LOOP *)

      IF  Index <= HIGH( str )  THEN
        str[ Index ] := 0C;
      END;

      termCH := zeichen;
    END  ReadString;

(*---------------------------------------------------------------------------*)

  PROCEDURE ReadAgain;

   BEGIN
     readAgain := TRUE;
   END  ReadAgain;

(*---------------------------------------------------------------------------*)

  PROCEDURE WriteString ((* EIN/ -- *) str: ARRAY OF CHAR );

    VAR  Index : INTEGER;

    BEGIN
      Index := 0;

      WHILE  ( Index <= HIGH( str )) & ( str[ Index ] # 0C )  DO
        Write( str[ Index ]);
        INC( Index );
      END;
    END  WriteString;

(*---------------------------------------------------------------------------*)

  PROCEDURE WriteLn;

   BEGIN
     Write( 12C ); Write( 15C );
   END  WriteLn;

(*---------------------------------------------------------------------------*)

  PROCEDURE AssignRead ((* EIN/ -- *)     rp   : ReadProcedure;
                        (* -- /AUS *) VAR done : BOOLEAN       );
    BEGIN
      RawRead := rp;
      done    := TRUE;
    END  AssignRead;

(*---------------------------------------------------------------------------*)

  PROCEDURE AssignBusyRead ((* EIN/ -- *)     rp   : ReadProcedure;
                            (* -- /AUS *) VAR done : BOOLEAN       );
    BEGIN
      BusyRead := rp;
      done     := TRUE;
    END  AssignBusyRead;

(*---------------------------------------------------------------------------*)

  PROCEDURE AssignWrite ((* EIN/ -- *)     wp   : WriteProcedure;
                         (* -- /AUS *) VAR done : BOOLEAN        );
    BEGIN
      Write := wp;
      done  := TRUE;
    END  AssignWrite;

(*===========================================================================*)

BEGIN (* Terminal *)
  ctrlc      := TRUE;
  echo       := FALSE;
  readAgain  := FALSE;

  Write      := StdWrite;
  RawRead    := StdRead;
  BusyRead   := StdBusyRead;
  WriteError := PrintError;

END  Terminal.
