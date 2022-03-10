
/* NMALLOC.C			New-malloc		*/

/* Nach einer Idee von Hans-JÅrgen Richstein aus ST-Computer 11/1990 p. 140 ff
	Die Routinen ersetzen jetzt die malloc/free/realloc... vollstaendig!
	Es wird der TOS-Speicher minus 50 KB in TCSMALL reserviert. Der Speicher
	wird dann selbst verwaltet. Dieser Code ist etwa doppelt so schnell wie
	der orginal Turbo-C (2.03) malloc-code in STDLIB.
	NMALLOC muss unmittlebar vor STDLIB gelinkt werden (siehe PRJ-Datei), da
	malloc auch aus der STDLIB von einigen funktionen PC-relativ aufgerufen
	wird.
*/
/* keine #include <..> !! */

/* size_t ist in mehreren Headerfiles wie folgt definiert:		*/
typedef unsigned long	size_t;

/*	Das Konstanten-Makro NULL ist in STDDEF.H deklariert:			*/
#define NULL        ( ( void * ) 0L )

/* init_mem wird von TCSMALL (Startup-code) aufgerufen. */
size_t init_mem(void *start_adress, size_t size);

/* Erweiterungen gegen Turbo-C */
size_t total_coreleft(void);
size_t n_of_fragments(void);

/* Wie in ext.h definiert:
	ermittelt den grîûten zur VerfÅgung stehenden Speicherblock		*/
size_t coreleft(void);

/* Wie Prototypen in stdlib.h:			*/
void free( void *ptr );
void *malloc(size_t size);
void *calloc ( size_t nitems, size_t size );
void *realloc(void *block, size_t newsize);

/* Funktionen aus string.h, Gruppe Speichermanipulation	*/
void *memset(void *s, int val, size_t len);
void *memcpy(void *dest, const void *src, size_t len);


/* Jetzt geht's richtig zur Sache.. */

#define MEM_BLOCK struct memory_header

MEM_BLOCK
{
	MEM_BLOCK *next;
	size_t size;
	char data[];
};

typedef struct
{
	size_t size;
	int mark;
	char user_block[];
} LARGE_BLOCK;

typedef struct
{
	unsigned int size;
	char user_block[];
} SMALL_BLOCK;

static MEM_BLOCK head;

static char *start_of_buffer,
				*end_of_buffer;


static void* make_user_block(MEM_BLOCK *block, size_t block_size)
{
	if(block_size > 0xFFFF)
	{
		((LARGE_BLOCK*) block)->size = block_size;
		((LARGE_BLOCK*) block)->mark = 0;
		return (void*) &(((LARGE_BLOCK*) block)->user_block);
	}
	else
	{
		((SMALL_BLOCK*) block)->size = (unsigned int)block_size;
		return (void*) &(((SMALL_BLOCK*) block)->user_block);
	}
}

static size_t actual_size(size_t desired_size)
{
	size_t size;
	if(desired_size & 1L) desired_size+=3;
	else desired_size+=2;
	size = desired_size + 
		((desired_size < 0xFFFEL) ? sizeof(SMALL_BLOCK) : sizeof(LARGE_BLOCK));
	if(size < sizeof(MEM_BLOCK)) size = sizeof(MEM_BLOCK);
	return size;
}

static void get_block_data(void *block, MEM_BLOCK **block_start,
			size_t *block_size, size_t *size_of_user_data)
{
	if(*((int *) block-1) ==0)
	{
		*block_start = (MEM_BLOCK *)((LARGE_BLOCK*) block-1);
		*block_size = ((LARGE_BLOCK *)*block_start)->size;
		*size_of_user_data = *block_size - sizeof(LARGE_BLOCK);
	}
	else
	{
		*block_start = (MEM_BLOCK *)((SMALL_BLOCK*) block-1);
		*block_size = ((SMALL_BLOCK *)*block_start)->size;
		*size_of_user_data = *block_size - sizeof(SMALL_BLOCK);
	}
}

static MEM_BLOCK *find_previous_block(MEM_BLOCK *block)
{
	MEM_BLOCK *previous;
	previous = &head;
	while((previous->next < block) && (previous->next != NULL))
		previous = previous->next;
	return previous;
}

static void *shrink_block(void *block, size_t old_size, size_t new_size)
{
	if(old_size - new_size >= sizeof(MEM_BLOCK))
	{
		free(make_user_block((MEM_BLOCK *)((char*)block + new_size),old_size - new_size));
		return make_user_block(block,new_size);
	}
	else
	return make_user_block(block,old_size);
}

static void split_block(MEM_BLOCK *block, size_t size_of_first)
{
	MEM_BLOCK *second_block;
	second_block = (MEM_BLOCK*)(((char*)block) + size_of_first);
	second_block->next = block->next;
	second_block->size = block->size - size_of_first;
	block->size = size_of_first;
	block->next = second_block;
}

static size_t insert_into_list(MEM_BLOCK *block, size_t size)
{
	MEM_BLOCK *previous, *following;
	previous = find_previous_block(block);
	following = previous->next;
	if(((following != NULL) && ((MEM_BLOCK*)((char*)block + size) > following))
			|| (size < sizeof(MEM_BLOCK))
			||	(block < (MEM_BLOCK*)((char*)previous + previous->size))
			||	(((char*)block < start_of_buffer) || ((char*)block + size > end_of_buffer)))
	{
		return -1;
	}
	else
	{
		block->size = size;
		if((MEM_BLOCK*)((char*) previous + previous->size) == block)
		{
			previous->size += size;
			block = previous;
		}
		else
		{
			block->size = size;
			block->next = following;
			previous->next = block;
		}
		if((MEM_BLOCK*)((char*)block + block->size) == following)
		{
			block->size += following->size;
			block->next = following->next;
		}
		return 0;
	}
}

