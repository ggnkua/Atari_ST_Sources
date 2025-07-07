/* Copyright (c) 1988 by Sozobon, Limited.  Author: Tony Andrews
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 */

static  char    Version[] =
"\r\nccd: version 1.01d  Copyright (c) 1988 by Sozobon, Limited.";

/*
 * ccd - C compiler driver program (for GEM)
 *
 * Parses command line for options and file names, then calls the
 * various passes of the compiler as needed.  
 * 
 * v1.01d - 11/05/88 Ian Lepore.
 *          This version is somewhat more 'desktop friendly'.  If the
 *          program is started without any command-line parms, it will
 *          prompt for them interactively.   This helps get around the
 *          small input line in the .TTP parms dialog. This hack also goes 
 *          around desktop's (and some shells') nasty habit of uppercasing
 *          all command-line parms by lowercasing everything arbitrarily,
 *          and using the '-z' switch to invoke the optimizer instead of
 *          the normal '-O' switch.
 */

#include <stdio.h>
#include <fcntl.h>
#include <osbind.h>
#include <ctype.h>

/*
 * This is the amount of space to grab from TOS at a time for
 * malloc(). The default is 64K which wastes space if you don't
 * need much. Since we spawn sub-programs from cc, it's important
 * to leave as much memory for them as possible.
 */
long    _BLKSIZ = 4096;

#ifndef TRUE
#define FALSE   (0)
#define TRUE    !FALSE
#endif

#define MAXOPT  16      /* max. number of options to any one pass */

/*
 * Standard filename extensions
 */
#define EXSUF   ".ttp,.tos,.prg"        /* suffixes for executables */
#define LIBSUF  ".a,.lib"               /* libraries */

/*
 * Compiler pass information
 */
#define CC      "hcc"

char    *hccopt[MAXOPT];
int     hcc_cnt = 0;            /* number of options to hcc */

/*
 * Optimizer information
 */
#define OPT     "top"
#define OTMP    "top_tmp.s"

/*
 * Assembler information
 */
#define ASM     "jas"                   /* default assembler */
#define ASMD    "as68symb.dat"          /* assembler data file (as68 only) */

/*
 * Loader information
 */
#define LD      "ld"
#define LTMP    "ldfile.tmp"            /* loader command file */

#define CSU     "dstart.o"              /* C startup code */
#define PCSU    "pdstart.o"             /* profiling startup code */

#define LIBC    "dlibs"                 /* C runtime library */
#define PLIBC   "pdlibs"                /* profiled runtime library */

#define LIBM    "libm"                  /* math library */
#define PLIBM   "plibm"                 /* profiled math library */

/*
 * Path information
 */

char    *path;          /* where to find executables */
char    *lib;           /* where to find library stuff */
char    *tmp;           /* where to put temporary files */

/*
 * Default paths for executables and libraries
 *
 * Always check the root of the current drive first.
 */
#define DEFPATH         "\\bin,\\sozobon\\bin"
#define DEFLIB          "\\lib,\\sozobon\\lib"
#define DEFTMP          ""

/*
 * Boolean options
 */
int     mflag = 0;      /* generate a load map */
int     vflag = 0;      /* show what we're doing w/ version numbers */
int     nflag = 0;      /* ...but don't really do it */
int     Sflag = 0;      /* generate assembly files */
int     cflag = 0;      /* generate ".s" files only */
int     Oflag = 0;      /* run the optimizer */
int     tflag = 0;      /* generate a symbol table in executables */
int     pflag = 0;      /* enable execution profiling */
int     fflag = 0;      /* enable floating point */

/*
 * We build lists of the various file types we're given. Within each
 * type, MAXF says how many we can deal with.
 */
#define MAXF    30

int     ncfiles = 0;    /* .c files */
char    *cfiles[MAXF];
int     nsfiles = 0;    /* .s files */
char    *sfiles[MAXF];
int     nofiles = 0;    /* .o files */
char    *ofiles[MAXF];
int     nlfiles = 0;    /* .a or .lib files (or files with no suffix) */
char    *lfiles[MAXF];

char    *output = NULL; /* output file */

/*-------------------------------------------------------------------------
 * added/changed for v1.01d
 *------------------------------------------------------------------------*/
