( ANOTHER: duplication of inline code words )
( use:  another <word name> )

decimal

: another
  { 6 regs  cfa dest
    headstart headlength
    codesize codestart
    1 local  codeoffset }

  head  to cfa
  cfa 4 - w@ 1023 and  to codesize
  
  codesize if
  
    codesize 1 + 2*  to codesize  ( full code size in bytes)
    cfa 5 - -1 traverse  to headstart
    cfa 4 + @  a5 +  to codestart
    cfa 8 + w@ 2+  to headlength

    cp @ to codeoffset  
    codestart here codesize cmove  codesize cp +!
    
    headstart there headlength cmove
    headlength hp +!
    
    there 10 - to dest ( point to new cfa)
    codeoffset dest inc ! ( cfa) codeoffset dest ! ( pfa)

  else

    ." not suitable for duplication"

  then
;
