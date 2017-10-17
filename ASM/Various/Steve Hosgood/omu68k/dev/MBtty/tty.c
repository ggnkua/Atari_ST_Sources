/******************************************************************************
 *	TTY handler			T.Barnaby 	1/6/85
 ******************************************************************************
 *
 *	Interupt or polled driven TTY handler for OMU to emulate the Codata
 *	TTY interface.
 *
 *	Implements :-
 *		RAW, CBREAK, ECHO, CRMOD, TANDEM, XTABS, CRDELAY
 *
 *		Knows about special characters (erase, kill, start,
 *			stop, interupt, quit, eof, input delim).
 *
 *		Does Xon, Xoff  properly ?
 *
 *		Full 8 bits in RAW, 7 bits masked on all other inputs
 *			8 bits on all outputs
 *
 *		No parity checking performed, tested, done, thought about
 *			etc etc ...
 *
 *		Baud rates settable as per Codata On output speed only.
 *
 *		Most Ioctls work except TIOCEXCL, TIOCNXLL and TIOCHPCL.
 *
 *		CR and NL delays included with simple loop timmer (delaym())
 *			NL1 is set to around 5ms
 *
 *		Quit, and interupt not implemented as yet
 *
 *	Main routines called from KERNEL are:-
 *
 *		o_tty()		Opens and sets up a new device for I/O
 *
 *		c_tty()		Closes a device
 *
 *		r_tty()		Reads characters from device, waits till
 *				they are available and returns number read.
 *
 *		w_tty()		Write characters to the device waits till
 *				TTY buffer has them all
 *
 *		i_tty()		Ioctl routine does all ioctl's
 *
 *	Routines for Kernel error print etc (Polled output):-
 *
 *		putchar()	Console character output polled direct
 *				output.
 *
 *		getchar()	Console character input polled direct
 *				input.
 *
 *	Routines called from device drivers :-
 *
 *		ttyin()		Input a character from the device to input
 *				buffer.
 *
 *		ttyout()	Output a character to device from output
 *				buffer.
 *
 *	Other routines :-
 *
 *		ttywait()	While the TTY handler is waiting around
 *				it passes through this routine , and is
 *				given the device number and a flag
 *				 indicating if the wait is for
 *				write or for read .
 *				This routine calls sleep() which will
 *				cause the process to sleep unitil the
 *				required event has occured.
 *				NOTE Wait during WWAITB could have a race
 *				hazard if sleep is called after the last
 *				character in the buffer has been transmitted
 *
 *		tputout()	Puts a number of characters into the
 *				Output buffer and initiates real device
 *				output.
 *
 *		tputbuf()	Puts as many characters as posible, or
 *				the number given into the input, or output
 *				buffer given.
 *
 *		tgetbuf()	Gets as many characters as posible, or
 *				the number given from the input, or output
 *				buffer given.
 *
 *		writechar()	Does actual character write
 *
 *		readchar()	Does actual character read
 *
 *	NOTE at the moment the extending of characters on output
 *		(CRMOD, XTABS etc), is done when an interupt or
 *		the next character is required from the buffer.
 *		This means that the extra characters added are
 *		polled out even when in interupt mode.
 *		CR, and NL delays are done here.
 *
 *	External routines used:-
 *
 *		All the device driver routines in tty device switch.
 *
 *		SPLTTY()	Mask interupt level (Noramlly level 6
 *				defined in excep.h).
 *		splx()		Sets the interupt level back
 *		sleep()		Causes the process to go to sleep awaiting
 *				an event
 *		wakeup()	Flags all processes that an event has occured
 *		sendgrp()	Sends a signal to a process group using this tty
 *
 *	Events
 *		If EVENTSON is defined, every time a buffer is ready,
 *		devevent() is called with the major and minor dev numbers.
 */

# include	"../../include/param.h"
# include	<sgtty.h>
# include	<sys/ioctl.h>

# include	"../../include/inode.h"
# include	"../../include/signal.h"
# include	"../../include/procs.h"
# include	"../../include/excep.h"
# include	"../../include/dev.h"
# include	"../../include/state.h"
# include       "tty.h"

