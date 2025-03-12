/* Mini-Output Programm, das Metadateien und Bitimage-Dateien */
/* auf ein beliebiges Ausgabeger„t sendet                     */

#include <stdio.h>
#include <string.h>
#include <portab.h>
#include <vdi.h>
#include <aes.h>

#if GEMDOS
#include <osbind.h>
#define Mavail() (LONG)Malloc (-1L)
#else
#include <gemdos.h>
#include <dosbind.h>
#endif

#include "showgem.h"

/****** DEFINES **************************************************************/

#define DEBUG           0
#define MAX_PLANES      8
#define MAX_PATTERNS    8
#define MAX_COLORS     16 /* GEM standard colors */
#define MAX_LINEBUF  1024 /* screen width max 8192 pixels in bit image */
#define META_BUF      512 /* 32767 max */

#define SCREEN         1
#define PLOTTER       11
#define PRINTER       21
#define METAFILE      31
#define CAMERA        41
#define TABLET        51

#define NDC            0
#define RC             2
#define FONT_SYSTEM    1
#define FONT_SWISS     2
#define DRV_NAMES      2         /* info_select for v_get_driver_info */
#define MAX_DRIVERS    4

#define V_CLRWK               3  /* Metafile VDI functions */
#define V_UPDWK               4
#define V_ESC                 5
#define V_PLINE               6
#define V_PMARKER             7
#define V_GTEXT               8
#define V_FILLAREA            9
#define V_GDP                11
#define VST_HEIGHT           12
#define VST_ROTATION         13
#define VS_COLOR             14
#define VSL_TYPE             15
#define VSL_WIDTH            16
#define VSL_COLOR            17
#define VSM_TYPE             18
#define VSM_HEIGHT           19
#define VSM_COLOR            20
#define VST_FONT             21
#define VST_COLOR            22
#define VSF_INTERIOR         23
#define VSF_STYLE            24
#define VSF_COLOR            25
#define VSWR_MODE            32
#define VST_ALIGNMENT        39
#define VSF_PERIMETER       104
#define VST_EFFECTS         106
#define VST_POINT           107
#define VSL_ENDS            108
#define VSF_UDPAT           112
#define VSL_UDSTY           113
#define VR_RECFL            114
#define VS_CLIP             129

#define V_BAR                 1  /* Metafile VDI GDP functions */
#define V_ARC                 2
#define V_PIESLICE            3
#define V_CIRCLE              4
#define V_ELLIPSE             5
#define V_ELLARC              6
#define V_ELLPIE              7
#define V_RBOX                8
#define V_RFBOX               9
#define V_JUSTIFIED          10

#define V_EXIT_CUR            2 /* Metafile VDI ESC functions */
#define V_ENTER_CUR           3
#define V_FORM_ADV           20
#define V_OUTPUT_WINDOW      21
#define V_CLEAR_DISP_LIST    22
#define V_BIT_IMAGE          23
#define V_ALPHA_TEXT         25
#define V_TOPBOT          18501

#define RSC_NAME   "SHOWGEM.RSC"        /* Name der Resource-Datei */
#define DRIVESEP   ':'
#define PATHSEP    '\\'
#define SUFFSEP    '.'

#define DHEADER   0x0020                /* user defined objects */
#define DCHECKBOX 0x0040
#define DRBUTTON  0x0060

#define ESC      27

#define RGB     0
#define CYM     1
#define HLS     2
#define PANTONE 3

#define abs(x)      ((x) <  0  ? -(x) : (x))  /* Absolut-Wert */
#define max(x,y)    (((x) > (y)) ? (x) : (y)) /* Maximim-Funktion */
#define min(x,y)    (((x) < (y)) ? (x) : (y)) /* Minimum Funktion */

/****** TYPES ****************************************************************/

typedef struct
{
  UWORD red;
  UWORD green;
  UWORD blue;
} RGB_LIST;

typedef struct
{
  WORD bgc;
  WORD style;
  WORD interior;
  WORD bdc;
  WORD width;
  WORD chc;
} OBINFO;

typedef struct meta_header
{
  WORD id;
  WORD headlen;
  WORD version;
  WORD transform;
  WORD min_x;
  WORD min_y;
  WORD max_x;
  WORD max_y;
  WORD pwidth;
  WORD pheight;
  WORD ll_x;
  WORD ll_y;
  WORD ur_x;
  WORD ur_y;
  WORD bit_image;
} META_HEADER;

typedef struct img_header
{
  WORD version;
  WORD headlen;
  WORD planes;
  WORD pat_run;
  WORD pix_width;
  WORD pix_height;
  WORD sl_width;
  WORD sl_height;
} IMG_HEADER;

typedef struct ximg_header
{
 WORD      version;
 WORD      headlen;
 WORD      planes;
 WORD      pat_run;
 WORD      pix_width;
 WORD      pix_height;
 WORD      sl_width;
 WORD      sl_height;
 BYTE      x_id [4];         /* must contain "XIMG" */
 WORD      color_model;      /* 0 = RGB,1 = CYM,2 = HLS, etc. */
 RGB_LIST  color_table [];   /* open array, length 2^planes */
} XIMG_HEADER;

typedef struct rect
{
  WORD x;
  WORD y;
  WORD w;
  WORD h;
} RECT;

typedef struct lrect
{
  LONG x;
  LONG y;
  LONG w;
  LONG h;
} LRECT;

typedef struct drect
{
  DOUBLE x;
  DOUBLE y;
  DOUBLE w;
  DOUBLE h;
} DRECT;

typedef struct point
{
  WORD x;
  WORD y;
} POINT;

typedef BYTE STRING [82];
typedef BYTE LONGSTR [255];

typedef UBYTE HUGE *HPTR;
typedef UBYTE FAR  *FPTR;

/****** VARIABLES ************************************************************/

#if GEMDOS
#if MW_C
LONG _stksize = 12288;            /* 12 KBytes Stack fr Mark Williams C */
#endif
#endif

#if MSDOS
#if TURBO_C
UWORD _stklen = 12288;            /* 12 KBytes Stack fr Turbo C */
#endif
#endif

#if DR_C | LASER_C | MW_C
EXTERN WORD        gl_apid;          /* Identifikation fr Applikation */
#else
GLOBAL WORD        gl_apid;          /* Identifikation fr Applikation */
#endif

GLOBAL WORD        contrl [12];      /* GEM Arrays fr Parameter... */
GLOBAL WORD        intin [256];      /* ...von VDI Aufrufen */
GLOBAL WORD        ptsin [256];
GLOBAL WORD        intout [256];
GLOBAL WORD        ptsout [256];

