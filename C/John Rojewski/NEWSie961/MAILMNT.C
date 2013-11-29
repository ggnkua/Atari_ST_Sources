/*
 * mailmnt.c - reduce number of mailbox directories
 *             copy contents of daily mailbox directories into monthly directories
 *             daily directories look like: YYYYMMDD, monthly look like: YYYYMM
 *             all mailboxes containing renamed/moved mail must have the filepath updated
 *
 * Written: 04/26/99	John Rojewski
 * Updated: 05/03/99	Try using rename() when possible to eliminate copy_file() and remove()
 *
 */
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <osbind.h>
#include <dos.h>
#include <aes.h>
#include <vdi.h>
#include <sys\types.h>
#include <sys\stat.h>

/* global variables */
#define MAX_BOXES 200
#define MAX_DIRS 300

char *strtoka( char *s, int tok );		/* prototype */

short screenx,screeny,screenw,screenh;
int finished=0;
int handle;

long count,mcount,fcount,dcount;
long comp;
char boxes[3000],*pointers[MAX_BOXES];	/* room for 230 13-byte mailbox names */
char dirs[3000],*dpointers[MAX_DIRS];	/* room for 333 9-byte mail directory names */
int *dmpointers[MAX_DIRS];
int *drpointers[MAX_DIRS];	/* directory mail renamed files */
int updateboxes[MAX_BOXES];	/* which mailboxes need to be updated */
char dmail[10000];
char last[10];

struct mhdr {
	char subject[80];
	char from[80];
	char to[80];
	char reply_to[80];
	char datetime[40];
	char status[5];
} mail_hdr;

char program_path[FMSIZE];
char mail_path[FMSIZE]="D:\\MAIL";
char resource[FMSIZE];


/* strtok parsing option to returning a NULL string instead of a NULL pointer */
char *strtoka( char *s, int tok )
{
	static char *p;
	char *q;

	if (s!=NULL) { p=s; }	/* returns null strings vs null pointers */
	q=p;
	while (*p!=tok) {
		if (*p=='\0') { return(p); }	/* found end of string */
		p++;
	}
	*p='\0';	/* replace token with null char */
	p++;		/* next start point */
	return(q);	/* return start point */
}

void initialize(void)
{
	char temp[120]="[0][Mailmnt.prg  For NEWSie|Compress daily mail|Directories into Monthly |Directories.][Continue|Exit]";

	if (appl_init()<0)
		exit(EXIT_FAILURE);
	getcd( 0, program_path );
	wind_get(DESK,WF_WORKXYWH,&screenx,&screeny,&screenw,&screenh);
	graf_mouse(ARROW,NULL);

	if (form_alert( 1, temp )==1) {
		return;
	} else {
 		deinitialize(EXIT_FAILURE);
	}
}

void deinitialize(int status)
{
	appl_exit();
	exit( status );
}

/* Ask the user to find the Mail directory to be examined */
int get_mail_path(void)
{
	char path[FMSIZE],dirname[FMSIZE],select[FMSIZE],temp[80];
	int button;

	strcpy( select, "*.*" );
	sprintf( dirname, "%s\\%s", program_path, select );
	fsel_exinput( dirname, select, &button, "Locate MAIL Directory" );
	if (button) {
		stcgfp( path, dirname );
		strcpy( mail_path, path );
		sprintf( temp, "[0][Your Mail directory is:|%s][OK|Cancel]", mail_path );
		if (form_alert( 1, temp )==1) {	chdir( path ); } else { button=0; }
	}
	return(button);
}

void beep(void)
{
	printf( "%c", '\x07' );
}

