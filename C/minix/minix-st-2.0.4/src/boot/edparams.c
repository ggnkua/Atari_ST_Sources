/*	edparams 1.17 - Modify boot parameters		Author: Kees J. Bot
 *								20 May 1992
 */

#define nil 0
#define _POSIX_SOURCE	1
#define _MINIX		1
#include <stddef.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <errno.h>
#include <termios.h>

/* The Minix boot block must start with these bytes: */
char boot_magic[] = { 0x31, 0xC0, 0x8E, 0xD8, 0xFA, 0x8E, 0xD0, 0xBC };

#define SECTOR_SIZE	512

#define PARAMSEC	1	/* Sector containing boot parameters. */

#define ESC		1234	/* Escape key (interrupt). */

int device;			/* Device to edit parameters. */
char *devname;			/* Name of device. */

struct termios termbuf;
int istty= 1;

void report(char *label)
/* edparams: label: No such file or directory */
{
	fprintf(stderr, "edparams: %s: %s\n", label, strerror(errno));
}

void fatal(char *label)
{
	report(label);
	exit(1);
}

void *alloc(void *m, size_t n)
{
	m= m == nil ? malloc(n) : realloc(m, n);
	if (m == nil) fatal("");
	return m;
}

char null[]= "";	/* This kludge saves lots of memory. */

void sfree(char *s)
/* Free a non-null string. */
{
	if (s != nil && s != null) free(s);
}

char *copystr(char *s)
/* Copy a non-null string using malloc. */
{
	char *c;

	if (*s == 0) return null;
	c= alloc(nil, (strlen(s) + 1) * sizeof(char));
	strcpy(c, s);
	return c;
}

int getch(void)
{
	char c;

	switch (read(0, &c, 1)) {
	case -1:
		if (errno != EINTR) fatal("");
		return(ESC);
	case 0:
		if (istty) putchar('\n');
		exit(0);
	default:
		return c & 0xFF;
	}
}

/* Sticky attributes. */
#define E_SPECIAL	0x01	/* These are known to the program. */
#define E_DEV		0x02	/* The value is a device name. */
#define E_RESERVED	0x04	/* May not be set by user, e.g. 'boot' */
#define E_STICKY	0x07	/* Don't go once set. */
/* Volatile attributes. */
#define E_VAR		0x08	/* Variable */
#define E_FUNCTION	0x10	/* Function definition. */

typedef struct environment {
	struct environment *next;
	char	flags;
	char	*name;
	char	*arg;
	char	*value;
	char	*defval;	/* Safehouse for default values. */
} environment;

environment *env;		/* Lists the environment. */

#define arraysize(a)	(sizeof(a) / sizeof((a)[0]))
#define arraylimit(a)	((a) + arraysize(a))

char *readline(void)
/* Read a line including a newline with echoing. */
{
	char *line;
	size_t i, z;
	int c;

	i= 0;
	z= 20;
	line= alloc(nil, z * sizeof(char));

	do {
		c= getch();

		if (c < ' ' && c != '\n') {
			printf("\7Don't use control characters!\n");
			while ((c= getch()) != '\n') {}
			i= 0;
		} else {
			line[i++]= c;
			if (i == z) {
				z*= 2;
				line= alloc(line, z * sizeof(char));
			}
		}
	} while (c != '\n');
	line[i]= 0;
	return line;
}

int sugar(char *tok)
/* Recognize special tokens. */
{
	return strchr("=(){};\n", tok[0]) != nil;
}

