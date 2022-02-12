/*
 * tosdir - list TOS directories.
 * toswrite - write stdin to TOS-file
 * tosread - read TOS-file to stdout
 *
 * Author: Michiel Huisjes.
 *
 * Modified for TOS by: Jost Mueller
 * 
 * Usage: tosdir [-lR] drive [dir]
 *	  tos -d[lR] drive [dir]
 *	  tosread [-a] drive file
 *	  tos -r[a] drive file
 *	  toswrite [-a] drive file
 *	  tos -w[a] drive file
 * Options:	l: Give long listing.
 *		R: List recursively.
 *		a: Set ASCII bit.
 */
#define ATARI 1

#include <sys/types.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <sys/stat.h>

#undef	DEBUG

#define MAX_CLUSTER_SIZE	(1024*16)  /* 1024 for floppies, 16k for HDs */
#define MAX_ROOT_ENTRIES	512
#define FAT_START		(m_bps)	/* One sector after bootsector */
						/* 512L for floppies */
#define clus_add(cl_no)		((long) (((long) cl_no - 2L) \
					* (long) cluster_size \
					+ data_start \
				       ))

/*
 * Block 0 of a TOS media
 *	(media : floppy diskette or hard disk partion)
 * Contains media description and boot code
 */
struct block0 {
	unsigned char	b0_res0[8];
	unsigned char	b0_serial[3];
	unsigned char	b0_bps[2];
	unsigned char	b0_spc;
	unsigned char	b0_res[2];
	unsigned char	b0_nfats;
	unsigned char	b0_ndirs[2];
	unsigned char	b0_nsects[2];
	unsigned char	b0_media;
	unsigned char	b0_spf[2];
	unsigned char	b0_spt[2];
	unsigned char	b0_nsides[2];
	unsigned char	b0_nhid[2];
	unsigned char	b0_code[0x1e2];
};
struct	block0	block0;
/*
 * TOS media desciption
 */
unsigned short	m_bps;		/* bytes per sector */
unsigned short	m_spc;		/* sectors per cluster */
unsigned short	m_res;		/* reserved sectors */
unsigned short	m_nfats;	/* # of FATs */
unsigned short	m_ndirs;	/* # of directory entries */
unsigned short	m_nsects;	/* sectors per media */
unsigned short	m_spf;		/* sectors per FAT */
unsigned short	m_spt;		/* sectors per track; not valid for hard disk */
unsigned short	m_nsides;	/* sides per media; not valid for hard disk */
unsigned short	m_nhid;		/* # of hidden sectors; not valid for hard disk */

/* convert an 88-format short into a 68-format short */
#define	sh88tosh68(ch)	((short)(((ch)[1]<<8)|(ch)[0]))

struct dir_entry {
	unsigned char d_name[8];
	unsigned char d_ext[3];
	unsigned char d_attribute;
	unsigned char d_reserved[10];
	unsigned short d_time;
	unsigned short d_date;
	unsigned short d_cluster;
	unsigned long d_size;
};

typedef struct dir_entry DIRECTORY;

#define NOT_USED	0x00
#define ERASED		0xE5
#define DIR		0x2E
#define DIR_SIZE	(sizeof (struct dir_entry))
#define SUB_DIR		0x10
#define NIL_DIR		((DIRECTORY *) 0)

#define LAST_CLUSTER	((isHardDisk)?0xFFFF:0x0FFF)
#define MASK		((isHardDisk)?0xFFF8:0x0FF8)
#define FREE		0x0000
#define BAD		((isHardDisk)?0xFFF0:0x0FF0)

typedef char BOOL;

#define TRUE	1
#define FALSE	0
#define NIL_PTR	((char *) 0)

#define TOS_TIME	315532800L     /* 1970 - 1980 */

#define READ			0
#define WRITE			1
#define disk_read(s, a, b)	disk_io(READ, (s), (a), (short)(b))
#define disk_write(s, a, b)	disk_io(WRITE, (s), (a), (short)(b))
#define FIND	3
#define LABEL	4
#define ENTRY	5
#define find_entry(d, e, p)	directory(d, e, FIND, p)
#define list_dir(d, e, f)	(void) directory(d, e, f, NIL_PTR)
#define label()			directory(root68, root_entries, LABEL, NIL_PTR)
#define new_entry(d, e)		directory(d, e, ENTRY, NIL_PTR)

#define is_dir(d)		((d)->d_attribute & SUB_DIR)
#define isHardDisk		(device[5] == 'h')
#undef EOF
#define EOF			0400
#define EOF_MARK		'\032'
#define STD_OUT			1
#define flush()			print(STD_OUT, NIL_PTR, 0)

short		disk;
unsigned char*	fat;
DIRECTORY	root[MAX_ROOT_ENTRIES];
DIRECTORY	root68[MAX_ROOT_ENTRIES];
DIRECTORY	save_entry;
char		null[MAX_CLUSTER_SIZE];
char		device[128];
char		path[128];
long		mark;
short		total_clusters,
		cluster_size,
      		root_entries,
		sub_entries;
long		fat_size;
long		max_cluster;
long		data_start;

BOOL		R_flag, L_flag, A_flag, tos, tos_read, tos_write, tos_dir;


