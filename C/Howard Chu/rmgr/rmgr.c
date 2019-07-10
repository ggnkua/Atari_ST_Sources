/* Copyright (c) 1987,1988 Oliver Laumann, Technical University of Berlin.
 * Not derived from licensed software.
 *
 * Permission is granted to freely use, copy, modify, and redistribute
 * this software, provided that no attempt is made to gain profit from it,
 * the author is not construed to be liable for any results of using the
 * software, alterations are clearly marked as such, and this notice is
 * not modified.
 */

/* This program Copyright 1990 by Howard Chu.
 *
 * This is rmgr, a remote window manager for Bellcore's MGR window
 * manager, by Howard Chu @ University of Michigan (Ann Arbor, MI).
 * Much of this program consists of Oliver Laumann's code; I have not
 * (usually) highlighted my changes in any way. Oliver didn't use any
 * comments at all; for the most part I have followed his lead...  }-)
 * Suffice to say, some of the routines are original, some are heavily
 * hacked upon versions of his code, and some are untouched from his
 * program. Of course, the volume of code here represents only half
 * of the code used in the screen program; the rest, support for ANSI
 * terminal emulation, was discarded.
 */

static char Version[] = "$Header: /usr/src/rmgr/RCS/rmgr.c,v 1.5 90/10/15 03:39:02 hyc Stable $";

#include <stdio.h>
#include <sgtty.h>
#include <signal.h>
#include <errno.h>
#include <ctype.h>
#include <utmp.h>
#include <pwd.h>
#include <nlist.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/file.h>
#include <sys/wait.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/stat.h>
#include <sys/dir.h>
#include "rmgr.h"

#ifdef GETTTYENT
#   include <ttyent.h>
#else
    static struct ttyent {
	char *ty_name;
    } *getttyent();
    static char *tt, *ttnext;
    static char ttys[] = "/etc/ttys";
#endif

#define MAXWIN     10
#define MSGWAIT     5

#define Ctrl(c) ((c)&037)

extern char **environ;
extern errno;
extern sys_nerr;
extern char *sys_errlist[];
extern char *index(), *rindex(), *malloc(), *getenv(), *MakeTermcap();
extern char *getlogin(), *ttyname();
static void AttacherFinit(), Finit(), SigHup(), SigChld();
static char *Filename(), **SaveArgs(), *GetTtyName();

static char PtyName[32], TtyName[32];
static char *ShellProg;
static char *ShellArgs[2];
static char inbuf[IOSIZE];
static inlen;
static ESCseen;
static GotSignal;
static char DefaultShell[] = "/bin/sh";
static char DefaultPath[] = ":/usr/ucb:/bin:/usr/bin";
static char PtyProto[] = "/dev/ptyXY";
static char TtyProto[] = "/dev/ttyXY";
static int TtyMode = 0622;
static char SockPath[512];
static char SockDir[] = ".rmgr";
static char *SockNamePtr, *SockName;
static ServerSocket;
static char *NewEnv[MAXARGS];
static char Esc = Ctrl('a');
static char *home;
static HasWindow;
static utmp, utmpf;
static char UtmpName[] = "/etc/utmp";
static char *LoginName;
static char HostName[MAXSTR];
static Detached;
static AttacherPid;	/* Non-Zero in child if we have an attacher */
static DevTty;
static char EventStr[]="%c%cA";
static char CommNames[MAXLINE];
static int VoluntaryDetach = 0;

struct mode {
    struct sgttyb m_ttyb;
    struct tchars m_tchars;
    struct ltchars m_ltchars;
    int m_ldisc;
    int m_lmode;
} OldMode, NewMode;

static struct win *curr, *other;
static CurrNum, OtherNum;
static struct win *wtab[MAXWIN];

