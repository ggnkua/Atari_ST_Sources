/*
 * C version of RUNIT.SH -- for Amulti testing.
 */
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include <osbind.h>

char bin[120];		/* where executables are (1 directory, sorry!)	*/
char home[120];		/* citadel home directory; HOME= in CITADEL.RUN	*/
char args[120];		/* arguments for citadel; ARGS= in CITADEL.RUN	*/
char here[120];		/* for MS-DOS: directory we came from		*/

struct rule {
    int code;
    char *cmd;
    char *tail;
    struct rule *next;
    struct rule *chain;
} ;

struct rule *rules = NULL,
	    *def   = NULL,
	    *init  = NULL,
	    *after = NULL;

int linno=0;
int status=0;

long _BLKSIZ=5000L;

int
cd(char *path)
{
    int drive;

    if (path[1] == ':' ) {
	drive = path[0] - 'a';
	if (Dsetdrv(drive) == 0)		/* the root directory       */
	    return 1;
	path += 2;
    }
    return Dsetpath(path[0] ? path : "\\");
}

void
terminate(int status)
{
    cd(here);
    if (fromdesk())
	hitkey();
    exit(status);
}

struct rule *
findrule(int code, struct rule *list)
{
    while (list && list->code != code)
	list = list->next;
    return list;
}

void
makerule(struct rule **rp, int code, char *name, char *line)
{
    char *cname, *ctail;
    struct rule *runner, *tmp;

    cname = strtok(line," \t");
    ctail = strtok(NULL,"\0");
    if (ctail && strlen(ctail) > 127) {
	fprintf(stderr, "command tail too long on line %d\n", linno);
	terminate(6);
    }

    tmp = (struct rule *) malloc(sizeof tmp[0]);
    tmp->code = code;
    tmp->cmd  = strdup(cname);
    tmp->tail = ctail ? strdup(ctail) : "";
    tmp->chain= NULL;

    for (runner = *rp; runner; runner = runner->next)
	if (runner->code == code) {		/* duplicate rule, add to */
	    while (runner->chain)		/* tail of chain	  */
		runner = runner->chain;
	    runner->chain = tmp;
	    tmp->next = NULL;
	    return;
	}

    tmp->next = *rp;
    *rp = tmp;
}

void
getwd(char *path)
{
    sprintf(path, "%c:", 'A' + Dgetdrv() );
    Dgetpath(&path[2], 0);
    strlwr(path);
}

char *
basename(char *s)
{
    register char *p;

    return ((p = strrchr(s,'\\')) || (p = strchr(s,':'))) ? (1+p) : (s);
}

static struct _dta temp;

int
fattr(char *f)
{
    char *p;
    long hold = Fgetdta();
    int attr;

    /*
     * an unverifiable directory (stupid cheapo operating system!)
     */
    p = basename(f);
    if (strcmp(p,".") == 0 || strcmp(p,"..") == 0
			   || (strlen(f) == 2 && f[1] == ':'))
	return 0x10;

    /*
     * any other file  (xxx/ means a null file in xxx....)
     */
    Fsetdta(&temp);
    attr = (Fsfirst(f, 0x1F) == 0) ? (temp.dta_attribute) : (-1);
    Fsetdta(hold);
    
    return attr;
}

static char *ext[] = { ".tos", ".ttp", ".prg", ".app", NULL };

