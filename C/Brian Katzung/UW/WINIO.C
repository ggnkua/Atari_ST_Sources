/*
 * This file contains file io routines
 */
#include <obdefs.h>
#include <gemdefs.h>
#include <stdio.h>
#include <osbind.h>
#include <xbios.h>
#include "wind.h"
#include "uw.h"
#include "windefs.h"

extern struct wi_str w[];

/*
 * Character stuff (fonts, keymaps).
 */
extern FNT *fnttbl[10];			/* List of pointers to fonts avail */
extern int fontsavail;			/* Number of fonts available */
extern FNT *curfont;			/* font in use */
extern int fontmenuobj[];		/* array of font menu object numbers */
/*
 * Options (somewhat loosely defined).
 */
extern int fast;			/* flag for fast open/close */
extern int overstrike;			/* flag for character output */
extern int sliders;			/* flag for sliders on new windows */
extern int titles;			/* flag for title bars on new windows */
extern int audibell;			/* Audible bell. */
extern int visibell;			/* Visible bell. */
extern int toponbel;			/* Top window on bell. */

extern FUNCSTRING fstrings[];		/* storage for function key bodys */

extern char cmdpath[];			/* default command executions strings */
extern char cmdname[];
extern char cmdargs[];

extern OBJECT *menubar;

void rsbufset();
long	bufsizs[] = {		/* rs-232 buffer sizes setable from uw */
	256l,	2048l,	16384l
};
int	bufsiz = 0;		/* index into table above of current size */

#ifdef	LOCATE
extern	char	*locate();
#else
#define	locate(n)	n
#endif

/* read a font from a file */
FNT * loadfont (name)
char	*name;
{
  FNT * curfont;
  char *tmpfnt;
  char menustr[20];
  char namestr[20];
  register int shift;
  register unsigned int mask;
  register int	i;
  char *getmem();

  if ((curfont = (FNT *) getmem((long)sizeof(FNT))) == NULL)
    return(NULL);
  i = Fopen(locate(name), 0);
  if (i<0)
    return (NULL);
  Fread(i, 2048L, curfont->f_data);
  Fclose(i);
  curfont->inc_x = MINMAX(curfont->f_data[16], 1, 8);
  curfont->inc_y = MINMAX(curfont->f_data[32], 1, 16);
  shift = 8-curfont->inc_x;
  mask = (1<<curfont->inc_x)-1;
  tmpfnt = curfont->f_data;
  for (i=0; i<2048; i++)
  {
    *tmpfnt = (*tmpfnt>>shift)&mask;
    tmpfnt++;
  }
  sscanf(name, "wind%3s", namestr);
  sprintf(menustr, "%1.2d x %1.2d %s font", curfont->inc_x, curfont->inc_y,
    namestr);
  set_menu_string(menustr, fontmenuobj[fontsavail]);
  gen_hash(curfont, &curfont->f_hash);

  fnttbl[fontsavail] = curfont;
  fontsavail++;
  return (curfont);
}

/* This function reads the config file from name in directory path and sets
 * the apropriate variables.
 */
