S_OSNAME	equ	0
S_OSXNAME	equ	1
S_OSVERSION	equ	2
S_OSHEADER	equ	3
S_OSBUILDDATE	equ	4
S_OSBUILDTIME	equ	5
S_OSCOMPILE	equ	6
S_OSFEATURES	equ	7
S_GETCOOKIE	equ	8
S_SETCOOKIE	equ	9
S_GETLVAL	equ	10
S_GETWVAL	equ	11
S_GETBVAL	equ	12
S_SETLVAL	equ	13
S_SETWVAL	equ	14
S_SETBVAL	equ	15
S_SECLEVEL	equ	16
S_RUNLEVEL	equ	17	/* currently disabled, reserved */
S_TSLICE	equ	18
S_FASTLOAD	equ	19
S_SYNCTIME	equ	20
S_BLOCKCACHE	equ	21
S_FLUSHCACHE	equ	22
S_CTRLCACHE	equ	23
S_CLOCKUTC	equ	100
S_TIOCMGET	equ	$54f8	/* 21752 */
S_KNAME		equ	900	/* kernel name - arg1 pointer to a buffer of arg2 len */
S_CNAME		equ	910	/* compiler name - arg1 pointer to a buffer of arg2 len */
S_CVERSION	equ	911	/* compiler version - arg1 pointer to a buffer of arg2 len */
S_CDEFINES	equ	912	/* compiler definitions - arg1 pointer to a buffer of arg2 len */
S_COPTIM	equ	913	/* compiler flags - arg1 pointer to a buffer of arg2 len */
S_DEBUGLEVEL	equ	1000	/* debug level */
S_DEBUGDEVICE	equ	1001	/* BIOS device number */
