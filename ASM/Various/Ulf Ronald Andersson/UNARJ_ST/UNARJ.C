/* UNARJ.C, UNARJ, R JUNG, 10/05/92
 * Main Extractor routine
 * Copyright (c) 1991 by Robert K Jung.  All rights reserved.
 *
 *   This code may be freely used in programs that are NOT ARJ archivers
 *   (both compress and extract ARJ archives).
 *
 *   If you wish to distribute a modified version of this program, you
 *   MUST indicate that it is a modified version both in the program and
 *   source code.
 *
 *   If you modify this program, I would appreciate a copy of the new
 *   source code.  I am holding the copyright on the source code, so
 *   please do not delete my name from the program files or from the
 *   documentation.
 *
 *   I wish to give credit to Haruhiko Okumura for providing the
 *   basic ideas for ARJ and UNARJ in his program AR.  Please note
 *   that UNARJ is significantly different from AR from an archive
 *   structural point of view.
 *
 * Modification history:
 * Date      Programmer  Description of modification.
 * 04/05/91  R. Jung     Rewrote code.
 * 04/23/91  M. Adler    Portabilized.
 * 04/29/91  R. Jung     Added l command.  Removed 16 bit dependency in
 *                       fillbuf().
 * 05/19/91  R. Jung     Fixed extended header skipping code.
 * 05/25/91  R. Jung     Improved find_header().
 * 06/03/91  R. Jung     Changed arguments in get_mode_str() and
 *                       set_ftime_mode().
 * 06/19/81  R. Jung     Added two more %c in printf() in list_arc().
 * 07/07/91  R. Jung     Added default_case_path() to extract().
 *                       Added strlower().
 * 07/20/91  R. Jung     Changed uint ratio() to static uint ratio().
 * 07/21/91  R. Jung     Added #ifdef VMS.
 * 08/28/91  R. Jung     Changed M_DIFFHOST message.
 * 08/31/91  R. Jung     Added changes to support MAC THINK_C compiler
 *                       per Eric Larson.
 * 10/07/91  R. Jung     Added missing ; to THINK_C additions.
 * 11/11/91  R. Jung     Added host_os test to fwrite_txt_crc().
 * 11/24/91  R. Jung     Added more error_count processing.
 * 12/03/91  R. Jung     Added backup file processing.
 * 10/05/92  G. Zahn     ST-Implementation
 *
 */

#include "unarj.h"
#include <tos.h>

#ifdef MODERN
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#else /* !MODERN */
extern void free();
extern void exit();
extern char *strcat();
extern char *strcpy();
extern char *strncpy();
extern char *strchr();
extern char *strrchr();
extern int strlen();
extern int strcmp();
#ifdef VMS
#include <ssdef.h>
#define EXIT_FAILURE SS$_ABORT
#define EXIT_SUCCESS SS$_NORMAL
#else
#define EXIT_FAILURE (1)
#define EXIT_SUCCESS (0)
#endif
#define toupper(c)   ((c)>='a'&&(c)<='z'?(c)-('a'-'A'):(c))
#define tolower(c)   ((c)>='A'&&(c)<='Z'?(c)+('a'-'A'):(c))
#endif /* ?MODERN */

#ifdef THINK_C
#include <console.h>
#endif

/* Global variables */

UCRC   crc;
FILE   *arcfile;
FILE   *outfile;
ushort bitbuf;
long   compsize;
long   origsize;
uchar  subbitbuf;
uchar  header[HEADERSIZE_MAX];
char   arc_name[FNAME_MAX];
int    command;
int    bitcount;
int    file_type;
int    no_output;
int    error_count;

/* Messages */

