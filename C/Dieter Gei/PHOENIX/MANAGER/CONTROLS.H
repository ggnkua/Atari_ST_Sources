/*****************************************************************************
 *
 * Module : CONTROLS.H
 * Author : Dieter Geiž
 *
 * Creation date    : 10.08.93
 * Last modification: 23.10.95
 *
 *
 * Description: This module defines the custom controls.
 *
 * History:
 * 23.10.95: DrawImageButton added
 * 20.10.95: ListBoxDraw and ListBox_Draw added
 * 14.08.95: Parameters in function InitControls added
 * 01.01.95: ListBox_... functions added
 * 31.12.94: Function DrawComboBox added
 * 14.12.94: Scrollbar definitions added
 * 18.07.94: Parameters round and shadow_width in DrawButton added
 * 17.07.94: Parameter vdi_handle in Draw... functions added
 * 17.03.94: Functions DrawString and Draw3DBox added
 * 13.03.94: Functions DrawButton and DrawGroupBox added
 * 12.03.94: Function DrawCheckradio added
 * 01.11.93: ListboxSetTabstops added
 * 30.10.93: Listbox background color added
 * 16.10.93: Functions ListBoxSendMessage and draw_owner_multi_icon added
 * 07.10.93: Function draw_owner_color and draw_owner_dlg_pattern added
 * 05.09.93: Function draw_owner_check and draw_owner_arrow added
 * 02.09.93: Functions build_icon, free_icon, and draw_owner_icon added
 * 27.09.93: Functions build_image added
 * 20.09.93: Functions ListBoxGetCallback, ListBoxGetWindowHandle, and ListBoxGetFont added
 * 16.09.93: Function ListBoxClick returns LONG
 * 15.09.93: Function switch_tree_3d added
 * 11.09.93: ComboBox extensions for listboxes added
 * 09.09.93: Listbox definitions added
 * 25.08.93: Parameter is_dialog removed from fix_tree
 * 10.08.93: Creation of body
 *****************************************************************************/

#ifndef __CONTROLS__
#define __CONTROLS__

/****** DEFINES **************************************************************/

#define BS_BMBUTTON             0x8000  /* G_BUTTON state 15: bitmap button */
#define BS_GROUPBOX             0x4000  /* G_BUTTON state 14: group box */
#define BS_CHECKBOX             0x2000  /* G_BUTTON state 13: chechbox and radio button */
#define BS_FUNCTION             0x1000  /* G_BUTTON state 12: function key */
#define BS_COMBOBOX             0x0800  /* G_BUTTON state 11: static part of combo box */

#define SS_PROPFACE             0x8000  /* G_STRING state 15: proportional face string */
#define SS_RIGHT                0x4000  /* G_STRING state 14: right justified */
#define SS_CENTER               0x2000  /* G_STRING state 13: center justified */
#define SS_INSIDE               0x1000  /* G_STRING state 12: text inside */
#define SS_OUTSIDE              0x0800  /* G_STRING state 11: text outside */

#define XS_DLGBKGND             0x8000  /* G_BOX state 15: dialog background (gray if 3d look) */
#define XS_GRAYBKGND            0x4000  /* G_BOX state 14: gray background for non-dialogs (panels) */
#define XS_LISTBOX              0x2000  /* G_BOX state 13: listbox */
#define XS_SCROLLBAR		        0x1000	/* G_BOX state 12: scrollbar */

#define IS_3DBOX                0x8000  /* G_IBOX state 15: 3d box */
#define IS_BORDER               0x4000  /* G_IBOX state 14: black border around 3d box */
#define IS_ROUNDBORDER          0x2000  /* G_IBOX state 13: round border around object */
#define IS_INSIDE               0x1000  /* G_IBOX state 12: box inside */
#define IS_OUTSIDE              0x0800  /* G_IBOX state 11: box outside */
#define IS_DOUBLELINE           0x0400  /* G_IBOX state 10: double 3d line for iconbars */

