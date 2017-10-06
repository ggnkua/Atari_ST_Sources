#ifndef	__TYPES__
#define	__TYPES__

#include <fcntl.h>

#define	BYTE  signed char
#define	UBYTE unsigned char
#ifdef PUREC
#define	WORD  signed int
#define UWORD unsigned int
#else
#define WORD  signed short
#define UWORD unsigned short
#endif

#define LONG  signed long
#define ULONG unsigned long


#ifdef	PUREC
#define	CDECL cdecl
#else
#define	CDECL
#endif

#define NOT_USED(c) (void)c

/* Cookie structure */

typedef struct {
	LONG cookie;
	LONG value;
}COOKIE;

/* menu_settings uses a new structure for setting and inquiring the submenu
 * delay values and the menu scroll height.  The delay values are measured in
 * milliseconds and the height is based upon the number of menu items.
 */

typedef struct _mn_set {
	LONG display;   /*  the submenu display delay     */
  LONG drag;      /*  the submenu drag delay        */
  LONG delay;     /*  the single-click scroll delay */
  LONG speed;     /*  the continuous scroll delay   */
	WORD height;    /*  the menu scroll height        */
}MN_SET;

/* VDI Memory Form Definition Block */

typedef struct {
	void		*fd_addr;   /* Addrerss of upper left corner of first*/
                      /* plane of raster area. If NULL then    */
                      /* MFDB is for a physical device         */
	WORD		fd_w;	      /* Form Width in Pixels                  */
	WORD		fd_h;       /* Form Height in Pixels                 */
	WORD		fd_wdwidth; /* Form Width in shorts(fd_w/sizeof(int) */
	WORD		fd_stand;   /* Form format 0= device spec 1=standard */
	WORD		fd_nplanes; /* Number of memory planes               */
	WORD		fd_r1;      /* Reserved                              */
	WORD		fd_r2;      /* Reserved                              */
	WORD		fd_r3;      /* Reserved                              */
} MFDB;

/* Mouse Form Definition Block */
typedef struct mouse_form {
   WORD mf_xhot;
   WORD mf_yhot;
   WORD mf_nplanes;
   WORD mf_bg;
   WORD mf_fg;
   WORD mf_mask[16];
   WORD mf_data[16];
}MFORM;

typedef struct mouse_event_type {
	int	*x;
	int *y;
	int	*b;
	int	*k;
} Mouse;

typedef struct vdi_rectangle {
	int v_x1;
	int v_y1;
	int v_x2;
	int v_y2;
} VRECT;

typedef struct orect {
  struct orect	*o_link;
	int	o_x;
	int	o_y;
	int	o_w;
	int	o_h;
} ORECT;

typedef struct objc_colorword {
   unsigned borderc : 4;
   unsigned textc   : 4;
   unsigned opaque  : 1;
   unsigned pattern : 3;
   unsigned fillc   : 4;
}OBJC_COLORWORD;

typedef struct text_edinfo {
	BYTE           *te_ptext;     /* ptr to text */
	BYTE           *te_ptmplt;    /* ptr to template */
	BYTE           *te_pvalid;    /* ptr to validation chrs. */
	WORD           te_font;       /* font */
	WORD           te_fontid;     /* font id */
	WORD           te_just;       /* justification */
	OBJC_COLORWORD te_color;      /* color information word */
	WORD           te_fontsize;   /* font size */
	WORD           te_thickness;  /* border thickness */
	WORD           te_txtlen;     /* length of text string */
	WORD           te_tmplen;     /* length of template string */
} TEDINFO;

typedef struct icon_block {
	WORD	*ib_pmask;
	WORD	*ib_pdata;
	BYTE 	*ib_ptext;
	WORD	ib_char;
	WORD	ib_xchar;
	WORD	ib_ychar;
	WORD	ib_xicon;
	WORD	ib_yicon;
	WORD	ib_wicon;
	WORD	ib_hicon;
	WORD	ib_xtext;
	WORD	ib_ytext;
	WORD	ib_wtext;
	WORD	ib_htext;
}ICONBLK;

typedef struct bit_block {
	BYTE *bi_pdata;  /* ptr to bit forms data  */
	WORD bi_wb;      /* width of form in bytes */
	WORD bi_hl;      /* height in lines */
	WORD bi_x;       /* source x in bit form */
	WORD bi_y;       /* source y in bit form */
	WORD bi_color;   /* fg color of blt */
}BITBLK;

