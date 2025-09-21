/*

	Copyright (C) 1988 Free Software Foundation

GNU tar is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY.  No author or distributor accepts responsibility to anyone
for the consequences of using it or for whether it serves any
particular purpose or works at all, unless he says so in writing.
Refer to the GNU tar General Public License for full details.

Everyone is granted permission to copy, modify and redistribute GNU tar,
but only under the conditions described in the GNU tar General Public
License.  A copy of this license is supposed to have been given to you
along with GNU tar so you can know your rights and responsibilities.  It
should be in a file named COPYING.  Among other things, the copyright
notice and this notice must be preserved on all copies.

In other words, go ahead and share GNU tar, but don't try to stop
anyone else from sharing it farther.  Help stamp out software hoarding!
*/

/*
 * Buffer management for tar.
 *
 * Written by John Gilmore, ihnp4!hoptoad!gnu, on 25 August 1985.
 *
 * @(#) buffer.c 1.28 11/6/87 - gnu
 */

#include <stdio.h>
#include <errno.h>
#ifdef atarist
#include <types.h>
#include <stat.h>
#include <string.h>
#else
#include <sys/types.h>		/* For non-Berkeley systems */
#include <sys/stat.h>
#endif

#include <signal.h>

#ifndef MSDOS
#include <sys/ioctl.h>
#ifndef USG
#include <sys/mtio.h>
#endif
#endif

#ifdef	MSDOS
# include <fcntl.h>
# include <process.h>
#else
# ifdef XENIX
#  include <sys/inode.h>
# endif
# include <sys/file.h>
#endif

#include "tar.h"
#include "port.h"
#include "rmt.h"

FILE *msg_file;		/* Either stdout or stderr:  The thing we write messages
			   (standard msgs, not errors) to.  Stdout unless we're
			   writing a pipe, in which case stderr */

#define	STDIN	0		/* Standard input  file descriptor */
#define	STDOUT	1		/* Standard output file descriptor */

#define	PREAD	0		/* Read  file descriptor from pipe() */
#define	PWRITE	1		/* Write file descriptor from pipe() */

#ifdef __GNU__
extern void	*malloc();
extern void	*valloc();
#else
extern char	*malloc();
extern char	*valloc();
#endif

extern char	*index(), *strcat();
extern char	*strcpy();

/*
 * V7 doesn't have a #define for this.
 */
#ifndef O_RDONLY
#define	O_RDONLY	0
#endif
#ifndef O_RDWR
#define O_RDWR		2
#endif
#ifndef O_CREAT
#define O_CREAT		0
#endif
#ifndef O_BINARY
#define O_BINARY	0
#endif

#define	MAGIC_STAT	105	/* Magic status returned by child, if
				   it can't exec.  We hope compress/sh
				   never return this status! */

void writeerror();
void readerror();
extern void finish_header();

/*
 * The record pointed to by save_rec should not be overlaid
 * when reading in a new tape block.  Copy it to record_save_area first, and
 * change the pointer in *save_rec to point to record_save_area.
 * Saved_recno records the record number at the time of the save.
 * This is used by annofile() to print the record number of a file's
 * header record.
 */
static union record **save_rec;
 union record record_save_area;
static long	    saved_recno;

/*
 * PID of child program, if f_compress or remote archive access.
 */
static int	childpid = 0;

/*
 * Record number of the start of this block of records
 */
long	baserec;

/*
 * Error recovery stuff
 */
static int	r_error_count;

/*
 * Have we hit EOF yet?
 */
static int	eof;

/* JF we're reading, but we just read the last record and its time to update */
extern time_to_start_writing;
int file_to_switch_to= -1;	/* If remote update, close archive, and use
				   this descriptor to write to */

static int volno = 1;		/* JF which volume of a multi-volume tape
				   we're on */

char *save_name = 0;		/* Name of the file we are currently writing */
long save_totsize;		/* total size of file we are writing.  Only
				   valid if save_name is non_zero */
long save_sizeleft;		/* Where we are in the file we are writing.
				   Only valid if save_name is non-zero */

int write_archive_to_stdout;

/* Used by fl_read and fl_write to store the real info about saved names */
static char real_s_name[NAMSIZ];
static long real_s_totsize;
static long real_s_sizeleft;

/*
 * Return the location of the next available input or output record.
 * Return NULL for EOF.  Once we have returned NULL, we just keep returning
 * it, to avoid accidentally going on to the next file on the "tape".
 */
union record *
findrec()
{
	if (ar_record == ar_last) {
		if (eof)
			return (union record *)NULL;	/* EOF */
		flush_archive();
		if (ar_record == ar_last) {
			eof++;
			return (union record *)NULL;	/* EOF */
		}
	}
	return ar_record;
}


/*
 * Indicate that we have used all records up thru the argument.
 * (should the arg have an off-by-1? XXX FIXME)
 */
void
userec(rec)
	union record *rec;
{
	while(rec >= ar_record)
		ar_record++;
	/*
	 * Do NOT flush the archive here.  If we do, the same
	 * argument to userec() could mean the next record (if the
	 * input block is exactly one record long), which is not what
	 * is intended.
	 */
	if (ar_record > ar_last)
		abort();
}


/*
 * Return a pointer to the end of the current records buffer.
 * All the space between findrec() and endofrecs() is available
 * for filling with data, or taking data from.
 */
union record *
endofrecs()
{
	return ar_last;
}


/*
 * Duplicate a file descriptor into a certain slot.
 * Equivalent to BSD "dup2" with error reporting.
 */
