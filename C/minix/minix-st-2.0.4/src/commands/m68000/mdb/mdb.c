/*
 * mdb.c - MINIX program debugger
 *
 * Written by Bruce D. Szablak
 *
 * This free software is provided for non-commerical use. No warrantee
 * of fitness for any use is implied. You get what you pay for. Anyone
 * may make modifications and distribute them, but please keep this header
 * in the distribution.
 */

#define T_OK		0
#define T_GETINS	1
#define T_GETDATA	2
#define T_GETUSER	3
#define	T_SETINS	4
#define T_SETDATA	5
#define T_SETUSER	6
#define T_RESUME	7
#define T_EXIT		8
#define T_STEP		9

#include "stdio.h"
#include <sys/types.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <string.h>
#include <unistd.h>
#include "signal.h"
#include "ctype.h"
#include "setjmp.h"
#include "user.h"
#include "sgtty.h"
#include "mdb.h"

struct proc *prc;

#define MAXLINE 120
#define PC ((long)&((struct proc *)0)->p_reg.pc)
#define MAXB 10
#define MAXP 3
#define MAXARG 20
#define SIZ (1 + sizeof(struct proc)/sizeof(long))
#define MAXLINE 120

long lbuf[SIZ], saddr, eaddr;
int curpid, cursig;
char *prog, sbuf[MAXLINE], *cmd, *cmdstart;
jmp_buf mainlp;
struct sgttyb in_gttyb, sv_gttyb; /* initial and saved */
struct tchars in_chars, sv_chars;
extern errno;

struct b_pnt
{
	struct b_pnt *nxt, *prv;
	long addr;
	long oldval;
	char cmd[1];
} *b_head, *curpnt;

_PROTOTYPE(void cleanup , (void));
_PROTOTYPE(int dowait , (void));
_PROTOTYPE(void update , (int dotty ));
_PROTOTYPE(void findbpnt , (int verbose ));
_PROTOTYPE(int disp_regs , (void));
_PROTOTYPE(char *skip , (char *s ));
_PROTOTYPE(void endcmd , (void));
_PROTOTYPE(int exebpnt , (int restart ));
_PROTOTYPE(void tstart , (int req , int verbose , int val , int cnt ));
_PROTOTYPE(void catch , (int sig ));
_PROTOTYPE(int run , (char *name , char *argstr , int tflg ));
_PROTOTYPE(void backtrace , (int all ));
_PROTOTYPE(void freepnt , (struct b_pnt *pnt ));
_PROTOTYPE(void breakpt , (long addr , char *cmd ));
_PROTOTYPE(void modify , (long addr , int cnt , int verbose ));
_PROTOTYPE(void display , (long addr , int req ));
_PROTOTYPE(void fill , (long addr , int req ));
_PROTOTYPE(void command , (void));
_PROTOTYPE(void main, (int argc, char *argv[]));

#if READLINE
char  *cbuf, *prompt = "* ";
_PROTOTYPE(char *readline, (char *buf));
_PROTOTYPE(void add_history, (char *line));
#else
char cbuf[MAXLINE];
#endif /* READLINE */

void cleanup()
{
	curpid = 0;
	curpnt = 0;
	while (b_head) freepnt(b_head);
}

dowait()
{
	int stat, ls, hs;

	while (wait(&stat) != curpid) {};
	ls = stat & 0xFF;
	hs = (stat >> 8) & 0xFF;
	if (ls == 0)
	{
		if (hs != 127)
			printf("child exited with status %d\n", hs);
		cleanup();
		return 0;
	}
	if (hs == 0)
	{
		printf("child terminated by signal %d\n", ls & 0x7F);
		if (ls & 0x80) printf("(core dumped)\n");
		cleanup();
		return 0;
	}
	return cursig = hs;
}
		
