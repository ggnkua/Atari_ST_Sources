/* ------------------------------------------------------------------------- */
/* ----- Let 'em Fly!  form_do() Sample ------------------------------------ */
/* ------------------------------------------------------------------------- */

#include <aes.h>
#include <tos.h>

#include <ltmf_lib.h>

#define	TRUE	(!0)

/* ------------------------------------------------------------------------- */

#define FMD_BACKWARD	-1
#define FMD_FORWARD	1
#define FMD_DEFLT	0

int find_obj(OBJECT *tree, int start_obj, int which)
{
	int	obj,
		flag, theflag,
		inc;

	obj = 0;
	flag = EDITABLE;
	inc = 1;
	switch(which)
	{
	    case FMD_BACKWARD :	inc = -1;
	    case FMD_FORWARD  :	obj = start_obj + inc;
	    			break;
	    case FMD_DEFLT    :	flag = DEFAULT;
				break;
	}
	while(obj >= 0) 
	{
		theflag = tree[obj].ob_flags;
		if(theflag & flag)
			return(obj);
		if (theflag & LASTOB)
			obj = -1;
		else
			obj += inc;
	}
	return(start_obj);
}

int fm_inifld(OBJECT *tree, int start_fld)
{
	if(start_fld == 0)
		start_fld = find_obj(tree, 0, FMD_FORWARD);
	return(start_fld);
}

/* ------------------------------------------------------------------------- */

int my_form_do(OBJECT *tree, int start_fld, int *msg)
{
	int	edit_obj,
		next_obj,
		which, cont,
		idx = 0,
		mx, my, mb, ks, kr, br;
	int	keys,
		kb_obj;

	next_obj = fm_inifld(tree, start_fld);
	keys = init_keys(tree);
	edit_obj = 0;
	cont = TRUE;
	while(cont)
	{
		if((next_obj != 0) && (edit_obj != next_obj))
		{
			edit_obj = next_obj;
			next_obj = 0;
			objc_edit(tree, edit_obj, 0, &idx, ED_INIT);
		}
		which = evnt_multi(MU_KEYBD|MU_BUTTON,
				0x02, 0x01, 0x01,
				0, 0, 0, 0, 0,
				0, 0, 0, 0, 0,
				msg,
				0, 0,
				&mx, &my, &mb, &ks, &kr, &br);
		if(which & MU_KEYBD)
		{
			kb_obj = keys ? lookup_key(kr, ks) : 0;
			if(kb_obj)
				cont = form_button(tree, kb_obj, 0x01, &next_obj);
			else
			{
				cont = form_keybd(tree, edit_obj, next_obj, kr, &next_obj, &kr);
				if(kr)
					objc_edit(tree, edit_obj, kr, &idx, ED_CHAR);
			}
		}
		if(which & MU_BUTTON)
		{
			next_obj = objc_find(tree, ROOT, MAX_DEPTH, mx, my);
			if(next_obj == -1)
			{
				Bconout(2, 7);
				next_obj = 0;
			}
			else if((tree[next_obj].ob_flags & 0xff) == NONE)
			{
				di_fly(tree);	/* Let 'em Fly! */
				next_obj = 0;
			}
			else
				cont = form_button(tree, next_obj, br, &next_obj);
		}
		if((!cont) || ((next_obj != 0) && (next_obj != edit_obj)))
			objc_edit(tree, edit_obj, 0, &idx, ED_END);
	}
	return(next_obj);
}
