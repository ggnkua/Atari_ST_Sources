/* Cron - clock daemon.			Author: S.R. Sampson */

/*
 * cron		clock daemon.
 *		Cron is the clock daemon.  It is typically started up from
 *		the system initialization file (/etc/rc or /etc/inittab) by
 *		the INIT program.
 *
 *		If started by hand it must be done by the superuser.
 *
 *		Since it is a true daemon, cron automatically puts itself in
 *		the background, to release its control terminal.  If cron is
 *		used, it runs all day, spending most of its time asleep.
 *		Once a minute it wakes up and forks off a child which then
 *		examines /usr/lib/crontab to see if there are any commands to
 *		be executed. The format of this table is the same as in UNIX,
 *		except that % is not allowed to indicate 'new line'.
 *
 * Usage:	/usr/bin/cron
 *
 * Datafile:	/usr/lib/crontab
 *		Each crontab entry has six fields:
 *
 *		 minute hour day-of-month month day-of-week command
 *
 *		Each entry is checked in turn, and any entry matching the
 *		current time is executed.  The entry * matches anything.
 *
 * Version:	1.9	03/02/91
 *
 * Authors:	Steven R. Sampson, Fred van Kempen, Simmule Turner,
 *		Peter de Vrijer
 */
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <limits.h>
#include <signal.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/wait.h>
#include <stdio.h>

#define CRONTAB		"/usr/lib/crontab"
#define LOGFILE		"/usr/adm/cronlog"

#define SEPARATOR	" \t"
#define CRONSIZE	2048

typedef struct cron_entry {
  struct cron_entry	*next;
  char			*mn;
  char			*hr;
  char			*day;
  char			*mon;
  char			*wkd;
  char			*cmd;
} CRON;


static char *Version = "@(#) cron 1.9 (03/02/91)";


static char crontab[CRONSIZE];		/* memory for the entries	*/
static CRON *head, *entry_ptr;		/* crontab entry pointers	*/
static time_t prv_time = (time_t) 0;	/* timekeeper: previous wakeup	*/
static FILE *log, *logf;		/* FILE pointer to logfile	*/

_PROTOTYPE(int main, (int argc, char **argv));
_PROTOTYPE(void log_error, (char *error, ...));
_PROTOTYPE(void assign, (CRON *entry, char *line));
_PROTOTYPE(void load_crontab, (void));
_PROTOTYPE(int match, (char *left, int right));
_PROTOTYPE(void wakeup, (void));

/* Write a record to the log file. */
#ifdef __STDC__
void log_error(char *error, ...)
{
  va_list args;

  va_start (args, error);
  if ((logf = fopen(LOGFILE, "a")) != NULL) {
	vfprintf(logf, error, args);
	fclose(logf);
  }
  va_end(args);
}
#else
/* the K&R lib does not have vfprintf */
void log_error(error)
char *error;
{
  if ((logf = fopen(LOGFILE, "a")) != NULL) {
	fprintf(logf, error);
	fclose(logf);
  }
}
#endif


/* Assign the field values to the current crontab entry in core. */
void assign(entry, line)
CRON *entry;
char *line;
{
  entry->mn	= strtok(line, SEPARATOR);
  entry->hr	= strtok( (char *)NULL, SEPARATOR);
  entry->day	= strtok( (char *)NULL, SEPARATOR);
  entry->mon	= strtok( (char *)NULL, SEPARATOR);
  entry->wkd	= strtok( (char *)NULL, SEPARATOR);
  entry->cmd	= strchr(entry->wkd, '\0') + 1;
}


/* Read the on-disk crontab file into core. */
void load_crontab()
{
  int len, pos;
  FILE *cfp;
  struct stat buf;

  if (stat(CRONTAB, &buf)) {
	if (prv_time == (time_t) 0) fprintf(log, "Can't stat crontab\n");
	prv_time = (time_t) 0;
	return;
  }

  if (buf.st_mtime <= prv_time) return;

  if ((cfp = fopen(CRONTAB, "r")) == NULL) {
	if (prv_time == (time_t) 0) fprintf(log, "Can't open crontab\n");
	prv_time = (time_t) 0;
	return;
  }
  prv_time = buf.st_mtime;
  len = pos = 0;
  entry_ptr = head;

  while (fgets(&crontab[pos], CRONSIZE - pos, cfp) != NULL) {
	if (crontab[pos] == '#' || crontab[pos] == '\n') continue;
	len = strlen(&crontab[pos]);
	if (crontab[pos + len - 1] == '\n') {
		len--;
		crontab[pos + len] = '\0';
	}

	assign(entry_ptr, &crontab[pos]);

	if (entry_ptr->next == NULL) {
		entry_ptr->next = (CRON *)malloc(sizeof(CRON));
		entry_ptr->next->next = NULL;
	}
	entry_ptr = entry_ptr->next;
	pos += ++len;
	if (pos >= CRONSIZE) break;
  }
  (void) fclose(cfp);

  while (entry_ptr) {
	entry_ptr->mn = NULL;
	entry_ptr = entry_ptr->next;
  }
}