#define LBS_VSCROLL		          0x0001	/* vertical slider */
#define LBS_VREALTIME           0x0002	/* realtime vertical slider */
#define LBS_MULTIPLESEL		      0x0004	/* multiple selection */
#define LBS_DRAWDISABLED	      0x0008	/* draw strings as disabled */
#define LBS_TOUCHEXIT		        0x0010	/* listbox is touchexit */
#define LBS_SELECTABLE		      0x0020	/* listbox is selectable */
#define LBS_DISABLED		        0x0040	/* listbox is disabled */
#define LBS_SELECTED		        0x0080  /* static part of combobox is selected */
#define LBS_OWNERDRAW		        0x0100	/* owner draws items */
#define LBS_USECHECKED		      0x0200	/* use CHECKED drawing for selected items */
#define LBS_MANDATORY		        0x0400	/* there muste be a selected item */
#define LBS_NO3DBORDER		      0x0800	/* no 3d border*/
#define LBS_COMBOTEXTREDRAW	    0x1000	/* redraw combo text only */
#define LBS_NOSTANDARDKEYBOARD	0x2000	/* no standard keyboard input */

#define LBN_GETITEM		               0	/* listbox notification: get item */
#define LBN_DRAWITEM		             1	/* listbox notification: draw item */
#define LBN_SELCHANGE		             2	/* listbox notification: selection changed */
#define LBN_DBLCLK		               3	/* listbox notification: double clicked */
#define LBN_SETFOCUS		             4	/* listbox notification: got focus */
#define LBN_KILLFOCUS		             5	/* listbox notification: lost focus */
#define LBN_KEYPRESSED		           6	/* listbox notification: user has pressed a key */

#define LBT_MAX_TABS		            64	/* max listbox tabs */
#define LBT_LEFT		                 0	/* listbox tab style: left justified */
#define LBT_CENTER		               1	/* listbox tab style: center justified */
#define LBT_RIGHT		                 2	/* listbox tab style: right justified */

#define SBS_VERTICAL		        0x0000	/* vertical scroll bar */
#define SBS_HORIZONTAL		      0x0001	/* horizontal scroll bar */
#define SBS_REALTIME		        0x0002	/* real time scrolling */
#define SBS_DISABLED		        0x0004	/* slider is disabled */
#define SBS_NO3DBORDER		      0x0008	/* no 3d border */

#define SBN_CHANGED		               0	/* scroll position has changed */

#define IBS_DISABLED		        0x0001	/* image button is disabled */
#define IBS_SELECTED		        0x0002  /* image button is selected */

#define DIB_DOWNARROW		             0	/* down arrow button */
#define DIB_DOTS		                 1	/* three dots */

/****** TYPES ****************************************************************/

typedef LONG (* LB_CALLBACK) (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p);
typedef LONG (* SB_CALLBACK) (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p);

typedef struct
{
  RECT    rc_item;			/* item rectangle */
  RECT    rc_clip;			/* clipping rectange */
  UWORD   style;			/* style of listbox */
  BOOLEAN selected;			/* draw as selected */
  WORD    font;				/* font of text */
  WORD    point;			/* size of text */
  UWORD   effects;			/* effects of text */
  WORD    color;			/* color of text */
  WORD    bk_color;			/* background color */
  WORD    num_tabs;			/* number of tabs (columns) */
  WORD    *tabs;			/* tab values */
  WORD    *tabstyles;			/* tab styles */
} LB_OWNERDRAW;

typedef VOID *HLB;			/* handle to listbox */
typedef VOID *HSB;			/* handle to scrollbar */

typedef struct
{
  UBYTE *di_buffer;			/* device independent buffer */
  UBYTE *dd_buffer;			/* device dependent buffer */
} IMG_BUF;

typedef struct
{
  BYTE    *name;			/* name of bitmap */
  WORD    width;			/* width of bitmap */
  WORD    height;			/* height of bitmap */
  IMG_BUF n1;				/* normal 1 planed bitmap */
  IMG_BUF s1;				/* selected 1 planed bitmap */
  IMG_BUF d1;				/* disabled 1 planed bitmap */
  IMG_BUF n4;				/* normal 4 planed bitmap */
  IMG_BUF s4;				/* selected 4 planed bitmap */
  IMG_BUF d4;				/* disabled 4 planed bitmap */
} BMBUTTON;

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL BOOLEAN     InitControls              (WORD wMaxUserBlk, WORD wMaxColorIcon, WORD wMaxBitmapButton, BMBUTTON *pBitmapButton);
GLOBAL BOOLEAN     TermControls              (VOID);

GLOBAL VOID        FixTree                   (OBJECT *tree);
GLOBAL VOID        SwitchTree3D              (OBJECT *tree);

