/*****************************************************************************
 *
 * Module : CONTROLS.C
 * Author : Dieter Geiû
 *
 * Creation date    : 10.08.93
 * Last modification: 05.04.97
 *
 *
 * Description: This module implements the custom controls.
 *
 * History:
 * 05.04.97: 2 colored checkboxes/radio buttons can be drawn transparently or opaque
 * 10.01.97: 2 colored checkboxes/radio buttons are being drawn transparently
 * 28.11.95: Error in lb_keyboard fixed when using keyboard with HLB listboxes
 * 23.10.95: DrawImageButton added
 * 20.10.95: ListBoxDraw and ListBox_Draw added
 * 12.10.95: Window handle of vertical scrollbar of listbox is also set in ListBox_SetWindowHandle
 * 14.08.95: Parameters in function InitControls added
 * 12.08.95: Using default background color for 3d objects, leaving possibility for own background color
 * 09.07.95: MAX_USERBLK increased
 * 29.01.95: Call to draw_3d in Draw3DBox corrected when drawing b/w inside or outside rects
 * 26.01.95: Problem with drawing of horizontal scrollbar fixed
 * 01.01.95: ListBox_... functions added
 * 31.12.94: Function DrawComboBox added
 * 19.12.94: Listboxes are using a scrollbar object
 * 17.12.94: 3d boxes are using a black border if dlg_colors < 16
 * 14.12.94: Scrollbar implementation added
 * 17.11.94: Color icons supported
 * 12.10.94: Function draw_owner_text added
 * 18.07.94: Parameters round and shadow_width in DrawButton added
 * 17.07.94: Parameter vdi_handle in Draw... functions added
 * 16.07.94: Accelerator lines will only be drawed if inx > 0 in draw_acc_line
 * 24.05.94: Using of btn_round_borders and btn_shadow_width added
 * 25.04.94: Variable use_adapt initialized in GLOBAL.C
 * 23.03.94: #ifndef DRIVESEP no longer neccessary
 * 17.03.94: Functions DrawString and Draw3DBox added
 * 13.03.94: Functions DrawButton and DrawGroupBox added
 * 12.03.94: Function DrawCheckRadio added
 * 14.11.93: Function keys using system color for text
 * 03.11.93: Using same buffer for monochrome bitmaps in conv_img
 * 02.11.93: No longer using large stack variables in lb_draw
 * 01.11.93: ListboxSetTabstops added
 * 30.10.93: Listbox background color added
 * 28.10.93: Adaption for multicolor icons added
 * 24.10.93: Problem in sb_calc_rect with LBC_PGUP fixed
 * 20.10.93: Listbox fits into desktop if too large in combobox_click
 * 17.10.93: ListBoxSetComboRect improved to allow standard rectangle
 * 16.10.93: Functions ListBoxSendMessage and draw_owner_multi_icon added
 * 15.10.93: Variable planes used
 * 10.10.93: Checkboxes and radio buttons react correctly on objc_change
 * 07.10.93: Function draw_owner_color and draw_owner_pattern added
 * 05.09.93: Different flavors of checkboxes, radio buttons and arrows added
 * 03.09.93: Variable sys_colors used to draw elements
 * 02.09.93: Functions build_icon, free_icon, and draw_owner_icon added
 * 29.09.93: Problem in lb_click with wind_update fixed
 * 27.09.93: Functions build_image added
 * 20.09.93: Functions ListBoxGetCallback, ListBoxGetWindowHandle, and ListBoxGetFont added
 * 16.09.93: Combobox functionality added
 * 10.09.93: Listbox functionality added
 * 04.09.93: Black line drawn when IS_BORDER and IS_DOUBLELINE
 * 02.09.93: Bitmap button drawing for selected buttons fixed
 * 28.08.93: G_IBOX can have outside border and round borders
 * 25.08.93: Parameter is_dialog removed from fix_tree
 * 10.08.93: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"

#include "files.h"
#include "utility.h"

#include "export.h"
#include "controls.h"

/****** DEFINES **************************************************************/

#define ARROW_SIZE         9            /* width and height of arrows */
#define BUTTON_SIZE       13            /* width and height of checkboxes and radio buttons */
#define BUTTONL_WIDTH     16            /* width and height of low resolution checkboxes and radio buttons */
#define BUTTONL_HEIGHT     8            /* width and height of low resolution checkboxes and radio buttons */
#define DOTS_SIZE         10		/* width and height of dots */

#define ALT_CHAR         '~'

#define MAX_PLANES        32            /* max planes for a bitmap */
#define MAX_PATTERNS       8            /* for pattern run */
#define MAX_LINEBUF     1024            /* max picture width is 8192 pixels */

#define SBC_SLIDER         0            /* scrollbar codes */
#define SBC_UP             1
#define SBC_DOWN           2
#define SBC_PGUP           3
#define SBC_PGDOWN         4
#define SBC_SLIDERAREA     5
#define SBC_PARENT         6

#define WAIT_CLICK         0            /* list ox waiting mode */
#define WAIT_TRACK         1
#define WAIT_SCROLL        2
#define WAIT_SLIDER        3

#define DEF_PAGESCROLL    11		/* default pagesize to scroll if pagesize less than or equal one */

#define STATE_BUTTON    (BS_BMBUTTON | BS_GROUPBOX | BS_CHECKBOX | BS_FUNCTION | BS_COMBOBOX) /* any extended G_BUTTON state */

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
  SB_CALLBACK callback;			/* Callback-Funktion */
  WORD        wh;			/* Fenster-Handle des Schiebers (falls in Fenster) */
  OBJECT      *tree;			/* Objektbaum des Schiebers */
  WORD        obj;			/* Objektnummer des Schiebers */
  UWORD       style;			/* Stil des Schiebers */
  RECT        rc_obj;			/* Aktuelles Rechteck des Objekts */
  WORD        pix_size; 		/* Grîûe des Schiebers in Pixel */
  WORD        pix_pos;			/* Position des Schiebers in Pixel */
  WORD        bk_color;			/* Farbe des Hintergrundes */
  LONG        count;			/* Anzahl Positionen */
  LONG        pagesize;			/* Anzahl Positionen beim seitenweisen scrollen */
  LONG        pos;			/* Position */
  LONG        spec;                     /* FÅr speziellen Gebrauch */
  BOOLEAN     uparrow_selected;		/* Pfeil nach oben/links selektiert */
  BOOLEAN     downarrow_selected;	/* Pfeil nach unten/rechts selektiert */
} SCROLLBAR;

typedef struct
{
  LB_CALLBACK callback;			/* Callback-Funktion */
  WORD        wh;			/* Fenster-Handle der Listbox (falls in Fenster) */
  OBJECT      *tree;			/* Objektbaum der Listbox */
  WORD        obj;			/* Objektnummer der Listbox */
  RECT        rc_obj;                   /* Aktuelles Rechteck des Objekts */
  WORD        y_alternate;              /* Y-Alternative, falls nicht ganz in Desktop passend */
  BYTE        **items; 			/* Liste aller EintrÑge */
  UWORD       style;			/* Stil der Listbox */
  SCROLLBAR   vsb;			/* Vertikaler Schieber */
  BOOLEAN     vsb_vis;                  /* Vertikaler Schieber sichtbar */
  WORD        vsb_size;			/* Grîûe des vertikalen Schiebers */
  LONG        vsb_oldpos;		/* Letze Position vor dem Scrollen */
  BOOLEAN     has_focus;		/* Hat Focus */
  BOOLEAN     is_combobox;              /* Ist Listbox einer Combobox */
  WORD        item_height; 		/* Hîhe eines Eintrags */
  WORD        left_offset;              /* Platz zum linken Rand */
  WORD        font;			/* Font der EintrÑge */
  WORD        point;			/* Fontgrîûe der EintrÑge */
  UWORD       effects;			/* Effekte des Fonts */
  WORD        color;			/* Farbe des Fonts */
  WORD        bk_color;			/* Farbe des Hintergrundes */
  LONG        spec;                     /* FÅr speziellen Gebrauch */
  LONG        sel_item;			/* Selektierter Eintrag in Listbox */
  SET         sel_set;			/* Selektierte EintrÑge (bei Mehrfachauswahl) */
  WORD        num_tabs;			/* Anzahl Tabulatoren */
  WORD        tabs [LBT_MAX_TABS];	/* Tabulatoren (Pixel) */
  WORD        tabstyles [LBT_MAX_TABS];	/* Tabulator-Stile */
} LISTBOX;

typedef struct				/* from xrscfix */
{
  USERBLK ublk;
  UWORD   old_type;
} OBBLK;

/****** VARIABLES ************************************************************/

#include "arrows1.h"
#include "buttonsl.h"
#include "buttons1.h"
#include "buttons4.h"
#include "dots1.h"

LOCAL USRBLK  *usrblk;                  /* user defined objects */
LOCAL WORD    num_usrblk;               /* number of used usrblks */
LOCAL WORD    max_userblk;              /* max number of userblks */

LOCAL OBBLK   *obblk;                   /* usrblks for color icons */
LOCAL CICON   *cicon_table;             /* color cion table */
LOCAL WORD    num_cicon;                /* number of color icons */
LOCAL WORD    max_cicon;                /* max number of color icons */

LOCAL BMBUTTON *bmbutton;               /* bitmap buttons */
LOCAL WORD     max_bmbutton;            /* number of bitmap buttons */

LOCAL WORD    farbtbl[256][32];		/* from xrscrfix */
LOCAL ULONG   farbtbl2[32];
LOCAL WORD    is_palette;
LOCAL WORD    rgb_palette[256][4];
LOCAL WORD    xpixelbytes;
LOCAL WORD    xscrn_planes;

LOCAL UBYTE   *arrows1_buf;             /* raster buffer for 1 planed arrows */
LOCAL UBYTE   *buttonsl_buf;            /* raster buffer for 1 planed low resolution check boxes and radio buttons */
LOCAL UBYTE   *buttons1_buf;            /* raster buffer for 1 planed check boxes and radio buttons */
LOCAL UBYTE   *buttons4_buf;            /* raster buffer for 4 planed check boxes and radio buttons */
LOCAL UBYTE   *dots1_buf;               /* raster buffer for 1 planed dots */

LOCAL WORD    arrows_width;             /* width of arrows image */
LOCAL WORD    arrows_height;            /* height of arrows image */
LOCAL WORD    arrows_planes;            /* planes of arrows image */

LOCAL WORD    buttons_width;            /* width of buttons image */
LOCAL WORD    buttons_height;           /* height of buttons image */
LOCAL WORD    buttons_planes;           /* planes of buttons image */

LOCAL WORD    buttonsl_width;           /* width of low resolution buttons image */
LOCAL WORD    buttonsl_height;          /* height of low resolution buttons image */
LOCAL WORD    buttonsl_planes;          /* planes of low resultion buttons image */

LOCAL WORD    dots_width;               /* width of dots image */
LOCAL WORD    dots_height;              /* height of dots image */
LOCAL WORD    dots_planes;              /* planes of dots image */

LOCAL OBJECT  combobox =                /* list box of combo box */
{
  -1, -1, -1, G_BOX, LASTOB, XS_LISTBOX, 0x00FF1100L, 0, 0, 21 ,6
};

/****** FUNCTIONS ************************************************************/

#if MSDOS
EXTERN PARMBLK   *fardr_start         (VOID);
EXTERN VOID      fardr_end            (WORD state);
#endif

LOCAL VOID       get_obinfo           (LONG obspec, OBINFO *obinfo);
LOCAL VOID       flip_word            (HPUCHAR adr);
LOCAL VOID       conv_img             (IMG_HEADER *img_header, HPUCHAR img_buffer, HPUCHAR raster_buffer, HPUCHAR trans_buffer, HPUCHAR *plane_ptr, WORD max_lines, WORD raster_planes, WORD fww);
LOCAL WORD       find_bmbutton        (BYTE *name);
LOCAL VOID       draw_acc_line        (WORD vdi_handle, WORD x, WORD y, BYTE *text, WORD inx, BOOLEAN disabled, WORD dlg_colors, WORD color, WORD bk_color);
LOCAL VOID       draw_owner_text      (WORD vdi_handle, LB_OWNERDRAW *lb_ownerdraw, BYTE *text, WORD x, WORD y, WORD *xy);
LOCAL VOID       tabbed_text          (WORD vdi_handle, WORD x, WORD y, BYTE *text, WORD num_tabs, WORD *tabs, WORD *tabstyles);

LOCAL VOID       lb_redraw            (LISTBOX *lb, RECT *rc_area);
LOCAL VOID       lb_draw_items        (LISTBOX *lb, RECT *rc_obj, WORD from, WORD to);
LOCAL BOOLEAN    lb_visible           (LISTBOX *lb, RECT *rc_obj);
LOCAL LONG       lb_click             (LISTBOX *lb, MKINFO *mkinfo);
LOCAL VOID       lb_key               (LISTBOX *lb, MKINFO *mkinfo);
LOCAL LONG       lb_comboclick        (LISTBOX *lb, MKINFO *mkinfo);
LOCAL LONG       lb_find_item         (LISTBOX *lb, WORD mox, WORD moy, BOOLEAN scroll, WORD *dir);
LOCAL LONG       lb_keyboard          (LISTBOX *lb, MKINFO *mk);
LOCAL LONG       lb_hndl_scroll       (LISTBOX *lb, MKINFO *mk, LONG olditem, LONG item);
LOCAL VOID       lb_scroll            (LISTBOX *lb, LONG old_pos, LONG new_pos);
LOCAL VOID       lb_change            (LISTBOX *lb, LONG item);

LOCAL LISTBOX    *lb_from_obj         (OBJECT *tree, WORD obj, BOOLEAN calc_rect);
LOCAL LONG       sb_callback          (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p);

LOCAL VOID       sb_redraw            (SCROLLBAR *sb, RECT *rc_area);
LOCAL LONG       sb_click             (SCROLLBAR *sb, MKINFO *mkinfo);
LOCAL VOID       sb_key               (SCROLLBAR *sb, MKINFO *mkinfo);
LOCAL WORD       sb_calc_pix_pos      (SCROLLBAR *sb);
LOCAL WORD       sb_calc_pix_size     (SCROLLBAR *sb);
LOCAL LONG       sb_calc_pos          (SCROLLBAR *sb, WORD slide_value);
LOCAL VOID       sb_calc_rect         (SCROLLBAR *sb, WORD which, RECT *r, WORD *xy, WORD inflate, WORD offset);
LOCAL WORD       sb_find_obj          (SCROLLBAR *sb, WORD x, WORD y);
LOCAL VOID       sb_slide             (SCROLLBAR *sb, MKINFO *mk, WORD slider);
LOCAL VOID       sb_arrows            (SCROLLBAR *sb, WORD dir, WORD x, WORD y);
LOCAL VOID       sb_scroll            (SCROLLBAR *sb, LONG old_pos, LONG new_pos);
LOCAL BOOLEAN    sb_visible           (SCROLLBAR *sb, RECT *rc_obj);
LOCAL WORD       sb_slide_box         (SCROLLBAR *sb);
LOCAL VOID       sb_change            (SCROLLBAR *sb, WORD slider);

LOCAL SCROLLBAR  *sb_from_obj         (OBJECT *tree, WORD obj, BOOLEAN calc_rect);

LOCAL VOID       draw_box             (RECT *box);
LOCAL VOID       fix_box              (RECT *box, RECT *bound);
LOCAL VOID       clear_rect           (CONST RECT *rect, WORD color);
#if MSDOS
LOCAL WORD       draw_listbox         (VOID);
LOCAL WORD       draw_combobox        (VOID);
LOCAL WORD       draw_scrollbar       (VOID);
LOCAL WORD       draw_3d_box          (VOID);
LOCAL WORD       draw_string          (VOID);
LOCAL WORD       draw_checkradio      (VOID);
LOCAL WORD       draw_groupbox        (VOID);
LOCAL WORD       draw_button          (VOID);
LOCAL WORD       draw_bmbutton        (VOID);
#else
LOCAL WORD CDECL draw_listbox         (PARMBLK *pb);
LOCAL WORD CDECL draw_combobox        (PARMBLK *pb);
LOCAL WORD CDECL draw_scrollbar       (PARMBLK *pb);
LOCAL WORD CDECL draw_3d_box          (PARMBLK *pb);
LOCAL WORD CDECL draw_string          (PARMBLK *pb);
LOCAL WORD CDECL draw_checkradio      (PARMBLK *pb);
LOCAL WORD CDECL draw_groupbox        (PARMBLK *pb);
LOCAL WORD CDECL draw_button          (PARMBLK *pb);
LOCAL WORD CDECL draw_bmbutton        (PARMBLK *pb);
#endif

LOCAL WORD       xadd_cicon           (CICONBLK *cicnblk, OBJECT *obj, WORD nub);
LOCAL VOID       draw_bitblk          (WORD *p, WORD x, WORD y, WORD w, WORD h, WORD num_planes, WORD mode, WORD *index);
LOCAL VOID       xfix_cicon           (UWORD *col_data, LONG len, WORD old_planes, WORD new_planes, MFDB *s);
LOCAL VOID       std_to_byte          (UWORD *col_data, LONG len, WORD old_planes, ULONG *farbtbl2, MFDB *s);
LOCAL VOID       xrect2array          (CONST GRECT *rect, WORD *array);
LOCAL WORD       test_rez             (VOID);
LOCAL VOID       xfill_farbtbl        (VOID);
LOCAL WORD CDECL xdraw_cicon          (PARMBLK *pb);

/*****************************************************************************/

GLOBAL BOOLEAN InitControls (WORD wMaxUserBlk, WORD wMaxColorIcon, WORD wMaxBitmapButton, BMBUTTON *pBitmapButton)
{
  WORD     i;
  BMBUTTON *bm;

  max_userblk  = wMaxUserBlk;
  max_cicon    = wMaxColorIcon;
  max_bmbutton = wMaxBitmapButton;
  bmbutton     = pBitmapButton;

  usrblk       = mem_alloc (max_userblk * sizeof (USRBLK));
  obblk        = mem_alloc (max_cicon * sizeof (OBBLK));
  cicon_table  = mem_alloc (max_cicon * sizeof (CICON));

  arrows1_buf  = BuildImg (arrows1, &arrows_width, &arrows_height, &arrows_planes);
  buttonsl_buf = BuildImg (buttonsl, &buttonsl_width, &buttonsl_height, &buttonsl_planes);
  buttons1_buf = BuildImg (buttons1, &buttons_width, &buttons_height, &buttons_planes);
  buttons4_buf = BuildImg (buttons4, &buttons_width, &buttons_height, &buttons_planes);
  dots1_buf    = BuildImg (dots1, &dots_width, &dots_height, &dots_planes);

  for (i = 0; i < max_bmbutton; i++)
  {
    bm = &bmbutton [i];

    bm->n1.dd_buffer = BuildImg (bm->n1.di_buffer, &bm->width, &bm->height, NULL);
    bm->s1.dd_buffer = BuildImg (bm->s1.di_buffer, &bm->width, &bm->height, NULL);
    bm->d1.dd_buffer = BuildImg (bm->d1.di_buffer, &bm->width, &bm->height, NULL);

    if (colors >= 16)
    {
      bm->n4.dd_buffer = BuildImg (bm->n4.di_buffer, &bm->width, &bm->height, NULL);
      bm->s4.dd_buffer = BuildImg (bm->s4.di_buffer, &bm->width, &bm->height, NULL);
      bm->d4.dd_buffer = BuildImg (bm->d4.di_buffer, &bm->width, &bm->height, NULL);
    } /* if */
  } /* for */

  FixTree (&combobox);

  return ((arrows1_buf != NULL) && (buttonsl_buf != NULL) && (buttons1_buf != NULL) && (buttons4_buf != NULL) && (dots1_buf != NULL) && (usrblk != NULL) && (obblk != NULL) && (cicon_table != NULL));
} /* InitControls */

/*****************************************************************************/

GLOBAL BOOLEAN TermControls (VOID)
{
  WORD i;

  mem_free (usrblk);
  mem_free (obblk);
  mem_free (cicon_table);

  mem_free (arrows1_buf);
  mem_free (buttonsl_buf);
  mem_free (buttons1_buf);
  mem_free (buttons4_buf);
  mem_free (dots1_buf);

  for (i = 0; i < max_bmbutton; i++)
  {
    mem_free (bmbutton [i].n1.dd_buffer);
    mem_free (bmbutton [i].s1.dd_buffer);
    mem_free (bmbutton [i].d1.dd_buffer);
    mem_free (bmbutton [i].n4.dd_buffer);
    mem_free (bmbutton [i].s4.dd_buffer);
    mem_free (bmbutton [i].d4.dd_buffer);
  } /* for */

  return (TRUE);
} /* TermControls */

/*****************************************************************************/

GLOBAL VOID FixTree (OBJECT *tree)
{
  WORD       obj, index;
  OBJECT     *ob;
  ICONBLK    *ib;
  BITBLK     *bi;
  BOOLEAN    hires;
  UWORD      type, i;
  BYTE       *p;
  BMBUTTON   *bm;
  IMG_HEADER *img_header;
  LISTBOX    *lb;
  SCROLLBAR  *sb;
  USRBLK     *usrblkp;
  STRING     alert;

  if (tree != NULL)
  {
    hires = (gl_hbox > 8) ? TRUE : FALSE;
    obj   = NIL;

    do
    {
      if (num_usrblk >= max_userblk)
      {
        strcpy (alert, "[3][Please increase MAX_USERBLK|in call to CONTROLS.C!][ EXIT ]");
        beep ();
        form_alert (1, alert);
        exit (255);
      } /* if */

      ob   = &tree [++obj];
      type = ob->ob_type & 0xFF;

#if GEM & (GEM2 | GEM3 | XGEM)
      if ((type == G_STRING) && (ob->ob_state & DISABLED))
      {
        BYTE *s;

        for (s = get_str (tree, obj); *s; s++)
          if (*s == 0x13) *s = '-';
      } /* if */
#endif

      if ((type == G_BUTTON) || (type == G_STRING))
      {
        p = (BYTE *)ob->ob_spec;

        if (strchr (p, ALT_CHAR) != NULL) /* alternate control char */
        {
          for (i = 0; p [i] != ALT_CHAR; i++);

          ob->ob_type |= (i + 1) << 8;    /* Position merken */

          if ((type == G_STRING) || (type == G_BUTTON) && (ob->ob_state & BS_CHECKBOX))
            ob->ob_width -= gl_wbox;

          strcpy (p + i, p + i + 1);      /* Zeichen rauslîschen */
        } /* if */
      } /* if */

      if ((type == G_CICON) && (planes <= 8))	/* MAGIC has it's own routines, but not everybody has MAGIC, so use only with more than 256 colors */
      {
        if (num_cicon == 0)
        {
          xscrn_planes = planes;
          xfill_farbtbl ();
          xpixelbytes = test_rez ();
        } /* if */

        if (num_cicon >= max_cicon)
        {
          strcpy (alert, "[3][Please increase MAX_CICON|in call to CONTROLS.C!][ EXIT ]");
          beep ();
          form_alert (1, alert);
          exit (255);
        } /* if */

        if (! xadd_cicon ((CICONBLK *)ob->ob_spec, ob, num_cicon++))
        {
          memset (&cicon_table [num_cicon - 1], 0, sizeof (CICON));
          ob->ob_type = G_ICON | (ob->ob_type & 0xFF00);
        } /* if */
      } /* if */

      if ((type == G_USERDEF) && (get_ob_type (tree, obj) == G_CICON))	/* Falls Åber xrsc_load geladen */
      {
        ib = (ICONBLK *)get_ob_spec (tree, obj);
        ob->ob_height = ib->ib_ytext + ib->ib_htext; /* Objekthîhe = Iconhîhe */
      } /* if */

      if ((type == G_ICON) || (type == G_CICON))
      {
        ib = (ICONBLK *)get_ob_spec (tree, obj);
        ob->ob_height = ib->ib_ytext + ib->ib_htext; /* Objekthîhe = Iconhîhe */
        trans_gimage (tree, obj);         /* Icons an Bildschirm anpassen */
      } /* if */

      if (type == G_IMAGE)
      {
        bi = (BITBLK *)get_ob_spec (tree, obj);
        ob->ob_height = bi->bi_hl;        /* Objekthîhe = Imagehîhe */
        trans_gimage (tree, obj);         /* Bit Images an Bildschirm anpassen */
      } /* if */

#if MSDOS | FLEXOS
      if (type == G_FBOXTEXT)
        ob->ob_height += 2;
#endif

      if (OB_STATE (tree, obj) & DRAW3D)
        ob->ob_y -= gl_hbox / 2;

      if (OB_STATE (tree, obj) & WHITEBAK)              /* half height box */
      {
        ob->ob_height -= gl_hbox / 2;
        if (! hires) ob->ob_height--;
      } /* if */

      if (type == G_BOX)
      {
        if (ob->ob_state & XS_DLGBKGND)
          if (dlg_colors >= 16)
          {
            if (obj == ROOT)
              undo_state (tree, ROOT, OUTLINED);

            ob->ob_spec = 0x00001170L | sys_colors [COLOR_DIALOG];	/* set background color to light gray */
          } /* if */
          else
          {
            if (obj == ROOT)
              do_state (tree, ROOT, OUTLINED);

            ob->ob_spec = 0x00021100L;					/* set background color to white */
          } /* else, if */

        if (ob->ob_state & XS_GRAYBKGND)
          if (dlg_colors >= 16)
            ob->ob_spec = (ob->ob_spec & 0xFFFFFF80L) | 0x00000070L | sys_colors [COLOR_DIALOG];
          else
            ob->ob_spec = (ob->ob_spec & 0xFFFFFF80L) | 0x00000000L;

        if (ob->ob_state & XS_LISTBOX)
        {
          usrblkp                   = &usrblk [num_usrblk++];
          usrblkp->userblk.ub_code  = draw_listbox;
          usrblkp->userblk.ub_parm  = (LONG)ob->ob_spec;
          usrblkp->ob_type          = type;
          ob->ob_type               = G_USERDEF | (ob->ob_type & 0xFF00);
          ob->ob_spec               = (LONG)usrblkp;
          ob->ob_x                 -= 2;                /* room for border */
          ob->ob_y                 -= 2;
          ob->ob_width             += 4;
          ob->ob_height            += 4;
          usrblkp->spec             = mem_alloc (sizeof (LISTBOX));
          lb                        = usrblkp->spec;

          mem_set (lb, 0, sizeof (LISTBOX));

          lb->wh            = FAILURE;
          lb->tree          = tree;
          lb->obj           = obj;
          lb->rc_obj.x      = ob->ob_x;
          lb->rc_obj.y      = ob->ob_y;
          lb->rc_obj.w      = ob->ob_width;
          lb->rc_obj.h      = ob->ob_height;
          lb->style         = LBS_VSCROLL | LBS_VREALTIME | LBS_MANDATORY;
          lb->item_height   = gl_hbox;
          lb->left_offset   = gl_wbox;
          lb->font          = FAILURE;
          lb->point         = FAILURE;
          lb->effects       = (UWORD)FAILURE;
          lb->color         = FAILURE;
          lb->bk_color      = FAILURE;
          lb->sel_item      = FAILURE;
          lb->vsb_size      = gl_wattr;

          lb->vsb.callback  = sb_callback;
          lb->vsb.wh        = FAILURE;
          lb->vsb.tree      = (OBJECT *)lb;	/* so I can get my listbox at callback time */
          lb->vsb.obj       = NIL;
          lb->vsb.rc_obj    = lb->rc_obj;
          lb->vsb.rc_obj.x += lb->rc_obj.w - (lb->vsb_size + 2);
          lb->vsb.rc_obj.w  = lb->vsb_size + 2; 
          lb->vsb.style     = SBS_VERTICAL | SBS_REALTIME | SBS_NO3DBORDER;
          lb->vsb.bk_color  = FAILURE;
          lb->vsb.count     = 0;
          lb->vsb.pagesize  = 1;
          lb->vsb.pos       = 0;

          if (ob->ob_state & DISABLED)
            lb->style |= LBS_DISABLED;

          if (ob->ob_flags & TOUCHEXIT)
          {
            lb->style    |= LBS_TOUCHEXIT;
            ob->ob_flags &= ~ TOUCHEXIT;
          } /* if */

          if (ob->ob_flags & SELECTABLE)
          {
            lb->style    |= LBS_SELECTABLE;
            ob->ob_flags &= ~ SELECTABLE;
          } /* if */
        } /* if */

        if (ob->ob_state & XS_SCROLLBAR)
        {
          usrblkp                   = &usrblk [num_usrblk++];
          usrblkp->userblk.ub_code  = draw_scrollbar;
          usrblkp->userblk.ub_parm  = (LONG)ob->ob_spec;
          usrblkp->ob_type          = type;
          ob->ob_type               = G_USERDEF | (ob->ob_type & 0xFF00);
          ob->ob_spec               = (LONG)usrblkp;
          usrblkp->spec             = mem_alloc (sizeof (SCROLLBAR));
          sb                        = usrblkp->spec;

          mem_set (sb, 0, sizeof (SCROLLBAR));

          sb->wh       = FAILURE;
          sb->tree     = tree;
          sb->obj      = obj;
          sb->style    = SBS_REALTIME | ((ob->ob_height > ob->ob_width) ? SBS_VERTICAL : SBS_HORIZONTAL);
          sb->bk_color = FAILURE;
          sb->count    = 0;
          sb->pagesize = 1;
          sb->pos      = 0;

          if (sb->style & SBS_HORIZONTAL)
          {
            ob->ob_x      -= 2;                         /* room for border */
            ob->ob_y      -= 2;
            ob->ob_width  += 4;
            ob->ob_height += 4;

            if (! odd (ob->ob_height))
              ob->ob_height++;
          } /* if */
          else
          {
            ob->ob_x      -= 2;                         /* room for border */
            ob->ob_y      -= 2;
            ob->ob_width  += 4;
            ob->ob_height += 4;

            if (! odd (ob->ob_width))
              ob->ob_width++;
          } /* else */

          sb->rc_obj.x = ob->ob_x;
          sb->rc_obj.y = ob->ob_y;
          sb->rc_obj.w = ob->ob_width;
          sb->rc_obj.h = ob->ob_height;

          if (ob->ob_state & DISABLED)
            sb->style |= SBS_DISABLED;
        } /* if */
      } /* if */

      if ((type == G_IBOX) && (ob->ob_state & IS_3DBOX))
      {
        usrblkp                  = &usrblk [num_usrblk++];
        usrblkp->userblk.ub_code = draw_3d_box;
        usrblkp->userblk.ub_parm = (LONG)ob->ob_spec;
        usrblkp->ob_type         = type;
        ob->ob_type              = G_USERDEF | (ob->ob_type & 0xFF00);
        ob->ob_spec              = (LONG)usrblkp;
      } /* if */

      if ((type == G_STRING) && (ob->ob_state & SS_PROPFACE))
      {
        usrblkp                   = &usrblk [num_usrblk++];
        usrblkp->userblk.ub_code  = draw_string;
        usrblkp->userblk.ub_parm  = (LONG)ob->ob_spec;
        usrblkp->ob_type          = type;
        ob->ob_type               = G_USERDEF | (ob->ob_type & 0xFF00);
        ob->ob_spec               = (LONG)usrblkp;
        ob->ob_x--;                                     /* room for border */
        ob->ob_y--;
        ob->ob_width             += 2;
        ob->ob_height            += 2;
      } /* if */

      if (type == G_BUTTON)
      {
        if (ob->ob_state & BS_GROUPBOX)
        {
          usrblkp                  = &usrblk [num_usrblk++];
          usrblkp->userblk.ub_code = draw_groupbox;
          usrblkp->userblk.ub_parm = (LONG)ob->ob_spec;
          usrblkp->ob_type         = type;
          ob->ob_type              = G_USERDEF | (ob->ob_type & 0xFF00);
          ob->ob_spec              = (LONG)usrblkp;
        } /* if */

        if (ob->ob_state & BS_CHECKBOX)			/* checkbox or radio button */
        {
          usrblkp                   = &usrblk [num_usrblk++];
          usrblkp->userblk.ub_code  = draw_checkradio;
          usrblkp->userblk.ub_parm  = (LONG)ob->ob_spec;
          usrblkp->ob_type          = type;
          ob->ob_type               = G_USERDEF | (ob->ob_type & 0xFF00);
          ob->ob_spec               = (LONG)usrblkp;
          ob->ob_width             += 3 * gl_wbox;      /* room for bit image and space */
        } /* if */

        if (ob->ob_state & BS_FUNCTION)			/* function key */
        {
          usrblkp                  = &usrblk [num_usrblk++];
          usrblkp->userblk.ub_code = draw_button;
          usrblkp->userblk.ub_parm = (LONG)ob->ob_spec;
          usrblkp->ob_type         = type;
          ob->ob_type              = G_USERDEF | (ob->ob_type & 0xFF00);
          ob->ob_spec              = (LONG)usrblkp;
        } /* if */

        if (ob->ob_state & BS_COMBOBOX)
        {
          usrblkp                   = &usrblk [num_usrblk++];
          usrblkp->userblk.ub_code  = draw_combobox;
          usrblkp->userblk.ub_parm  = (LONG)ob->ob_spec;
          usrblkp->ob_type          = type;
          ob->ob_type               = G_USERDEF | (ob->ob_type & 0xFF00);
          ob->ob_spec               = (LONG)usrblkp;
          ob->ob_x                 -= 2;                /* room for border */
          ob->ob_y                 -= 2;
          ob->ob_width             += 4;
          ob->ob_height            += 4;
          ob->ob_height             = max (ob->ob_height, gl_hattr + 2 + odd (gl_hattr));

          usrblkp->spec = mem_alloc (sizeof (LISTBOX));
          lb            = usrblkp->spec;

          mem_set (lb, 0, sizeof (LISTBOX));

          lb->wh           = FAILURE;
          lb->tree         = tree;
          lb->obj          = obj;
          lb->style        = LBS_VSCROLL | LBS_VREALTIME;
          lb->is_combobox  = TRUE;
          lb->item_height  = gl_hbox;
          lb->left_offset  = gl_wbox;
          lb->font         = FAILURE;
          lb->point        = FAILURE;
          lb->effects      = (UWORD)FAILURE;
          lb->color        = FAILURE;
          lb->bk_color     = FAILURE;
          lb->sel_item     = FAILURE;
          lb->vsb_size     = gl_wattr;

          lb->vsb.callback = sb_callback;
          lb->vsb.wh       = FAILURE;
          lb->vsb.tree     = (OBJECT *)lb;	/* so I can get my listbox at callback time */
          lb->vsb.obj      = NIL;
          lb->vsb.style    = SBS_VERTICAL | SBS_REALTIME | SBS_NO3DBORDER;
          lb->vsb.bk_color = FAILURE;
          lb->vsb.count    = 0;
          lb->vsb.pagesize = 1;
          lb->vsb.pos      = 0;

          if (ob->ob_state & DISABLED)
            lb->style |= LBS_DISABLED;

          if (ob->ob_flags & SELECTABLE)
            lb->style |= LBS_SELECTABLE;
        } /* if */

        if ((ob->ob_state & STATE_BUTTON) == 0)         /* regular pushbutton */
        {
          usrblkp                   = &usrblk [num_usrblk++];
          usrblkp->userblk.ub_code  = draw_button;
          usrblkp->userblk.ub_parm  = (LONG)ob->ob_spec;
          usrblkp->ob_type          = type;
          ob->ob_type               = G_USERDEF | (ob->ob_type & 0xFF00);
          ob->ob_spec               = (LONG)usrblkp;
          ob->ob_x                 -= 2;                /* room for default border */
          ob->ob_y                 -= 2;
          ob->ob_width             += 4;
          ob->ob_height            += 4;
        } /* if */

        if (ob->ob_state & BS_BMBUTTON)			/* bitmap button */
        {
          if ((index = find_bmbutton ((BYTE *)ob->ob_spec)) != FAILURE)
          {
            bm                       = &bmbutton [index];
            img_header               = (IMG_HEADER *)((bm->n1.di_buffer != NULL) ? bm->n1.di_buffer : bm->n4.di_buffer);
            usrblkp                  = &usrblk [num_usrblk++];
            usrblkp->userblk.ub_code = draw_bmbutton;
            usrblkp->userblk.ub_parm = (LONG)ob->ob_spec;
            usrblkp->ob_type         = type;
            usrblkp->spec            = bm;
            ob->ob_type              = G_USERDEF | (ob->ob_type & 0xFF00);
            ob->ob_spec              = (LONG)usrblkp;
            ob->ob_width             = (img_header == NULL) ? bm->width : img_header->sl_width;
            ob->ob_height            = (img_header == NULL) ? bm->height : img_header->sl_height;
          } /* if */
        } /* if */
      } /* if */
    } while (! (ob->ob_flags & LASTOB));
  } /* if */
} /* FixTree */