LOCAL  WORD        n_pts;
LOCAL  WORD        n_int;
LOCAL  LRECT       out_device;
LOCAL  LRECT       src;
LOCAL  LRECT       dst;
LOCAL  DOUBLE      dst_factor;       /* Faktor zum Einpassen */
LOCAL  DRECT       aspect_factor;    /* Faktor fr Maástabstreue */
LOCAL  DRECT       src_pixel;
LOCAL  LRECT       dst_pixel;
LOCAL  POINT       origo;
LOCAL  WORD        work_in [103];
LOCAL  WORD        work_out [57];
LOCAL  WORD        vdi_handle;
LOCAL  WORD        out_handle;
LOCAL  WORD        phys_handle;
LOCAL  BYTE        meta_name [80];
LOCAL  WORD        meta_handle;
LOCAL  ULONG       meta_len;
LOCAL  ULONG       meta_index;
LOCAL  UWORD       meta_buffer [META_BUF];
LOCAL  META_HEADER *meta_header;
LOCAL  BYTE        fs_iinpath [128];
LOCAL  BYTE        fs_iinsel [13];
LOCAL  WORD        fs_iexbutton;
LOCAL  WORD        more_fonts;
LOCAL  WORD        gl_wbox, gl_hbox, gl_wattr, gl_hattr;
LOCAL  STRING      drv_names [MAX_DRIVERS];
LOCAL  RGB_LIST    gem_colors [MAX_COLORS] = {1000, 1000, 1000,  /* white        */
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
                                               666,    0,  666}; /* dark magenta */



#if GEM & GEM3
LOCAL  WORD        drivers [MAX_DRIVERS] = {SCREEN, PLOTTER, PRINTER, CAMERA};
#endif

LOCAL  OBJECT      *dialog;
LOCAL  OBJECT      *userimg;
LOCAL  OBJECT      *working;
LOCAL  OBJECT      *fstrings;

LOCAL  BYTE        **alertmsg;               /* Fehlermeldungen */
LOCAL  USERBLK     check_blk;                /* used for Macintosh check boxes */
LOCAL  USERBLK     radio_blk;                /* used for Macintosh radio buttons */

/****** PROTOTYPES ***********************************************************/

EXTERN VOID      vdi             _((VOID));

#if MSDOS
EXTERN PARMBLK   *fardr_start    _((VOID));
EXTERN VOID      fardr_end       _((WORD state));
#endif

#if MSDOS
LOCAL WORD       draw_checkbox   _((VOID));
LOCAL WORD       draw_rbutton    _((VOID));
#else
LOCAL WORD CDECL draw_checkbox   _((FAR PARMBLK *pb));
LOCAL WORD CDECL draw_rbutton    _((FAR PARMBLK *pb));
#endif

LOCAL BOOLEAN    file_exist        _((BYTE *filename));
LOCAL VOID       file_split        _((BYTE *fullname, WORD *drive, BYTE *path, BYTE *filename, BYTE *ext));
LOCAL WORD       get_path          _((BYTE *path, WORD drive));
LOCAL BOOLEAN    set_path          _((BYTE *path));
LOCAL VOID       set_clip          _((WORD x, WORD y, WORD w, WORD h));
LOCAL VOID       do_state          _((OBJECT *tree, WORD obj, UWORD state));
LOCAL VOID       undo_state        _((OBJECT *tree, WORD obj, UWORD state));
LOCAL VOID       vdi_fix           _((MFDB *pfd, VOID *theaddr, WORD wb, WORD h));
LOCAL VOID       vdi_trans         _((WORD *saddr, WORD swb, WORD *daddr, WORD dwb, WORD h));
LOCAL VOID       trans_gimage      _((OBJECT *tree, WORD obj));
LOCAL VOID       get_obinfo        _((LONG obspec, OBINFO *obinfo));
LOCAL VOID       fix_objs          _((OBJECT *tree, BOOLEAN is_dialog));
LOCAL BOOLEAN    init_resource     _((VOID));
LOCAL WORD       hndl_dial         _((OBJECT *tree, WORD def, WORD x, WORD y, WORD w, WORD h));
LOCAL VOID       show_dial         _((OBJECT *tree));
LOCAL VOID       end_dial          _((OBJECT *tree));
LOCAL WORD       open_work         _((WORD device));
LOCAL VOID       close_work        _((WORD device));
LOCAL BOOLEAN    gdos_ok           _((VOID));
LOCAL VOID       get_screen_info   _((WORD vdi_handle));
LOCAL VOID       wait              _((VOID));
LOCAL VOID       flip_word         _((HPTR adr));
LOCAL VOID       flip_long         _((UWORD HUGE *adr));
LOCAL BOOLEAN    read_meta         _((STRING meta_name));
LOCAL WORD       get_word          _((VOID));
LOCAL BOOLEAN    get_code          _((VOID));
LOCAL WORD       new_width         _((WORD width));
LOCAL WORD       new_height        _((WORD height));
LOCAL VOID       transform         _((BOOLEAN flip_x, BOOLEAN flip_y));
LOCAL VOID       get_header_info   _((BOOLEAN best_fit));
LOCAL VOID       show_debug        _((BOOLEAN flip_x, BOOLEAN flip_y));
LOCAL VOID       new_trnfm         _((WORD source_planes, MFDB *s, MFDB *d));
LOCAL VOID       show_bit_image    _((IMG_HEADER *img_header, HPTR img_buffer,
                                      HPTR raster_buf, HPTR raster_ptr,
                                      HPTR *plane_ptr, WORD max_lines,
                                      WORD screen_planes, WORD fww));
LOCAL VOID       read_bit_image    _((STRING filename));
LOCAL VOID       show_page         _((VOID));
LOCAL VOID       do_command        _((WORD device, BOOLEAN best_fir, BOOLEAN flip_x, BOOLEAN flip_y));
LOCAL VOID       show_meta         _((WORD device, BOOLEAN best_fit, BOOLEAN usr_break));
LOCAL BOOLEAN    select_file       _((BYTE *name, BYTE *suffix, BYTE *filename));

/****** FUNCTIONS ************************************************************/

LOCAL BOOLEAN file_exist (filename)
BYTE *filename;

{
#if GEMDOS
  return (Fsfirst (filename, 0x00) == 0);
#else
  return (Fsfirst (filename, 0x00) > 0);
#endif
} /* file_exist */

/*****************************************************************************/

LOCAL VOID file_split (fullname, drive, path, filename, ext)
BYTE *fullname;
WORD *drive;
BYTE *path, *filename, *ext;

{
  LONGSTR s;
  BYTE    name [13];
  BYTE    *p, *f;
  WORD    drv;

  strcpy (s, fullname);
  p = strchr (s, DRIVESEP);

  if (p == NULL)                                /* Kein Laufwerk gefunden */
  {
    drv = Dgetdrv ();
    p   = s;
  } /* if */
  else
  {
    drv = p [-1] - 'A';
    p++;
  } /* else */

  if (drive != NULL) *drive = drv;

  f = strrchr (p, PATHSEP);

  if (f == NULL)                                /* Kein Pfad */
  {
    strcpy (name, p);                           /* Dateinamen retten */
    if (path != NULL) get_path (path, drv + 1);
  } /* if */
  else
  {
    strcpy (name, f + 1);                       /* Dateinamen retten */
    f [1] = EOS;

    if (path != NULL)
    {
      if (*p != PATHSEP)                        /* Keine Root */
        get_path (path, drv + 1);
      else
        *path = EOS;

      strcat (path, p);

      if (drive == NULL)
      {
        strcpy (s, "A:");
        s [0] += (BYTE)drv;
        strcat (s, path);
        strcpy (path, s);
      } /* if */
    } /* if */
  } /* else */

  if (filename != NULL) strcpy (filename, name);

  if (ext != NULL)
  {
    p = strrchr ((filename != NULL) ? filename : name, SUFFSEP);

    if (p == NULL)
      *ext = EOS;
    else
    {
      strcpy (ext, p + 1);
      if (filename != NULL) *p = EOS;
    } /* else */
  } /* if */
} /* file_split */

