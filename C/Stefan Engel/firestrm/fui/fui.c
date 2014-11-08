#include <stdio.h>
#include "dialog.h"
#include "window.h"

/*************************************************************************************************************************/
/*************************************************************************************************************************/
extern RO_Object objects[];
Window main_wind , second_wind;
short appl_id , graph_id;

/*************************************************************************************************************************/
/*************************************************************************************************************************/
int main(void)
{
	init_appl( &appl_id, &graph_id );

	main_wind.Status=WINDOW_STATUS_CLOSED;
	main_wind.Flags=WINDOW_FLAGS_CENTER|WINDOW_FLAGS_CLOSE|WINDOW_FLAGS_HIDE|WINDOW_FLAGS_TITLEBAR|WINDOW_FLAGS_MOVE|WINDOW_FLAGS_FULL|WINDOW_FLAGS_ICONIZE;
	strcpy(main_wind.Title,"Window Title");
	main_wind.Root=&objects[ 1 ];
	
	open_window(&main_wind);

	event_window();

	close_window(&main_wind);

	deinit_appl();
	return 0; 
}

