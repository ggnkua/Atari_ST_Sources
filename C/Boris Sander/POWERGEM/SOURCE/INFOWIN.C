/* ---------------------------------------------------------------------- */
/* Fenster: Information                                                   */
/* ---------------------------------------------------------------------- */
#include <aes.h>
#include "header.h"
#include "demo.h"
#include "powergem.h"

/* ---------------------------------------------------------------------- */
/* Fenster erzeugen und ”ffnen                                            */
/* ---------------------------------------------------------------------- */
void show_info()
{ 
	struct WINDOW *info;
	
	info = create_dial(MELDUNG, 0, NAME|CLOSER|MOVER, 0, 0, 0, 0);
	if (info)
	{
		button_action(info, BOAHEYH, break_dial, FALSE);
		open_window(info, "Information", 0);
	}
}