char *onetoken(char **aline, int arg)
/* Returns a string with one token for tokenize.  Arg is true when reading
 * between ( and ).
 */
{
	char *line= *aline;
	size_t n;
	char *tok;

	/* Skip spaces and runs of newlines. */
	while (*line == ' ' || (*line == '\n' && line[1] == '\n')) line++;

	*aline= line;

	/* Don't do odd junk (nor the terminating 0!). */
	if ((unsigned) *line < ' ' && *line != '\n') return nil;

	if (arg) {
		/* Function argument, anything goes except ). */
		int depth= 0;

		while ((unsigned) *line >= ' ') {
			if (*line == '(') depth++;
			if (*line == ')' && --depth < 0) break;
			line++;
		}
		while (line > *aline && line[-1] == ' ') line--;
	} else
	if (sugar(line)) {
		/* Single character token. */
		line++;
	} else {
		/* Multicharacter token. */
		do line++; while ((unsigned) *line > ' ' && !sugar(line));
	}
	n= line - *aline;
	tok= alloc(nil, (n + 1) * sizeof(char));
	memcpy(tok, *aline, n);
	tok[n]= 0;
	if (tok[0] == '\n') tok[0]= ';';	/* ';' same as '\n' */

	*aline= line;
	return tok;
}

/* Typed commands form strings of tokens. */

typedef struct token {
	struct token	*next;	/* Next in a command chain. */
	char		*token;
} token;

token **tokenize(token **acmds, char *line, int *fundef)
/* Takes a line apart to form tokens.  The tokens are inserted into a command
 * chain at *acmds.  Tokenize returns a reference to where another line could
 * be added.  The fundef variable holds the state tokenize is in when decoding
 * a multiline function definition.  It is nonzero when more must be read.
 * Tokenize looks at spaces as token separators, and recognizes only
 * ';', '=', '(', ')' '{', '}', and '\n' as single character tokens.
 */
{
	int fd= *fundef;
	char *tok;
	token *newcmd;
	static char funsugar[]= { '(', 0, ')', '{', '}' };

	while ((tok= onetoken(&line, fd == 1)) != nil) {
		if (fd == 1) {
			fd++;	/* Function argument. */
		} else
		if (funsugar[fd] == tok[0]) {
			/* Recognize next token as part of a function def. */
			fd= tok[0] == '}' ? 0 : fd + 1;
		} else
		if (fd != 0) {
			if (tok[0] == ';' && fd == 3) {
				/* Kill separator between ')' and '{'. */
				free(tok);
				continue;
			}
			/* Syntax error unless between '{' and '}'. */
			if (fd != 4) fd= 0;
		}
		newcmd= alloc(nil, sizeof(*newcmd));
		newcmd->token= tok;
		newcmd->next= *acmds;
		*acmds= newcmd;
		acmds= &newcmd->next;
	}
	*fundef= fd;
	return acmds;
}

token *cmds;		/* String of commands to execute. */
int err;		/* Set on an error. */

char *poptoken(void)
/* Pop one token off the command chain. */
{
	token *cmd= cmds;
	char *tok= cmd->token;

	cmds= cmd->next;
	free(cmd);

	return tok;
}

void voidtoken(void)
/* Remove one token from the command chain. */
{
	free(poptoken());
}

int trapsig;

void trap(int sig)
{
	trapsig= sig;
	signal(sig, trap);
	alarm(1);
}

void interrupt(void)
/* Clean up after an ESC has been typed. */
{
	printf("[ESC]\n");
	trapsig= 0;
	err= 1;
}

int is_default(environment *e)
{
	return (e->flags & E_SPECIAL) && e->defval == nil;
}

environment **searchenv(char *name)
{
	environment **aenv= &env;

	while (*aenv != nil && strcmp((*aenv)->name, name) != 0) {
		aenv= &(*aenv)->next;
	}

	return aenv;
}

#define b_getenv(name)	(*searchenv(name))
/* Return the environment *structure* belonging to name, or nil if not found. */

char *b_value(char *name)
/* The value of a variable. */
{
	environment *e= b_getenv(name);

	return e == nil || !(e->flags & E_VAR) ? nil : e->value;
}

char *b_body(char *name)
/* The value of a function. */
{
	environment *e= b_getenv(name);

	return e == nil || !(e->flags & E_FUNCTION) ? nil : e->value;
}