void update(dotty)
{
	int i;

	if (dotty)
	{
		ioctl(0, TIOCGETP, &sv_gttyb);
		ioctl(0, TIOCGETC, &sv_chars);
		ioctl(0, TIOCSETP, &in_gttyb);
		ioctl(0, TIOCSETC, &in_chars);
	}
	for (i = 0; i < (SIZ-1); i++)
	{
		lbuf[i] = ptrace(T_GETUSER, curpid, (long)(i*sizeof(long)),0L);
	}
	saddr = (long)prc->p_map[T].mem_vir << CLICK_SHIFT;
	eaddr = (long)(prc->p_map[D].mem_vir + prc->p_map[D].mem_len)
							<< CLICK_SHIFT;
}

void findbpnt(verbose)
{
	for (curpnt = b_head; curpnt; curpnt = curpnt->nxt)
	{
		if (curpnt->addr == prc->p_reg.pc)
		{
			ptrace(T_SETINS, curpid, curpnt->addr, curpnt->oldval);
			if (curpnt->cmd[0] != '\n')
				cmd = strcpy(cbuf, curpnt->cmd);
			else if (verbose)
				printf("Breakpoint hit.\n");
			return;
		}
	}
	if (verbose) printf("Unknown breakpoint hit.\n");
}

disp_regs()
{
	int i;
	register reg_t *reg = (reg_t *)&prc->p_reg;

	if (curpid <= 0)
	{
		printf("No active process.\n");
		return 1;
	}
	printf("\npc=%lx psw=%x\n\n",(long)prc->p_reg.pc, prc->p_reg.psw);
	printf(
"      0        1        2        3        4        5        6        7\nD");
	for (i = 0; i < 8; i++) printf(" %08lx", *reg++);
	printf("\nA");
	for (; i < NR_REGS; i++) printf(" %08lx", *reg++);
	printf(" %08lx\n\n", (long)prc->p_reg.sp);
	return 0;
}

char *
skip(s)
	register char *s;
{
	while (isspace(*s)) ++s;
	return *s ? s : s-1;
}

void endcmd()
{
	while (*cmd != '\n' && *cmd != ';') ++cmd;
}

#define BREAK(l) (0xA0000000 | ((l) & 0xFFFF))

exebpnt(restart)
{
	ptrace(T_STEP, curpid, 0L, (long)restart);
	if (dowait() == 0) return 1;
	ptrace(T_SETINS, curpid, curpnt->addr, BREAK(curpnt->oldval));
	curpnt = 0;
	return 0;
}

void tstart(req, verbose, val, cnt)
{
	if (curpid == 0)
	{
		if (verbose) printf("No active process.\n");
		return;
	}
	if (req == T_EXIT)
	{
		ptrace(T_EXIT, curpid, 0L, (long)val);
		dowait();
		return;
	}
	if (cnt==0) cnt = 1;
	ioctl(0, TIOCSETP, &sv_gttyb);
	ioctl(0, TIOCSETC, &sv_chars);
	do
	{
		if (curpnt)
		{
			if (exebpnt(val)) return;
			if (req == T_RESUME) cnt++;
			val = 0;
		}
		else
		{
			ptrace(req, curpid, 0L, (long)val);
			if (dowait() == 0) return;
			val = 0;
			switch (cursig)
			{
			case	SIGEMT: /* breakpoint */
				update(0);
				findbpnt(cnt <= 1);
				break;
			case	SIGTRAP: /* trace trap? */
				if (req == T_STEP) break;
			default: /* signal */
				val = cursig;
				break;
			}
		}
	}
	while (--cnt > 0);
	update(1);
	dasm((long)prc->p_reg.pc, 1, 1);
}

void catch(sig)
{
	signal(sig, catch);
	if (sig == SIGINT || sig == SIGQUIT) return;
	tstart(T_EXIT, 0, sig, 0);
	exit(0);
}