main (ac, av) char **av; {
    register n, len;
    register struct win **pp, *p;
    char *ap;
    static InitMenu();
    int s, r, w, x = 0;
    int rflag = 0;
    struct timeval tv;
    time_t now;
    char buf[IOSIZE], *myname = (ac == 0) ? "rmgr" : av[0];
    struct stat st;
    char *winname="";

    while (ac > 0) {
	ap = *++av;
	if (--ac > 0 && *ap == '-') {
	    switch (ap[1]) {
	    case 'r':
		rflag = 1;
		if (ap[2]) {
		    SockName = ap+2;
		    if (ac != 1) goto help;
		} else if (--ac == 1) {
		    SockName = *++av;
		} else if (ac != 0) goto help;
		break;
	    case 'n':
		if (ap[2]) {
		    ap += 2;
		} else {
		    if (--ac == 0) goto help;
		    ap = *++av;
		}
		winname=ap;
		break;
	    default:
	    help:
		Msg (0, "Use: %s [-n windowname] [cmd args]\n\
 or: %s -r [host.tty]", myname, myname);
	    }
	} else break;
    }
    CommNames[0]='}';
    if ((ShellProg = getenv ("SHELL")) == 0)
	ShellProg = DefaultShell;
    ShellArgs[0] = ShellProg;
    if (ac == 0) {
	ac = 1;
	av = ShellArgs;
    }
    if ((home = getenv ("HOME")) == 0)
	Msg (0, "$HOME is undefined.");
    sprintf (SockPath, "%s/%s", home, SockDir);
    if (stat (SockPath, &st) == -1) {
	if (errno == ENOENT) {
	    if (mkdir (SockPath, 0700) == -1)
		Msg (errno, "Cannot make directory %s", SockPath);
	    (void) chown (SockPath, getuid (), getgid ());
	} else Msg (errno, "Cannot get status of %s", SockPath);
    } else {
	if ((st.st_mode & S_IFMT) != S_IFDIR)
	    Msg (0, "%s is not a directory.", SockPath);
	if ((st.st_mode & 0777) != 0700)
	    Msg (0, "Directory %s must have mode 700.", SockPath);
	if (st.st_uid != getuid ())
	    Msg (0, "You are not the owner of %s.", SockPath);
    }
    (void) gethostname (HostName, MAXSTR);
    HostName[MAXSTR-1] = '\0';
    if (ap = index (HostName, '.'))
	*ap = '\0';
    strcat (SockPath, "/");
    SockNamePtr = SockPath + strlen (SockPath);
    if ((DevTty = open ("/dev/tty", O_RDWR|O_NDELAY)) == -1)
	Msg (errno, "/dev/tty");
    if (rflag) {
	Attach (MSG_ATTACH);
	Attacher ();
	/*NOTREACHED*/
    }
    if (GetSockName ()) {
	s = MakeClientSocket (1);
	SendCreateMsg (s, ac, av, winname);
	close (s);
	exit (0);
    }
    switch (fork ()) {
    case -1:
	Msg (errno, "fork");
	/*NOTREACHED*/
    case 0:
	break;
    default:
	Attacher ();
	/*NOTREACHED*/
    }
    AttacherPid = getppid ();
    ServerSocket = s = MakeServerSocket ();
    InitTerm ();
    InitMenu ();
    MakeNewEnv ();
    GetTTY (0, &OldMode);
    InitUtmp ();
    signal (SIGHUP, SigHup);
    signal (SIGINT, Finit);
    signal (SIGQUIT, Finit);
    signal (SIGTERM, Finit);
    signal (SIGTTIN, SIG_IGN);
    signal (SIGTTOU, SIG_IGN);
    if ((n = MakeWindow (*av, av, winname, (char *)0)) == -1) {
	SetTTY (0, &OldMode);
	FinitTerm ();
	Kill (AttacherPid, SIGHUP);
	exit (1);
    }
    SetCurrWindow (n);
    HasWindow = 1;
    SetMode (&OldMode, &NewMode);
    SetTTY (0, &NewMode);
    signal (SIGCHLD, SigChld);
    tv.tv_usec = 0;
    while (1) {
	r = 0;
	w = 0;
	if (inlen && curr->wpid>=0)
	    w |= 1 << curr->ptyfd;
	else
	    r |= 1 << 0;
	for (pp = wtab; pp < wtab+MAXWIN; ++pp) {
	    if (!(p = *pp))
		continue;
	    if (p->wpid >=0)
	    	r |= 1 << p->ptyfd;
	}
	r |= 1 << s;
	(void) fflush (stdout);
	if (GotSignal) {
	    SigHandler ();
	    continue;
	}
	if (select (32, &r, &w, &x, (struct timeval *)0) == -1) {
	    if (errno == EINTR)
		continue;
	    HasWindow = 0;
	    Msg (errno, "select");
	    /*NOTREACHED*/
	}
	if (GotSignal) {
	    SigHandler ();
	    continue;
	}
	if (r & 1 << s) {
	    ReceiveMsg (s);
	}
	if (r & 1 << 0) {
	    if (ESCseen) {
		inbuf[0] = Esc;
		inlen = read (0, inbuf+1, IOSIZE-1) + 1;
		ESCseen = 0;
	    } else {
		inlen = read (0, inbuf, IOSIZE);
	    }
	    if (inlen > 0)
		inlen = ProcessInput (inbuf, inlen);
	    if (inlen > 0)
		continue;
	}
	if (GotSignal) {
	    SigHandler ();
	    continue;
	}
	if (curr && w & 1 << curr->ptyfd && inlen > 0) {
	    if ((len = write (curr->ptyfd, inbuf, inlen)) > 0) {
		inlen -= len;
		bcopy (inbuf+len, inbuf, inlen);
	    }
	}
	if (GotSignal) {
	    SigHandler ();
	    continue;
	}
	for (n=0; n<MAXWIN; n++) {
	    if (!(p = wtab[n]))
		continue;
	    if (r & 1 << p->ptyfd) {
		if ((len = read (p->ptyfd, buf, IOSIZE)) == -1) {
		    if (errno == EWOULDBLOCK)
			len = 0;
		}
		if (len > 0)
		    WriteString (n, buf, len);
	    }
	}
	if (GotSignal)
	    SigHandler ();
    }
    /*NOTREACHED*/
}

static InitTerm() {
    register char *s;

    if ((s = getenv("TERM")) == 0)
	Msg(0, "No TERM in environment.");
    if (strcmp(s,"mgr"))
	Msg(0, "Only runs on mgr terminals.");

    m_setup(M_FLUSH);
    m_push(P_DEFAULT|P_POSITION);
    m_dupkey(Esc);
}

static FinitTerm() {
    m_nomenu2(); m_nomenu();
    m_clearmenu(1); m_clearmenu(2);
    m_clearevent(ACTIVATE); m_clearevent(RESHAPE); m_clearevent(DESTROY);
    m_popall();
}
    
static WriteString(n, buf, len) int n, len; char *buf; {
    register int i, j;
    register struct win *p;

    p=wtab[n];

    if (!Detached) {
	m_selectwin(n);
	write(fileno(m_termout), buf, len);
    } else
	p->win_ok=0;		/* Screen no longer matches reality... */

    i=SCRBUFSIZE - (p->outptr - p->outbuf);
    if (i>=len) {
	bcopy(buf,p->outptr,len);
	if (i==len) {
		p->outptr=p->outbuf;
		p->outful=1;
	} else
		p->outptr+=len;
    } else {
	j=len-i;
	bcopy(buf,p->outptr,i);
	bcopy(&buf[i],p->outbuf,j);
	p->outptr=p->outbuf+j;
	p->outful=1;
    }
}

