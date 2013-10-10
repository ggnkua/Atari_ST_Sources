#include <stdio.h>
#include "dialog.h"
#include "applicat.h"
/*************************************************************************************************************************/
/*************************************************************************************************************************/
extern RO_Func Function_list[];
extern int max_objects;
/*************************************************************************************************************************/
/*************************************************************************************************************************/
void draw_object(RO_Object *object, int x, int y)
{
	RO_Object *next=object->child;                                  /* Select the first child                            */
  
	if( object->type<=max_objects)                                  /* Is the Object in the object list                  */
	{
		if( Function_list[object->type].draw )                      /* Does the Object has a Draw function assigned      */
		Function_list[object->type].draw( object , x , y );         /* Then Draw the Object                              */
	}

	while( next )                                                   /* Does the current child exist?                     */
	{                                                               /* Then ...                                          */
		draw_object( next , x , y );                                /* Draw the current child and it's childs..          */
		next = next->next;                                          /* Move to the next child                            */
	}                                                               /* Until no more childs                              */
}



/*************************************************************************************************************************/
/*************************************************************************************************************************/
void draw_button( RO_Object *object , long x , long y)
{
  short x1 = 0 , x2 = 0 , y1 = 0 , y2 = 0;
  short xy[ 10 ] , dummy = 0;
  
  x1 = x + object->internal.x+object->out_x;                        /* Setting up the Coordinates for the Object         */
  x2 = x1+object->internal.w-1-2*object->out_x;                     /* ...                                               */
  y1 = y + object->internal.y+object->out_y;                        /* ...                                               */
  y2 = y1+object->internal.h-1-object->out_y;                       /* ...                                               */

  switch(object->Button->type)                                      /* Select between the different Button-types         */
  {
    case BUTTON_ROUNDED:                                            /* Round or Normal Button                            */
    case BUTTON_NORMAL:
    {
      xy[X1]=x1;
      xy[Y1]=y1;
      xy[X2]=x1;
      xy[Y2]=y2;
      xy[X3]=x2;
      xy[Y3]=y2;
      xy[X4]=x2;
      xy[Y4]=y1;
      xy[8]=x1;
      xy[9]=y1;
      vsl_color(appl->graph_id,COLOR_BLACK);
      v_pline(appl->graph_id,5,xy);
      x1++;
      y1++;
      x2--;
      y2--;

      if( object->Button->flags.Default)
      {
        xy[X1]=x1;
        xy[Y1]=y1;
        xy[X2]=x1;
        xy[Y2]=y2;
        xy[X3]=x2;
        xy[Y3]=y2;
        xy[X4]=x2;
        xy[Y4]=y1;
        xy[8]=x1;
        xy[9]=y1;
        vsl_color(appl->graph_id,COLOR_BLACK);
        v_pline(appl->graph_id,5,xy);
        x1++;
        y1++;
        x2--;
        y2--;
      }  
      xy[X1]=x1;
      xy[Y1]=y2;
      xy[X2]=x1;
      xy[Y2]=y1;
      xy[X3]=x2;
      xy[Y3]=y1;
      if(object->Button->flags.Selected)
        vsl_color(appl->graph_id,COLOR_DGRAY);
      else
        vsl_color(appl->graph_id,COLOR_WHITE);
      v_pline(appl->graph_id,3,xy);
    
      xy[X1]=x1+1;
      xy[Y1]=y2;
      xy[X2]=x2;
      xy[Y2]=y2;
      xy[X3]=x2;
      xy[Y3]=y1+1;
      if(object->Button->flags.Selected)
        vsl_color(appl->graph_id,COLOR_WHITE);
      else
        vsl_color(appl->graph_id,COLOR_DGRAY);
      v_pline(appl->graph_id,3,xy);
      x1++;
      y1++;
      x2--;
      y2--;
      xy[X1]=x1;
      xy[Y1]=y1;
      xy[X2]=x2;
      xy[Y2]=y2;
      vsf_color(appl->graph_id,COLOR_GRAY);
      vsf_interior(appl->graph_id,1);
      vr_recfl(appl->graph_id,xy);

      if(object->Button->text)
      {
		_set_font(appl, & object->Button->font );
		
        if(object->Button->flags.Selected)
          x1++;
        else
          y1--;
        vswr_mode(appl->graph_id,2);
		switch(object->Button->flags.Align_text)
		{
			case BUTTON_ALIGN_CENTER:
        		vst_alignment(appl->graph_id,1,5,&dummy,&dummy);
		        v_gtext( appl->graph_id , ( x1 + x2 + object->Button->text_x + 1 ) / 2 , y1 + object->Button->text_y , object->Button->text);
        		break;
			case BUTTON_ALIGN_LEFT:
        		vst_alignment(appl->graph_id,0,5,&dummy,&dummy);
        		v_gtext( appl->graph_id , x1 + object->Button->text_x , y1 + object->Button->text_y , object->Button->text );
				break;
			case BUTTON_ALIGN_RIGHT:
        		vst_alignment(appl->graph_id,2,5,&dummy,&dummy);
        		v_gtext( appl->graph_id , x2 + object->Button->text_x , y1 + object->Button->text_y , object->Button->text );
        		break;
        	case BUTTON_ALIGN_BOTH:
        		vst_alignment(appl->graph_id,0,5,&dummy,&dummy);
        		v_justified( appl->graph_id , x1 + object->Button->text_x , y1 + object->Button->text_y , object->Button->text , x2 - x1 , 1 , 1 );
		}
        vswr_mode(appl->graph_id,1);
      }
      break;
    }
    case BUTTON_RADIO:                                              /* Radio button (not fixed)                         */
/*
      to=&temp_objects[2];
      to->x=object->internal.x;
      to->y=object->internal.y;
      to->w=object->internal.w;
      to->h=object->internal.h;
      if(!(object->switches&SW_SELECTED))
        to->Image=&temp_images[0];
      else
        to->Image=&temp_images[1];
      draw(to,x,y);
      if(object->Button->text)
      {
		_set_font(appl, & object->Button->font );
        vst_alignment(appl->graph_id,0,5,&dummy,&dummy);
        x1+=3;
        vswr_mode(appl->graph_id,2);
        v_gtext(appl->graph_id,x1+16,y1,object->Button->text);
        vswr_mode(appl->graph_id,1);
      }
*/
      break;
    case BUTTON_CROSS:                                              /* Cross-check button                               */
    {
      x2=x1+16;
      y2=y1+16;
      xy[X1]=x1;
      xy[Y1]=y1;
      xy[X2]=x1;
      xy[Y2]=y2;
      xy[X3]=x2;
      xy[Y3]=y2;
      xy[X4]=x2;
      xy[Y4]=y1;
      xy[8]=x1;
      xy[9]=y1;
      vsl_color(appl->graph_id,COLOR_DGRAY);
      v_pline(appl->graph_id,5,xy);
      x1++;
      y1++;
      x2--;
      y2--;
      xy[X1]=x1;
      xy[Y1]=y2;
      xy[X2]=x1;
      xy[Y2]=y1;
      xy[X3]=x2;
      xy[Y3]=y1;
      vsl_color(appl->graph_id,COLOR_BLACK);
      v_pline(appl->graph_id,3,xy);
      xy[X1]=x1+1;
      xy[Y1]=y2;
      xy[X2]=x2;
      xy[Y2]=y2;
      xy[X3]=x2;
      xy[Y3]=y1+1;
      vsl_color(appl->graph_id,COLOR_GRAY);
      v_pline(appl->graph_id,3,xy);
      x1++;
      y1++;
      x2--;
      y2--;
      xy[X1]=x1;
      xy[Y1]=y1;
      xy[X2]=x2;
      xy[Y2]=y2;
      vsf_color(appl->graph_id,COLOR_WHITE);
      vsf_interior(appl->graph_id,1);
      vr_recfl(appl->graph_id,xy);
      x1++;
      y1++;
      x2--;
      y2--;
      if ( object->Button->flags.Selected)
      {
        vsl_color(appl->graph_id,COLOR_BLACK);
        xy[X1]=x1;
        xy[Y1]=y1;
        xy[X2]=x2;
        xy[Y2]=y2;
        v_pline(appl->graph_id,2,xy);
        xy[X1]=x1+1;
        xy[Y1]=y1;
        xy[X2]=x2;
        xy[Y2]=y2-1;
        v_pline(appl->graph_id,2,xy);
        xy[X1]=x1;
        xy[Y1]=y1+1;
        xy[X2]=x2-1;
        xy[Y2]=y2;
        v_pline(appl->graph_id,2,xy);
        xy[X1]=x1;
        xy[Y1]=y2;
        xy[X2]=x2;
        xy[Y2]=y1;
        v_pline(appl->graph_id,2,xy);
        xy[X1]=x1+1;
        xy[Y1]=y2;
        xy[X2]=x2;
        xy[Y2]=y1+1;
        v_pline(appl->graph_id,2,xy);
        xy[X1]=x1;
        xy[Y1]=y2-1;
        xy[X2]=x2-1;
        xy[Y2]=y1;
        v_pline(appl->graph_id,2,xy);
      }
      if(object->Button->text)
      {
		_set_font(appl, & object->Button->font );
        vst_alignment(appl->graph_id,0,5,&dummy,&dummy);
        x1+=3;
        y1-=2;
        vswr_mode(appl->graph_id,2);
        v_gtext(appl->graph_id,x1+16,y1,object->Button->text);
        vswr_mode(appl->graph_id,1);
      }
      break;
    }
  }
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
void draw_box(RO_Object *object, long x, long y)
{
  short x1 = 0 , x2 = 0 , y1 = 0 , y2 = 0;
  short xy[ 10 ] ;
  
  x1 = x + object->internal.x+object->out_x;
  x2 = x1+object->internal.w-1-2*object->out_x;
  y1 = y + object->internal.y+object->out_y;
  y2 = y1+object->internal.h-1-object->out_y;

  if( ( object->Box.effect & EFFECT_3DRAISED ) == EFFECT_3DRAISED )
  {
    xy[X1]=x1;
    xy[Y1]=y2;
    xy[X2]=x1;
    xy[Y2]=y1;
    xy[X3]=x2;
    xy[Y3]=y1;
    if( ( object->Box.color > COLOR_DGRAY ) && ( object->Box.color < 16 ) )
      vsl_color( appl->graph_id , object->Box.color - 8 );
    else
      vsl_color(appl->graph_id,COLOR_WHITE);
    v_pline(appl->graph_id,3,xy);
    xy[X1]++;
    xy[X2]=x2;
    xy[Y2]=y2;
    xy[Y3]++;
    if( ( object->Box.color > COLOR_BLACK ) && ( object->Box.color < COLOR_GRAY ) )
      vsl_color( appl->graph_id , object->Box.color+8 );
    else
      vsl_color( appl->graph_id , COLOR_BLACK );
    v_pline(appl->graph_id,3,xy);
    x1++;
    y1++;
    x2--;
    y2--;
  }
  xy[X1]=x1;
  xy[Y1]=y1;
  xy[X2]=x1;
  xy[Y2]=y2;
  xy[X3]=x2;
  xy[Y3]=y2;
  xy[X4]=x2;
  xy[Y4]=y1;
  xy[8]=x1;
  xy[9]=y1;
  if( ( ( object->Box.color > COLOR_BLACK ) && ( object->Box.color < COLOR_GRAY ) ) ||
      ( ( object->Box.color > COLOR_DGRAY ) && ( object->Box.color < 16 ) ))
    vsl_color(appl->graph_id,object->Box.color);
  else if( ( object->Box.effect & EFFECT_3DBORDER ) == EFFECT_3DBORDER )
    vsl_color( appl->graph_id , COLOR_GRAY );
  else
   vsl_color( appl->graph_id , COLOR_DGRAY );
  
  v_pline(appl->graph_id,5,xy);
  x1++;
  y1++;
  x2--;
  y2--;
  if( ( object->Box.effect & EFFECT_3DLOWERED ) == EFFECT_3DLOWERED )
  {
    xy[X1]=x1;
    xy[Y1]=y2;
    xy[X2]=x1;
    xy[Y2]=y1;
    xy[X3]=x2;
    xy[Y3]=y1;
    if( ( object->Box.color > COLOR_BLACK ) && ( object->Box.color < COLOR_GRAY ) )
      vsl_color( appl->graph_id , object->Box.color+8 );
    else
      vsl_color( appl->graph_id , COLOR_BLACK );
    v_pline(appl->graph_id,3,xy);
    xy[X1]++;
    xy[X2]=x2;
    xy[Y2]=y2;
    xy[Y3]++;
    if( ( object->Box.color > COLOR_DGRAY ) && ( object->Box.color < 16 ) )
      vsl_color( appl->graph_id , object->Box.color - 8 );
    else
      vsl_color(appl->graph_id,COLOR_WHITE);
    v_pline(appl->graph_id,3,xy);
    x1++;
    y1++;
    x2--;
    y2--;
  }
  vsf_color(appl->graph_id,object->Box.fcolor);
  vsf_style(appl->graph_id,object->Box.fpattern);
  vsf_interior(appl->graph_id,object->Box.fstyle);
  xy[X1]=x1;
  xy[Y1]=y1;
  xy[X2]=x2;
  xy[Y2]=y2;
  vr_recfl(appl->graph_id,xy);
  
}
/*************************************************************************************************************************/
/*************************************************************************************************************************/
void draw_dialog(RO_Object *object, long x, long y)
{
  RO_Object t_object;
  
  t_object.type=RO_BOX;
  t_object.internal.x=object->internal.x;
  t_object.internal.y=object->internal.y;
  t_object.internal.w=object->internal.w;
  t_object.internal.h=object->internal.h;
  t_object.child=NULL;
  t_object.out_x=object->out_x;
  t_object.out_y=object->out_y;
  t_object.Box.color=COLOR_GREY;
  t_object.Box.fcolor=COLOR_GREY;
  t_object.Box.fstyle=FSTYLE_SOLID;
  t_object.Box.effect=EFFECT_3DBORDER;
  t_object.Box.fpattern=FPATTERN_SOLID100;
  draw_object( &t_object , x , y );
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
void draw_textarea(RO_Object *object, long x, long y)
{
  RO_Object t_object;

  t_object.type=RO_BOX;
  t_object.internal.x=object->internal.x;
  t_object.internal.y=object->internal.y;
  t_object.internal.w=object->internal.w;
  t_object.internal.h=object->internal.h;
  t_object.child=NULL;
  t_object.out_x=object->out_x;
  t_object.out_y=object->out_y;
  t_object.Box.color=COLOR_GREY;
  t_object.Box.fcolor=COLOR_WHITE;
  t_object.Box.fstyle=FSTYLE_SOLID;
  t_object.Box.effect=EFFECT_3DLOWERED;
  t_object.Box.fpattern=FPATTERN_SOLID100;
  draw_object( &t_object , x , y );
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
void draw_string(RO_Object *object, long x, long y)
{
  short dummy = 0;

  if( object->String )
  {
	_set_font( appl , 0 );
//    vst_color( appl->graph_id , COLOR_BLACK );
    vst_alignment( appl->graph_id , 0 , 5 , &dummy , &dummy );
    vswr_mode( appl->graph_id , 2 );
    v_gtext( appl->graph_id , x + object->internal.x + object->out_x , y + object->internal.y + object->out_y , object->String );
    vswr_mode( appl->graph_id , 1 );
  }
}

/*************************************************************************************************************************/
/*************************************************************************************************************************/
void draw_scrollbar(RO_Object *object, int x, int y)
{
  RO_Object t_object;
  RO_Button t_button;
  t_button.font.Id = -1;
  t_button.font.Size = -1;
  t_button.font.Colour = -1;
  t_button.font.Effects = -1;
  memcpy(&t_object , object , sizeof(RO_Object) );
  t_object.flags.Max_w=0;
  t_object.flags.Max_h=0;
  t_object.flags.Change_w=0;
  t_object.flags.Change_h=0;
  t_object.flags.Same_w=0;
  t_object.flags.Same_h=0;
  t_object.out_x=0;
  t_object.out_y=0;
  x+=object->out_x;
  y+=object->out_y;
  if(object->parent->flags.Alignment)
  {
    t_object.type=RO_BUTTON;
    t_object.Button=&t_button;
    t_object.Button->type=BUTTON_NORMAL;
    t_object.Button->text="";
    calculate_small_size(&t_object);
    calculate_new_size(&t_object);
    t_object.internal.x=object->internal.x;
    t_object.internal.y=object->internal.y;
    draw_object(&t_object,x,y);
    t_object.internal.x=object->internal.x+object->internal.w-t_object.internal.w;
    t_object.Button->text="";
    draw_object(&t_object,x,y);
    t_object.type=RO_BOX;
    t_object.internal.x=object->internal.x+t_object.internal.w;
    t_object.internal.y=object->internal.y;
    t_object.internal.w=object->internal.w-2*t_object.internal.w;
    t_object.Box.color=COLOR_BLACK;
    t_object.Box.fcolor=COLOR_DGRAY;
    t_object.Box.fstyle=FSTYLE_SOLID;
    t_object.Box.fpattern=FPATTERN_SOLID100;
    t_object.Box.effect=EFFECT_3DLOWERED;
    draw_object(&t_object,x,y);
  }
  else
  {
    t_object.type=RO_BUTTON;
    t_object.Button=&t_button;
    t_object.Button->type=BUTTON_NORMAL;
    t_object.Button->text="";
    calculate_small_size(&t_object);
    calculate_new_size(&t_object);
    t_object.internal.x=object->internal.x;
    t_object.internal.y=object->internal.y;
    draw_object(&t_object,x,y);
    t_object.internal.y=object->internal.y + object->internal.h-t_object.internal.h;
    t_object.Button->text="";
    draw_object(&t_object,x,y);
    t_object.type=RO_BOX;
    t_object.internal.x=object->internal.x;
    t_object.internal.y=object->internal.y + t_object.internal.h;
    t_object.internal.h=object->internal.h - 2 * t_object.internal.h;
    t_object.Box.color=COLOR_BLACK;
    t_object.Box.fcolor=COLOR_GRAY;
    t_object.Box.fstyle=FSTYLE_SOLID;
    t_object.Box.fpattern=FPATTERN_SOLID100;
    t_object.Box.effect=EFFECT_3DLOWERED;
    draw_object(&t_object,x,y);
  }
}