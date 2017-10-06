/**************************************************************************
 * 
 *************************************************************************/

#include <osbind.h>
#include <gemfast.h>
#include <exterror.h>
#include "formdemo.h"

#ifndef NULL
  #define NULL 0L
#endif

#ifndef TRUE
  #define TRUE  1
  #define FALSE 0
#endif

/*-------------------------------------------------------------------------
 * Error messages...
 *-----------------------------------------------------------------------*/

#define Err_unknown     -300
#define Err_demo        -301

static _Err_tab custom_messages[] = {
    {Err_unknown, "(Cause of error unknown)"},
    {Err_demo,    "This is a custom error message for\n"
                  "the forms demo. It comes from the\n"
                  "the custom message table."},
};

static char xform_error[] = "Can't transform buttons for %s demo.\n";

/*-------------------------------------------------------------------------
 * Miscellanious text messages for the demos...
 *-----------------------------------------------------------------------*/

static char menu_title_string[] = "GemFast v1.8 Forms/Dialog Demo";

static char version_msg[] = 
            "\n"
    "\x7F"  "GemFast v1.8 Forms Demo\n"
    "\x7F"  "Public Domain 04/92 By Ian Lepore\n"
            "\n"
    ;


static char qtext_msg[] = 
    "\x7F" "Demo of frm_qtext()\n"
            "\n"
            "This is some formatted text in a box.\n"
            "Below are 4 random numbers, one per\n"
            "line, each one centered...\n"
            "\n"
    "\x7F"  "%d\n"
    "\x7F"  "%d\n"
    "\x7F"  "%d\n"
    "\x7F"  "%d\n"
    ;      

static char qchoice_buttons[] = 
    "Go For It\n"
    "Don't Do It\n"
    "Maybe\n"
    "Vote On It\n"
    "Punt"
    ;
                                
static char qchoice_msg[] = 
    "\x7F"  "Demo of frm_qchoice()\n"
            "\n"
    "\x7F"  "Listed below are some buttons that\n"
    "\x7F"  "might represents choices the user\n"
    "\x7F"  "could make at this point.\n"
            "\n"
    ;

static char qmenu_title[] = " Demo of frm_qmenu() ";

static char qmenu_items[] = 
    "Cue CAMBOT Still Store\n"
    "Invention Exchange\n"
    "Cut to the Chase\n"
    "Discuss Plot Point\n"
    "Commercial Sign\n"
    "Closing Credits\n"
    ;

static char mustsel_od_msg[] = 
    "\x7F"  "You must select one\n"
    "\x7F"  "of these buttons."
    ;
    
static char mustsel_in_msg[] = 
    "\x7F"  "You must select one or\n"
    "\x7F"  "more of these buttons."
    ;
    
static char mustenter_fn_msg[] = 
        "Filename is required."
        ;
        
static char track_msg[] = "Track: %-2d  Side %d";

static char progress_msg[] = 
    "\x7F"  "Demo of frm_progress()\n"
            "\n"
            "Let's pretend that we're going to do something to\n"
            "all %d tracks of a floppy disk.  This is an example\n"
            "of what a progress dialog might look like.\n"
            "\n"
            "Please note that this demo does NOT touch your disks!\n"
            "\n"
    "\x7F"  "\n" /* track/side message goes on this (last) line */
    ;       
            
/*-------------------------------------------------------------------------
 * RSC-related data...
 *-----------------------------------------------------------------------*/

#define RSRCNAME "formdemo.rsc"

OBJECT  *maintree;
OBJECT  *defltree;
OBJECT  *cbtntree;
OBJECT  *rbtntree;
OBJECT  *movetree;
OBJECT  *flagtree;
OBJECT  *desktree;
OBJECT  *menutree;

/*-------------------------------------------------------------------------
 * prg_exit - Free GEM resources and terminate program.
 *-----------------------------------------------------------------------*/

void prg_exit()
{
    rsrc_free();
    appl_exit();
    Pterm(0);
}

/*-------------------------------------------------------------------------
 * prg_init - Init GEM resources and our dialog handling stuff.
 *-----------------------------------------------------------------------*/

