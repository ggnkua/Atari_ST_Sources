/* *    extract.c - selectively extract C code using preprocessor conditional
 * *                compilation flags
 * *
 * *    Copyright (c) 1991, 1993 Pete Jordan, Horus Communications
 * *
 * *    * NO WARRANTY *
 * *
 * *    BECAUSE THIS PROGRAM IS LICENCED FREE OF CHARGE, WE PROVIDE ABSOLUTELY
 * *    NO WARRANTY, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
 * *    OTHERWISE STATED IN WRITING, HORUS COMMUNICATIONS, PETE JORDAN AND/OR
 * *    OTHER PARTIES PROVIDE THIS PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND,
 * *    EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * *    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
 * *    ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH
 * *    YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
 * *    NECESSARY SERVICING, REPAIR OR CORRECTION.
 * *
 * *    IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW WILL PETE JORDAN, HORUS
 * *    COMMUNICATIONS AND/OR ANY OTHER PARTY WHO MAY MODIFY AND REDISTRIBUTE
 * *    THIS PROGRAM AS PERMITTED BELOW, BE LIABLE TO YOU FOR DAMAGES, INCLUDING
 * *    ANY LOST PROFITS, LOST MONIES, OR OTHER SPECIAL, INCIDENTAL OR
 * *    CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
 * *    (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED
 * *    INACCURATE OR LOSSES SUSTAINED BY THIRD PARTIES OR A FAILURE OF THE
 * *    PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS) THIS PROGRAM, EVEN IF YOU
 * *    HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES, OR FOR ANY CLAIM
 * *    BY ANY OTHER PARTY.
 * *
 * *    * GENERAL PUBLIC LICENCE TO COPY *
 * *
 * *      1. You may copy and distribute verbatim copies of this source file
 * *    as you receive it, in any medium, provided that you conspicuously and
 * *    appropriately publish on each copy a valid copyright notice "Copyright
 * *    (C) 1991, 1993 Pete Jordan, Horus Communications"; and include following
 * *    the copyright notice a verbatim copy of the above disclaimer of warranty
 * *    and of this Licence. You may charge a distribution fee for the physical
 * *    act of transferring a copy.
 * *
 * *      2. You may modify your copy or copies of this source file or any
 * *    portion of it, and copy and distribute such modifications under the
 * *    terms of Paragraph 1 above, provided that you also do the following:
 * *
 * *        a) cause the modified files to carry prominent notices stating that
 * *        you changed the files and the date of any change; and
 * *
 * *        b) cause the whole of any work that you distribute or publish, that
 * *        in whole or in part contains or is a derivative of this program or
 * *        any part thereof, to be licenced at no charge to all third parties
 * *        on terms identical to those contained in this Licence Agreement
 * *        (except that you may choose to grant more extensive warranty
 * *        protection to some or all third parties, at your option).
 * *
 * *        c) You may charge a distribution fee for the physical act of
 * *        transferring a copy, and you may at your option offer warranty
 * *        protection in exchange for a fee.
 * *
 * *    Mere aggregation of another unrelated program with this program (or its
 * *    derivative) on a volume of a storage or distribution medium does not
 * *    bring the other program under the scope of these terms.
 * *
 * *      3. You may copy and distribute this program or any portion of it in
 * *    compiled, executable or object code form under the terms of Paragraphs
 * *    1 and 2 above provided that you do the following:
 * *
 * *        a) accompany it with the complete corresponding machine-readable
 * *        source code, which must be distributed under the terms of Paragraphs
 * *        1 and 2 above; or,
 * *
 * *        b) accompany it with a written offer, valid for at least three
 * *        years, to give any third party free (except for a nominal shipping
 * *        charge) a complete machine-readable copy of the corresponding source
 * *        code, to be distributed under the terms of Paragraphs 1 and 2 above;
 * *        or,
 * *
 * *        c) accompany it with the information you received as to where the
 * *        corresponding source code may be obtained. (This alternative is
 * *        allowed only for noncommercial distribution and only if you received
 * *        the program in object code or executable form alone.)
 * *
 * *    For an executable file, complete source code means all the source code
 * *    for all modules it contains; but, as a special exception, it need not
 * *    include source code for modules which are standard libraries that
 * *    accompany the operating system on which the executable file runs.
 * *
 * *      4. You may not copy, sublicence, distribute or transfer this program
 * *    except as expressly provided under this Licence Agreement. Any attempt
 * *    otherwise to copy, sublicence, distribute or transfer this program is
 * *    void and your rights to use the program under this Licence agreement
 * *    shall be automatically terminated. However, parties who have received
 * *    computer software programs from you with this Licence Agreement will not
 * *    have their licences terminated so long as such parties remain in full
 * *    compliance.
 * *
 * *      5. If you wish to incorporate parts of this program into other free
 * *    programs whose distribution conditions are different, write to Horus
 * *    Communications at 90 Belvoir Street, Hull HU5 3RG, England, or email to
 * *    horus@cix.compulink.co.uk or CIS: 100013,3547. Individual cases will be
 * *    treated on their merits subject to the two goals of preserving the free
 * *    status of all derivatives our free software and of promoting the sharing
 * *    and reuse of software.
 * *
 * *
 * *    In other words, you are welcome to use, share and improve this program.
 * *    You are forbidden to forbid anyone else to use, share and improve what
 * *    you give them. Help stamp out software-hoarding!
 * *
 * */