void
dupto(from, to, msg)
	int from, to;
	char *msg;
{
	int err;

	if (from != to) {
		(void) close(to);
		err = dup(from);
		if (err != to) {
			msg_perror("cannot dup %s",msg);
			exit(EX_SYSTEM);
		}
		(void) close(from);
	}
}

#ifdef MSDOS
void
child_open()
{
#ifdef atarist
	fprintf(stderr,"GEMDOS %s can't use compressed or remote archives\n",tar);
#else
	fprintf(stderr,"MSDOS %s can't use compressed or remote archives\n",tar);
#endif
	exit(EX_ARGSBAD);
}
#else
void
child_open()
{
	int pipe[2];
	int err = 0;

	int kidpipe[2];
	int kidchildpid;

	void ck_pipe();
	void ck_close();

#define READ	0
#define WRITE	1

	ck_pipe(pipe);

	childpid=fork();
	if(childpid<0) {
		msg_perror("cannot fork");
		exit(EX_SYSTEM);
	}
	if(childpid>0) {
		/* We're the parent.  Clean up and be happy */
		/* This, at least, is easy */

		if(ar_reading) {
			f_reblock++;
			archive=pipe[READ];
			ck_close(pipe[WRITE]);
		} else {
			archive = pipe[WRITE];
			ck_close(pipe[READ]);
		}
		return;
	}

	/* We're the kid */
	if(ar_reading)
		dupto(pipe[WRITE],STDOUT,"(child) pipe to stdout");
	else
		dupto(pipe[READ],STDIN,"(child) pipe to stdin");
	/* ck_close(pipe[READ]);
	ck_close(pipe[WRITE]);*/

	/* We need a child tar only if
	   1: we're reading/writing stdin/out (to force reblocking)
	   2: the file is to be accessed by rmt (compress doesn't know how
	   3: the file is not a plain file */
#ifdef NO_REMOTE
	if(!(ar_file[0]=='-' && ar_file[1]=='\0') && isfile(ar_file))
#else
	if(!(ar_file[0]=='-' && ar_file[1]=='\0') && !_remdev(ar_file) && isfile(ar_file))
#endif
	{
		/* We don't need a child tar.  Open the archive */
		if(ar_reading) {
			archive=open(ar_file, O_RDONLY|O_BINARY, 0666);
			if(archive<0) {
				msg_perror("can't open archive %s",ar_file);
				exit(EX_BADARCH);
			}
			dupto(archive,STDIN,"archive to stdin");
			/* close(archive); */
		} else {
			archive=creat(ar_file,0666);
			if(archive<0) {
				msg_perror("can't open archive %s",ar_file);
				exit(EX_BADARCH);
			}
			dupto(archive,STDOUT,"archive to stdout");
			/* close(archive); */
		}
	} else {
		/* We need a child tar */
		ck_pipe(kidpipe);

		kidchildpid=fork();
		if(kidchildpid<0) {
			msg_perror("child can't fork");
			exit(EX_SYSTEM);
		}

		if(kidchildpid>0) {
			/* About to exec compress:  set up the files */
			if(ar_reading) {
				dupto(kidpipe[READ],STDIN,"((child)) pipe to stdin");
				ck_close(kidpipe[WRITE]);
				/* dup2(pipe[WRITE],STDOUT); */
			} else {
				/* dup2(pipe[READ],STDIN); */
				dupto(kidpipe[WRITE],STDOUT,"((child)) pipe to stdout");
				ck_close(kidpipe[READ]);
			}
			/* ck_close(pipe[READ]); */
			/* ck_close(pipe[WRITE]); */
			/* ck_close(kidpipe[READ]);
			ck_close(kidpipe[WRITE]); */
		} else {
		/* Grandchild.  Do the right thing, namely sit here and
		   read/write the archive, and feed stuff back to compress */
			tar="tar (child)";
			if(ar_reading) {
				dupto(kidpipe[WRITE],STDOUT,"[child] pipe to stdout");
				ck_close(kidpipe[READ]);
			} else {
				dupto(kidpipe[READ],STDIN,"[child] pipe to stdin");
				ck_close(kidpipe[WRITE]);
			}

			if (ar_file[0] == '-' && ar_file[1] == '\0') {
				if (ar_reading)
					archive = STDIN;
				else
					archive = STDOUT;
			} else /* This can't happen if (ar_reading==2)
				archive = rmtopen(ar_file, O_RDWR|O_CREAT|O_BINARY, 0666);
			else */if(ar_reading)
				archive = rmtopen(ar_file, O_RDONLY|O_BINARY, 0666);
			else
				archive = rmtcreat(ar_file, 0666);

			if (archive < 0) {
				msg_perror("can't open archive %s",ar_file);
				exit(EX_BADARCH);
			}

			if(ar_reading) {
				for(;;) {
					char *ptr;
					int max,count;
		
					r_error_count = 0;
				error_loop:
					err=rmtread(archive, ar_block->charptr,(int)(blocksize));
					if(err<0) {
						readerror();
						goto error_loop;
					}
					if(err==0)
						break;
					ptr = ar_block->charptr;
					max = err;
					while(max) {
						count = (max<RECORDSIZE) ? max : RECORDSIZE;
						err=write(STDOUT,ptr,count);
						if(err!=count) {
							if(err<0) {
								msg_perror("can't write to compress");
								exit(EX_SYSTEM);
							} else
								msg("write to compress short %d bytes",count-err);
							count = (err<0) ? 0 : err;
						}
						ptr+=count;
						max-=count;
					}
				}
			} else {
				for(;;) {
					int n;
					char *ptr;
		
					n=blocksize;
					ptr = ar_block->charptr;
					while(n) {
						err=read(STDIN,ptr,(n<RECORDSIZE) ? n : RECORDSIZE);
						if(err<=0)
							break;
						n-=err;
						ptr+=err;
					}
						/* EOF */
					if(err==0) {
						blocksize-=n;
						err=rmtwrite(archive,ar_block->charptr,blocksize);
						if(err!=(blocksize))
							writeerror(err);
						blocksize+=n;
						break;
					}
					if(n) {
						msg_perror("can't read from compress");
						exit(EX_SYSTEM);
					}
					err=rmtwrite(archive, ar_block->charptr, (int)blocksize);
					if(err!=blocksize)
						writeerror(err);
				}
			}
		
			/* close_archive(); */
			exit(0);
		}
	}
		/* So we should exec compress (-d) */
	if(ar_reading)
		execlp("compress", "compress", "-d", (char *)0);
	else
		execlp("compress", "compress", (char *)0);
	msg_perror("can't exec compress");
	_exit(EX_SYSTEM);
}


