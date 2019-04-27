/***********************************************/
/*            C-manship, Listing 1             */
/*                 CHAPTER 16                  */
/*          Developed with Megamax C           */
/***********************************************/

#include "MENU.rsh"
#include <aes.h>
#include <vdi.h>

#define MU_MESAG 0x0010
#define ARROW    0
#define R_TREE   0
#define TRUE     1
#define FALSE    0

/* The usual required GEM global arrays */
int work_in[11],
    work_out[57],
    pxyarray[10],
    contrl[12],
    intin[128],
    ptsin[128],
    intout[128],
    ptsout[128];

/* Global variables */
int handle, dum;
MFORM mouse_dummy;
int msg_buf[8], op1, op2, op3, on;

char *alrt = "[1][C-manship, Chapter 16|by Clayton \
Walnum][Okay]";
char *on_str = "     On     ";
char *off_str = "    Off     ";

void open_vwork (void);
void do_menu (void);

int main ()
{
   appl_init ();       /* Initialize application.        */
   open_vwork ();      /* Set up workstation.            */
   do_menu();          /* Go do the MENU.                */
   v_clsvwk (handle);  /* Close virtual workstation.     */
   appl_exit ();       /* Back to the desktop.           */
   return 0;
}

void open_vwork (void)
{
   int i;

   /* Get graphics handle, initialize the GEM arrays and open  */
   /* a virtual workstation.                                   */

   handle = graf_handle ( &dum, &dum, &dum, &dum);
   for ( i=0; i<10; work_in[i++] = 1 );
   work_in[10] = 2;
   v_opnvwk ( work_in, &handle, work_out );
}

void do_menu (void)
{
   OBJECT * menu_adr; /* Address of the tree containing our menu. */

   /* First, we initialize our option flags, so we can keep   */
   /* track of which ones are active.  Also, we change the    */
   /* mouse pointer to an arrow.                              */
   op1 = TRUE;
   op2 = FALSE;
   op3 = FALSE;
   on  = TRUE;

   graf_mouse ( ARROW, &mouse_dummy );

   /* Here we load the resource file.  If the file is missing,*/
   /* we warn the user with an alert box then terminate the    */
   /* program by skipping the code following the ELSE.        */

   if ( ! rsrc_load ("\MENU.RSC") )
      form_alert ( 1, "[1][MENU.RSC missing!][Okay]" );

   /* If the resource file loads OK, we get the address of the*/
   /* tree, then handle menu messages from evnt_multi().      */

   else {
      rsrc_gaddr ( R_TREE, TREE00, &menu_adr );
      menu_bar ( menu_adr, TRUE );
      form_alert ( 1, "[1][showing menu][OK]");
      do {
         evnt_multi ( MU_MESAG,0,0,0,0,0,0,0,0,0,0,0,0,0,msg_buf,
                      0,0,&dum,&dum,&dum,&dum,&dum,&dum );

         switch ( msg_buf[3] ) {

            case TREE00_DESK:
               switch ( msg_buf[4] ) {
                  case TREE00_INFO:
                     form_alert ( 1, alrt );
                     break;
               }

            case TREE00_FILE:
               switch ( msg_buf[4] ) {
                  case TREE00_LOAD:
                     v_gtext ( handle, 20, 120, "Load file " );
                     break;
                  case TREE00_SAVE:
                     v_gtext ( handle, 20, 120, "Save file " );
                     break;
               }

            case TREE00_OPTIONS:
               switch ( msg_buf[4] ) {
                  case TREE00_OPTION1:
                     menu_icheck ( menu_adr, TREE00_OPTION1, op1=!op1 );
                     break;
                  case TREE00_OPTION2:
                     menu_icheck ( menu_adr, TREE00_OPTION2, op2=!op2 );
                     break;
                  case TREE00_OPTION3:
                     menu_icheck ( menu_adr, TREE00_OPTION3, op3=!op3 );
                     break;
               }

            case TREE00_SELECTS:
               switch ( msg_buf[4] ) {
                  case TREE00_ONOFF:
                     if ( on )
                        menu_text ( menu_adr, TREE00_ONOFF, off_str );
                     else
                        menu_text ( menu_adr, TREE00_ONOFF, on_str );
                     menu_ienable ( menu_adr, TREE00_SELECT1, on=!on );
                     menu_ienable ( menu_adr, TREE00_SELECT2, on );
                     menu_ienable ( menu_adr, TREE00_SELECT3, on );
                     break;
                  case TREE00_SELECT1:
                     v_gtext ( handle, 20, 120, "Select 1 " );
                     break;
                  case TREE00_SELECT2:
                     v_gtext ( handle, 20, 120, "Select 2 " );
                     break;
                  case TREE00_SELECT3:
                     v_gtext ( handle, 20, 120, "Select 3 " );
                  break;
               }
            menu_tnormal ( menu_adr, msg_buf[3], TRUE );
         }
      }
      while ( msg_buf[4] != TREE00_QUIT );
      menu_bar ( menu_adr, FALSE );
   }
}