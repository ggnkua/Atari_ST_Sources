#include <ec_gem.h>
#include "io.h"
#include "ioglobal.h"


char *gettext(int ob)
{
	OBJECT *text_tree;
	
	rsrc_gaddr(0, STRINGS, &text_tree);
	return(text_tree[ob].ob_spec.free_string);
}

/* -------------------------------------- */

int getlen(int ob)
{
	OBJECT *tree;
	
	rsrc_gaddr(0, VORLAGE, &tree);
	return(tree[ob].ob_width);
}

/* -------------------------------------- */

OBJECT *getob(int ob)
{
	OBJECT *tree;
	
	rsrc_gaddr(0, VORLAGE, &tree);
	return(&(tree[ob]));
}

/* -------------------------------------- */

void clear_sort_obs(void)
{
	menu_icheck(omenu, MVFROM, 0);
	menu_icheck(omenu, MVSUBJ, 0);
	menu_icheck(omenu, MVDATE, 0);
	odial[ABSSORT].ob_flags |= HIDETREE;
	odial[BTRSORT].ob_flags |= HIDETREE;
	odial[DATSORT].ob_flags |= HIDETREE;
}

/* -------------------------------------- */

void clear_view_obs(void)
{
	menu_icheck(omenu, MVALLE, 0);
	menu_icheck(omenu, MVSNDSNT, 0);
	menu_icheck(omenu, MVSND, 0);
	menu_icheck(omenu, MVSNT, 0);
	menu_icheck(omenu, MVNEWRED, 0);
	menu_icheck(omenu, MVRED, 0);
	menu_icheck(omenu, MVNEW, 0);
}