void
runcommand(char *cmd, char *tail)
{
#ifdef ATARIST
    static char pascal[129];
#endif
#ifdef MSDOS
    extern int errno;
    int tmp;
#endif
    static char fullcmd[200];
    char *eos, *p;
    int i;

#ifdef ATARIST
    sprintf(pascal, "%c%s", strlen(tail), tail);
#endif

    if (stricmp("$CONFIG", cmd) == 0)
	sprintf(fullcmd, "%s\\configur", bin);
    else if (stricmp("$EXIT", cmd) == 0)
	terminate(status);
    else if (stricmp("$RM", cmd) == 0) {
	strcpy(fullcmd, tail);
	for (p=strtok(fullcmd, "\t "); p; p=strtok(NULL, "\t "))
#ifdef ATARIST
	    status = Fdelete(p);
#else
	    unlink(p);
#endif
	return;
    }
    else if (strchr(cmd,'\\'))
	strcpy(fullcmd, cmd);
    else
	sprintf(fullcmd,"%s\\%s", bin, cmd);

    if (!strchr(basename(fullcmd),'.')) {
	eos = &fullcmd[strlen(fullcmd)];
	for (i=0; ext[i]; i++) {
	    strcpy(eos, ext[i]);
	    if (fattr(fullcmd) >= 0)
		break;
	}
	if (!ext[i]) {
	    status = -33;
    oopsie: fprintf(stderr, "%s: bad status %d -- bye!\n", cmd, status);
	    terminate(status & 0x7fff);
	}
    }
#ifdef ATARIST
    if ((status = Pexec(0, fullcmd, pascal, NULL)) < 0)
	goto oopsie;
#endif
#ifdef MSDOS
    if ((status=spawnl(P_WAIT, fullcmd, cmd, tail[0]?tail:NULL,NULL)) == -1) {
	status = (errno>0)?(-errno):(errno);
	goto oopsie;
    }
#endif
}

void
execrule(struct rule *r)
{
    while (r) {
	runcommand(r->cmd, r->tail);
	r = r->chain;
    }
}

int
main(int argc, char **argv)
{
    static char line[200];
    struct rule *toexec;
    FILE *fp;
    char *op, *tail;
    int i;
    char *runfile = "citadel.run";

    printf("RUNIT V0.2 - dlp 10-apr-88\n");

    bin[0] = home[0] = args[0] = 0;
    getwd(here);

    if (argc > 1) {
	i = fattr(argv[1]);
	if (i < 0) {
	    fprintf(stderr, "runit:  cannot find run file/directory `%s'\n",
			    argv[1]);
	    terminate(255);
	}
	else if (i & 0x10) {
	    if (cd(argv[1]) != 0) {
		fprintf(stderr, "cannot cd to `%s'\n", argv[1]);
		terminate(2);
	    }
	}
	else
	    runfile = argv[1];
    }
    if (fp=fopen(runfile, "r")) {
	while (fgets(line, 199, fp)) {
	    linno++;
	    strtok(line,"\n");
	    if (op=strtok(line,"=")) {
		tail=strtok(NULL,"\0");
		if (!(tail && *tail))
		    continue;
		if (stricmp(op,"STARTUP") == 0)
		    makerule(&init, 0, op, tail);
		else if (stricmp(op,"AFTER") == 0)
		    makerule(&after, 0, op, tail);
		else if (stricmp(op,"BIN") == 0)
		    strcpy(bin, tail);
		else if (stricmp(op,"HOME") == 0)
		    strcpy(home, tail);
		else if (stricmp(op,"ARGS") == 0)
		    strcpy(args, tail);
		else if (stricmp(op,"DEFAULT") == 0)
		    makerule(&def, 0, op, tail);
		else {
		    for (i=0; op[i]; i++)
			if (!isdigit(op[i])) {
			    fprintf(stderr, "bad rule %s on line %d\n",
					    op, linno);
			    terminate(1);
			}
		    makerule(&rules, atoi(op), op, tail);
		}
	    }
	}
	fclose(fp);
	if (findrule(0, rules) == NULL)
	    makerule(&rules, 0, "SYSOP EXIT", "$EXIT");

	if (home[0])
	    strlwr(home);
	else
	    getwd(home);

	if (!bin[0])
	    strcpy(bin,".");

	if (init)
	    execrule(init);

	while (1) {
	    if (cd(home) != 0) {
		fprintf(stderr, "cannot cd to `%s'\n", home);
		terminate(2);
	    }
	    if (fattr("ctdltabl.sys") < 0) {
		runcommand("$CONFIG","x");
		if (fattr("ctdltabl.sys") < 0)
		    terminate(3);
		sprintf(line, "%s crashola", args);
	    }
	    else
		strcpy(line, args);

	    runcommand("citadel", line);

	    toexec = findrule(status, rules);

	    if (after)
		execrule(after);

	    if (!toexec)
		toexec = def;
	    if (!toexec) {
		fprintf(stderr, "unexpected CC=%d\n", status);
		terminate(4);
	    }
	    execrule(toexec);
	}
    }
    else
	fprintf(stderr, "cannot open `citadel.run'\n");
    terminate(0);
}

