
/*
 *
 * Copyright (C) 1987   Pehong Chen     (phc@renoir.berkeley.edu)
 * Computer Science Division
 * University of California, Berkeley
 *
 */

#include        "mkind.h"

int             letter_ordering = FALSE;
int             compress_blanks = FALSE;
int             merge_page = TRUE;
int             init_page = FALSE;
int             even_odd = -1;
int             verbose = TRUE;
int             fn_no = -1;     /* total number of files */
int             idx_dot = TRUE; /* flag which shows dot in ilg being active */
int             idx_tt = 0;     /* total entry count of all files */
int             idx_et = 0;     /* erroneous entry count of all files */
int             idx_gt = 0;     /* good entry count of all files */

FIELD_PTR       *idx_key;
FILE            *log_fp;
FILE            *sty_fp;
FILE            *idx_fp;
FILE            *ind_fp;
FILE            *ilg_fp;
char            *pgm_fn;
char            sty_fn[LINE_MAX];
char            *idx_fn;
char            ind[STRING_MAX];
char            *ind_fn;
char            ilg[STRING_MAX];
char            *ilg_fn;
char            pageno[STRING_MAX];
static char     log_fn[STRING_MAX];
static char     base[STRING_MAX];
static int      need_version = TRUE;

#if (OS_ATARI & ATARI_TURBO_C)
int access(const char *filename, int amode); /* Prototype access */

#include <ext.h>
#include <errno.h>

#pragma warn -par                           /*Set warning to off */
int access(const char *name, int amode)
{       struct ffblk dta;
        amode = ((amode & 0x02) ? 0x16 : 0x17);
        return((int)(findfirst((char *)name, &dta, amode) != 0 /* E_OK */));
}
#endif /* ATARI */
main(argc, argv)
        int             argc;
        char            *argv[];
{
        char            *fns[LONG_MAX];
        char            *ap;
        int             use_stdin = FALSE;
        int             sty_given = FALSE;
        int             ind_given = FALSE;
        int             ilg_given = FALSE;
        int             log_given = FALSE;

        /* determine program name */
#if OS_VAXVMS
        pgm_fn = "makeindex";   /* Use symbolic name on VAX/VMS systems */
#elif OS_ATARI
        pgm_fn = "makeindx";    /* Use symbolic 8-character name on Atari ST */
#else /* NOT OS_VAXVMS */
        pgm_fn = rindex(*argv, DIR_DELIM);
        if (pgm_fn == NULL)
                pgm_fn = *argv;
        else
                pgm_fn++;
#endif /* OS_VAXVMS */

        /* process command line options */
        while (--argc > 0) {
                if (**++argv == SW_PREFIX) {
                        if (*(*argv+1) == NULL)
                                break;
                        for (ap = ++*argv; *ap != NULL; ap++)
                                switch (*ap) {

                                /* use standard input */
                                case 'i':
                                        use_stdin = TRUE;
                                        break;

                                /* enable letter ordering */
                                case 'l':
                                        letter_ordering = TRUE;
                                        break;

                                /* disable range merge */
                                case 'r':
                                        merge_page = FALSE;
                                        break;

                                /* supress progress message -- quiet mode */
                                case 'q':
                                        verbose = FALSE;
                                        break;

                                /* compress blanks */
                                case 'c':
                                        compress_blanks = TRUE;
                                        break;

                                /* style file */
                                case 's':
                                        argc--;
                                        open_sty(*++argv);
                                        sty_given = TRUE;
                                        break;

                                /* output index file name */
                                case 'o':
                                        argc--;
                                        ind_fn = *++argv;
                                        ind_given = TRUE;
                                        break;

                                /* transcript file name */
                                case 't':
                                        argc--;
                                        ilg_fn = *++argv;
                                        ilg_given = TRUE;
                                        break;

                                /* initial page */
                                case 'p':
                                        argc--;
                                        strcpy(pageno, *++argv);
                                        init_page = TRUE;
                                        if (STREQ(pageno, EVEN)) {
                                                log_given = TRUE;
                                                even_odd = 2;
                                        } else if (STREQ(pageno, ODD)) {
                                                log_given = TRUE;
                                                even_odd = 1;
                                        } else if (STREQ(pageno, ANY)) {
                                                log_given = TRUE;
                                                even_odd = 0;
                                        }
                                        break;

                                /* bad option */
                                default:
                                        FATAL("Unknown option -%c.\n", *ap);
                                        break;
                                }
                } else {
                        if (fn_no < LONG_MAX) {
                                check_idx(*argv, FALSE);
                                fns[++fn_no] = *argv;
                        } else {
                                FATAL("Too many input files (max %d).\n", LONG_MAX);
                        }
                }
        }

        process_idx(fns, use_stdin, sty_given, ind_given, ilg_given, log_given);
        idx_gt = idx_tt - idx_et;
        if (idx_gt > 0) {
                prepare_idx();
                sort_idx();
                gen_ind();
                MESSAGE("Output written in %s.\n", ind_fn);
        } else
                MESSAGE("Nothing written in %s.\n", ind_fn);

        MESSAGE("Transcript written in %s.\n", ilg_fn);
        CLOSE(ind_fp);
        CLOSE(ilg_fp);
        EXIT(0);

        return(0);                      /* never executed--avoids complaints */
                                        /* about no return value */
}


