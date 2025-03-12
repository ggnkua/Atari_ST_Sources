/*
 * Listing 1.20, Datei : ssh.c
 * Programm            : SSH - Eine einfache Shell
 * Modifikationsdatum  : 12-Dez-89
 * AbhÑngigkeiten      : stdio.h, osbind.h, string.h,
 *                       ctype.h, local.h, atom.h
 */

#include <stdio.h>
#include <osbind.h>
#include <string.h>
#include <ctype.h>
#include "local.h"
#include "atom.h"

/*
 * Konstante    : PATH
 *
 * Aufgabe      :
 *
 * EnthÑlt das Verzeichnis in dem zusÑtzlich zum
 * aktuellen Verzeichnis gesucht wird.
 */

#define PATH "C:\\BIN\\"

/*
 * Datentyp     : TOKEN
 *
 * Aufgabe      :
 *
 * AufzÑhlungstyp fÅr die lexikalische Analyse der
 * SSH-Kommandos.
 */

typedef enum {
    WORD,
    PIPE,
    INSYM,
    OUTSYM,
    END
} TOKEN;

/*
 * Variablen    : gword, ginfile, rest, cmdline
 *                gtoken, remove, tempcnt gargc,
 *                gargv
 *
 * Aufgabe      :
 *
 * Einige globale Variablen, die wÑhrend der Analyse
 * und Interpretation von SSH-Kommandos benîtigt
 * werden.
 */

static char    gword[255],
               ginfile[15],
               *rest,
               cmdline[255];
static TOKEN   gtoken;
static BOOLEAN remove;
static short   tempcnt,
               gargc;
static char    **gargv;

/*
 * Funktionen   : expand_gword, nextword, tempfile,
 *                wordlist, command, commandline,
 *                eval
 *
 * Parameter    : expand_gword();
 *                newstart = nextword(oldstart);
 *                tempfile(filename);
 *                wordlist();
 *                ok = command(infile);
 *                ok = commandline(infile);
 *                eval(str);
 *                char    *newstart,
 *                        *oldstart,
 *                        *str,
 *                        *filename;
 *                BOOLEAN ok,
 *                        infile;
 *
 * Aufgabe      :
 *
 * Die nachfolgenden Funktionen bilden das KernstÅck
 * bei der Interpretation von SSH-Kommandos.
 * <expand_gword> und <nextword> nehmen die lexika-
 * lische Analyse vor. Die Åbrigen Funktionen setzen
 * die SSH-Kommandos in ST-Kommandozeilen um. Dabei
 * wird auch gleichzeitig eine korrekte Syntax
 * sichergestellt.
 */

void expand_gword()
{   char erg[128],
         work[2],
         *gptr = &gword[0];
    int  argno;

    strcpy(erg, "");
    strcpy(work, " ");
    while (gptr[0] != 0) {
        if (gptr[0] == '$') {
            gptr++;
            argno = 0;
            while (gptr[0] != 0 &&
                   isdigit(gptr[0])) {
                argno = argno * 10 +
                        todigit(gptr[0]);
                gptr++;
            }
            if (argno >= 1 && argno < gargc)
                strcat(erg, gargv[argno]);
        }
        else {
            work[0] = gptr[0];
            strcat(erg, work);
            gptr++;
        }
    }
    strcpy(gword, erg);
}

char *nextword(cline)
char *cline;
{   char  *work = cline;
    short i;

    if (cline == NULL || strlen(cline) == 0) {
        gtoken = END;
        return(NULL);
    }
    while (work != 0) {
        if (work[0] == '<') {
            gtoken = INSYM;
            strcpy(gword, "<");
            return(++work);
        } else if (work[0] == '>') {
            gtoken = OUTSYM;
            strcpy(gword, ">");
            return(++work);
        } else if (work[0] == '|') {
            gtoken = PIPE;
            strcpy(gword, "|");
            return(++work);
        } else if (work[0] == ' ' ||
                   work[0] == '\t')
            ++work;
        else {
            gtoken = WORD;
            i = 0;
            if (work[0] == '\"') {
                do {
                    gword[i] = work[i];
                    i++;
                } while(work[i] != 0 &&
                        work[i] != '\"');
                gword[i] = '\"';
                i++;
            }
            else
                do {
                    gword[i] = work[i];
                    i++;
                } while(work[i] != 0 &&
                        work[i] != ' ' &&
                        work[i] != '\t' &&
                        work[i] != '>' &&
                        work[i] != '<' &&
                        work[i] != '|');
            gword[i] = 0;
            expand_gword();
            if (work[i] == 0)
                return(NULL);
            return(&work[i]);
        }
    }
    return(work);
}