#include <stdio.h>
#include <ctype.h>
#include <string.h>

#ifdef ANSI
#include <stdlib.h>
#include <stdarg.h>
#else
#include <varargs.h>
#ifndef ERRNO_OK
extern int errno;
#endif
#endif



#ifndef TRUE
#define FALSE   0
#define TRUE  (-1)
#endif



#ifndef ISCSYM_OK
#define iscsym(c) (isalnum(c) || (c)=='_')
#endif



#define USAGE (-1)



#define IGNORE	0
#define ISTRUE	1
#define ISFALSE 2



typedef struct FLAGDESC {
    struct FLAGDESC *next;
    char *flag;
    int select;
} flagdesc;



typedef struct FILEDESC {
    struct FILEDESC *next;
    char *name;
} filedesc;



char *progname;



#ifdef ANSI
    void fail(int err, char *reason,...)
#else
    void fail(err, reason, va_alist)
    int err;
    char *reason;
    va_dcl
#endif

{
    if (reason) {
	va_list args;

	#ifdef ANSI
	    va_start(args, reason);
	#else
	    va_start(args);
	#endif

	fprintf(stderr, "%s - ", progname);
	vfprintf(stderr, reason, args);

	if (err>0)
	    fprintf(stderr, ": %s\n", strerror(errno));
	else
	    putc('\n', stderr);

	va_end(args);
    }

    if (err==USAGE)
	fputs("usage: extract [+flag,...] [-flag,...] [file...]\n", stderr);

    exit(1);
}



#ifdef ANSI
    char *checkline(char *buff)
#else
    char *checkline(buff)
    char *buff;
#endif

{
    int ptr=0;
    char *ch=buff;
    char *charfound=NULL;
    int hashfound=FALSE;

    while (++ptr<256 && *ch) {
	if (!charfound && !isspace(*ch))
	    if (!hashfound && *ch=='#')
		hashfound=TRUE;
	    else
		charfound=ch;

	ch++;
    }

    if (ptr>255)
	fail(0, "line longer than 255 characters");

    return(hashfound ? charfound : NULL);
}



#ifdef ANSI
    int checktag(char *ch, flagdesc *flaglist)
#else
    int checktag(ch, flaglist)
    char *ch;
    flagdesc *flaglist;
#endif

{
    int invert;

    ch+=2;

    if (invert=(*ch=='n'))
        ch++;

    if (!strncmp(ch, "def", 3)) {
	char buff[64];
	char *ptr=buff;

	ch+=3;

        while (*ch && isspace(*ch))
            ch++;

        while (*ch && iscsym(*ch))
            *ptr++ = *ch++;

	*ptr='\0';

	if (*buff)
	    while (flaglist)
		if (strcmp(buff, flaglist->flag))
		    flaglist=flaglist->next;
		else if (flaglist->select)
		    return(invert ? ISFALSE : ISTRUE);
		else
		    return(invert ? ISTRUE : ISFALSE);

    }

    return(IGNORE);
}



#ifdef ANSI
    void extract(FILE *fpin, flagdesc *flaglist, FILE *fpout)
