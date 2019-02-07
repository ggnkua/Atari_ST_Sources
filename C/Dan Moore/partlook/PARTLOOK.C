/*
 * Hard disk partition stat program.
 *
 * Dumps misc. stats from the hard disk partition sector:
 *	partition type
 *	partition start
 *	partition length
 *	bootable
 *	active
 *
 *
 * dlm -- October 4, 1988
 *
 */

#include <portab.h>
#include <osbind.h>
#include <stdio.h>

/* misc defines */
#define TRUE	1
#define FALSE	0

/*
 * More external routines.  These are the DMA buss i/o routines
 * that Supra uploaded to the Developers Forum on Compuserve (PCS 57)
 *
 * Dave and I would like to thank Supra for releasing the source
 * code to these routines.
 *
 */
extern nhd_read();
extern nhd_write();
extern nhd_sense();

/*
 * structure defining misc. HD params.
 *
 * NOTE: not all hard disk formatting programs write this to the
 *       partition sector, so the values may be zero or bogus.
 */
typedef struct hd_info {
	WORD  cylinders;
	BYTE  heads,
	      res1;
	WORD  rwcc,
	      wpc;
	BYTE  land,
	      seekrate,
	      interleave,
	      spt;
	LONG  size;
} HDI, *HDI_PTR;

/*
 * structure defining a single hard disk partition
 */
typedef struct hd_part {
	LONG  id;	
	LONG  start;
	LONG  size;
} HDP, *HDP_PTR;

/*
 * location of info fields in the partition sector
 */
#define PART_BASE	0x1c6	/* start of the 4 standard partitions */
#define STAT_BASE	0x1b6	/* start of the hard disk stat table  */
#define EXT_BASE	0x156	/* start of the 8 extended partitions */


BYTE  hd_buff[512];	/* our disk i/o buffer			*/

void
dump_entry(n, i, hdp)
int n, i;
register HDP_PTR hdp;
{
	char type[6];		/* type string */
	char *boot = "";
	char *enable = "";

	/* 
	 * pull some magic and extract the first 3 chars of the type as
	 * a string.
	 */
	if (hdp[i].start) {	/* empty? */
		strncpy(type, ((char *)&hdp[i].id)+1, 3);
		type[3] = 0;
		if (hdp[i].id & 0x80000000L)
			boot = "bootable";
		if (hdp[i].id & 0x01000000L)
			enable = "enabled";
	}
	else
		type[0] = 0;

	/* number, start, size, type string, enabled/disabled, bootable */
	printf("%2d:\t%-7ld\t%-7ld\t%2ld\t%-5s\t%s\t%s\n",
		n, hdp[i].start, hdp[i].size,hdp[i].size / 2000L,
		type, enable, boot);
}

void
dump_hdinfo(device, unit)
int device, unit;
{
	HDI_PTR      hdi;
	HDP_PTR      hdp;
	register int i;

	printf("\n\n\nStats for device %d unit %d\n", device, unit);

	/*
	 * go read the partition sector from the drive.
	 * it is sector 0.
	 */

	/* secnum, count, buffer, dma device, dma lun */
	if (nhd_read(0L, 1, hd_buff, device, unit)) {
		printf("\tUnable to read partition sector!\n\n");
		return;
	}

	/*
	 * dump the info in the hard disk stat buffer.
	 * NOTE: This may be bogus since not all hard disk formatters
	 *       set these values.
	 * If the values look bogus then don't print anything.
	 */
	hdi = (HDI_PTR) (hd_buff + STAT_BASE);
	if (hdi->cylinders && hdi->heads && hdi->size) {
		printf("Hard disk format table:\n");
		printf("\tcylinders = %d\n",  hdi->cylinders);
		printf("\theads     = %d\n",  hdi->heads);
		printf("\tsize      = %ld\n", hdi->size);
	}

	/*
	 * There are two tables that give the partitions on a drive.
	 * The first one, at PART_BASE is the one Atari gave in the 
	 * "Hitch Hikers Guide to the BIOS".  There are 4 entries in
	 * that table.  The second table is an extension originally
	 * added by Supra.  It adds an additional 8 entries, allowing
	 * a total of 12 partitions on a drive.
	 */

	/* print the header for the dump */
	printf("\n\nPartition info:\n #\tstart\tsize\tmeg\ttype\n");

	hdp = (HDP_PTR) (hd_buff + PART_BASE);	/* the base 4 partitions */
	for (i = 0; i < 4; i++)
		dump_entry(i + 1, i, hdp);

	hdp = (HDP_PTR) (hd_buff + EXT_BASE);	/* the 8 extended partitions */
	for (i = 0; i < 8; i++)
		dump_entry(i + 5, i, hdp);

}

void
main()
{
	int device, unit;
	char input[80];

	setbuf(stdout, NULL);	/* unbuffered output */
	setbuf(stdin, NULL);	/* unbuffered input */

	puts("\t\tHard Disk Stat Program");
	puts("\t\tby Dan Moore and Dave Small");
	puts("\t\tCopyright (c) 1988 by Antic Publishing\n\n");

	do {
		do {
			printf("Enter SCSI device: ");
			gets(input);
			device = atoi(input);
		} while (device > 7 || device < 0);

		do {
			printf("Enter SCSI unit: ");
			gets(input);
			unit = atoi(input);
		} while (unit > 1 || unit < 0);

		dump_hdinfo(device, unit);

		printf("\nDump another? ");
		gets(input);
	} while (strcmp(input, "no"));
}
