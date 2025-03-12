**
** gemdos.i - GEMDOS magic numbers
**
** Copyright (c) 1989,90,93 HiSoft
**
* 13.12.90	Updated for TT TOS
* 29.3.92	Updated for MiNT
* 23.12.98	Updated for MiNT 1.15.0
* 13.10.99	Updated for MiNT 1.15.4

P_term0	equ	$00	;TOS GEMDOS
C_conin	equ	$01
C_conout	equ	$02
C_auxin	equ	$03
C_auxout	equ	$04
C_prnout	equ	$05
C_rawio	equ	$06
C_rawcin	equ	$07
C_necin	equ	$08
C_conws	equ	$09
C_conrs	equ	$0a
C_conis	equ	$0b
D_setdrv	equ	$0e
C_conos	equ	$10
C_prnos	equ	$11
C_auxis	equ	$12
C_auxos	equ	$13
M_addalt	equ	$14
S_lbopen	equ	$16	; MagiC/MiNT 1.15.3
S_lbclose	equ	$17	; MagiC/MiNT 1.15.3
D_getdrv	equ	$19
F_setdta	equ	$1a
Super	equ	$20
T_getdate	equ	$2a
T_setdate	equ	$2b
T_gettime	equ	$2c
T_settime	equ	$2d
F_getdta	equ	$2f
S_version	equ	$30
P_termres	equ	$31
S_config	equ	$33	; MagiC
D_free	equ	$36
D_create	equ	$39
D_delete	equ	$3a
D_setpath	equ	$3b
F_create	equ	$3c
F_open	equ	$3d
F_close	equ	$3e
F_read	equ	$3f
F_write	equ	$40
F_delete	equ	$41
F_seek	equ	$42
F_attrib	equ	$43
M_xalloc	equ	$44
F_dup	equ	$45
F_force	equ	$46
D_getpath	equ	$47
M_alloc	equ	$48
M_free	equ	$49
M_shrink	equ	$4a
P_exec	equ	$4b
P_term	equ	$4c
F_sfirst	equ	$4e
F_snext	equ	$4f
F_rename	equ	$56
F_datime	equ	$57

S_yield	equ	$ff	; MiNT GEMDOS
F_pipe	equ	$100
F_fchown	equ	$101	; 1.15.2
F_fchmod	equ	$102	; 1.15.2
F_sync	equ	$103	; planned
F_cntl	equ	$104
F_instat	equ	$105
F_outstat	equ	$106
F_getchar	equ	$107
F_putchar	equ	$108
P_wait	equ	$109
P_nice	equ	$10a
P_getpid	equ	$10b
P_getppid	equ	$10c
P_getpgrp	equ	$10d
P_setpgrp	equ	$10e
P_getuid	equ	$10f
P_setuid	equ	$110
P_kill	equ	$111
P_signal	equ	$112
P_vfork	equ	$113
P_getgid	equ	$114
P_setgid	equ	$115
P_sigblock	equ	$116
P_sigsetmask	equ	$117
P_usrval	equ	$118
P_domain	equ	$119
P_sigreturn	equ	$11a
P_fork	equ	$11b
P_wait3	equ	$11c
F_select	equ	$11d
P_rusage	equ	$11e
P_setlimit	equ	$11f
T_alarm	equ	$120
P_pause	equ	$121
S_sysconf	equ	$122
P_sigpending	equ	$123
D_pathconf	equ	$124
P_msg	equ	$125
F_midipipe	equ	$126
P_renice	equ	$127
D_opendir	equ	$128
D_readdir	equ	$129
D_rewinddir	equ	$12a
D_closedir	equ	$12b
F_xattr	equ	$12c
F_link	equ	$12d
F_symlink	equ	$12e
F_readlink	equ	$12f
D_cntl	equ	$130
F_chown	equ	$131
F_chmod	equ	$132
P_umask	equ	$133
P_semaphore	equ	$134
D_lock	equ	$135
P_sigpause	equ	$136
P_sigaction	equ	$137
P_geteuid	equ	$138
P_getegid	equ	$139
P_waitpid	equ	$13a
D_getcwd	equ	$13b
S_alert	equ	$13c

T_malarm	equ	$13d	; MiNT 1.15.x
P_sigintr	equ	$13e
S_uptime	equ	$13f
D_xreaddir	equ	$142
P_seteuid	equ	$143
P_setegid	equ	$144
P_getauid	equ	$145
P_setauid	equ	$146
P_getgroups	equ	$147
P_setgroups	equ	$148
T_setitimer	equ	$149
D_chroot	equ	$14a	; 1.15.3
F_stat	equ	$14b
D_setkey	equ	$14d	; 1.15.4
P_setreuid	equ	$14e
P_setregid	equ	$14f
S_ync	equ	$150
S_shutdown	equ	$151
D_readlabel	equ	$152
D_writelabel	equ	$153
S_system	equ	$154
T_gettimeofday	equ	$155
T_settimeofday	equ	$156
T_adjtime	equ	$157	; planned
P_getpriority	equ	$158
P_setpriority	equ	$159

SIG_DFL	equ	0
SIG_IGN	equ	1
SIG_ERR	equ	-1

SIGNULL	equ	0	; signals
SIGHUP	equ	1
SIGINT	equ	2
SIGQUIT	equ	3
SIGILL	equ	4
SIGTRAP	equ	5
SIGIOT	equ	6
SIGEMT	equ	7
SIGFPE	equ	8
SIGKILL	equ	9
SIGBUS	equ	10
SIGSEGV	equ	11
SIGSYS	equ	12
SIGPIPE	equ	13
SIGALRM	equ	14
SIGTERM	equ	15
SIGURG	equ	16
SIGSTOP	equ	17
SIGTSTP	equ	18
SIGCONT	equ	19
SIGCHLD	equ	20
SIGTTIN	equ	21
SIGTTOU	equ	22
SIGIO	equ	23
SIGXCPU	equ	24
SIGXFSZ	equ	25
SIGVTALRM	equ	26
SIGPROF	equ	27
SIGWINCH	equ	28
SIGUSR1	equ	29
SIGUSR2	equ	30

SHMSETBLK	equ	$4d01	;shared memory
SHMGETBLK	equ	$4d00
PSETFLAGS	equ	$5004	;memory flags
PGETFLAGS	equ	$5005

; memflags

F_FASTLOAD	equ	$0001
F_ALTLOAD	equ	$0002
F_ALTALLOC	equ	$0004
F_SMALLTPA	equ	$0008
F_SHTEXT	equ	$0800
F_ALLOCZERO	equ	$2000
F_KEEP	equ	$4000
F_OS_SPECIAL	equ	$8000

; protection codes

F_PROT_P	equ	$00	; private
F_PROT_G	equ	$10	; global
F_PROT_S	equ	$20	; supervisor
F_PROT_PR	equ	$30	; private/readable
F_PROT_I	equ	$40	; no real use in programs
F_PROTMODE	equ	$f0

; Pexec()

PE_LOADGO	equ	0
PE_LOAD	equ	3
PE_GO	equ	4
PE_BASEPAGE	equ	5
PE_GOTHENFREE	equ	6
PE_BASEPAGEFLG	equ	7
PE_CLOADGO	equ	100
PE_CGO	equ	104
PE_CGONOSHARE	equ	106
PE_REPLACE	equ	200

PW_NOBLOCK	equ	$0001	;Pwait3()
PW_STOPPED	equ	$0002

MSG_READ	equ	$0000	;Pmsg()
MSG_WRITE	equ	$0001
MSG_READWRITE	equ	$0002
MSG_NOWAIT	equ	$8000