static void
prepare_idx()
{
        NODE_PTR        ptr = head;
        int             i = 0;

        if ((idx_key = (FIELD_PTR *) calloc(idx_gt, sizeof(FIELD_PTR))) == NULL) {
                FATAL("Not enough core...abort.\n", "");
        }
        for (i = 0; i < idx_gt; i++) {
                idx_key[i] = &(ptr->data);
                ptr = ptr->next;
        }
}


static void
process_idx(fn, use_stdin, sty_given, ind_given, ilg_given, log_given)
        char            *fn[];
        int             use_stdin;
        int             sty_given;
        int             ind_given;
        int             ilg_given;
        int             log_given;
{
        int             i;

        if (fn_no == -1)
                /* use stdin if no input files specified */
                use_stdin = TRUE;
        else {
                check_all(fn[0], ind_given, ilg_given, log_given);
                PUT_VERSION;
                if (sty_given)
                        scan_sty();
                scan_idx();
                ind_given = TRUE;
                ilg_given = TRUE;
                for (i = 1; i <= fn_no; i++) {
                        check_idx(fn[i], TRUE);
                        scan_idx();
                }
        }

        if (use_stdin) {
                idx_fn = "stdin";
                idx_fp = stdin;

                if (ind_given) {
                        if (ind_fp == NULL)
                                ind_fp = OPEN_OUT(ind_fn);
                } else {
                        ind_fn = "stdout";
                        ind_fp = stdout;
                }

                if (ilg_given) {
                        if (ilg_fp == NULL)
                                ilg_fp = OPEN_OUT(ilg_fn);
                } else {
                        ilg_fn = "stderr";
                        ilg_fp = stderr;
                }

                if (need_version) {
                        PUT_VERSION;
                }
                if ((fn_no == -1) && (sty_given))
                        scan_sty();
                scan_idx();
                fn_no++;
        }

        ALL_DONE;
}


static void
check_idx(fn, open_fn)
        char            *fn;
        int             open_fn;
{
        char            *ptr = fn;
        char            *ext;
        int             with_ext = FALSE;
        int             i = 0;

        ext = rindex(fn, EXT_DELIM);
        if ((ext != NULL) && (ext != fn) && (*(ext+1) != DIR_DELIM)) {
                with_ext = TRUE;
                while ((ptr != ext) && (i < STRING_MAX))
                        base[i++] = *ptr++;
        } else
                while ((*ptr != NULL) && (i < STRING_MAX))
                        base[i++] = *ptr++;

        if (i < STRING_MAX)
                base[i] = NULL;
        else
                FATAL2("Index file name %s too long (max %d).\n",
                       base, STRING_MAX);

        idx_fn = fn;
        if (((open_fn) && ((idx_fp = OPEN_IN(idx_fn)) == NULL)) ||
            ((! open_fn) && (access(idx_fn, R_OK) != 0)))
                if (with_ext) {
                        FATAL("Input index file %s not found.\n", idx_fn);
                } else {
                        if ((idx_fn = (char *) malloc(STRING_MAX)) == NULL)
                                FATAL("Not enough core...abort.\n", "");
                        sprintf(idx_fn, "%s%s", base, INDEX_IDX);
                        if (((open_fn) && ((idx_fp = OPEN_IN(idx_fn)) == NULL)) ||
                            ((! open_fn) && (access(idx_fn, R_OK) != 0))) {
                                FATAL2("Couldn't find input index file %s nor %s.\n", base, idx_fn);
                        }
                }
}


