
/* internal structure defs for FILE structs and the code that hacks on them */

/* buffer size */

#define BUFSIZE 1024

struct file
	{
	unsigned char 	open_p;		/* 1-> this one's open */
	unsigned char	eof_p;		/* 1-> at eof */
	unsigned char	mode;		/* read and write mode bits */
	unsigned char	slush;
	unsigned short	handle;		/* the file_handle GEMDOS gave us */
	short		buf_index;	/* idx into buf; signed cause it can be
					   -1 when somebody ungetcs something */
	short		buf_max;	/* end of valid data in buf */
	unsigned long	file_position;	/* nbytes into file of buf */
	int		last_file_error; /* last error encountered */
	short		unchar_slush;	/* in case we unchar at begin buf */
	char		buf[BUFSIZE];	/* and the buffer */
	};

#define file_output_p(f)	\
	(((f->mode & 0x03) == O_WRONLY) || ((f->mode & 0x03) == O_RDWR))

#define file_input_p(f)	\
	(((f->mode & 0x03) == O_RDONLY) || ((f->mode & 0x03) == O_RDWR))

#define EOF -1
#define NULL 0

extern struct file * stdin;
extern struct file * stdout;
extern struct file * stderr;
