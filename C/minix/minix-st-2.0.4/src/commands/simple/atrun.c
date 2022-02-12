/* atrun - perform the work 'at' has squirreled away	Author: Jan Looyen */

/*-------------------------------------------------------------------------*
 *	atrun scans directory /usr/spool/at for 'at' jobs to be executed.  *
 *	Finished jobs have been moved to directory /usr/spool/at/past.     *
 *-------------------------------------------------------------------------*/

#include <sys/types.h>
#include <sys/dir.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <limits.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <dirent.h>

_PROTOTYPE(int main, (void));

int main()
{
  char realtime[15], procname[35], procpast[35];
  DIR *dir;
  struct dirent *entry;
  struct tm *p;
  struct stat sbuf;
  time_t clk;

/*-------------------------------------------------------------------------*
 *	Compute real time,  move 'at' jobs whose filenames < real time to  *
 *	/usr/spool/at/past and start a sh for each job.			   *
 *-------------------------------------------------------------------------*/
  time(&clk);
  p = localtime(&clk);
  sprintf(realtime, "%02d.%03d.%02d%02d.00",
	p->tm_year % 100, p->tm_yday, p->tm_hour, p->tm_min);
  if ((dir = opendir("/usr/spool/at")) != NULL)
	while ((entry = readdir(dir)) != NULL)
		if (entry->d_ino > 0 &&
		    entry->d_name[0] != '.' &&
		    entry->d_name[0] != 'p' &&
		strncmp(entry->d_name, realtime, (size_t) 11) <= 0) {

			sprintf(procname, "/usr/spool/at/%s", entry->d_name);
			sprintf(procpast, "/usr/spool/at/past/%s", entry->d_name);

			if (fork() == 0)	/* code for child */
				if (link(procname, procpast) == 0) {	/* link ok? */
					unlink(procname);
					stat(procpast, &sbuf);
					setgid(sbuf.st_gid);
					setuid(sbuf.st_uid);
					execl("/bin/sh", "sh", procpast, (char *) 0);
					fprintf(stderr, "proc %s can't start\n", procpast);
					exit(1);
				}
		}
  return(0);
}
