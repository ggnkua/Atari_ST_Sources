#include	<stdio.h>
#include	<stdlib.h>

extern	long	cdecl	pcr2l(long pcr);
extern	long	cdecl	l2pcr(long pcr);

int	main(int argc, char **argv)
{	int		i;
	long	t0,t1,t2,t3,t4;
	if	(argc < 2)
	{	puts("You should enter some numbers to test conversion.");
		puts("Please restart the program with arguments.");
	}
	for	(i=1; i<argc; i++)
	{	t0 = atol(argv[i]);
		t1 = l2pcr(t0);		t3 = pcr2l(t1);
		t2 = pcr2l(t0);		t4 = l2pcr(t2);
		printf("Test argument %d:\r\n",i);
		printf("  long= %08lx ==> pcr = %08lx ==> long= %08lx\r\n",t0,t1,t3);
		printf("  pcr = %08lx ==> long= %08lx ==> pcr = %08lx\r\n",t0,t2,t4);
	}	/* end for(i...) */
	puts("Hit <Return> to exit!");
	getchar();
	return 0;
}	/* End func main(argc, char **argv)	*/

/*	End of file:	TST_CONV.C	*/