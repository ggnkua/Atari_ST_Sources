/*
 *  libshare: a dirty patch to make LDG compiled against mintlib shareable
 *
 *  by Arnaud BERCEGEAY (Feb 2004)
 */

int     _enoent (const char *);

extern int __libc_unix_names;
extern void *_heapbase;
extern short _split_mem;
extern long _stksize;

/* definitions needed in malloc.c and realloc.c */

struct mem_chunk 
{
	long valid;
#define VAL_FREE  0xf4ee0abcL
#define VAL_ALLOC 0xa11c0abcL
#define VAL_BORDER 0xb04d0abcL

	struct mem_chunk *next;
	unsigned long size;
};
#define ALLOC_SIZE(ch) (*(long *)((char *)(ch) + sizeof(*(ch))))
#define BORDER_EXTRA ((sizeof(struct mem_chunk) + sizeof(long) + 7) & ~7)

/* [libshare] use "libshare" _mchunk_free_list instead of the one from
 *  mintlib */
#define _mchunk_free_list libshare_mchunk_free_list

/* linked list of free blocks */
extern struct mem_chunk _mchunk_free_list;


/*   [libshare] 
 *   memory block as static array for sbrk() at startup
 */
extern char static_mblock[];