/*****************************************************************************/

LOCAL WORD get_path (path, drive)
BYTE *path;
WORD drive;

{
  BYTE s [64], sep [2];
  WORD ret;

  path [0] = EOS;

  ret = Dgetpath (s, drive);

  if (*s)
  {
#if MSDOS | FLEXOS
    strcpy (path + 1, s);
    path [0] = PATHSEP;
#endif

#if GEMDOS
    strcpy (path, s);
#endif
  } /* if */

  sep [0] = PATHSEP;
  sep [1] = EOS;

  strcat (path, sep);
  return (ret);
} /* get_path */

/*****************************************************************************/

GLOBAL BOOLEAN set_path (path)
BYTE *path;

{
  LONGSTR s;
  BYTE    *p;
  WORD    l;

  strcpy (s, path);

  if (*s)
  {
    p = s;
    if (p [1] == DRIVESEP) p += 2;

    l = strlen (p);
    if ((l > 1) && (p [l - 1] == PATHSEP)) p [l - 1] = EOS;
  } /* if */

#if GEMDOS
  return ((WORD)Dsetpath (s) == 0);
#else
  Dsetpath (s);
  return (! DOS_ERR);
#endif
} /* set_path */

/*****************************************************************************/

LOCAL VOID set_clip (x, y, w, h)
WORD x, y, w, h;

{
  WORD pxy [4];

  pxy [0] = x;
  pxy [1] = y;
  pxy [2] = x + w - 1;
  pxy [3] = y + h - 1;

  vs_clip (vdi_handle, TRUE, pxy);
} /* set_clip */

/*****************************************************************************/

LOCAL VOID do_state (tree, obj, state)
OBJECT *tree;
WORD   obj;
UWORD  state;

{
  tree [obj].ob_state |= state;         /* Status im Objekt setzen */
} /* do_state */

/*****************************************************************************/

LOCAL VOID undo_state (tree, obj, state)
OBJECT *tree;
WORD   obj;
UWORD  state;

{
  tree [obj].ob_state &= ~ state;       /* Status im Objekt l”schen */
} /* undo_state */

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

#if MSDOS
LOCAL WORD draw_checkbox ()
{
  PARMBLK *pb = fardr_start();
#else
LOCAL WORD CDECL draw_checkbox (pb)
PARMBLK *pb;

{
#endif

  LONG    ob_spec;
  WORD    ob_x, ob_y;
  BOOLEAN selected;
  MFDB    s, d;
  BITBLK  *bitblk;
  WORD    obj; /* check box object number */
  WORD    pxy [8];
  WORD    index [2];
  OBINFO  obinfo;

  ob_spec   = pb->pb_parm;
  ob_x      = pb->pb_x;
  ob_y      = pb->pb_y;
  selected  = pb->pb_currstate & SELECTED;

  get_obinfo (ob_spec, &obinfo);
  set_clip (pb->pb_x, pb->pb_y, pb->pb_w, pb->pb_h);

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

#if MSDOS
  fardr_end (pb->pb_currstate & ~ SELECTED);
#endif

  return (pb->pb_currstate & ~ SELECTED);
} /* draw_checkbox */

/*****************************************************************************/
/* Zeichnet runde Radiobuttons                                               */
/*****************************************************************************/

#if MSDOS
LOCAL WORD draw_rbutton ()
{
  PARMBLK *pb = fardr_start();
#else
LOCAL WORD CDECL draw_rbutton (pb)
PARMBLK *pb;

{
#endif

  LONG    ob_spec;
  WORD    ob_x, ob_y;
  BOOLEAN selected;
  MFDB    s, d;
  BITBLK  *bitblk;
  WORD    robj; /* radio button object number */
  WORD    pxy [8];
  WORD    index [2];
  OBINFO  obinfo;

  ob_spec   = pb->pb_parm;
  ob_x      = pb->pb_x;
  ob_y      = pb->pb_y;
  selected  = pb->pb_currstate & SELECTED;

  get_obinfo (ob_spec, &obinfo);
  set_clip (pb->pb_x, pb->pb_y, pb->pb_w, pb->pb_h);

  if (selected) /* it was an objc_change */
    robj = (gl_hbox > 8) ? RBHSEL : RBLSEL; /* high resolution : low resolution */
  else
    robj = (gl_hbox > 8) ? RBHNORM : RBLNORM; /* high resolution : low resolution */

  bitblk = (BITBLK *)userimg [robj].ob_spec;

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

#if MSDOS
  fardr_end (pb->pb_currstate & ~ SELECTED);
#endif

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
  UWORD   xtype;

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
      ob = &tree [++obj];

      if (ob->ob_type == G_ICON)
      {
        ib = (ICONBLK *)ob->ob_spec;
        ob->ob_height = ib->ib_ytext + ib->ib_htext; /* Objekth”he = Iconh”he */
        trans_gimage (tree, obj);         /* Icons an Bildschirm anpassen */
      } /* if */

      if (ob->ob_type == G_IMAGE)
      {
        bi = (BITBLK *)ob->ob_spec;
        ob->ob_height = bi->bi_hl;        /* Objekth”he = Imageh”he */
        trans_gimage (tree, obj);         /* Bit Images an Bildschirm anpassen */
      } /* if */

      xtype = ob->ob_type >> 8;

      switch (xtype)
      {
        case DHEADER    : ob->ob_y -= gl_hbox / 2;
                          break;
        case DCHECKBOX  : check_blk.ub_parm  = ob->ob_spec;
                          ob->ob_y          += y_check;
                          ob->ob_height      = h_check;
#if MSDOS | FLEXOS | DR_C | LATTICE_C | MW_C | TURBO_C  /* LASER C kann es nicht */
                          ob->ob_type        = G_USERDEF;
                          ob->ob_spec        = (LONG)&check_blk;
#endif
                          break;
        case DRBUTTON   : radio_blk.ub_parm  = ob->ob_spec;
                          ob->ob_y          += y_radio;
                          ob->ob_height      = h_radio;
#if MSDOS | FLEXOS | DR_C | LATTICE_C | MW_C | TURBO_C  /* LASER C kann es nicht */
                          ob->ob_type        = G_USERDEF;
                          ob->ob_spec        = (LONG)&radio_blk;
#endif
                          break;
      } /* switch */
    } while (! (ob->ob_flags & LASTOB));
  } /* if */
} /* fix_objs */

/*****************************************************************************/

LOCAL BOOLEAN init_resource ()

{
  STRING s;

  if (! rsrc_load (RSC_NAME))
  {
    strcpy (s, "[3][Resource-File|");
    strcat (s, RSC_NAME);
    strcat (s, "?][ EXIT ]");
    form_alert (1, s);
    return (FALSE);
  } /* if */

  if (gl_hbox > 8) /* high resolution */
    rsrc_gaddr (R_TREE, DIALOGH, &dialog);
  else
    rsrc_gaddr (R_TREE, DIALOGL, &dialog);

  rsrc_gaddr (R_TREE,  USERIMG,  &userimg);
  rsrc_gaddr (R_TREE,  WORKING,  &working);
  rsrc_gaddr (R_TREE,  FSTRINGS, &fstrings);
  rsrc_gaddr (R_FRSTR, ROOT,     &alertmsg);    /* Adresse der Fehlermeldungen */

  fix_objs (dialog, TRUE);
  fix_objs (userimg, FALSE);
  fix_objs (working, FALSE);

  do_state (dialog, DSCREEN, SELECTED);
  do_state (dialog, SBESTFIT, SELECTED);

  return (TRUE);
} /* init_resource */

