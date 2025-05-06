
{ FixPas - Patch bugs in PASGEM library and COMPILER.PRG; resultant version is
    identical with 1.02.  Compile this patch program for TOS (but it doesn't
    really matter much).  To perform the patch after compiling the program,
      1.  Make a copy of your master disk (or your normal Pascal disk)
      2.  Copy the FIXPAS.TOS program to this new disk.
      3.  From either TOS or the Pascal manager, run the FIXPAS program.
    The new disk now contains patched versions of the GEM library and the
    Pascal Compiler. }

PROGRAM FixPas ;

  VAR
    f : PACKED FILE OF byte ;
    patch_pos : long_integer ;

  PROCEDURE patch( old_val, new_val : BYTE ) ;

    BEGIN
      get( f, patch_pos ) ;
      IF (f^ <> old_val) AND (f^ <> new_val) THEN
        BEGIN
          writeln( 'File doesn''t match: ', patch_pos:6:h, ' ', f^:2:h ) ;
          halt
        END ;
      f^ := new_val ;
      put( f, patch_pos ) ;
      patch_pos := patch_pos + 1 ;
    END ;

  PROCEDURE patch_pasgem ;

    BEGIN
      reset( f, 'pasgem' ) ;

      patch_pos := 11587 {$2d43} ;
      patch( $0e, $0c ) ;

      patch_pos := 11600 {$2d50} ;
      patch( $5c, $58 ) ;

      patch_pos := 21902 {$558e} ;
      patch( $54, $47 ) ;

      patch_pos := 37094 {$90e6} ;
      patch( $48, $38 ) ;
      patch( $c5, $05 ) ;
      patch( $d1, $e5 ) ;
      patch( $c5, $44 ) ;
      patch( $d1, $d0 ) ;
      patch( $c5, $c4 ) ;

      patch_pos := 37144 {$9118} ;
      patch( $67, $60 ) ;
    END ;

  PROCEDURE patch_compiler ;

    BEGIN
      reset( f, 'compiler.prg' ) ;

      patch_pos := 106550 {$1a036} ;
      patch( $46, $7c ) ;
      patch( $61, $46 ) ;
      patch( $74, $62 ) ;
      patch( $61, $74 ) ;
      patch( $6c, $61 ) ;
      patch( $20, $6c ) ;
      patch( $65, $20 ) ;
      patch( $72, $65 ) ;

      patch_pos := 106559 {$1a03f} ;
      patch( $6f, $72 ) ;
      patch( $72, $6f ) ;
      patch( $21, $72 ) ;
      patch( $5d, $21 ) ;
      patch( $5b, $20 ) ;
      patch( $20, $5d ) ;
      patch( $41, $5b ) ;
      patch( $62, $41 ) ;
      patch( $6f, $62 ) ;
      patch( $72, $6f ) ;
      patch( $74, $72 ) ;
      patch( $20, $74 ) ;

      patch_pos := 122165 {$1dd35} ;
      patch( $01, $02 ) ;
    END ;

  BEGIN
    patch_pasgem ;
    patch_compiler ;
  END.


