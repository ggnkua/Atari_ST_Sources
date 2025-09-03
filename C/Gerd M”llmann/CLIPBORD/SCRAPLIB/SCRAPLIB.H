/* -------------------------------------------------------------------- */
/*									*/
/*				SCRAPLIB.H				*/
/*			-------------------------			*/
/*			  (c) 1990 by Don Chaos				*/
/*									*/
/*			      Eric Bîhnisch				*/
/*			    In den Beeten  80				*/
/*			    7121 Ingersheim 1				*/
/*			    Phone 07142 51661				*/
/*									*/
/*     Dieser Header ist in Verbindung mit der SCRAPLIB.BIN-Library	*/
/*     zu verwenden. Er enthÑlt alle Definitionen fÅr die einzelnen	*/
/*     Funktionen.							*/
/*									*/
/* -------------------------------------------------------------------- */



#ifndef NARGS
	void	scrp_clear();
	word	scrp_init();
	word	scrp_length();
	word	scrp_find();
#else
	void	scrp_clear();
	word	scrp_init(byte *);
	word	scrp_length();
	word	scrp_find(byte *, byte *);
#endif
