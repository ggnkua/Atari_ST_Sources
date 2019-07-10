/*
 * etext.c
 * A simple filter to change EMACS-style text files into a format
 * suitable for importing into PageStream. I don't know why 
 * PageStream doesn't support EMACS-style files, but my copy doesn't,
 * so I wrote this filter. When compiled as a desk accessory, it
 * can be invoked from inside the page layout program.
 *
 * Compile as a GEM .PRG, or define DESK_ACCESSORY to compile
 * as an .ACC file. See MAKEFILE for details.
 *
 * Written by Steve Yelvington <steve@thelake.mn.org> September 1990.
 * Targeted for the Sozobon (free) C compiler, dLibs and GEMFAST.
 *
 * This program is in the public domain.
 */

#include <gemdefs.h>  /* or GEMFAST.H, if you prefer */
#include <obdefs.h>
#include <types.h>
#include <limits.h>
#include <osbind.h>

#ifndef NULL
#define NULL ((char *)0)
#endif

#define MENU_ID	" EMACS to PageStream"

static char pd[] = 
  "Public domain 1990 by Steve Yelvington <stecve@thelake.mn.org>";

int junk, button, menuid;
char infname[PATHSIZE], outfname[PATHSIZE];

/* GEM arrays. */
int work_in[11],
    work_out[57],
    contrl[12],
    intin[128],
    ptsin[128],
    intout[128],
    ptsout[128];

extern int gl_apid;

#define MAX_LINE	4096
char buf[MAX_LINE];	/* A big general-purpose line buffer */


/*
 * Function: main
 * Input: none
 * Output: none
 * Description: Initializes system and calls interact() when appropriate.
 */
main()
	{
	int msgbuf[8];
	appl_init();

#ifdef DESK_ACCESSORY
	menuid = menu_register(gl_apid, MENU_ID); /* add me to the Desk menu */
	for(;;)	/* loop forever */
		{
		evnt_mesag(msgbuf);
		if ( (msgbuf[0] == AC_OPEN) && (msgbuf[4] == menuid) )
			interact();	
		}
#else
	interact();
#endif
	appl_exit();			/* say goodbye to the AES */
	}

/*
 * Function: interact()
 * Input: none
 * Output: none
 * Description: Prompts user for filenames and calls filter() to do the work.
 */
interact()
	{
	infname[0] = outfname[0] = '\0';
	if (file_sel(infname,"Name of EMACS file to convert","*.*") == 0)
		return;
	if (file_sel(outfname,"Name for output file","*.TXT") == 0)
		return;
	graf_mouse(BUSY_BEE,NULL);
	filter(infname,outfname);
	graf_mouse(ARROW,NULL);
	}

/*
 * Function: file_sel
 * Input: Pointers to filename, a prompt string and a path mask. Any
 *        string may be empty, but none should be a NULL pointer.
 * Output: Sets filename equal to complete path. Returns value of exit button.
 * Description: A smart wrapper for fsel_exinput, which doesn't have a clue
 * about some important things.
 */
char inpath[128], insel[14];
int
file_sel(file, prompt, mask)	char *file, *prompt, *mask;
	{
	char *p;
	int drv;
	insel[0] = '\0';
	if (mask[1] != ':') /* If a drive is not not specified ... */
		{
		drv = Dgetdrv();  /* specify one, and ... */
		inpath[0] = drv + 'A';
		inpath[1] = ':';
		Dgetpath(&inpath[2], drv+1); /* 1 BASED drive number here */
		strcat(inpath,"\\");
		strcat(inpath,mask); /* ... concatenate the mask */
		}
	else
		strcpy(inpath,mask);
	insel[0] = '\0';

	wind_update(BEG_UPDATE); /* prevent AES from drawing on top of fsel */

	/*
	 * Note: Here we use the TOS 1.4 extended file selector call. If
	 * you are NOT using Ian Lepore's GEMFAST bindings, you may wish
	 * to #define fsel_exinput(a,b,c,d) fsel_input(a,b,c).
	 */
	if (fsel_exinput(inpath,insel,&button,prompt))
		{
		/* create a complete path to the chosen file */

		/* first, copy the inpath to the file buffer */
		strcpy(file,inpath);

		/* then point to the end of the string */
		p = file + (strlen(file) - 1);

		/* now back up over the path's mask, if any */
		while ((*p != '\\') && (*p != ':') && (p >= file))
			p--;

		/* and tack on the chosen root filename */
		strcpy(p+1,insel);
		}

	wind_update(END_UPDATE); /* return freedom to AES */

	return(button);		
	}


/*
 * Function: fhgets
 * Input: Pointer to data buffer, limit on the length of the buffer,
 *        and a valid open GEMDOS file handle.
 * Output: Fills in the data buffer if possible. Returns a pointer to
 *        the buffer, or NULL if end of file has been reached.
 * Description: fhgets is like fgets, but it works (s-l-o-w-l-y!) from 
 *        GEMDOS file handles. We have to write this because dLibs has
 *        memory allocation deeply rooted in the stdio package, and
 *        we want this program to run as a DA, which must not
 *        hold mallocked memory.
 */
char *fhgets(data,limit,fd)
	char *data;
	register int limit;
	int fd;
	{
	register char *p = data;
	char c[1];
	register int bytes_read;

	while(--limit > 0)
		{
		if ((bytes_read = Fread(fd,1L,c)) < 1)
			break;
		if ((*p++ = c[0]) == '\n')
			break;
		}
	*p = '\0';
	return((bytes_read <= 0 && p == data) ? NULL : data); /* NULL == EOF */
	}

/*
 * Function: fdputs.
 * Input: pointer to a null-terminated array of char, and a valid open GEMDOS
 *        file handle.
 * Output: Sends the string to the file and returns the number of bytes written.
 * Description: Works like fputs. A newline is not appended. 
 *
 */
int 
fhputs(s, fh) 
	char *s; int fh;
	{
	return (Fwrite(fh,(long)strlen(s),s));
	}


/*
 * Function: filter
 * Input: pointers to filenames
 * Output: Returns 0 for both success and failure; aborts on errors.
 * Description: The guts of the program: Copy a file, stripping line enders
 *         except on blank lines. The resulting file works with PageStream.
 */
int
filter(infile,outfile) char *infile, *outfile;
	{
	int in, out;

	in = Fopen(infile,0);
	if (in < 0)
		{
		sprintf(buf,"[1][Can't open file|%-28s |for reading][QUIT]", infile);
		form_alert(1,buf);
		return;
		}
	if (out = Fopen(outfile,1) > 0)
		{
		Fclose(out);
		sprintf(buf,"[1][%-28s |already exists!][Overwrite|QUIT]",outfile);
		if (form_alert(1,buf) == 2) return;
		Fdelete(outfile);
		}

	out = Fcreate(outfile,0);

	if (outfile < 0 )
		{
		sprintf(buf,"[1][Can't open file|%-28s |for writing][QUIT]", outfile);
		form_alert(1,buf);
		return;
		}
	buf[0] = '\0';

	while(fhgets(buf,MAX_LINE-1,in))
		{
		/* replace any line enders with nothing */
		strrpl(buf,"\r", "", -1);
		strrpl(buf,"\n", "", -1);
		if(buf[0] != '\0')
			{
			fhputs(buf,out);
			fhputs(" ",out);
			}
		else
			fhputs("\r\n",out);
		}

	Fclose(in);
	Fclose(out);
	return(0);
	}

