/*****************************************************************************
 *
 * Module : GLOBAL.C
 * Author : Dieter Geiû
 *
 * Creation date    : 05.03.90
 * Last modification:
 *
 *
 * Description: This module implements global definitions.
 *
 * History:
 * 22.12.07: Defaultwert (2) fÅr TabSize
 * 05.08.05: vqt_ext_name added
 * 22.06.03: Die Clipboard Funktionen nach clipbrd.c verschoben
 * 25.12.02: Suchen nach OLGA nicht mehr in init_global.
 *					 Globale Ermittlung von bShowDebugInfo.
 * 07.11.02: Globaler Speicher wird mit der neuen Lib-Funktion geholt
 * 08.08.02: Es wird ein globaler Speicherbereich reserviert.
 *           Bei den OLGA Funktionen wird der globale Speicher benutzt.
 * 04.04.98: work_in [14] and work_in [15] set to zero in open_work_ex
 * 26.02.97: Olga functions added
 * 23.02.97: Variables olga_apid and st_guide_apid initialized
 * 28.12.96: Function open_work_ex added
 * 18.06.96: Command line parameters packed in ' chars
 * 16.06.96: Call to str_upper removed
 * 15.06.96: Initialization of variable use_lfn added (ues drive C as reference)
 * 23.09.95: Function vst_arbpoint added
 * 16.09.95: Function text_extent added
 * 29.07.95: Function rc_inflate added
 * 14.07.95: Initialization of variable screen_info in open_vwork added
 * 16.11.94: Function trans_gimage works with G_CICON as well
 * 12.10.94: Variable btn_round_borders and btn_shadow_width initialized with FALSE and 1
 * 26.05.94: Using btn_shadow_width for dialog boxes
 * 24.05.94: Initialization of btn_round_borders and btn_shadow_width added
 * 02.05.94: ClipboardEmpty sets clip_size to 0
 * 26.04.94: Clipboard functions added
 * 25.04.94: Variable use_adapt initialized
 * 23.04.94: GetProfileString bug with empty strings fixed
 * 04.04.94: Inf file functions added
 * 29.03.94: Parameter char_width in v_text no longer needed
 * 12.02.94: Initialization of use_std_fs added
 * 17.12.93: Function scan_to_ascii added
 * 15.10.93: Initialization of planes added
 * 05.10.93: Initialization of dlg_checkbox, dlg_radiobutton, and dlg_arrow added
 * 03.10.93: Initialization of dialog color variables uses sys_colors
 * 30.09.93: Initialization of variables color_desktop and pattern_desktop added
 * 10.09.93: Function scroll_area moved from WINDOWS.C
 * 09.09.93: Initialization of colorpalette (254 = WHITE, 255 = BLACK) for 256 color resolution
 * 05.09.93: Initialization of color_highlight and color_highlighttext added
 * 04.09.93: Function get_parent added
 * 23.08.93: Function set_ob_spec added
 * 22.03.93: Initialization of dialog color variables added
 * 21.03.93: Function get_ob_type returns pure type (if not G_USERDEF)
 * 05.03.90: Creation of body
 *****************************************************************************/

#include <ctype.h>
#include <atarierr.h>

#include "import.h"

#include <olga.h>
#include <ph_lib.h>

#include "files.h"
#include "utility.h"

#include "export.h"
#include "global.h"

/****** DEFINES **************************************************************/

#ifndef GRAY
#define GRAY             DWHITE
#endif

#ifndef DGRAY
#define DGRAY            DBLACK
#endif

#define MAX_COLORS   16                 /* GEM Standard-Farben */
#define DEFAULTRATE  3                  /* Default Blinkrate */

#define FONT_CHICAGO 250                /* Font Nummer des Chicago fonts */

#define CTRL_CHAR    '^'                /* MenÅ-Control-Buchstabe */
#define ALT_CHAR     0x07               /* MenÅ-Alternate-Buchstabe */
#define SHIFT_CHAR   0x01               /* MenÅ-Shifttaste */
#define FUNC_CHAR    'F'                /* MenÅ-Funktionstaste */

#define FMD_FORWARD  0
#define FMD_BACKWARD 1
#define FMD_DEFLT    2

#define CHAR_COMMENT ';'

/****** TYPES ****************************************************************/

typedef struct
{
  UWORD red;
  UWORD green;
  UWORD blue;
} RGB_LIST;

#if MSDOS | FLEXOS | DR_C | LASER_C | LATTICE_C | MW_C
typedef struct
{
  BYTE  d_reserved [21];
  UBYTE d_attrib;
  UWORD d_time;
  UWORD d_date;
  ULONG d_length;
  BYTE  d_fname [14];
} DTA;
#endif

/****** VARIABLES ************************************************************/

#if GEMDOS
#if DR_C | LASER_C | TURBO_C | MW_C
EXTERN INT     _app;                     /* Applikation oder Accessory */
#endif
#endif

LOCAL WORD     last_mousenumber = 0;
LOCAL MFORM    *last_mouseform  = NULL;

/* [GS] 5.1c alt: nach clipbrd.c verschoben
LOCAL WORD     clip_mode = CM_RAM;
LOCAL LONG     clip_size [CF_FORMATS];
LOCAL VOID     *clip_data [CF_FORMATS];
LOCAL FULLNAME clip_filename;
*/

LOCAL RGB_LIST gem_colors [MAX_COLORS] =
{
  1000, 1000, 1000,  /* white        */
     0,    0,    0,  /* black        */
  1000,    0,    0,  /* red          */
     0, 1000,    0,  /* green        */
     0,    0, 1000,  /* blue         */
     0, 1000, 1000,  /* cyan         */
  1000, 1000,    0,  /* yellow       */
  1000,    0, 1000,  /* magenta      */
   666,  666,  666,  /* light grey   */
   333,  333,  333,  /* dark grey    */
   666,    0,    0,  /* dark red     */
     0,  666,    0,  /* dark green   */
     0,    0,  666,  /* dark blue    */
     0,  666,  666,  /* dark cyan    */
   666,  666,    0,  /* dark yellow  */
   666,    0,  666   /* dark magenta */
};

#if GEMDOS

LOCAL UWORD ctrl_keys [] =
{
  0x3900, 0x0201, 0x0302, 0x2903, 0x0504, 0x0605, 0x0706, 0x0d07, 0x0908, 0x0a09,
  0x1b0a, 0x1b0b, 0x330c, 0x351f, 0x340e, 0x080f, 0x0b10, 0x0211, 0x0300, 0x0413,
  0x0514, 0x0615, 0x071e, 0x0817, 0x0918, 0x0a19, 0x341a, 0x331b, 0x601c, 0x0b1d,
  0x601e, 0x0c1f, 0x1a01, 0x1e01, 0x3002, 0x2e03, 0x2004, 0x1205, 0x2106, 0x2207,
  0x2308, 0x1709, 0x240a, 0x250b, 0x260c, 0x320d, 0x310e, 0x180f, 0x1910, 0x1011,
  0x1312, 0x1f13, 0x1414, 0x1615, 0x2f16, 0x1117, 0x2d18, 0x2c19, 0x151a, 0x2714,
  0x1a1a, 0x2804, 0x291e, 0x351f, 0x0d00, 0x1e01, 0x3002, 0x2e03, 0x2004, 0x1205,
  0x2106, 0x2207, 0x2308, 0x1709, 0x240a, 0x250b, 0x260c, 0x320d, 0x310e, 0x180f,
  0x1910, 0x1011, 0x1312, 0x1f13, 0x1414, 0x1615, 0x2f16, 0x1117, 0x2d18, 0x2c19,
  0x151a, 0x2719, 0x2b1c, 0x280e, 0x2b1e
}; /* ctrl_keys */

LOCAL UWORD alt_keys [] =
{
  0x3920, 0x7800, 0x7900, 0x2923, 0x7b00, 0x7c00, 0x7d00, 0x8300, 0x7f00, 0x8000,
  0x1b2a, 0x1b2b, 0x332c, 0x352d, 0x342e, 0x7e00, 0x8100, 0x7800, 0x7900, 0x7a00,
  0x7b00, 0x7c00, 0x7d00, 0x7e00, 0x7f00, 0x8000, 0x343a, 0x333b, 0x603c, 0x8100,
  0x603e, 0x8200, 0x1a40, 0x1e00, 0x3000, 0x2e00, 0x2000, 0x1200, 0x2100, 0x2200,
  0x2300, 0x1700, 0x2400, 0x2500, 0x2600, 0x3200, 0x3100, 0x1800, 0x1900, 0x1000,
  0x1300, 0x1f00, 0x1400, 0x1600, 0x2f00, 0x1100, 0x2d00, 0x2c00, 0x1500, 0x275b,
  0x1a5c, 0x285d, 0x295e, 0x355f, 0x8300, 0x1e00, 0x3000, 0x2e00, 0x2000, 0x1200,
  0x2100, 0x2200, 0x2300, 0x1700, 0x2400, 0x2500, 0x2600, 0x3200, 0x3100, 0x1800,
  0x1900, 0x1000, 0x1300, 0x1f00, 0x1400, 0x1600, 0x2f00, 0x1100, 0x2d00, 0x2c00,
  0x1500, 0x277b, 0x2b7c, 0x287d, 0x2b7e
}; /* alt_keys */

LOCAL UWORD func_keys [] =
{
  0x3b00, 0x3c00, 0x3d00, 0x3e00, 0x3f00, 0x4000, 0x4100, 0x4200, 0x4300, 0x4400,
  0x5400, 0x5500, 0x5600, 0x5700, 0x5800, 0x5900, 0x5A00, 0x5B00, 0x5C00, 0x5D00,
  0x3b00, 0x3c00, 0x3d00, 0x3e00, 0x3f00, 0x4000, 0x4100, 0x4200, 0x4300, 0x4400,
  0x3b00, 0x3c00, 0x3d00, 0x3e00, 0x3f00, 0x4000, 0x4100, 0x4200, 0x4300, 0x4400
}; /* func_keys */

#endif

#if MSDOS | FLEXOS

LOCAL UWORD ctrl_keys [] =
{
  0x3920, 0x0000, 0x0300, 0x0000, 0x0000, 0x0000, 0x071e, 0x0000, 0x0000, 0x0000,
  0x1b1d, 0x1b1d, 0x0000, 0x351f, 0x0000, 0x0000, 0x0000, 0x0000, 0x0300, 0x0000,
  0x0000, 0x0000, 0x071e, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
  0x0000, 0x0c1c, 0x1011, 0x1e01, 0x3002, 0x2e03, 0x2004, 0x1205, 0x2106, 0x2207,
  0x2308, 0x1709, 0x240a, 0x250b, 0x260c, 0x320d, 0x310e, 0x180f, 0x1910, 0x1011,
  0x1312, 0x1f13, 0x1414, 0x1615, 0x2f16, 0x1117, 0x2d18, 0x2c19, 0x151a, 0x0000,
  0x0c1f, 0x0000, 0x0000, 0x351f, 0x0000, 0x1e01, 0x3002, 0x2e03, 0x2004, 0x1205,
  0x2106, 0x2207, 0x2308, 0x1709, 0x240a, 0x250b, 0x260c, 0x320d, 0x310e, 0x180f,
  0x1910, 0x1011, 0x1312, 0x1f13, 0x1414, 0x1615, 0x2f16, 0x1117, 0x2d18, 0x2c19,
  0x151a, 0x0000, 0x0000, 0x0000, 0x1b1d
}; /* ctrl_keys */

LOCAL UWORD alt_keys [] =
{
  0x3920, 0x7800, 0x7900, 0x0000, 0x7b00, 0x7c00, 0x7d00, 0x0000, 0x7f00, 0x8000,
  0x0000, 0x0000, 0x0000, 0x8200, 0x0000, 0x7e00, 0x8100, 0x7800, 0x7900, 0x7a00,
  0x7b00, 0x7c00, 0x7d00, 0x7e00, 0x7f00, 0x8000, 0x0000, 0x0000, 0x0000, 0x8100,
  0x0000, 0x0000, 0x1040, 0x1e00, 0x3000, 0x2e00, 0x2000, 0x1200, 0x2100, 0x2200,
  0x2300, 0x1700, 0x2400, 0x2500, 0x2600, 0x3200, 0x3100, 0x1800, 0x1900, 0x1000,
  0x1300, 0x1f00, 0x1400, 0x1600, 0x2f00, 0x1100, 0x2d00, 0x1500, 0x2c00, 0x095b,
  0x0c5c, 0x0a5d, 0x0000, 0x8200, 0x0000, 0x1e00, 0x3000, 0x2e00, 0x2000, 0x1200,
  0x2100, 0x2200, 0x2300, 0x1700, 0x2400, 0x2500, 0x2600, 0x3200, 0x3100, 0x1800,
  0x1900, 0x1000, 0x1300, 0x1f00, 0x1400, 0x1600, 0x2f00, 0x1100, 0x2d00, 0x1500,
  0x2c00, 0x087b, 0x567c, 0x0b7d, 0x1b7e
}; /* alt_keys */

LOCAL UWORD func_keys [] =
{
  0x3b00, 0x3c00, 0x3d00, 0x3e00, 0x3f00, 0x4000, 0x4100, 0x4200, 0x4300, 0x4400,
  0x5400, 0x5500, 0x5600, 0x5700, 0x5800, 0x5900, 0x5A00, 0x5B00, 0x5C00, 0x5D00,
  0x5e00, 0x5f00, 0x6000, 0x6100, 0x6200, 0x6300, 0x6400, 0x6500, 0x6600, 0x6700,
  0x6800, 0x6900, 0x6a00, 0x6b00, 0x6c00, 0x6d00, 0x6e00, 0x6f00, 0x7000, 0x7100
}; /* func_keys */

#endif

/****** FUNCTIONS ************************************************************/

LOCAL VOID vdi_fix   _((MFDB *pfd, VOID *theaddr, WORD wb, WORD h));
LOCAL VOID vdi_trans _((WORD *saddr, WORD swb, WORD *daddr, WORD dwb, WORD h));

LOCAL WORD find_obj  _((OBJECT *tree, WORD start_obj, WORD which));
LOCAL WORD fm_inifld _((OBJECT *tree, WORD start_fld));

