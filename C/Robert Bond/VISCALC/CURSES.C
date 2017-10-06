/**********************************************************************
 *
 * Tiny pseudo "curses" package (runs on U__X, VMS, or MCH_AMIGA)
 *
 *	v1.0	870117	DBW - D. Wecker, initial hack
 *
 **********************************************************************/

#ifdef VMS
#include <stsdef.h>
#include <ssdef.h>
#include <descrip.h>
#include <iodef.h>
#include <ttdef.h>

#define NIBUF   128		/* Input buffer size */
#define NOBUF   1024		/* MM says bug buffers win! */
#define EFN     0		/* Event flag */

char obuf[NOBUF];		/* Output buffer */
int nobuf;			/* # of bytes in above */
char ibuf[NIBUF];		/* Input buffer */
int nibuf;			/* # of bytes in above */
int ibufi;			/* Read index */
int oldmode[2];			/* Old TTY mode bits */
int newmode[2];			/* New TTY mode bits */
short iochan;			/* TTY I/O channel */
struct dsc$descriptor  idsc;
struct dsc$descriptor  odsc;
char oname[40];
int iosb[2];
int term[2];
int status;
#endif

#ifdef MCH_AMIGA
extern	char		*Open();
extern	long		Read(),Write();
extern	void		Close();
#define NEW		1006L
#define AMG_MAXBUF	1024
static char		*terminal = 0L;
static char		scrn_tmp[AMG_MAXBUF+1];
static long		scrn_tmp_p = 0L;
#endif

#ifdef U__X
#include <sys/ioctl.h>
#include <sgtty.h>
#include <stdio.h>
struct sgttyb old_tty,new_tty;
#endif

#ifdef MCH_AMIGA
#define	COLS	79
#define ROWS	23
#else
#define	COLS	80
#define ROWS	24
#endif

#ifdef TOS
#include <osbind.h>
#define ST_MAXBUF 512
static char		scrn_tmp[ST_MAXBUF+1];
static long		scrn_tmp_p = 0L;
#endif

#define NORMAL	0x00
#define BOLD	0x80

char	nscrn[ROWS][COLS],
	cscrn[ROWS][COLS],
	row,
	col,
	mode;
char	str[256];

move(y,x)
int y,x;
    {
    row = y;
    col = x;
    }

clrtoeol() {
    int i;

    for (i = col; i < COLS; i++) nscrn[row][i] = ' ' | mode;
    }

printw(fmt,a1,a2,a3,a4,a5)
char	*fmt,*a1,*a2,*a3,*a4,*a5;
    {
    int i,j;

    sprintf(str,fmt,a1,a2,a3,a4,a5);
    j = 0;
    for (i = col; i < COLS && str[j] != '\000'; i++)
	nscrn[row][i] = str[j++] | mode;
    col = i;
    }

clrtobot() {
    int i,j;

    clrtoeol();
    for (i = row+1; i < ROWS; i++)
	for (j = 0; j < COLS; j++)
	    nscrn[i][j] = ' ' | mode;
    }

standout() {
    mode = BOLD;
    }

standend() {
    mode = NORMAL;
    }

addstr(s)
char	*s;
    {
    printw("%s",s);
    }

