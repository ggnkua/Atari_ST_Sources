
/* MiniDemo (PRG): einfaches Dialog-Beispiel */

#include <e_gem.h>

void main()
{
	char *md="MiniDemo";
	if (open_rsc("minidemo.rsc",NULL,md,md,"MINIDEMO",0,0,0)==TRUE)
	{
		OBJECT *dia;
		rsrc_gaddr(R_TREE,0,&dia);
		fix_objects(dia,NO_SCALING,0,0);
		ob_clear_edit(dia);
		xdialog(dia,md,NULL,NULL,DIA_MOUSEPOS,FALSE,AUTO_DIAL);
		close_rsc(TRUE,0);
	}
	exit(-1);
}
