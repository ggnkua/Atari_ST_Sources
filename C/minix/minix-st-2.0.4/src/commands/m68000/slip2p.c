/*	slip 1.0 - Serial line IP			Author: Kees J. Bot
 *								19 Jul 1997
 *	Modified for Minix-ST to use two processes,	     Volker Seebode
 *	one doing serial->psip (master) and			10 Oct 2005
 *	one doing psip->serial (slave). No shadowing
 *	is needed. This way it runs much better on old hardware.
 */
#define nil 0
#include <sys/types.h>
#include <stdarg.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>
#include <sys/asynchio.h>
#include <termios.h>
#include <signal.h>

#define END		0300		/* End of packet. */
#define ESC		0333		/* Byte stuffing escape. */
#define ESC_END		0334		/* END -> ESC ESC_END -> END. */
#define ESC_ESC		0335		/* ESC -> ESC ESC_ESC -> ESC. */

#define PACKLEN		2048		/* Max datagram size. */
#define SLIPLEN   (1 + 2*PACKLEN + 1)	/* Max serial size when all escaped. */

/* Pathetic fprintf() clone to avoid dragging in the stdio library. */
static int fprintf(int fd, const char *format, ...);
#define stderr	2
static int setup_terminal(int fd);

#ifdef MASTER
char *cmdargs[3];
char *slave = "/usr/bin/slipslave";	/* path to slave executable */
#endif /* MASTER */

