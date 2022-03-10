
/* "makeproto"  Copyright 1989, 1990, 1991 Free Software Foundation */


/* Program to scan old-style source files and make prototypes */



#include <stdio.h>
#include <ctype.h>
#include <time.h>

#ifdef FILE       /* a #define in BSD, a typedef in SYSV (hp-ux, at least) */
# ifndef BSD
#  define BSD 1
# endif
#endif

#ifdef BSD
# include <strings.h>
#else
# include <string.h>
#endif



#define isidchar(x)    (isalnum(x) || (x) == '_')

#define dprintf        if (!debug) ; else printf

#define MAXARGS        16



int verbose, debug, incomment;


struct warnstruct {
    char *bad, *good;
} warntypes[] = {
    { "char",             "int" },
    { "signed char",      "int" },
    { "unsigned char",    "int" },
    { "short",            "int" },
    { "signed short",     "int" },
    { "unsigned short",   "int" },
    { "boolean",          "int" },
    { "Boolean",          "int" },
    { "float",            "double" },
    { NULL, NULL }
} ;



int readline(buf, inf)
char *buf;
FILE *inf;
{
    char *cp, *cp2;
    int spflag;

    for (;;) {
        if (fgets(buf, 1000, inf)) {
            cp = buf;
            cp2 = buf;
            spflag = 0;
            while (*cp) {
                if (incomment) {
                    if (cp[0] == '*' && cp[1] == '/') {
                        incomment = 0;
                        cp += 2;
                    } else
                        cp++;
                    spflag = 1;
                } else {
                    if (cp[0] == '/' && cp[1] == '*') {
                        incomment = 1;
                        cp += 2;
                    } else if (isspace(*cp)) {
                        spflag = 1;
                        cp++;
                    } else {
                        if (spflag)
                            *cp2++ = ' ';
                        *cp2++ = *cp++;
                        spflag = 0;
                    }
                }
            }
            *cp2 = 0;
            if (!*buf)
                continue;
            if (verbose)
                printf("\217%s\210\n", buf);
            return 1;
        } else
            strcpy(buf, "\001");
            return 0;
    }
}




int strbeginsword(s1, s2)
register char *s1, *s2;
{
    while (*s2 && *s1 == *s2)
        s1++, s2++;
    return (!*s2 && !isidchar(*s1));
}




void usage()
{
    fprintf(stderr, "usage:  makeproto [options] [infile ...] [-o outfile]]\n");
    fprintf(stderr, "           -tnnn   Tab to nnn after type name [default 15]\n");
    fprintf(stderr, "           -annn   Tab to nnn before arguments [default 30]\n");
    fprintf(stderr, "           -s0     Omit functions declared static\n");
    fprintf(stderr, "           -s1     Omit functions not declared static\n");
    fprintf(stderr, "           -x      Add \"extern\" keyword (-X => \"Extern\")\n");
    fprintf(stderr, "           -n      Include argument names in prototypes\n");
    fprintf(stderr, "           -m      Use PP/PV macro notation\n");
    exit(1);
}




#define bounce(msg)   do {  if (verbose) printf("Bounced: %s\n", msg); if (stupid) goto Lbounce;  } while (0)





