/*****************************************************************************/
/*                                                                           */
/* Modul: EXTOBFIX.C                                                         */
/* Datum: 17.02.91                                                           */
/*                                                                           */
/*****************************************************************************/

#include <stdio.h>
#include <string.h>
#include <portab.h>
#include <aes.h>
#include <vdi.h>

#include "extobfix.h"

/****** DEFINES **************************************************************/

#ifndef RSC_NAME
#define RSC_NAME   "EXTOBFIX.RSC"      /* Name der Resource-Datei */
#endif

#ifndef max
#define max(a,b)    (((a) > (b)) ? (a) : (b)) /* Maximum-Funktion */
#define min(a,b)    (((a) < (b)) ? (a) : (b)) /* Minimum Funktion */
#endif

#define DHEADER    0x0020
#define DHEIGHT    0x0040
#define DCRBUTTON  0x0080

#define HALFSTRSIZE 128        /* Halblange Stringgr”že */
#define DESK          0        /* Window-Handle/Klasse des Desktop als Objekt */
#define RC            2        /* Raster Koordinaten */

/****** TYPES ****************************************************************/

typedef struct
{
  WORD bgc;
  WORD style;
  WORD interior;
  WORD bdc;
  WORD width;
  WORD chc;
} OBINFO;

typedef struct
{
  WORD x;                                 /* X-Koordinate */
  WORD y;                                 /* Y-Koordinate */
  WORD w;                                 /* Breite */
  WORD h;                                 /* H”he */
} RECT;

typedef BYTE STR128 [HALFSTRSIZE];        /* Halblange Zeichenkette */

/****** VARIABLES ************************************************************/

#if DR_C | LASER_C | MW_C
EXTERN WORD   gl_apid;                   /* Identifikation fr Applikation */
#else
LOCAL WORD    gl_apid;                   /* Identifikation fr Applikation */
#endif

LOCAL USERBLK check_blk;                /* used for Macintosh check boxes */
LOCAL USERBLK radio_blk;                /* used for Macintosh radio buttons */

LOCAL WORD    gl_wbox;                   /* Breite einer Zeichenbox */
LOCAL WORD    gl_hbox;                   /* H”he einer Zeichenbox */
LOCAL WORD    gl_wattr;                  /* Breite eines Fensterattributes */
LOCAL WORD    gl_hattr;                  /* H”he eines Fensterattributes */

LOCAL WORD    phys_handle;               /* Physikalisches Workstation Handle */
LOCAL WORD    vdi_handle;                /* Virtuelles Workstation Handle */
LOCAL BOOLEAN vwork_open;                /* Virtuelle Workstation ge”ffnet ? */

LOCAL RECT    desk;                      /* Desktop Gr”že */
LOCAL RECT    clip;                      /* Letztes Clipping Rechteck */

LOCAL OBJECT  *userimg;

/****** FUNCTIONS ************************************************************/

GLOBAL LONG       pinit_obfix   _((BOOLEAN status));
LOCAL  VOID       fix_objs      _((OBJECT  *tree, BOOLEAN is_dialog));
LOCAL  VOID       xywh2rect     _((WORD x, WORD y, WORD w, WORD h, RECT *rect));
LOCAL  VOID       set_clip      _((BOOLEAN flag, CONST RECT *size));
LOCAL  VOID       trans_gimage  _((OBJECT *tree, WORD obj));
LOCAL  VOID       rc_copy       _((CONST RECT *ps, RECT *pd));
LOCAL  BOOLEAN    rc_intersect  _((CONST RECT *p1, RECT *p2));
LOCAL  VOID       rect2array    _((CONST RECT *rect, WORD *array));
LOCAL  VOID       xywh2array    _((WORD x, WORD y, WORD w, WORD h, WORD *array));
LOCAL  VOID       open_vwork    _((VOID));
LOCAL  VOID       close_vwork   _((VOID));
LOCAL  BOOLEAN    init_global   _((INT argc, BYTE *argv [], BYTE *acc_menu, WORD class));
LOCAL  BOOLEAN    term_global   _((VOID));

LOCAL  VOID       get_obinfo    _((LONG obspec, OBINFO *obinfo));

LOCAL WORD CDECL  draw_checkbox _((FAR PARMBLK *pb));
LOCAL WORD CDECL  draw_rbutton  _((FAR PARMBLK *pb));

