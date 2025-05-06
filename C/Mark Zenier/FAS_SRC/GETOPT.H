

/*
HEADER: 	;
TITLE: 		Frankenstein Cross Assemblers;
VERSION: 	2.0;
DESCRIPTION: "	Reconfigurable Cross-assembler producing Intel (TM)
		Hex format object records.  ";
SYSTEM: 	UNIX, MS-Dos ;
FILENAME: 	getopt.h;
WARNINGS: 	"This is some ancient code I found on a version 7 system
		when I was running the original port.  Asking for help from
		the original authors is not advised.  (Especially after
		the hack job I did on it.  Mark Zenier.)  "  ;
SEE-ALSO: 	frasmain.c;
AUTHORS: 	Keith Bostic, Rich $alz;
*/
/*
**  This is a public domain version of getopt(3).
**  Bugs, fixes to:
**		Keith Bostic
**			ARPA: keith@seismo
**			UUCP: seismo!keith
**  Added NO_STDIO, opterr handling, Rich $alz (mirror!rs).

  Framework Cross Assembler 
	use strchr
	remove NO_STDIO code
	Mark Zenier 	Specialized Systems Consultants, Inc.   
*/

/*
**  Error macro.  Maybe we want stdio, maybe we don't.
**  The (undocumented?) variable opterr tells us whether or not
**  to print errors.
*/

#define tell(s)								\
	if (opterr)							\
	    (void)fputs(*nargv, stderr),				\
	    (void)fputs(s,stderr),					\
	    (void)fputc(optopt, stderr),				\
	    (void)fputc('\n', stderr)



/* Global variables. */
static char	 EMSG[] = "";
int		 opterr = 1;		/* undocumented error-suppressor*/
int		 optind = 1;		/* index into argv vector	*/
int		 optopt;		/* char checked for validity	*/
char		*optarg;		/* arg associated with option	*/


getopt(nargc, nargv, ostr)
    int			  nargc;
    char		**nargv;
    char		 *ostr;
{
    static char		 *place = EMSG;	/* option letter processing	*/
    register char	 *oli;		/* option letter list index	*/

    if (!*place)			/* update scanning pointer	*/
    {
	if (optind >= nargc || *(place = nargv[optind]) != '-' || !*++place)
	    return(EOF);
	if (*place == '-')		/* found "--"			*/
	{
	    optind++;
	    return(EOF);
	}
    }
    /* option letter okay? */
    if ((optopt = *place++) == ':' || (oli = strchr(ostr, optopt)) == NULL)
    {
	if (!*place)
	    optind++;
	tell(": illegal option -- ");
	goto Bad;
    }
    if (*++oli != ':')			/* don't need argument		*/
    {
	optarg = NULL;
	if (!*place)
	    optind++;
    }
    else				/* need an argument		*/
    {
	if (*place)
	    optarg = place;		/* no white space		*/
	else
	    if (nargc <= ++optind)
	    {
		place = EMSG;
		tell(": option requires an argument -- ");
		goto Bad;
	    }
	    else
		optarg = nargv[optind];	/* white space			*/
	place = EMSG;
	optind++;
    }
    return(optopt);			/* dump back option letter	*/
Bad:
    return('?');
}

