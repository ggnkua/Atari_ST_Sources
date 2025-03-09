/*
 * OUTPUT.C
 * Ausgaberoutinen fÅr TT44TT
 * Copyright (c) 1991 by MAXON
 * Autoren: Oliver Scholz & Uwe Hax
 */


#include <portab.h>
#include <vdi.h>
#include <string.h>
#include <tos.h>
#include <aes.h>

#include "termdefs.h"
#include "proto.h"
#include "tt44tt.h"

#define GLOBAL extern
#include "variable.h"


/*
 * liest alle fÅr das Terminal angekommenen
 * Zeichen, gibt sie in dem Fenster aus und
 * aktualisiert das virtuelle Terminal
 */

VOID do_output(WORD wind_index)
{
  CHAR c;
    
  while (Bconstat(wind_index+aux_offset))
  {
    c=Bconin(wind_index+aux_offset);
    if (c!=ESCAPE)
    {
      if (terminal[wind_index].escape!=WAITING) 
        handle_escape(wind_index,c);
      else
      {
        insert_char(wind_index,c);
        print_char(wind_index,c);
      }
    }
    else
      terminal[wind_index].escape=ESCAPE;
  }
}


/*
 * initialisiert ein virtuelles Terminal
 */

VOID init_terminal(WORD wind_index)
{
  WORD i,j;
  
  for (i=0; i<TERM_HEIGHT; i++)
  {
    for (j=0; j<TERM_WIDTH; j++)
    terminal[wind_index].screen[i][j]=' '; 
    terminal[wind_index].screen[i][TERM_WIDTH] =
      EOS;
  }
  terminal[wind_index].x=terminal[wind_index].y =
    0;
  terminal[wind_index].escape=WAITING;
}


/*
 * Hier kînnen verschiedene Escapesequenzen
 * behandelt werden, um z.B. ein VT52 Terminal
 * zu emulieren
 */

VOID handle_escape(WORD wind_index, CHAR c)
{
  terminal[wind_index].escape=WAITING;
}


/*
 * Gibt ein Zeichen auf einem
 * virtuellen Terminal aus
 */

VOID insert_char(WORD wind_index, CHAR c)
{
  WORD x,y;

  update_pos(wind_index);
  
  switch (c)
  {
    case CR:     terminal[wind_index].x=0;
                 break;
    case LF:     term_lf(wind_index);
                 break;
    case TAB:    x=terminal[wind_index].x;
                 terminal[wind_index].x=x+8-x%8;
                 break;    
    case BACKSPACE:  
                 if (terminal[wind_index].x>0)
                   terminal[wind_index].x--;
                 break;
    case BELL:   break;    
    default:     x=terminal[wind_index].x++;
                 y=terminal[wind_index].y;
                 terminal[wind_index]
                    .screen[y][x]=c;
                 if (x >= TERM_WIDTH)
                 { /* Auto Wrap */
                   terminal[wind_index].x=0;
                   term_lf(wind_index);
                 }
  }
}


/* 
 * fÅhrt auf einem virtuellen Terminal einen
 * Line-Feed aus
 */

VOID term_lf(WORD wind_index)
{
  WORD i;
  
  if (terminal[wind_index].y==TERM_HEIGHT-1)
  {
    for (i=0; i<TERM_HEIGHT-1; i++)
      strcpy(terminal[wind_index].screen[i],
             terminal[wind_index].screen[i+1]);
    for (i=0; i<TERM_WIDTH; i++)
      terminal[wind_index]
          .screen[TERM_HEIGHT-1][i]=' ';
    terminal[wind_index]
          .screen[TERM_HEIGHT-1][TERM_WIDTH]=EOS;
  }
  else
    terminal[wind_index].y++;
}


/*
 * Gibt ein Zeichen im Terminalfenster aus
 */