int b_setenv(int flags, char *name, char *arg, char *value)
/* Change the value of an environment variable.  Returns the flags of the
 * variable if you are not allowed to change it, 0 otherwise.
 */
{
	environment **aenv, *e;

	if (*(aenv= searchenv(name)) == nil) {
		e= alloc(nil, sizeof(*e));
		e->name= copystr(name);
		e->flags= flags;
		e->defval= nil;
		e->next= nil;
		*aenv= e;
	} else {
		e= *aenv;

		/* Don't touch reserved names and don't change special
		 * variables to functions or vv.
		 */
		if (e->flags & E_RESERVED || (e->flags & E_SPECIAL
			&& (e->flags & E_FUNCTION) != (flags & E_FUNCTION)
		)) return e->flags;

		e->flags= (e->flags & E_STICKY) | flags;
		if (is_default(e)) {
			e->defval= e->value;
		} else {
			sfree(e->value);
		}
		sfree(e->arg);
	}
	e->arg= copystr(arg);
	e->value= copystr(value);
	return 0;
}

int b_setvar(int flags, char *name, char *value)
/* Set variable or simple function. */
{
	return b_setenv(flags, name, null, value);
}

void b_unset(char *name)
/* Remove a variable from the environment.  A special variable is reset to
 * its default value.
 */
{
	environment **aenv, *e;

	if ((e= *(aenv= searchenv(name))) == nil) return;

	if (e->flags & E_SPECIAL) {
		if (e->defval != nil) {
			sfree(e->arg);
			e->arg= null;
			sfree(e->value);
			e->value= e->defval;
			e->defval= nil;
		}
	} else {
		sfree(e->name);
		sfree(e->arg);
		sfree(e->value);
		*aenv= e->next;
		free(e);
	}
}

#define between(a, c, z)	((unsigned) ((c) - (a)) <= ((z) - (a)))

long a2l(char *a)
/* Cheap atol(). */
{
	int sign= 1;
	long n= 0;

	if (*a == '-') { sign= -1; a++; }

	while (between('0', *a, '9')) n= n * 10 + (*a++ - '0');

	return sign * n;
}

char *ul2a(u32_t n)
/* Transform a long number to ascii digits. */
{
	static char num[3 * sizeof(n)];
	char *a= arraylimit(num) - 1;

	do *--a = (n % 10) + '0'; while ((n/= 10) > 0);
	return a;
}

char *u2a(U16_t n)
/* Transform a short number to ascii digits. */
{
	return ul2a(n);
}

void get_parameters(void)
{
	char params[SECTOR_SIZE + 1];
	token **acmds;
	int fundef= 0;

	/* Variables that Minix needs: */
	b_setvar(E_SPECIAL|E_VAR|E_DEV, "rootdev", "ram");
	b_setvar(E_SPECIAL|E_VAR|E_DEV, "ramimagedev", "bootdev");
	b_setvar(E_SPECIAL|E_VAR, "ramsize", "0");
	b_setvar(E_SPECIAL|E_VAR, "processor", "?");
	b_setvar(E_SPECIAL|E_VAR, "bus", "?");
	b_setvar(E_SPECIAL|E_VAR, "memsize", "?");
	b_setvar(E_SPECIAL|E_VAR, "emssize", "?");
	b_setvar(E_SPECIAL|E_VAR, "video", "?");
	b_setvar(E_SPECIAL|E_VAR, "chrome", "?");

	/* Variables boot needs: */
	b_setvar(E_SPECIAL|E_VAR, "image", "minix");
	b_setvar(E_SPECIAL|E_FUNCTION, "main", "menu");

	/* Default menu function: */
	b_setenv(E_RESERVED|E_FUNCTION, "\1", "=,Start Minix", "boot");

	/* Reserved names: */
	b_setvar(E_RESERVED|E_VAR, "bootdev", null);
	b_setvar(E_RESERVED, "boot", null);
	b_setvar(E_RESERVED, "menu", null);
	b_setvar(E_RESERVED, "set", null);
	b_setvar(E_RESERVED, "unset", null);
	b_setvar(E_RESERVED, "save", null);
	b_setvar(E_RESERVED, "ls", null);
	b_setvar(E_RESERVED, "echo", null);
	b_setvar(E_RESERVED, "trap", null);
	b_setvar(E_RESERVED, "help", null);
	b_setvar(E_RESERVED, "exit", null);

	memset(params, 0, sizeof(params));

	/* Tokenize bootparams sector. */
	if (lseek(device, PARAMSEC * SECTOR_SIZE, SEEK_SET) < 0
				|| read(device, params, SECTOR_SIZE) < 0)
		fatal(devname);
	else {
		acmds= tokenize(&cmds, params, &fundef);

		/* Syntax check */
		(void) tokenize(acmds, ":;", &fundef);
	}
}