#if GEM & (GEM2 | GEM3 | XGEM)
#define graf_growbox grafgrowbox        /* for compatibility with header file */

LOCAL VOID graf_growbox   _((WORD orgx, WORD orgy, WORD orgw, WORD orgh, WORD x, WORD y, WORD w, WORD h));
LOCAL VOID graf_shrinkbox _((WORD orgx, WORD orgy, WORD orgw, WORD orgh, WORD x, WORD y, WORD w, WORD h));
#endif

LOCAL VOID lv_opnwk        (WORD *work_in, WORD *handle, WORD *work_out);
LOCAL WORD lvq_ext_devinfo (WORD handle, WORD device, WORD *dev_exists, BYTE *file_path, BYTE *file_name, BYTE *name);

#if GEMDOS | MSDOS | OS2 /* FLEXOS kennt den direkten vdi-Aufruf nicht */
EXTERN VOID vdi           _((VOID));
#endif

/*****************************************************************************/
/* ôffne virtuelle Workstation                                               */
/*****************************************************************************/

GLOBAL VOID open_vwork ()

{
  WORD i;
  WORD work_in [11];
  WORD work_out [57];

  for (i = 0; i < 10; work_in [i++] = 1);
  work_in [10] = RC;                           /* Raster Koordinaten */
  vdi_handle = phys_handle;
  v_opnvwk (work_in, &vdi_handle, work_out);   /* ôffne virtuelle Workstation */
  colors = work_out [13];                      /* Anzahl der Farben */

  screen_info.dev_w           = work_out [0] + 1L;
  screen_info.dev_h           = work_out [1] + 1L;
  screen_info.pix_w           = work_out [3];
  screen_info.pix_h           = work_out [4];
  screen_info.lPixelsPerMeter = 1000000L / screen_info.pix_h;
  screen_info.lRealPageWidth  = screen_info.dev_w * screen_info.pix_w;
  screen_info.lRealPageHeight = screen_info.dev_h * screen_info.pix_h;
  screen_info.lPhysPageWidth  = screen_info.lRealPageWidth;
  screen_info.lPhysPageHeight = screen_info.lRealPageHeight;
  screen_info.lXOffset        = (screen_info.lPhysPageWidth - screen_info.lRealPageWidth) / 2;
  screen_info.lYOffset        = (screen_info.lPhysPageHeight - screen_info.lRealPageHeight) / 2;

  if (vdi_handle == 0) vdi_handle = phys_handle;

#if GEM & XGEM
  vst_point (vdi_handle, gl_point, &i, &i, &i, &i);
#endif

  vqt_attributes (vdi_handle, work_out);       /* Globale Zeichensatzgrîûen */

  gl_wchar = work_out [6];                     /* Werte von Zeichen holen */
  gl_hchar = work_out [7];
} /* open_vwork */

/*****************************************************************************/
/* Schlieûe virtuelle Workstation                                            */
/*****************************************************************************/

GLOBAL VOID close_vwork ()

{
  if (vdi_handle != phys_handle)                /* Virtuelle Workstation ist offen */
  {
    v_clsvwk (vdi_handle);                      /* Workstation freigeben */
    vdi_handle = phys_handle;                   /* Physikalischen Bildschirm benutzen */
  } /* if */
} /* close_vwork */

/*****************************************************************************/
/* ôffne Workstation                                                         */
/*****************************************************************************/

GLOBAL WORD open_work (device, dev_info)
WORD    device;
DEVINFO *dev_info;

{
  WORD i;
  WORD handle;
  WORD work_in [103];
  WORD work_out [57];
  LONG lFactor;

  if (! gdos_ok ()) return (0);

  for (i = 0; i < 103; i++) work_in [i] = 1;

  work_in [0]  = device;                   /* Device handle */
  work_in [10] = RC;                       /* Raster Koordinaten */

  if (device == SCREEN)
  {
    handle = phys_handle;
    v_opnvwk (work_in, &handle, work_out); /* Virtuell îffnen */
  } /* if */
  else                                     /* Nicht Bildschirm */
  {
#if GEM & (GEM2 | GEM3 | XGEM)
    work_in [11] = OW_NOCHANGE;            /* Paralleler oder serieller port */
#endif
    v_opnwk (work_in, &handle, work_out);  /* Physikalisch îffnen */
  } /* else */

  dev_info->dev_w = work_out [0] + 1L;
  dev_info->dev_h = work_out [1] + 1L;
  dev_info->pix_w = work_out [3];
  dev_info->pix_h = work_out [4];

  vq_extnd (handle, TRUE, work_out);

  if (work_out [20] != 0)                  /* Exakte Werte verfÅgbar */
  {
    lFactor                   = (work_out [20] == 1) ? 10L : (work_out [20] == 2) ? 100L : 1000L;
    dev_info->lPixelsPerMeter = 1000000L * lFactor / work_out [22];
    dev_info->lRealPageWidth  = dev_info->dev_w * work_out [21] / lFactor;
    dev_info->lRealPageHeight = dev_info->dev_h * work_out [22] / lFactor;
    dev_info->lXOffset        = (LONG)work_out [40] * (LONG)work_out [21] / lFactor;
    dev_info->lYOffset        = (LONG)work_out [41] * (LONG)work_out [22] / lFactor;
    dev_info->lPhysPageWidth  = (dev_info->dev_w + work_out [40] + work_out [42]) * work_out [21] / lFactor;
    dev_info->lPhysPageHeight = (dev_info->dev_h + work_out [41] + work_out [43]) * work_out [22] / lFactor;
  } /* if */
  else
  {
    dev_info->lPixelsPerMeter = 1000000L / dev_info->pix_h;
    dev_info->lRealPageWidth  = dev_info->dev_w * dev_info->pix_w;
    dev_info->lRealPageHeight = dev_info->dev_h * dev_info->pix_h;
    dev_info->lPhysPageWidth  = dev_info->lRealPageWidth;
    dev_info->lPhysPageHeight = dev_info->lRealPageHeight;
    dev_info->lXOffset        = (dev_info->lPhysPageWidth - dev_info->lRealPageWidth) / 2;
    dev_info->lYOffset        = (dev_info->lPhysPageHeight - dev_info->lRealPageHeight) / 2;
  } /* else */

  return (handle);
} /* open_work */

/*****************************************************************************/

GLOBAL WORD open_work_ex (device, dev_info, pageformat, orientation, filename)
WORD    device;
DEVINFO *dev_info;
WORD    pageformat, orientation;
BYTE    *filename;

{
  WORD i;
  WORD handle;
  WORD work_in [103];
  WORD work_out [57];
  LONG lFactor;

  if (! gdos_ok ()) return (0);

  for (i = 0; i < 103; i++) work_in [i] = 1;

  work_in [0]  = device;                   /* Device handle */
  work_in [10] = RC;                       /* Raster Koordinaten */
  work_in [11] = pageformat;
  work_in [12] = (UWORD)((LONG)filename >> 16);
  work_in [13] = (UWORD)((LONG)filename & 0xFFFFL);
  work_in [14] = 0;
  work_in [15] = 0;

  if (device == SCREEN)
  {
    handle = phys_handle;
    v_opnvwk (work_in, &handle, work_out); /* Virtuell îffnen */
  } /* if */
  else                                     /* Nicht Bildschirm */
  {
#if GEM & (GEM2 | GEM3 | XGEM)
    work_in [11] = OW_NOCHANGE;            /* Paralleler oder serieller port */
#endif
    lv_opnwk (work_in, &handle, work_out); /* Physikalisch îffnen */
  } /* else */

  if (orientation >= 0)
    v_orient (handle, orientation);

  vq_extnd (handle, FALSE, work_out);

  dev_info->dev_w = work_out [0] + 1L;
  dev_info->dev_h = work_out [1] + 1L;
  dev_info->pix_w = work_out [3];
  dev_info->pix_h = work_out [4];

  vq_extnd (handle, TRUE, work_out);

  if (work_out [20] != 0)                  /* Exakte Werte verfÅgbar */
  {
    lFactor                   = (work_out [20] == 1) ? 10L : (work_out [20] == 2) ? 100L : 1000L;
    dev_info->lPixelsPerMeter = 1000000L * lFactor / work_out [22];
    dev_info->lRealPageWidth  = dev_info->dev_w * work_out [21] / lFactor;
    dev_info->lRealPageHeight = dev_info->dev_h * work_out [22] / lFactor;
    dev_info->lXOffset        = (LONG)work_out [40] * (LONG)work_out [21] / lFactor;
    dev_info->lYOffset        = (LONG)work_out [41] * (LONG)work_out [22] / lFactor;
    dev_info->lPhysPageWidth  = (dev_info->dev_w + work_out [40] + work_out [42]) * work_out [21] / lFactor;
    dev_info->lPhysPageHeight = (dev_info->dev_h + work_out [41] + work_out [43]) * work_out [22] / lFactor;
  } /* if */
  else
  {
    dev_info->lPixelsPerMeter = 1000000L / dev_info->pix_h;
    dev_info->lRealPageWidth  = dev_info->dev_w * dev_info->pix_w;
    dev_info->lRealPageHeight = dev_info->dev_h * dev_info->pix_h;
    dev_info->lPhysPageWidth  = dev_info->lRealPageWidth;
    dev_info->lPhysPageHeight = dev_info->lRealPageHeight;
    dev_info->lXOffset        = (dev_info->lPhysPageWidth - dev_info->lRealPageWidth) / 2;
    dev_info->lYOffset        = (dev_info->lPhysPageHeight - dev_info->lRealPageHeight) / 2;
  } /* else */

  return (handle);
} /* open_work_ex */

/*****************************************************************************/
/* Schlieûe Workstation                                                      */
/*****************************************************************************/

GLOBAL VOID close_work (device, out_handle)
WORD device, out_handle;

{
  if (device >= PRINTER)
    v_clswk (out_handle);
  else
    v_clsvwk (out_handle);
} /* close_work */

/*****************************************************************************/

GLOBAL BOOLEAN gdos_ok ()

{
#if GEMDOS
#if LASER_C | MW_C | TURBO_C
  return (vq_gdos () != 0);
#else
  return (TRUE);
#endif /* TURBO_C */
#else
  return (TRUE);
#endif /* GEMDOS */
} /* gdos_ok */

/*****************************************************************************/

GLOBAL UWORD scan_to_ascii (scan)
UWORD scan;

{
  return (alt_keys [scan - SP]);
} /* scan_to_ascii */

/*****************************************************************************/
/* Maus-Routinen                                                             */
/*****************************************************************************/

GLOBAL VOID set_mouse (number, addr)
WORD  number;
MFORM *addr;

{
  last_mousenumber = mousenumber;
  last_mouseform   = mouseform;
  mousenumber      = number;
  mouseform        = addr;
  graf_mouse (number, addr);
} /* set_mouse */

/*****************************************************************************/

GLOBAL VOID last_mouse ()

{
  set_mouse (last_mousenumber, last_mouseform);
} /* last_mouse */

/*****************************************************************************/

GLOBAL VOID hide_mouse ()

{
  if (hidden == 0) graf_mouse (M_OFF, NULL);
  hidden++;
} /* hide_mouse */

/*****************************************************************************/

GLOBAL VOID show_mouse ()

{
  hidden--;
  if (hidden == 0) graf_mouse (M_ON, NULL);
} /* show_mouse */

/*****************************************************************************/

GLOBAL VOID busy_mouse ()

{
  if (busy == 0) set_mouse (HOURGLASS, NULL);
  busy++;
} /* busy_mouse */

/*****************************************************************************/

GLOBAL VOID arrow_mouse ()

{
  busy--;
  if (busy == 0) set_mouse (ARROW, NULL);
} /* arrow_mouse */

/*****************************************************************************/
/* Objekt-Routinen                                                           */
/*****************************************************************************/

GLOBAL VOID do_state (tree, obj, state)
OBJECT *tree;
WORD   obj;
UWORD  state;

{
  tree [obj].ob_state |= state;         /* Status im Objekt setzen */
} /* do_state */

/*****************************************************************************/

GLOBAL VOID undo_state (tree, obj, state)
OBJECT *tree;
WORD   obj;
UWORD  state;

{
  tree [obj].ob_state &= ~ state;       /* Status im Objekt lîschen */
} /* undo_state */

/*****************************************************************************/

GLOBAL VOID flip_state (tree, obj, state)
OBJECT *tree;
WORD   obj;
UWORD  state;

{
  tree [obj].ob_state ^= state;         /* Status im Objekt invertieren */
} /* flip_state */

/*****************************************************************************/

GLOBAL WORD find_state (tree, obj, state)
OBJECT *tree;
WORD   obj;
UWORD  state;

{
  do
  {
    if (is_state (tree, obj, state)) return (obj);
  } while (! is_flags (tree, obj++, LASTOB));

  return (NIL);
} /* find_state */

/*****************************************************************************/

GLOBAL BOOLEAN is_state (tree, obj, state)
OBJECT *tree;
WORD   obj;
UWORD  state;

{
  return ((tree [obj].ob_state & state) != 0);
} /* is_state */

/*****************************************************************************/

GLOBAL VOID do_flags (tree, obj, flags)
OBJECT *tree;
WORD   obj;
UWORD  flags;

{
  tree [obj].ob_flags |= flags;         /* Flags im Objekt setzen */
} /* do_flags */

/*****************************************************************************/

GLOBAL VOID undo_flags (tree, obj, flags)
OBJECT *tree;
WORD   obj;
UWORD  flags;

{
  tree [obj].ob_flags &= ~ flags;       /* Flags im Objekt lîschen */
} /* undo_flags */

/*****************************************************************************/

GLOBAL VOID flip_flags (tree, obj, flags)
OBJECT *tree;
WORD   obj;
UWORD  flags;

{
  tree [obj].ob_flags ^= flags;         /* Flags im Objekt invertieren */
} /* flip_flags */

/*****************************************************************************/

GLOBAL WORD find_flags (tree, obj, flags)
OBJECT *tree;
WORD   obj;
UWORD  flags;

{
  do
  {
    if (is_flags (tree, obj, flags)) return (obj);
  } while (! is_flags (tree, obj++, LASTOB));

  return (NIL);
} /* find_flags */

