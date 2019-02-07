/* Symbol:	Definitions used by clients of Score Symbols
 * phil comeau 12-jul-89
 * last edited 17-jul-89 0003
 *
 * Copyright 1990 Antic Publishing Inc.
 */

/* Symbol Classes */
#define RSTSYMCLASS 1			/* raster symbols */
#define LINESYMCLASS 2			/* line symbols */
#define CRVSYMCLASS 3			/* curve symbols */
#define TXTSYMCLASS 4			/* text symbols */
#define TRLSYMCLASS 5			/* trill symbols */
#define LDGRLNSYMCLASS 6		/* ledgerline symbols */
#define SELSYMCLASS 7			/* selection symbols */
#define STFSYMCLASS 8			/* staff symbols */
#define BRACESYMCLASS 9			/* brace symbols */
#define BEAMSYMCLASS 10			/* beam symbols */

/* Symbol types */
#define SN1 1				/* whole note */
#define SR1 2				/* whole rest */
#define SN2UP 3				/* 1/2 note, stem up */
#define SN2DN 4				/* 1/2 note, stem down */
#define SR2 5				/* 1/2 rest */
#define SN4UP 6				/* 1/4 note, stem up */
#define SN4DN 7				/* 1/4 note, stem down */
#define SR4 8				/* 1/4 rest */
#define SN8UP 9				/* 8th note, stem up */
#define SN8DN 10			/* 8th note, stem down */
#define SR8 11				/* 8th rest */
#define SN16UP 12			/* 16th note, stem up */
#define SN16DN 13			/* 16th note, stem down */
#define SR16 14				/* 16th rest */
#define SN32UP 15			/* 32nd note, stem up */
#define SN32DN 16			/* 32nd note, stem down */
#define SR32 17				/* 32nd rest */
#define SN64UP 18			/* 64th note, stem up */
#define SN64DN 19			/* 64th note, stem down */
#define SR64 20				/* 64th rest */
#define SNAT 21				/* natural */
#define SSHARP 22			/* sharp */
#define SFLAT 23			/* flat */
#define SPIANO 24			/* piano mark */
#define SMEZZO 25			/* mezzo mark */
#define SFORTE 26			/* forte mark */
#define SN4HEAD 27			/* 1/4 note head */
#define SN2HEAD 28			/* half note head */
#define SDOT 29				/* dot */
#define STCLEF 30			/* treble clef */
#define SBCLEF 31			/* bass clef */
#define SACLEF 32			/* alto clef */
#define STURN 33			/* turn mark */
#define SSTAC 34			/* staccato mark */
#define SSEGNE 35			/* segne mark */
#define SCODA 36			/* coda mark */
#define SUPCRV 37			/* up curve */
#define SDNCRV 38			/* down curve */
#define STRILL 39			/* trill mark */
#define SBEAM 40			/* beam mark */
#define SLINE 41			/* line */
#define STEXT 42			/* text */
#define SBRACE 43			/* brace */
#define SLDGRLN 44			/* ledgerline */
#define SSTAFF 45			/* staff */
#define SSELECT 46			/* special selection symbol */
#define SGRACE 47			/* grace note */
#define SDSHARP 48			/* double sharp */
#define SFERMATA 49			/* fermata */

/* SYMBOL: Defines a musical or graphical symbol that can be drawn. Once
 * drawn, a symbol becomes an entity. A symbol can be thought of as a
 * template for an entity.
 */
typedef struct {
	int symTyp;			/* symbol type */
	int objId;			/* id of object representing this
					 * symbol in icon palette.
					 */
	int symClass;			/* symbol class: defines generic
					 * of this symbol (eg raster, text)
					 */
	char *symImg;			/* Pointer to the symbol's image
					 * bitmask (raster class symbols
					 * only)
					 */
	MSFORM *symMs;			/* pointer to structure describing
					 * the mouse form used for this
					 * symbol.
					 */
	char *symInfo;			/* pointer to symbol-specific
					 * information; NULL if not used.
					 */
	int symImgWd;			/* Width in pixels of the symbol's
					 * image bitmask.
					 */
	int symImgHt;			/* Height in pixels of the symbol's
					 * image bitmask.
					 */
	RECT2D symOrgRct;		/* rectangle surrounding symbol,
					 * relative to symbol's image
					 * (raster class symbols only)
					 */
	POINT2D symMsOff;		/* offset of the symbol's origin
					 * (the place where the user clicks
					 * to draw the symbol) from its
					 * graphical origin (eg. upper left
					 * corner of symbol's image)
					 * (raster class symbols only)
					 */
} SYMBOL;
