#include <stdio.h>
#include <signal.h>
#include <sgtty.h>
#include <stdlib.h>

extern char **envptr;
static char *shellp = (char *)NULL;

void do_shell()
{
    register int pid, wpid;
    register void (*oqsig)(), (*oisig)(), (*otsig)();
    register int fd = fileno(stdin);
    register int ofd;
    int	status;
    struct sgttyb con, con_save;
    
    if (shellp == (char *)NULL)
    {
	shellp = getenv("SHELL");
	if (shellp == (char *)NULL)
	    shellp = "/bin/sh";
    }

    if(ioctl(fd, TIOCGETP, &con) == EOF)
    {
	perror("console");
	return;
    }
    if((ofd = open("/dev/tty", 1)) < 0)
    {
	perror("console stdout");
	return;
    }
    
    con_save = con;
    con.sg_flags &= ~RAW;
    con.sg_flags |= ECHO;
    if(ioctl(fd, TIOCSETP, &con) == EOF)
    {
	perror("console");
	close(ofd);
	return;
    }
    
    oqsig = signal(SIGQUIT, SIG_IGN);
    oisig = signal(SIGINT,  SIG_IGN);
    otsig = signal(SIGTERM,  SIG_IGN);
    if ((pid=fork()) < 0)
    {
	(void) signal(SIGQUIT, oqsig);	
	(void) signal(SIGINT,  oisig);
	(void) signal(SIGTERM, otsig);
	(void)ioctl(fd, TIOCSETP, &con_save);
	close(ofd);
	fprintf(stderr, "Failed to create process");
	return;
    }
    if (pid == 0)
    {
	/* stdout is comm line, re-dir to console */
	close(fileno(stdout));
	dup(ofd);
	execle(shellp, "sh", "-i", (char *)NULL, envptr);
	exit(0);		/* Should do better!	*/
    }
    while ((wpid=wait(&status))>=0 && wpid!=pid)
	;
    (void) signal(SIGQUIT, oqsig);
    (void) signal(SIGINT,  oisig);
    (void) signal(SIGTERM, otsig);
    close(ofd);
    (void)ioctl(fd, TIOCSETP, &con_save);
}