GLOBAL UBYTE       *BuildImg                 (UBYTE *buffer, WORD *width, WORD *height, WORD *numplanes);
GLOBAL BOOLEAN     BuildIcon                 (ICON *icon, UBYTE *mask, UBYTE *data);
GLOBAL VOID        FreeIcon                  (ICON *icon);

GLOBAL VOID        DrawOwnerIcon             (LB_OWNERDRAW *lb_ownerdraw, RECT *img_rect, ICON *icon, BYTE *text, WORD text_offset);
GLOBAL VOID        DrawOwnerMultiIcon        (LB_OWNERDRAW *lb_ownerdraw, RECT *img_rect, ICON *icon, BYTE *text, WORD text_offset, WORD rows, WORD cols, WORD row, WORD col);
GLOBAL VOID        DrawOwnerColor            (LB_OWNERDRAW *lb_ownerdraw, RECT *img_rect, WORD color, BYTE *text, WORD text_offset);
GLOBAL VOID        DrawOwnerDlgPattern       (LB_OWNERDRAW *lb_ownerdraw, WORD color, WORD pattern);
GLOBAL VOID        DrawOwnerCheck            (LB_OWNERDRAW *lb_ownerdraw, RECT *img_rect, BOOLEAN radio, WORD index, BYTE *text, WORD text_offset);
GLOBAL VOID        DrawOwnerArrow            (LB_OWNERDRAW *lb_ownerdraw, RECT *img_rect, WORD index, BYTE *text, WORD text_offset);

GLOBAL VOID        DrawButton                (WORD vdi_handle, RECT *rc, RECT *rc_clip, BYTE *text, WORD acc_inx, WORD state, WORD bk_color, FONTDESC *fontdesc, BOOLEAN def, BOOLEAN round, WORD shadow_width);
GLOBAL VOID        DrawCheckRadio            (WORD vdi_handle, RECT *rc, RECT *rc_clip, BYTE *text, WORD acc_inx, WORD state, WORD bk_color, FONTDESC *fontdesc, BOOLEAN radio);
GLOBAL VOID        DrawGroupBox              (WORD vdi_handle, RECT *rc, RECT *rc_clip, BYTE *text, WORD acc_inx, WORD state, WORD bk_color, FONTDESC *fontdesc);
GLOBAL VOID        DrawString                (WORD vdi_handle, RECT *rc, RECT *rc_clip, BYTE *text, WORD acc_inx, WORD state, WORD bk_color, FONTDESC *fontdesc);
GLOBAL VOID        Draw3DBox                 (WORD vdi_handle, RECT *rc, RECT *rc_clip, WORD state, WORD border);
GLOBAL VOID        DrawComboBox              (WORD vdi_handle, RECT *rc, RECT *rc_clip, BYTE *text, WORD style, WORD bk_color, FONTDESC *fontdesc, WORD left_offset, WORD button_width, WORD num_tabs, WORD *tabs, WORD *tabstyles);
GLOBAL VOID        DrawListBox               (WORD vdi_handle, RECT *rc, RECT *rc_clip, HLB hlb);
GLOBAL VOID        DrawScrollBar             (WORD vdi_handle, RECT *rc, RECT *rc_clip, HSB hsb);
GLOBAL VOID        DrawImageButton           (WORD vdi_handle, RECT *rc, RECT *rc_clip, WORD style, WORD image);

