#include <ec_gem.h>

#include "io.h"
#include "ioglobal.h"

void spec_funcs(void)
{
	OBJECT 	*tree;
	int			ob;
	
	rsrc_gaddr(0, SPECFUNC, &tree);
	tree[MAKENEWRED].ob_state &= (~SELECTED);
	tree[SPECCLOSE].ob_state &= (~SELECTED);
	
	lock_menu(omenu);
	ob=w_do_dial(tree);
	unlock_menu(omenu);
	
	switch(ob)
	{
		case MAKENEWRED:
			form_alert(1, gettext(DOSPECFUNC));
		break;
	}
}