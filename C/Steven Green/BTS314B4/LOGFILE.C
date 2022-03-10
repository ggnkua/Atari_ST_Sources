/*
 * logfile.c
 *
 * Things concerning the log file
 */

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <time.h>
#include <string.h>
#include <stdarg.h>

#include "bink.h"
#include "logfile.h"
#include "sbuf.h"
#include "externs.h"
#include "msgs.h"
#include "vfossil.h"
#include "zmodem.h"

/*--------------------------------
 * Global variables
 */

int loglevel = 6;			/* How much stuff to log */
BOOLEAN debugging_log = 0;	/* We are in debugging mode */

/*--------------------------------
 * Static Data
 */

static char *log_name = NULL;		/* Name of log file */
static FILE *status_log = NULL;		/* File Handle */
static BOOLEAN need_update = 0;
static long loglength = 0;			/* Maximum size of logfile (0=infinite) */

static char *specifiers = "!*+:# >";
static struct tm *tp;
static time_t ltime;

#define lINELENGTH 120				/* Maximum statuslog line length */

#define real_flush(n)				/* empty function! */

/*--------------------------------
 * Functions
 */

static void fill_in_status(char *stat_line)
{

	time (&ltime);
	tp = localtime (&ltime);
	if (fullscreen)
	{
		sb_scrl (callwin, 1);
		sb_move (callwin, SB_ROWS - 15, 2);
		sb_puts (callwin, stat_line);
		sb_move (settingswin, SET_TIME_ROW, SET_TIME_COL);
		sprintf (junk, "%s %s %02d @ %02d:%02d",
				wkday[tp->tm_wday], mtext[tp->tm_mon], tp->tm_mday,
				tp->tm_hour, tp->tm_min);
		sb_puts (settingswin, (unsigned char *) junk);
		sb_show ();
	}
}

#if 0
void clear_statusline (void)
{
   if (fullscreen)
	  sb_fillc (callwin, ' ');
}
#endif

/*
 * Put text into the logfile, used just like printf()
 */

void status_line (char *fmt,...)
{
	va_list arg_ptr;

#ifdef Snoop
	char tmp[255];
#define e_input tmp
#endif /* Snoop */

	va_start (arg_ptr, fmt);
	vsprintf (e_input, fmt, arg_ptr);
	time (&ltime);
	tp = localtime (&ltime);

    if(e_input[0] != '>')
    {
		if (!sb_inited || !fullscreen || !un_attended)
		{
				printf ("\n%c %02i %03s %02i:%02i:%02i BINK %s", e_input[0],
					 tp->tm_mday, mtext[tp->tm_mon], tp->tm_hour, tp->tm_min, tp->tm_sec,
							&e_input[1]);
		}
		else
		{
				char stat_line[256];

				sprintf (stat_line, stat_str, e_input[0],
							tp->tm_hour, tp->tm_min, tp->tm_sec, &e_input[1]);

				fill_in_status (stat_line);

#ifdef OS_2
#ifdef Snoop
				if(hsnoop)
					SnoopWrite(hsnoop, stat_line);
#endif /* Snoop */
#endif /* OS_2	*/
		}
	}
	if ((status_log != NULL) &&
	   (debugging_log ||
		 ((strchr (specifiers, e_input[0]) - strchr (specifiers, '!')) <= loglevel)))
	{
		fprintf (status_log, "%c %02i %s %02i:%02i:%02i BINK %s\n", e_input[0],
			 tp->tm_mday, mtext[tp->tm_mon], tp->tm_hour, tp->tm_min, tp->tm_sec,
					&e_input[1]);
		if (immed_update)
		{
			fflush (status_log);
			real_flush (fileno (status_log));
			need_update = FALSE;
		}
		else
		{
			need_update = TRUE;
		}
	}
	va_end (arg_ptr);
}

/*
 * trim the logfile to max length
 */