static SigHandler () {
    while (GotSignal) {
	GotSignal = 0;
	DoWait ();
    }
}

static void SigChld () {
    GotSignal = 1;
}

static void SigHup () {
    Detach (0);
}

static DoWait () {
    register pid;
    register int n;
    register struct win **pp;
    union wait wstat;

    while ((pid = wait3 (&wstat, WNOHANG|WUNTRACED, NULL)) > 0) {
	for (n = 0; n<MAXWIN; n++) {
	    if (wtab[n] && pid == wtab[n]->wpid) {
		if (WIFSTOPPED (wstat)) {
		    (void) killpg (getpgrp (wtab[n]->wpid), SIGCONT);
		} else
			KillWindow(n);
	    }
	}
    }
    for (n=0; n<MAXWIN; n++)
	if (wtab[n] && wtab[n]->wpid >=0)
		break;
    if (n == MAXWIN)
	Finit();
}

static KillWindow (n) int n; {
    if (Detached || n!=CurrNum || !n) {
	WriteString(n,"[window shut down]",18);
	wtab[n]->wpid = -1;	/* Shut it down, but don't close */
	if (!n)
    	    FreeWindow (n);	/* Don't ever close window 0, but free it */
    } else {
	CurrNum = 0;
	curr = 0;
    	FreeWindow (n);
    }
}

static void Finit () {
    register int n;
    register struct win *p, **pp;

    for (n=0; n<MAXWIN; n++) {
	if (wtab[n])
	    FreeWindow(n);
    }
    SetTTY (0, &OldMode);
    FinitTerm ();
    printf ("\r[rmgr is terminating]\033c\n");
    Kill (AttacherPid, SIGHUP);
    exit (0);
}

static linemode(onoff) int onoff; {
	struct sgttyb buff;
	gtty(0,&buff);
	if (onoff)
		buff.sg_flags &= ~CBREAK;
	else
		buff.sg_flags |= CBREAK;
	stty(0,&buff);
}

static ProcessInput (buf, len) char *buf; {
    register n, k;
    register char *s, *p, *q;
    register struct win **pp;

    for (s = p = buf; len > 0; len--, s++) {
	if (*s == Esc) {
	    if (len > 1) {
		len--; s++;
		if (*s == Esc) {
		    *p++ = Esc;
		} else {		/* Process event or menu string */
		if (*s != ' ') {
		    n=(*s++)-'!';
		    len--;
		    if (!len) {		/* Make sure to get 3rd char */
			while(!read(0,s,1));
			len++;
		    }
		    p=buf;
		    switch (*s) {	/* Event Strings */
			case 'A':
				SetCurrWindow(n);
				break;
			case 'D':
				FreeWindow(n);
				break;
			case 'R':
				SizeWindow(n);
				break;
			case 'c':	/* Menu Strings */
				if ((n=MakeWindow((char *)0, (char *)0,
					"", (char *)0)) != -1)
					SetCurrWindow(n);
				break;
			case 'd':
				VoluntaryDetach=1;
				Detach(0);
				break;
			case 'f':
				SwitchWindow(n);
				break;
			case 'k':
				KillWindow(n);
				break;
			case 'n':
				if ((n=MakeWindow(ShellProg, ShellArgs,
					"", (char *)0)) != -1)
					SetCurrWindow(n);
				break;
			case 'q':
				Finit();
				break;
			case 's':
				VoluntaryDetach=1;
				Detach(1);
				break;
			}
		    }
		} 
	    } else ESCseen = 1;
	} else *p++ = *s;
    }
    return p - buf;
}

static SwitchWindow(n) {
    if (wtab[n]) {
    	SetCurrWindow(n);
    	m_setmode(M_ACTIVATE);
    }
}

static SetCurrWindow (n) {
    CurrNum = n;
    curr = wtab[n];
    m_selectwin(n);
    if (curr->wpid < 0)
	m_setmode(M_NOINPUT);	/* Dead window, disallow input */
}

static SizeWindow (n) int n; {
	struct winsize wbuf;
	char buf[32]; 

	m_selectwin(n);
	m_getinfo(G_WINSIZE);
	linemode(1);
	read(0,buf,31);
	linemode(0);
	buf[31]='\0';
	sscanf(buf,"%*c %d %d",&(wtab[n]->cols),&(wtab[n]->rows));
#ifdef	TIOCSWINSZ
	wbuf.ws_row = wtab[n]->rows;
	wbuf.ws_col = wtab[n]->cols;
	ioctl (wtab[n]->ptyfd, TIOCSWINSZ, &wbuf);
#endif
}

static FreeWindow (n) register int n; {
    register i;
    register struct win *wp;

    wp=wtab[n];
    if (wp) {
    	RemoveUtmp (wp->slot);
    	(void) chmod (wp->tty, 0666);
    	(void) chown (wp->tty, 0, 0);
    	close (wp->ptyfd);
    	free (wp);
    	wtab[n]=0;
    }
    if (n) {
	m_selectwin(n);
	m_clearevent(DESTROY);	/* Avoid redundant calling of FreeWindow */
	m_destroywin(n);
    }
    CollectNames();
    sleep(1);
    UpdateMenu(n);
}

