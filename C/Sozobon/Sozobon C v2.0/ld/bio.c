
/*
 * Copyright (c) 1991 by Sozobon, Limited.  Author: Johann Ruegg
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 */

#define MAXBF	5
#define BSIZE	1000

struct buf {
	struct buf *b_next;
	char b_bufr[BSIZE];
};

struct file {
	char *f_name;
	int f_fd;
	int f_flags;
	struct buf *f_first, *f_last;
	long f_fcount, f_rdoffs;
	int f_boffset;
	char f_bufr[BSIZE];
} f[MAXBF];
int numf = 0;
extern int vflag;

#define F_READING	1
#define F_FILEIO	2
#define F_LOCKED	4

t_open(s)
char *s;
{
	int i;

	if (numf >= MAXBF) {
		fatal("Too many b-files");
	}
	i = numf++;
	f[i].f_name = s;
	return i;
}

t_exit()
{
	int i;
	struct file *fp;

	for (i=0; i<numf; i++) {
		fp = &f[i];
		if (fp->f_flags & F_FILEIO)
#ifdef TOS
			remove(fp->f_name);
#else
			unlink(fp->f_name);
#endif
	}
	numf = 0;
}

t_frees()
{
	int i;
	struct file *fp;

	for (i=0; i<numf; i++) {
		fp = &f[i];
		if ((fp->f_flags & F_FILEIO) == 0 && fp->f_first) {
			t_freef(fp);
			return 1;
		}
	}
	return 0;
}

t_freef(fp)
struct file *fp;
{
	int fd;
	struct buf *bp, *t_dequeue();

	if (vflag) {
		printf("Using temp file for %s\n", fp->f_name);
	}

	fp->f_flags |= F_FILEIO;
	fd = open(fp->f_name, 2);
	if (fd < 0)
		fd = creat(fp->f_name, 0600);
	if (fd < 0)
		fatals("Cant open tmp file", fp->f_name);
	fp->f_fd = fd;
	while (fp->f_first) {
		bp = t_dequeue(fp);
		if (write(fd, bp->b_bufr, BSIZE) != BSIZE)
			fatal("write error");
		free(bp);
	}
	if (fp->f_flags & F_READING)
		lseek(fd, 0L, 0);
}

t_rewind(id)
{
	struct file *fp;
	int n;

	fp = &f[id];
	if (fp->f_flags & F_READING)
		fatal("t_rewind called twice");
	if (fp->f_boffset) {
		t_wfull(fp);
	}
	if (fp->f_flags & F_FILEIO)
		lseek(fp->f_fd, 0L, 0);
	fp->f_flags |= F_READING;
	if (fp->f_fcount)
		t_rfill(fp);
}

t_write(id, buf, cnt)
char *buf;
{
	struct file *fp;

	fp = &f[id];
	if (fp->f_flags & F_READING)
		fatal("write called while READING");
	while (cnt-- > 0)
		t_putc(fp, *buf++);
}

t_putc(fp, c)
struct file *fp;
char c;
{
	if (fp->f_boffset >= BSIZE)
		t_wfull(fp);
	fp->f_bufr[fp->f_boffset++] = c;
	fp->f_fcount++;
}

t_read(id, buf, cnt)
char *buf;
{
	char c;
	struct file *fp;

	fp = &f[id];
	if ((fp->f_flags & F_READING) == 0)
		fatal("read called while WRITING");
	while (cnt-- > 0) {
		c = t_getc(fp);
		*buf++ = c;
	}
}

t_getc(fp)
struct file *fp;
{
	if (fp->f_rdoffs >= fp->f_fcount)
		fatal("b-file read past end");
	if (fp->f_boffset >= BSIZE)
		t_rfill(fp);
	fp->f_rdoffs++;
	return fp->f_bufr[fp->f_boffset++];
}	

t_wfull(fp)
struct file *fp;
{
	char *malloc();
	int n;

	n = fp->f_boffset;
again:
	if (fp->f_flags & F_FILEIO) {
		if (write(fp->f_fd, fp->f_bufr, n) != n)
			fatal("write error");
		fp->f_boffset = 0;
	} else {
		struct buf *bp;

		bp = (struct buf *)malloc(sizeof(struct buf));
		if (!bp) {
			if (t_frees())
				goto again;
			fatal("out of memory");
		}
		bcopy(fp->f_bufr, bp->b_bufr, n);
		t_enqueue(fp, bp);
		fp->f_boffset = 0;
	}
}

t_enqueue(fp, bp)
struct file *fp;
struct buf *bp;
{
	bp->b_next = 0;
	if (fp->f_last) {
		fp->f_last->b_next = bp;
		fp->f_last = bp;
	} else {
		fp->f_first = fp->f_last = bp;
	}
}

struct buf *
t_dequeue(fp)
struct file *fp;
{
	struct buf *bp;

	bp = fp->f_first;
	if (!bp)
		fatal("internal buffer list error");
	fp->f_first = bp->b_next;
	if (fp->f_first == 0)
		fp->f_last = 0;
	return bp;
}

t_rfill(fp)
struct file *fp;
{
	int n;
	long l;

	if (fp->f_flags & F_FILEIO) {
		l = fp->f_fcount - fp->f_rdoffs;
		if (l > BSIZE)
			n = BSIZE;
		else
			n = l;
		if (read(fp->f_fd, fp->f_bufr, n) != n)
			fatal("read error");
		fp->f_boffset = 0;
	} else {
		struct buf *bp;

		bp = t_dequeue(fp);
		bcopy(bp->b_bufr, fp->f_bufr, BSIZE);
		free(bp);
		fp->f_boffset = 0;
	}
}
