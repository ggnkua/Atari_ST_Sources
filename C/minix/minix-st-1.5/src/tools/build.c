/* This program takes the previously compiled and linked pieces of the
 * operating system, and puts them together to build a boot diskette.
 * The files are read and put on the boot diskette in this order:
 *
 *      bootblok:       the diskette boot program
 *      kernel:         the operating system kernel
 *      mm:             the memory manager
 *      fs:             the file system
 *      init:           the system initializer
 *      menu:           the selection menu
 *
 * The bootblok file goes in sector 0 of the boot diskette.  The operating system
 * begins directly after it.  The kernel, mm, fs, init, and menu are each
 * padded out to a multiple of CLICK_SIZE bytes, and then concatenated into a
 * single file beginning 512 bytes into the file.  The first byte of sector 1
 * contains executable code for the kernel.  There is no header present.
 *
 * After the boot image has been built, build goes back and makes several
 * patches to the image file or diskette:
 *
 *      1. The last 4 words of the boot block are set as follows:
 *	   Word at 504:	Number of sectors to load
 *	   Word at 506:	start of data of menu in clicks
 *	   Word at 508:	0
 *	   Word at 510:	start of text of menu in clicks
 *
 *	2. Build writes a table into the first 8 words of the kernel's
 *	   data space.  It has 4 entries, the text and data size in clicks for each
 *	   program.  The kernel needs this information to run mm, fs, and
 *	   init.
 *
 *      3. The origin and size of the init program are patched into bytes 4-9
 *         of the file system data space. The file system needs this
 *         information, and expects to find it here.
 *
 * Build is called by:
 *
 *      build bootblok kernel mm fs init menu image
 *
 * to get the resulting image onto the file "image".
 */

#include "outmix.h"

#ifdef TOS
#include "fakeunix.c"
#else
long	lseek();
#endif

#define PROGRAMS 5              /* kernel + mm + fs + init + menu = 5 */
#define PROG_ORG    0           /* where does kernel begin in abs mem */
#define SECTOR_SIZE 512         /* size of buf */
#define READ_UNIT 512           /* how big a chunk to read in */
#define KERNEL_D_MAGIC 0x526F   /* identifies kernel data space */
#define FS_D_MAGIC 0xDADA	/* identifies fs data space */
#define CLICK_SIZE 256
#define CLICK_SHIFT 8
#define KERN 0
#define MM   1
#define FS   2
#define INIT 3
#define FSCK 4

int image;                      /* file descriptor used for output file */
int cur_sector;                 /* which 512-byte sector to be written next */
int buf_bytes;                  /* # bytes in buf at present */
char buf[SECTOR_SIZE];          /* buffer for output file */
char zero[SECTOR_SIZE];         /* zeros, for writing bss segment */

long cum_size;                  /* Size of kernel+mm+fs+init */
long all_size;                  /* Size of all 5 programs */

struct sizes {
  long text_size;               /* size in bytes */
  long data_size;               /* size in bytes */
  long bss_size;                /* size in bytes */
  short  secs;			/* #sectors written */
  short  nulls;			/* #sectors not written */
} sizes[PROGRAMS];

char *name[] = {"\nkernel", "mm    ", "fs    ", "init  ", "menu  "};

main(argc, argv)
int argc;
char *argv[];
{
/* Copy the boot block and the 5 programs to the output. */

  int i;

  if (argc != PROGRAMS+3) pexit("seven file names expected. ", "");

  create_image(argv[7]);              /* create the output file */

  /* Go get the boot block and copy it to the output file or diskette. */
  copy1(argv[1]);

  /* Copy the 5 programs to the output file or diskette. */
  for (i = 0; i < PROGRAMS; i++) copy2(i, argv[i+2]);
  flush();
  printf("                                               -----     -----\n");
#ifdef PCIX
  printf("Operating system size  %29ld     %5lx\n", cum_size, cum_size);
  printf("\nTotal size including menu is %ld.\n", all_size);
#else
  printf("Operating system size  %29D     %5X\n", cum_size, cum_size);
  printf("\nTotal size including menu is %D.\n", all_size);
#endif

  /* Make the three patches to the output file or diskette. */
  patch1(all_size);
  patch2();
  patch3();
  exit(0);
}