/*****************************************************************************/

GLOBAL BOOLEAN is_flags (tree, obj, flags)
OBJECT *tree;
WORD   obj;
UWORD  flags;

{
  return ((tree [obj].ob_flags & flags) != 0);
} /* is_flags */

/*****************************************************************************/

GLOBAL WORD find_type (tree, obj, type)
OBJECT *tree;
WORD   obj;
UWORD  type;

{
  do
  {
    if (is_type (tree, obj, type)) return (obj);
  } while (! is_flags (tree, obj++, LASTOB));

  return (NIL);
} /* find_type */

/*****************************************************************************/

GLOBAL BOOLEAN is_type (tree, obj, type)
OBJECT *tree;
WORD   obj;
UWORD  type;

{
  USRBLK *usrblk;

  if (OB_TYPE (tree, obj) == type) return (TRUE);

  if (OB_TYPE (tree, obj) == G_USERDEF)
  {
    usrblk = (USRBLK *)OB_SPEC (tree, obj);
    if (usrblk->ob_type == type) return (TRUE);
  } /* if */

  return (FALSE);
} /* is_type */

/*****************************************************************************/

GLOBAL VOID set_checkbox (tree, obj, selected)
OBJECT  *tree;
WORD    obj;
BOOLEAN selected;

{
  if (selected)
    do_state (tree, obj, SELECTED);
  else
    undo_state (tree, obj, SELECTED);
} /* set_checkbox */

/*****************************************************************************/

GLOBAL BOOLEAN get_checkbox (tree, obj)
OBJECT *tree;
WORD   obj;

{
  return (is_state (tree, obj, SELECTED));
} /* get_checkbox */

/*****************************************************************************/

GLOBAL VOID set_rbutton (tree, obj, lower, upper)
OBJECT *tree;
WORD   obj, lower, upper;

{
  REG WORD i;

  for (i = lower; i <= upper; i++)
    if (is_flags (tree, i, RBUTTON))
    {
      undo_state (tree, i, SELECTED);
      if (obj == i) do_state (tree, i, SELECTED);
    } /* if, for */
} /* set_rbutton */

/*****************************************************************************/

GLOBAL WORD get_rbutton (tree, obj)
OBJECT *tree;
WORD   obj;

{
  return (find_state (tree, obj, SELECTED));
} /* get_rbutton */

/*****************************************************************************/

GLOBAL VOID set_ptext (tree, obj, s)
OBJECT *tree;
WORD   obj;
BYTE   *s;

{
  TEDINFO *ptedinfo;

  ptedinfo = (TEDINFO *)get_ob_spec (tree, obj);
  strncpy (ptedinfo->te_ptext, s, ptedinfo->te_txtlen - 1);
  ptedinfo->te_ptext [ptedinfo->te_txtlen - 1] = EOS;
} /* set_ptext */

/*****************************************************************************/

GLOBAL VOID get_ptext (tree, obj, s)
OBJECT *tree;
WORD   obj;
BYTE   *s;

{
  TEDINFO *ptedinfo;

  ptedinfo = (TEDINFO *)get_ob_spec (tree, obj);
  strcpy (s, ptedinfo->te_ptext);
} /* get_ptext */

/*****************************************************************************/

GLOBAL VOID set_str (tree, obj, s)
OBJECT *tree;
WORD   obj;
BYTE   *s;

{
  USRBLK *usrblk;

  switch (OB_TYPE (tree, obj))
  {
    case G_TEXT     :
    case G_BOXTEXT  :
    case G_FTEXT    :
    case G_FBOXTEXT : set_ptext (tree, obj, s);
                      break;
    case G_BUTTON   :
    case G_STRING   :
    case G_TITLE    : strcpy ((BYTE *)tree [obj].ob_spec, s);
                      break;
    case G_ICON     : 
    case G_CICON    : strcpy (((ICONBLK *)tree [obj].ob_spec)->ib_ptext, s);
                      break;
    case G_USERDEF  : usrblk = (USRBLK *)tree [obj].ob_spec;
                      switch (usrblk->ob_type)
                      {
                        case G_BUTTON :
                        case G_STRING :
                        case G_TITLE  : strcpy ((BYTE *)usrblk->userblk.ub_parm, s);
                                        break;
                        default       : break;
                      } /* switch */
                      break;
    default         : break;
  } /* switch */
} /* set_str */

/*****************************************************************************/

GLOBAL BYTE *get_str (tree, obj)
OBJECT *tree;
WORD   obj;

{
  BYTE   *p;
  USRBLK *usrblk;

  switch (OB_TYPE (tree, obj))
  {
    case G_TEXT     :
    case G_BOXTEXT  :
    case G_FTEXT    :
    case G_FBOXTEXT : p = ((TEDINFO *)tree [obj].ob_spec)->te_ptext;
                      break;
    case G_BUTTON   :
    case G_STRING   :
    case G_TITLE    : p = (BYTE *)tree [obj].ob_spec;
                      break;
    case G_ICON     : 
    case G_CICON    : p = ((ICONBLK *)tree [obj].ob_spec)->ib_ptext;
                      break;
    case G_USERDEF  : usrblk = (USRBLK *)tree [obj].ob_spec;
                      switch (usrblk->ob_type)
                      {
                        case G_BUTTON :
                        case G_STRING :
                        case G_TITLE  : p = (BYTE *)usrblk->userblk.ub_parm;
                                        break;
                        default       : p = NULL;
                                        break;
                      } /* switch */
                      break;
    default         : p = NULL;
                      break;
  } /* switch */

  return (p);
} /* get_str */

/*****************************************************************************/

GLOBAL VOID set_ob_spec (tree, obj, ob_spec)
OBJECT *tree;
WORD   obj;
LONG   ob_spec;

{
  USERBLK *userblk;

  if (OB_TYPE (tree, obj) == G_USERDEF)
  {
    userblk = (USERBLK *)tree [obj].ob_spec;
    userblk->ub_parm = ob_spec;
  }
  else
    tree [obj].ob_spec = ob_spec;
} /* set_ob_spec */

/*****************************************************************************/

GLOBAL LONG get_ob_spec (tree, obj)
OBJECT *tree;
WORD   obj;

{
  USERBLK *userblk;

  if (OB_TYPE (tree, obj) == G_USERDEF)
  {
    userblk = (USERBLK *)tree [obj].ob_spec;
    return (userblk->ub_parm);
  }
  else
    return (tree [obj].ob_spec);
} /* get_ob_spec */

/*****************************************************************************/

GLOBAL UWORD get_ob_type (tree, obj)
OBJECT *tree;
WORD   obj;

{
  USRBLK *usrblk;

  if (OB_TYPE (tree, obj) == G_USERDEF)
  {
    usrblk = (USRBLK *)tree [obj].ob_spec;
    return (usrblk->ob_type);
  }
  else
    return (OB_TYPE (tree, obj));
} /* get_ob_type */

/*****************************************************************************/

GLOBAL WORD get_parent (tree, obj)
OBJECT *tree;
int    obj;

{
  WORD pobj;

  if (obj == NIL) return (NIL);

  pobj = tree [obj].ob_next;

  if (pobj != NIL)
    while (tree	[pobj].ob_tail != obj)
    {
      obj  = pobj;
      pobj = tree [obj].ob_next;
    } /* while,	if */

  return (pobj);
} /* get_parent	*/

/*****************************************************************************/

GLOBAL VOID menu_check (tree, obj, checkit)
OBJECT  *tree;
WORD    obj;
BOOLEAN checkit;

{
#if GEM & XGEM
  menu_icheck (tree, obj, checkit);
#else
  if (checkit)
    do_state (tree, obj, CHECKED);
  else
    undo_state (tree, obj, CHECKED);
#endif
} /* menu_check */

/*****************************************************************************/

GLOBAL VOID menu_enable (tree, obj, enableit)
OBJECT  *tree;
WORD    obj;
BOOLEAN enableit;

{
#if GEM & XGEM
  menu_ienable (tree, obj, checkit);
#else
  if (enableit)
    undo_state (tree, obj, DISABLED);
  else
    do_state (tree, obj, DISABLED);
#endif
} /* menu_enable */

/*****************************************************************************/

GLOBAL VOID objc_rect (tree, obj, rect, calc_border)
OBJECT  *tree;
WORD     obj;
RECT    *rect;
BOOLEAN calc_border;

{
  WORD border, diff;

  objc_offset (tree, obj, &rect->x, &rect->y);
  rect->w = tree [obj].ob_width;
  rect->h = tree [obj].ob_height;

  if (calc_border &&
      ((get_ob_type (tree, obj) == G_BOX) ||
       (get_ob_type (tree, obj) == G_IBOX) ||
       (get_ob_type (tree, obj) == G_BOXCHAR)))
  {
    border = (WORD)((get_ob_spec (tree, obj) >> 16) & 0x00FFL);

    if (border & 0x0080) border |= 0xFF00;      /* Rand negativ */

    if (border < 0)
    {
      rect->x += border;                        /* Wegen Rand */
      rect->y += border;
      rect->w -= 2 * border;
      rect->h -= 2 * border;
    } /* if */

    if (is_state (tree, obj, SHADOWED))         /* Schatten berÅcksichtigen */
    {
      rect->w += 2 * abs (border);
      rect->h += 2 * abs (border);
    } /* if */

    if (is_state (tree, obj, OUTLINED))         /* Outlined berÅcksichtigen */
    {
      if (border >= 0)
        diff = 3;
      else
        if (border > -3)
          diff = 3 + border;
        else
          diff = 0;

      rect->x -= diff;                          /* Wegen Rand */
      rect->y -= diff;        
      rect->w += 2 * diff;
      rect->h += 2 * diff;
    } /* if */
  } /* if */
} /* objc_rect */

/*****************************************************************************/

LOCAL VOID vdi_fix (pfd, theaddr, wb, h)
MFDB *pfd;
VOID *theaddr;
WORD wb, h;

{
  pfd->mp  = theaddr;
  pfd->fwp = wb << 3;
  pfd->fh  = h;
  pfd->fww = wb >> 1;
  pfd->np  = 1;
} /* vdi_fix */

/*****************************************************************************/

LOCAL VOID vdi_trans (saddr, swb, daddr, dwb, h)
WORD *saddr;
WORD swb;
WORD *daddr;
WORD dwb;
WORD h;

{
  MFDB src, dst;

  vdi_fix (&src, saddr, swb, h);
  src.ff = TRUE;

  vdi_fix (&dst, daddr, dwb, h);
  dst.ff = FALSE;

  vr_trnfm (vdi_handle, &src, &dst);
} /* vdi_trans */

/*****************************************************************************/

GLOBAL VOID trans_gimage (tree, obj)
OBJECT *tree;
WORD   obj;

{
  ICONBLK *piconblk;
  BITBLK  *pbitblk;
  WORD    *taddr;
  WORD    wb, hl, type;

  type = get_ob_type (tree, obj);

  if ((type == G_ICON) || (type == G_CICON))
  {
    piconblk = (ICONBLK *)get_ob_spec (tree, obj);
    taddr    = piconblk->ib_pmask;
    wb       = piconblk->ib_wicon;
    wb       = wb >> 3;
    hl       = piconblk->ib_hicon;

    vdi_trans (taddr, wb, taddr, wb, hl);

    taddr = piconblk->ib_pdata;
  } /* if */
  else
  {
    pbitblk = (BITBLK *)get_ob_spec (tree, obj);
    taddr   = pbitblk->bi_pdata;
    wb      = pbitblk->bi_wb;
    hl      = pbitblk->bi_hl;
  } /* else */

  vdi_trans (taddr, wb, taddr, wb, hl);
} /* trans_gimage */

/*****************************************************************************/
/* Default-Attribute fÅr Linie setzen                                        */
/*****************************************************************************/

GLOBAL VOID line_default (vdi_handle)
WORD vdi_handle;

{
  vswr_mode (vdi_handle, MD_REPLACE);
  vsl_color (vdi_handle, BLACK);
  vsl_ends (vdi_handle, SQUARED, SQUARED);
  vsl_type (vdi_handle, SOLID);
  vsl_width (vdi_handle, 1);
} /* line_default */

/*****************************************************************************/
/* Default-Attribute fÅr Text setzen                                         */
/*****************************************************************************/

GLOBAL VOID text_default (vdi_handle)
WORD vdi_handle;

{
  WORD ret;

  vswr_mode (vdi_handle, MD_REPLACE);
  vst_font (vdi_handle, FONT_SYSTEM);
  vst_color (vdi_handle, BLACK);
  vst_height (vdi_handle, gl_hchar, &ret, &ret, &ret, &ret);
  vst_effects (vdi_handle, TXT_NORMAL);
  vst_alignment (vdi_handle, ALI_LEFT, ALI_TOP, &ret, &ret);
  vst_rotation (vdi_handle, 0);
} /* text_default */

/*****************************************************************************/
/* Text ausgeben (> 127 Zeichen)                                             */
/*****************************************************************************/

GLOBAL VOID v_text (vdi_handle, x, y, string)
WORD vdi_handle, x, y;
BYTE *string;

{
  WORD len, minlen, extent [8];
  BYTE s [128];
  BYTE *p;

  for (len = strlen (string), p = string; len > 0; len -= 127, p += 127, x += extent [2] - extent [0])
  {
    minlen = min (127, len);
    strncpy (s, p, minlen);
    s [minlen] = EOS;
    v_gtext (vdi_handle, x, y, s);
    vqt_extent (vdi_handle, s, extent);
  } /* for */
} /* v_text */

/*****************************************************************************/
/* Punktgrîûe in AbhÑngigkeit von GDOS setzen                                */
/*****************************************************************************/

GLOBAL WORD vst_arbpoint (WORD vdi_handle, WORD point, WORD *char_width, WORD *char_height, WORD *cell_width, WORD *cell_height)
{
  if (gdos_ok)
    return (vst_arbpt (vdi_handle, point, char_width, char_height, cell_width, cell_height));
  else
    return (vst_point (vdi_handle, point, char_width, char_height, cell_width, cell_height));
} /* vst_arbpoint */

/*****************************************************************************/
/* Textbreite berechnen                                                      */
/*****************************************************************************/