_PROTOTYPE(void usage, (char *prog_name));
_PROTOTYPE(void getMdescr, (void));
_PROTOTYPE(int main, (int argc, char *argv []));
_PROTOTYPE(DIRECTORY *directory, (DIRECTORY *dir, int entries, int function, char *pathname));
_PROTOTYPE(void extract, (DIRECTORY *entry));
_PROTOTYPE(void print, (int fd, char *buffer, int bytes));
_PROTOTYPE(void make_file, (DIRECTORY *dir_ptr, int entries, char *name));
_PROTOTYPE(void fill_date, (DIRECTORY *entry));
_PROTOTYPE(char *make_name, (DIRECTORY *dir_ptr, int dir_fl));
_PROTOTYPE(int fill, (char *buffer));
_PROTOTYPE(int get_char, (void));
_PROTOTYPE(char *lsbrk, (long l));
_PROTOTYPE(void modes, (unsigned int mode));
_PROTOTYPE(void show, (DIRECTORY *d_ptr, char *name));
_PROTOTYPE(void free_blocks, (void));
_PROTOTYPE(char *num_out, (long number));
_PROTOTYPE(void print_string, (int err_fl, char *fmt, ...));
_PROTOTYPE(void vprint_string, (int err_fl, char *fmt, char *args));
_PROTOTYPE(DIRECTORY *read_cluster, (unsigned int cluster));
_PROTOTYPE(unsigned short free_cluster, (int exit_fl));
_PROTOTYPE(void link_fat, (unsigned int cl_1, unsigned int cl_2));
_PROTOTYPE(unsigned short next_cluster, (unsigned int cl_no));
_PROTOTYPE(char *slash, (char *str));
_PROTOTYPE(void add_path, (char *file, int slash_fl));
_PROTOTYPE(void disk_iol, (int op, unsigned long seek, unsigned long address, unsigned long bytes));
_PROTOTYPE(void disk_io, (int op, unsigned long seek, DIRECTORY *address, unsigned int bytes));
_PROTOTYPE(void bad, (void));
_PROTOTYPE(void dir68, (DIRECTORY *d68, DIRECTORY *d88));
_PROTOTYPE(void dir88, (DIRECTORY *d88, DIRECTORY *d68));

void usage(prog_name)
register char *prog_name;
{
	char*	toscall=	"tos -";
	char*	dirpar=		"lR] drive [dir]";
	char*	rwpar=		"a] drive file";

	if( tos ){
		print_string(TRUE, "Usage:\t%s%s%s\n\t%s%s%s\n\t%s%s%s\n",
			toscall, "d[", dirpar,
			toscall, "r[", rwpar,
			toscall, "w[", rwpar
		);
	}else{
		print_string(TRUE, "Usage: %s [-%s\n", prog_name,
		     tos_dir ? dirpar : rwpar);
	}
	exit(1);
}

void getMdescr()
{
	int	bad=0;

	disk_read( 0L, (DIRECTORY *)&block0, sizeof( struct block0 ) );
	if (strncmp((char *)&block0.b0_res0[2], "MINIX ", 6) == 0) {
		print_string(TRUE, "This is a MINIX diskette\n");
		exit(1);
	}
	m_bps= sh88tosh68( block0.b0_bps );
	if( m_bps <= 0 ){
		bad= 1;
		print_string( TRUE, "%d bytes per sector\n", m_bps );
	}
	m_spc= (short)block0.b0_spc;
	if( m_spc <= 0 ){
		bad= 1;
		print_string( TRUE, "%d sectors per cluster\n", m_spc );
	}
	m_res= sh88tosh68( block0.b0_res );
	m_nfats= (short) block0.b0_nfats;
	if( m_nfats <= 0 ){
		bad= 1;
		print_string( TRUE, "%d fats\n", m_nfats );
	}
	m_ndirs= sh88tosh68( block0.b0_ndirs );
	if( m_ndirs <= 0 ){
		bad= 1;
		print_string( TRUE, "%d directory entries\n", m_ndirs );
	}
	m_nsects= sh88tosh68( block0.b0_nsects );
	if( m_nsects <= 0 ){
		bad= 1;
		print_string( TRUE, "%d sectors per volume\n", m_nsects );
	}
	m_spf= sh88tosh68( block0.b0_spf );
	if( m_spf <= 0 ){
		bad= 1;
		print_string( TRUE, "%d sectors per fat\n", m_spf );
	}
	if (!isHardDisk)
	{
		m_spt= sh88tosh68( block0.b0_spt );
		if( m_spt <= 0 ){
			bad= 1;
			print_string( TRUE, "%d sectors per track\n", m_spt );
		}
		m_nsides= sh88tosh68( block0.b0_nsides );
		m_nhid= sh88tosh68( block0.b0_nhid );
	}

	if( bad ){
		print_string(TRUE,
			"Improper volume descriptor.\nIs that a TOS volume?\n"
		);
		exit(1);
	}

	/* try to avoid accessing single and double sided floppies
	 * by wrong device */
	if( !isHardDisk )
		if( (device[5] == 'f' && m_nsides != 1)
			|| (device[5]== 'd' && m_nsides != 2 ) ) {
			print_string( TRUE,
				"%s-sided floppy: cannot accesses via %s.\n",
				(m_nsides==1)? "Single":"Double", device
			);
			exit(1);
		}
#ifdef	DEBUG
	print_string( TRUE, "bytes per sector: %L\n", (long)m_bps );
	print_string( TRUE, "sectors per cluster: %L\n", (long)m_spc );
	print_string( TRUE, "reserved sectors: %L\n", (long)m_res );
	print_string( TRUE, "# FATs: %L\n", (long)m_nfats );
	print_string( TRUE, "# directory entries: %L\n", (long)m_ndirs );
	print_string( TRUE, "# sectors on media: %L\n", (long)m_nsects );
	print_string( TRUE, "sectors per FAT: %L\n", (long)m_spf );
	print_string( TRUE, "sectors per track: %L\n", (long)m_spt );
	print_string( TRUE, "sides per media: %L\n", (long)m_nsides );
	print_string( TRUE, "hidden sectors: %L\n", (long)m_nhid );
#endif /* DEBUG */
}

