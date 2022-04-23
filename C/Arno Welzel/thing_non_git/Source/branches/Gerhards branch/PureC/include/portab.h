/*****************************************************************************/
/*                                                                           */
/* PORTAB.H                                                                  */
/*                                                                           */
/* Use of this file may make your code compatible with all C compilers       */
/* listed.                                                                   */
/*                                                                           */
/*****************************************************************************/

/*****************************************************************************/
/* ENVIRONMENT                                                               */
/*****************************************************************************/

#ifndef __PORTAB__
#define __PORTAB__

#define GEMDOS     1                          /* Digital Research GEMDOS     */
#define MSDOS      0                          /* Microsoft MSDOS             */
#define OS2        0                          /* Microsoft OS/2              */
#define FLEXOS     0                          /* Digital Research FlexOS     */
#define UNIX       0                          /* Unix Operating System       */

#define M68000     1                          /* Motorola Processing Unit    */
#define I8086      0                          /* Intel Processing Unit       */

#define DR_C       0                          /* Digital Research C Compiler */
#define LASER_C    0                          /* Laser C Compiler            */
#define LATTICE_C  0                          /* Lattice C Compiler          */
#define MW_C       0                          /* Mark Williams C Compiler    */
#define TURBO_C    1                          /* Turbo C Compiler            */
#define MS_C       0                          /* Microsoft C Compiler        */
#define HIGH_C     0                          /* Metaware High C Compiler    */
#define PCC        0                          /* Portable C-Compiler         */
#define XL_C       0                          /* AIX C-Compiler/6000         */

#define GEM1       0x0001                     /* ATARI GEM version           */
#define GEM2       0x0002                     /* MSDOS GEM 2.x versions      */
#define GEM3       0x0004                     /* MSDOS GEM/3 version         */
#define XGEM       0x0100                     /* OS/2,FlexOS X/GEM version   */

#ifndef GEM
#if GEMDOS
#define GEM        GEM1                       /* GEMDOS default is GEM1      */
#endif /* GEMDOS */

#if MSDOS
#define GEM        GEM3                       /* MSDOS default is GEM3       */
#endif /* MSDOS */

#if OS2
#define GEM        XGEM                       /* OS/2 default is X/GEM       */
#endif /* MSDOS */

#if FLEXOS | UNIX
#define GEM        XGEM                       /* FlexOS default is X/GEM     */
#endif /* FLEXOS */
#endif /* GEM */

#undef GEM
/*****************************************************************************/
/* STANDARD TYPE DEFINITIONS                                                 */
/*****************************************************************************/

#define BYTE    char                          /* Signed byte                 */
#define CHAR    char                          /* Signed byte                 */
#define UBYTE   unsigned char                 /* Unsigned byte               */
#define UCHAR   unsigned char                 /* Unsigned byte               */

#if LATTICE_C | PCC | XL_C
#define WORD    short                         /* Signed word (16 bits)       */
#define SHORT   short                         /* Signed word (16 bits)       */
#define UWORD   unsigned short                /* Unsigned word               */
#define USHORT  unsigned short                /* Signed word (16 bits)       */
#else
#define WORD    short                         /* Signed word (16 bits)       */
#define SHORT   short                         /* Signed word (16 bits)       */
#define UWORD   unsigned short                /* Unsigned word               */
#define USHORT  unsigned short                /* Signed word (16 bits)       */
#endif

#define LONG    long                          /* Signed long (32 bits)       */
#define ULONG   unsigned long                 /* Unsigned long               */

#define BOOLEAN WORD                          /* 2 valued (true/false)       */
#define BOOL    BOOLEAN                       /* 2 valued (true/false)       */

#define FLOAT   float                         /* Single precision float      */
#define DOUBLE  double                        /* Double precision float      */

#define INT     short                         /* A machine dependent int     */
#define UINT    unsigned short                /* A machine dependent uint    */

#define REG     register                      /* Register variable           */
#define AUTO    auto                          /* Local to function           */
#define EXTERN  extern                        /* External variable           */
#define LOCAL   static                        /* Local to module             */
#define MLOCAL  LOCAL                         /* Local to module             */
#define GLOBAL                                /* Global variable             */

/*****************************************************************************/
/* COMPILER DEPENDENT DEFINITIONS                                            */
/*****************************************************************************/

#if GEMDOS                                    /* GEMDOS compilers            */
#if DR_C
#define void WORD                             /* DR_C doesn't know void      */
#endif /* DR_C */

#if LASER_C | LATICE_C
#define vqt_font_info vqt_fontinfo            /* Wrong GEM binding           */
#define graf_mbox graf_movebox                /* Wrong GEM binding           */
#define graf_rubbox graf_rubberbox            /* Wrong GEM binding           */
#endif /* LASER_C */

#if MW_C
#define VOID WORD                             /* MW_C doesn't know (void *)  */
#endif /* MW_C */