GLOBAL VOID        ListBoxRedraw             (OBJECT *tree, WORD obj);
GLOBAL VOID        ListBoxDraw               (OBJECT *tree, WORD obj, RECT *rc_clip);
GLOBAL LONG        ListBoxClick              (OBJECT *tree, WORD obj, MKINFO *mk);
GLOBAL VOID        ListBoxKey                (OBJECT *tree, WORD obj, MKINFO *mk);
GLOBAL LONG        ListBoxSendMessage        (OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p);
GLOBAL LB_CALLBACK ListBoxGetCallback        (OBJECT *tree, WORD obj);
GLOBAL VOID        ListBoxSetCallback        (OBJECT *tree, WORD obj, LB_CALLBACK callback);
GLOBAL WORD        ListBoxGetWindowHandle    (OBJECT *tree, WORD obj);
GLOBAL VOID        ListBoxSetWindowHandle    (OBJECT *tree, WORD obj, WORD wh);
GLOBAL VOID        ListBoxGetFont            (OBJECT *tree, WORD obj, WORD *font, WORD *point, UWORD *effects, WORD *color, WORD *bk_color);
GLOBAL VOID        ListBoxSetFont            (OBJECT *tree, WORD obj, WORD font, WORD point, UWORD effects, WORD color, WORD bk_color);
GLOBAL VOID        ListBoxSetFocus           (OBJECT *tree, WORD obj);
GLOBAL VOID        ListBoxKillFocus          (OBJECT *tree, WORD obj);
GLOBAL UWORD       ListBoxGetStyle           (OBJECT *tree, WORD obj);
GLOBAL VOID        ListBoxSetStyle           (OBJECT *tree, WORD obj, UWORD style, BOOLEAN on);
GLOBAL LONG        ListBoxGetCount           (OBJECT *tree, WORD obj);
GLOBAL VOID        ListBoxSetCount           (OBJECT *tree, WORD obj, LONG count, BYTE **strings);
GLOBAL WORD        ListBoxGetTextLen         (OBJECT *tree, WORD obj, LONG index);
GLOBAL WORD        ListBoxGetText            (OBJECT *tree, WORD obj, LONG index, BYTE *string);
GLOBAL LONG        ListBoxFindString         (OBJECT *tree, WORD obj, LONG index_start, BYTE *find);
GLOBAL LONG        ListBoxFindStringExact    (OBJECT *tree, WORD obj, LONG index_start, BYTE *find);
GLOBAL VOID        ListBoxSetSel             (OBJECT *tree, WORD obj, BOOLEAN select, LONG index);
GLOBAL VOID        ListBoxSelItemRange       (OBJECT *tree, WORD obj, BOOLEAN select, LONG first, LONG last);
GLOBAL LONG        ListBoxGetCurSel          (OBJECT *tree, WORD obj);
GLOBAL VOID        ListBoxSetCurSel          (OBJECT *tree, WORD obj, LONG index);
GLOBAL VOID        ListBoxSelectString       (OBJECT *tree, WORD obj, LONG index_start, BYTE *find);
GLOBAL BOOLEAN     ListBoxGetSel             (OBJECT *tree, WORD obj, LONG index);
GLOBAL LONG        ListBoxGetSelCount        (OBJECT *tree, WORD obj);
GLOBAL VOID        ListBoxGetSelItems        (OBJECT *tree, WORD obj, SET set);
GLOBAL WORD        ListBoxGetTabstops        (OBJECT *tree, WORD obj, WORD *tabs, WORD *tab_styles);
GLOBAL BOOLEAN     ListBoxSetTabstops        (OBJECT *tree, WORD obj, WORD num_tabs, WORD *tabs, WORD *tab_styles);
GLOBAL LONG        ListBoxGetTopIndex        (OBJECT *tree, WORD obj);
GLOBAL VOID        ListBoxSetTopIndex        (OBJECT *tree, WORD obj, LONG index);
GLOBAL WORD        ListBoxGetItemHeight      (OBJECT *tree, WORD obj);
GLOBAL VOID        ListBoxSetItemHeight      (OBJECT *tree, WORD obj, WORD height);
GLOBAL WORD        ListBoxGetLeftOffset      (OBJECT *tree, WORD obj);
GLOBAL VOID        ListBoxSetLeftOffset      (OBJECT *tree, WORD obj, WORD offset);
GLOBAL LONG        ListBoxGetSpec            (OBJECT *tree, WORD obj);
GLOBAL VOID        ListBoxSetSpec            (OBJECT *tree, WORD obj, LONG spec);
GLOBAL VOID        ListBoxGetComboRect       (OBJECT *tree, WORD obj, RECT *rc, WORD *y);
GLOBAL VOID        ListBoxSetComboRect       (OBJECT *tree, WORD obj, RECT *rc, WORD y);
GLOBAL LONG        ListBoxComboClick         (OBJECT *tree, WORD obj, MKINFO *mk);

