#ifndef  _FUI_Dialog
#define  _FUI_Dialog
#include "event.h"
/*************************************************************************************************************************/
/*************************************************************************************************************************/
#define RO_TREE             0
#define RO_DIALOG           1
#define RO_GROUP            2
#define RO_BUTTON           3
#define RO_BUTTONHELP       4
#define RO_BUTTONSCROLL     5
#define RO_SLIDEBOX         6
#define RO_TEXT             7
#define RO_TEXTINPUT        8
#define RO_TEXTINPUTSECRET  9
#define RO_TEXTINPUTMENU    10
#define RO_TEXTAREA         11
#define RO_TEXTINPUTAREA    12
#define RO_TEXTLISTAREA     13
#define RO_PICTURELISTAREA  14
#define RO_ICON             15
#define RO_BOX              16
#define RO_IMAGE            17
#define RO_TOOLPANEL        18
#define RO_TOOLPANELGROUP   19
#define RO_PANEL            20
#define RO_SCROLLBAR        21
#define RO_STRING           22

#define OBJECT_FIRST        0
#define OBJECT_LAST         1

#define DELETE_RECURSIVE    1
#define DELETE_NONRECURSIVE 0

#define BUTTON_NORMAL       0
#define BUTTON_ROUNDED      1
#define BUTTON_RADIO        2
#define BUTTON_CROSS        3

#define BUTTON_ALIGN_CENTER 0
#define BUTTON_ALIGN_LEFT   1
#define BUTTON_ALIGN_RIGHT  2
#define BUTTON_ALIGN_BOTH   3

#define COLOR_WHITE         0     
#define COLOR_BLACK         1     
#define COLOR_RED           2
#define COLOR_GREEN         3
#define COLOR_BLUE          4
#define COLOR_CYAN          5
#define COLOR_YELLOW        6
#define COLOR_PURPLE        7
#define COLOR_GRAY          8
#define COLOR_GREY          COLOR_GRAY
#define COLOR_DGRAY         9
#define COLOR_DGREY         COLOR_DGRAY
#define COLOR_DARKGRAY      COLOR_DGRAY
#define COLOR_DARKGREY      COLOR_DARKGRAY
#define COLOR_DRED          10
#define COLOR_DARKRED       COLOR_DRED
#define COLOR_DGREEN        11
#define COLOR_DARKGREEN     COLOR_DGREEN
#define COLOR_DBLUE         12
#define COLOR_DARKBLUE      COLOR_DBLUE
#define COLOR_DCYAN         13
#define COLOR_DARKGYAN      COLOR_DCYAN
#define COLOR_DYELLOW       14
#define COLOR_DPURPLE       15

#define X1                  0
#define X2                  2
#define X3                  4
#define X4                  6
#define Y1                  1
#define Y2                  3
#define Y3                  5
#define Y4                  7

#define EFFECT_NORMAL       0
#define EFFECT_3DRAISED     1
#define EFFECT_3DLOWERED    2
#define EFFECT_3DBORDER     3
#define EFFECT_FILL         4
  
#define FSTYLE_HOLLOW       0
#define FSTYLE_SOLID        1
#define FSTYLE_LINE1        2
#define FSTYLE_LINE2        3
#define FSTYLE_LINE3        4
#define FSTYLE_PATTERN1     5
#define FSTYLE_PATTERN2     6
#define FSTYLE_PATTERN3     7
#define FSTYLE_USERDEF1     8
#define FSTYLE_USERDEF2     9
#define FSTYLE_USERDEF3     10
#define FSTYLE_USERDEF4     11
#define FSTYLE_USERDEF5     12
#define FSTYLE_USERDEF6     13
#define FSTYLE_USERDEF7     14
#define FSTYLE_USERDEF8     15
 
#define FPATTERN_SOLID100    0
#define FPATTERN_SOLID50     8
#define FPATTERN_SOLID0      15

#define TEXT_NORMAL          0
#define TEXT_THICKEN         (1<<0)
#define TEXT_BOLD            TEXT_THICKEN
#define TEXT_LIGHT           (1<<1)
#define TEXT_SKEWED          (1<<2)
#define TEXT_ITALIC          TEXT_SKEWED
#define TEXT_UNDERLINE       (1<<3)
#define TEXT_OUTLINE         (1<<4)
#define TEXT_SHADOW          (1<<5)

#define SCROLLBAR_HORISONTAL 1
#define SCROLLBAR_VERTICAL   2

#define ALIGNMENT_HORISONTAL 0
#define ALIGNMENT_VERTICAL   1

/*************************************************************************************************************************/
/*************************************************************************************************************************/
typedef struct RO_Font
{
	int        Id;
	int        Size;
	int        Effects;
	int        Colour;
}RO_Font;

typedef struct RO_Group     /* 2 */
{
	int        test;
}RO_Group;

typedef struct RO_Button          /* 3 */
{
	short type;
	struct
	{
		int  Default       :1,
		     Selected      :1,
		     Align_text    :2,
		     Align_select  :2,
		     Unused        :26;
	}flags;
	char    *text;
	RO_Font font;
	long    text_x,
	        text_y;
}RO_Button;

typedef struct RO_ButtonHelp      /* 4 */
{
	int     test;
}RO_ButtonHelp;

typedef struct RO_ButtonScroll    /* 5 */
{
	int     test;
}RO_ButtonScroll;

typedef struct RO_SlideBox        /* 6 */
{
	int     test;
}RO_SlideBox;

