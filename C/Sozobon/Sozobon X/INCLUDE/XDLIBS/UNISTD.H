#ifndef _UNISTD_H
#define _UNISTD_H

/* see Posix standard -- 1003.1 sect 2.10 */

#ifndef F_OK
/* file access stuff: amode */
#define	F_OK			0
#define	X_OK			1
#define	W_OK			2
#define	R_OK			4
#endif

#ifndef SEEK_SET
/* lseek() : origin */
#define	SEEK_SET	0		/* from beginning of file */
#define	SEEK_CUR	1		/* from current location */
#define	SEEK_END	2		/* from end of file */
#endif


/* 1003.1 section 8.2.1.2 */
#define STDIN_FILENO	0
#define STDOUT_FILENO	1
#define STDERR_FILENO	2



extern	void _exit(int status);	/* don't use it but:	 */
extern	void exit(int status);

extern int	access(const char *name, int amode);
extern int	chdir(const char *pathname);
extern int	close(int handle);
extern int	dup(int handle);
extern int	dup2(int handle1, int handle2);

extern char	*getcwd(char *buffer, int size);

/* not a standard function */
extern void	cwd(char *buffer);

/* not a standard function */
int getopt(int argc, char **argv, char *optstring);

extern int	isatty(int handle);
extern long	lseek(int handle, long offset, int origin);

#if 0
/* not a standard function */
extern char *mktemp(char *pattern);
#endif

extern int	rmdir(const char *pathname);
extern int	read(int handle, void *data, unsigned length);

/* not a standard function */
extern long	lread(int handle, void *data, long length);

/* not a standard function */
extern unsigned sleep(unsigned int seconds);

/* not a standard function */
extern int	stime(long *rawtime);

/* not a standard function */
extern long	tell(int handle);

extern int unlink(char *filename);

extern int	write(int handle, const void *data, unsigned length);

/* not a standard function */
extern long	lwrite(int handle, const void *data, long length);


/* not a standard function */
extern void	usleep (unsigned long usec);

extern	int	getpid(void);
extern	int	getppid();

	/* defines for not implemeted functions	*/
#ifdef __MSHORT__
#define	getuid()	gemdos(0x10f)
#define	geteuid()	gemdos(0x138)
#define	getgid()	gemdos(0x114)
#define	getegid()	gemdos(0x139)

#define	kill(pid,sig)	(short)gemdos(0x111, (short)(pid), (short)sig)
#define	nice(delta)	(short)gemdos(0x10a, (short)(delta))
#define	pause()		(short)gemdos(0x121)
#define	alarm(sec)	gemdos(0x120, (long)sec)
#else
#include <osbind.h>
#define	getuid		Pgetuid
#define	geteuid		Pgeteuid
#define	getgid		Pgetgid
#define	getegid		Pgetegid

#define	kill(pid,sig)	Pkill((pid),(sig))
#define	nice(delta)	Pnice(delta)
#define	pause()		Pause()
#define	alarm(sec)	Talarm(sec)
#endif /* __MSHORT__ */

/* spawn:
 * run a child process executing a command <program>
 * same arguments as for standard exec functions
 */

int spawnl(char *program, char *arg0, ...);
int spawnv(char *program, char **argv);
int spawnlp(char *program, char *arg0, ...);
int spawnvp(char *program, char **argv);
int spawnle(char *program, char *arg0, ...);
int spawnlpe(char *program, char *arg0, ...);
int spawnve(char *program, char **argv, char **envp);
int spawnvpe(char *program, char **argv, char **envp);

	/* provided for compatibility with older versions, 
	 * although the names have changed!!
	 */
int spawnvep(char *program, **argv, *envp);
int spawnvpep(char *program, **argv, *envp);

/* not a standard function */
char *_conv_unixmode(char *buffer, char *path);

#if 0

	/* non existent	*/
int wait(int *rvp);
int fork(void);

#endif

#endif /* _UNISTD_H */