copy1(file_name)
char *file_name;
{
/* Copy the specified file to the output.  The file has no header.  All the
 * bytes are copied, until end-of-file is hit.
 */

  int fd, bytes_read;
  char inbuf[READ_UNIT];

  if ( (fd = open(file_name, 0)) < 0) pexit("can't open ",file_name);

  do {
        bytes_read = read(fd, inbuf, READ_UNIT);
        if (bytes_read < 0) pexit("read error on file ", file_name);
        if (bytes_read > 0) wr_out(inbuf, bytes_read);
  } while (bytes_read > 0);
  flush();
  close(fd);
}


copy2(num, file_name)
int num;                        /* which program is this (0 - 4) */
char *file_name;                /* file to open */
{
/* Open and read a file, copying it to output.  First read the header,
 * to get the text, data, and bss sizes.
 * Read in all of text and initialized data. Perform relocation.
 * Write the text, data, and bss to output.  The sum of these three pieces
 * must be padded upwards to a multiple of CLICK_SIZE, if need be.  The individual
 * pieces need not be multiples of CLICK_SIZE bytes.
 */

  int fd, count, rest, filler;
  unsigned length, n1;
  long reloffset, reloshift, tot_bytes;
  char *buf1, buf2[1024];
  register char *p1, *p2;
  register c, n2;
  struct exec exec;
  long b4;
  extern char *malloc();
  
  if ( (fd = open(file_name, 0)) < 0) pexit("can't open ", file_name);

  /* Read the header to see how big the segments are. */
  read_header(fd, &exec, file_name);

  reloshift = cum_size;
  reloffset = SZ_HEAD + exec.a_tsize + exec.a_dsize + exec.a_ssize;

  /* Pad the total size to a CLICK_SIZE-byte multiple, if needed. */
  tot_bytes = exec.a_tsize + exec.a_dsize + exec.a_bsize;
  rest = (int)(tot_bytes % CLICK_SIZE);
  filler = (rest > 0 ? CLICK_SIZE - rest : 0);
  exec.a_bsize += filler;
  tot_bytes += filler;
  if (num < FSCK) cum_size += tot_bytes;
  all_size += tot_bytes;

  /* Record the size information in the table. */
  sizes[num].text_size = exec.a_tsize;
  sizes[num].data_size = exec.a_dsize;
  sizes[num].bss_size  = exec.a_bsize;
  sizes[num].secs      = cur_sector;

  /* Print a message giving the program name and size, except for menu. */
  if (num < FSCK) { 
        printf("%s  text=%5D  data=%5D  bss=%5D  tot=%5D  hex=%4X\n",
                name[num],
		exec.a_tsize, exec.a_dsize, exec.a_bsize,
		tot_bytes, tot_bytes);
  }

  /* Read in relocation info from the exec file and relocate.
   * Relocation info is in GEMDOS format. Only longs can be relocated.
   *
   * The GEMDOS format starts with a long L: the offset to the
   * beginning of text for the first long to be relocated.
   * If L==0 then no relocations have to be made.
   *
   * The long is followed by zero or more bytes. Each byte B is
   * processed separately, in one of the following ways:
   *
   * B==0:
   *	end of relocation
   * B==1:
   *	no relocation, but add 254 to the current offset
   * B==0bWWWWWWW0:
   *	B is added to the current offset and the long addressed
   *	is relocated. Note that 00000010 means 1 word distance.
   * B==0bXXXXXXX1:
   *	illegal
   */

  /* Allocate memory and read in the text+data and relocation */
  length = exec.a_tsize + exec.a_dsize;
  if (length != exec.a_tsize + exec.a_dsize)
	pexit("more than 64k ", file_name);
  buf1 = malloc(length);
  if (buf1 == 0)
	pexit("too big ", file_name);
  p1 = buf1;
  n1 = length;
  while (n1 != 0) {
	count = (n1 < 16*1024 ? n1 : 16*1024);
	if (read(fd, p1, count) != count)
		pexit("read error on file ", file_name);
	n1 -= count;
	p1 += count;
  }
  if (lseek(fd, reloffset, 0) < 0)
	pexit("can't seek ", file_name);
  p1 = buf1;
  p2 = buf2;
  n2 = read(fd, p2, (int)sizeof(buf2));
  if (n2 < (int)sizeof(long))
	pexit("relocation info missing on file ", file_name);
  if (*((long *)p2) != 0) {
	p1 += *((long *)p2);
	n2 -= (int)sizeof(long);
	p2 += (int)sizeof(long);
	for (;;) {			/* once per relocation */
		if (p1 < buf1 || p1 >= &buf1[length])
			pexit("bad relocation in ", file_name);
		getstruc((char *)&b4, "M4", p1);
/* printf("%X L: %X -> %X\n", p1-buf1, b4, b4+reloshift); */
		b4 += reloshift;
		putstruc((char *)&b4, "M4", p1);
		for (;;) {		/* once per byte */
			if (--n2 < 0) {
				p2 = buf2;
				n2 = read(fd, p2, (int)sizeof(buf2));
				if (--n2 < 0)
					pexit("read error on file ", file_name);
			}
			c = *p2++ & 0xFF;
			if (c != 1)
				break;
			p1 += 254;
		}
		if (c == 0)
			break;
		if (c & 1)
			pexit("odd relo byte on file ", file_name);
		p1 += c;
	}
  }
  length = exec.a_tsize + exec.a_dsize;
  p1 = buf1;
  while (length != 0) {
	count = (length < READ_UNIT ? length : READ_UNIT);
        wr_out(p1, count);
        length -= count;
	p1 += count;
  }

  /* Write the bss to output. */
  n1 = n2 = 0;
  while (exec.a_bsize != 0) {
        count = (exec.a_bsize < SECTOR_SIZE ? exec.a_bsize : SECTOR_SIZE);
	if (count > SECTOR_SIZE - buf_bytes)
		count = SECTOR_SIZE - buf_bytes;
	if (count != SECTOR_SIZE)
	        wr_out(zero, count);
	else if (n1 == 0)
		n1 = cur_sector;
	else
		n2++;
        exec.a_bsize -= count;
  }
  if (n1) {
	sizes[num].nulls = n2 + 1;
	sizes[num].secs  = n1 - sizes[num].secs;
  } else {
	sizes[num].nulls = 0;
	sizes[num].secs  = cur_sector - sizes[num].secs;
  }
  free(buf1);
  close(fd);
}


