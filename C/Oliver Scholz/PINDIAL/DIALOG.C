/*
 * DIALOG.C
 * by Oliver Scholz
 * (c) 1991 MAXON Computer
 */
 
#include <aes.h>
#include <portab.h>

#include "defs.h"
#include "pindials.h"

#define GLOBAL extern
#include "globals.h"

VOID redo_obj(OBJECT *tree, WORD index,
              WORD rootindex);
VOID init_font(VOID);
VOID init_text(VOID);
VOID toggle_button(WORD *but, WORD object);

extern VOID redraw_desktop(WORD index);
extern WORD find_dialpos(WORD x, WORD y,WORD w,
            WORD h, WORD *xret, WORD *yret);
extern VOID cut_tree(WORD index,OBJECT **subtree,
                     WORD *old_parent);
extern VOID add_tree(WORD index, OBJECT *subtree,
                     WORD old_parent);
extern VOID redraw_dt_obj(WORD index);

/* Font-Dialogbox darstellen und abfragen */
 
VOID do_dial1(VOID)
{
  WORD cx,cy,cw,ch;
  WORD save_parent;
  WORD exitobj;
  WORD xflag;
  WORD xpos, ypos;

  if (font_pinned)
    return;

  init_font();

  /* Unterbaum abtrennen */
  cut_tree(FONTBOX, &fontbox, &save_parent);
    
  /* als eigenst„ndigen Dialog behandeln */
  form_center(fontbox,&cx,&cy,&cw,&ch);
  form_dial(FMD_START,cx,cy,cw,ch,cx,cy,cw,ch);

  objc_draw(fontbox,ROOT,MAX_DEPTH,cx,cy,cw,ch);

  xflag = TRUE;
  
  do {
    SHOW_MOUSE;
    exitobj = form_do(fontbox,0) & 0x7fff;
    HIDE_MOUSE;
    
    /* Objektindex korrigieren */
    exitobj += FONTBOX;

    /* Pin angeklickt ? */
    switch(exitobj)
    {
      case FONTPIN:
        if(find_dialpos(fontbox[ROOT].ob_x,
                        fontbox[ROOT].ob_y,
                        fontbox[ROOT].ob_width,
                        fontbox[ROOT].ob_height,
                        &xpos, &ypos))
        {
            form_dial(FMD_FINISH,cx,cy,cw,ch,
                      cx,cy,cw,ch);
            /* Dialog wieder im Baum einh„ngen */
            add_tree(FONTBOX, fontbox,
                     save_parent);
        
            /* an neuer Position */
            newdesk[FONTIBOX].ob_x=xpos;
            newdesk[FONTIBOX].ob_y=ypos;

            /* Reižzwecke anzeigen */
            newdesk[FONTPIN].ob_spec.bitblk =
                    pin_pinned;
        
            /* ganzen Dialog anzeigen... */
            newdesk[FONTIBOX].ob_flags &=
                    ~HIDETREE;

            /* ...bis auf OK Knopf */
            newdesk[FONTOK].ob_flags |= HIDETREE;
            font_pinned = TRUE;
        
            redraw_desktop(FONTIBOX);
            return;
        }
        else
            form_alert(1,DIAL_ERR);
        break;
      
      case FONTOK:
            newdesk[FONTOK].ob_state &= 
                ~SELECTED;
            xflag = FALSE;
            break;
            
      case FPICA:
      case FTIMES:
      case FELITE:
            switch(status.font)
            {
                case PICA:
                    newdesk[FPICA].ob_state &=
                        ~SELECTED;
                    redo_obj(fontbox,FPICA,
                             FONTBOX);
                    break;
                    
                case TIMES:
                    newdesk[FTIMES].ob_state &=
                        ~SELECTED;
                    redo_obj(fontbox,FTIMES,
                            FONTBOX);
                    break;
                    
                case ELITE:
                    newdesk[FELITE].ob_state &=
                        ~SELECTED;
                    redo_obj(fontbox,FELITE,
                            FONTBOX);
                    break;
            }
            newdesk[exitobj].ob_state |=
                SELECTED;
            redo_obj(fontbox,exitobj,FONTBOX);
            
            switch(exitobj)
            {
                case FELITE:
                    status.font = ELITE;
                    break;
                    
                case FTIMES:
                    status.font = TIMES;
                    break;
                    
                case FPICA:
                    status.font = PICA;
                    break;
            }
            break;
    } 
      
  } while (xflag);
  
  form_dial(FMD_FINISH,cx,cy,cw,ch,cx,cy,cw,ch);
  add_tree(FONTBOX, fontbox, save_parent);
 }

/* Attribut-Dialogbox darstellen u. abfragen */
 