/*****************************************************************************/

LOCAL WORD hndl_dial (tree, def, x, y, w, h)
OBJECT *tree;
WORD   def;
WORD   x, y, w, h;

{
  WORD xdial, ydial, wdial, hdial;
  WORD exit_obj;

  form_center (tree, &xdial, &ydial, &wdial, &hdial);     /* Mitte berechnen */
  form_dial (FMD_START, x, y, w, h, xdial, ydial, wdial, hdial);
  form_dial (FMD_GROW, x, y, w, h, xdial, ydial, wdial, hdial);

  objc_draw (tree, ROOT, MAX_DEPTH, xdial, ydial, wdial, hdial); /* Zeichnen */
  exit_obj = form_do (tree, def) & 0x7FFF;                         /* Dialog */

  form_dial (FMD_SHRINK, x, y, w, h, xdial, ydial, wdial, hdial);
  form_dial (FMD_FINISH, x, y, w, h, xdial, ydial, wdial, hdial);

  undo_state (tree, exit_obj, SELECTED);       /* Objekt wieder weiá machen */
  return (exit_obj);           /* Objekt, mit dem Dialogbox verlassen wurde */
} /* hndl_dial */

/*****************************************************************************/

LOCAL VOID show_dial (tree)
OBJECT *tree;

{
  WORD xdial, ydial, wdial, hdial;
  WORD x, y, w, h;

  x = y = w = h = 0;

  form_center (tree, &xdial, &ydial, &wdial, &hdial);     /* Mitte berechnen */
  form_dial (FMD_START, x, y, w, h, xdial, ydial, wdial, hdial);
  form_dial (FMD_GROW, x, y, w, h, xdial, ydial, wdial, hdial);

  objc_draw (tree, ROOT, MAX_DEPTH, xdial, ydial, wdial, hdial); /* Zeichnen */
} /* show_dial */

/*****************************************************************************/

LOCAL VOID end_dial (tree)
OBJECT *tree;

{
  WORD xdial, ydial, wdial, hdial;
  WORD x, y, w, h;

  x = y = w = h = 0;

  form_center (tree, &xdial, &ydial, &wdial, &hdial);     /* Mitte berechnen */
  form_dial (FMD_SHRINK, x, y, w, h, xdial, ydial, wdial, hdial);
  form_dial (FMD_FINISH, x, y, w, h, xdial, ydial, wdial, hdial);
} /* end_dial */

/*****************************************************************************/

LOCAL WORD open_work (device)
WORD device;

{
  WORD i;
  WORD handle;

  for (i = 0; i < 103; i++) work_in [i] = 1;

  work_in [0]  = device; /* device handle */
  work_in [10] = RC;     /* Raster Koordinaten */

  if (device == SCREEN)
  {
    handle = phys_handle;
    v_opnvwk (work_in, &handle, work_out); /* virtuell ”ffnen */
  } /* if */
  else                                     /* nicht Bildschirm */
  {
    work_in [11] = OW_NOCHANGE;            /* parallel or serial port */
    v_opnwk (work_in, &handle, work_out);  /* physikalisch ”ffnen */
  } /* else */

  out_device.x = 0;
  out_device.y = 0;
  out_device.w = work_out [0] + 1L;
  out_device.h = work_out [1] + 1L;

  dst_pixel.w = work_out [3];
  dst_pixel.h = work_out [4];

  return (handle);
} /* open_work */

/*****************************************************************************/

LOCAL VOID close_work (device)
WORD device;

{
  switch (device)
  {
    case SCREEN   : v_clsvwk (vdi_handle); break;
    case PLOTTER  :
    case PRINTER  : v_clswk (out_handle);  break;
  } /* switch */
} /* close_work */

/*****************************************************************************/

LOCAL BOOLEAN gdos_ok ()

{
#if GEMDOS
#if TURBO_C | LASER_C
  return (vq_gdos ());
#else
  return (TRUE);
#endif /* TURBO_C */
#else
  return (TRUE);
#endif /* GEMDOS */
} /* gdos_ok */

/*****************************************************************************/

LOCAL VOID get_screen_info (vdi_handle)
WORD vdi_handle;

{
  WORD work_out [57];
  WORD point;
  WORD char_w, char_h, cell_w, cell_h;
  WORD minimum, maximum, width;
  WORD distances [5], effects [3];
  LONG pix_w, pix_h;

  vq_extnd (vdi_handle, FALSE, work_out);

  out_device.x = 0;
  out_device.y = 0;
  out_device.w = work_out [0] + 1L;
  out_device.h = work_out [1] + 1L;

  dst_pixel.w = work_out [3];
  dst_pixel.h = work_out [4];

  vst_font (vdi_handle, FONT_SWISS);
  point = vst_point (vdi_handle, 99, &char_w, &char_h, &cell_w, &cell_h);
  vqt_font_info (vdi_handle, &minimum, &maximum, distances, &width, effects);

  char_h = distances [1] + distances [3] + 1;
  pix_h  = point * 25400L / 72 / char_h;
  pix_w  = pix_h * dst_pixel.w / dst_pixel.h;

  dst_pixel.w = pix_w;
  dst_pixel.h = pix_h;

  vst_font (vdi_handle, FONT_SYSTEM);
} /* get_screen_info */

/*****************************************************************************/

LOCAL VOID wait ()

{
  WORD  msgbuf [8];
  WORD  i;
  UWORD u;

  evnt_multi (MU_KEYBD + MU_BUTTON,
              1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
              msgbuf, 0, 0, &i, &i, &i, &i, &u, &i);
} /* wait */

/*****************************************************************************/

LOCAL VOID flip_word (adr)
REG HPTR adr;

{
  REG UBYTE c;

  c       = adr [0];
  adr [0] = adr [1];
  adr [1] = c;
} /* flip_word */

/*****************************************************************************/

LOCAL VOID flip_long (adr)
REG UWORD HUGE *adr;

{
  REG UWORD w;

  w       = adr [0];
  adr [0] = adr [1];
  adr [1] = w;

  flip_word ((HPTR)&adr [0]);
  flip_word ((HPTR)&adr [1]);
} /* flip_long */

/*****************************************************************************/

LOCAL BOOLEAN read_meta (meta_name)
STRING meta_name;

{
  BOOLEAN ok;

  ok          = FALSE;
  meta_handle = Fopen (meta_name, 0);

#if MSDOS | FLEXOS
  if (DOS_ERR) meta_handle = -32 - meta_handle;
#endif

  if (meta_handle < -3)
    form_alert (1, alertmsg [NOFILE]);
  else
  {
    meta_len    = sizeof (meta_buffer);
    meta_len    = Fread (meta_handle, meta_len, meta_buffer);
    meta_header = (META_HEADER *)meta_buffer;

#if M68000
    {
      REG WORD i;

      for (i = 0; i < meta_len / 2; i++) flip_word ((UBYTE *)&meta_buffer [i]);
    } /* #if */
#endif

    meta_index = meta_header->headlen;
    ok = TRUE;
  } /* else */

  return (ok);
} /* read_meta */

/*****************************************************************************/

LOCAL WORD get_word ()

