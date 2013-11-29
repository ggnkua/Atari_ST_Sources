#include <stdio.h>
#include "dialog.h"
#include "applicat.h"
/*************************************************************************************************************************/
extern RO_Func Function_list[];
extern int max_objects;
/*************************************************************************************************************************/
/*************************************************************************************************************************/
void calculate_small_size(RO_Object *object)
{
	RO_Object *next=object->child;                       /* Get the first child that the parent has           */
  
	object->internal.x=0;
	object->internal.y=0;
	object->internal.w=0;
	object->internal.h=0;
	/*********************************************************************************************************************/
	/* Starting to Calculate the minimum size that the childs are taking                                                 */
  
	while( next )                                              /* does the current child exist?                     */
	{
		calculate_small_size(next);                              /* Move down 1 section in the tree                   */
		if(next->flags.Change_w)                                 /* Can the Width of the child be changed in runtime? */
			object->flags.Change_w=1;                                     /* The change the Parent property for this also.     */
		if(next->flags.Change_h)                                 /* ... same as above but for the height              */
			object->flags.Change_h=1;                                     /* ...                                               */
		if(!object->flags.Alignment)                                    /* if the Parents alignment is Left to Right         */
		{
			object->internal.w+=next->internal.w;                                    /* add the childs size to the parent                 */
			if(object->internal.h<next->internal.h)                                  /* if the childs hight is bigger then the parents    */
				object->internal.h=next->internal.h;                                   /* Use the childs height as the parents              */
		}
		else                                                            /* If the parents alignment is Up to down            */
		{
			object->internal.h+=next->internal.h;                                    /* do the same as above but for height, not width     */
			if(object->internal.w<next->internal.w)                                  /* ...                                                */    
				object->internal.w=next->internal.w;                                   /* ...                                                */
		}
		next=next->next;                                  /* move to the next child that this parent got        */
	}

	/*********************************************************************************************************************/
	/* Calculate the new minimum size depending on object type                                                            */

	if( object->type<=max_objects)
	{
		if( Function_list[object->type].min_size )
			Function_list[object->type].min_size( object );
	}
	/*********************************************************************************************************************/

	next = object->child;                                /* move to the first child of the parent              */
	while( next )                                              /* continue while child exist                         */
	{
		if(next->type==RO_GROUP)                                 /* If the child is a Group-object                     */
		{
			if(!object->flags.Alignment)                            /* and the parents alignment is Left to Right         */
				next->internal.h=object->internal.h;                             /* Then use the same width as the parent minus offset  */
			else                                                          /* or the parents alignment is Up to Down             */
				next->internal.w=object->internal.w;                             /* then use the smae height as the parent             */ 
		}
		else                                                            /* Else if the Object is NOt a group-object           */
		{
			if(!object->flags.Alignment && next->flags.Max_h)/* if the alignment is LEft to right an the child has */
				next->internal.h=object->internal.h;                             /* Max_w set, then use the same w as the parent       */
			if(object->flags.Alignment && next->flags.Max_w) /* if the alignment is Up to down an the child has    */
				next->internal.w=object->internal.w;                             /* Max_h set, then use the same h as the parent       */
		}
		next=next->next;                                  /* move to the next child                             */
	}
	object->internal.w+=2*(object->in_x+object->out_x);     /* Add the offset to the minimum width                */
	object->internal.h+=2*(object->in_y+object->out_y);     /* Add the offset to the minimum height               */
	object->internal.min_w = object->internal.w;
	object->internal.min_h = object->internal.h;
}
/*************************************************************************************************************************/
/*************************************************************************************************************************/
/*************************************************************************************************************************/
/*************************************************************************************************************************/
void small_button( RO_Object *object )
{
  short extent[8];
  
  if(object->Button->text)
  {
	_set_font(appl, & object->Button->font );
    vqt_extent( appl->graph_id , object->Button->text , extent );
    if( object->flags.Alignment == ALIGNMENT_HORISONTAL)
    {
      object->Button->text_y = object->internal.h + object->in_y;
      object->Button->text_x = object->in_x;
      object->internal.h += extent[ 5 ] +2;
      if( object->internal.w < extent[ 2 ] )
        object->internal.w = extent[ 2 ] + 6;
    }
    else
    {
      object->Button->text_x = object->internal.w + object->in_x;
      object->Button->text_y = object->in_y;
      object->internal.w += extent[ 2 ] +2;
      if( object->internal.h < extent[ 5 ] )
        object->internal.h = extent[ 5 ] + 6;
    }
  }
  else
  {
    object->internal.w+=20;
    object->internal.h+=20;
  }
}
/*************************************************************************************************************************/
/*************************************************************************************************************************/
void small_textarea( RO_Object *object )
{
  if( !object->flags.Alignment )
  {
    object->internal.w += 100;
    if( object->internal.h < 50 )
      object->internal.h = 50;
  }
  else
  {
    object->internal.h += 50;
    if( object->internal.w < 100)
      object->internal.w = 100;
  }
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
void small_string( RO_Object *object )
{
  short extent[8];
  
  if(object->String)
  {
    vqt_extent( appl->graph_id , object->String , extent );
    if( !object->flags.Alignment )
    {
      object->internal.h += extent[ 5 ];
      if( object->internal.w < extent[ 2 ] )
        object->internal.w = extent[ 2 ];
    }
    else
    {
      object->internal.w += extent[ 2 ];
      if( object->internal.h < extent[ 5 ] )
        object->internal.h = extent[ 5 ];
    }
  }
}

/*************************************************************************************************************************/
void small_scrollbar( RO_Object *object )
{
  RO_Object t_object;
  RO_Button t_button;
  memcpy(&t_object , object , sizeof(RO_Object) );
  t_object.type=RO_BUTTON;
  t_object.Button=&t_button;
  t_object.Button->type=BUTTON_NORMAL;
  t_object.Button->text="";
  calculate_small_size(&t_object);
  
  if(object->parent->flags.Alignment)
  {
    object->internal.w=3*t_object.internal.w;
    object->internal.h=t_object.internal.h;
  }
  else
  {
    object->internal.w=t_object.internal.w;
    object->internal.h=3*t_object.internal.h;
  }
}