/* Find and store all of the directories, and index them in the dpointers array */
long get_directories(void)
{
	char temp[80];
	long count,c,rcnt=0;

	count = getfnl("*", dirs, sizeof(dirs), FA_SUBDIR );
	if (count > 0) {
		if (strbpl(dpointers,MAX_DIRS,dirs)!=count) {
			sprintf( temp, "[2][You have more than |300 Directories][Stop]");
			form_alert( 1, temp );
 			deinitialize(EXIT_FAILURE);
		}
		strsrt( dpointers, count );	/* sort in ascending order */
		for (c=0;c<count;c++) {
			if (dpointers[c][0]=='.') { continue; }
			if ((dpointers[c][0]!='1')&&(dpointers[c][0]!='2')) { continue; }	/* non-century */
			rcnt++;
		/*	sprintf( temp, "[0][Checking Directory |%s][OK]", dpointers[c] ); */
		/*	form_alert( 1, temp ); */
		}
		if (rcnt==0) {
			count = rcnt;	/* counting only 1xxxxxxx or 2xxxxxxxx is zero */
		} else {
			sprintf( temp, "[0][You have %ld Mail Directories][OK]", rcnt );
			form_alert( 1, temp );
		}
	} else {
		if (_OSERR) {
			sprintf( temp, "[2][You have No Mail Directories][Stop]");
		} else {
			sprintf( temp, "[2][You have more than |300 Directories][Stop]");
		}
		form_alert( 1, temp );
 		deinitialize(EXIT_FAILURE);
	}
	return(count);
}

/* Find and store all of the mailboxes, and index them in the pointers array */
long get_mailboxes(void)
{
	char temp[80];
	long count;

	count = getfnl("*.mbx", boxes, sizeof(boxes), 0 );
	if (count > 0) {
		if (strbpl(pointers,MAX_BOXES,boxes)!=count) {
			sprintf( temp, "[2][You have more than |200 Mailboxes][Stop]");
			form_alert( 1, temp );
 			deinitialize(EXIT_FAILURE);
		}
		sprintf( temp, "[0][You have %ld Mailboxes][OK]", count );
		form_alert( 1, temp );
		strsrt( pointers, count );	/* sort in ascending order */
	} else {
		if (_OSERR) {
			sprintf( temp, "[2][You have No Mailboxes][Stop]");
		} else {
			sprintf( temp, "[2][You have more than |200 Mailboxes][Stop]");
		}
		form_alert( 1, temp );
 		deinitialize(EXIT_FAILURE);
	}
	return(count);
}

/* Count and remember the number of email messages in each directory and a total */
long get_directory_mail(void)
{
	int c,d,index;
	long count=0,mail_cnt=0;
	char temp[FMSIZE];
	char **dmptr;

	for (c=0;c<dcount;c++) {	/* for each directory */
		dmpointers[c] = NULL;
		drpointers[c] = NULL;
		if (dpointers[c][0]=='.') { continue; }
		if ((dpointers[c][0]!='1')&&(dpointers[c][0]!='2')) { continue; }	/* non-century */
		chdir( dpointers[c] );
		count = getfnl("mail*.txt", dmail, sizeof(dmail), 0 );
	/*	sprintf( temp, "[0][Directory %s has|%ld messages][OK]", dpointers[c], count ); */
	/*	form_alert( 1, temp ); */
		if (count > 0) {
			dmpointers[c] = calloc( count+1, sizeof(int) );	/* mail list */
			drpointers[c] = calloc( count+1, sizeof(int) );	/* renumbered mail list */
			dmptr = calloc( count+1, sizeof(size_t) );
			if ((dmpointers[c]==NULL)||(drpointers[c]==NULL)||(dmptr==NULL)) {
				sprintf( temp, "[2][Insufficient memory to |continue processing.][Stop]" );
				form_alert( 1, temp );
 				deinitialize(EXIT_FAILURE);
			}
			dmpointers[c][0] = (int)count;
			if (strbpl(dmptr,count+1,dmail)==count) {
				for (d=0;d<count;d++) {
					index = get_mail_index( dmptr[d] );
					dmpointers[c][d+1] = index;
				}
			}
			free( dmptr );
			mail_cnt += count;
		}
		chdir( mail_path );
	}
	sprintf( temp, "[0][You have %ld Directory messages][OK]", mail_cnt );
	form_alert( 1, temp );
	return(mail_cnt);
}

