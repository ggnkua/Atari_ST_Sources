#include "dialog.h"

#define TEMP_BOX    0
#define TEMP_BUTTON 1
#define TEMP_IMAGE  2

short x1,y1,x2,y2,xy[10];
short work_in[11], work_out[57];
short graph_id;
short dummy;

extern RO_Object temp_objects[];
extern RO_Image temp_images[];
/****************************************************************************************/
/* Letar reda p† ett object med ett visst namn, genom att anv„nda denna rutin och genom */
/* att namge objekt s† kan man bli totalt oberoende fr†n hur objektet ser ut.           */
/****************************************************************************************/
long find_object(RO_Object *tree,char *name)
{
  long temp_object=0,
       number_of=0,
       counter;
  int  correct;
  
  if(!name)
    return -1;
  do
  {
    number_of+=tree[temp_object].w+1;
    temp_object=tree[temp_object].next;
  }while( temp_object>=0);
  
  temp_object=0;
  while( temp_object < number_of )
  {
    correct=1; 
    for ( counter=0 ; counter < 16 ; counter++ )
    {
      if (( name[counter] == 0 ) && ( tree[temp_object].name[counter] == 0 ))
        break;
      if (( name[counter]== 0 ) && ( tree[temp_object].name[counter] == 0 ))
      {
        correct=0;
        break;
      }
      if (name[counter]!=tree[temp_object].name[counter])
      {
        correct=0;
        break;
      }
    }
    if(correct==1)
      return(temp_object);
    temp_object++;
  }
  return(-1);
}
/****************************************************************************************/
/* placerar in ett object p† ett nytt st„lle                                            */
/****************************************************************************************/
int reorder_object(RO_Object *tree,char *object, char *next,char *prev,char *parent, char*child)
{
  long o_object,o_next,o_prev,o_parent,o_child;
  o_object=find_object(tree,object);
  o_next=find_object(tree,next);
  o_prev=find_object(tree,next);
  o_parent=find_object(tree,next);
  o_child=find_object(tree,next);
  return 0; 
}

/********************************************************************/
/* This Log-function should work almost like printf                 */
/* %d - int                                                         */
/* %l - long                                                        */
/* %s - char *                                                      */
/********************************************************************/
#include <stdarg.h>
#include <stdio.h>
void Log(char *logstring,...)
{
  char *point=logstring;
  int num_parm=0L;
  va_list ap;
  FILE *logfile;

  logfile=fopen("dialog.log","a");
  if(!logfile)
  {
    while(*point!=0)
    {
      if(*point=='%')
      {
        point++;
        if((*point=='c')||(*point=='d')||(*point=='s')||(*point=='l'))
          num_parm++;
        if(*point==0)
          point--;
      }
      point++;
    }
    if(num_parm>0)
      va_start(ap,logstring);
    point=logstring;
    
    while(*point!=0)
    {
      if(*point=='%')
      {
        point++;
         if(*point=='%')
         fputc('%',logfile);
        else if(*point=='d')
          fprintf(logfile,"%d",va_arg(ap,int));
        else if(*point=='l')
          fprintf(logfile,"%ld",va_arg(ap,long));
        else if(*point=='s')
          fprintf(logfile,"%s",va_arg(ap,char *));
        else if(*point!=0)
        {
          fputc('%',logfile);
          fputc(*point,logfile);
        }
        else
          point--;
      }
      else
        fputc(*point,logfile);
      point++;
    }
    fclose(logfile);
    va_end(ap);
  }
}
/****************************************************************************************/
/* Visar de olika objekten (anropar i sin tur de specifika rutiner som visar objekten)  */
/****************************************************************************************/
void show(RO_Object *tree,long object)
{
  long temp_object=object;
  long x=0 , y=0;
  int hidden;
  
  if(object==-1)
    return;

  hidden=0;
  while( tree[ temp_object ].parent >= 0 )
  {
    x+=tree[tree[temp_object].parent].x;
    y+=tree[tree[temp_object].parent].y;
    if(tree[tree[temp_object].parent].type==RO_WINDOW)
      y+=20;
    if( tree[ temp_object ].switches & SW_HIDDEN )
      hidden=1;
    temp_object=tree[temp_object].parent;
    
  }
  if(hidden)
    return;
  temp_object=object;
  graf_mouse(256,0);
//  do
//  {
    switch(tree[temp_object].type)
    {
      case RO_BUTTON:
        draw_button( &tree[ temp_object ] , x , y );
        break;
      case RO_BOX:
        draw_box( &tree[ temp_object ] , x , y );
        break;
      case RO_WINDOW:
        draw_window( &tree[ temp_object ] , x , y );
        break;
      case RO_IMAGE:
        draw_image( &tree[ temp_object ] , x , y );
        break;
      case RO_SCROLLBAR:
        draw_scrollbar( &tree[ temp_object ] , x , y );
      case RO_STRING:
        draw_string( &tree[ temp_object ] , x , y );
    }
    if( tree[ temp_object ].child >= 0 )
    {
      temp_object = tree[ temp_object ].child;
      show( tree , temp_object );
      temp_object = tree[ temp_object ].next;
      while( temp_object >= 0 )
      {
        show(tree , temp_object );
        temp_object = tree[ temp_object ].next ;
      }
    }
//  }while( temp_object != tree );
  graf_mouse( 257 , 0 );
}