/* return non-zero if p is the name of a directory */
isfile(p)
char *p;
{
	struct stat stbuf;

	if(stat(p,&stbuf)<0)
		return 1;
	if((stbuf.st_mode&S_IFMT)==S_IFREG)
		return 1;
	return 0;
}

#endif

#ifdef DONTDEF
/*
 * Fork a child to deal with remote files or compression.
 * If rem_host is zero, we are called only for compression.
 */
void
child_open(rem_host, rem_file)
	char *rem_host, *rem_file;
{

#ifdef	MSDOS
	fprintf(stderr,
#ifdef atarist
	  "MSDOS %s cannot deal with compressed or remote archives\n", tar);
#else
	  "MSDOS %s cannot deal with compressed or remote archives\n", tar);
#endif
	exit(EX_ARGSBAD);
#else

	int pipes[2];
	int err;
	struct stat arstat;
	char cmdbuf[1000];		/* For big file and host names */

	int other_pipes[2];	/* JF for remote update and Multivol */

	/* Create a pipe to talk to the child over */
	err = pipe(pipes);
	if (err < 0) {
		msg_perror ("cannot create pipe to child");
		exit(EX_SYSTEM);
	}

	if(cmd_mode==CMD_CAT || cmd_mode==CMD_UPDATE || cmd_mode==CMD_APPEND) {
		err=pipe(other_pipes);
		if(err<0) {
			msg_perror("cannot create a pipe");
			exit(EX_SYSTEM);
		}
	}

	/* Fork child process */
	childpid = fork();
	if (childpid < 0) {
		msg_perror("cannot fork");
		exit(EX_SYSTEM);
	}

	/*
	 * Parent process.  Clean up.
	 *
	 * We always close the archive file (stdin, stdout, or opened file)
	 * since the child will end up reading or writing that for us.
	 * Note that this may leave standard input closed.
	 * We close the child's end of the pipe since they will handle
	 * that too; and we set <archive> to the other end of the pipe.
	 *
	 * If reading, we set f_reblock since reading pipes or network
	 * sockets produces odd length data.
	 */
	if (childpid > 0) {
		if(f_multivol || cmd_mode==CMD_CAT || cmd_mode==CMD_UPDATE || cmd_mode==CMD_APPEND) {
			(void)close(other_pipes[PREAD]);
			file_to_switch_to=other_pipes[PWRITE];
		}
		(void) close (archive);
		if (ar_reading) {
			(void) close (pipes[PWRITE]);
			archive = pipes[PREAD];
			f_reblock++;
		} else {
			(void) close (pipes[PREAD]);
			archive = pipes[PWRITE];
		}
		return;
	}

	/*
	 * Child process.
	 */

	/* We can't do any of these to a compressed file, so it'd better
	   be remote */
	if(f_multivol || cmd_mode==CMD_UPDATE || cmd_mode==CMD_APPEND || cmd_mode==CMD_CAT) {
		char mode;

		(void) close(pipes[PREAD]);
		dupto(pipes[PWRITE],STDOUT,"(child) to stdout");
		(void) close(other_pipes[PWRITE]);
		dupto(other_pipes[PREAD],STDIN,"(child) to stdin");
		if(f_multivol)  {
			if(cmd_mode==CMD_CREATE)
				mode='c';
			else if(cmd_mode==CMD_DIFF || cmd_mode==CMD_LIST || cmd_mode==CMD_EXTRACT)
				mode='r';
			else mode='c';
		} else
			mode='c';

		(void) sprintf(cmdbuf,"rsh '%s' tar -S%c -b %d -f '%s'",rem_host,mode,blocking,rem_file);

		execlp("sh","sh","-c",cmdbuf,(char *)0);
		msg_perror("cannot exec sh");
		exit(MAGIC_STAT);
	}

	if (ar_reading) {
		/*
		 * Reading from the child...
		 *
		 * Close the read-side of the pipe, which our parent will use.
		 * Move the write-side of pipe to stdout,
		 * If local, move archive input to child's stdin,
		 * then run the child.
		 */
		(void) close (pipes[PREAD]);
		dupto(pipes[PWRITE], STDOUT, "to stdout");
		if (rem_host) {
			(void) close (STDIN);	/* rsh abuses stdin */
			if (STDIN != open("/dev/null"))
				msg_perror("Can't open /dev/null");
			(void) sprintf(cmdbuf,
				"rsh '%s' dd '<%s' bs=%db",
				rem_host, rem_file, blocking);
			if (f_compress)
				strcat(cmdbuf, "| compress -d");
#ifdef DEBUG
			fprintf(stderr, "Exec-ing: %s\n", cmdbuf);
#endif
			execlp("sh", "sh", "-c", cmdbuf, (char *)0);
			msg_perror("cannot exec sh");
		} else {
			/*
			 * If we are reading a disk file, compress is OK;
			 * otherwise, we have to reblock the input in case it's
			 * coming from a tape drive.  This is an optimization.
			 */
			dupto(archive, STDIN, "to stdin");
			err = fstat(STDIN, &arstat);
			if (err != 0) {
				msg_perror("can't fstat archive");
				exit(EX_SYSTEM);
			}
			if ((arstat.st_mode & S_IFMT) == S_IFREG) {
				execlp("compress", "compress", "-d", (char *)0);
				msg_perror("cannot exec compress");
			} else {
				/* Non-regular file needs dd before compress */
				(void) sprintf(cmdbuf,
					"dd bs=%db | compress -d",
					blocking);
#ifdef DEBUG
				fprintf(stderr, "Exec-ing: %s\n", cmdbuf);
#endif
				execlp("sh", "sh", "-c", cmdbuf, (char *)0);
				msg_perror("cannot exec sh");
			}
		}
		exit(MAGIC_STAT);
	} else {
		/*
		 * Writing archive to the child.
		 * It would like to run either:
		 *	compress
		 *	compress |            dd obs=20b
		 *		   rsh 'host' dd obs=20b '>foo'
		 * or	compress | rsh 'host' dd obs=20b '>foo'
		 *
		 * We need the dd to reblock the output to the
		 * user's specs, if writing to a device or over
		 * the net.  However, it produces a stupid
		 * message about how many blocks it processed.
		 * Because the shell on the remote end could be just
		 * about any shell, we can't depend on it to do
		 * redirect stderr properly for us -- the csh
		 * doesn't use the same syntax as the Bourne shell.
		 * On the other hand, if we just ignore stderr on
		 * this end, we won't see errors from rsh, or from
		 * the inability of "dd" to write its output file.
		 * The combination of the local sh, the rsh, the
		 * remote csh, and maybe a remote sh conspires to mess
		 * up any possible quoting method, so grumble! we
		 * punt and just accept the fucking "xxx blocks"
		 * messages.  The real fix would be a "dd" that
		 * would shut up.
		 *
		 * Close the write-side of the pipe, which our parent will use.
		 * Move the read-side of the pipe to stdin,
		 * If local, move archive output to the child's stdout.
		 * then run the child.
		 */
		(void) close (pipes[PWRITE]);
		dupto(pipes[PREAD], STDIN, "to stdin");
		if (!rem_host)
			dupto(archive, STDOUT, "to stdout");

		cmdbuf[0] = '\0';
		if (f_compress) {
			if (!rem_host) {
				err = fstat(STDOUT, &arstat);
				if (err != 0) {
					msg_perror("can't fstat archive");
					exit(EX_SYSTEM);
				}
				if ((arstat.st_mode & S_IFMT) == S_IFREG) {
					execlp("compress", "compress", (char *)0);
					msg_perror("cannot exec compress");
					_exit(EX_SYSTEM);
				}
			}
			strcat(cmdbuf, "compress | ");
		}
		if (rem_host) {
			(void) sprintf(cmdbuf+strlen(cmdbuf),
			  "rsh '%s' dd obs=%db '>%s'",
				 rem_host, blocking, rem_file);
		} else {
			(void) sprintf(cmdbuf+strlen(cmdbuf),
				"dd obs=%db",
				blocking);
		}
#ifdef DEBUG
		fprintf(stderr, "Exec-ing: %s\n", cmdbuf);
#endif
		execlp("sh", "sh", "-c", cmdbuf, (char *)0);
		msg_perror("cannot exec sh");
		exit(MAGIC_STAT);
	}
