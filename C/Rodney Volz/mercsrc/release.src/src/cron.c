/* 
 *   Copyright (c) 1990 Rodney Volz
 *   ALL RIGHTS RESERVED 
 * 
 *   THIS SOFTWARE PRODUCT CONTAINS THE
 *   UNPUBLISHED SOURCE CODE OF RODNEY VOLZ
 *
 *   The copyright notices above do not evidence
 *   intended publication of such source code.
 *
 */

/*
 * MERCURY UUCP SOURCECODE [cron.c]
 */

/* PARTS BORROWED FROM MINIX CRON */

#include <mintbind.h>
#include <osbind.h>
#include <stdio.h>
#include <time.h>
#include <ctype.h>


/* Define or un-define this... */
#if 0
#define debug(string)	fprintf(stderr,"%s\n",string)
#else
#define debug(string)
#endif


/*
 *
 *	Backup the files every other day at 7:30 pm:
 *		30 19 * * 1,3,5 sdbackup -s LAST dh0: incbkup_1:
 *
 */


#define CRONTAB		"D:\\etc\\crontab"
#define CRONERR		"D:\\etc\\cron.err"

#define TRUE 1
#define FALSE 0

#define MAXLINE 132
#define SIZE	64

extern	int	errno;
extern char *strchr();

int	file_end;
char	min[SIZE], hour[SIZE], day[SIZE],
	month[SIZE], wday[SIZE], command[SIZE];
char	*tokv[] = { min, hour, day, month, wday };
FILE	*fd;
int	err;
struct tm *tim;
static char mint = 0;		/* Do we use MiNT? */

sighandler()
{
	fprintf(stderr,"CRON: Caught signal.\n");
}

/*
 *	This is the basics, ready for bells and whistles
 *
 */

main()
{
	int omin,n;
	time_t t_tmp;

	/* Determine, if we use MiNT */
	if (Pgetpid() != -32)
		++mint;

	/* Some color settings */
	n = 0;
	xbios(7,n++,0);
	xbios(7,n++,112);
	xbios(7,n++,1792);
	xbios(7,n++,1911);


	/*
	 *	fopen() will create the file if it does not exist.
	 *	Any other errors will be output to stderr at startup.
	 */

	if (mint)
	{
		for (n = 0; n < 16; n++)
			Psignal(n,sighandler);
	}
	else	/* Say hello... */
	{
		printf("\033E");
		printf("- Cron running -\n\n");
	}
	
	omin = 0;
	for (;;)
	{
		for(;;)
		{
			delay(5);

			time(&t_tmp);
			tim = localtime(&t_tmp);

			if (tim->tm_min != omin)
				break;
		}

		wakeup();

		omin = tim->tm_min;
	}
}




long timer()	/* System-Timer holen */
{
	long _timer();
	long xbios();

	return((long)xbios(38,_timer));
}


long _timer()
{
	return(*((long *)0x4ba));
}


delay(n)		/* Wait n seconds */
int n;
{
	long t0;

	t0 = timer() + (250 * n);

	if (mint)
	{
		while (timer() < t0)
			Syield();
	}
	else
	{
		while (timer() < t0)
			;
	}
}



wakeup()
{
	FILE *fp;
	char cmd[128];
	char *ctime();
	time_t cur_time;
	char s1[100],s2[100];
	char *cp1,*cp2;
	long stddrive,tmpdrive;

	stddrive = (int)Dgetdrv();
	
	if (!(fd = fopen(CRONTAB, "r")))
		return(0);

	file_end = FALSE;

	time(&cur_time);
	tim = localtime(&cur_time);


	while (!file_end)
	{
		if (getline() && match(min,tim->tm_min) &&
		   match(hour,tim->tm_hour) && match(day,tim->tm_mday) &&
		   match(month,tim->tm_mon) && match(wday,tim->tm_wday))
		{
			/* Log our activities */
			fp = fopen(CRONERR,"a");
			fprintf(fp,"%02d/%02d %02d:%02d Cron: %s",tim->tm_mday,tim->tm_mon,
				tim->tm_hour,tim->tm_min,command);
			fclose(fp);

			if (!mint) /* Explain what we are doing */
			{
				fprintf(stdout,"\033p %02d/%02d %02d:%02d \033q %s",tim->tm_mday,tim->tm_mon,
					tim->tm_hour,tim->tm_min,command);
			}
			else	/* With mint: be quiet */
			{
				Psetlimit(2,(long)(Malloc(-1L) - 100000l));
			}

			if (command[1] == ':')
			{
				Dsetdrv((int)(toupper(command[0]) - 'A'));
			}
			system(command);
			Dsetdrv((int)stddrive);
		}
	}
	fclose(fd);
}


int getline()
{
	register char *p;
	register int   i;
	char	buffer[MAXLINE], *scanner(), *fgets();

	remark:
	if (fgets(buffer, sizeof buffer, fd) == NULL)
	{
		file_end = TRUE;
		return(FALSE);
	}

	if (*buffer == '#')
		goto remark;

	for (p = buffer, i = 0; i < 5; i++)
	{
		if ((p = scanner(tokv[i], p)) == (char *)NULL)
			return(FALSE);
	}

	strcpy(command,p);
	return(TRUE);
}


char *scanner(token, offset)
register char	*token;
register char	*offset;
{
	while ((*offset != ' ') && (*offset != '\t') && *offset)
		*token++ = *offset++;

	if (!*offset)
		return ((char *)NULL);

	*token = '\0';

	while ((*offset == ' ') || (*offset == '\t'))
		offset++;

	return (offset);
}


int match(left, right)
register char	*left;
register char	 right;
{
	register int	n;
	register char	c;

	n = 0;
	if (!strcmp(left, "*"))
		return(TRUE);

	while ((c = *left++) && (c >= '0') && (c <= '9'))
		n  =  (n * 10) + c - '0';

	switch (c)
	{
		case '\0':
			return (right == n);

		case ',':
		{
			if (right == n)
				return(TRUE);
			do {
				n = 0;
				while ((c = *left++) && (c >= '0') && (c <= '9'))
					n = (n * 10) + c - '0';
				if (right == n)
					return(TRUE);
				} while (c == ',');
			return(FALSE);
		}

		case '-':
		{
			if (right < n)
				return(FALSE);

			n = 0;
			while ((c = *left++) && (c >= '0') && (c <= '9'))
				n = (n * 10) + c - '0';

			return(right <= n);
		}
	}
}
