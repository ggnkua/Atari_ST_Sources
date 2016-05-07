#include "HighWire.h"

void
check_to_do_list()
{
	struct load_to_do *load_to_do_temp;
	struct parse_to_do *parse_to_do_temp;
	struct to_do_item *to_do_item_temp;
	
	while(read_to_do!=0)
	{
		switch(read_to_do->message_type)
		{
			case to_do_load_frame: 
				//load files + urls into memory ready for parsing
				load_to_do_temp=read_to_do->message;
				
				switch(load_to_do_temp->sub_type)
				{
					case 0: //clear settings and load new file into frame
						reset_frame(load_to_do_temp->frame);
						load_to_do_temp->frame->frame_filename=load_to_do_temp->filename;
						load_to_do_temp->frame->frame_named_location=load_to_do_temp->named_location;
						add_parse_item_to_to_do_list(load_file(load_to_do_temp->filename),load_to_do_temp->frame);
						break;
						
					case 1: //add new frame to current frame and load file into that frame
						if(load_to_do_temp->frame->next_frame!=0)
							destroy_frame_structure(load_to_do_temp->frame->next_frame);
						load_to_do_temp->frame->next_frame=new_frame();
						load_to_do_temp->frame->next_frame->frame_filename=load_to_do_temp->filename;
						load_to_do_temp->frame->next_frame->frame_named_location=load_to_do_temp->named_location;
						add_parse_item_to_to_do_list(load_file(load_to_do_temp->filename),load_to_do_temp->frame->next_frame);
						break;
					
					case 2: break; //add sub frame to passed frame - not used yet
				}
				break;
			
			case to_do_parse_frame:
				// parse a file and attach it to the passed frame
				parse_to_do_temp=read_to_do->message;
				parse_to_do_temp->frame->item=calculate_frame(parse_to_do_temp->file,&parse_to_do_temp->frame->frame_page_width);
				number_of_frames_left_to_load--;
				
				if(number_of_frames_left_to_load==0)
				{	
					calculate_frame_locations();
					redraw(window_handle,0,0,0,0,first_frame);
				}
				break;
		}
		to_do_item_temp=read_to_do;
		free(read_to_do->message);
		read_to_do=to_do_item_temp->next_to_do;
		free(to_do_item_temp);
	}
	add_to_do=0;
	return;
}

void
add_item_to_to_do_list(enum possible_message_types message_type, void *message_item)
{
	struct to_do_item *to_do_item_temp;
	
	to_do_item_temp=(struct to_do_item *)malloc(sizeof(struct to_do_item));
	if(add_to_do!=0)
		add_to_do->next_to_do=to_do_item_temp;
	add_to_do=to_do_item_temp;
	add_to_do->message_type=message_type;
	add_to_do->next_to_do=0;
	add_to_do->message=message_item;
	
	if(read_to_do==0)
		read_to_do=add_to_do;
}

void
add_load_item_to_to_do_list(short sub_type, char *address, struct frame_item *frame)
{
	struct load_to_do *load_to_do_temp;
	
	number_of_frames_left_to_load++;
	
	load_to_do_temp=(struct load_to_do *)malloc(sizeof(struct load_to_do));
	load_to_do_temp->sub_type=sub_type;
	load_to_do_temp->named_location=translate_address(address);
	load_to_do_temp->filename=address;
	load_to_do_temp->frame=frame;
	add_item_to_to_do_list(to_do_load_frame,load_to_do_temp);
}

void
add_parse_item_to_to_do_list(char *file, struct frame_item *frame)
{
	struct parse_to_do *parse_to_do_temp;
	parse_to_do_temp=(struct parse_to_do *)malloc(sizeof(struct parse_to_do));
	parse_to_do_temp->file=file;
	parse_to_do_temp->frame=frame;
	add_item_to_to_do_list(to_do_parse_frame,parse_to_do_temp);
}