read_config(path, name)
char *path;
char *name;
{
  char file[100];
  char *ptr;
  char *status;
  FILE *fd;
  int i, j;
  char *index(), *rindex();
  
  strcpy(file, path);
  ptr = rindex(file, '\\');
  if (ptr != NULL)
    *(ptr+1) = '\0';
  strcat(file, name);
  
  fd = fopen(file, "r");
  if (fd == NULL)
  {
    if (*path != '\0')	/* don't print error if in startup */
      form_alert(1, "[2][Can't open config input file][ok]");
    return;
  }
  status = fgets(file, 100,fd);
  while (status != NULL)
  {
    char * endline;
    if ((endline = rindex(file, '\n')) != NULL)
      *endline = '\0';
    if (!strncmp("audibell=", file, 9))
      audibell = atoi(file + 9);
    else if (!strncmp("visibell=", file, 9))
      visibell = atoi(file + 9);
    else if (!strncmp("topbell=", file, 8))
      toponbel = atoi(file + 8);
    else if (!strncmp("fast", file, 4))
      ++fast;
    else if (!strncmp("slow", file, 4))
    	fast = 0;
    else if (!strncmp("overstrike", file, 4))
      ++overstrike;
    else if (!strncmp("nooverstrike", file, 4))
      overstrike = 0;
    else if (!strncmp("sliders", file, 7))
      ++sliders;
    else if (!strncmp("nosliders", file, 9))
    	sliders = 0;
    else if (!strncmp("titles", file, 6))
      ++titles;
    else if (!strncmp("notitless", file, 8))
    	titles = 0;
    else if (!strncmp("font=", file, 5))
    {
      i = atoi(file+5);
      if (fontsavail > i)
      {
        for (j = 0; j < fontsavail; j++)
          objc_change(menubar, fontmenuobj[j], 0, 0, 0, 0, 0, NONE, 0);
        objc_change(menubar, fontmenuobj[i], 0, 0, 0, 0, 0, CHECKED, 0);
        curfont = fnttbl[i];
      }
    }
    else if (!strncmp("bufsiz=", file, 7))
    {
      i = atoi(file+7);
      for (j=0; j < sizeof(bufsizs)/sizeof(bufsizs[0]); j++)
      	if (bufsizs[j] >= i)
	  break;
      bufsiz = j;
      rsbufset(j);
    }
    else if (file[0] == 'f' && file[1] >= '0' && file[1] <= '9'
      && (file[2] == '=' || file[3] == '='))
      {
	i = atoi(file+1);
	if (i < 1) i = 1;
	if (i > NFSTRINGS - 2) i = NFSTRINGS - 2;
	status = index(file, '=');
	ptr = index(status, '\n');
	if (ptr != NULL)
	  *ptr = '\0';
	strcpy(fstrings[i-1], status+1);
      }
    else if (!strncmp("cmdpath=", file, 8))
	strcpy(cmdpath, file+8);
    else if (!strncmp("cmdname=", file, 8))
	strcpy(cmdname, file+8);
    else if (!strncmp("cmdargs=", file, 8))
	strcpy(cmdargs, file+8);
    status = fgets(file, 100, fd);
  }
  objc_change(menubar, VISIBELL, 0, 0, 0, 0, 0,
    visibell? CHECKED: 0, 0);
  objc_change(menubar, AUDIBELL, 0, 0, 0, 0, 0,
    audibell? CHECKED: 0, 0);
  objc_change(menubar, TOPONBEL, 0, 0, 0, 0, 0,
    toponbel? CHECKED: 0, 0);
  menu_icheck(menubar, MFAST, !fast);
  menu_icheck(menubar, OVERSTRI, overstrike);
  menu_icheck(menubar, WINSTYLE, sliders);
  menu_icheck(menubar, WINTITLE, titles);
}

/* This function writes the config file name in directory path.
 */
write_config (path, name)
char	*path;
char	*name;
{
	char	file[100];
	char	*ptr;
	FILE	*fd;
	int	i;
	char	*rindex();
  
	strcpy(file, path);
	ptr = rindex(file, '\\');
	if (ptr != NULL)
		*(ptr + 1) = '\0';
	strcat(file, name);
  
	fd = fopen(file, "w");
	if (fd == NULL)
	{
		form_alert(1, "[2][Can't open config output file][ok]");
		return;
	}

	fprintf(fd, "audibell=%d\n", audibell);
	fprintf(fd, "visibell=%d\n", visibell);
	fprintf(fd, "topbell=%d\n", toponbel);
	fprintf(fd, "%s\n", fast? "fast": "slow");
	fprintf(fd, "%s\n", overstrike? "overstrike": "nooverstrike");
	fprintf(fd, "%s\n", sliders? "sliders": "nosliders");
	fprintf(fd, "%s\n", titles? "titles": "notitles");
	fprintf(fd, "bufsiz=%ld\n", bufsizs[bufsiz]);
	fprintf(fd, "cmdpath=%s\n", cmdpath);
	fprintf(fd, "cmdname=%s\n", cmdname);
	fprintf(fd, "cmdargs=%s\n", cmdargs);
	for (i = 0; i < fontsavail; i++)
		if (curfont == fnttbl[i])
			fprintf(fd, "font=%d\n", i);

	for (i = 0; i < NFSTRINGS - 2; ++i)
		fprintf(fd, "f%d=%s\n", i + 1, fstrings[i]);
	fclose(fd);
}

