/*
 * Control-S Steuerprogramm fÅr Videorekorder
 * von Oliver Scholz
 * (c) 1991 MAXON Computer 1991
 */

#include "portab.h"
#include "aes.h"
#include "stdlib.h"
#include "sony.h"
#include "sony.rsh"

#define TV      1
#define VTR1    2
#define VTR2    7
#define VTR3    11

/* VTR1 fÅr Betamax */
/* VTR2 fÅr Video 8 */
/* VTR3 fÅr VHS */
#define VTR     VTR3

#define TRUE    1
#define FALSE   0

VOID send_sony(WORD device, WORD command,
               WORD times);
OBJECT *get_traddr(WORD tree_index);
VOID do_dialog(OBJECT *dial);
VOID redo_obj(OBJECT *tree, WORD index);

extern  _app;

VOID main(VOID)
{ 
    OBJECT *dialog;
    WORD i,dummy;
    WORD event;
    WORD msgbuff[8];
    WORD ap_id, mn_id;
  
    /* Programm initialisieren */
    ap_id = appl_init();
    if(ap_id == -1) exit(-1);
    
    /* Dialogadresse berechnen */
    for (i=0; i<NUM_OBS; i++)
        rsrc_obfix(rs_object,i);
    dialog=get_traddr(DIALOG);
    
    if(_app)
    {
        /* Applikation */
        graf_mouse(ARROW,0L);
        do_dialog(dialog);
    }
    else
    {   /* Accessory */
        mn_id = menu_register( ap_id,
                "  Fernbedienung" );
        
        /* keine Touchexit Knîpfe... */
        dialog[REW].ob_flags=SELECTABLE|EXIT;
        dialog[FF].ob_flags=SELECTABLE|EXIT;
        dialog[PRGUP].ob_flags=SELECTABLE|EXIT;
        dialog[PRGDOWN].ob_flags=SELECTABLE|EXIT;
        
        do
        {
            event = evnt_multi(MU_MESAG,
                        0, 0, 0,
                        0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0,
                        msgbuff,
                        0, 0,
                        &dummy, &dummy, &dummy,
                        &dummy, &dummy, &dummy );

            if(event & MU_MESAG)
                if((msgbuff[0] == AC_OPEN) &&
                   (msgbuff[4] == mn_id))
                   do_dialog(dialog);
        }
        while (TRUE);
    }
    appl_exit();
    exit(0);
}
    
/* Adresse eines Baumes ermitteln */

OBJECT *get_traddr(WORD tree_index)
{
  WORD i,j;
  
  for (i=0,j=0; i<=tree_index; i++)
    while (rs_object[j++].ob_next!=-1);

  return(&rs_object[--j]); 
}

VOID do_dialog(OBJECT *dial)
{
  WORD cx,cy,cw,ch;
  WORD xflag, exitobj;

  form_center(dial,&cx,&cy,&cw,&ch);
  
  form_dial(FMD_START,cx,cy,cw,ch,cx,cy,cw,ch);
  xflag = FALSE;

  objc_draw(dial,ROOT,MAX_DEPTH,cx,cy,cw,ch);

  do
  {
    exitobj = form_do(dial,0) & 0x7fff;

    dial[exitobj].ob_state &= ~SELECTED;
    switch(exitobj)
    {
        case FERTIG:
            xflag = TRUE;
            break;
            
        case POWER:
            send_sony(VTR,21,3);
            break;
        case PAUSE:
            send_sony(VTR,25,3);
            break;
        case PLAY:
            send_sony(VTR,26,3);
            break;
        case REC:
            send_sony(VTR,29,3);
            break;
        case REW:
            send_sony(VTR,27,3);
            break;
        case STOP:
            send_sony(VTR,24,3);
            break;
        case EJECT:
            send_sony(VTR,22,3);
            break;
        case FF:
            send_sony(VTR,28,3);
            break;
        case PRGUP:
            send_sony(VTR,16,3);
            break;
        case PRGDOWN:
            send_sony(VTR,17,3);
            break;
    }
    redo_obj(dial,exitobj);
    
  } while(!xflag);
    
  form_dial(FMD_FINISH,cx,cy,cw,ch,cx,cy,cw,ch);
}

VOID redo_obj(OBJECT *tree, WORD index)
{ WORD x,y,w,h;

  objc_offset(tree,index,&x,&y);
  w = tree[index].ob_width;
  h = tree[index].ob_height;
  
  objc_draw(tree,ROOT,MAX_DEPTH,x,y,w,h);
}