{
  LONG words;

  if (meta_index == META_BUF) /* fill buffer */
  {
    meta_index = 0;
    words      = Fread (meta_handle, 2L * META_BUF, meta_buffer) / 2;
    if (words == 0) return (-1);

#if M68000
    {
      REG WORD i;

      for (i = 0; i < words; i++) flip_word ((UBYTE *)&meta_buffer [i]);
    } /* #if */
#endif
  } /* if */

  return (meta_buffer [meta_index++]);
} /* get_word */

/*****************************************************************************/

LOCAL BOOLEAN get_code ()

{
  WORD i;

  contrl [0] = get_word ();
  if (contrl [0] == -1) return (FALSE);

  contrl [1] = get_word ();
  contrl [3] = get_word ();
  contrl [5] = get_word ();
  contrl [6] = out_handle;

  n_pts = contrl [1] * 2;
  n_int = contrl [3];

  for (i = 0; i < n_pts; i++) ptsin [i] = get_word ();
  for (i = 0; i < n_int; i++) intin [i] = get_word ();

  return (TRUE);
} /* get_code */

/*****************************************************************************/

LOCAL WORD new_width (width)
WORD width;

{
  width = width * dst_factor * aspect_factor.w;
  if (width == 0) width = 1;

  return (width);
} /* new_width */

/*****************************************************************************/

LOCAL WORD new_height (height)
WORD height;

{
  height = height * dst_factor * aspect_factor.h;
  if (height == 0) height = 1;

  return (height);
} /* new_height */

/*****************************************************************************/

LOCAL VOID transform (flip_x, flip_y)
BOOLEAN flip_x, flip_y;

{
  REG WORD    px, py;
  REG WORD    i, x, y;
      WORD    ix, iy;
      WORD    gdp, n;
      BOOLEAN special;

  for (i = 0; i < contrl [1]; i++)
  {
    ix = 2 * i;
    iy = ix + 1;
    px = ptsin [ix];
    py = ptsin [iy];

    if (contrl [0] == V_GDP)
    {
      gdp = contrl [5];
      n   = -1;

      switch (gdp)
      {
        case V_ARC       :
        case V_PIESLICE  : n = 3;  break;
        case V_CIRCLE    : n = 2;  break;
        case V_ELLIPSE   :
        case V_ELLARC    :
        case V_ELLPIE    :
        case V_JUSTIFIED : n = 1;  break;
        case V_BAR       :
        case V_RBOX      :
        case V_RFBOX     : n = -1; break;
      } /* switch */

      special = (i == n); /* Radius, L„nge */
    } /* if */
    else
    {
      gdp = 0;
      special = FALSE;
    } /* else */

    if (special)
    {
      switch (gdp)
      {
        case V_ARC       :
        case V_PIESLICE  :
        case V_CIRCLE    : px = px * dst.w / src.w; /* Radius */
                           break;
        case V_ELLIPSE   :  /* Transformiere x- und y-Radius */
        case V_ELLARC    :
        case V_ELLPIE    : px = px * dst.w / src.w;
                           py = py * dst.h / src.h;
                           break;
        case V_JUSTIFIED : px = px * dst.w / src.w; /* L„nge */
                           break;
      } /* switch */
    } /* if */
    else /* Bildschirmpunkte */
    {
      px -= origo.x;
      py -= origo.y;

      x = px * dst.w / src.w;
      y = py * dst.h / src.h;

      if (flip_x)
        px = dst.x + dst.w - x;
      else
        px = dst.x + x;

      if (flip_y)
        py = dst.y + dst.h - y;
      else
        py = dst.y + y;
    } /* else */

    ptsin [ix] = px;
    ptsin [iy] = py;
  } /* for */
} /* transform */

/*****************************************************************************/

LOCAL VOID get_header_info (best_fit)
BOOLEAN best_fit;

{
  DOUBLE  x_factor, y_factor;

  if (meta_header->ll_x != 0 ||
      meta_header->ll_y != 0 ||
      meta_header->ur_x != 0 ||
      meta_header->ur_y != 0)
  {
    src.x = min (meta_header->ll_x, meta_header->ur_x);
    src.y = min (meta_header->ll_y, meta_header->ur_y);
    src.w = abs ((LONG)meta_header->ur_x - (LONG)meta_header->ll_x) + 1;
    src.h = abs ((LONG)meta_header->ur_y - (LONG)meta_header->ll_y) + 1;

    if (meta_header->pwidth != 0 || /* page width/height */
        meta_header->pheight != 0)
    {
      src_pixel.w = (DOUBLE)meta_header->pwidth  * 100L / src.w;
      src_pixel.h = (DOUBLE)meta_header->pheight * 100L / src.h;

      aspect_factor.w = src_pixel.w / dst_pixel.w;
      aspect_factor.h = src_pixel.h / dst_pixel.h;
    } /* if */

    meta_header->transform = (meta_header->ll_y > 0) ? RC : NDC;

    origo.x = meta_header->ll_x;

    if (meta_header->transform == NDC)
      origo.y = -meta_header->ll_y;
    else
      origo.y = meta_header->ur_y;
  } /* if */

  if (meta_header->pwidth != 0 || /* page width/height */
      meta_header->pheight != 0)
  {
    dst.x = 0;
    dst.y = 0;
    dst.w = meta_header->pwidth  * 100L / dst_pixel.w;
    dst.h = meta_header->pheight * 100L / dst_pixel.h;

    x_factor = (DOUBLE)out_device.w / dst.w;
    y_factor = (DOUBLE)out_device.h / dst.h;

    if (best_fit) dst_factor = min (x_factor, y_factor);

    dst.w = dst.w * dst_factor;
    dst.h = dst.h * dst_factor;
    dst.x = (out_device.w - dst.w) / 2; /* center picture */
    dst.y = (out_device.h - dst.h) / 2;
  } /* if */
} /* get_header_info */

/*****************************************************************************/

LOCAL VOID show_debug (flip_x, flip_y)
BOOLEAN flip_x, flip_y;

{
  v_enter_cur (phys_handle);
  printf ("src: x = %5ld, y = %5ld, w = %5ld, h = %5ld\n",
  src.x, src.y, src.w, src.h);
  printf ("dst: x = %5ld, y = %5ld, w = %5ld, h = %5ld\n",
  dst.x, dst.y, dst.w, dst.h);
  printf ("out: x = %5ld, y = %5ld, w = %5ld, h = %5ld\n",
  out_device.x, out_device.y, out_device.w, out_device.h);
  printf ("origo: x = %d, y = %d\n", origo.x, origo.y);
  printf ("flip : x = %d, y = %d\n", flip_x, flip_y);
  printf ("more_fonts   = %d\n", more_fonts);
  printf ("dst_factor   = %lf\n", dst_factor);
  printf ("aspect_factor: w = %lf, h = %lf\n", aspect_factor.w, aspect_factor.h);
  printf ("src_pixel    : w = %lf/1000 mm, h = %lf/1000 mm\n", src_pixel.w, src_pixel.h);
  printf ("dst_pixel    : w = %ld/1000 mm, h = %ld/1000 mm\n", dst_pixel.w, dst_pixel.h);
  printf ("Mavail       : %ld\n", Mavail ());
  wait ();
  v_exit_cur (phys_handle);
  v_clrwk (phys_handle);
} /* show_debug */

/*****************************************************************************/