LOCAL  VOID       vdi_fix       _((MFDB *pfd, VOID *theaddr, WORD wb, WORD h));
LOCAL  VOID       vdi_trans     _((WORD *saddr, WORD swb, WORD *daddr, WORD dwb, WORD h));

/*****************************************************************************/

LOCAL LONG routines[] =
{	(LONG)fix_objs,					/* Eigene ob_fix Routine */
	0L,											/* Keine eigene form_alert Routine */
	0L,											/* Keine eigene Testroutine */
	0L,                     /* Noch keine Hilfeseite */
	'0610', '1965',         /* Magic */
	(LONG)pinit_obfix,
};

/*****************************************************************************/

LOCAL VOID get_obinfo (obspec, obinfo)
LONG   obspec;
OBINFO *obinfo;

{
  WORD colorwd;

  colorwd       = (WORD)obspec;
  obinfo->bgc   = colorwd & 0x0F;
  obinfo->style = (colorwd & 0x70) >> 4;

  if (obinfo->style == 0)
    obinfo->interior = 0;
  else
    if (obinfo->style == 7)
      obinfo->interior = 1;
    else
      obinfo->interior = (colorwd & 0x80) ? 3 : 2;

  obinfo->bdc   = (colorwd & 0xF000) >> 12;
  obinfo->width = (WORD)(obspec >> 16) & 0xFF;

  if (obinfo->width > 127) obinfo->width = 256 - obinfo->width;

  obinfo->chc = (colorwd & 0x0F00) >> 8;
} /* get_obinfo */

/*****************************************************************************/
/* Zeichnet ankreuzbare Buttons                                              */
/*****************************************************************************/

LOCAL WORD CDECL draw_checkbox (pb)
FAR PARMBLK *pb;

{ LONG    ob_spec;
  WORD    ob_x, ob_y;
  BOOLEAN selected;
  MFDB    s, d;
  BITBLK  *bitblk;
  WORD    obj;
  WORD    pxy [8];
  WORD    index [2];
  RECT    r;
  OBINFO  obinfo;

  ob_spec   = pb->pb_parm;
  ob_x      = pb->pb_x;
  ob_y      = pb->pb_y;
  selected  = pb->pb_currstate & SELECTED;

  get_obinfo (ob_spec, &obinfo);
  xywh2rect (pb->pb_xc, pb->pb_yc, pb->pb_wc, pb->pb_hc, &r);
  set_clip (TRUE, &r);

  if (selected) /* it was an objc_change */
    obj = (gl_hbox > 8) ? CBHSEL : CBLSEL;   /* high resolution : low resolution */
  else
    obj = (gl_hbox > 8) ? CBHNORM : CBLNORM; /* high resolution : low resolution */

  bitblk = (BITBLK *)userimg [obj].ob_spec;

  d.mp  = NULL; /* screen */
  s.mp  = (VOID *)bitblk->bi_pdata;
  s.fwp = bitblk->bi_wb << 3;
  s.fh  = bitblk->bi_hl;
  s.fww = bitblk->bi_wb >> 1;
  s.ff  = FALSE;
  s.np  = 1;

  pxy [0] = 0;
  pxy [1] = 0;
  pxy [2] = s.fwp - 1;
  pxy [3] = s.fh - 1;
  pxy [4] = ob_x;
  pxy [5] = ob_y;
  pxy [6] = ob_x + pxy [2];
  pxy [7] = ob_y + pxy [3];

  index [0] = obinfo.bgc;
  index [1] = WHITE;

  vrt_cpyfm (vdi_handle, MD_REPLACE, pxy, &s, &d, index);    /* copy it */

  return (pb->pb_currstate & ~ SELECTED);
} /* draw_checkbox */

/*****************************************************************************/
/* Zeichnet runde Radiobuttons                                               */
/*****************************************************************************/

LOCAL WORD CDECL draw_rbutton (pb)
FAR PARMBLK *pb;