/*****************************************************************************/

GLOBAL VOID SwitchTree3D (OBJECT *tree)
{
  WORD   obj;
  OBJECT *ob;
  UWORD  type;

  if (tree != NULL)
  {
    obj = NIL;

    do
    {
      ob   = &tree [++obj];
      type = get_ob_type (tree, obj);

      if (type == G_BOX)
      {
        if (ob->ob_state & XS_DLGBKGND)
          if (dlg_colors >= 16)
          {
            if (obj == ROOT)
              undo_state (tree, ROOT, OUTLINED);

            ob->ob_spec = 0x00011170L | sys_colors [COLOR_DIALOG];	/* set background color to light gray */
          } /* if */
          else
          {
            if (obj == ROOT)
              do_state (tree, ROOT, OUTLINED);

            ob->ob_spec = 0x00021100L;					/* set background color to white */
          } /* else, if */

        if (ob->ob_state & XS_GRAYBKGND)
          if (dlg_colors >= 16)
            ob->ob_spec = (ob->ob_spec & 0xFFFFFF80L) | 0x00000070L | sys_colors [COLOR_DIALOG];
          else
            ob->ob_spec = (ob->ob_spec & 0xFFFFFF80L) | 0x00000000L;
      } /* if */
    } while (! (ob->ob_flags & LASTOB));
  } /* if */
} /* SwitchTree3D */

/*****************************************************************************/

GLOBAL UBYTE *BuildImg (UBYTE *buffer, WORD *width, WORD *height, WORD *numplanes)
{
  WORD       i, screen_planes, raster_planes;
  LONG       planesize;
  LONG       size_header;
  IMG_HEADER *img_header;
  HPUCHAR    img_buffer;
  HPUCHAR    raster_buffer, trans_buffer;
  HPUCHAR    plane_ptr [MAX_PLANES];
  LONG       raster_len, trans_len;
  WORD       fww;

  if (buffer == NULL) return (NULL);

  img_header = (IMG_HEADER *)buffer;

#if I8086
  {
    WORD headlen;

    headlen = img_header->headlen;
    flip_word ((UBYTE *)&headlen);
    for (i = 0; i < headlen; i++) flip_word (&buffer [i * 2]);
  } /* if */
#endif

  screen_planes = planes;
  if (img_header->planes == 1) screen_planes = 1;       /* for optimizing */

#if GEMDOS
  raster_planes = use_adapt ? min (img_header->planes, screen_planes): screen_planes;
#else
  raster_planes = screen_planes;
#endif

  fww           = (img_header->sl_width + 15) / 16;     /* fww = form width in words */
  planesize     = 2L * (LONG)fww * img_header->sl_height;
  raster_len    = planesize * raster_planes;
  raster_buffer = (HPUCHAR)mem_alloc (raster_len);
  trans_len     = planesize * screen_planes;
  trans_buffer  = (HPUCHAR)mem_alloc (trans_len);

  if ((raster_buffer == NULL) || (trans_buffer == NULL))
  {
    mem_free (raster_buffer);
    mem_free (trans_buffer);
    return (NULL);
  } /* if */

  mem_lset ((VOID *)raster_buffer, 0, raster_len);
  mem_lset ((VOID *)trans_buffer, 0, trans_len);
  mem_lset ((VOID *)plane_ptr, 0, sizeof (plane_ptr));

  for (i = 0; i < raster_planes; i++)
    plane_ptr [i] = raster_buffer + i * planesize;

  size_header = img_header->headlen * 2; /* in bytes */
  img_buffer  = buffer + size_header;

  conv_img (img_header, img_buffer, raster_buffer, trans_buffer, plane_ptr, img_header->sl_height, raster_planes, fww);

  if (width != NULL) *width = img_header->sl_width;
  if (height != NULL) *height = img_header->sl_height;
  if (numplanes != NULL) *numplanes = img_header->planes;

#if I8086
  {
    WORD headlen;

    headlen = img_header->headlen;
    for (i = 0; i < headlen; i++) flip_word (&buffer [i * 2]);
  } /* if */
#endif

  mem_free (raster_buffer);

  return (trans_buffer);
} /* BuildImg */

/*****************************************************************************/

GLOBAL BOOLEAN BuildIcon (ICON *icon, UBYTE *mask, UBYTE *data)
{
  icon->mask = BuildImg (mask, NULL, NULL, NULL);
  icon->data = BuildImg (data, &icon->width, &icon->height, &icon->planes);

  return (((mask == NULL) || (icon->mask != NULL)) && ((data == NULL) || (icon->data != NULL)));
} /* BuildIcon */

/*****************************************************************************/

GLOBAL VOID FreeIcon (ICON *icon)
{
  mem_free (icon->mask);
  mem_free (icon->data);
} /* FreeIcon */

/*****************************************************************************/

GLOBAL VOID DrawOwnerIcon (LB_OWNERDRAW *lb_ownerdraw, RECT *img_rect, ICON *icon, BYTE *text, WORD text_offset)
{
  DrawOwnerMultiIcon (lb_ownerdraw, img_rect, icon, text, text_offset, 1, 1, 0, 0);
} /* DrawOwnerIcon */

/*****************************************************************************/

GLOBAL VOID DrawOwnerMultiIcon (LB_OWNERDRAW *lb_ownerdraw, RECT *img_rect, ICON *icon, BYTE *text, WORD text_offset, WORD rows, WORD cols, WORD row, WORD col)
{
  WORD x, y, w, h, xy [8], extent [8];
  WORD index [2];
  RECT r;
  MFDB s, d;

  r    = lb_ownerdraw->rc_item;
  r.x += ((icon != NULL) && (icon->mask == NULL)) ? img_rect->w + text_offset : 0;
  rect2array (&r, xy);
  vswr_mode (vdi_handle, MD_TRANS);
  vsf_interior (vdi_handle, FIS_SOLID);
  vsf_perimeter (vdi_handle, FALSE);
  vsf_style (vdi_handle, 0);
  vst_effects (vdi_handle, effects_btntext | (((lb_ownerdraw->style & (LBS_DRAWDISABLED | LBS_DISABLED)) && (dlg_colors < 16)) ? TXT_LIGHT : TXT_NORMAL));

  vqt_extent (vdi_handle, text, extent);
  h = extent [5] - extent [3];
  r = lb_ownerdraw->rc_item;
  x = r.x + text_offset;
  y = r.y + (r.h - h) / 2;

  if (icon != NULL)
    x += img_rect->w + 2;

  draw_owner_text (vdi_handle, lb_ownerdraw, text, x, y, xy);

  if ((icon != NULL) && ((icon->data != NULL) || (icon->mask != NULL)))
  {
    w    = icon->width / cols;
    h    = icon->height / rows;
    r    = *img_rect;
    r.x += (img_rect->w - w) / 2;
    r.y += (img_rect->h - h) / 2;
    r.w  = w;
    r.h  = h;

    xywh2array (col * w, row * h, w, h, &xy [0]);
    xywh2array (r.x, r.y, r.w, r.h, &xy [4]);

    d.mp  = NULL;				/* screen */
    s.mp  = (VOID *)icon->mask;
    s.fwp = icon->width;
    s.fh  = icon->height;
    s.fww = (s.fwp + 15) / 16;
    s.ff  = FALSE;
    s.np  = 1;

    if (icon->mask != NULL)
    {
      index [0] = WHITE;
      index [1] = WHITE;

      vrt_cpyfm (vdi_handle, MD_TRANS, xy, &s, &d, index);
    } /* if */

    s.mp = (VOID *)icon->data;
    s.np = (colors < 16) ? 1 : planes;

    if (icon->data != NULL)
      if (s.np == 1)
      {
        index [0] = BLACK;
        index [1] = WHITE;

        vrt_cpyfm (vdi_handle, MD_TRANS, xy, &s, &d, index);
      } /* if */
      else
        vro_cpyfm (vdi_handle, (icon->mask == NULL) ? S_ONLY : (s.np > 8) ? S_AND_D : S_OR_D, xy, &s, &d);
  } /* if */
} /* DrawOwnerMultiIcon */

/*****************************************************************************/

GLOBAL VOID DrawOwnerColor (LB_OWNERDRAW *lb_ownerdraw, RECT *img_rect, WORD color, BYTE *text, WORD text_offset)
{
  WORD x, y, h, xy [8], extent [8];
  RECT r;

  r = *img_rect;
  vswr_mode (vdi_handle, MD_TRANS);
  vsf_color (vdi_handle, BLACK);
  vsf_interior (vdi_handle, FIS_HOLLOW);
  vsf_perimeter (vdi_handle, TRUE);
  vsf_style (vdi_handle, 0);
  rect2array (&r, xy);
  v_bar (vdi_handle, xy);

  r.x++;
  r.y++;
  r.w -= 2;
  r.h -= 2;
  vswr_mode (vdi_handle, MD_REPLACE);
  vsf_color (vdi_handle, color);
  vsf_interior (vdi_handle, FIS_SOLID);
  vsf_perimeter (vdi_handle, TRUE);
  vsf_style (vdi_handle, 0);
  rect2array (&r, xy);
  v_bar (vdi_handle, xy);

  r   = lb_ownerdraw->rc_item;
  r.x = img_rect->x + img_rect->w + text_offset;
  rect2array (&r, xy);
  vswr_mode (vdi_handle, MD_TRANS);
  vsf_interior (vdi_handle, FIS_SOLID);
  vsf_perimeter (vdi_handle, FALSE);
  vsf_style (vdi_handle, 0);
  vst_effects (vdi_handle, effects_btntext | (((lb_ownerdraw->style & (LBS_DRAWDISABLED | LBS_DISABLED)) && (dlg_colors < 16)) ? TXT_LIGHT : TXT_NORMAL));

  vqt_extent (vdi_handle, text, extent);
  h = extent [5] - extent [3];
  r = lb_ownerdraw->rc_item;
  x = img_rect->x + img_rect->w + text_offset + 2;
  y = r.y + (r.h - h) / 2;

  draw_owner_text (vdi_handle, lb_ownerdraw, text, x, y, xy);
} /* DrawOwnerColor */

/*****************************************************************************/

GLOBAL VOID DrawOwnerDlgPattern (LB_OWNERDRAW *lb_ownerdraw, WORD color, WORD pattern)
{
  WORD xy [8];
  RECT r;

  r = lb_ownerdraw->rc_item;
  r.x++;
  r.y++;
  r.w -= 2;
  r.h -= 2;

  vswr_mode (vdi_handle, MD_TRANS);
  vsf_color (vdi_handle, (lb_ownerdraw->selected) ? BLACK : WHITE);
  vsf_interior (vdi_handle, FIS_HOLLOW);
  vsf_perimeter (vdi_handle, TRUE);
  vsf_style (vdi_handle, 0);
  rect2array (&r, xy);
  v_bar (vdi_handle, xy);

  r.x++;
  r.y++;
  r.w -= 2;
  r.h -= 2;
  vsf_color (vdi_handle, BLACK);
  rect2array (&r, xy);
  v_bar (vdi_handle, xy);

  r.x++;
  r.y++;
  r.w -= 2;
  r.h -= 2;
  vswr_mode (vdi_handle, MD_REPLACE);
  vsf_color (vdi_handle, color);
  vsf_interior (vdi_handle, (pattern == 0) ? FIS_HOLLOW : FIS_PATTERN);
  vsf_perimeter (vdi_handle, FALSE);
  vsf_style (vdi_handle, (pattern == 7) ? 8 : pattern);
  rect2array (&r, xy);
  v_bar (vdi_handle, xy);
} /* DrawOwnerDlgPattern */

/*****************************************************************************/

GLOBAL VOID DrawOwnerCheck (LB_OWNERDRAW *lb_ownerdraw, RECT *img_rect, BOOLEAN radio, WORD index, BYTE *text, WORD text_offset)
{
  WORD  x, y, h, w_button, h_button, xy [8], extent [8];
  WORD  inx [2];
  RECT  r;
  MFDB  s, d;
  UBYTE *rasterbuf;

  r    = lb_ownerdraw->rc_item;
  r.x += img_rect->w + text_offset;
  rect2array (&r, xy);
  vswr_mode (vdi_handle, MD_TRANS);
  vsf_interior (vdi_handle, FIS_SOLID);
  vsf_perimeter (vdi_handle, FALSE);
  vsf_style (vdi_handle, 0);
  vst_effects (vdi_handle, effects_btntext | (((lb_ownerdraw->style & (LBS_DRAWDISABLED | LBS_DISABLED)) && (dlg_colors < 16)) ? TXT_LIGHT : TXT_NORMAL));

  vqt_extent (vdi_handle, text, extent);
  h = extent [5] - extent [3];
  r = lb_ownerdraw->rc_item;
  x = r.x + img_rect->w + text_offset + 2;
  y = r.y + (r.h - h) / 2;

  draw_owner_text (vdi_handle, lb_ownerdraw, text, x, y, xy);

  vswr_mode (vdi_handle, MD_REPLACE);
  vsf_color (vdi_handle, (gl_hbox <= 8) || (dlg_colors < 16) ? WHITE : sys_colors [COLOR_DIALOG]);
  vsf_interior (vdi_handle, FIS_SOLID);
  vsf_perimeter (vdi_handle, TRUE);
  vsf_style (vdi_handle, 0);
  rect2array (img_rect, xy);
  v_bar (vdi_handle, xy);

  w_button  = (gl_hbox <= 8) ? BUTTONL_WIDTH  : BUTTON_SIZE;
  h_button  = (gl_hbox <= 8) ? BUTTONL_HEIGHT : BUTTON_SIZE;
  x         = w_button;
  y         = radio ? h_button : 0;
  rasterbuf = (gl_hbox <= 8) ? buttonsl_buf : (dlg_colors < 16) || (sys_colors [COLOR_DIALOG] != DWHITE) ? buttons1_buf : buttons4_buf;

  if (gl_hbox > 8)
    y += 2 * index * h_button;

  d.mp  = NULL;                         /* screen */
  s.mp  = (VOID *)rasterbuf;
  s.fwp = (gl_hbox <= 8) ? buttonsl_width : buttons_width;
  s.fh  = (gl_hbox <= 8) ? buttonsl_height : buttons_height;
  s.fww = (s.fwp + 15) / 16;
  s.ff  = FALSE;
  s.np  = (gl_hbox <= 8) || (dlg_colors < 16) || (sys_colors [COLOR_DIALOG] != DWHITE) ? 1 : planes;

  r = *img_rect;

  xywh2array (x, y, w_button, h_button, &xy [0]);
  xywh2array (r.x + (r.w - w_button) / 2, r.y + (r.h - h_button) / 2, w_button, h_button, &xy [4]);

  if (s.np == 1)			/* draw monochrome picture */
  {
    inx [0] = sys_colors [COLOR_BTNTEXT];
    inx [1] = (dlg_colors < 16) ? WHITE : sys_colors [COLOR_DIALOG];

    vrt_cpyfm (vdi_handle, MD_REPLACE, xy, &s, &d, inx);
  } /* if */
  else					/* draw color picture */
    vro_cpyfm (vdi_handle, S_ONLY, xy, &s, &d);
} /* DrawOwnerCheck */

/*****************************************************************************/

GLOBAL VOID DrawOwnerArrow (LB_OWNERDRAW *lb_ownerdraw, RECT *img_rect, WORD index, BYTE *text, WORD text_offset)
{
  WORD  x, y, h, xy [8], extent [8];
  WORD  inx [2];
  RECT  r;
  MFDB  s, d;
  UBYTE *rasterbuf;

  r    = lb_ownerdraw->rc_item;
  r.x += img_rect->w + text_offset;
  rect2array (&r, xy);
  vswr_mode (vdi_handle, MD_TRANS);
  vsf_interior (vdi_handle, FIS_SOLID);
  vsf_perimeter (vdi_handle, FALSE);
  vsf_style (vdi_handle, 0);
  vst_effects (vdi_handle, effects_btntext | (((lb_ownerdraw->style & (LBS_DRAWDISABLED | LBS_DISABLED)) && (dlg_colors < 16)) ? TXT_LIGHT : TXT_NORMAL));

  vqt_extent (vdi_handle, text, extent);
  h = extent [5] - extent [3];
  r = lb_ownerdraw->rc_item;
  x = r.x + img_rect->w + text_offset + 2;
  y = r.y + (r.h - h) / 2;

  draw_owner_text (vdi_handle, lb_ownerdraw, text, x, y, xy);

  vswr_mode (vdi_handle, MD_REPLACE);
  vsf_color (vdi_handle, (gl_hbox <= 8) || (dlg_colors < 16) ? WHITE : sys_colors [COLOR_DIALOG]);
  vsf_interior (vdi_handle, FIS_SOLID);
  vsf_perimeter (vdi_handle, TRUE);
  vsf_style (vdi_handle, 0);
  rect2array (img_rect, xy);
  v_bar (vdi_handle, xy);

  x         = 0;
  y         = 2 * index * ARROW_SIZE;
  rasterbuf = arrows1_buf;

  d.mp  = NULL;                         /* screen */
  s.mp  = (VOID *)rasterbuf;
  s.fwp = arrows_width;
  s.fh  = arrows_height;
  s.fww = (s.fwp + 15) / 16;
  s.ff  = FALSE;
  s.np  = 1;

  r = *img_rect;

  xywh2array (x, y, 3 * ARROW_SIZE, ARROW_SIZE, &xy [0]);
  xywh2array (r.x + (r.w - 3 * ARROW_SIZE) / 2, r.y + (r.h - ARROW_SIZE) / 2, 3 * ARROW_SIZE, ARROW_SIZE, &xy [4]);

  inx [0] = sys_colors [COLOR_BTNTEXT];
  inx [1] = sys_colors [COLOR_BTNFACE];

  vrt_cpyfm (vdi_handle, MD_TRANS, xy, &s, &d, inx);
} /* DrawOwnerArrow */

/*****************************************************************************/

GLOBAL VOID DrawButton (WORD vdi_handle, RECT *rc, RECT *rc_clip, BYTE *text, WORD acc_inx, WORD state, WORD bk_color, FONTDESC *fontdesc, BOOLEAN def, BOOLEAN round, WORD shadow_width)
{
  BYTE    *p;
  WORD    ob_x, ob_y, ob_w, ob_h, ret, i, border;
  WORD    x, y, w, h;
  BOOLEAN selected, disabled;
  WORD    xy [8];
  WORD    minimum, maximum, width;
  WORD    extent [8], distances [5], effects [3];
  RECT    save_clip;
  STRING  s;

  save_clip = clip;
  ob_x      = rc->x;
  ob_y      = rc->y;
  ob_w      = rc->w;
  ob_h      = rc->h;
  selected  = (state & SELECTED) != 0;
  disabled  = (state & DISABLED) != 0;

  set_clip (TRUE, rc_clip);

  if (bk_color == FAILURE)
    bk_color = sys_colors [COLOR_BTNFACE];

  line_default (vdi_handle);
  text_default (vdi_handle);

  vst_font (vdi_handle, (state & BS_FUNCTION) ? FONT_SYSTEM : (fontdesc != NULL) ? fontdesc->font : font_btntext);
  vst_point (vdi_handle, (state & BS_FUNCTION) ? 8 : (fontdesc != NULL) ? fontdesc->point : point_btntext, &ret, &ret, &ret, &ret);
  vst_effects (vdi_handle, (fontdesc != NULL) ? fontdesc->effects : effects_btntext);
  vqt_extent (vdi_handle, (text != NULL) ? text : "", extent);
  vqt_font_info (vdi_handle, &minimum, &maximum, distances, &width, effects);

  w = extent [2] - extent [0] + effects [2];
  h = extent [5] - extent [3];

  border = def ? 2 : 1;

  for (i = 0; i < border; i++)         /* draw border */
  { 
    xy [0] = ob_x + 1 + i;
    xy [1] = ob_y + i;
    xy [2] = ob_x + ob_w - 2 - i;
    xy [3] = ob_y + i;

    if (! round || (i > 0))
    {
      xy [0]--;
      xy [2]++;
    } /* if */

    v_pline (vdi_handle, 2, xy);

    xy [0] = ob_x + ob_w - 1 - i;
    xy [1] = ob_y + 1 + i;
    xy [2] = ob_x + ob_w - 1 - i;
    xy [3] = ob_y + ob_h - 2 - i;

    if (! round || (i > 0))
    {
      xy [1]--;
      xy [3]++;
    } /* if */

    v_pline (vdi_handle, 2, xy);

    xy [0] = ob_x + ob_w - 2 - i;
    xy [1] = ob_y + ob_h - 1 - i;
    xy [2] = ob_x + 1 + i;
    xy [3] = ob_y + ob_h - 1 - i;

    if (! round || (i > 0))
    {
      xy [0]++;
      xy [2]--;
    } /* if */

    v_pline (vdi_handle, 2, xy);

    xy [0] = ob_x + i;
    xy [1] = ob_y + ob_h - 2 - i;
    xy [2] = ob_x + i;
    xy [3] = ob_y + 1 + i;

    if (! round || (i > 0))
    {
      xy [1]++;
      xy [3]--;
    } /* if */

    v_pline (vdi_handle, 2, xy);
  } /* for */

  xy [0] = ob_x + border;              /* don't fill black border */
  xy [1] = ob_y + border;
  xy [2] = ob_x + ob_w - border - 1;
  xy [3] = ob_y + ob_h - border - 1;

  vswr_mode (vdi_handle, MD_REPLACE);
  vsf_color (vdi_handle, (dlg_colors < 16) ? WHITE : bk_color);
  vsf_interior (vdi_handle, FIS_SOLID);
  vr_recfl (vdi_handle, xy);           /* fill the interior */

  if (def)
  {
    ob_x++;
    ob_y++;
    ob_w -= 2;
    ob_h -= 2;
  } /* if */

  if (dlg_colors >= 16)
  {
    if (selected)
    {
      vsl_color (vdi_handle, sys_colors [COLOR_BTNSHADOW]);

      for (i = 0; i < 1; i++)
      {
        xy [0] = ob_x + 1 + i;
        xy [1] = ob_y + ob_h - 2;
        xy [2] = ob_x + 1 + i;
        xy [3] = ob_y + 1 + i;
        xy [4] = ob_x + ob_w - 2;
        xy [5] = ob_y + 1 + i;
        v_pline (vdi_handle, 3, xy);
      } /* for */
    } /* if */
    else
    {
      vsl_color (vdi_handle, sys_colors [COLOR_BTNHIGHLIGHT]);

      for (i = 0; i < shadow_width; i++)
      {
        xy [0] = ob_x + 1 + i;
        xy [1] = ob_y + ob_h - 3 - i;
        xy [2] = ob_x + 1 + i;
        xy [3] = ob_y + 1 + i;
        xy [4] = ob_x + ob_w - 3 - i;
        xy [5] = ob_y + 1 + i;
        v_pline (vdi_handle, 3, xy);
      } /* for */

      vsl_color (vdi_handle, sys_colors [COLOR_BTNSHADOW]);

      for (i = 0; i < shadow_width; i++)
      {
        xy [0] = ob_x + ob_w - 2 - i;
        xy [1] = ob_y + 2 + i;
        xy [2] = ob_x + ob_w - 2 - i;
        xy [3] = ob_y + ob_h - 2 - i;
        xy [4] = ob_x + 2 + i;
        xy [5] = ob_y + ob_h - 2 - i;
        v_pline (vdi_handle, 3, xy);
      } /* for */
    } /* else */
  } /* if */

  if (state & BS_FUNCTION)
  {
    x = ob_x + 4;
    y = ob_y;

    strcpy (s, (text == NULL) ? "=" : text);

    if ((p = strchr (s, '=')) != NULL)
      *p = EOS;
  } /* if */
  else
  {
    x = ob_x + (ob_w - w) / 2;
    y = ob_y + (ob_h - h) / 2;
  } /* if */

  if (dlg_colors >= 16)
    if (selected)
    {
      x++;
      y++;
    } /* if, if */

  if (dlg_colors >= 16)
    vswr_mode (vdi_handle, MD_TRANS);

  if (state & BS_FUNCTION)
  {
    vst_color (vdi_handle, (fontdesc != NULL) ? fontdesc->color : sys_colors [COLOR_BTNTEXT]);

    if (gl_hbox <= 8) y--;

    v_gtext (vdi_handle, x, y + 5, s);

    if (gl_hbox <= 8) y += 2;

    if ((dlg_colors >= 16) && disabled)
    {
      vst_color (vdi_handle, WHITE);
      v_gtext (vdi_handle, x + 1, y + ob_h - h - 4 + 1, p + 1);
    } /* if */

    vst_color (vdi_handle, (fontdesc != NULL) ? fontdesc->color : sys_colors [COLOR_BTNTEXT]);

    if (disabled)
      if (dlg_colors < 16)
        vst_effects (vdi_handle, TXT_LIGHT | effects_btntext);
      else
        vst_color (vdi_handle, sys_colors [COLOR_DISABLED]);

    if ((p != NULL) && (! disabled || (dlg_colors >= 16)))
      v_gtext (vdi_handle, x, y + ob_h - h - 4, p + 1);
  } /* if */
  else
    if (text != NULL)
    {
      if ((dlg_colors >= 16) && disabled)
      {
        vst_color (vdi_handle, WHITE);
        v_gtext (vdi_handle, x + 1, y + 1, text);
      } /* if */

      vst_color (vdi_handle, (fontdesc != NULL) ? fontdesc->color : sys_colors [COLOR_BTNTEXT]);

      if (disabled)
        if (dlg_colors < 16)
          vst_effects (vdi_handle, TXT_LIGHT | effects_btntext);
        else
          vst_color (vdi_handle, sys_colors [COLOR_DISABLED]);

      v_gtext (vdi_handle, x, y, text);
      draw_acc_line (vdi_handle, x, y, text, acc_inx, disabled, dlg_colors, (fontdesc != NULL) ? fontdesc->color : sys_colors [COLOR_BTNTEXT], bk_color);
    } /* if, else */

  if (selected && (dlg_colors < 16))
  {
    xywh2array (ob_x + 1, ob_y + 1, ob_w - 2, ob_h - 2, xy);

    vswr_mode (vdi_handle, MD_XOR);
    vsf_color (vdi_handle, BLACK);
    vsf_interior (vdi_handle, FIS_SOLID);
    vr_recfl (vdi_handle, xy);
  } /* if */

  set_clip (TRUE, &save_clip);
} /* DrawButton */

/*****************************************************************************/