VOID print_char(WORD wind_index, CHAR c)
{
    GRECT t1,t2;
    WORD x,y,w,h;
    CHAR zeichen[4];
    CHAR nonprintable[3];

/* Fehler im Turbo C (2.03): hier wird 
   das statische Array falsch initialisiert,
   daher Initialisierung 'zu Fuû' ... */

    nonprintable[0]=CR;
    nonprintable[1]=BACKSPACE;
    nonprintable[2]=TAB;

    if (window[wind_index].handle>=0)
    {
      /* nicht druckbare Zeichen abfangen */
      if (strchr(nonprintable,c))
      {
        update_cursor(wind_index);
        update_pos(wind_index);
        return; 
      }
      if (c==BELL)
      { /* kurz Bimmeln... */
        Cconout(BELL);
        return;
      }
      
      if (c==LF)
      {
        cursor(wind_index,CURSOR_OFF);
        wind_get(window[wind_index].handle,
                 WF_WORKXYWH,&x,&y,&w,&h);
        
        /* in der letzten Zeile des Fensters:
           scrollen */
        if (window[wind_index].y_corner+h/hchar-1
            == terminal[wind_index].tmp_y)
        {          
          /* letzte Zeile des Terminals:
             Slider verschieben */
          if (TERM_HEIGHT-1 !=
              terminal[wind_index].tmp_y)
          {
            window[wind_index].y_corner++;
            pos_slider(wind_index,VERTICAL);
          }
          scroll(wind_index,SCROLL_UP);
        }  
          
        cursor(wind_index,CURSOR_ON);
        return;
      }
          
      cursor(wind_index,CURSOR_OFF);
          
      wind_get(window[wind_index].handle,
               WF_FIRSTXYWH,&t1.g_x,&t1.g_y,
               &t1.g_w,&t1.g_h);

      wind_get(window[wind_index].handle,
               WF_WORKXYWH,&x,&y,&w,&h);
    
      /* Zeichenkoordinaten */
      t2.g_x=(terminal[wind_index].tmp_x
        - window[wind_index].x_corner)*wchar + x;
      t2.g_y=(terminal[wind_index].y
        - window[wind_index].y_corner)*hchar + y;
      t2.g_w=wchar;
      t2.g_h=hchar;
    
      zeichen[0]=c;
      zeichen[1]=EOS;

      /* Zeichen im Fenster ausgeben */
      while (t1.g_w && t1.g_h)
      {
        if (rc_intersect(&t2,&t1))
        {
          clipping(&t1,TRUE);
          v_gtext(vdi_handle,t2.g_x,
          t2.g_y+distances[4],zeichen);
        }
        wind_get(window[wind_index].handle,
                 WF_NEXTXYWH,&t1.g_x,&t1.g_y,
                 &t1.g_w,&t1.g_h);
      }
      clipping(&t1,FALSE);
    }
    cursor(wind_index,CURSOR_ON);
}


/*
 * Cursorposition updaten
 */

VOID update_pos(WORD wind_index)
{
  terminal[wind_index].tmp_x=
    terminal[wind_index].x;
  terminal[wind_index].tmp_y=
    terminal[wind_index].y;
}


/*
 * Scrollen im Fenster vertikal um eine Zeile
 */