{ LONG    ob_spec;
  WORD    ob_x, ob_y;
  BOOLEAN selected;
  MFDB    s, d;
  BITBLK  *bitblk;
  WORD    obj;
  WORD    pxy [8];
  WORD    index [2];
  RECT    r;
  OBINFO  obinfo;

  ob_spec   = pb->pb_parm;
  ob_x      = pb->pb_x;
  ob_y      = pb->pb_y;
  selected  = pb->pb_currstate & SELECTED;

  get_obinfo (ob_spec, &obinfo);
  xywh2rect (pb->pb_xc, pb->pb_yc, pb->pb_wc, pb->pb_hc, &r);
  set_clip (TRUE, &r);

  if (selected) /* it was an objc_change */
    obj = (gl_hbox > 8) ? RBHSEL : RBLSEL; /* high resolution : low resolution */
  else
    obj = (gl_hbox > 8) ? RBHNORM : RBLNORM; /* high resolution : low resolution */

  bitblk = (BITBLK *)userimg [obj].ob_spec;

  d.mp  = NULL; /* screen */
  s.mp  = (VOID *)bitblk->bi_pdata;
  s.fwp = bitblk->bi_wb << 3;
  s.fh  = bitblk->bi_hl;
  s.fww = bitblk->bi_wb >> 1;
  s.ff  = FALSE;
  s.np  = 1;

  pxy [0] = 0;
  pxy [1] = 0;
  pxy [2] = s.fwp - 1;
  pxy [3] = s.fh - 1;
  pxy [4] = ob_x;
  pxy [5] = ob_y;
  pxy [6] = ob_x + pxy [2];
  pxy [7] = ob_y + pxy [3];

  index [0] = obinfo.bgc;
  index [1] = WHITE;

  vrt_cpyfm (vdi_handle, MD_REPLACE, pxy, &s, &d, index);    /* copy it */

  return (pb->pb_currstate & ~ SELECTED);
} /* draw_rbutton */

/*****************************************************************************/

LOCAL VOID fix_objs (tree, is_dialog)
OBJECT  *tree;
BOOLEAN is_dialog;

{
  WORD    obj;
  OBJECT  *ob;
  ICONBLK *ib;
  BITBLK  *bi;
  WORD    y_radio, h_radio;
  WORD    y_check, h_check;
  BOOLEAN hires;
  UWORD   type, xtype;
#if GEM & (GEM2 | GEM3 | XGEM)
  BYTE    *s;
#endif

  hires   = (gl_hbox > 8) ? TRUE : FALSE;

  obj     = hires ? RBHNORM : RBLNORM;
  bi      = (BITBLK *)userimg [obj].ob_spec;
  h_radio = bi->bi_hl;
  y_radio = (gl_hbox - h_radio) / 2;

  obj     = hires ? CBHNORM : CBLNORM;
  bi      = (BITBLK *)userimg [obj].ob_spec;
  h_check = bi->bi_hl;
  y_check = (gl_hbox - h_check) / 2;

  check_blk.ub_code = draw_checkbox;
  radio_blk.ub_code = draw_rbutton;

  if (tree != NULL)
  {
#if GEM & (GEM2 | GEM3 | XGEM)
    if (is_dialog)
    {
      undo_state (tree, ROOT, SHADOWED);
      do_state (tree, ROOT, OUTLINED);
    } /* if */
#endif

    obj = NIL;

    do
    {
      ob    = &tree [++obj];
      type  = ob->ob_type & 0xFF;
      xtype = ob->ob_type >> 8;


#if GEM & (GEM2 | GEM3 | XGEM)
      if ((type == G_STRING) && (ob->ob_state & DISABLED))
        for (s = (BYTE *)ob->ob_spec; *s; s++)
          if (*s == 0x13) *s = '-';
#endif

      if (type == G_ICON)
      {
        ib = (ICONBLK *)ob->ob_spec;
        ob->ob_height = ib->ib_ytext + ib->ib_htext; /* Objekth”he = Iconh”he */
        trans_gimage (tree, obj);         /* Icons an Bildschirm anpassen */
      } /* if */

      if (type == G_IMAGE)
      {
        bi = (BITBLK *)ob->ob_spec;
        ob->ob_height = bi->bi_hl;        /* Objekth”he = Imageh”he */
        trans_gimage (tree, obj);         /* Bit Images an Bildschirm anpassen */
      } /* if */

      if (xtype & DHEADER) ob->ob_y -= gl_hbox / 2;     /* group box */

      if (xtype & DHEIGHT)                              /* half height box */
      {
        ob->ob_height -= gl_hbox / 2;
        if (! hires) ob->ob_height--;
      } /* if */

      if (xtype & DCRBUTTON)
      {
        if (ob->ob_flags & RBUTTON)                     /* radio button */
        {
          radio_blk.ub_parm  = (LONG)ob->ob_spec;
          ob->ob_y          += y_radio;
          ob->ob_height      = h_radio;
#if MSDOS | FLEXOS | DR_C | LATTICE_C | MW_C | TURBO_C
          ob->ob_type        = G_USERDEF;
          ob->ob_spec        = (LONG)&radio_blk;
#endif
        } /* if */
        else                                            /* checkbox */
        {
          check_blk.ub_parm  = (LONG)ob->ob_spec;
          ob->ob_y          += y_check;
          ob->ob_height      = h_check;
#if MSDOS | FLEXOS | DR_C | LATTICE_C | MW_C | TURBO_C
          ob->ob_type        = G_USERDEF;
          ob->ob_spec        = (LONG)&check_blk;
#endif
        } /* else */
      } /* if */
    } while (! (ob->ob_flags & LASTOB));
  } /* if */
} /* fix_objs */