#define MAXCMDV 64
char    cmdln[130];     /* Command image passed to compiler pieces.       */
char    cmdinp[255];    /* Interactive keyin command buffer.              */
char    *cmdv[MAXCMDV]; /* cmdv/cmdc = argv/argc.  Made global to make the*/
int     cmdc;           /* command input source transparent to main logic.*/
/*-------------------------------------------------------------------------
 * end of v1.01d changes
 *------------------------------------------------------------------------*/

myexit(n)
int     n;
{
        fprintf(stderr, "<Press RETURN to continue>\n");
        while (getchar() != '\n')
                ;
        exit(n);
}

mklower(s)
register char   *s;
{
        for (; *s ;s++) {
                if (isupper(*s))
                        *s = tolower(*s);
        }
}

usage()
{
        fprintf(stderr,
                "\nSozobon C Compiler Options:\n");
        fprintf(stderr,
                "-C             compile, but don't link\n");
        fprintf(stderr,
                "-Z             run the assembly code optimizer\n");
        fprintf(stderr,
                "-S             don't assemble, leave .s files around\n");
        fprintf(stderr,
                "-V             show the passes and versions as they run\n");
        fprintf(stderr,
                "-N             like -v, but don't really run anything\n");
        fprintf(stderr,
                "-M             tell the loader to generate a load map\n");
        fprintf(stderr,
                "-T             tell the loader to generate a symbol table\n");
        fprintf(stderr,
                "-F             link the floating point library\n");
        fprintf(stderr,
                "-P             enable execution profiling\n");
        fprintf(stderr,
                "-O f           use the file 'f' for the loader output\n");
        fprintf(stderr,
                "-Ilib          add dir. 'lib' to the header search list\n");
        fprintf(stderr,
                "-Dsym          define the pre-processor symbol 'sym' as 1\n");
        fprintf(stderr,
                "-Dsym=val      or as 'val'\n");
        fprintf(stderr,
                "-Usym          un-define the built-in symbol 'sym'\n");

}

/*-------------------------------------------------------------------------
 *
 * Begin v1.01d hack code to make 'cc' desktop-friendly.
 *
 *  (You'll see a decidedly different (read: un-unix) programming style
 *   in here.  Specifically, you won't find yourself 42 levels deep in 
 *   function calls before you hit a line of code that *does* something).
 *-----------------------------------------------------------------------*/

/*---------------------------------------------------------------------
 * Copy 'count' strings pointed to by elements in the array 'pointers'
 * into the interactive-keyin command line buffer.  As each string is
 * copied, save a pointer to it into the 'cmdv' array.  ('cmdv' takes the
 * place of 'argv' in the code found in 'main()').  Upon exit, cmdc
 * will count the count of cmdv array elements.
 *-------------------------------------------------------------------*/

cmd_copy(count, pointers)
int     count;
char    *pointers[];
{
        char    *p_wrk1, 
                *p_wrk2;

        p_wrk1 = cmdinp;
        for (cmdc = 0; cmdc < count; cmdc++)
                {
                cmdv[cmdc] = p_wrk1;
                p_wrk2 = pointers[cmdc];
                while (*p_wrk1++ = *p_wrk2++)
                        {}
                }          
}

/*-------------------------------------------------------------------------
 *
 * Note to self: included from \ian\libi\bldargv.c 
 *
 * BldArgv --  Scan a string, setting pointers to the space-delimited
 *             words within it.  Null terminate each word except the
 *             last (which should already be null terminated, anyway).
 *             Strip leading spaces from the args (that is...point
 *             past them).
 *
 *   Usage:
 *        Pass this routine a pointer to an array which will hold
 *        the pointers to the arguments, a pointer to the string buffer,
 *        and the maximum number of pointers your array can hold. It
 *        will return the number of pointers generated.  Note that if
 *        there are more words in the buffer than you have pointer slots
 *        for, the last pointer will be to the remainder of the buffer.
 *
 *        Confused?  Check this out:
 *
 *             char string[] = "    c:\test.prg   arga   argb   argc"
 *             char *argv[3];
 *             numargs = bldargv(argv,string,3);
 *
 *        This sequence will yield the following:
 *
 *             numargs = 3
 *             argv[0] -> "c:\test.prg"
 *             argv[1] -> "arga"
 *             argv[2] -> "argb   argc"
 *
 *        Note that the leading spaces were removed from the arguments,
 *        but the imbedded spaces within the 'rest of the buffer' 3rd
 *        arg were left intact.
 *
 * Maintenance:
 *  04/13/87 - Original version. 
 *
 *------------------------------------------------------------------------*/