initscr() {
    int	    i,j;

#ifdef MCH_AMIGA
    terminal = Open("RAW:1/1/639/199/DBW_VC (v1.0 870117)",(long)NEW);
#endif
#ifdef VMS
    odsc.dsc$a_pointer = "TT";
    odsc.dsc$w_length = strlen(odsc.dsc$a_pointer);
    odsc.dsc$b_dtype = DSC$K_DTYPE_T;
    odsc.dsc$b_class = DSC$K_CLASS_S;
    idsc.dsc$b_dtype = DSC$K_DTYPE_T;
    idsc.dsc$b_class = DSC$K_CLASS_S;
    do {
	idsc.dsc$a_pointer = odsc.dsc$a_pointer;
	idsc.dsc$w_length = odsc.dsc$w_length;
	odsc.dsc$a_pointer = &oname[0];
	odsc.dsc$w_length = sizeof(oname);
	status = LIB$SYS_TRNLOG(&idsc, &odsc.dsc$w_length, &odsc);
	if (status!=SS$_NORMAL && status!=SS$_NOTRAN) exit(status);
	if (oname[0] == 0x1B) {
	    odsc.dsc$a_pointer += 4;
	    odsc.dsc$w_length -= 4;
	    }
	}
    while (status == SS$_NORMAL);
    status = SYS$ASSIGN(&odsc, &iochan, 0, 0);
    if (status != SS$_NORMAL) exit(status);
    status = SYS$QIOW(EFN, iochan, IO$_SENSEMODE, iosb, 0, 0,
	    oldmode, sizeof(oldmode), 0, 0, 0, 0);
    if (status!=SS$_NORMAL || (iosb[0]&0xFFFF)!=SS$_NORMAL) exit(status);
    newmode[0] = oldmode[0];
    newmode[1] = oldmode[1] | TT$M_PASSALL | TT$M_NOECHO;
    status = SYS$QIOW(EFN, iochan, IO$_SETMODE, iosb, 0, 0,
	    newmode, sizeof(newmode), 0, 0, 0, 0);
    if (status!=SS$_NORMAL || (iosb[0]&0xFFFF)!=SS$_NORMAL) exit(status);
#endif

#ifdef U__X
    ioctl(0,TIOCGETP,&old_tty);
    ioctl(0,TIOCGETP,&new_tty);
    new_tty.sg_flags |= RAW;
    new_tty.sg_flags &= ~ECHO;
    ioctl(0,TIOCSETP,&new_tty);
#endif

    row	    = 0;
    col	    = 0;
    mode    = NORMAL;
    for (i = 0; i < ROWS; i++)
	for (j = 0; j < COLS; j++)
	    nscrn[i][j] = cscrn[i][j] = ' ';
    ttputs("\033E");
    }

clear() {
    row = 0;
    col = 0;
    clrtobot();
    }

endwin() {
    move(ROWS-1,0);
    refresh();

#ifdef MCH_AMIGA
    amg_flush();
    Close(terminal);
#endif

#ifdef VMS
    status = SYS$QIOW(EFN, iochan, IO$_SETMODE, iosb, 0, 0,
		oldmode, sizeof(oldmode), 0, 0, 0, 0);
    if (status!=SS$_NORMAL || (iosb[0]&0xFFFF)!=SS$_NORMAL) exit(status);
    status = SYS$DASSGN(iochan);
    if (status != SS$_NORMAL) exit(status);
#endif

#ifdef U__X
    ioctl(0,TIOCSETP,&old_tty);
#endif

    }

char inch() {
    return(nscrn[row][col] & 0x7F);
    }

touchwin() {
    int i,j;

    for (i=0; i<ROWS; i++)
	for (j=0; j<COLS; j++)
	    cscrn[i][j] = ' ';
    ttputs("\033E");
    }

refresh() {
    int	i,j,mode;

    mode = NORMAL;
    for (i=0; i < ROWS; i++) {
	for (j = 0; j < COLS; j++) {
	    if (nscrn[i][j] != cscrn[i][j]) {
		sprintf(str,"\033Y%c%c",i+32,j+32);
		ttputs(str);
		while (nscrn[i][j] != cscrn[i][j]) {
		    if (mode == NORMAL && (nscrn[i][j] & BOLD) == BOLD) {
			ttputs("\033p");
			mode = BOLD;
			}
		    else if (mode == BOLD && (nscrn[i][j] & BOLD) == NORMAL) {
			ttputs("\033q");
			mode = NORMAL;
			}
		    cscrn[i][j] = nscrn[i][j];
		    ttputc(nscrn[i][j] & 0x7F);
		    j++;
		    }
		}
	    }
	}
    sprintf(str,"\033Y%c%c",row+32,col+32);
    ttputs(str);
    if (mode) ttputs("\033q");
    ttflush();
    }

