.EXPORT int_reverse, long_reverse

* unsigned short int_reverse(unsigned short n)
*                                     D0
int_reverse:
  ROR.W #8,D0
  RTS

* unsigned long long_reverse(unsigned long n)
*                                     D0
long_reverse:
              ; D0.L = $1234
  ROR.W #8,D0 ; D0.L = $1243
  SWAP D0     ; D0.L = $4312
  ROR.W #8,D0 ; D0.L = $4321
  RTS