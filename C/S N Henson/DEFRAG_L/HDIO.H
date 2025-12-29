/* Comment out this next line if you want to force ICD physical mode */
/*#define NO_ICD_PHYS*/ 

extern char *hdd_err[];

/* This structue is set/passed by disk I/O functions. */


struct hdinfo
{
	long start;	/* Partition start in physical sectors */
	long size;	/* Partition size in physical sectors */
	int scsiz;	/* Sector size 0=1K 1=512bytes */
	int rwmode;	/* how to access partition */
	/* Valid rw modes */
#define RW_NORMAL	0x0	/* Normal Rwabs */
#define RW_PHYS		0x1	/* Physical Rwabs */
#define RW_XHDI		0x2	/* XHDI */
#define RW_MODE		0x1f	/* Mask for I/O modes */
#define RW_LRECNO	0x20	/* Use lrecno */
#define RW_CHECK	0x40	/* Check partition boundaries */
	int major;	/* major device number, unit number or device */
	int minor;	/* minor device number or pun */
};

#ifdef __STDC__
# define	P(s) s
#else
# define P(s) ()
#endif


/* hdio.c */
int get_hddinf P((int drive , struct hdinfo *hdinf , int flag ));
int _get_hddinf P((int drive , struct hdinfo *hdinf , int flag ));
int set_lrecno P((struct hdinfo *hdinf , long size ));
int test_lrecno P((int drive , int mode ));
int no_lrecno P((int drv ));
int no_plrecno P((int drv ));
int no_xhdi P((void));
int init_icd P((void));
long block_rwabs P((int rw , void *buf , unsigned num , long recno , struct hdinfo *hdinf ));

#undef P
