/*------------------------------------------------------------------*/
/* WINDOW.C                                                         */
/*                                                                  */
/* Fenster-Verwaltung                                               */
/* (c)1993 by MAXON-Computer                                        */
/* Autor: Uwe Hax                                                   */
/*------------------------------------------------------------------*/

#include <portab.h>
#include <aes.h>
#include <stdlib.h>

#include "prototyp.h"
#include "typedef.h"

extern TEAROFF tearoff[MAX_TEAROFF];



/*------------------------------------------------------------------*/
/* Fenster-Meldungen bearbeiten.                                    */
/*------------------------------------------------------------------*/

WORD do_window (WORD *msg_buff)
{
  WORD end = FALSE;

  switch (msg_buff[0])
  {
    case WM_TOPPED:
      wind_set(msg_buff[3], WF_TOP);
      break;
      
    case WM_REDRAW:
      redraw_window(msg_buff[3], (GRECT *)&msg_buff[4]);
      break;
      
    case WM_MOVED:
      move_window(msg_buff);
      break;
      
    case WM_CLOSED:
      close_window(msg_buff[3]);
      break;
  } /* switch */
    
  return (end);
} /* do_window */



/*------------------------------------------------------------------*/
/* Fensterinhalt neu zeichnen.                                      */
/*------------------------------------------------------------------*/

VOID redraw_window (WORD whandle, GRECT *clip)
{
  GRECT desk, w_clip;
  WORD i;
  OBJECT *tree = NULL;
  
  for (i = 0; i < MAX_TEAROFF; i++)
    if (tearoff[i].whandle == whandle)
    {
      tree = tearoff[i].tree;
      break;
    } /* if */
    
  if (tree == NULL)
    return;
    
  wind_get(DESKTOP, WF_WORKXYWH, &desk.g_x, &desk.g_y, &desk.g_w, &desk.g_h);
  wind_get(whandle, WF_FIRSTXYWH, &w_clip.g_x, &w_clip.g_y, &w_clip.g_w, &w_clip.g_h);

  while (w_clip.g_w && w_clip.g_h)
  {
    if (rc_intersect(&desk, &w_clip))
      if (rc_intersect(clip, &w_clip))
        objc_draw(tree, ROOT, MAX_DEPTH, w_clip.g_x, w_clip.g_y, w_clip.g_w, w_clip.g_h);

    wind_get(whandle, WF_NEXTXYWH, &w_clip.g_x, &w_clip.g_y, &w_clip.g_w, &w_clip.g_h);
  } /* while */
} /* redraw_window */



/*------------------------------------------------------------------*/
/* Fenster verschieben.                                             */
/*------------------------------------------------------------------*/

VOID move_window (WORD *msg_buff)
{
  WORD i;  
  WORD x,y,w,h;
  
  for (i = 0; i < MAX_TEAROFF; i++)
    if (tearoff[i].whandle == msg_buff[3])
    {
      wind_set(msg_buff[3], WF_CURRXYWH, msg_buff[4], msg_buff[5],
                msg_buff[6], msg_buff[7]);

      wind_get(msg_buff[3], WF_WORKXYWH, &x, &y, &w, &h);
      tearoff[i].tree[ROOT].ob_x = x;
      tearoff[i].tree[ROOT].ob_y = y;
      
      break;
    } /* if */
} /* move_window */



/*------------------------------------------------------------------*/
/* Fenster schliežen.                                               */
/*------------------------------------------------------------------*/

VOID close_window (WORD whandle)
{
  WORD i;
    
  for (i = 0; i < MAX_TEAROFF; i++)
    if (tearoff[i].whandle == whandle)
    {
      wind_close(whandle);
      wind_delete(whandle);
      
      free(tearoff[i].tree);
      
      tearoff[i].tree = NULL;
      tearoff[i].title[0] = EOS;
      tearoff[i].whandle = 0;

      break;
    } /* if */
} /* close_window */