GLOBAL HLB         ListBox_Create            (UWORD style, RECT *rc, LONG count);
GLOBAL VOID        ListBox_Delete            (HLB hlb);
GLOBAL VOID        ListBox_Redraw            (HLB hlb);
GLOBAL VOID        ListBox_Draw              (HLB hlb, RECT *rc_clip);
GLOBAL LONG        ListBox_Click             (HLB hlb, MKINFO *mk);
GLOBAL VOID        ListBox_Key               (HLB hlb, MKINFO *mk);
GLOBAL LONG        ListBox_SendMessage       (HLB hlb, WORD msg, LONG item, VOID *p);
GLOBAL VOID        ListBox_GetRect           (HLB hlb, RECT *rc);
GLOBAL VOID        ListBox_SetRect           (HLB hlb, CONST RECT *rc, BOOLEAN redraw);
GLOBAL LB_CALLBACK ListBox_GetCallback       (HLB hlb);
GLOBAL VOID        ListBox_SetCallback       (HLB hlb, LB_CALLBACK callback);
GLOBAL WORD        ListBox_GetWindowHandle   (HLB hlb);
GLOBAL VOID        ListBox_SetWindowHandle   (HLB hlb, WORD wh);
GLOBAL VOID        ListBox_GetFont           (HLB hlb, WORD *font, WORD *point, UWORD *effects, WORD *color, WORD *bk_color);
GLOBAL VOID        ListBox_SetFont           (HLB hlb, WORD font, WORD point, UWORD effects, WORD color, WORD bk_color);
GLOBAL VOID        ListBox_SetFocus          (HLB hlb);
GLOBAL VOID        ListBox_KillFocus         (HLB hlb);
GLOBAL UWORD       ListBox_GetStyle          (HLB hlb);
GLOBAL VOID        ListBox_SetStyle          (HLB hlb, UWORD style, BOOLEAN on);
GLOBAL LONG        ListBox_GetCount          (HLB hlb);
GLOBAL VOID        ListBox_SetCount          (HLB hlb, LONG count, BYTE **strings);
GLOBAL WORD        ListBox_GetTextLen        (HLB hlb, LONG index);
GLOBAL WORD        ListBox_GetText           (HLB hlb, LONG index, BYTE *string);
GLOBAL LONG        ListBox_FindString        (HLB hlb, LONG index_start, BYTE *find);
GLOBAL LONG        ListBox_FindStringExact   (HLB hlb, LONG index_start, BYTE *find);
GLOBAL VOID        ListBox_SetSel            (HLB hlb, BOOLEAN select, LONG index);
GLOBAL VOID        ListBox_SelItemRange      (HLB hlb, BOOLEAN select, LONG first, LONG last);
GLOBAL LONG        ListBox_GetCurSel         (HLB hlb);
GLOBAL VOID        ListBox_SetCurSel         (HLB hlb, LONG index);
GLOBAL VOID        ListBox_SelectString      (HLB hlb, LONG index_start, BYTE *find);
GLOBAL BOOLEAN     ListBox_GetSel            (HLB hlb, LONG index);
GLOBAL LONG        ListBox_GetSelCount       (HLB hlb);
GLOBAL VOID        ListBox_GetSelItems       (HLB hlb, SET set);
GLOBAL WORD        ListBox_GetTabstops       (HLB hlb, WORD *tabs, WORD *tab_styles);
GLOBAL BOOLEAN     ListBox_SetTabstops       (HLB hlb, WORD num_tabs, WORD *tabs, WORD *tab_styles);
GLOBAL LONG        ListBox_GetTopIndex       (HLB hlb);
GLOBAL VOID        ListBox_SetTopIndex       (HLB hlb, LONG index);
GLOBAL WORD        ListBox_GetItemHeight     (HLB hlb);
GLOBAL VOID        ListBox_SetItemHeight     (HLB hlb, WORD height);
GLOBAL WORD        ListBox_GetLeftOffset     (HLB hlb);
GLOBAL VOID        ListBox_SetLeftOffset     (HLB hlb, WORD offset);
GLOBAL LONG        ListBox_GetSpec           (HLB hlb);
GLOBAL VOID        ListBox_SetSpec           (HLB hlb, LONG spec);
GLOBAL VOID        ListBox_GetComboRect      (HLB hlb, RECT *rc, WORD *y);
GLOBAL VOID        ListBox_SetComboRect      (HLB hlb, RECT *rc, WORD y);
GLOBAL LONG        ListBox_ComboClick        (HLB hlb, MKINFO *mk);