GLOBAL VOID text_extent (WORD vdi_handle, BYTE *text, BOOLEAN incl_effects, WORD *width, WORD *height)
{
  WORD minimum, maximum, w;
  WORD extent [8], distances [5], effects [3];

  if (text == NULL)
    text = "";

  vqt_extent (vdi_handle, text, extent);
  vqt_font_info (vdi_handle, &minimum, &maximum, distances, &w, effects);

  if (width != NULL)
    *width  = extent [2] - extent [0] + (incl_effects ? effects [2] : 0);

  if (height != NULL)
    *height = extent [5] - extent [3];
} /* text_extent */

/*****************************************************************************/
/* 3-D-Rahmen zeichnen                                                       */
/*****************************************************************************/

GLOBAL VOID draw_3d (vdi_handle, x_offset, y_offset, border_width, width, height, upper_left, lower_right, corners, draw_borderline)
WORD    vdi_handle, x_offset, y_offset, border_width, width, height, upper_left, lower_right, corners;
BOOLEAN draw_borderline;

{
  WORD i;
  WORD xy [6];

  if ((width > 0) && (height > 0))
  {
    line_default (vdi_handle);

    for (i = 0; i < border_width; i++)
    {
      vsl_color (vdi_handle, corners);

      xy [0] = x_offset - border_width + i;
      xy [1] = y_offset + height + border_width - 1 - i;
      xy [2] = xy [0];
      xy [3] = xy [1];
      v_pline (vdi_handle, 2, xy);

      vsl_color (vdi_handle, upper_left);

      xy [0] = x_offset - border_width + i;
      xy [1] = y_offset + height + border_width - 2 - i;
      xy [2] = x_offset - border_width + i;
      xy [3] = y_offset - border_width + i;
      xy [4] = x_offset + width + border_width - 1 - i - 1;
      xy [5] = y_offset - border_width + i;
      v_pline (vdi_handle, 3, xy);

      vsl_color (vdi_handle, corners);

      xy [0] = x_offset + width + border_width - 1 - i;
      xy [1] = y_offset - border_width + i;
      xy [2] = xy [0];
      xy [3] = xy [1];
      v_pline (vdi_handle, 2, xy);
    } /* for */

    for (i = 0; i < border_width; i++)
    {
      vsl_color (vdi_handle, corners);

      xy [0] = x_offset + width + border_width - 1 - i;
      xy [1] = y_offset - border_width + i;
      xy [2] = xy [0];
      xy [3] = xy [1];
      v_pline (vdi_handle, 2, xy);

      vsl_color (vdi_handle, lower_right);

      xy [0] = x_offset + width + border_width - 1 - i;
      xy [1] = y_offset - border_width + i + 1;
      xy [2] = x_offset + width + border_width - 1 - i;
      xy [3] = y_offset + height + border_width - 1 - i;
      xy [4] = x_offset - border_width + i + 1;
      xy [5] = y_offset + height + border_width - 1 - i;
      v_pline (vdi_handle, 3, xy);

      vsl_color (vdi_handle, corners);

      xy [0] = x_offset - border_width + i;
      xy [1] = y_offset + height + border_width - 1 - i;
      xy [2] = xy [0];
      xy [3] = xy [1];
      v_pline (vdi_handle, 2, xy);
    } /* for */
  } /* if */

  if (draw_borderline)
  {
    xywh2array (x_offset - border_width - 1, y_offset - border_width - 1, width + 2 * border_width + 2, height + 2 * border_width + 2, xy);
    vswr_mode (vdi_handle, MD_TRANS);
    vsf_color (vdi_handle, BLACK);
    vsf_interior (vdi_handle, FIS_HOLLOW);
    vsf_perimeter (vdi_handle, TRUE);
    vsf_style (vdi_handle, 0);
    v_bar (vdi_handle, xy);
  } /* if */
} /* draw_3d */

/*****************************************************************************/
/* Dialog-Verarbeitung                                                       */
/*****************************************************************************/

GLOBAL BOOLEAN background (tree, obj, get, screen, buffer)
OBJECT  *tree;
WORD    obj;
BOOLEAN get;
MFDB    *screen, *buffer;

{
  RECT box;
  LONG size;
  WORD diff;
  WORD xy [8];

  objc_rect (tree, obj, &box, TRUE);

  if (rc_intersect (&desk, &box))               /* Nur auf sichtbarem Schirm zeichnen */
  {
    diff = box.x & 0x000F;                      /* Auf Wortgrenze ? */

    if (diff != 0)
    {
       box.x -= diff;
       box.w += diff;
    } /* if */

    screen->mp  = NULL;                         /* Bildschirm */
    buffer->fwp = box.w;
    buffer->fh  = box.h;
    buffer->fww = box.w / 16 + (box.w % 16 != 0);
    buffer->ff  = FALSE;
    buffer->np  = planes;

    if (get)
    {
      size       = (LONG)buffer->fww * 2L * (LONG)buffer->fh * (LONG)buffer->np;
      buffer->mp = mem_alloc (size);

      rect2array (&box, xy);
      xywh2array (0, 0, box.w, box.h, &xy [4]);
    } /* if */
    else
    {
      xywh2array (0, 0, box.w, box.h, xy);
      rect2array (&box, &xy [4]);
    } /* if */

    if (buffer->mp != NULL)
    {
      set_clip (FALSE, &desk);
      hide_mouse ();

      if (get)
        vro_cpyfm (vdi_handle, S_ONLY, xy, screen, buffer);
      else
      {
        vro_cpyfm (vdi_handle, S_ONLY, xy, buffer, screen);
        mem_free (buffer->mp);
      } /* else */

      show_mouse ();
    } /* if */
    else                        /* Wenigstens Update */
      if (! get) form_dial (FMD_FINISH, 0, 0, 0, 0, box.x, box.y, box.w, box.h);
  } /* if */

  return (buffer->mp != NULL);
} /* background */

/*****************************************************************************/

GLOBAL BOOLEAN opendial (tree, grow, size, screen, buffer)
OBJECT  *tree;
BOOLEAN grow;
RECT    *size;
MFDB    *screen, *buffer;

{
  BOOLEAN ok;
  RECT    r, d;

  ok = FALSE;

#if GEM & XGEM
  screen = NULL;
#endif

  if (size == NULL)
    xywh2rect (0, 0, 0, 0, &r);
  else
    r = *size;

  form_center (tree, &d.x, &d.y, &d.w, &d.h);

  if ((screen == NULL) || (buffer == NULL))
    form_dial (FMD_START, r.x, r.y, r.w, r.h, d.x, d.y, d.w, d.h);
  else
    ok = background (tree, ROOT, TRUE, screen, buffer);

  if (grow) growbox (&r, &d);

  return (ok);
} /* opendial */

/*****************************************************************************/

GLOBAL BOOLEAN closedial (tree, shrink, size, screen, buffer)
OBJECT  *tree;
BOOLEAN shrink;
RECT    *size;
MFDB    *screen, *buffer;

{
  BOOLEAN ok;
  RECT    r, d;

  ok = FALSE;

#if GEM & XGEM
  screen = NULL;
#endif

  if (size == NULL)
    xywh2rect (0, 0, 0, 0, &r);
  else
    r = *size;

  form_center (tree, &d.x, &d.y, &d.w, &d.h);

  if ((screen == NULL) || (buffer == NULL))
    form_dial (FMD_FINISH, r.x, r.y, r.w, r.h, d.x, d.y, d.w, d.h);
  else
    ok = background (tree, ROOT, FALSE, screen, buffer);

  if (shrink) shrinkbox (&r, &d);

  return (ok);
} /* closedial */

/*****************************************************************************/

GLOBAL WORD hndl_dial (tree, def, grow_shrink, save_back, size, ok)
OBJECT  *tree;
WORD    def;
BOOLEAN grow_shrink, save_back;
RECT    *size;
BOOLEAN *ok;

{
  RECT r;
  WORD exit_obj;
  MFDB screen, buffer;
  MFDB *screenp, *bufferp;

  if (save_back)                                        /* Hintergrund retten */
  {
    screenp = &screen;
    bufferp = &buffer;
  } /* if */
  else
    screenp = bufferp = NULL;                           /* Keinen Hintergrund retten */

  *ok = opendial (tree, grow_shrink, size, screenp, bufferp);
  form_center (tree, &r.x, &r.y, &r.w, &r.h);           /* Mitte berechnen */

  objc_draw (tree, ROOT, MAX_DEPTH, r.x, r.y, r.w, r.h); /* Zeichnen */
  draw_3d_dlg (tree);

  show_mouse ();                                        /* Maus ist beim Scrolling zweimal versteckt */
  show_mouse ();
  set_mouse (ARROW, NULL);
  exit_obj = formdo (tree, def) & 0x7FFF;               /* Dialog */
  last_mouse ();
  hide_mouse ();
  hide_mouse ();

  *ok = closedial (tree, grow_shrink, size, screenp, bufferp);
  undo_state (tree, exit_obj, SELECTED);                /* Objekt wieder weiû machen */

  return (exit_obj);           /* Objekt, mit dem Dialogbox verlassen wurde */
} /* hndl_dial */

/*****************************************************************************/

LOCAL WORD find_obj (tree, start_obj, which)
OBJECT *tree;
WORD   start_obj, which;

{
  WORD obj, theflag, thestate, flag, inc;

  obj  = 0;
  flag = EDITABLE;
  inc  = 1;

  switch (which)
  {
    case FMD_BACKWARD : inc = -1;               /* fall thru */
    case FMD_FORWARD  : obj = start_obj + inc;
                        break;
    case FMD_DEFLT    : flag = DEFAULT;
                        break;
  } /* switch */

  while (obj >= 0)
  {
    theflag  = tree [obj].ob_flags;
    thestate = tree [obj].ob_state;

    if (theflag & flag)
     if (! (theflag & HIDETREE))
       if (! (thestate & DISABLED)) return (obj);

    if (theflag & LASTOB)
      obj = NIL;
    else
      obj += inc;
  } /* while */

  return (obj);
} /* find_obj */

/*****************************************************************************/

LOCAL WORD fm_inifld (tree, start_fld)
OBJECT *tree;
WORD   start_fld;

{
  if (start_fld == 0) start_fld = find_obj (tree, 0, FMD_FORWARD);
  return (start_fld);
} /* fm_inifld */

/*****************************************************************************/

GLOBAL WORD formdo (tree, start)
OBJECT *tree;
WORD   start;

{
  WORD   edit_obj;
  WORD   next_obj, next;
  WORD   which, cont;
  WORD   idx;
  WORD   mx, my, mb, ks, br;
  UWORD  kr;
  MKINFO mk;

  wind_update (BEG_UPDATE);
  wind_update (BEG_MCTRL);

  next_obj = fm_inifld (tree, start);
  edit_obj = 0;
  cont     = TRUE;

  while (cont)
  {
    if ((next_obj != NIL) && (next_obj != 0) && (edit_obj != next_obj))
    {
      edit_obj = next_obj;
      next_obj = 0;
      objc_edit (tree, edit_obj, 0, &idx, EDINIT);
    } /* if */

    which = evnt_multi (MU_KEYBD | MU_BUTTON,
                        0x0002, 0x0001, 0x0001,
                        0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0,
                        NULL,
                        0, 0,
                        &mx, &my, &mb, &ks, &kr, &br);

    if (which & MU_KEYBD)
    {
      mk.alt       = (ks & K_ALT) != 0;
      mk.scan_code = kr >> 8;
      next         = NIL;

      if (mk.scan_code == UNDO) next = find_flags (tree, ROOT, UNDO_FLAG);
      if (next == NIL) next = check_alt (tree, &mk);

      if (next != NIL)
      {
        objc_offset (tree, next, &mx, &my);
        br    = 1;
        which = MU_BUTTON;
      } /* if */
      else
      {
        cont = form_keybd (tree, edit_obj, next_obj, kr, &next_obj, &kr);
        if (kr) objc_edit (tree, edit_obj, kr, &idx, EDCHAR);
      } /* else */
    } /* if */

    if (which & MU_BUTTON)
    {
      next_obj = objc_find (tree, ROOT, MAX_DEPTH, mx, my);

      if (next_obj == NIL)
      {
        beep ();
        next_obj = 0;
      } /* if */
      else
      {
        if (! is_flags (tree, next_obj, LASTOB) && (br == 1))
          if ((get_ob_type (tree, next_obj) == G_STRING) &&
              ((get_ob_type (tree, next_obj + 1) == G_FTEXT) ||
               (get_ob_type (tree, next_obj + 1) == G_FBOXTEXT) ||
               (get_ob_type (tree, next_obj + 1) == G_BOXTEXT))) next_obj++;

        cont = form_button (tree, next_obj, br, &next_obj);
      } /* else */
    } /* if */

    if (! cont || ((next_obj != 0) && (next_obj != edit_obj)))
      if (edit_obj != 0) objc_edit (tree, edit_obj, 0, &idx, EDEND);
  } /* while */

  wind_update (END_MCTRL);
  wind_update (END_UPDATE);

  return (next_obj);
} /* formdo */

/*****************************************************************************/

GLOBAL VOID blink (tree, obj, blinkrate)
OBJECT *tree;
WORD   obj, blinkrate;

{
  REG WORD i;

  if ((tree != NULL) && (obj != NIL))           /* Blinken mîglich */
    for (i = 0; i < 2 * blinkrate; i++)
    {
      objc_change (tree, obj, 0, desk.x, desk.y, desk.w, desk.h, tree [obj].ob_state ^ SELECTED, TRUE);
#if GEM & XGEM
      evnt_timer (10, 0);
#else
      evnt_timer (50, 0);
#endif
    } /* for */
} /* blink */

/*****************************************************************************/

GLOBAL WORD popup_menu (tree, obj, x, y, center_obj, relative, bmsk)
OBJECT  *tree;
WORD    obj, x, y, center_obj;
BOOLEAN relative;
WORD    bmsk;

