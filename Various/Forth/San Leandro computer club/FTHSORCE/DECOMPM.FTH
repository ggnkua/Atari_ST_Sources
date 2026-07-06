\ Machine/implementation-dependent definitions
2 constant /branch
2 constant #align

\ The "word type" is a number which distinguishes one type of word
\ from another.  For itc, it is the contents of the code field.
\ For dtc, it is the address of the code that is executed for that
\ word.  This code is reached by a  jsr instruction with a long absolute
\ address.

: word-type ( cfa -- word-type )
  dup w@ th 4ed4 =
  if   drop th 4ed4
  else 2 + ( skip jsr opcode ) l@
  then
;
: >data ( cfa -- data-address )
  dup word-type  ( cfa code-field-word )
  dup ['] #user word-type  = swap      ( user variable? )
  dup ['] key   word-type  = swap      ( deferred? )
  dup ['] forth word-type  = swap      ( vocabulary )
  drop or or
  if  >body >user  else  >body then
;
alias >is >data   ( for backward compatibility)

\ >target depends on the way that branches are compiled
: >target ( ip-of-branch-instruction -- target )
  ta1+ dup <w@ +
;

\ Ip is assumed to point just after a (;code .  flag is true if
\ the code at ip is a does> clause as opposed to a ;code clause.
: does-ip?   (s ip -- ip' flag )
  ta1+ dup /w + ta1+ swap
  wa1+ ( skip the jsr or bsr instruction ) token@
  ['] forth word-type ( jsr instruction in vocabulary does clause )
  wa1+ token@ =

;
\ Given an ip, scan backwards until you find the cfa.  This assumes
\ that the ip is within a colon definition, and it is not absolutely
\ guaranteed to work, but in practice it nearly always does.
\ This is dependent on the alignment requirements of the machine.
\ For a byte-aligned machine, change the /w to a /c.
: find-cfa ( ip -- cfa)
   begin
      #align - dup token@ ( ip' token )
      ['] here token@ =  ( look for the cfa of a : defn )
   until  ( ip)
;
: code? ( cfa -- f ) ( True if the cfa is for a code word )
\itc   token@ over >body =    ( cfa points to the pfa in code words )

\ XXXXXXXXXXXX should be 4eb9 for jsr
\dtc   w@ dup th 4eb9 <>  over th 4ef9 <> and  swap th 4ed4 <> and
\ \dtc   w@ th 4eb9  ( jsr opcode ) <>
;

variable isvar
: definer ( cfa-of-child -- cfa-of-defining-word )
  dup code?  if  drop ['] code   exit then
  word-type
  case
    ['] here  word-type of ['] :          endof
    ['] c/l   word-type of ['] constant   endof
    ['] isvar word-type of ['] variable   endof
    ['] base  word-type of ['] user       endof
    ['] emit  word-type of ['] defer      endof
    ['] forth word-type of ['] vocabulary endof
    ( default )  dup find-cfa swap
  endcase
;