LOCAL VOID new_trnfm (source_planes, s, d)
WORD source_planes;
MFDB *s;
MFDB *d;

{
#if GEMDOS
  REG WORD *src_ptr;
  REG WORD *dst_ptr;
  REG LONG size;
  REG LONG i, planewords;

  if ((source_planes == 1) || (s->np == 1))
    vr_trnfm (vdi_handle, s, d);
  else
  {
    planewords = s->fww * s->fh;
    size       = 2 * planewords * s->np;
    src_ptr    = (WORD *)Malloc (size);
    if (src_ptr == NULL) return;

    dst_ptr = s->mp;
    for (i = 0; i < size / 2; i++) src_ptr [i] = dst_ptr [i];
    s->mp = src_ptr;
    vr_trnfm (vdi_handle, s, d);

    Mfree (src_ptr);
  } /* else */
#else
  vr_trnfm (vdi_handle, s, d);
#endif
} /* new_trnfm */

/*****************************************************************************/

LOCAL VOID show_bit_image (img_header, img_buffer, raster_buf, raster_ptr,
                           plane_ptr, max_lines, screen_planes, fww)
IMG_HEADER *img_header;
HPTR       img_buffer;
HPTR       raster_buf;
HPTR       raster_ptr;
HPTR       *plane_ptr;
WORD       max_lines;
WORD       screen_planes;
WORD       fww;

{
  HPTR  img_ptr;
  HPTR  line_ptr;
  UBYTE line_buf [MAX_LINEBUF];
  LONG  l_buflen;
  WORD  vrc;                    /* vertical replication count */
  WORD  bytecols;               /* counter for planedata */
  UBYTE data;                   /* one byte of pixel data */
  UBYTE pattern [MAX_PATTERNS];
  WORD  max_pattern;
  UWORD length;
  WORD  index [2];
  WORD  idx, count;
  WORD  i, line;
  WORD  plane;
  WORD  fwb;
  MFDB  s, d;
  WORD  pxy [8];

  s.mp  = d.mp  = (VOID *)raster_buf;
  s.fwp = d.fwp = fww * 16;
  s.fh  = d.fh  = max_lines;
  s.fww = d.fww = fww;
  s.ff  = d.ff  = FALSE;
  s.np  = d.np  = screen_planes;

  fwb = fww * 2;

  pxy [0] = 0;
  pxy [1] = 0;
  pxy [2] = s.fwp - 1;
  pxy [3] = s.fh - 1;
  pxy [4] = ((out_device.w - pxy [2] - 1) / 2) & 0xFFF0; /* center picture at word boundaries */
  pxy [5] = (out_device.h - pxy [3] - 1) / 2;
  pxy [6] = pxy [4] + pxy [2];
  pxy [7] = pxy [5] + pxy [3];
  vs_clip (out_handle, TRUE, &pxy [4]);

  index [0] = BLACK;
  index [1] = WHITE;

  l_buflen = (img_header->sl_width + 7) / 8;
  if (l_buflen > MAX_LINEBUF) return;

  line        = 0;
  max_pattern = min (img_header->pat_run, MAX_PATTERNS);
  img_ptr     = img_buffer;

  while (line < max_lines)
  {
    vrc = 1;

    for (plane = 0; plane < img_header->planes; plane++)
    {
      bytecols = l_buflen;
      line_ptr = line_buf;

      while (bytecols > 0)
      {
        data = *img_ptr++;

        switch (data)
        {
          case 0    : /* vertical replication count or pattern run */
                      data = *img_ptr++;

                      if (data == 0) /* vertical replication count */
                      {
                        if (*img_ptr++ == 0xFF) vrc = *img_ptr++;
                      } /* if */
                      else /* pattern run */
                      {
                        bytecols -= data * img_header->pat_run;
                        for (i = 0; i < max_pattern; i++)
                          pattern [i] = img_ptr [i];
                        img_ptr  += img_header->pat_run;

                        while (data > 0)
                        {
                          for (i = 0; i < max_pattern; i++)
                            *line_ptr++ = pattern [i];
                          data--;
                        } /* while */
                      } /* else */
                      break;
          case 0x80 : /* bit string */
                      data = *img_ptr++;
                      bytecols -= data;

                      while (data > 0)
                      {
                        *line_ptr++ = *img_ptr++;
                        data--;
                      } /* while */
                      break;
          default   : /* solid run */
                      length    = data & 0x7F;
                      bytecols -= length;
                      data      = (data & 0x80) ? 0xFF : 0;

                      while (length > 0)
                      {
                        *line_ptr++ = data;
                        length--;
                      } /* while */
                      break;
        } /* switch */
      } /* while */

#if I8086 /* flip words */
      for (i = 0; i < l_buflen / 2; i++) flip_word (&line_buf [i * 2]);
#endif

      idx        = plane % screen_planes;
      raster_ptr = plane_ptr [idx];

      for (count = 0; count < vrc; count++)
      {
        if (line + count < max_lines)
        {
          line_ptr = line_buf;
          for (i = 0; i < l_buflen; i++) *raster_ptr++ |= *line_ptr++;
          if ((l_buflen & 0x1) != 0) raster_ptr++;
        } /* if */
      } /* for */
    } /* for */

    for (i = 0; i < screen_planes; i++) plane_ptr [i] += vrc * fwb;
    line += vrc;
  } /* while */

  new_trnfm (img_header->planes, &d, &s);
  d.mp = NULL; /* screen */

  if (img_header->planes == 1) /* Quellbild in monochrom zeichnen */
    vrt_cpyfm (vdi_handle, MD_REPLACE, pxy, &s, &d, index);
  else /* Quellbild in Farbe zeichnen */
    vro_cpyfm (out_handle, S_ONLY, pxy, &s, &d);
} /* show_bit_image */

/*****************************************************************************/

LOCAL VOID read_bit_image (filename)
STRING filename;