static CollectNames() {		/* Collect command names for second menu */
    register struct win **wp;
    register int n;
    char buf[8];

    CommNames[1]='\0';
    for (wp=wtab; wp<wtab+MAXWIN; wp++)
	if (*wp) {
	    strcat(CommNames,(*wp)->cmd);
	    strcat(CommNames,"}");
	}

    buf[0]=Esc;
    buf[1]='!';
    buf[2]='f';
    buf[3]='}';
    buf[4]='\0';
    for (n=0;n<MAXWIN;n++)
	if (wtab[n]) {
	    buf[1]=n+'!';
	    strcat(CommNames,buf);
	}
}

static char *MenuNames[]={"MGR Windows =>", "", "-=-=-=-=-=-=-",
	"Shell Window","Other Window","Kill Window","Suspend","Detach","Quit"};
static char MenuNull='\0';
static char MenuActs[24];
static char MenuLabs[8]="ncksdq";
static struct menu_entry MainMenu[9];

static InitMenu() {
    register int i;
    register char *ptr;

    ptr=MenuActs;
    for (i=3;i<9;i++) {
	MainMenu[i].action=ptr;
	*ptr++=Esc;
	*ptr++='!';
	*ptr++=MenuLabs[i-3];
	*ptr++='\0';
    }
    for (i=0;i<3;i++)
	MainMenu[i].action=(&MenuNull);

    for (i=0;i<9;i++)
	MainMenu[i].value=MenuNames[i];
}

static MakeMenu(n) int n; {
    MenuActs[9]=n+'!';
    MainMenu[1].value=wtab[n]->cmd;
    menu_load(1,9,MainMenu);
    m_loadmenu(2,CommNames);
    m_linkmenu(1,0,2,MF_SNIP);
    m_selectmenu2(1);
}

static UpdateMenu(n) int n; {
    register int i;

    for (i=0; i<MAXWIN; i++)
	if (wtab[i] && i!=n) {
	    m_selectwin(i);
	    m_loadmenu(2,CommNames);
	}
}

static Parse (buf, args) char *buf, **args; {
    register char *p = buf, **ap = args;
    register delim, argc = 0;

    argc = 0;
    for (;;) {
	while (*p && (*p == ' ' || *p == '\t')) ++p;
	if (*p == '\0' || *p == '#')
	    return argc;
	if (argc > MAXARGS-1)
	    Msg (0, "Too many tokens.");
	delim = 0;
	if (*p == '"' || *p == '\'') {
	    delim = *p; *p = '\0'; ++p;
	}
	++argc;
	*ap = p; ++ap;
	while (*p && !(delim ? *p == delim : (*p == ' ' || *p == '\t')))
	    ++p;
	if (*p == '\0') {
	    if (delim)
		Msg (0, "Missing quote.");
	    else
		return argc;
	}
	*p++ = '\0';
    }
}

static char TermBuf[MAXLINE];

static MakeWindow (prog, args, name, dir)
	char *prog, *name, **args, *dir; {
    register struct win *p;
    register char **cp;
    register n, f;
    int tf;
    int mypid;
    char ebuf[16];
    char ibuf[MY_MAXLINE];
    char *av[MAXARGS];
    char *ptr,*index();

    if ((f = OpenPTY ()) == -1) {
	Msg (0, "No more PTYs.");
	return -1;
    }
    (void) fcntl (f, F_SETFL, FNDELAY);
    if ((p = (struct win *)malloc (sizeof (struct win))) == 0) {
	Msg (0, "Out of memory.");
	return -1;
    }
    p->outful=0;
    p->outptr=p->outbuf;

    m_ttyset();
    if (!wtab[0]) {
	n=0;
    } else {
	m_resetflags(CBREAK);
	m_newwin(0,0,50,50);
	read(0, TermBuf, MAXLINE);
	TermBuf[MAXLINE-1]='\0';
    	n = atoi(&TermBuf[2]);
    }
    	m_selectwin(n);
        m_dupkey(Esc);
    	m_sizeall(n*5,n*5,80,24);
	strcpy(TermBuf,"TERMCAP=");
	m_getinfo(G_TERMCAP);
	read(0, &TermBuf[6], MAXLINE);
	TermBuf[MAXLINE-1]='\0';
	m_setflags(CBREAK);
	TermBuf[6]='P';
	TermBuf[7]='=';
	ptr=index(TermBuf,'\n');
	*ptr='\0';
    m_clear();
    sprintf(ebuf,EventStr,Esc,n+'!');
    m_setevent(ACTIVATE,ebuf);
    ebuf[2]='D';
    m_setevent(DESTROY,ebuf);
    ebuf[2]='R';
    m_setevent(RESHAPE,ebuf);
    m_ttyreset();
    wtab[n]=p;

    p->ptyfd = f;

    if (!prog) {
	int argc;

	SetTTY(0, &OldMode);
	printf("Enter command and arguments: ");
	fflush(stdout);
	ptr=gets(ibuf);
	SetTTY(0, &NewMode);
	if (!ptr || ((argc = Parse(ibuf, av)) == 0)) {
	    KillWindow(n);
	    return;
	}
	if (strcmp(av[0],"-n") == 0) {
	    name=av[1];
	    args=(&av[2]);
	} else 
	    args=av;
	prog=args[0];
    }

    strncpy (p->cmd, *name ? name : Filename (args[0]), MAXSTR-1);
    p->cmd[MAXSTR-1] = '\0';

    CollectNames();
    MakeMenu(n);
    UpdateMenu(n);
    strncpy (p->tty, TtyName, MAXSTR-1);
    (void) chown (TtyName, getuid (), getgid ());
    (void) chmod (TtyName, TtyMode);
    p->slot = SetUtmp (TtyName);
    p->rows=24;
    p->cols=80;
    switch (p->wpid = fork ()) {
    case -1:
	Msg (errno, "fork");
	free ((char *)p);
	return -1;
    case 0:
	signal (SIGHUP, SIG_DFL);
	signal (SIGINT, SIG_DFL);
	signal (SIGQUIT, SIG_DFL);
	signal (SIGTERM, SIG_DFL);
	signal (SIGTTIN, SIG_DFL);
	signal (SIGTTOU, SIG_DFL);
	setuid (getuid ());
	setgid (getgid ());
	if (dir && chdir (dir) == -1) {
	    SendErrorMsg ("Cannot chdir to %s: %s", dir, sys_errlist[errno]);
	    exit (1);
	}
	mypid = getpid ();
	ioctl (DevTty, TIOCNOTTY, (char *)0);
	if ((tf = open (TtyName, O_RDWR)) == -1) {
	    SendErrorMsg ("Cannot open %s: %s", TtyName, sys_errlist[errno]);
	    exit (1);
	}
	(void) dup2 (tf, 0);
	(void) dup2 (tf, 1);
	(void) dup2 (tf, 2);
	for (f = getdtablesize () - 1; f > 2; f--)
	    close (f);
	ioctl (0, TIOCSPGRP, &mypid);
	(void) setpgrp (0, mypid);
	SetTTY (0, &OldMode);
#ifdef	TIOCSWINSZ
	{
		struct winsize wbuf;
		wbuf.ws_row = p->rows;
		wbuf.ws_col=p->cols;
		ioctl (0, TIOCSWINSZ, &wbuf);
	}
#endif
	NewEnv[2] = TermBuf;
	sprintf (ebuf, "WINDOW=%d", n);
	NewEnv[3] = ebuf;
	execvpe (prog, args, NewEnv);
	SendErrorMsg ("Cannot exec %s: %s", prog, sys_errlist[errno]);
	exit (1);
    }
    return n;
}

