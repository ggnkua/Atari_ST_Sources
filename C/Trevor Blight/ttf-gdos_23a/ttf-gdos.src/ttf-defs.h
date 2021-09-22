/***** (C) 1998-2021 Trevor Blight ****************
*
*  $Id: ttf-defs.h 3277 2021-08-29 16:45:08Z trevor $
*
* ttf-defs.h:  general definitions for ttf-gdos
*
*
* ttf-gdos is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License
* as published by the Free Software Foundation; either version 2
* of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*
*
*
***************************************************/

#define HIGH(x) (sizeof(x)/sizeof(x[0]) - 1)
#if defined abs
#undef abs
#endif
#define abs(x)  ({ typeof(x) _x = x; _x>=0? _x: -_x; })
typedef enum{ FALSE = (0!=0), TRUE = (0==0) } BOOL;

#ifdef MSDOS
#define __asm__
#define __inline__
#endif

#define TRAP    __asm__ volatile( "illegal" )
#define BEEP   Cconout( '\a' )

/*lint -eau */
#ifdef NDEBUG
#define DEBUGMSG(s)
#define malloc(a) (void*)Malloc( (unsigned long)(a) )
#define free(p) (void)Mfree( (void*)(p) )
#define	assert(cond)
#define IPTR
#else

static inline void DEBUGMSG(const char *s)
{
     Cconws(s); (void)Cconin();
}

extern void dfree(const void *p, char *fn, int line);
#define free(p) dfree((p), __FILE__, __LINE__)
extern void *dmalloc(uint32 a);
#define malloc(a) dmalloc( (unsigned long)(a) )

