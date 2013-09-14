extern	long	bios();
#define	Lrwabs(a,b,c,d,e)	bios(4,a,b,c,-1,e,d)

char buf[512*63];

main()
{
	int i;
	long recno;
	
	for (i = 0; i < 512*63; i++)
	{
		buf[i] = 0;
	}
	
	for (recno = 0x2L; recno < 0x152aaL; recno += 0x3fL)
	{
		Lrwabs(9, buf, 0x3f, recno, 2);
	}
}
