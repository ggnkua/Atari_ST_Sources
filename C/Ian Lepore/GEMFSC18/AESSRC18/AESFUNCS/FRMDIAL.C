/**************************************************************************
 *
 *************************************************************************/

#include "gemfast.h"
#include "frmtypes.h"

#ifndef NULL
  #define NULL 0L
#endif

#define NO_FLAGS        (-1)
#define BLITOPTIONS     (FRM_USEBLIT|FRM_MOVEABLE)
#define CTL_ALLOCATED   0x80000000L
/*-------------------------------------------------------------------------
 *
 *-----------------------------------------------------------------------*/

static int call_system_form_do(ctl)
    register FormControl *ctl;
{
    return form_do(ctl->ptree, ctl->editobj);
}

/*-------------------------------------------------------------------------
 *
 *-----------------------------------------------------------------------*/

long            (*_FrBltVector)()    = NULL;
static int      (*default_form_do)() = call_system_form_do;
long            _FrmDefaults  = FRM_NORMAL;

/*-------------------------------------------------------------------------
 *
 *-----------------------------------------------------------------------*/

static int find_mover_object(ptree)
    register OBJECT *ptree;
{
    register OBJECT *pobj     = ptree;
    register int     obj      = 0;
    register int     ob_flags;

    for (;;) {
        ob_flags = pobj->ob_flags;
        if (ob_flags & FRM_MOVER) {
            return obj;
        }
        if (ob_flags & LASTOB) {
            return NO_OBJECT;
        }
        ++obj;
        ++pobj;
    }
}

/*-------------------------------------------------------------------------
 *
 *-----------------------------------------------------------------------*/

FormControl *_FrmSetup(ctl, options, ptree, pboundrect)
    register FormControl *ctl;
    register long        options;
    register OBJECT      *ptree;
    register GRECT       *pboundrect;
{
    if (pboundrect == NULL) {
        pboundrect = &gl_rwdesk;
    }

    if (!(options & FRM_NODEFAULTS)) {
        options |= _FrmDefaults;
    }

    ctl->ptree        = ptree;
    ctl->pboundrect   = pboundrect;
    ctl->options      = options & FRM_OPTIONBITS;
    ctl->form_do      = default_form_do;
    ctl->editobj      = ROOT;
    ctl->parentobj    = ROOT;
    ctl->moverobj     = NO_OBJECT;
    ctl->treeflags    = NO_FLAGS;
    ctl->select_state = SELECTED;
    ctl->blitbuffer   = NULL;

    if (options & FRM_DSTART) {
        if (options & FRM_NEARMOUSE) {
            int mx, my, dmy;
            graf_mkstate(&mx, &my, &dmy, &dmy);
            ptree->ob_x = mx - (ptree->ob_width  / 2);
            ptree->ob_y = my - (ptree->ob_height / 2);
            frm_confine(ptree, pboundrect);
        } else if (options & FRM_CENTER) {
            frmx_center(ptree, &ctl->scrnrect);
        }
    }

    frm_sizes(ptree, &ctl->scrnrect);
    rc_scale(&ctl->scrnrect, &ctl->littlerect, 20);

    if (options & FRM_DSTART) {
        if ((options & BLITOPTIONS) && _FrBltVector != NULL) {
            long blitbytes;
            blitbytes = (*_FrBltVector)(GRF_BMEMCALC, NULL, &ctl->scrnrect);
            if (NULL != (ctl->blitbuffer = apl_malloc(blitbytes))) {
                ctl->moverobj = find_mover_object(ptree);
                if (ctl->moverobj == NO_OBJECT && (options & FRM_MOVEABLE)) {
                    ctl->moverobj  = ROOT;
                    ctl->treeflags = frm_mkmoveable(ptree, ROOT);
                }
            }
        }
    }

    return ctl;
}

/*-------------------------------------------------------------------------
 *
 *-----------------------------------------------------------------------*/

void frm_cleanup(ctl)
    register FormControl *ctl;
{
    if (ctl != NULL) {
        if (ctl->blitbuffer != NULL) {
            apl_free(ctl->blitbuffer);
        }
        if (ctl->ptree != NULL && ctl->treeflags != NO_FLAGS) {
            ctl->ptree->ob_flags = ctl->treeflags;
        }
        if (ctl->options & CTL_ALLOCATED) {
            apl_free(ctl);
        }
    }
}

/*-------------------------------------------------------------------------
 *
 *-----------------------------------------------------------------------*/

void *frm_init(options, ptree, pboundrect)
    long        options;
    OBJECT      *ptree;
    GRECT       *pboundrect;
{
    FormControl *ctl;

    if (NULL == (ctl = apl_malloc((long)sizeof(*ctl)))) {
        return NULL;
    } else {
        _FrmSetup(ctl, options|FRM_DSTART, ptree, pboundrect);
        ctl->options |= CTL_ALLOCATED;
        return ctl;
    }
}

/*-------------------------------------------------------------------------
 *
 *-----------------------------------------------------------------------*/

void frm_start(ctl)
    register FormControl *ctl;
{
    if (ctl->blitbuffer != NULL) {
        (*_FrBltVector)(GRF_BFROMSCREEN, ctl->blitbuffer, &ctl->scrnrect);
    }

    frmx_dial(FMD_START, &ctl->littlerect, &ctl->scrnrect);

    if (ctl->options & FRM_EXPLODE) {
        frmx_dial(FMD_GROW,  &ctl->littlerect, &ctl->scrnrect);
    }

}

