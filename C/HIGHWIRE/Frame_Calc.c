#include <aes.h>

#include "HighWire.h"

void
calculate_frame_locations()
{
	short win_x,win_y,win_w,win_h,old_width;
	long old_height;
	struct frame_item *current_frame;
	
	current_frame=first_frame;

	if(wind_get(window_handle,WF_WORKXYWH,&win_x,&win_y,&win_w,&win_h)<0)
		return;
	while(current_frame!=0)
	{
		if(current_frame->item==0)
		{
			current_frame=current_frame->next_frame;
			continue;
		}
		old_height=current_frame->current_page_height;
		old_width=current_frame->frame.w;
		
		current_frame->clip.x=win_x;
		if(current_frame->frame_left>0)
			current_frame->clip.x+=current_frame->frame_left;
		else if(current_frame->frame_left<0)
			current_frame->clip.x+=win_w*current_frame->frame_left/-100;
				
		current_frame->clip.y=win_y;
		if(current_frame->frame_top>0)
			current_frame->clip.y+=current_frame->frame_top;
		else if(current_frame->frame_top<0)
			current_frame->clip.y+=win_h*current_frame->frame_top/-100;
	
		if(current_frame->frame_width==0)
			current_frame->clip.w=win_w+win_x-current_frame->clip.x;
		else if(current_frame->frame_width>0)
			current_frame->clip.w=min(current_frame->frame_width,win_w+win_x-current_frame->clip.x);
		else if(current_frame->frame_width<0)
			current_frame->clip.w=win_w*current_frame->frame_width/-100;
			
		if(current_frame->frame_height==0)
			current_frame->clip.h=win_h+win_y-current_frame->clip.y;
		else if(current_frame->frame_height>0)
			current_frame->clip.h=min(current_frame->frame_height,win_h+win_y-current_frame->clip.y);
		else if(current_frame->frame_height<0)
			current_frame->clip.h=win_h*current_frame->frame_height/-100;
		
		if(current_frame->border==true)
		{	current_frame->clip.x++;
			current_frame->clip.y++;
			current_frame->clip.w-=2;
			current_frame->clip.h-=2;}
			
		if(current_frame->frame_width<1)
			current_frame->frame.w=max(current_frame->clip.w,current_frame->frame_page_width);
		else 
			current_frame->frame.w=current_frame->frame_width;
		
		if(current_frame->frame.w>current_frame->clip.w)
		{	current_frame->h_scroll_on=true;
			current_frame->clip.h-=scroll_bar_width;
			if(current_frame->border==true)
				current_frame->clip.h++;
		}
		else
		{
			current_frame->h_scroll_on=false;
			current_frame->horizontal_scroll=0;
		}
		
		current_frame->current_page_height=calculate_frame_height(current_frame);
	
		if(current_frame->current_page_height>current_frame->clip.h)
		{	current_frame->v_scroll_on=true;
			current_frame->clip.w-=scroll_bar_width;
			if(current_frame->border==true)
				current_frame->clip.w++;
			if(current_frame->h_scroll_on==false)
			{
				if(current_frame->frame_width<1)
					current_frame->frame.w=max(current_frame->clip.w,current_frame->frame_page_width);
				else 
					current_frame->frame.w=current_frame->frame_width;
		
				if(current_frame->frame.w>current_frame->clip.w)
				{	current_frame->h_scroll_on=true;
					current_frame->clip.h-=scroll_bar_width;
					if(current_frame->border==true)
						current_frame->clip.h++;
				}
				else
				{
					current_frame->h_scroll_on=false;
					current_frame->horizontal_scroll=0;
				}
			}
			current_frame->current_page_height=calculate_frame_height(current_frame);
		}
		else
		{
			current_frame->v_scroll_on=false;
			current_frame->vertical_scroll=0;
		}
		
		if(old_height>0 && current_frame->vertical_scroll>0)
		{
			current_frame->vertical_scroll=current_frame->vertical_scroll*current_frame->current_page_height/old_height;
			if(current_frame->vertical_scroll+current_frame->clip.h>current_frame->current_page_height)
				current_frame->vertical_scroll=current_frame->current_page_height-current_frame->clip.h;
		}
		if(old_width>0 && current_frame->horizontal_scroll>0)
		{
			current_frame->horizontal_scroll=current_frame->horizontal_scroll*current_frame->frame.w/old_width;			
			if(current_frame->horizontal_scroll+current_frame->clip.w>current_frame->frame.w)
				current_frame->horizontal_scroll=current_frame->frame.w-current_frame->clip.w;
		}
		current_frame=current_frame->next_frame;
	}	
	frames_recalculated=true;
}

