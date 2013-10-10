#include <string.h>

#include "HighWire.h"

void
button_clicked(struct frame_item *first_frame,short mx, short my)
{
	struct frame_item *current_frame;
	current_frame=first_frame;
	while(current_frame!=0)
	{
		if(mx<current_frame->clip.x+current_frame->clip.w+scroll_bar_width && mx>current_frame->clip.x
			&& my<current_frame->clip.y+current_frame->clip.h+scroll_bar_width && my>current_frame->clip.y)
		{	
			frame_clicked(first_frame,current_frame,mx,my);
			return;
		}
		current_frame=current_frame->next_frame;
	}	
}
	
	
void
frame_clicked(struct frame_item *first_frame, struct frame_item *current_frame,short mx,short my)
{
	short distance=0,mouse_button_state,u;
	short slider_length,slider_pos,scroll_length;
	char *temp;
	
// *************** Vertical scroll **************	

	if(current_frame->v_scroll_on==true && mx>current_frame->clip.x+current_frame->clip.w)
	{
		scroll_length=current_frame->clip.h-1-scroll_bar_width*2;
		slider_length=((current_frame->clip.h>>2)*(scroll_length>>2)/(current_frame->current_page_height>>2))<<2;
		if(slider_length<scroll_bar_width)
			slider_length=scroll_bar_width;
		slider_pos=((scroll_length-slider_length)*current_frame->vertical_scroll/(current_frame->current_page_height-current_frame->clip.h))+current_frame->clip.y+scroll_bar_width+1;
	
		if(my<current_frame->clip.y+scroll_bar_width)
		{	//up
			if(current_frame->vertical_scroll-scroll_step>-1)
				distance=scroll_step;
			else
				if(current_frame->vertical_scroll>0)
					distance=current_frame->vertical_scroll;
			if(distance!=0)
			{
				current_frame->vertical_scroll-=distance;
				blit_block(current_frame,distance,d_up);
			}
		}
		else if(my<slider_pos)
		{	//page up
			if(current_frame->vertical_scroll-current_frame->clip.h-scroll_step>-1)
				distance=current_frame->clip.h-scroll_step;
			else
				if(current_frame->vertical_scroll>0)
					distance=current_frame->vertical_scroll;
			if(distance!=0)
			{
				current_frame->vertical_scroll-=distance;
				redraw_frame(window_handle,current_frame->clip.x,current_frame->clip.y,current_frame->clip.w,current_frame->clip.h,current_frame);
			}
		}
		else if(my<slider_pos+slider_length)
		{	//slider
			graf_mkstate(&mx,&my,&mouse_button_state,&u);
			if(mouse_button_state!=0)
			{
				graf_dragbox(scroll_bar_width,slider_length,current_frame->clip.x+current_frame->clip.w,slider_pos,current_frame->clip.x+current_frame->clip.w,current_frame->clip.y+scroll_bar_width,scroll_bar_width,scroll_length,&u,&slider_pos);
				slider_pos-=current_frame->clip.y+scroll_bar_width;
				current_frame->vertical_scroll=(current_frame->current_page_height-current_frame->clip.h)*slider_pos/(scroll_length-slider_length);
				distance=1;
				redraw_frame(window_handle,current_frame->clip.x,current_frame->clip.y,current_frame->clip.w,current_frame->clip.h,current_frame);
			}
		}
		else if(my<current_frame->clip.y+current_frame->clip.h-scroll_bar_width)
		{	//page down
			if(current_frame->vertical_scroll+current_frame->clip.h-scroll_step<current_frame->current_page_height-current_frame->clip.h)
				distance=current_frame->clip.h-scroll_step;
			else
				if(current_frame->vertical_scroll<current_frame->current_page_height-current_frame->clip.h)
					distance=current_frame->current_page_height-current_frame->vertical_scroll-current_frame->clip.h;
			if(distance!=0)
			{
				current_frame->vertical_scroll+=distance;
				redraw_frame(window_handle,current_frame->clip.x,current_frame->clip.y,current_frame->clip.w,current_frame->clip.h,current_frame);
			}
		}
		else if(my<current_frame->clip.y + current_frame->clip.h)
		{	//down
			if(current_frame->vertical_scroll+scroll_step<current_frame->current_page_height-current_frame->clip.h)
				distance=scroll_step;
			else
				if(current_frame->vertical_scroll<current_frame->current_page_height-current_frame->clip.h)
					distance=current_frame->current_page_height-current_frame->vertical_scroll-current_frame->clip.h;
			if(distance!=0)
			{
				current_frame->vertical_scroll+=distance;
				blit_block(current_frame,distance,d_down);
			}
		}
		if(distance!=0)
			draw_frame_borders(current_frame,1);
	}
// ******** Horizontal Scroll ***********

	else if(current_frame->h_scroll_on==true && my>current_frame->clip.y+current_frame->clip.h)
	{
		scroll_length=current_frame->clip.w-1-scroll_bar_width*2;
		slider_length=current_frame->clip.w*scroll_length/current_frame->frame.w;
		if(slider_length<scroll_bar_width)
			slider_length=scroll_bar_width;
		slider_pos=((scroll_length-slider_length)*current_frame->horizontal_scroll/(current_frame->frame.w-current_frame->clip.w))+current_frame->clip.x+scroll_bar_width+1;
	
		if(mx<current_frame->clip.x+scroll_bar_width)
		{	//left
			if(current_frame->horizontal_scroll-scroll_step>-1)
				distance=scroll_step;
			else
				if(current_frame->horizontal_scroll>0)
					distance=current_frame->horizontal_scroll;
			if(distance!=0)
			{
				current_frame->horizontal_scroll-=distance;
				blit_block(current_frame,distance,d_left);
			}
		}
		else if(mx<slider_pos)
		{	//page left
			if(current_frame->horizontal_scroll-current_frame->clip.w-scroll_step>-1)
				distance=current_frame->clip.w-scroll_step;
			else
				if(current_frame->horizontal_scroll>0)
					distance=current_frame->horizontal_scroll;
			if(distance!=0)
			{
				current_frame->horizontal_scroll-=distance;
				redraw_frame(window_handle,current_frame->clip.x,current_frame->clip.y,current_frame->clip.w,current_frame->clip.h,current_frame);
			}
		}
		else if(mx<slider_pos+slider_length)
		{
			graf_mkstate(&mx,&my,&mouse_button_state,&u);
			if(mouse_button_state!=0)
			{
				graf_dragbox(slider_length,scroll_bar_width,slider_pos,current_frame->clip.y+current_frame->clip.h,current_frame->clip.x+scroll_bar_width,current_frame->clip.y+current_frame->clip.h,scroll_length,scroll_bar_width,&slider_pos,&u);
				slider_pos-=current_frame->clip.x+scroll_bar_width;
				current_frame->horizontal_scroll=(current_frame->frame.w-current_frame->clip.w)*slider_pos/(scroll_length-slider_length);
				distance=1;
				redraw_frame(window_handle,current_frame->clip.x,current_frame->clip.y,current_frame->clip.w,current_frame->clip.h,current_frame);
			}
		}
		else if(mx<current_frame->clip.x+current_frame->clip.w-scroll_bar_width)
		{	//page right
			if(current_frame->horizontal_scroll+current_frame->clip.w-scroll_step<current_frame->frame.w-current_frame->clip.w)
				distance=current_frame->clip.w-scroll_step;
			else
				if(current_frame->horizontal_scroll<current_frame->frame.w-current_frame->clip.w)
					distance=current_frame->frame.w-current_frame->horizontal_scroll-current_frame->clip.w;
			if(distance!=0)
			{
				current_frame->horizontal_scroll+=distance;
				redraw_frame(window_handle,current_frame->clip.x,current_frame->clip.y,current_frame->clip.w,current_frame->clip.h,current_frame);
			}
		}
		else if(mx<current_frame->clip.x + current_frame->clip.w)
		{	//right
			if(current_frame->horizontal_scroll+scroll_step<current_frame->frame.w-current_frame->clip.w)
				distance=scroll_step;
			else
				if(current_frame->horizontal_scroll<current_frame->frame.w-current_frame->clip.w)
					distance=current_frame->frame.w-current_frame->horizontal_scroll-current_frame->clip.w;
			if(distance!=0)
			{
				current_frame->horizontal_scroll+=distance;
				blit_block(current_frame,distance,d_right);
			}
		}
		if(distance!=0)
			draw_frame_borders(current_frame,1);
	}
// *********** Clickable areas *************

	else
	{
		if(current_highlighted_link_area!=0)
		{
			temp=strdup(current_highlighted_link_area->link->address);
			if(*temp=='#')
			{
				current_highlighted_link_frame->frame_named_location=translate_address(temp);
				frames_recalculated=true;
				redraw(window_handle,0,0,0,0,first_frame);
			}
			else
			{
				add_load_item_to_to_do_list(0,current_highlighted_link_area->link->address,current_highlighted_link_frame);
			}
		}
	}
}