GLOBAL VOID        ScrollBarRedraw           (OBJECT *tree, WORD obj);
GLOBAL LONG        ScrollBarClick            (OBJECT *tree, WORD obj, MKINFO *mk);
GLOBAL VOID        ScrollBarKey              (OBJECT *tree, WORD obj, MKINFO *mk);
GLOBAL LONG        ScrollBarSendMessage      (OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p);
GLOBAL SB_CALLBACK ScrollBarGetCallback      (OBJECT *tree, WORD obj);
GLOBAL VOID        ScrollBarSetCallback      (OBJECT *tree, WORD obj, SB_CALLBACK callback);
GLOBAL WORD        ScrollBarGetWindowHandle  (OBJECT *tree, WORD obj);
GLOBAL VOID        ScrollBarSetWindowHandle  (OBJECT *tree, WORD obj, WORD wh);
GLOBAL WORD        ScrollBarGetBkColor       (OBJECT *tree, WORD obj);
GLOBAL VOID        ScrollBarSetBkColor       (OBJECT *tree, WORD obj, WORD bk_color);
GLOBAL UWORD       ScrollBarGetStyle         (OBJECT *tree, WORD obj);
GLOBAL VOID        ScrollBarSetStyle         (OBJECT *tree, WORD obj, UWORD style, BOOLEAN on);
GLOBAL LONG        ScrollBarGetCount         (OBJECT *tree, WORD obj);
GLOBAL VOID        ScrollBarSetCount         (OBJECT *tree, WORD obj, LONG count, BOOLEAN redraw);
GLOBAL LONG        ScrollBarGetPageSize      (OBJECT *tree, WORD obj);
GLOBAL VOID        ScrollBarSetPageSize      (OBJECT *tree, WORD obj, LONG pagesize, BOOLEAN redraw);
GLOBAL LONG        ScrollBarGetPos           (OBJECT *tree, WORD obj);
GLOBAL VOID        ScrollBarSetPos           (OBJECT *tree, WORD obj, LONG pos, BOOLEAN redraw);
GLOBAL LONG        ScrollBarGetSpec          (OBJECT *tree, WORD obj);
GLOBAL VOID        ScrollBarSetSpec          (OBJECT *tree, WORD obj, LONG spec);

GLOBAL HSB         ScrollBar_Create          (UWORD style, RECT *rc, LONG count, LONG pagesize);
GLOBAL VOID        ScrollBar_Delete          (HSB hsb);
GLOBAL VOID        ScrollBar_Redraw          (HSB hsb);
GLOBAL LONG        ScrollBar_Click           (HSB hsb, MKINFO *mk);
GLOBAL VOID        ScrollBar_Key             (HSB hsb, MKINFO *mk);
GLOBAL LONG        ScrollBar_SendMessage     (HSB hsb, WORD msg, LONG item, VOID *p);
GLOBAL VOID        ScrollBar_GetRect         (HSB hsb, RECT *rc);
GLOBAL VOID        ScrollBar_SetRect         (HSB hsb, CONST RECT *rc, BOOLEAN redraw);
GLOBAL SB_CALLBACK ScrollBar_GetCallback     (HSB hsb);
GLOBAL VOID        ScrollBar_SetCallback     (HSB hsb, SB_CALLBACK callback);
GLOBAL WORD        ScrollBar_GetWindowHandle (HSB hsb);
GLOBAL VOID        ScrollBar_SetWindowHandle (HSB hsb, WORD wh);
GLOBAL WORD        ScrollBar_GetBkColor      (HSB hsb);
GLOBAL VOID        ScrollBar_SetBkColor      (HSB hsb, WORD bk_color);
GLOBAL UWORD       ScrollBar_GetStyle        (HSB hsb);
GLOBAL VOID        ScrollBar_SetStyle        (HSB hsb, UWORD style, BOOLEAN on);
GLOBAL LONG        ScrollBar_GetCount        (HSB hsb);
GLOBAL VOID        ScrollBar_SetCount        (HSB hsb, LONG count, BOOLEAN redraw);
GLOBAL LONG        ScrollBar_GetPageSize     (HSB hsb);
GLOBAL VOID        ScrollBar_SetPageSize     (HSB hsb, LONG pagesize, BOOLEAN redraw);
GLOBAL LONG        ScrollBar_GetPos          (HSB hsb);
GLOBAL VOID        ScrollBar_SetPos          (HSB hsb, LONG pos, BOOLEAN redraw);
GLOBAL LONG        ScrollBar_GetSpec         (HSB hsb);
GLOBAL VOID        ScrollBar_SetSpec         (HSB hsb, LONG spec);

#endif /* __CONTROLS__ */