extern struct ttydev ttydevsw[];	/* TTY dev switch */

char	putchar(), getchar(), writechar(), readchar();

/* TTY structure */
struct ttystruct ttys[NDEVS];

/*
 *	Open a tty device
 *
 *	If the minor device is not open it is opened by calling
 *		Its initialisation routine as defined in the
 *		minor, minor tty device switch (ttydevsw[])
 */
o_tty(dev)
{
	struct ttystruct *tty;

	/* Check if device valid */
	if (dev < NDEVS){
		tty = &ttys[dev];		/* Pointer to dev structure */

		/* Sets processes controlling terminal if this is it.
		 * Checks if no valid controlling tty if so set it.
		 * I don't like this bit so it may be changed later.
		 */
		if(cur_proc->tty == -1) cur_proc->tty = dev;

		/* If first open set up line */
		if (tty->nopens++ == 0){

			/* valid device, unopened */
			tty->dev = dev;		/* Device No */
			tty->col = 0;		/* Column 0 */
			tty->line = 0;		/* Line 0 */

			/* Input buffer */
			flush(&tty->inbuf);

			/* Output buffer */
			flush(&tty->outbuf);

			tty->inxoff = XONSTATE;	/* Xon Xoff flags */
			tty->outxoff = XONSTATE;

			/* Setup tty.sgtty */
			tty->sgtty.sg_ispeed = tty->sgtty.sg_ospeed = INITBAUD;
			tty->sgtty.sg_erase = CERASE;
			tty->sgtty.sg_kill = CKILL;
			tty->sgtty.sg_flags = INITFLAGS;

			/* Gets special charcters */
			tty->tchars.t_intrc = CINTR;
			tty->tchars.t_quitc = CQUIT;
			tty->tchars.t_startc = CSTART;
			tty->tchars.t_stopc = CSTOP;
			tty->tchars.t_eofc = CEOT;
			tty->tchars.t_brkc = CBRK;

			/* Sets up physical device defined in ttydevsw[] */
			(*ttydevsw[dev].setfnc)(ttydevsw[dev].m_m_dev);

			tty->tx_rdy = RDY;	/* Tx is ready for output */
		}

		return 0;
	}

	/* invalid minor device */
	return -1;
}

/*
 *	Close a TTY device
 */
c_tty(dev)
{

	/* Check if valid device opened */
	if (dev < NDEVS && ttys[dev].nopens > 0){
		ttys[dev].nopens--;
		return 0;
	}
	else return -1;
}

/*
 *	R_tty	Read characters from input buffer if available
 *		Returns number actualy read.
 *		Will wait untill the buffer is ready for output
 *		ie in line mode will wait for NL before returning.
 */
r_tty(dev, buffer, nbytes)
char *buffer;
{
	int bytecount;
	struct ttystruct *tty;

	tty = &ttys[dev];

	/* Waits until characters are available and will return
	 * a maxinum of nbytes
	 */
	while(!tty->inbuf.outrdy){

		/* If polled Gets a character when available */
		if(ttydevsw[dev].type == POLLED){
			 ttyin(dev);			/* Get a character */
		}
		/* Call ttywait to indicate tty handler is dossing around */
		else{
			ttywait(dev,RWAITB);
		}
	}
	/* Fetches the characters from the buffer */
	bytecount = tgetbuf((&tty->inbuf),buffer,nbytes);

	/* Do tandem bit if nescecary */
	if(tty->sgtty.sg_flags & TANDEM){

		/* If bellow LW mark and in Xoff state send Xon char */
		if(tty->inbuf.inrdy && tty->inxoff){
			tty->inxoff = XONSTATE;

			/* Send character immeadiatly */
			writechar(dev, tty->tchars.t_startc);
		}
	}

	return bytecount;
}

/*
 *	W_tty	write characters to output buffer, wait until all
 *		the characters are in the buffer
 */