bldargv(argv, p_strbuf, maxarg)
register char *argv[], *p_strbuf;
int  maxarg;
{
        int  argc;

        argc = 0;
        while(*p_strbuf)
                {
                while (*p_strbuf == ' ')
                        p_strbuf++;
                if (*p_strbuf)
                        {
                        argv[argc++] = p_strbuf;
                        while (*p_strbuf && (*p_strbuf != ' '))
                                p_strbuf++;
                        if (*p_strbuf == ' ')
                                *p_strbuf++ = 0x00;
                        if (argc == maxarg)
                                return(argc);
                        }
                }
return(argc);
}

/*-------------------------------------------------------------------------
 * ask() - Read line from std input, convert to normal str, return length. 
 *  Note that this uses the native DOS function Cconrs() to get the string.
 *  If the user has redirected I/O in some way, we don't want the machine
 *  to lock up, we want to be able to talk with the user...
 *------------------------------------------------------------------------*/

ask(str,maxlen)
register char *str;
int  maxlen;
{
        register int  length,counter;
        register char *p_wrk1, *p_wrk2;

        *str = (char)maxlen;
        Cconrs(str);
        Cconws("\r\n"); /* hack: fixes bug in TurboST 'Cconrs' hook. */
        length = counter = (int)*(str+1);
        p_wrk2 = 2 + (p_wrk1 = str);
        while (counter--)
                *p_wrk1++ = *p_wrk2++;
        *p_wrk1 = 0x00;
        return(length);
}

/*-------------------------------------------------------------------------
 * interactive_input - Ask the user for the parms, parse them into args.
 *  Note that this uses the native DOS function Cconws() for output.
 *  If the user has redirected I/O in some way, we don't want the machine
 *  to lock up, we want to be able to talk with the user...
 *  (Oh yuck, it has a 'goto' in it...)
 *------------------------------------------------------------------------*/

interactive_input()
{
reprompt:
        Cconws("\r\nccd: Enter command line, '?' for help, <CR> to exit...\r\n");

        if (0 == ask(cmdinp, sizeof(cmdinp)))
                myexit(1);                      /* exit on <CR> */

        if (cmdinp[0] == '?')
                {
                usage();                        /* show help if requested */
                goto reprompt;                  /* then prompt again. */
                }

        cmdc = 1 + bldargv(&cmdv[1], cmdinp, MAXCMDV); 
}

/*-------------------------------------------------------------------------
 *
 * End of v1.01d desktop-friendly hack.  
 *  We now return you to your regularly-scheduled program...
 *
 *-----------------------------------------------------------------------*/

main(argc, argv)
int     argc;
char    *argv[];
{
        extern  char    *chsuf();
        register int    i;
        register char   *s;
        register int    endopt;
        int     domsg = FALSE;

/*------------------------------------------------------------------------
 * added for v1.01d
 *-----------------------------------------------------------------------*/
        if (argc == 1)                  /* if no cmdlin args, prompt     */
                interactive_input();    /* user for them interactively,  */
        else                            /* else copy cmdlin args to      */
                cmd_copy(argc, argv);   /* global buffer/pointer array.  */
/*------------------------------------------------------------------------
 * end of v1.01d changes
 *-----------------------------------------------------------------------*/

        for (i=1; i < cmdc ;i++) {
                mklower(cmdv[i]);       /* v1.01d: force arg to lowercase */
                if (cmdv[i][0] == '-') {        /* option */ 
                        endopt = FALSE;
                        for (s = &cmdv[i][1]; *s && !endopt ;s++) {
                                switch (*s) {
                                case 'c':
                                case 'C':
                                        cflag = TRUE; break;
                                case 'Z':
                                case 'z':
                                        Oflag = TRUE; break;
                                case 'S':
                                case 's':
                                        Sflag = TRUE; break;
                                case 'v':
                                case 'V':
                                        vflag = TRUE; break;
                                case 'n':
                                case 'N':
                                        nflag = TRUE; break;
                                case 'm':
                                case 'M':
                                        mflag = TRUE; break;
                                case 't':
                                case 'T':
                                        tflag = TRUE; break;
                                case 'f':
                                case 'F':
                                        fflag = TRUE; break;
                                case 'p':
                                case 'P':
                                        pflag = TRUE; break;
                                case 'o':
                                case 'O':
                                        output = cmdv[++i];
                                        endopt = TRUE;
                                        break;
                                /*
                                 * Options for other passes.
                                 */
                                case 'I':       /* compiler options */
                                case 'D':
                                case 'U':
                                        hccopt[hcc_cnt++] = cmdv[i];
                                        endopt = TRUE;
                                        break;
                                default:
                                        usage();
                                        myexit(1);
                                }
                        }
                } else {                /* input file */
                        if (output == NULL)
                                output = chsuf(cmdv[i], ".ttp");

                        keepfile(cmdv[i]);
                }
        }

        if ((ncfiles + nsfiles) > 1)
                domsg = TRUE;

        doinit();

        if (vflag)
                printf("%s\n", Version);

        for (i = 0; i < ncfiles ;i++) {
                if (domsg)
                        printf("%s:\n", cfiles[i]);
                docomp(cfiles[i]);
                doopt(cfiles[i]);
                doasm(cfiles[i], TRUE);
        }

        for (i = 0; i < nsfiles ;i++) {
                if (domsg)
                        printf("%s:\n", sfiles[i]);
                doasm(sfiles[i], FALSE);
        }

        dold();         /* run the loader */

        myexit(0);
}

