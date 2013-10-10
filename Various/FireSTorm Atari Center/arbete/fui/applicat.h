#ifndef  _FUI_Appl
#define  _FUI_Appl
#ifndef  _Window
#include "window.h"
#endif

typedef struct Application
{
	RO_Font font;
	Window_entry *first;
	Window_entry *current;
	short appl_id,graph_id;
	short screenx,screeny,screenw,screenh;
}Application;

extern Application *appl;
#endif