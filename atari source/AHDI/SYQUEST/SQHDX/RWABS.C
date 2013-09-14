/* Test driver calls */

#include	"osbind.h"
#include	"nuosbind.h"
#include	"getstart.h"

main()
{
	char	buf[512], bbuf[512];
	int	i;

/*	
	for (i = 0; i < 512;) {
		buf[i++] = 'M';
		buf[i++] = 'I';
		buf[i++] = 'N';
		buf[i++] = 'O';
	}

/**/	
	/* physical operation on unit 0 */
/*
	Lrwabs(9, buf, 1, 0x10000, 2);
	Lrwabs(8, bbuf, 1, 0x10000, 3);
/**/	
	/* logical operation on D: */
/*
	i = 1;
	while (i == 1) {
		Mediach(3);
		Getbpb(3);
		Rwabs(1, buf, 1, 0x700, 3);
	}
/**/	
/*
	Lrwabs(0, bbuf, 1, 0x10000, 3);
/**/
	Rwabs(8, bbuf, 1, 0, 2);
	Rwabs(9, bbuf, 1, 0, 2);
	Pterm(0);
}