#endif	/* MSDOS */
}

#endif

/*
 * Open an archive file.  The argument specifies whether we are
 * reading or writing.
 */
/* JF if the arg is 2, open for reading and writing. */
open_archive(reading)
	int reading;
{
	msg_file = stdout;

/* #ifndef MSDOS */
#ifdef DonTDeF
	/* JF Not doing this on MSdos systems looks like a good idea.
	   Does this stuff about 'slash' mean I can't simply say
	   remotesys:iggy to store it in 'iggy' on remotesys?  Do I
	   have to say remotesys:./iggy in order for it to work?
	   Who knows??  */
	colon = index(ar_file, ':');
	if (colon) {
		slash = index(ar_file, '/');
		if (slash && slash > colon) {
			/*
			 * Remote file specified.  Parse out separately,
			 * and don't try to open it on the local system.
			 */
			rem_file = colon + 1;
			rem_host = ar_file;
			*colon = '\0';
			goto gotit;
		}
	}
#endif

	if (blocksize == 0) {
		msg("invalid value for blocksize");
		exit(EX_ARGSBAD);
	}

	/*NOSTRICT*/
	if(f_multivol) {
		ar_block = (union record *) valloc((unsigned)(blocksize+(2*RECORDSIZE)));
		if(ar_block)
			ar_block += 2;
	} else
		ar_block = (union record *) valloc((unsigned)blocksize);
	if (!ar_block) {
		msg("could not allocate memory for blocking factor %d",
			blocking);
		exit(EX_ARGSBAD);
	}

	ar_record = ar_block;
	ar_last   = ar_block + blocking;
	ar_reading = reading;

	if (f_compress) {
		if(reading==2 || f_verify) {
			msg("cannot update or verify compressed archives");
			exit(EX_ARGSBAD);
		}
		child_open();
		if(!reading && ar_file[0]=='-' && ar_file[1]=='\0')
			msg_file = stderr;
		/* child_open(rem_host, rem_file); */
	} else if (ar_file[0] == '-' && ar_file[1] == '\0') {
		f_reblock++;	/* Could be a pipe, be safe */
		if(f_verify) {
			msg("can't verify stdin/stdout archive");
			exit(EX_ARGSBAD);
		}
		if(reading==2) {
			archive=STDIN;
			msg_file=stderr;
			write_archive_to_stdout++;
		} else if (reading)
			archive = STDIN;
		else {
			archive = STDOUT;
			msg_file = stderr;
		}
	} else if (reading==2 || f_verify) {
		archive = rmtopen(ar_file, O_RDWR|O_CREAT|O_BINARY, 0666);
	} else if(reading) {
		archive = rmtopen(ar_file, O_RDONLY|O_BINARY, 0666);
	} else {
		archive = rmtcreat(ar_file, 0666);
	}

	if (archive < 0) {
		msg_perror("can't open %s",ar_file);
		exit(EX_BADARCH);
	}
#ifdef	MSDOS
	setmode(archive, O_BINARY);
#endif

	if (reading) {
		ar_last = ar_block;		/* Set up for 1st block = # 0 */
		(void) findrec();		/* Read it in, check for EOF */

		if(f_volhdr) {
			union record *head;
			char *ptr;

			if(f_multivol) {
				ptr=malloc(strlen(f_volhdr)+20);
				sprintf(ptr,"%s Volume %d",f_volhdr,1);
			} else
				ptr=f_volhdr;
			head=findrec();
			if(!head)
				exit(EX_BADARCH);
			if(strcmp(ptr,head->header.name)) {
				msg("Volume mismatch!  %s!=%s\n",ptr,head->header.name);
				exit(EX_BADARCH);
			}
			if(ptr!=f_volhdr)
				free(ptr);
		}
	} else if(f_volhdr) {
		bzero((void *)ar_block,RECORDSIZE);
		if(f_multivol)
			sprintf(ar_block->header.name,"%s Volume 1",f_volhdr);
		else
			strcpy(ar_block->header.name,f_volhdr);
		ar_block->header.linkflag = LF_VOLHDR;
		finish_header(ar_block);
		/* ar_record++; */
	}
}


