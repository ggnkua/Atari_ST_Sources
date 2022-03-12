( Synonyms.fth)
( I've often wanted to rename control structures during development
  so that I could keep track of all the IF's, etc. The following word
  let's you do it without adding code to your segment. It merely creates
  a new name field and copies the info from the old name field. This
  will, of course, affect Body>Link)

( Usage:
	SYN existingName newName

Example:
	SYN IF IF1
	SYN IF IF2
	SYN IF IF3

	SYN THEN THEN1
	SYN THEN THEN2
	SYN THEN THEN3

: something
	....
	 IF
	  .....
	   IF1
	    ....
	   THEN1
	  ....
	   IF2
	    ....
	     IF3
	      ....
	     THEN3
	    ....
	   THEN2
	  THEN
	  ;		)

CODE LFA>CFA	( given an LFA, return address of just past the name)
	MOVE.L	(A6)+,A0	( get the LFA)
	ADDQ.L	#4,A0		( skip past the link)
	MOVE.B	(A0)+,D1	( get the count)
	ANDI.W	#$001F,D1	( mask off the smudge, etc. bits)
	BSET	#0,D1		( make sure the length is odd)
	ADDA.L	D1,A0		( there's the CFA)
	MOVE.L	A0,-(A6)	( push it)
	RTS
END-CODE

hex
: SYN	{ | Addr1 Addr2 bits }
	'=
	ABORT" not found!"
	-> Addr1		( store the LFA)
	drop			( dump the returned PFA)

	CREATE			( create the new name entry)
	-4 ALLOT		( recover the CREATE code)
	last -> Addr2		( LFA of new synonym)

	Addr1 4 +		( address of count byte1)
	 c@ E0 and -> bits	( leave just the smudge, etc. bits)
	Addr2 4 +		( address of count byte2)
	 c@ 1F and bits +	( add the proper bits on the count byte2)
	Addr2 4 + c!		( and store it away)

	Addr1 LFA>CFA -> Addr1	( now points to the first of 4 bytes
				  which are the 'CFA')
	Addr2 LFA>CFA -> Addr2	( 'CFA' of new syn)

	Addr1 @ Addr2 !		( all done!)
	;
decima