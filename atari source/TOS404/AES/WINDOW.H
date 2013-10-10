/*	WINDOW.H		3/15/89 - 3/30/89	Derek Mui	*/
/*	Change w_iblk to w_ciblk	7/11/92		D.Mui		*/

#define	SUP	0
#define SDOWN	1
#define SLEFT	2
#define	SRIGHT	3

#define	MAXWIN		8	/* max number of window	*/

#define PATHLEN		128
#define INFOLEN		62

#define MAX_DEPTH  8		/* Max folder level	*/

#define	SCREEN	  0	/* related to background			*/

#define NAME		0x0001
#define CLOSE		0x0002
#define FULL		0x0004
#define MOVE		0x0008
#define INFO		0x0010
#define SIZE		0x0020
#define UPARROW		0x0040
#define DNARROW		0x0080
#define VSLIDE		0x0100
#define LFARROW		0x0200
#define RTARROW		0x0400
#define HSLIDE		0x0800

#define ALLITEMS 0x0FFF

typedef struct	grect
{
	WORD	x;
	WORD	y;
	WORD	w;
	WORD	h;
} GRECT;


typedef	struct	window
{
	BYTE	*w_next;		/* link pointer		*/
	UWORD	w_id;			/* window handle	*/
	UWORD	w_free;			/* window free to use	*/
	BYTE	*w_path;		/* window path name	*/
	BYTE	*w_buf;			/* scratch buffer	*/
	WORD	w_level;		/* max level allowed in this path */
	BYTE	w_info[INFOLEN];	/* info line		*/
	GRECT	w_sizes;	/* window current size and pos	*/
	GRECT	w_work;		/* the current working xywh	*/
	OBJECT	*w_obj;		/* pointer to objects			*/
	WORD	w_srtitem;	/* file item # to start with		*/
	WORD	w_icon;		/* disk icon that owns this window	*/
	WORD	w_vicons;	/* maximum visible icons		*/
	BYTE	*w_memory;	/* file memory owns by this window	*/
	WORD	w_items;	/* max number of file items		*/
	WORD	w_maxicons;	/* max # of icons allocated in window	*/
	WORD	w_icol;		/* max number of col at any time	*/
	WORD	w_irow;		/* max number of row at any time	*/
	TEDINFO	*w_ted;
	CICONBLK *w_ciblk;	/* starting address of ciconblk		*/
	BYTE	*w_text;	/* starting address of text		*/
	WORD	w_coli;		/* the horizontal column index 		*/
	WORD	w_hvicons;	/* number of invisible icon per row	*/
	WORD	w_rowi;		/* the vertical row index		*/
	WORD	w_vvicons;	/* number of invisible icon per col	*/
	WORD	w_xcol;		/* number of visible column of icon	*/
	WORD	w_xrow;		/* number of visible row of icon	*/
} WINDOW;	


struct	dir
{
	WORD	d_att;		/* attribute	*/
	UWORD	d_time;		/* time		*/
	UWORD	d_date;		/* date		*/
	LONG	d_size;		/* size		*/
	BYTE	d_name[14];	/* name		*/
	WORD	d_state;	/* selected	*/
	WORD	d_order;	/* file's order	*/
};

#define DIR struct dir

typedef	struct	dta
{
	BYTE	reserved[20];	/* reserved area*/
	DIR	dirfile;
} DTA;

typedef struct myblk
{
	GRECT	*mygrect;
	BYTE	*myptr;
} MYBLK;
