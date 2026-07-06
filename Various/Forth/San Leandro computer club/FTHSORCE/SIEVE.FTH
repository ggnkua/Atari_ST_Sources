( sieve )

8192 constant size
variable flags   size allot

: do-prime  ( 16 seconds for 32-bit dtc forth)
  flags  size 1  fill  ( set array )
  0 ( 0 count ) size  0
  do  flags  i + c@
    if  i  dup  + 3 + dup i +
    begin  dup  size <
       while  0  over  flags  + c!  over  +
    repeat
   drop drop 1+
   then
 loop
 .  ." primes"
;
: 10-times  10 0 do do-prime loop ;

: do-prime.hi  ( 11 seconds for 32-bit dtc forth )
  flags  size 1  fill  ( set array )
  0 ( 0 count ) size  0
  do  flags  i + c@
    if  3 i + i + dup i + size <
       if size flags +  over i +   flags +
            do   0 i c!  dup
            +loop
       then drop  1+  ( bump prime counter)
   then
 loop
\ .  ." primes"
;
: 10-times.hi  10 0 do do-prime.hi loop ;

code flick'em ( prime# limit start -- prime#) ( replaces do 0 i c! dup +loop)
  sp )+ a1 amove  sp )+ d1 amove
  sp )  d0 move   0 d2 moveq

  begin  d2 a1 ) bmove  d0 a1 long adda
         a1 d1 cmp
  0< until
c;
: do-prime.lo  ( 6 seconds for 32-bit dtc forth )
  flags  size 1  fill  ( set array )
  0 ( 0 count ) size  0
  do  flags  i + c@
    if  3 i + i + dup i + size <
       if size flags +  over i +   flags +
            flick'em
       then drop  1+  ( bump prime counter)
   then
 loop
 .  ." primes"
;
: 10-times.lo  10 0 do do-prime.lo loop ;
