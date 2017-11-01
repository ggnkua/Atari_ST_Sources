IMPLEMENTATION MODULE  Filename;

(*****************************************************************************)
(*                                                                           *)
(* Rekompiliertes LPR-Originalmodul.  hk, Dez-89                             *)
(*                                                                           *)
(*****************************************************************************)



FROM    SYSTEM  IMPORT  (* PROC *) ADR;

IMPORT  GEMDOS; (*      (* PROC *) GetDrv, GetPath;
                 *)

IMPORT  AES;    (*      (* PROC *) FileSelectorInput;
                 *)



PROCEDURE  AppendStr ((* EIN/ -- *) VAR quelle : ARRAY OF CHAR;
                      (* EIN/AUS *) VAR ziel   : ARRAY OF CHAR;
                      (* EIN/AUS *) VAR idx    : INTEGER;
                      (* EIN/ -- *)     ch1,
                      (* EIN/ -- *)     ch2    : CHAR          );

   VAR  Index : INTEGER;

   BEGIN
     IF  quelle[ 0 ] > ' '  THEN

        IF  ch1 # ' '  THEN
          ziel[ idx ] := ch1;
          INC( idx );
        END;

        Index := 0;
        WHILE    ( Index <= HIGH( quelle )) & ( quelle[ Index ] > ' ' )
               & ( idx   <= HIGH( ziel   ))
        DO
           ziel[ idx ] := quelle[ Index ];
           INC( idx );
           INC( Index );
        END;

        IF  ch2 # ' '  THEN
          ziel[ idx ] := ch2;
          INC( idx );
        END;

     END; (* IF name *)
   END  AppendStr;

(*---------------------------------------------------------------------------*)

