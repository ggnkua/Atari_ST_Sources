/******************************************************************************
 *	Bio.c	Read and Write routines for files that are basically Block type
 ******************************************************************************
 *
 *	Modded T.Barnaby 17/5/85
 *		Bytecp() function added to copy data from and to buffer
 *		for speed.
 *		(bytecp() is in assembler in bytecp.68k).
 *
 *	Modded T.Barnaby 15-1-86
 *		b_write(), b_read(), and b_seek() altered to do appriate
 *		things for pipes.
 *	Modded T.Barnaby 15-5-86
 *		Additions for file events added.
 */

# include       <errno.h>
# include       "../include/param.h"
# include	"../include/signal.h"
# include       "../include/procs.h"
# include       "../include/buf.h"
# include       "../include/inode.h"
# include       "../include/file.h"
# include       "../include/dev.h"
# include	<sys/ioctl.h>

# define        B_READ          1
# define        B_WRITE         2

long curpos();

b_read(file, buffer, nbytes)
struct file *file;
char *buffer;
{
	char *cptr;
	int n, xfr_cnt, number;
	long charsleft;
	struct buf *b;

	xfr_cnt = 0;
	/* Checks file type */
	if (file->f_type == STD) {
		/* Checks if the file is a pipe */
		if(file->f_mode & PIPE){
			/* If so while there is no more data to read
			 * sleep until a write
			 * On the pipe wakesup this process.
			 * If the writeing process has died give up
			 * the goast.
			 */
			while((isize(file->f_inode) - curpos(file)) <= 0){
				if(!file->f_pipelink) break;
				/* Sleeps on the write pipes file table entry
				 * Waking up the write first
				 */
# ifdef TPIPES
printf("Read pipe about to sleep %d\n\r",cur_proc->pid);
# endif
				wakeup((caddr_t)file);
				sleep((caddr_t)file->f_pipelink, PPIPE);
# ifdef TPIPES
printf("Read pipe awoken isize %d %d\n\r",cur_proc->pid,isize(file->f_inode));
# endif

			}
		}
		/* limit read to stop at end of file or after */
		if ((charsleft = isize(file->f_inode) - curpos(file)) < 0)
			charsleft = 0;

		nbytes = (nbytes > charsleft)? charsleft: nbytes;
	}

	while (nbytes) {
		n = file->f_curblk;
		if (file->f_type == STD) {
			if ( !(n = physblk(n, file->f_inode, B_READ)))
				/* unallocated blocks read as nulls */
				n = -1;
		}

		/* Get into cache if not already there, if inode is single
		 * buffer mode then use last used buffer instead of the least
		 * used buffer.
		 */
		if(file->f_inode->i_flag & IONEBUF){
			b = getbuf(file->f_handler, file->f_dev, n, ONEBUF);
		}
		else b = getbuf(file->f_handler, file->f_dev, n, ALLBUF);

		/* If getbuf couldn't get block return error */
		if(b->b_flags == ABORT) return -1;

		cptr = &b->b_buf[file->f_curchar];

		if ((number=(BSIZE-file->f_curchar)) > nbytes) number = nbytes;
		bytecp(cptr,buffer,number);
		buffer+=number;
		nbytes-=number;
		xfr_cnt+=number;

		if ((file->f_curchar+=number) >= BSIZE){
			file->f_curchar = 0;
			file->f_curblk++;
		}
		/* Check for quit signals only could be a race hazard here !! */
		checkev(EVSIGQUIT);
	}

	/* If the file is a pipe and the end of the pipe buffers has been
	 * reached, truncate the inode, erasing the buffers and
	 * Set both the pipes read and writes file pointers to 0
	 * Wake up the writing process.
	 */
	if((file->f_mode & PIPE) && (file->f_curblk >= 8)){
# ifdef TPIPES
printf("Read trncating inode\n\r");
# endif
		itrunc(file->f_inode);
		file->f_curblk = 0;
		file->f_curchar = 0;
		if(file->f_pipelink){
			file->f_pipelink->f_curblk = 0;
			file->f_pipelink->f_curchar = 0;
		}
		wakeup((caddr_t)file);
	}
	
# ifdef TPIPES
if(file->f_mode & PIPE) printf("B_read finished %d %d\n\r",cur_proc->pid,xfr_cnt);
# endif

	return xfr_cnt;
}

