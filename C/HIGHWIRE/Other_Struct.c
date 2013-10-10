#include <string.h>

#include "HighWire.h"

void
destroy_clickable_area_structure(struct clickable_area *current_area)
{
	struct clickable_area *temp;
	
	while(current_area!=0)
	{
		temp=current_area->next_area;
		free(current_area);
		current_area=temp;
	}
}

struct clickable_area *
new_clickable_area()
{
	struct clickable_area *temp;
	temp=(struct clickable_area *)malloc(sizeof(struct clickable_area));
	temp->x=0;
	temp->y=0;
	temp->w=0;
	temp->h=0;
	temp->link=0;
	temp->next_area=0;
	return(temp);
}

/* ********************************* */

void
destroy_named_location_structure(struct named_location *current_location)
{
	struct named_location *temp;
	
	while(current_location!=0)
	{
		temp=current_location->next_location;
		free(current_location);
		current_location=temp;
	}
}

struct named_location *
new_named_location()
{
	struct named_location *temp;
	temp=(struct named_location *)malloc(sizeof(struct named_location));
	temp->position=0;
	temp->link=0;
	temp->next_location=0;
	return(temp);
}

/* ****************************** */

struct font_step *
new_step(short size)
{
	struct font_step *temp;
	temp=(struct font_step *)malloc(sizeof(struct font_step));
	temp->step=size;
	temp->previous_font_step=0;
	return(temp);
}

struct font_step *
add_step(struct font_step *old)
{
	struct font_step *temp;
	temp=new_step(old->step);
	temp->previous_font_step=old;
	return(temp);
}

struct font_step *
destroy_step(struct font_step *current)
{
	struct font_step *temp;
	if(current->previous_font_step != 0)
	{
		temp=current->previous_font_step;
		free(current);
		return(temp);
	}
	else
		return(current);
}

/* ******************************** */


struct list_stack_item *
new_stack_list_item(void)
{
	struct list_stack_item *temp;
	temp=(struct list_stack_item *) malloc(sizeof(struct list_stack_item));
	temp->bullet_style=disc;
	temp->current_list_count=0;
	temp->next_stack_item=0;
	return(temp);
}

struct list_stack_item *
remove_stack_item(struct list_stack_item *current_item)
{
	struct list_stack_item *temp;
	temp=current_item->next_stack_item;
	free(current_item);
	return(temp);
}

/* ******************************** */

struct url_link *
new_url_link(char *output, enum link_mode url_mode)
{
	struct url_link *temp;
	temp=(struct url_link *)malloc(sizeof(struct url_link));
	temp->mode=url_mode;
	temp->address=strdup(output);
	return(temp);
}
