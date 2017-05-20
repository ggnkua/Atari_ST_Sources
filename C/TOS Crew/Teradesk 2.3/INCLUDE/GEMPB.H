#ifndef GEMPB_H
#define GEMPB_H

/* (c) 1990 1999 Henk Robbers Amsterdam
	1990: used in a item_selector of my own (called within trap)
	1999: adapted to modern OS's like MagiC and MiNT,
			added flexibility and compiletime compatability with original binding.
	2002: adapted to modern AES like XaAES.
*/

#ifndef __2B_UNIVERSAL_TYPES__
/* For the AES: this is enough for complete portability */
typedef char			G_b;
typedef unsigned char	G_ub;
typedef int				G_i;	/* int types that are passed to the OS and need explicitely be 16 bits */
typedef unsigned short	G_u;
typedef long			G_l,
						fixed;
typedef unsigned long	G_ul;
#else					/* but if YOU use portab then I'll use it too :-) */
typedef int8			G_b;
typedef uint8			G_ub;
typedef int16			G_i;
typedef uint16			G_u;
typedef int32			G_l;
typedef uint32			G_ul;
#endif

typedef int				G_w;	/* int types in user interface */

#if 0
/* define these in your compilers -D options or in the project file */
#define G_MT	0	/* declare as 1 if you generate for Multi Threading version */ 
#define G_EXT	0	/* declare as 1 if you want extended bindings. */
#define G_MOD	0	/* declare as 1 if you want modified bindings for:
					   evnt_button, evnt_mouse, objc_draw, form_center,
					   form_do, form_dial wind_get.... */
#define G_STACK	0	/* declare as 1 if you want to compile for systems with
					   parameters all on the stack (faster bindings possible) */
#define PC_GLOB	0	/* declare as 1 if your program uses the global in GEMPARBLK of Pure C */
#endif

#if G_STACK && (sizeof(G_w) == sizeof(G_i))
	#define ON_STACK 1
	#if __TURBOC__ || __AHCC__ || __AC__
		#define G_decl cdecl	/* for bindings */
		#define __Cdecl cdecl	/* ALWAYS cdecl	*/
		#define CDECL 1
		#define __WGS_ELLIPSISD__ 1 	/* define this as 1 if you use the 'ellipsis'd version of wind_get & wind_set */
	#else
		#define G_decl	/* or whatever is needed */
		#define __Cdecl
	#endif
#else
	#if __TURBOC__ || __AHCC__ || __AC__
		#define G_decl			/* for bindings */
		#define __Cdecl cdecl	/* ALWAYS cdecl */
		#define CDECL 1
		#define __WGS_ELLIPSISD__ 1 	/* define this as 1 if you use the 'ellipsis'd version of wind_get & wind_set */
	#else
		#define G_decl	/* or whatever is needed */
		#define __Cdecl
	#endif
#endif

/* Pure C doesnt accept short for bit fields */
typedef int bits;				/* use these for bitfields */
typedef unsigned int ubits;

typedef union
{
	void *spec;			/* PC_GEM */
	long l;
	G_i pi[2];
} private;

/* At last give in to the fact that it is a struct, NOT an array */
typedef struct aes_global
{
	G_i version,
		count,
		id;
	private *pprivate;		/* 3,4 */
	void *ptree;			/* 5,6 */
	void *rshdr;			/* 7,8 */
	short lmem,				/* 9 */
		nplanes,			/* 10 */
		res1,client_end,	/* 11, 12 */
		c_max_h, bvhard;	/* 13, 14 */
} GLOBAL;

#if PCAES
	extern GLOBAL aes_global;
#else
	#define aes_global (_GemParBlk.glob)
#endif

#if G_MT									/* pass global at the user level */
	#define dglob ,GLOBAL *glob
	#define pglob glob
	#define G_n(x) MT_ ## x
	#define G_nv(x) MT_ ## x (GLOBAL *glob)	/* for void x(void) */
	#if PC_GLOB
		#define G_trap PC_trap_aes				/* if &global = nil, use _GemParBlk */
	#else
		#define G_trap _trap_aes						/* no reference to _GemParBlk */
	#endif
#else										/* use implicit global */
	#if PC_GLOB								/* use PC's _GemParBlk */
		#define dglob
		#define pglob 0L
		#define G_trap PC_trap_aes
	#else									/* use simple defaults */
		#define dglob
		#define pglob &aes_global
		#define G_trap _trap_aes
	#endif
	#define G_n(x) x
	#define G_nv(x) x(void)
#endif

#define G_c(f,ii,io,ai,ao) static G_i c[]={f,ii,io,ai,ao}

G_w __Cdecl G_trap
			(G_i   *contrl,			/*  4(sp) */
			 GLOBAL *glob,			/*  8(sp) */
             G_i   *intin,			/* 12(sp) */
             G_i   *intout,			/* 16(sp) */
             void  *addrin,			/* 20(sp) */
             void  *addrout);		/* 24(sp) */ 

void __Cdecl _trap_vdi
			(G_i    handle,			/* 	4(sp) */
             G_i    fu,				/* 	6(sp) */
             G_i    ii,				/* 	8(sp) */
             G_i    pi,				/* 10(sp) */
             G_i   *contrl,			/* 12(sp) */
             G_i   *intin,			/* 16(sp) */
             G_i   *ptsin,			/* 20(sp) */
             G_i   *intout,			/* 24(sp) */
             G_i   *ptsout);		/* 28(sp) */

typedef struct
{
	G_i	x, y, bstate, kstate;
} EVNTDATA;

typedef struct grect
{
#if G_PRFXS
	G_i		g_x,g_y,g_w,g_h;
#else
	G_i		x,y,w,h;
#endif
} GRECT;		/* GEM rectangle */

#if G_PRFXS
typedef struct
{
	G_i m_out,
		m_x,m_y,
		m_w,m_h;
} MOBLK;
#else
typedef struct
{
	G_i out,
		x,y,
		w,h;
} MOBLK;
#endif

/* Event library definitions */
typedef enum
{
	MU_KEYBD			= 0x0001,
	MU_BUTTON			= 0x0002,
	MU_M1	 			= 0x0004,
	MU_M2	 			= 0x0008,
	MU_MESAG			= 0x0010,
	MU_TIMER			= 0x0020,
	MU_WHEEL			= 0x0040,	/*     AES wheel support                            */
	MU_MX				= 0x0080,	/* HR: XaAES extension: report any mouse movement   */
									/*                      used for recursive menu's   */
	MU_NORM_KEYBD		= 0x0100,	/* 					    return normalized key code. */
	MU_DYNAMIC_KEYBD	= 0x0200	/*                      keybd as a bunch of buttons, includes release of key */
} EVENT_TY;

typedef struct    /* Event structure for EVNT_multi(), window dialogs, etc. */
{
	G_i
		mwhich,
		mx,
		my,
		mbutton,
		kstate,
		key,
		mclicks,
		reserved[9],
		msg[16];
} EVNT;

typedef struct
{
	G_i    contrl[15];
	GLOBAL glob;
	G_i    intin[132];
	G_i    intout[140];
	void   *addrin[16];
	void   *addrout[16];
} GEMPARBLK;				/* For Pure C */

extern  GEMPARBLK _GemParBlk;
extern  int       _app;

int  vq_aes( void );
/* AESPB is now completely out of sight */
#endif