#ifdef WINTEXT
/***********************************************************************/
/* Routines for text/list-windows                                      */
/***********************************************************************/
#include <aes.h>
#include <vdi.h>
#include <stdio.h>
#include <tos.h>
#include <string.h>
#include "windia.h"
#include "win_dia.h"
#include "win_dia2.h"
/***********************************************************************/
/* "converts" an Null-terminated ascii-string to something that can be */
/* viewed in the text-window (creates an line-list)                    */
/***********************************************************************/
int convert_text(WIN_DIALOG *info, const int way)
{
  char *pointer;
  if(info->type==TYPE_TEXT)
  {
    WIN_TEXT *text=(WIN_TEXT*)info->text;
    TEXTLINE *textline;
    long temp=NOLL;

    if(way) /* From Text to Window-text */
    {
      pointer=text->textstart;
      text->num_of_rows=text->num_of_cols=NOLL;
      while(*pointer!=NOLL)
      {
        if(*pointer=='\n')
        {
          text->num_of_rows++;
        }
        pointer++;
      }
      text->num_of_rows++;
      text->lineinfo=Malloc(sizeof(TEXTLINE)*(text->num_of_rows+1));
      if(text->lineinfo==NULL)
      {
        alertbox(1,MEMORY_ERROR);
        return(FALSE);
      }
      textline=text->lineinfo;
      pointer=text->textstart;
      textline[NOLL].line=pointer;
      temp=NOLL;
      while(*pointer!=NOLL)
      {
        if(*pointer=='\n')
        {
          textline[temp].length=pointer-textline[temp].line-1;
          if(textline[temp].length>255)                         /* this should be properly fixed */
            textline[temp].length=255;                          /* This is an Dirty Fix          */
          if(textline[temp].length>text->num_of_cols)
            text->num_of_cols=textline[temp].length;
          textline[++temp].line=pointer+1;
        }
        pointer++;
      }
      if(*(pointer-1)=='\n')
        textline[temp].length=pointer-textline[temp].line-2;
      else
        textline[temp].length=pointer-textline[temp].line-1;
      
      text->textend=pointer;
      return(TRUE);
    }
    else /* From Window-text to text */
    {
      Mfree(text->lineinfo);
      text->lineinfo=NULL;
      text->textend=NULL;
      return(TRUE);
    }
  }
  else
    return(TRUE);
}