main(argc, argv)
int argc;
char **argv;
{
    FILE *inf, *outf;
    char outfname[256];
    char buf[1000], ifdefname[256];
    char ftype[256], fname[80], dtype[256], decl[256], dname[80], temp[256];
    char argdecls[MAXARGS][256], argnames[MAXARGS][80];
    char *cp, *cp2, *cp3;
    int i, j, pos, len, thistab, numstars, whichf, nargs, incomment, errors = 0;
    long li;
    int typetab = 15, argtab = 30, width = 80, usenames = 0, usemacros = 0;
    int useextern = 0, staticness = -1, hasheader = 0, useifdefs = 0;
    int stupid = 1, firstdecl;

    errors = 0;
    verbose = 0;
    debug = 0;
    *outfname = 0;
    while (argc > 1 && argv[1][0] == '-') {
        if (argv[1][1] == 't') {
            typetab = atoi(argv[1] + 2);
        } else if (argv[1][1] == 'a') {
            argtab = atoi(argv[1] + 2);
        } else if (argv[1][1] == 'w') {
            width = atoi(argv[1] + 2);
        } else if (argv[1][1] == 's') {
            staticness = atoi(argv[1] + 2);
        } else if (argv[1][1] == 'v') {
            verbose = 1;
        } else if (argv[1][1] == 'D') {
            debug = 1;
        } else if (argv[1][1] == 'x') {
            useextern = 1;
        } else if (argv[1][1] == 'X') {
            useextern = 2;
        } else if (argv[1][1] == 'n') {
            usenames = 1;
        } else if (argv[1][1] == 'm') {
            usemacros = 1;
        } else if (argv[1][1] == 'h') {
            hasheader = 1;
        } else if (argv[1][1] == 'i') {
            useifdefs = 1;
        } else if (argv[1][1] == 'o' && argc > 2) {
            strcpy(outfname, argv[2]);
            argc--, argv++;
        } else {
            usage();
        }
        argc--, argv++;
    }
    if (argc > 2 && !strcmp(argv[argc-2], "-o")) {
        strcpy(outfname, argv[argc-1]);
        argc -= 2;
    }
    if (*outfname) {
        outf = fopen(outfname, "w");
        if (!outf) {
            perror(outfname);
            exit(1);
        }
    } else
        outf = stdout;
    if (hasheader) {
        time(&li);
        cp = ctime(&li);
        cp[24] = 0;
        fprintf(outf, "\n/* Declarations created by \"makeproto\" on %s */\n", cp);
        fprintf(outf, "\n\n");
    }
    incomment = 0;
    for (whichf = 1; whichf < argc + (argc < 2); whichf++) {
        if (whichf >= argc || !strcmp(argv[whichf], "-")) {
            inf = stdin;
        } else {
            inf = fopen(argv[whichf], "r");
            if (!inf) {
                perror(argv[whichf]);
                fprintf(outf, "\n/* Unable to open file %s */\n", argv[whichf]);
                errors++;
                continue;
            }
        }
        firstdecl = 1;
        while (readline(buf, inf)) {
            if (!isidchar(*buf))
                continue;
            cp = buf;
            cp2 = ftype;
            numstars = 0;
            while (isspace(*cp) || isidchar(*cp))
                *cp2++ = *cp++;
            if (*cp == '*') {
                while (*cp == '*' || isspace(*cp)) {
                    if (*cp == '*')
                        numstars++;
                    cp++;
                }
            } else {
                while (cp > buf && isspace(cp[-1])) cp--, cp2--;
                while (cp > buf && isidchar(cp[-1])) cp--, cp2--;
            }
            while (cp2 > ftype && isspace(cp2[-1])) cp2--;
            *cp2 = 0;
            if (!*ftype)
                strcpy(ftype, "int");
            dprintf("numstars is %d\n", numstars);   /***/
            dprintf("ftype is %s\n", ftype);     /***/
            dprintf("cp after ftype is %s\n", cp);     /***/
            if (strbeginsword(ftype, "static") || strbeginsword(ftype, "Static")) {
                if (staticness == 0)
                    bounce("Function is static");
            } else {
                if (staticness == 1)
                    bounce("Function is not static");
                if (useextern &&
                     !strbeginsword(ftype, "extern") && !strbeginsword(ftype, "Extern")) {
                    sprintf(temp, useextern == 2 ? "Extern %s" : "extern %s", ftype);
                    strcpy(ftype, temp);
                }
            }
            while (isspace(*cp)) cp++;
            if (!*cp) {
                readline(buf, inf);
                cp = buf;
            }
            dprintf("cp before fname is %s\n", cp);     /***/
            if (!isidchar(*cp))
                bounce("No function name");
            cp2 = fname;
            while (isidchar(*cp))
                *cp2++= *cp++;
            *cp2 = 0;
            dprintf("fname is %s\n", fname);     /***/
            dprintf("cp after fname is %s\n", cp);     /***/
            while (isspace(*cp)) cp++;
            if (*cp++ != '(')
                bounce("No function '('");
            nargs = 0;
            if (!*cp) {
                readline(buf, inf);
                cp = buf;
            }
            while (isspace(*cp)) cp++;
            while (*cp != ')') {
                if (!isidchar(*cp))
                    bounce("Missing argument name");
                if (nargs >= MAXARGS)
                    bounce("Too many arguments");
                cp2 = argnames[nargs];
                argdecls[nargs][0] = 0;
                nargs++;
                while (isidchar(*cp))
                    *cp2++ = *cp++;
                *cp2 = 0;
                dprintf("Argument %d is named %s\n", nargs-1, argnames[nargs-1]);    /***/
                while (isspace(*cp)) cp++;
                if (*cp == ',') {
                    cp++;
                    if (!*cp) {
                        readline(buf, inf);
                        cp = buf;
                    }
                    while (isspace(*cp)) cp++;
                } else if (*cp != ')')
                    bounce("Missing function ')'");
            }
            if (cp[1])
                bounce("Characters after function ')'");
            readline(buf, inf);
            cp = buf;
            for (;;) {
                while (isspace(*cp)) cp++;
                if (isidchar(*cp)) {
                    cp2 = dtype;
                    if (strbeginsword(cp, "register")) {
                        cp += 8;
                        while (isspace(*cp)) cp++;
                    }
                    while (isspace(*cp) || isidchar(*cp))
                        *cp2++ = *cp++;
                    if (*cp == ',' || *cp == ';' || *cp == '[') {
                        while (cp2 > dtype && isspace(cp2[-1])) cp--, cp2--;
                        while (cp2 > dtype && isidchar(cp2[-1])) cp--, cp2--;
                    } else if (*cp != '(' && *cp != '*')
                        bounce("Strange character in arg decl");
                    while (cp2 > dtype && isspace(cp2[-1])) cp2--;
                    *cp2 = 0;
                    if (!*dtype)
                        bounce("Empty argument type");
                    for (;;) {
                        cp2 = decl;
                        cp3 = dname;
                        while (*cp == '*' || *cp == '(' || isspace(*cp))
                            *cp2++ = *cp++;
                        if (!isidchar(*cp))
                            bounce("Missing arg decl name");
                        while (isidchar(*cp)) {
                            if (usenames)
                                *cp2++ = *cp;
                            *cp3++ = *cp++;
                        }
                        if (!usenames) {
                            while (cp2 > decl && isspace(cp2[-1])) cp2--;
                            while (isspace(*cp)) cp++;
                        }
                        i = 0;
                        while (*cp && *cp != ';' && (*cp != ',' || i > 0)) {
                            if (*cp == '(' || *cp == '[') i++;
                            if (*cp == ')' || *cp == ']') i--;
                            *cp2++ = *cp++;
                        }
                        *cp2 = 0;
                        *cp3 = 0;
                        dprintf("Argument %s is %s\n", dname, decl);     /***/
                        if (i > 0)
                            bounce("Unbalanced parens in arg decl");
                        if (!*cp)
                            bounce("Missing ';' or ',' in arg decl");
                        for (i = 0; i < nargs && strcmp(argnames[i], dname); i++) ;
                        if (i >= nargs)
                            bounce("Arg decl name not in argument list");
                        if (*decl)
                            sprintf(argdecls[i], "%s %s", dtype, decl);
                        else
                            strcpy(argdecls[i], dtype);
                        if (*cp == ',') {
                            cp++;
                            if (!*cp) {
                                readline(buf, inf);
                                cp = buf;
                            }
                            while (isspace(*cp)) cp++;
                        } else
                            break;
                    }
                    cp++;
                    if (!*cp) {
                        readline(buf, inf);
                        cp = buf;
                    }
                } else
                    break;
            }
            if (*cp != '{')
                bounce("Missing function '{'");
            if (firstdecl) {
                firstdecl = 0;
                if (argc > 2)
                    fprintf(outf, "\n/* Declarations from %s */\n", argv[whichf]);
                if (useifdefs && inf != stdin) {
                    strcpy(ifdefname, argv[whichf]);
		    cp = ifdefname;
		    for (cp2 = ifdefname; *cp2; ) {
			if (*cp2++ == '/')
			    cp = cp2;
		    }
                    for (cp2 = ifdefname; *cp; cp++, cp2++) {
		        if (islower(*cp))
			    *cp2 = toupper(*cp);
                        else if (isalnum(*cp))
                            *cp2 = *cp;
                        else
                            *cp2 = '_';
                    }
                    fprintf(outf, "#ifdef PROTO_%s\n", ifdefname);
                }
            }
            for (i = 0; i < nargs; i++) {
                if (!argdecls[i][0])
                    sprintf(argdecls[i], "int %s", argnames[i]);
                for (j = 0; warntypes[j].bad &&
                            !strbeginsword(argdecls[i], warntypes[j].bad); j++) ;
                if (warntypes[j].bad) {
                    cp = argdecls[i];
                    while (isspace(*cp) || isidchar(*cp)) cp++;
                    if (!*cp) {     /* not, e.g., "char *" */
                        sprintf(temp, "%s%s", warntypes[j].good,
                                              argdecls[i] + strlen(warntypes[j].bad));
                        strcpy(argdecls[i], temp);
                        fprintf(stderr, "Warning: Argument %s of %s has type %s\n",
                                        argnames[i], fname, warntypes[j]);
                    }
                }
            }
            if (verbose && outf != stdout)
                printf("Found declaration for %s\n", fname);
            fprintf(outf, "%s", ftype);
            pos = strlen(ftype) + numstars;
            do {
                putc(' ', outf);
                pos++;
            } while (pos < typetab);
            for (i = 1; i <= numstars; i++)
                putc('*', outf);
            fprintf(outf, "%s", fname);
            pos += strlen(fname);
            do {
                putc(' ', outf);
                pos++;
            } while (pos < argtab);
            if (nargs == 0) {
                if (usemacros)
                    fprintf(outf, "PV();");
                else
                    fprintf(outf, "(void);");
            } else {
                if (usemacros)
                    fprintf(outf, "PP( ("), pos += 5;
                else
                    fprintf(outf, "("), pos++;
                thistab = pos;
                for (i = 0; i < nargs; i++) {
                    len = strlen(argdecls[i]);
                    if (i > 0) {
                        putc(',', outf);
                        pos++;
                        if (pos > thistab && pos + len >= width) {
                            putc('\n', outf);
                            for (j = 1; j <= thistab; j++)
                                putc(' ', outf);
                            pos = thistab;
                        } else {
                            putc(' ', outf);
                            pos++;
                        }
                    }
                    fprintf(outf, "%s", argdecls[i]);
                    pos += len;
                }
                if (usemacros)
                    fprintf(outf, ") );");
                else
                    fprintf(outf, ");");
            }
            putc('\n', outf);
Lbounce: ;
        }
        if (inf != stdin) {
            if (useifdefs && !firstdecl)
                fprintf(outf, "#endif /*PROTO_%s*/\n", ifdefname);
            fclose(inf);
        }
    }
    if (hasheader) {
        fprintf(outf, "\n\n/* End. */\n\n");
    }
    if (outf != stdout)
        fclose(outf);
    if (errors)
        exit(1);
    else
        exit(0);
}



/* End. */