int main(argc, argv)
int		argc;
register char	*argv[];
{
	register char *arg_ptr = slash(argv[0]);
	register int	i;
	DIRECTORY *entry;
	short index = 1;
	register char *drive;
	unsigned char fat_check;

	if (!strcmp(arg_ptr, "tos") ){
		tos = TRUE;
		if( argc > 1 && argv[1][0] == '-' )
			switch( argv[1][1] ){
			case 'd':
				tos_dir = TRUE;
				break;
			case 'r':
				tos_read = TRUE;
				break;
			case 'w':
				tos_write = TRUE;
				break;
			default:
				usage( arg_ptr );
			}
		else
			usage( arg_ptr );
	}else if (!strcmp(arg_ptr, "tosdir"))
		tos_dir = TRUE;
	else if (!strcmp(arg_ptr, "tosread"))
		tos_read = TRUE;
	else if (!strcmp(arg_ptr, "toswrite"))
		tos_write = TRUE;
	else {
		print_string(TRUE, "Program should be named tos, tosread, toswrite or tosdir.\n");
		exit(1);
	}

	if (argc == 1)
		usage(argv[0]);

	if (argv[1][0] == '-') {
		for (arg_ptr=(tos)?&argv[1][2]:&argv[1][1]; *arg_ptr; arg_ptr++) {
			if (*arg_ptr == 'l' && tos_dir)
				L_flag = TRUE;
			else if (*arg_ptr == 'R' && tos_dir)
				R_flag = TRUE;
			else if (*arg_ptr == 'a' && !tos_dir)
				A_flag = TRUE;
			else
				usage(argv[0]);
		}
		index++;
	}

	if (index == argc)
		usage(argv[0]);

	drive = argv[index++];
	if (*drive >= '0' && *drive <= '9')
		sprintf(device, "/dev/fd%c", *drive);
	else if (*drive == '/')
		strcpy(device, drive);
	else
		sprintf(device, "/dev/%s", drive);

	if ((disk = open(device, 2)) < 0) {
		print_string(TRUE, "Cannot open %s\n", device);
		exit(1);
	}

	getMdescr();
	total_clusters	= m_nsects / m_spc;
	cluster_size	= m_bps * m_spc;
	fat_size	= m_bps * m_spf;
	data_start	= ((	(long)m_ndirs * (long)sizeof(DIRECTORY)
				+ (long)fat_size * 2L

/* MSDOS positions the data start differently from ATARI;
   ATARI is always adjacent to the directory
 */

#if !ATARI
			  	+ ((long)cluster_size - 1L)
			   )	/(long)cluster_size
			  )	*(long)cluster_size;
	if( isHardDisk ){
		data_start += m_bps;	/* some heuristic */
	}
#else
			+ FAT_START));
#endif
	max_cluster	= total_clusters - (data_start/cluster_size) - 2;

	root_entries	= m_ndirs;	
	sub_entries	= cluster_size / 32;

	if( fat_size <= 0 ){
		print_string(TRUE,
			"Unusual fat_size %d.\nIs that a TOS volume?\n",
			fat_size
		);
		exit(1);
	}
	if( (fat= (unsigned char*)lsbrk( fat_size )) <= (unsigned char*)0 ){
		print_string(TRUE, "Can't set break!\n" );
		exit(1);
	}
	disk_iol(READ, FAT_START, (unsigned long)fat, fat_size);

#ifdef	DEBUG
	print_string( TRUE, "total_clusters: %L\n", (long)total_clusters );
	print_string( TRUE, "cluster_size: %L\n", (long)cluster_size );
	print_string( TRUE, "fat_size: %L\n", (long)fat_size );
	print_string( TRUE, "data_start: %L bytes (%L blocks)\n",
	  data_start, data_start/512 );
	print_string( TRUE, "root_entries: %L\n", (long)root_entries );
	print_string( TRUE, "sub_entries: %L\n", (long)sub_entries );
	print_string( TRUE, "fat type is %d\n", (int)sh88tosh68( &fat[0] ) );
	flush();