/***********************************************************************/
/***********************************************************************/
void update_text(WIN_DIALOG *info, const short xy[XYWH])
{
  short w[4],t[4],ls,le,effects,color;
  WIN_TEXT *text=info->text;
  char tempchar;
  
  if((info->status==WINDOW_HIDDEN)||(info->status==WINDOW_IHIDDEN))
    return;
  wind_update(BEG_UPDATE);
  graf_mouse(M_OFF,NOLL);
  set_text_sliders(info);
  wind_get(info->ident,WF_FIRSTXYWH,&w[X],&w[Y],&w[W],&w[H]);

  while((w[W]!=0)&&(w[H]!=0))
  {
    w[W]=w[W]+w[X];	
    w[H]=w[Y]+w[H];
    if(xy!=NULL)
    {
      t[X]=xy[X];
      t[Y]=xy[Y];
      t[W]=(short)(t[X]+xy[W]);
      t[H]=(short)(t[Y]+xy[H]);
    }
    else if((info->status==WINDOW_ICONIZED)||(info->status==WINDOW_NMICONIZED))
    {
      t[X]=info->i_x;
      t[Y]=info->i_y;
      t[W]=(short)(t[X]+info->icondata[ROOT].ob_width);
      t[H]=(short)(t[X]+info->icondata[ROOT].ob_height);
    }
    else
    {
      t[X]=info->xy[X];
      t[Y]=info->xy[Y];
      t[W]=info->xy[W]+info->xy[X];
      t[H]=info->xy[H]+info->xy[Y];
    }
    if(t[X]<w[X])
      t[X]=w[X];
    if(t[Y]<w[Y])
      t[Y]=w[Y];
    if(t[W]>w[W])
      t[W]=w[W];
    if(t[H]>w[H])
      t[H]=w[H];
    if((t[W]>t[X])&&(t[H]>t[Y]))
    {
      if((info->status==WINDOW_ICONIZED)||(info->status==WINDOW_NMICONIZED))
      {
        info->icondata[ROOT].ob_x=info->i_x;
        info->icondata[ROOT].ob_y=info->i_y;
        objc_draw(info->icondata,ROOT,MAX_DEPTH,t[X],t[Y],t[W]-t[X],t[H]-t[Y]);
      }
      else if((info->status==WINDOW_OPENED)||(info->status==WINDOW_REDRAW)||(info->status==WINDOW_NMOPENED)||(info->status==WINDOW_NMREDRAW))
      {
        if(info->status==WINDOW_REDRAW)
          info->status=WINDOW_OPENED;
        else if(info->status==WINDOW_NMREDRAW)
          info->status=WINDOW_NMOPENED;

        vsf_color(text->graf_id,WHITE);
        vswr_mode(text->graf_id,MD_REPLACE);
        w[X]=NOLL;
        if(text->dialog!=NOLL)
        {
          objc_draw(text->dialog,ROOT,MAX_DEPTH,t[X]-1,t[Y]-2,t[W]-t[X]+1,t[H]-t[Y]+1);
          if(t[Y]<(text->dialog[ROOT].ob_y+text->dialog[ROOT].ob_height))
          {
            w[Y]=NOLL;
            t[Y]=text->dialog[ROOT].ob_y+text->dialog[ROOT].ob_height;
          }
          else
            w[Y]=text->dialog[ROOT].ob_y+text->dialog[ROOT].ob_height-t[Y];
          w[H]=t[H]-t[Y];
          t[H]--,t[W]--;
          vs_clip(text->graf_id,TRUE,t);
          if(t[Y]<t[H])
            vr_recfl(text->graf_id,t);
          t[Y]=text->dialog[ROOT].ob_y+text->dialog[ROOT].ob_height;
        }
        else
        {
          t[H]--,t[W]--;
          vs_clip(text->graf_id,TRUE,t);
          vr_recfl(text->graf_id,t);
          w[H]=t[H]-t[Y];
          t[H]=info->xy[Y];
          if(t[Y]<t[H])
            w[Y]=NOLL;
          else
            w[Y]=t[H]-t[Y];
          t[Y]=t[H];
        }
        ls=-w[Y]/text->char_h;
        le=ls+w[H]/text->char_h+1+text->offset_y;
        t[H]=ls*text->char_h;
        ls+=text->offset_y;
        if(le>text->num_of_rows-1)
          le=text->num_of_rows-1;
        t[W]=text->offset_x*text->char_w;
        t[X]=info->xy[X];
        if((info->type==TYPE_TEXT)&&(le>=0))
        {
          for(;ls<=le;ls++)
          {
            if(ls<text->num_of_rows-1)
            {
              tempchar=text->lineinfo[ls].line[text->lineinfo[ls].length];
              text->lineinfo[ls].line[text->lineinfo[ls].length]=NOLL;
            }
            v_gtext(text->graf_id,t[X]-t[W],t[Y]+t[H],text->lineinfo[ls].line);
            if(ls<text->num_of_rows-1)
              text->lineinfo[ls].line[text->lineinfo[ls].length]=tempchar;
            t[H]+=text->char_h;
          }
        }
        else if((le>=0) &&(ls<=le))
        {
          text->createline(ls,d_temp,MAXSTRING,&effects,&color);
          vst_effects(text->graf_id,effects);
          vst_color(text->graf_id,color);
          v_gtext(text->graf_id,t[X]-t[W],t[Y]+t[H],d_temp);
          if(text->select==ls)
          {
            vswr_mode(text->graf_id,MD_XOR);
            w[X]=t[X]+t[W];
            w[Y]=t[Y]+t[H]-2;
            w[W]=w[X]+screenw;
            w[H]=w[Y]+text->char_h-1;
            vr_recfl(text->graf_id,w);
            vswr_mode(text->graf_id,MD_REPLACE);
          }
          t[H]+=text->char_h;
          for(++ls;ls<=le;ls++)
          {
            text->createnext(d_temp,MAXSTRING,&effects,&color);
            vst_effects(text->graf_id,effects);
            vst_color(text->graf_id,color);
            v_gtext(text->graf_id,t[X]-t[W],t[Y]+t[H],d_temp);
            if(text->select==ls)
            {
              vswr_mode(text->graf_id,MD_XOR);
              w[X]=t[X]+t[W];
              w[Y]=t[Y]+t[H]-2;
              w[W]=w[X]+screenw;
              w[H]=w[Y]+text->char_h-1;
              vr_recfl(text->graf_id,w);
              vswr_mode(text->graf_id,MD_REPLACE);
            }
            t[H]+=text->char_h;
          }
        }
        vs_clip(text->graf_id,FALSE,t);
      }
    }
    wind_get(info->ident,WF_NEXTXYWH,&w[X],&w[Y],&w[W],&w[H]);
  }
  graf_mouse(M_ON,NOLL);
  wind_update(END_UPDATE);

}

