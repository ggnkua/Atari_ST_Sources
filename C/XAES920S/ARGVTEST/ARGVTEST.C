/* Test various dialogue functions */

#include <prelude.h>
#include <tos_gem.h>
#include <stdio.h>

#if CALLER
char ridiculously_large[] =
/*2345678901234567890123456789012   */
" arg1111111111111111111111111111"
" arg2222222222222222222222222222"
" arg3333333333333333333333333333"
" arg4444444444444444444444444444"
" arg5555555555555555555555555555"
" arg6666666666666666666666666666"
" arg7777777777777777777777777777"
;


int main(void)
{
	appl_init();
	*ridiculously_large = 0x7f;
	shel_write(1,0,0,"d:\\xaaes9\\argvtest\\argvuse.TTP",ridiculously_large);
	appl_exit();
	return 0;
}

#else

int main(int argc, char **argv, char **env)
{
	int i = 0;
	printf("Parameters voor '%s'\n", argv[0] ? argv[0] : "~~~");
	while(argc)
	{
		printf("arg %d: '%s'\n", i, argv[i]);
		argc--, i++;
	}
	bios(2,2);
	return 0;
}

#endif