GLOBAL VOID DrawCheckRadio (WORD vdi_handle, RECT *rc, RECT *rc_clip, BYTE *text, WORD acc_inx, WORD state, WORD bk_color, FONTDESC *fontdesc, BOOLEAN radio)
{
  WORD    ob_x, ob_y, ret;
  WORD    x, y, w, h, w_button, h_button;
  BOOLEAN selected, disabled, transparent;
  MFDB    s, d;
  WORD    xy [8];
  WORD    index [2];
  WORD    minimum, maximum, width;
  WORD    extent [8], distances [5], effects [3];
  RECT    save_clip, r;
  UBYTE   *rasterbuf;

  save_clip   = clip;
  w_button    = (gl_hbox <= 8) ? BUTTONL_WIDTH  : BUTTON_SIZE;
  h_button    = (gl_hbox <= 8) ? BUTTONL_HEIGHT : BUTTON_SIZE;
  ob_x        = rc->x;
  ob_y        = rc->y;
  w           = w_button;
  h           = h_button;
  selected    = (state & SELECTED) != 0;
  disabled    = (state & DISABLED) != 0;
  transparent = bk_color == FAILURE - 1;

  set_clip (TRUE, rc_clip);

  if (bk_color <= FAILURE)
    bk_color = (dlg_colors < 16) ? WHITE : sys_colors [COLOR_DIALOG];

  line_default (vdi_handle);
  text_default (vdi_handle);

  x         = 0;
  y         = radio ? h_button : 0;
  rasterbuf = (gl_hbox <= 8) ? buttonsl_buf : (dlg_colors < 16) || (bk_color != DWHITE) ? buttons1_buf : buttons4_buf;

  if (selected)
    x += w_button;

  if (gl_hbox > 8)
  {
    if (radio)
      y += 2 * dlg_radiobutton * h_button;
    else
      y += 2 * dlg_checkbox * h_button;

    if (disabled)
      x += 2 * w_button;
  } /* if */

  d.mp  = NULL;                         /* screen */
  s.mp  = (VOID *)rasterbuf;
  s.fwp = (gl_hbox <= 8) ? buttonsl_width : buttons_width;
  s.fh  = (gl_hbox <= 8) ? buttonsl_height : buttons_height;
  s.fww = (s.fwp + 15) / 16;
  s.ff  = FALSE;
  s.np  = (gl_hbox <= 8) || (dlg_colors < 16) || (bk_color != DWHITE) ? 1 : planes;

  xywh2array (x, y, w, h, &xy [0]);
  xywh2array (ob_x + (2 * gl_wbox - w_button) / 2, ob_y + (rc->h - h_button) / 2, w, h, &xy [4]);

  if (s.np == 1)			/* draw monochrome picture */
  {
    index [0] = (fontdesc != NULL) ? fontdesc->color : sys_colors [COLOR_BTNTEXT];
    index [1] = bk_color;

    vrt_cpyfm (vdi_handle, transparent ? MD_TRANS : MD_REPLACE, xy, &s, &d, index);
  } /* if */
  else					/* draw color picture */
    vro_cpyfm (vdi_handle, S_ONLY, xy, &s, &d);

  if (text != NULL)
  {
    vst_font (vdi_handle, (fontdesc != NULL) ? fontdesc->font : font_btntext);
    vst_point (vdi_handle, (fontdesc != NULL) ? fontdesc->point : point_btntext, &ret, &ret, &ret, &ret);
    vst_effects (vdi_handle, (fontdesc != NULL) ? fontdesc->effects : effects_btntext);
    vqt_extent (vdi_handle, text, extent);
    vqt_font_info (vdi_handle, &minimum, &maximum, distances, &width, effects);

    h = extent [5] - extent [3];
    x = ob_x + 3 * gl_wbox;
    y = ob_y + (rc->h - h) / 2;

    r    = *rc;
    r.x += 3 * gl_wbox;
    r.w -= 3 * gl_wbox;

    clear_rect (&r, bk_color);
    vswr_mode (vdi_handle, MD_TRANS);

    if (dlg_colors >= 16)
      if (disabled)
      {
        vst_color (vdi_handle, WHITE);
        v_gtext (vdi_handle, x + 1, y + 1, text);
      } /* if, if */

    vst_color (vdi_handle, (fontdesc != NULL) ? fontdesc->color : sys_colors [COLOR_BTNTEXT]);

    if (disabled)
      if (dlg_colors < 16)
        vst_effects (vdi_handle, TXT_LIGHT | ((fontdesc != NULL) ? fontdesc->effects : effects_btntext));
      else
        vst_color (vdi_handle, sys_colors [COLOR_DISABLED]);

    v_gtext (vdi_handle, x, y, text);
    draw_acc_line (vdi_handle, x, y, text, acc_inx, disabled, dlg_colors, (fontdesc != NULL) ? fontdesc->color : sys_colors [COLOR_BTNTEXT], bk_color);
  } /* if */

  set_clip (TRUE, &save_clip);
} /* DrawCheckRadio */

/*****************************************************************************/

GLOBAL VOID DrawGroupBox (WORD vdi_handle, RECT *rc, RECT *rc_clip, BYTE *text, WORD acc_inx, WORD state, WORD bk_color, FONTDESC *fontdesc)
{
  WORD    ob_x, ob_y, ob_w, ob_h, ret;
  WORD    x, y, w, h;
  BOOLEAN disabled;
  WORD    xy [12];
  WORD    minimum, maximum, width;
  WORD    extent [8], distances [5], effects [3];
  RECT    save_clip, r;

  save_clip = clip;
  ob_x      = rc->x;
  ob_y      = rc->y;
  ob_w      = rc->w;
  ob_h      = rc->h;
  disabled  = (state & DISABLED) != 0;

  set_clip (TRUE, rc_clip);

  if (bk_color == FAILURE)
    bk_color = (dlg_colors < 16) ? WHITE : sys_colors [COLOR_DIALOG];

  line_default (vdi_handle);
  text_default (vdi_handle);

  vst_font (vdi_handle, (fontdesc != NULL) ? fontdesc->font : font_btntext);
  vst_point (vdi_handle, (fontdesc != NULL) ? fontdesc->point : point_btntext, &ret, &ret, &ret, &ret);
  vst_effects (vdi_handle, (fontdesc != NULL) ? fontdesc->effects : effects_btntext);
  vqt_extent (vdi_handle, (text != NULL) ? text : "", extent);
  vqt_font_info (vdi_handle, &minimum, &maximum, distances, &width, effects);

  w = extent [2] - extent [0] + effects [2];
  h = extent [5] - extent [3];

  xy [ 0] = ob_x + gl_wbox;
  xy [ 1] = ob_y + h / 2;
  xy [ 2] = ob_x;
  xy [ 3] = xy [1];
  xy [ 4] = xy [2];
  xy [ 5] = ob_y + ob_h - 1;
  xy [ 6] = ob_x + ob_w - 1;
  xy [ 7] = xy [5];
  xy [ 8] = xy [6];
  xy [ 9] = xy [1];
  xy [10] = ob_x + 3 * gl_wbox + w;
  xy [11] = xy [1];

  if ((text == NULL) || (text [0] == EOS))	/* empty box, no need to resize */
  {
    xy [ 1] -= h / 2;
    xy [ 3]  = xy [1];
    xy [ 9]  = xy [1];
    xy [10]  = xy [0];
    xy [11]  = xy [1];
  } /* if */

  if (dlg_colors < 16)
    v_pline (vdi_handle, 6, xy);
  else
  {
    xy [5]--;
    xy [6]--;
    xy [7] = xy [5];
    xy [8] = xy [6];

    vsl_color (vdi_handle, sys_colors [COLOR_BTNSHADOW]);
    v_pline (vdi_handle, 6, xy);

    xy [ 1]++;
    xy [ 2]++;
    xy [ 3]++;
    xy [ 4]++;
    xy [ 5]++;
    xy [ 6]++;
    xy [ 7] = xy [5];
    xy [ 8] = xy [6];
    xy [ 9]++;
    xy [11]++;

    vsl_color (vdi_handle, sys_colors [COLOR_BTNHIGHLIGHT]);
    v_pline (vdi_handle, 6, xy);
  } /* else */

  if (text != NULL)
  {
    x = ob_x + 2 * gl_wbox;
    y = ob_y;

    xywh2rect (x, y, w, h, &r);
    clear_rect (&r, bk_color);
    vswr_mode (vdi_handle, MD_TRANS);

    if (dlg_colors >= 16)
      if (disabled)
      {
        vst_color (vdi_handle, WHITE);
        v_gtext (vdi_handle, x + 1, y + 1, text);
      } /* if, if */

    vst_color (vdi_handle, (fontdesc != NULL) ? fontdesc->color : sys_colors [COLOR_BTNTEXT]);

    if (disabled)
      if (dlg_colors < 16)
        vst_effects (vdi_handle, TXT_LIGHT | ((fontdesc != NULL) ? fontdesc->effects : effects_btntext));
      else
        vst_color (vdi_handle, sys_colors [COLOR_DISABLED]);

    v_gtext (vdi_handle, x, y, text);
    draw_acc_line (vdi_handle, x, y, text, acc_inx, disabled, dlg_colors, (fontdesc != NULL) ? fontdesc->color : sys_colors [COLOR_BTNTEXT], bk_color);
  } /* if */

  set_clip (TRUE, &save_clip);
} /* DrawGroupBox */

/*****************************************************************************/

GLOBAL VOID DrawString (WORD vdi_handle, RECT *rc, RECT *rc_clip, BYTE *text, WORD acc_inx, WORD state, WORD bk_color, FONTDESC *fontdesc)
{
  WORD    ob_x, ob_y, ob_w, ob_h, ret;
  WORD    x, y, w, h;
  BOOLEAN selected, disabled;
  WORD    xy [8];
  WORD    minimum, maximum, width;
  WORD    extent [8], distances [5], effects [3];
  RECT    save_clip, r;

  save_clip = clip;
  ob_x      = rc->x;
  ob_y      = rc->y;
  ob_w      = rc->w;
  ob_h      = rc->h;
  selected  = (state & SELECTED) != 0;
  disabled  = (state & DISABLED) != 0;

  set_clip (TRUE, rc_clip);

  if (bk_color == FAILURE)
    bk_color = (dlg_colors < 16) ? WHITE : sys_colors [COLOR_DIALOG];

  line_default (vdi_handle);
  text_default (vdi_handle);

  if (dlg_colors >= 16)
    if (state & SS_INSIDE)
      draw_3d (vdi_handle, ob_x + 1, ob_y + 1, 1, ob_w - 2 , ob_h - 2, sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNFACE], FALSE);
    else
      if (state & SS_OUTSIDE)
        draw_3d (vdi_handle, ob_x + 1, ob_y + 1, 1, ob_w - 2, ob_h - 2, sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], FALSE);

  ob_x++;				/* don't use border for background and text */
  ob_y++;
  ob_w -= 2;
  ob_h -= 2;

  if (text != NULL)
  {
    vst_font (vdi_handle, (fontdesc != NULL) ? fontdesc->font : font_btntext);
    vst_point (vdi_handle, (fontdesc != NULL) ? fontdesc->point : point_btntext, &ret, &ret, &ret, &ret);
    vst_effects (vdi_handle, (fontdesc != NULL) ? fontdesc->effects : effects_btntext);
    vqt_extent (vdi_handle, text, extent);
    vqt_font_info (vdi_handle, &minimum, &maximum, distances, &width, effects);

    w = extent [2] - extent [0] + effects [2];
    h = extent [5] - extent [3];
    x = ob_x;
    y = ob_y + (ob_h - h) / 2;

    xywh2rect (ob_x, ob_y, ob_w, ob_h, &r);
    clear_rect (&r, bk_color);

    rc_intersect (rc_clip, &r);		/* so text won't be written outside object rectangle */
    set_clip (TRUE, &r);

    if (state & SS_RIGHT)
      x = ob_x + ob_w - w;
    else
      if (state & SS_CENTER)
        x = ob_x + (ob_w - w) / 2;

    vswr_mode (vdi_handle, MD_TRANS);

    if ((dlg_colors >= 16) && disabled)
    {
      vst_color (vdi_handle, WHITE);
      v_gtext (vdi_handle, x + 1, y + 1, text);
    } /* if */

    vst_color (vdi_handle, (fontdesc != NULL) ? fontdesc->color : sys_colors [COLOR_BTNTEXT]);

    if (disabled)
      if (dlg_colors < 16)
        vst_effects (vdi_handle, TXT_LIGHT | ((fontdesc != NULL) ? fontdesc->effects : effects_btntext));
      else
        vst_color (vdi_handle, sys_colors [COLOR_DISABLED]);

    v_gtext (vdi_handle, x, y, text);
    draw_acc_line (vdi_handle, x, y, text, acc_inx, disabled, dlg_colors, (fontdesc != NULL) ? fontdesc->color : sys_colors [COLOR_BTNTEXT], bk_color);
  } /* if */

  if (selected && (dlg_colors < 16))
  {
    xywh2array (ob_x, ob_y, ob_w, ob_h, xy);
    vswr_mode (vdi_handle, MD_XOR);
    vsf_color (vdi_handle, BLACK);
    vsf_interior (vdi_handle, FIS_SOLID);
    vr_recfl (vdi_handle, xy);
  } /* if */

  set_clip (TRUE, &save_clip);
} /* DrawString */

/*****************************************************************************/

GLOBAL VOID Draw3DBox (WORD vdi_handle, RECT *rc, RECT *rc_clip, WORD state, WORD border)
{
  WORD ob_x, ob_y, ob_w, ob_h, w;
  WORD xy [8];
  RECT save_clip;

  save_clip = clip;
  ob_x      = rc->x;
  ob_y      = rc->y;
  ob_w      = rc->w;
  ob_h      = rc->h;

  set_clip (TRUE, rc_clip);

  line_default (vdi_handle);

  if (dlg_colors >= 16)
  {
    w = border;

    if (state & IS_BORDER)
      border++;

    if (border <= 0)
    {
      w      = - border;
      border = 0;
    } /* if */

    if (state & IS_ROUNDBORDER)
    {
      border = (state & IS_BORDER) != 0;

      draw_3d (vdi_handle, ob_x + 5 + border, ob_y + 5 + border, 0, ob_w - 2 * (5 + border), ob_h - 2 * (5 + border), sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], TRUE);
      draw_3d (vdi_handle, ob_x + 4 + border, ob_y + 4 + border, 1, ob_w - 2 * (4 + border), ob_h - 2 * (4 + border), sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNFACE], FALSE);
      draw_3d (vdi_handle, ob_x + 3 + border, ob_y + 3 + border, 2, ob_w - 2 * (3 + border), ob_h - 2 * (3 + border), sys_colors [COLOR_BTNFACE], sys_colors [COLOR_BTNFACE], sys_colors [COLOR_BTNFACE], FALSE);
      draw_3d (vdi_handle, ob_x + 1 + border, ob_y + 1 + border, 1, ob_w - 2 * (1 + border), ob_h - 2 * (1 + border), sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], (state & IS_BORDER) != 0);
    } /* if */
    else
      if (state & IS_INSIDE)
        draw_3d (vdi_handle, ob_x + border, ob_y + border, w, ob_w - 2 * border, ob_h - 2 * border, sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNFACE], (state & IS_BORDER) != 0);
      else
        if (state & IS_OUTSIDE)
          draw_3d (vdi_handle, ob_x + border, ob_y + border, w, ob_w - 2 * border, ob_h - 2 * border, sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], (state & IS_BORDER) != 0);
        else
          if (state & IS_DOUBLELINE)
          {
            line_default (vdi_handle);
            xywh2array (ob_x, ob_y, ob_w, 1, xy);
            vsl_color (vdi_handle, sys_colors [COLOR_BTNHIGHLIGHT]);
            v_pline (vdi_handle, 2, xy);
            xywh2array (ob_x, ob_y + ob_h - ((state & IS_BORDER) ? 2 : 1), ob_w, 1, xy);
            vsl_color (vdi_handle, sys_colors [COLOR_BTNSHADOW]);
            v_pline (vdi_handle, 2, xy);

            if (state & IS_BORDER)
            {
              xywh2array (ob_x, ob_y + ob_h - 1, ob_w, 1, xy);
              vsl_color (vdi_handle, BLACK);
              v_pline (vdi_handle, 2, xy);
            } /* if */
          } /* if, else, else, else */
  } /* if */
  else
  {
    if (state & (IS_INSIDE | IS_OUTSIDE))
      draw_3d (vdi_handle, ob_x, ob_y, 0, ob_w, ob_h, BLACK, BLACK, BLACK, TRUE);

    if ((state & (IS_BORDER | IS_DOUBLELINE)) == (IS_BORDER | IS_DOUBLELINE))
    {
      xywh2array (ob_x, ob_y + ob_h - 1, ob_w, 1, xy);
      vsl_color (vdi_handle, BLACK);
      v_pline (vdi_handle, 2, xy);
    } /* if */

    if ((state & (IS_BORDER | IS_ROUNDBORDER)) == (IS_BORDER | IS_ROUNDBORDER))
      draw_3d (vdi_handle, ob_x + 1, ob_y + 1, 0, ob_w - 2, ob_h - 2, BLACK, BLACK, BLACK, TRUE);
  } /* else */

  set_clip (TRUE, &save_clip);
} /* Draw3DBox */

/*****************************************************************************/

GLOBAL VOID DrawComboBox (WORD vdi_handle, RECT *rc, RECT *rc_clip, BYTE *text, WORD style, WORD bk_color, FONTDESC *fontdesc, WORD left_offset, WORD button_width, WORD num_tabs, WORD *tabs, WORD *tabstyles)
{
  LOCAL WORD    ob_x, ob_y, ob_w, ob_h, ret;
  LOCAL WORD    x, y, h;
  LOCAL BOOLEAN selected, disabled;
  LOCAL WORD    xy [8];
  LOCAL WORD    minimum, maximum, width;
  LOCAL WORD    extent [8], distances [5], effects [3];
  LOCAL RECT    save_clip, new_clip, r;
  LOCAL MFDB    s, d;
  LOCAL WORD    index [2];

  save_clip = clip;
  ob_x      = rc->x;
  ob_y      = rc->y;
  ob_w      = rc->w;
  ob_h      = rc->h;
  selected  = (style & LBS_SELECTED) != 0;
  disabled  = (style & LBS_DISABLED) != 0;

  set_clip (TRUE, rc_clip);

  if ((bk_color == FAILURE) || (dlg_colors < 16))
    bk_color = WHITE;

  line_default (vdi_handle);
  text_default (vdi_handle);

  vst_font (vdi_handle, (fontdesc == NULL) || (fontdesc->font == FAILURE) ? font_btntext : fontdesc->font);
  vst_point (vdi_handle, (fontdesc == NULL) || (fontdesc->point == FAILURE) ? point_btntext : fontdesc->point, &ret, &ret, &ret, &ret);
  vst_color (vdi_handle, (fontdesc == NULL) || (fontdesc->color == FAILURE) ? sys_colors [COLOR_BTNTEXT] : fontdesc->color);
  vst_effects (vdi_handle, (fontdesc == NULL) || (fontdesc->effects == (UWORD)FAILURE) ? effects_btntext : fontdesc->effects);
  vqt_extent (vdi_handle, (text != NULL) ? text : "", extent);
  vqt_font_info (vdi_handle, &minimum, &maximum, distances, &width, effects);

  h = extent [5] - extent [3];

  if (! (style & LBS_COMBOTEXTREDRAW))			/* so a redraw wouldn't destroy the top or bottom of the drop down list */
    if ((dlg_colors >= 16) && ! (style & LBS_NO3DBORDER))
    {
      draw_3d (vdi_handle, ob_x + 1, ob_y + 1, 1, ob_w - 2, ob_h - 2, sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNFACE], FALSE);
      draw_3d (vdi_handle, ob_x + 2, ob_y + 2, 1, ob_w - 4, ob_h - 4, BLACK, sys_colors [COLOR_BTNFACE], sys_colors [COLOR_BTNSHADOW], FALSE);
    } /* if */
    else
      draw_3d (vdi_handle, ob_x + 2, ob_y + 2, 1, ob_w - 4, ob_h - 4, BLACK, BLACK, BLACK, FALSE);

  xywh2array (ob_x + 2, ob_y + 2, ob_w - 3 - button_width, ob_h - 4, xy);
  vswr_mode (vdi_handle, MD_REPLACE);
  vsf_color (vdi_handle, bk_color);
  vsf_interior (vdi_handle, FIS_SOLID);
  vr_recfl (vdi_handle, xy);			/* fill the interior */

  if ((rc_clip->x + rc_clip->w >= ob_x + ob_w - button_width - 1) && (rc_clip->y + rc_clip->h >= ob_y + 1) && ! (style & LBS_COMBOTEXTREDRAW))
  {
    vswr_mode (vdi_handle, MD_TRANS);
    vsf_color (vdi_handle, BLACK);
    vsf_interior (vdi_handle, FIS_HOLLOW);
    vsf_perimeter (vdi_handle, TRUE);
    vsf_style (vdi_handle, 0);
    xywh2array (ob_x + ob_w - button_width - 1, ob_y + 1, button_width, ob_h - 2, xy);
    v_bar (vdi_handle, xy);			/* border of arrow area */
    vswr_mode (vdi_handle, MD_REPLACE);

    d.mp  = NULL;
    s.mp  = (VOID *)arrows1_buf;
    s.fwp = arrows_width;
    s.fh  = arrows_height;
    s.fww = (s.fwp + 15) / 16;
    s.ff  = FALSE;
    s.np  = 1;

    if (dlg_colors >= 16)
    {
      vsf_color (vdi_handle, sys_colors [COLOR_BTNFACE]);
      vsf_interior (vdi_handle, FIS_SOLID);
      xywh2array (ob_x + ob_w - button_width, ob_y + 2, button_width - 2, ob_h - 4, xy);
      vr_recfl (vdi_handle, xy);		/* down arrow background */

      if (selected)
        draw_3d (vdi_handle, ob_x + ob_w - button_width + 1, ob_y + 3, 1, button_width - 4, ob_h - 6, sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], sys_colors [COLOR_BTNSHADOW], TRUE);
      else
        draw_3d (vdi_handle, ob_x + ob_w - button_width + 1, ob_y + 3, 1, button_width - 4, ob_h - 6, sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], TRUE);

      xywh2array (2 * ARROW_SIZE, 2 * dlg_arrow * ARROW_SIZE, ARROW_SIZE, ARROW_SIZE, &xy [0]);

      if (disabled)
      {
        xywh2array (ob_x + ob_w - button_width - 1 + (button_width - ARROW_SIZE) / 2 + 1, ob_y + 1 + (ob_h - 2 - ARROW_SIZE) / 2 + 1, ARROW_SIZE, ARROW_SIZE, &xy [4]);

        if (selected)
        {
          xy [4]++;
          xy [5]++;
          xy [6]++;
          xy [7]++;
        } /* if */

        index [0] = WHITE;
        index [1] = sys_colors [COLOR_BTNFACE];

        vrt_cpyfm (vdi_handle, MD_TRANS, xy, &s, &d, index);		/* draw disabled down arrow */
      } /* if */

      xywh2array (ob_x + ob_w - button_width - 1 + (button_width - ARROW_SIZE) / 2, ob_y + 1 + (ob_h - 2 - ARROW_SIZE) / 2, ARROW_SIZE, ARROW_SIZE, &xy [4]);

      if (selected)
      {
        xy [4]++;
        xy [5]++;
        xy [6]++;
        xy [7]++;
      } /* if */

      index [0] = disabled ? sys_colors [COLOR_DISABLED] : sys_colors [COLOR_BTNTEXT];
      index [1] = sys_colors [COLOR_BTNFACE];

      vrt_cpyfm (vdi_handle, MD_TRANS, xy, &s, &d, index);		/* draw down arrow */
    } /* if */
    else
    {
      vsf_color (vdi_handle, WHITE);
      vsf_interior (vdi_handle, FIS_SOLID);
      xywh2array (ob_x + ob_w - button_width, ob_y + 2, button_width - 2, ob_h - 4, xy);
      vr_recfl (vdi_handle, xy);					/* down arrow background */

      draw_3d (vdi_handle, ob_x + ob_w - button_width, ob_y + 2, 0, button_width - 2, ob_h - 4, sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], TRUE);

      xywh2array (2 * ARROW_SIZE, 2 * dlg_arrow * ARROW_SIZE, ARROW_SIZE, ARROW_SIZE, &xy [0]);
      xywh2array (ob_x + ob_w - button_width - 1 + (button_width - ARROW_SIZE) / 2, ob_y + 1 + (ob_h - 2 - ARROW_SIZE) / 2, ARROW_SIZE, ARROW_SIZE, &xy [4]);

      index [0] = BLACK;
      index [1] = WHITE;

      vrt_cpyfm (vdi_handle, MD_TRANS, xy, &s, &d, index);		/* draw down arrow */

      vswr_mode (vdi_handle, MD_XOR);
      vsf_color (vdi_handle, BLACK);
      vsf_interior (vdi_handle, FIS_SOLID);

      if (selected)
      {
        xywh2array (ob_x + ob_w - button_width, ob_y + 2, button_width - 2, ob_h - 4, xy);
        vr_recfl (vdi_handle, xy);
      } /* if */
    } /* else */
  } /* if */

  ob_x += 2;								/* don't use border for background and text */
  ob_y += 2;
  ob_w -= button_width + 3;
  ob_h -= 4;

  x = ob_x + left_offset;
  y = ob_y + (ob_h - h) / 2;

  if (disabled)
    if (dlg_colors < 16)
      vst_effects (vdi_handle, TXT_LIGHT | effects_btntext);
    else
      vst_color (vdi_handle, sys_colors [COLOR_DISABLED]);

  vswr_mode (vdi_handle, MD_TRANS);
  xywh2rect (ob_x, ob_y, ob_w, ob_h, &r);
  new_clip = *rc_clip;
  rc_intersect (&r, &new_clip);
  set_clip (TRUE, &new_clip);

  if (! (style & LBS_OWNERDRAW))
    tabbed_text (vdi_handle, x, y, text, num_tabs, tabs, tabstyles);

  set_clip (TRUE, &save_clip);
} /* DrawComboBox */

/*****************************************************************************/

GLOBAL VOID DrawListBox (WORD vdi_handle, RECT *rc, RECT *rc_clip, HLB hlb)
{
  LISTBOX       *lb = hlb;
  LOCAL WORD    ob_x, ob_y, ob_w, ob_h;
  LOCAL WORD    xy [8];
  LOCAL BOOLEAN vsb_disabled;
  LOCAL RECT    save_clip, r;

  save_clip = clip;
  set_clip (TRUE, rc_clip);
  rect2xywh (rc, &ob_x, &ob_y, &ob_w, &ob_h);

  lb->rc_obj       = *rc;
  lb->vsb.pagesize = (ob_h - 4) / lb->item_height;
  lb->vsb.pix_size = sb_calc_pix_size (&lb->vsb);
  lb->vsb.pix_pos  = sb_calc_pix_pos (&lb->vsb);
  lb->vsb_vis      = (lb->style & LBS_VSCROLL) || (lb->vsb.count > lb->vsb.pagesize);
  vsb_disabled     = lb->vsb.count <= lb->vsb.pagesize;

  line_default (vdi_handle);

  if ((dlg_colors >= 16) && ! (lb->style & LBS_NO3DBORDER))
  {
    draw_3d (vdi_handle, ob_x + 1, ob_y + 1, 1, ob_w - 2, ob_h - 2, sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNFACE], FALSE);
    draw_3d (vdi_handle, ob_x + 2, ob_y + 2, 1, ob_w - 4, ob_h - 4, BLACK, sys_colors [COLOR_BTNFACE], sys_colors [COLOR_BTNSHADOW], FALSE);
  } /* if */
  else
    draw_3d (vdi_handle, ob_x + 2, ob_y + 2, 1, ob_w - 4, ob_h - 4, BLACK, BLACK, BLACK, FALSE);

  xywh2array (ob_x + 2, ob_y + 2, ob_w - 3 - (lb->vsb_vis ? lb->vsb_size : 1), ob_h - 4, xy);
  vswr_mode (vdi_handle, MD_REPLACE);
  vsf_color (vdi_handle, (dlg_colors < 16) || (lb->bk_color == FAILURE) ? WHITE : lb->bk_color);
  vsf_interior (vdi_handle, FIS_SOLID);
  vr_recfl (vdi_handle, xy);			/* fill the interior */

  if (lb->vsb_vis && (rc_clip->x + rc_clip->w - 1 >= ob_x + ob_w - lb->vsb_size - 1) && (rc_clip->y + rc_clip->h >= ob_y + 1))
  {
    r    = *rc;
    r.x += r.w - (lb->vsb_size + 2);
    r.w  = lb->vsb_size + 2;

    DrawScrollBar (vdi_handle, &r, rc_clip, &lb->vsb);
  } /* if */

  if ((! lb->vsb_vis || (rc_clip->x < ob_x + ob_w - lb->vsb_size - 1)) && (rc_clip->y + rc_clip->h >= ob_y + 1))	/* draw listbox items */
    lb_draw_items (lb, rc, 0, lb->vsb.pagesize - 1);

  set_clip (TRUE, &save_clip);
} /* DrawListBox */

/*****************************************************************************/