{
  MFDB    screen, buffer;
  OBJECT  *objp;
  WORD    item, founditem, olditem;
  WORD    mox, moy, mobutton, mokstate;
  BOOLEAN leave;
  WORD    xold, yold;
  WORD    xdiff, ydiff;
  RECT    r, box;
  WORD    event, ret;
  UWORD   uret;

  graf_mkstate (&mox, &moy, &mobutton, &mokstate);
  objc_rect (tree, obj, &box, FALSE);

  objp  = &tree [obj];
  xold  = objp->ob_x;                           /* Alte Werte retten */
  yold  = objp->ob_y;
  xdiff = (relative ? mox : 0) - box.x;
  ydiff = (relative ? moy : 0) - box.y;

  if (center_obj != NIL)                        /* Zentrum von Objekt berÅcksichtigen */
  {
    objc_rect (tree, center_obj, &r, FALSE);

    if (relative)
    {
      x -= r.w / 2 + r.x - box.x;
      y -= r.h / 2 + r.y - box.y;
    } /* if */
    else
    {
      x -= r.x - box.x;
      y -= r.y - box.y;
    } /* else */
  } /* if */

  objp->ob_x += xdiff + x;                      /* X/Y neu setzen */
  objp->ob_y += ydiff + y;

  objc_rect (tree, obj, &box, FALSE);           /* RÑnder berÅcksichtigen */

  xdiff = box.x + box.w - (desk.x + desk.w);    /* Rechts heraushÑngend ? */
  if (xdiff > 0) objp->ob_x -= xdiff;

  ydiff = box.y + box.h - (desk.y + desk.h);    /* Unten heraushÑngend ? */
  if (ydiff > 0) objp->ob_y -= ydiff;

  objc_rect (tree, obj, &box, FALSE);           /* RÑnder berÅcksichtigen */

  xdiff = box.x - desk.x;                       /* Links heraushÑngend ? */
  if (xdiff < 0) objp->ob_x -= xdiff;

  ydiff = box.y - desk.y;                       /* Oben heraushÑngend ? */
  if (ydiff < 0) objp->ob_y -= ydiff;

  if (relative)
  {
    objp->ob_x &= 0xFFFE;                       /* X immer gerade */
    objp->ob_y -= ! odd (objp->ob_y);           /* Y immer ungerade */
  } /* if */

  olditem   = NIL;
  founditem = item = objc_find (tree, obj, MAX_DEPTH, mox, moy); /* In MenÅ ? */

  if (item != NIL)
    if (is_state (tree, item, DISABLED) || ! is_flags (tree, item, SELECTABLE)) item = NIL;

  if (item != NIL) do_state (tree, item, SELECTED);

  background (tree, obj, TRUE, &screen, &buffer);
  objc_draw (tree, obj, MAX_DEPTH, desk.x, desk.y, desk.w, desk.h);

  set_mouse (ARROW, NULL);
  wind_update (BEG_MCTRL);                      /* Mauskontrolle Åbernehmen */

  do
  {
    if (founditem != NIL)                       /* In MenÅeintrag */
    {
      leave = TRUE;
      objc_rect (tree, founditem, &r, FALSE);
    } /* if */
    else                                        /* Auûerhalb Pop-Up-MenÅ */
    {
      leave = FALSE;
      objc_rect (tree, obj, &r, FALSE);
    } /* else */

    event = evnt_multi (MU_BUTTON | MU_M1,
                        1, bmsk, ~ mobutton & bmsk,
                        leave, r.x, r.y, r.w, r.h,
                        0, 0, 0, 0, 0,
                        NULL, 0, 0,
                        &mox, &moy, &ret, &ret, &uret, &ret);

    olditem   = item;
    founditem = item = objc_find (tree, obj, MAX_DEPTH, mox, moy);

    if (item != NIL)
      if (is_state (tree, item, DISABLED) || ! is_flags (tree, item, SELECTABLE)) item = NIL;

    if (olditem != item)
    {
      if (olditem != NIL)
        objc_change (tree, olditem, 0, desk.x, desk.y, desk.w, desk.h, tree [olditem].ob_state ^ SELECTED, TRUE);

      if (item != NIL)
        objc_change (tree, item, 0, desk.x, desk.y, desk.w, desk.h, tree [item].ob_state ^ SELECTED, TRUE);
    } /* if */
  } while (! (event & MU_BUTTON));

  wind_update (END_MCTRL);                      /* Mauskontrolle wieder abgeben */
  blink (tree, item, blinkrate);
  last_mouse ();

  background (tree, obj, FALSE, &screen, &buffer);

  if (item != NIL) undo_state (tree, item, SELECTED);
  if (~ mobutton & bmsk) evnt_button (1, bmsk, 0x0000, &ret, &ret, &ret, &ret); /* Warte auf Mausknopf */

  objp->ob_x = xold;                            /* Alte Werte restaurieren */
  objp->ob_y = yold;

  return (item);
} /* popup_menu */

/*****************************************************************************/

GLOBAL BOOLEAN is_menu_key (menu, mk, title, item)
OBJECT *menu;
MKINFO *mk;
WORD   *title, *item;

{
  REG WORD  ltitle, litem;
  REG BYTE  *s;
  REG UWORD key;
      WORD  i, func;
      WORD  sign, c;
      WORD  menubox;

  *title = NIL;
  *item  = NIL;

  if (menu != NULL)
  {
    key     = 0;
    menubox = menu [ROOT].ob_tail;
    menubox = menu [menubox].ob_head;
    ltitle  = THEFIRST;

    do
    {
      litem = menu [menubox].ob_head;                   /* Erster Eintrag */

      do
      {
        if ((get_ob_type (menu, litem) == G_STRING) && ! is_state (menu, litem, DISABLED))
        {
          s = get_str (menu, litem);                    /* MenÅ */
          for (i = strlen (s); (i >= 0) && (s [i] != SP); i--);

          if ((i >= 0) && (strlen (s + i) >= 2))        /* Leerzeichen und ein Buchstabe */
          {
            sign = s [++i];                             /* "Vorzeichen" */
            c    = ((sign == FUNC_CHAR) && (strlen (s + i + 1) > 0)) ? FUNC_CHAR : s [++i]; /* Eigentliches Zeichen */
            func = 0;

            if (c == EOS)                               /* Genau 1 Zeichen */
            {
              if (! (mk->ctrl || mk->alt))
                if (toupper (sign) == toupper (mk->ascii_code)) key = mk->kreturn;
            } /* if */
            else
            {
              if (c == FUNC_CHAR) sscanf (s + i + 1, "%d", &func); /* Funktionstaste */

              switch (sign)
              {
                case CTRL_CHAR  : if (mk->ctrl)         /* Control-Zeichen */
                                    if (func != 0)
                                      key = func_keys [func - 1 + 2 * MAX_FUNC];
                                    else
                                      if (mk->ascii_code == (ctrl_keys [c - SP] & 0x00FF))
                                        key = mk->kreturn;
                                  break;
                case ALT_CHAR   : if (mk->alt)          /* Alternate-Zeichen */
                                    if (func != 0)
                                      key = func_keys [func - 1 + 3 * MAX_FUNC];
                                    else
                                      key = alt_keys [c - SP];
                                  break;
                case SHIFT_CHAR : if (mk->shift)        /* Shift-Zeichen */
                                    if (func != 0) key = func_keys [func - 1 + MAX_FUNC];
                                  break;
                case FUNC_CHAR  : if (! (mk->ctrl || mk->alt || mk->shift))
                                    if (func != 0) key = func_keys [func - 1];
                                  break;
              } /* switch */
            } /* else */
          } /* if */
  
          if ((key != 0) && (key == mk->kreturn))       /* Zeichen erkannt */
          {
           *title = ltitle;
           *item  = litem;

           return (TRUE);                               /* Fertig */
          } /* if */
        } /* if */

        litem = menu [litem].ob_next;                   /* NÑchster Eintrag */
      } while (litem != menubox);

      menubox = menu [menubox].ob_next;                 /* NÑchstes Drop-Down-MenÅ */
      ltitle  = menu [ltitle].ob_next;                  /* NÑchster Titel */
    } while (ltitle != THEACTIVE);
  } /* if */

  return (FALSE);
} /* is_menu_key */

/*****************************************************************************/

GLOBAL WORD check_alt (tree, mk)
OBJECT *tree;
MKINFO *mk;

{
  WORD  obj, pos;
  BYTE  *p, ch;
  UWORD code;

  if (mk->alt)
  {
    obj = ROOT;

    do
    {
      if (! is_flags (tree, obj, HIDETREE) &&
          ! is_state (tree, obj, DISABLED) &&
          (OB_EXTYPE (tree, obj) != 0) &&
          ((get_ob_type (tree, obj) == G_BUTTON) || (get_ob_type (tree, obj) == G_STRING)))
      {
        p   = get_str (tree, obj);
        pos = OB_EXTYPE (tree, obj);
        ch  = toupper (p [pos - 1]) & 0xFF;

        if (isprint (ch))
        {
          code = alt_keys [ch - SP];
          if ((code >> 8) == mk->scan_code) return (obj);
        } /* if */
      } /* if */
    } while (! is_flags (tree, obj++, LASTOB));
  } /* if */

  return (NIL);
} /* check_alt */

/*****************************************************************************/

GLOBAL VOID draw_3d_dlg (tree)
OBJECT *tree;

{
  RECT    rect;
  WORD    border, obj;
  BOOLEAN pos;

  if (dlg_colors >= 16)
  {
    border = (WORD)((get_ob_spec (tree, ROOT) >> 16) & 0x00FFL);

    if (border & 0x0080) border |= 0xFF00;      /* Rand negativ */

    if (dlg_round_borders)
      pos = border > 0;

    if (border <= 0)
      border = btn_shadow_width;
    else
      border = btn_shadow_width + 1;

    hide_mouse ();
    objc_rect (tree, ROOT, &rect, FALSE);

    if (dlg_round_borders)
    {
      draw_3d (vdi_handle, rect.x + 5 + pos, rect.y + 5 + pos, 0, rect.w - 2 * (5 + pos), rect.h - 2 * (5 + pos), sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], TRUE);
      draw_3d (vdi_handle, rect.x + 4 + pos, rect.y + 4 + pos, 1, rect.w - 2 * (4 + pos), rect.h - 2 * (4 + pos), sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNFACE], FALSE);
      draw_3d (vdi_handle, rect.x + 3 + pos, rect.y + 3 + pos, 2, rect.w - 2 * (3 + pos), rect.h - 2 * (3 + pos), sys_colors [COLOR_BTNFACE], sys_colors [COLOR_BTNFACE], sys_colors [COLOR_BTNFACE], FALSE);
      draw_3d (vdi_handle, rect.x + 1 + pos, rect.y + 1 + pos, 1, rect.w - 2 * (1 + pos), rect.h - 2 * (1 + pos), sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], FALSE);
    } /* if */
    else
      draw_3d (vdi_handle, rect.x + border, rect.y + border, btn_shadow_width, rect.w - 2 * border, rect.h - 2 * border, sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], FALSE);

    obj = ROOT;

    do
    {
      if (get_ob_type (tree, obj) == G_FBOXTEXT)
      {
        objc_rect (tree, obj, &rect, FALSE);

        draw_3d (vdi_handle, rect.x - 1, rect.y - 1, 1, rect.w + 2, rect.h + 2, sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNFACE], FALSE);
        draw_3d (vdi_handle, rect.x, rect.y, 1, rect.w, rect.h, BLACK, sys_colors [COLOR_BTNFACE], sys_colors [COLOR_BTNSHADOW], FALSE);
      } /* if */
    } while (! is_flags (tree, obj++, LASTOB));

    show_mouse ();
  } /* if */
} /* draw_3d_dlg */

/*****************************************************************************/
/* Rechteck-Routinen                                                         */
/*****************************************************************************/

GLOBAL VOID scroll_area (area, dir, delta)
CONST RECT *area;
WORD       dir, delta;

{
  MFDB  s, d;
  WORD  xy [8];
  RECT  dst;

  wind_update (BEG_UPDATE);             /* Benutzer darf nicht mehr agieren */
  hide_mouse ();                        /* Maus verstecken, da gescrollt wird */

  s.mp = d.mp = NULL;                   /* Erzwinge Bildschirmadresse */

  rect2array (area, xy);
  rect2array (area, &xy [4]);

  if (dir & HORIZONTAL)                 /* Horizontales Scrolling */
  {
    xy [4] -= delta;
    xy [6] -= delta;
  } /* else */
  else                                  /* Vertikales Scrolling */
  {
    xy [5] -= delta;
    xy [7] -= delta;
  } /* if */

  array2rect (&xy [4], &dst);           /* Nur Zielraster zeichnen */

  if (rc_intersect (&desk, &dst))
  {
    set_clip (TRUE, &dst);              /* Setze Clipping auf Schirm */
    vro_cpyfm (vdi_handle, S_ONLY, xy, &s, &d); /* Eigentliches Scrolling */
  } /* if */

  show_mouse ();                        /* Zeige Maus wieder */
  wind_update (END_UPDATE);             /* Benutzer darf wieder agieren */
} /* scroll_area */

/*****************************************************************************/
/* Zwei Rechtecke auf Gleichheit testen																			*/

GLOBAL BOOLEAN rc_equal (p1, p2)
CONST RECT *p1, *p2;

{
  return ((p1->x == p2->x) && (p1->y == p2->y) &&
          (p1->w == p2->w) && (p1->h == p2->h));
} /* rc_equal */

/*****************************************************************************/

GLOBAL VOID rc_copy (ps, pd)
CONST RECT *ps;
RECT       *pd;

{
#if ANSI
  *pd = *ps;
#else
  pd->x = ps->x;
  pd->y = ps->y;
  pd->w = ps->w;
  pd->h = ps->h;
#endif
} /* rc_copy */

/*****************************************************************************/
/* Zwei Rechtecke werden vereinigt																					 */
/* Ergebnis steht in p2                  																		 */

GLOBAL VOID rc_union (p1, p2)
CONST RECT *p1;
RECT       *p2;

{
  RECT r;

  if ((p2->w == 0) || (p2->h == 0))
    *p2 = *p1;
  else
  {
    r.x = min (p1->x, p2->x);
    r.y = min (p1->y, p2->y);
    r.w = max (p1->x + p1->w, p2->x + p2->w) - r.x;
    r.h = max (p1->y + p1->h, p2->y + p2->h) - r.y;

    *p2 = r;
  } /* else */
} /* rc_union */