/****************************************************************************************/
/*                                                                                      */
/****************************************************************************************/
void draw_button(RO_Object *object, long x, long y)
{
  RO_Object *to;
  x1 = x + object->x;
  x2 = x1+object->w-1;
  y1 = y + object->y;
  y2 = y1+object->h-1;
  switch(object->Button->type)
  {
    case BUTTON_ROUNDED:
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
      vsl_color(graph_id,COLOR_BLACK);
      v_pline(graph_id,5,xy);
      x1++;
      y1++;
      x2--;
      y2--;

      if( object->switches&SW_DEFAULT)
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
        vsl_color(graph_id,COLOR_BLACK);
        v_pline(graph_id,5,xy);
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
      if(object->switches&SW_SELECTED)
        vsl_color(graph_id,COLOR_DGRAY);
      else
        vsl_color(graph_id,COLOR_WHITE);
      v_pline(graph_id,3,xy);
    
      xy[X1]=x1+1;
      xy[Y1]=y2;
      xy[X2]=x2;
      xy[Y2]=y2;
      xy[X3]=x2;
      xy[Y3]=y1+1;
      if(object->switches&SW_SELECTED)
        vsl_color(graph_id,COLOR_WHITE);
      else
        vsl_color(graph_id,COLOR_DGRAY);
      v_pline(graph_id,3,xy);
      x1++;
      y1++;
      x2--;
      y2--;
      xy[X1]=x1;
      xy[Y1]=y1;
      xy[X2]=x2;
      xy[Y2]=y2;
      vsf_color(graph_id,COLOR_GRAY);
      vsf_interior(graph_id,1);
      vr_recfl(graph_id,xy);
      if(object->Button->text)
      {
        vst_font(graph_id,1);
        vst_color(graph_id,COLOR_BLACK);
        vst_point(graph_id,10,&dummy,&dummy,&dummy,&dummy);
        vst_alignment(graph_id,1,5,&dummy,&dummy);
        vst_effects(graph_id,0);
        if(object->switches&SW_SELECTED)
          x1++;
        else
          y1--;
        vswr_mode(graph_id,2);
        v_gtext(graph_id,(x2+x1)/2,y1,object->Button->text);
        vswr_mode(graph_id,1);
      }
      break;
    }
    case BUTTON_RADIO:
      to=&temp_objects[2];
      to->x=object->x;
      to->y=object->y;
      to->w=object->w;
      to->h=object->h;
      if(!(object->switches&SW_SELECTED))
        to->Image=&temp_images[0];
      else
        to->Image=&temp_images[1];
      draw_image(to,x,y);
      if(object->Button->text)
      {
        vst_font(graph_id,1);
        vst_color(graph_id,COLOR_BLACK);
        vst_point(graph_id,10,&dummy,&dummy,&dummy,&dummy);
        vst_alignment(graph_id,0,5,&dummy,&dummy);
        vst_effects(graph_id,0);
        x1+=3;
        vswr_mode(graph_id,2);
        v_gtext(graph_id,x1+16,y1,object->Button->text);
        vswr_mode(graph_id,1);
      }
      break;
    case BUTTON_CROSS:
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
      vsl_color(graph_id,COLOR_DGRAY);
      v_pline(graph_id,5,xy);
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
      vsl_color(graph_id,COLOR_BLACK);
      v_pline(graph_id,3,xy);
      xy[X1]=x1+1;
      xy[Y1]=y2;
      xy[X2]=x2;
      xy[Y2]=y2;
      xy[X3]=x2;
      xy[Y3]=y1+1;
      vsl_color(graph_id,COLOR_GRAY);
      v_pline(graph_id,3,xy);
      x1++;
      y1++;
      x2--;
      y2--;
      xy[X1]=x1;
      xy[Y1]=y1;
      xy[X2]=x2;
      xy[Y2]=y2;
      vsf_color(graph_id,COLOR_WHITE);
      vsf_interior(graph_id,1);
      vr_recfl(graph_id,xy);
      x1++;
      y1++;
      x2--;
      y2--;
      if ( object->switches & SW_SELECTED)
      {
        vsl_color(graph_id,COLOR_BLACK);
        xy[X1]=x1;
        xy[Y1]=y1;
        xy[X2]=x2;
        xy[Y2]=y2;
        v_pline(graph_id,2,xy);
        xy[X1]=x1+1;
        xy[Y1]=y1;
        xy[X2]=x2;
        xy[Y2]=y2-1;
        v_pline(graph_id,2,xy);
        xy[X1]=x1;
        xy[Y1]=y1+1;
        xy[X2]=x2-1;
        xy[Y2]=y2;
        v_pline(graph_id,2,xy);
        xy[X1]=x1;
        xy[Y1]=y2;
        xy[X2]=x2;
        xy[Y2]=y1;
        v_pline(graph_id,2,xy);
        xy[X1]=x1+1;
        xy[Y1]=y2;
        xy[X2]=x2;
        xy[Y2]=y1+1;
        v_pline(graph_id,2,xy);
        xy[X1]=x1;
        xy[Y1]=y2-1;
        xy[X2]=x2-1;
        xy[Y2]=y1;
        v_pline(graph_id,2,xy);
      }
      if(object->Button->text)
      {
        vst_font(graph_id,1);
        vst_color(graph_id,COLOR_BLACK);
        vst_point(graph_id,10,&dummy,&dummy,&dummy,&dummy);
        vst_alignment(graph_id,0,5,&dummy,&dummy);
        vst_effects(graph_id,0);
        x1+=3;
        y1-=2;
        vswr_mode(graph_id,2);
        v_gtext(graph_id,x1+16,y1,object->Button->text);
        vswr_mode(graph_id,1);
      }
      break;
    }
  }
}