static execvpe (prog, args, env) char *prog, **args, **env; {
    register char *path, *p;
    char buf[1024];
    char *shargs[MAXARGS+1];
    register i, eaccess = 0;

    if (prog[0] == '/')
	path = "";
    else if ((path = getenv ("PATH")) == 0)
	path = DefaultPath;
    do {
	p = buf;
	while (*path && *path != ':')
	    *p++ = *path++;
	if (p > buf)
	    *p++ = '/';
	strcpy (p, prog);
	if (*path)
	    ++path;
	execve (buf, args, env);
	switch (errno) {
	case ENOEXEC:
	    shargs[0] = DefaultShell;
	    shargs[1] = buf;
	    for (i = 1; shargs[i+1] = args[i]; ++i)
		;
	    execve (DefaultShell, shargs, env);
	    return;
	case EACCES:
	    eaccess = 1;
	    break;
	case ENOMEM: case E2BIG: case ETXTBSY:
	    return;
	}
    } while (*path);
    if (eaccess)
	errno = EACCES;
}

static OpenPTY () {
    register char *p, *l, *d;
    register i, f, tf;

    strcpy (PtyName, PtyProto);
    strcpy (TtyName, TtyProto);
    for (p = PtyName, i = 0; *p != 'X'; ++p, ++i) ;
    for (l = "qpr"; *p = *l; ++l) {
	for (d = "0123456789abcdef"; p[1] = *d; ++d) {
	    if ((f = open (PtyName, O_RDWR)) != -1) {
		TtyName[i] = p[0];
		TtyName[i+1] = p[1];
		if ((tf = open (TtyName, O_RDWR)) != -1) {
		    close (tf);
		    return f;
		}
		close (f);
	    }
	}
    }
    return -1;
}

static SetTTY (fd, mp) struct mode *mp; {
    ioctl (fd, TIOCSETP, &mp->m_ttyb);
    ioctl (fd, TIOCSETC, &mp->m_tchars);
    ioctl (fd, TIOCSLTC, &mp->m_ltchars);
    ioctl (fd, TIOCLSET, &mp->m_lmode);
    ioctl (fd, TIOCSETD, &mp->m_ldisc);
}

static GetTTY (fd, mp) struct mode *mp; {
    ioctl (fd, TIOCGETP, &mp->m_ttyb);
    ioctl (fd, TIOCGETC, &mp->m_tchars);
    ioctl (fd, TIOCGLTC, &mp->m_ltchars);
    ioctl (fd, TIOCLGET, &mp->m_lmode);
    ioctl (fd, TIOCGETD, &mp->m_ldisc);
}

static SetMode (op, np) struct mode *op, *np; {
    *np = *op;
    np->m_ttyb.sg_flags &= ~(CRMOD|ECHO);
    np->m_ttyb.sg_flags |= CBREAK;
    np->m_tchars.t_intrc = -1;
    np->m_tchars.t_quitc = -1;
    np->m_ltchars.t_suspc = -1;
    np->m_ltchars.t_dsuspc = -1;
    np->m_ltchars.t_flushc = -1;
    np->m_ltchars.t_lnextc = -1;
}

static char *GetTtyName () {
    register char *p;
    register n;

    for (p = 0, n = 0; n <= 2 && !(p = ttyname (n)); n++)
	;
    if (!p || *p == '\0')
	Msg (0, "rmgr must run on a tty.");
    return p;
}