/*
 * This routine will match the left string with the right number.
 *
 * The string can contain the following syntax *
 *	*		This will return 1 for any number
 *	x,y [,z, ...]	This will return 1 for any number given.
 *	x-y		This will return 1 for any number within
 *			the range of x thru y.
 */
int match(left, right)
register char *left;
register int right;
{
  register int n;
  register char c;

  n = 0;
  if (!strcmp(left, "*")) return(1);

  while ((c = *left++) && (c >= '0') && (c <= '9')) n = (n * 10) + c - '0';

  switch (c) {
	case '\0':
		return(right == n);
		/*NOTREACHED*/
		break;
	case ',':
		if (right == n) return(1);
		do {
			n = 0;
			while ((c = *left++) && (c >= '0') && (c <= '9'))
				n = (n * 10) + c - '0';

			if (right == n) return(1);
		} while (c == ',');
		return(0);
		/*NOTREACHED*/
		break;
	case '-':
		if (right < n) return(0);
		n = 0;
		while ((c = *left++) && (c >= '0') && (c <= '9'))
			n = (n * 10) + c - '0';
		return(right <= n);
		/*NOTREACHED*/
		break;
	default:
		break;
  }
  return(0);
}


/* Wakeup from the sleep(), and check for any work. */
void wakeup()
{
  register struct tm *tm;
  time_t cur_time;
  CRON *this_entry;
  int st, pid;

  this_entry = head;
  load_crontab();

  time(&cur_time);
  tm = localtime(&cur_time);

  while (this_entry->next && this_entry->mn) {
	if (match(this_entry->mn, tm->tm_min) &&
	    match(this_entry->hr, tm->tm_hour) &&
	    match(this_entry->day, tm->tm_mday) &&
	    match(this_entry->mon, tm->tm_mon + 1) &&
	    match(this_entry->wkd, tm->tm_wday)) {
		fprintf(log, "%02d/%02d-%02d:%02d  %s\n",
			tm->tm_mon + 1, tm->tm_mday, tm->tm_hour, tm->tm_min,
							this_entry->cmd);
		if ((pid = fork()) == 0) {
			st = execl("/bin/sh", "/bin/sh", "-c",
						this_entry->cmd, (char *)NULL);
			log_error("EXEC failed with status = %d\n", st);
		} else {
			if (pid < 0)
				log_error("cron grandchild: Fork failed!\n\n");
		}
	}
	this_entry = this_entry->next;
  }
}


int main(argc, argv)
int argc;
char *argv[];
{
  register struct tm *tm;
  int status, i, pid;
  time_t clk;

  (void) chdir("/usr/adm");

  if ((status = fork()) < 0) {
	fprintf(stderr, "cron: cannot fork!\n");
	exit(1);
  } else if (status > 0) exit(0);

  /* We are now the child. Ignore ALL signals. */
  for (i = 1; i <= _NSIG; i++) signal(i, SIG_IGN);

  /* Attempt to free all open file descriptors (we mostly don't have any
   * files open, and reopen CRONTAB and LOGFILE as necessary).
   */
  for (i = 0; i < OPEN_MAX; i++) close(i);

  /* Create a logfile, appending to the previous one. */
  if ((log = fopen(LOGFILE, "a")) != NULL) {
	time(&clk);
	tm = localtime(&clk);  
	fprintf(log, "cron started at: %02d/%02d-%02d:%02d\n",
 		tm->tm_mon + 1, tm->tm_mday, tm->tm_hour, tm->tm_min);
	fclose(log);
  }

  entry_ptr = (CRON *)malloc(sizeof(CRON));
  entry_ptr->next = NULL;
  head = entry_ptr;

  /* The endless loop. */
  while (1) {
	/* Sleep till the next full minute */
	(void) time(&clk);
	sleep((unsigned) (60 - clk % 60));

	/*
	 * Now fork twice. The grandchild will run wakeup() .
	 * In that way cron will never have to wait longer than 
	 * a few seconds
	 */
	if ((pid = fork()) == 0) {
		/*
		 * This is the child, lets set the process group and
		 * fork again.  This is the way it should be done in
		 * a true daemon.
		 */
		/* setpgrp();*/ /* make this line a comment if not available */

		if ((pid = fork()) == 0) {
			/*
			 * This is the grandchild, it has to do all the
			 * work.  Set up standard file descriptors.  No
			 * files are open at this point, so their numbers
			 * will be 0, 1 and 2 as required.  Open the logfile
			 * if present, otherwise create it.
			 */
			(void) open("/dev/null", O_RDWR);
			if ((log = fopen(LOGFILE, "a")) != NULL) {
				setbuf(log, (char *)NULL);
				(void) dup(fileno(log));
			} else {
				(void) dup(0);
				(void) dup(0);
			}

			wakeup();

			/* The grandchild has to do an exit() also. */
			exit(0);
		} else {
			/*
			 * Here we are still the child, check if everything
			 * is ok. In any case we do an exit.
			 */
			if (pid < 0) {
			    log_error("cron: fork of grandchild failed\n");
			}
			exit(0);
		}
	} else {
		/* This is the parent. */
		if (pid < 0) {
			log_error("cron: fork of child failed.\n");
		} else {
			/* Wait for the child to change process group. */
			while (wait( (int *)NULL ) != pid);
		}
	}
  }
}
