/***********************************************/
/* Es gibt sie doch! - Checkboxen unter GEM    */
/* Autor: Uwe Hax                              */
/* (C) 1991 MAXON Computer                     */
/***********************************************/


#include <aes.h>
#include <portab.h>
#include <string.h>
#include <stdlib.h>


/* Defines fÅr Zugriff auf die Dialgobox */
#define DIALOG      0
#define CHECKBOX    1
#define OK          3
#define STATUS      5


/* Resource-Definitionen fÅr Dialogbox */
OBJECT test_dialog[] = {
  -1, 1, 5, G_BOX, NONE, OUTLINED, 0x21100L, 
  0,0, 176,128,
  2, -1, -1, G_BOX, TOUCHEXIT, CROSSED, 
  0xFF1171L, 24,48, 16,16,
  3, -1, -1, G_STRING, NONE, NORMAL, 
  (LONG)"GEM-Checkbox", 56,48, 96,16,
  4, -1, -1, G_BUTTON, 0x7, NORMAL, (LONG)"Ok", 
  56,96, 64,16,
  5, -1, -1, G_STRING, NONE, NORMAL, 
  (LONG)"Test-Dialog", 48,16, 96,16,
  0, -1, -1, G_STRING, LASTOB, NORMAL, 
  (LONG)"(Status: ein)", 56,64, 96,16
};


VOID main(VOID)
{
  WORD x,y,w,h;
  WORD objc_x,objc_y;
  WORD button;
  WORD dummy;
  
  /* Programm anmelden */
  appl_init();
  
  graf_mouse(M_OFF,0L);
  graf_mouse(ARROW,0L);
  
  /* Trick 17: Box-Inhalt invertieren */
  test_dialog[CHECKBOX].ob_state |= SELECTED;

  /* Dialogbox îffnen */
  form_center(test_dialog,&x,&y,&w,&h);
  form_dial(FMD_START,x,y,w,h,x,y,w,h);
  objc_draw(test_dialog,ROOT,MAX_DEPTH,x,y,w,h);
  graf_mouse(M_ON,0L);

  /* Dialog auswerten */
  do
  {
    button=form_do(test_dialog,0) & 0x7fff;
   
    /* Checkbox angeklickt? */
    if (button==CHECKBOX)
    {
      /* Kreuz ein- und ausschalten */
      if (test_dialog[CHECKBOX].ob_state & 
                                         CROSSED)
      {
        test_dialog[CHECKBOX].ob_state &= 
                                        ~CROSSED;
        strncpy(&test_dialog[STATUS].ob_spec.
                         free_string[9],"aus",3);
      }
      else
      {
        test_dialog[CHECKBOX].ob_state |= 
                                         CROSSED;
        strncpy(&test_dialog[STATUS].ob_spec.
                         free_string[9],"ein",3);
      }
      
      /* Checkbox neu zeichnen */
      graf_mouse(M_OFF,0L); 
      objc_offset(test_dialog,CHECKBOX,&objc_x,
                                        &objc_y);
      objc_draw(test_dialog,ROOT,MAX_DEPTH,
                objc_x,objc_y,
                test_dialog[CHECKBOX].ob_width,
                test_dialog[CHECKBOX].ob_height);
      graf_mouse(M_ON,0L);
  
      /* Status neu zeichnen */
      objc_offset(test_dialog,STATUS,&objc_x,
                  &objc_y);
      objc_draw(test_dialog,ROOT,MAX_DEPTH,
                objc_x,objc_y,
                test_dialog[STATUS].ob_width,
                test_dialog[STATUS].ob_height);
                
      /* Warten, bis Mausclick-Ende */
      evnt_button(1,1,0,&dummy,&dummy,&dummy,
                  &dummy);
    }
  }
  while (test_dialog[button].ob_flags & 
                                      TOUCHEXIT);

  /* Dialogbox entfernen und Programm beenden */
  form_dial(FMD_FINISH,x,y,w,h,x,y,w,h);
  appl_exit();
  exit(0);
}