w_tty(dev, buffer, nbytes)
int nbytes;
int dev;
char *buffer;
{
	int bytecount;
	int no;

	/* Write all bytes to tty buffer */
	bytecount = nbytes;

	/* Wait until all bytes are written */
	while(bytecount>0){

		/* Puts as many bytes as possible to the output buffer
		 * And starts transmission if nessecary
		 */
		no = tputout(dev,buffer,bytecount);
		bytecount -= no;
		buffer += no;

		/* Call ttywait to indicate tty handler is dossing around */
		if(bytecount > 0) ttywait(dev,WWAITB);
	}
	return nbytes;
}

/*
 *	ttywait		All functions withing the tty handler
 *			will pass through here when they are
 *			waiting around for somthing or other.
 */
ttywait(dev,type)
short dev;
char type;
{
	int c;

	switch(type){
	case RWAITB:
		/* Sets process to sleep on rxbuf */
		sleep((caddr_t)&ttys[dev].inbuf,PTTY);
		break;
	case WWAITB:
		/* Sets process to sleep on txbuf */
		sleep((caddr_t)&ttys[dev].outbuf,PTTY);
		break;
	}
}

/*
 *	ttyin	Character to buffer from device
 *		This routine is called whenever there is a character
 *		ready for input (interupt mode), or when one is required
 *		(polled mode).
 */
ttyin(dev)
int dev;
{
	register struct ttystruct *tty;
	char ch, bufrdy, dont_put;


	/* If polled Waits untill there is a character ready before
	 * Getting it. ttywait() is called to indicate that the tty
	 * Handler is dossing arround from within readchar().
	 */
	ch = readchar(dev);

	tty = &ttys[dev];	/* Gets address of tty structure for device */

	tty->inbuf.outrdy = bufrdy = 0;	/* Sets buffer to notready for output */
	dont_put = 0;			/* Dont put character to buffer flag */

	/* Checks if not in RAW mode */
	if(!(tty->sgtty.sg_flags & RAW)){

		ch &= ~TOPB;		/* Masks top bit */

		/* Check special characters */
		do {
			if(ch == tty->tchars.t_intrc){
				/* Send signal to processes flag signal only */
				sendgrp(tty->dev,SIGINT,0);
				dont_put = 1;		/* Don't output */
				break;
			}
			if(ch == tty->tchars.t_quitc){
				/* Send signal to processes flag signal only */
				sendgrp(tty->dev,SIGQUIT,0);
				dont_put = 1;		/* Don't output */
				break;
			}

			/* Xoff handler , First check if Xoff character */
			if(ch == tty->tchars.t_stopc){
				dont_put = 1;		/* Don't output */
				/* Stops output if going */
				if(!tty->outxoff){
					tty->outxoff = XOFFSTATE;
					break;
				}
			}

			/* NOTE Xoff can fall through here to allow
			 *	Single character Xon/Xoff
			 */

			/* Xon handler, first check if Xon character */
			if(ch == tty->tchars.t_startc){
				dont_put = 1;		/* Don't output */
				/* Starts output if stoped */
				if(tty->outxoff){
					tty->outxoff = XONSTATE;
					if(tty->tx_rdy) ttyout(tty->dev);
					break;
				}
			}


			/* Do these bits unless in CBREAK mode */
			if(!(tty->sgtty.sg_flags & CBREAK)){

				/* Eof handler */
				if(ch == tty->tchars.t_eofc){
					bufrdy = RDY;	/* Sets buffer ready */
					dont_put = 1;	/* Don't output */
					break;
				}


				/* Erase character */
				if(ch == tty->sgtty.sg_erase){
					/* rubout - not before start of line */
					rubout(tty, 1);
					dont_put = 1;	/* Don't output */
					break;
				}

				/* Line kill character */
				if(ch == tty->sgtty.sg_kill){
					/* Rubout till start of buffer */
					rubout(tty, tty->inbuf.count);
					/* Make sure buffer pointers correct */
					tty->inbuf.outptr = tty->inbuf.inptr;
					dont_put = 1;	/* Don't output */
					break;
				}
			}

			/* End of line character */
			if(ch == tty->tchars.t_brkc){
				if(ch != (char)(-1)) bufrdy = RDY;
				break;
			}
		}while(0);

		/* Checks for CRMOD conversion */
		if(ch == CR){
			/* Check if CRMOD if so do so */
			if(tty->sgtty.sg_flags & CRMOD) ch = NL;
		}

		/* If line termination set buffer to ready for output */
		if(ch == NL) bufrdy = RDY;

	}

	/* If RAW or CBREAK set buffer ready all all characters unless
	 * dontput has been set.
	 */
	if(!dont_put && (tty->sgtty.sg_flags & (CBREAK | RAW))) bufrdy = RDY;

	/* Put character to input buffer if required */
	if(!dont_put){
		/* If no characters have been put then don't echo */
		if(tputbuf(&ch,&tty->inbuf,1)){

			/* Do echo if required */
			if((tty->sgtty.sg_flags & ECHO) &&
				!(tty->sgtty.sg_flags & RAW)){
				tputout(tty->dev,&ch,1);  /* No check if done */
			}
		}
	}

	/* Sets buffer ready flag if apropriate */
	if(bufrdy){
		tty->inbuf.outrdy = RDY;
		wakeup((caddr_t)&tty->inbuf);
#ifdef	EVENTSON
		devevent(DEVTTYMAJ, tty->dev);
#endif	EVENTSON
	}

	/* Tandem mode check */
	if(tty->sgtty.sg_flags & TANDEM){
		/* If above HW mark and not in Xoff state send Xoff */
		if(!tty->inbuf.inrdy && !tty->inxoff){
			tty->inxoff = XOFFSTATE;

			/* Send character imediatly wait untill device ready */
			writechar(dev,tty->tchars.t_stopc);
		}
	}

	return 1;
}
/*
 *	Readchar	Will wait until a character is ready
 *			passing through ttywait(), to indicate
 *			that the tty handler is dossing around again.
 *			Then low and behold it gets the character Weyyy!
 *			(ps thats a Mark'ism.)
 */
