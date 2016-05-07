#include <aes.h>

#include "HighWire.h"

enum bool
process_messages(struct frame_item *first_frame)
{
	short wx,wy,ww,wh;
	switch (event_messages[0])
	{
		case WM_MOVED:
			wind_set(event_messages[3],WF_CURRXYWH,event_messages[4],event_messages[5],event_messages[6],event_messages[7]);
			calculate_frame_locations();
			break;
		case WM_SIZED:
			wind_get(window_handle,WF_WORKXYWH,&wx,&wy,&ww,&wh);
			wind_set(event_messages[3],WF_CURRXYWH,event_messages[4],event_messages[5],event_messages[6],event_messages[7]);
			calculate_frame_locations();
		case WM_REDRAW:
			redraw(event_messages[3],event_messages[4],event_messages[5],event_messages[6],event_messages[7],first_frame);
			break;
		case WM_CLOSED:
		case AP_TERM:
			return(true);
			break;
		case WM_TOPPED:
			wind_set(window_handle,WF_TOP,event_messages[3],0,0,0);
			break;
		case WM_FULLED:
			wind_get(0,WF_WORKXYWH,&wx,&wy,&ww,&wh);
			wind_set(event_messages[3],WF_CURRXYWH,wx,wy,ww,wh);
			calculate_frame_locations();
			break;
		case WM_BOTTOM:
			wind_set(window_handle,WF_BOTTOM,event_messages[3],0,0,0);
			break;
		case WM_ICONIFY:
		case WM_UNICONIFY:
			break;
	}
	return(false);
}