#endif /* DEBUG */

	disk_read(FAT_START + (long) fat_size, (DIRECTORY *)&fat_check, sizeof(fat_check));

	if (fat_check != fat[0]) {
		print_string(TRUE, "Disk type in FAT copy differs from disk type in FAT original.\n");
		print_string(TRUE, "copy=%x is=%x fat_size=%L FAT_START=%L\n",
			fat_check,fat[0],fat_size,FAT_START);
		exit(1);
	}

	if( root_entries > MAX_ROOT_ENTRIES ){
		print_string(TRUE,
			"Root directory too big.\nIs that a TOS volume?"
		);
		exit(1);
	}
	disk_read((FAT_START) + 2L * (long) fat_size, root, DIR_SIZE * root_entries);
	for( i= 0 ; i < root_entries ; i++ ){
		dir68( &root68[i], &root[i] );
	}

	if (tos_dir) {
		entry = label();
		print_string(FALSE, "Volume in drive %s ", device);
		if (entry == NIL_DIR)
			print(STD_OUT, "has no label.\n\n", 0);
		else
			print_string(FALSE, "is %S\n\n", entry->d_name);
	}

	if (argv[index] == NIL_PTR) {
		if (!tos_dir)
			usage(argv[0]);
		print(STD_OUT, "Root directory:\n", 0);
		list_dir(root68, root_entries, FALSE);
		free_blocks();
		flush();
		exit(0);
	}

	for (arg_ptr = argv[index]; *arg_ptr; arg_ptr++)
		if (*arg_ptr == '\\')
			*arg_ptr = '/';
		else if (*arg_ptr >= 'a' && *arg_ptr <= 'z')
			*arg_ptr += ('A' - 'a');
	if (*--arg_ptr == '/')
		*arg_ptr = '\0';       /* skip trailing '/' */

	add_path(argv[index], FALSE);
	add_path("/", FALSE);

	if (tos_dir)
		print_string(FALSE, "Directory %s:\n", path);

	entry = find_entry(root68, root_entries, argv[index]);

	if (tos_dir) {
		list_dir(entry, sub_entries, FALSE);
		free_blocks();
	}
	else if (tos_read)
		extract(entry);
	else {
		if (entry != NIL_DIR) {
			flush();
			if (is_dir(entry))
				print_string(TRUE, "%s is a directory.\n", path);
			else
				print_string(TRUE, "%s already exists.\n", argv[index]);
			exit(1);
		}

		add_path(NIL_PTR, TRUE);

		if (*path)
			make_file(find_entry(root68, root_entries, path),
				  sub_entries, slash(argv[index]));
		else
			make_file(root68, root_entries, argv[index]);
	}

	(void) close(disk);
	flush();
	return(0);
}

DIRECTORY *directory(dir, entries, function, pathname)
DIRECTORY *dir;
short entries;
int function;
register char *pathname;
{
	register DIRECTORY *dir_ptr = dir;
	DIRECTORY	*mem = NIL_DIR;
	DIRECTORY	*dp, *sp;
	DIRECTORY	*sd68;
	unsigned short	cl_no = dir->d_cluster;
	unsigned short	type, last;
	char 		file_name[14];
	char 		*name;
	int 		i = 0;

	if (function == FIND) {
		while (*pathname != '/' && *pathname && i < 12)
			file_name[i++] = *pathname++;
		while (*pathname != '/' && *pathname)
			pathname++;
		file_name[i] = '\0';
	}

	do {
		if (entries != root_entries) {
			mem = dir_ptr = read_cluster(cl_no);
			last = cl_no;
			cl_no = next_cluster(cl_no);

			if( (sd68 = (DIRECTORY *) sbrk(cluster_size) )<= (DIRECTORY *)NULL ){
				print_string(TRUE, "Can't set break!\n");
				exit(1);
			}
			sp= dir_ptr;
			i = cluster_size/sizeof(DIRECTORY);
			for( dp= sd68; dp < sd68 + i ; ){
				dir68( dp++, sp++ );
			}
			dir_ptr= sd68;
		}

		for (i = 0; i < entries; i++, dir_ptr++) {
			type = dir_ptr->d_name[0] & 0x0FF;
			if (function == ENTRY) {
				if (type == NOT_USED || type == ERASED) {
					mark = lseek(disk, 0L, 1) -
						(long) cluster_size +
						(long) i * (long) DIR_SIZE;
					if (!mem)
						mark += (long) cluster_size - (long) (root_entries * sizeof (DIRECTORY));
					return dir_ptr;
				}
				continue;
			}
			if (type == NOT_USED)
				break;
			if (dir_ptr->d_attribute & 0x08) {
				if (function == LABEL)
					return dir_ptr;
				continue;
			}
			if (type == DIR || type == ERASED || function == LABEL)
				continue;
			type = is_dir(dir_ptr);
			name = make_name(dir_ptr, (function == FIND) ?
					 FALSE : type);
			if (function == FIND) {
				if (strcmp(file_name, name) != 0)
					continue;
				if (!type) {
					if (tos_dir || *pathname) {
						flush();
						print_string(TRUE, "Not a directory: %s\n", file_name);
						exit(1);
					}
				}
				else if (*pathname == '\0' && tos_read) {
					flush();
					print_string(TRUE, "%s is a directory.\n", path);
					exit(1);
				}
				if (*pathname) {
					dir_ptr = find_entry(dir_ptr,
						   sub_entries, pathname + 1);
				}
				if (mem) {
					if (dir_ptr) {
						bcopy((char *)dir_ptr, (char *)&save_entry, DIR_SIZE);
						dir_ptr = &save_entry;
					}
					(void) brk((char *)mem);
				}
				return dir_ptr;
			}
			else {
				if (function == FALSE)
					show(dir_ptr, name);
				else if (type) {	/* Recursive */
					print_string(FALSE, "Directory %s%s:\n", path, name);
					add_path(name, FALSE);
					list_dir(dir_ptr, sub_entries, FALSE);
					add_path(NIL_PTR, FALSE);
				}
			}
		}
		if (mem)
			(void) brk((char *)mem);
	} while (cl_no != LAST_CLUSTER && mem);

	switch (function) {
		case FIND:
			if (tos_write && *pathname == '\0')
				return NIL_DIR;
			flush();
			print_string(TRUE, "Cannot find `%s'.\n", file_name);
			exit(1);
		case LABEL:
			return NIL_DIR;
		case ENTRY:
			if (!mem) {
				flush();
				print_string(TRUE, "No entries left in root directory.\n");
				exit(1);
			}

			cl_no = free_cluster(TRUE);
			link_fat(last, cl_no);
			link_fat(cl_no, LAST_CLUSTER);
			disk_write(clus_add(cl_no), (DIRECTORY *)null, cluster_size);

			return new_entry(dir, entries);
		case FALSE:
			if (R_flag) {
				print(STD_OUT, "\n", 0);
				list_dir(dir, entries, TRUE);
			}
	}
	return NIL_DIR;
}