GLOBAL VOID DrawScrollBar (WORD vdi_handle, RECT *rc, RECT *rc_clip, HSB hsb)
{
  SCROLLBAR     *sb = hsb;
  LOCAL WORD    ob_x, ob_y, ob_w, ob_h, boxsize;
  LOCAL MFDB    s, d;
  LOCAL WORD    xy [8];
  LOCAL WORD    index [2];
  LOCAL BOOLEAN disabled;
  LOCAL RECT    save_clip, r;

  save_clip = clip;
  set_clip (TRUE, rc_clip);
  rect2xywh (rc, &ob_x, &ob_y, &ob_w, &ob_h);

  boxsize      = (sb->style & SBS_HORIZONTAL) ? ob_h - 2 : ob_w - 2;
  disabled     = sb->count <= sb->pagesize;
  sb->rc_obj   = *rc;
  sb->pix_size = sb_calc_pix_size (sb);
  sb->pix_pos  = sb_calc_pix_pos (sb);

  line_default (vdi_handle);

  if ((dlg_colors >= 16) && ! (sb->style & SBS_NO3DBORDER))
    draw_3d (vdi_handle, ob_x + 1, ob_y + 1, 1, ob_w - 2, ob_h - 2, sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNFACE], FALSE);

  draw_3d (vdi_handle, ob_x + 2, ob_y + 2, 1, ob_w - 4, ob_h - 4, BLACK, BLACK, BLACK, FALSE);

  d.mp  = NULL;
  s.mp  = (VOID *)arrows1_buf;
  s.fwp = arrows_width;
  s.fh  = arrows_height;
  s.fww = (s.fwp + 15) / 16;
  s.ff  = FALSE;
  s.np  = 1;

  if (dlg_colors >= 16)
  {
    vsf_color (vdi_handle, sys_colors [COLOR_BTNFACE]);
    vsf_interior (vdi_handle, FIS_SOLID);
    sb_calc_rect (sb, SBC_UP, &r, xy, 1, 0);
    vr_recfl (vdi_handle, xy);						/* up arrow background */

    sb_calc_rect (sb, SBC_DOWN, &r, xy, 1, 0);
    vr_recfl (vdi_handle, xy);						/* down arrow background */

    sb_calc_rect (sb, SBC_UP, &r, xy, 2, 0);

    if (sb->uparrow_selected)
      draw_3d (vdi_handle, r.x, r.y, 1, boxsize - 4, boxsize - 4, sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], sys_colors [COLOR_BTNSHADOW], TRUE);
    else
      draw_3d (vdi_handle, r.x, r.y, 1, boxsize - 4, boxsize - 4, sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], TRUE);

    sb_calc_rect (sb, SBC_DOWN, &r, xy, 2, 0);

    if (sb->downarrow_selected)
      draw_3d (vdi_handle, r.x, r.y, 1, boxsize - 4, boxsize - 4, sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], sys_colors [COLOR_BTNSHADOW], TRUE);
    else
      draw_3d (vdi_handle, r.x, r.y, 1, boxsize - 4, boxsize - 4, sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], TRUE);

    sb_calc_rect (sb, SBC_UP, &r, NULL, 0, sb->uparrow_selected ? 1 : 0);
    xywh2array (0, 2 * dlg_arrow * ARROW_SIZE + ((sb->style & SBS_HORIZONTAL) ? ARROW_SIZE : 0), ARROW_SIZE, ARROW_SIZE, &xy [0]);

    if (disabled)
    {
      xywh2array (r.x + (boxsize - ARROW_SIZE) / 2 + 1, r.y + (boxsize - ARROW_SIZE) / 2 + 1, ARROW_SIZE, ARROW_SIZE, &xy [4]);

      index [0] = WHITE;
      index [1] = sys_colors [COLOR_BTNFACE];

      vrt_cpyfm (vdi_handle, MD_TRANS, xy, &s, &d, index);		/* draw disabled up arrow */
    } /* if */

    xywh2array (r.x + (boxsize - ARROW_SIZE) / 2, r.y + (boxsize - ARROW_SIZE) / 2, ARROW_SIZE, ARROW_SIZE, &xy [4]);

    index [0] = disabled ? sys_colors [COLOR_DISABLED] : sys_colors [COLOR_BTNTEXT];
    index [1] = sys_colors [COLOR_BTNFACE];

    vrt_cpyfm (vdi_handle, MD_TRANS, xy, &s, &d, index);		/* draw up arrow */

    sb_calc_rect (sb, SBC_DOWN, &r, NULL, 0, sb->downarrow_selected ? 1 : 0);
    xywh2array (ARROW_SIZE, 2 * dlg_arrow * ARROW_SIZE + ((sb->style & SBS_HORIZONTAL) ? ARROW_SIZE : 0), ARROW_SIZE, ARROW_SIZE, &xy [0]);

    if (disabled)
    {
      xywh2array (r.x + (boxsize - ARROW_SIZE) / 2 + 1, r.y + (boxsize - ARROW_SIZE) / 2 + 1, ARROW_SIZE, ARROW_SIZE, &xy [4]);

      index [0] = WHITE;
      index [1] = sys_colors [COLOR_BTNFACE];

      vrt_cpyfm (vdi_handle, MD_TRANS, xy, &s, &d, index);		/* draw disabled down arrow */
    } /* if */

    xywh2array (r.x + (boxsize - ARROW_SIZE) / 2, r.y + (boxsize - ARROW_SIZE) / 2, ARROW_SIZE, ARROW_SIZE, &xy [4]);

    index [0] = disabled ? sys_colors [COLOR_DISABLED] : sys_colors [COLOR_BTNTEXT];
    index [1] = sys_colors [COLOR_BTNFACE];

    vrt_cpyfm (vdi_handle, MD_TRANS, xy, &s, &d, index);		/* draw down arrow */
  } /* if */
  else
  {
    vsf_color (vdi_handle, BLACK);
    vsf_interior (vdi_handle, FIS_HOLLOW);
    vsf_perimeter (vdi_handle, TRUE);

    sb_calc_rect (sb, SBC_UP, &r, xy, 0, 0);
    v_bar (vdi_handle, xy);						/* up arrow background */

    sb_calc_rect (sb, SBC_DOWN, &r, xy, 0, 0);
    v_bar (vdi_handle, xy);						/* down arrow background */

    sb_calc_rect (sb, SBC_UP, &r, NULL, 0, 0);
    xywh2array (0, 2 * dlg_arrow * ARROW_SIZE + ((sb->style & SBS_HORIZONTAL) ? ARROW_SIZE : 0), ARROW_SIZE, ARROW_SIZE, &xy [0]);
    xywh2array (r.x + (boxsize - ARROW_SIZE) / 2, r.y + (boxsize - ARROW_SIZE) / 2, ARROW_SIZE, ARROW_SIZE, &xy [4]);

    index [0] = BLACK;
    index [1] = WHITE;

    vrt_cpyfm (vdi_handle, MD_TRANS, xy, &s, &d, index);		/* draw up arrow */

    vswr_mode (vdi_handle, MD_XOR);
    vsf_color (vdi_handle, BLACK);
    vsf_interior (vdi_handle, FIS_SOLID);

    if (sb->uparrow_selected)
    {
      sb_calc_rect (sb, SBC_UP, &r, xy, 1, 0);
      vr_recfl (vdi_handle, xy);
    } /* if */

    sb_calc_rect (sb, SBC_DOWN, &r, NULL, 0, 0);
    xywh2array (ARROW_SIZE, 2 * dlg_arrow * ARROW_SIZE + ((sb->style & SBS_HORIZONTAL) ? ARROW_SIZE : 0), ARROW_SIZE, ARROW_SIZE, &xy [0]);
    xywh2array (r.x + (boxsize - ARROW_SIZE) / 2, r.y + (boxsize - ARROW_SIZE) / 2, ARROW_SIZE, ARROW_SIZE, &xy [4]);

    index [0] = BLACK;
    index [1] = WHITE;

    vrt_cpyfm (vdi_handle, MD_TRANS, xy, &s, &d, index);		/* draw down arrow */

    if (sb->downarrow_selected)
    {
      sb_calc_rect (sb, SBC_DOWN, &r, xy, 1, 0);
      vr_recfl (vdi_handle, xy);
    } /* if */

    vswr_mode (vdi_handle, MD_REPLACE);
  } /* else */

  if (dlg_colors >= 16)
  {
    vsf_color (vdi_handle, disabled ? WHITE : (sb->bk_color == FAILURE) ? sys_colors [COLOR_SCROLLBAR] : sb->bk_color);
    vsf_interior (vdi_handle, FIS_SOLID);
    vsf_perimeter (vdi_handle, FALSE);
    vsf_style (vdi_handle, 0);
    sb_calc_rect (sb, SBC_PARENT, &r, xy, 1, 0);
    v_bar (vdi_handle, xy);						/* slider area */

    if (! disabled)
    {
      vsf_color (vdi_handle, sys_colors [COLOR_BTNFACE]);
      vsf_interior (vdi_handle, FIS_SOLID);
      sb_calc_rect (sb, SBC_SLIDER, &r, xy, 1, 0);
      vr_recfl (vdi_handle, xy);					/* slider background */

      if (sb->style & SBS_HORIZONTAL)
        draw_3d (vdi_handle, r.x + 1, r.y + 1, 1, sb->pix_size - 4, boxsize - 4, sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], TRUE);
      else
        draw_3d (vdi_handle, r.x + 1, r.y + 1, 1, boxsize - 4, sb->pix_size - 4, sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], TRUE);
    } /* if */
  } /* if */
  else
  {
    vsf_color (vdi_handle, disabled ? WHITE : BLACK);
    vsf_interior (vdi_handle, disabled ? FIS_SOLID : FIS_PATTERN);
    vsf_perimeter (vdi_handle, FALSE);
    vsf_style (vdi_handle, disabled ? 0 : 1);
    sb_calc_rect (sb, SBC_PARENT, &r, xy, 1, 0);
    v_bar (vdi_handle, xy);						/* slider area */

    if (! disabled)
    {
      vsf_color (vdi_handle, WHITE);
      vsf_interior (vdi_handle, FIS_SOLID);
      sb_calc_rect (sb, SBC_SLIDER, &r, xy, 1, 0);
      vr_recfl (vdi_handle, xy);					/* slider background */

      if (sb->style & SBS_HORIZONTAL)
        draw_3d (vdi_handle, r.x, r.y, 0, sb->pix_size - 2, boxsize - 2, sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], TRUE);
      else
        draw_3d (vdi_handle, r.x, r.y, 0, boxsize - 2, sb->pix_size - 2, sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], TRUE);
    } /* if */
  } /* else */

  set_clip (TRUE, &save_clip);
} /* DrawScrollBar */

/*****************************************************************************/

GLOBAL VOID DrawImageButton (WORD vdi_handle, RECT *rc, RECT *rc_clip, WORD style, WORD image)
{
  LOCAL WORD    ob_x, ob_y, ob_w, ob_h, w, h, size;
  LOCAL BOOLEAN selected, disabled;
  LOCAL WORD    xy [8];
  LOCAL RECT    save_clip;
  LOCAL MFDB    s, d;
  LOCAL WORD    index [2];
  LOCAL UBYTE   *buf;

  save_clip = clip;
  ob_x      = rc->x;
  ob_y      = rc->y;
  ob_w      = rc->w;
  ob_h      = rc->h;
  selected  = (style & IBS_SELECTED) != 0;
  disabled  = (style & IBS_DISABLED) != 0;

  set_clip (TRUE, rc_clip);

  line_default (vdi_handle);

  if ((rc_clip->x + rc_clip->w >= ob_x) && (rc_clip->y + rc_clip->h >= ob_y))
  {
    vswr_mode (vdi_handle, MD_TRANS);
    vsf_color (vdi_handle, BLACK);
    vsf_interior (vdi_handle, FIS_HOLLOW);
    vsf_perimeter (vdi_handle, TRUE);
    vsf_style (vdi_handle, 0);
    xywh2array (ob_x, ob_y, ob_w, ob_h, xy);
    v_bar (vdi_handle, xy);			/* border of arrow area */
    vswr_mode (vdi_handle, MD_REPLACE);

    switch (image)
    {
      case DIB_DOWNARROW : buf  = arrows1_buf;
                           w    = arrows_width;
                           h    = arrows_height;
                           size = ARROW_SIZE;
                           break;
      case DIB_DOTS      : buf  = dots1_buf;
                           w    = dots_width;
                           h    = dots_height;
                           size = DOTS_SIZE;
                           break;
    } /* switch */

    d.mp  = NULL;
    s.mp  = (VOID *)buf;
    s.fwp = w;
    s.fh  = h;
    s.fww = (s.fwp + 15) / 16;
    s.ff  = FALSE;
    s.np  = 1;

    if (dlg_colors >= 16)
    {
      vsf_color (vdi_handle, sys_colors [COLOR_BTNFACE]);
      vsf_interior (vdi_handle, FIS_SOLID);
      xywh2array (ob_x + 1, ob_y + 1, ob_w - 2, ob_h - 2, xy);
      vr_recfl (vdi_handle, xy);		/* background */

      if (selected)
        draw_3d (vdi_handle, ob_x + 2, ob_y + 2, 1, ob_w - 4, ob_h - 4, sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], sys_colors [COLOR_BTNSHADOW], TRUE);
      else
        draw_3d (vdi_handle, ob_x + 2, ob_y + 2, 1, ob_w - 4, ob_h - 4, sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNFACE], TRUE);

      if (image == DIB_DOWNARROW)
        xywh2array (2 * size, 2 * dlg_arrow * size, size, size, &xy [0]);
      else
        xywh2array (0, 0, size, size, &xy [0]);

      if (disabled)
      {
        xywh2array (ob_x + 1 + (ob_w - 2 - size) / 2 + 1, ob_y + 1 + (ob_h - 2 - size) / 2 + 1, size, size, &xy [4]);

        if (selected)
        {
          xy [4]++;
          xy [5]++;
          xy [6]++;
          xy [7]++;
        } /* if */

        index [0] = WHITE;
        index [1] = sys_colors [COLOR_BTNFACE];

        vrt_cpyfm (vdi_handle, MD_TRANS, xy, &s, &d, index);		/* draw disabled image */
      } /* if */

      xywh2array (ob_x + 1 + (ob_w - 2 - size) / 2, ob_y + 1 + (ob_h - 2 - size) / 2, size, size, &xy [4]);

      if (selected)
      {
        xy [4]++;
        xy [5]++;
        xy [6]++;
        xy [7]++;
      } /* if */

      index [0] = disabled ? sys_colors [COLOR_DISABLED] : sys_colors [COLOR_BTNTEXT];
      index [1] = sys_colors [COLOR_BTNFACE];

      vrt_cpyfm (vdi_handle, MD_TRANS, xy, &s, &d, index);		/* draw image */
    } /* if */
    else
    {
      vsf_color (vdi_handle, WHITE);
      vsf_interior (vdi_handle, FIS_SOLID);
      xywh2array (ob_x + 1, ob_y + 1, ob_w - 2, ob_h - 2, xy);
      vr_recfl (vdi_handle, xy);					/* background */

      if (image == DIB_DOWNARROW)
        xywh2array (2 * size, 2 * dlg_arrow * size, size, size, &xy [0]);
      else
        xywh2array (0, 0, size, size, &xy [0]);

      xywh2array (ob_x + 1 + (ob_w - 2 - size) / 2, ob_y + 1 + (ob_h - 2 - size) / 2, size, size, &xy [4]);

      index [0] = BLACK;
      index [1] = WHITE;

      vrt_cpyfm (vdi_handle, MD_TRANS, xy, &s, &d, index);		/* draw image */

      vswr_mode (vdi_handle, MD_XOR);
      vsf_color (vdi_handle, BLACK);
      vsf_interior (vdi_handle, FIS_SOLID);

      if (selected)
      {
        xywh2array (ob_x + 1, ob_y + 1, ob_w - 2, ob_h - 2, xy);
        vr_recfl (vdi_handle, xy);
      } /* if */
    } /* else */
  } /* if */

  set_clip (TRUE, &save_clip);
} /* DrawImageButton */

/*****************************************************************************/

GLOBAL VOID ListBoxRedraw (OBJECT *tree, WORD obj)
{
  LISTBOX *lb = lb_from_obj (tree, obj, TRUE);

  ListBox_Redraw (lb);
} /* ListBoxRedraw */

/*****************************************************************************/

GLOBAL VOID ListBoxDraw (OBJECT *tree, WORD obj, RECT *rc_clip)
{
  LISTBOX *lb = lb_from_obj (tree, obj, TRUE);

  ListBox_Draw (lb, rc_clip);
} /* ListBoxDraw */

/*****************************************************************************/

GLOBAL LONG ListBoxClick (OBJECT *tree, WORD obj, MKINFO *mk)
{
  LISTBOX *lb = lb_from_obj (tree, obj, TRUE);

  return (ListBox_Click (lb, mk));
} /* ListBoxClick */

/*****************************************************************************/

GLOBAL VOID ListBoxKey (OBJECT *tree, WORD obj, MKINFO *mk)
{
  LISTBOX *lb = lb_from_obj (tree, obj, TRUE);

  ListBox_Key (lb, mk);
} /* ListBoxKey */

/*****************************************************************************/

GLOBAL LONG ListBoxSendMessage (OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  return (ListBox_SendMessage (lb, msg, item, p));
} /* ListBoxSendMessage */

/*****************************************************************************/

GLOBAL LB_CALLBACK ListBoxGetCallback (OBJECT *tree, WORD obj)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  return (ListBox_GetCallback (lb));
} /* ListBoxGetCallback */

/*****************************************************************************/

GLOBAL VOID ListBoxSetCallback (OBJECT *tree, WORD obj, LB_CALLBACK callback)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  ListBox_SetCallback (lb, callback);
} /* ListBoxSetCallback */

/*****************************************************************************/

GLOBAL WORD ListBoxGetWindowHandle (OBJECT *tree, WORD obj)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  return (ListBox_GetWindowHandle (lb));
} /* ListBoxGetWindowHandle */

/*****************************************************************************/

GLOBAL VOID ListBoxSetWindowHandle (OBJECT *tree, WORD obj, WORD wh)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  ListBox_SetWindowHandle (lb, wh);
} /* ListBoxSetWindowHandle */

/*****************************************************************************/

GLOBAL VOID ListBoxGetFont (OBJECT *tree, WORD obj, WORD *font, WORD *point, UWORD *effects, WORD *color, WORD *bk_color)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  ListBox_GetFont (lb, font, point, effects, color, bk_color);
} /* ListBoxGetFont */

/*****************************************************************************/

GLOBAL VOID ListBoxSetFont (OBJECT *tree, WORD obj, WORD font, WORD point, UWORD effects, WORD color, WORD bk_color)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  ListBox_SetFont (lb, font, point, effects, color, bk_color);
} /* ListBoxSetFont */

/*****************************************************************************/

GLOBAL VOID ListBoxSetFocus (OBJECT *tree, WORD obj)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  ListBox_SetFocus (lb);
} /* ListBoxSetFocus */

/*****************************************************************************/

GLOBAL VOID ListBoxKillFocus (OBJECT *tree, WORD obj)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  ListBox_KillFocus (lb);
} /* ListBoxKillFocus */

/*****************************************************************************/

GLOBAL UWORD ListBoxGetStyle (OBJECT *tree, WORD obj)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  return (ListBox_GetStyle (lb));
} /* ListBoxGetStyle */

/*****************************************************************************/

GLOBAL VOID ListBoxSetStyle (OBJECT *tree, WORD obj, UWORD style, BOOLEAN on)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  if (on)
  {
    if (style & LBS_DISABLED)
      do_state (tree, obj, DISABLED);

    if (style & LBS_SELECTED)
      do_state (tree, obj, SELECTED);
  } /* if */
  else
  {
    if (style & LBS_DISABLED)
      undo_state (tree, obj, DISABLED);

    if (style & LBS_SELECTED)
      undo_state (tree, obj, SELECTED);
  } /* else */

  ListBox_SetStyle (lb, style, on);
} /* ListBoxSetStyle */

/*****************************************************************************/

GLOBAL LONG ListBoxGetCount (OBJECT *tree, WORD obj)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  return (ListBox_GetCount (lb));
} /* ListBoxGetCount */

/*****************************************************************************/

GLOBAL VOID ListBoxSetCount (OBJECT *tree, WORD obj, LONG count, BYTE **strings)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  ListBox_SetCount (lb, count, strings);
} /* ListBoxSetCount */

/*****************************************************************************/

GLOBAL WORD ListBoxGetTextLen (OBJECT *tree, WORD obj, LONG index)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  return (ListBox_GetTextLen (lb, index));
} /* ListBoxGetTextLen */

/*****************************************************************************/

GLOBAL WORD ListBoxGetText (OBJECT *tree, WORD obj, LONG index, BYTE *string)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  return (ListBox_GetText (lb, index, string));
} /* ListBoxGetText */

/*****************************************************************************/

GLOBAL LONG ListBoxFindString (OBJECT *tree, WORD obj, LONG index_start, BYTE *find)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  return (ListBox_FindString (lb, index_start, find));
} /* ListBoxFindString */

/*****************************************************************************/

GLOBAL LONG ListBoxFindStringExact (OBJECT *tree, WORD obj, LONG index_start, BYTE *find)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  return (ListBox_FindStringExact (lb, index_start, find));
} /* ListBoxFindStringExact */

/*****************************************************************************/

GLOBAL VOID ListBoxSetSel (OBJECT *tree, WORD obj, BOOLEAN select, LONG index)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  ListBox_SetSel (lb, select, index);
} /* ListBoxSetSel */

/*****************************************************************************/

GLOBAL VOID ListBoxSelItemRange (OBJECT *tree, WORD obj, BOOLEAN select, LONG first, LONG last)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  ListBox_SelItemRange (lb, select, first, last);
} /* ListBoxSelItemRange */

/*****************************************************************************/

GLOBAL LONG ListBoxGetCurSel (OBJECT *tree, WORD obj)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  return (ListBox_GetCurSel (lb));
} /* ListBoxGetCurSel */

/*****************************************************************************/

GLOBAL VOID ListBoxSetCurSel (OBJECT *tree, WORD obj, LONG index)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  ListBox_SetCurSel (lb, index);
} /* ListBoxSetCurSel */

/*****************************************************************************/

GLOBAL VOID ListBoxSelectString (OBJECT *tree, WORD obj, LONG index_start, BYTE *find)
{
  ListBoxSetCurSel (tree, obj, ListBoxFindString (tree, obj, index_start, find));
} /* ListBoxSelectString */

/*****************************************************************************/

GLOBAL BOOLEAN ListBoxGetSel (OBJECT *tree, WORD obj, LONG index)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  return (ListBox_GetSel (lb, index));
} /* ListBoxGetSel */

/*****************************************************************************/

GLOBAL LONG ListBoxGetSelCount (OBJECT *tree, WORD obj)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  return (ListBox_GetSelCount (lb));
} /* ListBoxGetSelCount */

/*****************************************************************************/

GLOBAL VOID ListBoxGetSelItems (OBJECT *tree, WORD obj, SET set)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  ListBox_GetSelItems (lb, set);
} /* ListBoxGetSelItems */

/*****************************************************************************/

GLOBAL WORD ListBoxGetTabstops (OBJECT *tree, WORD obj, WORD *tabs, WORD *tab_styles)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  return (ListBox_GetTabstops (lb, tabs, tab_styles));
} /* ListBoxGetTabstops */

/*****************************************************************************/

GLOBAL BOOLEAN ListBoxSetTabstops (OBJECT *tree, WORD obj, WORD num_tabs, WORD *tabs, WORD *tab_styles)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  return (ListBox_SetTabstops (lb, num_tabs, tabs, tab_styles));
} /* ListBoxSetTabstops */

/*****************************************************************************/

GLOBAL LONG ListBoxGetTopIndex (OBJECT *tree, WORD obj)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  return (ListBox_GetTopIndex (lb));
} /* ListBoxGetTopIndex */

/*****************************************************************************/

GLOBAL VOID ListBoxSetTopIndex (OBJECT *tree, WORD obj, LONG index)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  ListBox_SetTopIndex (lb, index);
} /* ListBoxSetTopIndex */

/*****************************************************************************/

GLOBAL WORD ListBoxGetItemHeight (OBJECT *tree, WORD obj)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  return (ListBox_GetItemHeight (lb));
} /* ListBoxGetItemHeight */

/*****************************************************************************/

GLOBAL VOID ListBoxSetItemHeight (OBJECT *tree, WORD obj, WORD height)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  ListBox_SetItemHeight (lb, height);
} /* ListBoxSetItemHeight */

/*****************************************************************************/

GLOBAL WORD ListBoxGetLeftOffset (OBJECT *tree, WORD obj)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  return (ListBox_GetLeftOffset (lb));
} /*  ListBoxGetLeftOffset */

/*****************************************************************************/

GLOBAL VOID ListBoxSetLeftOffset (OBJECT *tree, WORD obj, WORD offset)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  ListBox_SetLeftOffset (lb, offset);
} /* ListBoxSetLeftOffset */

/*****************************************************************************/

GLOBAL LONG ListBoxGetSpec (OBJECT *tree, WORD obj)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  return (ListBox_GetSpec (lb));
} /* ListBoxGetSpec */

/*****************************************************************************/

GLOBAL VOID ListBoxSetSpec (OBJECT *tree, WORD obj, LONG spec)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  ListBox_SetSpec (lb, spec);
} /* ListBoxSetSpec */

/*****************************************************************************/

GLOBAL VOID ListBoxGetComboRect (OBJECT *tree, WORD obj, RECT *rc, WORD *y)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  ListBox_GetComboRect (lb, rc, y);
} /* ListBoxGetComboRect */

/*****************************************************************************/

GLOBAL VOID ListBoxSetComboRect (OBJECT *tree, WORD obj, RECT *rc, WORD y)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);
  WORD    rx, ry;

  if (rc == NULL)
  {
    objc_offset (tree, obj, &rx, &ry);
    lb->rc_obj.x    = rx;
    lb->rc_obj.y    = ry + OB_HEIGHT (tree, obj) - 3;
    lb->rc_obj.w    = OB_WIDTH (tree, obj) - 4;
    lb->rc_obj.h    = y * lb->item_height;
    lb->y_alternate = ry + 1;
  } /* if */
  else
  {
    lb->rc_obj      = *rc;
    lb->y_alternate = y;
  } /* else */
} /* ListBoxSetComboRect */

/*****************************************************************************/

GLOBAL LONG ListBoxComboClick (OBJECT *tree, WORD obj, MKINFO *mk)
{
  LISTBOX *lb = lb_from_obj (tree, obj, FALSE);

  return (ListBox_ComboClick (lb, mk));
} /* ListBoxComboClick */

/*****************************************************************************/

GLOBAL HLB ListBox_Create (UWORD style, RECT *rc, LONG count)
{
  LISTBOX *lb;

  lb = mem_alloc (sizeof (LISTBOX));

  if (lb != NULL)
  {
    mem_set (lb, 0, sizeof (LISTBOX));

    lb->wh           = FAILURE;
    lb->tree         = (OBJECT *)lb;		/* so caller can get "this" pointer in callback */
    lb->obj          = NIL;
    lb->style        = style;
    lb->item_height  = gl_hbox;
    lb->left_offset  = gl_wbox;
    lb->font         = FAILURE;
    lb->point        = FAILURE;
    lb->effects      = (UWORD)FAILURE;
    lb->color        = FAILURE;
    lb->bk_color     = FAILURE;
    lb->sel_item     = FAILURE;
    lb->vsb_size     = gl_wattr;

    lb->vsb.callback = sb_callback;
    lb->vsb.wh       = FAILURE;
    lb->vsb.tree     = (OBJECT *)lb;		/* so I can get my listbox at callback time */
    lb->vsb.obj      = NIL;
    lb->vsb.style    = SBS_VERTICAL | SBS_NO3DBORDER | ((style & LBS_VREALTIME) ? SBS_REALTIME : 0);
    lb->vsb.bk_color = FAILURE;
    lb->vsb.count    = count;
    lb->vsb.pagesize = 1;
    lb->vsb.pos      = 0;

    if (rc != NULL)
    {
      lb->rc_obj        = *rc;
      lb->vsb.pagesize  = (lb->rc_obj.h - 4) / lb->item_height;
      lb->vsb.rc_obj    = lb->rc_obj;
      lb->vsb.rc_obj.x += lb->rc_obj.w - (lb->vsb_size + 2);
      lb->vsb.rc_obj.w  = lb->vsb_size + 2; 
    } /* if */

    lb->vsb_vis = (lb->style & LBS_VSCROLL) || (lb->vsb.count > lb->vsb.pagesize);
  } /* if */

  return (lb);
} /* ListBox_Create */

/*****************************************************************************/

GLOBAL VOID ListBox_Delete (HLB hlb)
{
  mem_free (hlb);
} /* ListBox_Delete */

/*****************************************************************************/

GLOBAL VOID ListBox_Redraw (HLB hlb)
{
  LISTBOX *lb = hlb;

  lb_redraw (lb, &lb->rc_obj);
} /* ListBox_Redraw */

/*****************************************************************************/

GLOBAL VOID ListBox_Draw (HLB hlb, RECT *rc_clip)
{
  LISTBOX *lb = hlb;

  DrawListBox (vdi_handle, &lb->rc_obj, rc_clip, lb);
} /* ListBox_Redraw */

/*****************************************************************************/

GLOBAL LONG ListBox_Click (HLB hlb, MKINFO *mk)
{
  LISTBOX *lb = hlb;

  return (lb_click (lb, mk));
} /* ListBox_Click */

/*****************************************************************************/

GLOBAL VOID ListBox_Key (HLB hlb, MKINFO *mk)
{
  LISTBOX *lb = hlb;

  lb_key (lb, mk);
} /* ListBox_Key */

/*****************************************************************************/

GLOBAL LONG ListBox_SendMessage (HLB hlb, WORD msg, LONG item, VOID *p)
{
  LISTBOX *lb = hlb;

  return ((lb->callback != NULL) ? lb->callback (lb->wh, lb->tree, lb->obj, msg, item, p) : 0L);
} /* ListBox_SendMessage */

/*****************************************************************************/

GLOBAL VOID ListBox_GetRect (HLB hlb, RECT *rc)
{
  LISTBOX *lb = hlb;

  *rc = lb->rc_obj;
} /* ListBox_GetRect */

/*****************************************************************************/

GLOBAL VOID ListBox_SetRect (HLB hlb, CONST RECT *rc, BOOLEAN redraw)
{
  LISTBOX *lb = hlb;

  lb->rc_obj        = *rc;
  lb->vsb.pagesize  = (lb->rc_obj.h - 4) / lb->item_height;
  lb->vsb.rc_obj    = lb->rc_obj;
  lb->vsb.rc_obj.x += lb->rc_obj.w - (lb->vsb_size + 2);
  lb->vsb.rc_obj.w  = lb->vsb_size + 2; 
  lb->vsb_vis       = (lb->style & LBS_VSCROLL) || (lb->vsb.count > lb->vsb.pagesize);

  if (redraw)
    lb_redraw (lb, &lb->rc_obj);
} /* ListBox_SetRect */

/*****************************************************************************/

GLOBAL LB_CALLBACK ListBox_GetCallback (HLB hlb)
{
  LISTBOX *lb = hlb;

  return (lb->callback);
} /* ListBox_GetCallback */

/*****************************************************************************/

GLOBAL VOID ListBox_SetCallback (HLB hlb, LB_CALLBACK callback)
{
  LISTBOX *lb = hlb;

  lb->callback = callback;
} /* ListBox_SetCallback */

/*****************************************************************************/

GLOBAL WORD ListBox_GetWindowHandle (HLB hlb)
{
  LISTBOX *lb = hlb;

  return (lb->wh);
} /* ListBox_GetWindowHandle */

/*****************************************************************************/

GLOBAL VOID ListBox_SetWindowHandle (HLB hlb, WORD wh)
{
  LISTBOX *lb = hlb;

  lb->wh = lb->vsb.wh = wh;
} /* ListBox_SetWindowHandle */

/*****************************************************************************/

GLOBAL VOID ListBox_GetFont (HLB hlb, WORD *font, WORD *point, UWORD *effects, WORD *color, WORD *bk_color)
{
  LISTBOX *lb = hlb;

  if (font     != NULL) *font     = lb->font;
  if (point    != NULL) *point    = lb->point;
  if (effects  != NULL) *effects  = lb->effects;
  if (color    != NULL) *color    = lb->color;
  if (bk_color != NULL) *bk_color = lb->bk_color;
} /* ListBox_GetFont */

/*****************************************************************************/

GLOBAL VOID ListBox_SetFont (HLB hlb, WORD font, WORD point, UWORD effects, WORD color, WORD bk_color)
{
  LISTBOX *lb = hlb;

  lb->font     = font;
  lb->point    = point;
  lb->effects  = effects;
  lb->color    = color;
  lb->bk_color = bk_color;
} /* ListBox_SetFont */

/*****************************************************************************/

GLOBAL VOID ListBox_SetFocus (HLB hlb)
{
  LISTBOX *lb = hlb;

  lb->has_focus = TRUE;

  ListBox_Redraw (lb);

  if (lb->callback != NULL)
    lb->callback (lb->wh, lb->tree, lb->obj, LBN_SETFOCUS, lb->sel_item, NULL);
} /* ListBox_SetFocus */

/*****************************************************************************/

GLOBAL VOID ListBox_KillFocus (HLB hlb)
{
  LISTBOX *lb = hlb;

  lb->has_focus = FALSE;

  ListBox_Redraw (lb);

  if (lb->callback != NULL)
    lb->callback (lb->wh, lb->tree, lb->obj, LBN_KILLFOCUS, lb->sel_item, NULL);
} /* ListBox_KillFocus */

/*****************************************************************************/

GLOBAL UWORD ListBox_GetStyle (HLB hlb)
{
  LISTBOX *lb = hlb;

  return (lb->style);
} /* ListBox_GetStyle */

/*****************************************************************************/

GLOBAL VOID ListBox_SetStyle (HLB hlb, UWORD style, BOOLEAN on)
{
  LISTBOX *lb = hlb;

  if (on)
    lb->style |= style;
  else
    lb->style &= ~ style;

  if (style & LBS_VREALTIME)
    ScrollBar_SetStyle (&lb->vsb, SBS_REALTIME, on);

  lb->vsb.pagesize = (lb->rc_obj.h - 4) / lb->item_height;
  lb->vsb_vis      = (lb->style & LBS_VSCROLL) || (lb->vsb.count > lb->vsb.pagesize);
} /* ListBox_SetStyle */

/*****************************************************************************/

GLOBAL LONG ListBox_GetCount (HLB hlb)
{
  LISTBOX *lb = hlb;

  return (lb->vsb.count);
} /* ListBox_GetCount */

/*****************************************************************************/

