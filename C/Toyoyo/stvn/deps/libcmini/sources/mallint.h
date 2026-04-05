/* definitions needed in malloc.c and realloc.c */

#define MALLOC_DEBUG 0
#if MALLOC_DEBUG
#include <mint/arch/nf_ops.h>
#endif

struct mem_chunk
{
	unsigned long valid;
#define VAL_FREE  0xf4ee0abcL
#define VAL_ALLOC 0xa11c0abcL
#define VAL_SBRK  0xb04d0abcUL

	struct mem_chunk *next;
	struct mem_chunk *prev;
	unsigned long size;
	/* unsigned long alloc_size; */
};

#define MALLOC_ALIGNMENT 4
#define ALLOC_EXTRA ((sizeof(struct mem_chunk) + MALLOC_ALIGNMENT - 1) & ~(MALLOC_ALIGNMENT - 1))

#define SBRK_EXTRA ((sizeof(struct mem_chunk) + sizeof(size_t) + (MALLOC_ALIGNMENT - 1)) & ~(MALLOC_ALIGNMENT - 1))
#define SBRK_SIZE(ch) (*(size_t *)((char *)(ch) + sizeof(*(ch))))

/* linked list of free blocks */
extern struct mem_chunk _mchunk_free_list;

void __mallocChunkSize(size_t siz);
