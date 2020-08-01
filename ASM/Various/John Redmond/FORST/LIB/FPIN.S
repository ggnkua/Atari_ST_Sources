decimal
: module ;

10 i>f          constant f10.0
1 i>f f10.0 f/  constant f0.1

: fconvert
 { 3 args &pointer &value &range  2 locals pointer char }

  &pointer @ 1+ to pointer

  begin
    pointer c@ to char
    char 47 > char 58 < and
  while
    &value @ f10.0 f*  char 48 - i>f f+ &value !
    &range @ 0< not
    if 1 &range +! then
    1 addto pointer
  repeat

  pointer  &pointer ! ;

: expconvert  { 1 arg pointer  3 locals char numb sign }

  1 addto pointer  0 to numb  0 to sign

  pointer c@ 45 = dup
  if  drop 1 addto pointer  -1 to sign
  else
    43 =
    if  1 addto pointer  then
  then

  begin
   pointer c@ to char
   char 47 > char 58 < and
  while
   numb 10 *  char 48 - +  to numb
   1 addto pointer
  repeat

  numb  sign if negate then   pointer ;

: fnumber  { 1 arg charptr  3 locals sign mantissa dpl }

  0 to sign  0 to mantissa  -1 to dpl

  charptr 1+ c@ 45 = dup
  if  drop 1 addto charptr  -1 to sign
  else
    43 =
    if  1 addto charptr  then
  then

  addr charptr  addr mantissa  addr dpl  fconvert
  charptr c@ 32 =
  if mantissa  sign  if fnegate then  exit then

  0 to dpl
  charptr c@ 46 =
  if
    addr charptr  addr mantissa  addr dpl  fconvert
  then

  charptr c@ 95 and 69 =
  if
    charptr expconvert
    to charptr  negate addto dpl
  then

  charptr c@ 32 - abort" FP conversion error"
  
  mantissa
  dpl if
    dpl 0>
    if
      begin  dpl 0>
      while  f0.1 f*  -1 addto dpl
      repeat
    else
      begin  dpl 0<
      while  f10.0 f*  1 addto dpl
      repeat
    then
  then
  sign  if fnegate then
;

: ffetch  32 word fnumber ;

