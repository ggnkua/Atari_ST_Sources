/**************************************************************************
 * FRMTYPES.H - datatypes internal to the forms handling subsystem.
 *************************************************************************/

#ifndef FRMTYPES_H
#define FRMTYPES_H

#include <stdarg.h>

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
    int     (*form_do)(struct form_control *ctl);
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

typedef long BLITFU(int options, void *buffer, void *prect);

extern long             _FrmDefaults;

FormControl *_FrmSetup	(FormControl *ctl, long options, OBJECT *ptree, GRECT *pboundrect);

char *	_FrmVFormat		(char *fmt, va_list args, int *plen);
void 	_FrmVFree		(char *buffer);

void 	_FrmTrWidths	(OBJECT *ptree, int parent, int width);
int 	_FrmDS2Obj		(char **ppstr, OBJECT *pobj, TEDINFO *pted, int *pwidth, int maxobj);
void	_FrmNLPatch		(char **patch_array);
void	_FrmNL2DS		(char *strings, char **pointer_array, char **patch_array, int maxstrings);

#endif
