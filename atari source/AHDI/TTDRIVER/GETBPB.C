/* Test driver calls */

#include	"osbind.h"
#include	"getstart.h"


main()
{
	int	i;
	BPB*	blk;
	long	changed;
	int	drv, ret;

	for (i = 2; i < 8; i++) {
		drv = 'A' + i;
		Cconout(drv);
		/*
		if (changed = Mediach(i)) {
			ret = (int)changed + '0';
			Cconws(" -- Medium has been changed -- ");
			Cconout(ret);
			Cconws("\r\n");
		/**/
			blk = (BPB *)Getbpb(i);
		/*
		} else {
			Cconws(" -- Medium has not changed\r\n");
		}
		/**/
	}
	Pterm0();
}