/****************************************************************************************/
/*                                                                                      */
/****************************************************************************************/
void draw_box(RO_Object *object, long x, long y)
{
  x1=x + object->x;
  x2=x1+object->w-1;
  y1=y + object->y;
  y2=y1+object->h-1;

  if( ( object->Box.effect & EFFECT_3DRAISED ) == EFFECT_3DRAISED )
  {
    xy[X1]=x1;
    xy[Y1]=y2;
    xy[X2]=x1;
    xy[Y2]=y1;
    xy[X3]=x2;
    xy[Y3]=y1;
    if( ( object->Box.color > COLOR_DGRAY ) && ( object->Box.color < 16 ) )
      vsl_color( graph_id , object->Box.color - 8 );
    else
      vsl_color(graph_id,COLOR_WHITE);
    v_pline(graph_id,3,xy);
    xy[X1]++;
    xy[X2]=x2;
    xy[Y2]=y2;
    xy[Y3]++;
    if( ( object->Box.color > COLOR_BLACK ) && ( object->Box.color < COLOR_GRAY ) )
      vsl_color( graph_id , object->Box.color+8 );
    else
      vsl_color( graph_id , COLOR_BLACK );
    v_pline(graph_id,3,xy);
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
    vsl_color(graph_id,object->Box.color);
  else if( ( object->Box.effect & EFFECT_3DBORDER ) == EFFECT_3DBORDER )
    vsl_color( graph_id , COLOR_GRAY );
  else
   vsl_color( graph_id , COLOR_DGRAY );
  
  v_pline(graph_id,5,xy);
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
      vsl_color( graph_id , object->Box.color+8 );
    else
      vsl_color( graph_id , COLOR_BLACK );
    v_pline(graph_id,3,xy);
    xy[X1]++;
    xy[X2]=x2;
    xy[Y2]=y2;
    xy[Y3]++;
    if( ( object->Box.color > COLOR_DGRAY ) && ( object->Box.color < 16 ) )
      vsl_color( graph_id , object->Box.color - 8 );
    else
      vsl_color(graph_id,COLOR_WHITE);
    v_pline(graph_id,3,xy);
    x1++;
    y1++;
    x2--;
    y2--;
  }
  vsf_color(graph_id,object->Box.fcolor);
  vsf_style(graph_id,object->Box.fpattern);
  vsf_interior(graph_id,object->Box.fstyle);
  xy[X1]=x1;
  xy[Y1]=y1;
  xy[X2]=x2;
  xy[Y2]=y2;
  vr_recfl(graph_id,xy);
  
}
/****************************************************************************************/
/*                                                                                      */
/****************************************************************************************/
void draw_window(RO_Object *object, long x, long y)
{
  int nx,nw;
  RO_Object *to;

  to=&temp_objects[TEMP_BOX];
  to->x=0;
  to->y=20;
  to->w=object->w;
  to->h=object->h-20;
  to->Box.color=object->Window->Box.color;
  to->Box.fcolor=object->Window->Box.fcolor;
  to->Box.fstyle=object->Window->Box.fstyle;
  to->Box.fpattern=object->Window->Box.fpattern;
  to->Box.effect=object->Window->Box.effect;
  draw_box(to,x+object->x,y+object->y);
  nx=0;
  nw=object->w;
  to=&temp_objects[TEMP_BUTTON];
  to->x=0;
  to->y=0;
  to->w=20;
  to->h=20;
  to->Button->type=BUTTON_NORMAL;
  if (object->Window->flag.close)
  {
    to->Button->text="";
    draw_button(to,x+object->x,y+object->y);
    nx+=to->w;
    nw-=to->w;
  }
  if (object->Window->flag.full)
  {
    to->x=nx+nw-20;
    to->Button->text="";
    draw_button(to,x+object->x,y+object->y);
    nw-=to->w;
  }
  if (object->Window->flag.iconize)
  {
    to->x=nx+nw-20;
    to->Button->text="";
    draw_button(to,x+object->x,y+object->y);
    nw-=to->w;
  }
  if (object->Window->flag.hide)
  {
    to->x=nx+nw-20;
    to->Button->text="";
    draw_button(to,x+object->x,y+object->y);
    nw-=to->w;
  }
  if (object->Window->flag.move)
  {
    to->x=nx;
    to->w=nw;
    to->Button->text=object->Window->titletext;
    draw_button(to,x+object->x,y+object->y);
  }
  else
  {
    to=&temp_objects[TEMP_BOX];
    to->x=nx;
    to->y=0;
    to->w=nw;
    to->h=20;
    to->Box.color=COLOR_BLACK;
    to->Box.fcolor=COLOR_GRAY;
    to->Box.fstyle=FSTYLE_SOLID;
    to->Box.fpattern=FPATTERN_SOLID100;
    to->Box.effect=0;
    draw_box(to,x+object->x,y+object->y);
    
  }
}