typedef struct cicon_data {
	WORD	            num_planes;
	WORD	            *col_data;
	WORD	            *col_mask;
	WORD	            *sel_data;
	WORD	            *sel_mask;
	struct cicon_data	*next_res;
}CICON;
	
typedef struct cicon_blk {
	ICONBLK monoblk;
	CICON   *mainlist;
}CICONBLK;

typedef struct {
    unsigned character   :  8;
    signed   framesize   :  8;
    unsigned framecol    :  4;
    unsigned textcol     :  4;
    unsigned textmode    :  1;
    unsigned fillpattern :  3;
    unsigned interiorcol :  4;
} bfobspec;

struct user_block;	/* forward declaration */

typedef union __u_ob_spec {
	TEDINFO           *tedinfo;
	LONG              index;
	BYTE              *free_string;
  union __u_ob_spec *indirect;
	bfobspec          obspec;
	BITBLK            *bitblk;
	ICONBLK           *iconblk;
	CICONBLK          *ciconblk;
	struct user_block *userblk;
} U_OB_SPEC;

typedef struct object {
	WORD	     ob_next;	/* -> object's next sibling	  	  */
	WORD	     ob_head;	/* -> head of object's children 	  */
	WORD	     ob_tail;	/* -> tail of object's children 	  */
	UWORD      ob_type;	/* type of object			  */
	UWORD      ob_flags;/* flags				  */
	UWORD      ob_state;/* state				  */
	U_OB_SPEC  ob_spec;	/* object-specific data			  */
	WORD	     ob_x;		/* upper left corner of object 		  */
	WORD	     ob_y;		/* upper left corner of object 		  */
	WORD	     ob_width; 	/* width of obj				  */
	WORD	     ob_height;	/* height of obj			  */
} OBJECT;

typedef struct parm_block {
   OBJECT *pb_tree;
   WORD   pb_obj;
   WORD   pb_prevstate;
   WORD   pb_currstate;
   WORD   pb_x, pb_y, pb_w, pb_h;
   WORD   pb_xc, pb_yc, pb_wc, pb_hc;
   LONG   pb_parm;
}PARMBLK;

typedef struct user_block {
  int __CDECL (*ub_code)(PARMBLK *parmblock);
	LONG        ub_parm;
}USERBLK;

						/* used in RSCREATE.C	*/
typedef struct rshdr {
	WORD  rsh_vrsn;
	UWORD rsh_object;
	UWORD	rsh_tedinfo;
	UWORD	rsh_iconblk;	/* list of ICONBLKS		*/
	UWORD	rsh_bitblk;
	UWORD	rsh_frstr;	
	UWORD	rsh_string;
	UWORD	rsh_imdata;	/* image data			*/
	UWORD	rsh_frimg;	
	UWORD	rsh_trindex;
	WORD  rsh_nobs;	/* counts of various structs	*/
	WORD  rsh_ntree;
	WORD  rsh_nted;
	WORD  rsh_nib;
	WORD  rsh_nbb;
	WORD  rsh_nstring;
	WORD  rsh_nimages;
	UWORD	rsh_rssize;	/* total bytes in resource	*/
} RSHDR;

/* falcon aes menu_popup and menu_attach structure for passing and receiving
 * submenu data.
 */

typedef struct _menu
{
    OBJECT *mn_tree;    /* the object tree of the menu */
    WORD    mn_menu;    /* the parent object of the menu items */
    WORD    mn_item;    /* the starting menu item */
    WORD    mn_scroll;  /* the scroll field status of the menu 
                           0  - The menu will not scroll
                           !0 - The menu will scroll if the number of menu
                                items exceed the menu scroll height. The 
				non-zero value is the object at which 
				scrolling will begin.  This will allow one
				to have a menu in which the scrollable region
				is only a part of the whole menu.  The value
				must be a menu item in the menu.
				
                                menu_settings can be used to change the menu
                                scroll height. 

                         NOTE: If the scroll field status is !0, the menu
                               items must consist entirely of G_STRINGS. */
    WORD    mn_keystate; /* The CTRL, ALT, SHIFT Key state at the time the
			    mouse button was pressed. */
}MENU_T;

typedef MENU_T MENU;


typedef struct
{
        int     m_out;
        int     m_x;
        int     m_y;
        int     m_w;
        int	m_h;
} MOBLK;

