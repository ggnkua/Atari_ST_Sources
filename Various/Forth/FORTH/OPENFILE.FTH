( OpenFile.fth)
( Uses the FSelInput box for opening read-only or r/w files for a task)

60 user FileID	( where to stuff a fileID for Mach1 to know of it)

2 constant R/W
0 constant R/O

create PathName		( inital path displayed)
	DC.B	'A:\*.*'
	DC.B	0		( all strings must be null-terminated)
	DCB.B	20,0

create Selection	( initial selection displayed)
	DC.B	'X.X'
	DC.B	0		( all strings must be null-terminated)
	DCB.B	20,0

: OpenFile { mode }	( use FileSel to open a file. Put handle in FileID)
	PathName Selection CALL FSelInput
	IF			( test result code)
	 IF			( non-zero if OK button pushed)
	  Selection mode CALL fOpen
	   dup 0< IF		( result code is < 0 if error.)
		abort" file error!"
	      ELSE
		FileID w!
	      THEN
	  THEN
	 THEN
	;

( this is the same as WORKING" except that you select the file w/ the mouse)
: USING		R/O OpenFile ;
: WORKING	R/W OpenFile ;
: CLOSE		FileID w@ CALL fClose drop ;