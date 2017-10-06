/*
 *	WinDom, Librairie GEM par Dominique BÇrÇziat
 *	copyright 1997/2001
 *
 *	module: cookie.h
 *	description: dÇfinition de quelques cookies
 */

/* WinX */

#define WINX_COOKIE	0x57494E58UL	/* 'WINX' */

/* IConiFy Server */

#define ICFS_COOKIE	0x49434653UL	/* 'ICFS' */

#define ICF_GETSIZE  0x0000
#define ICF_GETPOS   0x0001
#define ICF_FREEPOS  0x0002
#define ICF_FREEALL  0x0100
#define ICF_INFO     0x0200
#define ICF_CONFIG   0x0201
#define ICF_SETSIZE  0x0202
#define ICF_SETSPACE 0x0203

struct _config_icfs {
 unsigned WORD reserved : 13; /* unbenutzt, sollte 0 sein */
 unsigned WORD yfirst   : 1;  /* Bit 2: 1=zuerst in y-Richtung */
 unsigned WORD right    : 1;  /* Bit 1: 1=rechts anfangen */
 unsigned WORD top      : 1;  /* Bit 0: 1=oben anfangen */
};

typedef struct {
 unsigned WORD version;  /* Versionsnummer als BCD (0x0010 fÅr 0.10) */
 struct _config_icfs config; /* Config., siehe oben */
 WORD xsize, ysize,      /* Breite und Hîhe des Fensters, default=72 */
      xspace, yspace;    /* Abstand zwischen Fenstern, default=0 */
} ICFSCONFIG;


/* MagiC */
#define MAGX_COOKIE     0x4D616758UL	/* 'MagX' */
typedef struct {
     long magic;                   /* muû $87654321 sein              */
     void *membot;                 /* Ende der AES- Variablen         */
     void *aes_start;              /* Startadresse                    */
     long magic2;                  /* ist 'MAGX'                      */
     long date;                    /* Erstelldatum ttmmjjjj           */
     void (*chgres)(int res, int txt);  /* Auflîsung Ñndern           */
     long (**shel_vector)(void);   /* residentes Desktop              */
     char *aes_bootdrv;            /* von hieraus wurde gebootet      */
     int  *vdi_device;             /* vom AES benutzter VDI-Treiber   */
     void *reservd1;
     void *reservd2;
     void *reservd3;
     int  version;                 /* z.B. $0201 ist V2.1             */
     int  release;                 /* 0=alpha..3=release              */
} AESVARS;

typedef struct {
     long    config_status;
     void *dosvars;
     AESVARS *aesvars;
     void *res1;
     void *hddrv_functions;
     long status_bits;             /* MagiC 3 ab 24.5.95         */
} MAGX_INFOS;

/* MiNT */
#define MiNT_COOKIE     0x4D694E54UL	/* 'MiNT' */

/* Let's Them Fly */
#define LTMF_COOKIE		0x4C544D46UL	/* 'LTMF' */

/* Nvdi */
#define NVDI_COOKIE		0x4E564449UL	/* 'NVDI' */
typedef struct { 
   int  version;  /*  e.g. 0x0301 for version 3.01 */ 
   long  date;    /*  e.g. 0x18061990L for 18.06.1990 */ 
} NVDI_STRUC; 

/* Naes */

#define NAES_COOKIE		0x6E414553UL	/* 'nAES' */

typedef struct {
	unsigned int	version;
	unsigned int	date;
	unsigned int	time;
	unsigned int	flags;
	unsigned long	unused_1;
	unsigned long	unused_2;
} N_AESINFO;

/* BubbleGEM */

#define BUBBLEGEM_REQUEST  0xBABA
#define BUBBLEGEM_SHOW     0xBABB
#define BUBBLEGEM_ACK      0xBABC
#define BUBBLEGEM_ASKFONT  0xBABD
#define BUBBLEGEM_FONT     0xBABE
#define BUBBLEGEM_HIDE     0xBABF

/* drapeaux pour 'BHLP' */
#define BGC_FONTCHANGED		0x01
#define BGC_NOWINSTYLE		0x02
#define BGC_SENDKEY			0x04
#define BGC_DEMONACTIVE		0x08
#define BGC_TOPONLY			0x10

/* drapeaux pour  mot 7 de BUBBLEGEM_SHOW */
#define BGS7_USRHIDE		0x0001
#define BGS7_MOUSE 			0x0004


#define BHLP_COOKIE	0x42484C50UL	/* 'BHLP' */
#define BGEM_COOKIE 0x4247454DUL	/* 'BGEM' */

typedef struct {
	long   magic;   /* nombre magique valant 'BGEM' */
	long   size;    /* taille de la structure R07: 18 */
	int    release; /* numÇro de version R07: 7, pas de valeur antÇrieur Ö 5 */
	int    active;  /* <>0, if straight line a help displayed becomes;
                       	 0  else */
	MFORM *mhelp;   /* forme de la souris de Bubble */
	int    dtimer;  /* depuis R06, DÑmon-Timer; Default 200ms; */
} BGEM;

/* Functions
 */
int get_cookie ( long cookie, long *p_value);
int new_cookie ( long id, long value);
int set_cookie ( long cookie, long value);

/* EOF */
