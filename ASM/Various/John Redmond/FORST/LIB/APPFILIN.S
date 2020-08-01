( appfilin.s: basic application file input)

decimal

: openerror
  cr ." could not open the file" cr
  appabort
;
: closeerror
  cr ." could not close the file" cr
  appabort
;
: open
  a7 dec w!  a7 dec !  61 a7 dec w!  gemdos
  d0 d0  ( 2 copies of result)
  8 addto a7
  ( result)  0< if openerror then
;
: openfile  { 5 regs  offset end start length extension }

  -128 a5 + to start  start c@  to length
   start length + 1+  to end  end to offset
   0 to extension  ( no .XXX)
   
  for length
    offset dec c@  [ascii] . =  if 1 to extension leave then
  next
  
  extension if
    offset 4 + end - to length
    for length   32 end inc c!  next  ( pad with spaces)
  then
  
  start 1+ 2 open ( file name in base page)
;  

: close  a7 dec w! ( handle)  62 a7 dec w!  gemdos
  d0  ( save result)  4 addto a7
  ( result) 0<  if closeerror then
;
: read  swap  ( ^buffer to top)
  a7 dec ! ( ^buffer)  a7 dec ! ( #chars)
  a7 dec w! ( handle)  63 a7 dec w!  gemdos
  d0 ( #chars read)
  12 addto a7
;
