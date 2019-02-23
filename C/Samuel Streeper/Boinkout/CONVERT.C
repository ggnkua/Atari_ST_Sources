/***************************************
	convert.c

The file bout2.pi3 contains the monochrome
images used in boinkout. This program converts
a high res degas picture to 2 medium res pictures,
one for the even scan lines and one for the odd scan
lines of the original.  (half the resolution is lost
going to medium res, and for each animation you can
pick the half that looks better). The reason I use
this program instead of degas' conversion is this
one doesn't attempt anti-aliasing: The resulting
medium res picture is just black and white.
***************************************/

#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include <math.h>

int buf1[16500], buf2[16500], buf3[16500];

#define TRUE 1
#define FALSE 0

/* A degas file header... */
int junk[] = 
	{
	0x0001,
	0x0777,
	0x0700,
	0x0070,
	0x0000,
	0x0777,
	0x0700,
	0x0070,
	0x0770,
	0x0007,
	0x0707,
	0x0077,
	0x0555,
	0x0333,
	0x0733,
	0x0373,
	0x0773
	};

main()
{
	register int *ptr1, *ptr2;
	int *ptr3;
	register int i,j,xhand;

	Cconws("\033E");

	xhand = Fopen("bout2.pi3",0);
	if (xhand > 0)
	{
		Fread(xhand,(long)34L,buf1);
		Fread(xhand,(long)32000L,buf1);
		Fclose(xhand);
	}
	else Cconws("read error\r\n");

	ptr1 = buf1;
	ptr2 = buf2;

	for (i=0; i<200; i++)
	{
		for (j=0;j<40;j++)
		{
			*ptr2++ = *ptr1;
			*ptr2++ = *ptr1++;
		}
		ptr1 += 40;
	}

	ptr1 = buf1;
	ptr3 = buf3;

	for (i=0; i<200; i++)
	{
		ptr1 += 40;
		for (j=0;j<40;j++)
		{
			*ptr3++ = *ptr1;
			*ptr3++ = *ptr1++;
		}
	}

	xhand = Fcreate("bouteven.pi2",0);
	if (xhand > 0)
	{
		Fwrite(xhand,(long)34L,junk);
		Fwrite(xhand,(long)32000L,buf2);
		Fclose(xhand);
	}
	else Cconws("create error\r\n");

	xhand = Fcreate("boutodd.pi2",0);
	if (xhand > 0)
	{
		Fwrite(xhand,(long)34L,junk);
		Fwrite(xhand,(long)32000L,buf3);
		Fclose(xhand);
	}
	else Cconws("create error\r\n");
	Cnecin();
}
