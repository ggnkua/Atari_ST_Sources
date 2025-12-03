
{$S4}

program batch ;

const {$i d:\pascal\libs\gemconst.pas }

type  c_type = packed array [1..80] of char ;

      {$i d:\pascal\libs\gemtype.pas }

var   result       : long_integer ;
      argumente    : integer ;
      filehandel   : text ;
      zeile,
      filename     : string ;
      laufwerk     : char ;
      pfad,
      programm,
      command,
      environment  : c_type ;
  
      {$i d:\pascal\libs\gemsubs.pas }



function pexec(     mode        : integer ;
                var programm    : c_type ;
                var command     : c_type ;
                var environment : c_type ) : long_integer ;

gemdos( $4b ) ;



procedure dsetdrv( laufwerk : integer ) ;

gemdos( $0e ) ;



procedure dsetpath( var pfad : c_type ) ;

gemdos( $3b ) ;



procedure string_to_c( zeile : string ; var c_string : c_type ) ;

var i : integer ;

begin
  for i := 1 to length( zeile ) do c_string[ i ] := zeile[ i ] ;
  c_string[ i ] := chr( 0 ) 
end ;



begin
  if init_gem >= 0 
  then begin
        argumente := cmd_args ;
        if argumente > 0
        then begin
               cmd_getarg( 1, filename ) ;
               io_check( false ) ;
               reset( filehandel, filename ) ;
               if io_result = 0
               then begin
                      readln( filehandel, zeile ) ;
                      laufwerk := zeile[ 1 ] ;
                      dsetdrv( ord( laufwerk ) - 65 ) ;
                      string_to_c( zeile, pfad ) ;
                      dsetpath( pfad ) ;
                      readln( filehandel, zeile ) ;
                      close( filehandel ) ;
                      string_to_c( zeile, programm ) ;
                      command[ 1 ] := chr( 0 ) ; 
                      environment[ 1 ] := chr( 0 ) ;
                      result := pexec( 0, programm, command, environment ) 
                    end 
             end ;
         exit_gem    
       end
end.