/* determine if a file in a directory has been renamed, return the orignal or new number */
int renamed_mail_file(char *directory, int number)
{
	int c,d;
	char temp[80];

	for (c=0;c<dcount;c++) {
		if (dpointers[c][0]=='.') { continue; }
		if (strncmp(directory, dpointers[c], 8)==0) {	/* if yyyymmdd directory found */
			if (dmpointers[c]!=NULL) {
				for (d=1;d<=dmpointers[c][0];d++) {
					if (dmpointers[c][d]==number) {
						if (drpointers[c][d]!=0) {
						/*	sprintf( temp, "[0][%s %04d -> %04d][OK]", dpointers[c], number, drpointers[c][d] ); */
						/*	form_alert( 1, temp ); */
							return(drpointers[c][d]);
						}
					/*	sprintf( temp, "[0][%s %04d found][OK]", dpointers[c], number ); */
					/*	form_alert( 1, temp ); */
						return(number);
					}
				}
				sprintf( temp, "[0][%s mail%04d.txt |Not found][OK]", dpointers[c], number );
				form_alert( 1, temp );
			}
			continue;
		}
	}
	sprintf( temp, "[0][Directory %8.8s Not found][OK]", directory );
	form_alert( 1, temp );
	return(number);
}

/* Read each mailbox line, and identify email filename as being affected by directory change */
int read_mailbox(char *filename)
{
	FILE *fid;
	int  mailnum,rc=0;
	char buff[200],mailname[FMSIZE];

	graf_mouse( BUSY_BEE, NULL );

	fid = fopen( filename, "ra" );
	if (fid!=NULL) {
		while (fgets( buff, sizeof(buff), fid )!=NULL) {
			mailnum = parse_mailbox_header( buff, mailname );
			if (strstr(mailname,last)!=NULL) {	/* if mail is in requested month's directories */
				rc++;	/* we have affected mailbox */
			}
		}
		fclose( fid );
	}
	graf_mouse( ARROW, NULL );
	return( rc );
}

/* Read each mailbox line, and identify email filename as being affected by directory change */
int read_write_mailbox(char *infile, char *outfile)
{
	FILE *fid,*fid2;
	int  mailnum,newnum,rc=0;
	char buff[300],mailname[FMSIZE],*p;
	char buff2[300];

	graf_mouse( BUSY_BEE, NULL );

	fid = fopen( infile, "ra" );
	if (fid!=NULL) {
		fid2 = fopen( outfile, "wa" );
		while (fgets( buff, sizeof(buff), fid )!=NULL) {
			if ((p=strstr(buff,last))!=NULL) {	/* if mail is in requested month's directories */
				strcpy( buff2, buff );	/* duplicate line for parse */
				mailnum = parse_mailbox_header( buff2, mailname );
				if (*(p-1)='\\') {	/* is this start of directory? */
					newnum = renamed_mail_file( p, mailnum );	/* get possible new number */
					*(p+6)='\0';
					strcpy( buff2, buff ); /* we have affected entry */
					if (newnum!=mailnum) {	/* file number has changed */
						sprintf( mailname, "%04d", newnum );
						memcpy( p+13, mailname, 4);	/* overlay number */
					}
					strcat( buff2, p+8 );
					strcpy( buff, buff2 );	/* copy back */
				}
			}
			fputs( buff, fid2 );
		}
		fclose( fid2 );
		fclose( fid );
	}
	graf_mouse( ARROW, NULL );
	return( rc );
}

/* Return the numeric (nnnn) part of the filename (mailnnnn.txt) */
int get_mail_index( char *filename )
{
	char temp[FNSIZE],temp2[5];

	stcgfn( temp, filename );		/* mailnnnn.txt format */
	memcpy( temp2, temp+4, 4 );
	temp2[4] = '\0';
	return( atoi(temp2) );
}

/* For each mailbox line, we need to determine the email filename */
int parse_mailbox_header( char *buff, char *mailname )
{
	char *status, *author, *author_email, *subject, *datetime;
	char *filename, *num_lines;

	status = strtoka( buff, '\t' );
	subject = strtoka( NULL, '\t' );
	author = strtoka( NULL, '\t' );
	author_email = strtoka( NULL, '\t' );
	datetime = strtoka( NULL, '\t' );
	filename = strtoka( NULL, '\t' );
	num_lines = strtoka( NULL, '\n' );
	strcpy( mailname, filename );

	return(get_mail_index( filename ));
}


int file_exists( char *filename )
{
	struct FILEINFO info;

	return( !dfind( &info, filename, 0 ));	/* 1 if file exists */
}