int	sprintf(char *, const char *, ...);
#ifndef assert
char assert_buf[128];
# define assert(cond)  \
  if(!(cond)) { \
   (void)sprintf( assert_buf, "assertion `%s' failed at line %ld of `" __FILE__ "'.\n\r", #cond, (long)(__LINE__)); \
   Cconws(assert_buf); \
   (void)Cnecin(); \
  } /* if */
#endif
#define IPTR = (void*)0xB1B1B1B1
#endif /* NDEBUG */

#if D_SHOW
#include <ctype.h>
#include <stdio.h>
#define dprintf(s) printf s
#else
#define dprintf(s)
#endif

#define OP_OPNWK  1        /* vdi opcodes */
#define OP_OPNVWK 100
#define OP_CLSWK  2
#define OP_CLSVWK 101
#define OP_GTEXT  8
#define OP_SETFNT 21
#define OP_LDFNT  119
#define OP_ULDFNT 120
#define OP_FILL   9
#define OP_ESCAPE 5
#define OP_GDP    11
#define OP_DEVINFO 248

#define MemAvail() Malloc(-1)

extern   BYTE etext[];
extern   BYTE edata[];
extern   void *end[];

#define TTFont_Tablep  (*(FONT_RECORD **)end)
#define GemFont_Tablep (*(FILE_NAME **)(end+1))
#define gem_path (*(char **)(end+2))
#define setup_inf (*(TTF_GDOS_INF_RECORD *)(end+3))	/* must match hook code */

#define error_code setup_inf.file_len

#ifdef NULL
#undef NULL
#endif
#define NULL  ((void *)0L)

typedef int16 FILE_H;        /* gemdos file handle */

typedef enum{ OK=0, FILE_ERR, MEM_ERR, READ_ERR } tTTF_ERROR;

/** ttf-gdos.c **/
typedef char tGemFName[32];


#define GEM_FIRST_CH ' '
#define GEM_LAST_CH  255

typedef struct _font {

/* Type    Name       Offset   Function		    Comments		     */
/* ------------------------------------------------------------------------- */
   int16  font_id;    /*  0 Font face identifier  1 == system font	     */
   int16  size;       /*  2 Font size in points				     */
   char   name[32];   /*  4 Face name					     */
   uint16  first_ade; /* 36 Lowest ADE value in the face (lowest ASCII value of displayable character).		             */
   uint16  last_ade;  /* 38 Highest ADE value in the face (highest ASCII value of displayable character).		             */
   int16  top;	      /* 40 Distance of top line relative to baseline	     */
   int16  ascent;     /* 42 Distance of ascent line relative to baseline     */
   int16  half;       /* 44 Distance of half line relative to baseline       */
   int16  descent;    /* 46 Distance of decent line relative to baseline     */
   int16  bottom;     /* 48 Distance of bottom line relative to baseline     */
		                /*    All distances are measured in absolute values    */
		                /*    rather than as offsets. They are always +ve      */
   int16 max_char_width; /* 50 Width of the widest character in font	     */
   int16 max_cell_width; /* 52 Width of the widest cell character cell in face  */
   int16 left_offset;  /* 54 Left Offset see Vdi appendix G		     */
   int16 right_offset; /* 56 Right offset   "      "     "		     */
   int16  thicken;    /* 58 Number of pixels by which to thicken characters  */
   int16  ul_size;    /* 60 Width in  pixels of the underline		     */
   int16  lighten;    /* 62 The mask used to lighten characters		     */
   int16  skew;       /* 64 The mask used to determine when to perform       */
                      /*    additional rotation on the character to perform skewing  */
   int16  flags;      /* 66 Flags					     */
                                /*      bit 0 set if default system font     */
		                /*      bit 1 set if horiz offset table should be used */
		                /*      bit 2 byte-swap flag (thanks to Intel idiots)  */
		                /*      bit 3 set if mono spaced font		     */
   int8   *h_table;   /* 68 Pointer to horizontal offset table		     */
   uint16 *off_table; /* 72 Pointer to character offset table		     */
   uint8   *form_data;/* 76 Pointer to font data			     */
   uint16 form_width; /* 80 Form width (#of bytes /scanline in font data)    */
   uint16 form_height;/* 82 Form height (#of scanlines in font data)	     */
   struct _font *next_font;  /* 84 Pointer to next font in this face		     */
} tGEM_FONT_HDR;

struct contrl_io {
   int16 opcode;
   int16 nptsin;
   int16 nptsout;
   int16 nintin;
   int16 nintout;
   const int16 subfunc;
   int16 handle;
};

typedef struct {
   void          *scratch_adr;
   uint16         scratch_size;
   tGEM_FONT_HDR   *font_chain;
} FONT_CONTRL_RECORD;

typedef struct {
   struct contrl_io *contrl_adr;
   const int16 *const intin_adr;
   int16 *ptsin_adr;
   int16 *intout_adr;
   int16 *ptsout_adr;
} Vdi_Params;


/*** data record for each active workstation
** each slot in the active wkstn table can be in one of 6 states:
**   empty, open with dynamic driver, loaded/opened with a resident or
** permanent driver
** pdev == NULL for empty
** and root_handle != 0 for opened workstation
***/
typedef struct {
   const DEVICE_RECORD *pdev;	/* pointer to device data, it mustn't change */
   int16          rc_flag;	/* raster/normalised coords?? */
   int16          root_handle;	/* for vwkstns, handle of root wkstn; 0 when closed */
   int16          drv_handle;	/* device driver's handle */
   uint16         dev_width;
   uint16         dev_height;
   uint16         dpix;
   uint16         dpiy;
   int16          font_id; /* id of currently selected font for this workstation */
   int16          bez_qual; /* current quality of bezier curves for this workstation */
   int16        (*entry_point)(void);	/* device driver entry point */
   struct basep  *base_pagep;
   FONT_CONTRL_RECORD wks_fonts;
} ACTIVE_WKS_REC;


#define MAX_WKS 24
extern ACTIVE_WKS_REC active_wk_tbl[MAX_WKS];

extern int16 xintin[256];
extern int16 xptsin[10];
extern int16 xintout[44];
extern int16 xptsout[12];
extern struct contrl_io xcontrl;

static __inline__ void *hi_malloc( const int32 m )
{
   return malloc(m);
}

int32 get_sysfile_siz( const FILE_NAME );
FILE_H open_sys_file( const FILE_NAME );
ACTIVE_WKS_REC *find_wkstnp( const int16 );
void call_driver( const Vdi_Params * const vdi_param_adr,
             register const ACTIVE_WKS_REC *const pw );

__inline__ static void xcall_driver( const Vdi_Params *vdi_param_adr, const ACTIVE_WKS_REC *const pw )
{
#ifndef MSDOS
   register Vdi_Params *vdi_in __asm__("d1");;
   vdi_param_adr->contrl_adr->handle = pw->drv_handle;
    __asm__ volatile ("movl %1,%0": "=d"(vdi_in): "g"(vdi_param_adr) );
#endif
   (void)(*pw->entry_point)();	    /* call_driver() */
} /* xcall_driver */

#if defined GDOS
/** font.c **/
void vst_load_fonts(const Vdi_Params *vdi_param_adr);
void vst_unload_fonts(register const Vdi_Params *vdi_param_adr);
void free_wks_fonts( ACTIVE_WKS_REC *const pw );
void vst_font( const Vdi_Params *vdi_param_adr );
void v_gtext( const Vdi_Params *vdi_param_adr );
#endif

/** ttf.c **/
void ttf_startup( const int16 nr_ttf_fonts );
int set_tables( const int16 ttf_nr, const FILE_H fh );
int get_ttf_data( const int ttf_nr, char *const font_name, const FILE_H fh );
int get_glyf_data( const int ttf_nr, const FILE_H fh );
void release_glyf_data( void );

/** glyph.c **/
void gen_font_header( const int16 ttf_nr,
         tGEM_FONT_HDR *const fntp,
         const uint16 dpix, const uint16 dpiy );
void gen_font_data( FILE_H fh, const int16 ttf_nr, tGEM_FONT_HDR *const fntp,
         const ACTIVE_WKS_REC *const pw, int16 nr_chars, const uint16 *gem_chars );


/** cache.c **/
uint32 install_cache( uint32 size );
void remove_cache( void );
void find_mem( uint32 rq_size, void **const base );
void use_mem( void *const p );
void release_mem( void *const p );


/*********************** end of ttf-defs.h ******************/