/*****************************************************************************/
/* Zwei Rechtecke werden geschnitten																				 */
/* Ergebnis steht in p2                  																		 */
/* RÅckgabe: TRUE, wenn Schnittrechteck nicht leer ist, sonst FALSE					 */

GLOBAL BOOLEAN rc_intersect (p1, p2)
CONST RECT *p1;
RECT       *p2;

{
  REG WORD tx, ty, tw, th;

  tw = min (p2->x + p2->w, p1->x + p1->w);
  th = min (p2->y + p2->h, p1->y + p1->h);
  tx = max (p2->x, p1->x);
  ty = max (p2->y, p1->y);

  p2->x = tx;
  p2->y = ty;
  p2->w = tw - tx;
  p2->h = th - ty;

  return ((tw > tx) && (th > ty));
} /* rc_intersect */

/*****************************************************************************/

GLOBAL VOID rc_inflate (rect, x, y)
RECT *rect;
WORD x, y;

{
  rect->x -= x;
  rect->y -= y;
  rect->w += 2 * x;
  rect->h += 2 * y;
} /* rc_inflate */

/*****************************************************************************/
/* Testet, ob ein Punkt in einem Rechteck liegt                      				 */

GLOBAL BOOLEAN inside (x, y, r)
WORD       x, y;
CONST RECT *r;

{
  return ((x >= r->x) && (y >= r->y) && (x < r->x + r->w) && (y < r->y + r->h));
} /* inside */

/*****************************************************************************/

GLOBAL VOID rect2array (rect, array)
CONST RECT *rect;
WORD       *array;

{
  *array++ = rect->x;
  *array++ = rect->y;
  *array++ = rect->x + rect->w - 1;
  *array   = rect->y + rect->h - 1;
} /* rect2array */

/*****************************************************************************/

GLOBAL VOID array2rect (array, rect)
CONST WORD *array;
RECT       *rect;

{
  rect->x = min (array [0], array [2]);
  rect->y = min (array [1], array [3]);
  rect->w = max (array [0], array [2]) - rect->x + 1;
  rect->h = max (array [1], array [3]) - rect->y + 1;
} /* array2rect */

/*****************************************************************************/

GLOBAL VOID xywh2array  (x, y, w, h, array)
WORD x, y, w, h;
WORD *array;

{
  *array++ = x;
  *array++ = y;
  *array++ = x + w - 1;
  *array   = y + h - 1;
} /* xywh2array */

/*****************************************************************************/

GLOBAL VOID array2xywh  (array, x, y, w, h)
CONST WORD *array;
WORD       *x, *y, *w, *h;

{
  *x = *array++;
  *y = *array++;
  *w = *array++ - *x + 1;
  *h = *array - *y + 1;
} /* array2xywh */

/*****************************************************************************/

GLOBAL VOID xywh2rect (x, y, w, h, rect)
WORD x, y, w, h;
RECT *rect;

{
  rect->x = x;
  rect->y = y;
  rect->w = w;
  rect->h = h;
} /* xywh2rect */

/*****************************************************************************/

GLOBAL VOID rect2xywh (rect, x, y, w, h)
CONST RECT *rect;
WORD       *x, *y, *w, *h;

{
  *x = rect->x;
  *y = rect->y;
  *w = rect->w;
  *h = rect->h;
} /* rect2xywh */

/*****************************************************************************/

GLOBAL VOID set_clip (clipflag, size)
BOOLEAN     clipflag;
CONST RECT *size;

{
  RECT r;
  WORD xy [4];

  r    = (size == NULL) ? desk : *size;
  clip = r;                             /* Rette aktuelle Werte */

  if (rc_intersect (&desk, &r))         /* Nur auf Desktop zeichnen */
    rect2array (&r, xy);
  else
    xywh2array (0, 0, 0, 0, xy);        /* Nichts zeichnen */

  vs_clip (vdi_handle, clipflag, xy);   /* Setze Rechteckausschnitt */
} /* set_clip */

/*****************************************************************************/

#if GEM & (GEM2 | GEM3 | XGEM)
LOCAL VOID graf_growbox (orgx, orgy, orgw, orgh, x, y, w, h)
WORD orgx, orgy, orgw, orgh;
WORD x, y, w, h;

{
  WORD  cx, cy, cnt, xstep, ystep;

  xgrf_stepcalc (orgw, orgh, x, y, w, h, &cx, &cy, &cnt, &xstep, &ystep);
  graf_mbox (orgw, orgh, orgx, orgy, cx, cy);
  xgrf_2box (cx, cy, orgw, orgh, TRUE, cnt, xstep, ystep, TRUE);
} /* graf_growbox */

/*****************************************************************************/

LOCAL VOID graf_shrinkbox (orgx, orgy, orgw, orgh, x, y, w, h)
WORD orgx, orgy, orgw, orgh;
WORD x, y, w, h;

{
  WORD cx, cy, cnt, xstep, ystep;

  xgrf_stepcalc (orgw, orgh, x, y, w, h, &cx, &cy, &cnt, &xstep, &ystep);
  xgrf_2box (x, y, w, h, TRUE, cnt, -xstep, -ystep, TRUE);
  graf_mbox (orgw, orgh, cx, cy, orgx, orgy);
} /* graf_shrinkbox */
#endif

/*****************************************************************************/

LOCAL VOID lv_opnwk (WORD *work_in, WORD *handle, WORD *work_out)
{
  WORD i;

  contrl [0] = 1;															/* Funktionsnummer */
  contrl [1] = 0;
  contrl [3] = 16;
  contrl [4] = 0;															/* fÅr spÑteren Test lîschen */
  contrl [5] = 27;
  contrl [6] = 0;

  for (i = 0; i < 16; i++)
    intin [i] = work_in [i];

  vdi ();

  for (i = 0; i < 45; i++)
    work_out [i] = intout [i];

  for (i = 45; i < 57; i++)
    work_out [i] = ptsout [i];

  *handle = contrl [6];
} /* lv_opnwk */

/*****************************************************************************/

LOCAL WORD lvq_ext_devinfo (WORD handle, WORD device, WORD *dev_exists, BYTE *file_path, BYTE *file_name, BYTE *name)
{
  contrl [0] = 248;															/* Funktionsnummer */
  contrl [1] = 0;
  contrl [3] = 7;
  contrl [4] = 0;															/* fÅr spÑteren Test lîschen */
  contrl [5] = 4242;
  contrl [6] = handle;

  intin [0]           = device;
  *(BYTE **)&intin[1] = file_path;
  *(BYTE **)&intin[3] = file_name;
  *(BYTE **)&intin[5] = name;

  vdi ();

  *dev_exists = intout [0];
  return (intout [1]);
} /* lvq_ext_devinfo */

/*****************************************************************************/

GLOBAL VOID growbox (st, fin)
CONST RECT *st, *fin;

{
  RECT r;

  if (grow_shrink)
  {
    r = *st;

    if ((r.x == 0) && (r.y == 0))
    {
      r.x = fin->x + fin->w / 2;
      r.y = fin->y + fin->h / 2;
    } /* if */

    graf_growbox (r.x, r.y, r.w, r.h, fin->x, fin->y, fin->w, fin->h);
  } /* if */
} /* growbox */

/*****************************************************************************/

GLOBAL VOID shrinkbox (fin, st)
CONST RECT *fin, *st;

{
  RECT r;

  if (grow_shrink && ! acc_close)
  {
    r = *fin;

    if ((r.x == 0) && (r.y == 0))
    {
      r.x = st->x + st->w / 2;
      r.y = st->y + st->h / 2;
    } /* if */

    graf_shrinkbox (r.x, r.y, r.w, r.h, st->x, st->y, st->w, st->h);
  } /* if */
} /* shrinkbox */

/*****************************************************************************/
/* Fehlerbehandlung                                                          */
/*****************************************************************************/

GLOBAL VOID beep ()

{
  if (ring_bell)
  {
#if GEM & (GEM2 | GEM3 | XGEM)
    v_sound (phys_handle, 550, 3);
#else
#if GEMDOS
    Bconout (2, BEL);
#endif
#endif
  } /* if */
} /* beep */

/*****************************************************************************/

GLOBAL WORD note (button, index, helpinx, helptree)
WORD   button, index, helpinx;
OBJECT *helptree;

{
  WORD    ret;
  BOOLEAN ok;

  set_mouse (ARROW, NULL);

  if (alertmsg == NULL)
    ret = 0;
  else
    do
    {
      ret = form_alert (button, alertmsg [index]);

      if ((ret == helpinx) && (helptree != NULL)) hndl_dial (helptree, 0, FALSE, TRUE, NULL, &ok);
    } while (ret == helpinx);

  last_mouse ();
  return (ret);
} /* note */

/*****************************************************************************/

GLOBAL WORD error (button, index, helpinx, helptree)
WORD   button, index, helpinx;
OBJECT *helptree;

{
  beep ();
  return (note (button, index, helpinx, helptree));
} /* error */

/*****************************************************************************/
/* Mengen-Routinen                                                           */
/*****************************************************************************/

GLOBAL VOID setcpy (set1, set2)
SET set1, set2;

{
  mem_move (set1, set2, SETSIZE * sizeof (ULONG));
} /* setcpy */

/*****************************************************************************/

GLOBAL VOID setall (set)
SET set;

{
  mem_set (set, 0xFF, SETSIZE * sizeof (ULONG));
} /* setall */

/*****************************************************************************/

GLOBAL VOID setclr (set)
SET set;

{
  mem_set (set, 0x00, SETSIZE * sizeof (ULONG));
} /* setclr */

/*****************************************************************************/

GLOBAL VOID setnot (set)
SET set;

{
  REG WORD i;

  for (i = 0; i < SETSIZE; i++) set [i] = ~ set [i];
} /* setnot */

/*****************************************************************************/

GLOBAL VOID setand (set1, set2)
SET set1, set2;

{
  REG WORD i;

  for (i = 0; i < SETSIZE; i++) set1 [i] &= set2 [i];
} /* setand */

/*****************************************************************************/

GLOBAL VOID setor (set1, set2)
SET set1, set2;

{
  REG WORD i;

  for(i = 0; i < SETSIZE; i++) set1 [i] |= set2 [i];
} /* setor */

/*****************************************************************************/

GLOBAL VOID setxor (set1, set2)
SET set1, set2;

{
  REG WORD i;

  for (i = 0; i < SETSIZE; i++) set1 [i] ^= set2 [i];
} /* setxor */

/*****************************************************************************/

GLOBAL VOID setincl (set, elt)
SET  set;
WORD elt;

{
  if ((0 <= elt) && (elt <= SETMAX)) set [elt / 32] |= (1L << (elt % 32));
} /* setincl */

/*****************************************************************************/

GLOBAL VOID setexcl (set, elt)
SET  set;
WORD elt;

{
  if ((0 <= elt) && (elt <= SETMAX)) set [elt / 32] &= (~ (1L << (elt % 32)));
} /* setexcl */

/*****************************************************************************/

GLOBAL BOOLEAN setin (set, elt)
SET  set;
WORD elt;

{
  if ((0 <= elt) && (elt <= SETMAX))
    return ((set [elt / 32] & (1L << (elt % 32))) ? TRUE : FALSE);
  else
    return (FALSE);
} /* setin */

/*****************************************************************************/

GLOBAL BOOLEAN setcmp (set1, set2)
SET set1, set2;

{
  REG WORD    i;
  REG BOOLEAN res;

  for (res = TRUE, i = 0; res && (i < SETSIZE); i++)
    res = (set2 != NULL ? set1 [i] == set2 [i] : set1 [i] == 0);

  return (res);
} /* setcmp */

/*****************************************************************************/

GLOBAL WORD setcard (set)
SET set;

{
  REG WORD i, j, card;
  REG ULONG l;

  for (i = card = 0; i < SETSIZE; i++)
    for (j = 0, l = set [i]; j < 32; j++)
    {
      if (l & 1) card++;
      l >>= 1;
    } /* for, for */

  return (card);
} /* setcard */

/*****************************************************************************/

GLOBAL BOOLEAN select_file (name, path, suffix, label, filename)
BYTE *name, *path, *suffix, *label, *filename;

{
  BYTE    *p;
  LONGSTR s;

#if GEMDOS
  WORD tos;
  LONG stack;

  stack = Super (NULL);
  tos   = *(UWORD *)(*(LONG *)0x4F2 + 0x02); /* Hole TOS-Version */

  Super ((VOID *)stack);
#endif

  if ((path != NULL) && (*path))        /* Pfad Ñndern */
    strcpy (fs_path, path);

  if (suffix != NULL)                   /* Suffix Ñndern */
  {
    p = strrchr (fs_path, PATHSEP);
    if (p != NULL) p [1] = EOS;         /* Suffix lîschen */
    strcat (fs_path, suffix);
  } /* if */

  if ((name != NULL) && ! use_lfn)      /* Name Ñndern */
  {
    strncpy (fs_sel, name, 12);         /* Default-Name */
    fs_sel [12] = EOS;
  } /* if */

  set_mouse (ARROW, NULL);

#if GEMDOS
  if (tos >= 0x0104)
    fsel_exinput (fs_path, fs_sel, &fs_button, label);
  else
    fsel_input (fs_path, fs_sel, &fs_button);
#else
  fsel_exinput (fs_path, fs_sel, &fs_button, label);
#endif

  last_mouse ();

  strcpy (s, fs_path);                  /* Path aufbereiten */
  p = strrchr (s, PATHSEP);
  if (p != NULL) p [1] = EOS;

  if (*fs_sel)                          /* Dateinamen gewÑhlt */
  {
    strcpy (filename, s);
    strcat (filename, fs_sel);
  } /* if */
  else
    filename [0] = EOS;                 /* Keinen Dateinamen gewÑhlt */

  if (fs_button != 0)
  {
    if ((path != NULL) && (*path))      /* Pfad Ñndern */
      strcpy (path, fs_path);

    if ((name != NULL) && (*name) && (*fs_sel)) /* Name Ñndern */
      strcpy (name, fs_sel);
  } /* if */

  return (*fs_sel && (fs_button != 0)); /* Dateiname und OK gewÑhlt */
} /* select_file */