static char *M_USAGE  [] =
{
"   Usage:\n",
"UNARJ [v] archive[.arj] (list archive with pathnames)\n",
"UNARJ l archive[.arj]   (list archive with statistics)\n",
"\n",
"UNARJ e archive[.arj]   (extract archive)\n",
"UNARJ x archive[.arj]   (extract with pathnames)\n",
"UNARJ t archive[.arj]   (test archive)\n",
"\n",
"This is an UNARJ program for ATARI ST/STE/TT-computers by Gero Zahn.\n",
"You may freely use, copy and distribute this program, provided that no fee\n",
"is charged for such use, copying or distribution, and it is distributed\n",
"ONLY in its original unmodified state.  UNARJ is provided as is without\n",
"warranty of any kind, express or implied, including but not limited to\n",
"the implied warranties of merchantability and fitness for a particular\n",
"purpose. Refer to the manual for more information.\n",
"\n",
" UNARJ for PC: Robert K Jung, Internet: robjung@world.std.com\n",
"ATARI-version: Gero Zahn,     Internet: q92127@pbhrzx.uni-paderborn.de\n",
NULL
};

char M_VERSION [] = "UNARJ (ATARI-version) 2.30GZ (C)opyright 1991 Robert K Jung / 1992 Gero Zahn\n\n";

char M_ARCDATE [] = "Archive date      : %s\n";
char M_BADCOMND[] = "Bad UNARJ command: %s";
char M_BADCOMNT[] = "Invalid comment header";
char M_BADHEADR[] = "Bad header";
char M_BADTABLE[] = "Bad Huffman code";
char M_CANTOPEN[] = "Can't open %s";
char M_CANTREAD[] = "Can't read file or unexpected end of file";
char M_CANTWRIT[] = "Can't write file. Disk full?";
char M_CRCERROR[] = "CRC error!\n";
char M_CRCOK   [] = "CRC OK\n";
char M_DIFFHOST[] = "  Binary file!";
char M_ENCRYPT [] = "File is password encrypted, ";
char M_ERRORCNT[] = "%sFound %5d error(s)!";
char M_EXTRACT [] = "Extracting %-25s";
char M_FEXISTS [] = "%-25s exists, ";
char M_HEADRCRC[] = "Header CRC error!";
char M_NBRFILES[] = "%5d file(s)\n";
char M_NOMEMORY[] = "Out of memory";
char M_NOTARJ  [] = "%s is not an ARJ archive";
char M_PROCARC [] = "Processing archive: %s\n";
char M_SKIPPED [] = "Skipped %s\n";
char M_SUFFIX  [] = ARJ_SUFFIX;
char M_TESTING [] = "Testing    %-25s";
char M_UNKNMETH[] = "Unsupported method: %d, ";
char M_UNKNTYPE[] = "Unsupported file type: %d, ";
char M_UNKNVERS[] = "Unsupported version: %d, ";

#define get_crc()       get_longword()
#define fget_crc(f)     fget_longword(f)

#define setup_get(PTR)  (get_ptr = (PTR))
#define get_byte()      ((uchar)(*get_ptr++ & 0xff))

#define BUFFERSIZE      4096

#define ASCII_MASK      0x7F

#define CRCPOLY         0xEDB88320L

#define UPDATE_CRC(r,c) r=crctable[((uchar)(r)^(uchar)(c))&0xff]^(r>>CHAR_BIT)

/* Local functions */

#ifdef MODERN
static void  make_crctable(void);
static void  crc_buf(char *str, int len);
static void  strparity(uchar *p);
static FILE  *fopen_msg(char *name, char *mode);
static int   fget_byte(FILE *f);
static uint  fget_word(FILE *f);
static ulong fget_longword(FILE *f);
static void  fread_crc(uchar *p, int n, FILE *f);
static void  decode_path(char *name);
static void  get_date_str(char *str, ulong tstamp);
static int   parse_path(char *pathname, char *path, char *entry);
static void  strncopy(char *to, char *from, int len);
static uint  get_word(void);
static ulong get_longword(void);
static long  find_header(FILE *fd);
static int   read_header(int first, FILE *fd, char *name);
static void  skip(void);
static void  unstore(void);
static int   check_flags(void);
static int   extract(void);
static int   test(void);
static uint  ratio(long a, long b);
static void  list_start(void);
static void  list_arc(int count);
static void  verb_start(void);
static void  verb_arc(int count);
static void  execute_cmd(void);
static void  help(void);
#endif /* MODERN */

/* Local variables */

static char   filename[FNAME_MAX];
static char   comment[COMMENT_MAX];
static char   *hdr_filename;
static char   *hdr_comment;