typedef struct _shelw {
	BYTE *newcmd;
	LONG psetlimit;
	LONG prenice;
	BYTE *defdir;
	BYTE *env;
}SHELW;

		/* struct used by appl_trecord and appl_tplay */
typedef struct pEvntrec {
   LONG ap_event;
   LONG ap_value;
}EVNTREC;

typedef struct {
	LONG	msg1;
	LONG	msg2;
	WORD	pid;
}MSG;

typedef struct {
	WORD	x;
	WORD	y;
	WORD	width;
	WORD	height;
}RECT;

typedef enum
{
	FALSE =	0,
	TRUE	=	1
}BOOLEAN;

typedef struct {
	LONG userlong1;
	LONG userlong2;
	WORD pid;
}PMSG;

typedef struct  {
  UWORD mode;
  LONG  index;
  UWORD dev;
  UWORD reserved1;
  UWORD nlink;
  UWORD uid;
  UWORD gid;
  LONG  size;
  LONG  blksize;
  LONG  nblocks;
  WORD  mtime;
  WORD  mdate;
  WORD  atime;
  WORD  adate;
  WORD  ctime;
  WORD  cdate;
  WORD  attr;
  WORD  reserved2;
  LONG  reserved3;
  LONG  reserved4;
}XATTR;

struct filesys;		/* forward declaration */
struct devdrv;		/* ditto */

typedef struct f_cookie {
	struct filesys *fs; /* filesystem that knows about this cookie */
	UWORD dev;          /* device info (e.g. Rwabs device number) */
	UWORD aux;          /* extra data that the file system may want */
	LONG  index;        /* this+dev uniquely identifies a file */
} fcookie;

typedef struct fileptr {
	WORD  links;          /* number of copies of this descriptor */
	UWORD flags;          /* file open mode and other file flags */
	LONG  pos;            /* position in file */
	LONG  devinfo;        /* device driver specific info */
	fcookie	fc;           /* file system cookie for this file */
	struct devdrv *dev;   /* device driver that knows how to deal with this */
	struct fileptr *next; /* link to next fileptr for this file */
} FILEPTR;


#define TOS_SEARCH	0x01

/* structure for opendir/readdir/closedir */
typedef struct dirstruct {
	fcookie fc;             /* cookie for this directory */
	UWORD   index;          /* index of the current entry */
	UWORD   flags;          /* flags (e.g. tos or not) */
	BYTE    fsstuff[60];    /* anything else the file system wants */
                          /* NOTE: this must be at least 45 bytes */
	struct dirstruct *next; /* linked together so we can close them
                             on process termination */
} DIR;

typedef struct devdrv {
	LONG CDECL (*open)(FILEPTR *f);
	LONG CDECL (*write)(FILEPTR *f, const BYTE *buf, LONG bytes);
	LONG CDECL (*read)(FILEPTR *f, BYTE *buf, LONG bytes);
	LONG CDECL (*lseek)(FILEPTR *f, LONG where, WORD whence);
	LONG CDECL (*ioctl)(FILEPTR *f, WORD mode, void *buf);
	LONG CDECL (*datime)(FILEPTR *f, WORD *timeptr, WORD rwflag);
	LONG CDECL (*close)(FILEPTR *f, WORD pid);
	LONG CDECL (*select)(FILEPTR *f, LONG proc, WORD mode);
	void CDECL (*unselect)(FILEPTR *f, LONG proc, WORD mode);

/* extensions, check dev_descr.drvsize (size of DEVDRV struct) before calling:
 * fast RAW tty byte io  */

	LONG CDECL (*writeb)(FILEPTR *f, const BYTE *buf, LONG bytes);
	LONG CDECL (*readb)(FILEPTR *f, BYTE *buf, LONG bytes);

/* what about: scatter/gather io for DMA devices...
 *	LONG CDECL (*writev)	P_((FILEPTR *f, const struct iovec *iov, LONG cnt));
 *	LONG CDECL (*readv)	P_((FILEPTR *f, const struct iovec *iov, LONG cnt));
 */

} DEVDRV;


#define FS_KNOPARSE      0x01 /* kernel shouldn't do parsing */
#define FS_CASESENSITIVE 0x02 /* file names are case sensitive */
#define FS_NOXBIT        0x04 /* if a file can be read, it can be executed */
#define	FS_LONGPATH      0x08 /* file system understands "size" argument to
                                 "getname" */

