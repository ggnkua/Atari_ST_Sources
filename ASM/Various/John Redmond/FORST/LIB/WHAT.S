( what.s: description of the functions of a word)
( usage: what <name>)

hex macros

: what { 5 regs cfa ffa nfa pfa length }

  cr head to cfa
  cfa 5 - -1 traverse to nfa
  cfa 4- to ffa  cfa 4+ to pfa

  nfa id. [ascii] : emit
  nfa c@ 40 and 0=  if ." not " then
  ." immediate" cr

  ffa w@ 3ff and  to length
  ." code length in bytes: "
  length if length 1+ 2* . else ." not specified"  then cr

  ffa c@ f8 and
  case
     20 of " no edges expected and 1 returned" endof
     80 of " 1 edge expected and none returned" endof
    0a0 of " 1 edge expected and 1 returned" endof
    0b0 of " 1 edge exected and 2 returned" endof
    0f0 of " 2 edges expected and 2 returned" endof
    0e0 of " 2 edges expected and 1 returned" endof
    0e8 of " 2 edges expected and a test result returned" endof
    0a8 of " 1 edge expected and a test result returned" endof
      0 of " no edges specified" endof
           " unclassified edge specification" ( default)
  endcase   type ( the message) cr

  ffa 2+ w@
  case
        0 of " no POP specified" endof
    0ffff of " no optimisation of leading edge" endof
    0fffe of " no optimisation of leading edge" endof
     2d00 of " the top edge is POP D0" endof
     2d08 of " the top edge if POP A0" endof
             " unclassified POP expected" ( default)
  endcase  type cr

  ." code or data address is " pfa @ os> . cr

;

decimal