static Attach (how) {
    register s, lasts, found = 0;
    register DIR *dirp;
    register struct direct *dp;
    struct msg m;
    char last[MAXNAMLEN+1];

    if (SockName) {
	if ((lasts = MakeClientSocket (0)) == -1)
	    if (how == MSG_CONT)
		Msg (0,
		    "This session has already been continued from elsewhere.");
	    else
		Msg (0, "There is no session to be resumed from %s.", SockName);
    } else {
	if ((dirp = opendir (SockPath)) == NULL)
	    Msg (0, "Cannot open %s", SockPath);
	while ((dp = readdir (dirp)) != NULL) {
	    SockName = dp->d_name;
	    if (SockName[0] == '.')
		continue;
	    if ((s = MakeClientSocket (0)) != -1) {
		if (found == 0) {
		    strcpy (last, SockName);
		    lasts = s;
		} else {
		    if (found == 1) {
			printf ("There are detached sessions on:\n");
			printf ("   %s\n", last);
			close (lasts);
		    }
		    printf ("   %s\n", SockName);
		    close (s);
		}
		found++;
	    }
	}
	if (found == 0)
	    Msg (0, "There is no session to be resumed.");
	if (found > 1)
	    Msg (0, "Type \"rmgr -r host.tty\" to resume one of them.");
	closedir (dirp);
	strcpy (SockNamePtr, last);
	SockName = SockNamePtr;
    }
    m.type = how;
    strcpy (m.m.attach.tty, GetTtyName ());
    m.m.attach.apid = getpid ();
    if (write (lasts, (char *)&m, sizeof (m)) != sizeof (m))
	Msg (errno, "write");
}

static void AttacherFinit () {
    exit (0);
}

static void ReAttach () {
    Attach (MSG_CONT);
}

static Attacher () {
    signal (SIGHUP, AttacherFinit);
    signal (SIGCONT, ReAttach);
    while (1)
	pause ();
}

static Detach (suspend) {
    register struct win **pp;
    register int i;

    if (Detached)
	return;
    signal (SIGHUP, SIG_IGN);
    if (VoluntaryDetach) {	/* Can't save state if line dropped */
    for (i=MAXWIN-1;i>0;i--) {
	if (wtab[i]) {
	m_selectwin(i);
	m_nomenu2();
	m_push(P_EVENT);
    	}
    }
    m_selectwin(0);
    m_nomenu2(); m_nomenu();
    m_push(P_ALL);
    m_setmode(M_ACTIVATE);
    }
    SetTTY (0, &OldMode);
    if (suspend) {
	Kill (AttacherPid, SIGTSTP);
	for (pp=wtab; pp < wtab+MAXWIN; ++pp)
	    if (*pp) (*pp)->win_ok=1;
    } else {
	for (pp=wtab; pp < wtab+MAXWIN; ++pp)
	    if (*pp) RemoveUtmp ((*pp)->slot);
	printf ("\n[detached]\n");
	Kill (AttacherPid, SIGHUP);
	AttacherPid = 0;
    }
    close (0);
    close (1);
    close (2);
    ioctl (DevTty, TIOCNOTTY, (char *)0);
    Detached = 1;
    do {
	ReceiveMsg (ServerSocket); 
    } while (Detached);
    if (!suspend) {
	for (pp = wtab; pp < wtab+MAXWIN; ++pp)
	    if (*pp) (*pp)->slot = SetUtmp ((*pp)->tty);
    }
    signal (SIGHUP, SigHup);
}

static Kill (pid, sig) {
    if (pid != 0)
	(void) kill (pid, sig);
}

static GetSockName () {
    register client;
    static char buf[2*MAXSTR];

    if ((SockName = getenv ("STY")) != 0 && *SockName != '\0') {
	client = 1;
	setuid (getuid ());
	setgid (getgid ());
    } else {
	sprintf (buf, "%s.%s", HostName, Filename (GetTtyName ()));
	SockName = buf;
	client = 0;
    }
    return client;
}

static MakeServerSocket () {
    register s;
    struct sockaddr_un a;
    char *p;

    if ((s = socket (AF_UNIX, SOCK_STREAM, 0)) == -1)
	Msg (errno, "socket");
    a.sun_family = AF_UNIX;
    strcpy (SockNamePtr, SockName);
    strcpy (a.sun_path, SockPath);
    if (connect (s, (struct sockaddr *)&a, strlen (SockPath)+2) != -1) {
	p = Filename (SockPath);
	Msg (0, "You already have a session running on %s.\n\
If it has been detached, try \"rmgr -r\".", p);
	/*NOTREACHED*/
    }
    (void) unlink (SockPath);
    if (bind (s, (struct sockaddr *)&a, strlen (SockPath)+2) == -1)
	Msg (errno, "bind");
    (void) chown (SockPath, getuid (), getgid ());
    if (listen (s, 5) == -1)
	Msg (errno, "listen");
    return s;
}

static MakeClientSocket (err) {
    register s;
    struct sockaddr_un a;

    if ((s = socket (AF_UNIX, SOCK_STREAM, 0)) == -1)
	Msg (errno, "socket");
    a.sun_family = AF_UNIX;
    strcpy (SockNamePtr, SockName);
    strcpy (a.sun_path, SockPath);
    if (connect (s, (struct sockaddr *)&a, strlen (SockPath)+2) == -1) {
	if (err) {
	    Msg (errno, "connect: %s", SockPath);
	} else {
	    close (s);
	    return -1;
	}
    }
    return s;
}

