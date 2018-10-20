/* 

		Definitions for Grape Import/Export modules
		
*/


#if  !defined( __FIODEF__ )
#define __FIODEF__


#if !defined(uchar)
#define uchar	unsigned char
#endif

#define _GF_ fblock.gpfio->

/* Format and subcode definitions */
#define B1	0			/* Format 1 Bit, BW or color */
#define		B1_WB	0		/*	0=White, 1=Black */
#define		B1_BW	1		/*	1=White, 0=Black */
#define		B1_CL 2		/*	0=pal[0], 1=pal[1] */

#define B4	1			/* Format 4 Bit, colors = pal[0-15] */
#define 	B4_PP			0		/*	PixelPacked (1 Byte=2 Pixel) */
#define		B4_IP_FL 	1		/* 	Interleaved Bitplanes, first bit=low bit */
#define		B4_IP_FH 	2		/* 	Interleaved Bitplanes, first bit=high bit */

#define B8	2			/* Format 8 Bit, grey or color */
#define		B8_GWBPP 		0		/* PixelPacked, Grey, 0=White, 255=Black */
#define		B8_GBWPP 		1		/* PixelPacked, Grey, 255=White, 0=Black */
#define		B8_GWBIP_FL 2		/* Interleaved Bitplanes, 0=White, 255=Black, first bit=low bit */
#define		B8_GWBIP_FH 3		/* Interleaved Bitplanes, 0=White, 255=Black, first bit=high bit */
#define		B8_GBWIP_FL 4		/* Interleaved Bitplanes, 255=White, 0=Black, first bit=low bit  */
#define		B8_GBWIP_FH 5		/* Interleaved Bitplanes, 255=White, 0=Black, first bit=high bit */
#define		B8_CPP	 		6		/* PixelPacked, colors=pal[0-255] */
#define		B8_CIP_FL	 	7		/* Interleaved Bitplanes, colors=pal[0-255], first bit=low bit  */
#define		B8_CIP_FH	 	8		/* Interleaved Bitplanes, colors=pal[0-255], first bit=high bit  */

#define	B24	3			/* Format 24 Bit (true color) */
#define		B24_RGBPP	0		/* PixelPacked, RGB */
#define		B24_RGBIP 1		/* Interleaved BYTE(!)planes, RGB */
#define		B24_CMYPP	2		/* PixelPacked, CMY */
#define		B24_CMYIP 3		/* Interleaved BYTE(!)planes, CMY */
#define		B24_RPP		4		/* Single PixelPacked Plane, Red */
#define		B24_GPP		5		/* Single PixelPacked Plane, Green */
#define		B24_BPP		6		/* Single PixelPacked Plane, Blue */
#define		B24_CPP		7		/* Single PixelPacked Plane, Cyan */
#define		B24_MPP		8		/* Single PixelPacked Plane, Magenta */
#define		B24_YPP		9		/* Single PixelPacked Plane, Yellow */

#define B32 4		/* Format 32 Bit (true color) */
#define		B32_CMYKPP	0	/* PixelPacked, CMYK */
#define		B32_CMYKIP	1	/* Interleaved BYTE(!)planes, CMYK */
#define		B32_CPP			3	/* Single PixelPacked Plane, Cyan */
#define		B32_MPP			4	/* Single PixelPacked Plane, Magenta */
#define		B32_YPP			5	/* Single PixelPacked Plane, Yellow */
#define		B32_KPP			6	/* Single PixelPacked Plane, Black */

/* get/set_pal definitions */
#define RGB_8				0	/* RGB-values 0-255 */
#define CMY_8				1	/* CMY-values 0-255 */
#define RGB_PM			2	/* RGB-values promille */
#define CMY_PM			3	/* CMY-values promille */
#define RGB_PM_VDI	4	/* RGB-values promille, Atari-XBIOS-Palette */
#define CMY_PM_VDI	5	/* CMY-values promille, Atari-XBIOS-Palette */

/* Export-Support definitions */
#define SUP1			1		/* 1 Bit B/W */
#define SUP4			2		/* 4 Bit, 16 Colors */
#define	SUP8G			4		/* 8 Bit, Grey */
#define SUP8C			8		/* 8 Bit, Colorpalette */
#define	SUP24RGB	16	/* 24 Bit RGB */
#define SUP24CMY	32	/* 24 Bit CMY */
#define SUP32			64	/* 32 Bit CMYK */

/* identify()-returncodes */
#define	UNKNOWN 0
#define	EXT_REC	1	/* Extender (z.B. ".IMG") erkannt */
#define EDT_REC 2 /* Extender und Data (z.B. w*h=filesize) erkannt */
#define REL_REC 3 /* ZuverlÑssige Erkennung (z.B. magic-string) */
#define	CAN_LOAD 4 /* Wird mit Erkennungscode ver-odert, wenn 
											Datei vom Modul geladen werden kann */
#define FAST_LOAD 8 /* Wird mit CAN_LOAD verodert, wenn Modul speziell
											 fÅr das erkannte Format optimiert ist */