/*
 * Remember a union record * as pointing to something that we
 * need to keep when reading onward in the file.  Only one such
 * thing can be remembered at once, and it only works when reading
 * an archive.
 *
 * We calculate "offset" then add it because some compilers end up
 * adding (baserec+ar_record), doing a 9-bit shift of baserec, then
 * subtracting ar_block from that, shifting it back, losing the top 9 bits.
 */
saverec(pointer)
	union record **pointer;
{
	long offset;

	save_rec = pointer;
	offset = ar_record - ar_block;
	saved_recno = baserec + offset;
}

/*
 * Perform a write to flush the buffer.
 */

/*send_buffer_to_file();
  if(new_volume) {
  	deal_with_new_volume_stuff();
	send_buffer_to_file();
  }
 */

fl_write()
{
	int err;
	int copy_back;
	extern int errno;
#ifdef TEST
	static long test_written = 0;
#endif

#ifdef TEST
	if(test_written>=30720) {
		errno = ENOSPC;
		err = 0;
	} else
#endif
	err = rmtwrite(archive, ar_block->charptr,(int) blocksize);
	if(err!=blocksize && !f_multivol)
		writeerror(err);

#ifdef TEST
	if(err>0)
		test_written+=err;
#endif
	if (err == blocksize) {
		if(f_multivol) {
			if(!save_name) {
				real_s_name[0]='\0';
				real_s_totsize=0;
				real_s_sizeleft = 0;
				return;
			}
#ifdef MSDOS
			if(save_name[1]==':')
				save_name+=2;
#endif
			while(*save_name=='/')
				save_name++;

			strcpy(real_s_name,save_name);
			real_s_totsize = save_totsize;
			real_s_sizeleft = save_sizeleft;
		}
		return;
	}

#ifndef atarist /* ENOSPC isn't available under GEMDOS; punt */
	/* We're multivol  Panic if we didn't get the right kind of response */
	if(err>0 || (errno!=ENOSPC && errno!=EIO))
		writeerror(err);
#endif

	if(new_volume(0)<0)
		return;
#ifdef TEST
	test_written=0;
#endif
	if(f_volhdr && real_s_name[0]) {
		copy_back=2;
		ar_block-=2;
	} else if(f_volhdr || real_s_name[0]) {
		copy_back = 1;
		ar_block--;
	} else
		copy_back = 0;
	if(f_volhdr) {
		bzero((void *)ar_block,RECORDSIZE);
		sprintf(ar_block->header.name,"%s Volume %d",f_volhdr,volno);
		ar_block->header.linkflag = LF_VOLHDR;
		finish_header(ar_block);
	}
	if(real_s_name[0]) {
		extern void to_oct();
		int tmp;

		if(f_volhdr)
			ar_block++;
		bzero((void *)ar_block,RECORDSIZE);
		strcpy(ar_block->header.name,real_s_name);
		ar_block->header.linkflag = LF_MULTIVOL;
		to_oct((long)real_s_sizeleft,1+12,
		       ar_block->header.size);
		to_oct((long)real_s_totsize-real_s_sizeleft,
		       1+12,ar_block->header.offset);
		tmp=f_verbose;
		f_verbose=0;
		finish_header(ar_block);
		f_verbose=tmp;
		if(f_volhdr)
			ar_block--;
	}

	err = rmtwrite(archive, ar_block->charptr,(int) blocksize);
	if(err!=blocksize)
		writeerror(err);

#ifdef TEST
	test_written = blocksize;
#endif
	if(copy_back) {
		ar_block+=copy_back;
		bcopy((void *)(ar_block+blocking-copy_back),
		      (void *)ar_record,
		      copy_back*RECORDSIZE);
		ar_record+=copy_back;

		if(real_s_sizeleft>=copy_back*RECORDSIZE)
			real_s_sizeleft-=copy_back*RECORDSIZE;
		else if((real_s_sizeleft+RECORDSIZE-1)/RECORDSIZE<=copy_back)
			real_s_name[0] = '\0';
		else {
#ifdef MSDOS
			if(save_name[1]==':')
				save_name+=2;
#endif
			while(*save_name=='/')
				save_name++;

			strcpy(real_s_name,save_name);
			real_s_sizeleft = save_sizeleft;
			real_s_totsize=save_totsize;
		}
		copy_back = 0;
	}
}

