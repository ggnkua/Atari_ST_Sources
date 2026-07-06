\ Command completion package a la TENEX.

decimal
\ index of char at the beginning of the latest word in the input buffer
variable start-of-word

variable #candidates   0 #candidates !

: namelen ( length-byte -- length-portion )
\ width @ and
;
: @char ( addr -- char ) \ Removes any tag bits
  c@ 127 and
;

: word-to-string ( -- str )
  bufstart   @  start-of-word @  +  ( addr of start of word )
  bufcursor  @  start-of-word @  -  ( start-addr len )
  'word  place
  'word
;
: collect-string ( -- str )
  ( finds start of this word and the current length of the word )
  ( leaves address of a packed string which contains that word )
  end-of-word
  bufcursor @    start-of-word !
  bufcursor @
  if
       bufstart @  bufcursor @  1-  bounds  ( bufend bufstart )
       swap  ( bufstart bufend )  ( loop runs backwards over buffer )
       do i c@ bl = if leave then
          -1 start-of-word +!
       -1 +loop
  then
  word-to-string  ( str )
;
: add-space ( -- )  bl lastchar c! insert-character ;

\ leaves address of temporary buffer space for collecting match candidates
: candidates  ( -- addr ) pad 100 + ;

: end-of-name? ( nfa+n -- nfa+n f )
  dup c@  128 and
;
: substring?  ( addr nfa -- f )

  2dup c@ namelen swap c@   ( addr nfa nlen tlen )
  < if 2drop false exit then  ( not a substring if string longer than name )

  true -rot  ( true addr nfa )
  1+ swap    ( true nfa+1 addr )
  count bounds
  ?do   ( f nfa+n )
      dup @char  ( f nfa+n char-in-name )
      i c@ <>    ( f nfa+n character-mismatch? )
      if   nip  false swap  leave   then
      1+
  loop  ( f nfa+m )
  drop
;
: new-candidate ( lfa -- lfa )
  dup l>name  ( lfa nfa )
    candidates #candidates @ na+   !   ( lfa )
  1 #candidates +!   ( lfa )
;
: find-candidates-in-thread ( addr thread -- addr )
  begin  dup origin u>            ( addr lfa lfa )
  while  2dup l>name  substring?  ( addr lfa f )
         if new-candidate then
       link@
  repeat
  drop  ( addr )
;
: find-candidates-in-voc ( addr voc -- addr )
  over swap hash link@ ( addr thread )
  find-candidates-in-thread
;

: find-candidates ( str -- )
  #candidates off
  prior off        ( addr )
  #vocs 0
  do
     context i na+ @   dup         ( addr voc voc )
     if   dup prior @ over prior !  = ( addr voc prior=voc? )
          if   drop                   ( addr )
          else find-candidates-in-voc ( addr )
          then
     else drop                        ( addr )
     then
  loop
  drop
;
\ True if "char" is different from the "char#"-th character in str
: cclash? ( char# char str -- char# char f )
  count namelen      ( char# char str+1 count )
  3 pick <=          ( char# char str+1 f )
  if   drop true     ( str too short is a clash )
  else 2 pick +      ( char# char address-in-string )
       @char         ( char# char str-char )
       over <>
  then
;

\ If all the candidate words have the same character in the "char#"-th
\ position, leave that character and true, otherwise just leave false.
: candidates-agree? ( char# -- char true | false )
  candidates @       ( char# first-candidate-nfa )
  2dup c@ namelen >=         ( char# first-nfa f )

\ if the test string is the same length as the first candidate,
\ then the first candidate has no char at position char#, so there
\ can be no agreement.  Since the test string is a substring of all
\ candidates, the > condition should not happen

  if   2drop false  exit then  ( char# false )
  true -rot   ( true char# first-candidate )
       over + 1+ @char         ( f char# char )

  ( now test all other candidates to see if their "char#"-th character )
  ( is the same as that of the first candidate )

       candidates na1+  #candidates @  1-  /n*  bounds
       ?do   ( f char# char )
            i @ cclash?  ( f char# char f )
            if  rot drop  false -rot  leave then
       /n +loop        ( f char# char )
       rot if   nip true   else   2drop false   then
;
: expand-initial-substring ( -- )
  bufcursor @  start-of-word @  -
  begin                          ( current-length )
         dup candidates-agree?   ( current-len [ char true ] | false )
  while  lastchar c! insert-character
         1+                      ( current-length )
  repeat
  drop
;
\ highly dependent on the format on names in the dictionary
: one-candidate? ( -- f )
  ( true if there is only one candidate or if they all are the same name )
  true   ( prime the loop )
  candidates  #candidates @ /n*  bounds
  ?do  i @        ( f addr1 )
       candidates @ dup c@ namelen  ( f addr1 addr2 len )
       1+ ( include the length byte in the comparison )
       compare   ( f mismatch? )
       if  drop false leave then
  /n +loop
;
: do-erase ( -- ) ( Side effect: bufcurrent and bufcursor may be reduced )
  begin
    word-to-string   ( addr )
    find-candidates
    #candidates @ 0=
  while
    erase-previous-character 
  repeat
;
defer word-is-complete
' add-space is word-is-complete
: do-expand ( -- )
  expand-initial-substring
 ( If expansion does not result in a unique choice, beep )
  one-candidate?
  if  word-is-complete  else beep  then
;
: expand-word ( max-len bufstart current char -- ... )
              ( ... -- max-len bufstart new-current' char )
  collect-string   ( str )
  find-candidates  ( )
  #candidates @
  if   do-expand   else  do-erase  then
;
: show-candidates  ( -- )
       candidates #candidates  @  /n* bounds
       ?do  i @ .id  /n +loop
;
: do-show ( max-len bufstart current-cnt char -- ... )
          ( ...  max-len bufstart current-cnt char )
  cr
  collect-string   ( str )
  dup c@
  if   find-candidates 
       show-candidates
  else drop ." Any word at all is a candidate." cr
            ." Use words to see the entire dictionary"
  then
  retype-line
;

only forth also keys-forth definitions

: ^@ expand-word ;
: ^_ do-show ;

only forth also definitions
