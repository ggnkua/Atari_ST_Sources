#include "global.h"
#include "rsc.h"
#include "set.h"
#include "window.h"
#include "icon.h"

#define	MAX_TYPE_ANZ	10

typedef struct
{
	void	(*exist)	(int obj_nr, SET actions);
	bool	(*test)	(int obj_nr, int action);
	int	(*edit)	(int obj_nr, int action);
	bool	(*drag)	(int obj_nr, int dest_obj);
} ICON_TYPE;

typedef ICON_TYPE *TYPEP;

typedef struct
{
	int	icon;
	int	type_id;
} ICON_TO_TYPE;
typedef ICON_TO_TYPE *I2T;

static ICON_TYPE		icon[MAX_TYPE_ANZ];
static ICON_TO_TYPE	i2t[MAX_ICON_ANZ];
static int				type_anz = 0;

/* ============================================================== */

static TYPEP search_type(int obj_nr)
{
	int	i;
	I2T	ic;

	obj_nr &= (~SUB_ICON);
	for (ic=i2t,i=MAX_ICON_ANZ; (--i)>=0; ic++)
		if (ic->icon==obj_nr)
			return(icon+ic->type_id);
	return(NULL);
}

int all_icons(int *c)
{
	I2T	ic;
	int	i, anz;

	ic = i2t;
	for (i=MAX_ICON_ANZ, anz=0; (--i)>=0; ic++)
		if (ic->icon!=-1)
		{
			*c++ = ic->icon;
			anz++;
		}
	return anz;
}

/* <0 : Fehler bei der Ausfhrung	*/
/*	=0 : Nicht m”glich					*/
/* >0 : Erfolgreich ausgefhrt		*/
int do_icon(int icon, int action)
{
	TYPEP	t;

	t = search_type(icon);
	if (t!=NULL && (t->test)(icon,action))
		return (t->edit)(icon,action);
	return 0;
}

void do_all_icon(int type_id, int action)
{
	I2T	ic;
	int	i;

	ic = i2t;
	for (i=MAX_ICON_ANZ; (--i)>=0; ic++)
		if (ic->icon!=-1 && (ic->type_id==type_id || type_id==ALL_TYPES))
		{
			do_icon(ic->icon, action);
		}
}

bool icon_test(int icon, int action)
{
	TYPEP	t;

	t = search_type(icon);
	if (t!=NULL)
		return (t->test)(icon,action);
	return FALSE;
}

int icon_edit(int icon, int action)
{
	TYPEP	t;

	t = search_type(icon);
	if (t!=NULL)
		return (t->edit)(icon,action);
	return 0;
}

void icon_exist(int icon, SET actions)
{
	TYPEP	t;

	t = search_type(icon);
	if (t==NULL || t->exist==NULL)
		setclr(actions);
	else (t->exist)(icon,actions);
}

bool icon_drag(int dest_obj, int src_obj)
{
	TYPEP	t;

	t = search_type(dest_obj);						/* Ziel-Icon */
	if (t==NULL || t->drag==NULL) return FALSE;
	return((t->drag)(dest_obj,src_obj));
}

int decl_icon_type(bool(*test)(int,int),
						 int(*edit)(int,int),
						 void(*exist)(int,SET),
						 bool(*drag)(int,int))
{
	TYPEP	t;

	if (type_anz==MAX_TYPE_ANZ)
		inote(1, 0, FATALERR, 12);
	t = icon+type_anz;
	t->exist	= exist;
	t->test	= test;
	t->edit	= edit;
	t->drag	= drag;
	type_anz++;
	return (type_anz-1);
}

bool add_icon(int type_id, int obj_nr)
{
	int	i;
	I2T	ic;

	ic = i2t;
	for (i=MAX_ICON_ANZ; (--i)>=0; ic++)
		if (ic->icon==-1)
		{
			ic->icon = obj_nr;
			ic->type_id = type_id;
			return TRUE;
		}
	return FALSE;
}

void del_icon(int obj_nr)
{
	I2T	ic;
	int	i;

	ic = i2t;
	for (i=MAX_ICON_ANZ; (--i)>=0; ic++)
		if (ic->icon==obj_nr)
		{
			ic->icon = -1;
			return;
		}
	inote(1, 0, FATALERR, 1);
}

int icon_anz(int type_id)
{
	I2T	ic;
	int	i, anz;

	anz = 0;
	ic = i2t;
	for (i=MAX_ICON_ANZ; (--i)>=0; ic++)
		if (ic->type_id==type_id || type_id==ALL_TYPES)
			anz++;
	return anz;
}

void init_icon(void)
{
	int	i;
	I2T	ic = i2t;

	for (i=MAX_ICON_ANZ; (--i)>=0; ic++)
		ic->icon = -1;
}