void extract(entry)
register DIRECTORY *entry;
{
	register unsigned short cl_no = entry->d_cluster;
	char buffer[MAX_CLUSTER_SIZE];
	short rest;

	if (entry->d_size == 0)	       /* Empty file */
		return;

	do {
		disk_read(clus_add(cl_no), (DIRECTORY *)buffer, cluster_size);
		rest = (entry->d_size > (long) cluster_size) ? cluster_size : (short) entry->d_size;
		print(STD_OUT, buffer, rest);
		entry->d_size -= (long) rest;
		cl_no = next_cluster(cl_no);
		if (cl_no == BAD) {
			flush();
			print_string(TRUE, "Reserved cluster value encountered.\n");
			exit(1);
		}
	} while (entry->d_size && cl_no != LAST_CLUSTER);

	if (cl_no != LAST_CLUSTER)
		print_string(TRUE, "Too many clusters allocated for file.\n");
	else if (entry->d_size != 0)
		print_string(TRUE, "Premature EOF: %L bytes left.\n",
			     entry->d_size);
}

void print(fd, buffer, bytes)
int fd;
register char *buffer;
register short bytes;
{
	static short index;
	static BOOL lf_pending = FALSE;
	static char output[MAX_CLUSTER_SIZE + 1];

	if (buffer == NIL_PTR) {
		if (tos_read && A_flag && lf_pending) {
			output[index++] = '\r';
			lf_pending = FALSE;
		}
		if (write(fd, output, index) != index) {
			print_string(TRUE,"Failed: write(%d,%L,%L)\n",
				fd,(long)output,(long)index);
			bad();
		}
		index = 0;
		return;
	}

	if (bytes == 0)
		bytes = strlen(buffer);

	while (bytes--) {
		if (index >= MAX_CLUSTER_SIZE) {
			if (write(fd, output, index) != index)
				bad ();
			index = 0;
		}
		if (tos_read && A_flag) {
			if (*buffer == '\r') {
				if (lf_pending)
					output[index++] = *buffer++;
				else {
					lf_pending = TRUE;
					buffer++;
				}
			}
			else if (*buffer == '\n') {
				output[index++] = *buffer++;
				lf_pending = FALSE;
			}
			else if (lf_pending) {
				output[index++] = '\r';
				output[index++] = *buffer++;
			}
			else if ((output[index++] = *buffer++) == EOF_MARK) {
				if (lf_pending) {
					output[index - 1] = '\r';
					index++;
					lf_pending = FALSE;
				}
				index--;
				return;
			}
		}
		else
			output[index++] = *buffer++;
	}
}

void make_file(dir_ptr, entries, name)
DIRECTORY	*dir_ptr;
int		entries;
char		*name;
{
	register DIRECTORY	*entry = new_entry(dir_ptr, entries);
	DIRECTORY		entry88;
	register char		*ptr;
	char			buffer[MAX_CLUSTER_SIZE];
	unsigned short		cl_no,
				next;
	short			i,
				r;
	long			size = 0L;

	bcopy("           ",(char *)&entry->d_name[0],11);	/* clear entry */
	for (i = 0, ptr = name; i < 8 && *ptr != '.' && *ptr; i++)
		entry->d_name[i] = *ptr++;
	while (*ptr != '.' && *ptr)
		ptr++;
	if (*ptr == '.')
		ptr++;
	for (i=0;i < 3 && *ptr; i++){
		if( *ptr == '.' ){
			print_string(TRUE, "Extension must not contain '.' !\n" );
			exit(1);
		}
		entry->d_ext[i] = *ptr++;
	}
	for (i = 0; i < 10; i++)
		entry->d_reserved[i] = '\0';
	entry->d_attribute = '\0';

	entry->d_cluster = 0;

	while ((r = fill(buffer)) > 0) {
		if ((next = free_cluster(FALSE)) > total_clusters) {
			print_string(TRUE, "Diskette full. File truncated.\n");
			break;
		}

		disk_write(clus_add(next), (DIRECTORY *)buffer, r);

		if (entry->d_cluster == 0)
			cl_no = entry->d_cluster = next;
		else {
			link_fat(cl_no, next);
			cl_no = next;
		}

		size += r;
	}

	if (entry->d_cluster != 0)
		link_fat(cl_no, LAST_CLUSTER);

	entry->d_size = A_flag ? (size - 1) : size;	/* Strip added ^Z */
	fill_date(entry);
	dir88( &entry88, entry );
	disk_write(mark, &entry88, DIR_SIZE);
	disk_write(FAT_START, (DIRECTORY *)fat, fat_size);
	disk_write(FAT_START + (long) fat_size, (DIRECTORY *)fat, fat_size);
/*???	where are the other fat copies on a hard disk? */
}


