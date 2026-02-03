
{ file font.pas zum Erstellen von degas_font speziell fr Pascal-Programme
  Programmablauf es wird nach verschiedenen Zeichens„tzes gefragt und geladen
  bis die Maximale Anzahl oder ABBRUCH getastet wird. Zum Schluž die ausgabe
  alle geladenen Zeichens„tze .

  Um Poken zu k”nnen muž noch font_ext.o dazugelinkt werden

   Copyright by J. Isensee
____________________________________________________________________________}


PROGRAM font_1_pas  ;

CONST
     Max_font = 7 ;

TYPE
     path_name = STRING[80] ;
     font_typ = PACKED ARRAY[0..$FFF] OF CHAR  ;
     font_feld = ARRAY[1..max_font ] OF font_typ ;
     zeile_typ = PACKED ARRAY[0..15] OF CHAR;
     str255    = STRING[255] ;

VAR
   font : font_feld ;
   alt_font_adr : LONG_INTEGER ;
      C : CHAR ;
   i,max_i_font : INTEGER ;

 FUNCTION init_gem : INTEGER ;  EXTERNAL ;
 PROCEDURE exit_gem ; EXTERNAL ;
 FUNCTION get_in_file ( VAR parh,name : path_name ) : BOOLEAN ;EXTERNAL ;
 PROCEDURE draw_string ( x,y : INTEGER ; s : str255 ); EXTERNAL ;

  FUNCTION font_adresse ( VAR font : font_typ ): LONG_INTEGER ;
    FUNCTION adresse ( VAR font : font_typ ) : LONG_INTEGER ;  EXTERNAL ;
   BEGIN font_adresse := adresse ( font ) ;
   END;


FUNCTION  FCLOSE ( handle : INTEGER ) : INTEGER ; GEMDOS($3E);
FUNCTION  FSEEK ( OFFSET : LONG_INTEGER ;handle,mode : INTEGER ) :LONG_INTEGER;
          GEMDOS($42);
PROCEDURE Fread ( handle : INTEGER ; count : LONG_INTEGER ;
                  VAR buffer : zeile_typ ); GEMDOS($3F);


FUNCTION l_peek ( x : LONG_INTEGER ): LONG_INTEGER ; EXTERNAL ;

PROCEDURE Load_font ( VAR font : font_feld );

 LABEL 99 ;

 VAR path , name : path_name ;
     i,j,k, high_adr,low_adr : INTEGER ;
     erg : INTEGER ;
     adr,sc ,dummy,err : LONG_INTEGER ;
     p_file   : TEXT ;
    zeile : zeile_typ ;

 BEGIN
   Path := 'C:\*.FNT' ;
   name := '.FNT' ;
   I := 1 ;
   WHILE get_in_file ( path , name ) DO
     BEGIN
       { file auf und zu }
       reset ( p_file , name );
       erg := handle( p_file );    { bergang von Pascal- nach C-Notation }
         IF (erg > 0) THEN
           BEGIN
             sc := fseek ( 0 , erg , 2 );      { L„nge feststellen }
             DUMMY := fseek ( 0 ,erg , 0 );    { Zum Anfang zurck }
             IF (sc = $1000) OR (sc = $800) OR (sc = $801 ) THEN
               BEGIN
                 FOR j := 0 TO 255 DO
                  BEGIN
                     DUMMY := fseek ( j*16 ,erg , 0 );
                     fread ( erg , 16 , zeile );
                     FOR k := 0 TO 15 DO font[i,k*256+j]  := zeile[k] ;
                  END;
                  i := succ(i);
               END
               ELSE writeln( 'was war das');
               err := fclose ( erg );
           END;
         IF i > max_font THEN GOTO 99 ;  { in Pascal fehlt ein BREAK }
     END ; { do }
 99 :  max_i_font := pred(i) ;
 END; { of load_font }

 PROCEDURE chance ( font_adr : LONG_INTEGER );
  PROCEDURE L_poke ( ort, inhalt : LONG_INTEGER) ; EXTERNAL ;
 BEGIN
   L_poke ( $607e , font_adr );        { fr draw_string }
   L_poke ( $2924 , font_adr );        { fr Write () ;  }
 END;

 PROCEDURE alt_font ( font_adr : LONG_INTEGER );
  BEGIN
    chance ( font_adr );
  END ;

 PROCEDURE new_font ( i : INTEGER );
  BEGIN
   chance ( font_adresse ( font[i] ));
  END;

BEGIN
 alt_font_adr := l_peek ( $607e );                { alte Adresse Retten }
 writeln ( #27,'E Pascal-Test von Degas-Fonts ');
 WHILE keypress DO read(C);
 IF init_gem >= 0 THEN
    BEGIN
       load_font ( font );
       writeln( #27,'E');
       FOR i := 1 TO max_i_font DO
         BEGIN
           new_font(i);
           writeln( 'Dies ist ein Text in hoffentlicher neuer Schrift ');
           FOR C := #14 TO #255 DO write(C);
           writeln ;
         END;
       alt_font ( alt_font_adr );
       writeln( 'Dies ist ein Text in hoffentlicher alter Schrift ');
       FOR C := 'A' TO 'z' DO write(C);
       writeln;

    END;
 Exit_gem ;
 writeln('exit please Keypress !');
 readln ;
END.
