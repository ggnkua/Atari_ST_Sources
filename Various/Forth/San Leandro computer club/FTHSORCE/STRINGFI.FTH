: string-fwrite ( addr count l.byteno fd -- count )
  drop ldrop nip
;
: string-fopen ( addr len -- string-fd )
  (get-fd  ?dup 0= abort" all fds used "  ( addr len fd )
  >r initbuf                              ( )
  bflimit @  dup bfend ! bftop !

  0                 fid    !
  modify            fmode  !
  ['] nullread      fread  !
  ['] string-fwrite fwrite !
  ['] drop          fclose !
  ['] noop          falign !
  r>
;
: string-load ( addr len -- )
  string-fopen (load
;
: mload ( -- )
  pad readit   ( ending-address )
  pad tuck -   ( start-address len )
  string-fopen ( fd ) 
  >r r@ (load
  r> close
;