/***********************************************************************/
/***********************************************************************/
void scroll_text(WIN_DIALOG *info, int direction)
{
  WIN_TEXT *text=info->text;
  short xy[XYWH];
  
  if(text->num_of_rows<=NOLL)
    return;
  xy[X]=info->xy[X];
  xy[W]=info->xy[W];
  if(text->dialog!=NOLL)
  {
    xy[Y]=info->xy[Y]+text->dialog[ROOT].ob_height;
    xy[H]=info->xy[H]-text->dialog[ROOT].ob_height;
  }
  else
  {
    xy[Y]=info->xy[Y];
    xy[H]=info->xy[H];
  }
  switch(direction)
  {
    case WA_UPPAGE:
      if(text->offset_y>(xy[H]/text->char_h)-1)
      {
        text->offset_y-=(xy[H]/text->char_h)-1;
        if(info->type==TYPE_LIST)
        {
          text->select-=(xy[H]/text->char_h)-1;
          if(text->select<NOLL)
            text->select=NOLL;
        }
        update_text(info,xy);
      }
      else if(text->offset_y>NOLL)
      {
        text->offset_y=NOLL;
        if(info->type==TYPE_LIST)
        {
          text->select-=(xy[H]/text->char_h)-1;
          if(text->select<NOLL)
            text->select=NOLL;
        }
        update_text(info,xy);
      }
      else if(info->type==TYPE_LIST)
      {
        if(text->select>NOLL)
        {
          list_mark(info,text->select,FALSE);
          text->select=NOLL;
          list_mark(info,text->select,FALSE);
          set_text_sliders(info);
        }
      }
      break;
    case WA_DNPAGE:
      if(text->offset_y<text->num_of_rows-(2*(xy[H]/text->char_h)))
      {
        text->offset_y+=(xy[H]/text->char_h)-1;
        if(info->type==TYPE_LIST)
        {
          text->select+=(xy[H]/text->char_h)-1;
          if(text->select>text->num_of_rows)
            text->select=text->num_of_rows;
        }
        update_text(info,xy);
      }
      else if(text->offset_y<text->num_of_rows-(xy[H]/text->char_h))
      {
        text->offset_y=text->num_of_rows-(xy[H]/text->char_h);
        if(info->type==TYPE_LIST)
        {
          text->select+=(xy[H]/text->char_h)-1;
          if(text->select>text->num_of_rows-1)
            text->select=text->num_of_rows-1;
        }
        update_text(info,xy);
      }
      else if(info->type==TYPE_LIST)
      {
        if(text->select<text->num_of_rows-1)
        {
          list_mark(info,text->select,FALSE);
          text->select=text->num_of_rows-1;
          list_mark(info,text->select,FALSE);
          set_text_sliders(info);
        }
      }
      break;
    case WA_UPLINE:
      if(info->type==TYPE_TEXT)
      {
        if(text->offset_y>NOLL)
        {
          text->offset_y--;
          text_scroll(info, 1,WA_UPLINE);
        }
      }
      else
      {
        if(text->select>NOLL)
        {
          list_mark(info,text->select,FALSE);
          text->select--;
          if(text->select<text->offset_y)  
          {
            if(text->offset_y>(xy[H]/text->char_h))
            {
              text->offset_y-=(xy[H]/text->char_h);
              update_text(info,xy);
            }
            else if(text->offset_y>NOLL)
            {
              text->offset_y=NOLL;
              update_text(info,NULL);
            } 
          }
          else
          {
            list_mark(info,text->select,FALSE);
            set_text_sliders(info);
          }
        }
      }
      break;
    case WA_DNLINE:
      if(info->type==TYPE_TEXT)
      {
        if(text->offset_y<text->num_of_rows-(xy[H]/text->char_h))
        {
          text->offset_y++;
          text_scroll(info,1,WA_DNLINE);
        }
      }
      else
      {
        if(text->select<text->num_of_rows-1)
        {
          list_mark(info,text->select,FALSE);
          text->select++;
          if(text->select>text->offset_y+xy[H]/text->char_h-1)
          {
            if(text->offset_y<text->num_of_rows-(2*(xy[H]/text->char_h)))
            {
              text->offset_y+=xy[H]/text->char_h;
              update_text(info,info->xy);
            }
            else if(text->offset_y<text->num_of_rows-(xy[H]/text->char_h))
            {
              text->offset_y=text->num_of_rows-xy[H]/text->char_h;
              update_text(info,NULL);
            }
          }
          else
          {
            list_mark(info,text->select,FALSE);
            set_text_sliders(info);
          }
        }
      }
      break;
    case WA_LFPAGE:
      if(text->offset_x>(xy[W]/text->char_w)-1)
      {
        text->offset_x-=(xy[W]/text->char_w)-1;
        update_text(info,xy);
      }
      else if(text->offset_x>NOLL)
      {
        text->offset_x=NOLL;
        update_text(info,xy);
      }
      break;
    case WA_RTPAGE:
      if(text->offset_x<text->num_of_cols-(2*(xy[W]/text->char_w)))
      {
        text->offset_x+=(xy[W]/text->char_w)-1;
        update_text(info,xy);
      }
      else if(text->offset_x<text->num_of_cols-(xy[W]/text->char_w))
      {
        text->offset_x=text->num_of_cols-(xy[W]/text->char_w);
        update_text(info,xy);
      }
      break;
    case WA_LFLINE:
      if(text->offset_x>NOLL)
      {
        text->offset_x--;
        text_scroll(info, 1,WA_LFLINE);
      }
      break;
    case WA_RTLINE:
      if(text->offset_x<text->num_of_cols-(xy[W]/text->char_w))
      {
        text->offset_x++;
        text_scroll(info,1,WA_RTLINE);
      }
  }
}