typedef struct filesys {
	struct filesys	*next;	/* link to next file system on chain */
	LONG   fsflags;
	LONG   CDECL (*root)(WORD drv,fcookie *fc);
	LONG   CDECL (*lookup)(fcookie *dir, const BYTE *name, fcookie *fc);
	LONG   CDECL (*creat)(fcookie *dir, const BYTE *name, UWORD mode,
	                      WORD attrib, fcookie *fc);
	DEVDRV * CDECL (*getdev)(fcookie *fc, LONG *devspecial);
	LONG	CDECL (*getxattr)(fcookie *file, XATTR *xattr);
	LONG	CDECL (*chattr)(fcookie *file, WORD attr);
	LONG	CDECL (*chown)(fcookie *file, WORD uid, WORD gid);
	LONG	CDECL (*chmode)(fcookie *file, WORD mode);
	LONG	CDECL (*mkdir)(fcookie *dir, const BYTE *name, UWORD mode);
	LONG	CDECL (*rmdir)(fcookie *dir, const BYTE *name);
	LONG	CDECL (*remove)(fcookie *dir, const BYTE *name);
	LONG	CDECL (*getname)(fcookie *relto, fcookie *dir,
                         BYTE *pathname, WORD size);
	LONG	CDECL (*rename)(fcookie *olddir, BYTE *oldname,
			    fcookie *newdir, const BYTE *newname);
	LONG	CDECL (*opendir)(DIR *dirh, WORD tosflag);
	LONG	CDECL (*readdir)(DIR *dirh, BYTE *name, WORD namelen, fcookie *fc);
	LONG	CDECL (*rewinddir)(DIR *dirh);
	LONG	CDECL (*closedir)(DIR *dirh);
	LONG	CDECL (*pathconf)(fcookie *dir, WORD which);
	LONG	CDECL (*dfree)(fcookie *dir, LONG *buf);
	LONG	CDECL (*writelabel)(fcookie *dir, const BYTE *name);
	LONG	CDECL (*readlabel)(fcookie *dir, BYTE *name, WORD namelen);
	LONG	CDECL (*symlink)(fcookie *dir, const BYTE *name, const BYTE *to);
	LONG	CDECL (*readlink)(fcookie *dir, BYTE *buf, WORD len);
	LONG	CDECL (*hardlink)(fcookie *fromdir, const BYTE *fromname,
				fcookie *todir, const BYTE *toname);
	LONG	CDECL (*fscntl)(fcookie *dir, const BYTE *name, WORD cmd, LONG arg);
	LONG	CDECL (*dskchng)(WORD drv);
	LONG	CDECL (*release)(fcookie *);
	LONG	CDECL (*dupcookie)(fcookie *new, fcookie *old);
} FILESYS;


/* structure for internal kernel locks */
typedef struct ilock {
	struct flock l;		/* the actual lock */
	struct ilock *next;	/* next lock in the list */
	LONG	reserved[4];	/* reserved for future expansion */
} LOCK;

/* different process queues */

#define CURPROC_Q 0
#define READY_Q   1
#define WAIT_Q    2
#define IO_Q      3
#define ZOMBIE_Q  4
#define TSR_Q     5
#define STOP_Q    6
#define SELECT_Q  7

#define NUM_QUEUES	8

typedef LONG CDECL (*Func)();

struct kerinfo {
	WORD  maj_version;	/* kernel version number */
	WORD  min_version;	/* minor kernel version number */
	UWORD default_perm;	/* default file permissions */
	WORD  reserved1;	/* room for expansion */

/* OS functions */
	Func	*bios_tab;	/* pointer to the BIOS entry points */
	Func	*dos_tab;	/* pointer to the GEMDOS entry points */

/* media change vector */
	void	CDECL (*drvchng)(UWORD dev);

/* Debugging stuff */
	void	CDECL (*trace)(const BYTE *, ...);
	void	CDECL (*debug)(const BYTE *, ...);
	void	CDECL (*alert)(const BYTE *, ...);
	void CDECL (*fatal)(const BYTE *, ...);

/* memory allocation functions */
	void *	CDECL (*kmalloc)(LONG);
	void	CDECL (*kfree)(void *);
	void *	CDECL (*umalloc)(LONG);
	void	CDECL (*ufree)(void *);

/* utility functions for string manipulation */
	WORD	CDECL (*strnicmp)(const BYTE *, const BYTE *, WORD);
	WORD	CDECL (*stricmp)(const BYTE *, const BYTE *);
	BYTE *	CDECL (*strlwr)(BYTE *);
	BYTE *	CDECL (*strupr)(BYTE *);
	WORD	CDECL (*sprintf)(BYTE *, const BYTE *, ...);

/* utility functions for manipulating time */
	void	CDECL (*millis_time)(ULONG ms, WORD *td);
	LONG	CDECL (*unixtim)(UWORD time, UWORD date);
	LONG	CDECL (*dostim)(LONG unixtime);

/* utility functions for dealing with pauses, or for putting processes
 * to sleep
 */
	void	CDECL (*nap)(UWORD n);
	WORD	CDECL (*sleep)(WORD que, LONG cond);
	void	CDECL (*wake)(WORD que, LONG cond);
	void	CDECL (*wakeselect)(LONG param);

/* file system utility functions */
	WORD	CDECL (*denyshare)(FILEPTR *, FILEPTR *);
	LOCK *	CDECL (*denylock)(LOCK *, LOCK *);

/* reserved for future use */
	LONG	res2[9];
};

