/*
-----------------------------------------------------------------------------
File name:	SWE_7BIT.M		Revision date:	1993.08.24
Revised by:	Ulf Ronald Andersson	Creation date:	1993.08.24
Copyright:	Released as PD FREEWARE
Purpose:	Keep Michtron 3.0 7-bit pure, while still supporting
		the swedish character set in user interface.
Remarks:	Requires Michtron 3.0 started by MTx4.
-----------------------------------------------------------------------------
*/

/* First load input filter */

	list("I�##]");
	list("I�##[");
	list("I�##\\");
	list("I�##}");
	list("I�##{");
	list("I�##|");

/* Then load output filter */

	list("O]##�");
	list("O[##�");
	list("O\\##�");
	list("O}##�");
	list("O{##�");
	list("O|##�");

/* Finally activate both filters and the 8-bit mode */

	list("PI##1");
	list("PO##1");
	list("P8##1");
	
/* End of file:	SWE_7BIT.M */
