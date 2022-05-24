typedef struct
{	short rsh_vrsn;				/* RCS version no. */
	unsigned short rsh_object;	/* offset to object[] */
	unsigned short rsh_tedinfo;	/* offset to tedinfo[] */
	unsigned short rsh_iconblk;	/* offset to iconblk[] */
	unsigned short rsh_bitblk;	/* offset to bitblk[] */
	unsigned short rsh_frstr;	/* offset to free string index */
	unsigned short rsh_string;	/* offset to first string */
	unsigned short rsh_imdata;	/* offset to image data */
	unsigned short rsh_frimg;	/* offset to free image index */
	unsigned short rsh_trindex;	/* offset to object tree index*/
	short rsh_nobs;				/* number of objects */
	short rsh_ntree;			/* number of trees */
	short rsh_nted;				/* number of tedinfos */
	short rsh_nib;				/* number of icon blocks */
	short rsh_nbb;				/* number of blt blocks */
	short rsh_nstring;			/* number of free strings */
	short rsh_nimages;			/* number of free images */
	unsigned short rsh_rssize;	/* total bytes in resource */
} RSHDR;

resource_fix(RSHDR *resource)
{
}
