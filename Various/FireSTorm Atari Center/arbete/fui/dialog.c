#include "dialog.h"
#include "applicat.h"

#include <stdio.h>
#include <osbind.h>
/*************************************************************************************************************************/
void draw_button( RO_Object *object , long x , long y);
void draw_box(RO_Object *object, long x, long y);
void draw_dialog(RO_Object *object, long x, long y);
void draw_textarea(RO_Object *object, long x, long y);
void draw_string(RO_Object *object, long x, long y);
void draw_scrollbar(RO_Object *object, long x, long y);
void small_button( RO_Object *object );
void small_textarea( RO_Object *object );
void small_string( RO_Object *object );
void small_scrollbar( RO_Object *object );
/*************************************************************************************************************************/
RO_Func Function_list[]=
{
  /* RO_TREE            */ { NULL , NULL             , NULL            , NULL },
  /* RO_DIALOG          */ { NULL , NULL             , &draw_dialog    , NULL },
  /* RO_GROUP           */ { NULL , NULL             , NULL            , NULL },
  /* RO_BUTTON          */ { NULL , &small_button    , &draw_button    , NULL },
  /* RO_BUTTONHELP      */ { NULL , NULL             , NULL            , NULL },
  /* RO_BUTTONSCROLL    */ { NULL , NULL             , NULL            , NULL },
  /* RO_SLIDEBOX        */ { NULL , NULL             , NULL            , NULL },
  /* RO_TEXT            */ { NULL , NULL             , NULL            , NULL },
  /* RO_TEXTINPUT       */ { NULL , NULL             , NULL            , NULL },
  /* RO_TEXTINPUTSECRET */ { NULL , NULL             , NULL            , NULL },
  /* RO_TEXTINPUTMENU   */ { NULL , NULL             , NULL            , NULL },
  /* RO_TEXTAREA        */ { NULL , &small_textarea  , &draw_textarea  , NULL },
  /* RO_TEXTINPUTAREA   */ { NULL , NULL             , NULL            , NULL },
  /* RO_TEXTLISTAREA    */ { NULL , NULL             , NULL            , NULL }, 
  /* RO_PICTURELISTAREA */ { NULL , NULL             , NULL            , NULL }, 
  /* RO_ICON            */ { NULL , NULL             , NULL            , NULL },
  /* RO_BOX             */ { NULL , NULL             , &draw_box       , NULL }, 
  /* RO_IMAGE           */ { NULL , NULL             , NULL            , NULL },
  /* RO_TOOLPANEL       */ { NULL , NULL             , NULL            , NULL },
  /* RO_TOOLPANELGROUP  */ { NULL , NULL             , NULL            , NULL },
  /* RO_PANEL           */ { NULL , NULL             , NULL            , NULL },
  /* RO_SCROLLBAR       */ { NULL , &small_scrollbar , &draw_scrollbar , NULL },
  /* RO_STRING          */ { NULL , &small_string    , &draw_string    , NULL },
};

int max_objects = RO_STRING;

