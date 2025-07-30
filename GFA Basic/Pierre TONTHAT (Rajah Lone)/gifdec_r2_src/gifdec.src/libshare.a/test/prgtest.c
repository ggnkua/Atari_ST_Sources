/*
 * 
 */

#include <stdio.h>
#include <gem.h>
#include <ldg.h>

LDG *ldgtest;
void (*information)(void) = NULL;
void (*test)(void) = NULL;
void (*init)(void) = NULL;

int main( void)
{
	appl_init();
	
	printf("TEST programm for libshare library\n\n");
	printf("loading test.ldg...");
	
	ldgtest = ldg_open("test.ldg",ldg_global);
	if (!ldgtest) 
	{
		printf("failed!\n");
		appl_exit();
		return -1;
	}
	printf("ok.\n");
	
	init = ldg_find( "init", ldgtest);
	if (! init)
	{
		printf("init() not found\n");
		ldg_close(ldgtest,ldg_global);
		appl_exit();
		return -1;
	}
	printf("init() found at address %p\n",init);

	information = ldg_find( "information", ldgtest);
	if (! information)
	{
		printf("information() not found\n");
		ldg_close(ldgtest,ldg_global);
		appl_exit();
		return -1;
	}
	printf("information() found at address %p\n",information);
	
	test = ldg_find( "test", ldgtest);
	if (! test)
	{
		printf("test() not found\n");
		ldg_close(ldgtest,ldg_global);
		appl_exit();
		return -1;
	}
	printf("test() found at address %p\n",test);

	/* 1st: call libshare_init() */
	printf("1st, call the libshare_init subroutine...\n");
	init();
	printf("done.\n");

	/* now, we can use the LDG as we want */
	printf("now, call the information subroutine...\n");
	information();
	printf("done.\n");
	
	printf("now, call the test subroutine...\n");
	test();
	printf("done.\n");
	
	printf("now, call the information subroutine...\n");
	information();
	printf("done.\n");
	
	ldg_close(ldgtest,ldg_global);
	
	appl_exit();
	
	return 0;
}

