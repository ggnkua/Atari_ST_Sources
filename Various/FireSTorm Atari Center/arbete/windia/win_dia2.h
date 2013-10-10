/***********************************************************************/
/* Definitions about different Keys that are useful to know            */
/***********************************************************************/
#define CH_SHIFT   1
#define CH_CTRL    '^'
#define CH_ALT     7
#define CH_HELP    "Help"
#define CH_UNDO    "Undo"
#define CH_DELETE  "Del"
#define CH_ESC     "Esc"
#define CH_TAB     "Tab"
#define CH_INSERT  "Ins"
#define CH_CLR     "Clr"
#define CH_BACKSPC "Bspc"

#define NU_SHIFT   0x0100
#define NU_CTRL    0x0200
#define NU_ALT     0x0400
#define NU_SCAN    0x0800
#define NU_DELETE  127
#define NU_ESC     27
#define NU_TAB     9
#define NU_BACKSPC 8

#define SCRAPFILE "SCRAP.TXT"
#define SLIDESIZE  1000

#define SCROLL_UP     0
#define SCROLL_DOWN   1
#define SCROLL_LEFT   2
#define SCROLL_RIGHT  3

/***********************************************************************/
/* Popup information                                                   */
/***********************************************************************/
typedef struct
{
  int     s_antal, d_antal;
  int     size;
  int     select, offset, number;
  int     x, y, w, h;
  OBJECT *tree;
  int     object;
  char   *string, *pointer1, *pointer2;
} POPUP_DATA;

/***********************************************************************/
/* event Information                                                   */
/***********************************************************************/
typedef struct
{
  short   mo_x,           /* X-coord for mouse in Eventmulti           */        
          mo_y,           /* Y-coord for mouse in Eventmulti           */
          mo_b,           /* Button-state for mouse in Eventmulti      */
          key,            /* Key-state in Eventmulti                   */
          k_s,            /* Key-Shift-state in Eventmulti             */
          m_r;            /* number of Mouseclicks in Eventmulti       */
  int     check,          /*                                           */
          end,            /*                                           */
          count,          /* Temporary counter                         */
          active,         /* Internal Number of Active Window          */
          found;          /* Window has Been found (In internal List)  */
  short   w1,w2,w3,w4;    /* Temporary Window-coords (for updating)    */
  short   d1,d2,d3,d4;    /* Temporary Window-coords (For updating)    */
  short   xy[4];          /* Temporary Window-coords (For updating)    */
  short   data[16];       /* Messages with Evnt-Multi                  */
} EVENT_DATA;

/***********************************************************************/
/* dialog Info                                                         */
/***********************************************************************/
typedef struct 
{
  int          text_object; /*  What object is holding the cursor-key  */
  short        text_pos;    /* On what position is the cursor-key      */
}DIALOG_INFO;

/***********************************************************************/
/* Window Info                                                         */
/***********************************************************************/
typedef struct
{
  int number;                       /* Number of Windows               */
  int nonmodal;                     /* number of opened NonModals      */
  WIN_DIALOG *window[MAX_WINDOWS];  /* List of Window-Informations     */
  DIALOG_INFO diainfo[MAX_WINDOWS]; /* List of Cursor-key-Informations */
}WINDOW;

/***********************************************************************/
/***********************************************************************/
void fix_button_pressed();
void fix_key_clicked();
void fix_message();
void deinit_popup(POPUP_DATA *pop);
void init_popup(POPUP_DATA *pop);
void update(WIN_DIALOG *info, short xy[]);
void copy_word(WIN_DIALOG *info,int x,int y);

#ifdef WINLOGGING
void WinLog(char *logstring,...);
#endif
/***********************************************************************/
/***********************************************************************/
extern short        screenx, screeny, screenw, screenh, aes_ver;
extern short        work_in[11], work_out[57], ap_id, graf_id, xy[8],dummy;
extern char         d_temp[MAXSTRING];
extern FILE        *d_fil;
extern error        fel;
extern WINDOW       dias;
extern short        shortkeys[100];
extern short        shortkorr[100];
extern OBJECT      *menutree,*poptree;
extern char       **key_table;
extern long         num_fonts;
extern short        font_width,font_height;
extern long int     timer;
extern int          exist_3d,
                    gdos;
extern EVENT_DATA   evnt;
extern char        *pop_string;
extern long        *pop_values;
extern RESULT       tebax;