{
  WORD        handle;
  WORD        i, screen_planes;
  WORD        max_lines;
  LONG        max_llines, planesize, l;
  LONG        max_buffer;
  LONG        size_header;
  IMG_HEADER  *img_header;
  XIMG_HEADER x_header;
  BYTE        x_id [5];
  RGB_LIST    rgb_list;
  WORD        rgb [3];
  LONG        colors;
  LONG        img_len;
  HPTR        img_buffer;
  HPTR        raster_buf;
  HPTR        raster_ptr;
  HPTR        plane_ptr [MAX_PLANES];
  LONG        rast_buflen;
  WORD        fww;

  handle = Fopen (filename, 0);

#if MSDOS | FLEXOS
  if (DOS_ERR) handle = -32 - handle;
#endif

  if (handle < -3)
    form_alert (1, alertmsg [NOFILE]);
  else
  {
    size_header = sizeof (XIMG_HEADER);
    Fread (handle, size_header, &x_header);
    img_header = (IMG_HEADER *)&x_header;
    img_buffer = (HPTR)&x_header;

    strncpy (x_id, x_header.x_id, 5);
    x_id [4] = EOS;

#if I8086
    {
      WORD headlen;

      headlen = sizeof (IMG_HEADER) / 2;
      for (i = 0; i < headlen; i++) flip_word (&img_buffer [i * 2]);
    } /* #if */
#endif

    size_header = img_header->headlen * 2;
    colors = 1L << img_header->planes;
    if (colors > 32767) colors = 32767;
    vq_extnd (out_handle, FALSE, work_out); /* get screen colors */
    rgb [0] = 0; /* set to black */
    rgb [1] = 0;
    rgb [2] = 0;
    for (i = colors; i < work_out [13]; i++) vs_color (vdi_handle, i, rgb);

    if ((x_header.headlen > 8) && (strcmp (x_id, "XIMG") == 0))
    {
#if I8086
      flip_word ((UBYTE *)&x_header.color_model);
#endif

      for (i = 0; i < colors; i++)
      {
        Fread (handle, (LONG)sizeof (RGB_LIST), &rgb_list);

#if I8086
        flip_word ((UBYTE *)&rgb_list.red);
        flip_word ((UBYTE *)&rgb_list.green);
        flip_word ((UBYTE *)&rgb_list.blue);
#endif

        rgb [0] = rgb_list.red;
        rgb [1] = rgb_list.green;
        rgb [2] = rgb_list.blue;

        if (x_header.color_model == RGB) vs_color (vdi_handle, i, rgb);
      } /* for */
    } /* if */

    vq_extnd (out_handle, TRUE, work_out);
    screen_planes = work_out [4];
    if (img_header->planes == 1) screen_planes = 1; /* for optimizing */

    fww        = (img_header->sl_width + 15) / 16; /* fww = form width in words */
    max_lines  = img_header->sl_height;
    max_buffer = Mavail ();

    max_llines  = max_buffer / (2L * fww * screen_planes);
    max_lines   = min (max_llines, img_header->sl_height);
    planesize   = 2L * fww * max_lines;
    rast_buflen = planesize * screen_planes;
    raster_buf  = (HPTR)Malloc (rast_buflen);
    raster_ptr  = raster_buf;

    if (raster_buf == NULL)
    {
      form_alert (1, alertmsg [NOMEMORY]);
      return;
    } /* if */

    for (i = 0; i < screen_planes; i++) plane_ptr [i] = raster_buf + i * planesize;
    for (l = 0; l < rast_buflen; l++) raster_buf [l] = 0;

    img_len     = Fseek (0L, handle, 2) - size_header;
    img_buffer  = (HPTR)Malloc (img_len);

    if (img_buffer == NULL)
    {
      Mfree ((FPTR)raster_buf);
      form_alert (1, alertmsg [NOMEMORY]);
      return;
    }
    else
    {
      Fseek (size_header, handle, 0);
      img_len = Fread (handle, img_len, (FPTR)img_buffer); /* read pixel data */

      show_bit_image (img_header, img_buffer, raster_buf, raster_ptr,
                      plane_ptr, max_lines, screen_planes, fww);

      Mfree ((FPTR)img_buffer);
      Mfree ((FPTR)raster_buf);
    } /* else */

    Fclose (handle);
  } /* else */
} /* read_bit_image */

/*****************************************************************************/

LOCAL VOID show_page ()

{
  WORD pxy [4];

  pxy [0] = out_device.x;
  pxy [1] = out_device.y;
  pxy [2] = out_device.x + out_device.w - 1;
  pxy [3] = out_device.y + out_device.h - 1;

  vswr_mode (out_handle, MD_REPLACE);
  vsf_interior (out_handle, FIS_SOLID);
  vsf_color (out_handle, BLACK);
  vr_recfl (out_handle, pxy); /* Bildschirm schwarz fllen */

  pxy [0] = dst.x;
  pxy [1] = dst.y;
  pxy [2] = dst.x + dst.w - 1;
  pxy [3] = dst.y + dst.h - 1;

  vswr_mode (out_handle, MD_REPLACE);
  vsf_interior (out_handle, FIS_SOLID);
  vsf_color (out_handle, WHITE);
  vr_recfl (out_handle, pxy); /* Ausgabegr”áe weiá fllen */
  vs_clip (out_handle, TRUE, pxy);
} /* show_page */

/*****************************************************************************/

LOCAL VOID do_command (device, best_fit, flip_x, flip_y)
WORD    device;
BOOLEAN best_fit;
BOOLEAN flip_x, flip_y;

{
  WORD    i, esc;
  STRING  filename, img_name;

  esc = 0;

  if (contrl [0] == V_ESC) /* Bit-Images nicht direkt auf Bildschirm */
  {
    esc = contrl [5];

    if ((esc == V_BIT_IMAGE) && (device == SCREEN))
    {
      esc = -1;

      for (i = 0; i < contrl [3] - 5; i++) img_name [i] = intin [5 + i];
      img_name [i] = EOS;
      strcpy (filename, img_name);

      if (file_exist (filename))
        read_bit_image (filename);
      else
        form_alert (1, alertmsg [NOFILE]);
    } /* if */
  } /* if */

  switch (contrl [0])
  {
    case V_ESC      :
    case V_PLINE    :
    case V_PMARKER  :
    case V_GTEXT    :
    case V_FILLAREA :
    case V_GDP      :
    case VR_RECFL   :
    case VS_CLIP    : transform (flip_x, flip_y);
                      break;
    case VSL_WIDTH  : ptsin [0] = new_width (ptsin [0]);
                      break;
    case VST_HEIGHT :
    case VSM_HEIGHT :
    case V_TOPBOT   : ptsin [1] = new_height (ptsin [1]);
                      break;
    case VST_POINT  : if ((device == SCREEN) && best_fit) /* use vst_height */
                      {
#if GEMDOS | MSDOS /* FLEXOS kennt den direkten vdi-Aufruf nicht */
                        vdi (); /* do vst_point */
#endif
                        contrl [0] = VST_HEIGHT;
                        contrl [1] = 1;
                        contrl [3] = 0;

                        ptsin [0] = 0;
                        ptsin [1] = dst_factor * ptsout [1];
                        if (ptsin [1] == 0) ptsin [1] = 1;
                      } /* if */
                      else
                        intin [0] = dst_factor * intin [0];
                      break;
  } /* switch */

#if GEMDOS | MSDOS /* FLEXOS kennt den direkten vdi-Aufruf nicht */
  if (esc >= 0) vdi ();
#endif
} /* do_command */

/*****************************************************************************/

LOCAL VOID show_meta (device, best_fit, usr_break)
WORD    device;
BOOLEAN best_fit;
BOOLEAN usr_break;