/*****************************************************************************/
/* Inf-Datei Funtionen                                                       */
/*****************************************************************************/

GLOBAL BYTE *ReadInfFile (BYTE *pFileName)
{
  BYTE  *pszInf;
  BOOL  bOk;
  HFILE hFile;
  LONG  lLength;

  bOk     = FALSE;
  lLength = file_length (pFileName);

  if ((pszInf = mem_alloc (lLength + 1)) != NULL)
    if ((hFile = file_open (pFileName, O_RDONLY)) >= 0)
    {
      if (file_read (hFile, lLength, pszInf) == lLength)
      {
        bOk              = TRUE;
        pszInf [lLength] = EOS;
      } /* if */

      file_close (hFile);
    } /* if, if */

  if (! bOk)
  {
    if (pszInf != NULL) mem_free (pszInf);
    pszInf = NULL;
  } /* if */

  return (pszInf);
} /* ReadInfFile */

/*****************************************************************************/

GLOBAL BYTE *FindSection (BYTE *pszInf, BYTE *pszSection)
{
  BYTE    *p;
  LONGSTR sz;

  if (pszInf == NULL)
   return (NULL);

  sprintf (sz, "[%s]", pszSection);

  p = strstr (pszInf, sz);

  if (p == NULL)
  {
    str_upper (sz);
    p = strstr (pszInf, sz);
  } /* if */

  if (p == NULL)
  {
    str_lower (sz);
    p = strstr (pszInf, sz);
  } /* if */

  if (p != NULL)
  {
    while ((*p != '\n') && (*p != EOS)) p++;
    if (*p != EOS) p++;
  } /* if */

  return (p);
} /* FindSection */

/*****************************************************************************/

GLOBAL BYTE *GetKeyVal (BYTE *pszInf, BYTE *pszSection, BYTE *pszKey, BYTE *pszKeyVal, INT iKeySize)
{
  *pszKeyVal = EOS;

  if ((pszInf = FindKey (pszInf, pszSection, pszKey)) != NULL)
    pszInf = CopyKeyVal (pszInf, pszKeyVal, iKeySize);

  return (pszInf);
} /* GetKeyVal */

/*****************************************************************************/

GLOBAL BYTE *GetNextLine (BYTE *pszInf, BYTE *pszLine, INT iLineSize)
{
  INT  i;
  BYTE *p;

  p  = pszLine;
  *p = EOS;

  if ((pszInf == NULL) || (*pszInf == EOS)) return (NULL);

  for (i = 0; (i < iLineSize - 1) && (*pszInf != '\r') && (*pszInf != '\n') && (*pszInf != EOS); i++)
  {
    if ((i == 0) && (*pszInf == '['))
      return (NULL);

    *p++ = *pszInf++;
  } /* for */

  *p = EOS;

  while ((*pszInf != '\n') && (*pszInf != EOS)) pszInf++;
  if (*pszInf != EOS) pszInf++;

  if (pszLine [0] == CHAR_COMMENT)
    pszLine [0] = EOS;

  return (pszInf);
} /* GetNextLine */

/*****************************************************************************/

GLOBAL BYTE *FindKey (BYTE *pszInf, BYTE *pszSection, BYTE *pszKey)
{
  LONGSTR sz;
  BYTE    *p, *q;

  if ((pszInf = FindSection (pszInf, pszSection)) != NULL)
    while ((pszInf = GetNextLine (p = pszInf, sz, sizeof (sz))) != NULL)
      if (sz [0] != EOS)
        if ((q = strchr (sz, '=')) != NULL)
        {
          *q = EOS;

          if (strcmpi (sz, pszKey) == 0)
            return (strchr (p, '=') + 1);
        } /* if, if, while, if */

  return (NULL);
} /* FindKey */

/*****************************************************************************/

GLOBAL BYTE *CopyKeyVal (BYTE *pszKey, BYTE *pszKeyVal, INT iKeySize)
{
  INT i;

  for (i = 0; (i < iKeySize - 1) && (*pszKey != '\r') && (*pszKey != '\n'); i++)
    *pszKeyVal++ = *pszKey++;

  *pszKeyVal = EOS;

  while ((*pszKey != '\n') && (*pszKey != EOS)) pszKey++;
  if (*pszKey != EOS) pszKey++;

  return (pszKey);
} /* CopyKeyVal */

/*****************************************************************************/

GLOBAL BYTE *GetString (BYTE *psz, BYTE *pszString)
{
  *pszString = EOS;

  if ((psz == NULL) || (*psz == EOS)) return (NULL);

  while (*psz == SP) psz++;
  while ((*psz != '"') && (*psz != EOS)) psz++;

  if (*psz != EOS) psz++;

  while ((*psz != '"') && (*psz != EOS)) *pszString++ = *psz++;

  *pszString = EOS;

  if (*psz != EOS) psz++;

  while (*psz == SP) psz++;
  while ((*psz != ',') && (*psz != EOS)) psz++;

  if (*psz != EOS) psz++;

  return (psz);
} /* GetString */

/*****************************************************************************/

GLOBAL BYTE *GetText (BYTE *psz, BYTE *pszText)
{
  INT chSep;

  *pszText = EOS;

  if ((psz == NULL) || (*psz == EOS)) return (NULL);
  while (*psz == SP) psz++;

  chSep = (*psz == '"') ? '"' : ',';

  if (chSep == '"') psz++;

  while ((*psz != chSep) && (*psz != EOS)) *pszText++ = *psz++;

  *pszText = EOS;

  if (*psz != EOS)
  {
    psz++;

    if (chSep == '"')
    {
      while (*psz == SP) psz++;
      while ((*psz != ',') && (*psz != EOS)) psz++;
      if (*psz != EOS) psz++;
    } /* if */
  } /* if */

  return (psz);
} /* GetText */

/*****************************************************************************/

GLOBAL BOOLEAN GetProfileBool (BYTE *pszInf, BYTE *pszSection, BYTE *pszKey, BOOLEAN bDefault)
{
  LONGSTR s;

  if ((pszInf = FindKey (pszInf, pszSection, pszKey)) != NULL)
  {
    CopyKeyVal (pszInf, s, sizeof (s));
    bDefault = FALSE;

    if (s [0] != EOS)
      bDefault = atoi (s);
  } /* if */

  return (bDefault);
} /* GetProfileBool */

/*****************************************************************************/

GLOBAL WORD GetProfileWord (BYTE *pszInf, BYTE *pszSection, BYTE *pszKey, WORD wDefault)
{
  LONGSTR s;

  if ((pszInf = FindKey (pszInf, pszSection, pszKey)) != NULL)
  {
    CopyKeyVal (pszInf, s, sizeof (s));
    wDefault = 0;

    if (s [0] != EOS)
      wDefault = atoi (s);
  } /* if */

  return (wDefault);
} /* GetProfileWord */

/*****************************************************************************/

GLOBAL LONG GetProfileLong (BYTE *pszInf, BYTE *pszSection, BYTE *pszKey, LONG lDefault)
{
  LONGSTR s;

  if ((pszInf = FindKey (pszInf, pszSection, pszKey)) != NULL)
  {
    CopyKeyVal (pszInf, s, sizeof (s));
    lDefault = 0;

    if (s [0] != EOS)
      lDefault = atol (s);
  } /* if */

  return (lDefault);
} /* GetProfileLong */

/*****************************************************************************/

GLOBAL BYTE *GetProfileString (BYTE *pszInf, BYTE *pszSection, BYTE *pszKey, BYTE *pszDefault, BYTE *pszBuffer)
{
  if ((pszInf = FindKey (pszInf, pszSection, pszKey)) != NULL)
    CopyKeyVal (pszInf, pszBuffer, sizeof (LONGSTR));
  else
    strcpy (pszBuffer, pszDefault);

  return (pszBuffer);
} /* GetProfileString */

/*****************************************************************************/

GLOBAL VOID RemLeadSP (BYTE *pString)
{
  REG CHAR *p;

  for (p = pString; (*p != EOS) && isspace (*p); p++);
  while (*p != EOS) *pString++ = *p++;
  *pString = EOS;
} /* RemLeadSP */

/*****************************************************************************/

GLOBAL VOID RemTrailSP (BYTE *pString)
{
  REG CHAR *p;
  REG LONG l;

  for (p = pString, l = 0; *p != EOS; p++, l++);
  l--;
  while ((l >= 0) && isspace (pString [l])) l--;
  pString [l + 1] = EOS;
} /* RemTrailSP */

/* [GS] 5.1c alt: nach clipbrd.c verschoben 
/*****************************************************************************/

GLOBAL WORD ClipboardGetMode (VOID)
{
  return (clip_mode);
} /* ClipboardGetMode */

/*****************************************************************************/

GLOBAL WORD ClipboardSetMode (WORD wMode)
{
  WORD old_mode;

  old_mode  = clip_mode;
  clip_mode = wMode;

  return (old_mode);
} /* ClipboardSetMode */

/*****************************************************************************/

GLOBAL VOID ClipboardGetName (BYTE *pszFileName)
{
  strcpy (pszFileName, clip_filename);
} /* ClipboardGetName */

/*****************************************************************************/

GLOBAL VOID ClipboardSetName (BYTE *pszFileName)
{
  strcpy (clip_filename, pszFileName);
} /* ClipboardSetName */

/*****************************************************************************/

GLOBAL LONG ClipboardGetSize (WORD wFormat)
{
  return (clip_size [wFormat]);
} /* ClipboardGetSize */

/*****************************************************************************/

GLOBAL VOID ClipboardSetSize (WORD wFormat, LONG lSize)
{
  clip_size [wFormat] = lSize;
} /* ClipboardSetSize */

/*****************************************************************************/

GLOBAL VOID *ClipboardGetData (WORD wFormat)
{
  return (clip_data [wFormat]);
} /* ClipboardGetData */

/*****************************************************************************/

GLOBAL VOID ClipboardSetData (WORD wFormat, VOID *pData)
{
  mem_free (clip_data [wFormat]);
  clip_data [wFormat] = pData;
} /* ClipboardSetMode */

/*****************************************************************************/

GLOBAL VOID ClipboardEmpty (VOID)
{
  WORD i;

  for (i = 0; i < CF_FORMATS; i++)
  {
    mem_free (clip_data [i]);
    clip_data [i] = NULL;
    clip_size [i] = 0;
  } /* for */
} /* ClipboardEmpty */

*/

/*****************************************************************************/

GLOBAL VOID OlgaLink (BYTE *pszFileName, WORD wLink)
{
  WORD msg [8];
  LONG *p;

  if (olga_apid >= 0)
  {
  	strcpy ( global_mem1, pszFileName );

    p = (LONG *)(msg + 3);

    msg [0] = OLGA_LINK;
    msg [1] = gl_apid;
    msg [2] = 0;
    *p      = (LONG)global_mem1;
    msg [5] = wLink;
    msg [6] = 0;
    msg [7] = 0;

    appl_write (olga_apid, sizeof (msg), msg);
  } /* if */
} /* OlgaLink */

/*****************************************************************************/

GLOBAL VOID OlgaUnlink (BYTE *pszFileName, WORD wLink)
{
  WORD msg [8];
  LONG *p;

  if (olga_apid >= 0)
  {
  	strcpy ( global_mem1, pszFileName );

    p = (LONG *)(msg + 3);

    msg [0] = OLGA_UNLINK;
    msg [1] = gl_apid;
    msg [2] = 0;
    *p      = (LONG)global_mem1;
    msg [5] = wLink;
    msg [6] = 0;
    msg [7] = 0;

    appl_write (olga_apid, sizeof (msg), msg);
  } /* if */
} /* OlgaUnlink */

/*****************************************************************************/

GLOBAL VOID OlgaLinkRenamed (BYTE *pszOldName, BYTE *pszNewName, WORD wLink)
{
  WORD msg [8];
  LONG *p, *q;

  if (olga_apid >= 0)
  {
  	strcpy ( global_mem1, pszOldName );
  	strcpy ( global_mem2, pszNewName );
    p = (LONG *)(msg + 3);
    q = (LONG *)(msg + 5);

    msg [0] = OLGA_LINKRENAMED;
    msg [1] = gl_apid;
    msg [2] = 0;
    *p      = (LONG)global_mem1;
    *q      = (LONG)global_mem2;
    msg [7] = wLink;

    appl_write (olga_apid, sizeof (msg), msg);
  } /* if */
} /* OlgaLinkRenamed */

/*****************************************************************************/

GLOBAL VOID OlgaStartExt (BYTE *pszExtension, BYTE *pszFileName)
{
  WORD msg [8];
  BYTE *p;
  LONG *q;

  if (olga_apid >= 0)
  {
  	strcpy ( global_mem1, pszFileName );

    p = (BYTE *)(msg + 4);
    q = (LONG *)(msg + 6);

    msg [0] = OLGA_START;
    msg [1] = gl_apid;
    msg [2] = 0;
    msg [3] = OLS_EXTENSION;

    memset (p, 0, 4);
    strncpy (p, pszExtension, 4);
    *q      = (LONG)global_mem1;

    appl_write (olga_apid, sizeof (msg), msg);
  } /* if */
} /* OlgaStartExt */

/*****************************************************************************/

GLOBAL BYTE *NameFromDevice (BYTE *pszDeviceName, WORD wDevice)
{
  WORD     dev_exists;
  FULLNAME file_path;
  FILENAME file_name;

  lvq_ext_devinfo (vdi_handle, wDevice, &dev_exists, file_path, file_name, pszDeviceName);

  if (! dev_exists)
    *pszDeviceName = EOS;

  return (pszDeviceName);
} /* NameFromDevice */

/*****************************************************************************/

GLOBAL WORD DeviceFromName (BYTE *pszDeviceName)
{
  WORD     wDevice, dev_exists;
  FULLNAME file_path;
  FILENAME file_name;
  LONGSTR  name;

  for (wDevice = PLOTTER; wDevice < 100; wDevice++)
  {
    lvq_ext_devinfo (vdi_handle, wDevice, &dev_exists, file_path, file_name, name);

    if (dev_exists)
      if (strcmpi (name, pszDeviceName) == 0)
        return (wDevice);
  } /* for */

  return (FAILURE);
} /* DeviceFromName */