char
readchar(dev)
short dev;
{
	short intlevel;
	char ch;

	intlevel = SPLTTY();
	/* Wait until device is ready , only if polled device */
	if(!ttydevsw[dev].type){
		while(!((*ttydevsw[dev].status)(ttydevsw[dev].m_m_dev) & RRDY))
			ttywait(dev,RWAITC); 
	}
	/* Get character character */
	ch = (*ttydevsw[dev].rchar)(ttydevsw[dev].m_m_dev);
	splx(intlevel);
	return ch;
}

/*
 * Rubout - rubs out chars in buffer 
 *              will rub out no more than 'count' chars.
 *		will rub out only till the start of the buffer
 *              Returns actual no. rubbed out.
 */
rubout(tty,count)
struct ttystruct *tty;
int count;
{
	char ch;
	int cnt;
	char *botbuf;		/* Start address of buffer */

	
	botbuf = &tty->inbuf.buf[0];

	/* If no characters in buffer return */
	if(tty->inbuf.count <= 0){
		tty->inbuf.count = 0;
		return 0;
	}

	cnt = 0;

	/* Rubout characters untill start of buffer or count */
	while (count-- && (tty->inbuf.count-- > 0)){

		/* Decrement pointer to last character */
		if((--(tty->inbuf.inptr)) < botbuf)
			tty->inbuf.inptr = &tty->inbuf.buf[TTYBUFSIZE];

		/* Echos backspace space backspace */
		if(tty->sgtty.sg_flags & ECHO){
			/* Send out bs,sp,bs (note no check if worked) nauty */
			tputout(tty->dev,"\b \b",3);
		}

		cnt++;
	}

	return cnt;
}

/*
 *	ttyout	Output a character from tty buffer to device
 *		All output conversions done here.
 *		This is either called by a device when requesting output
 *		interupt mode, or by the TTY handler for output
 *		in polled mode
 */