/*****************************************************************************/

main()
{
  if (init_global (0, NULL, NULL, 0) == TRUE)
	{	form_alert (1, "[3][Dieses Programm kann|nur von Interface|gestartet werden !][ Abbruch ]");
		term_global ();
	}

	return (0);
}

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

LOCAL BOOLEAN init_global (argc, argv, acc_menu, class)
INT  argc;
BYTE *argv [];
BYTE *acc_menu;
WORD class;

{	WORD   i;
	STR128 rsc_name, s;
#if GEM & (GEM2 | GEM3 | XGEM)
  BYTE   *p;
#endif

  i = appl_init ();                       /* Applikationsnummer besorgen */

#if (LATTICE_C | TURBO_C) | (GEM & (GEM2 | GEM3 | XGEM))
  gl_apid = i;                            /* gl_apid nicht extern */
#endif

  if (gl_apid < 0) return (FALSE);

  phys_handle = graf_handle (&gl_wbox, &gl_hbox, &gl_wattr, &gl_hattr); /* Handle des Bildschirms */
  vdi_handle  = phys_handle;              /* Benutze physikalischen Bildschirm */
  vwork_open  = FALSE;

  wind_get (DESK, WF_WXYWH, &desk.x, &desk.y, &desk.w, &desk.h);        /* Gr”že des Desktop */

#if GEM & GEM1
  strcpy (rsc_name, RSC_NAME);                  /* Programm wurde vielleicht mit Pexec gestartet */
#else
  strcpy (rsc_name, app_name);
  p = strrchr (rsc_name, SUFFSEP);              /* Programmname hat immer Suffix */
  strcpy (p + 1, "RSC");
#endif

  if (! rsrc_load (rsc_name))
	{
		strcpy (s, "[3][Resource-File|");
		strcat (s, rsc_name);
		strcat (s, "?][ EXIT ]");
		form_alert (1, s);
		return (FALSE);
  } /* if */

  rsrc_gaddr (R_TREE, USERIMG, &userimg);       /* Adresse der Mac-Images */
  rsrc_gaddr (R_TREE, HELP_EXT, &routines[3]);  /* Adresse der Hilfeseite */
  fix_objs (userimg, FALSE);
	
  open_vwork ();                          /* ™ffne virtuelle Workstation */

  return (TRUE);
} /* init_global */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

LOCAL BOOLEAN term_global ()

{
  if (gl_apid >= 0)
  {
		rsrc_free ();					              /* Resourcen freigeben */
    close_vwork ();                     /* Workstation schliežen */
    appl_exit ();                       /* Applikation beenden */
  } /* if */

  return (TRUE);
} /* term_global */

/*****************************************************************************/
/* ™ffne virtuelle Workstation                                               */
/*****************************************************************************/

LOCAL VOID open_vwork ()