GLOBAL VOID ListBox_SetCount (HLB hlb, LONG count, BYTE **strings)
{
  LISTBOX *lb = hlb;

  lb->vsb.count    = count;
  lb->items        = strings;
  lb->vsb.pagesize = (lb->rc_obj.h - 4) / lb->item_height;
  lb->vsb_vis      = (lb->style & LBS_VSCROLL) || (lb->vsb.count > lb->vsb.pagesize);
  lb->vsb.pos      = min (lb->vsb.pos, lb->vsb.count - lb->vsb.pagesize);
  lb->vsb.pos      = max (lb->vsb.pos, 0);
  lb->vsb_oldpos   = lb->vsb.pos;
} /* ListBox_SetCount */

/*****************************************************************************/

GLOBAL WORD ListBox_GetTextLen (HLB hlb, LONG index)
{
  LISTBOX *lb = hlb;
  BYTE    *p;

  if (index == FAILURE)
    p = NULL;
  else
    if (lb->items != NULL)
      p = lb->items [index];
    else
      if (lb->callback != NULL)
        p = (BYTE *)lb->callback (lb->wh, lb->tree, lb->obj, LBN_GETITEM, index, NULL);
      else
        p = NULL;

  return (p == NULL ? 0 : strlen (p));
} /* ListBox_GetTextLen */

/*****************************************************************************/

GLOBAL WORD ListBox_GetText (HLB hlb, LONG index, BYTE *string)
{
  LISTBOX *lb = hlb;
  BYTE    *p;

  if (index == FAILURE)
    p = NULL;
  else
    if (lb->items != NULL)
      p = lb->items [index];
    else
      if (lb->callback != NULL)
        p = (BYTE *)lb->callback (lb->wh, lb->tree, lb->obj, LBN_GETITEM, index, NULL);
      else
        p = NULL;

  if (p == NULL)
    string [0] = EOS;
  else
    strcpy (string, p);

  return (p == NULL ? 0 : strlen (p));
} /* ListBox_GetText */

/*****************************************************************************/

GLOBAL LONG ListBox_FindString (HLB hlb, LONG index_start, BYTE *find)
{
  LISTBOX *lb = hlb;
  LONG    i, index;
  BYTE    *p;

  for (i = 0; i < lb->vsb.count; i++)
  {
    index = (index_start + i) % lb->vsb.count;

    if (lb->items != NULL)
      p = lb->items [index];
    else
      if (lb->callback != NULL)
        p = (BYTE *)lb->callback (lb->wh, lb->tree, lb->obj, LBN_GETITEM, index, NULL);
      else
        p = NULL;

    if (p == NULL)
      break;
    else
      if (strnicmp (find, p, strlen (find)) == 0)
        return (index);
  } /* for */

  return (FAILURE);
} /* ListBox_FindString */

/*****************************************************************************/

GLOBAL LONG ListBox_FindStringExact (HLB hlb, LONG index_start, BYTE *find)
{
  LISTBOX *lb = hlb;
  LONG    i, index;
  BYTE    *p;

  for (i = 0; i < lb->vsb.count; i++)
  {
    index = (index_start + i) % lb->vsb.count;

    if (lb->items != NULL)
      p = lb->items [index];
    else
      if (lb->callback != NULL)
        p = (BYTE *)lb->callback (lb->wh, lb->tree, lb->obj, LBN_GETITEM, index, NULL);
      else
        p = NULL;

    if (p == NULL)
      break;
    else
      if (stricmp (find, p) == 0)
        return (index);
  } /* for */

  return (FAILURE);
} /* ListBox_FindStringExact */

/*****************************************************************************/

GLOBAL VOID ListBox_SetSel (HLB hlb, BOOLEAN select, LONG index)
{
  LISTBOX *lb = hlb;

  if ((0 <= index) && (index <= SETMAX))
    if (select)
      setincl (lb->sel_set, (WORD)index);
    else
      setexcl (lb->sel_set, (WORD)index);
} /* ListBox_SetSel */

/*****************************************************************************/

GLOBAL VOID ListBox_SelItemRange (HLB hlb, BOOLEAN select, LONG first, LONG last)
{
  LISTBOX *lb = hlb;

  while (last < first)
  {
    if ((0 <= first) && (first <= SETMAX))
      if (select)
        setincl (lb->sel_set, (WORD)first);
      else
        setexcl (lb->sel_set, (WORD)first);

    first++;
  } /* while */
} /* ListBox_SelItemRange */

/*****************************************************************************/

GLOBAL LONG ListBox_GetCurSel (HLB hlb)
{
  LISTBOX *lb = hlb;

  return (lb->sel_item);
} /* ListBox_GetCurSel */

/*****************************************************************************/

GLOBAL VOID ListBox_SetCurSel (HLB hlb, LONG index)
{
  LISTBOX *lb = hlb;

  index = min (index, lb->vsb.count - 1);
  index = max (index, FAILURE);

  if (lb->style & LBS_MULTIPLESEL)
    setincl (lb->sel_set, index);
  else
    lb->sel_item = index;
} /* ListBox_SetCurSel */

/*****************************************************************************/

GLOBAL VOID ListBox_SelectString (HLB hlb, LONG index_start, BYTE *find)
{
  LISTBOX *lb = hlb;

  ListBox_SetCurSel (lb, ListBox_FindString (lb, index_start, find));
} /* ListBox_SelectString */

/*****************************************************************************/

GLOBAL BOOLEAN ListBox_GetSel (HLB hlb, LONG index)
{
  LISTBOX *lb = hlb;

  if ((0 <= index) && (index <= SETMAX))
    return (setin (lb->sel_set, (WORD)index));
  else
    return (FALSE);
} /* ListBox_GetSel */

/*****************************************************************************/

GLOBAL LONG ListBox_GetSelCount (HLB hlb)
{
  LISTBOX *lb = hlb;

  return (setcard (lb->sel_set));
} /* ListBox_GetSelCount */

/*****************************************************************************/

GLOBAL VOID ListBox_GetSelItems (HLB hlb, SET set)
{
  LISTBOX *lb = hlb;

  setcpy (set, lb->sel_set);
} /* ListBox_GetSelItems */

/*****************************************************************************/

GLOBAL WORD ListBox_GetTabstops (HLB hlb, WORD *tabs, WORD *tab_styles)
{
  LISTBOX *lb = hlb;

  if (tabs != NULL) mem_move (tabs, lb->tabs, lb->num_tabs * sizeof (WORD));
  if (tab_styles != NULL) mem_move (tab_styles, lb->tabstyles, lb->num_tabs * sizeof (WORD));

  return (lb->num_tabs);
} /* ListBox_GetTabstops */

/*****************************************************************************/

GLOBAL BOOLEAN ListBox_SetTabstops (HLB hlb, WORD num_tabs, WORD *tabs, WORD *tab_styles)
{
  LISTBOX *lb = hlb;

  if (tabs != NULL) mem_move (lb->tabs, tabs, min (num_tabs, LBT_MAX_TABS) * sizeof (WORD));
  if (tab_styles != NULL) mem_move (lb->tabstyles, tab_styles, min (num_tabs, LBT_MAX_TABS) * sizeof (WORD));

  lb->num_tabs = min (num_tabs, LBT_MAX_TABS);

  return (num_tabs <= LBT_MAX_TABS);
} /* ListBox_SetTabstops */

/*****************************************************************************/

GLOBAL LONG ListBox_GetTopIndex (HLB hlb)
{
  LISTBOX *lb = hlb;

  return (lb->vsb.pos);
} /* ListBox_GetTopIndex */

/*****************************************************************************/

GLOBAL VOID ListBox_SetTopIndex (HLB hlb, LONG index)
{
  LISTBOX *lb = hlb;

  lb->vsb.pagesize = (lb->rc_obj.h - 4) / lb->item_height;
  index            = min (index, lb->vsb.count - lb->vsb.pagesize);
  index            = max (index, 0);
  lb->vsb.pos      = lb->vsb_oldpos = index;
} /* ListBox_SetTopIndex */

/*****************************************************************************/

GLOBAL WORD ListBox_GetItemHeight (HLB hlb)
{
  LISTBOX *lb = hlb;

  return (lb->item_height);
} /* ListBox_GetItemHeight */

/*****************************************************************************/

GLOBAL VOID ListBox_SetItemHeight (HLB hlb, WORD height)
{
  LISTBOX *lb = hlb;

  lb->item_height  = height;
  lb->vsb.pagesize = (lb->rc_obj.h - 4) / lb->item_height;
} /* ListBox_SetItemHeight */

/*****************************************************************************/

GLOBAL WORD ListBox_GetLeftOffset (HLB hlb)
{
  LISTBOX *lb = hlb;

  return (lb->left_offset);
} /* ListBox_GetLeftOffset */

/*****************************************************************************/

GLOBAL VOID ListBox_SetLeftOffset (HLB hlb, WORD offset)
{
  LISTBOX *lb = hlb;

  lb->left_offset = offset;
} /* ListBox_SetLeftOffset */

/*****************************************************************************/

GLOBAL LONG ListBox_GetSpec (HLB hlb)
{
  LISTBOX *lb = hlb;

  return (lb->spec);
} /* ListBox_GetSpec */

/*****************************************************************************/

GLOBAL VOID ListBox_SetSpec (HLB hlb, LONG spec)
{
  LISTBOX *lb = hlb;

  lb->spec = spec;
} /* ListBox_SetSpec */

/*****************************************************************************/

GLOBAL VOID ListBox_GetComboRect (HLB hlb, RECT *rc, WORD *y)
{
  LISTBOX *lb = hlb;

  *rc = lb->rc_obj;
  *y  = lb->y_alternate;
} /* ListBox_GetComboRect */

/*****************************************************************************/

GLOBAL VOID ListBox_SetComboRect (HLB hlb, RECT *rc, WORD y)
{
  LISTBOX *lb = hlb;

  if (rc != NULL)
    lb->rc_obj = *rc;

  lb->y_alternate = y;
} /* ListBox_SetComboRect */

/*****************************************************************************/

GLOBAL LONG ListBox_ComboClick (HLB hlb, MKINFO *mk)
{
  LISTBOX *lb = hlb;

  return (lb_comboclick (lb, mk));
} /* ListBox_ComboClick */

/*****************************************************************************/

GLOBAL VOID ScrollBarRedraw (OBJECT *tree, WORD obj)
{
  SCROLLBAR *sb = sb_from_obj (tree, obj, TRUE);

  ScrollBar_Redraw (sb);
} /* ScrollBarRedraw */

/*****************************************************************************/

GLOBAL LONG ScrollBarClick (OBJECT *tree, WORD obj, MKINFO *mk)
{
  SCROLLBAR *sb = sb_from_obj (tree, obj, TRUE);

  return (ScrollBar_Click (sb, mk));
} /* ScrollBarClick */

/*****************************************************************************/

GLOBAL VOID ScrollBarKey (OBJECT *tree, WORD obj, MKINFO *mk)
{
  SCROLLBAR *sb = sb_from_obj (tree, obj, TRUE);

  ScrollBar_Key (sb, mk);
} /* ScrollBarKey */

/*****************************************************************************/

GLOBAL LONG ScrollBarSendMessage (OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p)
{
  SCROLLBAR *sb = sb_from_obj (tree, obj, FALSE);

  return (ScrollBar_SendMessage (sb, msg, item, p));
} /* ScrollBarSendMessage */

/*****************************************************************************/

GLOBAL SB_CALLBACK ScrollBarGetCallback (OBJECT *tree, WORD obj)
{
  SCROLLBAR *sb = sb_from_obj (tree, obj, FALSE);

  return (ScrollBar_GetCallback (sb));
} /* ScrollBarGetCallback */

/*****************************************************************************/

GLOBAL VOID ScrollBarSetCallback (OBJECT *tree, WORD obj, SB_CALLBACK callback)
{
  SCROLLBAR *sb = sb_from_obj (tree, obj, FALSE);

  ScrollBar_SetCallback (sb, callback);
} /* ScrollBarSetCallback */

/*****************************************************************************/

GLOBAL WORD ScrollBarGetWindowHandle (OBJECT *tree, WORD obj)
{
  SCROLLBAR *sb = sb_from_obj (tree, obj, FALSE);

  return (ScrollBar_GetWindowHandle (sb));
} /* ScrollBarGetWindowHandle */

/*****************************************************************************/

GLOBAL VOID ScrollBarSetWindowHandle (OBJECT *tree, WORD obj, WORD wh)
{
  SCROLLBAR *sb = sb_from_obj (tree, obj, FALSE);

  ScrollBar_SetWindowHandle (sb, wh);
} /* ScrollBarSetWindowHandle */

/*****************************************************************************/

GLOBAL WORD ScrollBarGetBkColor (OBJECT *tree, WORD obj)
{
  SCROLLBAR *sb = sb_from_obj (tree, obj, FALSE);

  return (ScrollBar_GetBkColor (sb));
} /* ScrollBarGetBkColor */

/*****************************************************************************/

GLOBAL VOID ScrollBarSetBkColor (OBJECT *tree, WORD obj, WORD bk_color)
{
  SCROLLBAR *sb = sb_from_obj (tree, obj, FALSE);

  ScrollBar_SetBkColor (sb, bk_color);
} /* ScrollBarSetBkColor */

/*****************************************************************************/

GLOBAL UWORD ScrollBarGetStyle (OBJECT *tree, WORD obj)
{
  SCROLLBAR *sb = sb_from_obj (tree, obj, FALSE);

  return (ScrollBar_GetStyle (sb));
} /* ScrollBarGetStyle */

/*****************************************************************************/

GLOBAL VOID ScrollBarSetStyle (OBJECT *tree, WORD obj, UWORD style, BOOLEAN on)
{
  SCROLLBAR *sb = sb_from_obj (tree, obj, FALSE);

  if (on)
  {
    if (style & SBS_DISABLED)
      do_state (tree, obj, DISABLED);
  } /* if */
  else
  {
    if (style & SBS_DISABLED)
      undo_state (tree, obj, DISABLED);
  } /* else */

  ScrollBar_SetStyle (sb, style, on);
} /* ScrollBarSetStyle */

/*****************************************************************************/

GLOBAL LONG ScrollBarGetCount (OBJECT *tree, WORD obj)
{
  SCROLLBAR *sb = sb_from_obj (tree, obj, FALSE);

  return (ScrollBar_GetCount (sb));
} /* ScrollBarGetCount */

/*****************************************************************************/

GLOBAL VOID ScrollBarSetCount (OBJECT *tree, WORD obj, LONG count, BOOLEAN redraw)
{
  SCROLLBAR *sb = sb_from_obj (tree, obj, TRUE);

  ScrollBar_SetCount (sb, count, redraw);
} /* ScrollBarSetCount */

/*****************************************************************************/

GLOBAL LONG ScrollBarGetPageSize (OBJECT *tree, WORD obj)
{
  SCROLLBAR *sb = sb_from_obj (tree, obj, FALSE);

  return (ScrollBar_GetPageSize (sb));
} /* ScrollBarGetPageSize */

/*****************************************************************************/

GLOBAL VOID ScrollBarSetPageSize (OBJECT *tree, WORD obj, LONG pagesize, BOOLEAN redraw)
{
  SCROLLBAR *sb = sb_from_obj (tree, obj, TRUE);

  ScrollBar_SetPageSize (sb, pagesize, redraw);
} /* ScrollBarSetPageSize */

/*****************************************************************************/

GLOBAL LONG ScrollBarGetPos (OBJECT *tree, WORD obj)
{
  SCROLLBAR *sb = sb_from_obj (tree, obj, FALSE);

  return (ScrollBar_GetPos (sb));
} /* ScrollBarGetPos */

/*****************************************************************************/

GLOBAL VOID ScrollBarSetPos (OBJECT *tree, WORD obj, LONG pos, BOOLEAN redraw)
{
  SCROLLBAR *sb = sb_from_obj (tree, obj, TRUE);

  ScrollBar_SetPos (sb, pos, redraw);
} /* ScrollBarSetPos */

/*****************************************************************************/

GLOBAL LONG ScrollBarGetSpec (OBJECT *tree, WORD obj)
{
  SCROLLBAR *sb = sb_from_obj (tree, obj, FALSE);

  return (ScrollBar_GetSpec (sb));
} /* ScrollBarGetSpec */

/*****************************************************************************/

GLOBAL VOID ScrollBarSetSpec (OBJECT *tree, WORD obj, LONG spec)
{
  SCROLLBAR *sb = sb_from_obj (tree, obj, FALSE);

  ScrollBar_SetSpec (sb, spec);
} /* ScrollBarSetSpec */

/*****************************************************************************/

GLOBAL HSB ScrollBar_Create (UWORD style, RECT *rc, LONG count, LONG pagesize)
{
  SCROLLBAR *sb;

  sb = mem_alloc (sizeof (SCROLLBAR));

  if (sb != NULL)
  {
    mem_set (sb, 0, sizeof (SCROLLBAR));

    sb->wh       = FAILURE;
    sb->tree     = (OBJECT *)sb;		/* so caller can get "this" pointer in callback */
    sb->obj      = NIL;
    sb->style    = style;
    sb->bk_color = FAILURE;
    sb->count    = count;
    sb->pagesize = pagesize;
    sb->pos      = 0;

    if (rc != NULL)
      sb->rc_obj = *rc;
  } /* if */

  return (sb);
} /* ScrollBar_Create */

/*****************************************************************************/

GLOBAL VOID ScrollBar_Delete (HSB hsb)
{
  mem_free (hsb);
} /* ScrollBar_Delete */

/*****************************************************************************/

GLOBAL VOID ScrollBar_Redraw (HSB hsb)
{
  SCROLLBAR *sb = hsb;

  sb_redraw (sb, &sb->rc_obj);
} /* ScrollBar_Redraw */

/*****************************************************************************/

GLOBAL LONG ScrollBar_Click (HSB hsb, MKINFO *mk)
{
  SCROLLBAR *sb = hsb;

  return (sb_click (sb, mk));
} /* ScrollBar_Click */

/*****************************************************************************/

GLOBAL VOID ScrollBar_Key (HSB hsb, MKINFO *mk)
{
  SCROLLBAR *sb = hsb;

  sb_key (sb, mk);
} /* ScrollBar_Key */

/*****************************************************************************/

GLOBAL LONG ScrollBar_SendMessage (HSB hsb, WORD msg, LONG item, VOID *p)
{
  SCROLLBAR *sb = hsb;

  return ((sb->callback != NULL) ? sb->callback (sb->wh, sb->tree, sb->obj, msg, item, p) : 0L);
} /* ScrollBar_SendMessage */

/*****************************************************************************/

GLOBAL VOID ScrollBar_GetRect (HSB hsb, RECT *rc)
{
  SCROLLBAR *sb = hsb;

  *rc = sb->rc_obj;
} /* ScrollBar_GetRect */

/*****************************************************************************/

GLOBAL VOID ScrollBar_SetRect (HSB hsb, CONST RECT *rc, BOOLEAN redraw)
{
  SCROLLBAR *sb = hsb;
  RECT      rc_obj;

  sb->rc_obj = *rc;

  if (redraw)
  {
    sb_calc_rect (sb, SBC_SLIDERAREA, &rc_obj, NULL, 0, 0);
    sb_redraw (sb, &rc_obj);
  } /* if */
} /* ScrollBar_SetRect */

/*****************************************************************************/

GLOBAL SB_CALLBACK ScrollBar_GetCallback (HSB hsb)
{
  SCROLLBAR *sb = hsb;

  return (sb->callback);
} /* ScrollBar_GetCallback */

/*****************************************************************************/

GLOBAL VOID ScrollBar_SetCallback (HSB hsb, SB_CALLBACK callback)
{
  SCROLLBAR *sb = hsb;

  sb->callback = callback;
} /* ScrollBar_SetCallback */

/*****************************************************************************/

GLOBAL WORD ScrollBar_GetWindowHandle (HSB hsb)
{
  SCROLLBAR *sb = hsb;

  return (sb->wh);
} /* ScrollBar_GetWindowHandle */

/*****************************************************************************/

GLOBAL VOID ScrollBar_SetWindowHandle (HSB hsb, WORD wh)
{
  SCROLLBAR *sb = hsb;

  sb->wh  = wh;
} /* ScrollBar_SetWindowHandle */

/*****************************************************************************/

GLOBAL WORD ScrollBar_GetBkColor (HSB hsb)
{
  SCROLLBAR *sb = hsb;

  return (sb->bk_color);
} /* ScrollBar_GetBkColor */

/*****************************************************************************/

GLOBAL VOID ScrollBar_SetBkColor (HSB hsb, WORD bk_color)
{
  SCROLLBAR *sb = hsb;

  sb->bk_color = bk_color;
} /* ScrollBar_SetBkColor */

/*****************************************************************************/

GLOBAL UWORD ScrollBar_GetStyle (HSB hsb)
{
  SCROLLBAR *sb = hsb;

  return (sb->style);
} /* ScrollBar_GetStyle */

/*****************************************************************************/

GLOBAL VOID ScrollBar_SetStyle (HSB hsb, UWORD style, BOOLEAN on)
{
  SCROLLBAR *sb = hsb;

  if (on)
    sb->style |= style;
  else
    sb->style &= ~ style;
} /* ScrollBar_SetStyle */

/*****************************************************************************/

GLOBAL LONG ScrollBar_GetCount (HSB hsb)
{
  SCROLLBAR *sb = hsb;

  return (sb->count);
} /* ScrollBar_GetCount */

/*****************************************************************************/

GLOBAL VOID ScrollBar_SetCount (HSB hsb, LONG count, BOOLEAN redraw)
{
  SCROLLBAR *sb = hsb;
  RECT      rc_obj;

  sb->count = count;

  if (redraw)
  {
    sb_calc_rect (sb, SBC_PARENT, &rc_obj, NULL, 0, 0);
    sb_redraw (sb, &rc_obj);
  } /* if */
} /* ScrollBar_SetCount */

/*****************************************************************************/

GLOBAL LONG ScrollBar_GetPageSize (HSB hsb)
{
  SCROLLBAR *sb = hsb;

  return (sb->pagesize);
} /* ScrollBar_GetPageSize */

/*****************************************************************************/

GLOBAL VOID ScrollBar_SetPageSize (HSB hsb, LONG pagesize, BOOLEAN redraw)
{
  SCROLLBAR *sb = hsb;
  RECT      rc_obj;

  sb->pagesize = pagesize;

  if (redraw)
  {
    sb_calc_rect (sb, SBC_PARENT, &rc_obj, NULL, 0, 0);
    sb_redraw (sb, &rc_obj);
  } /* if */
} /* ScrollBar_SetPageSize */

/*****************************************************************************/

GLOBAL LONG ScrollBar_GetPos (HSB hsb)
{
  SCROLLBAR *sb = hsb;

  return (sb->pos);
} /* ScrollBar_GetPos */

/*****************************************************************************/

GLOBAL VOID ScrollBar_SetPos (HSB hsb, LONG pos, BOOLEAN redraw)
{
  SCROLLBAR *sb = hsb;
  RECT      rc_obj;

  sb->pos = pos;

  if (redraw)
  {
    sb_calc_rect (sb, SBC_PARENT, &rc_obj, NULL, 0, 0);
    sb_redraw (sb, &rc_obj);
  } /* if */
} /* ScrollBar_SetPos */

/*****************************************************************************/

GLOBAL LONG ScrollBar_GetSpec (HSB hsb)
{
  SCROLLBAR *sb = hsb;

  return (sb->spec);
} /* ScrollBar_GetSpec */

/*****************************************************************************/

GLOBAL VOID ScrollBar_SetSpec (HSB hsb, LONG spec)
{
  SCROLLBAR *sb = hsb;

  sb->spec = spec;
} /* ScrollBar_SetSpec */

/*****************************************************************************/

LOCAL VOID get_obinfo (LONG obspec, OBINFO *obinfo)
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

LOCAL VOID flip_word (HPUCHAR adr)
{
  REG UBYTE c;

  c       = adr [0];
  adr [0] = adr [1];
  adr [1] = c;
} /* flip_word */

/*****************************************************************************/

LOCAL VOID conv_img (IMG_HEADER *img_header, HPUCHAR img_buffer, HPUCHAR raster_buffer, HPUCHAR trans_buffer, HPUCHAR *plane_ptr, WORD max_lines, WORD raster_planes, WORD fww)
{
  HPUCHAR img_ptr;
  HPUCHAR line_ptr;
  HPUCHAR raster_ptr;
  HPUCHAR plane_ptr_save [MAX_PLANES];
  UBYTE   line_buf [MAX_LINEBUF];
  WORD    l_buflen;
  WORD    vrc;                           /* vertical replication count */
  WORD    bytecols;                      /* counter for planedata */
  UBYTE   data;                          /* one byte of pixel data */
  UBYTE   pattern [MAX_PATTERNS];
  WORD    max_pattern;
  UWORD   length;
  WORD    idx, count;
  WORD    i, line;
  WORD    plane;
  WORD    fwb;
  MFDB    s, d;
  LONG    raster_len;

#if GEMDOS
  EXTERN BOOLEAN adapt (WORD bm_width, WORD bm_height, WORD bm_planes, UBYTE **bm_adr, WORD *bm_colors, UBYTE *trans_buffer);
#endif

  d.mp  = (VOID *)trans_buffer;
  s.mp  = (VOID *)raster_buffer;
  s.fwp = d.fwp = fww * 16;
  s.fh  = d.fh  = max_lines;
  s.fww = d.fww = fww;
  s.np  = d.np  = raster_planes;

#if MSDOS
  s.ff = FALSE;
  d.ff = TRUE;
#else
  s.ff = TRUE;
  d.ff = FALSE;
#endif

  fwb      = fww * 2;
  l_buflen = (img_header->sl_width + 7) / 8;
  if (l_buflen > MAX_LINEBUF) return;

  mem_move (plane_ptr_save, plane_ptr, sizeof (plane_ptr_save));

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
                        for (i = 0; i < max_pattern; i++)  pattern [i] = img_ptr [i];
                        img_ptr += img_header->pat_run;

                        while (data > 0)
                        {
                          for (i = 0; i < max_pattern; i++) *line_ptr++ = pattern [i];
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

      idx        = plane % raster_planes;
      raster_ptr = plane_ptr [idx];

      for (count = 0; count < vrc; count++)
        if (line + count < max_lines)
        {
          line_ptr = line_buf;
          for (i = 0; i < l_buflen; i++) *raster_ptr++ |= *line_ptr++;
          if ((l_buflen & 0x1) != 0) raster_ptr++;
        } /* if, for */
    } /* for */

    for (i = 0; i < raster_planes; i++) plane_ptr [i] += vrc * fwb;
    line += vrc;
  } /* while */

#if GEMDOS
  if ((img_header->planes == 1) || (planes == 1) || (planes == img_header->planes) && (planes <= 4) || (planes < img_header->planes))
  {
    if (img_header->planes == 1)
    {
      d.mp = raster_buffer;
      vr_trnfm (vdi_handle, &s, &d);
      raster_len = 2L * (LONG)fww * img_header->sl_height * raster_planes;
      mem_lmove (trans_buffer, raster_buffer, raster_len);
    } /* if */
    else
      vr_trnfm (vdi_handle, &s, &d);
  } /* if */
  else
    if (use_adapt)
    {
      XIMG_HEADER *ximg_header;
      WORD        *ximg_colors;

      if (img_header->headlen == sizeof (IMG_HEADER) / sizeof (WORD))
        ximg_colors = NULL;
      else
      {
        ximg_header = (XIMG_HEADER *)img_header;
        ximg_colors = ximg_header->color_table;
      } /* else */

      adapt (img_header->sl_width, img_header->sl_height, img_header->planes, plane_ptr_save, ximg_colors, trans_buffer);

      set_clip (TRUE, &clip);	/* set last clipping rectangle (has been changed by adapt) */
    } /* if */
    else
      vr_trnfm (vdi_handle, &s, &d);
#else
  vr_trnfm (vdi_handle, &s, &d);
#endif
} /* conv_img */

/*****************************************************************************/

LOCAL WORD find_bmbutton (BYTE *name)
{
  WORD i;

  for (i = 0; i < max_bmbutton; i++)
    if (stricmp (bmbutton [i].name, name) == 0)
      return (i);

  return (FAILURE);
} /* find_bmbutton */

/*****************************************************************************/

LOCAL VOID draw_acc_line (WORD vdi_handle, WORD x, WORD y, BYTE *text, WORD inx, BOOLEAN disabled, WORD dlg_colors, WORD color, WORD bk_color)
{
  WORD    w, h, xy [4];
  WORD    minimum, maximum, width;
  WORD    extent [8], distances [5], effects [3];
  LONGSTR s;

  if (inx > 0)
  {
    vqt_font_info (vdi_handle, &minimum, &maximum, distances, &width, effects);

    strncpy (s, text, LONGSTRLEN);
    s [inx - 1] = EOS;

    vqt_extent (vdi_handle, s, extent);

    w = extent [2] - extent [0] + effects [2];
    h = extent [5] - extent [3];

    xy [0] = x + w;
    xy [1] = y + h - ((gl_hbox <= 8) ? 1 : 2);

    s [0] = text [inx - 1];
    s [1] = EOS;

    vqt_extent (vdi_handle, s, extent);

    w = extent [2] - extent [0] + effects [2];
    h = extent [5] - extent [3];

    xy [2] = xy [0] + w - 1;
    xy [3] = xy [1];

    vswr_mode (vdi_handle, MD_TRANS);
    vsl_udsty (vdi_handle, 0xAAAA);
    vsl_type (vdi_handle, disabled ? (dlg_colors < 16) ? USERLINE : SOLID : SOLID);
    vsl_color (vdi_handle, disabled ? (dlg_colors < 16) ? BLACK : sys_colors [COLOR_DISABLED] : color);
    v_pline (vdi_handle, 2, xy);

    if (dlg_colors >= 16)
    {
      vsl_type (vdi_handle, SOLID);
      vsl_color (vdi_handle, disabled ? WHITE : bk_color);

      xy [0]++;
      xy [1]++;
      xy [2]++;
      xy [3]++;

      v_pline (vdi_handle, 2, xy);
    } /* if */
  } /* if */
} /* draw_acc_line */

/*****************************************************************************/

LOCAL VOID draw_owner_text (WORD vdi_handle, LB_OWNERDRAW *lb_ownerdraw, BYTE *text, WORD x, WORD y, WORD *xy)
{
  if (lb_ownerdraw->selected)
  {
    vsf_color (vdi_handle, (dlg_colors < 16) ? BLACK : sys_colors [COLOR_HIGHLIGHT]);
    v_bar (vdi_handle, xy);

    if (dlg_colors < 16)
      vst_color (vdi_handle, WHITE);
    else
      vst_color (vdi_handle, (lb_ownerdraw->style & (LBS_DRAWDISABLED | LBS_DISABLED)) ? sys_colors [COLOR_DISABLED] : sys_colors [COLOR_HIGHLIGHTTEXT]);

    tabbed_text (vdi_handle, x, y, text, lb_ownerdraw->num_tabs, lb_ownerdraw->tabs, lb_ownerdraw->tabstyles);
  } /* if */
  else
  {
    vsf_color (vdi_handle, (dlg_colors < 16) || (lb_ownerdraw->bk_color == FAILURE) ? WHITE : lb_ownerdraw->bk_color);
    v_bar (vdi_handle, xy);

    if (dlg_colors < 16)
      vst_color (vdi_handle, BLACK);
    else
      vst_color (vdi_handle, (lb_ownerdraw->style & (LBS_DRAWDISABLED | LBS_DISABLED)) ? sys_colors [COLOR_DISABLED] : (lb_ownerdraw->color == FAILURE) ? sys_colors [COLOR_BTNTEXT] : lb_ownerdraw->color);

    tabbed_text (vdi_handle, x, y, text, lb_ownerdraw->num_tabs, lb_ownerdraw->tabs, lb_ownerdraw->tabstyles);
  } /* else */
} /* draw_owner_text */

/*****************************************************************************/

