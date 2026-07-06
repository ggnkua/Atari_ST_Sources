\ Implements needs.  This works as follows:
\
\ needs foo tools.fth
\
\ If foo is not defined, the file tools.fth will be loaded, which should
\ define foo.  If foo is already defined, nothing will happen.

: needs ( -- ) ( Input Stream: desired-word file-name )
  bl word find       ( str false | cfa true )
  nip  bl word swap  ( filename flag )
  if    drop
  else  "load
  then
;