#else
    void extract(fpin, flaglist, fpout)
    FILE *fpin;
    flagdesc *flaglist;
    FILE *fpout;
#endif

{
    char buff[256];
    unsigned char depths[16];
    int nextdepth=0;
    int depth=0;
    int copying=TRUE;

    while (fgets(buff, 256, fpin)) {
	char *ch=checkline(buff);
	int copy=copying;

	if (ch)
	    if (!strncmp(ch, "if", 2)) {
		int test=checktag(ch, flaglist);

		depth++;

		if (copying && test!=IGNORE) {
		    copying=test==ISTRUE;
		    copy=FALSE;
		    depths[nextdepth++]=depth;
		}
	    } else if (!strncmp(ch, "else", 4)) {
		if (nextdepth && depth==depths[nextdepth-1]) {
		    copying= !copying;
		    copy=FALSE;
		}
	    } else if (!strncmp(ch, "endif", 5)) {
		if (depth>0) {
		    if (nextdepth && depth==depths[nextdepth-1]) {
			nextdepth--;
			copying=TRUE;
			copy=FALSE;
		    }

		    depth--;
		}
	    }

        if (copy)
            fputs(buff, fpout);

    }
}



#ifdef ANSI
    void backupname(char *source, char *dest)
#else
    void backupname(source, dest)
    char *source, *dest;
#endif

{
    char *point=NULL;

    while (*source) {
        if (*source=='.')
            point=dest;

	*dest++ = *source++;
    }

    if (!point)
        point=dest;

    strcpy(point, ".BAK");
}



#ifdef ANSI
    FILE *openfile(char *fn, char *mode)
#else
    FILE *openfile(fn, mode)
    char *fn, *mode;
#endif

{
    FILE *fp=fopen(fn, mode);

    if (!fp)
	fail(errno, "error opening %s for %s", fn, mode);

    return(fp);
}



#ifdef ANSI
    void copyfile(char *source, char *dest)
#else
    void copyfile(source, dest)
    char *source, *dest;
#endif

{
    FILE *fpin=openfile(source, "r");
    FILE *fpout=openfile(dest, "w");
    int ch;

    while ((ch=getc(fpin))!=EOF)
	if (putc(ch, fpout)==EOF)
	    fail(errno, "error writing to %s", dest);

    fclose(fpout);
    fclose(fpin);
}



#ifdef ANSI
    void main(int argc, char **argv)
#else
    void main(argc, argv)
    int argc;
    char **argv;
#endif

{
    flagdesc *flaglist=NULL, *thisflag=NULL;
    filedesc *filelist=NULL, *thisfile=NULL;
    int argptr=0;

    progname= *argv;

    while (++argptr<argc) {
	char *thisarg=argv[argptr];

	if (*thisarg=='+' || *thisarg=='-') {
	    if (! *(thisarg+1))
		fail(USAGE, "null flag (space after +/- ?)");

	    if (!flaglist)
		thisflag=flaglist=(flagdesc *)malloc(sizeof(flagdesc));
	    else {
		thisflag->next=(flagdesc *)malloc(sizeof(flagdesc));
		thisflag=thisflag->next;
	    }

	    thisflag->next=NULL;
	    thisflag->flag=thisarg+1;
	    thisflag->select= *thisarg=='+';
	} else {
	    if (!filelist)
		thisfile=filelist=(filedesc *)malloc(sizeof(filedesc));
	    else {
		thisfile->next=(filedesc *)malloc(sizeof(filedesc));
		thisfile=thisfile->next;
	    }

	    thisfile->next=NULL;
	    thisfile->name=thisarg;
	}
    }

    if (!flaglist)
	fail(USAGE, "no compiler flags specified");

    if (!filelist)
	extract(stdin, flaglist, stdout);
    else {
	int status=filelist->next!=NULL;

	while (filelist) {
	    char backup[128];
	    FILE *fpin, *fpout;

            if (status)
                printf("%s - %s\n", progname, filelist->name);

	    backupname(filelist->name, backup);
	    copyfile(filelist->name, backup);
	    fpin=openfile(backup, "r");
	    fpout=openfile(filelist->name, "w");
	    extract(fpin, flaglist, fpout);
	    fclose(fpout);
	    fclose(fpin);

	    filelist=filelist->next;
	}
    }

    exit(0);
}

