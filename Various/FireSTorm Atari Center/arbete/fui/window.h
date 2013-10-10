#ifndef  _FUI_Window
#define  _FUI_Window
#include "dialog.h"
#include "event.h"

/*************************************************************************************************************************/
/*************************************************************************************************************************/
#define WINDOW_STATUS_CLOSED   (0)
#define WINDOW_STATUS_OPENED   (1<<31)
#define WINDOW_STATUS_ICONIZED (1<<30)
#define WINDOW_STATUS_HIDDEN   (1<<29)

#define WINDOW_FLAGS_NONE      0
#define WINDOW_FLAGS_CLOSE     (1<<31)
#define WINDOW_FLAGS_TITLEBAR  (1<<30)
#define WINDOW_FLAGS_MOVE      (1<<29)
#define WINDOW_FLAGS_FULL      (1<<28)
#define WINDOW_FLAGS_ICONIZE   (1<<27)
#define WINDOW_FLAGS_HIDE      (1<<26)
#define WINDOW_FLAGS_MODAL     (1<<25)
#define WINDOW_FLAGS_CENTER    (1<<24)

#define MENU_STATE_CHECKED     (1<<15)
#define MENU_STATE_DISABLED    (1<<14)

#define MOVE_NONE              0
#define MOVE_TOP               1
#define MOVE_LEFT              2
#define MOVE_RIGHT             4
#define MOVE_BOTTOM            8
#define MOVE_TOP_LEFT          ( MOVE_TOP | MOVE_LEFT )
#define MOVE_LEFT_TOP          MOVE_TOP_LEFT
#define MOVE_TOP_RIGHT         ( MOVE_TOP | MOVE_RIGHT )
#define MOVE_RIGHT_TOP         MOVE_TOP_RIGHT
#define MOVE_BOTTOM_LEFT       ( MOVE_BOTTOM | MOVE_LEFT )
#define MOVE_LEFT_BOTTOM       MOVE_BOTTOM_LEFT
#define MOVE_BOTTOM_RIGHT      ( MOVE_BOTTOM | MOVE_RIGHT )
#define MOVE_RIGHT_BOTTOM      MOVE_BOTTOM_RIGHT

#define MOVE_SEPERATOR_SIZE    10
#define MOVE_SIZE              2
/*************************************************************************************************************************/
/*************************************************************************************************************************/
typedef struct Window
{
	union
	{
		unsigned int        Status;
		struct
		{
			unsigned int    Opened   :1,
			                Iconized :1,
			                Hidden   :1;
			
		}s;
	};
	int                     Ident;
	union
	{
		int                 Flags;
		struct
		{
			unsigned int    Close    :1,
			                Title    :1,
			                Move     :1,
			                Full     :1,
			                Iconize  :1,
			                Hide     :1,
			                Modal    :1,
			                Center   :1,
			                Back     :1,
			                Scroll_h :1,
			                Scroll_w :1;
		}f;
	};
	unsigned int            x,
	                        y,
	                        w,
	                        h,
	                        i_x,
	                        i_y,
	                        i_w,
	                        i_h;
	RO_Object               *Root;
	RO_Object               *Menu;
	unsigned char           Title[50];
	unsigned int            Tag;
}Window;

typedef struct Window_entry
{
	Window                  *window;
	RO_Object				*wind_object;
	RO_Object               *obj_close,*obj_move,*obj_icon,*obj_back,*obj_hide,*obj_full,*obj_scroll_h,*obj_scroll_w;
	RO_Object               *obj_current;
	unsigned char           move;
	struct Window_entry     *next;
	
}Window_entry;
/*************************************************************************************************************************/
/*************************************************************************************************************************/

#endif