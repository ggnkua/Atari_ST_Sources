/*
 * stty.c: a simple implementation of stty(1)
 *
 * Original version by Eric R. Smith, slightly extended by Thierry Bousch
 * to support the additional modem ioctls.
 */

#include <stdio.h>
#include <ioctl.h>
#include <ctype.h>

#ifndef B0
#define B0 0
#endif
#ifndef B134
#define B134 B135
#endif

/* bummer, why isn't this one in ioctl.h? */
#ifndef RTSCTS
#define RTSCTS	0x2000
#endif

/* these ones may change, look in modm0dev.h */
#define TIOCGHUPCL	(('T'<< 8) | 98)
#define TIOCSHUPCL	(('T'<< 8) | 99)
#define TIOCGSOFTCAR	(('T'<< 8) | 100)
#define TIOCSSOFTCAR	(('T'<< 8) | 101)

struct {
	char *name;
	short bits;
} modes[] = {
	{ "crmod", CRMOD },
	{ "cbreak", CBREAK },
	{ "echo", ECHO },
	{ "even", EVENP },
	{ "odd", ODDP },
	{ "rtscts", RTSCTS },
	{ "raw", RAW },
	{ "tandem", TANDEM },
	{ "tostop", TOSTOP },
	{ "xkey", XKEY }
};

#define NMODES (sizeof(modes) / sizeof(modes[0]))

struct {
	int num;
	int baud;
} bauds[] = {
	{     B0,     0 },
	{    B50,    50 },
	{    B75,    75 },
	{   B110,   110 },
	{   B134,   134 },
	{   B150,   150 },
	{   B200,   200 },
 	{   B300,   300 },
	{   B600,   600 },
	{  B1200,  1200 },
	{  B1800,  1800 },
	{  B2400,  2400 },
 	{  B4800,  4800 },
	{  B9600,  9600 },
	{ B19200, 19200 },
	{ B38400, 38400 }
};

#define NBAUDS (sizeof(bauds) / sizeof(bauds[0]))

void prchar(s,c)
char *s;
char c;
{
    printf("%s ",s);
    if (c < ' ') printf("^%c ",c + '@');
    else if (c == 127) printf("^? ");
    else printf("%c ",c);
}

void prmode(s,f)
char *s;
int f;
{
    printf("%s%s ",(f ? "" : "-"),s);
}

int speed(sp)
int sp;
{
  int i;

  for (i = 0; i<NBAUDS; i++) {
    if (bauds[i].num == sp)
      return (bauds[i].baud);
  }
  return -1;
}

int baudnum(bs)
char *bs;
{
  int bv;
  int i;

  if (!(isdigit(*bs)))
    return -1;
  bv = atoi(bs);  
  for (i = 0; i<NBAUDS; i++) {
     if (bauds[i].baud == bv)
      return (bauds[i].num);
   }
  return -1;
}

/*
 * atok: turns a string into an ASCII value.  ^x yields control-x
 * for X in @A-Za-z[\]^_ as long as there are only two chars.
 * ^? yields DEL (127) and other single chars yield themselves.
 */

int atok(s)
char *s;
{
    char c;

    if (!s || !*s) return -1;
    c = *s++;
    if (c == '^') {
	c = *s++;
	if (*s) return -1;
	if (c == '?') return 127;
	else if (c >= '@' && c <= '_') return (c - '@');
	else if (c >= 'a' && c <= 'z') return (c - '`');
	else return -1;
    }
    else if (*s) return -1;
    else return c;
}

