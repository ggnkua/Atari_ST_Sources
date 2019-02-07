/*
 * Hard Disk partition copier
 *
 * by Dave Small and Dan Moore
 * Copyright 1988 Antic Publishing, Inc.
 *
 * copy one HD partition to another.
 *
 * BE VERY CAREFUL WITH THIS!!!!!
 *
 * dlm --- 09/14/87
 *
 * dlm --- 11/22/88	added a useable front end for START
 *
 */
#include <portab.h>
#include <osbind.h>
#include <stdio.h>

#define DEBUG		0		/* print numbers, no i/o */
#define REAL		1		/* copy code enabled? */

/*
 * More external routines.  These are the DMA buss i/o routines
 * that Supra uploaded to the Developers Forum on Compuserve (PCS 57)
 *
 * Dave and I would like to thank Supra for releasing the source
 * code to these routines.
 *
 */
extern int nhd_read();
extern int nhd_write();

#define BUF_SECS (127)
#define BUF_SIZE (512L * BUF_SECS)

 /* the backup buffers and variables */ 
long	hd_buff;		/* our disk i/o buffer			*/

/*
 * globals
 */
int	src_device, dst_device;		/* SCSI device to use		*/
int	src_unit, dst_unit;		/* logical unit on device	*/
long    src_sector, dst_sector;
long    copy_len;

/*
 * the actual, magical hard disk partition copier.
 * the program no one can live without.
 */
int
do_copy()
{
	register unsigned int  sec_count, stat;
	register unsigned long curr_sec;
	register unsigned long total_sectors;
	int error = 0, pass = 0;

	total_sectors = copy_len - 1;	/* how many to dup */
	sec_count     = BUF_SECS;

	/* now do the copy.  */
	for (curr_sec = 0; curr_sec < total_sectors && sec_count; curr_sec += sec_count, pass++) {

		/* adjust number of sectors if nearing the end of the copy */
		if (curr_sec + sec_count >= copy_len)
			sec_count = copy_len - curr_sec - 1;

		if (pass % 8 == 0) {
			printf("Now reading sector %ld\n", curr_sec + src_sector);
		}

		/* nhd_read(sectno.L,count.W,buff.L,dma.W) */
#if DEBUG
		printf("read sector: %ld to %ld \n", curr_sec + src_sector, curr_sec + sec_count + src_sector);
		stat = 0;
#else
		stat = nhd_read(curr_sec + src_sector, sec_count, hd_buff, src_device, src_unit);
#endif
		if (stat) {
			printf("READ ERROR! At sector %ld.\n", curr_sec + src_sector);
			error = 1;
			break;
		}

#if DEBUG
		printf("\twrite sector: %ld to %ld\n", curr_sec + dst_sector, curr_sec + sec_count + dst_sector);
		stat = 0;
#else
		stat = nhd_write(curr_sec + dst_sector, sec_count, hd_buff, dst_device, dst_unit);
#endif
		if (stat) {
			printf("WRITE ERROR! At sector %ld.\n", curr_sec + dst_sector);
			error = 1;
			break;
		}
	}
	return (error);
}

void
get_long(prompt, variable, min, max)
char *prompt;
long *variable;
long  min, max;
{
	char   input[80];
	register long temp;
	extern long atol();

	do {
		printf(prompt);
		gets(input);
		temp = atol(input);
	} while (temp > max || temp < min);

	*variable = temp;
}

void
get_int(prompt, variable, min, max)
char *prompt;
int  *variable;
int  min, max;
{
	long temp;
	get_long(prompt, &temp, (long) min, (long) max);
	*variable = (int)temp;
}

main()
{
	char input[80];

	setbuf(stdout, NULL);	/* unbuffered output */
	setbuf(stdin, NULL);	/* unbuffered input */

	puts("\t\tHard Disk Partition Copier");
	puts("\t\tby Dan Moore and Dave Small");
	puts("\t\tCopyright (c) 1988 by Antic Publishing\n\n");

	if ((hd_buff = Malloc(BUF_SIZE)) == NULL) {
		puts("Unable to allocate work buffer\nRETURN to exit.");
		getchar();
	}	

	do {

		get_int("Enter source SCSI device: ", &src_device, 0, 7);
		get_int("Enter source SCSI unit: ", &src_unit, 0, 1);
		get_long("Enter starting sector: ", &src_sector, 0L, 0x7fffffffL);
		get_int("Enter destination SCSI device: ", &dst_device, 0, 7);
		get_int("Enter destination SCSI unit: ", &dst_unit, 0, 1);
		get_long("Enter destination sector: ", &dst_sector, 0L, 0x7fffffffL);
		get_long("Enter length: ", &copy_len, 1L, 0x7fffffffL);

		printf("\n\nSOURCE: device %d\tlun %d\tsector %ld\n", src_device, src_unit, src_sector);
		printf("DEST:   device %d\tlun %d\tsector %ld\n", dst_device, dst_unit, dst_sector);
		printf("copy length %ld\n\n", copy_len);

		printf("If you have ANY doubts DO NOT CONTINUE!!\n");
		printf("An incorrect copy can DESTROY the data on your drive!!\n\n");
		printf("Type \"yes\" to copy sectors: ");
		gets(input);

		if (strcmp(input, "yes") == 0) {
#if REAL
			if (!do_copy())	/* do it toit */
				puts("It won.\n");
			else
				puts("It lost.\n");
#else
			puts("copy code goes here!");
#endif
		}

		printf("\n\nType \"quit\" to exit: ");
		gets(input);

	} while(strcmp(input, "quit"));

	Mfree(hd_buff);
}
