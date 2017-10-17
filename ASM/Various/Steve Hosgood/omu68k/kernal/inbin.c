/*******************************************************************************
 *	Inbin.c		Internal kernal commands
 *******************************************************************************
 */

# include	"../include/param.h"
# include	<a.out.h>
# include	<sys/dir.h>
# include	"../include/stat.h"
# include	<errno.h>
# include	"../include/dev.h"
# include	"../include/buf.h"
# include	"../include/memory.h"
# include	"../include/inbin.h"

/* mention primitives */
int cat(), sync(), cp(), rm(), mv(), lss();
int getblock(), pmem(), smem(), testp();

/* Command jump table */
struct Comm kercom[] = {
	"cat", 0, cat,
	"cp", 0, cp,
	"mv", 0, mv,
	"rm", 0, rm,
	"sync", 0, sync,
	"ls", 0, lss,
	"lss", 0, lss,
	"getb", 0, getblock,
	"pmem", 0, pmem,
	"smem", 0, smem,
	"test", 0, testp,
	0,      0
};

testp(){
	int	c;

	while(1){
		write(1, "TEST\n", 5);
		for(c = 0; c < 400000; c++);
	}
}
/*
 * Built-in 'cat' command.
 */
cat(argc, argv)
char *argv[];
{
	char **filename;

	filename = &argv[1];
	argc--;

	while (argc--)
		if(catfile(*filename++)) return -1;

	return 0;
}

catfile(name)
char *name;
{
	char buffer[BSIZE];
	int nbytes, fd;

	if ((fd = open(name, 0)) == -1){
		printk("cat: cannot open %s\n", name);
		return -1;
	}

	while (nbytes = read(fd, buffer, BSIZE)){
		write(1, buffer, nbytes);
	}

	close(fd);
	return 0;
}

/*
 * Built in version of 'cp' command.
 */
cp(argc, argv)
int	argc;
char	*argv[];
{
	char buffer[BSIZE];
	int f_in, f_out, nbytes, err;

	err = 0;
	if ((f_in = open(argv[1], 0)) == -1){
		printk("cp: cannot read %s\n", argv[1]);
		return -1;
	}

	if ((f_out = creat(argv[2], 0644)) == -1){
		printk("cp: cannot create %s\n", argv[2]);
		close(f_in);
		return -1;
	}

	while (nbytes = read(f_in, buffer, BSIZE)){
		if (nbytes != write(f_out, buffer, nbytes)){
			printk("cp: write error\n");
			err = -1;
			break;
		}
	}

	close(f_in);
	close(f_out);

	return err;
}

/*
 * built-in version of 'rm'.
 */
rm(argc, argv)
char *argv[];
{

	if (argc != 2){
		printk("rm: arg count\n");
		return -1;
	}
	else if (unlink(argv[1]) == -1){
		printk("rm: %s not removed\n", argv[1]);
		return -1;
	}

	return 0;
}

/*
 * Built-in version of 'mv' - renames a file.
 */
mv(argc, argv)
char *argv[];
{

	if (argc != 3){
		printk("mv: arg count\n");
		return -1;
	}
	else if (link(argv[1], argv[2])){
		printk("mv: cannot link to %s\n", argv[2]);
		return -1;
	}
	else if (unlink(argv[1])){
		printk("mv: cannot unlink %s\n", argv[1]);
		return -1;
	}

	return 0;
}

/*
 * Hatoi - convert ascii hex string to int.
 */
hatoi(str)
char *str;
{
	char ch;
	unsigned val;

	val = 0;
	while (ch = *str++){
		if (ch >= '0' && ch <= '9')
			val = (val << 4) | (ch - '0');
		else if (ch >= 'A' && ch <= 'F')
			val = (val << 4) | (ch - 'A' + 10);
		else if (ch >= 'a' && ch <= 'f')
			val = (val << 4) | (ch - 'a' + 10);
		else
			break;
	}

	return val;
}

lss(argc, argv)
int argc;
char *argv[];
{
	int xpos;
	int xent;
	struct	direct dir;
	int file;
	char name[20];

	if(argc == 2) strcpy(name,argv[1]);
	else strcpy(name,".");
	xpos = xent = 0;
	if((file = open(name,0)) == -1) return -1;
	while(read(file, &dir, sizeof(dir))){
		if(dir.d_ino){
			if((xpos += 12) >= 80){
				printk("\n");
				xent = 0;
				xpos = 12;
			}
			printk("%s",dir.d_name);
			if((xent += strlen(dir.d_name)) > 12)
				 xent = strlen(dir.d_name) - 12;

			while((xent++) < 12) write(1, " ", 1);
			xent=0;
		}
	}
	printk("\n");
	close(file);
	return 0;
}

