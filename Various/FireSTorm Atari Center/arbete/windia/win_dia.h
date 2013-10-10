/***********************************************************************/
/* My own dialog in windows rutines                                    */
/* X Open dialogs                                                      */
/* X Closing dialogs                                                   */
/* X Moving of dialogs                                                 */
/* X Updating of dialogs                                               */
/* X Handling of Menu-bar (without Short-keys)                         */
/* . Handling of Short-keys in the Menu-bar                            */
/* X Iconifying of window                                              */  
/* X Uniconify of Dialogs                                              */
/* X Handling of Buttons in Active Dialogs                             */
/* X Handling of Default Button in Active Windows                      */
/*   Handling of Buttons in Background Dialogs                         */
/* . Handling of Radio Buttons in Active Dialogs                       */
/*   Handling of Radio buttons in Background dialogs                   */
/* . Handling Of Editable Text-Objects                                 */
/* . Handling of Text-Windows                                          */
/*   Handling of List-Windows                                          */
/*   Handling of Clipboard Copy in text-window                         */
/*   Handling of Selection of Items in List-Window                     */
/***********************************************************************/
#define WINDOW_CLOSED        0
#define WINDOW_OPENED        1
#define WINDOW_ICONIZED      2
#define WINDOW_HIDDEN        4
#define WINDOW_IHIDDEN       5
#define WINDOW_REDRAW        6
#define WINDOW_NMOPENED      11
#define WINDOW_NMICONIZED    12
#define WINDOW_NMREDRAW      16

#define TYPE_DIALOG          0
#define TYPE_TEXT            1
#define TYPE_LIST            2

#define SVAR_OBJECT          0
#define SVAR_OBJECT_MENU_ROW 1
#define SVAR_MOUSE_BUTTON    2
#define SVAR_MOUSE_CLICKS    3
#define SVAR_MOUSE_X         4
#define SVAR_MOUSE_Y         5
#define SVAR_KEY_VALUE       6
#define SVAR_KEY_SHIFT       7
#define SVAR_WINDOW_ID       9
#define SVAR_WINDOW_MESSAGE  10
#define SVAR_WINDOW_DATA_0   11
#define SVAR_WINDOW_DATA_1   11
#define SVAR_WINDOW_DATA_2   13
#define SVAR_WINDOW_DATA_3   14
#define SVAR_WINDOW_DATA_4   15
#define SVAR_TEXT_START_HI   2
#define SVAR_TEXT_START_LO   3
#define SVAR_TEXT_END_HI     4
#define SVAR_TEXT_END_LO     5
#define SVAR_TEXT_LENGTH     6

#define DEBUGFILE "dialog.log"

#define DIALOG_VER  "V0.60"
#define FALSE       0
#define TRUE        1
#define FAIL        -1
#define NOLL        0
#define OK          0
#define MAXSTRING   255

#define MENU_CLICKED   1
#define WINDOW_CLICKED 2
#define DIALOG_CLICKED 3
#define KEY_CLICKED    4
#define BUTTON_CLICKED 5
#define TIMER_EXIT     6
#define TEXT_CLICKED   7
#define UNDEF_MESSAGE  8 
#define VA_MESSAGE     9
#define DRAGNDROP      10
#define TEXT_SELECTED  11

#define MAX_WINDOWS    16
#define MAXWINSTRING   80

#define RESOURCE_ERROR "[1][ Where is the | resouce file? ][ OOOPS! ]"
#define WINDOW_ERROR   "[1][ No More windows! ][ OOOPS! ]"
#define APPL_ERROR     "[1][ Application init | Error! ][ OOOPS! ]"
#define GDOS_ERROR     "[1][ This Program needs | GDOS to run! ][ OOOPS! ]"
#define MEMORY_ERROR   "[1][ Not Enough Memory | To Complete the Operation ][ OOOPS! ]"
#define MENU_ERROR     "[1][ This is strange, the | menu could not be | displayed ][ What? ]"
#define ERR_NOTHING    0
#define ERR_NORMAL     1
#define ERR_EXIT       2

#define FONT_NAME_SIZE 33
#define FONT_SIZE_SIZE 5

#define __OB_SPEC
/***********************************************************************/
/* Definitions for changeing an object status/flag                     */
/***********************************************************************/
#define SET_STATE        0
#define CLEAR_STATE      1
#define CHANGE_STATE     2
#define SET_FLAGS        3
#define CLEAR_FLAGS      4
#define CHANGE_FLAGS     5
#define UPDATE           6

/**************************************************************************************************************/
/* Extended Object Specifications                                                                             */
/**************************************************************************************************************/
#define GE_DRAGBUTTON (G_BUTTON|0x0100)
#define GE_DRAGBOX    (G_BOX|0x0100)
/**************************************************************************************************************/
/* Special Keys definition                                                                                    */
/**************************************************************************************************************/
#define SC_INSERT  82
#define SC_CLR     71
#define SC_HELP    98
#define SC_UNDO    97
#define SC_UP      72
#define SC_DOWN    80
#define SC_LEFT    75
#define SC_RIGHT   77
#define SC_F1      4
#define SC_F10     13
/***********************************************************************/
/* Indexing for XYWH                                                   */
/***********************************************************************/
#define XYWH       4
#define X          0
#define Y          1
#define W          2
#define H          3
#define X1         0
#define Y1         1 
#define X2         2 
#define Y2         3
#define X3         4
#define Y3         5
#define X4         6
#define Y4         7

typedef struct                                    /************************************************************/
{                                                 /* Error Structure                                          */
  int  type;                                      /* How big Problem                                          */
  char text[255];                                 /* text-Message                                             */
}error;                                           /************************************************************/