static ushort headersize;
static uchar  first_hdr_size;
static uchar  arj_nbr;
static uchar  arj_x_nbr;
static uchar  host_os;
static uchar  arj_flags;
static short  method;
static uint   file_mode;
static ulong  time_stamp;
static short  entry_pos;
static ushort host_data;
static uchar  *get_ptr;
static UCRC   file_crc;
static UCRC   header_crc;

static long   first_hdr_pos;
static long   torigsize;
static long   tcompsize;

static int    clock_inx;

static char   *writemode[2]  = { "wb",  "w" };

static UCRC   crctable[UCHAR_MAX + 1];

/* Functions */

static void
make_crctable()
{
    uint i, j;
    UCRC r;

    for (i = 0; i <= UCHAR_MAX; i++)
    {
        r = i;
        for (j = CHAR_BIT; j > 0; j--)
        {
            if (r & 1)
                r = (r >> 1) ^ CRCPOLY;
            else
                r >>= 1;
        }
        crctable[i] = r;
    }
}

static void
crc_buf(str, len)
char *str;
int  len;
{
    while (len--)
        UPDATE_CRC(crc, *str++);
}

void
disp_clock()
{
    static char clock_str[4] = { '|', '/', '-', '\\' };

    printf("(%c)\b\b\b", clock_str[clock_inx]);
    clock_inx = (clock_inx + 1) & 0x03;
}

void
error(fmt, arg)
char *fmt;
char *arg;
{
    putc('\n', stdout);
    printf(fmt, arg, error_count);
    putc('\n', stdout);
    exit(EXIT_FAILURE);
}

static void
strparity(p)
uchar *p;
{
    while (*p)
    {
        FIX_PARITY(*p);
        p++;
    }
}

static FILE *
fopen_msg(name, mode)
char *name;
char *mode;
{
    FILE *fd;

    fd = file_open(name, mode);
    if (fd == NULL)
        error(M_CANTOPEN, name);
    return fd;
}

static int
fget_byte(f)
FILE *f;
{
    int c;

    if ((c = getc(f)) == EOF)
        error(M_CANTREAD, "");
    return c & 0xFF;
}

static uint
fget_word(f)
FILE *f;
{
    uint b0, b1;

    b0 = fget_byte(f);
    b1 = fget_byte(f);
    return (b1 << 8) + b0;
}

static ulong
fget_longword(f)
FILE *f;
{
    ulong b0, b1, b2, b3;

    b0 = fget_byte(f);
    b1 = fget_byte(f);
    b2 = fget_byte(f);
    b3 = fget_byte(f);
    return (b3 << 24) + (b2 << 16) + (b1 << 8) + b0;
}

static void
fread_crc(p, n, f)
uchar *p;
int   n;
FILE  *f;
{
    n = file_read((char *)p, 1, n, f);
    origsize += n;
    crc_buf((char *)p, n);
}

void
fwrite_txt_crc(p, n)
uchar *p;
int   n;
{
    uchar c;

    crc_buf((char *)p, n);
    if (no_output)
        return;

    if (file_type == TEXT_TYPE)
    {
        while (n--)
        {
            c = *p++;
            if (host_os != OS)
            {
                FIX_PARITY(c);
            }
            if (putc((int) c, outfile) == EOF)
                error(M_CANTWRIT, "");
        }
    }
    else
    {
        if (file_write((char *)p, 1, n, outfile) != n)
            error(M_CANTWRIT, "");
    }
}

void
init_getbits()
{
    bitbuf = 0;
    subbitbuf = 0;
    bitcount = 0;
    fillbuf(2 * CHAR_BIT);
}

void
fillbuf(n)                /* Shift bitbuf n bits left, read n bits */
int n;
{
    bitbuf = (bitbuf << n) & 0xFFFF;  /* lose the first n bits */
    while (n > bitcount)
    {
        bitbuf |= subbitbuf << (n -= bitcount);
        if (compsize != 0)
        {
            compsize--;
            subbitbuf = (uchar) getc(arcfile);
        }
        else
            subbitbuf = 0;
        bitcount = CHAR_BIT;
    }
    bitbuf |= subbitbuf >> (bitcount -= n);
}

