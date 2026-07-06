\ Emacs-style line editing for command lines.  Needs to be more
\ efficient at updating the screen, rather than doing everything
\ a character at a time.  See "install-line-editing" for functions
\ implemented and key bindings

\ To run this successfully under Unix, you have to
\ "stty nl cbreak -echo"

\ requires terminals.f
only forth also definitions

decimal

  \ maximum size of input buffer
nuser buflen
  \ address of start of input buffer
nuser bufstart
  \ number of characters currently in input buffer
nuser bufcurrent
  \ character that was most recently typed, or character to add
nuser lastchar
  \ position of cursor within line
nuser bufcursor   0 bufcursor !
  \ remembers size of previous line
nuser last-bufcurrent  0 last-bufcurrent !

: #after ( -- n )
  bufcurrent @ bufcursor @ -
;
: leading ( -- bufstart bufcursor )
  bufstart @ bufcursor @
;
: cursor-address ( -- addr )
  leading +
;
: before-cursor ( -- bufstart-addr cursor-address-1 )
  leading 1- bounds swap
;
: -chars ( n -- ) 0 ?do left  loop  ;
: +chars ( n -- ) 0 ?do right loop  ;
only forth also definitions
: forward-in-buf
  #after 0>
  if   1  bufcursor +!
  else beep
  then
;
: forward-character
  forward-in-buf
  right
;
: backward-character
  bufcursor @
  if   -1 bufcursor +!
       left
  else beep
  then
;
: erase-next-character
  bufcurrent @
  if  -1  bufcurrent +!
       cursor-address   dup 1+  swap
       #after       cmove
\ Atari  -- This is a CROCK! fix it
       cursor-address #after  type
       kill-line
       #after -chars
\       delete-char
  else beep
  then
;
: erase-previous-character
  bufcursor @
  if   -1 bufcursor +!
       left
       erase-next-character
  else beep
  then
;
: insert-character
  bufcurrent @  1+   buflen @  min   bufcurrent !
  cursor-address   dup 1+  ( addr addr+1 )
  #after 1-  cmove>
  lastchar c@  cursor-address  c!
  lastchar c@
  forward-in-buf
  #after
  if   insert-char
  else emit
  then
\ Atari
  cursor-address #after type   #after -chars
;
: beginning-of-line
   bufcursor @ -chars
  bufcursor off
;
: end-of-line
  #after +chars
  bufcurrent @ bufcursor !
;
: finish-line
\  end-of-line
  bufcurrent @ last-bufcurrent !
  bufcurrent @ span !
  buflen @ bufcurrent !
  cr
  0 bufcursor !
;
: kill-to-end-of-line
  bufcursor @ bufcurrent !
  kill-line
;
: grab-last-line
  last-bufcurrent @ dup  bufcurrent ! bufcursor !
  leading type
;
: retype-line
  cr
  bufstart @ bufcurrent @  type
  #after -chars
;
: erase-blanks-backward ( -- )
  bufcursor @
  if
    before-cursor   ( bufstart bufend )
    do  i c@
         bl <> if leave then
         erase-previous-character
    -1 +loop
  then
;
: erase-non-blanks-backward ( -- )
  bufcursor @
  if
     before-cursor   ( bufstart bufend )
     do  i c@
         bl = if leave then
         erase-previous-character
     -1 +loop
   then
;
: erase-previous-word 
  erase-blanks-backward
  erase-non-blanks-backward
;
\ XXX need a word to delete n characters.  Then find the number of 
\ characters to delete and delete them all at once
: erase-blanks-forward ( -- )
  #after 0
  ?do  cursor-address c@
       bl <> if leave then
       erase-next-character
  loop
;
: erase-non-blanks-forward ( -- )
  #after 0
  ?do cursor-address  c@
      bl = if leave then
      erase-next-character
  loop
;
: erase-next-word 
  erase-blanks-forward
  erase-non-blanks-forward
;
: beginning-of-word
  bufcursor @
  if
    before-cursor   ( bufstart bufend )
    do i c@
       bl = if leave then
       -1 bufcursor +!  left
    -1 +loop
  then
;
: end-of-word ( -- )
  cursor-address  #after   bounds
  ?do i c@
      bl = if leave then
      1 bufcursor +!  right
  loop
;
: forward-word
  forward-character
  end-of-word
;
: backward-word
  backward-character
  beginning-of-word
;
: quote-next-character
  key lastchar c!  insert-character
;

only forth also definitions
vocabulary keys-forth

nuser keys  ' keys-forth keys !

create name-buf 32 allot

: add-char-to-string ( str char -- )
  over ( str char str )
  count dup >r ( str char addr len )
  + c!  ( str )
  r> 1+ swap c!
;
: add-char-to-name ( str char -- )
  dup bl <
  if   ( control character so translate to ^ form )  ( str char )
     over ascii ^ add-char-to-string  ( str char )
     ascii A 1- +  ( str char' )
  then
  add-char-to-string
;
defer not-found
' beep is not-found

: do-command ( -- )
  name-buf lastchar c@  add-char-to-name
  name-buf keys @ >body >user vfind ( cfa true | addr false )
  if  execute else not-found then
;

defer printable-char
' insert-character is printable-char
: clear-name-buf ( -- )
  name-buf 32 blank  0 name-buf w!
;
: (newexpect   (s adr len -- )
   dup span ! buflen !  bufstart !
   0 bufcurrent !  0 bufcursor !
   begin   bufcurrent @  buflen @ < 
   while   key  dup  lastchar c!  dup bl <
     if    drop clear-name-buf  do-command
     else  127 = if  erase-previous-character  else  printable-char   then
     then
   repeat
;

only forth also keys-forth definitions

: ^F forward-character ;
: ^B backward-character ;
: ^A beginning-of-line ;
: ^E end-of-line ;
: ^D erase-next-character ;
: ^H erase-previous-character ;
: ^K kill-to-end-of-line ;
: ^M finish-line ;
: ^J finish-line ;
: ^Q quote-next-character ;
: ^L retype-line ;
: ^[ key lastchar c! do-command ;
: ^[h erase-previous-word ;
: ^[d erase-next-word ;
: ^[f forward-word ;
: ^[b backward-word ;
: ^[= grab-last-line ;

only forth also definitions
: emacs-edit
  ['] (newexpect ['] expect (is
  ['] crlf    ['] cr     (is
;
: (cold-hook  (cold-hook  emacs-edit ;
' (cold-hook is cold-hook
