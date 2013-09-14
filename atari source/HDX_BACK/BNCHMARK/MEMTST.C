#include <osbind.h>
#include <stdio.h>
#include <stat.h>

extern int errno;

struct disk_info {
	unsigned long di_free; /* free allocation units */
	unsigned long di_many; /* how many AUs on disk */
	unsigned long di_ssize;/* sector size - bytes per sector*/
	unsigned long di_spau; /* sectors per AU */
};

main()

{

	int hand;
	int status;
	char *buffer, *tmp;
	char buf[512];
	long copysize;
	long fsect;
	long fbyte;
	long tsect;
	long tbyte;
	int dd, i;

	struct disk_info dev;

	dd = Dgetdrv();	/* the current partition, C is 2 */

	Dfree(&dev, dd+1);	/* add 1, because the Dfree thinks drive C is 3*/
	fsect = dev.di_free*dev.di_spau;
	tsect = dev.di_spau*dev.di_many;
	fbyte = fsect*dev.di_ssize;
	tbyte = tsect*dev.di_ssize;

	if ((hand=Fcreate("c:\\tstfile.c", 0x00)) < 0)	{
		fprintf(stderr, "\nCan't creat a test file.");
		errno = -hand;
		perror("Fcreat failed");
		Pterm(1);
	}
	buffer = (char *)malloc(4096);
	tmp = buffer;
	for (i=0; i < 4095; i++)	{
		*tmp++ = '1';
	}
	*tmp = '0';

	copysize = fbyte + 3*dev.di_ssize;
	copysize = 512;

	while(copysize > 4096)	{
		if ((status=Fwrite(hand, 4096L, buffer)) < 0)	{
			Fclose(hand);
			Fdelete("tstfile");
			fprintf(stderr, "\nWrite error on test file");
			errno = -status;
			perror("Write failure");
			Pterm(1);
		}
		copysize -= 4096;
	}
	if (copysize > 0)	{
		if ((status=Fwrite(hand, copysize, buf)) < 0)	{
			Fclose(hand);
			Fdelete("tstfile");
			fprintf(stderr, "\nWrite error on test file");
			errno = -status;
			perror("Write failure");
			Pterm(1);
		}
	}
	Fclose(hand);
	printf("Test file was created\n");
}