/* Handle write errors on the archive.  Write errors are always fatal */
/* Hitting the end of a volume does not cause a write error unless the write
*  was the first block of the volume */

void
writeerror(err)
int err;
{
	if (err < 0) {
		msg_perror("can't write to %s",ar_file);
		exit(EX_BADARCH);
	} else {
		msg("write to %s short %d bytes",ar_file,blocksize-err);
		exit(EX_BADARCH);
	}
}

/*
 * Handle read errors on the archive.
 *
 * If the read should be retried, readerror() returns to the caller.
 */
void
readerror()
{
#	define	READ_ERROR_MAX	10

	read_error_flag++;		/* Tell callers */

	msg_perror("read error on %s",ar_file);

	if (baserec == 0) {
		/* First block of tape.  Probably stupidity error */
		exit(EX_BADARCH);
	}

	/*
	 * Read error in mid archive.  We retry up to READ_ERROR_MAX times
	 * and then give up on reading the archive.  We set read_error_flag
	 * for our callers, so they can cope if they want.
	 */
	if (r_error_count++ > READ_ERROR_MAX) {
		msg("Too many errors, quitting.");
		exit(EX_BADARCH);
	}
	return;
}


/*
 * Perform a read to flush the buffer.
 */
fl_read()
{
	int err;		/* Result from system call */
	int left;		/* Bytes left */
	char *more;		/* Pointer to next byte to read */

	/*
	 * Clear the count of errors.  This only applies to a single
	 * call to fl_read.  We leave read_error_flag alone; it is
	 * only turned off by higher level software.
	 */
	r_error_count = 0;	/* Clear error count */

	/*
	 * If we are about to wipe out a record that
	 * somebody needs to keep, copy it out to a holding
	 * area and adjust somebody's pointer to it.
	 */
	if (save_rec &&
	    *save_rec >= ar_record &&
	    *save_rec < ar_last) {
		record_save_area = **save_rec;
		*save_rec = &record_save_area;
	}
	if(write_archive_to_stdout && baserec!=0) {
		err=rmtwrite(1, ar_block->charptr, blocksize);
		if(err!=blocksize)
			writeerror(err);
	}
	if(f_multivol) {
		if(save_name) {
			if(save_name!=real_s_name) {
#ifdef MSDOS
				if(save_name[1]==':')
					save_name+=2;
#endif
				while(*save_name=='/')
					save_name++;

				strcpy(real_s_name,save_name);
				save_name=real_s_name;
			}
			real_s_totsize = save_totsize;
			real_s_sizeleft = save_sizeleft;
				
		} else {
			real_s_name[0]='\0';
			real_s_totsize=0;
			real_s_sizeleft = 0;
		}
	}

error_loop:
	err = rmtread(archive, ar_block->charptr, (int)blocksize);
	if (err == blocksize)
		return;

	if (err < 0) {
		readerror();
		goto error_loop;	/* Try again */
	}

	if(err == 0 && f_multivol) {
		union record *head;

	try_volume:
		if(new_volume((cmd_mode==CMD_APPEND || cmd_mode==CMD_CAT || cmd_mode==CMD_UPDATE) ? 2 : 1)<0)
			return;
	vol_error:
		err = rmtread(archive, ar_block->charptr,(int) blocksize);
		if(err < 0) {
			readerror();
			goto vol_error;
		}
		if(err!=blocksize)
			goto short_read;

		head=ar_block;

		if(head->header.linkflag==LF_VOLHDR) {
			if(f_volhdr) {
				char *ptr;

				ptr=(char *)malloc(strlen(f_volhdr)+20);
				sprintf(ptr,"%s Volume %d",f_volhdr,volno);
 				if(strcmp(ptr,head->header.name)) {
					msg("Volume mismatch! %s!=%s\n",ptr,head->header.name);
					--volno;
					free(ptr);
					goto try_volume;
				}
				free(ptr);
			}
			if(f_verbose)
				fprintf(msg_file,"Reading %s\n",head->header.name);
			head++;
		} else if(f_volhdr) {
			msg("Warning:  No volume header!");
		}

		if(real_s_name[0]) {
			long from_oct();

			if(head->header.linkflag!=LF_MULTIVOL || strcmp(head->header.name,real_s_name)) {
				msg("%s is not continued on this volume!",real_s_name);
				--volno;
				goto try_volume;
			}
			if(real_s_totsize!=from_oct(1+12,head->header.size)+from_oct(1+12,head->header.offset)) {
				msg("%s is the wrong size (%ld!=%ld+%ld)",
				       head->header.name,save_totsize,
				       from_oct(1+12,head->header.size),
				       from_oct(1+12,head->header.offset));
				--volno;
				goto try_volume;
			}
			if(real_s_totsize-real_s_sizeleft!=from_oct(1+12,head->header.offset)) {
				msg("This volume is out of sequence");
				--volno;
				goto try_volume;
			}
			head++;
		}
		ar_record=head;
		return;
	}

 short_read:
	more = ar_block->charptr + err;
	left = blocksize - err;

again:
	if (0 == (((unsigned)left) % RECORDSIZE)) {
		/* FIXME, for size=0, multi vol support */
		/* On the first block, warn about the problem */
		if (!f_reblock && baserec == 0 && f_verbose && err > 0) {
			msg("Blocksize = %d record%s",
				err / RECORDSIZE, (err > RECORDSIZE)? "s": "");
		}
		ar_last = ar_block + ((unsigned)(blocksize - left))/RECORDSIZE;
		return;
	}
	if (f_reblock) {
		/*
		 * User warned us about this.  Fix up.
		 */
		if (left > 0) {
error2loop:
			err = rmtread(archive, more, (int)left);
			if (err < 0) {
				readerror();
				goto error2loop;	/* Try again */
			}
			if (err == 0) {
				msg("archive %s EOF not no block boundry",ar_file);
				exit(EX_BADARCH);
			}
			left -= err;
			more += err;
			goto again;
		}
	} else {
		msg("only read %d byes from archive %s",err,ar_file);
		exit(EX_BADARCH);
	}
}


