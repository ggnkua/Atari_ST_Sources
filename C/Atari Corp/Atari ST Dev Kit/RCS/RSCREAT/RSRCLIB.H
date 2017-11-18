/*	RSRCLIB.H	05/05/84 - 09/13/84	Lowell Webster		*/

#define OP_VERSION control[0]
#define OP_CODE control[1]
#define OP_ID control[2]
#define OP_FLAGS control[3]
#define RET_CODE int_out[0]

#define RS_PFNAME addr_in[0]		/* rs_init, 			*/
#define RS_TYPE int_in[0]
#define RS_INDEX int_in[1]
#define RS_INADDR addr_in[0]
#define RS_OUTADDR addr_out[0]		


#define RMODE_RD 0
#define RMODE_WR 1
#define RMODE_RW 2

#define SMODE 0				/* seek mode is absolute offset	*/
#define F_ATTR 0			/* file attribute for creating	*/

typedef struct rssofln
{
	WORD	rss_offset;
	WORD	rss_length;
}RSSOFLN;

typedef struct imofln			/* image block structure	*/
{
	WORD	rim_offset;
	WORD	rim_length;
}IMOFLN;

typedef struct rstree
{
	WORD	rst_first;
	WORD	rst_count;
}RSTREE;

#define RES_TREE	8		/* # of long tree pointers	*/
					/*  reserved in the global array*/

			/* these must coincide w/ rshdr */
#define RT_VRSN 0
#define RT_OB 1
#define RT_TEDINFO 2
#define RT_ICONBLK 3
#define RT_BITBLK 4
#define RT_FREESTR 5
#define RT_STRING 6
#define RT_IMAGEDATA 7
#define	RT_FREEIMG 8
#define RT_TRINDEX 9

#define NUM_RTYPES 10

#define R_NOBS 10
#define R_NTREE 11
#define R_NTED 12
#define R_NICON 13
#define R_NBITBLK 14
#define R_NSTRING 15
#define R_IMAGES 16

#define NUM_RN 7

#define RS_SIZE 17				/* NUM_RTYPES + NUM_RN	*/

#define HDR_LENGTH (RS_SIZE + 1) * 2		/* in bytes	*/


typedef struct rshdr
{
	WORD		rsh_vrsn;	/* must same order as RT_	*/
	WORD		rsh_object;
	WORD		rsh_tedinfo;
	WORD		rsh_iconblk;	/* list of ICONBLKS		*/
	WORD		rsh_bitblk;
	WORD		rsh_frstr;	
	WORD		rsh_string;
	WORD		rsh_imdata;	/* image data			*/
	WORD		rsh_frimg;	
	WORD		rsh_trindex;
	WORD		rsh_nobs;	/* counts of various structs	*/
	WORD		rsh_ntree;
	WORD		rsh_nted;
	WORD		rsh_nib;
	WORD		rsh_nbb;
	WORD		rsh_nstring;
	WORD		rsh_nimages;
	WORD		rsh_rssize;	/* total bytes in resource	*/
}RSHDR;


/* type definitions for use by an application when calling	*/
/*  rsrc_gaddr and rsrc_saddr					*/

#define R_TREE 0
#define R_OBJECT 1
#define R_TEDINFO 2
#define R_ICONBLK 3
#define R_BITBLK 4
#define R_STRING 5		/* gets pointer to free strings	*/
#define R_IMAGEDATA 6		/* gets pointer to free images	*/
#define R_OBSPEC 7
#define R_TEPTEXT 8		/* sub ptrs in TEDINFO	*/
#define R_TEPTMPLT 9
#define R_TEPVALID 10
#define R_IBPMASK 11		/* sub ptrs in ICONBLK	*/
#define R_IBPDATA 12
#define R_IBPTEXT 13
#define R_BIPDATA 14		/* sub ptrs in BITBLK	*/
#define R_FRSTR 15		/* gets addr of ptr to free strings	*/
#define R_FRIMG 16		/* gets addr of ptr to free images	*/