static void
check_all(fn, ind_given, ilg_given, log_given)
        char            *fn;
        int             ind_given;
        int             ilg_given;
        int             log_given;
{
        check_idx(fn, TRUE);

        if (! ind_given) {
                sprintf(ind, "%s%s", base, INDEX_IND);
                ind_fn = ind;
        }
        ind_fp = OPEN_OUT(ind_fn);

        if (! ilg_given) {
                sprintf(ilg, "%s%s", base, INDEX_ILG);
                ilg_fn = ilg;
        }
        ilg_fp = OPEN_OUT(ilg_fn);

        if (log_given) {
                sprintf(log_fn, "%s%s", base, INDEX_LOG);
                if ((log_fp = OPEN_IN(log_fn)) == NULL) {
                        FATAL("Source log file %s not found\n", log_fn);
                } else {
                        find_pageno();
                        CLOSE(log_fp);
                }
        }
}


static void
find_pageno()
{
        int             i = 0;
        int             p, c;

#if OS_VAXVMS
        /* Scan forward through the file for VMS, because fseek
           doesn't work on variable record files */
        c = GET_CHAR(log_fp);
        while (c != EOF) {
                p = c;
                c = GET_CHAR(log_fp);
                if (p == LSQ && isdigit(c)) {
                        i = 0;
                        do {
                                pageno[i++] = c;
                                c = GET_CHAR(log_fp);
                        } while (isdigit(c));
                        pageno[i] = NULL;
                }
        }
        if (i == 0) {
                fprintf(ilg_fp, "Couldn't find any page number in %s...ignored\n",
                        log_fn);
                init_page = FALSE;
        }
#else /* NOT OS_VAXVMS */
        fseek(log_fp, -1L, 2);
        p = GET_CHAR(log_fp);
        fseek(log_fp, -2L, 1);
        do {
                c = p;
                p = GET_CHAR(log_fp);
        } while (! (((p == LSQ) && isdigit(c)) || (fseek(log_fp, -2L, 1) != 0)));
        if (p == LSQ) {
                while ((c = GET_CHAR(log_fp)) == SPC);
                do {
                        pageno[i++] = (char)c;
                        c = GET_CHAR(log_fp);
                } while (isdigit(c));
                pageno[i] = NULL;
        } else {
                fprintf(ilg_fp, "Couldn't find any page number in %s...ignored\n", log_fn);
                init_page = FALSE;
        }
#endif /* OS_VAXVMS */
}

static void
open_sty(fn)
        char            *fn;
{
        char            *path;
        char            *ptr;
        int             i;
        int             len;

        if ((path = getenv(STYLE_PATH)) == NULL) {
                /* style input path not defined */
                strcpy(sty_fn, fn);
                sty_fp = OPEN_IN(sty_fn);
        } else {
#if OS_VAXVMS
                if (length(STYLE_PATH) + strlen(fn) + 1 > LONG_MAX) {
                        FATAL("Path %s too long (max %d).\n",
                              STYLE_PATH, LONG_MAX);
                } else {
                        sprintf(sty_fn, "%s:%s", STYLE_PATH, fn);
                        sty_fp = OPEN_IN(sty_fn);
                }
#else /* NOT OS_VAXVMS */
                len = LONG_MAX - strlen(fn) - 1;
                while (*path != NULL) {
#if OS_XENIX
                        i = 0;
                        while ((*path != ENV_SEPAR) && (*path != NULL) && (i < len))
                                sty_fn[i++] = *path++;
#else /* NOT OS_XENIX */
                        ptr = index(path, ENV_SEPAR);
                        i = 0;
                        while ((path != ptr) && (i < len))
                                sty_fn[i++] = *path++;
#endif /* OS_XENIX */
                        if (i == len) {
                                FATAL2("Path %s too long (max %d).\n",
                                       sty_fn, LONG_MAX);
                        } else {
                                sty_fn[i++] = DIR_DELIM;
                                sty_fn[i] = NULL;
                                strcat(sty_fn, fn);
#if OS_XENIX
                                if (((sty_fp = OPEN_IN(sty_fn)) == NULL) && (*path != NULL))
#else /* NOT OS_XENIX */
                                if ((sty_fp = OPEN_IN(sty_fn)) == NULL)
#endif /* OS_XENIX */
                                        path++;
                                else
                                        break;
                        }
                }
#endif /* OS_VAXVMS */
        }

        if (sty_fp == NULL)
                FATAL("Index style file %s not found\n", fn);
}


int
strtoint(str)
        char            *str;
{
        int             val = 0;

        while (*str != NULL) {
                val = 10*val + *str - 48;
                str++;
        }
        return (val);
}