ttgetc() {
#ifdef MCH_AMIGA
    unsigned char ch[2];

    Read(terminal, ch, 1L);
    return (ch[0] & 0xFF);
#endif

#ifdef VMS
    while (ibufi >= nibuf) {
	ibufi = 0;
	term[0] = 0;
	term[1] = 0;
	status = SYS$QIOW(EFN, iochan, IO$_READLBLK|IO$M_TIMED,
	iosb, 0, 0, ibuf, NIBUF, 0, term, 0, 0);
	if (status != SS$_NORMAL) exit(status);
	status = iosb[0] & 0xFFFF;
	if (status!=SS$_NORMAL && status!=SS$_TIMEOUT) exit(status);
	nibuf = (iosb[0]>>16) + (iosb[1]>>16);
	if (nibuf == 0) {
	    status = SYS$QIOW(EFN, iochan, IO$_READLBLK,
	    iosb, 0, 0, ibuf, 1, 0, term, 0, 0);
	    if (status != SS$_NORMAL || (status = (iosb[0]&0xFFFF)) != SS$_NORMAL)
	    exit(status);
	    nibuf = (iosb[0]>>16) + (iosb[1]>>16);
	    }
	}
    return (ibuf[ibufi++] & 0x7F);
#endif

#ifdef U__X
    return(getchar() & 0x7F);
#endif

#ifdef TOS
	char c, hi, lo;
	long keycode=Crawcin();
	lo=keycode&0xff;
	hi=(keycode>>16)&0xff;
	switch (hi) {
		case 0x62 : {c='?'; break;}
		case 0x48 : {c='\020'; break;}
		case 0x4b : {c='\002'; break;}
		case 0x4d : {c='\006'; break;}
		case 0x50 : {c='\016'; break;}
		default : {c=lo;}
	}
	return (c);

#endif
    }

ttputc(c)
#ifdef MCH_AMIGA
char c;
#endif
    {
#ifdef MCH_AMIGA
    scrn_tmp[scrn_tmp_p++] = c;
    if(scrn_tmp_p>=AMG_MAXBUF) amg_flush();
#endif

#ifdef TOS
    scrn_tmp[scrn_tmp_p++] = c;
    if(scrn_tmp_p>=ST_MAXBUF) st_flush();
#endif

#ifdef VMS
    if (nobuf >= NOBUF) ttflush();
    obuf[nobuf++] = c;
#endif

#ifdef U__X
    fputc(c, stdout);
#endif
    }

#ifdef MCH_AMIGA
amg_flush()
    {
    if(scrn_tmp_p) Write(terminal,scrn_tmp,(long)scrn_tmp_p);
    scrn_tmp_p = 0;
    }
#endif

#ifdef TOS
st_flush()
    {
    scrn_tmp[scrn_tmp_p]=0;
    if(scrn_tmp_p) cputs(scrn_tmp);
    scrn_tmp_p = 0;
    }
#endif

ttputs(s)
char	*s;
    {
    while (*s) ttputc(*s++);
    }

ttflush()
    {
#ifdef MCH_AMIGA
    amg_flush();
#endif

#ifdef TOS
    st_flush();
#endif

#ifdef VMS
    status = SS$_NORMAL;
    if (nobuf != 0) {
	status = SYS$QIOW(EFN, iochan, IO$_WRITELBLK|IO$M_NOFORMAT,
	iosb, 0, 0, obuf, nobuf, 0, 0, 0, 0);
	if (status == SS$_NORMAL) status = iosb[0] & 0xFFFF;
	nobuf = 0;
	}
    return (status);
#endif

#ifdef U__X
    fflush(stdout);
#endif
    }