void prg_init()
{
    int status;
    
    exterrset(custom_messages, TRUE);

    appl_init();

    frm_enableblit();
    frm_defaults(FRM_CENTER|FRM_MOUSEARROW|FRM_USEBLIT|FRM_MOVEABLE);
    
    if (!rsrc_load(RSRCNAME)) {
        frm_error(Err_unknown, "Fatal", "Can't load resource file!\n");
        prg_exit();
    }
    
    rsc_gtrees(MAINTREE, &maintree,
               MOVETREE, &movetree,
               DEFLTREE, &defltree,
               CBTNTREE, &cbtntree,
               RBTNTREE, &rbtntree,
               FLAGTREE, &flagtree,
               DESKTREE, &desktree,
               MENUTREE, &menutree,
               -1);
               
    frm_mkmoveable(movetree, MOVEBAR);

    if (0 != (status = rsc_cubuttons(cbtntree))) {
        frm_qerror(status, xform_error, "CUA");
    }
    
    if (0 != (status = rsc_rrbuttons(rbtntree))) {
        frm_qerror(status, xform_error,  "RR");
    }
    
    graf_mouse(THIN_CROSS, NULL);
}

/*-------------------------------------------------------------------------
 * demo_frm_eflag - Demo the dialog error flagging system.
 *-----------------------------------------------------------------------*/

static void demo_frm_eflag()
{
    int     selection;
    char    *edittext;
    
    rsc_gstrings(flagtree, FLAGTEIF, &edittext, -1);
    *edittext = 0;
    
    frm_dialog(FRM_DSTART|FRM_DDRAW, flagtree, 0);
    
    do  {
        selection = frm_dialog(FRM_DDO, flagtree, FLAGTEIF);
        switch (selection) {
          case FLAGBXCN:
            break;
          case FLAGBXHM:
            frm_eflag(flagtree, FLAGBXHM, "Ouch!");
            selection = NO_OBJECT;
            break;
          case FLAGBXOK:
            if (NO_OBJECT == obj_rbfind(flagtree, FLAGPBOD, SELECTED)) {
                frm_eflag(flagtree, FLAGPBOD, mustsel_od_msg);
                selection = NO_OBJECT;
            } else if (0 == obj_bmbuttons(flagtree, FLAGPBIN, SELECTED, OBJ_BMINQUIRE)) {
                frm_eflag(flagtree, FLAGPBIN, mustsel_in_msg);
                selection = NO_OBJECT;
            } else if (0 == *edittext) {
                frm_eflag(flagtree, FLAGTEIF, mustenter_fn_msg);
                selection = NO_OBJECT;
            }
            break;
        }
    } while (selection == NO_OBJECT);
    
    frm_dialog(FRM_DFINISH, flagtree, 0);

}

/*-------------------------------------------------------------------------
 * demo_frm_progress - Demo the dynamic progress dialog.
 *-----------------------------------------------------------------------*/

static void demo_frm_progress()
{
    int tracks;
    int counter;
    tracks = 80;
    
    frm_progress(FRM_PSTART, tracks, "Abort", progress_msg, tracks);
    
    for (counter = 0; counter < tracks; ++counter) {
        if (frm_progress(FRM_PUPDATE, 0, NULL, track_msg, counter, 0)) {
            break;
        }
        evnt_timer(100,0);
        if (frm_progress(FRM_PUPDATE, 0, NULL, track_msg, counter, 1)) {
            break;
        }
        evnt_timer(100,0);
        if (frm_progress(FRM_PUPDATE, OBJ_TINCREMENT, NULL, NULL)) {
            break;
        }
    }
    
    frm_qtext("\x7F" "All done");
    
    frm_progress(FRM_PFINISH, 0, NULL, NULL);
}

/*-------------------------------------------------------------------------
 * 
 *-----------------------------------------------------------------------*/

static void drag_icon(ptree, object)
    OBJECT *ptree;
    int     object;
{
    GRECT old_rect;
    GRECT new_rect;
    
    obj_clcalc(ptree, object, &old_rect, NULL);
    rc_copy(&old_rect, &new_rect);
    
    grfx_dragbox(&new_rect, &gl_rwdesk, &new_rect);
    ptree[object].ob_x = new_rect.g_x - ptree->ob_x;
    ptree[object].ob_y = new_rect.g_y - ptree->ob_y;
    
    frmx_dial(FMD_FINISH, NULL, &old_rect);
    frmx_dial(FMD_FINISH, NULL, &new_rect);
    evnt_timer(0,0);
}

/*-------------------------------------------------------------------------
 * demo_frm_desktop - Demo the handling of an installed desktop.
 *-----------------------------------------------------------------------*/

