/*	sys_vars.h	/	6.4.92	/	MATRIX	/	WA	*/

# define _bootdev	((int *)0x446)
# define _v_bas_ad 	((byte **)0x44e)
# define sshiftmd  	((byte *)0x44c)
# define _vbclock	((long *)0x462)
# define _frclock	((long *)0x466)
# define _hz_200	((long *)0x4ba)
# define _longframe	((word *)0x59e)
# define _sysbase 	((SYSHDR **)0x4F2L)
# define kb_shift 	*((byte *)((*_sysbase)->kbshift))