ushort
getbits(n)
int n;
{
    ushort x;

    x = bitbuf >> (2 * CHAR_BIT - n);
    fillbuf(n);
    return x;
}

static void
decode_path(name)
char *name;
{
    for ( ; *name; name++)
    {
        if (*name == ARJ_PATH_CHAR)
            *name = PATH_CHAR;
    }
}

static void
get_date_str(str, tstamp)
char  *str;
ulong tstamp;
{
    sprintf(str, "%04u-%02u-%02u %02u:%02u:%02u",
           ts_year(tstamp), ts_month(tstamp), ts_day(tstamp),
           ts_hour(tstamp), ts_min(tstamp), ts_sec(tstamp));
}

static int
parse_path(pathname, path, entry)
char *pathname;
char *path;
char *entry;
{
    char *cptr, *ptr, *fptr;
    short pos;

    fptr = NULL;
    for (cptr = PATH_SEPARATORS; *cptr; cptr++)
    {
        if ((ptr = strrchr(pathname, *cptr)) != NULL &&
                (fptr == NULL || ptr > fptr))
            fptr = ptr;
    }
    if (fptr == NULL)
        pos = 0;
    else
        pos = fptr + 1 - pathname;
    if (path != NULL)
    {
       strncpy(path, pathname, pos);
       path[pos] = NULL_CHAR;
    }
    if (entry != NULL)
       strcpy(entry, &pathname[pos]);
    return pos;
}

static void
strncopy(to, from, len)
char *to;
char *from;
int  len;
{
    int i;

    for (i = 1; i < len && *from; i++)
        *to++ = *from++;
    *to = NULL_CHAR;
}

void
strlower(s)
char *s;
{
    while (*s)
    {
        *s = (char) tolower(*s);
        s++;
    }
}

void
strupper(s)
char *s;
{
    while (*s)
    {
        *s = (char) toupper(*s);
        s++;
    }
}

voidp *
malloc_msg(size)
int size;
{
    char *p;

    if ((p = (char *)xmalloc(size)) == NULL)
        error(M_NOMEMORY, "");
    return (voidp *)p;
}

static uint
get_word()
{
    uint b0, b1;

    b0 = get_byte();
    b1 = get_byte();
    return (b1 << 8) + b0;
}

static ulong
get_longword()
{
    ulong b0, b1, b2, b3;

    b0 = get_byte();
    b1 = get_byte();
    b2 = get_byte();
    b3 = get_byte();
    return (b3 << 24) + (b2 << 16) + (b1 << 8) + b0;
}

static long
find_header(fd)
FILE *fd;
{
    long arcpos, lastpos;
    int c;

    arcpos = file_tell(fd);
    file_seek(fd, 0L, SEEK_END);
    lastpos = file_tell(fd) - 2;
    if (lastpos > MAXSFX)
        lastpos = MAXSFX;
    for ( ; arcpos < lastpos; arcpos++)
    {
        file_seek(fd, arcpos, SEEK_SET);
        c = fget_byte(fd);
        while (arcpos < lastpos)
        {
            if (c != HEADER_ID_LO)  /* low order first */
                c = fget_byte(fd);
            else if ((c = fget_byte(fd)) == HEADER_ID_HI)
                break;
            arcpos++;
        }
        if (arcpos >= lastpos)
            break;
        if ((headersize = fget_word(fd)) <= HEADERSIZE_MAX)
        {
            crc = CRC_MASK;
            fread_crc(header, (int) headersize, fd);
            if ((crc ^ CRC_MASK) == fget_crc(fd))
            {
                file_seek(fd, arcpos, SEEK_SET);
                return arcpos;
            }
        }
    }
    return -1;          /* could not find a valid header */
}

