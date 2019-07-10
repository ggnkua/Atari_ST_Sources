/*
 * libtag.c -- File description tag handling for Citadel
 *
 * 88Apr12 orc	MS-DOS doesn't allow filenames that start with ., so we
 *		will use $ instead
 * 87Apr01 orc	ripped to shreds and redone in a totally different way.
 * 87Jan30 orc	Created.
 */

#include "ctdl.h"
#include "msg.h"
#include "room.h"
#include "citlib.h"

/*
 * tagSetup()	Set up the description file.
 * tagClose()	Close the description file.
 * getTag()	Get the tag for a file.
 * putTag()	Write a file tag into the descr file.
 */

#ifdef MSDOS
#define	TAGFILE	"$dir"
#else
#define TAGFILE ".fdr"
#endif
#define TAGTEMP "$tagtemp"

FILE *safeopen();
static FILE *tagfile = NULL;
static int preload;

/*
 * tagcmp() - compare a filetag with a filename
 */
static
tagcmp(fname, tag)
char *fname, *tag;
{
    while (toupper(*fname) == toupper(*tag))
	fname++, tag++;
    if (*fname == 0 && (*tag == '\t' || *tag == ' '))
	return 0;
    if (*tag == 0 || (toupper(*fname) < toupper(*tag)))
	return -1;
    return 1;
}

/*
 * tagSetup() - opens up tagfile.
 */
tagSetup()
{
    preload = YES;
    return xchdir(roomBuf.rbdirname) && (tagfile = safeopen(TAGFILE,"r"));
}

/*
 * tagClose() - shuts down the tagfile.
 */
void
tagClose()
{
    if (tagfile)
	fclose(tagfile);
    tagfile = NULL;
}

/*
 * putTag() - updates a file tag
 */
void
putTag(fname, desc)
char *fname, *desc;
{
    FILE *temp;
    char line[500];
    int flag;

    if (tagfile = safeopen(TAGFILE, "r")) {
	temp = safeopen(TAGTEMP, "w");
/* (int) typecast added by RH 89May08 */
	while (flag=(int)fgets(line, 500, tagfile)) {
	    if (tagcmp(fname, line) <= 0)
		break;
	    fputs(line, temp);
	}
	fprintf(temp, "%s\t%s\n", fname, desc);
	if (flag && tagcmp(fname, line) != 0)
	    fputs(line, temp);

	while (fgets(line, 500, tagfile))
	    fputs(line, temp);

	fclose(tagfile);
	fclose(temp);
	dunlink(TAGFILE);
	drename(TAGTEMP, TAGFILE);
    }
    else if (tagfile = safeopen(TAGFILE, "w")) {
	fprintf(tagfile, "%s\t%s\n", fname, desc);
	fclose(tagfile);
    }
    else
	mprintf("Can't write file tag!\n ");
}

/*
 * getTag() - returns the tag for a file.
 */
char *
getTag(fname)
char *fname;
{
    char *strpbrk();

    if (tagfile) {
	if (preload) {
	    msgBuf.mbtext[0] = 0;
	    fgets(msgBuf.mbtext, MAXTEXT-10, tagfile);
	    preload = NO;
	}
	while (tagcmp(fname, msgBuf.mbtext) > 0)
	    if (!fgets(msgBuf.mbtext, MAXTEXT-10, tagfile)) {
		rewind(tagfile);
		return NULL;
	    }
	if (tagcmp(fname, msgBuf.mbtext) == 0) {
	    preload = YES;
	    strtok(msgBuf.mbtext, "\n");
	    return 1+strpbrk(msgBuf.mbtext, "\t ");
	}
    }
    return NULL;
}

/*
 * rewindtag() - returns tag file pointer to start of file
 */
void
rewindtag(void)
{
    rewind(tagfile);
}