/*****************************************************************************/

#if GEM & GEM1

GLOBAL WORD v_orient (WORD vdi_handle, WORD orientation)
{
  intin [0] = orientation;												/* Ausrichtung */

  contrl [0] = 5;															/* Funktionsnummer */
  contrl [1] = 0;
  contrl [3] = 1;
  contrl [4] = 0;															/* fÅr spÑteren Test lîschen */
  contrl [5] = 27;
  contrl [6] = vdi_handle;

  vdi ();

  if (contrl [4] == 1)
    return (intout[0]);
  else
   return (0);
} /* v_orient */

#endif

/* [GS] 5.1f Start */
/*****************************************************************************/

#if GEM & GEM1

GLOBAL WORD vqt_ext_name( WORD vdi_handle, WORD index, BYTE *name,
				                  WORD *font_format, WORD *flags )
{
  intin [0] = index;
  intin [1] = 0;															/* reserviert      */

  contrl [0] = 130;														/* Funktionsnummer */
  contrl [1] = 0;
  contrl [3] = 2;
  contrl [4] = 0;															/* fÅr spÑteren Test lîschen */
  contrl [5] = 1;
  contrl [6] = vdi_handle;

  vdi ();

	/* Die Werte zurÅckgeben */

	if( name!=NULL )
	{
		WORD *i_ptr;
		BYTE *c_ptr;
		WORD i, anz;
		
		anz = (contrl[4]<33 ? contrl[4] : 33);
		for( i=0, i_ptr=&intout[1], c_ptr=name ; i<anz ; i_ptr++, c_ptr++, i++ )
			*c_ptr=(char)*i_ptr;
		for( ; i<33 ; c_ptr++, i++ )
			*c_ptr = 0;
	}
	
	/* Ggf. die erweiterten Parameter liefern */
	if( font_format!=NULL )
	{
		if( contrl[4]>34 )
		{
			/* Die Angabe wird von NVDI geliefert */
			*font_format = intout[34] & 0x00FF;
		}
		else if( contrl[4]>33 )
		{
			/* Es ist irgendein Vektor-Font */
			*font_format = (intout[33]&0x0001 ? 0x0000 : 0x0001);
		}
		else
		{
			/* Es ist ein Bitmap-Font */
			*font_format = 0x0001;
		}
	}
	if( flags!=NULL )
	{
		if( contrl[4]>34 )
			*flags = (intout[34] >> 8) & 0x00FF;
		else
			*flags = 0x0001;
	}
	
	return intout[0];
} /* vqt_ext_name */

#endif
/* Ende */

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_global (argc, argv, acc_menu, class)
INT  argc;
BYTE *argv [];
BYTE *acc_menu;
WORD class;

{
  WORD     i;
  BYTE     *p;
  BOOLEAN  ok;
  WORD     char_width, char_height, cell_width, cell_height, rgb [3];
  WORD     work_out [57];
  FULLNAME s;
#if GEM & (GEM2 | GEM3 | XGEM)
  WORD     max_colors;
#endif
#if GEMDOS
  LONG     drives;
  WORD     drive;
  BOOLEAN  ready;
  LONG     err;
#endif

  i = appl_init ();                       /* Applikationsnummer besorgen */

#if (LATTICE_C | TURBO_C) | (GEM & (GEM2 | GEM3 | XGEM))
  gl_apid = i;                            /* gl_apid nicht extern */
#endif

  if (gl_apid < 0) return (FALSE);

  phys_handle = graf_handle (&gl_wbox, &gl_hbox, &gl_wattr, &gl_hattr); /* Handle des Bildschirms */
  vdi_handle  = phys_handle;              /* Benutze physikalischen Bildschirm */

  open_vwork ();                          /* Workstation îffnen */

  vst_font (vdi_handle, FONT_SYSTEM);

  for (gl_point = 8; gl_point <= 10; gl_point++)
  {
    vst_point (vdi_handle, gl_point, &char_width, &char_height, &cell_width, &cell_height);
    if (cell_height == gl_hbox) break;    /* Punktgrîûe des System Fonts */
  } /* for */

#if GEM & (GEM2 | GEM3 | XGEM)            /* wegen TT */
  max_colors = min (colors, MAX_COLORS);

  if (colors > 2)                         /* nicht b/w */
    for (i = 0; i < max_colors; i++)      /* GEM-Farben festlegen */
    {
      rgb [0] = gem_colors [i].red;
      rgb [1] = gem_colors [i].green;
      rgb [2] = gem_colors [i].blue;

      vs_color (vdi_handle, i, rgb);
    } /* for, if */
#endif

  if (colors == 256)
  {
    rgb [0] = gem_colors [WHITE].red;
    rgb [1] = gem_colors [WHITE].green;
    rgb [2] = gem_colors [WHITE].blue;
    vs_color (vdi_handle, 254, rgb);

    rgb [0] = gem_colors [BLACK].red;
    rgb [1] = gem_colors [BLACK].green;
    rgb [2] = gem_colors [BLACK].blue;
    vs_color (vdi_handle, 255, rgb);
  } /* if */

  vq_extnd (vdi_handle, TRUE, work_out);  /* Hole Anzahl Planes */

  planes                           = work_out [4];
  dlg_colors                       = colors;
  sys_colors [COLOR_HIGHLIGHT]     = DBLUE;
  sys_colors [COLOR_HIGHLIGHTTEXT] = WHITE;
  sys_colors [COLOR_DISABLED]      = DGRAY;
  sys_colors [COLOR_BTNFACE]       = GRAY;
  sys_colors [COLOR_BTNHIGHLIGHT]  = WHITE;
  sys_colors [COLOR_BTNSHADOW]     = DGRAY;
  sys_colors [COLOR_BTNTEXT]       = BLACK;
  sys_colors [COLOR_SCROLLBAR]     = DGRAY;
  sys_colors [COLOR_DIALOG]        = GRAY;
  font_btntext                     = (gl_hbox > 8) ? FONT_CHICAGO : FONT_SYSTEM;
  point_btntext                    = gl_point;
  effects_btntext                  = TXT_NORMAL;
  use_3d                           = TRUE;
  dlg_round_borders                = TRUE;
  use_std_fs                       = FALSE;
  dlg_checkbox                     = 0;
  dlg_radiobutton                  = 0;
  dlg_arrow                        = 0;
  btn_round_borders                = FALSE;
  btn_shadow_width                 = 1;
  color_desktop                    = (colors == 2) ? BLACK : DGREEN;
  pattern_desktop                  = (colors == 2) ? 4 : 7;
  use_lfn                          = FALSE;

#if GEMDOS
  err     = Dpathconf ("C:\\", 3);
  use_lfn = (err != -32) && (Dpathconf ("C:\\", 5) != 2);

  Pdomain (1);
#endif

  wind_get (DESK, WF_WXYWH, &desk.x, &desk.y, &desk.w, &desk.h);        /* Grîûe des Desktop */

  busy          = 0;                      /* Maus ist nicht geschÑftig */
  mousenumber   = ARROW;                  /* Aktuelle Mausform-Nummer */
  mouseform     = NULL;                   /* Aktuelle Mausform */
  done          = FALSE;                  /* "Ende" wurde nicht gewÑhlt */
  ring_bell     = TRUE;                   /* Glocke eingeschaltet */
  grow_shrink   = TRUE;                   /* Grow/Shrink-Modus eingeschaltet */
  blinkrate     = DEFAULTRATE;            /* Anfangsblinkrate */
/* [GS] 5.2 Start */
	TabSize				= 2;											/* Tabulatorweite */
/* End */
  updtmenu      = TRUE;                   /* MenÅs immer auf neuen Stand bringen */
  cmd [0]       = EOS;                    /* Kein Kommando */
  tail [0]      = EOS;                    /* Keine Kommandozeile */
  called_by [0] = EOS;                    /* Eventuell kein aufrufendes Programm */
  menu          = NULL;                   /* Noch keine MenÅzeile */
  about         = NULL;                   /* Noch keine About-Box */
  desktop       = NULL;                   /* Noch kein eigener Desktop */
  freetext      = NULL;                   /* Noch keine freien Texte */
  alertmsg      = NULL;                   /* Noch keine Fehlermeldungen */

  act_drv = get_drive ();                 /* Aktuelles Laufwerk holen */
  get_path (act_path);                    /* Aktuellen Pfad holen */

#if FLEXOS
  str_upper (act_path);                   /* Aktueller Pfad nicht immer groû */
#endif

  strcpy (fs_path, act_path);             /* Standard-Zugriffspfad */
  p     = strchr (fs_path, PATHSEP);
  p [1] = EOS;                            /* Auf Root kÅrzen */
  strcat (fs_path, "*.*");                /* Alle Dateien */
  fs_sel [0] = EOS;                       /* Leerer Dateiname */

  for (i = 1; i < argc; i++)              /* Programm mit Pexec aufgerufen */
  {
    strcat (tail, "'");
    strcat (tail, argv [i]);              /* FÅge Parameter zusammen */
    strcat (tail, "'");
    strcat (tail, " ");
  } /* for */

  if (*tail) tail [strlen (tail) - 1] = EOS; /* Letztes Leerzeichen lîschen */

  shel_read (cmd, s);                     /* Kommando holen */

  s [s [0] + 1] = EOS;                    /* Lîsche '\r' */

  if (*tail == EOS) strcpy (tail, s + 1); /* Programm mit shel_write aufgerufen */

#if FLEXOS
  str_upper (tail);                       /* Parameter immer in Groûschrift */
#endif

  p = strrchr (tail, PROGSEP);

  if (p != NULL)
  {
    strcpy (called_by, p + 1);            /* Aufrufendes Programm feststellen */
    *p = EOS;                             /* Programm ausblenden */
  } /* if */

  for (p = tail; *p; p++)
    if (*p == ',') *p = SP;               /* Kommata durch Leerzeichen ersetzen */

  strcpy (app_name, cmd);                 /* Kopiere Programmname */
  strcpy (app_path, cmd);                 /* Kopiere Pfadname */
  p = strrchr (app_path, PATHSEP);

  if (p == NULL)                          /* Kein Pfad */
    strcpy (app_path, act_path);          /* Pfad durch aktuellen Pfad ersetzen */
  else
  {
    p++;
    strcpy (app_name, p);                 /* Kopiere Programmname */
    *p = EOS;
  } /* if */

#if MSDOS | FLEXOS | LATTICE_C
  p = strrchr (app_name, SUFFSEP);

  deskacc = (p != NULL) &&
            ((strcmp (p + 1, "ACC") == 0) ||
             (strcmp (p + 1, "RSC") == 0)); /* Accessories mit rsrc_load */
#else
  deskacc = ! _app;                       /* _app wird im Initialisierungscode gesetzt */
#endif

  if (deskacc)
  {
    menu_id    = (acc_menu == NULL) ? FAILURE : menu_register (gl_apid, acc_menu); /* Accesory-MenÅ */
    class_desk = DESKWINDOW;                    /* Desktop im Fenster */

    if (menu_id < 0)
      while (TRUE) evnt_timer (0, 1);           /* Lasse andere Prozesse ran */
  } /* if */
  else
  {
    menu_id    = FAILURE;                       /* Kein Accesoory-MenÅ */
    class_desk = class;                         /* Desktop-Klasse */
  } /* else */

  scrp_read (scrapdir);                         /* Scrap-Directory lesen */

  if (*scrapdir == EOS)                         /* Noch keines gesetzt */
  {
    strcpy (scrapdir, SCRAPDIR);

#if GEMDOS
    drives = Dsetdrv (act_drv);                 /* Alle Laufwerke */

    if ((drives & 0xFFFFFFFCL) == 0L)
      drive = 0;                                /* Benutze Laufwerk A */
    else
    {
      drive = 2;                                /* Beginne bei Laufwerk C */
      ready = FALSE;

      while (! ready)
      {
        if (drives & (1L << drive))             /* Laufwerk gefunden */
          ready = TRUE;
        else
          drive++;
      } /* while */
    } /* else */

    scrapdir [0] = (BYTE)('A' + drive);
#endif

    scrp_write (scrapdir);                      /* Scrap-Directory setzen */
  } /* if */

  i = strlen (scrapdir);

  if (scrapdir [i - 1] != PATHSEP)
  {
    scrapdir [i]     = PATHSEP;
    scrapdir [i + 1] = EOS;
  } /* if */

  strcpy (s, scrapdir);
  s [strlen (s) - 1] = EOS;                     /* Backslash lîschen */

  if (! path_exist (scrapdir))
  {
    ok = path_create (s);                       /* Erzeuge Scrap-Directory */

    if (! ok)
    {
      *scrapdir = EOS;
      scrp_write (scrapdir);                    /* Kein Scrap-Directory mîglich */
    } /* if */
  } /* if */

  system_inf    = ReadInfFile (SYSTEM_INF);
  use_adapt     = GetProfileBool (system_inf, "System", "AdaptBitmaps", use_adapt);
  bShowDebugInfo = GetProfileBool (system_inf, "Phoenix", "Debug", FALSE);

  st_guide_apid = appl_find ("ST-GUIDE");
/* [GS] 5.1f Start: */
	if ( st_guide_apid < 0 )
	  st_guide_apid = appl_find ("HYPVIEW");
/* Ende */

	global_mem1 = (char *) malloc_global ( 1024L );
	if ( global_mem1 == NULL )
		return FALSE;
	global_mem2 = (char *) malloc_global ( 1024L );
	if ( global_mem2 == NULL )
		return FALSE;

/* [GS] 5.1f Start */
	nvdi_version = get_nvdi ();
/* Ende */

  return (TRUE);
} /* init_global */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_global ()

{
  mem_free (system_inf);

  	if ( global_mem1 != NULL )
  		Mfree ( global_mem1 );
  	if ( global_mem2 != NULL )
  		Mfree ( global_mem2 );

  if (gl_apid >= 0)
  {
    close_vwork ();                     /* Workstation schlieûen */
    appl_exit ();                       /* Applikation beenden */
  } /* if */

  return (TRUE);
} /* term_global */

/*****************************************************************************/