static int
read_header(first, fd, name)
int  first;
FILE *fd;
char *name;
{
    ushort extheadersize, header_id;

    header_id = fget_word(fd);
    if (header_id != HEADER_ID)
    {
        if (first)
            error(M_NOTARJ, name);
        else
            error(M_BADHEADR, "");
    }

    headersize = fget_word(fd);
    if (headersize == 0)
        return 0;               /* end of archive */
    if (headersize > HEADERSIZE_MAX)
        error(M_BADHEADR, "");

    crc = CRC_MASK;
    fread_crc(header, (int) headersize, fd);
    header_crc = fget_crc(fd);
    if ((crc ^ CRC_MASK) != header_crc)
        error(M_HEADRCRC, "");

    setup_get(header);
    first_hdr_size = get_byte();
    arj_nbr = get_byte();
    arj_x_nbr = get_byte();
    host_os = get_byte();
    arj_flags = get_byte();
    method = get_byte();
    file_type = get_byte();
    (void)get_byte();
    time_stamp = get_longword();
    compsize = get_longword();
    origsize = get_longword();
    file_crc = get_crc();
    entry_pos = get_word();
    file_mode = get_word();
    host_data = get_word();

    hdr_filename = (char *)&header[first_hdr_size];
    strncopy(filename, hdr_filename, (int) sizeof(filename));
    if (host_os != OS)
        strparity((uchar *)filename);
    if ((arj_flags & PATHSYM_FLAG) != 0)
        decode_path(filename);

    hdr_comment = (char *)&header[first_hdr_size + strlen(hdr_filename) + 1];
    strncopy(comment, hdr_comment, (int) sizeof(comment));
    if (host_os != OS)
        strparity((uchar *)comment);

    /* if extheadersize == 0 then no CRC */
    /* otherwise read extheader data and read 4 bytes for CRC */

    while ((extheadersize = fget_word(fd)) != 0)
        file_seek(fd, (long) (extheadersize + 4), SEEK_CUR);

    return 1;                   /* success */
}

static void
skip()
{
    file_seek(arcfile, compsize, SEEK_CUR);
}

static void
unstore()
{
    int n;
    long pos;
    char *buffer;

    buffer = (char *)malloc_msg(BUFFERSIZE);
    pos = file_tell(arcfile);
    disp_clock();
    n = (int)(BUFFERSIZE - (pos % BUFFERSIZE));
    n = compsize > (long)n ? n : (int)compsize;
    while (compsize > 0)
    {
        if (file_read(buffer, 1, n, arcfile) != n)
            error(M_CANTREAD, "");
        disp_clock();
        compsize -= n;
        fwrite_txt_crc((uchar *)buffer, n);
        n = compsize > BUFFERSIZE ? BUFFERSIZE : (int)compsize;
    }
    free(buffer);
}

static int
check_flags()
{
    if (arj_x_nbr > ARJ_X_VERSION)
    {
        printf(M_UNKNVERS, arj_x_nbr);
        printf(M_SKIPPED, filename);
        skip();
        return -1;
    }
    if ((arj_flags & GARBLE_FLAG) != 0)
    {
        printf(M_ENCRYPT);
        printf(M_SKIPPED, filename);
        skip();
        return -1;
    }
    if (method < 0 || method > MAXMETHOD || (method == 4 && arj_nbr == 1))
    {
        printf(M_UNKNMETH, method);
        printf(M_SKIPPED, filename);
        skip();
        return -1;
    }
    if (file_type != BINARY_TYPE && file_type != TEXT_TYPE)
    {
        printf(M_UNKNTYPE, file_type);
        printf(M_SKIPPED, filename);
        skip();
        return -1;
    }
    return 0;
}

void create_branch(p)
char *p;
{
	char pa[FNAME_MAX];
	void create_branch(char *p);

	if (strlen(p)!=0) {
		parse_path(p,pa,(char *)NULL);
		pa[strlen(pa)-1]=0;
		create_branch(pa);
		Dcreate(p);
	}											
}