VOID scroll(WORD wind_index, WORD direction)
{
  GRECT t1;
  WORD x,y,w,h;
  WORD line;
  WORD xyarray[8];
  WORD temp;
  MFDB screen;
  WORD work_out[57];
  WORD i;
  WORD y_pos;
  CHAR out[TERM_WIDTH+1];
  
  wind_get(window[wind_index].handle,
           WF_FIRSTXYWH,&t1.g_x,&t1.g_y,
           &t1.g_w,&t1.g_h);
  wind_get(window[wind_index].handle,
           WF_WORKXYWH,&x,&y,&w,&h);
  vq_extnd(vdi_handle,1,work_out);
  
  /* solange noch Rechtecke in der Liste */
  while (t1.g_w && t1.g_h)
  {
    clipping(&t1,TRUE);
  
    if (t1.g_h>hchar)
    {
      /* nach oben kopieren */
      xyarray[0]=t1.g_x;
      xyarray[1]=t1.g_y+hchar;
      xyarray[2]=t1.g_x+t1.g_w-1;
      xyarray[3]=t1.g_y+t1.g_h-1;
      xyarray[4]=t1.g_x;
      xyarray[5]=t1.g_y;
      xyarray[6]=t1.g_x+t1.g_w-1;
      xyarray[7]=t1.g_y+t1.g_h-1-hchar;
    
      /* nach unten kopieren */
      if (direction == SCROLL_DOWN)
        for (i=0; i<4; i++)
        {
          temp=xyarray[i];
          xyarray[i]=xyarray[i+4];
          xyarray[i+4]=temp;
        }
    
      screen.fd_addr=0L;
      screen.fd_w=t1.g_w;
      screen.fd_h=t1.g_h;
      screen.fd_wdwidth=t1.g_w/16+1;
      screen.fd_stand=0;
      screen.fd_nplanes=work_out[4];
      vro_cpyfm(vdi_handle,S_ONLY,xyarray,
                &screen,&screen);
    }  
    
    /* Zeile im Rechteck berechnen und ausgeben*/
    if (direction == SCROLL_UP)
      y_pos=(t1.g_y+t1.g_h-y)/hchar-1;
    else
      y_pos=(t1.g_y-y)/hchar;

    line=window[wind_index].y_corner+y_pos;

    /* schnellere Ausgabe */
    if (t1.g_x+t1.g_w == x+w)
    {
      t1.g_w += wchar;    
      clipping(&t1,TRUE);
    }

    /* Zeile ausgeben... */
    strcpy(out,terminal[wind_index].screen[line]
           +window[wind_index].x_corner);
    out[w/wchar]=EOS;    
    v_gtext(vdi_handle,x,
            y+y_pos*hchar+distances[4],out);
    
    /* ...und eventuell noch eine */
    if (((line < TERM_HEIGHT-1) && 
          (direction == SCROLL_UP))
      || 
         ((line > 0) && 
          (direction == SCROLL_DOWN)))
    {
      strcpy(out,terminal[wind_index]
             .screen[line+1]+
             window[wind_index].x_corner);
      out[w/wchar]=EOS;    
      v_gtext(vdi_handle,x,
             y+(y_pos+1)*hchar+distances[4],out);
    }

    wind_get(window[wind_index].handle,
             WF_NEXTXYWH,&t1.g_x,&t1.g_y,
             &t1.g_w,&t1.g_h);
  }
  clipping(&t1,FALSE);  
}


/*
 * Cursor zeichnen bzw. lîschen
 */

VOID cursor(WORD wind_index, WORD flag)
{
  GRECT t1,t2;
  WORD x,y,w,h;
  WORD xyarray[8];
 
  if (window[wind_index].handle < 0)
    return;

  if (flag == CURSOR_ON)
    update_pos(wind_index);
  
  vswr_mode(vdi_handle,MD_XOR);
  
  wind_get(window[wind_index].handle,WF_WORKXYWH,
           &x,&y,&w,&h);
  
  if (flag == CURSOR_OFF)
  {
    xyarray[0] = (terminal[wind_index].tmp_x -
        window[wind_index].x_corner)*wchar + x;
    xyarray[1] = (terminal[wind_index].tmp_y -
        window[wind_index].y_corner)*hchar + y;
  }
  else
  {
    xyarray[0] = (terminal[wind_index].x -
        window[wind_index].x_corner)*wchar + x;
    xyarray[1] = (terminal[wind_index].y -
        window[wind_index].y_corner)*hchar + y;
  }

  xyarray[2]=xyarray[0];
  xyarray[3]=xyarray[1]+hchar;

  xyarray[4]=xyarray[2]+1; 
  xyarray[5]=xyarray[3];
  xyarray[6]=xyarray[4]; 
  xyarray[7]=xyarray[1];
    
  t2.g_x=xyarray[0];
  t2.g_y=xyarray[1];
  t2.g_w=2;
  t2.g_h=hchar;
  
  wind_get(window[wind_index].handle,
           WF_FIRSTXYWH,&t1.g_x,&t1.g_y,
           &t1.g_w,&t1.g_h);    
           
  /* Cursor zeichnen unter Beachtung der
     Rechteck-Liste */
  while(t1.g_w && t1.g_h)
  {
    if (rc_intersect(&t2,&t1))
    {
      clipping(&t1,TRUE);
      v_pline(vdi_handle,4,xyarray);   
    }
    wind_get(window[wind_index].handle,
             WF_NEXTXYWH,&t1.g_x,&t1.g_y,
             &t1.g_w,&t1.g_h);
  }
  clipping(&t1,FALSE);

  vswr_mode(vdi_handle,MD_REPLACE);
}


/* 
 * alten Cursor lîschen und neuen zeichnen
 */
 
VOID update_cursor(WORD wind_index)
{
  cursor(wind_index,CURSOR_OFF);
  cursor(wind_index,CURSOR_ON);
}



