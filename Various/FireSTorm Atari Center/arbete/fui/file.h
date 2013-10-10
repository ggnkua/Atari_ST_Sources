#ifndef  _FUI_Dialog_File
#define  _FUI_Dialog_File

/*************************************************************************************************************************/
/*************************************************************************************************************************/
typedef struct File_RO_Font
{
	int        Id;
	int        Size;
	int        Effects;
	int        Colour;
}RO_Font;

typedef struct File_RO_Group     /* 2 */
{
	int        test;
}RO_Group;

typedef struct File_RO_Button          /* 3 */
{
	short        type;
	struct
	{
		int      Default       :1,
		         Selected      :1,
		         Align_text    :2,
		         Align_select  :2,
		         Unused        :26;
	}flags;
	File_RO_Font font;
	long         text_x,
	             text_y;
}RO_Button;

typedef struct File_RO_ButtonHelp      /* 4 */
{
	int     test;
}RO_ButtonHelp;

typedef struct File_RO_ButtonScroll    /* 5 */
{
	int     test;
}RO_ButtonScroll;

typedef struct File_RO_SlideBox        /* 6 */
{
	int     test;
}RO_SlideBox;

typedef struct File_RO_Text            /* 7 */
{
	File_RO_Font font;
}RO_Text;

typedef struct File_RO_TextInput       /* 8 */
{
	File_RO_Font font;
}RO_TextInput;

typedef struct File_RO_TextInputSecret /* 9 */
{
	File_RO_Font font;
}RO_TextInputSecret;

typedef struct File_RO_TextInputMenu   /* 10  */
{
	int     test;
}RO_TextInputMenu;

typedef struct File_RO_TextArea        /* 10  */
{
	int     rows,
	        cols;
	File_RO_Font font;
}RO_TextArea;
 
typedef struct File_RO_TextInputArea   /* 12 */
{
	int     test;
}RO_TextInputArea;

typedef struct File_RO_TextListArea    /* 13 */
{
	int test;
}RO_TextListArea;

typedef struct File_RO_PictureListArea /* 14 */
{
	int test;
}RO_PictureListArea;

typedef struct File_RO_Icon            /* 15 */
{
	int test;
}RO_Icon;

typedef struct File_RO_Box             /* 16 */  
{
	int     color    :8,
	        fcolor   :8,
	        fstyle   :4,
	        fpattern :4,
	        effect   :8;
}RO_Box;

typedef struct File_RO_Image           /* 17 */
{
	short   width,
	        height,
	        depth;
	long    *data;
	long    *mask;
}RO_Image;

typedef struct File_RO_ToolPanel       /* 18 */
{
	int     Minimize :1,
	        move     :1;
}RO_ToolPanel;

typedef struct File_RO_ToolPanelGroup  /* 19 */
{
	int     test;
}RO_ToolPanelGroup;

typedef struct File_RO_Panel           /* 20 */
{
	int     visible  :1,
	        text_pos :2;
}RO_Panel;

typedef struct File_RO_ScrollBar       /* 21 */
{
	int     max,
	        min,
	        pos,
	        size,
	        type;
}RO_ScrollBar;
 
typedef struct File_RO_Dialog          /* 1 */
{

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

typedef struct File_RO_Object          
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
		void                    *Data;
		File_RO_Dialog          *Dialog;
		File_RO_Group           *Group;
		File_RO_Button          *Button;
		File_RO_ButtonHelp      *ButtonHelp;
		File_RO_ButtonScroll    *ButtonScroll;
		File_RO_SlideBox        *SlideBox;
		File_RO_Text            *Text;
		File_RO_TextInput       *TextInput;
		File_RO_TextInputSecret *TextInputSecret;
		File_RO_TextInputMenu   *TextInputMenu;
		File_RO_TextArea        *TextArea;
		File_RO_TextInputArea   *TextInputArea;
		File_RO_TextListArea    *TextListArea;
		File_RO_PictureListArea *PictureListArea;
		File_RO_ToolPanel       *ToolPanel;
		File_RO_ToolPanelGroup  *ToolPanelGroup;
		File_RO_Box             Box;
		File_RO_Icon            *Icon;
		File_RO_Image           *Image;
		File_RO_ScrollBar       *ScrollBar;
		char                    *String;
	};
#endif
	short                  in_x,
	                       in_y,
	                       out_x,
	                       out_y;
	int                    tag;
} RO_Object;
  
#endif