

#include "flicker.h"
#include "flicmenu.h"

extern see_number_slider(), feel_number_slider(), white_slice(),
	change_dev(), wbtextx2(), load_patch(), 
	left_arrow(), right_arrow(), inc_slider(), dec_slider(),
	yellow_block(), black_block(),
	save_patch(), new_patch(), page_patch(),
	change_patch_type(), wbtext(), flash_red();
extern WORD current_drive;
extern char rd_name[];

WORD patch_file_type = SEQ;


#define DEVY (147+1+(11+2)*3)
#define DEVDY 11
#define DEVDX 18
#define DEVX1 87 

struct flicmenu ptc_save =
	{
	NONEXT,
	NOCHILD,
	11*(14+2)+DEVX1+10, DEVY,	45, DEVDY,
	"Save",
	wbtext,
	save_patch,
	NOGROUP, 0,
	};
struct flicmenu ptc_page =
	{
	&ptc_save,
	NOCHILD,
	11*(14+2)+DEVX1-57+20, DEVY,	45, DEVDY,
	"Page",
	wbtext,
	page_patch,
	NOGROUP, 0,
	};
struct flicmenu ptc_pad =
	{
	&ptc_page,
	NOCHILD,
	43, DEVY,	319-3*(55+2)-2+35, DEVDY,
	rd_name,
	wbtext,
	NOFEEL,
	NOGROUP, 0,
	};
struct flicmenu ptc_new =
	{
	&ptc_pad,
	NOCHILD,
	1, DEVY,	40, DEVDY,
	"New",
	wbtext,
	new_patch,
	NOGROUP, 0,
	};

#define DEVXA 1

struct flicmenu ptc_load =
	{
	NONEXT,
	NOCHILD,
	11*(DEVDX+2)+DEVXA, DEVY,	97, DEVDY,
	"Load Patch",
	wbtext,
	load_patch,
	NOGROUP, 0,
	};
struct flicmenu pd010 =
	{
	&ptc_load,
	NOCHILD,
	10*(DEVDX+2)+DEVXA, DEVY,	DEVDX, DEVDY,
	"K:",
	wbtextx2,
	change_dev,
	&current_drive, 10,
	};
struct flicmenu pd009 =
	{
	&pd010,
	NOCHILD,
	9*(DEVDX+2)+DEVXA, DEVY,	DEVDX, DEVDY,
	"J:",
	wbtextx2,
	change_dev,
	&current_drive, 9,
	};
struct flicmenu pd008 =
	{
	&pd009,
	NOCHILD,
	8*(DEVDX+2)+DEVXA, DEVY,	DEVDX, DEVDY,
	"I:",
	wbtextx2,
	change_dev,
	&current_drive, 8,
	};
struct flicmenu pd007 =
	{
	&pd008,
	NOCHILD,
	7*(DEVDX+2)+DEVXA, DEVY,	DEVDX, DEVDY,
	"H:",
	wbtextx2,
	change_dev,
	&current_drive, 7,
	};
struct flicmenu pd006 =
	{
	&pd007,
	NOCHILD,
	6*(DEVDX+2)+DEVXA, DEVY,	DEVDX, DEVDY,
	"G:",
	wbtextx2,
	change_dev,
	&current_drive, 6,
	};
struct flicmenu pd005 =
	{
	&pd006,
	NOCHILD,
	5*(DEVDX+2)+DEVXA, DEVY,	DEVDX, DEVDY,
	"F:",
	wbtextx2,
	change_dev,
	&current_drive, 5,
	};
struct flicmenu pd004 =
	{
	&pd005,
	NOCHILD,
	4*(DEVDX+2)+DEVXA, DEVY,	DEVDX, DEVDY,
	"E:",
	wbtextx2,
	change_dev,
	&current_drive, 4,
	};
struct flicmenu pd003 =
	{
	&pd004,
	NOCHILD,
	3*(DEVDX+2)+DEVXA, DEVY,	DEVDX, DEVDY,
	"D:",
	wbtextx2,
	change_dev,
	&current_drive, 3,
	};
struct flicmenu pd002 =
	{
	&pd003,
	NOCHILD,
	2*(DEVDX+2)+DEVXA, DEVY,	DEVDX, DEVDY,
	"C:",
	wbtextx2,
	change_dev,
	&current_drive, 2,
	};
