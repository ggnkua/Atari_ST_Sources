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

/*
 *	XaAES/oAESis Extended Shell Write structure 
 *	- Extra fields for UID/GID setting of spawned clients.
 */
typedef struct _xshelw {
	char *newcmd;
	long psetlimit;
	long prenice;
	char *defdir;
	char *env;
	short uid;            /* New child's UID */
	short gid;            /* New child's GID */
} XSHELW;

#define SW_PSETLIMIT	0x100
#define SW_PRENICE		0x200
#define SW_PDEFDIR		0x400
#define SW_ENVIRON		0x800
#define SW_UID 			0x1000   /* Set user id of launched child */
#define SW_GID			0x2000   /* Set group id of launched child */

XSHELW mine = {0};

int main(void)
{
	appl_init();
	*ridiculously_large = 0x7f;

	mine.newcmd = "argvuse.TTP";
	mine.defdir = "d:\\xaaes\\argvdir";
	shel_write(0x401,0,0,(char *)&mine,ridiculously_large);
	appl_exit();
	return 0;
}

#else

int Pgetppid(void);

int main(int argc, char **argv, char **env)
{
	int i = 0; long try;
	char defdir[130];
	short drive;
	printf("Parameters voor '%s'\n", argv[0] ? argv[0] : "~~~");
	while(argc)
	{
		printf("arg %d: '%s'\n", i, argv[i]);
		argc--, i++;
	}
	try = Fopen("tryopen", 0);
	printf("tried open result: %ld\n", try);
	if (try > 0)
		Fclose(try);
	drive = Dgetdrv();
	printf("defdrv = %d\n", drive);
	Dgetpath(defdir,0);
	printf("defpath(0) = '%s'\n", defdir);
	Dgetpath(defdir,drive + 1);
	printf("defpath(%c) = '%s'\n", drive + 'a', defdir);
	printf("Parent = %d\n", Pgetppid());
	bios(2,2);
	return 0;
}

#endif