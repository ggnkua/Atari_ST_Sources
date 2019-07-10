/*
 * ckdoor.c - check the CTDLDOOR.SYS file and make sure that all the entries
 *		are legitimate.
 *
 * 90Dec14 AA	Hacked a bit for gcc.
 */

#include <stdio.h>
#include <string.h>
#include <osbind.h>
#include "door.h"
    
char *program = "ckdoor";

main()
{
    int  mode;
    char *p, *name, *command, *remark;
    char msg[80], line[180];
    FILE *f;
    int lineno=0;
    extern char VERSION[];

    printf("%s for Fnordadel V%s\n", program, VERSION);

    /*
     *  <name> <mode> <command> [tail] [#remark]
     */

    if (f = fopen("ctdldoor.sys", "r")) {
	while (fgets(line, 180, f)) {
	    lineno++;
	    strtok(line,"\n");
	    mode = 0;
	    if (remark = strrchr(line, '#'))
		*remark++ = 0;

	    name = strtok(line,"\t ");
	    if (!name)
		continue;
	    if (strlen(name) >= DOORSIZE) {
		printf("%d: door name <%s> is too long\n", lineno, name);
		continue;
	    }

	    p = strtok(NULL,"\t ");
	    while (*p) {
		if (tolower(*p) == 'l') {
		    if (fattr(1+p) < 0) {
			printf("%d: can't find `l' directory <%s>\n", lineno, 1+p);
			goto contin;
		    }
		    break;
		}
		else if (tolower(*p) == 'i') {
		    ++p;
		    if (!*p || (*p == ' ')) {
			printf("%d: must have room name for `i'\n", lineno);
			goto contin;
		    }
		    break;		/* Don't mess much with room name */
		}
		else if (strchr(DOORCHARS, tolower(*p)) == NULL) {
		    printf("%d: illegal mode character <%c> for door %s\n",
			    lineno, *p, name);
		    goto contin;
		}
		p++;
	    }
	    command = strtok(NULL, "\t ");
	    if (fattr(command) < 0) {
		printf("%d: program <%s> does not exist for door <%s>\n",
			lineno, command, name);
		continue;
	    }
	contin:;
	}
	fclose(f);
    }
    else
	printf("ctdldoor.sys does not exist\n");
    if (fromdesk())
	hitkey();
}

char *
basename(char *s)
{
    register char *p;

    return ((p=strrchr(s,'\\')) || (p=strchr(s,':'))) ? (1+p) : (s);
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
