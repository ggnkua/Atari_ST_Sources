decimal
: module ;

10000000  i>f constant 10mill
-1666667  i>f 10mill f/ constant s3
   83333  i>f 10mill f/ constant s5
   -1984  i>f 10mill f/ constant s7
      28  i>f 10mill f/ constant s9

355 i>f 113 i>f f/ constant pi
pi 2 i>f f/ constant pi/2
pi 4 i>f f/ constant pi/4
pi 2 i>f f* constant 2pi

: (sin) { 1 arg angle  2 locals square term }

  angle to term
  angle dup f* to square

  angle          term square f* to term
  term s3 f* f+  term square f* to term
  term s5 f* f+  term square f* to term
  term s7 f* f+  term square f* to term
  term s9 f* f+ ;

: sin { 1 arg angle  1 local sign }

  angle 0< to sign
  angle fabs to angle
  angle 2pi >
  if  angle 2pi fmod to angle  then
  angle pi >
  if  angle pi f- to angle  sign not to sign  then
  angle pi/2 >
  if  pi angle f- to angle then
  angle (sin)  sign if fnegate then ;

: cos  pi/2 f+ sin ;
 
: tan  dup sin swap cos f/ ;