char *addptr;

void addparm(char *n)
{
	while (*n != 0 && *addptr != 0) *addptr++ = *n++;
}

void save_parameters(void)
/* Save nondefault environment variables to the bootparams sector. */
{
	environment *e;
	char params[SECTOR_SIZE + 1];

	/* Default filling: */
	memset(params, '\n', SECTOR_SIZE);

	/* Don't touch the 0! */
	params[SECTOR_SIZE]= 0;
	addptr= params;

	for (e= env; e != nil; e= e->next) {
		if (e->flags & E_RESERVED || is_default(e)) continue;

		addparm(e->name);
		if (e->flags & E_FUNCTION) {
			addparm("(");
			addparm(e->arg);
			addparm("){");
		} else {
			addparm((e->flags & (E_DEV|E_SPECIAL)) != E_DEV
							? "=" : "=d ");
		}
		addparm(e->value);
		if (e->flags & E_FUNCTION) addparm("}");
		if (*addptr == 0) {
			printf("The environment is too big\n");
			return;
		}
		*addptr++= '\n';
	}
	/* Save the parameters on disk. */
	if (lseek(device, PARAMSEC * SECTOR_SIZE, SEEK_SET) < 0
				|| write(device, params, SECTOR_SIZE) < 0) {
		report(devname);
		printf("Can't save environment\n");
	}
}

void show_env(void)
/* Show the environment settings. */
{
	environment *e;

	for (e= env; e != nil; e= e->next) {
		if (e->flags & E_RESERVED) continue;
		if (!istty && is_default(e)) continue;

		if (e->flags & E_FUNCTION) {
			printf("%s(%s) {%s}\n", e->name, e->arg, e->value);
		} else {
			printf(is_default(e) ? "%s = (%s)\n" : "%s = %s\n",
				e->name, e->value);
		}
	}
}

int numeric(char *s)
/* True iff s is a string of digits. */
{
	char *n= s;

	while (between('0', *n, '9')) n++;

	return n != s && *n == 0;
}

u32_t milli_time(void)
{
	return 1000 * (u32_t) time(nil);	/* Overflow is no problem. */
}

u32_t milli_since(u32_t base)
{
	return milli_time() - base;
}

char *Thandler;
u32_t Tbase, Tcount;

void unschedule(void)
/* Invalidate a waiting command. */
{
	alarm(0);

	if (Thandler != nil) {
		free(Thandler);
		Thandler= nil;
	}
}

void schedule(long msec, char *cmd)
/* Schedule command at a certain time from now. */
{
	unschedule();
	Thandler= cmd;
	Tbase= milli_time();
	Tcount= msec;
	alarm(1);
}

int expired(void)
/* Check if the timer expired.  If so prepend the scheduled command to
 * the command chain and return 1.
 */
{
	int fundef= 0;

	if (Thandler == nil || milli_since(Tbase) < Tcount) return 0;

	(void) tokenize(tokenize(&cmds, Thandler, &fundef), ";", &fundef);
	unschedule();
	return 1;
}

int delay(char *msec)
/* Delay for a given time.  Returns true iff delay was not interrupted.
 * If msec happens to be the string "swap" then wait till the user hits
 * return after changing diskettes.
 */
{
	int swap= 0;
	u32_t base, count;

	if (strcmp(msec, "swap") == 0) {
		swap= 1;
		count= 0;
		printf("\nInsert the root diskette then hit RETURN\n");
	} else
	if ((count= a2l(msec)) > 0) {
		base= milli_time();
	}

	alarm(1);	/* Let the "counter" run. */

	do {
		if (swap) {
			switch (getch()) {
			case ESC:	interrupt(); return 0;
			case '\n':	swap= 0;
			}
		} else
		if (count > 0) {
			pause();
			if (trapsig == SIGINT) interrupt();
		}
	} while (!expired()
		&& (swap || (count > 0 && milli_since(base) < count))
	);
	return 1;
}

