/* VDI TEST-Programm                */
/* Zeichnet ein Haus und einen Text */
/* auf ein beliebiges AusgabegerÑt  */

#include <stdio.h>
#include <string.h>
#include <portab.h>
#include <vdi.h>
#include <aes.h>

#define SCREEN     01
#define PLOTTER    11
#define PRINTER    21
#define METAFILE   31
#define CAMERA     41
#define TABLET     51

#define NDC         0
#define RC          2

#define VM_PAGESIZE 0
#define VM_COORDS   1

#define SWISS       2 /* SWISS font */

#define abs(x)      ((x) <  0  ? -(x) : (x))  /* Absolut-Wert */
#define max(x,y)    (((x) > (y)) ? (x) : (y)) /* Maximim-Funktion */
#define min(x,y)    (((x) < (y)) ? (x) : (y)) /* Minimum Funktion */

/****** Variablen ************************************************************/

GLOBAL WORD    contrl [12];
GLOBAL WORD    intin [128];
GLOBAL WORD    ptsin [128];
GLOBAL WORD    intout [128];
GLOBAL WORD    ptsout [128];

LOCAL  WORD    work_in [103];
LOCAL  WORD    work_out [57];
LOCAL  WORD    vdi_handle;
LOCAL  BOOLEAN from_desktop;
LOCAL  BYTE    meta_name [80];
LOCAL  WORD    min_x, min_y, max_x, max_y;
LOCAL  WORD    screen_w, screen_h;
LOCAL  WORD    meta_w, meta_h;

/****** Prototypen ***********************************************************/

EXTERN VOID vdi _((VOID));      /* funktioniert auf X/GEM nicht */

#if GEM & (GEM1 | GEM2)         /* fehlen auf Ñlteren GEM Systemen */
LOCAL  VOID vm_pagesize   _((WORD vdi_handle, WORD pgwidth, WORD pgheight));
LOCAL  VOID vm_coords     _((WORD vdi_handle, WORD llx, WORD lly, WORD urx, WORD ury));
#endif

LOCAL  BOOLEAN open_work  _((WORD device, WORD coord));
LOCAL  VOID    close_work _((WORD device, WORD coord));
LOCAL  VOID    wait       _((VOID));
LOCAL  VOID    house      _((WORD device, WORD coord));

/*****************************************************************************/

#if GEM & (GEM1 | GEM2) /* fehlen auf Ñlteren GEM Systemen */
LOCAL VOID vm_pagesize (vdi_handle, pgwidth, pgheight)
WORD vdi_handle, pgwidth, pgheight;

{
  contrl [0] = 5;
  contrl [1] = 0;
  contrl [3] = 3;
  contrl [5] = 99;
  contrl [6] = vdi_handle;

  intin [0] = VM_PAGESIZE;
  intin [1] = pgwidth;
  intin [2] = pgheight;

  vdi ();
} /* vm_pagesize */

/*****************************************************************************/

LOCAL VOID vm_coords (vdi_handle, llx, lly, urx, ury)
WORD vdi_handle, llx, lly, urx, ury;

{
  contrl [0] = 5;
  contrl [1] = 0;
  contrl [3] = 5;
  contrl [5] = 99;
  contrl [6] = vdi_handle;

  intin [0] = VM_COORDS;
  intin [1] = llx;
  intin [2] = lly;
  intin [3] = urx;
  intin [4] = ury;

  vdi ();
} /* vm_coords */
#endif /* GEMDOS */

/*****************************************************************************/

LOCAL BOOLEAN open_work (device, coord)
WORD device;
WORD coord;

{
  WORD i;

  for (i = 0; i < 103; i++) work_in [i] = 1;

  work_in [0]  = device; /* device handle       */
  work_in [10] = coord;  /* NDC/RC Koordinaten  */

  if (device != SCREEN)  /* GEM/3 Erweiterungen */
  {
    work_in [11] = OW_NOCHANGE; /* Paralleler oder Serieller Port */
    work_in [12] = 0;           /* Port #0 */
  } /* if */

  if (device == SCREEN)
  {
    if (from_desktop)
    {
      appl_init ();
      vdi_handle = graf_handle (&i, &i, &i, &i);
      v_opnvwk (work_in, &vdi_handle, work_out); /* virtuell îffnen */
      graf_mouse (M_OFF, NULL);
    }
    else
    {
      v_opnwk (work_in, &vdi_handle, work_out); /* physikalisch îffnen */
      v_hide_c (vdi_handle);
    } /* else */

    screen_w = work_out [0];
    screen_h = work_out [1];
  } /* if */
  else                                          /* nicht Bildschirm */
    v_opnwk (work_in, &vdi_handle, work_out);

  if (vdi_handle > 0) /* erfolgreich geîffnet */
  {
    switch (device)
    {
      case SCREEN   : v_clrwk (vdi_handle);                break; /* Bildschirm lîschen */
      case PLOTTER  : v_clrwk (vdi_handle);                break;
      case PRINTER  : v_updwk (vdi_handle);                break;
      case METAFILE : vm_filename (vdi_handle, meta_name); break;
    } /* switch */

    vst_load_fonts (vdi_handle, 0);
  } /* if */

  return (vdi_handle > 0);
} /* open_work */