read_header(fd, exec, file_name)
int fd;
struct exec *exec;
char *file_name;
{
  char hbuf[SZ_HEAD];

  /* Read header */
  if (read(fd, hbuf, SZ_HEAD) != SZ_HEAD)
	pexit("file header too short: ", file_name);

  /* fix byte order and alignment */
  getstruc((char *)exec, SF_HEAD, hbuf);

  if (exec->a_magic != A_MAGICD)
        pexit("bad header type. File: ", file_name);
  if (exec->a_entry != 0)
        pexit("entry point not 0. File: ", file_name);
}


wr_out(buffer, bytes)
char buffer[READ_UNIT];
int bytes;
{
/* Write some bytes to the output file.  This procedure must avoid writes
 * that are not entire 512-byte blocks, because when this program runs on
 * MS-DOS, the only way it can write the raw diskette is by using the system
 * calls for raw block I/O.
 */

  int room, count, count1;
  register char *p, *q;

  /* Copy the data to the output buffer. */
  room = SECTOR_SIZE - buf_bytes;
  count = (bytes <= room ? bytes : room);
  count1 = count;
  p = &buf[buf_bytes];
  q = buffer;
  while (count--) *p++ = *q++;
  
  /* See if the buffer is full. */
  buf_bytes += count1;
  if (buf_bytes == SECTOR_SIZE) {
        /* Write the whole block to the disk. */
        write_block(cur_sector, buf);
        clear_buf();
  }

  /* Is there any more data to copy. */
  if (count1 == bytes) return;
  bytes -= count1;
  buf_bytes = bytes;
  p = buf;
  while (bytes--) *p++ = *q++;
}