void validate_dir( char *root, char *thedir, char *dir_path )
{
	struct FILEINFO info;

	sprintf( dir_path, "%s\\%s", root, thedir );
	if (dfind( &info, dir_path, FA_SUBDIR )) {	/* if dir does not exist */
		if (mkdir( dir_path, S_IWRITE|S_IREAD )) {	/* if cannot make dir */
			strcpy( dir_path, root );
		}
	}
}

void remove_mailbox_dir( char *filename )
{
	char dir_path[FMSIZE],temp[FMSIZE],*p;
	struct FILEINFO info;
	int rc;

	strcpy( dir_path, filename );
	if (p=strrchr( dir_path, '\\' )) {
		*(p+1)='\0';				/* remove filename, leave final '\' */
		strcpy( temp, dir_path );
		strcat( temp, "*.*" );		/* append template  */
	/*	fprintf( log, "Dir_path %s, temp %s\n", dir_path, temp ); */
		if (dfind( &info, temp, 0 )) {	/* if directory is empty */
			rc=rmdir( dir_path );		/* remove empty directory */
			if (rc) {
			/*	sprintf( temp, "Unable to delete Directory |%s %d %ld\n", dir_path, rc, _OSERR ); */
			/*	form_alert( 1, temp ); */
			}
		}
	}
}

/* duplicate a file with a new filename, used to move files to a new directory */
int copy_file(char *newfile, char *filename)
{
	FILE *fid,*fid2;
	char  buff[500];
	int lines=0;

	fid = fopen( filename, "ra" );
	if (fid!=NULL) { 
		fid2 = fopen( newfile, "wa" );
		if (fid2!=NULL) { 
			while (fgets( buff, sizeof(buff), fid )!=NULL) {
				fputs( buff, fid2 );
				lines++;
			}
			fclose( fid2 );
		}
		fclose( fid );
	}
	return(lines);
}

/* given the xxxxnnnn.txt format, find the next available nnnn to use as a filename. */
int get_unique_filename(int start, char *prefix, char *path )
{
	FILE *fid;
	char filename[FMSIZE];
	int c;

	for (c=start;;c++) {
		sprintf( filename, "%s\\%s%04d.txt", path, prefix, c );
		fid = fopen( filename, "ra" );
		if (fid==NULL) { break; }	/* file file does not exist... */
		fclose( fid );
	}
	return(c);
}

/* report on "compressed" directories to user */
long report_compressed_directory(void)
{
	static int dir=0;
	int c,mailcnt=0,rc,startdir=0;
	int numdir=0;
	char temp[80];
	static int cont=0;

	last[0]='\0';
	for (c=dir;c<dcount;c++) {
		if (dpointers[c][0]=='.') { continue; }
		if ((dpointers[c][0]!='1')&&(dpointers[c][0]!='2')) { continue; }	/* non-century */
		if (strlen( dpointers[c] )==6) {
			if (cont!=2) {
				sprintf( temp, "[0][Directory %s is compressed][OK|Continue]", dpointers[c] );
				cont = form_alert( 1, temp );
			}
			continue;
		}
		if (strncmp( dpointers[c], last, 6 )!=0) {	/* first 6 chars do not match */
			if (last[0]!='\0') {	/* if not empty string */
				sprintf( temp, "[2][%d Directories for %6.6s |have %d messages|Compress Now?][Yes|No]", numdir, last, mailcnt );
				rc=form_alert( 1, temp );
				dir = c;	/* start here next time */
				if (rc==1) { return( startdir ); }	/* If yes, break out now */
			}
		/*	sprintf( temp, "[0][Directories for %6.6s |are not compressed][OK]", dpointers[c] ); */
		/*	form_alert( 1, temp ); */
			strncpy( last, dpointers[c], 6 );	/* keep only YYYYMM */
			startdir = c;
			mailcnt = 0;	/* reset mail for the month total */
			numdir  = 0;	/* reset number of daily directories */
		}
		mailcnt += dmpointers[c][0];	/* total mail in this directory */
		numdir++;			/* increment number of daily directories */
	}
	return(0);
}

/* create a new directory and copy files from existing directories to new one,
	renaming duplicate filenames as necessary */
