/* Test driver calls */

#include	"osbind.h"
/*
#include	"nuosbind.h"
#include	"getstart.h"
/**/

char	buf[512*274];
int	x = 1;

main()
{
	/*
	char	buf[512], bbuf[512];
	int	i;
	long	srchndl, dsthndl, ret;
	/**/

/*
	for (i = 0; i < 512*3;) {
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
	Rwabs(1, buf+1, 3, 102, 3);
	Rwabs(0, buf, 3, 102, 3);
	Rwabs(9, bbuf, 1, 0, 11);
	Rwabs(8, bbuf, 1, 0, 11);
	Rwabs(9, bbuf, 1, 0, 11);
	char	*buf256;
	
	buf256 = (char *)Malloc(131072L);
	Rwabs(8, buf256+1, 2, 0, 18);
	Rwabs(9, buf256+1, 2, 0xa35a, 18);
/**/
/*
	Rwabs(8, buf256+1, 255, 0, 10);
	Rwabs(9, buf256+1, 255, 0, 10);
/**/
	Fsfirst("h:\\*.*", 0);
	
	while (!(Cconis()))
		;

	Fsfirst("g:\\*.*", 0);
	Fsfirst("h:\\*.*", 0);
	Pterm(0);
}