/*
 * doinit() - set up some variables before getting started
 */
doinit()
{
        path = DEFPATH;
        lib = DEFLIB;
        tmp = DEFTMP;
}

/*
 * keepfile(f) - remember the filename 'f' in the appropriate place
 */
keepfile(f)
char    *f;
{
        char    *p, *strchr();

        if ((p = strchr(f, '.')) == NULL) {     /* no suffix */
                lfiles[nlfiles++] = f;
                return;
        }

        if (strcmp(p, ".c") == 0) {
                cfiles[ncfiles++] = f;
                return;
        }
        if (strcmp(p, ".s") == 0) {
                sfiles[nsfiles++] = f;
                return;
        }
        if (strcmp(p, ".o") == 0) {
                ofiles[nofiles++] = f;
                return;
        }
        if (strcmp(p, ".a") == 0) {
                lfiles[nlfiles++] = f;
                return;
        }
        if (strcmp(p, ".lib") == 0) {
                lfiles[nlfiles++] = f;
                return;
        }
        fprintf(stderr, "cc: unknown file suffix '%s'\n", f);
        myexit(1);
}

/*
 * chsuf(f, suf) - change the suffix of file 'f' to 'suf'.
 *
 * Space for the new string is obtained using malloc().
 */
char *
chsuf(f, suf)
char    *f;
char    *suf;
{
        char    *malloc();
        char    *s, *p;

        p = s = malloc(strlen(f) + strlen(suf) + 1);

        strcpy(p, f);

        for (; *p ; p++) {
                if (*p == '.')
                        break;
        }

        while (*suf)
                *p++ = *suf++;

        *suf = '\0';

        return s;
}

/*
 * isfile(f) - return true if the given file exists
 */
int
isfile(f)
char    *f;
{
        int     fd;

        if ((fd = open(f, O_RDONLY)) < 0)
                return FALSE;

        close(fd);
        return TRUE;
}

/*
 * findfile(e, b, s, chknul)
 *
 * Finds a file in one of the directories given in the environment
 * variable whose value is pointed to by 'e'. Looks for the file
 * given by 'b' with one of the suffixes listed in 's'. The suffix
 * string should contain suffixes delimited by commas.
 *
 * e.g.  findfile("env stuff", "hcc", ".tos,.ttp,.prg")
 *
 * Returns a pointer to a static area containing the pathname of the
 * file, if found, NULL otherwise.
 *
 * If 'chknul' is set, try the base name without any suffix as well.
 */