int run(name, argstr, tflg)
	char *name, *argstr;
{
	int procid;

	if( (procid = fork()) == 0 )
	{
		char *argv[MAXARG], *inf = 0, *outf = 0;
		int argc;

		if (tflg && ptrace(T_OK, 0, 0L, 0L) < 0)
		{
			perror("ptrace");
			exit(127);
		}
		argv[0] = name;
		for (argc = 1; ; )
		{
			argstr = skip(argstr);
			if (*argstr == '\n' || *argstr == ';')
			{
				argv[argc] = 0;
				if (inf) freopen(inf, "r", stdin);
				if (outf) freopen(outf, "w", stdout);
			        execvp(name, argv);
				perror("execvp");
			        exit( 127 );
			}
			if (*argstr == '<') inf = argstr+1;
			else if (*argstr == '>') outf = argstr+1;
			else if (argc == MAXARG)
			{
				printf("Too many arguments.\n");
				exit(127);
			}
			else argv[argc++] = argstr;
			while (!isspace(*argstr)) argstr++;
			if (*argstr == '\n') argstr[1] = '\n', argstr[2] = 0;
			*argstr++ = 0;
		}
	}
	if (procid < 0)
	{
		printf("Fork failed.\n");
	}
	return procid;
}

#define ADDQ(l) (((l >> 16) & 0xF13F) == 0x500F)
#define ADDQ_CNT(l) ((((l >> 25) - 1) & 7) + 1)
#define LEA(l) ((l >> 16) == 0x4FEF)
#define LEA_DISP(l) ((long)(int)l)
#define ADDA(l) ((int)(l >> 16) == 0xDFFC)

void backtrace(all)
{
	char sep;
	long pc, bp, off, val, obp, opc;

	if (curpid <= 0)
	{
		printf("No process.\n");
		return;
	}
	pc = prc->p_reg.pc;
#ifdef ALTES_MINIX
	bp = prc->p_reg.a6;
#else
	bp = prc->p_reg.fp;
#endif /* ALTES_MINIX */
	if (bp == 0)
	{
		printf("No active frame.\n");
		return;
	}
	errno = 0;
	do
	{
		opc = pc;
		pc = ptrace(T_GETDATA, curpid, bp+4, 0L);
		off = ptrace(T_GETDATA, curpid, pc, 0L);
		if (errno) return;
		symbolic(opc, '(');
		obp = bp;
		bp += 2*sizeof(val);
		if (ADDQ(off))
			off = ADDQ_CNT(off) + bp;
		else if (LEA(off))
			off = LEA_DISP(off) + bp;
		else if (ADDA(off))
			off = ptrace(T_GETDATA, curpid, pc+2, 0L) + bp;
		else
			goto skiplp;

		for (;;)
		{
			if (errno) return;
			val = ptrace(T_GETDATA, curpid, bp, 0L) >> 16;
			printf("0x%04x", (int)val);
			bp += sizeof(int);
			if (bp >= off) break;
			putc(',', stdout);
		}

		skiplp:

		fputs(")\n", stdout);
		bp = ptrace(T_GETDATA, curpid, obp, 0L);
	}
	while (all && bp);
}

void freepnt(pnt)
	struct b_pnt *pnt;
{
	if (pnt->prv) pnt->prv->nxt = pnt->nxt;
	else b_head = pnt->nxt;
	if (pnt->nxt) pnt->nxt->prv = pnt->prv;
	if (curpid > 0) ptrace(T_SETINS, curpid, pnt->addr, pnt->oldval);
	free(pnt);
	if (pnt == curpnt) curpnt = 0;
}

void breakpt(addr, cmd)
	long addr;
	char *cmd;
{
	char *s;
	struct b_pnt *new;
	int lng;

	if (curpid <= 0)
	{
		printf("No active process.\n");
		return;
	}
	for (new = b_head; new; new=new->nxt)
		if (new->addr == addr)
		{
			printf("Breakpoint already exists here.\n");
			return;
		}
	new = malloc(sizeof(struct b_pnt) + strlen(cmd));
	if (new == 0)
	{
		printf("No room.\n");
		return;
	}
	new->nxt = b_head;
	new->prv = 0;
	if (b_head) b_head->prv = new;
	b_head = new;
	new->addr = addr;
	strcpy(new->cmd, cmd);
	new->oldval = ptrace(T_GETINS, curpid, addr, 0L);
	ptrace(T_SETINS, curpid, addr, BREAK(new->oldval));
	if (ptrace(T_GETINS, curpid, addr, 0L) != BREAK(new->oldval))
	{
		perror("Can't set breakpoint");
		freepnt(new);
	}
}