static int
extract()
{
    char name[FNAME_MAX];
    char path[FNAME_MAX];

    if (check_flags())
    {
        error_count++;
        return 0;
    }

    no_output = 0;
    if (command == 'E')
    {
        strcpy(name, &filename[entry_pos]);
        strcpy(path, "");
    }
    else
    {
        strcpy(name, filename);

/*	BUG patch start
 *      if (entry_pos!=0) strncpy(path,filename,entry_pos-1);
 *	The line above can fail to terminate string
 *	So it is be replaced by the lines below
 */
		if	(entry_pos!=0)
		{	strncpy(path,filename,entry_pos);
			path[entry_pos]='\0';
		}

/* BUG patch end */

        else strcpy(path,"");
    }

    if (host_os != OS)
        default_case_path(name);

    if (file_exists(name))
    {
        printf(M_FEXISTS, name);
        printf(M_SKIPPED, name);
        skip();
        error_count++;
        return 0;
    }
    
    if (path!=NULL) create_branch(path);
    
    outfile = file_open(name, writemode[file_type & 1]);
    if (outfile == NULL)
    {
        printf(M_CANTOPEN, name);
        putchar('\n');
        skip();
        error_count++;
        return 0;
    }
    printf(M_EXTRACT, name);
    if (host_os != OS && file_type == BINARY_TYPE)
        printf(M_DIFFHOST);
    printf("  ");

    crc = CRC_MASK;

    if (method == 0)
        unstore();
    else if (method == 1 || method == 2 || method == 3)
        decode();
    else if (method == 4)
        decode_f();
    fclose(outfile);

    set_ftime_mode(name, time_stamp, file_mode, (uint) host_os);

    if ((crc ^ CRC_MASK) == file_crc)
        printf(M_CRCOK);
    else
    {
        printf(M_CRCERROR);
        error_count++;
    }
    return 1;
}

static int
test()
{
    if (check_flags())
        return 0;

    no_output = 1;
    printf(M_TESTING, filename);
    printf("  ");

    crc = CRC_MASK;

    if (method == 0)
        unstore();
    else if (method == 1 || method == 2 || method == 3)
        decode();
    else if (method == 4)
        decode_f();

    if ((crc ^ CRC_MASK) == file_crc)
        printf(M_CRCOK);
    else
    {
        printf(M_CRCERROR);
        error_count++;
    }
    return 1;
}

static uint
ratio(a, b)
long a, b;
{
   int i;

   for (i = 0; i < 3; i++)
       if (a <= LONG_MAX / 10)
           a *= 10;
       else
           b /= 10;
   if ((long) (a + (b >> 1)) < a)
   {
       a >>= 1;
       b >>= 1;
   }
   if (b == 0)
       return 0;
   return (uint) ((a + (b >> 1)) / b);
}

static void
list_start()
{
    printf("Filename       Original Compressed Ratio DateTime modified CRC-32   AttrBTPMGVX\n");
    printf("------------ ---------- ---------- ----- ----------------- -------- -----------\n");
}

static void
list_arc(count)
int count;
{
    uint r;
    int garble_mode, path_mode, volume_mode, extfil_mode, ftype, bckf_mode;
    char date_str[20], fmode_str[10];
    static char mode[5] = { 'B', 'T', '?', 'D', 'V' };
    static char pthf[2] = { ' ', '+' };
    static char pwdf[2] = { ' ', 'G' };  /* plain, encrypted */
    static char volf[2] = { ' ', 'V' };
    static char extf[2] = { ' ', 'X' };
    static char bckf[2] = { ' ', '*' };

    if (count == 0)
        list_start();

    garble_mode = ((arj_flags & GARBLE_FLAG) != 0);
    volume_mode = ((arj_flags & VOLUME_FLAG) != 0);
    extfil_mode = ((arj_flags & EXTFILE_FLAG) != 0);
    bckf_mode   = ((arj_flags & BACKUP_FLAG) != 0);
    path_mode   = (entry_pos > 0);
    r = ratio(compsize, origsize);
    torigsize += origsize;
    tcompsize += compsize;
    ftype = file_type;
    if (ftype != BINARY_TYPE && ftype != TEXT_TYPE && ftype != DIR_TYPE &&
            ftype != LABEL_TYPE)
        ftype = 3;
    get_date_str(date_str, time_stamp);
    strcpy(fmode_str, "    ");
    if (host_os == OS)
        get_mode_str(fmode_str, (uint) file_mode);
    if (strlen(&filename[entry_pos]) > 12)
        printf("%-12s\n             ", &filename[entry_pos]);
    else
        printf("%-12s ", &filename[entry_pos]);
    printf("%10ld %10ld %u.%03u %s %08lX %4s%c%c%c%u%c%c%c\n",
        origsize, compsize, r / 1000, r % 1000, &date_str[2], file_crc,
        fmode_str, bckf[bckf_mode], mode[ftype], pthf[path_mode], method,
        pwdf[garble_mode], volf[volume_mode], extf[extfil_mode]);
}

