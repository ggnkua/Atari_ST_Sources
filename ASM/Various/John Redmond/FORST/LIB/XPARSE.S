\ xparse.s: parse the input stream until one of a set of delimiters
\ (specified in a counted array) is found, or the stream is exhausted.

decimal
-1 constant true
0  constant false
32 constant bl
13 constant cret
-1 constant eof
\ character arrays: first value is the number of chars

create punctchars 7 w,
 ascii , w,  ascii ; w,  ascii ( w,  ascii ) w,  bl w,  cret w,  eof w,
create endchars  3 w,
 cret w,  ascii ; w,  eof w,
create whitechars  4 w,
 bl w,  9 w,  cret w,  10 w,
create string 80 allot

: match	{ 2 regargs char matchptr 2 regs #puncts result }
  false  ( result on stack)  matchptr inc w@ to #puncts
  for #puncts
    matchptr inc w@ char =  if 1- ( make result true) leave then
  next
  ( return result) ;
  
: punct  ( char--t/f) punctchars match ;
: endchar  ( char--t/f) endchars match ;
: white  ( char--t/f) whitechars match ;

\ printchar: keep fetching chars until one is printable, then return it

: printchar  { 1 reg char }
  begin
   inchar to char
   char white not
   char 0< or
  until  char ( return it) ;

\ xparse: skip over leading white space, then assemble a string until
\ a punctuation char (defined above) is fetched, and
\ return a pointer to a counted string, with the terminating char on top

: xparse  { 3 regs strpointer char #chars }
  string 1+ to strpointer  0 to #chars
  printchar to char  ( skip over white space)
  begin
    char 0<  char punct  or not
  while
    char strpointer inc c!  1 addto #chars
    inchar to char  ( get another char)
  repeat
  bl strpointer inc c!  0 strpointer c! ( term with space, then null)
  #chars string c!  string char ( return string and term char) ;


\ newword: a high-level version of word, functionally equivalent
\ to the the system version

: newword  { 1 regarg delim  3 regs strpointer char #chars }

  string 1+ to strpointer  0 to #chars
  
  delim bl =
  if  printchar  else  inchar  then  to char
  
  begin

    char 0<  if leave then ( end of string)
  
    char strpointer inc c!  1 addto #chars

    inchar to char  ( get another char)
        
    delim bl =
    if
      char white
    else
      char delim =
    then
    
  until

  bl strpointer inc c!  0 strpointer c! ( space, then null)
  
  #chars string c!
  string ( return string)
;
