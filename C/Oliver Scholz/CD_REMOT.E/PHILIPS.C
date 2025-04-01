/*
 * RC5 Steuerprogramm
 * von Oliver Scholz
 * (c) 1992 MAXON Computer
 */

#include "portab.h"
#include "stdio.h"
#include "tos.h"
#include "aes.h"
#include "stdlib.h"
#include "philips.h"
#include "philips.rsh"

#define TRUE    1
#define FALSE   0

#define CD              12
/* #define CD           20 */

VOID send_rc5(WORD device, WORD command,
               WORD times);
OBJECT *get_traddr(WORD tree_index);
VOID do_dialog(OBJECT *dial);
VOID redo_obj(OBJECT *tree, WORD index);

extern  _app;

WORD main(VOID)
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
                "  CD-Player" );
        
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
    
    return(0);
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
            send_rc5(CD,12,4);
            break;
        case PAUSE:
            send_rc5(CD,48,4);
            break;
        case PLAY:
            send_rc5(CD,53,4);
            break;
        case STOP:
            send_rc5(CD,54,4);
            break;
        case REW:
            send_rc5(CD,36,4);
            break;
        case FF:
            send_rc5(CD,30,4);
            break;
        case DISPLAY:
            send_rc5(CD,15,4);
            break;
        case OPEN:
            send_rc5(CD,45,4);
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

