
PROGRAM copy_pas ;

  CONST
    chunk_size = 4096 ;
    fn_length = 64 ;

  TYPE
    buffer_type = PACKED ARRAY [ 1..chunk_size ] OF byte ;
    file_name_type = PACKED ARRAY [ 1..fn_length ] OF char ;

  VAR
    fname : STRING ;
    buf : buffer_type ;
    i, in_file, out_file : integer ;
    name : file_name_type ;

  FUNCTION gem_create( VAR fname : file_name_type ; mode : integer ) : integer;
    GEMDOS( $3C ) ;

  FUNCTION gem_open( VAR fname : file_name_type ; mode : integer ) : integer;
    GEMDOS( $3D ) ;

  PROCEDURE gem_close( handle : integer ) ;
    GEMDOS( $3E ) ;

  FUNCTION gem_read( handle : integer ; nbytes : long_integer ;
                VAR buf : buffer_type ) : long_integer ;
    GEMDOS( $3F ) ;

  FUNCTION gem_write( handle : integer ; nbytes : long_integer ;
                VAR buf : buffer_type ) : long_integer ;
    GEMDOS( $40 ) ;

  PROCEDURE gem_seek( nbytes : long_integer ; handle, mode : integer ) ;
    GEMDOS( $42 ) ;

  PROCEDURE copy_file( in_file, out_file : integer ) ;

    VAR
      n : long_integer ;

    BEGIN
      REPEAT
        gem_close( out_file ) ;         { Close down the output! }
        out_file := gem_open( name, 1 ) ;
        gem_seek( 0, out_file, 2 ) ;    { Seek end-of-file }
        n := gem_read( in_file, chunk_size, buf ) ;
        writeln( 'read chunk of ', n, ' bytes' ) ;
        IF n < 0 THEN
          BEGIN
            writeln( 'error ', n, ' on input file' ) ;
            halt ;
          END
        ELSE IF n > 0 THEN
          IF gem_write( out_file, n, buf ) = n THEN
            writeln( 'wrote chunk properly' )
          ELSE
            BEGIN
              writeln( 'error writing output file' ) ;
              halt ;
            END ;
      UNTIL n = 0 ;
    END ;

  BEGIN
    write( 'Source file: ' ) ;
    readln( fname ) ;
    FOR i := 1 TO length( fname ) DO
      name[i] := fname[i] ;
    name[ length(fname) + 1 ] := chr(0) ;
    in_file  := gem_open( name, 0 ) ;
    IF in_file >= 0 THEN
      writeln( 'opened input file' )
    ELSE
      BEGIN
        writeln( 'error ', in_file, ' opening input' ) ;
        halt ;
      END ;
    write( 'Destination file: ' ) ;
    readln( fname ) ;
    FOR i := 1 TO length( fname ) DO
      name[i] := fname[i] ;
    name[ length(fname) + 1 ] := chr(0) ;
    out_file := gem_create( name, 0 ) ;
    IF out_file >= 0 THEN
      writeln( 'opened output file' )
    ELSE
      BEGIN
        writeln( 'error ', out_file, ' opening output' ) ;
        halt ;
      END ;
    copy_file( in_file, out_file ) ;
    gem_close( in_file ) ;
    gem_close( out_file ) ;
  END.

