
PROGRAM dir_test ;

  TYPE
    fn_range = 1..14 ;
    fname = PACKED ARRAY [ fn_range ] OF char ;
    frec = PACKED RECORD
             reserved : PACKED ARRAY [ 0..19 ] OF byte ;
             resvd2 : byte ;
             attrib : byte ;
             time_stamp : integer ;
             date_stamp : integer ;
             size : long_integer ;
             name : fname ;
           END ;
    path_name = PACKED ARRAY [ 1..80 ] OF char ;

  VAR
    r : frec ;
    i : fn_range ;
    path_string : STRING ;
    path : path_name ;

  PROCEDURE set_dta( VAR buf : frec ) ;
    GEMDOS( $1a ) ;

  FUNCTION get_first( VAR path : path_name ; search_attrib :integer ):integer ;
    GEMDOS( $4e ) ;

  FUNCTION get_next : integer ;
    GEMDOS( $4f ) ;

  PROCEDURE show_file( VAR r : frec ) ;

    VAR
      i : fn_range ;

    BEGIN
      WITH r DO
        BEGIN
          write( attrib:2:h, ' ', time_stamp:4:h, ' ', date_stamp:4:h, ' ',
                size:8:h, ' ' ) ;
          i := 1 ;
          WHILE (i <= 14) AND (name[i] <> chr(0)) DO
            BEGIN
              write( name[i] ) ;
              i := i + 1
            END ;
          writeln ;
        END ;
    END ;

  BEGIN
    write( 'search path: ' ) ;
    readln( path_string ) ;
    FOR i := 1 TO length( path_string ) DO
      path[i] := path_string[i] ;
    path[ length(path_string)+1 ] := chr(0) ;
    set_dta( r ) ;
    IF get_first( path, 0 ) < 0 THEN
      writeln( 'no files match specification!' )
    ELSE
      REPEAT
        show_file( r ) ;
      UNTIL get_next < 0 ;
  END.