/*
 * Flush the current buffer to/from the archive.
 */
flush_archive()
{
	baserec += ar_last - ar_block;	/* Keep track of block #s */
	ar_record = ar_block;		/* Restore pointer to start */
	ar_last = ar_block + blocking;	/* Restore pointer to end */

	if (ar_reading) {
		if(time_to_start_writing) {
			time_to_start_writing=0;
			ar_reading=0;

			if(file_to_switch_to>=0) {
				rmtclose(archive);
				archive=file_to_switch_to;
			} else
	 			(void)backspace_output();
			fl_write();
		} else
			fl_read();
	} else {
		fl_write();
	}
}

/* Backspace the archive descriptor by one blocks worth.
   If its a tape, MTIOCTOP will work.  If its something else,
   we try to seek on it.  If we can't seek, we lose! */
backspace_output()
{
	long cur;
	/* int er; */
	extern char *output_start;
	extern int errno;

#ifdef MTIOCTOP
	struct mtop t;

	t.mt_op = MTBSR;
	t.mt_count = 1;
	if((rmtioctl(archive,MTIOCTOP,&t))>=0)
		return 1;
	if(errno==EIO && (rmtioctl(archive,MTIOCTOP,&t))>=0)
		return 1;
#endif

		cur=rmtlseek(archive,0L,1);
	cur-=blocksize;
	/* Seek back to the beginning of this block and
	   start writing there. */

	if(rmtlseek(archive,cur,0)!=cur) {
		/* Lseek failed.  Try a different method */
		msg("Couldn't backspace archive file.  It may be unreadable without -i.");
		/* Replace the first part of the block with nulls */
		if(ar_block->charptr!=output_start)
			bzero(ar_block->charptr,output_start-ar_block->charptr);
		return 2;
	}
	return 3;
}


/*
 * Close the archive file.
 */
close_archive()
{
	int child;
	int status;

	if (time_to_start_writing || !ar_reading)
		flush_archive();
	if(cmd_mode==CMD_DELETE) {
		long pos;

		pos = rmtlseek(archive,0L,1);
#ifndef MSDOS
		/* FIXME does ftruncate really take an INT?! */
		(void) ftruncate(archive,(int)pos);
#else
		(void)rmtwrite(archive,"",0);
#endif
	}
	if(f_verify)
		verify_volume();
	(void) rmtclose(archive);

#ifndef	MSDOS
	if (childpid) {
		/*
		 * Loop waiting for the right child to die, or for
		 * no more kids.
		 */
		while (((child = wait(&status)) != childpid) && child != -1)
			;

		if (child != -1) {
			switch (TERM_SIGNAL(status)) {
			case 0:
				/* Child voluntarily terminated  -- but why? */
				if (TERM_VALUE(status) == MAGIC_STAT) {
					exit(EX_SYSTEM);/* Child had trouble */
				}
				if (TERM_VALUE(status) == (SIGPIPE + 128)) {
					/*
					 * /bin/sh returns this if its child
					 * dies with SIGPIPE.  'Sok.
					 */
					break;
				} else if (TERM_VALUE(status))
					msg("child returned status %d",
						TERM_VALUE(status));
			case SIGPIPE:
				break;		/* This is OK. */

			default:
				msg("child died with signal %d%s",
				 TERM_SIGNAL(status),
				 TERM_COREDUMP(status)? " (core dumped)": "");
			}
		}
	}
#endif	/* MSDOS */
}