static SendCreateMsg (s, ac, av, name) char **av, *name; {
    struct msg m;
    register char *p;
    register len, n;

    m.type = MSG_CREATE;
    p = m.m.create.line;
    for (n = 0; ac > 0 && n < MAXARGS-1; ++av, --ac, ++n) {
	len = strlen (*av) + 1;
	if (p + len >= m.m.create.line+MY_MAXLINE)
	    break;
	strcpy (p, *av);
	p += len;
    }
    m.m.create.nargs = n;
    if (name)
	strcpy(m.m.create.name,name);
    else
	m.m.create.name[0]='\0';
    if (getwd (m.m.create.dir) == 0)
	Msg (0, "%s", m.m.create.dir);
    if (write (s, (char *)&m, sizeof (m)) != sizeof (m))
	Msg (errno, "write");
}

/*VARARGS1*/
static SendErrorMsg (fmt, p1, p2, p3, p4, p5, p6) char *fmt; {
    register s;
    struct msg m;

    s = MakeClientSocket (1);
    m.type = MSG_ERROR;
    sprintf (m.m.message, fmt, p1, p2, p3, p4, p5, p6);
    (void) write (s, (char *)&m, sizeof (m));
    close (s);
    sleep (2);
}

static char m_rbuf[MAXLINE];

static char *m_read() {
    register char *ptr; char *index();
    register int i;

    i=read(0,m_rbuf,MAXLINE-1);
    m_rbuf[i]='\0';
    ptr=index(m_rbuf,Esc);
    if (!ptr)
	ptr=m_rbuf;
    else
	ptr++;
    return(ptr);
}

static ReplayWindow(p) struct win *p; {
    register int n;

	n=p->outptr-p->outbuf;
	if (p->outful)		/* Replay last screen of data */
		write(1,p->outptr,SCRBUFSIZE-n);
	write(1,p->outbuf,n);
}

static RestoreWindows(mt) int mt; {
    register int i, j=0;
    struct window_data wd;
    register char *ptr;
    register struct win *p;
    char buf[8];
    int n, nw;
    int oldset=1;

    if (mt != MSG_CONT) {	/* Restore after a detach, not suspend */
    linemode(1);
    for (i=MAXWIN-1; i>=0; i--) {
	m_selectwin(i);
	m_getinfo(G_ID);
	ptr=m_read();
	sscanf(ptr,"%d %d",&n, &nw);
	if (wtab[i]) {
	    p=wtab[i];
	    if (n!=i) {		/* That one didn't exist, remake it... */
		oldset=0;	/* Looks like the old context is gone. */
		m_newwin(j,j,50,50);
		ptr=m_read();
		n=atoi(ptr);
		if (!n) 
			Msg(0, "Error restoring window.");
		m_selectwin(n);
	    }
	    if (!oldset) {
		m_size(p->cols,p->rows);
	    	m_dupkey(Esc);
	    	sprintf(buf,EventStr,Esc,n+'!');
	    	m_setevent(ACTIVATE,buf);
	    	buf[2]='D';
	    	m_setevent(DESTROY,buf);
	    	buf[2]='R';
	    	m_setevent(RESHAPE,buf);
		MakeMenu(n);
		ReplayWindow(p);
	    } else if (VoluntaryDetach) {
		m_pop();
	    } else ReplayWindow(p);	/* Redraw for hangup */
	} else if (i) {		/* Gee, a window we didn't create. Byebye. */
	    oldset=0;		/* Again, we must have lost the old stuff */
	    m_destroywin(i);
	}
    }
    linemode(0);
    } else {
	for (i=0;i<MAXWIN;i++) {
	    p=wtab[i];
	    if (p) {
		m_selectwin(i);
		m_pop();
		m_selectmenu2(1);
		if (!p->win_ok)
		    ReplayWindow(p);
	    }
	}
    }
    VoluntaryDetach=0;
}
	    
static ReceiveMsg (s) {
    register ns;
    struct sockaddr_un a;
    int left, len = sizeof (a);
    struct msg m;
    char *p;

    if ((ns = accept (s, (struct sockaddr *)&a, &len)) == -1) {
	Msg (errno, "accept");
	return;
    }
    p = (char *)&m;
    left = sizeof (m);
    while (left > 0 && (len = read (ns, p, left)) > 0) {
	p += len;
	left -= len;
    }
    close (ns);
    if (len == -1)
	Msg (errno, "read");
    if (left > 0)
	return;
    switch (m.type) {
    case MSG_CREATE:
	if (!Detached)
	    ExecCreate (&m);
	break;
    case MSG_CONT:
	if (m.m.attach.apid != AttacherPid || !Detached)
	    break;	/* Intruder Alert */
	/*FALLTHROUGH*/
    case MSG_ATTACH:
	if (Detached) {
	    if (kill (m.m.attach.apid, 0) == 0 &&
		    open (m.m.attach.tty, O_RDWR) == 0) {
		(void) dup (0);
		(void) dup (0);
		AttacherPid = m.m.attach.apid;
		Detached = 0;
		GetTTY (0, &OldMode);
		SetMode (&OldMode, &NewMode);
		SetTTY (0, &NewMode);
		RestoreWindows(m.type);
		SwitchWindow(CurrNum);
	    }
	} else {
	    Kill (m.m.attach.apid, SIGHUP);
	    Msg (0, "Not detached.");
	}
	break;
    case MSG_ERROR:
	Msg (0, "%s", m.m.message);
	break;
    default:
	Msg (0, "Invalid message (type %d).", m.type);
    }
}