{
  WORD i;
  WORD work_in [11];
  WORD work_out [57];

  if (! vwork_open)
  {
    vwork_open = TRUE;

    for (i = 0; i < 10; work_in [i++] = 1);
    work_in [10] = RC;                         /* Raster Koordinaten */
    vdi_handle = phys_handle;
    v_opnvwk (work_in, &vdi_handle, work_out); /* ™ffne virtuelle Workstation */

#if GEM & XGEM
    vst_point (vdi_handle, 10, &i, &i, &i, &i);
#endif

    vqt_attributes (vdi_handle, work_out);     /* Globale Zeichensatzgr”žen */
  } /* if */
} /* open_vwork */

/*****************************************************************************/
/* Schlieže virtuelle Workstation                                            */
/*****************************************************************************/

LOCAL VOID close_vwork ()

{
  if (vwork_open)
  {
    v_clsvwk (vdi_handle);                      /* Workstation freigeben */
    vdi_handle = phys_handle;                   /* Physikalischen Bildschirm benutzen */
    vwork_open = FALSE;
  } /* if */
} /* close_vwork */

/*****************************************************************************/

LOCAL VOID trans_gimage (tree, obj)
OBJECT *tree;
WORD   obj;

{
  ICONBLK *piconblk;
  BITBLK  *pbitblk;
  WORD    *taddr;
  WORD    wb, hl, type;

  type = tree [obj].ob_type;

  if (type == G_ICON)
  {
    piconblk = (ICONBLK *)tree [obj].ob_spec;
    taddr    = piconblk->ib_pmask;
    wb       = piconblk->ib_wicon;
    wb       = wb >> 3;
    hl       = piconblk->ib_hicon;

    vdi_trans (taddr, wb, taddr, wb, hl);

    taddr = piconblk->ib_pdata;
  } /* if */
  else
  {
    pbitblk = (BITBLK *)tree [obj].ob_spec;
    taddr   = pbitblk->bi_pdata;
    wb      = pbitblk->bi_wb;
    hl      = pbitblk->bi_hl;
  } /* else */

  vdi_trans (taddr, wb, taddr, wb, hl);
} /* trans_gimage */

/*****************************************************************************/

LOCAL VOID xywh2rect (x, y, w, h, rect)
WORD x, y, w, h;
RECT *rect;

{
  rect->x = x;
  rect->y = y;
  rect->w = w;
  rect->h = h;
} /* xywh2rect */

/*****************************************************************************/

LOCAL VOID set_clip (clipflag, size)
BOOLEAN     clipflag;
CONST RECT *size;

{
  RECT r;
  WORD xy [4];

  if (size == NULL)
    rc_copy (&desk, &r);                /* Nichts definiert, nimm Desktop */
  else
    rc_copy (size, &r);                 /* Benutze definierte Gr”že */

  rc_copy (&r, &clip);                  /* Rette aktuelle Werte */

  if (rc_intersect (&desk, &r))         /* Nur auf Desktop zeichnen */
    rect2array (&r, xy);
  else
    xywh2array (0 ,0 ,0 ,0, xy);        /* Nichts zeichnen */

  vs_clip (vdi_handle, clipflag, xy);   /* Setze Rechteckausschnitt */
} /* set_clip */

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

LOCAL VOID rc_copy (ps, pd)
CONST REG RECT *ps;
REG RECT       *pd;

{
  pd->x = ps->x;
  pd->y = ps->y;
  pd->w = ps->w;
  pd->h = ps->h;
} /* rc_copy */

/*****************************************************************************/

LOCAL BOOLEAN rc_intersect (p1, p2)
CONST REG RECT *p1;
REG RECT       *p2;

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

LOCAL VOID rect2array (rect, array)
CONST RECT *rect;
WORD       *array;

{
  *array++ = rect->x;
  *array++ = rect->y;
  *array++ = rect->x + rect->w - 1;
  *array   = rect->y + rect->h - 1;
} /* rect2array */

/*****************************************************************************/

LOCAL VOID xywh2array  (x, y, w, h, array)
WORD x, y, w, h;
WORD *array;

{
  *array++ = x;
  *array++ = y;
  *array++ = x + w - 1;
  *array   = y + h - 1;
} /* xywh2array */

/*****************************************************************************/

GLOBAL LONG pinit_obfix (status)
BOOLEAN status;

{
	if (status == TRUE)
	{	if (!init_global (0, NULL, NULL, 0))
			return (0L);
		else
			return ((LONG)routines);
	}
	else
		term_global ();
	
	return (0L);
}
