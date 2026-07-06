\ Implements:
\ rstrace ( -- )
\    Shows the calling sequence that is stored on the return stack,
\    without destroying the return stack.
\ .calls ( cfa -- )
\    Prints a list of all the words which call the word whose compilation
\    address is on the stack

only forth also hidden definitions
: probably-cfa? ( cfa -- flag)
  dup origin here within  ( address must be in the dictionary)
  if   dup 1 and 0=       ( the address must be even)
       if   w@ ['] here w@ =
       else drop false
       then
  else drop false
  then
;
: reasonable-ip? ( ip -- flag)
  dup  origin here between  ( ip flag)
  if  1 and 0= ( must be even ) else drop false then
;
: .current-word ( ip -- )
  find-cfa  ( cfa)
  c.id      ( )
;
: .last-executed ( ip -- )
  /token - token@  ( cfa)
  dup probably-cfa? 
  if c.id else drop ." ??" then
;
: .caller ( ip -- )
  td 18 to-column ." Called from "
  dup .current-word
  td 56 to-column ." at "
  .
;
: (rstrace ( -- )
  base @ hex
  rp0 @  rp@
  do   i @ dup reasonable-ip?
       if    dup .last-executed /token - .caller
       else  .
       then
       cr
  /n +loop
  base !
;
only forth hidden also forth definitions
: rstrace ( -- ) ( Return stack backtrace)
  rp@ rp0 @ u>
  if   ." Return Stack Underflow" rp0 @ rp!
  else (rstrace
then
;
: .calls ( cfa -- )
  origin   ( cfa origin)
  begin ( cfa search-start )
         2dup here  tsearch  ( cfa last [ found-at ] f )
  while  dup  .caller cr    ( cfa last found-at)
         nip ta1+
  repeat 2drop
;
only forth also definitions
