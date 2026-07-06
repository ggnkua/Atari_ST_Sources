\ From Perry/Laxen, with changes due to vocabulary threads in user area
\ Display the WORDS in the Context Vocabulary         27Sep83map
create tbuf #threads /link * allot
: largest (s addr n -- addr' val )
   over 0 swap rot 0  ( addr 0 addr  n 0 )
   do   2dup link@ u<   ( addr-largest largest thisaddr  largest<thisone? )
      if   nip nip      ( this-addr )
           dup link@ over  ( this-addr this-one this-addr )
      then              ( largest-addr largest this-addr )
      /link +
   loop   drop
;
: follow ( voc -- )
  tbuf #threads /link * cmove
;
: another? ( -- [ nfa ] more? )
  tbuf #threads largest  ( largest-thread-addr largest-link )
  dup origin u>          ( largest-thread-addr largest-link more? )
  if   tuck link@ swap link!  l>name true
  else 2drop false
  then
;
: >threads >body >user ;
: over-vocabulary (s cfa-of-word-to-execute voc-cfa -- )
  >threads
  follow
  begin  another?   ( cfa  [ nfa ] flag )
  while             ( cfa nfa )
     n>link over execute
  repeat
;

: words   (s -- )
   tabstops @  td 14 tabstops !
   ??cr
   context @ follow
   begin   another?
   while                     ( nfa )
     dup c@ th 1f and  .tab  ( nfa )
     .id
     key? if  tabstops ! exit then
   repeat
   tabstops !
;

only definitions forth also
: words    words ;
only forth also definitions