ttyout(dev)
short dev;
{
	int cnt, nchars;
	struct ttystruct *tty;
	char ch;

	tty = &ttys[dev];	/* Gets address of tty entry for device */

	/* Checks if no more characters in buffer or Xoff is in progress
	 * if so sets tx_rdy flag to indicate acias requirement for tx char
	 */
	if(tty->outxoff || !tgetbuf(&tty->outbuf,&ch,1)){
		tty->tx_rdy = RDY;
		return 0;
	}

	tty->tx_rdy = NOTRDY;

	/* Check If in raw mode */
	if(tty->sgtty.sg_flags & RAW){
		/* Prints the character to device */
		writechar(dev, ch);
		tty->col++;
	}
	/* If not raw do any output conversions */
	else{
		switch (ch){
		case TAB:
			/* skip to next col modulo 8 */
			nchars = ((tty->col+TABSIZE) & TABMASK) - tty->col;
			tty->col += nchars;
	
			/* If Xtabs print spaces */
			if(tty->sgtty.sg_flags & XTABS){
				/* Output number of tab spaces */
				for (cnt = nchars; cnt; cnt--){
					/* Wait until device ready and
					 * print a space
					 */
					writechar(dev, ' ');
				}
			}
	
			/* Else output tab character */
			else writechar(dev, ch);

			break;

		case BS:
			/* Back space */
			writechar(dev, ch);
			if(tty->col-- < 0) tty->col = 0;   /* back one space */
			break;

		case NL:
			/* implement CRMOD type of conversion */
			if(tty->sgtty.sg_flags&CRMOD){
				writechar(dev, NL);
				nldelay(tty);	/* Do NL delay */
				tty->line++;

			/* Polled output of char wait until device ready */
				writechar(dev, CR);
				crdelay(tty);		/* Do CR delay */
				tty->col = 0;
			}
			else{
				writechar(dev, NL);
				tty->line++;
				nldelay(tty); /* Do NL delay */
			}
			break;

		case CR:
			/* Do CR */
			writechar(dev, CR);
			tty->col = 0;
			crdelay(tty);		/* Do CR delay */
			break;

		default:
			/* Prints the character to device */
			writechar(dev, ch);
			tty->col++;
			break;
		}
	}
	/* Check if buffer is valid if so wake up any processes waiting */
	if(tty->outbuf.inrdy == RDY) wakeup((caddr_t)&tty->outbuf);

	return 1;
}
/*
 *	Writchar	Will wait until a character is ready
 *			passing through ttywait(), to indicate
 *			that the tty handler is dossing around again.
 *			and then write the character.
 */
char
writechar(dev,ch)
short dev;
char ch;
{
	short intlevel;

	intlevel = SPLTTY();
	/* Wait until device is ready note no need if interupt */
	while(!((*ttydevsw[dev].status)(ttydevsw[dev].m_m_dev) & WRDY))
		ttywait(dev,WWAITC); 
	/* Write character */
	(*ttydevsw[dev].wchar)(ttydevsw[dev].m_m_dev, ch);
	splx(intlevel);
	return;
}
/*
 *	Crdelay		CR delay algorithm
 */
crdelay(tty)
struct ttystruct *tty;
{
	int delay;

	/* Checks if there is CR delay */
	if(delay = (tty->sgtty.sg_flags & CRDELAY)){

		switch(delay){
		case CR1:
			delaym(tty->dev,80);		/* 80 mS delay */
			break;

		case CR2:
			delaym(tty->dev,160);		/* 160 mS delay */
			break;

		}
	}
	return;
}
/*
 *	nldelay		NL delay algorithm
 */
nldelay(tty)
struct ttystruct *tty;
{
	int delay;

	/* Checks if there is NL delay */
	if(delay = (tty->sgtty.sg_flags & NLDELAY)){

		switch(delay){
		case NL1:
			delaym(tty->dev,10);		/* 5 mS delay */
			break;

		case NL2:
			delaym(tty->dev,100);		/* 160 mS delay */
			break;

		}
	}
	return;
}
/*
 *	Simple delay very, very, very inacurate.
 */
delaym(dev,count)
short dev;
int count;
{
	int c;
	short intlevel;

	while(count--){
		/* 1ms delay very aprox! , dependent on ttywait !*/
		for(c=0; c<200; c++) ttywait(dev,DWAIT);
	}
}

/*
 * Kernel routines need putchar + getchar to console.
 *	Polled access is used, as errors don't want to be interupt
 *	bound incase they mess up.
 */
char
getchar()
{
	return readchar(CONSOLE);
}