enum whatfun { NOFUN, SELECT, DEFFUN, USERFUN } menufun(environment *e)
{
	if (!(e->flags & E_FUNCTION) || e->arg[0] == 0) return NOFUN;
	if (e->arg[1] != ',') return SELECT;
	return e->flags & E_RESERVED ? DEFFUN : USERFUN;
}

void menu(void)
/* By default:  Show a simple menu.
 * Multiple kernels/images:  Show extra selection options.
 * User defined function:  Kill the defaults and show these.
 * Wait for a keypress and execute the given function.
 */
{
	int fundef= 0, c, def= 1;
	char *choice= nil;
	environment *e;
	struct termios rawterm;

	rawterm= termbuf;
	rawterm.c_lflag &= ~(ICANON|ECHO|IEXTEN);
	if (tcsetattr(0, TCSANOW, &rawterm) < 0) fatal("");

	/* Just a default menu? */
	for (e= env; e != nil; e= e->next) if (menufun(e) == USERFUN) def= 0;

	printf("\nHit a key as follows:\n\n");

	/* Show the choices. */
	for (e= env; e != nil; e= e->next) {
		switch (menufun(e)) {
		case DEFFUN:
			if (!def) break;
			/*FALL THROUGH*/
		case USERFUN:
			printf("    %c  %s\n", e->arg[0], e->arg+2);
			break;
		case SELECT:
			printf("    %c  Select %s kernel\n", e->arg[0],e->name);
			break;
		default:;
		}
	}

	/* Wait for a keypress. */
	do {
		if ((c= getch()) == ESC) {
			if (trapsig == SIGINT) { interrupt(); goto ret; }
			if (expired()) goto ret;
		}

		for (e= env; e != nil; e= e->next) {
			switch (menufun(e)) {
			case DEFFUN:
				if (!def) break;
			case USERFUN:
			case SELECT:
				if (c == e->arg[0]) choice= e->value;
			}
		}
	} while (choice == nil);

	/* Execute the chosen function. */
	printf("%c\n", c);
	(void) tokenize(&cmds, choice, &fundef);
ret:
	if (tcsetattr(0, TCSANOW, &termbuf) < 0) fatal("");
}

void help(void)
/* Not everyone is a rocket scientist. */
{
	struct help {
		char	*thing;
		char	*help;
	} *pi;
	static struct help info[] = {
		{ nil,	"Names:" },
		{ "rootdev",		"Root device" },
		{ "ramimagedev",	"RAM disk image if root is RAM" },
		{ "ramsize",		"RAM disk size if root is not RAM" },
		{ "bootdev",		"Special name for the boot device" },
		{ "fd0, hd3, hd2a",	"Devices (as in /dev)" },
		{ "image",		"Name of the kernel image" },
		{ "main",		"Startup function" },
		{ nil,	"Commands:" },
		{ "name = [device] value",  "Set environment variable" },
		{ "name() { ... }",	    "Define function" },
		{ "name(key,text) { ... }",
			"A menu function like: minix(=,Start Minix) {boot}" },
		{ "name",		"Call function" },
		{ "boot [device]",	"Boot Minix or another O.S." },
		{ "delay [msec]",	"Delay (500 msec default)" },
		{ "echo word ...",	"Print the words" },
		{ "ls [directory]",	"List contents of directory" },
		{ "menu",		"Choose a menu function" },
		{ "save",		"Save environment" },
		{ "set",		"Show environment" },
		{ "trap msec command",	"Schedule command" },
		{ "unset name ...",	"Unset variable or set to default" },
		{ "exit",		"Exit to UNIX" },
	};

	for (pi= info; pi < arraylimit(info); pi++) {
		if (pi->thing != nil) printf("    %-24s- ", pi->thing);
		printf("%s\n", pi->help);
	}
}

