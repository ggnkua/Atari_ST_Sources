/************************************************/
/*             MEM.C V1.0, 16.8.1990            */
/* Autor: Grischa Ekart / (c) by Grischa Ekart  */
/*  erstellt mit Turbo C V1.0 von BORLAND GmbH  */
/************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*                  defines                     */

#ifndef FALSE
#define FALSE 0
#endif
#ifndef TRUE
#define TRUE 1
#endif

/*                 structures                   */

typedef	struct _pointer {
/*   'memory' muss an erster Stelle stehen!!!   */
	void		*memory;
	size_t	size;
	struct	_pointer *next;
	struct	_pointer *prev;
} POINTER;

/*             internal definitions             */

static	void *mem_bot;
static	void *mem_top;
static	POINTER *first_ptr;
static	POINTER *last_ptr;

/*              global prototypes               */

int		mem_init(size_t size);
int		mem_exit(void);
void		**mem_alloc(size_t size);
void		mem_free(void **ptr);

/*             internal prototypes              */

static	int mem_fit(size_t size);
static	void mem_compact(void);

/*             function definitions             */

int
mem_init(size_t size)
{
	if((mem_bot = malloc(size)) == NULL)
		return(FALSE);

	mem_top = (char *)mem_bot + size + 1;
	first_ptr = NULL;
	last_ptr = NULL;
	return(TRUE);
}

int
mem_exit(void)
{
	free(mem_bot);
	if(first_ptr != NULL)
		return(FALSE);
	else
		return(TRUE);
}

void**
mem_alloc(size_t size)
{
	POINTER	*pointer;

	size = (size + 1) & ~1;
	if(mem_top <= (char *)mem_bot + size)
		return((void **)NULL);

	if(first_ptr == NULL)
	{
		pointer = malloc(sizeof(POINTER));
		first_ptr = last_ptr = pointer;
		pointer->memory = mem_bot;
		pointer->size = size;
		pointer->next = NULL;
		pointer->prev = NULL;
		return((void **)pointer);
	}
	if(!mem_fit(size))
	{
		mem_compact();
		if(!mem_fit(size))
			return((void **)NULL);
	}
	pointer = malloc(sizeof(POINTER));
	pointer->memory = (char *)last_ptr->memory
		+ last_ptr->size;

	pointer->size = size;
	pointer->next = last_ptr->next;
	pointer->prev = last_ptr;
	last_ptr->next = pointer;
	last_ptr = pointer;
	return((void **)pointer);
}

void
mem_free(void **ptr)
{
	POINTER *pointer;

	pointer = (POINTER *)ptr;
	if(pointer->prev != NULL)
	{
		pointer->prev->next
			= pointer->next;
	}
	else
	{
		first_ptr = pointer->next;
	}
	if(pointer->next != NULL)
	{
		pointer->next->prev
			= pointer->prev;
	else
	{
		last_ptr = pointer->prev;
	}
	free((void *)pointer);
}

static int
mem_fit(size_t size)
{
	return(mem_top > (char *)last_ptr->memory
		+ last_ptr->size + size);
}

static void
mem_compact(void)
{
	POINTER *pointer;
	void	*memory;

	memory = mem_bot;
	pointer = first_ptr;
	while(pointer != NULL)
	{
		if(pointer->memory > memory)
		{
			memcpy(memory,
				pointer->memory,
				pointer->size);
		}
		pointer->memory = memory;
		(char *)memory += pointer->size;
		pointer = pointer->next;
	}
}
