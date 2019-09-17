/*       EVENT Manager Definitions   */

                                      /* multiflags */
#define MU_KEYBD	0x0001
#define MU_BUTTON	0x0002
#define MU_M1		0x0004
#define MU_M2		0x0008
#define MU_MESAG	0x0010
#define MU_TIMER	0x0020
                                      /* keybord sates */
#define K_RSHIFT	0x0001
#define K_LSHIFT	0x0002
#define K_CTRL		0x0004
#define K_ALT		0x0008
                                      /* message values */
#define MN_SELECTED	10
#define WM_REDRAW	20
#define WM_TOPPED	21
#define WM_CLOSED	22
#define WM_FULLED	23
#define WM_ARROWED	24
#define WM_HSLID	25
#define WM_VSLID	26
#define WM_SIZED	27
#define WM_MOVED	28
#define WM_NEWTOP	29
#define AC_OPEN		40
#define AC_CLOSE	41


/*         FORM Manager definitions         */

                                             /* Form flags */
#define FMD_START	0
#define FMD_GROW	1
#define FMD_SHRINK	2
#define FMD_FINISH	3

/*     Resource Manager Definitions         */
                                             /* data structure types */

#define R_TREE		0
#define R_OBJECT	1
#define R_TEDINFO	2
#define R_ICONBLK	3
#define R_BITBLK	4
#define R_STRING	5	/* gets pointer to free strings */
#define R_IMAGEDATA	6	/* gets pointer to free images */
#define R_OBSPEC	7
#define R_TEPTEXT	8	/* sub ptrs in TEDINFO */
#define R_TEPTMPLT	9
#define R_TEPVALID	10
#define R_IBPMASK	11	/* sub ptrs in ICONBLK */
#define R_IBPDATA	12
#define R_IBPTEXT	13
#define R_BIPDATA	14	/* sub ptrs in BITBLK */
#define R_FRSTR		15	/* gets addr of ptr to free strings */
#define R_FRIMG		16	/* gets addr of ptr to free images */
                                        /* used in RSCREATE.C */

typedef struct rshdr
{
	int                 rsh_vrsn;			/* RCS version no. */
	int                 rsh_object;	        /* offset to object[] */
	int                 rsh_tedinfo;	    /* offset to tedinfo[] */
	int                 rsh_iconblk;	    /* offset to iconblk[] */
	int                 rsh_bitblk;	        /* offset to bitblk[] */
	int                 rsh_frstr;		    /* offset to free string index */
	int                 rsh_string;	        /* offset to first string */
	int                 rsh_imdata;	        /* offset to image data */
	int                 rsh_frimg;		    /* offset to free image index */
	int                 rsh_trindex;	    /* offset to object tree index */
	int                 rsh_nobs;			/* number of objects */
	int                 rsh_ntree;			/* number of trees */
	int                 rsh_nted;			/* number of tedinfos */
	int                 rsh_nib;			/* number of icon blocks */
	int                 rsh_nbb;			/* number of blt blocks */
	int                 rsh_nstring;		/* number of free strings */
	int                 rsh_nimages;		/* number of free images */
	int                 rsh_rssize;	        /* total bytes in resource */
} RSHDR;
#define F_ATTR 0                            /* file attribute for dos_create */


/*       Window Manager Definitions         */
                                            /* Window Attributes */
#define NAME		0x0001
#define CLOSER		0x0002
#define FULLER  	0x0004
#define MOVER		0x0008
#define INFO		0x0010
#define SIZER		0x0020
#define UPARROW		0x0040
#define DNARROW		0x0080
#define VSLIDE		0x0100
#define LFARROW		0x0200
#define RTARROW		0x0400
#define HSLIDE		0x0800
                                    /* wind_create flags */
#define WC_BORDER     0
#define WC_WORK       1
                                    /* wind_get flags */
#define WF_KIND		   1
#define WF_NAME 	   2
#define WF_INFO 	   3
#define WF_WORKXYWH	   4
#define WF_CURRXYWH	   5
#define WF_PREVXYWH	   6
#define WF_FULLXYWH	   7
#define WF_HSLIDE	   8
#define WF_VSLIDE	   9
#define WF_TOP		  10
#define WF_FIRSTXYWH  11	
#define WF_NEXTXYWH	  12
#define WF_RESVD	  13
#define WF_NEWDESK	  14
#define WF_HSLSIZE	  15
#define WF_VSLSIZE	  16
#define WF_SCREEN	  17
                                    /* update flags */
                                    
#define	END_UPDATE	0
#define	BEG_UPDATE	1
#define	END_MCTRL	2
#define	BEG_MCTRL	3


/*      GRAPHICS Manager Definitions                      */
                                    /* Mouse Forms        */
#define	ARROW		0
#define	TEXT_CRSR	1
#define	HOURGLASS	2
#define	POINT_HAND	3
#define	FLAT_HAND	4
#define	THIN_CROSS	5
#define	THICK_CROSS	6
#define	OUTLN_CROSS	7
#define	USER_DEF	255
#define M_OFF		256
#define M_ON		257


/*      MISCELLANEOUS Structures                          */
                                    /* Memory Form Definition Block */
typedef struct fdbstr
{
         long    fd_addr;
         int             fd_w;
         int             fd_h;
         int             fd_wdwidth;
         int             fd_stand;
         int             fd_nplanes;
         int             fd_r1;
         int             fd_r2;
         int             fd_r3;
}FDB;
                                    /* Mouse Form Definition Block  */
typedef struct mfstr
{
        int     mf_xhot;
        int     mf_yhot;
        int     mf_nplanes;
        int     mf_fg;
        int     mf_bg;
        int     mf_mask[16];
        int     mf_data[16];
} MFORM;
