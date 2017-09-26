/*  pghdr.h - header file for program loaders, 'size' pgms, etc.	*/
/*  PGMHDR01, PGMINFO */




#define	PGMHDR01	struct	pgmhdr01
PGMHDR01
{
	/*  magic number is already read  */
	LONG	h01_tlen ;	/*  length of text segment		*/
	LONG	h01_dlen ;	/*  length of data segment		*/
	LONG	h01_blen ;	/*  length of bss  segment		*/
	LONG	h01_slen ;	/*  length of symbol table		*/
	LONG	h01_res1 ;	/*  reserved - always zero		*/
	LONG	h01_res2 ;	/*  ?					*/
	WORD	h01_abs ;	/*  not zero if no relocation		*/
} ;

#define	PGMINFO		struct	pgminfo
PGMINFO
{
	LONG	pi_tpalen ;		/*  length of tpa area		*/
	BYTE	*pi_tbase ;		/*  start addr of text seg	*/
	LONG	pi_tlen ;		/*  length of text seg		*/
	BYTE	*pi_dbase ;		/*  start addr of data seg	*/
	LONG	pi_dlen ;		/*  length of data seg		*/
	BYTE	*pi_bbase ;		/*  start addr of bss  seg	*/
	LONG	pi_blen ;		/*  length of bss  seg		*/
	LONG	pi_slen ;		/*  length of symbol table	*/
} ;