static void
verb_start()
{
    printf("Ratio   Filename\n");
    printf("-----   --------------------------------------------------\n");
}

static void
verb_arc(count)
int count;
{
    uint r;

    if (count == 0)
        verb_start();

    r = ratio(compsize, origsize);
        
    printf("%u.%03u   %s\n",r/1000,r%1000,filename);
}

static void
execute_cmd()
{
    int file_count;
    char date_str[22];
    uint r;

    first_hdr_pos = 0;
    time_stamp = 0;
    first_hdr_size = FIRST_HDR_SIZE;

    arcfile = fopen_msg(arc_name, "rb");

    printf(M_PROCARC, arc_name);

    first_hdr_pos = find_header(arcfile);
    if (first_hdr_pos < 0)
        error(M_NOTARJ, arc_name);
    file_seek(arcfile, first_hdr_pos, SEEK_SET);
    if (!read_header(1, arcfile, arc_name))
        error(M_BADCOMNT, "");
    get_date_str(date_str, time_stamp);
    printf(M_ARCDATE, date_str);

    file_count = 0;
    while (read_header(0, arcfile, arc_name))
    {
        switch (command)
        {
        case 'E':
        case 'X':
            if (extract())
                file_count++;
            break;
        case 'L':
            list_arc(file_count++);
            skip();
            break;
        case 'V':
            verb_arc(file_count++);
            skip();
            break;
        case 'T':
            if (test())
                file_count++;
            break;
        }
    }

    if (command == 'L' || command=='V')
    {
        printf("------------ ---------- ---------- ----- -----------------\n");
        r = ratio(tcompsize, torigsize);
        printf(" %5d files %10ld %10ld %u.%03u %s\n",
            file_count, torigsize, tcompsize, r / 1000, r % 1000, &date_str[2]);
    }
    else
        printf(M_NBRFILES, file_count);

    fclose(arcfile);
}

static void
help()
{
    int i;

    for (i = 0; M_USAGE[i] != NULL; i++)
        printf(M_USAGE[i]);
}

int
main(argc, argv)
int  argc;
char *argv[];
{
    int i, j, lastc;
    char *arc_p;

#ifdef THINK_C
    argc = ccommand(&argv);
#endif

    printf(M_VERSION);

    if (argc == 1)
    {
        help();
        return EXIT_SUCCESS;
    }
    else if (argc == 2)
    {
        command = 'V';
        arc_p = argv[1];
    }
    else if ((argc == 3) || ((argc == 4) && (0 == strcmp(argv[3],"*.*"))))
    {
        if (strlen(argv[1]) > 1)
            error(M_BADCOMND, argv[1]);
        command = toupper(*argv[1]);
        if (strchr("ELVTX", command) == NULL)
            error(M_BADCOMND, argv[1]);
        arc_p = argv[2];
    }
    else
    {
        help();
        return EXIT_FAILURE;
    }

    strncopy(arc_name, arc_p, FNAME_MAX);
    case_path(arc_name);
    i = (int) strlen(arc_name);
    j = parse_path(arc_name, (char *)NULL, (char *)NULL);
    lastc = arc_name[i - 1];
    if (lastc == ARJ_DOT)
        arc_name[i - 1] = NULL_CHAR;
    else if (strchr(&arc_name[j], ARJ_DOT) == NULL)
        strcat(arc_name, M_SUFFIX);

    make_crctable();

    error_count = 0;
    clock_inx = 0;
    arcfile = NULL;
    outfile = NULL;

    execute_cmd();

    if (error_count > 0)
        error(M_ERRORCNT, "");

    return EXIT_SUCCESS;
}

/* end UNARJ.C */
