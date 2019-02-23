/***********************************************************
SBOINK Image Tester by Samuel Streeper
(C) Copyright 1990 by Antic Publishing, Inc.

IMGTEST.C:
	This program dumps an 80 byte wide region of the
	monochrome boink ball image to the monochrome monitor.
************************************************************/

#include <osbind.h>

char temp[10000];
int rez;

main()
{	register int fd, i, j;
	register char *ptr1, *ptr2;

	Cconws("\033E\n\n\n\n\n\n\n\n\n\n");

	rez = Getrez();
	if (rez != 1 && rez != 2)
	{
		Cconws("Only runs in medium and high resolution\r\n");
		Cconin();
		return;
	}

	if (rez == 2)
	{
		fd = Fopen("boink.im3",0);
		if (fd > 0)
		{	Fread(fd,10000L,temp);
			Fclose(fd);
		}
		else
		{
			Cconws("BOINK.IM3 data file not found!\r\n");
			Cconin();
			return;
		}

		ptr1 = (char *)Physbase();
		ptr2 = temp;

		for (i=0; i<102; i++)
		{
			for(j=0; j<80; j++) *ptr1++ = *ptr2++;
			ptr2 += 14;
		}
	}
	else		/* medium rez */
	{
		fd = Fopen("boink.im2",0);
		if (fd > 0)
		{	Fread(fd,10000L,temp);
			Fclose(fd);
		}
		else
		{
			Cconws("BOINK.IM2 data file not found!\r\n");
			Cconin();
			return;
		}

		ptr1 = (char *)Physbase();
		ptr2 = temp;

		for (i=0; i<50; i++)
		{
			for(j=0; j<160; j++) *ptr1++ = *ptr2++;
			ptr2 += 28;
		}
	}

	Cconws("Press a key...");
	Cconin();
}