void tempfile(filename)
char *filename;
{   remove = TRUE;
    sprintf(filename, "%08d.TMP", tempcnt++);
}

void wordlist()
{   if (gtoken == WORD) {
        sprintf(cmdline, "%s %s", cmdline, gword);
        rest = nextword(rest);
        wordlist();
    }
}

BOOLEAN command(infile)
BOOLEAN infile;
{   char    *work;
    BOOLEAN outfile = FALSE;

    if (gtoken != WORD) {
        fprintf(stderr, "ssh: WORD expected\n");
        return(FALSE);
    }
    else {
        sprintf(cmdline, "%s %s", cmdline, gword);
        rest = nextword(rest);
        wordlist();
        if (infile)
            sprintf(cmdline, "%s %s", cmdline,
                    ginfile);
        if (gtoken == INSYM) {
            if (infile) {
                fprintf(stderr,
     "ssh: Only one stdin-Redirection is allowed\n");
                return(FALSE);
            }
            infile = TRUE;
            rest = nextword(rest);
            if (gtoken == WORD) {
                sprintf(cmdline, "%s < %s", cmdline,
                        gword);
                rest = nextword(rest);
            }
            else {
                fprintf(stderr, "ssh: Missing WORD\n");
                return(FALSE);
            }
        }
        if (gtoken == OUTSYM) {
            if (outfile) {
                fprintf(stderr,
     "ssh: Only one stout-Redirection is allowed\n");
                return(FALSE);
            }
            outfile = TRUE;
            rest = nextword(rest);
            if (gtoken == WORD) {
                sprintf(cmdline, "%s > %s", cmdline,
                        gword);
                rest = nextword(rest);
            }
            else {
                fprintf(stderr, "ssh: Missing WORD\n");
                return(FALSE);
            }
        }
        return(TRUE);
    }
}

BOOLEAN commandline(infile)
BOOLEAN infile;
{   char *work,
         filename[15];
    void execute();

    if (command(infile)) {
        if (gtoken == PIPE) {
            tempfile(filename);
            sprintf(cmdline, "%s > %s", cmdline,
                    filename);
            execute(cmdline);
            strcpy(cmdline, "");
            rest = nextword(rest);
            sprintf(ginfile, "< %s", filename);
            return(commandline(TRUE));
        }
        else if (gtoken == END) {
            execute(cmdline);
            strcpy(cmdline, "");
            return(TRUE);
        }
        else {
        fprintf(stderr, "ssh: End-of-line expected\n");
        return(FALSE);
        }
    }
    else {
        fprintf(stderr, "ssh: Execution fails\n");
        return(FALSE);
    }
}

void eval(cline)
char *cline;
{   void execute();

    rest = nextword(cline);
    tempcnt = 0;
    remove = FALSE;
    strcpy(cmdline, "");
    commandline(FALSE);
    if (remove) {
        strcpy(cmdline, " rm.ttp *.TMP");
        execute(cmdline);
    }
}

/*
 * Funktionen   : cd, pwd, intexecute, execute
 *
 * Parameter    : ok = cd(argc, argv);
 *                ok = pwd(argc, argv);
 *                ok = intexecute(cmd, cmdline);
 *                execute(cline);
 *                BOOLEAN ok;
 *                short   argc;
 *                char    **argv,
 *                        *cmd,
 *                        *cmdline,
 *                        *cline;
 *
 * Aufgabe      :
 *
 * Die nachfolgenden Funktionen Åbernehmen die
 * AusfÅhrung von internen und externen Kommandos.
 * Die drei Kommandos <cd>, <pwd> und <exit> sind
 * hier intern realisiert. Alle Åbrigen Kommandos
 * werden nachgeladen. Die Funktion <intexecute>
 * dient der AusfÅhrung interner Kommandos; die
 * Funktion <execute> fÅhrt externe Kommandos aus,
 * dabei sortiert sie zuvor die internen Kommandos 
 * aus und leitet ihre Interpretation ein.
 */

