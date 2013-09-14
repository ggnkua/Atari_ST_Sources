
/* speed.c */

/* test the speet of the hard disk by read from the hard disk. */

#include <osbind.h>
#include <stat.h>
#include <stdio.h>

/* "DMA" buffer structure for Fsfirst() and Fsnext().	*/

/*
typedef struct {
	char	d_glob[12];	 GEMDOS wildcard string from Fsfirst
	char	d_mask;		 Attribute mask from Fsfirst 
	char	d_dirent[4];	 Offset into directory, MSB first 
	char	d_dirid[4];	 Pointer to directory structure in GEM mem
	char	d_fattr;	 File attributes 
	long	d_tandd;	 Time and date words 
	long	d_fsize;	 File size 
	char 	d_fname[14];	 File name 
} DMABUFFER;
*/


/*	Main entrance of the file operation function	*/



main(argc, argv)
int argc;
char *argv[];

{

	int 	inhand;
	DMABUFFER *mydta;
	char 	*buffer, *saved;
	long 	copysiz, bufsiz, tmpsiz; 
	unsigned int time1, time2;
	int tem;

	if (argc != 2)	{
		printf("Usage: fast filename\n");
		goto end;
	}
	if ((inhand = Fopen(argv[1], 0)) < 0)	
	{
	  if ((inhand == 0xFFFA) || (inhand == 0xFFFE))/* seek error or */	
			printf("Seek error.\n");
	  goto end;
	}
	saved = (DMABUFFER *)Fgetdta();
	Fsetdta(mydta=(DMABUFFER *)Malloc((long)sizeof(DMABUFFER)));

	if (Fsfirst(argv[1], 0xF7))	{
		printf("Error.\n");
		goto end;
	}
	bufsiz = (long )Malloc(-1L);
	buffer = (char *)Malloc(bufsiz);
	copysiz = mydta->d_fsize;
	tem = (copysiz/512)/2048;
	printf("%s %d %s", "The reading time for", tem,
					"Mb is: "); 
	time1 = Tgettime();		/* get the system time */
	while (copysiz > 0)	
	{
	  tmpsiz = (copysiz > bufsiz) ? bufsiz : copysiz;
	  if (Fread(inhand, tmpsiz, buffer) < 0)	{	
	  	printf("read error.\n");
		goto end;
	  }
		copysiz -= bufsiz;
	}
	time2 = Tgettime();		/* get the system time */
	conver(time1, time2);


end:
	Mfree(buffer);
	Fsetdta(saved);
	Fclose(inhand);
	Mfree(mydta);
	return;
}



conver(time1, time2)

unsigned int time1, time2;

{

	int seconds1, minutes1;
	int seconds2, minutes2, result;
	long hours1, hours2, totsec1, totsec2;

	seconds1 = (time1 & 0x001F) << 1;	/* bits 0:4*/
	minutes1 = (time1 >> 5) & 0x3F;		/* bits 5:10 */
	hours1   = (time1 >> 11) & 0x1F;		/* bits 11:15 */

	totsec1 = hours1 * 3600 + minutes1 * 60 + seconds1;

	seconds2 = (time2 & 0x001F) << 1;	/* bits 0:4*/
	minutes2 = (time2 >> 5) & 0x3F;		/* bits 5:10 */
	hours2   = (time2 >> 11) & 0x1F;		/* bits 11:15 */

	totsec2 = hours2 * 3600 + minutes2 * 60 + seconds2;
	result = totsec2 - totsec1;

	printf("%d %s\n", result, "seconds.");
}