LOCAL VOID tabbed_text (WORD vdi_handle, WORD x, WORD y, BYTE *text, WORD num_tabs, WORD *tabs, WORD *tabstyles)
{
  BYTE          *p;
  WORD          x_text, y_text, i, tab, ret;
  LOCAL LONGSTR s;				/* don't use stack because of limited ownerdraw AES stack */

  p   = text;
  tab = 0;

  while ((p != NULL) && (*p != EOS))
  {
    for (i = 0; (*p != '\t') && (*p != EOS); i++, p++)
      if (i < LONGSTRLEN)
        s [i] = *p;

    if (*p != EOS) p++;

    s [min (i, LONGSTRLEN)] = EOS;

    x_text = x + ((tab < num_tabs) ? tabs [tab] : tab * gl_wbox * 8);
    y_text = y;

    vst_alignment (vdi_handle, (tab < num_tabs) ? tabstyles [tab] : ALI_LEFT, ALI_TOP, &ret, &ret);
    v_gtext (vdi_handle, x_text, y_text, s);

    tab++;
  } /* while */
} /* tabbed_text */

/*****************************************************************************/

LOCAL VOID lb_redraw (LISTBOX *lb, RECT *rc_area)
{
  RECT r;

  hide_mouse ();

  if ((lb->wh == FAILURE) || lb->is_combobox)
    DrawListBox (vdi_handle, &lb->rc_obj, rc_area, lb);
  else
  {
    wind_get (lb->wh, WF_FIRSTXYWH, &r.x, &r.y, &r.w, &r.h);

    while ((r.w != 0) && (r.h != 0))
    {
      if (rc_intersect (&lb->rc_obj, &r))
        if (rc_intersect (rc_area, &r))
          DrawListBox (vdi_handle, &lb->rc_obj, &r, lb);

      wind_get (lb->wh, WF_NEXTXYWH, &r.x, &r.y, &r.w, &r.h);
    } /* while */
  } /* else */

  show_mouse ();
} /* lb_redraw */

/*****************************************************************************/

LOCAL VOID lb_draw_items (LISTBOX *lb, RECT *rc_obj, WORD from, WORD to)
{
  LOCAL WORD         char_width, char_height, cell_width, cell_height;
  LOCAL WORD         i, y, h, x_text, y_text;
  LOCAL WORD         xy [8], extent [8];
  LOCAL RECT         r, save_clip, rc_clip;
  LOCAL BYTE         *p;
  LOCAL LB_OWNERDRAW lb_ownerdraw;

  save_clip = clip;
  text_default (vdi_handle);
  vst_font (vdi_handle, (lb->font == FAILURE) ? font_btntext : lb->font);
  vst_point (vdi_handle, (lb->point == FAILURE) ? point_btntext : lb->point, &char_width, &char_height, &cell_width, &cell_height);

  for (i = 0, y = rc_obj->y + 2; i < lb->vsb.pagesize; i++, y += lb->item_height)
    if (lb->vsb.pos + i < lb->vsb.count)
      if ((from <= i) && (i <= to))
      {
        r        = *rc_obj;
        r.x     += 2;
        r.y      = y;
        r.w     -= lb->vsb_vis ? lb->vsb_size + 3 : 4;
        r.h      = lb->item_height;
        rc_clip  = r;

        if (rc_intersect (&save_clip, &rc_clip))
        {
          set_clip (TRUE, &rc_clip);

          if (lb->items != NULL)
            p = lb->items [lb->vsb.pos + i];
          else
            if (lb->callback != NULL)
              p = (BYTE *)lb->callback (lb->wh, lb->tree, lb->obj, LBN_GETITEM, lb->vsb.pos + i, NULL);
            else
              p = NULL;

          if (lb->style & LBS_OWNERDRAW)
          {
            lb_ownerdraw.rc_item   = r;
            lb_ownerdraw.rc_clip   = rc_clip;
            lb_ownerdraw.style     = lb->style;
            lb_ownerdraw.selected  = (lb->vsb.pos + i == lb->sel_item) || (lb->style & LBS_MULTIPLESEL) && setin (lb->sel_set, (WORD)(lb->vsb.pos + i));
            lb_ownerdraw.font      = lb->font;
            lb_ownerdraw.point     = lb->point;
            lb_ownerdraw.effects   = lb->effects;
            lb_ownerdraw.color     = lb->color;
            lb_ownerdraw.bk_color  = lb->bk_color;
            lb_ownerdraw.num_tabs  = lb->num_tabs;
            lb_ownerdraw.tabs      = lb->tabs;
            lb_ownerdraw.tabstyles = lb->tabstyles;

            if (lb->callback != NULL)
              lb->callback (lb->wh, lb->tree, lb->obj, LBN_DRAWITEM, lb->vsb.pos + i, &lb_ownerdraw);
          } /* if */
          else
          {
            if (p != NULL)
            {
              vqt_extent (vdi_handle, p, extent);
              h      = extent [5] - extent [3];
              x_text = r.x + lb->left_offset;
              y_text = r.y + (r.h - h) / 2;
            } /* if */

            rect2array (&r, xy);
            vswr_mode (vdi_handle, MD_TRANS);
            vsf_interior (vdi_handle, FIS_SOLID);
            vsf_perimeter (vdi_handle, FALSE);
            vsf_style (vdi_handle, 0);
            vst_effects (vdi_handle, ((lb->style & (LBS_DRAWDISABLED | LBS_DISABLED)) && (dlg_colors < 16)) ? TXT_LIGHT : TXT_NORMAL);

            if ((lb->vsb.pos + i == lb->sel_item) || (lb->style & LBS_MULTIPLESEL) && setin (lb->sel_set, (WORD)(lb->vsb.pos + i)))
            {
              if (dlg_colors < 16)
                vsf_color (vdi_handle, (lb->style & LBS_USECHECKED) ? WHITE : BLACK);
              else
                vsf_color (vdi_handle, (lb->style & LBS_USECHECKED) ? WHITE : sys_colors [COLOR_HIGHLIGHT]);

              v_bar (vdi_handle, xy);

              if (dlg_colors < 16)
                vst_color (vdi_handle, (lb->style & LBS_USECHECKED) ? BLACK : WHITE);
              else
                vst_color (vdi_handle, (lb->style & (LBS_DRAWDISABLED | LBS_DISABLED)) ? sys_colors [COLOR_DISABLED] : (lb->style & LBS_USECHECKED) ? (lb->color == FAILURE) ? sys_colors [COLOR_BTNTEXT] : lb->color : sys_colors [COLOR_HIGHLIGHTTEXT]);

              if (p != NULL)
                if (lb->style & LBS_USECHECKED)
                {
                  vst_font (vdi_handle, FONT_SYSTEM);				/* check sign available in system font */
                  v_gtext (vdi_handle, r.x + 2, y_text, "\010");		/* leave two additional pixels at left side */
                  vst_font (vdi_handle, (lb->font == FAILURE) ? font_btntext : lb->font);
                  tabbed_text (vdi_handle, x_text + gl_wbox, y_text, p, lb->num_tabs, lb->tabs, lb->tabstyles);
                } /* if */
                else
                  tabbed_text (vdi_handle, x_text, y_text, p, lb->num_tabs, lb->tabs, lb->tabstyles);
            } /* if */
            else
            {
              vsf_color (vdi_handle, (dlg_colors < 16) || (lb->bk_color == FAILURE) ? WHITE : lb->bk_color);
              v_bar (vdi_handle, xy);

              if (dlg_colors < 16)
                vst_color (vdi_handle, BLACK);
              else
                vst_color (vdi_handle, (lb->style & (LBS_DRAWDISABLED | LBS_DISABLED)) ? sys_colors [COLOR_DISABLED] : (lb->color == FAILURE) ? sys_colors [COLOR_BTNTEXT] : lb->color);

              if (p != NULL)
                tabbed_text (vdi_handle, x_text + ((lb->style & LBS_USECHECKED) ? gl_wbox : 0), y_text, p, lb->num_tabs, lb->tabs, lb->tabstyles);
            } /* else */
          } /* else */
        } /* if */
      } /* if, if, for */

  set_clip (TRUE, &save_clip);
} /* lb_draw_items */

/*****************************************************************************/

LOCAL BOOLEAN lb_visible (LISTBOX *lb, RECT *rc_obj)
{
  RECT r, rc;

  if ((lb->wh == FAILURE) || lb->is_combobox)
    return (TRUE);
  else
  {
    wind_get (lb->wh, WF_FIRSTXYWH, &r.x, &r.y, &r.w, &r.h);

    while ((r.w != 0) && (r.h != 0))
    {
      rc = *rc_obj;

      if (rc_intersect (&r, &rc))
        if (rc_equal (rc_obj, &rc))
          return (TRUE);

      wind_get (lb->wh, WF_NEXTXYWH, &r.x, &r.y, &r.w, &r.h);
    } /* while */
  } /* else */

  return (FALSE);
} /* lb_visible */

/*****************************************************************************/

LOCAL LONG lb_click (LISTBOX *lb, MKINFO *mkinfo)
{
  WORD   slider;
  LONG   item, olditem;
  WORD   dir;
  MKINFO mk;
  WORD   act_number;
  MFORM  *act_form;

  lb->vsb.pagesize = (lb->rc_obj.h - 4) / lb->item_height;

  graf_mkstate (&mk.mox, &mk.moy, &mk.mobutton, &mk.kstate);

  mk.momask = mkinfo->momask;
  olditem   = lb->sel_item;
  item      = FAILURE;
  slider    = FAILURE;

  if (lb->vsb_vis)
    slider = sb_find_obj (&lb->vsb, mk.mox, mk.moy);

  if (slider != FAILURE)
    sb_click (&lb->vsb, mkinfo);
  else
  {
    act_number = mousenumber;
    act_form   = mouseform;

    set_mouse (ARROW, NULL);

    if (lb->style & LBS_SELECTABLE)
      if ((mk.mobutton & mkinfo->momask) && ! (lb->style & LBS_MULTIPLESEL) && ! (lb->style & LBS_TOUCHEXIT))
      {
        wind_update (BEG_MCTRL);		/* Mauskontrolle Åbernehmen */

        item = lb_find_item (lb, mk.mox, mk.moy, FALSE, &dir);

        if (item != FAILURE)
        {
          item         = lb_hndl_scroll (lb, &mk, olditem, item);
          lb->sel_item = item;

          if (olditem != item)
            if (lb->callback != NULL)
              lb->callback (lb->wh, lb->tree, lb->obj, LBN_SELCHANGE, item, NULL);
        } /* if */

        wind_update (END_MCTRL);		/* Mauskontrolle wieder abgeben */
      } /* if */
      else
      {
        item = lb_find_item (lb, mk.mox, mk.moy, FALSE, &dir);

        if (item != FAILURE)
        {
          lb->sel_item = item;

          if (lb->style & LBS_MULTIPLESEL)
          {
            lb->sel_item = FAILURE;		/* Es darf kein einzelnes selektiertes Objekt geben */

            if (setin (lb->sel_set, item))
              setexcl (lb->sel_set, item);
            else
              setincl (lb->sel_set, item);
          } /* if */
        } /* if */

        if ((olditem != item) || (lb->style & LBS_MULTIPLESEL))
        {
          if ((olditem != FAILURE) && ! (lb->style & LBS_MULTIPLESEL))
            lb_change (lb, olditem);

          if (item != FAILURE)
          {
            lb_change (lb, item);

            if (lb->callback != NULL)
              lb->callback (lb->wh, lb->tree, lb->obj, LBN_SELCHANGE, item, NULL);
          } /* if */
        } /* if */

        if (mkinfo->breturn == 2)
          if (item != FAILURE)
            if (lb->callback != NULL)
              lb->callback (lb->wh, lb->tree, lb->obj, LBN_DBLCLK, item, mkinfo);
      } /* else, if */

      graf_mouse (act_number, act_form);

    } /* else */

  return (item);
} /* lb_click */

/*****************************************************************************/

LOCAL VOID lb_key (LISTBOX *lb, MKINFO *mkinfo)
{
  lb->vsb.pagesize = (lb->rc_obj.h - 4) / lb->item_height;
  lb->vsb.pix_size = sb_calc_pix_size (&lb->vsb);
  lb->vsb.pix_pos  = sb_calc_pix_pos (&lb->vsb);

  lb_keyboard (lb, mkinfo);
} /* lb_key */

/*****************************************************************************/

LOCAL LONG lb_comboclick (LISTBOX *lb, MKINFO *mkinfo)
{
  BOOLEAN ready;
  OBJECT  *tree;
  WORD    mode, slider;
  UWORD   style;
  MFDB    screen, buffer;
  LONG    item, olditem, saveitem, selected;
  WORD    dir, ret, diff;
  MKINFO  mk;
  UWORD   event, events;
  RECT    r;
  WORD    act_number;
  MFORM   *act_form;

  tree = &combobox;

  if (lb->rc_obj.h > desk.h / 2 - lb->item_height)
    lb->rc_obj.h = (desk.h / 2 - lb->item_height) / lb->item_height * lb->item_height;

  lb->rc_obj.w += 4;
  lb->rc_obj.h += 4;

  if (lb->sel_item >= lb->vsb.count) lb->sel_item = lb->vsb.count - 1;

  lb->vsb.pagesize = lb->rc_obj.h / lb->item_height;
  lb->vsb_vis      = (lb->style & LBS_VSCROLL) || (lb->vsb.count > lb->vsb.pagesize);
  lb->vsb.pos      = lb->sel_item;
  lb->vsb.pos      = min (lb->vsb.pos, lb->vsb.count - lb->vsb.pagesize);
  lb->vsb.pos      = max (lb->vsb.pos, 0);
  lb->vsb_oldpos   = lb->vsb.pos;

  tree->ob_x      = lb->rc_obj.x;
  tree->ob_y      = lb->rc_obj.y;
  tree->ob_width  = lb->rc_obj.w;
  tree->ob_height = lb->rc_obj.h;

  objc_rect (tree, ROOT, &r, FALSE);          /* RÑnder berÅcksichtigen */

  diff = r.x + r.w - (desk.x + desk.w);       /* Rechts heraushÑngend ? */
  if (diff > 0) tree->ob_x -= diff;

  diff = r.y + r.h - (desk.y + desk.h);       /* Unten heraushÑngend ? */
  if (diff > 0)
  {
    objc_rect (tree, ROOT, &r, TRUE);
    tree->ob_y = lb->y_alternate - r.h + 4;   /* Alternative wÑhlen */
  } /* if */

  objc_rect (tree, ROOT, &r, FALSE);          /* RÑnder berÅcksichtigen */

  diff = r.x - desk.x;                        /* Links heraushÑngend ? */
  if (diff < 0) tree->ob_x -= diff;

  diff = r.y - desk.y;                        /* Oben heraushÑngend ? */
  if (diff < 0) tree->ob_y -= diff;

  lb->rc_obj.x = tree->ob_x;
  lb->rc_obj.y = tree->ob_y;

  act_number = mousenumber;
  act_form   = mouseform;

  graf_mkstate (&mk.mox, &mk.moy, &mk.mobutton, &mk.kstate);
  background (tree, ROOT, TRUE, &screen, &buffer);
  hide_mouse ();
  style      = lb->style;
  lb->style |= LBS_NO3DBORDER;
  DrawListBox (vdi_handle, &lb->rc_obj, &desk, lb);
  lb->style = style;
  show_mouse ();

  mk.momask = mkinfo->momask;
  mode      = (mk.mobutton & mk.momask) ? WAIT_TRACK : WAIT_CLICK;
  item      = saveitem = selected = lb->sel_item;
  ready     = FALSE;
  slider    = FAILURE;

  set_mouse (ARROW, NULL);
  wind_update (BEG_UPDATE);
  wind_update (BEG_MCTRL);                    /* Mauskontrolle Åbernehmen */

  do
  {
    events = MU_BUTTON;

    if (mode == WAIT_CLICK)
      events |= MU_KEYBD;

    if (mode == WAIT_TRACK)
    {
      events |= MU_M1;
      objc_rect (tree, ROOT, &r, FALSE);
      r.x += 2;
      r.y += 2;
      r.w -= lb->vsb_vis ? lb->vsb_size + 3 : 4;
      r.h  = (WORD)min (lb->vsb.count, (LONG)lb->vsb.pagesize) * lb->item_height;
    } /* if */

    event = evnt_multi (events,
                        1, mkinfo->momask, ~ mk.mobutton & mkinfo->momask,
                        FALSE, r.x, r.y, r.w, r.h,
                        0, 0, 0, 0, 0,
                        NULL, 0, 0,
                        &mk.mox, &mk.moy,
                        &mk.momask, &mk.kstate,
                        &mk.kreturn, &mk.breturn);

    graf_mkstate (&ret, &ret, &mk.mobutton, &mk.kstate); /* Werte nach Ereignis */

    mk.momask = mkinfo->momask;
    mk.shift  = (mk.kstate & (K_RSHIFT | K_LSHIFT)) != 0;
    mk.ctrl   = (mk.kstate & K_CTRL) != 0;
    mk.alt    = (mk.kstate & K_ALT) != 0;
    olditem   = item;

    if (mode == WAIT_CLICK)
      slider = (event & MU_BUTTON) && lb->vsb_vis ? sb_find_obj (&lb->vsb, mk.mox, mk.moy) : FAILURE;

    if (slider != FAILURE)
      mode = WAIT_SLIDER;
    else
      item = lb_find_item (lb, mk.mox, mk.moy, FALSE, &dir);

    if (event & MU_BUTTON)
      switch (mode)
      {
        case WAIT_CLICK  : if (item == FAILURE)
                           {
                             if (lb->style & LBS_MANDATORY)
                               item = selected;
                             ready = TRUE;
                           } /* if */
                           else
                             if (mk.mobutton & mkinfo->momask)
                               mode = WAIT_SCROLL;
                             else
                             {
                               ready    = TRUE;
                               saveitem = FAILURE;
                             } /* else, else */
                           break;
        case WAIT_TRACK  : mode = WAIT_CLICK;
                           item = olditem;
                           break;
        case WAIT_SCROLL : break;
        case WAIT_SLIDER : mode = WAIT_CLICK;
                           sb_slide (&lb->vsb, &mk, slider);
                           break;
      } /* switch, if */

    if (event & MU_KEYBD)
    {
      item = lb_keyboard (lb, &mk);

      if ((mk.ascii_code == CR) || (mk.ascii_code == ESC) || (mk.scan_code == UNDO))
      {
        ready = TRUE;

        if (mk.ascii_code == CR)
          saveitem = FAILURE;
      } /* if */

      if ((mk.ascii_code == ESC) || (mk.scan_code == UNDO))
        if (lb->style & LBS_MANDATORY)
          item = selected;
    } /* if */

    if (event & MU_M1)
      if (item != FAILURE)
        mode = WAIT_SCROLL;

    if (lb->style & LBS_MANDATORY)
      if (item == FAILURE)
        item = olditem;                         /* etwas ist immer ausgewÑhlt */

    if (mode == WAIT_SCROLL)
    {
      item  = lb_hndl_scroll (lb, &mk, olditem, item);
      ready = TRUE;

      if (item != FAILURE)
      {
        saveitem = FAILURE;

        hide_mouse ();
        if (lb->callback != NULL)
          lb->callback (lb->wh, lb->tree, lb->obj, LBN_SELCHANGE, item, NULL);
        show_mouse ();
      } /* if */
    } /* if */
    else
      if (event & MU_BUTTON)                    /* nicht bei Tastatur */
      {
        if (item != FAILURE)
          lb->sel_item = item;

        if (olditem != item)
        {
          if (olditem != FAILURE)
            lb_change (lb, olditem);

          if (item != FAILURE)
          {
            lb_change (lb, item);

            hide_mouse ();
            if (lb->callback != NULL)
              lb->callback (lb->wh, lb->tree, lb->obj, LBN_SELCHANGE, item, NULL);
            show_mouse ();
          } /* if */
        } /* if */
      } /* if, else */
  } while (! ready);

  lb->sel_item = item;

  if (lb->sel_item == FAILURE)
    lb->sel_item = selected;

  if (saveitem != FAILURE)			/* Original wieder ausgewÑhlt */
  {
    hide_mouse ();
    if (lb->callback != NULL)
      lb->callback (lb->wh, lb->tree, lb->obj, LBN_SELCHANGE, saveitem, NULL);
    show_mouse ();
  } /* if */

  wind_update (END_MCTRL);			/* Mauskontrolle wieder abgeben */
  wind_update (END_UPDATE);
  graf_mouse (act_number, act_form);

  background (tree, ROOT, FALSE, &screen, &buffer);

  return (item);
} /* lb_comboclick */

/*****************************************************************************/

LOCAL LONG lb_find_item (LISTBOX *lb, WORD mox, WORD moy, BOOLEAN scroll, WORD *dir)
{
  LONG item;
  RECT rc_sliderarea, rc_obj;

  sb_calc_rect (&lb->vsb, SBC_SLIDERAREA, &rc_sliderarea, NULL, 0, 0);

  rc_obj    = lb->rc_obj;
  rc_obj.x += 2;
  rc_obj.y += 2;
  rc_obj.w -= 4;
  rc_obj.h -= 4;

  *dir = FAILURE;
  item = FAILURE;

  if (scroll || ! lb->vsb_vis || ! inside (mox, moy, &rc_sliderarea))
  {
    if (lb->vsb_vis)
      rc_obj.w -= lb->vsb_size - 1;

    if (inside (mox, moy, &rc_obj) || scroll && (lb->style & LBS_MANDATORY))
      item = lb->vsb.pos + (moy - (lb->rc_obj.y + 2)) / lb->item_height;

    if (scroll && (lb->style & LBS_MANDATORY))
    {
      item = min (item, lb->vsb.count - 1);
      item = max (item, 0);
    } /* if */

    if (item >= lb->vsb.count) item = FAILURE;

    if (scroll)
      if (moy < lb->rc_obj.y + 2)
      {
        if (lb->vsb.pos > 0) *dir = SBC_UP;
        if (lb->style & LBS_MANDATORY) item = max (0, lb->vsb.pos - 1);
      } /* if */
      else
        if (moy >= lb->rc_obj.y + lb->rc_obj.h - 2)
        {
          if (lb->vsb.pos + lb->vsb.pagesize < lb->vsb.count) *dir = SBC_DOWN;
          if (lb->style & LBS_MANDATORY) item = min (lb->vsb.pos + lb->vsb.pagesize, lb->vsb.count - 1);
        } /* if, else */
  } /* if */

  return (item);
} /* lb_find_item */

/*****************************************************************************/

LOCAL LONG lb_keyboard (LISTBOX *lb, MKINFO *mk)
{
  LONG item, olditem, diff;
  BYTE s [2];

  item           = olditem = lb->sel_item;
  mk->ascii_code = mk->kreturn & 0x00FF;
  mk->scan_code  = mk->kreturn >> 8;

#if GEMDOS
  if ((mk->scan_code >= 71) && (mk->scan_code <= 82) && /* Shift-Pfeile */
      (mk->scan_code != 74) && (mk->scan_code != 78)) mk->ascii_code = 0;
#endif

  mk->kreturn = (mk->scan_code << 8) | mk->ascii_code;

  if (mk->ascii_code == CR) return (lb->sel_item);
  if ((mk->ascii_code == ESC) || (mk->scan_code == UNDO)) return (FAILURE);

  if (mk->shift && (mk->ascii_code == 0))
    switch (mk->scan_code)
    {
      case UP       :
      case LEFT     : mk->scan_code = PGUP;   break;
      case RIGHT    :
      case DOWN     : mk->scan_code = PGDOWN; break;
      case CLR_HOME : mk->scan_code = ENDKEY; break;
    } /* switch, if */

  if (mk->ascii_code == 0)
    switch (mk->scan_code)
    {
      case UP     :
      case LEFT   : item--;                       break;
      case RIGHT  :
      case DOWN   : item++;                       break;
      case PGUP   : item -= lb->vsb.pagesize - 1; break;
      case PGDOWN : item += lb->vsb.pagesize - 1; break;
      case POS1   : item = 0;                     break;
      case ENDKEY : item = lb->vsb.count - 1;     break;
      default     : return (item);
    } /* switch, if */
  else
  {
    if (lb->style & LBS_NOSTANDARDKEYBOARD)
      item = lb->callback (lb->wh, lb->tree, lb->obj, LBN_KEYPRESSED, lb->sel_item, mk);
    else
    {
      s [0] = mk->ascii_code;
      s [1] = EOS;
      item  = ListBox_FindString (lb, lb->sel_item + 1, s);
    } /* if */

    if (item == FAILURE)
      item = lb->sel_item;
  } /* else */

  if (item < 0) item = 0;
  if (item >= lb->vsb.count) item = lb->vsb.count - 1;

  diff = item - lb->sel_item;

  if (diff != 0)
  {
    lb->sel_item = item;

    lb_change (lb, olditem);

    if ((lb->vsb.pos <= item) && (item < lb->vsb.pos + lb->vsb.pagesize))
      lb_change (lb, item);
    else
      if (item < olditem)
        sb_scroll (&lb->vsb, lb->vsb.pos, item);
      else
        sb_scroll (&lb->vsb, lb->vsb.pos, item - lb->vsb.pagesize + 1);

    hide_mouse ();
    if (lb->callback != NULL)
      lb->callback (lb->wh, lb->tree, lb->obj, LBN_SELCHANGE, lb->sel_item, NULL);
    show_mouse ();
  } /* if */
  else
    if ((lb->sel_item < lb->vsb.pos) || (lb->sel_item >= lb->vsb.pos + lb->vsb.pagesize))
      if (item < olditem)
        sb_scroll (&lb->vsb, lb->vsb.pos, item);
      else
        sb_scroll (&lb->vsb, lb->vsb.pos, item - lb->vsb.pagesize + 1);

  return (item);
} /* lb_keyboard */

/*****************************************************************************/

LOCAL LONG lb_hndl_scroll (LISTBOX *lb, MKINFO *mk, LONG olditem, LONG item)
{
  WORD dir;

  if (item != FAILURE)
    lb->sel_item = item;

  if (olditem != item)
  {
    if (olditem != FAILURE)
      lb_change (lb, olditem);

    if (item != FAILURE)
      lb_change (lb, item);
  } /* if */

  do
  {
    olditem = item;
    item    = lb_find_item (lb, mk->mox, mk->moy, TRUE, &dir);

    if (lb->style & LBS_MANDATORY)
      if (item == FAILURE)
        item = olditem;                         /* etwas ist immer ausgewÑhlt */

    lb->sel_item = item;

    if (olditem != item)
      if (olditem != FAILURE)
        lb_change (lb, olditem);

    sb_arrows (&lb->vsb, dir, mk->mox, mk->moy);

    if (dir == FAILURE)
      if (olditem != item)
        if (item != FAILURE)
          lb_change (lb, item);

    graf_mkstate (&mk->mox, &mk->moy, &mk->mobutton, &mk->kstate);
  } while (mk->mobutton & mk->momask);

  return (item);
} /* lb_hndl_scroll */

/*****************************************************************************/

LOCAL VOID lb_scroll (LISTBOX *lb, LONG old_pos, LONG new_pos)
{
  LONG    max_pos, delta;
  RECT    r;
  BOOLEAN visible, fits;

  visible = lb_visible (lb, &lb->rc_obj);
  max_pos = lb->vsb.count - lb->vsb.pagesize;
  r       = lb->rc_obj;

  rc_intersect (&desk, &r);
  fits = rc_equal (&r, &lb->rc_obj);			/* fits into desktop completely */

  if (max_pos < 0) max_pos = 0;

  if (new_pos > max_pos) new_pos = max_pos;
  if (new_pos < 0) new_pos = 0;

  delta = new_pos - old_pos;

  if (delta != 0)
  {
    hide_mouse ();

    lb->vsb_oldpos  = lb->vsb.pos;

    if ((labs (delta) >= (LONG)lb->vsb.pagesize) || ! visible || ! fits)
    {
      if (visible)
      {
        set_clip (TRUE, &lb->rc_obj);
        lb_draw_items (lb, &lb->rc_obj, 0, lb->vsb.pagesize - 1);
      } /* if */
      else
      {
        r    = lb->rc_obj;
        r.x += 2;
        r.y += 2;
        r.w -= lb->vsb_vis ? lb->vsb_size + 3 : 4;
        r.h -= 4;
        lb_redraw (lb, &r);
      } /* else */
    } /* if */
    else
    {
      r    = lb->rc_obj;
      r.x += 2;
      r.y += 2;
      r.w -= lb->vsb_vis ? lb->vsb_size + 3 : 4;
      r.h -= 4;

      if (delta > 0)
      {
        r.y += (WORD)(lb->item_height * delta);
        r.h -= (WORD)(lb->item_height * delta);
        scroll_area (&r, VERTICAL, (WORD)(delta * lb->item_height));
        set_clip (TRUE, &lb->rc_obj);
        lb_draw_items (lb, &lb->rc_obj, (WORD)(lb->vsb.pagesize - delta), lb->vsb.pagesize - 1);
      } /* if */
      else
      {
        r.h += (WORD)(lb->item_height * delta);
        scroll_area (&r, VERTICAL, (WORD)(delta * lb->item_height));
        set_clip (TRUE, &lb->rc_obj);
        lb_draw_items (lb, &lb->rc_obj, 0, (WORD)(- delta - 1));
      } /* else */
    } /* else */

    show_mouse ();
  } /* if */
} /* lb_scroll */

/*****************************************************************************/

LOCAL VOID lb_change (LISTBOX *lb, LONG item)
{
  RECT r;

  item -= lb->vsb.pos;

  if ((0 <= item) && (item < lb->vsb.pagesize))
  {
    r    = lb->rc_obj;
    r.x += 2;
    r.y += 2 + (WORD)(item * lb->item_height);
    r.w -= lb->vsb_vis ? lb->vsb_size + 3 : 4;
    r.h  = lb->item_height;

    hide_mouse ();
    set_clip (TRUE, &r);

    if (lb_visible (lb, &lb->rc_obj))
      lb_draw_items (lb, &lb->rc_obj, item, item);
    else
      lb_redraw (lb, &r);

    show_mouse ();
  } /* if */
} /* lb_change */

/*****************************************************************************/

LOCAL LISTBOX *lb_from_obj (OBJECT *tree, WORD obj, BOOLEAN calc_rect)
{
  LISTBOX *lb;
  USRBLK  *usrblkp;
  RECT    rc_obj;

  usrblkp = (USRBLK *)tree [obj].ob_spec;
  lb      = (LISTBOX *)usrblkp->spec;

  if (calc_rect)
  {
    objc_rect (tree, obj, &rc_obj, FALSE);

    lb->rc_obj        = rc_obj;
    lb->vsb.rc_obj    = lb->rc_obj;
    lb->vsb.rc_obj.x += lb->rc_obj.w - (lb->vsb_size + 2);
    lb->vsb.rc_obj.w  = lb->vsb_size + 2; 
  } /* if */

  return (lb);
} /* lb_from_obj */

/*****************************************************************************/

LOCAL LONG sb_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p)
{
  LISTBOX *lb;

  lb = (LISTBOX *)tree;

  switch (msg)
  {
    case SBN_CHANGED : lb_scroll (lb, lb->vsb_oldpos, lb->vsb.pos);
                       break;
  } /* switch */

  return (0L);
} /* sb_callback */

/*****************************************************************************/

LOCAL VOID sb_redraw (SCROLLBAR *sb, RECT *rc_area)
{
  RECT r;

  hide_mouse ();

  if (sb->wh == FAILURE)
    DrawScrollBar (vdi_handle, &sb->rc_obj, rc_area, sb);
  else
  {
    wind_get (sb->wh, WF_FIRSTXYWH, &r.x, &r.y, &r.w, &r.h);

    while ((r.w != 0) && (r.h != 0))
    {
      if (rc_intersect (&sb->rc_obj, &r))
        if (rc_intersect (rc_area, &r))
          DrawScrollBar (vdi_handle, &sb->rc_obj, &r, sb);

      wind_get (sb->wh, WF_NEXTXYWH, &r.x, &r.y, &r.w, &r.h);
    } /* while */
  } /* else */

  show_mouse ();
} /* sb_redraw */

/*****************************************************************************/