/***********************************************************************/
/***********************************************************************/
int fix_key_text(void)
{
  char       key=evnt.key&255;
  char       scan=evnt.key/256;
  WIN_TEXT   *text;
  WIN_DIALOG *info;

  if(evnt.active==FAIL)
    return(FALSE);
  info=dias.window[evnt.active];
  text=info->text;
  if(text==NOLL)
    return(FALSE);
  if(text->num_of_rows==NOLL)
    return(FALSE);
  switch(key)
  {
    case '\n':
    case '\r':
      if((!evnt.k_s)&&(info->type==TYPE_LIST))
      {
        evnt.end=TRUE;
        tebax.type=TEXT_CLICKED;
        tebax.data[SVAR_MOUSE_BUTTON]=MO_LEFT;
        tebax.data[SVAR_MOUSE_CLICKS]=2;
        tebax.data[SVAR_OBJECT]=text->select;
        tebax.data[SVAR_WINDOW_ID]=info->ident;
        return(TRUE);
      }
      break;
    default:
      break;
  }
  switch(scan)
  {
    case SC_UP:
      if(info->text->sc_up)
      {
        if(evnt.k_s==NOLL)
        {
          scroll_text(info,WA_UPLINE);
          scan=0;
        }
        else if(evnt.k_s&(K_RSHIFT|K_LSHIFT))
        {
          scroll_text(info,WA_UPPAGE);
          scan=0;
        }
        else if(evnt.k_s&K_CTRL)
        {
          evnt.k_s=0;
          evnt.key=SC_CLR*256;
          scan=0;
          return fix_key_text();
        }
        if(!scan)
        {
          if(info->type==TYPE_LIST)
          {
            evnt.end=TRUE;
            tebax.type=TEXT_CLICKED;
            tebax.data[SVAR_MOUSE_BUTTON]=MO_LEFT;
            tebax.data[SVAR_MOUSE_CLICKS]=1;
            tebax.data[SVAR_OBJECT]=text->select;
            tebax.data[SVAR_WINDOW_ID]=info->ident;
          }
          return(TRUE);
        }
      }
      break;
    case SC_DOWN:
      if(info->text->sc_down)
      {
        if(evnt.k_s==NOLL)
        {
          scroll_text(info,WA_DNLINE);
          scan=0;
        }
        else if(evnt.k_s&(K_RSHIFT|K_LSHIFT))
        {
          scroll_text(info,WA_DNPAGE);
          scan=0;
        }
        else if(evnt.k_s&K_CTRL)
        {
          evnt.k_s=K_RSHIFT|K_LSHIFT;
          evnt.key=SC_CLR*256;
          scan=0;
          return fix_key_text();
        }
        if(!scan)
        {
          if(info->type==TYPE_LIST)
          {
            evnt.end=TRUE;
            tebax.type=TEXT_CLICKED;
            tebax.data[SVAR_MOUSE_BUTTON]=MO_LEFT;
            tebax.data[SVAR_MOUSE_CLICKS]=1;
            tebax.data[SVAR_OBJECT]=text->select;
            tebax.data[SVAR_WINDOW_ID]=info->ident;
          }
          return(TRUE);
        }
      }
      break;
    case SC_CLR:
    {
      if((evnt.k_s==NOLL)&&(info->text->sc_up))
      {
        text->offset_y=NOLL;
        if(info->type==TYPE_LIST)
        {
          text->select=NOLL;
        }
        update_text(info,NULL);
        if((!evnt.k_s)&&(info->type==TYPE_LIST))
        {
          evnt.end=TRUE;
          tebax.type=TEXT_CLICKED;
          tebax.data[SVAR_MOUSE_BUTTON]=MO_LEFT;
          tebax.data[SVAR_MOUSE_CLICKS]=1;
          tebax.data[SVAR_OBJECT]=text->select;
          tebax.data[SVAR_WINDOW_ID]=info->ident;
          return(TRUE);
        }
        return(TRUE);
      }
      else if((evnt.k_s&(K_RSHIFT|K_LSHIFT))&&(info->text->sc_down))
      {
        if(text->dialog)
          text->offset_y=text->num_of_rows-((info->xy[H]-text->dialog[ROOT].ob_height)/text->char_h);
        else
          text->offset_y=text->num_of_rows-(info->xy[H]/text->char_h);
        if(text->offset_y<0)
          text->offset_y=NOLL;
        if(info->type==TYPE_LIST)
        {
          text->select=text->num_of_rows-1;
        }
        update_text(info,NULL);
        if((!evnt.k_s)&&(info->type==TYPE_LIST))
        {
          evnt.end=TRUE;
          tebax.type=TEXT_CLICKED;
          tebax.data[SVAR_MOUSE_BUTTON]=MO_LEFT;
          tebax.data[SVAR_MOUSE_CLICKS]=1;
          tebax.data[SVAR_OBJECT]=text->select;
          tebax.data[SVAR_WINDOW_ID]=info->ident;
        }
        return(TRUE);
      }
    }
    case SC_LEFT:
    {
      if (info->text->sc_left)
      {
        if(evnt.k_s==NOLL)
        {
          scroll_text(info,WA_LFLINE);
          return(TRUE);
        }
        else if(evnt.k_s&(K_RSHIFT|K_LSHIFT))
        {
          scroll_text(info,WA_LFPAGE);
          return(TRUE);
        }
        else if(evnt.k_s&K_CTRL)
        {
          text->offset_x=NOLL;
          update_text(info,NULL);
          return(TRUE);
        }
      }
      break;
    }
    case SC_RIGHT:
    {
      if (info->text->sc_right)
      {
        if(evnt.k_s==NOLL)
        {
          scroll_text(info,WA_RTLINE);
          return(TRUE);
        }
        else if(evnt.k_s&(K_RSHIFT|K_LSHIFT))
        {
          scroll_text(info,WA_RTPAGE);
          return(TRUE);
        }
        else if(evnt.k_s&K_CTRL)
        {
          text->offset_x=text->num_of_cols-(info->xy[W]/text->char_w);
          update_text(info,NULL);
          return(TRUE);
        }
      }
    }
  }
  return(FALSE);
}