{
  WORD    command;
  WORD    minmax [4];
  BOOLEAN flip_x, flip_y;
  BOOLEAN ok;
  WORD    mx, my, mstate, kstate;

  src_pixel.w     = dst_pixel.w;
  src_pixel.h     = dst_pixel.h;
  aspect_factor.w = 1.0;
  aspect_factor.h = 1.0;
  dst_factor      = 1.0;
  origo.x         = 0;
  origo.y         = 0;

  src.x = 0;
  src.y = 0;
  src.w = 32768L;
  src.h = 32768L;

  dst.x = out_device.x;
  dst.y = out_device.y;
  dst.w = out_device.w;
  dst.h = out_device.h;

  minmax [0] = dst.x;
  minmax [1] = dst.y;
  minmax [2] = dst.w - 1;
  minmax [3] = dst.h - 1;

  vs_clip (out_handle, TRUE, minmax);
  get_header_info (best_fit);

  flip_x = FALSE;
  flip_y = meta_header->transform != RC;

  if (device != SCREEN)
  {
    if (meta_header->pwidth < meta_header->pheight)
      v_orient (out_handle, OR_PORTRAIT);
    else
      v_orient (out_handle, OR_LANDSCAPE);
  } /* else */

#if DEBUG
  show_debug (flip_x, flip_y);
#endif /* DEBUG */

#if GEMDOS
  vq_extnd (out_handle, FALSE, work_out); /* get screen colors */
  if (work_out [13] == 2) /* show page only on monochrome monitors on ATARI ST */
#endif
  if ((device == SCREEN) && (meta_header->bit_image != 1)) show_page ();

  command = 0;
  ok      = TRUE;

  while (get_code () && ok)
  {
    command++;
    do_command (device, best_fit, flip_x, flip_y);

    if ((device == SCREEN) && usr_break)
    {
      graf_mkstate (&mx, &my, &mstate, &kstate);

      if (kstate & (K_LSHIFT | K_RSHIFT)) ok = FALSE;
      if (kstate & K_ALT) wait ();
      while (kstate & K_CTRL) graf_mkstate (&mx, &my, &mstate, &kstate);
    } /* if */
  } /* while */

  v_updwk (out_handle);
} /* show_meta */

/*****************************************************************************/

LOCAL BOOLEAN select_file (name, suffix, filename)
BYTE *name, *suffix, *filename;

{
  WORD i;
  BYTE s [80];

  if (*suffix)                          /* Suffix „ndern */
  {
    i = strlen (fs_iinpath);
    while (fs_iinpath [i] != PATHSEP) i--;
    fs_iinpath [i + 1] = EOS;
    strcat (fs_iinpath, suffix);
  } /* if */

  name [12] = EOS;
  if (*name) strcpy (fs_iinsel, name);  /* Default-Name */
  fsel_input (fs_iinpath, fs_iinsel, &fs_iexbutton);

  strcpy (s, fs_iinpath);               /* Path aufbereiten */
  i = strlen (s);
  while (s [i] != PATHSEP) i--;
  s [i + 1] = EOS;

  if (*fs_iinsel)
  {
    strcpy (filename, s);
    strcat (filename, fs_iinsel);
  } /* if */
  else
  {
    filename [0] = EOS;                 /* Keinen Dateinamen gew„hlt */
    fs_iexbutton = 0;                   /* Abbruch */
  } /* else */

  return (fs_iexbutton != 0);
} /* select_file */

/*****************************************************************************/

GLOBAL WORD main ()

{
  WORD     i, len;
  WORD     device;
  WORD     sel_device;
  WORD     exit_obj;
  WORD     rgb [3];
  BOOLEAN  best_fit, ok;
  BOOLEAN  usr_break;
  BYTE     filename [13];
  WORD     act_drive, drive;
  STRING   act_path, s;
  STRING   info_string;
  ICONBLK  *iconblk;

  i = appl_init ();                       /* Applikationsnummer besorgen */

#if (LATTICE_C | TURBO_C) | (GEM & (GEM2 | GEM3 | XGEM))
  gl_apid = i;                            /* gl_apid nicht extern */
#endif

  phys_handle = graf_handle (&gl_wbox, &gl_hbox, &gl_wattr, &gl_hattr); /* Handle des Bildschirms */
  vdi_handle  = open_work (SCREEN);

  if (init_resource ())
  {
    for (i = 0; i < MAX_DRIVERS; i++)
    {
      strcpy (drv_names [i], (BYTE *)fstrings [NSCREEN + i].ob_spec);
      iconblk = (ICONBLK *)dialog [DSCREEN + i].ob_spec;
      len     = strlen (iconblk->ib_ptext);
#if GEM & GEM3
      v_get_driver_info (drivers [i], DRV_NAMES, (UBYTE *)info_string);
#endif
      if (*info_string)
        strcpy (s, info_string);
      else
        strcpy (s, drv_names [i]);

      s [len] = EOS;
      strcpy (iconblk->ib_ptext, s);
    } /* for */

    act_drive = Dgetdrv ();
    get_path (act_path, 0);

    sprintf (fs_iinpath, "A:%s*.GEM", act_path);
    fs_iinpath [0] += Dgetdrv ();           /* Standard-Laufwerk */
    fs_iinsel [0]   = EOS;                  /* Leerer Dateiname */
    strcpy (meta_name, "");
    strcpy (filename, "");

    while (select_file (filename, "*.GEM", meta_name) && *meta_name)
    {
      ok = FALSE;

      file_split (fs_iinpath, &drive, s, NULL, NULL);
      Dsetdrv (drive);
      set_path (s);

      if (file_exist (meta_name))
      {
        strcpy ((BYTE *)dialog [FILENAME].ob_spec, fs_iinsel);
        exit_obj = hndl_dial (dialog, 0, 0, 0, 0, 0);
        if (exit_obj == DSTART) ok = TRUE;
      } /* if */
      else
        form_alert (1, alertmsg [NOFILE]);

      graf_mouse (M_OFF, NULL);

      if (ok && read_meta (meta_name))
      {
        best_fit  = (dialog [SBESTFIT].ob_state & SELECTED) != 0;
        usr_break = (dialog [DSTOP].ob_state & SELECTED) != 0;

        for (i = 0; i < 4; i++)
          if (dialog [DSCREEN + i].ob_state & SELECTED) sel_device = i + 1;

        switch (sel_device)
        {
          case 1  : device = SCREEN;  break;
          case 2  : device = PLOTTER; break;
          case 3  : device = PRINTER; break;
          case 4  : device = CAMERA;  break;
          default : device = 0;       break;
        } /* switch */

        if (device > 0)
        {
          switch (device)
          {
            case SCREEN   : out_handle = vdi_handle;
                            v_clrwk (out_handle); /* Bildschirm l”schen */
                            break;
            case PLOTTER  :
            case PRINTER  :
            case CAMERA   : out_handle = open_work (device);
                            break;
          } /* switch */

          if (out_handle == 0)
          {
            graf_mouse (M_ON, NULL);
            form_alert (1, alertmsg [NODEVICE]);
            graf_mouse (M_OFF, NULL);
          } /* if */
          else
          {

            if (gdos_ok ()) more_fonts = vst_load_fonts (out_handle, 0);

            if (device == SCREEN)
              get_screen_info (out_handle); /* geladene Fonts benutzen */
            else
            {
              v_clrwk (vdi_handle);
              show_dial (working);
            } /* else */

            show_meta (device, best_fit, usr_break);

            if (device != SCREEN) end_dial (working);
            if (gdos_ok ()) vst_unload_fonts (out_handle, 0);

            switch (device)
            {
              case SCREEN   : wait ();             break;
              case PLOTTER  :
              case PRINTER  :
              case CAMERA   : close_work (device); break;
            } /* switch */
          } /* else */
        } /* if */

        Fclose (meta_handle);
      } /* if */

      for (i = 0; i < MAX_COLORS; i++)
      {
        rgb [0] = gem_colors [i].red;
        rgb [1] = gem_colors [i].green;
        rgb [2] = gem_colors [i].blue;

        vs_color (vdi_handle, i, rgb);
      } /* for */

      v_clrwk (vdi_handle);
      graf_mouse (M_ON, NULL);
    } /* while */

    rsrc_free ();
    Dsetdrv (act_drive);
    set_path (act_path);
  } /* if */

  close_work (SCREEN);
  appl_exit ();
  return (0);
} /* main */