int main(int argc, char **argv)
{
    char *ps_device;
    int ps_fd;
    int discard;
    register ssize_t r;
    pid_t other_pid;
    register size_t ps_len, sl_len;		/* only one counter needed */
    register unsigned char *sl_end;
    unsigned char ps_buf[PACKLEN];	/* only one buffer */
    unsigned char sl_buf[SLIPLEN];	/* only one buffer */
#ifdef MASTER
    unsigned char *ps_buf_end = ps_buf + PACKLEN; /* avoid calc */
#endif /* MASTER */
    asynchio_t asyn;
    register unsigned char *pp;
    register unsigned char *sp;
    register int c;
#ifdef RINGBUF
    unsigned char *slhead, *sltail;
    unsigned char *sl_bufend = sl_buf + SLIPLEN;
#define	SL_WRAP(p)	if ((p) == sl_bufend) (p) = sl_buf
#else
#define	SL_WRAP(p)
#endif /* RINGBUF */

    if (argc != 2) {
	fprintf(stderr, "Usage: slip psip-device\n");
	exit(1);
    }
    ps_device= argv[1];

    discard= 0;		/* No input error. */
    sl_len= 0;		/* Nothing read from serial line yet. */
    sl_end= nil;	/* No END marker seen. */
    ps_len= 0;		/* Nothing to write to pseudo IP device. */

#ifdef MASTER
    /* Oops, standard Minix can't do asynchronous I/O.  Fork and let the parent
     * do serial -> psip, and the child do psip -> serial.  (Note that we have
     * to make sure that we're not reading and writing at the same time even
     * for standard Minix.  For Minix-vmd we do fill an input buffer while an
     * output buffer is waiting to be drained to improve performance a bit.)
     */
    switch ((other_pid= fork())) {
    case -1:
	fprintf(stderr, "slip: can't fork: %s\n", strerror(errno));
	exit(1);
    case 0:
	/* Child. */
	cmdargs[0] = slave;;
	cmdargs[1] = ps_device;
	cmdargs[2] = 0;
	execv(slave, cmdargs);
	/* should not come here */
	fprintf(stderr, "child can't exec %s\n", slave);
	exit(1);
	break;
    default:
	/* Parent. */
	break;
    }

    if ((ps_fd= open(ps_device, O_WRONLY)) < 0) {
	fprintf(stderr, "slip: can't open %s: %s\n",
	    ps_device, strerror(errno));
	kill(other_pid, SIGKILL);
	exit(1);
    }
    setup_terminal(0);
    
    fprintf(stderr, "slip: Connecting input/output to %s\n", ps_device);

#else
    other_pid = getppid();

    if ((ps_fd= open(ps_device, O_RDONLY)) < 0) {
	fprintf(stderr, "slip: can't open %s: %s\n",
	    ps_device, strerror(errno));
	kill(other_pid, SIGKILL);
	exit(1);
    }
#endif /* MASTER */

    asyn_init(&asyn);

#ifdef	RINGBUF
    slhead = sl_buf;	/* pointing after last received char */
    sp = sl_buf;	/* running pointer */
    sltail = sl_buf;	/* pointing at beginning of actual input */
#endif /* RINGBUF */

    for (;;) {
#ifdef MASTER
	    /* If there is an END marker in the serial input then create
	     * an IP packet to be send to the TCP/IP task.
	     */
	    while (sl_end != nil && ps_len == 0) {
		pp = ps_buf;
#ifdef RINGBUF
		sp = sltail;
		while (sp != sl_end) {
#else
		sp = sl_buf;
		while (sp < sl_end) {
#endif /* !RINGBUF */
		    c= *sp++;
		    SL_WRAP(sp);

		    if (c == ESC) {
			switch (*sp++) {
			case ESC_ESC:	/* ESC ESC_ESC -> ESC. */
			    c= ESC;
			    break;
			case ESC_END:	/* ESC ESC_END -> END. */
			    c= END;
			    break;
			default:
			    /* Protocol error. */
			    discard= 1;
			}
			SL_WRAP(sp);
		    }
		    if (pp < ps_buf_end) {
			*pp++ = c;
		    } else {
			/* Packet too big, discard. */
			discard= 1;
			fprintf(stderr, "Protocol error 0x%x\n", c);
		    }
		}
		if (discard) {
		    discard= 0;
		} else {
		    /* A new packet can be send to the TCP/IP server. */
		    ps_len= (pp - ps_buf);
		}
#ifdef RINGBUF
		sl_end++;
		SL_WRAP(sl_end);
		sltail = sl_end;

		if (slhead < sltail) {
		    sl_len = ((sl_bufend - sltail) + (slhead - sl_buf));
		    sl_end = memchr(sltail, END, (int) (sl_bufend - sltail));
		    if (sl_end == nil)
			sl_end = memchr(sl_buf, END, (int) (slhead - sl_buf));
		} else {
		    sl_len = slhead - sltail;
		    sl_end = memchr(sltail, END, sl_len);
		}
#else
		/* Move what's beyond END to the front. */
		sl_end++;
		sl_len -= (sl_end - sl_buf);
		memmove(sl_buf, sl_end, sl_len);
		sl_end= memchr(sl_buf, END, sl_len);
#endif /* RINGBUF */
	    }

	    /* Reading from serial input. */
	    if (sl_end == nil && ps_len == 0) {
#ifdef RINGBUF
again:
		r= asyn_read(&asyn, 0, slhead, sltail > slhead ?
			(int)(sltail - slhead) : (int)(sl_bufend - slhead));

		if (r > 0) {
		    sl_end = memchr(slhead, END, r);
		    sl_len += r;
		    slhead += r;
		    if (slhead == sl_bufend) {
			slhead = sl_buf;
			if (sl_end == nil) goto again;
		    }
		    if (sl_end == nil && sl_len == SLIPLEN) {
			/* Packet is idiotically big and no END in sight. */
			sl_len= 0;
			sltail = slhead;
			discard= 1;
		    }
#else
		r= asyn_read(&asyn, 0, sl_buf + sl_len,
							SLIPLEN - sl_len);
		if (r > 0) {
		    sl_end= memchr(sl_buf + sl_len, END, r);
		    sl_len+= r;
		    if (sl_end == nil && sl_len == SLIPLEN) {
			/* Packet is idiotically big and no END in sight. */
			sl_len= 0;
			discard= 1;
		    }
#endif /* RINGBUF */
		} else
		if (r == 0) {
		    fprintf(stderr, "slip: EOF on serial input\n");
		    break;
		} else
		if (errno != ASYN_INPROGRESS) {
		    fprintf(stderr, "slip: serial input error: %s\n",
			strerror(errno));
		    break;
		}
	    }

	    /* Writing to the psip device. */
	    if (ps_len > 0) {
		r= asyn_write(&asyn, ps_fd, ps_buf, ps_len);
		if (r == (int) ps_len) {
		    /* Packet written. */
		    ps_len= 0;
		} else
		if (r >= 0) {
		    fprintf(stderr,
			"slip: odd write to %s, tried %u, wrote %d\n",
			ps_device, (unsigned) ps_len, (int) r);
		    break;
		} else
		if (errno != ASYN_INPROGRESS) {
		    fprintf(stderr, "slip: error writing %s: %s\n",
			ps_device, strerror(errno));
		    break;
		}
	    }
#else /* not MASTER */
	    /* Transform an IP packet to a "byte stuffed" serial packet. */
	    if (ps_len > 0 && sl_len == 0) {
		pp = ps_buf;
#ifdef RINGBUF
		sp = slhead;
#else
		sp = sl_buf;
#endif /* RINGBUF */

		*sp++ = END;
		SL_WRAP(sp);
		while (ps_len > 0) {
		    c= *pp++;
		    ps_len--;
		    switch (c) {
		    case ESC:		/* ESC -> ESC ESC_ESC. */
			*sp++ = ESC;
			c= ESC_ESC;
			break;
		    case END:		/* END -> ESC ESC_END. */
			*sp++ = ESC;
			c= ESC_END;
			break;
		    }
		    SL_WRAP(sp);
		    *sp++ = c;
		    SL_WRAP(sp);
		}
		*sp++ = END;
		SL_WRAP(sp);
#ifdef RINGBUF
		slhead = sp;
		if (sltail <= slhead)
		    sl_len = slhead - sltail;
		else
		    sl_len = sl_bufend - sltail + slhead - sl_buf;
#else
		sl_len= (sp - sl_buf);
#endif /* RINGBUF */
	    }

	    /* Reading from the psip device. */
	    if (ps_len == 0 && sl_len == 0) {
		r= asyn_read(&asyn, ps_fd, ps_buf, PACKLEN);
		if (r > 0) {
		    /* One packet read. */
		    ps_len= r;
		} else
		if (r == 0) {
		    fprintf(stderr, "slip: EOF on %s\n", ps_device);
		    break;
		} else
		if (errno != ASYN_INPROGRESS) {
		    fprintf(stderr, "slip: error reading %s: %s\n",
			ps_device, strerror(errno));
		    break;
		}
	    }

	    /* Writing to serial output. */
	    if (sl_len > 0) {
#ifdef RINGBUF
		if (sltail > slhead) {
		    r= asyn_write(&asyn, 1, sltail, sl_len > sl_bufend-sltail ?
			    (int) (sl_bufend - sltail) : sl_len);
		} else
again_ps:
		    r= asyn_write(&asyn, 1, sltail, sl_len);
		if (r > 0) {
		    sltail += r;
		    sl_len -= r;
		    if (sltail == sl_bufend) {
			sltail = sl_buf;
			/*if (sl_len > 0) goto again_ps;*/
		    }
#else
		r= asyn_write(&asyn, 1, sl_buf, sl_len);
		if (r > 0) {
		    if ((sl_len-= r) > 0) {
			memmove(sl_buf, sl_buf + r, sl_len);
		    }
#endif /* RINGBUF */
		} else
		if (r == 0) {
		    fprintf(stderr, "slip: EOF on serial output\n");
		    break;
		} else
		if (errno != ASYN_INPROGRESS) {
		    fprintf(stderr, "slip: serial output error: %s\n",
			strerror(errno));
		    break;
		}
	    }
#endif /* MASTER */

	/* Wait for something to happen. */
	if (asyn_wait(&asyn, 0, (char *) nil) < 0) {
	    fprintf(stderr,
		"slip: error while waiting for I/O to happen: %s\n",
		strerror(errno));
	    break;
	}

    }

    /* Tell my alter ego that the game is over. */
    kill(other_pid, SIGKILL);

    return 1;
}

static int fprintf(int fd, const char *format, ...)
/* Simple fprintf() to save a few bytes by not using the stdio library. */
{
    int len;
    ssize_t r;
    const char *fp0, *fp;
    va_list ap;

    len= 0;
    fp= fp0= format;
    va_start(ap, format);

    while (*fp != 0) {
	if (*fp == '%' && memchr("sdu", fp[1], 3) != nil) {
	    if (fp > fp0) {
		if ((r= write(fd, fp0, (int)(fp - fp0))) < 0) return -1;
		len+= r;
	    }
	    fp++;
	    fp0= fp+1;

	    if (*fp == 's') {
		char *s= va_arg(ap, char *);

		if ((r= write(fd, s, strlen(s))) < 0) return -1;
		len+= r;
	    } else {
		int d, base;
		unsigned u;
		char a[3 * sizeof(u) + 2];
		char *p, c;

		if (*fp == 'x')
		    base = 16;
		else
		    base = 10;

		if (*fp == 'd') {
		    u= d= va_arg(ap, int);
		    if (d < 0) u= -u;
		} else {
		    u= va_arg(ap, unsigned);
		    d= 0;
		}

		p= a + sizeof(a);
		*--p= 0;
		do {
		    if (u % base > 9)
			c = 'a' + (u % base) - 10;
		    else
			c = '0' + (u % base);
		    *--p= c;
		} while ((u /= base) > 0);

		if (d < 0) *--p= '-';
		if ((r= write(fd, p, (int)((a + sizeof(a)) - p))) < 0) return -1;
		len+= r;
	    }
	}
	fp++;
    }
    if (fp > fp0) {
	if ((r= write(fd, fp0, (int)(fp - fp0))) < 0) return -1;
	len+= r;
    }
    va_end(ap);
    return len;
}

#ifdef MASTER
static struct termios sl_termios;

static int setup_terminal(fd)
int fd;
{
  struct termios  stermios;
  long i;

  /* Save the current TTY state, and set new speed and flags. */
  if (tcgetattr(fd, &sl_termios) == -1) {
    fprintf(stderr, "tty_init: can't read termios parameters: %s\n",
      strerror(errno));
    return(-errno);
  }
  memcpy((char *) &stermios, (char *) &sl_termios, sizeof(struct termios));
  stermios.c_cflag |= (CS8 | CREAD); /* set 8 bits char, enable receiver */
  stermios.c_cflag &= ~(CLOCAL); /* enable usage modem signals */
  stermios.c_lflag &= ~(ICANON | ECHO | IEXTEN | ISIG | ECHOE | ECHOK | ECHONL); 
            /* no canon, no echo, no extended function, no signals
               no echo erase, no ech kill, no echo NL */
  stermios.c_oflag &= ~(OPOST | ONLCR); 
            /* no output procesing, no NL/CR convertion */
  stermios.c_iflag &= ~(ICRNL | IXON | IXOFF);    
            /* no CR/NL convertion, no XON, no XOFF */
#if 0
  /* Fetch the baud rate, and set it if needed. */
  i = set_baud(baud);
  if (i < 0) {
     fprintf(stderr,"tty_init: invalid speed setting\n");     
     return(i);
     }
  if (i != 0) {
	stermios.c_ispeed = (speed_t)i;
	stermios.c_ospeed = (speed_t)i;
  }
#endif
  if (tcsetattr(fd, TCSANOW, &stermios) == -1) {
    fprintf(stderr, "tty_init: can't set termios parameters: %s\n",
      strerror(errno));
    return(-errno);
  }
  return 0;
}
#endif /* MASTER */
