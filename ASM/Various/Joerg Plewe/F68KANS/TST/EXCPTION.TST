( EXCEPTION tests )
( JPS, 18apr93 )

: could-fail ( -- char )
	KEY DUP [CHAR] Q = THROW ;
	
: do-it ( a b -- c)
	2DROP could-fail ;
	
: try-it ( --)
	1 2 ['] do-it CATCH
	IF		2DROP ." There was an exception!" 
	ELSE	." The character was " DUP . EMIT
	THEN CR ; 
	
