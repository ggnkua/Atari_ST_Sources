#ifndef _FUI_Event
#define _FUI_Event

/*************************************************************************************************************************/
/*************************************************************************************************************************/
#define EVENT_MENU             0
#define EVENT_KEY              1
#define EVENT_MOUSE            2
#define EVENT_WINDOW           3
#define EVENT_BUTTON           4
#define EVENT_OTHER            0xffffffff

/*************************************************************************************************************************/
/*************************************************************************************************************************/
typedef struct Event_menu
{
	unsigned short	        Index,
	                        Row;
	union
	{
		unsigned short      State;
		struct
		{
			int       Checked  :1,
			                Disabled :1;
		}s;
	};
}Event_menu;

typedef struct Event_key
{
	short                   Key_num;
	short                   Shift;
	short                   Ascii;
}Event_key;

typedef struct Event_mouse
{
	short                   Direction,
	                        x,
	                        y;
}Event_mouse;

typedef struct Event_window
{
	short                   Id;
}Event_window;

typedef struct Event_button
{
	short                   Button,
	                        Shift;
}Event_button;

typedef struct
{
	long    type;
	union
	{
		short               Data[16];  // EVENT_OTHER;
		Event_menu          Menu_data;
		Event_key           Key_data;
		Event_mouse         Mouse_data;
		Event_window        Window_data;
		Event_button        Button_data;
	};
}EVENT_DATA;

/*XYZZYX SYSTEM DEPENDENT DATA */
typedef struct
{
	short mo_x,           /* X-coord for mouse in EventNutton          */        
	      mo_y,           /* Y-coord for mouse in EventButton          */
	      mo_b,           /* Button-state for mouse in EventButton     */
	      key,            /* Key-state in Eventmulti                   */
	      k_s,            /* Key-Shift-state in Eventmulti             */
	      m_r;            /* number of Mouseclicks in Eventmulti       */
	int   check,          /*                                           */
	      end,            /*                                           */
	      count,          /* Temporary counter                         */
	      active,         /* Internal Number of Active Window          */
	      found;          /* Window has Been found (In internal List)  */
	short w1,w2,w3,w4;    /* Temporary Window-coords (for updating)    */
	short d1,d2,d3,d4;    /* Temporary Window-coords (For updating)    */
	short xy[4];          /* Temporary Window-coords (For updating)    */
	short data[16];       /* Messages with Evnt-Multi                  */
} HANDLER_DATA;

/*************************************************************************************************************************/
/*************************************************************************************************************************/

#endif