/****************************************************************************************/
/*                                                                                      */
/****************************************************************************************/
void draw_scrollbar(RO_Object *object, int x, int y)
{
  RO_Object *to;

  if(object->ScrollBar->type==SCROLLBAR_HORISONTAL)
  {
    to=&temp_objects[TEMP_BUTTON];
    to->x=0;
    to->y=0;
    to->w=20;
    to->h=object->h;
    to->Button->type=BUTTON_NORMAL;
    to->Button->text="";
    draw_button(to,x+object->x,y+object->y);
    to->x=object->w-20;
    to->Button->text="";
    draw_button(to,x+object->x,y+object->y);
    to=&temp_objects[TEMP_BOX];
    to->x=20;
    to->y=0;
    to->w=object->w-40;
    to->h=object->h;
    to->Box.color=COLOR_BLACK;
    to->Box.fcolor=COLOR_DGRAY;
    to->Box.fstyle=FSTYLE_SOLID;
    to->Box.fpattern=FPATTERN_SOLID100;
    to->Box.effect=EFFECT_3DLOWERED;
    draw_box(to,x+object->x,y+object->y);
    
  }
  else if(object->ScrollBar->type==SCROLLBAR_VERTICAL)
  {
    to=&temp_objects[TEMP_BUTTON];
    to->x=0;
    to->y=0;
    to->w=object->w;
    to->h=20;
    to->Button->type=BUTTON_NORMAL;
    to->Button->text="";
    draw_button(to,x+object->x,y+object->y);
    to->y=object->h-20;
    to->Button->text="";
    draw_button(to,x+object->x,y+object->y);
    to=&temp_objects[TEMP_BOX];
    to->x=0;
    to->y=20;
    to->w=object->w;
    to->h=object->h-40;
    to->Box.color=COLOR_BLACK;
    to->Box.fcolor=COLOR_GRAY;
    to->Box.fstyle=FSTYLE_SOLID;
    to->Box.fpattern=FPATTERN_SOLID100;
    to->Box.effect=EFFECT_3DLOWERED;
    draw_box(to,x+object->x,y+object->y);
  }
}
/****************************************************************************************/
/*                                                                                      */
/****************************************************************************************/
void draw_image(RO_Object *object , int x, int y)
{
  short xy[2];
  int colour,masknum;
  unsigned char *data;
  unsigned short *mask;
    
  vsm_type(graph_id,1);
  vsm_height(graph_id,1);
  x+=object->x;
  y+=object->y;
  
  if(object->Image->depth==4)
  {
    data=(unsigned char *)object->Image->data;
    mask=(unsigned short *)object->Image->mask;
    masknum=15;
    for( xy[Y1]=y; xy[Y1]<y+object->Image->height; xy[Y1]++)
    {
      for( xy[X1]=x; xy[X1]<x+object->Image->width; xy[X1]++)
      {
        if(masknum<0)
          mask++,masknum=15;
        colour=((*data)>>4) &0xf;
        vsm_color(graph_id,colour);
        if(((*mask)>>masknum)&1)
          v_pmarker(graph_id,1,xy);
        masknum--;
        xy[X1]++;
        colour=(*data) &0xf;
        vsm_color(graph_id,colour);
        if(((*mask)>>masknum)&1)
          v_pmarker(graph_id,1,xy);
        masknum--;
        data++;
      }
    }
  }
}

/****************************************************************************************/
/*                                                                                      */
/****************************************************************************************/
void draw_string(RO_Object *object, long x, long y)
{
/*
  x1 = x + object->x;
  x2 = x1+object->w-1;
  y1 = y + object->y;
  y2 = y1+object->h-1;
  vst_font(graph_id,1);
  vst_color(graph_id,COLOR_BLACK);
  vst_point(graph_id,10,&dummy,&dummy,&dummy,&dummy);
  vst_alignment(graph_id,0,5,&dummy,&dummy);
  vst_effects(graph_id,0);
  vswr_mode(graph_id,2);
  v_gtext(graph_id,(x2+x1)/2,y1,object->Button->text);
  vswr_mode(graph_id,1);
*/
}