void
check_mouse_position(struct frame_item *current_frame, short mx, short my)
{
	struct clickable_area *current_area,*highlighted_link_area;
	
	if(current_highlighted_link_area!=0)
	{
		if(mx<current_highlighted_link_area->x+current_highlighted_link_frame->frame.x ||
			my<current_highlighted_link_area->y+current_highlighted_link_frame->frame.y ||
			mx>current_highlighted_link_area->x+current_highlighted_link_area->w+current_highlighted_link_frame->frame.x ||
			my>current_highlighted_link_area->y+current_highlighted_link_area->h+current_highlighted_link_frame->frame.y
			)
		{
			graf_mouse(0,0);
			highlighted_link_area=current_highlighted_link_area;
			current_highlighted_link_area=0;
			redraw_frame(window_handle,current_frame->frame.x+highlighted_link_area->x,current_frame->frame.y+highlighted_link_area->y,highlighted_link_area->w,highlighted_link_area->h,current_highlighted_link_frame);
			current_highlighted_link_frame=0;
		}
		else
		{
			return;
		}
	}
	
	while(current_frame->clip.x>mx || current_frame->clip.y>my || current_frame->clip.x+current_frame->clip.w-1<mx || current_frame->clip.y+current_frame->clip.h-1<my)
	{
		current_frame=current_frame->next_frame;
		if(current_frame==0)
			return;
	}
	
	current_area=current_frame->first_clickable_area;
	if(current_area==0)
		return;
		
	mx-=current_frame->frame.x;
	my-=current_frame->frame.y;
	while(current_area->x>mx || current_area->y>my || current_area->x+current_area->w-1<mx || current_area->y+current_area->h-1<my)
	{
		current_area=current_area->next_area;
		if(current_area==0)
			return;
	}
	
	if(current_highlighted_link_area==0 && current_area->link->mode==href)
	{
		graf_mouse(3,0);
		current_highlighted_link_frame=current_frame;
		current_highlighted_link_area=current_area;
		redraw_frame(window_handle,current_highlighted_link_area->x+current_frame->frame.x,current_highlighted_link_area->y+current_frame->frame.y,current_highlighted_link_area->w,current_highlighted_link_area->h,current_highlighted_link_frame);
	}
}