/***********************************************************************/
/***********************************************************************/
void list_mark(WIN_DIALOG *info, int mark,int redraw)
{
  WIN_TEXT   *text;
  short w[XYWH],t[XYWH],effects,color;
  
  if(info==NOLL)
    return;
  text=info->text;
  if((text==NOLL)||(info->type!=TYPE_LIST)||(info->status==WINDOW_ICONIZED)||(info->status==WINDOW_NMICONIZED))
    return;
  if(text->num_of_rows==NOLL)
    return;
  if((mark<text->offset_y)||(mark>text->offset_y+info->xy[H]/text->char_h))
    return;
  set_text_sliders(info);
  if((info->status!=WINDOW_OPENED)&&(info->status!=WINDOW_NMOPENED))
    return;
  wind_get(info->ident,WF_FIRSTXYWH,&w[X],&w[Y],&w[W],&w[H]);
  wind_update(BEG_UPDATE);
  graf_mouse(M_OFF,NOLL);
  while((w[W]!=0)&&(w[H]!=0))
  {
    t[X]=info->xy[X];
    t[W]=info->xy[X]+info->xy[W];
    if(mark!=text->offset_y)
    {
      t[Y]=info->xy[Y]+(mark-text->offset_y)*text->char_h-2;
      t[H]=t[Y]+text->char_h;
    }
    else
    {
      t[Y]=info->xy[Y]+(mark-text->offset_y)*text->char_h;
      t[H]=t[Y]+text->char_h-2;
    }
    if(text->dialog!=NOLL)
    {
      t[Y]+=text->dialog[ROOT].ob_height;
      t[H]+=text->dialog[ROOT].ob_height;
    }  
    w[W]=w[W]+w[X];	
    w[H]=w[Y]+w[H];
    if(t[X]<w[X])
      t[X]=w[X];
    if(t[Y]<w[Y])
      t[Y]=w[Y];
    if(t[W]>w[W])
      t[W]=w[W];
    if(t[H]>w[H])
      t[H]=w[H];
    if((t[W]>t[X])&&(t[H]>t[Y]))
    {
      t[W]--,t[H]--;
      vs_clip(text->graf_id,TRUE,t);
      vsf_color(text->graf_id,WHITE);
      if(redraw)
      {
        vswr_mode(text->graf_id,MD_REPLACE);
        vr_recfl(text->graf_id,t);
        text->createline(mark,d_temp,MAXSTRING,&effects,&color);
        vst_effects(text->graf_id,effects);
        vst_color(text->graf_id,color);
        w[Y]=info->xy[Y]+(mark-text->offset_y)*text->char_h;
        w[X]=info->xy[X]-text->offset_x*text->char_w;
        if(text->dialog!=NOLL)
          w[Y]+=text->dialog[ROOT].ob_height;
        v_gtext(text->graf_id,w[X],w[Y],d_temp);
      }
      vswr_mode(text->graf_id,MD_XOR);
      vr_recfl(text->graf_id,t);
      vswr_mode(text->graf_id,MD_REPLACE);
      vs_clip(text->graf_id,FALSE,t);
    }
    wind_get(info->ident,WF_NEXTXYWH,&w[X],&w[Y],&w[W],&w[H]);
  }
  graf_mouse(M_ON,NOLL);
  wind_update(END_UPDATE);
}

