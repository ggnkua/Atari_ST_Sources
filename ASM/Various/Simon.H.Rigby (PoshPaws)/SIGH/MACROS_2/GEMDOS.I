* GEMDOS
*=======
* TRAP #1 - EXCEPTION VECTOR #33 AT ADDRESS 132 ($84)
* Supports User & Supervisor modes
* Results returned in d0
* d0-d2/a0-a2 are corrupted


p_term0		equ	$00	;done
c_conin		equ	$01	;done
c_conout	equ	$02	;done
c_auxin		equ	$03	;done
c_auxout	equ	$04	;done
c_prnout	equ	$05	;done
c_rawio		equ	$06	;done
c_rawcin	equ	$07	;done
c_necin		equ	$08	;done
c_conws		equ	$09	;done
c_conrs		equ	$0a	;done
c_conis		equ	$0b	;done

d_setdrv	equ	$0e	;done

c_conos		equ	$10	;done
c_prnos		equ	$11	;done
c_auxis		equ	$12	;done
c_auxos		equ	$13	;done
m_addalt	equ	$14	;done

d_getdrv	equ	$19	;done
f_setdta	equ	$1a	;done

super		equ	$20	;done

t_getdate	equ	$2a	;done
t_setdate	equ	$2b	;done
t_gettime	equ	$2c	;done
t_settime	equ	$2d	;done

f_getdta	equ	$2f	;done
s_version	equ	$30	;done
p_termres	equ	$31	;done

d_free		equ	$36	;done

d_create	equ	$39	;done
d_delete	equ	$3a	;done
d_setpath	equ	$3b	;done
f_create	equ	$3c	;done
f_open		equ	$3d	;done
f_close		equ	$3e	;done
f_read		equ	$3f	;done
f_write		equ	$40	;done
f_delete	equ	$41	;done
f_seek		equ	$42	;done
f_attrib	equ	$43	;done
m_xalloc	equ	$44	;done
f_dup		equ	$45	;done
f_force		equ	$46	;done
d_getpath	equ	$47	;done
m_alloc		equ	$48	;done
m_free		equ	$49	;done
m_shrink	equ	$4a	;done
p_exec		equ	$4b	;done
p_term		equ	$4c	;done

f_sfirst	equ	$4e	;done
f_snext		equ	$4f	;done

f_rename	equ	$56	;done
f_datime	equ	$57	;done

s_yield		equ	$ff
f_pipe		equ	$100

f_cntl		equ	$104
f_instat	equ	$105
f_outstat	equ	$106
f_getchar	equ	$107
f_putchar	equ	$108
p_wait		equ	$109
p_nice		equ	$10a
p_getpid	equ	$10b
p_getppid	equ	$10c
p_getpgrp	equ	$10d
p_setpgrp	equ	$10e
p_getuid	equ	$10f
p_setuid	equ	$110
p_kill		equ	$111
p_signal	equ	$112
p_vfork		equ	$113
p_getgid	equ	$114
p_setgid	equ	$115
p_sigblock	equ	$116
p_sigsetmask	equ	$117
p_usrval	equ	$118
p_domain	equ	$119
p_sigreturn	equ	$11a
p_fork		equ	$11b
p_wait3		equ	$11c
f_select	equ	$11d
p_rusage	equ	$11e
p_setlimit	equ	$11f
t_alarm		equ	$120
p_pause		equ	$121							\
s_sysconf	equ	$122
p_sigpending	equ	$123
d_pathconf	equ	$124
p_msg		equ	$125
f_midipipe	equ	$126
p_renice	equ	$127
d_opendir	equ	$128
d_readdir	equ	$129
d_rewinddir	equ	$12a
d_closedir	equ	$12b
f_xattr		equ	$12c
f_link		equ	$12d
f_symlink	equ	$12e
f_readlink	equ	$12f
d_cntl		equ	$130
f_chown		equ	$131
f_chmod		equ	$132
p_umask		equ	$133
p_semaphore	equ	$134
d_lock		equ	$135
p_sigpause	equ	$136
p_sigaction	equ	$137
p_geteuid	equ	$138
p_getegid	equ	$139
p_waitpid	equ	$13a
d_getcwd	equ	$13b
s_alert		equ	$13c

EINVFN	equ	-32
EFILNF	equ	-33
EPTHNF	equ	-34
ENHNDL	equ	-35
EACCDN	equ	-36
EIHNDL	equ	-37
ENSMEM	equ	-39
EIMBA	equ	-40
EDRIVE	equ	-46
ENSNAME	equ	-48
ENMFIL	equ	-49
ERANGE	equ	-64
EINTRN	equ	-65
EPLFMT	equ	-66
EGSBF	equ	-67

ELOOP	equ	-80
EMOUNT	equ	-200