static void remove_from_list(MEM_BLOCK *block)
{
	MEM_BLOCK *previous;
	previous = find_previous_block(block);
	previous->next = block->next;
}
				
size_t init_mem(void *start_adress, size_t size)
{
	if((size < sizeof(MEM_BLOCK)) || (start_adress == NULL)) return -1;
	else
	{
		((MEM_BLOCK *) start_adress)->next = NULL;
		((MEM_BLOCK *) start_adress)->size = size;
		head.next = (MEM_BLOCK *) start_adress;
		start_of_buffer = (char *) start_adress;
		end_of_buffer = (char *) start_adress + size;
		head.size = 0;
		return 0;
	}
}

void *malloc(size_t size)
{
	MEM_BLOCK *current_block, *previous_block;
	void *desired_block;
	size_t allocated_size;
	
	desired_block = NULL;
	if(size >= 0)
	{
		allocated_size = actual_size(size);
		current_block = head.next;
		previous_block = &head;
		while((current_block != NULL) && (current_block->size < allocated_size))
		{
			previous_block=current_block;
			current_block=current_block->next;
		}
		if(current_block != NULL)
		{
			if(current_block->size - allocated_size < sizeof(MEM_BLOCK))
				allocated_size = current_block->size;
			else split_block(current_block, allocated_size);
			previous_block->next=current_block->next;
			desired_block = make_user_block(current_block,allocated_size);
		}
	}
	return desired_block;
}

void *calloc ( size_t nitems, size_t size )
{
	void *block;
	size_t total_size;
	
	total_size = nitems * size;
	block = malloc(total_size);
	if(block != NULL) memset(block,0,total_size);
	return block;
}

void *realloc(void *block, size_t newsize)
{
	MEM_BLOCK *returned_block,
				 *previous,
				 *following;
	void *temp_block;
	size_t	current_size,
				size_of_realloc,
				size_of_enlarge,
				data_size;

	size_of_realloc = actual_size(newsize);
	if((block != NULL) && (size_of_realloc >= sizeof(MEM_BLOCK)))
	{
		get_block_data(block,&returned_block,&current_size,&data_size);
		if(size_of_realloc > current_size)
		{
			previous = find_previous_block(returned_block);
			following = previous->next;
			if(((char *) returned_block + current_size == (char*) following)
				&& (current_size + following->size >= size_of_realloc))
			{
				size_of_enlarge = current_size + following->size;
				previous->next=following->next;
				if((current_size < 0xFFFF) && (size_of_realloc > 0xFFFF))
					memcpy((char*)block + sizeof(LARGE_BLOCK) - sizeof(SMALL_BLOCK),
								block, data_size);
				block =shrink_block(returned_block,size_of_enlarge,size_of_realloc);
			}
			else
			if(((char*) returned_block == (char*) previous + previous->size)
					&& (current_size + previous->size >= size_of_realloc))
			{
				size_of_enlarge = current_size + previous->size;
				remove_from_list(previous);
				temp_block = block;
				block = make_user_block(previous, size_of_realloc);
				memcpy(block,temp_block,data_size);
				shrink_block(previous,size_of_enlarge,size_of_realloc);
			}
			else
			if(((char*) returned_block + current_size == (char*)following)
					&& ((char*) returned_block == (char*)previous + previous->size)
					&& (current_size + previous->size + following->size >= size_of_realloc))
			{
				size_of_enlarge = current_size + previous->size + following->size;
				previous->next = following->next;
				remove_from_list(previous);
				temp_block = block;
				block = make_user_block(previous,size_of_realloc);
				memcpy(block,temp_block,data_size);
				shrink_block(previous,size_of_enlarge,size_of_realloc);
			}
			else
			{
				temp_block = block;
				block = malloc(newsize);
				if(block != NULL)
				{
					memcpy(block,temp_block,data_size);
					free(temp_block);
				}
			}
		}
		else
		if(size_of_realloc < current_size)
		{
			if((current_size > 0xFFFF) && (size_of_realloc < 0xFFFF))
			{
				memcpy( ((LARGE_BLOCK*)returned_block)->user_block,
							block,data_size);
			}
			shrink_block(returned_block,current_size,size_of_realloc);
		}
		}
	return block;
}

void free(void *ptr)
{
	MEM_BLOCK *returned_block;
	size_t size, dummy;
	
	if(ptr != NULL)
	{
		get_block_data(ptr,&returned_block,&size,&dummy);
		insert_into_list(returned_block,size);
	}
}

size_t coreleft(void)
{
	MEM_BLOCK *block;
	size_t size_of_largest;

	block = head.next;
	size_of_largest=0;
	while(block != NULL)
	{
		if(block->size > size_of_largest)
			size_of_largest = block->size;
		block = block->next;
	}
	return size_of_largest-((size_of_largest < 0xFFFF) ? sizeof(SMALL_BLOCK)
				: sizeof(LARGE_BLOCK));
}

size_t total_coreleft(void)
{
	MEM_BLOCK *block;
	size_t total=0;
	block = head.next;
	while(block != NULL)
	{
		total += block->size -((block->size < 0xFFFF) ? sizeof(SMALL_BLOCK)
				: sizeof(LARGE_BLOCK));
		block = block->next;
	}
	return total;
}

size_t n_of_fragments(void)
{
	MEM_BLOCK *block;
	size_t total=0;
	block = head.next;
	while(block != NULL)
	{
		total ++;
		block = block->next;
	}
	return total;
}