void create_and_copy(long comp)
{
	char new_dir[FMSIZE],old[FMSIZE],new[FMSIZE];
	char temp[80];
	long c;
	int d,to,next_mail_number=1;

	validate_dir( mail_path, last, new_dir );
	for (c=comp;c<dcount;c++) {
		if (strncmp( last, dpointers[c], 6 )!=0) { continue; }
		if (dmpointers[c]!=NULL) {	/* if there are files in this directory */
			for (d=1;d<=dmpointers[c][0];d++) {
				if (dmpointers[c][d]!=0) {
					to = dmpointers[c][d];
					sprintf( old, "%s\\%s\\mail%04d.txt", mail_path, dpointers[c], to );
					sprintf( new, "%s\\mail%04d.txt", new_dir, to );
					if (file_exists(new)) {
						next_mail_number = get_unique_filename(next_mail_number, "mail", new_dir );
						sprintf( new, "%s\\mail%04d.txt", new_dir, next_mail_number );
						drpointers[c][d] = next_mail_number++;
					}
					if (drpointers[c][d]!=0) { to = drpointers[c][d]; }
				/*	sprintf( temp, "[0][Copying mail%04d.txt |     to mail%04d.txt][OK]", dmpointers[c][d], to ); */
				/*	form_alert( 1, temp ); */

					if (rename( old, new )!=0) {	/* non-zero is failure */			
						if (copy_file( new, old )) { remove( old ); }		
					}	
				}
			}
		}
		sprintf( old, "%s\\%s\\", mail_path, dpointers[c] );
		remove_mailbox_dir( old );
	}
	sprintf( temp, "[0][Directories for %6.6s |are now compressed][OK]", last );
	form_alert( 1, temp );
}

/* We have found all the emails, now find which mailboxs need to be updated */
int check_mailboxes(void)
{
	int c,total=0,num=0;
/*	char temp[80]; */

	for (c=0;c<count;c++) {
		updateboxes[c]=0;	/* initialize to no update required */
	/*	sprintf( temp, "[0][Checking Mailbox |%s][OK]", pointers[c] ); *
	/*	form_alert( 1, temp ); */
		num = read_mailbox( pointers[c] );
		if (num) {
			updateboxes[c]=num;	/* update is required */
		/*	sprintf( temp, "[0][Mailbox %s |has %d files moved][OK]", pointers[c], num ); */
		/*	form_alert( 1, temp ); */
		}
		total +=num;
	}
	return( total );
}

/* We have found all the emails, now find which mailboxs need to be updated */
int update_mailboxes(void)
{
	int c,total=0,num=0;
	char temp[80];
	static int cont=0;

	for (c=0;c<count;c++) {
		if (updateboxes[c]!=0) {	/* if update is required */
		/*	sprintf( temp, "[0][Updating Mailbox |%s][OK]", pointers[c] ); */
		/*	form_alert( 1, temp ); */
			copy_file( "xmailmnt.txt", pointers[c] );	/* make a copy */
			read_write_mailbox( "xmailmnt.txt", pointers[c] );
			remove( "xmailmnt.txt" );	/* remove copy */
			if (cont!=2) {
	 			sprintf( temp, "[0][Mailbox %s |has been updated][OK|Continue]", pointers[c] );
				cont = form_alert( 1, temp );	/* continue will suppress further msgs */
			}
		}
		total +=num;
	}
	return( total );
}

/* Everything happens from here to find mailbox directories, and compress the daily
	directories into monthly directories, and update filenames in mailboxes as required.
	Process keys on directory YYYYMM.  If the user requests the directory to be compressed,
	the new directory is created, files are copied (and/or renamed), then the affected mailboxes
	are updated with the new directory name and mailnnnn.txt as required.
*/
int main(void)
{
	char temp[80];

	initialize();
	if (get_mail_path()) {
		dcount = get_directories();
		count  = get_mailboxes();
		if (dcount>0) {
			mcount = get_directory_mail();
			while ((comp = report_compressed_directory())>0) {
				create_and_copy(comp);		/* create dir and copy files */
				if (check_mailboxes()) {	/* identify mailboxes that need modification */
					update_mailboxes();	/* and modify them */
				}
			}
			sprintf( temp, "[0][Updates Completed][OK]" );
			form_alert( 1, temp );
		} else {
			sprintf( temp, "[0][No Directories to Update][OK]" );
			form_alert( 1, temp );
		}
	}
	deinitialize(EXIT_SUCCESS);
	return(EXIT_SUCCESS);
}

/* end of mailmnt.c */