static ExecCreate (mp) struct msg *mp; {
    char *args[MAXARGS];
    register n;
    register char **pp = args, *p = mp->m.create.line;

    for (n = mp->m.create.nargs; n > 0; --n) {
	*pp++ = p;
	p += strlen (p) + 1;
    }
    *pp = 0;
    if ((n = MakeWindow (mp->m.create.line, args, mp->m.create.name,
	    mp->m.create.dir)) != -1)
	SwitchWindow (n);
}

static char **SaveArgs (argc, argv) register argc; register char **argv; {
    register char **ap, **pp;

    if ((pp = ap = (char **)malloc ((argc+1) * sizeof (char **))) == 0)
	Msg (0, "Out of memory.");
    while (argc--) {
	if ((*pp = malloc (strlen (*argv)+1)) == 0)
	    Msg (0, "Out of memory.");
	strcpy (*pp, *argv);
	++pp; ++argv;
    }
    *pp = 0;
    return ap;
}

static MakeNewEnv () {
    register char **op, **np = NewEnv;
    static char buf[MAXSTR];

    if (strlen (SockName) > MAXSTR-5)
	SockName = "?";
    sprintf (buf, "STY=%s", SockName);
    *np++ = buf;
    *np++ = "TERM=mgr";
    np += 2;
    for (op = environ; *op; ++op) {
	if (np == NewEnv + MAXARGS - 1)
	    break;
	if (!IsSymbol (*op, "TERM") && !IsSymbol (*op, "TERMCAP")
		&& !IsSymbol (*op, "STY"))
	    *np++ = *op;
    }
    *np = 0;
}

static IsSymbol (e, s) register char *e, *s; {
    register char *p;
    register n;

    for (p = e; *p && *p != '='; ++p) ;
    if (*p) {
	*p = '\0';
	n = strcmp (e, s);
	*p = '=';
	return n == 0;
    }
    return 0;
}

/*VARARGS2*/
Msg (err, fmt, p1, p2, p3, p4, p5, p6) char *fmt; {
    char buf[1024];
    register char *p = buf;

    if (Detached)
	return;
    sprintf (p, fmt, p1, p2, p3, p4, p5, p6);
    if (err) {
	p += strlen (p);
	if (err > 0 && err < sys_nerr)
	    sprintf (p, ": %s", sys_errlist[err]);
	else
	    sprintf (p, ": Error %d", err);
    }
    printf ("%s\r\n", buf);
    if (!HasWindow) {
	Kill (AttacherPid, SIGHUP);
	exit (1);
    }
}

static char *Filename (s) char *s; {
    register char *p;

    p = s + strlen (s) - 1;
    while (p >= s && *p != '/') --p;
    return ++p;
}

static IsNum (s, base) register char *s; register base; {
    for (base += '0'; *s; ++s)
	if (*s < '0' || *s > base)
	    return 0;
    return 1;
}

static InitUtmp () {
    struct passwd *p;

    if ((utmpf = open (UtmpName, O_WRONLY)) == -1) {
	if (errno != EACCES)
	    Msg (errno, UtmpName);
	return;
    }
    if ((LoginName = getlogin ()) == 0 || LoginName[0] == '\0') {
	if ((p = getpwuid (getuid ())) == 0)
	    return;
	LoginName = p->pw_name;
    }
    utmp = 1;
}

static SetUtmp (name) char *name; {
    register char *p;
    register struct ttyent *tp;
    register slot = 1;
    struct utmp u;

    if (!utmp)
	return 0;
    if (p = rindex (name, '/'))
	++p;
    else p = name;
    setttyent ();
    while ((tp = getttyent ()) != NULL && strcmp (p, tp->ty_name) != 0)
	++slot;
    if (tp == NULL)
	return 0;
    strncpy (u.ut_line, p, 8);
    strncpy (u.ut_name, LoginName, 8);
    u.ut_host[0] = '\0';
    time (&u.ut_time);
    (void) lseek (utmpf, (long)(slot * sizeof (u)), 0);
    (void) write (utmpf, (char *)&u, sizeof (u));
    return slot;
}

static RemoveUtmp (slot) {
    struct utmp u;

    if (slot) {
	bzero ((char *)&u, sizeof (u));
	(void) lseek (utmpf, (long)(slot * sizeof (u)), 0);
	(void) write (utmpf, (char *)&u, sizeof (u));
    }
}

#ifndef GETTTYENT

static setttyent () {
    struct stat s;
    register f;
    register char *p, *ep;

    if (ttnext) {
	ttnext = tt;
	return;
    }
    if ((f = open (ttys, O_RDONLY)) == -1 || fstat (f, &s) == -1)
	Msg (errno, ttys);
    if ((tt = malloc (s.st_size + 1)) == 0)
	Msg (0, "Out of memory.");
    if (read (f, tt, s.st_size) != s.st_size)
	Msg (errno, ttys);
    close (f);
    for (p = tt, ep = p + s.st_size; p < ep; ++p)
	if (*p == '\n') *p = '\0';
    *p = '\0';
    ttnext = tt;
}

static struct ttyent *getttyent () {
    static struct ttyent t;

    if (*ttnext == '\0')
	return NULL;
    t.ty_name = ttnext + 2;
    ttnext += strlen (ttnext) + 1;
    return &t;
}

#endif

#ifndef USEBCOPY
bcopy (s1, s2, len) register char *s1, *s2; register len; {
    if (s1 < s2 && s2 < s1 + len) {
	s1 += len; s2 += len;
	while (len-- > 0) {
	    *--s2 = *--s1;
	}
    } else {
	while (len-- > 0) {
	    *s2++ = *s1++;
	}
    }
}
#endif