setcapture (wp)
WI_STR	*wp;
{
	char	full[80];
	register char	*cp1, *cp2;

	if (wp->wi_lfd)
	{
		fclose(wp->wi_lfd);
		wp->wi_lfd = NULL;
	}
	if (*wp->wi_fname)
	{
		cp1 = full;
		for (cp2 = wp->wi_fpath; *cp2; *cp1++ = *cp2++);
		while (--cp1 >= full && *cp1 != '\\');
		strcpy(++cp1, wp->wi_fname);
		if ((wp->wi_lfd = fopen(full, "a")) == NULL)
		{
			form_alert(1, "[2][Unable to open capture file.][ok]");
			*wp->wi_fname = '\0';
		}
	}
	w_rename(wp - w, NULL);
}

#define	DEFUCR	0x88		/* Async, 1 stop bit */

int	speedobjs[] = {
	BB1920,	BB960,	BB480,	BB360,	BB240,	BB200,	BB180,	BB120,
	BB60,	BB30,	BB20,	BB15,	BB13,	BB11,	BB7,	BB5
};
int	flowobjs[] = {
	FCBNONE,	FCBXON,		FCBRTS
};
int	parobjs[] = {
	PBNONE,		PBODD,		PBEVEN
};
int	stopobjs[] = {
	SBB1,		SBB15,		SBB2
};
int	bcbobjs[] = {
	BCB8,		BCB7,		BCB6,		BCB5
};
int	bufobjs[] = {
	BUFSIZ1,	BUFSIZ2,	BUFSIZ32
};
#ifdef	GETSPEED
/* Baud rates 75 and 50 are not currently decoded. */
int	timevals[] = {
	1,	2,	4,	5,	8,	10,	11,
	16,	32,	64,	96,	128,	143,	175
};
#endif

int	speed = -1;		/* Don't know */
int	flow = -1;
int	ucr = -1;
struct iorec old_iorec;

/* load rs232 configuration into RSCONF dialog */
getrsconf ()
{
	OBJECT	*obj;
	register int	i;
#ifdef	GETSPEED
#define	MFP	0xFFFFFA01L
#define	TDDR	36
#define	hz_200	((unsigned long *) 0x4BAL)
	int	tv;			/* Timer value */
	int	maxtv;			/* Maximum timer value */
	unsigned long	endhz;		/* End of polling period */
	long	savessp;		/* Old stack pointer */
#endif
#ifdef	GETFLOW
	struct	rsiorec	{
		char	fill0[32];
		char	rsmode;
		char	fill1[1];
	};
#endif

#ifdef	GETSPEED
	savessp = Super(0L);
	maxtv = 0;
	endhz = *hz_200 + 8;
	while (*hz_200 < endhz)
	{
		tv = *((unsigned char *) (0xFFFFFA01L + 36));
		if (tv > maxtv)
			maxtv = tv;
	}
	(void) Super(savessp);
	for (i = sizeof(timevals) / sizeof(timevals[0]);
	  --i >= 0 && timevals[i] != maxtv; );
	if (i >= 0)
		speed = i;
#endif
#ifdef	GETFLOW
	flow = ((struct rsiorec *) Iorec(0))->rsmode;
	if (flow == 3)			/* UW doesn't support both */
		flow = 1;
#endif
#ifdef	GETUCR
	/* Dev. Kit code suggests that Rsconf() returns old register vals */
	ucr = (xbios(15, -1, -1, -1, -1, -1, -1) >> 24) & 0xFF;
#endif
	rsrc_gaddr(R_TREE, RSCONF, &obj);
	for (i = sizeof(speedobjs) / sizeof(int); --i >= 0; )
		obj[speedobjs[i]].ob_state = NORMAL;
	for (i = sizeof(flowobjs) / sizeof(int); --i >= 0; )
		obj[flowobjs[i]].ob_state = NORMAL;
	for (i = sizeof(parobjs) / sizeof(int); --i >= 0; )
		obj[parobjs[i]].ob_state = NORMAL;
	for (i = sizeof(stopobjs) / sizeof(int); --i >= 0; )
		obj[stopobjs[i]].ob_state = NORMAL;
	for (i = sizeof(bcbobjs) / sizeof(int); --i >= 0; )
		obj[bcbobjs[i]].ob_state = NORMAL;
	for (i = sizeof(bufobjs) / sizeof(int); --i >= 0; )
		obj[bufobjs[i]].ob_state = NORMAL;

	if (speed >= 0)
		obj[speedobjs[speed]].ob_state = SELECTED;

	if (flow >= 0)
		obj[flowobjs[flow]].ob_state = SELECTED;

	if (ucr >= 0)
	{
		switch (ucr & 0x6)	/* Parity */
		{
		default:
			obj[PBNONE].ob_state = SELECTED;
			break;
		case 0x4:
			obj[PBODD].ob_state = SELECTED;
			break;
		case 0x6:
			obj[PBEVEN].ob_state = SELECTED;
			break;
		}
	
		switch (ucr & 0x18)
		{
		default:
			obj[SBB1].ob_state = SELECTED;
			break;
		case 0x10:
			obj[SBB15].ob_state = SELECTED;
			break;
		case 0x18:
			obj[SBB2].ob_state = SELECTED;
			break;
		}
	
		obj[bcbobjs[(ucr >> 5) & 3]].ob_state = SELECTED;
	}
	obj[bufobjs[bufsiz]].ob_state = SELECTED;
}
	
