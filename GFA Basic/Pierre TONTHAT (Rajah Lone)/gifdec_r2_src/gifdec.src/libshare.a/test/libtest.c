/*  test-libshare
 */

#include <stdlib.h>
#include <stdio.h>
#include <mint/osbind.h>
#include <ldg.h>
#include <gem.h>

#include <libshare.h>

void __CDECL information( void);
void __CDECL test( void);

void __CDECL test( void)
{
	void *ptr = (void*)malloc(123);
	ptr = realloc(ptr,125);
	free(ptr);
}

void __CDECL information( void) 
{
	char buffer[64];
	int i;
		
	sprintf(buffer,"TEST LIBSHARE 0.10\n");
	Cconws(buffer);
	
	sprintf(buffer,"__sbrk_has_been_called = %d\n",__sbrk_has_been_called);
	Cconws(buffer);
	
	sprintf(buffer,"list of 20 first malloc performed:\n");
	Cconws(buffer);
	
	for (i=0; i<__ind_lst_malloc; i++) {
		sprintf(buffer,"malloc #%2d : addr=%08x	size=%ld\n",
		        i,__lst_malloc_addr[i],__lst_malloc_size[i]);
		Cconws(buffer);
	}
	
	sprintf(buffer,"list of 20 first free performed:\n");
	Cconws(buffer);
	
	for (i=0; i<__ind_lst_free; i++) {
		sprintf(buffer,"free #%2d : addr=%08x\n",
		        i,__lst_free[i]);
		Cconws(buffer);
	}
}

PROC LibFunc[] = 
{ 
	/* MANDATORY */
	{
		"init",
		"/* initialise the library */\n"
    	"void init( void);\n",
		libshare_init
	},
	/* OPTIONAL... */
	{
		"information",
		"/* print informations to stdout */\n"
    	"void information( void);\n",
		information
	},
	{
		"test",
		"/* do some malloc stuff */\n"
    	"void test( void);\n",
		test
	}
};

LDGLIB LibLdg =
{
	0x0010, 		    /* library version 0.10 */
	3,				    /* count of functions in library */
	LibFunc,		    /* function addresses */
	"test of libshare", /* Library information string */
	LDG_NOT_SHARED,     /* Library flags */
	libshare_exit,      /* close function */
	0L                  /* user extension */
};

int main( void) 
{
	if( ldg_init( &LibLdg) == -1) {
		appl_init();
		form_alert( 1, "[1][This program is a LDG library][End]");
		appl_exit();
	}
	return 0;
}
