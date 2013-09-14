#include <osbind.h>
#include <stdio.h>
#include <stat.h>
#include <bios.h>

extern int errno;

struct disk_info {
	unsigned long di_free; /* free allocation units */
	unsigned long di_many; /* how many AUs on disk */
	unsigned long di_ssize;/* sector size - bytes per sector*/
	unsigned long di_spau; /* sectors per AU */
};

main()

{

	int hand1, hand2;
	int i, status;
	char *buffer, *tmp;
	long copysize, rdsize, wrsize;
	long fsect;
	long fbyte;
	long tsect;
	long tbyte;
	int dd;
	struct disk_info dev;
	struct bpb *bp;

	DMABUFFER mydta;

	bp = (struct bpb *) Getbpb(2);
	dd = Dgetdrv();	 /*the current partition, C is 2 */

	/*add 1, because the Dfree thinks drive C is 3*/
	/*
	Dfree(&dev, dd+7);
	*/
	Dfree(&dev, dd+3);	
	fsect = dev.di_free*dev.di_spau;
	tsect = dev.di_spau*dev.di_many;
	fbyte = fsect*dev.di_ssize;
	tbyte = tsect*dev.di_ssize;
	/*
	if ((hand1 = Fopen("a:\\memtst1.c", 0)) < 0) 	{
		fprintf(stderr, "\nCan't open input file.");
		errno = -hand1;
		perror("Fopen failed");
		Pterm(1);
	}
	if ((hand2 = Fopen("c:\\memtst1.cb", 1)) < 0) 	{
		fprintf(stderr, "\nCan't open input file.");
		errno = -hand2;
		perror("Fopen failed");
		Pterm(1);
	}
	Fsetdta(mydta=(struct DMABUFFER *)malloc(sizeof(struct DMABUFFER)));
	Fsetdta(&mydta);

	if ((status=Fsfirst("a:\\memtst1.c", 0xf7)) != 0)	{
		Fclose(hand1);
		fprintf(stderr,"\nError getting stats on input file.");
		errno = -status;
		perror("Fopen failed");
		Pterm(1);
	}

	status = mydta.d_fattr & 7;
	*/
	status = 0x00;
	if ((hand2=Fcreate("c:\\memtst1.cmm", status)) < 0)	{
		/*
		Fclose(hand1);
		*/
		fprintf(stderr, "\nCan't creat a test file.");
		errno = -hand2;
		perror("Fcreat failed");
		Pterm(1);
	}
	buffer = (char *)malloc(4096);
	tmp = buffer;
	for (i=0; i < 4095; i++)	{
		*tmp++ = 'F';
	}
	*tmp = '0';

	/*
	rdsize = mydta.d_fsize;
	*/

	wrsize = fbyte + 2*512;
	copysize = wrsize;
	while(copysize > 4096)	{
		/*
		if ((status=Fread(hand1, 4096L, buffer)) < 0)	{
			Fclose(hand1);
			Fclose(hand2);
			Fdelete("memtst1.cmm");
			fprintf(stderr, "\nRead error on test file");
			errno = -status;
			perror("Read failure");
			Pterm(1);
		}
		*/
		if ((status=Fwrite(hand2, 4096L, buffer)) < 0)	{
			Fclose(hand1);
			Fclose(hand2);
			Fdelete("memtst1.cmm");
			fprintf(stderr, "\nWrite error on test file");
			errno = -status;
			perror("Write failure");
			Pterm(1);
		}
		copysize -= 4096;
	}
	if (copysize > 0)	{
		/*
		if ((status=Fread(hand1, copysize, buffer)) < 0)	{
			Fclose(hand1);
			Fclose(hand2);
			Fdelete("memtst1.cmm");
			fprintf(stderr, "\nRead error on test file");
			errno = -status;
			perror("Read failure");
			Pterm(1);
		}
		*/
		if ((status=Fwrite(hand2, copysize, buffer)) < 0)	{
			Fclose(hand1);
			Fclose(hand2);
			Fdelete("memtst1.cmm");
			fprintf(stderr, "\nWrite error on test file");
			errno = -status;
			perror("Write failure");
			Pterm(1);
		}
		/*
		if ((status=Rwabs(1, buffer, 2060, 3, 2)) < 0)	{
			Fclose(hand1);
			Fclose(hand2);
			Fdelete("memtst1.cmm");
			fprintf(stderr, "\nWrite error on test file");
			errno = -status;
			perror("Write failure");
			Pterm(1);
		}
		*/
	}
	/*
	Fclose(hand1);
	printf("Test file was created\n");
	Fsetdta(NULL);
	*/
	Fclose(hand2);
	Pterm0();
}