void modify(addr, cnt, verbose)
	long addr;
{
	long curval, off;

	if (curpid == 0)
	{
		printf("No active process.\n");
		return;
	}
	curval = ptrace(T_GETDATA, curpid, addr, 0L);
	ioctl(0, TIOCSETP, &sv_gttyb);
	ioctl(0, TIOCSETC, &sv_chars);
	do
	{
		if (cursig == SIGTRAP) cursig = 0;
		if (verbose)
		{
			off = ptrace(T_GETUSER, curpid, PC, 0L);
			dasm(off, 1, 0);
		}
		if (curpnt && exebpnt(cursig)) return;
		else
		{
			ptrace(T_STEP, curpid, addr, 0L);
			switch (dowait())
			{
			case	0: return;
			case	SIGEMT: update(0); findbpnt(0); break;
			}
		}
		if (curval != ptrace(T_GETDATA, curpid, addr, 0L))
		{
			printf("Modification detected\n");
			break;
		}
	}
	while (--cnt);
	update(1);
	dasm(prc->p_reg.pc, 1, 1);
	return;
}

void display(addr, req)
	long addr;
{
	int count, size, out, shift;
	long val, msk;
	char fmt;

	if (curpid == 0)
	{
		printf("No active process\n");
		return;
	}
	count = strtol(cmd, &cmd, 0);
	if (count == 0) count = 1;
	if (*cmd == 'i' || *cmd == 'I')
	{
		if (req == T_GETUSER)
		{
			printf("Can't disassemble a register's contents.\n");
/*			longjmp(mainlp); --jrb */
			longjmp(mainlp, 1); /* ++jrb */
		}
		dasm(addr, count, *cmd == 'i');
		return;
	}
	switch (*cmd++)
	{
	case	'b': size = sizeof(char); break;
	case	'h': size = sizeof(short); break;
	case	'l': size = sizeof(long); break;
	default	   : size = sizeof(int); --cmd; break;
	}
	switch (fmt = *cmd)
	{
	case	'c': count *= size; size = sizeof(char); break;
	case	's': addr = ptrace(req, curpid, addr, 0L); req = T_GETDATA;
	case	'a': size = sizeof(char);
		     break;
	}
	out = 0;
	msk = size == sizeof(long) ? 0xFFFFFFFF : (1L << (8*size)) - 1;
	shift = 32 - 8*size;
	do
	{
		val = (ptrace(req, curpid, addr, 0L) >> shift) & msk;
		if (out == 0) printf("\n0x%08lx: ", addr);
		switch (fmt)
		{
		case	'c':
			printf(isprint(val) ? "   %c " : "\\%03o ", (char)val);
			if (++out == 8) out = 0;
			break;
		case	'u':
			printf("%12lu ", val); if (++out == 4) out = 0; break;
		case	'x':
			printf("%*lx ", 2*size, val);
			if (++out == (size == 4 ? 4 : 8)) out = 0;
			break;
		case	'o':
			printf("%*lo ", 3*size, val);
			if (++out == (size == 4 ? 4 : 8)) out = 0;
			break;
		case	's':
		case	'a':
			if (val) fputc((char)val, stdout);
			else goto exitlp;
			if (++out == 64) out = 0;
			break;
		default:
		case	'd':
			printf("%12ld ", val); if (++out == 4) out = 0; break;
		}
		addr += size;
	}
	while (--count > 0 || fmt == 's' || fmt == 'a');
exitlp:
	fputc('\n', stdout);
}

