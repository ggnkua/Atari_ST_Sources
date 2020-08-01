decimal
: module ;

: normalize { 1 arg fno  1 local decexp }

  -1 to decexp
  fno expon 0<
    if  fno fabs
      begin dup f0.1 <
      while f10.0 f*  -1 addto decexp repeat
    else  fno fabs
      begin dup f1.0 < not
      while f0.1 f*  1 addto decexp repeat
    then
  decexp ( normalized mantissa, dec exponent) ;

: spill ( fno)
  dup mant  swap expon 8 + lsl
  40000000 um*  swap
  0< if 1+ then 2/ ( decimal mantissa) ;

: sigfigs  { 1 arg mantissa  2 locals #digs quotient }

  mantissa  7 to #digs
  begin
   dup to quotient
   10 /mod swap  0=  #digs 1 > and
  while
   -1 addto #digs
  repeat  drop
  quotient #digs ( scaled mantissa, #digits) ;

: decpt  46 hold ;
: figures  dup 0> if  0 do # loop  else drop then ;
: zeros  dup 0> if  0 do 48 hold loop  else drop then ;

: scientific  { 4 args fno value length exponent }

  exponent abs
  <#
    #s  exponent sign  69 hold  drop
    value
    length 1 >
    if
      length 1- figures decpt
    then
    #  fno sign
  #>  ( string,length) ;

: vsmall  { 4 args fno value length exponent }

  value
  <#
    #s
    exponent -1 <
    if exponent abs 1- zeros then
    decpt 1 zeros  fno sign
  #>  ( string,length) ;

: small  { 4 args fno value length exponent  1 local diff }

  exponent length - to diff

  value
  diff 0=
  if
   <# 1 zeros  #s  fno sign  #> exit
  then

  diff 0>
  if
    <# diff 1+ zeros  #s  fno sign #>
  else
    diff -1 =
    if
      <# #s fno sign #>
    else
      <# diff abs 1- figures decpt  #s  fno sign #>
    then
  then ( string,length) ;

: (f.) { 1 arg fno  3 regs decexp numb numbase }

  base @ to numbase  decimal ( force to decimal output)

  fno 0=
  if
    0  <# # #>
  else
    fno normalize ( mant,decexp) to decexp
    ( mant) spill to numb
    fno numb sigfigs decexp
    decexp -3 < decexp 5 > or
    if
      scientific
    else
      decexp 0<
      if vsmall else small then
    then
  then ( string,length)

  numbase base ! ;

: f. (f.)  type space ;