PROCEDURE  compose ((* EIN/AUS *) VAR n : filename;
                    (* EIN/AUS *) VAR d : filename;
                    (* -- /AUS *) VAR s : ARRAY OF CHAR );

   VAR  Index : INTEGER;

   PROCEDURE  app ((* EIN/AUS *) VAR str1 : ARRAY OF CHAR;
                   (* EIN/AUS *) VAR str2 : ARRAY OF CHAR;
                   (* EIN/ -- *)     ch1,
                   (* EIN/ -- *)     ch2  : CHAR          );

      BEGIN
        IF  str1[ 0 ] > ' '  THEN
          AppendStr( str1, s, Index, ch1, ch2 );
        ELSE
          AppendStr( str2, s, Index, ch1, ch2 );
        END;
      END  app;

   BEGIN (* compose *)
     Index := 0;
     WHILE  Index <= HIGH( s )  DO
       s[ Index ] := 0C;
       INC( Index );
     END;

     Index := 0;
     IF  n.drv <= ' '  THEN
       s[ 0 ] := d.drv;
     ELSE
       s[ 0 ] := n.drv;
     END;

     IF  s[ 0 ] >= ' '  THEN
       s[ 1 ] := ':';
       Index := 2;
     END;

     IF  (( n.path[ 0 ] >  ' ' )  &  ( n.path[ 0 ] # '\' ))  OR
         (( n.path[ 0 ] <= ' ' )  &  ( d.path[ 0 ] # '\' ))
     THEN
        s[ Index ] := '\';
        INC( Index );
     END;

     app( n.path, d.path, ' ', ' ' );

     IF  s[ Index - 1 ] # '\'  THEN
       s[ Index ] := '\';
       INC( Index );
     END;

     app( n.name, d.name, ' ', ' ' );
     app( n.ext,  d.ext,  '.', ' ' );

   END  compose;

(*---------------------------------------------------------------------------*)

PROCEDURE  getspec ((* EIN/ -- *) VAR n : filename;
                    (* -- /AUS *) VAR s : ARRAY OF CHAR );

   VAR  Index : INTEGER;

   BEGIN
     Index := 0;
     WHILE  Index <= HIGH( s )  DO
       s[ Index ] := 0C;
       INC( Index );
     END;

     Index := 0;
     AppendStr( n.name, s, Index, ' ', ' ' );
     AppendStr( n.ext,  s, Index, '.', ' ' );
   END  getspec;

(*---------------------------------------------------------------------------*)

PROCEDURE  parse ((* EIN/ -- *) VAR s : ARRAY OF CHAR;
                  (* -- /AUS *) VAR n : filename      );

   VAR  KompStartIdx,
        DoppelpunktIdx,
        PfadEndeIdx,
        PunktIdx,
        StringEnde   : INTEGER;

   PROCEDURE copyStr ((* -- /AUS *) VAR str    : ARRAY OF CHAR;
                      (* EIN/ -- *)     maxIdx : INTEGER       );

      VAR  Index : INTEGER;

      BEGIN
        Index := 0;
        WHILE  Index <= HIGH( str )  DO
          str[ Index ] := 0C;
          INC( Index );
        END;

        Index := 0;

        IF  maxIdx > ( HIGH( str ) + KompStartIdx )  THEN
          maxIdx := HIGH( str ) + KompStartIdx;
        END;

        WHILE  KompStartIdx <= maxIdx  DO
           str[ Index ] := s[ KompStartIdx ];
           INC( Index );
           INC( KompStartIdx );
        END;
      END  copyStr;


   BEGIN (* parse *)
     StringEnde := 0;
     WHILE  ( StringEnde <= (* < *) HIGH( s ))  &  ( s[ StringEnde ] # 0C )  DO
       INC( StringEnde );
     END;
     IF  s[ StringEnde ] = 0C  THEN
       DEC( StringEnde );
     END;

     PfadEndeIdx := StringEnde;
     WHILE  ( PfadEndeIdx >= 0 )  &  ( s[ PfadEndeIdx ] # '\' )  DO
       DEC( PfadEndeIdx );
     END;

     PunktIdx := StringEnde;
     WHILE  ( PunktIdx >= 0 )  &  ( s[ PunktIdx ] # '.' )  DO
       DEC( PunktIdx );
     END;
     IF  PunktIdx <= PfadEndeIdx  THEN
       PunktIdx := StringEnde + 1;
(*       DoppelpunktIdx := StringEnde;
     ELSE
       DoppelpunktIdx := PunktIdx;     *)
     END;


     WHILE  ( DoppelpunktIdx >= 0 )  &  ( s[ DoppelpunktIdx ] # ':' )  DO
       DEC( DoppelpunktIdx );
     END;

     IF  PfadEndeIdx = -1  THEN
       PfadEndeIdx := DoppelpunktIdx;
     END;

     KompStartIdx := 0;
     WHILE  s[ KompStartIdx ] = ' '  DO
       INC( KompStartIdx );
     END;

     n.drv := 0C;
     IF  DoppelpunktIdx > 0  THEN
       n.drv := s[ DoppelpunktIdx - 1 ];
     END;

     KompStartIdx := DoppelpunktIdx + 1;
     copyStr( n.path, PfadEndeIdx );

     KompStartIdx := PfadEndeIdx + 1;
     copyStr( n.name, PunktIdx - 1 );

     KompStartIdx := PunktIdx + 1;
     copyStr( n.ext, StringEnde );
   END  parse;

(*---------------------------------------------------------------------------*)

PROCEDURE ClearFilename ((* -- /AUS *) VAR fn : filename );

   PROCEDURE clearStr ((* -- /AUS *) VAR string : ARRAY OF CHAR );

      VAR  Index : INTEGER;

      BEGIN
        FOR  Index := 0  TO  HIGH( string )  DO
          string[ Index ] := 0C;
        END;
      END  clearStr;


   BEGIN (* ClearFilename *)
     WITH  fn  DO
       drv := 0C;
       clearStr( path );
       clearStr( name );
       clearStr( ext );
     END; (* WITH *)

   END  ClearFilename;

(*---------------------------------------------------------------------------*)

PROCEDURE GetDriveAndPath ((* -- /AUS *) VAR fn : filename );

   VAR  Drive : CARDINAL;

   BEGIN
     ClearFilename( fn );

     GEMDOS.GetDrv( Drive );
     fn.drv := CHR( Drive + 41H );

     GEMDOS.GetPath( fn.path, Drive + 1 );

   END  GetDriveAndPath;

(*---------------------------------------------------------------------------*)

PROCEDURE SelectFilename ((* EIN/AUS *) VAR mask : filename;
                          (* EIN/AUS *) VAR name : filename;
                          (* -- /AUS *) VAR exit : BOOLEAN  );

   VAR  ExitButton : INTEGER;
        PfadRec    : filename;
        EinPfad,
        AusPfad    : fullname;

   BEGIN
     getspec( name, AusPfad );
     GetDriveAndPath( PfadRec );
     PfadRec.ext  := '*';
     PfadRec.name := '*';
     compose( mask, PfadRec, EinPfad );

     AES.FileSelectorInput( ADR( EinPfad ), ADR( AusPfad ), ExitButton );

     exit := ExitButton = 0;

     parse( EinPfad, name );
     parse( AusPfad, PfadRec );

     name.name := PfadRec.name;
     name.ext  := PfadRec.ext;
   END  SelectFilename;

END  Filename.