VOID do_dial2(VOID)
{
  WORD cx,cy,cw,ch;
  WORD save_parent;
  WORD exitobj;
  WORD xflag;
  WORD xpos, ypos;

  if (text_pinned)
    return;

  init_text();

  /* Unterbaum abtrennen */
  cut_tree(TEXTBOX, &textbox, &save_parent);
    
  /* als eigenst„ndigen Dialog behandeln */
  form_center(textbox,&cx,&cy,&cw,&ch);
  form_dial(FMD_START,cx,cy,cw,ch,cx,cy,cw,ch);

  objc_draw(textbox,ROOT,MAX_DEPTH,cx,cy,cw,ch);

  xflag = TRUE;
  
  do {
    SHOW_MOUSE;
    exitobj = form_do(textbox,0) & 0x7fff;
    HIDE_MOUSE;
    
    /* Objektindex korrigieren */
    exitobj += TEXTBOX;

    /* Pin angeklickt ? */
    switch(exitobj)
    {
      case TEXTPIN:
        if(find_dialpos(textbox[ROOT].ob_x,
                        textbox[ROOT].ob_y,
                        textbox[ROOT].ob_width,
                        textbox[ROOT].ob_height,
                        &xpos, &ypos))
        {
            form_dial(FMD_FINISH,cx,cy,cw,ch,
                      cx,cy,cw,ch);

            /* Dialog wieder im Baum einh„ngen */
            add_tree(TEXTBOX, textbox,
                     save_parent);
        
            /* an neuer Position */
            newdesk[TEXTIBOX].ob_x=xpos;
            newdesk[TEXTIBOX].ob_y=ypos;

            /* Reižzwecke anzeigen */
            newdesk[TEXTPIN].ob_spec.bitblk =
                    pin_pinned;
        
            /* ganzen Dialog anzeigen... */
            newdesk[TEXTIBOX].ob_flags &=
                    ~HIDETREE;

            /* ...bis auf OK Knopf */
            newdesk[TEXTOK].ob_flags |= HIDETREE;
            text_pinned = TRUE;
        
            redraw_desktop(TEXTIBOX);
            return;
        }
        else
            form_alert(1,DIAL_ERR);
        break;
      
      case TEXTOK:
            newdesk[TEXTOK].ob_state &=
                ~SELECTED;
            xflag = FALSE;
            break;
            
      case TKURSIV:
            toggle_button(&status.kursiv,
                exitobj);
            break;
                            
      case TUNTER:
            toggle_button(&status.unterstrichen,
                          exitobj);
            break;

      case TLEICHT:
           toggle_button(&status.leicht,exitobj);

            break;

      case TFETT:
            toggle_button(&status.fett, exitobj);
            break;
    } 
      
  } while (xflag);
  
  form_dial(FMD_FINISH,cx,cy,cw,ch,cx,cy,cw,ch);
  add_tree(TEXTBOX, textbox, save_parent);
}
 
/* Pinbare Dialoge initialisieren */
 
VOID init_pins(VOID)
{ 
/* Pinnbare Dialoge: entpinnen, unsichtbar */
  newdesk[FONTPIN].ob_spec.bitblk =
    pin_unpinned;
  newdesk[FONTIBOX].ob_flags |= HIDETREE;
  font_pinned = FALSE;

  newdesk[TEXTPIN].ob_spec.bitblk =
    pin_unpinned;
  newdesk[TEXTIBOX].ob_flags |= HIDETREE;
  text_pinned = FALSE;

  /* IBox und Dialogbox deckungsgleich machen */
  newdesk[FONTIBOX].ob_width=
        newdesk[FONTBOX].ob_width;
  newdesk[FONTIBOX].ob_height=
        newdesk[FONTBOX].ob_height;
  newdesk[FONTBOX].ob_x=0;
  newdesk[FONTBOX].ob_y=0;
    
  newdesk[TEXTIBOX].ob_width=
        newdesk[TEXTBOX].ob_width;
  newdesk[TEXTIBOX].ob_height=
        newdesk[TEXTBOX].ob_height;   
  newdesk[TEXTBOX].ob_x=0;
  newdesk[TEXTBOX].ob_y=0;
}

/* Font Dialogbox initialisieren */
 
VOID init_font(VOID)
{
  WORD objtable[3] = {  FPICA, FELITE, FTIMES  };
  WORD i;
  
  for (i=0; i<3; i++)
    newdesk[objtable[i]].ob_state &= ~SELECTED;
    
  switch(status.font)
  {
    case PICA:
        newdesk[FPICA].ob_state |= SELECTED;
        break;
        
    case ELITE:
        newdesk[FELITE].ob_state |= SELECTED;
        break;

    case TIMES:
        newdesk[FTIMES].ob_state |= SELECTED;
        break;
 }
}

/* Text-Dialogbox initialisieren */
 
VOID init_text(VOID)
{
  if(status.kursiv)  
    newdesk[TKURSIV].ob_state |= SELECTED;
  else
    newdesk[TKURSIV].ob_state &= ~SELECTED;
 
   if(status.unterstrichen)  
    newdesk[TUNTER].ob_state |= SELECTED;
   else
    newdesk[TUNTER].ob_state &= ~SELECTED;
 
   if(status.leicht)  
    newdesk[TLEICHT].ob_state |= SELECTED;
   else
    newdesk[TLEICHT].ob_state &= ~SELECTED;
 
   if(status.fett)  
    newdesk[TFETT].ob_state |= SELECTED;
   else
    newdesk[TFETT].ob_state &= ~SELECTED;
}

/* Objekt im Baum neuzeichnen */
 
VOID redo_obj(OBJECT *tree, WORD index,
              WORD rootindex)
{
  WORD x,y,w,h;
   
    objc_offset(tree,index-rootindex,&x, &y);   
    w = newdesk[index].ob_width;
    h = newdesk[index].ob_height;
    objc_draw(tree,ROOT,MAX_DEPTH,x,y,w,h);
}

/* Knopf umschalten, entsprechende   */
/* Variable umsetzen und neuzeichnen */
 
VOID toggle_button(WORD *but, WORD object)
{
    if (*but)
    {
        *but = FALSE;
        newdesk[object].ob_state &= ~SELECTED;
    }
    else
    {
        *but = TRUE;
        newdesk[object].ob_state |= SELECTED;
    }
    redo_obj(textbox,object,TEXTBOX);
}