BOOLEAN cd(argc, argv)
short argc;
char  *argv[];
{   if (argc == 2) {
        convupper(argv[1]);
        if (!acd(argv[1])) {
            fprintf(stderr,
                    "cd: can't find directory\n");
            return(FALSE);
        }
    }
    else {
        fprintf(stderr,
                "cd: need exactly one parameter\n");
        return(FALSE);
    }
    return(TRUE);
}

BOOLEAN pwd(argc, argv)
short argc;
char  *argv[];
{   char actdir[100];

    if (argc == 1) {
        apwd(actdir);
        printf("%s\n", actdir);
        return(TRUE);
    }
    fprintf(stderr, "pwd: no parameter expected\n");
    return(FALSE);
}

BOOLEAN intexecute(cmd, cmdline)
char *cmd, *cmdline;
{   short   argc = 1,
            i;
    char    **argv,
            *work;
    BOOLEAN first,
            ok;
    
    work = cmdline;
    first = TRUE;
    while (work[0] != 0) {
        if (work[0] != ' ') {
            if (first) {
                first = FALSE;
                argc++;
            }
        }
        else
            first = TRUE;
        work++;
    }
    argv = (char **)malloc(4 * (argc - 1));
    argv[0] = "";
    work = cmdline;
    first = TRUE;
    i = 1;
    while (work[0] != 0) {
        if (work[0] != ' ') {
            if (first) {
                first = FALSE;
                argv[i] = work;
                i++;
            }
        }
        else {
            first = TRUE;
            work[0] = 0;
        }
        work++;
    }
    if (strcmp(cmd, "CD") == 0)
        ok = cd(argc, argv);
    else if (strcmp(cmd, "PWD") == 0)
        ok = pwd(argc, argv);
    else if (strcmp(cmd, "EXIT") == 0)
        exit(0);
    else
        ok = FALSE;
    free(argv);
    return(ok);
}

void execute(cline)
char *cline;
{   char cmd      [128],
         cmdline  [128],
         pcmdline [128],
         directory[128],
         filename [128],
         *work;
    long erg;

    while (cline[0] == ' ')
        cline++;
    work = cline;
    while (work[0] != 0 && work[0] != ' ')
        work++;
    if (work[0] == 0)
        strcpy(cmdline, "");
    else
        strcpy(cmdline, &work[1]);
    if (work[0] == ' ');
        work[0] = 0;
    strcpy(cmd, cline);
    convupper(cmd);
    ctop(cmdline, pcmdline);
    pathsplit(cmd, directory, filename);
    if (strcmp(cmd, "CD") == 0 ||
        strcmp(cmd, "PWD") == 0 ||
        strcmp(cmd, "EXIT") == 0) {
        if (!intexecute(cmd, cmdline))
          fprintf(stderr, "ssh: Execution fails.\n");
        return;
    }
    else if (onlyalpha(filename))
        strcat(cmd, ".TTP");
    erg = Pexec(0, cmd, pcmdline, "");
    if (erg < 0) {
        pathsplit(cmd, directory, filename);
        if (strcmp(directory, "") == 0) {
            strcpy(cmd, PATH);
            strcat(cmd, filename);
            erg = Pexec(0, cmd, pcmdline, "");
            if (erg < 0)
                fprintf(stderr,
                    "ssh: Execution fails. %s %ld\n",
                    "Return value is", erg);
        }
    }
}

void main(argc, argv)
short argc;
char  **argv;
{   char cmdline[127],
         *work;

    if (isatty(STDIN)) {
        printf("SSH - Simple SHell\n");
        printf("(c) 12/89 by D.Brockhaus\n");
    }
    gargc = argc;
    gargv = argv;
    do {
        if (isatty(STDIN))
            printf("$ ");
        if (gets(cmdline) == NULL)
            exit(0);
        if (!(strcmp(cmdline, "") == 0 ||
              cmdline[0] == '#'))
            eval(cmdline);
    } while (TRUE);
}
