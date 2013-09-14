/*
	Common Defines
*/
#define		false		0
#define		true		1
#define		FREAD		0
#define		FWRITE		1
#define		FRDWR		2
#define		NWFIL		0

/*	Composer special Keys	*/
#define		QL	0x12
#define		QR	0x1c
#define		QC	0x1d

#define		DH	0x07
#define		sDH	0x14
#define		sHY	0x0b

#define		Rf	0x0c
#define		cr	0x0d
#define		lf	0x0a
#define		srt	0x0f
#define		hrt	0x1f

#define		Mdsh	0xf0
#define		Ndsh	0xf7

#define		TSP	0xfc
#define		NSP	0xfd
#define		MSP	0xfe

#define		STAG	0xf9
#define		ETAG	0xf8
#define		PTAG	0xdf

/*	Composer Tag pointers	*/
#define		num_tags	6		/* total number of tags	*/
#define		COMP		0		/* Cptarget mark tag	*/
#define		OVSP		1		/* Overset  mark tag	*/
#define		NLTP		2		/* -Lts Rge mark tag	*/
#define		PRFP		3		/* Pref Rge mark tag	*/
#define		PRFS		4		/* Pref Spc mark tag	*/
#define		CPBK		5		/* Cmpbreak mark tag	*/

/*	Text Window Tag pters	*/
#define		mrk_base	0		/* user marks: A,B,C,D	*/
#define		WWRP		4		/* screen word wrap tag	*/
#define		TMP1		5		/* temporary tag 1	*/
#define		TMP2		6		/* temporary tag 2	*/
#define		TMP3		7		/* temporary tag 3	*/
#define		TMP4		8		/* temporary tag 4	*/
#define		HMRK		9		/* block mark start tag	*/
#define		top_line	10		/* top window line tag	*/
int		wdw_tags;			/* total number of tags	*/

/*	Text Positions		*/
#define		top_row		0		/* top row in window	*/
#define		wdw_cols	75		/* # columns fixed...	*/
char		wdw_rows;			/* # rows set by screen	*/
struct	{
	char	mrow, mcol;			/* window Maximn RowCol	*/
	char	row, col;			/* window cursor RowCol	*/
} current;

/*	Buffer pointers		*/
unsigned char	*buf_ptr[num_tags];		/* compos tag array	*/
unsigned char	**wdw_ptr;			/* window tag array	*/
unsigned char	*buf_start, *buf_end;		/* buffer delimiters	*/
unsigned char	*current_char;		/* first char in the 2nd buffer	*/
unsigned char	*free_start;		/* first char in the free area	*/

/*	Externals to avoid type conflicts	*/
extern	unsigned long	free_space();

/*	BackEnd Defines		*/
#define		OFF		0
#define		ON		1
#define		IC		0xc0
#define		SPC		0xc1
#define		CMDCH		0xc2