flush()
{
  if (buf_bytes == 0) return;
  write_block(cur_sector, buf);
  clear_buf();
}


clear_buf()
{
  register char *p;

  for (p = buf; p < &buf[SECTOR_SIZE]; p++) *p = 0;
  buf_bytes = 0;
  cur_sector++;
}


patch1(all_size)
long all_size;
{
/* Put the ip and cs values for menu in the last two words of the boot blk.
 * Put in bootblok-offset 504 the number of sectors to load.
#ifdef ATARI_ST
 * Put in bootblok-offset 502 a checksum to make it acceptable for TOS
#endif
 */

  long menu_org;
  unsigned short cs, sectrs, ip = 0;
  char cbuf[SECTOR_SIZE];

  if (cum_size % CLICK_SIZE != 0) pexit("MINIX is not multiple of CLICK_SIZE bytes", "");
  menu_org = PROG_ORG + cum_size;       /* where does menu begin */
  cs = menu_org >> CLICK_SHIFT;

  /* calc nr of sectors to load (starting at 0) */
  sectrs = (unsigned) ((all_size + 511L) / 512L);

  read_block(0, cbuf);          /* read in boot block */
  putstruc((char *)&sectrs, "M2", &cbuf[SECTOR_SIZE-8]);
  putstruc((char *)&cs, "M2", &cbuf[SECTOR_SIZE-6]);
  putstruc((char *)&ip, "M2", &cbuf[SECTOR_SIZE-4]);
  putstruc((char *)&cs, "M2", &cbuf[SECTOR_SIZE-2]);
#ifdef ATARI_ST
  { short sum, i; register short *p;
	for (i = 0; i < PROGRAMS; i++) {
	    putstruc((char *)&sizes[i].secs, "M2", &cbuf[SECTOR_SIZE-32+i*4]);
	    putstruc((char *)&sizes[i].nulls, "M2", &cbuf[SECTOR_SIZE-30+i*4]);
	}
	cbuf[SECTOR_SIZE-12] = cbuf[SECTOR_SIZE-11] = '\0';
	sum = 0;
	for (p = (short *)cbuf; p < (short *)&cbuf[SECTOR_SIZE]; p++) {
		getstruc((char *)&i, "M2", (char *)p);
		sum += i;
	}
	getstruc((char *)&i, "M2", &cbuf[SECTOR_SIZE-10]);
	i -= sum;
	i += 0x1234;
	putstruc((char *)&i, "M2", &cbuf[SECTOR_SIZE-10]);
  }
#endif
  write_block(0, cbuf);
}

patch2()
{
/* This program now has information about the sizes of the kernel, mm, fs, and
 * init.  This information is patched into the kernel as follows. The first 8
 * words of the kernel data space are reserved for a table filled in by build.
 * The first 2 words are for kernel, then 2 words for mm, then 2 for fs, and
 * finally 2 for init.  The first word of each set is the text size in clicks;
 * the second is the data+bss size in clicks.
 * The text size is 0, i.e., the whole thing is data.
 */

  int i, text_clicks, data_clicks;
  long data_offset;

  /* See if the magic number is where it should be in the kernel. */
  data_offset = 512L + (long)sizes[KERN].text_size;    /* start of kernel data */
  i = get_word(data_offset);
  if (i != KERNEL_D_MAGIC)
	pexit("kernel data space: no magic #","");
  
  for (i = 0; i < PROGRAMS - 1; i++) {
	text_clicks = 0;
	data_clicks = ( sizes[i].text_size
			+
			sizes[i].data_size
			+
			sizes[i].bss_size
		      ) >> CLICK_SHIFT;
        put_word(data_offset + 4*i + 0L, text_clicks);
        put_word(data_offset + 4*i + 2L, data_clicks);
  }
}