static void trim_log(void)
{
	if(status_log && loglength)
	{
		long len;

		fflush(status_log);
		fseek(status_log, 0L, SEEK_END);
		len = ftell(status_log);
		if(len >= loglength)
		{
			FILE *fpin, *fpout;
			int c;
			char name[FMSIZE];
			char *s;
			long newlen = loglength - loglength/4;
			char *buffer;
			size_t buflen;
			size_t copylen;

			buffer = malloc(buflen = 16384);	/* Use 16K buffer */
			if(!buffer)
			{
#ifdef DEBUG
				status_line(">log_trim: Couldn't allocate memory for buffer");
#endif
				return;
			}

			fclose(status_log);
			status_log = NULL;

#ifdef DEBUG
			status_line(">Trimming logfile to %ld bytes", newlen);
#endif

			
			fpin = fopen(log_name, read_ascii);
			if(!fpin)
			{
#ifdef DEBUG
				status_line(">log_trim: Couldn't reopen %s for reading!", log_name);
#endif
				goto openit;
			}
#if 0
			setvbuf(fpin, NULL, _IOFBF, 8192);	/* Use 8K buffer */
#endif

			len -= newlen;			/* Get position in file we want */
			fseek(fpin, len, SEEK_SET);

			while( (c = fgetc(fpin)) != '\n')		/* Skip to next line */
				if(c == EOF)
				{
					fclose(fpin);
					goto openit;
				}

			strcpy(name, log_name);
			s = strrchr(name, '.');
			if(!s)
				s = name + strlen(name);
			strcpy(s, ".TMP");

			fpout = fopen(name, write_ascii);
			if(fpout)
			{
#if 0
				setvbuf(fpout, NULL, _IOFBF, 8192);		/* Use 8K buffer */
#endif
				errno = 0;	/* Clear errors */

#if 0
				while( (c = fgetc(fpin)) != EOF)
					fputc(c, fpout);
#else

				do
				{
					copylen = fread(buffer, 1, buflen, fpin);
					if(copylen > 0)
						fwrite(buffer, 1, copylen, fpout);
				} while(copylen > 0);

#endif
				fclose(fpin);
				fclose(fpout);

				if(errno)
				{
#ifdef DEBUG
					status_line(">log_trim: Error, leaving %s along", log_name);
#endif
					unlink(name);
				}
				else
				{
					unlink(log_name);
					rename(name, log_name);
				}
			}
			else
			{
#ifdef DEBUG
				status_line(">log_trim: Couldn't open temporary file '%s'", name);
#endif
				fclose(fpin);
			}

		openit:
			free(buffer);
			status_log = fopen(log_name, append_ascii);
		}


	}
}

/*
 * Open the logfile
 */

int open_log(void)
{
	if(status_log == NULL)
	{
		if(!log_name)
			log_name = strdup("binkley.log");

		if((status_log = fopen (log_name, append_ascii)) == NULL)
		{
			printf("\n%s\n", msgtxt[M_NO_LOGFILE]);
			return -1;
		}
		trim_log();
	}
	return 0;
}

/*
 * Close the logfile
 */

void close_log(void)
{
	if (status_log)
	{
		trim_log();
		fclose (status_log);
		status_log = NULL;
	}
}

/*
 * Initialise the logfile
 */

int init_log(char *name, long length)
{
	if(log_name)			/* Free existing name (if any) */
	{
		free(log_name);
		log_name = NULL;
	}
	close_log();			/* Close any existing file */

	log_name = strdup(name);
	loglength = length * 1024;

	if(open_log() < 0)
	{
		free(name);
		log_name = NULL;
		return -1;
	}
	else
	{
		fprintf(status_log,"\n");			/* Start it off with a CR */
		fflush(status_log);
		real_flush(fileno(status_log));
	}
	return 0;
}


/*
 * Flush the logfile
 */

void flush_log(void)
{
	fflush (status_log);
	real_flush (fileno (status_log));
	need_update = FALSE;
}

/*
 * Update the logfile if it needs it
 */

void update_log(void)
{
	if (need_update)
	{
		flush_log();
		/*
		trim_log();
		*/
	}
}

/*
 * Debug display used by zmodem
 *
 * Displays it into logfile and on top of screen
 */

#ifdef ZDEBUG
void show_debug_name (string)
char *string;
{
   int x, y;
   static char *filler = "                           ";

  if(debugging_log)
  {
   x = wherex ();
   y = wherey ();
   gotoxy (40, 0);
   scr_printf (string);
   scr_printf (&filler[strlen (string)]);
   gotoxy (x, y);
#ifdef NEW  /* ZDEBUG  22.06.1990 */
   status_line (">DEBUG: %s", string);
#endif
  }
}
#endif

