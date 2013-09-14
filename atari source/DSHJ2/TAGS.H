/*
	Tag attributes is applied only to text delimited
	by the start and end Tag points.
Function Name		Function #	Argument(s)
-------------		----------	-------------------------
Point	Size		1		Use 1 int
Set	Size		2		Use 1 int
Font			3		Use 1 int
Advance Leading		4		Use 1 long
Reverse Leading		5		Use 1 long
Horizontal Move Right	6		Use 1 int
Horizontal Move Left	7		Use 1 int
Auto. Char. Comp.	8		Use 1 int (flag+mode)
					mode	0 - Off
						1 - loosest	value
						2 - medium	value
						3 - tightest	value
Manual Char. Comp.	9		Use 1 int (flag+mode)
					mode	0	- Off
						others	- On
Kerning			10		Use 1 int (flag+mode)
					mode	0 - Off, 1 - On
Reverse Video		11		Use 1 int (flag+mode)
					mode	0 - Off, 1 - On
Justification Mode	12		Use 1 int (flag+mode)
					mode	0 - Justified
						1 - Quadded Left
						2 - Quadded Right
						3 - Quadded Center
Flash	Only		13		Use 1 char (flag)
					flag	0 - Off, 1 - On
Flash	Off		14		Use 1 char (flag)
					flag	0 - Off, 1 - On
Pseudo	Italic		15		Use 1 int (flag+mode)
					mode	0	- Off
						others	- On
Insert	Character	16		Use 1 int (flag+char)
					char	- character to insert
Letter	Spacing		17		Use 2 ints
					byte0	- cmd flag
					byte1	- 0: Off, 1: On
					byte2	- Pos. Letter Space
					byte3	- Neg. Letter Space
Hyphenation		18		Use 3 ints
					int0	- cmd flag
					byte0	- mode	0: Off, 1: On
					byte1	- # of successive hyphens
					byte2	- # of chars before hyphen
					byte3	- # of chars after hyphen
Space	Band		19		Use 2 ints
					byte0	- cmd flag
					byte1	- Minimum	Space
					byte2	- Preferred	Space
					byte3	- Maximum	Space
*/
struct	STYtag {
	unsigned	ptsz;	/* PoinT SiZe	in 1/8ths Point	*/
	unsigned	ssiz;	/* Set	 SIZe	in 1/8ths Point	*/
	unsigned	font;	/* FONT number	(1 to 9999)	*/
	unsigned long	avld;	/* AdVance Lead		in VMS	*/
	unsigned long	rvld;	/* ReVerse Lead 	in VMS	*/
	unsigned	hmvr;	/* Hor. MoVe Right	in HMS	*/
	unsigned	hmvl;	/* Hor. MoVe Left	in HMS	*/
	char		acfg;
	char		acomp;	/* Auto.  char. COMPensation	*/
	char		mcfg;
	char		mcomp;	/* Manual char. COMPensation	*/
	char		krfg;
	char		kernmd;	/* KERNing	 MoDe		*/
	char		rvfg;
	char		rvomd;	/* Reverse VideO MoDe		*/
	char		jmfg;
	char		jstmd;	/* JuSTification MoDe		*/
	char		fonmd;	/* Flash ONly	 MoDe		*/
	char		fofmd;	/* Flash OFf	 MoDe		*/
	char		pifg;
	char		psimd;	/* PSeudo Italic MoDe		*/
	char		icfg;
	char		iCHR;	/* Insert CHaRacter		*/
	char		ltfg;
	char		ltsmd;	/* LetTerSpacing MoDe		*/
	char		plts;	/* Positive LetTer Space in RU	*/
	char		nlts;	/* Negative LetTer Space in RU	*/
	int		hyfg;
	char		hypmd;	/* HYPhenation	 MoDe		*/
	char		nsuchyp;/* No. of SUCcessive	HYPhens	*/
	char		nbefhyp;/* No. of chars BEFore	HYPhen	*/
	char		nafthyp;/* No. of chars AFTer	HYPhen	*/
	char		spfg;
	char		minsp;	/* MINimum	SPace	 in RU	*/
	char		prfsp;	/* PReFerred	SPace	 in RU	*/
	char		maxsp;	/* MAXimum	SPace	 in RU	*/
	char		used;	/* flag if tag used...		*/
};				/* structure size = 48 bytes	*/

/*
	ARRAY of pointers to STYTAG structure
*/
#define		NUMTAG		200
struct	STYtag	Tagarray[NUMTAG];
