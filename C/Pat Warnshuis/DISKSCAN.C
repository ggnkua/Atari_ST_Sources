/*  DISKSCAN.C  scans sectors and selectively writes them to
				a named file to recover trashed directory
	Pat Warnshuis 1-503-246-3724
	10/10/85
*/

#include <stdio.h>
#include <vt52.h>
#include <pats.h>

#define READ	  0
#define ADRIVE    0
#define SECSIZE   512
#define CNT 	  2
#define FALSE     0
#define TRUE	  !FALSE

short int  sect, bytecnt, more;
char  buff[CNT*SECSIZE], filename[17];
FILE  *fp;

main()
{
	bytecnt = 0;

	setup();
	more = TRUE;
	while( more  && (bytecnt < 4096) )
	{
		readsectors();
		more = action();
	}
	fclose(fp);
	exit();
}

setup()
{
	short int i, stat;

	printf("%s\n\nInsert bad diskette in drive A:\n", CLR_SCRN);
	printf("\nEnter starting sector number: ");
	scanf("%hd", &sect);
	strcpy(filename, "H:");
	get_line("\nEnter name of output drive: ", filename, 3);
	strcat(filename, "JUNK");
	get_line("\nEnter name of output file: ", filename, 15);

	if( (fp = fopen(filename, "w")) == NULL )
		{
		printf("\nCannot open %s\n", filename);
		exit();
		}
}

readsectors()
{
	short int  i;
	char  ch;

	rwabs(READ, buff, CNT, sect, ADRIVE);
	sect += CNT;
	puts(CUR_OFF);
	for( i = 0 ; i < CNT*SECSIZE ; i++)
		if( isascii( ch=buff[i]) )
			putchar(ch);
	printf("%s\n", CUR_ON);
}

action()
{
	short int  i;
	char  ch;

	puts(CLR_EOP);
	printf("%sfilename: %s   filesize: %d   last sector read: %d   \n",
		   REV_VID, filename, bytecnt, sect);
	printf("SPACE=save   X=save & exit   ANY_OTHER=skipit   Select: %s",
		   NOR_VID);
	ch = toupper(necin());
	putchar('\n');

	if( (ch == SPC) || (ch == 'X') )
		{
/*  								*/
debug("\nwriting sectors to fp");
/*  								*/

			for( i = 0; i < CNT*SECSIZE; i++ )
				fputc(buff[i], fp);
			bytecnt += 1024;

/*  								*/
/* fputc() crashes to GEM desktop   */
/*  								*/
/* really want fwrite() but.... 	*/
/* fwrite(buff, 1024, fp) crashes   */
/* fwrite(buff,1,1024,fp) crashes   */
/*   see tstfio.c   				*/

		}
	return( more = ( ch == 'X' ) ? FALSE : TRUE );
}

debug(s) char *s;
{ printf("\n%s....Any key...\n"); necin(); }