LOCAL LONG sb_click (SCROLLBAR *sb, MKINFO *mkinfo)
{
  WORD   obj;
  MKINFO mk;
  WORD   act_number;
  MFORM  *act_form;

  sb->pix_size = sb_calc_pix_size (sb);
  sb->pix_pos  = sb_calc_pix_pos (sb);

  act_number = mousenumber;
  act_form   = mouseform;

  graf_mkstate (&mk.mox, &mk.moy, &mk.mobutton, &mk.kstate);

  mk.momask = mkinfo->momask;

  set_mouse (ARROW, NULL);

  obj = sb_find_obj (sb, mk.mox, mk.moy);

  if (obj != FAILURE)
    sb_slide (sb, &mk, obj);

  graf_mouse (act_number, act_form);

  return (sb->pos);
} /* sb_click */

/*****************************************************************************/

LOCAL VOID sb_key (SCROLLBAR *sb, MKINFO *mkinfo)
{
} /* sb_key */

/*****************************************************************************/

LOCAL WORD sb_calc_pix_pos (SCROLLBAR *sb)
{
  WORD pos, boxsize, size;
  LONG max_pos, value;

  boxsize = (sb->style & SBS_HORIZONTAL) ? sb->rc_obj.h - 2 : sb->rc_obj.w - 2;
  size    = (sb->style & SBS_HORIZONTAL) ? sb->rc_obj.w : sb->rc_obj.h;
  max_pos = sb->count - sb->pagesize;

  if (max_pos <= 0)
    pos = 0;
  else
    if (sb->count < 1000L)
    {
      value = (1000L * sb->pos * (size - 2 * boxsize - sb->pix_size)) / max_pos;
      pos   = (WORD)(value / 1000L);
      if (value % 1000L >= 500L) pos++;
    } /* if */
    else
    {
      value = (sb->pos * (size - 2 * boxsize - sb->pix_size)) / max_pos;
      pos   = (WORD)value;
    } /* else, else */

  return (pos);
} /* sb_calc_pix_pos */

/*****************************************************************************/

LOCAL WORD sb_calc_pix_size (SCROLLBAR *sb)
{
  WORD boxsize, size;

  boxsize  = (sb->style & SBS_HORIZONTAL) ? sb->rc_obj.h - 2 : sb->rc_obj.w - 2;
  size     = (sb->style & SBS_HORIZONTAL) ? sb->rc_obj.w : sb->rc_obj.h;
  size    -= 2 * boxsize;

  if ((sb->count > 0) && (sb->pagesize <= sb->count))
    size = (WORD)((size * sb->pagesize) / sb->count);

  if (size < boxsize) size = boxsize;

  return (size);
} /* sb_calc_pix_size */

/*****************************************************************************/

LOCAL LONG sb_calc_pos (SCROLLBAR *sb, WORD slide_value)
{
  LONG pos, max_pos;
  LONG value;

  max_pos = sb->count - sb->pagesize;

  if (max_pos < 0) max_pos = 0;

  value = max_pos * slide_value;
  pos   = value / 1000;
  if (value % 1000 >= 500) pos++;

  return (pos);
} /* sb_calc_pos */

/*****************************************************************************/

LOCAL VOID sb_calc_rect (SCROLLBAR *sb, WORD which, RECT *r, WORD *xy, WORD inflate, WORD offset)
{
  WORD boxsize;
  RECT rc;

  rc = *r = sb->rc_obj;

  if (sb->style & SBS_HORIZONTAL)
  {
    boxsize  = sb->rc_obj.h - 2;
    rc.x    += boxsize + sb->pix_pos;
    rc.y    += 1;
    rc.w     = sb->pix_size;
    rc.h     = boxsize;
  } /* if */
  else
  {
    boxsize  = sb->rc_obj.w - 2;
    rc.x    += 1;
    rc.y    += boxsize + sb->pix_pos;
    rc.w     = boxsize;
    rc.h     = sb->pix_size;
  } /* else */
                     
  switch (which)
  {
    case SBC_PARENT     : if (sb->style & SBS_HORIZONTAL)
                          {
                            r->x += boxsize;
                            r->y++;
                            r->w  = sb->rc_obj.w - 2 * boxsize;
                            r->h  = boxsize;
                          } /* if */
                          else
                          {
                            r->x++;
                            r->y += boxsize;
                            r->w  = boxsize;
                            r->h  = sb->rc_obj.h - 2 * boxsize;
                          } /* else */
                          break;
    case SBC_PGUP       : *r = rc;
                          if (sb->style & SBS_HORIZONTAL)
                          {
                            r->x = sb->rc_obj.x + boxsize;
                            r->w = sb->pix_pos;
                          } /* if */
                          else
                          {
                            r->y = sb->rc_obj.y + boxsize;
                            r->h = sb->pix_pos;
                          } /* else */
                          break;
    case SBC_PGDOWN     : *r = rc;
                          if (sb->style & SBS_HORIZONTAL)
                          {
                            r->x = rc.x + sb->pix_size;
                            r->w = sb->rc_obj.w - 2 * boxsize - sb->pix_pos - sb->pix_size;
                          } /* if */
                          else
                          {
                            r->y = rc.y + sb->pix_size;
                            r->h = sb->rc_obj.h - 2 * boxsize - sb->pix_pos - sb->pix_size;
                          } /* else */
                          break;
    case SBC_UP         : r->x++;
                          r->y++;
                          r->w = boxsize;
                          r->h = boxsize;
                          break;
    case SBC_DOWN       : if (sb->style & SBS_HORIZONTAL)
                          {
                            r->x += r->w - boxsize - 1;
                            r->y++;
                          } /* if */
                          else
                          {
                            r->x++;
                            r->y += r->h - boxsize - 1;
                          } /* else */
                          r->w = boxsize;
                          r->h = boxsize;
                          break;
    case SBC_SLIDER     : *r = rc;
                          break;
    case SBC_SLIDERAREA : r->x++;
                          r->y++;

                          if (sb->style & SBS_HORIZONTAL)
                          {
                            r->w -= 2;
                            r->h  = boxsize;
                          } /* if */
                          else
                          {
                            r->w  = boxsize;
                            r->h -= 2;
                          } /* else */
                          break;
  } /* switch */

  r->x += inflate + offset;
  r->y += inflate + offset;
  r->w -= 2 * inflate;
  r->h -= 2 * inflate;

  if (xy != NULL)
    rect2array (r, xy);
} /* sb_calc_rect */

/*****************************************************************************/

LOCAL WORD sb_find_obj (SCROLLBAR *sb, WORD x, WORD y)
{
  WORD obj;
  RECT r;

  for (obj = SBC_SLIDER; obj <= SBC_SLIDERAREA; obj++)
  {
    sb_calc_rect (sb, obj, &r, NULL, 0, 0);

    if (inside (x, y, &r))
      return (obj);
  } /* for */

  return (FAILURE);
} /* sb_find_obj */

/*****************************************************************************/

LOCAL VOID sb_slide (SCROLLBAR *sb, MKINFO *mk, WORD slider)
{
  WORD org_slider, old_slider;

  if (sb->count > sb->pagesize)			/* there is slider functionality */
  {
    if (slider != FAILURE)
      sb_change (sb, slider);

    org_slider = slider;

    do
    {
      sb_arrows (sb, slider, mk->mox, mk->moy);
      graf_mkstate (&mk->mox, &mk->moy, &mk->mobutton, &mk->kstate);
      old_slider = slider;
      slider     = sb_find_obj (sb, mk->mox, mk->moy);

      if (slider != org_slider)			/* use same slider functionality only */
        slider = FAILURE;

      if (old_slider != slider)
      {
        if (old_slider != FAILURE)
          sb_change (sb, old_slider);

        if (slider != FAILURE)
          sb_change (sb, slider);
      } /* if */
    } while (mk->mobutton & mk->momask);

    if (slider != FAILURE)
      sb_change (sb, slider);
  } /* if */
} /* sb_slide */

/*****************************************************************************/

LOCAL VOID sb_arrows (SCROLLBAR *sb, WORD dir, WORD x, WORD y)
{
  LONG new_pos;
  LONG pagesize;

  if (dir != FAILURE)
  {
    new_pos  = sb->pos;
    pagesize = sb->pagesize;

    if (pagesize <= 1) pagesize = DEF_PAGESCROLL;	/* to scroll at least 10 lines */

    switch (dir)
    {
      case SBC_SLIDER : new_pos = sb_calc_pos (sb, sb_slide_box (sb));
                        break;
      case SBC_PGUP   : new_pos -= pagesize - 1;
                        break;
      case SBC_PGDOWN : new_pos += pagesize - 1;
                        break;
      case SBC_UP     : new_pos--;
                        break;
      case SBC_DOWN   : new_pos++;
                        break;
    } /* switch */

    sb_scroll (sb, sb->pos, new_pos);
  } /* if */
} /* sb_arrows */

/*****************************************************************************/

LOCAL VOID sb_scroll (SCROLLBAR *sb, LONG old_pos, LONG new_pos)
{
  LONG    max_pos, delta, old;
  RECT    r;
  BOOLEAN visible;

  visible = sb_visible (sb, &sb->rc_obj);
  max_pos = sb->count - sb->pagesize;

  if (max_pos < 0) max_pos = 0;

  if (new_pos > max_pos) new_pos = max_pos;
  if (new_pos < 0) new_pos = 0;

  delta = new_pos - old_pos;

  if (delta != 0)
  {
    hide_mouse ();

    sb->pos     = new_pos;
    old         = sb->pix_pos;
    sb->pix_pos = sb_calc_pix_pos (sb);

    if (old != sb->pix_pos)
    {
      sb_calc_rect (sb, SBC_PARENT, &r, NULL, 1, 0);	/* don't need to redraw border */

      if (visible)
        DrawScrollBar (vdi_handle, &sb->rc_obj, &r, sb);
      else
        sb_redraw (sb, &r);
    } /* if */

    if (sb->callback != NULL)
      sb->callback (sb->wh, sb->tree, sb->obj, SBN_CHANGED, new_pos, NULL);

    show_mouse ();
  } /* if */
} /* sb_scroll */

/*****************************************************************************/

LOCAL BOOLEAN sb_visible (SCROLLBAR *sb, RECT *rc_obj)
{
  RECT r, rc;

  if (sb->wh == FAILURE)
    return (TRUE);
  else
  {
    wind_get (sb->wh, WF_FIRSTXYWH, &r.x, &r.y, &r.w, &r.h);

    while ((r.w != 0) && (r.h != 0))
    {
      rc = *rc_obj;

      if (rc_intersect (&r, &rc))
        if (rc_equal (rc_obj, &rc))
          return (TRUE);

      wind_get (sb->wh, WF_NEXTXYWH, &r.x, &r.y, &r.w, &r.h);
    } /* while */
  } /* else */

  return (FALSE);
} /* sb_visible */

/*****************************************************************************/

LOCAL WORD sb_slide_box (SCROLLBAR *sb)
{
  LONG   value, maxpos, oldpos, newpos;
  RECT   bound;
  WORD   event, ret;
  WORD   x_offset, y_offset, size;
  RECT   startbox, box;
  MKINFO mk, start;

  graf_mkstate (&start.mox, &start.moy, &start.mobutton, &start.kstate);
  mk = start;

  sb_calc_rect (sb, SBC_SLIDER, &startbox, NULL, 0, 0);
  sb_calc_rect (sb, SBC_PARENT, &bound, NULL, 0, 0);

  box      = startbox;
  x_offset = y_offset = 0;
  value    = 0;
  maxpos   = (sb->style & SBS_HORIZONTAL) ? bound.w - startbox.w : bound.h - startbox.h;
  newpos   = sb->pos;

  line_default (vdi_handle);
  vsl_type (vdi_handle, USERLINE);

  draw_box (&box);

  do
  {
    event = evnt_multi (MU_BUTTON | MU_M1,
                        1, start.mobutton, 0x0000,
                        TRUE, mk.mox, mk.moy, 1, 1,
                        0, 0, 0, 0, 0,
                        NULL,
                        0, 0,
                        &mk.mox, &mk.moy,
                        &mk.momask, &mk.kstate,
                        &mk.kreturn, &mk.breturn);

    graf_mkstate (&ret, &ret, &mk.mobutton, &mk.kstate); /* Werte nach Ereignis */

    if (event & MU_M1)
    {
      fix_box (&box, &bound);
      draw_box (&box);

      x_offset = mk.mox - start.mox;
      y_offset = mk.moy - start.moy;
      box.x    = startbox.x + x_offset;
      box.y    = startbox.y + y_offset;

      fix_box (&box, &bound);

      if (sb->style & LBS_VREALTIME)
      {
        size   = (sb->style & SBS_HORIZONTAL) ? box.x - bound.x : box.y - bound.y;
        value  = (1000L * size) / maxpos;
        oldpos = newpos;
        newpos = sb_calc_pos (sb, (WORD)value);

        if (oldpos != newpos)
          sb_scroll (sb, sb->pos, newpos);
      } /* if */

      draw_box (&box);
    } /* if */
  } while (! (event & MU_BUTTON));

  draw_box (&box);

  size = (sb->style & SBS_HORIZONTAL) ? box.x - bound.x : box.y - bound.y;

  return ((WORD)((1000L * size) / maxpos));
} /* sb_slide_box */

/*****************************************************************************/

LOCAL VOID sb_change (SCROLLBAR *sb, WORD slider)
{
  RECT r;

  sb_calc_rect (sb, slider, &r, NULL, 0, 0);

  switch (slider)
  {
    case SBC_SLIDER     : break;
    case SBC_PGUP       : break;
    case SBC_PGDOWN     : break;
    case SBC_UP         : sb->uparrow_selected ^= TRUE;
                          sb_redraw (sb, &r);
                          break;
    case SBC_DOWN       : sb->downarrow_selected ^= TRUE;
                          sb_redraw (sb, &r);
                          break;
    case SBC_PARENT     : break;
    case SBC_SLIDERAREA : break;
  } /* switch */
} /* sb_change */

/*****************************************************************************/

LOCAL SCROLLBAR *sb_from_obj (OBJECT *tree, WORD obj, BOOLEAN calc_rect)
{
  SCROLLBAR *sb;
  USRBLK    *usrblkp;
  RECT      rc_obj;

  usrblkp = (USRBLK *)tree [obj].ob_spec;
  sb      = (SCROLLBAR *)usrblkp->spec;

  if (calc_rect)
  {
    objc_rect (tree, obj, &rc_obj, FALSE);

    sb->rc_obj = rc_obj;
  } /* if */

  return (sb);
} /* sb_from_obj */

/*****************************************************************************/

LOCAL VOID draw_box (RECT *box)
{
  WORD xy [10];

  hide_mouse ();

  xy [0] = box->x;
  xy [1] = box->y;
  xy [2] = xy [0];
  xy [3] = xy [1] + box->h - 1;
  xy [4] = xy [0] + box->w - 1;
  xy [5] = xy [3];
  xy [6] = xy [4];
  xy [7] = xy [1];
  xy [8] = xy [0];
  xy [9] = xy [1];

  set_clip (TRUE, &desk);
  line_default (vdi_handle);
  vswr_mode (vdi_handle, MD_XOR);
  vsl_type (vdi_handle, USERLINE);
  vsl_udsty (vdi_handle, 0x5555);
  v_pline (vdi_handle, 5, xy);

  show_mouse ();
} /* draw_box */

/*****************************************************************************/

LOCAL VOID fix_box (RECT *box, RECT *bound)
{
  WORD diff;

  diff = bound->x - box->x;
  if (diff > 0) box->x = bound->x;              /* Links heraushÑngend */

  diff = bound->x + bound->w - (box->x + box->w);
  if (diff < 0) box->x += diff;                 /* Rechts heraushÑngend */

  diff = bound->y - box->y;
  if (diff > 0) box->y = bound->y;              /* Oben heraushÑngend */

  diff = bound->y + bound->h - (box->y + box->h);
  if (diff < 0) box->y += diff;                 /* Unten heraushÑngend */
} /* fix_box */

/*****************************************************************************/

LOCAL VOID clear_rect (CONST RECT *rect, WORD color)
{
  WORD xy [4];
  RECT r;

  r = *rect;

  if ((r.w > 0) && (r.h > 0))
  {
    vswr_mode (vdi_handle, MD_REPLACE);
    vsf_interior (vdi_handle, FIS_SOLID);
    vsf_color (vdi_handle, color);
    rect2array (&r, xy);
    vr_recfl (vdi_handle, xy);
  } /* if */
} /* clr_rect */

/*****************************************************************************/
/* Zeichnet listbox                                                          */
/*****************************************************************************/