#if LATTICE_C
#define ADR(A) (LONG)A >> 16, (LONG)A & 0xFFFF
#else
#define ADR(A) (WORD)((LONG)A >> 16), (WORD)((LONG)A & 0xFFFF)
#endif /* LATTICE_C */
#endif /* GEMDOS */

#if MSDOS | OS2                               /* MSDOS or OS2 compilers      */
#define ADR(A) (WORD)((LONG)A & 0xFFFF), (WORD)((LONG)A >> 16)
#endif /* MSDOS */

#if FLEXOS                                    /* FlexOS compilers            */
#define ADR(A) (WORD)((LONG)A & 0xFFFF), (WORD)((LONG)A >> 16)
#endif /* FLEXOS */

#if MS_C | TURBO_C | HIGH_C                   /* ANSI compilers              */
#define ANSI 1
#define _(params) params                      /* Parameter checking          */
#else
#define ANSI 0
#define _(params) ()                          /* No parameter checking       */
#define const
#define volatile
#if DR_C | LASER_C | LATTICE_C | MW_C
#define size_t UINT
#endif
#endif

#if DR_C | LASER_C | LATTICE_C | MW_C | HIGH_C | PCC | XL_C
#define cdecl
#define pascal
#endif

#define CONST    const
#define VOLATILE volatile
#define CDECL    cdecl
#define PASCAL   pascal

#define SIZE_T   size_t

#ifndef VOID
#define VOID     void
#endif

/*****************************************************************************/
/* OPERATING SYSTEM DEPENDENT DEFINITIONS                                    */
/*****************************************************************************/

#if GEMDOS | UNIX
#define NEAR                                  /* Near pointer                */
#define FAR                                   /* Far pointer                 */
#define HUGE                                  /* Huge pointer                */
#else
#if HIGH_C
#define NEAR   _near                          /* Near pointer                */
#define FAR    _far                           /* Far pointer                 */
#define HUGE   _huge                          /* Huge pointer                */
#else
#define NEAR    near                          /* Near pointer                */
#define FAR     far                           /* Far pointer                 */
#define HUGE    huge                          /* Huge pointer                */
#endif /* HIGH_C */
#endif /* GEMDOS */

#if MSDOS | OS2 | FLEXOS                      /* MSDOS or OS2 compilers      */
#define FPOFF(a)  (UWORD)(a)
#define FPSEG(a)  ((UWORD)((ULONG)(a) >> 16))
#define MKFP(a,b) ((VOID FAR *)(((ULONG)(a) << 16) | (UWORD)(b)))
#endif /* MSDOS | OS2 | FLEXOS */

#if FLEXOS                                    /* FlexOS compilers            */
#define main GEMAIN                           /* Because of X/GEM SRTL       */
#endif /* FLEXOS */

#if GEM & GEM1
#define appl_bvset(bvdisk, bvhard)
#define appl_yield() evnt_timer (0, 0)
#define xgrf_stepcalc(orgw, orgh, xc, yc, w, h, pcx, pcy, pcnt, pxstep, pystep)
#define xgrf_2box(xc, yc, w, h, corners, cnt, xstep, ystep, doubled)
#endif /* GEM1 */


#if GEM & (GEM1 | GEM2)
#define menu_click(click, setit)
#define v_copies(handle, count)
#define v_etext(handle, x, y, string, offsets)
#define v_orient(handle, orientation)
#define v_tray(handle, tray)
#define v_xbit_image(handle, filename, aspect, x_scale, y_scale, h_align, v_align, rotate, background, foreground, xy)\
        v_bit_image (handle, filename, aspect, x_scale, y_scale, h_align, v_align, xy)
#define vst_ex_load_fonts(handle, select, font_max, font_free)\
        vst_load_fonts   (handle, select)
#endif /* GEM1 | GEM2 */

#if GEM & (GEM2 | GEM3 | XGEM)
#define fsel_exinput(pipath, pisel, pbutton, plabel)\
        fsel_input  (pipath, pisel, pbutton)
#define wind_new()
#endif /* GEM2 | GEM3 | XGEM */

/*****************************************************************************/
/* MISCELLANEOUS DEFINITIONS                                                 */
/*****************************************************************************/

#ifndef FALSE
#define FALSE   (BOOLEAN)0                    /* Function FALSE value        */
#define TRUE    (BOOLEAN)1                    /* Function TRUE  value        */
#endif

#define FAILURE (-1)                          /* Function failure return val */
#define SUCCESS 0                             /* Function success return val */
#define FOREVER for (;;)                      /* Infinite loop declaration   */
#define EOS     '\0'                          /* End of string value         */

#ifndef NULL
#define NULL    0L                            /* Null long value             */
#endif

#ifndef EOF
#define EOF     (-1)                          /* EOF value                   */
#endif

#endif /* __PORTAB__ */