/*-------------------------------------------------------------------------
 *
 *-----------------------------------------------------------------------*/

void frm_draw(ctl, obj)
    register FormControl *ctl;
    int                  obj;
{
    objc_draw(ctl->ptree, obj, MAX_DEPTH, *ctl->pboundrect);
}

/*-------------------------------------------------------------------------
 *
 *-----------------------------------------------------------------------*/

void frm_finish(ctl)
    register FormControl *ctl;
{
    if (ctl->options & FRM_EXPLODE) {
        frmx_dial(FMD_SHRINK, &ctl->littlerect, &ctl->scrnrect);
    }

    if (ctl->blitbuffer != NULL) {
        (*_FrBltVector)(GRF_BTOSCREEN, ctl->blitbuffer, &ctl->scrnrect);
    } else {
        frmx_dial(FMD_FINISH, &ctl->littlerect, &ctl->scrnrect);
        evnt_timer(1,0);
    }

}

/*-------------------------------------------------------------------------
 *
 *-----------------------------------------------------------------------*/

void frm_move(ctl)
    register FormControl *ctl;
{
    int            oldmouse;
    int            mb;
    int            dmy;
    register int   adjust;
    register GRECT *prect = (GRECT *)&ctl->ptree->ob_x;

    if (ctl->blitbuffer == NULL) {
        return;
    }

    /*
     * delay very briefly, then see if the mouse button is still down.
     * if it's not, just return.  this prevents false 'moves' when all
     * the user did was miss the button s/he was after.
     */
     
    evnt_timer(10,0);
    graf_mkstate(&dmy, &dmy, &mb, &dmy);
    if (!mb) {
        return;
    }
    
    (*_FrBltVector)(GRF_BTOSCREEN, ctl->blitbuffer, &ctl->scrnrect);

    adjust = obj_clcalc(ctl->ptree, ROOT, NULL, NULL);
    rc_gadjust(prect, adjust, adjust);

    oldmouse = graf_mouse(FLAT_HAND, NULL);
    grfx_dragbox(prect, ctl->pboundrect, prect);
    graf_mouse(oldmouse, NULL);

    adjust = -adjust;
    rc_gadjust(prect, adjust, adjust);

    frm_sizes(ctl->ptree, &ctl->scrnrect);
    (*_FrBltVector)(GRF_BFROMSCREEN, ctl->blitbuffer, &ctl->scrnrect);
    frm_draw(ctl, ROOT);
}

/*-------------------------------------------------------------------------
 *
 *-----------------------------------------------------------------------*/

int frm_do(ctl, editobj)
    register FormControl *ctl;
    int                  editobj;
{
    int oldmouse;
    int rv;
    int obj;

    if (ctl->options & FRM_MOUSEARROW) {
        oldmouse = graf_mouse(ARROW, 0L);
    }

    ctl->editobj = editobj;

    do  {
        obj = 0x7FFF & (rv = (*ctl->form_do)(ctl));
        if (rv == NO_OBJECT) {
            goto QUICK_EXIT;
        }
        if (obj == ctl->moverobj) {
            frm_move(ctl);
        }
    } while (obj == ctl->moverobj);

    if (ctl->ptree[obj].ob_flags & (EXIT|DEFAULT)) {
        evnt_timer(70,0);
        obj_stchange(ctl->ptree, obj, ~ctl->select_state,
            OBJ_CLIPDRAW, ctl->pboundrect);
    }

QUICK_EXIT:

    if (ctl->options & FRM_MOUSEARROW) {
        graf_mouse(oldmouse, 0L);
    }

    return rv;
}

/*-------------------------------------------------------------------------
 *
 *-----------------------------------------------------------------------*/

int frm_dialog(options, ptree, object)
    long    options;
    OBJECT *ptree;
    int     object;
{
    FormControl ctl;
    int         selobj;
    long        actions;

    if (0 == (actions = options & FRM_ACTIONBITS)) {
        options  |= (actions = FRM_DCOMPLETE);
    }

    if (actions == FRM_DCOMPLETE) {
        wind_update(BEG_UPDATE);
    } else {
        if (options & BLITOPTIONS) {
            options &= ~BLITOPTIONS;
        }
    }

    _FrmSetup(&ctl, options, ptree, NULL);

    if (actions & FRM_DSTART) {
        frm_start(&ctl);
    }

    if (actions & FRM_DDRAW) {
        frm_draw(&ctl, (options & FRM_DSTART) ? ROOT : object);
    }

    if (actions & FRM_DDO) {
        selobj = frm_do(&ctl, object);
    }

    if (actions & FRM_DFINISH) {
        frm_finish(&ctl);
    }

    frm_cleanup(&ctl);

    if (actions == FRM_DCOMPLETE) {
        wind_update(END_UPDATE);
    }

    return selobj;
}

/*-------------------------------------------------------------------------
 *
 *-----------------------------------------------------------------------*/

long frm_defaults(options)
    long options;
{
    long rv = _FrmDefaults;

    if (options != FRM_GETDEFAULTS) {
        _FrmDefaults = options & FRM_OPTIONBITS & ~FRM_NODEFAULTS;
    }
    return rv;
}

/*-------------------------------------------------------------------------
 *
 *-----------------------------------------------------------------------*/

void *frm_dovector(newfunc)
    void *newfunc;
{
    void *rv = default_form_do;

    if (newfunc != NULL) {
        default_form_do = newfunc;
    }
    return rv;
}

