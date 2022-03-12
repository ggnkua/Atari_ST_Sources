( sieve.fth)
( This is the Forth Sieve, written to run the sieve as a Forth programmer
  would. This is not the Byte Sieve, which is perfect for batch-compiled
  languages but points out the biggest drawback of Forth: moving data
  around in global arrays. Even in this sieve, you can see (or guess)
  how inefficient the line 'flags i + c@ IF' is when compared with
  'IF flags(i)'

  This sieve figures out the prime numbers from 0 to size*2. The array
  is actually of all the odd numbers since it's a given that an even
  number is not prime. When you dump the final array, you'll see that
  bytes representing 1,3,5,7,11, etc. are ones, while the bytes
  representing bytes 9,15,21, etc. are zeroed)

decimal
8192 constant size

variable flags   size vallot

: primes ( - primes)	( does the primes once)
	flags size 01 fill
	0		( prime counter)
	size 0		( range/2 of numbers to do)
	DO
	 flags i + c@	( see if prime already)
	  IF
	  3 i + i + dup i + size <
	   IF
	     size flags + over flags i + +	( range of nums to tag)
	     DO
	      0 i c! dup	( tag numbers as non-primes)
	     +LOOP
	   THEN
	   drop 1+	( drop the i used for +loop, increment prime count)
	  THEN
	LOOP ;

: sieve 
	COUNTER			( start counting )
	10 0 DO primes LOOP 	( perform 10 iterations )
	TIMER			( stop counting )
        CR . ."   primes"	( print the number of primes )
	 9 0 DO DROP LOOP ;	( clean-up stack )

CR .( Type 'sieve' to execute this benchmark program ) CR