void fill(addr, req)
	long addr;
{
	int count, size, shift, seg;
	long val, msk, nval;
	char fmt;

	if (curpid == 0)
	{
		printf("No active process\n");
		return;
	}
	count = strtol(cmd, &cmd, 0);
	switch (*cmd++)
	{
	case	'b': size = sizeof(char); break;
	case	'h': size = sizeof(short); break;
	case	'l': size = sizeof(long); break;
	default	   : size = sizeof(int); --cmd; break;
	}
	shift = 32 - 8*size;
	msk = (0x80000000 >> 8*size);
	cmd = getexp(cmd, &nval, &seg);
	nval <<= shift;
	do
	{
		val = ptrace(req, curpid, addr, 0L) | (nval & msk);
		val &= (nval | ~msk);
		ptrace(req+3, curpid, addr, val);
		addr += size;
	}
	while (--count>0);
}

void command()
{
	char c, *p;
	int i, seg;
	long exp;
	struct b_pnt *bp;

	seg = S; /* don't restrict segment expressions are in */
	cmdstart = cmd = skip(cmd);
	cmd = getexp(cmd, &exp, &seg);
	if (exp == 0)
	{
		seg = T;
		exp = prc->p_reg.pc;
	}
	switch (c = *cmd++)
	{
	case '!': /* escape to shell OR set variable to value */
		if (cmd == cmdstart+1)
		{
			cmd = skip(cmd);
			if (*cmd == '\n' || *cmd == ';')
			{
				i = run("/bin/sh", "\n", 0);
			}
			else
			{
				for (p=cmd+1; *p && !isspace(*p); p++) {};
				*p++ = 0;
				i = run(cmd, *p ? p : "\n", 0);
			}
			if (i > 0) while (wait(&seg) != i) {};
			break;
		}
		if (seg == 'T')
		{
			printf("Can only modify data variables.\n");
			break;
		}
		fill(exp, T_GETDATA);
		break;
	case 'T': /* top line of backtrace */
		backtrace(0);
		break;
	case 't': /* back trace */
		backtrace(1);
		break;
	case '/': /* print variable value */
		display(exp, T_GETDATA);
		break;
	case 'x': /* print registers and instruction */
		if (disp_regs()) break;
		/*FALLTHROUGH*/
	case 'X': /* print instruction */
		i = strtol(cmd, &cmd, 0);
		if (curpid > 0)
			dasm(exp, i ? i : 1, 1);
		else
			printf("No active process.\n");
		break;
	case 'R': /* run program with no args */
	case 'r': /* run program with args (possibly defaulted) */
		tstart(T_EXIT, 0, 0, 0);
		if (c == 'r')
		{
			cmd = skip(cmd);
			if (*cmd == '\n' || *cmd == ';') cmd = sbuf;
			else strcpy(sbuf, cmd);
		}
		else
		{
			cmd = "\n";
		}
		if (curpid = run(prog, cmd, 1))
		{
			if (dowait())
			{
			    ptrace(T_SETUSER, curpid,
#ifdef ALTES_MINIX
				 (long)&((struct proc *)0)->p_reg.a6, 0L);
#else
				 (long)&((struct proc *)0)->p_reg.fp, 0L);
#endif

			    update(1);
			    printf("Process stopped.\n");
			}
		}
		break;
	case 'c': /* continue program - ignore signal */
		cursig = 0;
	case 'C': /* continue program - handle signal */
		i = 0;
		if (seg == T && curpnt == 0 && cmd != cmdstart+1)
		{
			breakpt(exp, "\n");
			curpnt = b_head;
			ptrace(T_SETINS, curpid, curpnt->addr, curpnt->oldval);
			i = 1;
		}
		tstart(T_RESUME, 1, cursig, (int)strtol(cmd, &cmd, 0));
		if (i) /* remove temporary bp */
		{
			freepnt(b_head);
		}
		if (cursig == SIGEMT) return;
		if (curpid) printf("Process stopped by signal %d\n", cursig);
		break;
	case 'i': /* single step - ignore signal */
		tstart(T_STEP, 1, 0, (int)strtol(cmd, &cmd, 0));
		break;
	case 'I': /* single step - handle signal */
		tstart(T_STEP, 1, cursig, (int)strtol(cmd, &cmd, 0));
		break;
	case 'm': /* single step until location modified */
	case 'M': /* single step until location modified - verbose */
		modify(exp, (int)strtol(cmd, &cmd, 0), c == 'M');
		break;
	case 'k': /* kill current program */
		tstart(T_EXIT, 1, 0, 0);
		break;
	case 'b': /* set a breakpoint at the given line */
		if (seg == D)
		{
			printf("Address not in text space.\n");
			return;
		}
		breakpt(exp, skip(cmd));
		cmd = "\n";
		return;
	case 'B': /* print list of currently active breakpoints */
		for (i = 1, bp = b_head; bp; bp=bp->nxt, i++)
		{
			p = addr_to_name(bp->addr - saddr, &exp);
			printf("%2d: %s+0x%lx (0x%lx) - %s",
				i, p, exp, bp->addr, bp->cmd);
		}
		break;
	case 'd': /* delete breakpoint */
		if (seg == T)
		{
			for (bp = b_head; bp && bp->addr != exp; bp=bp->nxt) {};
			if (bp) { freepnt(bp); break; }
		}
		printf("No such breakpoint.\n");
		break;
	case 'D': /* delete all breakpoints */
		while(b_head) freepnt(b_head);
		break;
	case 'q': /* quit */
		tstart(T_EXIT, 0, 0, 0);
		exit(0);
	case '\n':
	case ';':
		if (isdigit(*cmdstart)) symbolic(exp, '\n');
		else printf("0x%lx\n", exp);
		--cmd;
		break;
	case 'v': printf("MDB version 1.1\n"); break;
	case '$':
		cmdstart = cmd;
		cmd = skip(cmd+2);
		if (*cmd == '!')
		{
			cmd++;
			fill(reg_addr(cmdstart), T_GETUSER);
			break;
		}
		if (*skip(cmd+2) == '/')
		{
			cmd++;
			display(reg_addr(cmdstart), T_GETUSER);
			break;
		}
		/*FALLTHROUGH*/
	default:
		printf("Unknown command.\n");
		break;
	}
	while (*cmd != '\n' && *cmd != ';') ++cmd;
	if (*cmd == ';') cmd = skip(cmd+1);
}

