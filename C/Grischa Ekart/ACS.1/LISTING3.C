/*           DIALOG.C V1.0, 20.1.1992           */
/* Autor: Grischa Ekart                         */

#include    "g:\acs\acs.h"
#include    <dialog.h>

static   Awindow *dialog_create(void *not_used);
static   void ja_click(void);
static   void nein_click(void);
static   void reset_click(void);

static   void reset_dialog(OBJECT *object);

#include    <dialog.ah>

typedef  struct {
   int   checkA;
   int   checkB;
   int   option;
} DATA;

DATA  global_data;

static Awindow
*dialog_create(void *not_used)
{
   Awindow *wi;

   wi = Awi_create(&DIALOGFENSTER);
   if(wi == NULL)
      return(NULL);

   reset_dialog(wi->work);
   (wi->open)(wi);
   return(wi);
}

int
ACSinit(void)
{
   Awindow  *window;

   window = Awi_root();
   if(window == NULL)
      return(FAIL);

   (window->service)(window, AS_NEWCALL,
      &DIALOGFENSTER.create);

   global_data.checkA = 0; 
   global_data.checkB = 0; 
   global_data.option = 1; 
   return(OK);
}

static void
ja_click(void)
{
   int      ob_index = -1;

   global_data.checkA = 0; 
   global_data.checkB = 0; 
   while(1)
   {
      ob_index = Aob_findflag(ev_object, ob_index, SELECTABLE);
      if(ob_index == -1)
         break;

      if(ev_object[ob_index].ob_state & SELECTED)
      {
         switch(ob_index)
         {
            case CHECKA:
               global_data.checkA = 1;
               break;
   
            case CHECKB:
               global_data.checkB = 1;
               break;
   
            case OPTION1:
               global_data.option = 1;
               break;
   
            case OPTION2:
               global_data.option = 2;
               break;
   
            case OPTION3:
               global_data.option = 3;
               break;
         }
      }
   }
   Awi_closed(ev_window);
}

static void
nein_click(void)
{
   reset_dialog(ev_object);
   ev_object[OPTION1].ob_state &= ~SELECTED;
   switch(global_data.option)
   {
      case 1:
         ev_object[OPTION1].ob_state |= SELECTED;
         break;

      case 2:
         ev_object[OPTION2].ob_state |= SELECTED;
         break;

      case 3:
         ev_object[OPTION3].ob_state |= SELECTED;
         break;
   }
   if(global_data.checkA)
      ev_object[CHECKA].ob_state |= SELECTED;

   if(global_data.checkB)
      ev_object[CHECKB].ob_state |= SELECTED;

   Awi_closed(ev_window);
}

static void
reset_click(void)
{
   reset_dialog(ev_object);
   Awi_obredraw(ev_window, ROOT);
}

void
reset_dialog(OBJECT *object)
{
   object[CHECKA].ob_state &= ~SELECTED;
   object[CHECKB].ob_state &= ~SELECTED;
   object[OPTION1].ob_state |= SELECTED;
   object[OPTION2].ob_state &= ~SELECTED;
   object[OPTION3].ob_state &= ~SELECTED;
}