void execute(void)
/* Get one command from the command chain and execute it. */
{
	token *second, *third, *fourth, *fifth, *sep;
	char *name= cmds->token;
	size_t n= 0;

	/* There must be a separator lurking somewhere. */
	for (sep= cmds; sep != nil && sep->token[0] != ';'; sep= sep->next) n++;

	if ((second= cmds->next) != nil
		&& (third= second->next) != nil
		&& (fourth= third->next) != nil)
			fifth= fourth->next;

		/* Null command? */
	if (n == 0) {
		voidtoken();
		return;
	} else
		/* name = [device] value? */
	if ((n == 3 || n == 4)
		&& !sugar(name)
		&& second->token[0] == '='
		&& !sugar(third->token)
		&& (n == 3 || (n == 4 && third->token[0] == 'd'
					&& !sugar(fourth->token)
	))) {
		char *value= third->token;
		int flags= E_VAR;

		if (n == 4) { value= fourth->token; flags|= E_DEV; }

		if ((flags= b_setvar(flags, name, value)) != 0) {
			printf("%s is a %s\n", name,
				flags & E_RESERVED ? "reserved word" :
						"special function");
			err= 1;
		}
		while (cmds != sep) voidtoken();
		return;
	} else
		/* name '(' arg ')' '{' ... '}'? */
	if (n >= 5
		&& !sugar(name)
		&& second->token[0] == '('
		&& fourth->token[0] == ')'
		&& fifth->token[0] == '{'
	) {
		token *fun= fifth->next;
		int ok= 1, flags;
		char *body;
		size_t len= 1;

		sep= fun;
		while (sep != nil && sep->token[0] != '}') {
			len+= strlen(sep->token) + 1;
			sep= sep->next;
		}
		if (sep == nil || (sep= sep->next) == nil
			|| sep->token[0] != ';'
		) ok= 0;

		if (ok) {
			body= alloc(nil, len * sizeof(char));
			*body= 0;

			while (fun->token[0] != '}') {
				strcat(body, fun->token);
				if (!sugar(fun->token)
					&& !sugar(fun->next->token)
				) strcat(body, " ");
				fun= fun->next;
			}

			if ((flags= b_setenv(E_FUNCTION, name,
						third->token, body)) != 0) {
				printf("%s is a %s\n", name,
					flags & E_RESERVED ? "reserved word" :
							"special variable");
				err= 1;
			}
			while (cmds != sep) voidtoken();
			free(body);
			return;
		}
	} else
		/* Command coming up, check if ESC typed. */
	if (trapsig == SIGINT) {
		interrupt();
		return;
	} else
		/* unset name ..., echo word ...? */
	if (n >= 1 && (
		strcmp(name, "unset") == 0
		|| strcmp(name, "echo") == 0
	)) {
		int cmd= name[0];
		char *arg= poptoken();

		for (;;) {
			free(arg);
			if (cmds == sep) break;
			arg= poptoken();
			if (cmd == 'u') {
				b_unset(arg);
			} else {
				printf("%s", arg);
				if (cmds != sep) putchar(' ');
			}
		}
		if (cmd == 'e') putchar('\n');
		return;
	} else
		/* boot device, ls dir, delay msec? */
	if (n == 2 && (
		strcmp(name, "boot") == 0
		|| strcmp(name, "delay") == 0
		|| strcmp(name, "ls") == 0
	)) {
		if (name[0] == 'b') printf("[boot %s]\n", second->token);
		if (name[0] == 'd') (void) delay(second->token);
		if (name[0] == 'l') printf("[ls %s]\n", second->token);
		voidtoken();
		voidtoken();
		return;
	} else
		/* trap msec command? */
	if (n == 3 && strcmp(name, "trap") == 0 && numeric(second->token)) {
		long msec= a2l(second->token);

		voidtoken();
		voidtoken();
		schedule(msec, poptoken());
		return;
	} else
		/* Simple command. */
	if (n == 1) {
		char *cmd= poptoken();
		char *body;
		int fundef= 0;
		int ok= 0;

		if (strcmp(cmd, "boot") == 0) { printf("[boot]\n"); ok= 1; }
		if (strcmp(cmd, "delay") == 0) { (void) delay("500"); ok= 1; }
		if (strcmp(cmd, "ls") == 0) { printf("[ls]\n"); ok= 1; }
		if (strcmp(cmd, "menu") == 0) { menu(); ok= 1; }
		if (strcmp(cmd, "save") == 0) { save_parameters(); ok= 1; }
		if (strcmp(cmd, "set") == 0) { show_env(); ok= 1; }
		if (strcmp(cmd, "help") == 0) { help(); ok= 1; }
		if (strcmp(cmd, "exit") == 0) exit(0);

		/* Command to check bootparams: */
		if (strcmp(cmd, ":") == 0) ok= 1;

		/* User defined function. */
		if (!ok && (body= b_body(cmd)) != nil) {
			(void) tokenize(&cmds, body, &fundef);
			ok= 1;
		}
		if (!ok) printf("%s: unknown function", cmd);
		free(cmd);
		if (ok) return;
	} else {
		/* Syntax error. */
		printf("Can't parse:");
		while (cmds != sep) {
			printf(" %s", cmds->token); voidtoken();
		}
	}

	/* Getting here means that the command is not understood. */
	printf("\nTry 'help'\n");
	err= 1;
}

