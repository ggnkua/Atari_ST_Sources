( tests for CLIB SI )
DECIMAL

initCLIB

tm t		( define a tm-structure )

25 	t >tm_sec	w! 
12 	t >tm_min 	w!
8	t >tm_hour 	w!
19	t >tm_mday 	w!
8	t >tm_mon 	w!
93 	t >tm_year 	w!
3	t >tm_wday 	w!
0	t >tm_yday 	w!
0	t >tm_isdst w!



t _asctime TYPE
 

_clk_tck .		
( should give 200 )

_clock U.

VARIABLE timer 

_time timer !  
timer _ctime TYPE	
( important: _ctime wants a pointer! )

timer _gmtime  		_asctime TYPE 
	
timer _localtime	_asctime TYPE

_timezone .
( should give 3600 = 1h to GMT )


t _mktime timer !
timer _ctime TYPE

256 CONSTANT maxtimestrsz
CREATE timestrbuf	maxtimestrsz ALLOT

: frmt ( -- str )
	S" Now is: %Z %a %d%b%y %H:%M:%S" ; 


_time timer !

timestrbuf maxtimestrsz frmt timer _gmtime  _strftime 

timestrbuf  SWAP CR TYPE


( security check )
DEPTH . ( should yield 0 )