char *
findfile(e, b, s, chknul)
char    *e;
char    *b;
char    *s;
int     chknul;
{
        static  char    file[256];
        char    env[256];
        char    suf[128];
        char    *eptr, *sptr;
        char    *p;

        /*
         * Make a copy of the value of the env. variable. Convert all
         * delimiters to nulls.
         */
        if (e != NULL) {
                strcpy(env, e);
                for (p = env; *p ;p++) {
                        if (*p == ';' || *p == ',')
                                *p = '\0';
                }
                p[1] = '\0';            /* double null terminator */
        } else
                env[1] = env[0] = '\0';

        strcpy(suf, s);
        for (p = suf; *p ;p++) {
                if (*p == ',')
                        *p = '\0';
        }
        p[1] = '\0';            /* double null terminator */

        /*
         * Always check the root of the current drive and the
         * current directory first. If that doesn't work, then
         * start looking in the usual places...
         */
        for (sptr = suf; *sptr ;) {

                sprintf(file, "%s%s", b, sptr);

                if (isfile(file))
                        return file;

                sprintf(file, "\\%s%s", b, sptr);

                if (isfile(file))
                        return file;

                while (*sptr++ != '\0')
                        ;
        }

        for (eptr = env; *eptr ;) {
                if (chknul) {
                        sprintf(file, "%s\\%s", eptr, b);
                        if (isfile(file))
                                return file;
                }

                for (sptr = suf; *sptr ;) {

                        sprintf(file, "%s\\%s%s", eptr, b, sptr);

                        if (isfile(file))
                                return file;

                        while (*sptr++ != '\0')
                                ;
                }
                while (*eptr++ != '\0')
                        ;
        }
        return NULL;            /* give up */
}

/*
 * docmd(path, cmdline) - run a command
 */
int
docmd(path, cmdline)
char    *path;
char    *cmdline;
{
        int     i;
        char    cmd[150];

        strcpy(&cmd[1], cmdline);
        cmd[0] = strlen(cmdline);

        i = Pexec(0, path, cmd, 0L);

        return i;
}

/*
 * docomp(f) - run the compiler on the given .c file
 */
docomp(f)
char    *f;
{
        int     i;
        char    *cpath, *sf;

        if ((cpath = findfile(path, CC, EXSUF, FALSE)) == NULL) {
                fprintf(stderr, "cc: can't find compiler program '%s'\n", CC);
                myexit(1);
        }

        strcpy(cmdln, pflag ? "-P " : "");

        for (i=0; i < hcc_cnt ;i++) {
                strcat(cmdln, hccopt[i]);
                strcat(cmdln, " ");
        }
        strcat(cmdln, f);

        if (nflag || vflag)
                fprintf(stderr, "%s %s\n", cpath, cmdln);

        if (!nflag) {
                if (docmd(cpath, cmdln)) {
                        sf = chsuf(f, ".s");
                        unlink(sf);
                        free(sf);
                        fprintf(stderr, "cc: compiler failed\n");
                        myexit(1);
                }
        }
}

/*
 * doopt(f) - run the optimizer
 *
 * Only optimize files that were produced by the compiler.
 */
doopt(f)
char    *f;
{
        int     i;
        char    *opath;
        char    *sf;

        if (!Oflag)
                return;

        if ((opath = findfile(path, OPT, EXSUF, FALSE)) == NULL) {
                fprintf(stderr, "cc: can't find optimizer program '%s'\n", OPT);
                myexit(1);
        }

        sf = chsuf(f, ".s");

        if (nflag || vflag)
                fprintf(stderr, "%s %s %s\n",
                        opath, sf, OTMP);

        if (!nflag) {
                sprintf(cmdln, "%s %s", sf, OTMP);
                if (docmd(opath, cmdln)) {
                        unlink(OTMP);
                        fprintf(stderr, "cc: optimizer failed (continuing)\n");
                        unlink(OTMP);
                } else {
                        unlink(sf);
                        rename(OTMP, sf);
                }
        }
        free(sf);
}

/*
 * doasm() - run the assembler
 *
 * If 'istmp' is TRUE, the file we were given is a temporary
 */
doasm(f, istmp)
char    *f;
int     istmp;
{
        char    *strrchr();
        int     i;
        char    apath[128], *dpath;
        char    *s;
        char    *sf;

        if (Sflag)
                return;

        if ((dpath = findfile(path, ASM, EXSUF, FALSE)) == NULL) {
                fprintf(stderr, "cc: can't find assembler program '%s'\n", ASM);
                myexit(1);
        }
        strcpy(apath, dpath);

        dpath = NULL;

        sf = chsuf(f, ".s");

        if (nflag || vflag)
                fprintf(stderr, "%s -l -u%s%s %s\n",
                        apath,
                        (dpath != NULL) ? " -s " : "",
                        (dpath != NULL) ? dpath : "",
                        sf);

        if (!nflag) {
                sprintf(cmdln, "%s%s %s",
                        (dpath != NULL) ? "-l -u -s " : "",
                        (dpath != NULL) ? dpath : "",
                        sf);

                if (docmd(apath, cmdln)) {
                        fprintf(stderr, "cc: assembler failed '%s'\n",
                                sf);
                        if (istmp)
                                unlink(sf);
                        free(sf);
                        myexit(1);
                }
        }

        if (nflag) {
                free(sf);
                return;
        }

        if (istmp)
                unlink(sf);

        free(sf);
}

