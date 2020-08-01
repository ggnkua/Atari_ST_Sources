: module ;

hex
: q/  { 2 regargs num den }
  0 num den 0  ud/mod  2swap 2drop ;

: align   { 3 regargs lo hi exponent }
  ( double mantissa)
  hi lo or
  if
    begin
      hi ff800000 and  0=
    while
      lo 2* to lo
      hi rol to hi
      -1 addto exponent
    repeat
    lo 0<
    if 1 addto hi then  ( round up)
    hi 1000000 < not    ( overshot?)
    if
      hi 2/ to hi
      1 addto exponent
    then
  then
  hi exponent  ( mantissa,exponent)
;

: expon  17 lsr  0ff and 7f - ;
: mant  7fffff and 800000 or ;
: smant  dup mant  swap 0< if negate then ;

: pack  { 2 regargs mantiss exp }
  mantiss
  if
    exp 7e >		( decimal 37)
    if  7fffffff	( infinity because overflow)
    else
      exp -7f <		( decimal -37)
      if  0		( zero because underflow)
      else
        mantiss abs 7fffff and
        exp 7f + 0ff and wflip 7 lsl  or
      then
    then
  else 0		( because a zero mantissa)
  then ;

: fnegate  dup 0= not  if  80000000 xor then ;
: fabs  7fffffff and ;

: f*  { 2 regargs fn1 fn2 }
  fn1 0= fn2 0= or
  if 0  ( zero product)
  else
    fn1 mant fn2 mant um*  ( mantissa product)
    fn1 expon fn2 expon + 9 +  align  pack
    fn1 fn2 xor 0<
    if fnegate then  ( real product)
  then ;

: f/ { 2 regargs num den }

  den 0=
  if  7fffffff  exit then  ( infinity)
  num 0=
  if  0  exit then         ( zero)

  num mant den mant q/  ( mantissa quotient)
  num expon den expon -  17 + align  pack
  num den xor 0<
  if fnegate then          ( real quotient)
;

: +mants { 3 regargs #shifts bigger smaller }

  #shifts 17 >
  if
    bigger smant
  else
    smaller smant #shifts asr
    bigger smant +
  then ( mantissa)
;

: f+  { 2 regargs fn1 fn2  3 regs diff exponent fsign }

  fn1 0= if  fn2  exit then
  fn2 0= if  fn1  exit then

  fn1 expon  fn2 expon  -  to diff
  fn1 expon to exponent

  diff
  if
    diff 0>
    if
      diff fn1 fn2
    else
      fn2 expon to exponent
      diff abs fn2 fn1
    then
    +mants
  else
    fn1 smant fn2 smant +
  then

  dup 0= if exit then
  dup to fsign  abs

  dup 800000 <
  if
    begin
      2*  -1 addto exponent
      dup 800000 and
    until
  else
    begin
      dup ff000000 and
    while
      2/  1 addto exponent
    repeat
  then

  exponent pack
  fsign 0<
  if fnegate then ( real sum)
;

: f-  fnegate f+ ;

: i>f  { 1 regarg numb }
  numb 0=
  if 0
  else
    numb abs 0  37 align  pack
    numb 0<
    if fnegate then
  then ;

: f>i { 1 regarg fno  1 reg exponent }
  fno 0=
  if 0
  else
    fno expon to exponent
    exponent 0<
    if
      0
    else
      8 addto exponent
      fno mant 0
      begin
        d2*  -1 addto exponent
        exponent 0<
      until
      swap drop
      fno 0<  if negate then
    then
  then
;

1 i>f constant f1.0
0a i>f constant f10.0
f1.0 f10.0 f/ constant f0.1
f1.0 2 i>f f/ constant f0.5

: fix  f>i i>f ;
: int  dup fabs  f0.5 f+ fix
  swap 0< if fnegate then ;
: fmod  2dup f/ fix f* f- ;
