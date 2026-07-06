\ Create and manipulate new stacks.
\
\ 100 stack: foo      Create a new stack called foo with 100 bytes of storage
\ 123 foo push        Push the number 123 on the stack foo
\ foo pop             Pop the top element from the stack foo onto the
\                     parameter stack
\ foo top@            Copy the top element from the stack foo onto the
\                     parameter stack
\ 456 foo top!        Replace the top element of the stack foo with 456
\ foo ?empty          True if the stack foo is empty
\ foo sdepth          Returns the number of items on the stack foo
\ foo clearstack      Empties the stack foo

: stack: ( size -- ) ( Input stream: name )
    create here , allot ( top, )
;
: push ( n stack -- ) /n over +! @ ! ;
: ?empty ( stack -- f ) dup @ >= ;
: pop ( stack -- n )
    dup ?empty abort" empty user stack"
    dup @ @ swap /n negate swap +! ;
: top@ ( stack -- n ) ( leaves top element )
    dup ?empty abort" empty user stack" @ @  ;
: top! ( n stack -- ) ( replaces top element )
  dup pop drop push ;
: clearstack ( stack -- ) ( empties stack )  dup ! ;
: sdepth ( stack -- depth ) dup @ swap - /n / ;