char
putchar(ch)
char ch;
{
	int	c;

	/* Perform simple output conversions */
	switch(ch){
	case NL:
		/* implement CRMOD type of conversion */
		if(ttys[CONSOLE].sgtty.sg_flags&CRMOD){
			writechar(CONSOLE,CR);
			crdelay(&ttys[CONSOLE]);	/* Do CR delay */

			/* Wait untill port is ready */
			writechar(CONSOLE,NL);
			ttys[CONSOLE].col = 0;
			ttys[CONSOLE].line++;
			nldelay(&ttys[CONSOLE]);	/* Do NL delay */
		}
		else{
			writechar(CONSOLE,ch);
			ttys[CONSOLE].line++;
			nldelay(&ttys[CONSOLE]); /* Do NL delay */
		}
		break;

	case CR:
		writechar(CONSOLE,ch);
		ttys[CONSOLE].col = 0;
		crdelay(&ttys[CONSOLE]); /* Do CR delay */
		break;

	case TAB:
		for(c = 0; c < 8; c++) writechar(CONSOLE,' ');
		break;
		
	default:
		/* Normal character output */
		writechar(CONSOLE,ch);
		break;
	}
	return;
}

/*
 *	tputout		Puts the number of bytes given into the output buffer
 *			Setting the buffer to print the characters and
 *			starting off the print if nessecary
 */
tputout(dev, buffer, nbytes)
int dev;
char *buffer;
int nbytes;
{
	int bytecount;
	short intlevel;


	/* Put as many as possible bytes into the output buffer
	 * for this device
	 */
	bytecount = tputbuf(buffer,(&ttys[dev].outbuf),nbytes);
	ttys[dev].outbuf.outrdy = RDY;		/* Sets the buffer to print */

	/* If acia is waiting for a character give it one to start
	 * The output ( tx_rdy flag notes this ) interupt driven only.
	 */
	if(ttydevsw[dev].type == INTERUPT){
		if(ttys[dev].tx_rdy){
			intlevel = SPLTTY();		/* Disables interupts */
			ttyout(dev);			/* Outputs a character*/
			splx(intlevel);			/* Renables them again*/
		}
	}

	/* If polled type of device print out all characters */
	if(ttydevsw[dev].type == POLLED){
		while(ttys[dev].outbuf.count>0){
			/* If device has character for RX then get it */
			if((*ttydevsw[dev].status)(ttydevsw[dev].m_m_dev)
				& RRDY) ttyin(dev);
			ttyout(dev);
		}
	}
	return bytecount;
}
/*
 *	Tputbuf	Puts the number of bytes into the buffer if possible
 *		Returns the number of bytes entered.
 *		Common for both input and output buffers
 *		is passed a pointer to the buffer structure
 */
tputbuf(from,tbuf,number)
char *from;
struct ttybuf *tbuf;
short number;
{
	register int num;
	register char *topbuf;
	short	intlevel;

	intlevel = SPLTTY();		/* Disable all interupts */

	/* Finds number of characters to write (max is full buffer) */
	if((tbuf->count + number) > TTYBUFSIZE){
		number = TTYBUFSIZE - tbuf->count;
	}
	num = number;
	topbuf = &tbuf->buf[TTYBUFSIZE];	/* Address of buffer top */

	/* Puts data into buffer at inptr wrapping inptr to start of buffer
	 *	if necessary
	 */
	while(num--){
		*tbuf->inptr++ = *from++;
		if(tbuf->inptr >= topbuf) tbuf->inptr = &tbuf->buf[0];
	}

	/* Updates buffer byte count and high water mark flag */
	if((tbuf->count += number) > HIGHMARK) tbuf->inrdy = 0;
	splx(intlevel);				/* Renable interupts */
	return number;
 }
/*
 *	Tgetbuf	Gets the number of bytes from the buffer if possible
 *		Returns the number of bytes got.
 */