/*************************************************************************************************************************/
/*************************************************************************************************************************/
void calculate_new_size(RO_Object *start_object, int w, int h)
{
	int change_able_w=0,change_able_h=0;
	int obj_w=start_object->internal.min_w-2*(start_object->out_x+start_object->in_x);
	int obj_h=start_object->internal.min_h-2*(start_object->out_y+start_object->in_y);
	int max_w=0,max_h=0;
	int total_w=0,total_h=0;
	int left_change_w=0,left_change_h=0;
	int left_max_w=0,left_max_h=0;
	RO_Object *next_object=start_object->child;

	if(w<start_object->internal.min_w)
		w=start_object->internal.min_w;
	if(h<start_object->internal.min_h)
		h=start_object->internal.min_h;
	w-=2*(start_object->out_x+start_object->in_x);
	h-=2*(start_object->out_y+start_object->in_y);

  while( next_object )
  {
    if(start_object->flags.Alignment == ALIGNMENT_HORISONTAL)                              /* sorting Left to Right */
    {
      total_w+=next_object->internal.min_w;
	  total_h=obj_h;
      if(next_object->flags.Change_w)
	    change_able_w+=next_object->internal.min_w;
      if(next_object->flags.Change_h)
	    change_able_h=total_h;
      if(next_object->flags.Max_w)
        max_w+=next_object->internal.min_w;
      if(next_object->flags.Max_h)
        max_h=total_h;
	}
	else                                                            /* Sorting Up to Down */
	{
      total_w=obj_w;
      total_h+=next_object->internal.min_h;
	  if(next_object->flags.Change_h)
	    change_able_h+=next_object->internal.min_h;
      if(next_object->flags.Change_w)
	    change_able_w=total_w;
      if(next_object->flags.Max_w)
        max_w=total_w;
      if(next_object->flags.Max_h)
        max_h+=next_object->internal.min_h;
    }
    next_object=next_object->next;                                  /* move to the next child                             */
  }
  left_change_w=w-(total_w-change_able_w);
  left_change_h=h-(total_h-change_able_h);
  left_max_w=w-(total_w-max_w);
  left_max_h=w-(total_w-max_w);

  next_object=start_object->child;
  while( next_object )
  {
    if(!start_object->flags.Alignment && next_object->flags.Max_w)
    {
      next_object->internal.w=(obj_w)*left_max_w/max_w;
    }
    if(start_object->flags.Alignment && next_object->flags.Max_h)
    {
      next_object->internal.h=(obj_h)*left_max_h/max_h;
	}
	if(next_object->flags.Change_w && next_object->flags.Change_h)
      calculate_new_size(next_object, next_object->internal.w*left_change_w/change_able_w, next_object->internal.h*left_change_h/change_able_h);
	else if(next_object->flags.Change_w)
    {
      calculate_new_size(next_object, next_object->internal.w*left_change_w/change_able_w, next_object->internal.h);
	}
	else if(next_object->flags.Change_h)
      calculate_new_size(next_object, next_object->internal.w, next_object->internal.h*left_change_h/change_able_h);
    next_object=next_object->next;                                  /* move to the next child                             */
  }

  if(start_object->internal.w<w && start_object->flags.Change_w)
    start_object->internal.w=w+2*(start_object->out_x+start_object->in_x);
  if(start_object->internal.h<h && start_object->flags.Change_h)
    start_object->internal.h=h+2*(start_object->out_y+start_object->in_y);
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
void calculate_xy_pos(RO_Object *start_object,int x,int y)
{
  RO_Object *next_object=start_object->child, *parent=start_object->parent;

  if(parent)
  {
    if(parent->flags.Alignment)
    {
      if((start_object->flags.pAlign_left && start_object->flags.pAlign_right)||(!start_object->flags.pAlign_left && !start_object->flags.pAlign_right))
      {
        switch(parent->type)
        {
          case RO_BUTTON:
            start_object->internal.x=x;
            break;
          default:
            start_object->internal.x=x+(start_object->parent->internal.w-start_object->parent->in_x-start_object->internal.w)/2;
            break;
        }
      }
      else if(!start_object->flags.pAlign_left && start_object->flags.pAlign_right)
      {
        switch(parent->type)
        {
          case RO_BUTTON:
            start_object->internal.x=x;
            break;
          default:
            start_object->internal.x=x+start_object->parent->internal.w-start_object->parent->in_x-start_object->internal.w;
            break;
        }
      }
      else
        start_object->internal.x=x;
      start_object->internal.y=y;
    }
    else
    {
      if((start_object->flags.pAlign_top && start_object->flags.pAlign_bottom)||(!start_object->flags.pAlign_top && !start_object->flags.pAlign_bottom))
      {
        switch(parent->type)
        {
          case RO_BUTTON:
            start_object->internal.y=y;
            break;
          default:
            start_object->internal.y=y+(start_object->parent->internal.h-start_object->parent->in_y-start_object->internal.h)/2;
            break;
        }
      }
      else if(!start_object->flags.pAlign_top && start_object->flags.pAlign_bottom)
      {
        switch(parent->type)
        {
          case RO_BUTTON:
            start_object->internal.y=y;
            break;
          default:
            start_object->internal.y=y+start_object->parent->internal.h-start_object->parent->in_y-start_object->internal.h;
            break;
        }
      }
      else
        start_object->internal.y=y;
      start_object->internal.x=x;
    }
    
  }
  else
  {
    start_object->internal.x=x;
    start_object->internal.y=y;
  }
  x+=start_object->in_x;
  y+=start_object->in_y;
  while( next_object )                                              /* does the current child exist?                     */
  {
  	calculate_xy_pos(next_object,x,y);
  	if(!start_object->flags.Alignment)
  	  x+=next_object->internal.w;
  	else
  	  y+=next_object->internal.h;
    next_object=next_object->next;                                  /* move to the next child                             */
  }
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
void add_object(RO_Object *Parent , int position , RO_Object *object )
{
	if( ! Parent->child )
		Parent->child = object;
	else if(position == OBJECT_LAST)
	{
		RO_Object *temp = Parent->child;
		while( temp->next )
			temp = temp->next;
		temp->next = object;
	}
	else if(position == OBJECT_FIRST)
	{
		object->next = Parent->child;
		Parent->child = object;
	}

	object->parent = Parent;
	
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
void remove_object(RO_Object *object)
{
	if( object->parent->child == object )
		object->parent->child = object->next;
	else if( object->parent )
	{
		RO_Object *temp = object->parent->child;
		while( temp->next != object )
			temp = temp->next;
		temp->next = object->next;
	}
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
void delete_object(RO_Object *object , int recursive)
{
	if( recursive )
	{
		if( object->child )
			delete_object( object->child , recursive );
		if( object->next )
			delete_object( object->next , recursive );
	}
	
	remove_object( object );
	switch( object->type )
	{
		case RO_BOX:
			break;
		default:
			Mfree( object->Data );
			break;
	}
	Mfree( object );

}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
void _set_font( Application *appl , RO_Font *font )
{
	short dummy;
	
	if( font )
	{
		if( font->Colour >= 0 )
			vst_color( appl->graph_id,font->Colour );
		else
			vst_color( appl->graph_id,appl->font.Colour );
		if( font->Id >= 0 )
			vst_font( appl->graph_id,font->Id );
		else
			vst_font( appl->graph_id,appl->font.Id );

		if( font->Size >= 0 )
			vst_point( appl->graph_id , font->Size , &dummy , &dummy , &dummy , &dummy );
		else
			vst_point( appl->graph_id , appl->font.Size , &dummy , &dummy , &dummy , &dummy );

		if( font->Effects >= 0)
			vst_effects( appl->graph_id , font->Effects );
		else
			vst_effects( appl->graph_id , appl->font.Effects );
	}
	else
	{
		vst_color( appl->graph_id , appl->font.Colour );
		vst_font( appl->graph_id , appl->font.Id );
		vst_point( appl->graph_id , appl->font.Size , &dummy , &dummy , &dummy , &dummy );
		vst_effects( appl->graph_id , appl->font.Effects );
	}
}