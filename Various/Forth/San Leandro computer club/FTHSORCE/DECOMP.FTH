\ From Perry/Laxen, with suitable modification for the Unix F83
\ Structured decompilation of conditionals added by Mitch Bradley

\    A Forth decompiler is a utility program that translates
\ executable forth code back into source code.  Normally this is
\ impossible, since traditional compilers produce more object
\ code than source, but in Forth it is quite easy.  The decompiler
\ is almost one to one.
\ It was written with modifiability in mind, so if you add your
\ own special compiling words, it will be easy to change the
\ decompiler to include them.  This code is highly implementation
\ dependant, and will NOT work on other Forth system.  To invoke
\ the decompiler, use the word SEE <name> where <name> is the
\ name of a Forth word.

decimal

\ Like ." but goes to a new line if needed.
: cr." ( -- ) skipstr dup ?line type ;
: .." ( -- ) compile cr." ," ; immediate

\ Positional case defining word                       28AUG83HHL
( Subscripts start FROM 0 )
: out   ( # apf -- ) ( report out of range error )
   cr  ." subscript out of range on "  dup body>
   c.id  ."    max is " ?   ."    tried " .  quit   ;
: map  ( # apf -- a ) ( convert subscript # to address a )
   2dup @  u< if   na1+ swap na+   else   out  then   ;
: maptoken  ( # apf -- a ) ( convert subscript # to address a )
   2dup @  u< if   na1+ swap /token * +   else   out  then   ;

: case:   (s n --  ) ( define positional case defining word )
   constant  hide    ]
   does>   ( #subscript -- ) ( executes #'th word )
     maptoken  token@  execute   ;

\ associative:                table lookup def. word  01mar82hhl
\ : associative:
\    constant
\    does>         (s n -- index )
\       dup @              ( n pfa cnt )
\       -rot dup @ 0       ( cnt n pfa cnt 0 )
\       do   na1+   2dup @ = ( cnt n pfa' bool )
\          if 2drop drop   i 0 0   leave   then
\             ( clear stack and return index that matched )
\       loop   2drop
\ ;
\ pf contains: n ( normal ) token, token, ...

: tassociative:
   constant
   does>         (s n -- index )
      dup @              ( n pfa cnt )
      dup >r -rot na1+        ( cnt n table-addr )
      r> 0                    ( cnt n table-addr cnt 0 )
      do   2dup token@ =          ( cnt n pfa' bool )
         if 2drop drop   i 0 0   leave   then
            ( clear stack and return index that matched )
         ta1+
      loop   2drop
;

\ decompile each type of word                         02oct83map
defer (see
vocabulary hidden
hidden definitions

: nulldis ( cfa -- ) drop ." <no disassembler>" ;
defer disassemble  ' nulldis is disassemble

\ Breaks is a list of places in a colon definition where control
\ is transferred without there being a branch nearby.
\ Each entry has two items: the address and a number which indicates
\ what kind of branch target it is (either a begin, for backward branches,
\ a then, for forward branches, or an exit.

: breaks pad ;
variable end-breaks

: add-break ( break-address break-type -- )
  end-breaks @ 2!  /n 2*  end-breaks +!
;
variable break-type  variable break-addr   variable where-break
: next-break ( -- break-address break-type )
  -1 break-addr !   ( prime stack)
  end-breaks @  breaks
  ?do  i  2@ over   break-addr @ u<
       if  break-type !  break-addr !  i where-break ! else 2drop then
  /n 2* +loop
  break-addr @  -1  <>  if -1 -1 where-break @ 2! then
;
: forward-branch? ( ip-of-branch-token -- f )
  dup >target u<
;
\ Bare-if? checks to see if the target address on the stack was
\ produced by an if with no else.  This is used to decide whether
\ to put a "then" at that target address.  If the conditional branch
\ to this target is part of an "if else then", the target address
\ for the "then" is found from the "else".  If the conditional branch
\ to this target was produced by a "while", there is no "then".
: bare-if? ( ip-of-branch-target -- f )
  /branch - /token - dup token@  ( ip' possible-branch-cfa )
  dup ['] branch  =    ( unconditional branch means else or repeat )
  if  drop drop false exit then  ( ip' cfa )
  ['] ?branch =  ( cond. forw. branch is for an 'if then' with null body)
  if   forward-branch?
  else drop true
  then
;
\ While? decides if the conditional branch at the current ip is
\ for a while as opposed to an if.  It finds out by looking at the
\ target for the conditional branch;  if there is a backward branch
\ just before the target, it is a while.
: while? ( ip-of-?branch -- f )
  >target
  /branch - /token - dup token@  ( ip' possible-branch-cfa )
  ['] branch =           ( looking for the uncond. branch from the repeat )
  if  forward-branch? 0= ( if the branch is forward, it's an if .. else )
  else drop false
  then
;
: indent ( -- )
  #out @ lmargin @ > if cr then
  lmargin @ #out @ - spaces
;
: +indent ( -- ) indent 6 lmargin +! ;
: -indent ( -- ) -6 lmargin +! indent ;
: <indent ( -- ) -6 lmargin +! +indent ;

: .begin ( -- ) +indent .." begin " ;
: .then  ( -- ) -indent .." then  " ;

\ Extent holds the largest known extent of the current word, as determined
\ by branch targets seen so far.  This is used to decide if an exit should
\ terminate the decompilation, or whether it is "protected" by a conditional.
variable extent  extent off
: umax ( u1 u2 -- umax ) 2dup < if swap then drop ;
: +extent ( possible-new-extent -- )
  extent @ umax extent !
;
: +branch ( ip-of-branch -- next-ip )  ta1+ /branch + ;
: scan-branch ( ip-of-?branch -- ip' )
  dup dup forward-branch?
  if    >target dup +extent   ( branch-target-address)
        dup bare-if? ( ip f ) ( f is true if this is an if branch )
        if   ['] .then add-break
        else drop
        then
  else >target ['] .begin add-break
  then
  +branch
;

: scan-unnest ( ip -- ip' | 0 )
  dup extent @ u>= if drop 0 else ta1+ then
;
: .branch ( ip -- ip' )
  dup forward-branch?
  if   <indent .." else  "
  else -indent .." repeat "
  then
  +branch
;
: .?branch ( ip -- ip' )
  dup forward-branch?
  if  dup while?
      if   <indent .." while "
      else +indent .." if    "
      then
  else -indent .." until " then
  +branch
;

: .do    ( ip -- ip' )  +indent .." do    " +branch ;
: .?do   ( ip -- ip' )  +indent .." ?do   " +branch ;
: .loop  ( ip -- ip' )  -indent .." loop  " +branch ;
: .+loop ( ip -- ip' )  -indent .." +loop " +branch ;

: classify-literal ( n -- ) ( guess what kind of constant n is )
  dup printable?
  if   .." ascii " dup emit .."  ( " . .." ) "
  else . then
;
\ first check for word being immediate so that it may be preceded
\ by [compile] if necessary
: check-[compile] ( cfa -- cfa )
  dup immediate? if .." [compile] " then
;
: .word       (s ip -- ip' )
   dup token@ check-[compile] ?cr c.id   ta1+   ;
: skip-word ( ip -- ip' )   ta1+ ;
: .inline     (s ip -- ip' )
   ta1+ dup @  classify-literal  na1+   ;
: skip-inline (s ip -- ip' ) ta1+ na1+ ;
: .llit       (s ip -- ip' )
   ta1+ dup l@ l. la1+  ;
: skip-llit   (s ip -- ip' ) ta1+ la1+ ;
\ : .branch     (s ip -- ip' )
\    .word   dup <w@ .   /branch +   ;
: skip-branch (s ip -- ip' ) +branch ;
: .quote      (s ip -- ip' )
   .word   .word   ;
: skip-quote  (s ip -- ip' ) ta1+ ta1+ ;
: .string     (s ip -- ip' )
   .word   dup count type ascii " emit space  +str ;
: skip-string (s ip -- ip' )    ta1+ +str ;
: .[']   (s ip -- ip' )
   ta1+  .." ['] " dup token@ c.id  ta1+ ;
: skip-[']   (s ip -- ip' ) ta1+ ta1+ ;

: .unnest     (s ip -- ip' )
   dup extent @ u>=
   if   0 lmargin ! indent .." ; " cr  drop   0
   else .." exit " ta1+
   then
;
: .(;code    (s ip -- ip' )
   does-ip?
   if    .." does> "
   else  0 lmargin ! indent .." ;code " cr disassemble   0
   then
;
: .finish     (s ip -- ip' )
   .word   drop   0   ;

\ classify each word in a definition                  23jun83hhl
17 tassociative: execution-class
   (  0 ) [compile]  (lit            (  1 ) [compile]  ?branch
   (  2 ) [compile]  branch          (  3 ) [compile]  (loop
   (  4 ) [compile]  (+loop          (  5 ) [compile]  (do
   (  6 ) [compile]  compile         (  7 ) [compile]  (."
   (  8 ) [compile]  (abort"         (  9 ) [compile]  (;code
   ( 10 ) [compile]  unnest          ( 11 ) [compile]  ("
   ( 12 ) [compile]  (?do            ( 13 ) [compile]  (;uses
   ( 14 ) [compile]  exit            ( 15 ) [compile]  (llit
   ( 16 ) [compile]  ('

\ classify each word in a definition                  23jun83hhl
18 case: .execution-class
   (  0 )     .inline                (  1 )     .?branch
   (  2 )     .branch                (  3 )     .loop
   (  4 )     .+loop                 (  6 )     .do
   (  6 )     .quote                 (  7 )     .string
   (  8 )     .string                (  9 )     .(;code 
   ( 10 )     .unnest                ( 11 )     .string
   ( 12 )     .?do                   ( 13 )     .finish
   ( 14 )     .unnest                ( 15 )     .llit
   ( 16 )     .[']
  ( default ) .word
;
\ classify each word in a definition                  23jun83hhl
18 case: do-scan
   (  0 )     skip-inline            (  1 )     scan-branch
   (  2 )     scan-branch            (  3 )     skip-branch
   (  4 )     skip-branch            (  6 )     skip-branch
   (  6 )     skip-quote             (  7 )     skip-string
   (  8 )     skip-string            (  9 )     scan-unnest
   ( 10 )     scan-unnest            ( 11 )     skip-string
   ( 12 )     skip-branch            ( 13 )     scan-unnest
   ( 14 )     scan-unnest            ( 15 )     skip-llit
   ( 16 )     skip-[']
  ( default ) skip-word
;

\ decompile a : definition                            15mar83map
: scan-pfa   (s cfa -- )
   dup extent !
   breaks end-breaks !
   >body
   begin
      dup token@ execution-class do-scan
      dup 0= key? or
   until   drop
;
: .pfa   (s cfa -- )
  dup scan-pfa next-break 3 lmargin ! indent
   >body
   begin
      ?cr   break-addr @ over =
         if    break-type @ execute  next-break
         else  dup token@ execution-class .execution-class
         then
      dup 0= key? or
   until   
   drop
;
: .immediate   (s cfa -- )
   immediate? if   .." immediate"   then   ;

\ display category of word                            27sep83map
: .constant    (s cfa -- )
   dup >body ?   .." constant "   c.id   ;
: .variable    (s cfa -- )
   dup >body .   .." variable "   dup c.id
   .." value = " >body ?   ;
: .:           (s cfa -- )
   .." : "  dup c.id 2 spaces  .pfa   ;
: .user-variable   (s cfa -- )
   dup >body ?   .." user variable "   dup c.id
   .." value = "   >data  ?   ;

\ display category of word                            11oct83hhl
: .defer   (s cfa -- )
   .." deferred " dup c.id   .." is "  >data token@ (see   ;
: .user-defer   (s cfa -- )
   .." user deferred "   dup c.id  .." is "  >data token@ (see   ;
\ Decompile a word whose type is not one of those listed in
\ definition-class.  These include code words, and does> and
\ ;code words which are not explicitly recognized in definition-class.
: .other   (s cfa -- )
   dup code? if   .." code " dup c.id cr disassemble   exit   then
\ was not a code word, so print the name of the definer and part of the pf
   dup definer c.id           ( print name of definer )
   dup c.id                   ( print name of child )
   dup >body @ .." ( Parameter field: " . .." ) "
;

5 tassociative: definition-class
   ( 0 )   [compile]  :        ( 1 )   [compile]  constant
   ( 2 )   [compile]  variable ( 3 )   [compile]  user
   ( 4 )   [compile]  defer

6 case:   .definition-class
   ( 0 )   .:            ( 1 )   .constant
   ( 2 )   .variable     ( 3 )   .user-variable
   ( 4 )   .defer        ( 5 )   .other
;

\ top level of the decompiler see                     29sep83map
: ((see   (s cfa -- )
   ( cr )  dup dup definer definition-class .definition-class
   .immediate   ;   ' ((see  is (see 

forth definitions

: see   (s -- )
   '   (see     ;
