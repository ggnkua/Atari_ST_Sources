/**************************************************************************
 * FRMTYPES.H - datatypes internal to the forms handling subsystem.
 *************************************************************************/

#ifndef FRMTYPES_H
#define FRMTYPES_H

#define Array_els(a) ( sizeof(a) / sizeof((a)[0]) )

/*-------------------------------------------------------------------------
 * All dynamic dialogs get these options...
 *-----------------------------------------------------------------------*/

#define FRM_DEFAULT_DYNOPT    (FRM_USEBLIT | FRM_MOVEABLE | FRM_MOUSEARROW)
#define FRM_MANDATORY_DYNOPT  (FRM_CENTER  | FRM_DCOMPLETE)

/*-------------------------------------------------------------------------
 *
 *-----------------------------------------------------------------------*/

typedef struct form_control {
    OBJECT  *ptree;
    void    *blitbuffer;
    int     (*form_do)();
    long    options;
    int     editobj;
    int     parentobj;
    int     moverobj;
    int     defaultobj;
    int     specialobj;
    int     select_state;
    int     treeflags;
    GRECT   littlerect;
    GRECT   scrnrect;
    GRECT   *pboundrect;
} FormControl;

/*-------------------------------------------------------------------------
 *
 *-----------------------------------------------------------------------*/

extern long             _FrmDefaults;

extern FormControl *    _FrmSetup();

extern char *           _FrmVFormat();
extern void             _FrmVFree();

extern void             _FrmTrWidths();
extern int              _FrmDS2Obj();
extern void             _FrmNLPatch();
extern void             _FrmNL2DS();

#endif