static void demo_frm_desktop()
{
    int     obj;
    int     oldmouse;
    int     exit_requested  = FALSE;
    int     selected_object = NO_OBJECT;
    XMULTI  xm;
    char    dummy_path[128];
    
    xm.mflags   = MU_MESAG | MU_BUTTON;
    xm.mbclicks = 2;
    xm.mbmask   = 1;
    xm.mbstate  = 1;

    oldmouse = graf_mouse(ARROW, NULL);
    frm_desktop(FRM_DTINSTALL|FRM_CENTER, desktree);
    
    do  {
        evnx_multi(&xm);
        
        if ((xm.mwhich & MU_MESAG) && xm.msgbuf[0] == MN_SELECTED) {
            switch (xm.msgbuf[4]) {
              case MENDINFO:
                frm_qtext(version_msg);
                break;
              case MENFFSEL:
                fsl_dialog(FSL_NORMAL, dummy_path, NULL, NULL, "Dummy File Selector");
                break;
              case MENFQUIT:
                exit_requested = TRUE;
                break;
            }
            menu_tnormal(menutree, xm.msgbuf[3], TRUE);
        }
        
        if (xm.mwhich & MU_BUTTON) {
            if (selected_object != NO_OBJECT) {
                obj_stchange(desktree, selected_object, ~SELECTED, TRUE);
            }
            obj = objc_find(desktree, ROOT, MAX_DEPTH, xm.mmox, xm.mmoy);
            if (obj != NO_OBJECT && desktree[obj].ob_type == G_ICON) {
                obj_stchange(desktree, obj, SELECTED, TRUE);
                selected_object = obj;
                if (xm.mbreturn == 2) {
                    frm_qtext("You double-clicked an icon");
                } else {
                    drag_icon(desktree, obj);
                }
            }
        }
        
    } while (!exit_requested);
    

    frm_desktop(FRM_DTREMOVE, NULL);
    graf_mouse(oldmouse, NULL);
}

 
/*-------------------------------------------------------------------------
 * change_defaults - Change the default dialog handling options.
 *-----------------------------------------------------------------------*/

static void change_defaults()
{
    int  basic_options;
    int  dynamic_options;
    long default_options;
    
    default_options = frm_defaults(FRM_GETDEFAULTS);
    basic_options   = default_options & FRM_BOPTIONBITS;
    dynamic_options = (default_options & FRM_DOPTIONBITS) >> 16;
    
    obj_bmbuttons(defltree, DEFLPBB1, SELECTED, basic_options);
    obj_bmbuttons(defltree, DEFLPBD1, SELECTED, dynamic_options);
    
    frm_dialog(FRM_NORMAL, defltree, 0);
    
    basic_options   = obj_bmbuttons(defltree, DEFLPBB1, SELECTED, OBJ_BMINQUIRE);
    dynamic_options = obj_bmbuttons(defltree, DEFLPBD1, SELECTED, OBJ_BMINQUIRE);
    
    default_options = ((long)dynamic_options << 16) | basic_options; 
    frm_defaults(default_options);
}

/*-------------------------------------------------------------------------
 * main - Yer typical main driver routine.
 *-----------------------------------------------------------------------*/

main()
{
    int selection;
    
    prg_init();
    mnu_tbar(menu_title_string);
    
    do  {
        selection = frm_menu(FRM_DMUSTSELECT, maintree, SELECTED);
        maintree[selection].ob_state &= ~SELECTED;
        switch (selection) {
        
          case MAINBXEX:
            /* exit -- do nothing */
            break;

          case MAINBXCD:
            change_defaults();
            break;

          case FRMDESKT:
            menu_bar(menutree, TRUE);
            demo_frm_desktop();
            mnu_tbar(menu_title_string);
            break;

          case FRMEFLAG:
            demo_frm_eflag();
            break;
        
          case FRMPROGR:
            demo_frm_progress();
            break;

          case FRMMKMOV:
            frm_dialog(FRM_USEBLIT, movetree, 0);
            break;

          case RSCCUBUT:
            frm_dialog(FRM_NORMAL, cbtntree, 0);
            break;

          case RSCRRBUT:
            frm_dialog(FRM_NORMAL, rbtntree, 0);
            break;

          case FRMQTEXT:
            frm_qtext(qtext_msg, rand(), rand(), rand(), rand());
            break;

          case FRMQERRO:
            frm_qerror(Err_demo, "\x7F" "Demo of frm_qerror()\n\n");
            break;

          case FRMQUEST:
            frm_question("\nDo you like the demo so far?\n\n");
            break;

          case FRMQCHOI:
            frm_qchoice(qchoice_buttons, qchoice_msg);
            break;

          case FRMQMENU:
            frm_qmenu(qmenu_title, qmenu_items);
            break;

          default:
            frm_qerror(Err_unknown, 
                        "Impossible: unknown case in main switch()...\n"
                        "\x7F" "Exit button value was %d\n",
                        selection);
            break;
        }
    } while (selection != MAINBXEX);
    
    prg_exit();
}