typedef struct RO_Text            /* 7 */
{
	char    *text;
	RO_Font font;
}RO_Text;

typedef struct RO_TextInput       /* 8 */
{
	char    *text;
	char    *valid;
	RO_Font font;
}RO_TextInput;

typedef struct RO_TextInputSecret /* 9 */
{
	char    *text;
	char    *valid;
	char    secret;
	RO_Font font;
}RO_TextInputSecret;

typedef struct RO_TextInputMenu   /* 10  */
{
	int     test;
}RO_TextInputMenu;

typedef struct RO_TextArea        /* 10  */
{
	int     rows,
	        cols;
	char    *text;
	RO_Font font;
}RO_TextArea;
 
typedef struct RO_TextInputArea   /* 12 */
{
	int     test;
}RO_TextInputArea;

typedef struct RO_TextListArea    /* 13 */
{
	int test;
}RO_TextListArea;

typedef struct RO_PictureListArea /* 14 */
{
	int test;
}RO_PictureListArea;

typedef struct RO_Icon            /* 15 */
{
	int test;
/*
	union
	{
		int       flags    :32;
		struct flag
		{
			int   selected :1,
			      disabled :1,
			      unused   :30;
		}flag;
	};
*/
}RO_Icon;

typedef struct RO_Box             /* 16 */  
{
	int     color    :8,
	        fcolor   :8,
	        fstyle   :4,
	        fpattern :4,
	        effect   :8;
}RO_Box;

typedef struct RO_Image           /* 17 */
{
	short   width,
	        height,
	        depth;
	long    *data;
	long    *mask;
}RO_Image;

typedef struct RO_ToolPanel       /* 18 */
{
	int     Minimize :1,
	        move     :1;
}RO_ToolPanel;

typedef struct RO_ToolPanelGroup  /* 19 */
{
	int     test;
}RO_ToolPanelGroup;

typedef struct RO_Panel           /* 20 */
{
	int     visible  :1,
	        text_pos :2;
	char    *text;
}RO_Panel;

typedef struct RO_ScrollBar       /* 21 */
{
	int     max,
	        min,
	        pos,
	        size,
	        type;
}RO_ScrollBar;
 
typedef struct RO_Dialog          /* 1 */
{
	char *titletext;

#ifdef DATAVOID
	int data         :32;
	int data2        :32;
#else
	union
	{
		int flags      :32;
		struct flag
		{
			int close    :1,
			    move     :1,
			    full     :1,
			    iconize  :1,
			    hide     :1,
			    not_used :27;
		}flag;
	};
	union
	{
		int data2      :32;
		RO_Box Box;
	};
#endif
}RO_Dialog;

typedef struct RO_Object          
{
	char          name[16];
	struct RO_Object  *parent,
	                  *child,
	                  *next;
	long              type;
	struct
	{
		int  pAlign_top    : 1,
		     pAlign_bottom : 1,
		     pAlign_left   : 1,
		     pAlign_right  : 1,
		     Max_h         : 1,
		     Max_w         : 1,
		     Same_w        : 1,
		     Same_h        : 1,
		     Change_w      : 1,
		     Change_h      : 1,
		     Alignment     : 1,
		     Hidden        : 1,
		     Enabled       : 1,
		     Unused        : 19;
	}flags;

#ifdef DATAVOID
	void         *data;
#else
	union 
	{
		void               *Data;
		RO_Dialog          *Dialog;
		RO_Group           *Group;
		RO_Button          *Button;
		RO_ButtonHelp      *ButtonHelp;
		RO_ButtonScroll    *ButtonScroll;
		RO_SlideBox        *SlideBox;
		RO_Text            *Text;
		RO_TextInput       *TextInput;
		RO_TextInputSecret *TextInputSecret;
		RO_TextInputMenu   *TextInputMenu;
		RO_TextArea        *TextArea;
		RO_TextInputArea   *TextInputArea;
		RO_TextListArea    *TextListArea;
		RO_PictureListArea *PictureListArea;
		RO_ToolPanel       *ToolPanel;
		RO_ToolPanelGroup  *ToolPanelGroup;
		RO_Box             Box;
		RO_Icon            *Icon;
		RO_Image           *Image;
		RO_ScrollBar       *ScrollBar;
		char               *String;
	};
#endif
	short                  in_x,
	                       in_y,
	                       out_x,
	                       out_y;
	int                    tag;
	struct
	{
		short              x,
		                   y,
		                   w,
		                   h;
		short              min_w,
		                   min_h;
		int                active  : 1;
	}internal;
} RO_Object;
  
typedef struct RO_Func
{
	struct RO_Func         *super;
	void ( *min_size )     ( RO_Object * );
	void ( *draw )         ( RO_Object * , long , long );
	void ( *set_language ) ( RO_Object * , char * );
	void ( *handle_event ) ( RO_Object * , EVENT_DATA *event);
}RO_Func;

/*************************************************************************************************************************/
/*************************************************************************************************************************/
extern void init_graph(void);
extern void show(RO_Object *tree,long object);
extern void deinit_graph(void);
extern void draw_window(RO_Object *object, long x, long y);
extern void draw_button(RO_Object *object , long x , long y );
extern void draw_box(RO_Object *object , long x , long y );
extern void draw_image(RO_Object *object , int x, int y);
extern void draw_scrollbar(RO_Object *object, int x, int y);
extern long find_object(RO_Object *tree , char *name ); 

extern RO_Object *create_object(int type);


#endif