main(argc,argv)
int argc;
char *argv[];
{
	int fd;
	int i;
	char *kp;
	long err;
	struct sgttyb sg;
	struct tchars tc;
	struct ltchars ltc;
	short hupcl, softcar;
	int b;

	fd = 0;
	if (!(isatty(fd))) {
		if ((fd = open("U:\\dev\\tty",0)) < 0) {
			perror("can't open tty");
			exit(1);
		}
	}

	if (ioctl(fd,TIOCGETP,&sg) ||
	    ioctl(fd,TIOCGETC,&tc) ||
	    ioctl(fd,TIOCGLTC,&ltc)) {
		perror("can't do ioctl");
		exit(1);
	}
	hupcl = 0;	/* default is "no hangup-on-close" */
	softcar = 1;	/* default is "local"              */
	ioctl(fd,TIOCGHUPCL,&hupcl);
	ioctl(fd,TIOCGSOFTCAR,&softcar);

	--argc, ++argv;

	if (!argc) {
		/* print current state */
		prchar("intr",tc.t_intrc);
		prchar("quit",tc.t_quitc);
		prchar("start",tc.t_startc);
		prchar("stop",tc.t_stopc);
		prchar("eof",tc.t_eofc);
		prchar("brk",tc.t_brkc);
		putchar('\n');

		prchar("susp",ltc.t_suspc);
		prchar("dsusp",ltc.t_dsuspc);
		prchar("rprnt",ltc.t_rprntc);
		prchar("flush",ltc.t_flushc);
		prchar("werase",ltc.t_werasc);
		prchar("lnext",ltc.t_lnextc);
		putchar('\n');

		printf("ispeed %d ospeed %d ",
		    speed(sg.sg_ispeed),
		    speed(sg.sg_ospeed));
		prchar("erase",sg.sg_erase);
		prchar("kill",sg.sg_kill);
		prmode("hupcl",hupcl);
		prmode("local",softcar);
		putchar('\n');

		for (i=0; i<NMODES; i++) {
		    prmode(modes[i].name,sg.sg_flags & modes[i].bits);
		}
		putchar('\n');
		exit(0);
        }
	while (argc) {
	    if ((b = baudnum(argv[0])) != -1) {
		sg.sg_ispeed = sg.sg_ospeed = b;
	    }
	    else if (strcmp("intr",argv[0]) == 0) {
		kp = &tc.t_intrc;
		goto key;
	    }
	    else if (strcmp("quit",argv[0]) == 0) {
		kp = &tc.t_quitc;
		goto key;
	    }
	    else if (strcmp("start",argv[0]) == 0) {
		kp = &tc.t_startc;
		goto key;
	    }
	    else if (strcmp("stop",argv[0]) == 0) {
		kp = &tc.t_stopc;
		goto key;
	    }
	    else if (strcmp("eof",argv[0]) == 0) {
		kp = &tc.t_eofc;
		goto key;
	    }
	    else if (strcmp("brk",argv[0]) == 0) {
		kp = &tc.t_brkc;
		goto key;
	    }
	    else if (strcmp("susp",argv[0]) == 0) {
		kp = &ltc.t_suspc;
		goto key;
	    }
	    else if (strcmp("dsusp",argv[0]) == 0) {
		kp = &ltc.t_dsuspc;
		goto key;
	    }
	    else if (strcmp("rprnt",argv[0]) == 0) {
		kp = &ltc.t_rprntc;
		goto key;
	    }
	    else if (strcmp("flush",argv[0]) == 0) {
		kp = &ltc.t_flushc;
		goto key;
	    }
	    else if (strcmp("werase",argv[0]) == 0) {
		kp = &ltc.t_werasc;
		goto key;
	    }
	    else if (strcmp("lnext",argv[0]) == 0) {
		kp = &ltc.t_lnextc;
key:
		if (argc == 1) {
		    printf("%s requires a key-name argument\n",argv[0]);
		    exit(1);
		}
		if ((*kp = atok(argv[1])) == -1) {
		    printf("Invalid key name for %s: %s\n",argv[0],argv[1]);
		    exit(1);
		}
		++argv, --argc;
	    }
	    else if (**argv == '-') {
		/* check against each mode */
		if (strcmp("hupcl",1+argv[0]) == 0) {
			hupcl = 0;
			ioctl(fd,TIOCSHUPCL,&hupcl);
			goto ok1;
		}
		if (strcmp("local",1+argv[0]) == 0) {
			softcar = 0;
			ioctl(fd,TIOCSSOFTCAR,&softcar);
			goto ok1;
		}
		for (i=0; i<NMODES; i++) {
		    if (strcmp(modes[i].name,&argv[0][1]) == 0) {
			sg.sg_flags &= ~modes[i].bits;
			goto ok1;
		    }
		}
		printf("No such mode: %s\n",&argv[0][1]);
		exit(1);
ok1:		;
	    }
	    else {
	    	if (strcmp("hupcl",argv[0]) == 0) {
	    		hupcl = 1;
	    		ioctl(fd,TIOCSHUPCL,&hupcl);
	    		goto ok2;
	    	}
	    	if (strcmp("local",argv[0]) == 0) {
	    		softcar = 1;
	    		ioctl(fd,TIOCSSOFTCAR,&softcar);
	    		goto ok2;
	    	}
		for (i=0; i<NMODES; i++) {
		    if (strcmp(modes[i].name,*argv) == 0) {
			sg.sg_flags |= modes[i].bits;
			goto ok2;
		    }
		}
		printf("No such mode: %s\n",*argv);
		exit(1);
ok2:		;
	    }
	    ++argv, --argc;
	} /* end of "while (argc)" */

	if (ioctl(fd,TIOCSETP,&sg) ||
	    ioctl(fd,TIOCSETC,&tc) ||
	    ioctl(fd,TIOCSLTC,&ltc)) {
		perror("Can not set tty modes");
	}
	exit(0);
}