patch3()
{
/* Write the origin and text and data sizes of the init program in FS's data
 * space.  The file system expects to find these 3 words there.
 */

  int mag, w0, w1, w2;
  long init_text_size, init_data_size, init_org, fs_org, fbase, mm_data;

  init_org  = PROG_ORG;
  init_org += sizes[KERN].text_size+sizes[KERN].data_size+sizes[KERN].bss_size;
  mm_data = init_org - PROG_ORG +512L;	/* offset of mm in file */
  mm_data += (long) sizes[MM].text_size;
  mm_data -= SECTOR_SIZE * sizes[KERN].nulls;
  init_org += sizes[MM].text_size + sizes[MM].data_size + sizes[MM].bss_size;
  fs_org = init_org - PROG_ORG + 512L;   /* offset of fs-text into file */
  fs_org +=  (long) sizes[FS].text_size;
  fs_org -= SECTOR_SIZE * (sizes[KERN].nulls + sizes[MM].nulls);
  init_org += sizes[FS].text_size + sizes[FS].data_size + sizes[FS].bss_size;
  init_text_size = sizes[INIT].text_size;
  init_data_size = sizes[INIT].data_size + sizes[INIT].bss_size;
  init_org  = init_org >> CLICK_SHIFT;  /* convert to clicks */
  init_data_size += init_text_size;
  init_text_size = 0;
  init_text_size = init_text_size >> CLICK_SHIFT;
  init_data_size = init_data_size >> CLICK_SHIFT;

  w0 = init_org;
  w1 = init_text_size;
  w2 = init_data_size;

  /* Check for appropriate magic numbers. */
  fbase = fs_org;
  mag = get_word(mm_data);
  if (mag != FS_D_MAGIC) pexit("mm data space: no magic #","");
  mag = get_word(fbase);
  if (mag != FS_D_MAGIC) pexit("fs data space: no magic #","");

  put_word(fbase+4L, w0);
  put_word(fbase+6L, w1);
  put_word(fbase+8L ,w2);
}


int get_word(offset)
long offset;
{
/* Fetch one byte from the output file. */

  char buff[SECTOR_SIZE];
  short b2;

  read_block( (int)(offset/SECTOR_SIZE), buff);
  getstruc((char *)&b2, "M2", &buff[offset % SECTOR_SIZE]);
  return(b2 & 0xFFFF);
}

put_word(offset, byte_value)
long offset;
int byte_value;
{
/* Write one byte into the output file. This is not very efficient, but
 * since it is only called to write a few words it is just simpler.
 */

  char buff[SECTOR_SIZE];
  short b2;

  b2 = byte_value;
  read_block( (int)(offset/SECTOR_SIZE), buff);
  putstruc((char *)&b2, "M2", &buff[offset % SECTOR_SIZE]);
  write_block( (int)(offset/SECTOR_SIZE), buff);
}


pexit(s1, s2)
char *s1, *s2;
{
  printf("Build: %s%s\n", s1, s2);
  exit(1);
}

#include "getstruc.c"
#include "putstruc.c"

create_image(f)
char *f;
{
/* Create the output file. */
  image = creat(f, 0666);
  close(image);
  image = open(f, 2);
}

read_block(blk, buff)
int blk;
char buff[SECTOR_SIZE];
{
  lseek(image, (long)SECTOR_SIZE * (long) blk, 0);
  if (read(image, buff, SECTOR_SIZE) != SECTOR_SIZE) pexit("block read error", "");
}

write_block(blk, buff)
int blk;
char buff[SECTOR_SIZE];
{
  lseek(image, (long)SECTOR_SIZE * (long) blk, 0);
  if (write(image, buff, SECTOR_SIZE) != SECTOR_SIZE) pexit("block write error", "");
}
