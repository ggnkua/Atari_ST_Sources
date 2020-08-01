/***************************************************************\
*								*
*  PDMAKE, Atari ST version					*
*								*
*  Adapted from mod.sources Vol 7 Issue 71, 1986-12-03.		*
*								*
*  This port makes extensive use of the original net.sources	*
*  port by Jwahar Bammi.					*
*								*
*      Ton van Overbeek						*
*      Email: TPC862@ESTEC.BITNET				*
*             TPC862%ESTEC.BITNET@WISCVM.WISC.EDU    (ARPA)	*
*             ...!mcvax!tpc862%estec.bitnet   (UUCP Europe)	*
*             ...!ucbvax!tpc862%estec.bitnet  (UUCP U.S.A.)	*
*             71450,3537  (CompuServe)				*
*								*
\***************************************************************/

/*
 *
 * ststuff.c - Retrofit routines
 *             for the Atari St's
 *
 */

#include <stdio.h>
#include <ctype.h>
#include "h.h"
#include "astat.h"

/*
 * Get file statistics - sort of like stat(2)
 */

int	getstat(fname, buf)
register char	*fname;
register struct stat *buf;
{
	register struct stat *save_dta;
	register int	status;

	/* Save old DTA */
	save_dta = (struct stat *)Fgetdta();

	/* set the new DTA */
	Fsetdta(buf);

	/* Find file stat */
	status = Fsfirst(fname, 0);

	/* reset dta */
	Fsetdta(save_dta);

	/* return status */
	return (status == 0) ? 0 : -1;

}


/*
 * system - execute a command and return status
 */
int	system(cmd)
register char	*cmd;
{
	char	command[128], tail[130];
	register char	*p, *save, *findcmd();
	register int	n;

	if (*cmd == '%')
		/* Atari special internal command */
		return st_special(cmd);

	/* Break up command into command and command tail */
	for (p = save = command; !isspace(*cmd); *p++ = *cmd++)	/* copy */
		;
	*p = '\0';

	while (isspace(*cmd)) 
		cmd++;				/* skip blanks */
	if ((n = strlen(cmd)) > 128) {
		fprintf(stderr, "Command '%s' too long\n", save);
		return - 1;
	}

	tail[0] = (char) n;
	strcpy(&tail[1], cmd);

	return (int)Pexec(0, findcmd(command), tail, (char *)NULL);
}


/*
 * Find a command given a partially qualified command name
 */
static char	*suf[] = {
	"prg",
	"ttp",
	"tos",
	(char *) 0
};


char	*
findcmd(cmd)
char	*cmd;
{
	static char	file[128];
	char	pathbuf[512];
	char	*path, *p;
	char	*baseptr, *strrchr(), *strchr(), *getenv(), *strtok();
	int	hassuf, i;
	struct stat sbuf;

	if ((baseptr = strrchr(cmd, '\\')) == NULL)
		baseptr = cmd;

	hassuf = (strchr(baseptr, '.') != NULL);

	if (baseptr != cmd && hassuf)		/* absolute path with suffix */
		return cmd;

	path = getenv("PATH");

	if (baseptr != cmd || path == NULL) {	/* absolute, or no path */
		for (i = 0; suf[i] != NULL ; i++) {	/* abs path, no suf */
			sprintf(file, "%s.%s", cmd, suf[i]);
			if (getstat(file, &sbuf) == 0)
				return file;
		}
		return cmd;			/* will have to do */
	}
	strcpy(pathbuf, path);

	for (p = strtok(pathbuf, ";,"); p != NULL ; p = strtok(NULL, ";,")) {
		if (hassuf) {
			sprintf(file, "%s\\%s", p, cmd);
			if (getstat(file, &sbuf) == 0)
				return file;
		} else {
			for (i = 0; suf[i] != NULL ; i++) {
				sprintf(file, "%s\\%s.%s", p, cmd, suf[i]);
				if (getstat(file, &sbuf) == 0)
					return file;
			}
		}
	}
	return cmd;				/* will have to do */
}


/*
 * Atari St special commands
 *
 */
int	st_special(cmd)
register char	*cmd;
{
	extern int	rm(), cp();

	switch (cmd[1]) {
	case 'r':
	case 'R':	/* remove */
		return rm(&cmd[2]);

	case 'c':
	case 'C':	/* copy */
		return cp(&cmd[2]);

	case 'e':
	case 'E':
		return echo(&cmd[2]);

	default:
		fprintf(stderr, "Warning: '%s' - Unknown Atari Special Command\n",
		    cmd);
	}
	return 0;
}


/*
 * remove file(s)
 *
 */
