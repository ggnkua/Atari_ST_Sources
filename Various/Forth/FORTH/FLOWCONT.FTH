( flowControl.fth)
( the words .IF. .ELSE. and .THEN. to control file loading. May not
  be nested. Used to load parts of a program depending on the value
  of whatever's on the stack. Use of .ELSE. is optional.)

( Example:
  To load a different section of code for monochrome monitors instead
  of color:

: mono? -1 ; Immediate	( true, for loading mono code)
.....			( this code is loaded no matter what)
mono? .IF.
....	....	....	( this code will be loaded)
	.ELSE.
.....	.....	.....	( this code won't)
	.THEN.
....			( this code will get loaded no matter what)
)

decimal

: .THEN. ; Immediate	( merely a marker for the others)

: .ELSE.  { | thenLFA } ( do '32 WORD's until it finds .THEN.)
			( DOESN'T HAVE TO BE USED)

	['] .THEN.
	body>link -> thenLFA	( hold this to compare to)

	BEGIN
	 32 word	( look for a count of 6)
	  dup c@ 6 =
	   IF		( now see if it was .THEN.)
	    find drop	( flag)
	    thenLFA =
	     If	  1	( was indeed .THEN. so stop skipping)
	     Else 0	( wasn't .THEN. so continue)
	     Then
	   ELSE		( just get next word)
	    drop 0	( until flag)
	   THEN
	 UNTIL
	 ; Immediate

: .IF.  { flag | elseLFA thenLFA } ( do '32 WORD's until find .ELSE.
				or .THEN. depending on the flag of course)

	flag
	IF		( was true, so let load. .ELSE. will take care
			of everything)
	ELSE		( was false, skip until .ELSE. or .THEN.)
	  ['] .ELSE.
	  body>link -> elseLFA	( hold this to compare to)

	  ['] .THEN.
	  body>link -> thenLFA	( hold this to compare to)

	  BEGIN
	   32 word	( look for a count of 6)
	    dup c@ 6 =
	    IF		  ( now see if it was .ELSE. or .THEN.)
	      find drop	  ( flag)
	      dup	  ( dup the LFA)
	      elseLFA =
	      swap
	      thenLFA = or
	       If   1	   ( was one of them so stop skipping)
	       Else 0	   ( wasn't either so continue)
	       Then
	     ELSE	  ( just get next word)
	      drop 0	  ( until flag)
	     THEN
	   UNTIL
	 THEN
	 ; Immediate

