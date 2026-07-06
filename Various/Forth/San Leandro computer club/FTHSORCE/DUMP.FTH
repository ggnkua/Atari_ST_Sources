( From Perry/Laxen, largely verbatim )

\ The dump utility gives you a formatted hex dump with the ascii
\ text corresponding to the bytes on the right hand side of the
\ screen.  In addition you can use the SM word to set a range of
\ memory locations to desired values.  SM displays an address and
\ its contents.  You can go forwards or backwards depending upon
\ which character you type. Entering a hex number changes the
\ contents of the location.  DL can be used to dump a line of
\ text from a screen.

\ General Dump Utility - Output                       06Oct83map
: .2   (s n -- )   n->l <#   # #   #>   type   space   ;
: d.2   (s addr len -- )   bounds ?do   i c@ .2   loop   ;
: emit.   (s char -- )
   127 and dup printable? 0= if drop ascii . then emit ;
: dln   (s addr --- )
   cr   dup 8 u.r   2 spaces   8 2dup d.2 space
   over + 8 d.2 space
   16   bounds ?do   i c@ emit.   loop   ;
: ?.n    (s n1 n2 -- n1 )
   2dup = if  ." \/"  drop   else   2 .r   then   space   ;
: ?.a    (s n1 n2 -- n1 )
   2dup = if  ." v"  drop   else   1 .r   then  ;



\ dump and fill memory utility                        06oct83map
: .head   (s addr len -- addr' len' )
   swap   dup -16 and  swap  15 and   ( cr ) 10 spaces
   8 0 do   i ?.n   loop   space   16 8 do   i ?.n   loop
   space   16 0 do  i ?.a  loop   rot +  ;
: dump   (s addr len -- )
   base @ -rot  hex   .head  ( addr len )
   dup 0= if 1+ then
   bounds do   i dln  key? ?leave  16 +loop   base !   ;
: du   (s addr -- addr+64 )
   dup 64 dump   64 +   ;
\ : dl   (s line# -- )
\    c/l * scr @ block +   c/l dump   ;