typedef struct                                    /************************************************************/
{                                                 /* Information about the lines in a text-window             */
  char     *line;                                 /* Pointer to the beginning of the line                     */
  short     length;                               /* The Length of the line (excluding the new-line chars     */
}TEXTLINE;                                        /************************************************************/

typedef struct                                    /************************************************************/
{                                                 /* Information about the text/list-windows                  */
  union                                           /* text/list Text-Window OR List-window entity              */
  {                                               /*                                                          */
    char   *textstart;                            /* Text: Start of Text (pointer)                            */
    char   *(*createline)(int ,char *, int,       /* List: routine to create the "first" update line          */
             short *, short *);                   /*                                                          */
  };                                              /**                                                        **/
  union                                           /* text/list Text-Window OR List-window entity              */
  {                                               /*                                                          */
    char   *textend;                              /* Text: End of text (pointer)                              */
    char   *(*createnext)(char *,int,             /* List: routine to create the "following" update lines     */
             short *, short *);                   /*                                                          */
  };                                              /**                                                         */
  union                                           /* text/list Text-Window OR List-window entity              */
  {                                               /*                                                          */
    TEXTLINE *lineinfo;                           /* Text: Information about the lines in the text            */
    int      select;                              /* List: which Line is Selected?                            */
  };                                              /**                                                        **/
  OBJECT   *dialog;                               /* Pointer to the "toolbar"                                 */
  long     num_of_rows,num_of_cols,max_cols;      /* The Size of the text/List, adn the maximum row-size      */
  long     offset_y, offset_x;                    /* The starting position in the text/list                   */
  short    font_id,font_size;                     /* The ID and size of the Font (Only used when opening)     */
  short    char_w,char_h;                         /* the Information about the Characterset to be used        */
  short    graf_id;                               /* The Virtual Device number for this window                */
  int      mark_free  :1,                         /* How can the Marking of lines be? (text-win               */
           mark_line  :1,                         /* Is it possible to mark lines in the list?                */
           mark_linem :1,                         /* Is it possible to mark MANY lines in the list?           */
           fcolor     :4,                         /* forground color of the window (text-color)               */
           bcolor     :4,                         /* Background color of the window                           */
           sc_left    :1,                         /* Should the Left-cursor key scroll the window?            */
           sc_right   :1,                         /* Should the Right-cursor key scroll the window?           */
           sc_up      :1,                         /* Should the Up-cursor key scroll the window?              */
           sc_down    :1;                         /* Should the Down-cursor key scroll the window?            */
  struct
  {
    int    start_col,
           start_row,
           end_row,
           end_col;
  }mark;
}WIN_TEXT;                                        /************************************************************/

typedef struct                                    /************************************************************/
{                                                 /* the Window structure                                     */
  int           type;                             /* what type of window is this?                             */
  int           attr;                             /* The Window Attributes (closer, etc)                      */
  int           status;                           /* The Status of the window (closed, etc)                   */
  int           ident;                            /* The window Identity (Id-number)                          */
  char          w_name[MAXWINSTRING];             /* The window-Name                                          */
  char          w_info[MAXWINSTRING];             /* The information-line                                     */
  short         xy[4];                            /* The Internal Window Coordinates                          */
  int           i_x,i_y;                          /* The X/Y-Position of the Icon                             */
  long          order;                            /* the "topping" order                                      */
  OBJECT        *icondata;                        /* Pointer to the Icon-Object                               */
  union                                           /* Dialog/Text window Entity                                */
  {                                               /*                                                          */
    OBJECT      *dialog;                          /* Dialog: Pointer to the dialog                            */
    WIN_TEXT    *text;                            /* Text: Pointer to the text-structure                      */
  };                                              /*                                                          */
  long          tag;                              /* To be used as an window depended free variable           */
}WIN_DIALOG;                                      /************************************************************/

typedef struct                                    /************************************************************/
{
  int    type;
  short  window;
  short  data[16];
}RESULT;

/***********************************************************************/
/* Global Variables used by windia, that are "extern"                  */
/***********************************************************************/
extern short  screenx, screeny, screenw, screenh;
extern char   d_temp[MAXSTRING];
extern error  fel;
extern char   **key_table;

/***********************************************************************/
#ifdef PUREC
  AESPB  aespb;
#endif

/***********************************************************************/
/* funktioner som kan anropas!                                         */
/***********************************************************************/
int    open_menu(OBJECT *tree, int type);
int    open_dialog(WIN_DIALOG *info,short win_xy[XYWH]);
int    open_nonmodal(WIN_DIALOG *info,short win_xy[XYWH]);
void   close_dialog(WIN_DIALOG *info);
void   redraw_window(WIN_DIALOG *info);
RESULT form_dialog(void);
void   iconify_window(WIN_DIALOG *info);
void   uniconify_window(WIN_DIALOG *info);
void   str2ted(OBJECT *tree, int object, char *text);
void   ted2str(OBJECT *tree, int object, char *text);
int    ted2int(OBJECT *tree, int object);
int    popup(char *string,int selected,OBJECT *tree,int object,char *choice);
void   button(WIN_DIALOG *info, int object, int type ,short data,int draw);
void   b_place(OBJECT *dialog, int object, short xy[XYWH]);
void   update_dialog(WIN_DIALOG *info, short xy[XYWH]);
void   update_text(WIN_DIALOG *info, const short xy[XYWH]);
void   set_textwin_sliders(WIN_DIALOG *info);
void   set_text_font(WIN_DIALOG *info, short font_id, short font_size,int update);
short  font_id(char *name);
