\ Implements:
\ (more ( fd -- )
\   display an already-open text file, stopping at the end of every
\   screenfull.  When stopped, displays "More?" and waits for a command:
\   <space>      display next screenfull
\   <return>     display one more line
\   q            quit
\ more ( -- ) ( Input stream: filename )
\   like (more but takes the name of the file from the input stream
\ (tail ( fd -- )
\   display the last 1000 characters of a file, paginating like (more
\ tail ( -- ) ( Input stream: filename )
\   like (tail but takes the name of the file from the input stream

decimal
variable ifile
: ?end-of-screen
  #line @  #lines 1- >=
  if  dark ." More? " light 
      key  (cr kill-line
      case
        ascii q   of  ifile @ close  abort  endof
        control m of  -1 #line +!           endof
        #line off erase-screen
      endcase
  then
;
: (more ( fd -- )
  ifile !
  #line off  erase-screen
  begin 
    ifile @ fgetc dup 0>=
  while
    dup  control j  =
    if  drop cr ?end-of-screen  else  emit  then
  repeat
  ifile @ close
;
: openfile ( -- fd )   ( Input Stream: filename )
  bl word read open
  ?dup 0= abort" Can't open file"
;
: more ( -- ) ( Input Stream: filename )
  openfile (more
;
: (tail ( fd -- )
  ifile !
  \ There ought to be an official function to do this next line
  ifile @ file !  fid @ gemfsize  ( end-of-file-position )
  \ We really ought to scan backwards for newlines.
  td 1000 -  0  max     \ seek backwards but not too far
     ifile @ fseek
  ifile @ (more
;
: tail ( -- ) ( Input Stream: filename )
  openfile (tail
;
