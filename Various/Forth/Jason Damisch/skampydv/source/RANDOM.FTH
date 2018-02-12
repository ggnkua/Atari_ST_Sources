\ Interface to random number generator

decimal
17 xbios: _random { -- l.rnd-number }  \ bios random number routine

\ The 2/ throws away the lsb which is not very random; it toggles every time
: rnd  ( limit -- rndnum )  \ return random number up to limit
   _random 2/ swap  mod
;

\ ******
: random
\ (  limit --  random-number  )
	_random swap mod
;
