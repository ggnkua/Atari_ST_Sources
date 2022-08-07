
struct selection
{
	
	WORD   x_min_pos;	/* position of collision box */
	WORD	y_min_pos;
	WORD	x_max_pos;
	WORD	y_max_pos;
	 
	WORD   is_selected;

	char	*display_data;		/* icon title string */	
	WORD   display_mode;
	int     (*display_function)();

	char    *function_data;
	WORD   function_case;
	int	(*function)();

	char *double_data;
	int (*double_function)();

	char *help_data;
	int (*help_function)();
};

struct menu
{
WORD visible;
WORD redraw_flag;
WORD xoff, yoff;
WORD width, height;
WORD sel_count;
WORD sel_alloc;
struct selection *sel_list;
struct virtual_input *(*with_input)();
WORD meta;
WORD help;
};


#define NO_CASE 255
#define NO_DATA NULL

#define FIRST_TIME 0
#define EVERY_TIME 1
#define ONE_OF 2
/*defs for display_case*/

#define DISPLAY_ONLY 0
#define GO_SUBBER 1
#define GO_SUB_REDRAW 2
#define GO_SUB_REMENU 3
#define DISAPPEAR_MENU 4
#define DOUBLE 5
#define NO_HI_GOSUB 6
#define STORY 7
#define VROUTINE 8
#define SROUTINE 9
#define COMENU 10
#define RETURN_SOMETHING 11
#define HELP 12
#define DISABLED 13	/*and unlucky too!*/
/*defs for sel->function_case*/

#define NO_DOUBLE 0
#define NO_HELP 0
#define NO_SFUNCTION NULL
#define NO_SDATA	NULL

extern struct selection morph_table[];
extern struct selection *cur_sel;


struct slider
	{
	char * string;
	long scale;
	long value;
	};

struct n_slider
	{
	char * string;
	long scale;
	long value;
	long usual;
	};
/*same as slider, but display a tick a default value*/

struct select_column
    {
    struct name_list *name_list;
    WORD name_count;
    WORD top_name;
    WORD selected;
    WORD names_visible;
    };

struct cursor_box
    {
    struct cursor *cursor;
    WORD color;
    };

struct cursor_text
	{
	struct cursor *cursor;
	char *text;
	};

    
struct one_of
    {
    WORD *which_one;
    WORD i_am;
    char *display_data;
    };


extern int back_color, fore_color, hi_color, grey_color;

#define NOSWAP_CONT 1
#define MOVE_MENU 2
#define REDRAW_EVERY 4
/* bits for nested parameter to main_menu_driver(control, nested) */