void monitor(void)
/* Read one or more lines and tokenize them. */
{
	char *line;
	int fundef= 0;
	token **acmds= &cmds;

	unschedule();	/* Kill a trap. */

	do {
		if (istty) putchar(fundef == 0 ? '>' : '+');
		fflush(stdout);
		line= readline();
		acmds= tokenize(acmds, line, &fundef);
		free(line);
	} while (fundef != 0);
}

void main(int argc, char **argv)
/* Do not load or start anything, just edit parameters. */
{
	int i;
	char bootcode[SECTOR_SIZE];

	if (tcgetattr(0, &termbuf) < 0) istty= 0;
	if (argc > 2) istty= 0;

	if (argc < 2) {
		fprintf(stderr, "Usage: edparams device [command ...]\n");
		exit(1);
	}

	/* Go over the arguments, changing control characters to spaces. */
	for (i= 2; i < argc; i++) {
		char *p;

		for (p= argv[i]; *p != 0; p++) {
			if ((unsigned) *p < ' ' && *p != '\n') *p= ' ';
		}
	}

	devname= argv[1];
	if ((device= open(devname, O_RDWR | O_CREAT, 0666)) < 0)
		fatal(devname);

	/* Check if it is a bootable Minix device. */
	if (read(device, bootcode, SECTOR_SIZE) != SECTOR_SIZE
		|| memcmp(bootcode, boot_magic, sizeof(boot_magic)) != 0) {
		fprintf(stderr, "edparams: %s: not a bootable Minix device\n",
			devname);
		exit(1);
	}

	/* Print greeting message.  */
	if (istty) printf("Boot parameters editor.\n");

	signal(SIGINT, trap);
	signal(SIGALRM, trap);

	/* Get environment variables from the parameter sector. */
	get_parameters();

	i= 2;
	for (;;) {
		/* While there are commands, execute them! */
		while (cmds != nil || i < argc) {
			if (cmds == nil) {
				/* A command line command. */
				token **acmds;
				int fundef= 0;
				acmds= tokenize(&cmds, argv[i++], &fundef);
				(void) tokenize(acmds, ";", &fundef);
			}
			execute();
			if (err) {
				/* An error, stop interpreting. */
				if (!istty) exit(1);
				while (cmds != nil) voidtoken();
				err= 0;
				break;
			}
			(void) expired();
		}

		/* Commands on the command line? */
		if (argc > 2) break;

		/* The "monitor" is just a "read one command" thing. */
		monitor();
	}
	exit(0);
}
