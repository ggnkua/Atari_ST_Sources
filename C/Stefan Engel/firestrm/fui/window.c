/*************************************************************************************************************************/
/*************************************************************************************************************************/
#include <aes.h>
#include <vdi.h>
#include <osbind.h>
#include "window.h"
#include "error.h"
#include "applicat.h"
#include "..\info\vaproto\vaproto.h"

/*************************************************************************************************************************/
/*************************************************************************************************************************/
HANDLER_DATA handler;
long timer = - 1;
EVENT_DATA event;

/*************************************************************************************************************************/
/*************************************************************************************************************************/
void _fix_message( HANDLER_DATA *handler, EVENT_DATA *event);
void _fix_key( HANDLER_DATA *handler, EVENT_DATA *event);
void _fix_timer( HANDLER_DATA *handler, EVENT_DATA *event);
void _fix_button( HANDLER_DATA *handler, EVENT_DATA *event);
void _fix_mouse( HANDLER_DATA *handler, EVENT_DATA *event);
void _redraw_wind(Window_entry *wind, short xy[4]);
int  _check_buttonpress(RO_Object *object , int x , int y);
/*************************************************************************************************************************/
/*************************************************************************************************************************/
Window_entry *_find_window(short Ident)
{
	Window_entry *current = appl->first;

	while ( current )
	{
		if( current->window->Ident == Ident )
		{
			return current;
		}
	}
	return 0;
}
/*************************************************************************************************************************/
/*************************************************************************************************************************/
void open_window( Window *window )
{
	short dummy=0;
	if( ! window->s.Opened )
	{
		/* XYZZYX SYSTEM DEPENDENT CALL */
		window->Ident = wind_create( 0 , appl->screenx , appl->screeny , appl->screenw , appl->screenh );
		if( window->Ident > 0 )
		{
			if(appl->first==0)
			{
				appl->first = ( Window_entry *) Malloc( sizeof( Window_entry ) );
				if( ! appl->first )
				{
					wind_delete( window->Ident );
					window->Ident = -1;
					return ;
				}
		  		memset( appl->first , 0 , sizeof( Window_entry ) );

				appl->current = appl->first;
			}
			else
			{
				Window_entry *current=appl->first;
				while(current->next)
					current = current->next;
				current->next = ( Window_entry *) Malloc( sizeof( Window_entry ) );
				if( ! current->next )
				{
					wind_delete( window->Ident );
					window->Ident = -1;
					return ;
				}
		  		memset( current->next , 0 , sizeof( Window_entry ) );
				appl->current = current->next;
			}
			appl->current->window=window;
			_create_window( appl->current );
			
			calculate_small_size( appl->current->wind_object );
			if( window->w < appl->current->wind_object->internal.w )   window->w = appl->current->wind_object->internal.w;
			if( window->h < appl->current->wind_object->internal.h )   window->h = appl->current->wind_object->internal.h;
			if( window->x + window->w > appl->screenw )                    window->x = appl->screenw - window->w;
			if( window->y + window->h > appl->screenh )                    window->h = appl->screenh - window->h;
			if( window->x < appl->screenx )                                window->x = appl->screenx;
			if( window->y < appl->screeny )                                window->y = appl->screeny;
			if( window->w > appl->screenw )                                window->w = appl->screenw;
			if( window->h > appl->screenh )                                window->h = appl->screenh;
			calculate_new_size( appl->current->wind_object , window->w , window->h );
			if( window->f.Center )
			{
				window->x = appl->screenx + ( appl->screenw >> 1 ) - ( window->w >> 1 );
				window->y = appl->screeny + ( appl->screenh >> 1 ) - ( window->h >> 1 );
			}
			calculate_xy_pos( appl->current->wind_object , 0, 0 );
			/* XYZZYX SYSTEM DEPENDENT CALL */
			dummy=wind_open( window->Ident , window->x , window->y , window->w , window->h );
			window->s.Opened = 1;
		}
		else
		{
		
		}
	}
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
void close_window( Window *window )
{
	Window_entry *current = appl->first;
	Window_entry *last = 0;
	
	while ( current )
	{
		if( current->window->Ident == window->Ident )
		{
			if( last )
			{
				last->next = current->next;
			}
			if(current == appl->current )
			{
				if( last )
				{
					appl->current = last->next;
				}
				else
				{
					appl->current = last;
				}
			}
			Mfree( current );
			if( current == appl->first )
			{
				appl->first = 0;
			}
				
			window->Status = WINDOW_STATUS_CLOSED;
		    wind_close( window->Ident );
    		wind_delete( window->Ident );
		}
		last = current;
		current = current->next;
	}
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
EVENT_DATA event_window()
{
	short mouse_x , mouse_y , dummy ;
	handler.check = 0;
	handler.end = 0;
	do
	{
		if( ! handler.check )
		{
			graf_mkstate( &mouse_x , &mouse_y, &dummy, &dummy );
			if( timer >= 0)
				handler.check = evnt_multi(MU_M1|MU_KEYBD|MU_BUTTON|MU_MESAG|MU_TIMER,
				                           258,MO_LEFT|MO_RIGHT,0,
				                           1,mouse_x,mouse_y,1,1,
				                           0,0,0,0,0,
				                           handler.data,timer&65535,timer>>16,
				                           &handler.mo_x,&handler.mo_y,&handler.mo_b,&handler.k_s,&handler.key, &handler.m_r);
			else
				handler.check=evnt_multi(MU_M1|MU_KEYBD|MU_BUTTON|MU_MESAG,
				                         258,MO_LEFT|MO_RIGHT,0,
				                         1,mouse_x,mouse_y,1,1,
				                         0,0,0,0,0,
				                         handler.data,0,0,
				                         &handler.mo_x,&handler.mo_y,&handler.mo_b,&handler.k_s,&handler.key,&handler.m_r);
		}
		if( handler.check & MU_MESAG )         _fix_message( &handler , &event );
		else if( handler.check & MU_TIMER )    _fix_timer( &handler , &event );
		else if( handler.check & MU_KEYBD )    _fix_key( &handler , &event );
		else if( handler.check & MU_BUTTON )   _fix_button( &handler , &event );
		else if( handler.check & MU_M1 )       _fix_mouse( &handler , &event );
		if( handler.end )                      return( event );

	} while( 1 );
	return ( event ) ; // this row should never be executed
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
void _fix_message( HANDLER_DATA *handler, EVENT_DATA *event)
{
	Window_entry *wind;
	handler->check&=~MU_MESAG;
	switch( handler->data[0] )
	{
		case MN_SELECTED:
			break;
		case WM_ONTOP:
			break;
		case WM_UNTOPPED:
			break;
		case WM_NEWTOP:
			break;
		case WM_CLOSED:
			break;
		case WM_FULLED:
			break;
		case WM_SIZED:
			wind=_find_window(handler->data[3]);
			if(wind)
			{
				appl->current->window->x = handler->data[ 4 ];
				appl->current->window->y = handler->data[ 5 ];
				appl->current->window->w = handler->data[ 6 ];
				appl->current->window->h = handler->data[ 7 ];
				calculate_small_size( appl->current->wind_object );
				calculate_new_size( appl->current->wind_object , appl->current->window->w , appl->current->window->h );
				calculate_xy_pos( appl->current->wind_object , 0, 0 );
				_redraw_wind(wind,&(handler->data[4]));
			}
			break;
		case WM_ARROWED:
			break;
		case WM_HSLID:
			break;
		case WM_VSLID:
			break;
		case WM_ICONIFY:
			break;
		case WM_UNICONIFY:
			break;
		case WM_TOPPED:
			wind=_find_window(handler->data[3]);
			if(wind)
          		wind_set(wind->window->Ident,WF_TOP,wind->window->Ident,0,0,0);
			break;
		case WM_MOVED:
			break;
		case WM_REDRAW:
			wind=_find_window(handler->data[3]);
			if(wind)
				_redraw_wind(wind,&(handler->data[4]));
			break;
		case SH_WDRAW: /* what does this do? */
			break;
		case 0x5758:  /* Magic: "Show only Title-Bar" On  */
			break;
		case 0x5759:  /* Magic: "Show only Title-Bar" Off */
			break;
		case AV_SENDKEY:
			break;
		case 0x7a18:   /* FONT_CHANGED */
			wind=_find_window(handler->data[3]);
			if(wind)
			{
				short dummy;
				appl->font.Id = handler->data[ 4 ];
				appl->font.Size = handler->data[ 5 ];
				appl->font.Colour = handler->data[ 6 ];
				appl->font.Effects = handler->data[ 7 ];
				
				vst_font( appl->graph_id , handler->data[ 4 ] );
				if( handler->data[ 5 ] > 0 )
					vst_point( appl->graph_id , handler->data[ 5 ] , &dummy , &dummy , &dummy , &dummy );
				else
					vst_height( appl->graph_id , - handler->data[ 5 ] , &dummy , &dummy , &dummy , &dummy );
				vst_effects( appl->graph_id , handler->data[ 7 ] );

				calculate_small_size( wind->wind_object );
				if( wind->window->w > appl->screenw )
					wind->window->w = appl->screenw;
				if( wind->window->h > appl->screenh )
					wind->window->h = appl->screenh;
				if( wind->wind_object->internal.w > wind->window->w )
				{
					wind->window->x -= ( wind->wind_object->internal.w - wind->window->w ) / 2;
					wind->window->w = wind->wind_object->internal.w;
				}
				if( wind->wind_object->internal.h > wind->window->h )
				{
					wind->window->y -= ( wind->wind_object->internal.h - wind->window->h ) / 2;
					wind->window->h = wind->wind_object->internal.h;
				}	
				if( wind->window->x < appl->screenx )
					wind->window->x = appl->screenx;
				if( wind->window->y < appl->screeny )
					wind->window->y = appl->screeny;
				calculate_new_size( wind->wind_object , wind->window->w , wind->window->h );
				calculate_xy_pos( wind->wind_object , 0, 0 );
				wind_set( wind->window->Ident , WF_CXYWH , wind->window->x , wind->window->y , wind->window->w , wind->window->h );
				_redraw_wind( wind , 0 );
				
			}
			break;
		default:
			break;
	}
}
/*************************************************************************************************************************/
/*************************************************************************************************************************/
void _fix_timer( HANDLER_DATA *handler, EVENT_DATA *event)
{
	handler->check &= ~MU_TIMER;
}
/*************************************************************************************************************************/
/*************************************************************************************************************************/
void _fix_key( HANDLER_DATA *handler, EVENT_DATA *event)
{
	handler->check &= ~MU_KEYBD;
}
/*************************************************************************************************************************/
/*************************************************************************************************************************/
void _fix_button( HANDLER_DATA *handler, EVENT_DATA *event)
{
	handler->check &= ~MU_BUTTON;
	if( ( handler->mo_b == MO_LEFT ) && ( handler->m_r == 1 ) && ( handler->k_s == 0 ) )
	{
		short mouse_x , mouse_y , dummy ;
		short xy[ 10 ];
		short xy2[ 4 ];
		HANDLER_DATA h2;

		xy[ 0 ] = appl->current->window->x;
		xy[ 1 ] = appl->current->window->y;
		xy[ 2 ] = xy[ 0 ]+ appl->current->window->w - 1;
		xy[ 3 ] = xy[ 1 ];
		xy[ 4 ] = xy[ 0 ] + appl->current->window->w - 1;
		xy[ 5 ] = xy[ 1 ] + appl->current->window->h - 1;
		xy[ 6 ] = xy[ 0 ];
		xy[ 7 ] = xy[ 1 ] + appl->current->window->h - 1;
		xy[ 8 ] = xy[ 0 ];
		xy[ 9 ] = xy[ 1 ];
		h2.end = 0;
		h2.check = 0;
		if(appl->current->move)
		{
			wind_update(BEG_UPDATE);
			vswr_mode( appl->graph_id , 3 );
			graf_mouse(256,0);
			v_pline( appl->graph_id , 5 , xy );
			graf_mouse(257,0);
			while( ! h2.end)
			{
			    graf_mkstate( &mouse_x , &mouse_y, &dummy, &dummy );
				if( ! h2.check )
					h2.check = evnt_multi(MU_M1|MU_BUTTON,1,MO_LEFT,0,1,mouse_x,mouse_y,1,1,0,0,0,0,0,0,0,0,&h2.mo_x,&h2.mo_y,&h2.mo_b,&h2.k_s,&h2.key,&h2.m_r);
				if( h2.check & MU_M1 )
				{
					h2.check &= ~MU_M1;
					graf_mouse(256,0);
					v_pline( appl->graph_id , 5 , xy );

					if( h2.mo_x < appl->screenx )
						h2.mo_x = appl->screenx;
					else if ( h2.mo_x > appl->screenx + appl->screenw -1 )
						h2.mo_x = appl->screenx + appl->screenw -1;
					if( h2.mo_y < appl->screeny )
						h2.mo_y = appl->screeny;
					else if ( h2.mo_y > appl->screeny + appl->screenh -1 )
						h2.mo_y = appl->screeny + appl->screenh -1;

					if( appl->current->move & MOVE_LEFT )
					{
						if( xy[ 2 ] - h2.mo_x > appl->current->wind_object->internal.min_w + 1 )
							xy[ 0 ] = h2.mo_x;
						else
							xy[ 0 ] = xy[ 2 ] - appl->current->wind_object->internal.min_w + 1;
						xy[ 6 ] = xy[ 0 ];
						xy[ 8 ] = xy[ 0 ];
					}
					else if( appl->current->move & MOVE_RIGHT )
					{
						if( h2.mo_x - xy[ 0 ] > appl->current->wind_object->internal.min_w - 1 )
							xy[ 2 ] = h2.mo_x;
						else
							xy[ 2 ] = xy[ 0 ] + appl->current->wind_object->internal.min_w - 1;
						xy[ 4 ] = xy[ 2 ];
						
					}
					if( appl->current->move & MOVE_TOP )
					{
						if( xy[ 5 ] - h2.mo_y > appl->current->wind_object->internal.min_h + 1 )
							xy[ 1 ] = h2.mo_y;
						else
							xy[ 1 ] = xy[ 5 ] - appl->current->wind_object->internal.min_h + 1;
						xy[ 3 ] = xy[ 1 ];
						xy[ 9 ] = xy[ 1 ];
					}
					else if( appl->current->move & MOVE_BOTTOM )
					{
						if( h2.mo_y - xy[ 1 ] > appl->current->wind_object->internal.min_h - 1 )
							xy[ 5 ] = h2.mo_y;
						else
							xy[ 5 ] = xy[ 1 ] + appl->current->wind_object->internal.min_h - 1;
						xy[ 7 ] = xy[ 5 ];
					}
					v_pline( appl->graph_id , 5 , xy );
					graf_mouse(257,0);
				}
				else if( h2.check & MU_BUTTON )
				{
					graf_mouse(256,0);
					v_pline( appl->graph_id , 5 , xy );
					graf_mouse(257,0);
					vswr_mode( appl->graph_id , 1 );
					wind_update(END_UPDATE);
					h2.check &= ~MU_BUTTON;
					xy[ 2 ] = xy[ 2 ] - xy[ 0 ] + 1;
					xy[ 3 ] = xy[ 5 ] - xy[ 1 ] + 1;
					appl->current->window->x = xy[ 0 ];
					appl->current->window->y = xy[ 1 ];
					appl->current->window->w = xy[ 2 ];
					appl->current->window->h = xy[ 3 ];
					calculate_small_size( appl->current->wind_object );
					calculate_new_size( appl->current->wind_object , appl->current->window->w , appl->current->window->h );
					calculate_xy_pos( appl->current->wind_object , 0, 0 );
					wind_set( appl->current->window->Ident , WF_CXYWH , xy[ 0 ] , xy[ 1 ] , xy[ 2 ] , xy[ 3 ] );
					_redraw_wind(appl->current,xy);
					h2.end = 1;
				}
			}
			return;
		}
		if((appl->current->window->f.Move)&&(appl->current->obj_move))
		{
			xy2[ 0 ] = appl->current->obj_move->internal.x + appl->current->window->x - handler->mo_x;
			xy2[ 1 ] = appl->current->obj_move->internal.y + appl->current->window->y - handler->mo_y;
			xy2[ 2 ] = xy2[ 0 ] + appl->current->obj_move->internal.w;
			xy2[ 3 ] = xy2[ 1 ] + appl->current->obj_move->internal.h;
			if (((xy2[0]<=0) && (xy2[2] >= 0))&&((xy2[1]<0)&&(xy2[3]>0)))
			{
				xy2[ 0 ] = appl->current->window->x - handler->mo_x;
				xy2[ 1 ] = appl->current->window->y - handler->mo_y;
				wind_update(BEG_UPDATE);
				appl->current->obj_move->Button->flags.Selected = 1 ;
				graf_mouse(256,0);
				draw_object(appl->current->obj_move,appl->current->window->x,appl->current->window->y);
				vswr_mode( appl->graph_id , 3 );
				v_pline( appl->graph_id , 5 , xy );
				graf_mouse(257,0);
				while( ! h2.end)
				{
				    graf_mkstate( &mouse_x , &mouse_y, &dummy, &dummy );
					if( ! h2.check )
						h2.check = evnt_multi(MU_M1|MU_BUTTON,1,MO_LEFT,0,1,mouse_x,mouse_y,1,1,0,0,0,0,0,0,0,0,&h2.mo_x,&h2.mo_y,&h2.mo_b,&h2.k_s,&h2.key,&h2.m_r);
					if( h2.check & MU_M1 )
					{
						h2.check &= ~MU_M1;
						graf_mouse(256,0);
						v_pline( appl->graph_id , 5 , xy );

						xy[ 0 ] = h2.mo_x + xy2[ 0 ];
						xy[ 1 ] = h2.mo_y + xy2[ 1 ];
						if( xy[ 0 ] < appl->screenx )
							xy[ 0 ] = appl->screenx;
						else if ( xy[ 0 ] > appl->screenx + appl->screenw -1 )
							xy[ 0 ] = appl->screenx + appl->screenw -1;
						if( xy[ 1 ] < appl->screeny )
							xy[ 1 ] = appl->screeny;
						else if ( xy[ 1 ] > appl->screeny + appl->screenh -1 )
							xy[ 1 ] = appl->screeny + appl->screenh -1;
						xy[ 2 ] = xy[ 0 ]+ appl->current->window->w - 1;
						xy[ 3 ] = xy[ 1 ];
						xy[ 4 ] = xy[ 0 ] + appl->current->window->w - 1;
						xy[ 5 ] = xy[ 1 ] + appl->current->window->h - 1;
						xy[ 6 ] = xy[ 0 ];
						xy[ 7 ] = xy[ 1 ] + appl->current->window->h - 1;
						xy[ 8 ] = xy[ 0 ];
						xy[ 9 ] = xy[ 1 ];
						v_pline( appl->graph_id , 5 , xy );
						graf_mouse(257,0);
					}
					else if( h2.check & MU_BUTTON )
					{
						graf_mouse(256,0);
						v_pline( appl->graph_id , 5 , xy );
						graf_mouse(257,0);
						h2.check &= ~MU_BUTTON;
						appl->current->window->x = xy[ 0 ];
						appl->current->window->y = xy[ 1 ];
						xy[ 2 ] = appl->current->window->w;
						xy[ 3 ] = appl->current->window->h;
						wind_set( appl->current->window->Ident , WF_CXYWH , xy[ 0 ] , xy[ 1 ] , xy[ 2 ] , xy[ 3 ] );
						vswr_mode( appl->graph_id , 1 );
						graf_mouse(256,0);
						appl->current->obj_move->Button->flags.Selected = 0 ;
						draw_object(appl->current->obj_move,appl->current->window->x,appl->current->window->y);
						wind_update(END_UPDATE);
						graf_mouse(257,0);
						h2.end = 1;
					}
				}
				return;
			}
		}
		if((appl->current->window->f.Close)&&(appl->current->obj_close))
		{
			xy2[ 0 ] = appl->current->obj_close->internal.x + appl->current->window->x - handler->mo_x;
			xy2[ 1 ] = appl->current->obj_close->internal.y + appl->current->window->y - handler->mo_y;
			xy2[ 2 ] = xy2[ 0 ] + appl->current->obj_close->internal.w;
			xy2[ 3 ] = xy2[ 1 ] + appl->current->obj_close->internal.h;
			if (((xy2[0]<=0) && (xy2[2] >= 0))&&((xy2[1]<0)&&(xy2[3]>0)))
			{
				if(_check_buttonpress( appl->current->obj_close , appl->current->window->x , appl->current->window->y ))
				{
					handler->end = 1;
				}
				return;
			}
		}
		if((appl->current->window->f.Full)&&(appl->current->obj_full))
		{
			xy2[ 0 ] = appl->current->obj_full->internal.x + appl->current->window->x - handler->mo_x;
			xy2[ 1 ] = appl->current->obj_full->internal.y + appl->current->window->y - handler->mo_y;
			xy2[ 2 ] = xy2[ 0 ] + appl->current->obj_full->internal.w;
			xy2[ 3 ] = xy2[ 1 ] + appl->current->obj_full->internal.h;
			if ((appl->current->window->f.Full ) && ((xy2[0]<=0) && (xy2[2] >= 0))&&((xy2[1]<0)&&(xy2[3]>0)))
			{
				if(_check_buttonpress( appl->current->obj_full , appl->current->window->x , appl->current->window->y ))
				{
					appl->current->window->x = appl->screenx;
					appl->current->window->y = appl->screeny;
					appl->current->window->w = appl->screenw;
					appl->current->window->h = appl->screenh;
					calculate_small_size( appl->current->wind_object );
					calculate_new_size( appl->current->wind_object , appl->current->window->w , appl->current->window->h );
					calculate_xy_pos( appl->current->wind_object , 0, 0 );
					wind_set( appl->current->window->Ident , WF_CXYWH , appl->current->window->x , appl->current->window->y , appl->current->window->w , appl->current->window->h );
					_redraw_wind(appl->current,xy);
				}
				return;
			}
		}
		if((appl->current->window->f.Hide)&&(appl->current->obj_hide))
		{
			xy2[ 0 ] = appl->current->obj_hide->internal.x + appl->current->window->x - handler->mo_x;
			xy2[ 1 ] = appl->current->obj_hide->internal.y + appl->current->window->y - handler->mo_y;
			xy2[ 2 ] = xy2[ 0 ] + appl->current->obj_hide->internal.w;
			xy2[ 3 ] = xy2[ 1 ] + appl->current->obj_hide->internal.h;
			if ((appl->current->window->f.Hide ) && ((xy2[0]<=0) && (xy2[2] >= 0))&&((xy2[1]<0)&&(xy2[3]>0)))
			{
				if(_check_buttonpress( appl->current->obj_hide , appl->current->window->x , appl->current->window->y ))
				{
				}
				return;
			}
		}
		if((appl->current->window->f.Back)&&(appl->current->obj_back))
		{
			xy2[ 0 ] = appl->current->obj_back->internal.x + appl->current->window->x - handler->mo_x;
			xy2[ 1 ] = appl->current->obj_back->internal.y + appl->current->window->y - handler->mo_y;
			xy2[ 2 ] = xy2[ 0 ] + appl->current->obj_back->internal.w;
			xy2[ 3 ] = xy2[ 1 ] + appl->current->obj_back->internal.h;
			if ((appl->current->window->f.Back ) && ((xy2[0]<=0) && (xy2[2] >= 0))&&((xy2[1]<0)&&(xy2[3]>0)))
			{
				if(_check_buttonpress( appl->current->obj_back , appl->current->window->x , appl->current->window->y ))
				{
				}
				return;
			}
		}
		if((appl->current->window->f.Iconize)&&(appl->current->obj_icon))
		{
			xy2[ 0 ] = appl->current->obj_icon->internal.x + appl->current->window->x - handler->mo_x;
			xy2[ 1 ] = appl->current->obj_icon->internal.y + appl->current->window->y - handler->mo_y;
			xy2[ 2 ] = xy2[ 0 ] + appl->current->obj_icon->internal.w;
			xy2[ 3 ] = xy2[ 1 ] + appl->current->obj_icon->internal.h;
			if ((appl->current->window->f.Iconize ) && ((xy2[0]<=0) && (xy2[2] >= 0))&&((xy2[1]<0)&&(xy2[3]>0)))
			{
				if(_check_buttonpress( appl->current->obj_icon , appl->current->window->x , appl->current->window->y ))
				{
				}
				return;
			}
		}
	}
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
void _fix_mouse( HANDLER_DATA *handler, EVENT_DATA *event)
{
	Window_entry *current = appl->first;

	handler->check&=~MU_M1;

	while ( current )
	{
		int x0,y0,x1,x2,y1,y2;
		x0 = handler->mo_x;
		y0 = handler->mo_y;
		x1 = current->window->x;
		y1 = current->window->y;
		x2 = current->window->x + current->window->w;
		y2 = current->window->y + current->window->h;

		if( ( x0 >= x1 - MOVE_SIZE ) && ( x0 <= x1 + MOVE_SEPERATOR_SIZE )  && (y0 >= y1 - MOVE_SIZE ) && (y0 <= y1 + MOVE_SIZE ) )
		{
			if( current->move == MOVE_NONE ) graf_mouse(M_SAVE , 0);
			current->move = MOVE_TOP_LEFT;
			graf_mouse(OUTLN_CROSS , 0);
		}
		else if( ( x0 >= x1 - MOVE_SIZE ) && ( x0 <= x1 + MOVE_SEPERATOR_SIZE )  && (y0 >= y2 - MOVE_SIZE ) && (y0 <= y2 + MOVE_SIZE ) )
		{
			if( current->move == MOVE_NONE ) graf_mouse(M_SAVE , 0);
			current->move = MOVE_BOTTOM_LEFT;
			graf_mouse(OUTLN_CROSS , 0);
		}
		else if( ( x0 >= x2 - MOVE_SEPERATOR_SIZE ) && ( x0 <= x2 + MOVE_SIZE )  && (y0 >= y1 - MOVE_SIZE ) && (y0 <= y1 + MOVE_SIZE ) )
		{
			if( current->move == MOVE_NONE ) graf_mouse(M_SAVE , 0);
			current->move = MOVE_TOP_RIGHT;
			graf_mouse(OUTLN_CROSS , 0);
		}
		else if( ( x0 >= x2 - MOVE_SEPERATOR_SIZE ) && ( x0 <= x2 + MOVE_SIZE )  && (y0 >= y2 - MOVE_SIZE ) && (y0 <= y2 + MOVE_SIZE ) )
		{
			if( current->move == MOVE_NONE ) graf_mouse(M_SAVE , 0);
			current->move = MOVE_BOTTOM_RIGHT;
			graf_mouse(OUTLN_CROSS , 0);
		}
		else if( ( x0 >= x1 - MOVE_SEPERATOR_SIZE ) && ( x0 <= x2 - MOVE_SEPERATOR_SIZE )  && (y0 >= y1 - MOVE_SIZE ) && (y0 <= y1 + MOVE_SIZE ) )
		{
			if( current->move == MOVE_NONE ) graf_mouse(M_SAVE , 0);
			current->move = MOVE_TOP;
			graf_mouse(THIN_CROSS , 0);
		}
		else if( ( x0 >= x1 - MOVE_SEPERATOR_SIZE ) && ( x0 <= x2 - MOVE_SEPERATOR_SIZE )  && (y0 >= y2 - MOVE_SIZE ) && (y0 <= y2 + MOVE_SIZE ) )
		{
			if( current->move == MOVE_NONE ) graf_mouse(M_SAVE , 0);
			current->move = MOVE_BOTTOM;
			graf_mouse(THIN_CROSS , 0);
		}
		else if( ( y0 >= y1 - MOVE_SIZE ) && ( y0 <= y1 + MOVE_SEPERATOR_SIZE )  && (x0 >= x1 - MOVE_SIZE ) && (x0 <= x1 + MOVE_SIZE ) )
		{
			if( current->move == MOVE_NONE ) graf_mouse(M_SAVE , 0);
			current->move = MOVE_TOP_LEFT;
			graf_mouse(OUTLN_CROSS , 0);
		}
		else if( ( y0 >= y1 - MOVE_SIZE ) && ( y0 <= y1 + MOVE_SEPERATOR_SIZE )  && (x0 >= x2 - MOVE_SIZE ) && (x0 <= x2 + MOVE_SIZE ) )
		{
			if( current->move == MOVE_NONE ) graf_mouse(M_SAVE , 0);
			current->move = MOVE_TOP_RIGHT;
			graf_mouse(OUTLN_CROSS , 0);
		}
		else if( ( y0 >= y2 - MOVE_SEPERATOR_SIZE ) && ( y0 <= y2 + MOVE_SIZE )  && (x0 >= x1 - MOVE_SIZE ) && (x0 <= x1 + MOVE_SIZE ) )
		{
			if( current->move == MOVE_NONE ) graf_mouse(M_SAVE , 0);
			current->move = MOVE_BOTTOM_LEFT;
			graf_mouse(OUTLN_CROSS , 0);
		}
		else if( ( y0 >= y2 - MOVE_SEPERATOR_SIZE ) && ( y0 <= y2 + MOVE_SIZE )  && (x0 >= x2 - MOVE_SIZE ) && (x0 <= x2 + MOVE_SIZE ) )
		{
			if( current->move == MOVE_NONE ) graf_mouse(M_SAVE , 0);
			current->move = MOVE_BOTTOM_RIGHT;
			graf_mouse(OUTLN_CROSS , 0);
		}
		else if( ( y0 >= y1 + MOVE_SEPERATOR_SIZE ) && ( y0 <= y2 - MOVE_SEPERATOR_SIZE )  && (x0 >= x1 - MOVE_SIZE ) && (x0 <= x1 + MOVE_SIZE ) )
		{
			if( current->move == MOVE_NONE ) graf_mouse(M_SAVE , 0);
			current->move = MOVE_LEFT;
			graf_mouse(THIN_CROSS , 0);
		}
		else if( ( y0 >= y1 + MOVE_SEPERATOR_SIZE ) && ( y0 <= y2 - MOVE_SEPERATOR_SIZE )  && (x0 >= x2 - MOVE_SIZE ) && (x0 <= x2 + MOVE_SIZE ) )
		{
			if( current->move == MOVE_NONE ) graf_mouse(M_SAVE , 0);
			current->move = MOVE_RIGHT;
			graf_mouse(THIN_CROSS , 0);
		}
		else if ( current->move != MOVE_NONE )
		{
			current->move = MOVE_NONE;
			graf_mouse(M_RESTORE , 0);
		}
		current = current->next;
	}
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
int _create_window(Window_entry *wind)
{
	RO_Object *temp1, *temp2;
	
	wind->wind_object = create_object(RO_GROUP);
	if( wind->wind_object)
	{
		RO_Object *group1,*group2,*group3;
		
		wind->wind_object->flags.Alignment = ALIGNMENT_VERTICAL;
		sprintf(wind->wind_object->name,"Window %d",wind->window->Ident);
		group1= create_object(RO_GROUP);
		group1->flags.pAlign_top = 1;
		group1->flags.Max_w = 1;
		group1->flags.Change_w = 1;
		group1->flags.Same_h = 1;
		sprintf(group1->name,"Group1 %d",wind->window->Ident);
		add_object(wind->wind_object,OBJECT_LAST,group1);
		group2= create_object(RO_GROUP);
		group2->flags.pAlign_top = 1;
		group2->flags.pAlign_bottom = 1;
		group2->flags.Change_w = 1;
		group2->flags.Change_h = 1;
		group2->in_x=1;
		sprintf(group2->name,"Group2 %d",wind->window->Ident);
		add_object(wind->wind_object,OBJECT_LAST,group2);

		group3= create_object(RO_GROUP);
		group3->flags.pAlign_bottom = 1;
		group3->flags.Change_w = 1;
		group3->flags.Same_h = 1;
		sprintf(group3->name,"Group3 %d",wind->window->Ident);
		add_object(wind->wind_object,OBJECT_LAST,group3);
		add_object(group2, OBJECT_LAST, wind->window->Root);
		wind->window->Root->flags.pAlign_left = 1;
		wind->window->Root->flags.pAlign_top = 1;
		wind->window->Root->flags.pAlign_bottom = 1;
		if( wind->window->f.Close )
		{
			wind->obj_close = create_object( RO_BUTTON );
			wind->obj_close->Button->text = "";
			wind->obj_close->flags.pAlign_left = 1;
			wind->obj_close->Button->font.Id = 1;
			wind->obj_close->Button->font.Size = 10;
			wind->obj_close->Button->font.Effects = 0;
			sprintf(wind->obj_close->name,"Close %d",wind->window->Ident);
			add_object( group1 , OBJECT_LAST , wind->obj_close );
		}
		if( wind->window->f.Move )
		{
			wind->obj_move = create_object( RO_BUTTON );
			wind->obj_move->flags.Change_w = 1;
			wind->obj_move->flags.pAlign_left = 1;
			wind->obj_move->flags.pAlign_right = 1;
			wind->obj_move->Button->font.Id = 1;
			wind->obj_move->Button->font.Size = 10;
			wind->obj_move->Button->font.Effects = 0;
			sprintf(wind->obj_move->name,"Move %d",wind->window->Ident);
			add_object( group1 , OBJECT_LAST , wind->obj_move );
			if(wind->window->f.Title)
			{
				wind->obj_move->Button->text = wind->window->Title;
			}
		}
		else if(wind->window->f.Title)
		{
			temp1 = create_object( RO_BOX );
			temp1->Box.color = COLOR_GREY;
			temp1->Box.fcolor = COLOR_GREY;
			temp1->Box.fstyle = FSTYLE_SOLID;
			temp1->Box.fpattern = FPATTERN_SOLID100;
			temp1->Box.effect = EFFECT_3DRAISED;
			temp1->flags.Change_w = 1;
			temp1->flags.pAlign_left = 1;
			temp1->flags.pAlign_right = 1;
			sprintf(temp1->name,"TBack %d",wind->window->Ident);
			add_object( group1 , OBJECT_LAST , temp1 );
			temp2 =  create_object (RO_STRING );
			temp2->flags.Max_w = 1;
			temp2->flags.pAlign_left = 1;
			temp2->flags.pAlign_right = 1;
			temp2->String = wind->window->Title;
			sprintf(temp2->name,"Title %d",wind->window->Ident);
			add_object( temp1 , OBJECT_LAST , temp2 );
		}
		if( wind->window->f.Back )
		{
			wind->obj_back = create_object( RO_BUTTON );
			wind->obj_back->Button->text = "";
			wind->obj_back->flags.Same_w = 1;
			wind->obj_back->flags.Same_h = 1;
			wind->obj_back->flags.pAlign_right = 1;
			wind->obj_back->Button->font.Id = 1;
			sprintf(wind->obj_back->name,"Back %d",wind->window->Ident);
			add_object( group1 , OBJECT_LAST , wind->obj_back );
		}
		if( wind->window->f.Hide )
		{
			wind->obj_hide = create_object( RO_BUTTON );
			wind->obj_hide->Button->text = "ð";
			wind->obj_hide->flags.Same_w = 1;
			wind->obj_hide->flags.Same_h = 1;
			wind->obj_hide->flags.pAlign_right = 1;
			wind->obj_hide->Button->font.Id = 1;
			wind->obj_hide->Button->font.Size = 10;
			wind->obj_hide->Button->font.Effects = 0;
			sprintf(wind->obj_hide->name,"Hide %d",wind->window->Ident);
			add_object( group1 , OBJECT_LAST , wind->obj_hide );
		}
		if( wind->window->f.Iconize )
		{
			wind->obj_icon = create_object( RO_BUTTON );
			wind->obj_icon->Button->text = "";
			wind->obj_icon->flags.Same_w = 1;
			wind->obj_icon->flags.Same_h = 1;
			wind->obj_icon->flags.pAlign_right = 1;
			wind->obj_icon->Button->font.Id = 1;
			wind->obj_icon->Button->font.Size = 10;
			wind->obj_icon->Button->font.Effects = 0;
			sprintf(wind->obj_icon->name,"Icon %d",wind->window->Ident);
			add_object( group1 , OBJECT_LAST , wind->obj_icon );
		}
		if( wind->window->f.Full )
		{
			wind->obj_full = create_object( RO_BUTTON );
			wind->obj_full->Button->text = "";
			wind->obj_full->flags.Same_w = 1;
			wind->obj_full->flags.Same_h = 1;
			wind->obj_full->flags.pAlign_right = 1;
			wind->obj_full->Button->font.Id = 1;
			wind->obj_full->Button->font.Size = 10;
			wind->obj_full->Button->font.Effects = 0;
			sprintf(wind->obj_full->name,"Full %d",wind->window->Ident);
			add_object( group1 , OBJECT_LAST , wind->obj_full );
		}
		if( wind->window->f.Scroll_h )
		{
			wind->obj_scroll_h = create_object( RO_SCROLLBAR );
			wind->obj_scroll_h->ScrollBar->type = SCROLLBAR_VERTICAL;
			wind->obj_scroll_h->flags.Same_w = 1;
			wind->obj_scroll_h->flags.Change_h = 1;
			wind->obj_scroll_h->flags.Max_h = 1;
			wind->obj_scroll_h->flags.pAlign_right = 1;
			sprintf(wind->obj_scroll_h->name,"Scrollh %d",wind->window->Ident);
			add_object( group2 , OBJECT_LAST , wind->obj_scroll_h );
		}
		if( wind->window->f.Scroll_w )
		{
			wind->obj_scroll_w = create_object( RO_SCROLLBAR );
			wind->obj_scroll_w->ScrollBar->type = SCROLLBAR_HORISONTAL;
			wind->obj_scroll_w->flags.Same_w = 1;
			wind->obj_scroll_w->flags.Change_h = 1;
			wind->obj_scroll_w->flags.Max_h = 1;
			wind->obj_scroll_w->flags.pAlign_right = 1;
			sprintf(wind->obj_scroll_w->name,"Scrollw %d",wind->window->Ident);
			add_object( group2 , OBJECT_LAST , wind->obj_scroll_w );
		}
	}
	else
		return -1;
	return 0;
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
void _delete_window(Window_entry *wind)
{
	delete_object(wind->wind_object , DELETE_RECURSIVE );
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
void print_window(Window_entry *wind)
{
	printf("This is window %d and it has", wind->window->Ident);
	if(wind->window->f.Title && wind->window->Title)
		printf("\"%s\" as a title\n");
	else
		printf("no title\n");
	printf("Here is the Full contents of this window:\n\n");
	print_object(wind->wind_object, 1 );
	printf("\nThat was it!");
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
void print_object(RO_Object *object, int Recursive)
{
	if(object)
	{
		printf("This is an object of type %d ",object->type);
		switch(object->type)
		{
			case RO_DIALOG:
				printf("(RO_DIALOG)\n");
				break;
			default:
				printf("(Unknown)\n");
		}
	}
	getch();

	if(Recursive)
	{
		if(object->child)
			print_object(object->child, Recursive);
		if(object->next)
			print_object(object->next, Recursive);
	}
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
void _redraw_wind(Window_entry *wind, short xy[4])
{
  short w[4];
  short t[4];
//  int temp_window,temp_counter;
//  if((info->status==WINDOW_HIDDEN)||(info->status==WINDOW_IHIDDEN))
//    return;
  
  
  graf_mouse(256,0);
  wind_update(BEG_UPDATE);
  wind_get(wind->window->Ident,WF_FIRSTXYWH,&w[0],&w[1],&w[2],&w[3]);
  while((w[2]!=0)&&(w[3]!=0))
  {
    w[2]=(short)(w[0]+w[2]);	
    w[3]=(short)(w[1]+w[3]);
    if(xy!=NULL)
    {
      t[0]=xy[0];
      t[1]=xy[1];
      t[2]=(short)(t[0]+xy[2]);
      t[3]=(short)(t[1]+xy[3]);
    }
/*
    else if((info->status==WINDOW_ICONIZED)||(info->status==WINDOW_NMICONIZED))
    {
      t[0]=info->i_x;
      t[1]=info->i_y;
      t[2]=(short)(t[0]+info->icondata[ROOT].ob_width);
      t[3]=(short)(t[1]+info->icondata[ROOT].ob_height);
    }
*/
    else
    {
      t[0]=wind->window->x;
      t[1]=wind->window->y;
      t[2]=(short)(t[0]+wind->window->w);
      t[3]=(short)(t[1]+wind->window->h);
    }
    if(t[0]<w[0])
      t[0]=w[0];
    if(t[1]<w[1])
      t[1]=w[1];
    if(t[2]>w[2])
      t[2]=w[2];
    if(t[3]>w[3])
      t[3]=w[3];
    if((t[2]>t[0])&&(t[3]>t[1]))
    {
      t[2]--;
      t[3]--;
      vs_clip(appl->graph_id , 1 , t );
/*
      if((info->status==WINDOW_ICONIZED)||(info->status==WINDOW_NMICONIZED))
      {
        info->icondata[ROOT].ob_x=info->i_x;
        info->icondata[ROOT].ob_y=info->i_y;
        objc_draw(info->icondata,ROOT,MAX_DEPTH,t[0],t[1],t[2]-t[0],t[3]-t[1]);
      }
      else if((info->status==WINDOW_OPENED)||(info->status==WINDOW_NMOPENED))
*/
        draw_object(wind->wind_object,wind->window->x,wind->window->y);
/*
/*
      temp_window=FAIL;
      for(temp_counter=0;temp_counter<dias.number;temp_counter++)
        if(info->ident==dias.window[temp_counter]->ident)
          temp_window=temp_counter;
      if(dias.diainfo[temp_window].text_object!=ROOT)
        objc_edit(info->dialog,dias.diainfo[temp_window].text_object,0,&dias.diainfo[temp_window].text_pos,ED_INIT);
*/
       
      vs_clip(appl->graph_id , 0 , t );
    }
    wind_get(wind->window->Ident,WF_NEXTXYWH,&w[0],&w[1],&w[2],&w[3]);
  }
  wind_update(END_UPDATE);
  graf_mouse(257,0);
}
	
/*************************************************************************************************************************/
/*************************************************************************************************************************/
int _check_buttonpress( RO_Object *object , int x , int y)
{
	short xy2[ 4 ];
	short mouse_x , mouse_y , dummy ;
	HANDLER_DATA h2;

	xy2[ 0 ] = object->internal.x + x;
	xy2[ 1 ] = object->internal.y + y;
	wind_update( BEG_UPDATE );
	object->Button->flags.Selected = 1 ;
	graf_mouse( 256 , 0 );
	draw_object( object , x , y );
	graf_mouse( 257 , 0 );
	wind_update( END_UPDATE );
	h2.check = 0;
	while( 1 )
	{
	    graf_mkstate( &mouse_x , &mouse_y , &dummy , &dummy );
		if( ! h2.check )
			h2.check = evnt_multi(MU_M1|MU_BUTTON,1,MO_LEFT,0,1,xy2[ 0 ],xy2[ 1 ],object->internal.w,object->internal.h,0,0,0,0,0,0,0,0,&h2.mo_x,&h2.mo_y,&h2.mo_b,&h2.k_s,&h2.key,&h2.m_r);
		if( h2.check & MU_M1 )
		{
			h2.check &= ~MU_M1;
			wind_update(BEG_UPDATE);
			object->Button->flags.Selected = 0 ;
			graf_mouse(256,0);
			draw_object(object , x , y );
			graf_mouse(257,0);
			wind_update(END_UPDATE);
			return 0;
		}
		else if( h2.check & MU_BUTTON )
		{
			h2.check &= ~MU_M1;
			wind_update(BEG_UPDATE);
			object->Button->flags.Selected = 0 ;
			graf_mouse(256,0);
			draw_object(object , x , y );
			graf_mouse(257,0);
			wind_update(END_UPDATE);
			return 1;
		}
	}
}