/***********************************************************************/
/***********************************************************************/
int set_mark(WIN_DIALOG *info, int mark, int redraw)
{
  WIN_TEXT *text;
  short xy[XYWH];
  if(info==NOLL)
    return(FALSE);
  if((info->text==NOLL)||(info->type!=TYPE_LIST)||(info->status==WINDOW_CLOSED))
    return(FALSE);
  text=info->text;
  if(text->num_of_rows==NOLL)
    return(FALSE);
  if(info->type!=TYPE_LIST)
    return(FALSE);
  if((mark<NOLL)||(mark>=text->num_of_rows))
    return(FALSE);
  if((info->status==WINDOW_OPENED)||(info->status==WINDOW_NMOPENED))
    list_mark(info,text->select,FALSE);
  text->select=mark;
  xy[X]=info->xy[X];
  xy[W]=info->xy[W];
  if(text->dialog!=NOLL)
  {
    xy[Y]=info->xy[Y]+text->dialog[ROOT].ob_height;
    xy[H]=info->xy[H]-text->dialog[ROOT].ob_height;
  }
  else
  {
    xy[Y]=info->xy[Y];
    xy[H]=info->xy[H];
  }
  if((mark<text->offset_y)||(mark>=text->offset_y+xy[H]/text->char_h))
  {
    text->offset_y=mark-(xy[H]/text->char_h)/2;
    if(text->offset_y+xy[H]/text->char_h>=text->num_of_rows)
      text->offset_y=text->num_of_rows-xy[H]/text->char_h;
    if(text->offset_y<NOLL)
      text->offset_y=NOLL;
    if(((info->status==WINDOW_OPENED)||(info->status==WINDOW_NMOPENED))&&(redraw))
      update_text(info,xy);
  }
  else
  {
    list_mark(info,text->select,redraw);
  }
  return(TRUE);
}

/********************************************************************/
/********************************************************************/
void set_text_sliders(WIN_DIALOG *info)
{
  WIN_TEXT *text;
  short xy[XYWH];
  
  if(info==NOLL)
    return;
  if((info->type!=TYPE_TEXT)&&(info->type!=TYPE_LIST))
    return;
  if(info->text==NOLL)
    return;
  text=info->text;

  xy[X]=info->xy[X];
  xy[W]=info->xy[W];
  if(text->dialog!=NOLL)
  {
    xy[Y]=info->xy[Y]+text->dialog[ROOT].ob_height;
    xy[H]=info->xy[H]-text->dialog[ROOT].ob_height;
  }
  else
  {
    xy[Y]=info->xy[Y];
    xy[H]=info->xy[H];
  }
  
  if(info->type==TYPE_TEXT)
  {
    if(!((xy[H]/text->char_h)>text->num_of_rows))
      wind_set(info->ident,WF_VSLIDE,(SLIDESIZE*text->offset_y)/(text->num_of_rows-xy[H]/text->char_h),0,0,0);
  }
  else
    wind_set(info->ident,WF_VSLIDE,(SLIDESIZE*text->select)/(text->num_of_rows-1),0,0,0);

}

