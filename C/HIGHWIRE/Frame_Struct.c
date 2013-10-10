#include "HighWire.h"

void
destroy_frame_structure(struct frame_item *current_frame)
{
	struct frame_item *temp;
	
	while(current_frame!=0)
	{
		if(current_frame->item!=0)
			destroy_paragraph_structure(current_frame->item);
		if(current_frame->first_clickable_area!=0)
			destroy_clickable_area_structure(current_frame->first_clickable_area);
		if(current_frame->first_named_location!=0)
			destroy_named_location_structure(current_frame->first_named_location);
		temp=current_frame->next_frame;
		free(current_frame);
		current_frame=temp;
	}
}	


struct frame_item *
new_frame(void)
{
	struct frame_item *temp;
	temp=(struct frame_item *) malloc(sizeof(struct frame_item));
	temp->item=0;
	temp->frame_width=0;
	temp->frame_height=0;
	temp->frame_left=0;
	temp->frame_top=0;
	temp->horizontal_scroll=0;
	temp->vertical_scroll=0;
	temp->border=false;
	temp->frame_page_width=0;
	temp->next_frame=0;
	temp->current_page_height=0;
	temp->clip.x=0;
	temp->clip.y=0;
	temp->clip.w=0;
	temp->clip.h=0;
	temp->first_clickable_area=0;
	temp->first_named_location=0;
	temp->frame_filename=0;
	temp->frame_named_location=0;
	return(temp);
}

void
reset_frame(struct frame_item *frame)
{
	if(frame->first_clickable_area!=0)
		destroy_clickable_area_structure(frame->first_clickable_area);
	if(frame->item!=0)
		destroy_paragraph_structure(frame->item);
	frame->item=0;
	frame->frame_width=0;
	frame->frame_height=0;
	frame->frame_left=0;
	frame->frame_top=0;
	frame->horizontal_scroll=0;
	frame->vertical_scroll=0;
	frame->border=false;
	frame->frame_page_width=0;
	frame->current_page_height=0;
	frame->clip.x=0;
	frame->clip.y=0;
	frame->clip.w=0;
	frame->clip.h=0;
	frame->first_clickable_area=0;
	frame->first_named_location=0;
	frame->frame_filename=0;
	frame->frame_named_location=0;
}