typedef struct
{/* Freie Optionen fÅr Exportformatdefinition */
	int		possibs;	/* <2:Checkbox, >=2:Popup */
	char	**names;	/* Stringpointerarray fÅr Checkboxtext bzw.
										 Popuptexte, je max. 16 Zeichen */
}OPTION;

typedef struct
{/* Descriptor of Grape-memory-Image */
	int	height;
	int	width;
	int line_width;
	
	/* Either c,m,y or mask is set to NULL */
	uchar	*c;
	uchar *m;
	uchar *y;
	
	uchar *mask;
	
	int		mode;	/* Set by Grape on Import: 0=just import
								1=Use active mask, use Insert-Settings */ 
	long	done_bytes;	/* Used for clock-mousepointer */
}GRAPE_DSCR;

typedef struct
{/* Descriptor of Memory-Image-Block */
	int	format;
	int	subcode;

	int	height;	/* Total size of Import/Export-Image (Pixels) */
	int	width;
		
	uchar	*data;
	
	int		x;		/* Block of Import/Export Image at *data */
	int		y;
	int		w;
	int		h;
	int		lw;		/* line-width of block (Pixels) */
}BLOCK_DSCR;

typedef struct
{/* Descriptor einer Grafikdatei */
 /* Hier darf ausschlieûlich gelesen werden: */
	int 	fh;			/* Handle des geîffneten Files */
	long 	flen;		/* Dateigrîûe in Bytes */
	uchar *buf256;/* Die ersten 256 Zeichen der Datei */
	
	char	*path;	/* Der Pfad der Datei (mit abschlieûendem '\') */
	char	*name;	/* Der Dateiname ohne Endung (und ohne '.') */
	char	*ext;		/* Die Endung mit fÅhrendem '.' oder nur 0 */

	/* Diese Daten werden vom Modul geliefert: */
	char	*descr;	/* Description of Fileformat, max. 8x45 chars */
	int		width;
	int		height;
}FILE_DSCR;

typedef struct
{
	/* Set the color-palette for loading to pal[n][3], where
		pal[0][0]=R[0], pal[0][1]=G[0], pal[0][2]=B[0]
		pal[1][0]=R[1], pal[1][1]=G[1], pal[1][2]=B[1]
		...
	*/
	void cdecl 			(*set_col_pal)(int mode, int num, int *pal);

	/* Get the color-palette for saving */
	int	*cdecl				(*get_col_pal)(int mode, int num);
	
	/* Store the loaded block of format/subcode starting at data
		 with lw pixels width at the Destination dd in x,y,w,h
		 (dd came from Grape with the load-command)
	*/
	void cdecl			(*store_block)(BLOCK_DSCR *bd, GRAPE_DSCR *dd);
	
	/* Copy the Block x,y,w,h from sd to the Destination starting at
		 data with width lw, convert from Grape format to format/subcode
	*/
	void cdecl			(*get_block)(BLOCK_DSCR *bd, GRAPE_DSCR *sd);

	/* Module can't form_alert, because it has no initialized global,
  	use this one instead */
	int cdecl				(*form_alert)(int fo_adefbttn, const char *fo_astring );
	
	/* don't use your own malloc-lib, save memory: */
	void *cdecl			(*malloc)( size_t size );
	void *cdecl			(*calloc)( size_t nitems, size_t size );
	void *cdecl 		(*realloc)( void *block, size_t newsize );
	void cdecl			(*free)( void *ptr );
}GRAPE_FIOFN;

typedef struct
{
	void cdecl			(*mod_init)(void);	/* Initialisierung des Moduls */

	int cdecl				(*identify)(FILE_DSCR *fd);

	int cdecl				(*load_file)(FILE_DSCR *fd, GRAPE_DSCR *dd);
	
	int cdecl				(*save_file)(FILE_DSCR *fd, GRAPE_DSCR *sd, int ex_format, int cmp_format, int *options);
}MODULE_FIOFN;

typedef struct
{
	char			magic[12]; /* Muû "GRAPEFIOMOD"+'0' sein */
	long			version;	 /* Schnittstellen-Version, diese: '0101' */

	
	/* Daten des Moduls, werden von Grape erst nach mod_init gelesen */

	long			id;					/* Moduleigene ID, 4 Zeichen */
	char			name[20];		/* Der Name des unterstÅzten Basisformats
													(TIFF, TARGA etc..), max. 20 Zeichen,
													Nullzeichen muû nicht vorhanden sein */

	uchar			ex_formats;		/* UnterstÅtzte Export-Formate 
														(SUPx verodert)*/

	int				cmp_num;			/* Anzahl der Kompressionsverfahren */
	char			**cmp_names;	/* Bezeichnungen der Kompressionsverfahren,
															je max. 20 Zeichen  */
	
	int				opt_num;			/* Anzahl der Optionen */
	OPTION		*options;			/* Array der Optionen */
		
	/* Funktionspointer */
	MODULE_FIOFN	*mod_fn;	/* Wird vom Modul gefÅllt */
	
	/* Wird von Grape ausgefÅllt */
	GRAPE_FIOFN	*gpfio;				/* Div. Funktionspointer */
}FIOMODBLK;

#endif