struct flicmenu pd001 =
	{
	&pd002,
	NOCHILD,
	1*(DEVDX+2)+DEVXA, DEVY,	DEVDX, DEVDY,
	"B:",
	wbtextx2,
	change_dev,
	&current_drive, 1,
	};
struct flicmenu pd000 =
	{
	&pd001,
	NOCHILD,
	0*(DEVDX+2)+DEVXA, DEVY,	DEVDX, DEVDY,
	"A:",
	wbtextx2,
	change_dev,
	&current_drive, 0,
	};

struct flicmenu ptc_load_switch =
	{
	NONEXT,
	&pd000,
	1, DEVY, 317, 11,
	NOTEXT,
	NOSEE,
	NOFEEL,
	NOGROUP, 0,
	};
struct slidepot pmemory_sl =
	{
	0, 0, -1,
	};
extern struct flicmenu ptc_memory;
struct flicmenu ptc_rmemory = 
	{
	&ptc_load_switch,
	NOCHILD,
	319-13, 147+1+(11+2)*2, 12, 11,
	(char *)&ptc_memory,
	right_arrow,
	inc_slider,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu ptc_memory =
	{
	&ptc_rmemory,
	NOCHILD,
	61+14, 147+1+(11+2)*2, 257-2*14, 11,
	(char *)&pmemory_sl,
	see_number_slider,
	feel_number_slider,
	NOGROUP, 0,
	};
struct flicmenu ptc_lmemory = 
	{
	&ptc_memory,
	NOCHILD,
	61, 147+1+(11+2)*2, 12, 11,
	(char *)&ptc_memory,
	left_arrow,
	dec_slider,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu ptc002a =
	{
	&ptc_lmemory,
	NOCHILD,
	1, 147+1+(11+2)*2, 58, 11,
	"KBytes",
	wbtext,
	NOFEEL,
	NOGROUP, 0,
	};
struct slidepot pframes_sl =
	{
	0,
	2047,
	99,
	};
extern struct flicmenu ptc_frames;
struct flicmenu ptc_rframes = 
	{
	&ptc002a,
	NOCHILD,
	319-13, 147+1+(11+2)*1, 12, 11,
	(char *)&ptc_frames,
	right_arrow,
	inc_slider,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu ptc_frames =
	{
	&ptc_rframes,
	NOCHILD,
	61+14, 147+1+(11+2)*1, 257-2*14, 11,
	(char *)&pframes_sl,
	see_number_slider,
	feel_number_slider,
	NOGROUP, 0,
	};
struct flicmenu ptc_lframes = 
	{
	&ptc_frames,
	NOCHILD,
	61, 147+1+(11+2)*1, 12, 11,
	(char *)&ptc_frames,
	left_arrow,
	dec_slider,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu ptc001a =
	{
	&ptc_lframes,
	NOCHILD,
	1, 147+1+(11+2)*1, 58, 11,
	"Frames",
	wbtext,
	NOFEEL,
	NOGROUP, 0,
	};
struct slidepot pstart_sl =
	{
	0,
	2047,
	0,
	};
extern struct flicmenu ptc_start;
struct flicmenu ptc_rstart = 
	{
	&ptc001a,
	NOCHILD,
	319-13, 147+1, 12, 11,
	(char *)&ptc_start,
	right_arrow,
	inc_slider,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu ptc_start =
	{
	&ptc_rstart,
	NOCHILD,
	61+14, 147+1, 257-2*14, 11,
	(char *)&pstart_sl,
	see_number_slider,
	feel_number_slider,
	NOGROUP, 0,
	};
struct flicmenu ptc_lstart = 
	{
	&ptc_start,
	NOCHILD,
	61, 147+1, 12, 11,
	(char *)&ptc_start,
	left_arrow,
	dec_slider,
	NOGROUP, 0,
	NOKEY,
	};
struct flicmenu ptc000a =
	{
	&ptc_lstart,
	NOCHILD,
	1, 147+1, 58, 11,
	"Start",
	wbtext,
	NOFEEL,
	NOGROUP, 0,
	};
struct flicmenu menupatch = 
	{
	NONEXT,
	&ptc000a,
	0, 147,	319, 52,
	NOTEXT,
	white_slice,
	NOFEEL,
	NOGROUP, 0,
	};