/* set rs232 configuration from the RSCONF dialog */
setrsconf ()
{
	register int	i;
	OBJECT	*obj;
	short	parity = 0;
	short	stop = 0;
	short	bcb = -1;

	rsrc_gaddr(R_TREE, RSCONF, &obj);

	for (i = sizeof(speedobjs) / sizeof(int); --i >= 0; )
		if (obj[speedobjs[i]].ob_state & SELECTED)
		{
			speed = i;
			break;
		}

	for (i = sizeof(flowobjs) / sizeof(int); --i >= 0; )
		if (obj[flowobjs[i]].ob_state & SELECTED)
		{
			flow = i;
			break;
		}

	for (i = sizeof(parobjs) / sizeof(int); --i >= 0; )
		if (obj[parobjs[i]].ob_state & SELECTED)
		{
			parity = i + 1;
			break;
		}

	for (i = sizeof(stopobjs) / sizeof(int); --i >= 0; )
		if (obj[stopobjs[i]].ob_state & SELECTED)
		{
			stop = i + 1;
			break;
		}

	for (i = sizeof(bcbobjs) / sizeof(int); --i >= 0; )
		if (obj[bcbobjs[i]].ob_state & SELECTED)
		{
			bcb = i;
			break;
		}

	for (i = sizeof(bufobjs) / sizeof(int); --i >= 0; )
		if (obj[bufobjs[i]].ob_state & SELECTED)
		{
			bufsiz = i;
			break;
		}

	if ((parity || stop || bcb >= 0) && ucr < 0)
		ucr = DEFUCR;
	if (parity)
		ucr = (ucr & ~0x6) | (parity << 1);
	if (stop)
		ucr = (ucr & ~0x18) | (stop << 3);
	if (bcb >= 0)
		ucr = (ucr & ~0x60) | (bcb << 5);

	Rsconf(speed, flow, ucr, -1, -1, -1);
	rsbufset(bufsiz);
}

void rsbufset(bufsiz)
int bufsiz;
{
	struct iorec *ioptr;
	static char    *memalloced = NULL;
	static int	oldbufsiz = 0;

	ioptr = Iorec(0);
	if (old_iorec.io_bufsiz == 0)
		old_iorec = *ioptr;	/* save gem buffer */
	if (oldbufsiz != bufsiz) {
		char *mem;
		oldbufsiz = bufsiz;
		mem = (char *) Malloc(bufsizs[bufsiz]);
		if (mem != NULL) {
			if (memalloced != NULL)
				Mfree(memalloced);
			memalloced = mem;
			ioptr->io_buff = mem;
			ioptr->io_bufsiz = bufsizs[bufsiz];
			ioptr->io_head = 0;
			ioptr->io_tail = 0;
			ioptr->io_low = bufsizs[bufsiz] / 4;
			ioptr->io_high = ioptr->io_bufsiz - ioptr->io_low;
		}
	}
}