#define SEC_MIN	60L
#define SEC_HOUR	(60L * SEC_MIN)
#define SEC_DAY	(24L * SEC_HOUR)
#define SEC_YEAR	(365L * SEC_DAY)
#define SEC_LYEAR	(366L * SEC_DAY)

short mon_len[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

void fill_date(entry)
DIRECTORY *entry;
{
	register long cur_time = time((long *) 0) - TOS_TIME;
	unsigned short year = 0, month = 1, day, hour, minutes, seconds;
	int i;
	long tmp;

	if (cur_time < 0)	       /* Date not set on booting ... */
		cur_time = 0;
	for (;;) {
		tmp = (year % 4 == 0) ? SEC_LYEAR : SEC_YEAR;
		if (cur_time < tmp)
			break;
		cur_time -= tmp;
		year++;
	}

	day = (unsigned short) (cur_time / SEC_DAY);
	cur_time -= (long) day *SEC_DAY;

	hour = (unsigned short) (cur_time / SEC_HOUR);
	cur_time -= (long) hour *SEC_HOUR;

	minutes = (unsigned short) (cur_time / SEC_MIN);
	cur_time -= (long) minutes *SEC_MIN;

	seconds = (unsigned short) cur_time;

	mon_len[1] = (year % 4 == 0) ? 29 : 28;
	i = 0;
	while (day >= mon_len[i]) {
		month++;
		day -= mon_len[i++];
	}
	day++;

	entry->d_date = (year << 9) | (month << 5) | day;
	entry->d_time = (hour << 11) | (minutes << 5) | seconds;
}

char *make_name(dir_ptr, dir_fl)
register DIRECTORY *dir_ptr;
short dir_fl;
{
	static char name_buf[14];
	register char *ptr = name_buf;
	short i;

	for (i = 0; i < 8; i++)
		*ptr++ = dir_ptr->d_name[i];

	while (*--ptr == ' ');

	ptr++;
	if (dir_ptr->d_ext[0] != ' ') {
		*ptr++ = '.';
		for (i = 0; i < 3; i++)
			*ptr++ = dir_ptr->d_ext[i];
		while (*--ptr == ' ');
		ptr++;
	}
	if (dir_fl)
		*ptr++ = '/';
	*ptr = '\0';

	return name_buf;
}

int fill(buffer)
register char *buffer;
{
	static BOOL eof_mark = FALSE;
	char *last = &buffer[cluster_size];
	char *begin = buffer;
	register short c;

	if (eof_mark)
		return 0;

	while (buffer < last) {
		if ((c = get_char()) == EOF) {
			eof_mark = TRUE;
			if (A_flag)
				*buffer++ = EOF_MARK;
			break;
		}
		*buffer++ = c;
	}

	return (int) (buffer - begin);
}

int get_char()
{
	static short read_chars, index;
	static char input[MAX_CLUSTER_SIZE];
	static BOOL new_line = FALSE;

	if (new_line == TRUE) {
		new_line = FALSE;
		return '\n';
	}

	if (index == read_chars) {
		if ((read_chars = read(0, input, cluster_size)) == 0)
			return EOF;
		index = 0;
	}

	if (A_flag && input[index] == '\n') {
		new_line = TRUE;
		index++;
		return '\r';
	}

	return input[index++];
}

#define HOUR	0xF800		       /* Upper 5 bits */
#define MIN	0x07E0		       /* Middle 6 bits */
#define YEAR	0xFE00		       /* Upper 7 bits */
#define MONTH	0x01E0		       /* Mid 4 bits */
#define DAY	0x01F		       /* Lowest 5 bits */

char *month[] = {
		 "Jan", "Feb", "Mar", "Apr", "May", "Jun",
		 "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
};

/* sbrk is defined as accepting a signed int.  passing it a number > 2^15
 * causes it to release memory. 
 * Thus, lsbrk calls sbrk multiple times.
 */
char *
lsbrk(l)
long l;
{
	char *cp,*r;
	short sl;

	cp = sbrk(0);
	while(l) {
		sl = l>0x7ff0L?0x7ff0:l;
		if((r=sbrk(sl)) <= (char*)0)
			return(r);
		l -= sl;
	}
	return(cp);	
}

void modes(mode)
register unsigned int mode;
{
	print_string(FALSE, "\t%c%c%c%c%c", (mode & SUB_DIR) ? 'd' : '-',
		     (mode & 02) ? 'h' : '-', (mode & 04) ? 's' : '-',
		     (mode & 01) ? '-' : 'w', (mode & 0x20) ? 'a' : '-');
}

void show(d_ptr, name)
DIRECTORY *d_ptr;
char *name;
{
	register unsigned short e_date;
	register unsigned short e_time;
	unsigned short next;
	char bname[20];
	short i = 0;
	DIRECTORY	*dir_ptr;

	dir_ptr= d_ptr;

	while (*name && *name != '/')
		bname[i++] = *name++;
	bname[i] = '\0';
	if (!L_flag) {
		print_string(FALSE, "%s\n", bname);
		return;
	}
	modes(dir_ptr->d_attribute);
	print_string(FALSE, "\t%s%s", bname, strlen(bname) < 8 ? "\t\t" : "\t");
	i = 1;
	if (is_dir(dir_ptr)) {
		next = dir_ptr->d_cluster;
		while ((next = next_cluster(next)) != LAST_CLUSTER){
			i++;
		}
		print_string(FALSE, "%L", (long) i * (long) cluster_size);
	}
	else
		print_string(FALSE, "%L", dir_ptr->d_size);

	e_date= dir_ptr->d_date;
	e_time= dir_ptr->d_time;
	if ((e_date & MONTH) == 0) e_date = 0x21; /* 1 jan 1980 */
	print_string(FALSE, "\t%N:%N %P %s %d\n", (int)((e_time & HOUR) >> 11),
		     (int)((e_time & MIN) >> 5), (int)(e_date & DAY),
	   month[((e_date & MONTH) >> 5) - 1], (int)((e_date & YEAR) >> 9) + 1980);
}

void free_blocks()
{
	register short cl_no;
	register unsigned short nxt;
	register short free = 0;
	short bad = 0;

	for (cl_no = 2; cl_no <= total_clusters; cl_no++) {
		switch (nxt= next_cluster(cl_no)) {
			case FREE:
				free++;
				break;
/*			case BAD: */
			case 0xFFF0:
			case 0x0FF0:
				if( nxt == BAD )
					bad++;
		}
	}

	print_string(FALSE, "Free space: %L bytes.\n", (long) free * (long) cluster_size);
	if (bad)
		print_string(FALSE, "Bad sectors: %L bytes.\n", (long) bad * (long) cluster_size);
}

char *num_out(number)
register long number;
{
	static char num_buf[13];
	char temp[13];
	register short i = 0;
	short j;

	if (number == 0)
		temp[i++] = '0';

	if(number < 0L) {
		temp[i++] = '-';
		number = 0 - number;
	}
	while (number) {
		temp[i++] = (char) (number % 10L + '0');
		number /= 10L;
	}

	for (j = 0; j < 11; j++)
		num_buf[j] = temp[i - j - 1];

	num_buf[i] = '\0';
	return num_buf;
}

#ifdef __STDC__
void print_string(int err_fl, char *fmt, ...)
{
   va_list args;

   va_start(args, fmt);
   vprint_string(err_fl, fmt, args);
   va_end(args);
}
#else
#define vprint_string print_string
#endif

/* VARARGS */
void vprint_string(err_fl, fmt, args)
int err_fl;
char *fmt;
char *args;
{
	char buf[200];
	register char *buf_ptr = buf;
	char *scan_ptr;
			/* hier stand &args, m.E. falsch! (VS 2002/07/26) */
	register char *arg_ptr = (char*)args;
	short i;

	while (*fmt) {
		if (*fmt == '%') {
			fmt++;
			if (*fmt == 'c') {
				*buf_ptr++ = *(arg_ptr+1);
				arg_ptr += sizeof(int);
				fmt++;
				continue;
			}
			if (*fmt == 'S') {
				scan_ptr = *((char **)arg_ptr);
				arg_ptr += sizeof(char *);
				for (i = 0; i < 11; i++)
					*buf_ptr++ = *scan_ptr++;
				fmt++;
				continue;
			}
			if (*fmt == 's') {
				scan_ptr = *((char **)arg_ptr);
				arg_ptr += sizeof(char *);
			} else if (*fmt == 'L') {
				scan_ptr = num_out(*((long *) arg_ptr));
				arg_ptr += sizeof(long);
			}
			else {
				scan_ptr = num_out((long) *((int *)arg_ptr));
				if (*fmt == 'P' && *((int *)arg_ptr) < 10)
					*buf_ptr++ = ' ';
				else if (*fmt == 'N' && *((int *)arg_ptr) < 10)
					*buf_ptr++ = '0';
				arg_ptr += sizeof(int);
			}
			while (*buf_ptr++ = *scan_ptr++);
			buf_ptr--;
			fmt++;
		}
		else
			*buf_ptr++ = *fmt++;
	}

	*buf_ptr = '\0';

	if (err_fl) {
		flush();
		write(2, buf, (int) (buf_ptr - buf));
	}
	else
		print(STD_OUT, buf, 0);
}

DIRECTORY *read_cluster(cluster)
register unsigned int cluster;
{
	register DIRECTORY *sub_dir;

	if( (long)cluster > max_cluster || (long) cluster < 2 ){
		print_string(TRUE,"read_cluster(%L) - not in range.\n", (long)cluster );
		exit(1);
	}
	if ((sub_dir = (DIRECTORY *) sbrk(cluster_size)) <= (DIRECTORY *)NULL) {
		print_string(TRUE, "Cannot set break!\n");
		exit(1);
	}
	disk_read(clus_add(cluster), sub_dir, cluster_size);
	return sub_dir;
}

unsigned short free_cluster(exit_fl)
int exit_fl;
{
	static short cl_index = 2;

	while (cl_index <= total_clusters && next_cluster(cl_index) != FREE)
		cl_index++;

	if (exit_fl && cl_index > total_clusters) {
		flush();
		print_string(TRUE, "Diskette full. File not added.\n");
		exit(1);
	}

	return (unsigned short)cl_index++;
}

void link_fat(cl_1, cl_2)
unsigned int cl_1;
register unsigned int cl_2;
{
	register unsigned char *fat_index = &fat[(cl_1 >> 1) * 3 + 1];

	if ( !isHardDisk ){
		if (cl_1 & 0x01) {
			*(fat_index + 1) = cl_2 >> 4;
			*fat_index = (*fat_index & 0x0F) | ((cl_2 & 0x0F) << 4);
		}else {
			*(fat_index - 1) = cl_2 & 0x0FF;
			*fat_index = (*fat_index & 0xF0) | (cl_2 >> 8);
		}
	}else{
		fat_index= &fat[cl_1 * 2];
		*(fat_index+1) = cl_2>>8;
		*fat_index = cl_2;
	}
}

unsigned short next_cluster(cl_no)
register unsigned int cl_no;
{
	register unsigned char *fat_index = &fat[(cl_no>>1)*3 + 1];

	if( !isHardDisk ){
		if (cl_no & 0x01)
			cl_no = (*(fat_index + 1) << 4) | (*fat_index >> 4);
		else
			cl_no = ((*fat_index & 0x0F) << 8) | *(fat_index - 1);
	}else{
		fat_index= &fat[cl_no*2];
		cl_no= *(fat_index+1)<<8 | *fat_index;
	}

	if ((cl_no & MASK) == MASK)
		cl_no = LAST_CLUSTER;
	else if ((cl_no & BAD) == BAD)
		cl_no = BAD;

	return cl_no;
}

char *slash(str)
register char *str;
{
	register char *result = str;

	while (*str)
		if (*str++ == '/')
			result = str;

	return result;
}

void add_path(file, slash_fl)
register char *file;
int slash_fl;
{
	register char *ptr = path;

	while (*ptr)
		ptr++;

	if (file == NIL_PTR) {
		ptr--;
		do {
			ptr--;
		} while (*ptr != '/' && ptr != path);
		if (ptr != path && !slash_fl)
			ptr++;
		*ptr = '\0';
	}
	else
		while (*ptr++ = *file++);
}

/* Break up the reads in to something less than 2^15 */

void disk_iol(op, seek, address, bytes)
register int op;
unsigned long seek;
unsigned long address;
register unsigned long bytes;
{
	unsigned short shbytes;
	while(bytes) {
		shbytes = bytes > 0x7ff0L? 0x7ff0: bytes;
		disk_io(op,seek,(DIRECTORY *)address,shbytes);
		seek += shbytes;
		address += shbytes;
		bytes -= shbytes;
	}
}

void disk_io(op, seek, address, bytes)
register int op;
unsigned long seek;
DIRECTORY *address;
register unsigned int bytes;
{
	unsigned int r;

#ifdef DEBUG
print_string(TRUE,"%s: seek=%L block=%d size=%d\n",
 (op==READ?"READ":"WRITE"),
 seek,(int)(seek>>9),(int)(bytes>>9));
#endif

	if (lseek(disk,(long) seek, 0) == (off_t)-1) {
		flush();
		print_string(TRUE, "Bad lseek\n");
		exit(1);
	}

	if (op == READ){
		r = read(disk, (char *)address, bytes);
	}else{
		r = write(disk, (char *)address, bytes);
	}
	if (r != bytes){
		print_string(TRUE,"Failed r/w (%d,%L,%L)\n",
			disk,(long)address,(long)bytes);
		bad();
	}
}

void bad()
{
	flush();
	perror("I/O error");
	exit(1);
}

/*
 * Convert the TOS directory structure
 * as it is on the volumes
 * into a format convient for the C program on a 68k
 * and vice versa
 */

void dir68( d68, d88 )
	DIRECTORY	*d68;
	DIRECTORY	*d88;
{
	char	*sp;	/* source byte */
	char	*dp;	/* destination byte */

	/* name, extension, attribute and reserved are ok */
	dp= (char*) d68;
	sp= (char*) d88;
	while( dp < (char*) &(d68->d_time) )
		*dp++= *sp++;

	dp= (char*) &(d68->d_time);
	sp= (char*) &(d88->d_time);
	dp[0]= sp[1];
	dp[1]= sp[0];

	dp= (char*) &(d68->d_date);
	sp= (char*) &(d88->d_date);
	dp[0]= sp[1];
	dp[1]= sp[0];

	dp= (char*) &(d68->d_cluster);
	sp= (char*) &(d88->d_cluster);
	dp[0]= sp[1];
	dp[1]= sp[0];

	dp= (char*) &(d68->d_size);
	sp= (char*) &(d88->d_size);
	dp[0]= sp[3];
	dp[1]= sp[2];
	dp[2]= sp[1];
	dp[3]= sp[0];
}

void dir88( d88, d68 )
	DIRECTORY	*d88;
	DIRECTORY	*d68;
{
	char	*sp;	/* source byte */
	char	*dp;	/* destination byte */

	/* name, extension, attribute and reserved are ok */
	dp= (char*) d88;
	sp= (char*) d68;
	while( dp < (char*) &(d88->d_time) )
		*dp++= *sp++;

	dp= (char*) &(d88->d_time);
	sp= (char*) &(d68->d_time);
	dp[0]= sp[1];
	dp[1]= sp[0];

	dp= (char*) &(d88->d_date);
	sp= (char*) &(d68->d_date);
	dp[0]= sp[1];
	dp[1]= sp[0];

	dp= (char*) &(d88->d_cluster);
	sp= (char*) &(d68->d_cluster);
	dp[0]= sp[1];
	dp[1]= sp[0];

	dp= (char*) &(d88->d_size);
	sp= (char*) &(d68->d_size);
	dp[0]= sp[3];
	dp[1]= sp[2];
	dp[2]= sp[1];
	dp[3]= sp[0];
}