/*
 * Getblock	Prints out a block from given device
 */
getblock(argc,argv)
char *argv[];
int argc;
{
	struct buf *s_buf;

	if(argc != 4){
		printk("Usage:	Device major, Device minor, Block no\n");
		return -1;
	}
	s_buf = getbuf(&bdevsw[atoi(argv[1])], atoi(argv[2]), atoi(argv[3]),
		ALLBUF);
	con(s_buf->b_buf);
	return 0;
}

/*
 *	Pmem()	Prints memory setings.
 */
pmem(argc, argv)
char *argv[];
int argc;
{
	int seg;
	struct	Majseg mem;

	printf("Segment	inuse	nosegs	start	end\n");

	/* Gets information on segments */
	for(seg=0; seg<NMSEGS; seg++){
		getseg(seg, &mem);
		printk("Major %d	%x	%x	%x	%x\n", seg,
			mem.inuse, mem.nsegs, mem.start, mem.end);
		if(argc > 1) pmemmin(seg);
	}
	return 0;
}

/*
 *	Pmemmin()	Prints the given major segments minor segments
 */
pmemmin(maj){
	int	c;
	struct	Minseg *seg;

	seg = mem_maj[maj].segs;
	printk("	Minor	inuse	Pid	Start	End\n");
	for(c=0; c<mem_maj[maj].nsegs; c++){
		printk("	%d	%d	%d	%x	%x\n",c, seg->inuse, seg->pid, seg->start, seg->end);
		seg++;
	}
}

/*
 *	Smem()		Sets a memory segment to new size.
 */
smem(argc, argv)
char *argv[];
int argc;
{
	int seg;
	struct	Majseg mem;

	if(argc != 4){
		printk("usage:	smem <seg> <start> <end>\n");
		return -1;
	}
	seg = hatoi(argv[1]);
	mem.start = (caddr_t)hatoi(argv[2]);
	mem.end = (caddr_t)hatoi(argv[3]);
	if(setseg(seg, &mem) == -1){
		printk("Smem unable to set memory\n");
		return -1;
	}
	return 0;
}

char *byte3_prt(), *basci1();
# define	NOPERLINE 16
# define	TAB	0x09

char *byte3_prt(), *basci1();
# define	NOPERLINE 16
# define	TAB	0x09

con(buff)
char *buff;
{
	int nobytes, n, address, number;
	char buffer1[16], *ptr1, buffer2[256], *ptr2;

	number=address=0;
	nobytes=NOPERLINE;
	while(number<32){
		for(n=0; n<NOPERLINE; n++) buffer1[n] = *buff++;
		ptr1=buffer1;
		ptr2=byte3_prt(buffer2,address);
		*ptr2++ =TAB;
		n=nobytes;
		while(n--){
			ptr2=basci1(ptr2,*ptr1++);
		}
		n=nobytes;
		*(ptr2-1)=' ';
		while(n++<NOPERLINE){
			*ptr2++ =' ';
			*ptr2++ =' ';
			*ptr2++ =' ';
		}
		*(ptr2-1)=TAB;
		for(n=7; n>0; n--) *ptr2++ =' ';
		*ptr2++ ='*';
		ptr1=buffer1;
		n=nobytes+1;
		for(n=nobytes; n>0; n--){
			if(!(*ptr1&0x80)&&(*ptr1>0x1F)&&(*ptr1<0x7F))
				*ptr2++ = *ptr1;
			else *ptr2++ = '.';
			ptr1++;
		}
		*ptr2++ ='\n';
		address+=NOPERLINE;
		write(1,buffer2,(ptr2-buffer2));
		if(++number==16) getchar();
	}
}
char *basci1(str,byte)
char *str, byte;
{
	int n;

	if((n=((byte>>4)&0xF)+'0')>'9') n+=7;
	*str++ =n;
	if((n=(byte&0xF)+'0')>'9') n+=7;
	*str++ =n;
	*str++ =',';
	return str;
}
char *byte3_prt(str,ch)
char *str;
int ch;
{
	int c;
	for(c=20; c>=0; c-=4){
		*str++ =hex_asc((ch>>c)&0xF);
	}
	return str;
}
hex_asc(ch)
char ch;
{
	if((ch+='0')>'9') ch+=7;
	return ch;
}