#ifdef DONTDEF
/*
 * Message management.
 *
 * anno writes a message prefix on stream (eg stdout, stderr).
 *
 * The specified prefix is normally output followed by a colon and a space.
 * However, if other command line options are set, more output can come
 * out, such as the record # within the archive.
 *
 * If the specified prefix is NULL, no output is produced unless the
 * command line option(s) are set.
 *
 * If the third argument is 1, the "saved" record # is used; if 0, the
 * "current" record # is used.
 */
void
anno(stream, prefix, savedp)
	FILE	*stream;
	char	*prefix;
	int	savedp;
{
#	define	MAXANNO	50
	char	buffer[MAXANNO];	/* Holds annorecment */
#	define	ANNOWIDTH 13
	int	space;
	long	offset;
	int	save_e;

	save_e=errno;
	/* Make sure previous output gets out in sequence */
	if (stream == stderr)
		fflush(stdout);
	if (f_sayblock) {
		if (prefix) {
			fputs(prefix, stream);
			putc(' ', stream);
		}
		offset = ar_record - ar_block;
		(void) sprintf(buffer, "rec %d: ",
			savedp?	saved_recno:
				baserec + offset);
		fputs(buffer, stream);
		space = ANNOWIDTH - strlen(buffer);
		if (space > 0) {
			fprintf(stream, "%*s", space, "");
		}
	} else if (prefix) {
		fputs(prefix, stream);
		fputs(": ", stream);
	}
	errno=save_e;
}
#endif

/* We've hit the end of the old volume.  Close it and open the next one */
/* Values for type:  0: writing  1: reading  2: updating */
new_volume(type)
int	type;
{
	/* int	c; */
	char	inbuf[80];
	char	*p;
	extern int now_verifying;
	char *getenv();

	if(now_verifying)
		return -1;
	if(f_verify)
		verify_volume();
	if(rmtclose(archive)<0) {
		msg_perror("can't close %s",ar_file);
		exit(EX_BADARCH);
	}
	volno++;
	for(;;) {
		fprintf(msg_file,"Prepare volume #%d and hit return: ",volno);
		if(fgets(inbuf,80,stdin)==0 || inbuf[0]=='\n')
			break;
		switch(inbuf[0]) {
		case '?':
			fprintf(msg_file,"\
 n [name]   Give a new filename for the next (and subsequent) volume(s)\n\
 q          Abort tar\n\
 !          Spawn a subshell\n\
 ?          Print this list\n");
			break;

		case 'q':	/* Quit */
			fprintf(msg_file,"No new volume; exiting.\n");
			if(cmd_mode!=CMD_EXTRACT && cmd_mode!=CMD_LIST && cmd_mode!=CMD_DIFF)
				msg("Warning:  Archive is INCOMPLETE!");
			exit(EX_BADARCH);

		case 'n':	/* Get new file name */
		{
			char *q,*r;
			static char *old_name;

			for(q= &inbuf[1];*q==' ' || *q=='\t';q++)
				;
			for(r=q;*r;r++)
				if(*r=='\n')
					*r='\0';
			if(old_name)
				free(old_name);
			old_name=p=(char *)malloc((unsigned)(strlen(q)+2));
			if(p==0) {
				msg("Can't allocate memory for name");
				exit(EX_SYSTEM);
			}
			(void) strcpy(p,q);
			ar_file=p;
			break;
		}

		case '!':
#ifdef MSDOS
# ifdef atarist
			spawnl(P_WAIT,getenv("SHELL"),NULL);
# else
			spawnl(P_WAIT,getenv("COMSPEC"),"-",0);
# endif
#else
				/* JF this needs work! */
			switch(fork()) {
			case -1:
				msg_perror("can't fork!");
				break;
			case 0:
				p=getenv("SHELL");
				if(p==0) p="/bin/sh";
				execlp(p,"-sh","-i",0);
				msg_perror("can't exec a shell %s",p);
				_exit(55);
			default:
				wait(0);
				break;
			}
#endif
			break;
		}
	}

	if(type==2 || f_verify)
		archive=rmtopen(ar_file,O_RDWR|O_CREAT,0666);
	else if(type==1)
		archive=rmtopen(ar_file,O_RDONLY,0666);
	else if(type==0)
		archive=rmtcreat(ar_file,0666);
	else
		archive= -1;

	if(archive<0) {
		msg_perror("can't open %s",ar_file);
		exit(EX_BADARCH);
	}
#ifdef MSDOS
	setmode(archive,O_BINARY);
#endif
	return 0;
}

/* this is a useless function that takes a buffer returned by wantbytes
   and does nothing with it.  If the function called by wantbytes returns
   an error indicator (non-zero), this function is called for the rest of
   the file.
 */
int
no_op(size,data)
int size;
char *data;
{
	return 0;
}

/* Some other routine wants SIZE bytes in the archive.  For each chunk of
   the archive, call FUNC with the size of the chunk, and the address of
   the chunk it can work with.
 */
int
wantbytes(size,func)
long size;
int (*func)();
{
	char *data;
	long	data_size;

	while(size) {
		data = findrec()->charptr;
		if (data == NULL) {	/* Check it... */
			msg("Unexpected EOF on archive file");
			return -1;
		}
		data_size = endofrecs()->charptr - data;
		if(data_size>size)
			data_size=size;
		if((*func)(data_size,data))
			func=no_op;
		userec((union record *)(data + data_size - 1));
		size-=data_size;
	}
	return 0;
}
