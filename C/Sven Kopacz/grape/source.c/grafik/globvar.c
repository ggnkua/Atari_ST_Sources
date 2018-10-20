#include <grape_h.h>
#include "grape.h"
#include "undo.h"
#include "module.h"
#include "ple.h"
#include "penedit.h"
#include "penpal.h"
#include "dithtab.h"
#include "layer.h"
#include "mask.h"
#include "export.h"
#include "fiomod.h"

/* Globale Variablen */

int layer_id=0, mask_id=0, layers_off;

void *physbase;
int sx, sy, sw, sh,  undo_buffers;
int	planes;
int	artpad;

int sel_tool=SDRAW;

int	quit=0;

int	xrsrc[15];

/* Modus: 0=Farbe, 1=Grau */
char col_or_grey;

int	rgb248[3];

PEN	pen;
ASG_COOKIE *asgc;
ASG_COOKIE default_tablet=
{
1, /* Version */
64, /* act_press */
200, /* max_press */
"Not present",	/* tablet-Name */
0, /* Driver-ID */
NULL,	/* Div. functions */
NULL,
NULL,
NULL,
NULL,
NULL
};

DITHER_PRE_FIELD r_dither[256];
DITHER_PRE_FIELD g_dither[256];
DITHER_PRE_FIELD b_dither[256];
DITHER_FIELD rr_dither[256];
DITHER_FIELD gg_dither[256];
DITHER_FIELD bb_dither[256];
int	square_root[1000];
int TB_IMG_X, TB_M_IMG_X;
OBJECT *mmenu, *onew, *oundo, *opened, *opledit, *otool;
OBJECT *keycmds, *ocoldd, *opmode, *ounopt, *oaopt;
OBJECT *ocoled, *opens, *oicons, *omerk, *otoolbar, *onewlay;
OBJECT *ocopylay, *ospecial, *oframe, *onewmask;
OBJECT *ocolpal, *ostartup, *omodule, *opreview, *oclear;
OBJECT *osize, *oprint, *ozoom, *ofzooms, *oexport, *ofexport;
OBJECT *ofxsave, *omodopt, *ostampopt, *osrcpens;
WINDOW wundorec, wpened, wpledit, wtool, wcoled, wpens, wnew;
WINDOW wnewlay, wcopylay, wspecial, wnewmask, wcolpal, wpmode;
WINDOW winfo, wunopt, waopt, wmodule, wpreview, wclear;
WINDOW wsize, wprint, wzoom, wfzooms, wexport, wfexport;
WINDOW wfxsave, wmodopt, wstampopt;
DINFO  dundorec, dpened, dpledit, dtool, dcoled, dpens, dnew;
DINFO  dnewlay, dcopylay, dspecial, dnewmask, dcolpal, dpmode;
DINFO	 dinfo, dunopt, daopt, dmodule, dpreview, dclear;
DINFO  dsize, dprint, dzoom, dfzooms, dexport, dfexport;
DINFO	 dfxsave, dmodopt, dstampopt;
FREE_UNDO_LIST	*ful;
POLYNOM	ple;
POLY_TARGET ple_target;
PEN_PARAMETER pgp, default_pen;
PEN_LIST	first_pen;
LAY_LIST	*first_lay=NULL, *act_lay=NULL, *painted_lay=NULL;
MASK_LIST	*first_mask=NULL, *act_mask=NULL, *painted_mask=NULL;
MODULE_LIST	*first_module=NULL;
GRAPE_FN		grape_mod_info;
GRAPE_FIOFN	grape_fiomod_info;
FIO_LIST		*first_fiomod=NULL;
int	module_id;
int	expf_id;
MASK	*mod_mask;
LAYER	*mod_lay;
LAY_STORE lay_store[11];
MASK_STORE mask_store[11];
EXP_FORM *first_expf=NULL;
int	tool_tol[8][3];
/* Preview-Function */
int cdecl(*prev_func)(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv);

/* Farbtabelle fÅr mask_color
   Bit 0=Magenta sichtbar
   Bit 1=Gelb
   Bit 2=Cyan
*/
unsigned char mask_col_tab[8]=
{ 0,7, 3,6,5, 4,2,1 };


/* Globale Farbpalette fÅr Im-/Export */
uchar gc_pal[256][3];

_main_win main_win;

_pens_obs pens_obs;
_colpal_obs colpal_obs;

_frame_data frame_data;

_paths paths;

_magics magics;