/*
 * dold() - run the loader
 */
dold()
{
        FILE    *fp, *fopen();
        int     i;
        char    tfile[128];
        char    *lpath;
        char    *s;
        char    *l;

        if (cflag || Sflag)
                return;

        /*
         * Construct the name of the loader data file.
         */
        if (*tmp != '\0') {
                strcpy(tfile, tmp);
                if (tfile[strlen(tfile)-1] != '\\')
                        strcat(tfile, "\\");
        } else
                tfile[0] = '\0';

        strcat(tfile, LTMP);

        unlink(tfile);
        /*
         * Construct loader command file
         */
        if ((fp = fopen(tfile, "w")) == NULL) {
                fprintf(stderr, "cc: can't open loader temp file\n");
                myexit(1);
        }

        l = pflag ? PCSU : CSU;
        if ((lpath = findfile(lib, l, "", TRUE)) == NULL) {
                fprintf(stderr, "cc: can't find C startup code '%s'\n", l);
                myexit(1);
        }
        fprintf(fp, "%s\n", lpath);

        for (i = 0; i < ncfiles ;i++) {
                s = chsuf(cfiles[i], ".o");
                fprintf(fp, "%s\n", s);
                free(s);
        }
        for (i = 0; i < nsfiles ;i++) {
                s = chsuf(sfiles[i], ".o");
                fprintf(fp, "%s\n", s);
                free(s);
        }
        for (i = 0; i < nofiles ;i++)
                fprintf(fp, "%s\n", ofiles[i]);

        for (i = 0; i < nlfiles ;i++) {
                if (isfile(lfiles[i])) {
                        fprintf(fp, "%s\n", lfiles[i]);
                } else {
                        lpath = findfile(lib, lfiles[i], LIBSUF, TRUE);
                        if (lpath == NULL) {
                                fprintf(stderr, "cc: can't find library '%s'\n", lfiles[i]);
                                myexit(1);
                        }
                        fprintf(fp, "%s\n", lpath);
                }
        }

        if (fflag) {
                l = pflag ? PLIBM : LIBM;
                if ((lpath = findfile(lib, l, LIBSUF, TRUE)) == NULL) {
                        fprintf(stderr, "cc: can't find floating point library '%s'\n",l);
                        myexit(1);
                }
                fprintf(fp, "%s\n", lpath);
        }

        l = pflag ? PLIBC : LIBC;
        if ((lpath = findfile(lib, l, LIBSUF, TRUE)) == NULL) {
                fprintf(stderr, "cc: can't find C runtime library '%s'\n", l);
                myexit(1);
        }
        fprintf(fp, "%s\n", lpath);

        fclose(fp);

        if ((lpath = findfile(path, LD, EXSUF, FALSE)) == NULL) {
                fprintf(stderr, "cc: can't find loader program '%s'\n", LD);
                myexit(1);
        }

        sprintf(cmdln, "%s%s-p -u _main %s -o %s -f %s",
                mflag ? "-m " : "",
                tflag ? "-t " : "",
                fflag ? "-u __printf -u __scanf " : "",
                output,
                tfile);

        if (nflag || vflag)
                fprintf(stderr, "%s %s\n", lpath, cmdln);

        if (!nflag) {
                if (docmd(lpath, cmdln)) {
                        fprintf(stderr, "cc: loader failed\n");
                        unlink(tfile);
                        unlink(output);
                        myexit(1);
                }
        }

        if (nflag)
                return;

        for (i = 0; i < ncfiles ;i++) {
                s = chsuf(cfiles[i], ".o");
                unlink(s);
                free(s);
        }

        for (i = 0; i < nsfiles ;i++) {
                s = chsuf(sfiles[i], ".o");
                unlink(s);
                free(s);
        }

        unlink(tfile);
}
