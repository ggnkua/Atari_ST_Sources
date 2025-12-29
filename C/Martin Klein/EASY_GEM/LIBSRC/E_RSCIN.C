#include <tos.h>
#include <aes.h>
#include <easy_gem.h>

void rsc_init(char *fn,void (*fkt)())
{
	if(open_vwork())
	{
		if(rsrc_load(fn))
		{
			graf_mouse(ARROW,0L);
			(*fkt)();
			rsrc_free();
		}
		else
		{
			Cconws("\nRSC-File konnte nicht geladen werden !!!");
			Cconws("\n\n >>> TASTE <<<");
			Crawcin();
		}
		close_vwork();
	}
	else
	{
		Cconws("\nEs konnte keine virtuelle Workstation ge”ffnet werden !!!");
		Cconws("\n\n >>> TASTE <<<");
		Crawcin();
	}
}