/*
 * PINS.C
 * Hilfsroutinen fÅr pinbare Dialogboxen
 * by Oliver Scholz
 * (c) 1991 MAXON Computer
 */

#include <aes.h>
#include <portab.h>
#include <vdi.h>

#include "defs.h"
#include "pindials.h"

#define GLOBAL extern
#include "globals.h"

extern WORD rc_intersect(GRECT *r1,GRECT *r2);

VOID node_add(WORD node, WORD index);
WORD intersect(WORD index, GRECT *pos);
VOID redraw_dt_grect(WORD index, GRECT *t2);
VOID get_grect(WORD index, GRECT *t);
VOID enlarge_grect(GRECT *t);
 
WORD find_dialpos(WORD x, WORD y, WORD w, WORD h,
                  WORD *xret, WORD *yret)
{
  GRECT pos;
  WORD xpos, ypos;
 
  SHOW_MOUSE;
  graf_mouse(FLAT_HAND,0L);
  /* Rahmen lÑût sich aus Desktop rausschieben,
     bis auf die linke, obere 16x16 Pixel Ecke */
  graf_dragbox(w,h,x,y,0,hchar+3,xres+w-16,
               yres-hchar-3+h-16,&xpos,&ypos);
  graf_mouse(ARROW,0L);
  HIDE_MOUSE;
 
  *xret = xpos; *yret = ypos;
  
  pos.g_x = xpos;   /* GRECT fÅr diesen Dialog */
  pos.g_y = ypos;
  pos.g_w = w;
  pos.g_h = h;

  if(font_pinned)   /* mit gepinnten schneiden */
    if(intersect(FONTIBOX, &pos))
      return(FALSE);
  
  if(text_pinned)  
    if(intersect(TEXTIBOX, &pos))
      return(FALSE);
      
  return(TRUE);
}

WORD intersect(WORD index, GRECT *pos)
{
  GRECT box, ppos;
  
  box.g_x = newdesk[index].ob_x;
  box.g_y = newdesk[index].ob_y;
  box.g_w = newdesk[index].ob_width;
  box.g_h = newdesk[index].ob_height;
  
  ppos.g_x = pos->g_x;
  ppos.g_y = pos->g_y;
  ppos.g_w = pos->g_w;
  ppos.g_h = pos->g_h;
  return(rc_intersect(&box, &ppos));
}

VOID cut_tree(WORD index, OBJECT **subtree,
              WORD *old_parent)
{
  WORD last;
  WORD this;

  /* Adresse des neuen Unterbaums eintragen */   
   
  *subtree = newdesk+index;

  /* alter Parent */
  *old_parent = newdesk[index].ob_next;

  /* Baum ist jetzt Root... */
  newdesk[index].ob_next = -1;
  
  newdesk[*old_parent].ob_head =
    newdesk[*old_parent].ob_tail = -1;
  
  this = index;
  last = this;

  while(this != -1)
    if(newdesk[this].ob_tail != last)
        {
        last = this;
        this = newdesk[last].ob_head;
        if (this == -1)
            {
            this = newdesk[last].ob_next;
            node_add(last, (-1)*index);
            }
        }
    else
        {
        last = this;
        this = newdesk[last].ob_next;
        node_add(last, (-1)*index);
        }
}

VOID add_tree(WORD index, OBJECT *subtree,
              WORD old_parent)
{
  WORD last;
  WORD this;
  
  this = ROOT;
  last = this;

  while(this != -1)
    if(subtree[this].ob_tail != last)
        {
        last = this;
        this = subtree[last].ob_head;
        if (this == -1)
            {
            this = subtree[last].ob_next;
            node_add(last+index, index);
            }
        }
    else
        {
        last = this;
        this = subtree[last].ob_next;
        node_add(last+index, index);
        }

  /* wieder in alten Baum einhÑngen */
  newdesk[index].ob_next = old_parent;
  newdesk[old_parent].ob_head =
    newdesk[old_parent].ob_tail = index;
  /* form_center rÅckgÑngig machen... */
  newdesk[index].ob_x = newdesk[index].ob_y = 0;
}


VOID node_add(WORD node, WORD index)
{   /* Alle Indices != -1 zurÅckstellen */
    if (newdesk[node].ob_head != -1)
        newdesk[node].ob_head += index;
    if (newdesk[node].ob_tail != -1)
        newdesk[node].ob_tail += index;
    if (newdesk[node].ob_next != -1)
        newdesk[node].ob_next += index;
}

VOID redraw_desktop(WORD index)
{
  GRECT t2;

  get_grect(index,&t2);
  enlarge_grect(&t2);
  redraw_dt_grect(index, &t2);
}

VOID get_grect(WORD index, GRECT *t)
{
  WORD x,y;
  
  objc_offset(newdesk, index, &x, &y);
  t->g_x = x;
  t->g_y = y;
  t->g_w=newdesk[index].ob_width;
  t->g_h=newdesk[index].ob_height;
}

/* GRECT vergrîûern fÅr outlined Dialogboxen */
VOID enlarge_grect(GRECT *t)
{
  t->g_x -= 4;  /* evtl. Rand... */
  t->g_y -= 4;
  if (t->g_x < 0)
        t->g_x = 0;
  if (t->g_y < 0)
        t->g_y = 0;

  t->g_w += 8;
  t->g_h += 8;
}

/* Desktop ab 'index' im GRECT t2 neuzeichnen */
VOID redraw_dt_grect(WORD index, GRECT *t2)
{
  GRECT t1;

  wind_get(DESKTOP,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,
           &t1.g_w,&t1.g_h);
  while (t1.g_w && t1.g_h)
  {
    if (rc_intersect(t2,&t1))
      objc_draw(newdesk,index,MAX_DEPTH,t1.g_x,
                t1.g_y,t1.g_w,t1.g_h);
    wind_get(DESKTOP,WF_NEXTXYWH,&t1.g_x,&t1.g_y,
             &t1.g_w,&t1.g_h);
  }
}

VOID redraw_dt_obj(WORD index)
{ 
  GRECT t;
  get_grect(index,&t);
  redraw_dt_grect(ROOT,&t);
}