b_write(file, buffer, nbytes)
struct file *file;
char *buffer;
{
	char *cptr;
	int n, xfr_cnt, number;
	struct buf *b;

	xfr_cnt = 0;
	while (nbytes){

		/* Check if file is a pipe */
		if(file->f_mode & PIPE){
			/* Checks if there is anyone reading the pipe */
			if(!file->f_pipelink){
				/* If not send the pipe signal */
# ifdef TPIPES
printf("Writting to a write only pipe %d\n\r",cur_proc->pid);
# endif
				sendsig(cur_proc->pid, SIGPIPE, 1);
				return error(EPIPE);
			}
			/* Check if end of pipe if so sleep untill ready */
			while(file->f_curblk >= 8){
				/* Sleeps on read file table entry
				 * Wakeing up the read process first
				 */
# ifdef TPIPES
printf("Write pipe sleeping %d\n\r",cur_proc->pid);
# endif
				wakeup((caddr_t)file);
				sleep((caddr_t)file->f_pipelink, PPIPE);
				/* Check if pipe was severed (nasty) */
				if(!file->f_pipelink){
# ifdef TPIPES
printf("Writting to a write only pipe %d\n\r",cur_proc->pid);
# endif
					sendsig(cur_proc->pid, SIGPIPE, 1);
					return error(EPIPE);
				}
			}
		}
		n = file->f_curblk;
		if (file->f_type == STD){
			if ( !(n = physblk(n, file->f_inode, B_WRITE)))
				/* No more free space */
				return error(ENOSPC);
		}

		/* Get into cache if not already there, if inode is single
		 * buffer mode then use last used buffer instead of the least
		 * used buffer.
		 */
		if(file->f_inode->i_flag & IONEBUF){
			b = getbuf(file->f_handler, file->f_dev, n, ONEBUF);
		}
		else b = getbuf(file->f_handler, file->f_dev, n, ALLBUF);

		/* If getbuf couldn't get block return number of bytes written*/
		if(b->b_flags == ABORT) return xfr_cnt;

		cptr = &b->b_buf[file->f_curchar];
		b->b_flags |= WRITE;

		if ((number=(BSIZE-file->f_curchar)) > nbytes) number = nbytes;
		bytecp(buffer,cptr,number);
		buffer += number;
		nbytes -= number;
		xfr_cnt += number;

		if ((file->f_curchar += number) >= BSIZE){
			file->f_curchar = 0;
			file->f_curblk++;
		}

		if (file->f_type == STD)
			/* if file is bigger now, change inode */
			iexpand(file->f_inode, curpos(file));

		/* Check for quit signals only */
/*		checkev(EVSIGQUIT); */
	}

	/* If the file is a pipe, wakeup the process waiting for
	 * the pipe to be written to, also signal any processes awaiting
	 * a read of the pipe event.
	 */
	if(file->f_mode & PIPE){
		wakeup((caddr_t)file);
#ifdef	EVENTSON
		fileevent(file->f_pipelink);
#endif	EVENTSON
	}

	return xfr_cnt;
}

/*
 * B_seek - perform a seek on a block-structured file.
 */
long
b_seek(file, pos, mode)
long pos;
struct file *file;
{
	long cur;

	/* Cannot seek on a pipe */
	if(file->f_mode & PIPE) return error(ESPIPE);

	cur = curpos(file);
	switch (mode){
	case 0:
		/* set to absolute position */
		cur = pos;
		break;

	case 1:
		/* set pointer to current + offset */
		cur += pos;
		break;

	case 2:
		/* set pointer to end + offset */
		cur = isize(file->f_inode) + pos;
	}

	if (cur >= 0){
		/* file is only physically expanded by a write, not here */
		file->f_curchar = cur & 0x1FF;
		file->f_curblk = cur >> 9;
	}
	else
		/* attempt to point before start of file */
		cur = -1;

	return cur;
}

/*
 * Curpos - returns current byte in a file.
 */
long
curpos(fptr)
struct file *fptr;
{

	return (( long )(fptr->f_curblk) << 9) | (fptr->f_curchar & 0x1FF);
}

/*
 *	B_ioctl()	Std file ioctl
 */
b_ioctl(file, request, argp)
struct	file *file;
int	*argp;
{
	/* If request is FIONREAD (ie number of bytes in file), return
	 * number of bytes in file.
	 */
	if(request == FIONREAD){
		*argp = (isize(file->f_inode) - curpos(file));
		return 0;
	}
	return -1;
}