/********************************************************************/
/********************************************************************/
void set_text_font(WIN_DIALOG *info, short font_id, short font_size,int update)
{
  if((info->type!=TYPE_TEXT)&&(info->type!=TYPE_LIST))
    return;
  if(info->status==WINDOW_CLOSED)
    return;
  if((font_id!=FAIL)&&(font_size!=FAIL))
  {
    vst_font(info->text->graf_id,font_id);
    vst_point(info->text->graf_id,-1,&dummy,&dummy,&info->text->char_w,&info->text->char_h);
  }
  if(font_size!=FAIL)
    vst_point(info->text->graf_id,font_size,&dummy,&dummy,&info->text->char_w,&info->text->char_h);
  if(((info->status==WINDOW_OPENED)||(info->status==WINDOW_NMOPENED))&&(update))
    update_text(info,NULL);
  
}

/********************************************************************/
/********************************************************************/
void text_scroll(WIN_DIALOG *info,int lines,int direction)
{
  MFDB mfdb;
  short w[XYWH],t[XYWH],ls,le,effects,color,xy[10];
  WIN_TEXT *text=info->text;
  char tempchar;
  
  if((info->status!=WINDOW_OPENED)&&(info->status!=WINDOW_NMOPENED))
    return;

  wind_update(BEG_UPDATE);
  graf_mouse(M_OFF,NOLL);
  set_text_sliders(info);

  mfdb.fd_addr=0;
  wind_get(info->ident,WF_FIRSTXYWH,&w[X],&w[Y],&w[W],&w[H]);
  while((w[W]!=0)&&(w[H]!=0))
  {
    w[W]=w[W]+w[X];	
    w[H]=w[Y]+w[H];
    t[X1]=info->xy[X];
    t[Y1]=info->xy[Y];
    t[X2]=info->xy[W]+info->xy[X];
    t[Y2]=info->xy[H]+info->xy[Y];
    if(text->dialog!=NOLL)
      t[Y1]+=text->dialog[ROOT].ob_height;
    if(t[X1]<w[X1])
      t[X1]=w[X1];
    if(t[Y1]<w[Y1])
      t[Y1]=w[Y1];
    if(t[X2]>w[X2])
      t[X2]=w[X2];
    if(t[Y2]>w[Y2])
      t[Y2]=w[Y2];
    if((t[X2]>t[X1])&&(t[Y2]>t[Y1]))
    {
      t[X2]--,t[Y2]--;
      vs_clip(text->graf_id,TRUE,t);
      switch(direction)
      {
        case WA_UPLINE:
          xy[8]=t[Y1];
          xy[X1]=t[X1];
          xy[Y1]=t[Y1];
          xy[X2]=t[X2];
          xy[Y2]=t[Y2]-text->char_h;
          xy[X3]=t[X1];
          xy[Y3]=t[Y1]+text->char_h;
          xy[X4]=t[X2];
          xy[Y4]=t[Y2];
          t[Y2]=xy[Y3];
          break;
        case WA_DNLINE:
          xy[8]=t[Y1];
          xy[X1]=t[X1];
          xy[Y1]=t[Y1]+text->char_h;
          xy[X2]=t[X2];
          xy[Y2]=t[Y2];
          xy[X3]=t[X1];
          xy[Y3]=t[Y1];
          xy[X4]=t[X2];
          xy[Y4]=t[Y2]-text->char_h;
          t[Y1]=xy[Y4];
          break;
        case WA_LFLINE:
          xy[8]=t[Y1];
          xy[X1]=t[X1];
          xy[Y1]=t[Y1];
          xy[X2]=t[X2]-text->char_w;
          xy[Y2]=t[Y2];
          xy[X3]=t[X1]+text->char_w;
          xy[Y3]=t[Y1];
          xy[X4]=t[X2];
          xy[Y4]=t[Y2];
          t[X2]=xy[X3];
          break;
        case WA_RTLINE:
          xy[8]=t[Y1];
          xy[X1]=t[X1]+text->char_w;
          xy[Y1]=t[Y1];
          xy[X2]=t[X2];
          xy[Y2]=t[Y2];
          xy[X3]=t[X1];
          xy[Y3]=t[Y1];
          xy[X4]=t[X2]-text->char_w;
          xy[Y4]=t[Y2];
          t[X1]=xy[X4];
          break;
      }
      vro_cpyfm(text->graf_id,S_ONLY,xy,&mfdb,&mfdb);

      vr_recfl(text->graf_id,t);
      vs_clip(text->graf_id,FALSE,t);
      vs_clip(text->graf_id,TRUE,t);
      if(text->dialog)
      {
        if(t[Y]<(text->dialog[ROOT].ob_y+text->dialog[ROOT].ob_height))
        {
          w[Y]=NOLL;
        }
        else
          w[Y]=text->dialog[ROOT].ob_y+text->dialog[ROOT].ob_height-t[Y];
        t[Y]=text->dialog[ROOT].ob_y+text->dialog[ROOT].ob_height;
      }
      else
      {
        t[H]=info->xy[Y];
        if(t[Y]>t[H])
          w[Y]=0;
        else
          w[Y]=t[H]-t[Y];
        t[Y]=t[H];
      }

      ls=-w[Y]/text->char_h;
      t[H]=ls*text->char_h;
      ls+=text->offset_y;
      le=ls+w[H]/text->char_h+1+text->offset_y;
      if(le>text->num_of_rows-1)
        le=text->num_of_rows-1;
      t[W]=text->offset_x*text->char_w;
      t[X]=info->xy[X];

      if((info->type==TYPE_TEXT)&&(le>=0))
      {
        for(;ls<=le;ls++)
        {
          if(ls<text->num_of_rows-1)
          {
            tempchar=text->lineinfo[ls].line[text->lineinfo[ls].length];
            text->lineinfo[ls].line[text->lineinfo[ls].length]=NOLL;
          }
          v_gtext(text->graf_id,t[X]-t[W],t[Y]+t[H],text->lineinfo[ls].line);
          if(ls<text->num_of_rows-1)
            text->lineinfo[ls].line[text->lineinfo[ls].length]=tempchar;
          t[H]+=text->char_h;
        }
      }
      else if((le>=0) &&(ls<=le))
      {
        text->createline(ls,d_temp,MAXSTRING,&effects,&color);
        vst_effects(text->graf_id,effects);
        vst_color(text->graf_id,color);
        v_gtext(text->graf_id,t[X]-t[W],t[Y]+t[H],d_temp);
        if(text->select==ls)
        {
          vswr_mode(text->graf_id,MD_XOR);
          w[X]=t[X]+t[W];
          w[Y]=t[Y]+t[H]-2;
          w[W]=w[X]+screenw;
          w[H]=w[Y]+text->char_h-1;
          vr_recfl(text->graf_id,w);
          vswr_mode(text->graf_id,MD_REPLACE);
        }
        t[H]+=text->char_h;
        for(++ls;ls<=le;ls++)
        {
          text->createnext(d_temp,MAXSTRING,&effects,&color);
          vst_effects(text->graf_id,effects);
          vst_color(text->graf_id,color);
          v_gtext(text->graf_id,t[X]-t[W],t[Y]+t[H],d_temp);
          if(text->select==ls)
          {
            vswr_mode(text->graf_id,MD_XOR);
            w[X]=t[X]+t[W];
            w[Y]=t[Y]+t[H]-2;
            w[W]=w[X]+screenw;
            w[H]=w[Y]+text->char_h-1;
            vr_recfl(text->graf_id,w);
            vswr_mode(text->graf_id,MD_REPLACE);
          }
          t[H]+=text->char_h;
        }
      }
      vs_clip(text->graf_id,FALSE,t);
    }
    wind_get(info->ident,WF_NEXTXYWH,&w[X],&w[Y],&w[W],&w[H]);
  }
  graf_mouse(M_ON,NOLL);
  wind_update(END_UPDATE);
}

/********************************************************************/
/* copy a Word from the TEXT-window                                 */
/********************************************************************/
void copy_word(WIN_DIALOG *info,int x,int y)
{
  char *start,*end;
  WIN_TEXT *text =info->text;
  
  text->mark.start_row=y/text->char_h+text->offset_y;
  text->mark.start_col=x/text->char_w+text->offset_x;
  text->mark.end_row=text->mark.start_row;
  text->mark.end_col=text->mark.start_col;
  start=text->lineinfo[text->mark.start_row].line+text->mark.start_col;
  end=start;
  while ((*start!='\n')&&(*start!='\r')&&(*start!=' ')&&(*start!='\t')&&(*start!='\0')&&(start>text->textstart))
    start--;
  start++;
  while ((*end!='\n')&&(*end!='\r')&&(*end!=' ')&&(*end!='\t')&&(*end!='\0')&&(end<text->textend))
    end++;
  end--;
  if(scrp_read(d_temp)==NOLL)
  {
    return;
  }
  strncat(d_temp,SCRAPFILE,MAXSTRING);
  d_fil=fopen(d_temp,"w");
  if(d_fil==NOLL)
    return;
  fwrite(start,1,end-start+1,d_fil);
  fclose(d_fil);
}

#endif