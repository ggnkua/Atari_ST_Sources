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

#if !defined( __PORTAB__ )
#define __PORTAB__

#define GEMDOS     1                          /* Digital Research GEMDOS     */
#define MSDOS      0                          /* Microsoft MSDOS             */
#define OS2        0                          /* Microsoft OS/2              */
#define FLEXOS     0                          /* Digital Research FlexOS     */

#define MiNT       1                          /* Atari MultiTOS */

#define M68000     1                          /* Motorola Processing Unit    */
#define I8086      0                          /* Intel Processing Unit       */

#define DR_C       0                          /* Digital Research C Compiler */
#define LASER_C    0                          /* Laser C Compiler            */
#define LATTICE_C  0                          /* Lattice C Compiler          */
#define MW_C       0                          /* Mark Williams C Compiler    */
#define TURBO_C    1                          /* Turbo C Compiler            */
#define MS_C       0                          /* Microsoft C Compiler        */
#define HIGH_C     0                          /* Metaware High C Compiler    */

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

#if FLEXOS
#define GEM        XGEM                       /* FlexOS default is X/GEM     */
#endif /* FLEXOS */
#endif /* GEM */

/*****************************************************************************/
/* STANDARD TYPE DEFINITIONS                                                 */
/*****************************************************************************/

#define BYTE    char                          /* Signed byte                 */
#define UBYTE   unsigned char                 /* Unsigned byte               */

#if LATTICE_C
#define WORD    short                         /* Signed word (16 bits)       */
#define UWORD   unsigned short                /* unsigned word               */
#else
#define WORD    int                           /* Signed word (16 bits)       */
#define UWORD   unsigned int                  /* unsigned word               */
#endif

#define LONG    long                          /* signed long (32 bits)       */
#define ULONG   unsigned long                 /* Unsigned long               */

#define BOOLEAN WORD                          /* 2 valued (true/false)       */

#define FLOAT   float                         /* single precision float      */
#define DOUBLE  double                        /* double precision float      */

#define INT     int                           /* a machine dependent int     */
#define UINT    unsigned int                  /* a machine dependent uint    */

#define REG     register                      /* register variable           */
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

#if LASER_C
#define graf_mbox graf_movebox                /* Wrong GEM binding           */
#define graf_rubbox graf_rubberbox            /* Wrong GEM binding           */
#endif /* LASER_C */

#if LATTICE_C
#define graf_mbox graf_movebox                /* Wrong GEM binding           */
#define graf_rubbox graf_rubberbox            /* Wrong GEM binding           */
#endif /* LATTICE_C */

#if TURBO_C
#define graf_mbox graf_movebox                /* Wrong GEM binding           */
#define graf_rubbox graf_rubberbox            /* Wrong GEM binding           */
#endif /* TURBO_C */

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
#define _(params) params                      /* parameter checking          */
#else
#define ANSI 0
#define _(params) ()                          /* no parameter checking       */
#define const
#define volatile
#define size_t UINT
#endif

#if DR_C | LASER_C | LATTICE_C | MW_C | HIGH_C
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

#if GEMDOS
#define FAR                                   /* Far Pointer                 */
#define NEAR                                  /* Near Pointer                */
#else
#define FAR     far                           /* Far Pointer                 */
#define NEAR    near                          /* Near Pointer                */
#endif /* GEMDOS */

#if GEM & GEM1
#define appl_bvset(bvdisk, bvhard)
/*
#define appl_yield() evnt_timer (0, 0)
*/
#define menu_unregister(mid)
/*
#define scrp_clear()
*/
#define xgrf_stepcalc(orgw, orgh, xc, yc, w, h, pcx, pcy, pcnt, pxstep, pystep)
#define xgrf_2box(xc, yc, w, h, corners, cnt, xstep, ystep, doubled)
#endif /* GEM1 */

#if GEM & (GEM1 | XGEM)
#define shel_rdef(lpcmd, lpdir)
#define shel_wdef(lpcmd, lpdir)
#endif /* GEM1 | XGEM */

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

#define FALSE   (BOOLEAN)0                    /* Function FALSE value        */
#define TRUE    (BOOLEAN)1                    /* Function TRUE  value        */
#define FAILURE (-1)                          /* Function failure return val */
#define SUCCESS 0                             /* Function success return val */
#define FOREVER for (;;)                      /* Infinite loop declaration   */
#define EOS     '\0'                          /* End of string value         */
/*
#ifndef NULL
#define NULL    0L                            /* Null long value             */
#endif
*/
#ifndef EOF
#define EOF     (-1)                          /* EOF value                   */
#endif
#define min(a,b) ((a)<(b)?(a):(b))
#define max(a,b) ((a)>(b)?(a):(b))
#endif /* __PORTAB__ */

