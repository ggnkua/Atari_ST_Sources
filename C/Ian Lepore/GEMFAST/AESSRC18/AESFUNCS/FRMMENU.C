/**************************************************************************
 * FRMMENU.C - The frm_menu() and frm_mdo() functions.
 *************************************************************************/

#include "gemfast.h"
#include "frmtypes.h"

#ifndef TRUE
  #define TRUE  1
  #define FALSE 0
#endif

#ifndef NULL
  #define NULL 0L
#endif

#define BLITOPTIONS (FRM_USEBLIT|FRM_MOVEABLE)

#define MU_M1_ENTRY 0
#define MU_M1_EXIT  1

static void wait_buttonup()
{
    int dmy;
    evnt_button(1,1,0,&dmy,&dmy,&dmy,&dmy);
}

int frm_mdo(ctl)
    register FormControl *ctl;
{
    int             mx;
    int             my;
    int             mb;
    int             dmy;
    int             exit_condition;
    int             mouse_object;
    int             watch_object;
    int             selected_object;
    int             oldmouse;
    int             ob_flags;
    int             ob_state;
    GRECT           leaverect;
    XMULTI          xm;
    register OBJECT *ptree = ctl->ptree;

    wind_update(BEG_MCTRL);
    oldmouse = graf_mouse(GRF_MSINQUIRE, NULL);

    if (ctl->options & FRM_MEXITPARENT) {
        obj_clcalc(ptree, ctl->parentobj, &leaverect, NULL);
    } else if (ctl->options & FRM_MEXITVICINITY) {
        obj_clcalc(ptree, ctl->parentobj, &leaverect, NULL);
        rc_gadjust(&leaverect, 4*gl_wchar, 2*gl_hchar);
        rc_intersect(&gl_rwdesk,  &leaverect);
    } else {
        rc_copy(&gl_rwdesk, &leaverect);
    }

    watch_object    = ctl->parentobj;
    selected_object = NO_OBJECT;

    xm.mflags   = MU_M1 | MU_BUTTON;
    xm.mbclicks = 1;
    xm.mbmask   = 1;
    xm.mbstate  = 1;
    xm.mm1flags = MU_M1_ENTRY;

    if (ctl->defaultobj != NO_OBJECT) {
        xm.mflags |= MU_KEYBD;
    }

    do  {
        exit_condition = FALSE;
        obj_clcalc(ptree, watch_object, &xm.mm1rect, NULL);

        evnx_multi(&xm);
        graf_mkstate(&mx, &my, &mb, &dmy);

        if ((xm.mwhich & MU_M1) && (selected_object != NO_OBJECT)) {
            obj_stchange(ptree, selected_object, ~ctl->select_state,
                OBJ_CLIPDRAW, ctl->pboundrect);
            selected_object = NO_OBJECT;
        }

        mouse_object = objc_find(ptree, ctl->parentobj, MAX_DEPTH, mx, my);
        watch_object = ctl->parentobj;
        xm.mm1flags  = MU_M1_ENTRY;

        if (mouse_object == NO_OBJECT) {
            if (!rc_ptinrect(&leaverect, mx, my)) {
                exit_condition = TRUE;
            }
        } else {
            ob_flags = ptree[mouse_object].ob_flags;
            ob_state = ptree[mouse_object].ob_state;
            if ( (ob_flags & (SELECTABLE|EXIT|TOUCHEXIT|DEFAULT)) &&
                !(ob_state & DISABLED)) {
                selected_object = mouse_object;
                if (!(ob_flags & (EXIT|DEFAULT|TOUCHEXIT))) {
                    watch_object = mouse_object;
                    xm.mm1flags = MU_M1_EXIT;
                    obj_stchange(ptree, mouse_object, ctl->select_state,
                        OBJ_CLIPDRAW, ctl->pboundrect);
                }
            }
        }

        if (xm.mwhich & MU_BUTTON) {
            exit_condition = TRUE;
            if (selected_object != NO_OBJECT && (ob_flags & (EXIT|DEFAULT))) {
                if (!graf_watchbox(ptree, selected_object, ctl->select_state, ob_state)) {
                    exit_condition = FALSE;
                    selected_object = NO_OBJECT;
                }
            }
        }
    
        if (xm.mwhich & MU_KEYBD && (xm.mkreturn & 0x00FF) == '\r') {
            selected_object = ctl->defaultobj;
            exit_condition  = TRUE;
            obj_stchange(ptree, selected_object, ctl->select_state,
                OBJ_CLIPDRAW, ctl->pboundrect);
        }

        if ((ctl->options & FRM_DMUSTSELECT) && selected_object == NO_OBJECT) {
            exit_condition = FALSE;
        }

    } while (!exit_condition);

    wind_update(END_MCTRL);

    return selected_object;
}

static int find_default_exit(ptree)
    register OBJECT *ptree;
{
    register int    counter = 0;
    
    for (;;) {
        if (ptree->ob_flags & DEFAULT) {
            return counter;
        }
        if (ptree->ob_flags & LASTOB) {
            return NO_OBJECT;
        }
        ++ptree;
        ++counter;
    }
}

int frm_menu(options, ptree, select_state)
    long            options;
    register OBJECT *ptree;
    int             select_state;
{
    FormControl     ctl;
    int             selobj;
    long            actions;

    if (0 == (actions = options & FRM_ACTIONBITS)) {
        options  |= (actions = FRM_DCOMPLETE);
    }

    if (actions == FRM_DCOMPLETE) {
        wind_update(BEG_UPDATE);
        wind_update(BEG_MCTRL);
    } else {
        if (options & BLITOPTIONS) {
            options &= ~BLITOPTIONS;
        }
    }
    
    wait_buttonup();

    _FrmSetup(&ctl, options, ptree, NULL);
    ctl.select_state = select_state;
    ctl.form_do      = frm_mdo;
    ctl.defaultobj   = find_default_exit(ptree);

    if (actions & FRM_DSTART) {
        frm_start(&ctl);
    }

    if (actions & FRM_DDRAW) {
        frm_draw(&ctl, ROOT);
    }

    if (actions & FRM_DDO) {
        selobj = frm_do(&ctl, 0);
    }

    if (actions & FRM_DFINISH) {
        frm_finish(&ctl);
    }

    frm_cleanup(&ctl);

    if (!(ptree[selobj].ob_flags & TOUCHEXIT)) {
        wait_buttonup();
    }
    
    if (actions == FRM_DCOMPLETE) {
        wind_update(END_MCTRL);
        wind_update(END_UPDATE);
    }

    return selobj;
}