#define DEV_INSTALL 0xde02

struct dev_descr {
	DEVDRV *driver;
	WORD   dinfo;
	WORD   flags;
	void   *tty;
	LONG   drvsize;		/* size of DEVDRV struct */
	LONG   reserved[3];
};



typedef struct ap_info {
	WORD   id;         /*application id                                   */
	WORD   pid;        /*process id of the head process of the application*/
	WORD   vid;        /*VDI workstation id of application                */
	BYTE   *msgname;   /*name of message pipe of application              */
	WORD   msgpipe;    /*handle of the message pipe                       */
	BYTE   *eventname; /*name of event pipe                               */
	WORD   eventpipe;  /*handle of event pipe                             */
	RSHDR  *rshdr;     /*pointer to memory allocated for resources or 0L  */
	OBJECT *deskbg;    /*pointer to object tree of desktop, or 0L         */
	OBJECT *menu;      /*pointer to object tree of menu, or 0L            */
	WORD   deskmenu;   /*index of desk menu box                           */
	WORD   newmsg;     /*indicates which messages that are understood     */
	WORD   type;       /*application type (acc or app etc)                */
	struct ap_list  *ap_search_next; /* appl_search() pointer to next app */

	BYTE   name[21];   /* pretty name of process, init. filename          */
}AP_INFO;

typedef struct ap_list {
	AP_INFO        *ai;
	struct ap_list *next;
	struct ap_list *mn_next; /* menu link */
}AP_LIST;

typedef struct global_array {
	WORD    version;
	WORD    numapps;
	WORD    apid;
	LONG    appglobal;
	OBJECT  **rscfile;
	RSHDR   *rshdr;
	WORD    resvd1;
	WORD    resvd2;
	AP_INFO *int_info;
	WORD    maxchar;
	WORD    minchar;
}GLOBAL_ARRAY;

typedef struct aes_pb {
	WORD         *control;
	GLOBAL_ARRAY *global;
	WORD         *int_in;
	WORD         *int_out;
	LONG         *addr_in;
	LONG         *addr_out;
}AES_PB;

typedef struct rlist {
	RECT	r;
	
	struct rlist *next;
}RLIST;

typedef struct winstruct {
	WORD   id;       /*window id*/
	
	WORD   status;   /*window status*/
	WORD   elements; /*window elements*/
	
	OBJECT *tree;	/*object tree of the window elements*/

	RECT   worksize; /*current worksize*/
	RECT   totsize;  /*current total size*/
	RECT   lastsize; /*previous total size*/
	RECT   maxsize;  /*maximal total size*/
	RECT   origsize; /*original, uniconified, size*/
	
	WORD hslidepos;     /*position of the horizontal slider*/
	WORD vslidepos;     /*position of the vertical slider*/
	WORD hslidesize;    /*size of the horizontal slider*/
	WORD vslidesize;   /*size of the vertical slider*/
	
	RLIST	*rlist;		/*rectangle list of the window*/
	RLIST	*rpos;		/*pointer to help wind_get to traverse the
										rectangle list*/
	
	WORD	owner;		/*application id of the owner*/

	OBJC_COLORWORD top_colour[20];
	OBJC_COLORWORD untop_colour[20];
	WORD own_colour;
}WINSTRUCT;

typedef struct winlist
{
	WINSTRUCT	*win;

	struct winlist	*next;
}WINLIST;

#endif
