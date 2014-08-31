/*
-----------------------------------------------------------------------------
File name:	7BIT_SWE.M		Revision date:	1993.08.24
Revised by:	Ulf Ronald Andersson	Creation date:	1993.08.24
Copyright:	Released as PD FREEWARE
Purpose:	Keep Michtron 3.0 7-bit pure, while still supporting
		the swedish character set in user interface.
Remarks:	Requires Michtron 3.0 started by MTx4.
-----------------------------------------------------------------------------
*/

/* First load input filter */

	list("I]##è");
	list("I[##é");
	list("I\\##ô");
	list("I}##Ü");
	list("I{##Ñ");
	list("I|##î");

/* Then load output filter */

	list("Oè##]");
	list("Oé##[");
	list("Oô##\\");
	list("OÜ##}");
	list("OÑ##{");
	list("Oî##|");

/* Finally activate both filters and the 8-bit mode */

	list("PI##1");
	list("PO##1");
	list("P8##1");
	
/* End of file: 7BIT_SWE.M */
