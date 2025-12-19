
#include "e_gem.h"

void ob_dostate(OBJECT *tree, int obj, int state)
{
	tree[obj].ob_state |= state;
}

void ob_undostate(OBJECT *tree, int obj, int state)
{
	tree[obj].ob_state &= ~state;
}

int ob_isstate(OBJECT *tree, int obj, int state)
{
	if (tree[obj].ob_state & state)
		return 1;
	else
		return 0;
}

void ob_doflag(OBJECT *tree, int obj, int flag)
{
	tree[obj].ob_flags |= flag;
}

void ob_undoflag(OBJECT *tree, int obj, int flag)
{
	tree[obj].ob_flags &= ~flag;
}

int ob_isflag(OBJECT *tree, int obj, int flag)
{
	if (tree[obj].ob_flags & flag)
		return 1;
	else
		return 0;
}

void ob_xywh(OBJECT *tree, int obj, GRECT *rec)
{
	*rec = *((GRECT *) &tree[obj].ob_x);
}

static char **typetest(OBJECT *tree, int obj)
{
	OBJECT *t = tree + obj;
	int ot;

	switch ((ot = t->ob_type) & 0xff)
	{
	case G_TEXT:
	case G_FTEXT:
	case G_BOXTEXT:
	case G_FBOXTEXT:
		return &(t->ob_spec.tedinfo->te_ptext);
	case G_STRING:
	case G_BUTTON:
	case G_TITLE:
		return &(t->ob_spec.free_string);
	default:
		if ((ot & G_TYPE) == ((ATTR_TEXT << 8) | G_USERDEF))	
			return ((char **) &(t->ob_spec.userblk->ub_parm));
		else
			return (NULL);
	}
}

char *ob_get_text(OBJECT *tree, int obj, int clear)
{
	char **te;

	if (te = typetest(tree, obj)) {
		if (clear)
			**te = '\0';
		return *te;
	} else
		return NULL;
}

void ob_set_text(OBJECT *tree, int obj, char *text)
{
	char **te;

	if (te = typetest(tree, obj))
		*te = text;
}

void ob_draw_dialog(OBJECT *tree,int x,int y,int w,int h)
{
	int tx,ty,tw,th;

	form_center(tree,&tx,&ty,&tw,&th);
	form_dial(FMD_START,tx,ty,tw,th,tx,ty,tw,th);

	if (x|y|w|h)
		form_dial(FMD_GROW,x,y,w,h,tx,ty,tw,th);
	objc_draw(tree,0,MAX_DEPTH,tx,ty,tw,th);
}

void ob_undraw_dialog(OBJECT *tree,int x,int y,int w,int h)
{
	int tx,ty,tw,th;

	form_center(tree,&tx,&ty,&tw,&th);
	if (x|y|w|h)
		form_dial(FMD_SHRINK,tx,ty,tw,th,x,y,w,h);
	form_dial(FMD_FINISH,tx,ty,tw,th,tx,ty,tw,th);
}

#ifdef __GNUC__
int rc_inside(int x, int y, GRECT *rec)
{
	return (x >= rec->g_x && x < rec->g_x + rec->g_w &&
			y >= rec->g_y && y < rec->g_y + rec->g_h);
}
#endif	/* __GNUC__ */

#ifdef LATTICE
void rc_grect_to_array(GRECT *rec,int *pxy)
{
	pxy[0] = rec->g_x;
	pxy[1] = rec->g_y;
	pxy[2] = rec->g_x + rec->g_w - 1;
	pxy[3] = rec->g_y + rec->g_h - 1;
}
#endif	/* LATTICE */

void rc_array_to_grect(int *pxy,GRECT *rec)
{
	rec->g_x = pxy[0];
	rec->g_y = pxy[1];
	rec->g_w = pxy[2] - pxy[0] + 1;
	rec->g_h = pxy[3] - pxy[1] + 1;
}

int EvntMulti(EVENT *evnt_struct)
{
	return (evnt_struct->ev_mwich = evnt_multi(evnt_struct->ev_mflags,
		evnt_struct->ev_mbclicks,
		evnt_struct->ev_bmask,
		evnt_struct->ev_mbstate,
		evnt_struct->ev_mm1flags,
		evnt_struct->ev_mm1x,
		evnt_struct->ev_mm1y,
		evnt_struct->ev_mm1width,
		evnt_struct->ev_mm1height,
		evnt_struct->ev_mm2flags,
		evnt_struct->ev_mm2x,
		evnt_struct->ev_mm2y,
		evnt_struct->ev_mm2width,
		evnt_struct->ev_mm2height,
		evnt_struct->ev_mmgpbuf,
		((unsigned long)evnt_struct->ev_mthicount << 16) + evnt_struct->ev_mtlocount,
		&evnt_struct->ev_mmox,
		&evnt_struct->ev_mmoy,
		&evnt_struct->ev_mmobutton,
		&evnt_struct->ev_mmokstate,
		&evnt_struct->ev_mkreturn,
		&evnt_struct->ev_mbreturn));
}