tgetbuf(tbuf,to,number)
char *to;
struct ttybuf *tbuf;
short number;
{
	register int num;
	register char *topbuf;
	short	intlevel;

	/* Test if buffer is ready to output characters */
	if(!tbuf->outrdy) return 0;

	intlevel = SPLTTY();			/* Mask all interupts */
	/* Finds number of characters to read */
	if(tbuf->count < number){
		number = tbuf->count;
	}
	num = number;
	topbuf = &tbuf->buf[TTYBUFSIZE];	/* Address of buffer top */

	/* Puts data from buffer to pointer  wrapping outptr to start of buffer
	 *	if necessary
	 */
	while(num--){
		*to++ = *tbuf->outptr++;
		if(tbuf->outptr >= topbuf) tbuf->outptr = &tbuf->buf[0];
	}

	/* Updates buffer count and checks for bellow low water mark */
	if(!(tbuf->count -= number)) tbuf->outrdy = 0;
	if(tbuf->count < LOWMARK) tbuf->inrdy = RDY;
	splx(intlevel);				/* Renable interupts */
	return number;
}
/*
 *	Flush	Flush the buffer whose address is given
 */
flush(tbuf)
struct ttybuf *tbuf;
{
	short	intlevel;

	/* If not in an interupt then mask all temparily */
	intlevel = SPLTTY();
	tbuf->inptr = &tbuf->buf[0];
	tbuf->outptr = &tbuf->buf[0];
	tbuf->count = 0;
	tbuf->inrdy = RDY;
	tbuf->outrdy = NOTRDY;

	/* Recover last interupt state */
	splx(intlevel);
}


/*
 * I_tty - implement ioctl for this device (Almost fake), infact its
 *		allmost real now.
 */
i_tty(dev, request, argp)
int *argp;
{

	struct	ttystruct *tty;
	short intlevel;

	/* Gets address of relevent tty structure */
	tty = &ttys[dev];

	intlevel = SPLTTY();		/* Mask out those yeuchy interupts */
	switch (request) {
	case TIOCGETP:
		/* old gtty call in effect */
		bytecp(&tty->sgtty, argp, sizeof(struct sgttyb));
		break;

	case TIOCGETC:
		/* Gets special charcters */
		bytecp(&tty->tchars, argp, sizeof(struct tchars));
		break;

	case TIOCGLTC:
		/* Gets local special charcters */
		bytecp(&tty->ltchars, argp, sizeof(struct ltchars));
		break;

	case TIOCSETP:
		/* Setting params */
		bytecp(argp, &tty->sgtty, sizeof(struct sgttyb));

		/* Wait until output queue is empty, renable interupts
		 * While this is happening. Call ttywait() to indicate
		 * That the tty handler is dossing around
		 */
		splx(intlevel);
		while(tty->outbuf.count) ttywait(dev,WWAITB);
		intlevel = SPLTTY();

		/* Flush buffers */
		flush(&tty->inbuf);
		flush(&tty->outbuf);

		/* Sets up physical device */
		(*ttydevsw[dev].setfnc)(ttydevsw[dev].m_m_dev);

		/* Ouput a character if one in output buffer, there
		 * Won't be but ttyout will find this out the hard
		 * way, (such is life!)  and set the tx_rdy flag.
		 */
		ttyout(dev);
		break;

	case TIOCSETN:
		/* Setting params */
		bytecp(argp, &tty->sgtty, sizeof(struct sgttyb));

		/* Sets up physical device */
		(*ttydevsw[dev].setfnc)(ttydevsw[dev].m_m_dev);

		/* Ouput a character if one in output buffer */
		ttyout(dev);
		break;

	case TIOCSETC:
		/* Sets special charcters */
		bytecp(argp, &tty->tchars, sizeof(struct tchars));
		break;

	case TIOCSLTC:
		/* Sets local special charcters */
		bytecp(argp, &tty->ltchars, sizeof(struct ltchars));
		break;

	case TIOCFLUSH:
		/* Flush all buffers */
		flush(&tty->inbuf);
		flush(&tty->outbuf);
		break;

	case FIONREAD:
		/* Number of bytes in buffer */
		*argp = tty->inbuf.count;
		break;

	default:
		/* illegal */
		if(state.warning) printf("IOCTL not available %d\n\r",request);
		splx(intlevel);		/* Reset interupt level */
		return -1;
	}

	/* successful.. */
	splx(intlevel);			/* Reset interupts good luck! */
	return 0;
}
