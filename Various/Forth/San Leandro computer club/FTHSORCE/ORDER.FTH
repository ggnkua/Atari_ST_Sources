( The also/only vocabulary search order scheme )

context dup @ swap na1+ !   ( make forth also )
vocabulary root   root definitions
: also   (s -- )
   context dup na1+ #vocs 2- /n * cmove>
;
: only
   ['] root >body >user ( thread address for root vocabulary )
   context #vocs 1- /n *  ( root-thread-addr  context size-2 )
   2dup erase           ( root-thread-addr  context size-2 )
   +            ( root-thread-addr addr-of-last-entry-in-search-list )
   !
   root
;
: seal   (s -- ) ( Input stream: vocabulary-name )
   ' >body   context #vocs /n * erase   context !   ;
: previous   (s -- )
   context dup na1+ swap #vocs 2- /n * cmove
   context #vocs 2- /n * + off   ;

: forth   forth ;
: definitions   definitions   ;
: v>body ( voc-link-addr --- pfa )   /n -  ;
: find-voc ( voc-ptr-addr -- cfa )
  voc-link                  ( voc-ptr-addr voc-link )
  begin    token@           ( voc-ptr-addr voc-link-addr )
     dup origin u>          ( voc-ptr-addr voc-link-addr more-vocs? )
  while
     2dup v>body >user   =  ( voc-ptr-addr voc-link-addr found? )
     if   v>body  body>  nip exit   then
  repeat                    ( voc-ptr-addr last-voc-link-addr )
  2drop false
;
: order   (s -- )
   ." context: " context
   #vocs 0
   do   dup @ ?dup
      if   find-voc >name .id then
   na1+
   loop drop
   4 spaces ." current: " current @ find-voc >name .id
;
: vocs   (s -- )
   voc-link token@
   begin   dup ( #threads 2* - ) v>body body> >name .id
      token@ dup origin u<=
   until
   drop
;
only forth also definitions
