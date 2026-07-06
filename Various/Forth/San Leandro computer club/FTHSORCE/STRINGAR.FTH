\ String-array
\ Creates an array of strings.
\ Used in the form:
\ string-array name
\   ," This is the first string in the table"
\   ," this is the second one"
\   ," and this is the third"
\ end-string-array
\
\ name is later executed as:
\
\ name ( index -- addr )
\   index is a number between 0 and one less than the number of strings in
\   the array.  addr is the address of the corresponding packed string.
\   if index is less than 0 or greater than or equal to the number of
\   strings in the array, name aborts with the message:
\        String array index out of range

: string-array ( -- )  ( input stream: name )
  create
  0 ,    ( the number of strings )
  0 ,    ( the starting address of the pointer table )
  does>  ( index pfa )
  2dup @ ( index pfa  index #strings )
  0 swap within  0= abort" String array index out of range"    ( index pfa )
  na1+ @   ( index table-address )
  swap na+ @
;
: end-string-array ( -- )
  here align          ( string-end-addr )
  last @ name> >body  ( string-end-addr pfa )
  na1+ here over !    \ Store table address in the second word of the pf
  na1+                ( string-end-addr first-string-addr )
  begin               ( string-end-addr this-string-addr )
      2dup >          ( string-end-addr this-string-addr )
  while
      \ Store string address in table
      dup ,           ( string-end-addr this-string-addr )
      \ Find next string address
      +str
  repeat              ( string-end-addr next-string-addr )
  2drop               ( )
  \ Calculate and store number of strings
  last @ name> >body  ( pfa )
  dup na1+ @          ( pfa table-addr )
  here swap - /n /    ( pfa #strings )
  swap !
;
