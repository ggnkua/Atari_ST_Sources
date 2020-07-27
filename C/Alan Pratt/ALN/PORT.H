/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 88/08/23 14:20:42 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	port.h,v $
* Revision 1.1  88/08/23  14:20:42  apratt
* Initial revision
* 
* =======================================================================
*
* $Revision: 1.1 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/port.h,v $
* =======================================================================
*
*************************************************************************
*/
/*
 * PORT.H: portability functions between VAX and ST
 */

#if defined(VAX) || defined(ATARI_GCC)
#include <sys/file.h>	/* to get file open modes O_CREAT, O_READ, etc */
#define CREAT(name)		creat(name,0666)	/* likely mode */
#define OPEN(name,mode)		open(name,mode)
#define CLOSE(fd)		close(fd)
#define FSEEK(fd,amount,whence)	lseek(fd,amount,whence)
#define FTELL(fd)		(long)lseek(fd,0L,1)
#define READ(fd,buffer,count)	read(fd,buffer,(int)(count))
#define WRITE(fd,buffer,count)	write(fd,buffer,(int)(count))
#define UNLINK(file)		unlink(file)
extern long FSIZE();

#else /* not VAX */
#ifdef ATARIST
#include <osbind.h>
#define O_READ 1		/* OPEN mode flag */
#define CREAT(name)		Fcreate(name,0)		/* a useful mode */
#define OPEN(name,mode)		Fopen(name,mode)
#define CLOSE(desc)		Fclose(desc)
#define FSEEK(fd,amount,whence)	Fseek(amount,fd,whence)
#define FTELL(fd)		(long)Fseek(0L,fd,1)
#define READ(fd,buffer,count)	Fread(fd,(long)(count),buffer)
#define WRITE(fd,buffer,count)	Fwrite(fd,(long)(count),buffer)
#define UNLINK(file)		Fdelete(file)
extern long FSIZE();

#else /* neither VAX nor ATARIST */
#if 1+	/* deliberate syntax error: you must define ATARIST or VAX */
#endif /* end if 1+ */
#endif /* end if ATARIST */
#endif /* end if VAX */

