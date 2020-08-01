/*----------------------------------------------------------------*
 | envargs - add default options from environment to command line
 |---------------------------------------------------------------- 
 | Author: Bill Davidsen, original 10/13/91, revised 23 Oct 1991.
 | This program is in the public domain.
 |---------------------------------------------------------------- 
 | Minor program notes:
 |  1. Yes, the indirection is a tad complex
 |  2. Parenthesis were added where not needed in some cases
 |     to make the action of the code less obscure.
 |  3. Set tabsize to four to make this pretty
 |---------------------------------------------------------------- 
 | UnZip notes: 24 May 92 ("v1.4"):
 |  1. #include "unzip.h" for prototypes (24 May 92)
 |  2. changed ch to type char (24 May 92)
 |  3. added an ifdef to avoid Borland warnings (24 May 92)
 |  4. included Rich Wales' mksargs() routine (for MS-DOS, maybe
 |     OS/2? NT?) (4 Dec 93)
 |  5. added alternate-variable string envstr2 (21 Apr 94)
 *----------------------------------------------------------------*/


#include "unzip.h"

static int count_args __((char *));
static void mem_err __((void));

#if (defined(SCCS) && !defined(lint))  /* causes warnings:  annoying */
   static char *SCCSid = "@(#)envargs.c    1.3 23 Oct 1991";
#endif

static char Far NoMemArguments[] = "envargs:  can't get memory for arguments";



void envargs(Pargc, Pargv, envstr, envstr2)
    int *Pargc;
    char ***Pargv, *envstr, *envstr2;
{
    char *getenv();
    char *envptr;       /* value returned by getenv */
    char *bufptr;       /* copy of env info */
    int argc = 0;       /* internal arg count */
    char ch;            /* spare temp value */
    char **argv;        /* internal arg vector */
    char **argvect;     /* copy of vector address */

    /* see if anything in either of valid environment variables */
    if ((envptr = getenv(envstr)) == (char *)NULL || *envptr == 0)
        if ((envptr = getenv(envstr2)) == (char *)NULL || *envptr == 0)
            return;

    /* count the args so we can allocate room for them */
    argc = count_args(envptr);
    bufptr = (char *)malloc(1+strlen(envptr));
    if (bufptr == (char *)NULL)
        mem_err();
    strcpy(bufptr, envptr);

    /* allocate a vector large enough for all args */
    argv = (char **)malloc((argc+*Pargc+1)*sizeof(char *));
    if (argv == (char **)NULL)
        mem_err();
    argvect = argv;

    /* copy the program name first, that's always true */
    *(argv++) = *((*Pargv)++);

    /* copy the environment args next, may be changed */
    do {
        *(argv++) = bufptr;
        /* skip the arg and any trailing blanks */
        while (((ch = *bufptr) != '\0') && ch != ' ')
            ++bufptr;
        if (ch == ' ')
            *(bufptr++) = '\0';
        while (((ch = *bufptr) != '\0') && ch == ' ')
            ++bufptr;
    } while (ch);

    /* now save old argc and copy in the old args */
    argc += *Pargc;
    while (--(*Pargc))
        *(argv++) = *((*Pargv)++);

    /* finally, add a NULL after the last arg, like UNIX */
    *argv = (char *)NULL;

    /* save the values and return */
    *Pargv = argvect;
    *Pargc = argc;
}



static int count_args(s)
    char *s;
{
    int count = 0;
    char ch;

    do {
        /* count and skip args */
        ++count;
        while (((ch = *s) != '\0') && ch != ' ')
            ++s;
        while (((ch = *s) != '\0') && ch == ' ')
            ++s;
    } while (ch);

    return count;
}



static void mem_err()
{
    perror(LoadFarString(NoMemArguments));
    exit(2);
}



#ifdef TEST

main(argc, argv)
    int argc;
    char **argv;
{
    int i;

    printf("Orig argv: %p\n", argv);
    dump_args(argc, argv);
    envargs(&argc, &argv, "ENVTEST");
    printf(" New argv: %p\n", argv);
    dump_args(argc, argv);
}



dump_args(argc, argv)
    int argc;
    char *argv[];
{
    int i;

    printf("\nDump %d args:\n", argc);
    for (i = 0; i < argc; ++i)
        printf("%3d %s\n", i, argv[i]);
}

#endif /* TEST */



#ifdef MSDOS   /* DOS_OS2?  DOS_NT_OS2? */

/*
 * void mksargs(int *argcp, char ***argvp)
 *
 *    Substitutes the extended command line argument list produced by
 *    the MKS Korn Shell in place of the command line info from DOS.
 *
 *    The MKS shell gets around DOS's 128-byte limit on the length of
 *    a command line by passing the "real" command line in the envi-
 *    ronment.  The "real" arguments are flagged by prepending a tilde
 *    (~) to each one.
 *
 *    This "mksargs" routine creates a new argument list by scanning
 *    the environment from the beginning, looking for strings begin-
 *    ning with a tilde character.  The new list replaces the original
 *    "argv" (pointed to by "argvp"), and the number of arguments
 *    in the new list replaces the original "argc" (pointed to by
 *    "argcp").
 *
 *    Rich Wales
 */
void mksargs(argcp, argvp)
    int *argcp;
    char ***argvp;
{
#ifndef MSC /* declared differently in MSC 7.0 headers, at least */
    extern char **environ;          /* environment */
#endif
    char        **envp;             /* pointer into environment */
    char        **newargv;          /* new argument list */
    char        **argp;             /* pointer into new arg list */
    int         newargc;            /* new argument count */

    /* sanity check */
    if (environ == NULL || argcp == NULL || argvp == NULL || *argvp == NULL)
        return;

    /* find out how many environment arguments there are */
    for (envp = environ, newargc = 0; *envp != NULL && (*envp)[0] == '~';
         envp++, newargc++)
        ;
    if (newargc == 0)
        return;     /* no environment arguments */

    /* set up new argument list */
    newargv = (char **) malloc(sizeof(char **) * (newargc+1));
    if (newargv == NULL)
        return;     /* malloc failed */

    for (argp = newargv, envp = environ; *envp != NULL && (*envp)[0] == '~';
         *argp++ = &(*envp++)[1])
        ;
    *argp = NULL;   /* null-terminate the list */

    /* substitute new argument list in place of old one */
    *argcp = newargc;
    *argvp = newargv;
}

#endif /* MSDOS */