/*****************************************************************************/

LOCAL VOID close_work (device, coord)
WORD device;
WORD coord;

{
  WORD llx, lly, urx, ury;

  if (device == SCREEN) wait ();

  if (from_desktop)
    graf_mouse (M_ON, NULL);
  else
    v_show_c (vdi_handle, TRUE);

  if (from_desktop && device == SCREEN)
  {
    vst_unload_fonts (vdi_handle, 0);
    v_clsvwk (vdi_handle);
    appl_exit ();
  } /* if */
  else
  {
    switch (device)
    {
      case SCREEN   : break;
      case PLOTTER  : v_updwk (vdi_handle); break;
      case PRINTER  : v_updwk (vdi_handle); break;
      case METAFILE : if (coord == NDC)
                      {
                        llx = 0;
                        lly = 0;
                        urx = meta_w;
                        ury = meta_h;
                      }
                      else /* RC */
                      {
                        llx = 0;
                        lly = meta_h;
                        urx = meta_w;
                        ury = 0;
                      } /* else */

                      v_meta_extents (vdi_handle, min_x, min_y, max_x, max_y);
                      vm_pagesize (vdi_handle, 1905, 2540);     /* Letter size = 7,5 x 10.00 Zoll */
                      vm_coords (vdi_handle, llx, lly, urx, ury);
                      break;
    } /* switch */

    vst_unload_fonts (vdi_handle, 0);
    v_clswk (vdi_handle);
  } /* else */
} /* close_work */

/*****************************************************************************/

LOCAL VOID wait ()

{
  WORD echo_xy [2];
  BYTE string [2];

  echo_xy [0] = 0;
  echo_xy [1] = 0;

  if (from_desktop)
    evnt_keybd ();
  else
    vrq_string (vdi_handle, 1, 0, echo_xy, string);
} /* wait */

/*****************************************************************************/

LOCAL VOID house (device, coord)
WORD device;
WORD coord;

{
  WORD i, pxy [12];

  if (open_work (device, coord))
  {
    if (coord == NDC)
    {
      pxy [0]  = 6000;
      pxy [1]  = 6000;
      pxy [2]  = 6000;
      pxy [3]  = 10000;
      pxy [4]  = 10000;
      pxy [5]  = 12000;
      pxy [6]  = 14000;
      pxy [7]  = 10000;
      pxy [8]  = 14000;
      pxy [9]  = 6000;
      pxy [10] = 6000;
      pxy [11] = 6000;

      if (device == METAFILE)
      {
        min_x = pxy [0];
        min_y = pxy [1];
        max_x = pxy [6];
        max_y = pxy [5];

        meta_w = 32766;
        meta_h = 32766;
      } /* if */
    } /* if */
    else
    {
      pxy [0]  = 100;
      pxy [1]  = 200;
      pxy [2]  = 100;
      pxy [3]  = 100;
      pxy [4]  = 200;
      pxy [5]  = 50;
      pxy [6]  = 300;
      pxy [7]  = 100;
      pxy [8]  = 300;
      pxy [9]  = 200;
      pxy [10] = 100;
      pxy [11] = 200;

      if (device == METAFILE)
      {
        min_x = pxy [0];
        min_y = pxy [5];
        max_x = pxy [6];
        max_y = pxy [1];

        meta_w = screen_w;
        meta_h = screen_h;
      } /* if */
    } /* else */

    vswr_mode (vdi_handle, MD_TRANS);
    vsl_color (vdi_handle, RED);
    vsl_type (vdi_handle, SOLID);
    v_pline (vdi_handle, 6, pxy); /* Haus zeichnen */

    vst_color (vdi_handle, GREEN);
    vst_font (vdi_handle, SWISS);
    vst_effects (vdi_handle, TXT_NORMAL);
    vst_alignment (vdi_handle, ALI_LEFT, ALI_BOTTOM, &i, &i);
    vst_point (vdi_handle, 10, &i, &i, &i, &i);
    vst_rotation (vdi_handle, 0);
    v_gtext (vdi_handle, pxy [0], pxy [1], "VDI-Test HAUS");

    close_work (device, coord);
  } /* if */
} /* house */

/*****************************************************************************/

GLOBAL WORD main ()

{
  screen_w = 639; /* default Werte */
  screen_h = 199; /* werden spÑter korrigiert */

  from_desktop = TRUE; /* FALSE fÅr MSDOS, wenn GEMVDI direkt gestartet wird */

  house (SCREEN, NDC);
  house (SCREEN, RC);

/*
  house (PLOTTER, NDC);
  house (PLOTTER, RC);
*/

/*
  house (PRINTER, NDC);
  house (PRINTER, RC);
*/


  strcpy (meta_name, "HOUSENDC.GEM");
  house (METAFILE, NDC);
  strcpy (meta_name, "HOUSERC.GEM");
  house (METAFILE, RC);


  return (0);
} /* main */