int	rm(list)
register char	*list;
{
	char	name[128];
	register char	*p;

	while ((!isspace(*list)) && (*list != '\0')) 
		list++;
	while (*list != '\0') {
		while (isspace(*list)) 
			list++;

		for (p = name; !isspace(*list) && (*list != '\0'); 
		    *p++ = *list++) /* copy */
			;
		*p = '\0';

		if (p != name)
			wremove(name);	/* never mind the return value
                      			 * we are doing 'rm -f'
					 */
	}
	return 0;
}


#define iswild(F) ((strchr(F,'*')!=(char *)NULL)||(strchr(F,'?')!=(char *)NULL))

/*
 * this routine actually removes the files, dealing with wildcards
 *
 */
wremove(filename)
register char	*filename;
{
	register struct stat *save_dta;
	struct stat buf;
	char	fbuf[128];
	char	pbuf[128];
	register char	*path, *p;
	extern char	*strcpy(), *strcat(), *strchr(), *strrchr();

	if (!iswild(filename)) {
		/* not a wild card */
		unlink(filename);
		return;
	}

	/* Wild Card */
	if ((p = strrchr(filename, '\\')) != (char *)NULL) {
		register char	*q;

		/* Pick up path */
		p++;
		for (path = pbuf, q = filename; q != p; *path++ = *q++) /* Copy */
			;
		*path = '\0';
		path = pbuf;
	} else
		/* No path */
		path = (char *)NULL;

	/* Save old DTA */
	save_dta = (struct stat *)Fgetdta();

	/* set the new DTA */
	Fsetdta(&buf);

	/* Unlink the first match for wild card */
	if (Fsfirst(filename, (0x01 | 0x010 | 0x020)) != 0)
		/* No such file(s), simply return */
		return;

	unlink ( (path == (char *)NULL) ? buf.st_sp2
	     : strcat(strcpy(fbuf, path), buf.st_sp2) );

	/* Unlink any other match(s) for wild card */
	while (Fsnext() == 0)
		/* rest of them */
		unlink ( (path == (char *)NULL) ? buf.st_sp2
		     : strcat(strcpy(fbuf, path), buf.st_sp2) );

	/* reset dta */
	Fsetdta(save_dta);
}


/*
 * copy files
 *
 */
int	cp(list)
register char	*list;
{
	char	source[128], dest[128];
	char	buf[512];
	register char	*p;
	register int	fsource, fdest;
	register long	count;

	while ((!isspace(*list)) && (*list != '\0')) 
		list++;
	while (isspace(*list)) 
		list++;
	if (*list == '\0') {
		/* no source specified */
		fprintf(stderr, "Usage: ${CP} <source file> <destination file>\n");
		return 1;
	}

	for (p = source; !isspace(*list) && (*list != '\0'); *p++ = *list++) /* copy */
		;
	*p = '\0';

	while (isspace(*list)) 
		list++;
	if (*list == '\0') {
		/* no destination specified */
		fprintf(stderr, "Usage: ${CP} <source file> <destination file>\n");
		return 2;
	}

	for (p = dest; !isspace(*list) && (*list != '\0'); *p++ = *list++) /* copy */
		;
	*p = '\0';

	if (*list != 0) {
		fprintf(stderr, "Only 2 parameters allowed\n");
		fprintf(stderr, "Usage: $(CP) <source file> <destination file>\n");
		return 6;
	}


	if ((fsource = Fopen(source, 0)) < 0) {
		fprintf(stderr, "%s: no such file\n", source);
		return 3;
	}

	if ((fdest = Fcreate(dest, 0)) < 0) {
		/* May already exist */
		if ((fdest = Fopen(dest, 1)) < 0) {
			fprintf(stderr, "%s: cannot open for write\n", dest);
			Fclose(fsource);
			return 4;
		}
	}

	while ((count = Fread(fsource, 512L, buf)) > 0) {
		if (Fwrite(fdest, count, buf) != count) {
			fprintf(stderr, "Error writing %s\n", dest);
			Fclose(fsource);
			Fclose(fdest);
			return 5;
		}
	}

	Fclose(fsource);
	Fclose(fdest);

	return 0;
}


/*
 * Echo arguments
 *
 */
int	echo(list)
register char	*list;
{
	while ((!isspace(*list)) && (*list != '\0')) 
		list++;

	if (*list != '\0') {
		while (isspace(*list)) 
			list++;
		printf("%s\n", list);
	}

	return 0;
}


/*
 * rtime - stuff current time & date into long (ptr passed)
 *
 */
rtime(t)
long	*t;
{
	*t = Gettime();    /* Ikbd's time */
}


/*
 * Flips Word of a long, used to get the date into the Higher order bits,
 * and time into the lower order bits of a long, so that comparisons can
 * later be done using a simple C relational operator.
 *
 */
void
FlipWords(i)
unsigned int	i[];
{
	register unsigned int	temp;

	temp = i[0];
	i[0] = i[1];
	i[1] = temp;
}