void main(argc, argv)
	char *argv[];
{
	int i;
	
	prc  = (struct proc *)lbuf;
	ioctl(0, TIOCGETP, &in_gttyb);
	ioctl(0, TIOCGETC, &in_chars);

	for (i = 1; i < _NSIG; i++) signal(i, catch);
	strcpy(sbuf, "\n");
	prog = argc > 1 ? argv[1] : "a.out";
	getsyms(prog);

/*	setjmp(&mainlp); --jrb */
	setjmp(mainlp);  /* ++jrb */
#if READLINE
	while ((cbuf = readline(prompt)) != NULL) {
		if (strlen(cbuf) >= MAXLINE - 2)
		{
			printf("Command line too long.\n");
			free(cbuf);
			continue;
		}
		add_history(cbuf);
		strcat(cbuf, "\n");

		cmd = cbuf;
		command();
		while (*cmd != '\n') command();
		free(cbuf);
#else
	while ((printf("* "), fflush(stdout),
			fgets(cbuf, sizeof(cbuf), stdin)) != NULL)
	{
		if (strlen(cbuf) == sizeof(cbuf)-1)
		{
			printf("Command line too long.\n");
			continue;
		}
		cmd = cbuf;
		command();
		while (*cmd != '\n') command();
#endif /* READLINE */
	}
        tstart(T_EXIT, 0, 0, 0);
	exit(0);
}