long
calculate_frame_height(struct frame_item *frame)
{
	struct paragraph_item *current_paragraph;
	struct word_item *current_word,*line_start,*line_end;
	struct url_link *current_link;
	struct clickable_area *current_clickable_area;
	struct named_location *current_named_location;
	short left_indent,right_indent,current_line_width,line_tail=0,line_height;
	short alignment_spacer,height_spacer,frame_w;
	short previous_word_height=0;
	long current_height=0;
	enum bool clickable_area_exists=false;
	
	current_paragraph=frame->item;
	frame_w=frame->frame.w;
	current_clickable_area=frame->first_clickable_area;
	current_named_location=frame->first_named_location;
	current_link=0;
	
	if(current_paragraph==0)
		return(0);
	current_word=current_paragraph->item;
	while(current_paragraph!=0)
	{
		current_paragraph->current_paragraph_height=0;
		current_word=current_paragraph->item;
		
		if(current_paragraph->paragraph_code==hr)
		{
			current_paragraph->current_paragraph_height=abs(current_word->word_height)+20;
			current_height+=current_paragraph->current_paragraph_height;
			current_paragraph=current_paragraph->next_paragraph;
			continue;
		}
	
		left_indent=current_paragraph->left_border;
		right_indent=current_paragraph->right_border;
		
		while(current_word!=0)
		{
			current_line_width=0;
			line_start=current_word;
			line_height=0;
			line_tail=0;
			clickable_area_exists=false;
			while(current_word!=0 && (current_line_width+current_word->word_width)<(frame_w-left_indent-right_indent))
			{
				if(current_word->word_code==br && current_word != line_start)
					break;
				current_line_width+=current_word->word_width;
				if(line_height<current_word->word_height)
					line_height=current_word->word_height;
				if(line_tail<current_word->word_tail_drop)
					line_tail=current_word->word_tail_drop;
				if(current_word->link!=0)
				{	
					if(current_word->link->mode==href)
					{	
						clickable_area_exists=true;
					}
					else
					{
						if(frame->first_named_location==0)
						{
							current_named_location=frame->first_named_location=new_named_location();
							current_named_location->link=current_word->link;
							current_named_location->position=current_height+current_paragraph->current_paragraph_height;
						}
						else
						{
							if(current_named_location->link!=current_word->link)
							{
								if(current_named_location->next_location==0)
									current_named_location->next_location=new_named_location();
								current_named_location=current_named_location->next_location;
								current_named_location->link=current_word->link;
								current_named_location->position=current_height+current_paragraph->current_paragraph_height;
							}
						}
					}
				}		
				current_word=current_word->next_word;
			}
			
			if(clickable_area_exists==true)
			{
				line_end=current_word;
				current_word=line_start;
				
				switch(current_paragraph->alignment)
				{
					case center:
						alignment_spacer=(frame_w-current_line_width-left_indent-right_indent)/2+left_indent;break;
					case right:
						alignment_spacer=(frame_w-current_line_width-left_indent);break;
					default:
						alignment_spacer=left_indent;
				}
				
				current_line_width=0;
				
				while(current_word!=line_end)
				{
					switch(current_word->vertical_align)
					{
						case below:
							height_spacer=-(current_word->word_height/2);break;
						case above:
							height_spacer=previous_word_height-current_word->word_height;break;
						case bottom:
							previous_word_height=current_word->word_height;
						default:
							height_spacer=0;
					}
				
					if(current_line_width==0 && *current_word->item==Space_Code)
						switch(current_paragraph->alignment)
						{
							case right:
								break;
							case center:
								alignment_spacer-=current_word->space_width/2;break;
							default:
								alignment_spacer-=current_word->space_width;
						}
					if(current_link!=0 || current_word->link!=0)
					{
						if(current_link!=0 && current_word->link==0)
						{
							current_link=0;
						}
						else if(current_link==0 && current_word->link !=0)
						{
							current_link=current_word->link;
						
							if(frame->first_clickable_area==0)
							{
								current_clickable_area=frame->first_clickable_area=new_clickable_area();
							}
							else
							{	
								if(current_clickable_area->next_area==0)
									current_clickable_area->next_area=new_clickable_area();
								current_clickable_area=current_clickable_area->next_area;
							}
							
							current_clickable_area->x=current_line_width+alignment_spacer;
							current_clickable_area->y=current_height+current_paragraph->current_paragraph_height;
							current_clickable_area->h=line_height+line_tail;
							current_clickable_area->w=current_word->word_width;
							current_clickable_area->link=current_link;
						}
						else if(current_link==current_word->link)
							current_clickable_area->w+=current_word->word_width;
						else if(current_link!=0 && current_word->link!=0)
						{
							if(current_clickable_area->next_area==0)
								current_clickable_area->next_area=new_clickable_area();
							current_clickable_area=current_clickable_area->next_area;
							current_link=current_word->link;
							if(current_clickable_area==0)
								new_clickable_area(current_clickable_area);
							current_clickable_area->x=current_line_width+alignment_spacer;
							current_clickable_area->y=current_height+current_paragraph->current_paragraph_height;
							current_clickable_area->h=line_height+line_tail;
							current_clickable_area->w=current_word->word_width;
							current_clickable_area->link=current_link;
						}
					}
					current_line_width+=current_word->word_width;
					current_word=current_word->next_word;
				}
				if(current_link!=0)
					current_link=0;
			}
			current_paragraph->current_paragraph_height+=line_height+line_tail;
		}
		if(current_paragraph->eop_space>0)
			current_paragraph->current_paragraph_height+=current_paragraph->eop_space;
		else
			current_height+=current_paragraph->eop_space;
		current_height+=current_paragraph->current_paragraph_height;
		current_paragraph=current_paragraph->next_paragraph;
	}
	return(current_height);
}