#if MSDOS
LOCAL WORD draw_listbox (VOID)
{
  PARMBLK *pb = fardr_start ();
#else
LOCAL WORD CDECL draw_listbox (PARMBLK *pb)
{
#endif

  LISTBOX *lb;
  USRBLK  *usrblkp;
  WORD    state;
  RECT    rc_obj, rc_clip;

  usrblkp = (USRBLK *)(pb->pb_tree [pb->pb_obj].ob_spec);
  lb      = (LISTBOX *)usrblkp->spec;
  state   = pb->pb_currstate;

  if (state & DISABLED)
    lb->style |= LBS_DISABLED;
  else
    lb->style &= ~ LBS_DISABLED;

  state &= ~ (SELECTED | DISABLED);

  xywh2rect (pb->pb_x, pb->pb_y, pb->pb_w, pb->pb_h, &rc_obj);
  xywh2rect (pb->pb_xc, pb->pb_yc, pb->pb_wc, pb->pb_hc, &rc_clip);

  lb->rc_obj = rc_obj;

  DrawListBox (vdi_handle, &rc_obj, &rc_clip, lb);

#if MSDOS
  fardr_end (state);
#endif

  return (state);
} /* draw_listbox */

/*****************************************************************************/
/* Zeichnet combobox                                                         */
/*****************************************************************************/

#if MSDOS
LOCAL WORD draw_combobox (VOID)
{
  PARMBLK *pb = fardr_start ();
#else
LOCAL WORD CDECL draw_combobox (PARMBLK *pb)
{
#endif

  BYTE         *text;
  LISTBOX      *lb;
  WORD         ob_x, ob_y, ob_w, ob_h, state;
  USRBLK       *usrblkp;
  RECT         rc, rc_clip, save_clip;
  LB_OWNERDRAW lb_ownerdraw;
  FONTDESC     fontdesc;

  text      = (BYTE *)pb->pb_parm;
  usrblkp   = (USRBLK *)(pb->pb_tree [pb->pb_obj].ob_spec);
  lb        = (LISTBOX *)usrblkp->spec;
  state     = pb->pb_currstate;
  ob_x      = pb->pb_x;
  ob_y      = pb->pb_y;
  ob_w      = pb->pb_w;
  ob_h      = pb->pb_h;

  xywh2rect (pb->pb_x, pb->pb_y, pb->pb_w, pb->pb_h, &rc);
  xywh2rect (pb->pb_xc, pb->pb_yc, pb->pb_wc, pb->pb_hc, &rc_clip);

  if (state & SELECTED)
    lb->style |= LBS_SELECTED;
  else
    lb->style &= ~ LBS_SELECTED;

  if (state & DISABLED)
    lb->style |= LBS_DISABLED;
  else
    lb->style &= ~ LBS_DISABLED;

  state &= ~ (SELECTED | DISABLED);

  fontdesc.font    = lb->font;
  fontdesc.point   = lb->point;
  fontdesc.effects = lb->effects;
  fontdesc.color   = lb->color;

  DrawComboBox (vdi_handle, &rc, &rc_clip, text, lb->style, lb->bk_color, &fontdesc, lb->left_offset, lb->vsb_size, lb->num_tabs, lb->tabs, lb->tabstyles);

  if (lb->style & LBS_OWNERDRAW)
  {
    save_clip = clip;

    ob_x += 2;								/* don't use border for background and text */
    ob_y += 2;
    ob_w -= lb->vsb_size + 3;
    ob_h -= 4;

    xywh2rect (ob_x, ob_y, ob_w, ob_h, &rc);
    rc_intersect (&rc, &rc_clip);
    set_clip (TRUE, &rc_clip);

    lb_ownerdraw.rc_item   = rc;
    lb_ownerdraw.rc_clip   = rc_clip;
    lb_ownerdraw.style     = lb->style;
    lb_ownerdraw.selected  = FALSE;
    lb_ownerdraw.font      = lb->font;
    lb_ownerdraw.point     = lb->point;
    lb_ownerdraw.effects   = lb->effects;
    lb_ownerdraw.color     = lb->color;
    lb_ownerdraw.bk_color  = lb->bk_color;
    lb_ownerdraw.num_tabs  = lb->num_tabs;
    lb_ownerdraw.tabs      = lb->tabs;
    lb_ownerdraw.tabstyles = lb->tabstyles;

    if (lb->callback != NULL)
      lb->callback (lb->wh, lb->tree, lb->obj, LBN_DRAWITEM, FAILURE, &lb_ownerdraw);

    set_clip (TRUE, &save_clip);
  } /* if */

#if MSDOS
  fardr_end (state);
#endif

  return (state);
} /* draw_combobox */

/*****************************************************************************/
/* Zeichnet scrollbar                                                        */
/*****************************************************************************/

#if MSDOS
LOCAL WORD draw_scrollbar (VOID)
{
  PARMBLK *pb = fardr_start ();
#else
LOCAL WORD CDECL draw_scrollbar (PARMBLK *pb)
{
#endif

  SCROLLBAR *sb;
  USRBLK    *usrblkp;
  WORD      state;
  RECT      rc, rc_clip;

  usrblkp = (USRBLK *)(pb->pb_tree [pb->pb_obj].ob_spec);
  sb      = (SCROLLBAR *)usrblkp->spec;
  state   = pb->pb_currstate;

  if (state & DISABLED)
    sb->style |= SBS_DISABLED;
  else
    sb->style &= ~ SBS_DISABLED;

  state &= ~ (SELECTED | DISABLED);

  xywh2rect (pb->pb_x, pb->pb_y, pb->pb_w, pb->pb_h, &rc);
  xywh2rect (pb->pb_xc, pb->pb_yc, pb->pb_wc, pb->pb_hc, &rc_clip);

  sb->rc_obj = rc;

  DrawScrollBar (vdi_handle, &rc, &rc_clip, sb);

#if MSDOS
  fardr_end (state);
#endif

  return (state);
} /* draw_scrollbar */

/*****************************************************************************/
/* Zeichnet 3d box                                                           */
/*****************************************************************************/

#if MSDOS
LOCAL WORD draw_3d_box (VOID)
{
  PARMBLK *pb = fardr_start ();
#else
LOCAL WORD CDECL draw_3d_box (PARMBLK *pb)
{
#endif

  WORD state, border;
  RECT rc, rc_clip;

  state  = pb->pb_currstate;
  border = (WORD)((pb->pb_parm >> 16) & 0x00FFL);

  if (border & 0x0080) border |= 0xFF00;			/* Rand negativ */

  xywh2rect (pb->pb_x, pb->pb_y, pb->pb_w, pb->pb_h, &rc);
  xywh2rect (pb->pb_xc, pb->pb_yc, pb->pb_wc, pb->pb_hc, &rc_clip);

  Draw3DBox (vdi_handle, &rc, &rc_clip, state, border);

  state &= ~ (SELECTED | DISABLED);

#if MSDOS
  fardr_end (state);
#endif

  return (state);
} /* draw_3d_box */

/*****************************************************************************/
/* Zeichnet strings                                                          */
/*****************************************************************************/

#if MSDOS
LOCAL WORD draw_string (VOID)
{
  PARMBLK *pb = fardr_start ();
#else
LOCAL WORD CDECL draw_string (PARMBLK *pb)
{
#endif

  BYTE     *text;
  WORD     state;
  RECT     rc, rc_clip;
  FONTDESC fontdesc;

  text  = (BYTE *)pb->pb_parm;
  state = pb->pb_currstate;

  xywh2rect (pb->pb_x, pb->pb_y, pb->pb_w, pb->pb_h, &rc);
  xywh2rect (pb->pb_xc, pb->pb_yc, pb->pb_wc, pb->pb_hc, &rc_clip);

  fontdesc.font    = font_btntext;
  fontdesc.point   = point_btntext;
  fontdesc.effects = effects_btntext;
  fontdesc.color   = sys_colors [COLOR_BTNTEXT];

  DrawString (vdi_handle, &rc, &rc_clip, text, OB_EXTYPE (pb->pb_tree, pb->pb_obj), state, FAILURE, &fontdesc);

  state &= ~ (SELECTED | DISABLED);

#if MSDOS
  fardr_end (state);
#endif

  return (state);
} /* draw_string */

/*****************************************************************************/
/* Zeichnet checkboxes und radio buttons                                     */
/*****************************************************************************/

#if MSDOS
LOCAL WORD draw_checkradio (VOID)
{
  PARMBLK *pb = fardr_start ();
#else
LOCAL WORD CDECL draw_checkradio (PARMBLK *pb)
{
#endif

  BYTE     *text;
  WORD     state;
  BOOLEAN  changed, radio;
  RECT     rc, rc_clip;
  FONTDESC fontdesc;

  text    = (BYTE *)pb->pb_parm;
  state   = pb->pb_currstate;
  changed = (pb->pb_currstate ^ pb->pb_prevstate) & SELECTED;
  radio   = (OB_FLAGS (pb->pb_tree, pb->pb_obj) & RBUTTON) != 0;

  xywh2rect (pb->pb_x, pb->pb_y, pb->pb_w, pb->pb_h, &rc);
  xywh2rect (pb->pb_xc, pb->pb_yc, pb->pb_wc, pb->pb_hc, &rc_clip);

  fontdesc.font    = font_btntext;
  fontdesc.point   = point_btntext;
  fontdesc.effects = effects_btntext;
  fontdesc.color   = sys_colors [COLOR_BTNTEXT];

  DrawCheckRadio (vdi_handle, &rc, &rc_clip, changed ? NULL : text, OB_EXTYPE (pb->pb_tree, pb->pb_obj), state, FAILURE, &fontdesc, radio);

  state &= ~ (SELECTED | DISABLED);

#if MSDOS
  fardr_end (state);
#endif

  return (state);
} /* draw_checkradio */

/*****************************************************************************/
/* Zeichnet group box                                                        */
/*****************************************************************************/

#if MSDOS
LOCAL WORD draw_groupbox (VOID)
{
  PARMBLK *pb = fardr_start ();
#else
LOCAL WORD CDECL draw_groupbox (PARMBLK *pb)
{
#endif

  BYTE     *text;
  WORD     state;
  RECT     rc, rc_clip;
  FONTDESC fontdesc;

  text  = (BYTE *)pb->pb_parm;
  state = pb->pb_currstate;

  xywh2rect (pb->pb_x, pb->pb_y, pb->pb_w, pb->pb_h, &rc);
  xywh2rect (pb->pb_xc, pb->pb_yc, pb->pb_wc, pb->pb_hc, &rc_clip);

  fontdesc.font    = font_btntext;
  fontdesc.point   = point_btntext;
  fontdesc.effects = effects_btntext;
  fontdesc.color   = sys_colors [COLOR_BTNTEXT];

  DrawGroupBox (vdi_handle, &rc, &rc_clip, text, OB_EXTYPE (pb->pb_tree, pb->pb_obj), state, FAILURE, &fontdesc);

  state &= ~ (SELECTED | DISABLED);

#if MSDOS
  fardr_end (state);
#endif

  return (state);
} /* draw_groupbox */

/*****************************************************************************/
/* Zeichnet pushbuttons                                                      */
/*****************************************************************************/

#if MSDOS
LOCAL WORD draw_button (VOID)
{
  PARMBLK *pb = fardr_start ();
#else
LOCAL WORD CDECL draw_button (PARMBLK *pb)
{
#endif

  BYTE     *text;
  WORD     state;
  RECT     rc, rc_clip;
  FONTDESC fontdesc;

  text  = (BYTE *)pb->pb_parm;
  state = pb->pb_currstate;

  xywh2rect (pb->pb_x, pb->pb_y, pb->pb_w, pb->pb_h, &rc);
  xywh2rect (pb->pb_xc, pb->pb_yc, pb->pb_wc, pb->pb_hc, &rc_clip);

  fontdesc.font    = font_btntext;
  fontdesc.point   = point_btntext;
  fontdesc.effects = effects_btntext;
  fontdesc.color   = sys_colors [COLOR_BTNTEXT];

  DrawButton (vdi_handle, &rc, &rc_clip, text, OB_EXTYPE (pb->pb_tree, pb->pb_obj), state, sys_colors [COLOR_BTNFACE], &fontdesc, (OB_FLAGS (pb->pb_tree, pb->pb_obj) & DEFAULT) != 0, btn_round_borders, btn_shadow_width);

  state &= ~ (SELECTED | DISABLED);

#if MSDOS
  fardr_end (state);
#endif

  return (state);
} /* draw_button */

/*****************************************************************************/
/* Zeichnet bitmap buttons                                                   */
/*****************************************************************************/

#if MSDOS
LOCAL WORD draw_bmbutton (VOID)
{
  PARMBLK *pb = fardr_start ();
#else
LOCAL WORD CDECL draw_bmbutton (PARMBLK *pb)
{
#endif

  BMBUTTON *bmbutton;
  USRBLK   *usrblkp;
  WORD     ob_x, ob_y, ob_w, ob_h, state, i;
  BOOLEAN  selected, disabled, noselected, nodisabled;
  MFDB     s, d;
  WORD     xy [8];
  WORD     index [2];
  RECT     r, save_clip;
  UBYTE    *rasterbuf;

  save_clip  = clip;
  usrblkp    = (USRBLK *)(pb->pb_tree [pb->pb_obj].ob_spec);
  bmbutton   = (BMBUTTON *)usrblkp->spec;
  ob_x       = pb->pb_x;
  ob_y       = pb->pb_y;
  ob_w       = bmbutton->width;
  ob_h       = bmbutton->height;
  state      = pb->pb_currstate;
  selected   = (state & SELECTED) != 0;
  disabled   = (state & DISABLED) != 0;
  noselected = nodisabled = FALSE;

  xywh2rect (pb->pb_xc, pb->pb_yc, pb->pb_wc, pb->pb_hc, &r);
  set_clip (TRUE, &r);

  if (disabled)
  {
    rasterbuf = (dlg_colors < 16) ? bmbutton->d1.dd_buffer : bmbutton->d4.dd_buffer;

    if (rasterbuf == NULL)
    {
      nodisabled = TRUE;
      rasterbuf  = (dlg_colors < 16) ? bmbutton->n1.dd_buffer : bmbutton->n4.dd_buffer;
    } /* if */
  } /* if */
  else
    if (selected)
    {
      rasterbuf = (dlg_colors < 16) ? bmbutton->s1.dd_buffer : bmbutton->s4.dd_buffer;

      if (rasterbuf == NULL)
      {
        noselected = TRUE;
        rasterbuf  = (dlg_colors < 16) ? bmbutton->n1.dd_buffer : bmbutton->n4.dd_buffer;
      } /* if */
    } /* if */
    else
      rasterbuf = (dlg_colors < 16) ? bmbutton->n1.dd_buffer : bmbutton->n4.dd_buffer;

  d.mp  = NULL;                 /* screen */
  s.mp  = (VOID *)rasterbuf;
  s.fwp = ob_w;
  s.fh  = ob_h;
  s.fww = (s.fwp + 15) / 16;
  s.ff  = FALSE;
  s.np  = (dlg_colors < 16) ? 1 : planes;

  xy [0] = 0;
  xy [1] = 0;
  xy [2] = ob_w - 1;
  xy [3] = ob_h - 1;
  xy [4] = ob_x;
  xy [5] = ob_y;
  xy [6] = ob_x + xy [2];
  xy [7] = ob_y + xy [3];

  state &= ~ SELECTED;

  if ((s.np == 1) || (rasterbuf == NULL))			/* draw monochrome picture */
  {
    if (rasterbuf == NULL)
    {
      rasterbuf = bmbutton->n1.dd_buffer;                       /* no rasterbuffer found, try monochrome buffer */
      s.mp      = (VOID *)rasterbuf;
    } /* if */

    index [0] = BLACK;
    index [1] = WHITE;

    if (disabled && ! nodisabled)
      state &= ~ DISABLED;

    if (rasterbuf != NULL)
      vrt_cpyfm (vdi_handle, MD_REPLACE, xy, &s, &d, index);

    if (selected && noselected)
    {
      xy [4]++;
      xy [5]++;
      xy [6]--;
      xy [7]--;
      vswr_mode (vdi_handle, MD_XOR);
      vsf_color (vdi_handle, BLACK);
      vsf_interior (vdi_handle, FIS_SOLID);
      vr_recfl (vdi_handle, &xy [4]);
    } /* if */
  } /* if */
  else                                  /* draw color picture */
  {
    if (disabled && ! nodisabled)
      state &= ~ DISABLED;

    xy [4]++;                           /* don't gray black border */
    xy [5]++;
    xy [6]--;
    xy [7]--;
 
    vswr_mode (vdi_handle, MD_REPLACE);
    vsf_color (vdi_handle, sys_colors [COLOR_BTNFACE]);
    vsf_interior (vdi_handle, FIS_SOLID);
    vr_recfl (vdi_handle, &xy [4]);     /* gray the interior */
 
    line_default (vdi_handle);

    xy [0] = ob_x + 1;
    xy [1] = ob_y;
    xy [2] = ob_x + ob_w - 2;
    xy [3] = ob_y;
    v_pline (vdi_handle, 2, xy);

    xy [0] = ob_x + ob_w - 1;
    xy [1] = ob_y + 1;
    xy [2] = ob_x + ob_w - 1;
    xy [3] = ob_y + ob_h - 2;
    v_pline (vdi_handle, 2, xy);

    xy [0] = ob_x + ob_w - 2;
    xy [1] = ob_y + ob_h - 1;
    xy [2] = ob_x + 1;
    xy [3] = ob_y + ob_h - 1;
    v_pline (vdi_handle, 2, xy);

    xy [0] = ob_x;
    xy [1] = ob_y + ob_h - 2;
    xy [2] = ob_x;
    xy [3] = ob_y + 1;
    v_pline (vdi_handle, 2, xy);

    if (selected)
    {
      vsl_color (vdi_handle, sys_colors [COLOR_BTNSHADOW]);

      for (i = 0; i < 1; i++)
      {
        xy [0] = ob_x + 1 + i;
        xy [1] = ob_y + ob_h - 2;
        xy [2] = ob_x + 1 + i;
        xy [3] = ob_y + 1 + i;
        xy [4] = ob_x + ob_w - 2;
        xy [5] = ob_y + 1 + i;
        v_pline (vdi_handle, 3, xy);
      } /* for */
    } /* if */
    else
    {
      vsl_color (vdi_handle, sys_colors [COLOR_BTNHIGHLIGHT]);

      for (i = 0; i < 1; i++)
      {
        xy [0] = ob_x + 1 + i;
        xy [1] = ob_y + ob_h - 3 - i;
        xy [2] = ob_x + 1 + i;
        xy [3] = ob_y + 1 + i;
        xy [4] = ob_x + ob_w - 3 - i;
        xy [5] = ob_y + 1 + i;
        v_pline (vdi_handle, 3, xy);
      } /* for */

      vsl_color (vdi_handle, sys_colors [COLOR_BTNSHADOW]);

      for (i = 0; i < 2; i++)
      {
        xy [0] = ob_x + ob_w - 2 - i;
        xy [1] = ob_y + 1 + i;
        xy [2] = ob_x + ob_w - 2 - i;
        xy [3] = ob_y + ob_h - 2 - i;
        xy [4] = ob_x + 1 + i;
        xy [5] = ob_y + ob_h - 2 - i;
        v_pline (vdi_handle, 3, xy);
      } /* for */
    } /* else */

    xy [0] = 1;
    xy [1] = 1;
    xy [2] = ob_w - 2;
    xy [3] = ob_h - 2;
    xy [4] = ob_x + xy [0];
    xy [5] = ob_y + xy [1];
    xy [6] = ob_x + xy [2];
    xy [7] = ob_y + xy [3];

    if (selected)
    {
      if (noselected)
      {
        xy [0]++;
        xy [1]++;
        xy [2] -= 3;
        xy [3] -= 3;
        xy [4] += 2;
        xy [5] += 2;
        xy [6] -= 2;
        xy [7] -= 2;
      } /* if */
      else
      {
        xy [2] -= 2;
        xy [3] -= 2;
        xy [4]++;
        xy [5]++;
        xy [6]--;
        xy [7]--;
      } /* else */
    } /* if */

    if (rasterbuf != NULL)
      vro_cpyfm (vdi_handle, S_ONLY, xy, &s, &d);
  } /* else */

  set_clip (TRUE, &save_clip);

#if MSDOS
  fardr_end (state);
#endif

  return (state);
} /* draw_bmbutton */

/*****************************************************************************/

#define fd_addr     mp
#define fd_w        fwp
#define fd_h        fh
#define fd_wdwidth  fww
#define fd_stand    ff
#define fd_nplanes  np
#define xvdi_handle vdi_handle

/*****************************************************************************/
/* Icon ins gerÑteabhÑngige Format wandeln und ggf an andere Auflîsungen     */
/* anpassen                                                                  */
/*****************************************************************************/

LOCAL WORD xadd_cicon (CICONBLK *cicnblk, OBJECT *obj, WORD nub)

{	WORD     x, y, line, xmax, best_planes, find_planes;
	CICON    *cicn, *color_icn, *best_icn = NULL;
  LONG     len, *next;
  MFDB     d;
#if SAVE_MEMORY == TRUE
	CICON    *max_icn = NULL;
#endif

	len = cicnblk->monoblk.ib_wicon / 8 * cicnblk->monoblk.ib_hicon;

	color_icn = &cicon_table[nub];

	best_planes = 1;
	if (xscrn_planes > 8)
		find_planes = 4;
	else
		find_planes = xscrn_planes;

	cicn = cicnblk->mainlist;
	next = (LONG *)&cicnblk->mainlist;

	while (cicn != NULL)
	{
		*next = (LONG)cicn;
		next = (LONG *)&cicn->next_res;

#if SAVE_MEMORY == TRUE
		if (cicn->num_planes > xscrn_planes)
			max_icn = cicn;
#endif
		if (cicn->num_planes >= best_planes && cicn->num_planes <= find_planes)
		{
			best_planes = cicn->num_planes;
			best_icn = cicn;
		}
		cicn = cicn->next_res;
	}
	
	if (best_icn == NULL)		/* kein passendes Farbicon gefunden */
		return (FALSE);
	else
		*color_icn = *best_icn;

	if (best_planes > 1)
		color_icn->num_planes = xscrn_planes;
	else
		color_icn->num_planes = 1;
	
	/* Platz fÅr das gerÑteabhÑngige Format allozieren */
	if ((color_icn->col_data = malloc (len * color_icn->num_planes)) == NULL)
		return (FALSE);
	if (color_icn->sel_data)
	{
		if ((color_icn->sel_data = malloc (len * color_icn->num_planes)) == NULL)
		{
			free (color_icn->col_data);
			return (FALSE);
		}
	}
	
	if (best_planes > 1)
	{	if (best_icn->sel_data == NULL)
		{
			/* Selected-Maske vorbereiten */
			if ((color_icn->sel_mask = malloc (len)) == NULL)
			{
				free (color_icn->col_data);
				if (color_icn->sel_data)
					free (color_icn->sel_data);
				return (FALSE);
			}
	
			xmax = cicnblk->monoblk.ib_wicon / 16;
	
			for (y = 0; y < cicnblk->monoblk.ib_hicon; y++)
			{
				line = y * xmax;
	
				for (x = 0; x < xmax; x++)
				{
					if (y & 1)
						color_icn->sel_mask[line + x] = best_icn->col_mask[line + x] & 0xaaaa;
					else
						color_icn->sel_mask[line + x] = best_icn->col_mask[line + x] & 0x5555;
				}
			}
		}
		
		d.fd_addr    = color_icn->col_data;
		d.fd_w       = cicnblk->monoblk.ib_wicon;
		d.fd_h       = cicnblk->monoblk.ib_hicon;
		d.fd_wdwidth = d.fd_w >> 4;
		d.fd_stand   = TRUE;
		d.fd_nplanes = xscrn_planes;
	
		xfix_cicon ((UWORD *)best_icn->col_data, len, best_planes, xscrn_planes, &d);
		if (best_icn->sel_data)
		{	d.fd_addr = color_icn->sel_data;
			xfix_cicon ((UWORD *)best_icn->sel_data, len, best_planes, xscrn_planes, &d);
		}
	}
	else
	{
		memcpy (color_icn->col_data, best_icn->col_data, len);
		memcpy (color_icn->sel_data, best_icn->sel_data, len);
	}

#if SAVE_MEMORY == TRUE
	if (best_icn->num_planes < color_icn->num_planes && max_icn != NULL)
	{	if (best_icn->sel_data == NULL || max_icn->sel_data != NULL)
		{
			best_icn->col_data = max_icn->col_data;
			best_icn->sel_data = max_icn->sel_data;
			best_icn->num_planes = xscrn_planes;
		}
	}
	
	if (best_icn->num_planes == color_icn->num_planes)
	{
		memcpy (best_icn->col_data, color_icn->col_data, len * color_icn->num_planes);
		free (color_icn->col_data);
		color_icn->col_data = NULL;
		if (best_icn->sel_data != NULL)
		{	memcpy (best_icn->sel_data, color_icn->sel_data, len * color_icn->num_planes);
			free (color_icn->sel_data);
			color_icn->sel_data = NULL;
		}
		else
		{	memcpy (cicnblk->monoblk.ib_pmask, color_icn->sel_mask, len);
			best_icn->sel_mask = cicnblk->monoblk.ib_pmask;
			free (color_icn->sel_mask);
			color_icn->sel_mask = NULL;
		}
	}
	else
	{
		if (best_icn->sel_data == NULL)
		{
			memcpy (cicnblk->monoblk.ib_pmask, color_icn->sel_mask, len);
			free (color_icn->sel_mask);
			color_icn->sel_mask = NULL;
			best_icn->col_data = color_icn->col_data;
			best_icn->sel_mask = cicnblk->monoblk.ib_pmask;
			best_icn->num_planes = color_icn->num_planes;
		}
		else
			*best_icn = *color_icn;
	}
	cicnblk->mainlist = best_icn;
#else
	color_icn->next_res = cicnblk->mainlist;
	cicnblk->mainlist = color_icn;
#endif
	obblk[nub].old_type = G_CICON;
	obblk[nub].ublk.ub_parm = obj->ob_spec/*.index*/;
	obblk[nub].ublk.ub_code = xdraw_cicon;
	obj->ob_spec/*.index*/ = (LONG)&obblk[nub].ublk;
	obj->ob_type = (obj->ob_type & 0xff00) | G_USERDEF;
	
	return (TRUE);
}

/*****************************************************************************/
/* Unter TrueColor Pixelwerte der RGB-Palette ermitteln                      */
/*****************************************************************************/

LOCAL VOID xfill_farbtbl ()

{	WORD np, color, pxy[8], backup[32], rgb[3];
	MFDB screen;
	MFDB pixel = {NULL, 16, 1, 1, 0, 1, 0, 0, 0};
	MFDB stdfm = {NULL, 16, 1, 1, 1, 1, 0, 0, 0};
	WORD pixtbl[16] = {0, 2, 3, 6, 4, 7, 5, 8, 9, 10, 11, 14, 12, 15, 13, 16};
	
	if (xscrn_planes >= 8)
	{
		if (xscrn_planes > 8)
		{
			if (is_palette == FALSE)	/* Keine Palette in der Resource */
			{
				for (color = 0; color < 255; color++)
				{	if (color < 16)
					{	vq_color (xvdi_handle, pixtbl[color], 1, rgb_palette[color]);
						rgb_palette[color][3] = pixtbl[color];
					}
					else
					{	vq_color (xvdi_handle, color + 1, 1, rgb_palette[color]);
						rgb_palette[color][3] = color + 1;
					}
				}
				vq_color (xvdi_handle, 1, 1, rgb_palette[255]);
				rgb_palette[255][3] = 1;
				is_palette = TRUE;
			}
			
			vs_clip (xvdi_handle, FALSE, pxy);
			graf_mouse (M_OFF, NULL);

			memset (backup, 0, sizeof (backup));
	 		memset (farbtbl, 0, 32 * 256 * sizeof (WORD));
			screen.fd_addr = NULL;
			stdfm.fd_nplanes = pixel.fd_nplanes = xscrn_planes;
		
			vswr_mode (xvdi_handle, MD_REPLACE);
			vsl_ends (xvdi_handle, 0, 0);
			vsl_type (xvdi_handle, 1);
			vsl_width (xvdi_handle, 1);
			memset (pxy, 0, sizeof (pxy));
			
			pixel.fd_addr = backup;	/* Punkt retten */
			vro_cpyfm (xvdi_handle, S_ONLY, pxy, &screen, &pixel);
		
			/* Alte Farbe retten */
			vq_color (xvdi_handle, 15, 1, rgb);

			for (color = 0; color < 256; color++)
			{
				vs_color (xvdi_handle, 15, rgb_palette[color]);
				vsl_color (xvdi_handle, 15);
				v_pline (xvdi_handle, 2, pxy);
				
				stdfm.fd_addr = pixel.fd_addr = farbtbl[color];
		
				/* vro_cpyfm, weil v_get_pixel nicht mit TrueColor (>=24 Planes) funktioniert */
				vro_cpyfm (xvdi_handle, S_ONLY, pxy, &screen, &pixel);
	
				if (farbtbl2 != NULL && xpixelbytes)
				{	farbtbl2[color] = 0L;
					memcpy (&farbtbl2[color], pixel.fd_addr, xpixelbytes);
				}
					
				vr_trnfm (xvdi_handle, &pixel, &stdfm);
				for (np = 0; np < xscrn_planes; np++)
					if (farbtbl[color][np])
						farbtbl[color][np] = 0xffff;
			}
		
			/* Alte Farbe restaurieren */
			vs_color (xvdi_handle, 15, rgb);

			pixel.fd_addr = backup;	/* Punkt restaurieren */
			vro_cpyfm (xvdi_handle, S_ONLY, pxy, &pixel, &screen);
		
			graf_mouse (M_ON, NULL);
		}
		else
		{	if (farbtbl2 != NULL && xpixelbytes)
				for (color = 0; color < 256; color++)
					*(UBYTE *)&farbtbl2[color] = color;
		}
	}
}

/*****************************************************************************/
/* Testen wieviel Bytes pro Pixel im gerÑteabhÑngigen Format verwendet werden*/
/*****************************************************************************/

LOCAL WORD test_rez ()

{	WORD     i, np, color, pxy[8], rgb[3], bpp = 0;
	UWORD    backup[32], test[32];
	WORD     black[3] = {0, 0, 0};
	WORD     white[3] = {1000, 1000, 1000};
	MFDB     screen;
	MFDB     pixel = {NULL, 16, 1, 1, 0, 1, 0, 0, 0};
	MFDB     stdfm = {NULL, 16, 1, 1, 1, 1, 0, 0, 0};

	if (xscrn_planes >= 8)
	{
		stdfm.fd_nplanes = pixel.fd_nplanes = xscrn_planes;

		if (xscrn_planes == 8)
		{
			color = 0xff;
			memset (test, 0, xscrn_planes * sizeof (WORD));
			for (np = 0; np < xscrn_planes; np++)
				test[np] = (color & (1 << np)) << (15 - np);
	
			pixel.fd_addr = stdfm.fd_addr = test;
			vr_trnfm (xvdi_handle, &stdfm, &pixel);
			
			for (i = 1; i < xscrn_planes; i++)
				if (test[i])	break;
			
			if (i >= xscrn_planes && !(test[0] & 0x00ff))
				bpp = 1;
		}
		else
		{
			vs_clip (xvdi_handle, FALSE, pxy);
			screen.fd_addr = NULL;
			
			memset (backup, 0, sizeof (backup));
		
			vswr_mode (xvdi_handle, MD_REPLACE);
			vsl_ends (xvdi_handle, 0, 0);
			vsl_type (xvdi_handle, 1);
			vsl_width (xvdi_handle, 1);
			memset (pxy, 0, sizeof (pxy));
			
			graf_mouse (M_OFF, NULL);
		
			pixel.fd_addr = backup;	/* Punkt retten */
			vro_cpyfm (xvdi_handle, S_ONLY, pxy, &screen, &pixel);
		
			/* Alte Farbe retten */
			vq_color (xvdi_handle, 15, 1, rgb);
	
			/* GerÑteabhÑngiges Format testen */
			pixel.fd_addr = test;
			vsl_color (xvdi_handle, 15);
			vs_color (xvdi_handle, 15, white);
			v_pline (xvdi_handle, 2, pxy);
			
			memset (test, 0, xscrn_planes * sizeof (WORD));
			vro_cpyfm (xvdi_handle, S_ONLY, pxy, &screen, &pixel);
			
			for (i = (xscrn_planes + 15) / 16 * 2; i < xscrn_planes; i++)
				if (test[i])	break;
			
			if (i >= xscrn_planes)
			{
				vs_color (xvdi_handle, 15, black);
				v_pline (xvdi_handle, 2, pxy);
				
				memset (test, 0, xscrn_planes * sizeof (WORD));
				vro_cpyfm (xvdi_handle, S_ONLY, pxy, &screen, &pixel);
				
				for (i = (xscrn_planes + 15) / 16 * 2; i < xscrn_planes; i++)
					if (test[i])	break;
				
				if (i >= xscrn_planes)
					bpp = (xscrn_planes + 7) / 8;
			}

			/* Alte Farbe restaurieren */
			vs_color (xvdi_handle, 15, rgb);
	
			pixel.fd_addr = backup;	/* Punkt restaurieren */
			vro_cpyfm (xvdi_handle, S_ONLY, pxy, &pixel, &screen);
		
			graf_mouse (M_ON, NULL);
	
			vs_clip (xvdi_handle, TRUE, pxy);
		}
	}

	return (bpp);
}

/*****************************************************************************/
/* Icon an aktuelle Grafikauflîsung anpassen                                 */
/* (z.B. 4 Plane Icon an 24 Plane TrueColor)                                 */
/*****************************************************************************/

LOCAL VOID xfix_cicon (UWORD *col_data, LONG len, WORD old_planes, WORD new_planes, MFDB *s)

{	LONG  x, i, old_len, rest_len, mul[32], pos;
	UWORD np, *new_data, mask, pixel, bit, color, back[32], old_col[32], maxcol;
	WORD  got_mem = FALSE;
	MFDB  d;
	
	len >>= 1;

	if (old_planes == new_planes)
	{	if (s != NULL)
		{	if (new_planes == xscrn_planes)
			{
				d = *s;
				d.fd_stand = FALSE;
				s->fd_addr = col_data;
				if (d.fd_addr == s->fd_addr)
				{	if ((d.fd_addr = malloc (len * 2 * new_planes)) == NULL)
						d.fd_addr = s->fd_addr;
					else
						got_mem = TRUE;
				}
				
				vr_trnfm (xvdi_handle, s, &d);
				if (d.fd_addr != s->fd_addr && got_mem == TRUE)
				{
					memcpy (s->fd_addr, d.fd_addr, len * 2 * new_planes);
					free (d.fd_addr);
				}
			}
			else
				memcpy (s->fd_addr, col_data, len * 2 * new_planes);
		}
		return;
	}
	
	if (new_planes <= 8)
	{
		old_len  = old_planes * len;
		rest_len = new_planes * len - old_len;

		if (s != NULL)
		{
			new_data = &((UWORD *)s->fd_addr)[old_len];
			memset (new_data, 0, rest_len * 2);
			memcpy (s->fd_addr, col_data, old_len * 2);
			col_data = s->fd_addr;
		}
		else
			new_data = (UWORD *)&col_data[old_len];
		
		for (x = 0; x < len; x++)
		{
			mask = 0xffff;
	
			for (i = 0; i < old_len; i += len)
				mask &= (UWORD)col_data[x+i];
			
			if (mask)
				for (i = 0; i < rest_len; i += len)
					new_data[x+i] |= mask;
		}

		if (s != NULL)	/* ins gerÑteabhÑngige Format konvertieren */
		{
			d = *s;
			d.fd_stand = 0;
			if ((d.fd_addr = malloc (len * 2 * new_planes)) == NULL)
				d.fd_addr = s->fd_addr;
			
			vr_trnfm (xvdi_handle, s, &d);
			if (d.fd_addr != s->fd_addr)
			{
				memcpy (s->fd_addr, d.fd_addr, len * 2 * new_planes);
				free (d.fd_addr);
			}
		}
	}
	else	/* TrueColor, bzw RGB-orientierte Pixelwerte */
	{
		if (!xpixelbytes || s == NULL)
		{
			for (i = 0; i < new_planes; i++)
				mul[i] = i * len;
			
			if (old_planes < 8)
			{
				maxcol = (1 << old_planes) - 1;
				memcpy (old_col, farbtbl[maxcol], new_planes * sizeof (WORD));
				memset (farbtbl[maxcol], 0, new_planes * sizeof (WORD));
			}
	
			if (s != NULL)
			{
				new_data = &((UWORD *)s->fd_addr)[old_len];
				memset (new_data, 0, rest_len * 2);
				memcpy (s->fd_addr, col_data, old_len * 2);
				col_data = s->fd_addr;
			}
			
			for (x = 0; x < len; x++)
			{
				bit = 1;
				for (np = 0; np < old_planes; np++)
					back[np] = col_data[mul[np] + x];
				
				for (pixel = 0; pixel < 16; pixel++)
				{
					color = 0;
					for (np = 0; np < old_planes; np++)
					{
						color += ((back[np] & 1) << np);
						back[np] >>= 1;
					}
					
					for (np = 0; np < new_planes; np++)
					{	pos = mul[np] + x;
						col_data[pos] = (col_data[pos] & ~bit) | (farbtbl[color][np] & bit);
					}
					
					bit <<= 1;
				}
			}
			if (old_planes < 8)
				memcpy (farbtbl[maxcol], old_col, new_planes * sizeof (WORD));

			if (s != NULL)	/* ins gerÑteabhÑngige Format konvertieren */
			{
				d = *s;
				d.fd_stand = 0;
				if ((d.fd_addr = malloc (len * 2 * new_planes)) == NULL)
					d.fd_addr = s->fd_addr;
				
				vr_trnfm (xvdi_handle, s, &d);
				if (d.fd_addr != s->fd_addr)
				{
					memcpy (s->fd_addr, d.fd_addr, len * 2 * new_planes);
					free (d.fd_addr);
				}
			}
		}
		else
			std_to_byte (col_data, len, old_planes, farbtbl2, s);
	}
}

/*****************************************************************************/
/* std_to_byte wandelt eine Grafik im Standardformat direkt ins gerÑte-      */
/* abhÑngige Format (in Auflîsungen mit >= 16 Planes)                        */
/*****************************************************************************/

LOCAL VOID std_to_byte (col_data, len, old_planes, farbtbl2, s)
UWORD *col_data;
LONG  len;
WORD  old_planes;
ULONG *farbtbl2;
MFDB  *s;

{	LONG  x, i, mul[32], pos;
	UWORD np, *new_data, pixel, color, back[32];
	WORD  memflag = FALSE;
	UBYTE *p1, *p2;
	ULONG  colback;

	if (s->fd_addr == col_data)
	{
		if ((col_data = malloc (len * 2 * s->fd_nplanes)) == NULL)
			return;
		memcpy (col_data, s->fd_addr, len * 2 * s->fd_nplanes);
		memflag = TRUE;
	}
	new_data = (UWORD *)s->fd_addr;
	p1 = (UBYTE *)new_data;

	if (old_planes < 8)
	{
		colback = farbtbl2[(1 << old_planes) - 1];
		farbtbl2[(1 << old_planes) - 1] = farbtbl2[255];
	}
		
	for (i = 0; i < old_planes; i++)
		mul[i] = i * len;
	
	pos = 0;
	
	for (x = 0; x < len; x++)
	{
		for (np = 0; np < old_planes; np++)
			back[np] = col_data[mul[np] + x];
		
		for (pixel = 0; pixel < 16; pixel++)
		{
			color = 0;
			for (np = 0; np < old_planes; np++)
			{
				color |= ((back[np] & 0x8000) >> (15 - np));
				back[np] <<= 1;
			}
			
			switch (xpixelbytes)
			{
				case 2:
					new_data[pos++] = *(UWORD *)&farbtbl2[color];
					break;

				case 3:
					p2 = (UBYTE *)&farbtbl2[color];
					*(p1++) = *(p2++);
					*(p1++) = *(p2++);
					*(p1++) = *(p2++);
					break;

				case 4:
					((ULONG *)new_data)[pos++] = farbtbl2[color];
					break;
			}
		}
	}

	if (old_planes < 8)
		farbtbl2[(1 << old_planes) - 1] = colback;

	if (memflag)
		free (col_data);
}

/*****************************************************************************/
/* Zeichnet Farb-Icon                                                        */
/*****************************************************************************/

LOCAL WORD CDECL xdraw_cicon (PARMBLK *pb)

{	WORD	 	ob_x, ob_y, x, y, dummy, pxy[4], m_mode, i_mode, mskcol, icncol;
	LONG	 	ob_spec;
	ICONBLK *iconblk;
	CICON   *cicn;
	WORD    *mask, *data, *dark = NULL;
	BYTE    letter[2];
	WORD    selected, mindex[2], iindex[2], buf, xy[4];
	BOOLEAN invert = FALSE;
	
	selected = pb->pb_currstate & SELECTED;
	
	xrect2array ((GRECT *)&pb->pb_xc, xy);
	vs_clip (xvdi_handle, TRUE, xy);   /* Setze Rechteckausschnitt */

	ob_spec	= pb->pb_parm;
	ob_x		= pb->pb_x;
	ob_y		= pb->pb_y;

	iconblk = (ICONBLK *)ob_spec;
	cicn    = ((CICONBLK *)ob_spec)->mainlist;
	m_mode  = MD_TRANS;

	if (selected) /* it was an objc_change */
	{
		if (cicn->sel_data != NULL)
		{
			mask = cicn->sel_mask;
			data = cicn->sel_data;
			if (cicn->num_planes > 1)
			{	if (cicn->num_planes > 8)	/* TrueColor, bzw RGB-orientierte Grafikkarte? */
					i_mode = S_AND_D;
				else
					i_mode = S_OR_D;
			}
			else
				i_mode = MD_TRANS;
		}
		else
		{
			mask = cicn->col_mask;
			data = cicn->col_data;

			if (cicn->num_planes > 1)
			{	if (cicn->num_planes > 8)
					i_mode = S_AND_D;
				else
					i_mode = S_OR_D;
				dark = cicn->sel_mask;
			}
			else
				invert = TRUE;
		}
	}
	else
	{
		mask = cicn->col_mask;
		data = cicn->col_data;
	
		if (cicn->num_planes > 1)
		{	if (cicn->num_planes > 8)
				i_mode = S_AND_D;
			else
				i_mode = S_OR_D;
		}
		else
			i_mode = MD_TRANS;
	}
	
	mindex [0] = ((iconblk->ib_char & 0x0f00) != 0x0100) ? (iconblk->ib_char & 0x0f00) >> 8 : WHITE;
	mindex [1] = WHITE;
	
	icncol = iindex[0] = (WORD)(((UWORD)iconblk->ib_char & 0xf000U) >> 12U);
	iindex[1] = WHITE;

	mskcol = (iconblk->ib_char & 0x0f00) >> 8;

	x = ob_x + iconblk->ib_xicon;
	y = ob_y + iconblk->ib_yicon;

	if (invert)
	{
		buf       = iindex[0];
		iindex[0] = mindex[0];
		mindex[0] = buf;
		i_mode    = MD_TRANS;
	}
	if (selected)
	{
		buf    = icncol;
		icncol = mskcol;
		mskcol = buf;
	}
	
	draw_bitblk (mask, x, y, iconblk->ib_wicon, iconblk->ib_hicon, 1, m_mode, mindex);
	draw_bitblk (data, x, y, iconblk->ib_wicon, iconblk->ib_hicon, cicn->num_planes, i_mode, iindex);
	
	if (dark)
	{
		mindex [0] = BLACK;
		mindex [1] = WHITE;
		draw_bitblk (dark, x, y, iconblk->ib_wicon, iconblk->ib_hicon, 1, MD_TRANS, mindex);
	}

	if (iconblk->ib_ptext[0])
	{
		x = ob_x + iconblk->ib_xtext;
		y = ob_y + iconblk->ib_ytext;
		
		pxy[0] = x;
		pxy[1] = y;
		pxy[2] = x + iconblk->ib_wtext - 1;
		pxy[3] = y + iconblk->ib_htext - 1;
		
		vswr_mode     (xvdi_handle, MD_REPLACE);		/* Textbox zeichnen */
		vsf_color     (xvdi_handle, mskcol);
		vsf_interior  (xvdi_handle, FIS_SOLID);
		vsf_perimeter (xvdi_handle, FALSE);
		v_bar         (xvdi_handle, pxy);
	}

	vswr_mode     (xvdi_handle, MD_TRANS);
  vst_font      (xvdi_handle, 1);	/* Systemfont */
	vst_height    (xvdi_handle, 4, &dummy, &dummy, &dummy, &dummy);
  vst_color     (xvdi_handle, icncol);
  vst_effects   (xvdi_handle, TXT_NORMAL);
  vst_alignment (xvdi_handle, ALI_LEFT, ALI_TOP, &dummy, &dummy);
  vst_rotation  (xvdi_handle, 0);
	
	if (iconblk->ib_ptext[0])
	{	x += (iconblk->ib_wtext - strlen (iconblk->ib_ptext) * 6) / 2;
		y += (iconblk->ib_htext - 6) / 2;
		
		v_gtext (xvdi_handle, x, y, iconblk->ib_ptext);
	}

	letter[0] = iconblk->ib_char & 0xff;
	if (letter[0])
	{
		letter[1] = '\0';
		x = ob_x + iconblk->ib_xicon + iconblk->ib_xchar;
		y = ob_y + iconblk->ib_yicon + iconblk->ib_ychar;
	
		v_gtext (xvdi_handle, x, y, letter);
	}
	
	return (pb->pb_currstate & ~ SELECTED);
} /* draw_userdef */

/*****************************************************************************/

LOCAL VOID draw_bitblk (WORD *p, WORD x, WORD y, WORD w, WORD h, WORD num_planes, WORD mode, WORD *index)

{	WORD	 	pxy[8];
	MFDB	 	s, d;

	d.fd_addr	   = NULL; /* screen */
	s.fd_addr    = (VOID *)p;
	s.fd_w       = w;
	s.fd_h       = h;
	s.fd_wdwidth = w >> 4;
	s.fd_stand   = FALSE;
	s.fd_nplanes = num_planes;

	pxy[0] = 0;
	pxy[1] = 0;
 	pxy[2] = s.fd_w - 1;
 	pxy[3] = s.fd_h - 1;

	pxy[4] = x;
	pxy[5] = y;
	pxy[6] = pxy[4] + pxy [2];
	pxy[7] = pxy[5] + pxy [3];

	if (num_planes > 1)
		vro_cpyfm (xvdi_handle, mode, pxy, &s, &d);
	else
		vrt_cpyfm (xvdi_handle, mode, pxy, &s, &d, index);	 /* copy it */
}

/*****************************************************************************/

LOCAL VOID xrect2array (CONST GRECT *rect, WORD *array)

{
  *array++ = rect->g_x;
  *array++ = rect->g_y;
  *array++ = rect->g_x + rect->g_w - 1;
  *array   = rect->g_y + rect->g_h - 1;
} /* xrect2array */

/*****************************************************************************/

