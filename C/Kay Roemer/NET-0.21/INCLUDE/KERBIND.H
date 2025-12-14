/*
 *	Definitions to access the functions and constants provided
 *	by the kernel with `struct kerinfo'.
 *
 *	09/25/93, kay roemer
 */

#ifndef _KERBIND_H
#define _KERBIND_H

#include "config.h"
#include "file.h"

/* name of the global defined `struct kerinfo *', returned from the kernel */
#define KERINFO kernelinfo
extern struct kerinfo *KERINFO;

/* GEMDOS functions */
#define p_term0		(*KERINFO->dos_tab[0x000])
#define c_conin		(*KERINFO->dos_tab[0x001])
#define c_conout	(*KERINFO->dos_tab[0x002])
#define c_auxin		(*KERINFO->dos_tab[0x003])
#define c_auxout	(*KERINFO->dos_tab[0x004])
#define c_prnout	(*KERINFO->dos_tab[0x005])
#define c_rawio		(*KERINFO->dos_tab[0x006])
#define c_rawcin	(*KERINFO->dos_tab[0x007])
#define c_necin		(*KERINFO->dos_tab[0x008])
#define c_conws		(*KERINFO->dos_tab[0x009])
#define c_conrs		(*KERINFO->dos_tab[0x00a])
#define c_conis		(*KERINFO->dos_tab[0x00b])
#define d_setdrv	(*KERINFO->dos_tab[0x00e])
#define c_conos		(*KERINFO->dos_tab[0x010])
#define c_prnos		(*KERINFO->dos_tab[0x011])
#define c_auxis		(*KERINFO->dos_tab[0x012])
#define c_auxos		(*KERINFO->dos_tab[0x013])
#define d_getdrv	(*KERINFO->dos_tab[0x019])
#define f_setdta	(*KERINFO->dos_tab[0x01a])
#define s_uper		(*KERINFO->dos_tab[0x020])
#define t_getdate	(*KERINFO->dos_tab[0x02a])
#define t_setdate	(*KERINFO->dos_tab[0x02b])
#define t_gettime	(*KERINFO->dos_tab[0x02c])
#define t_settime	(*KERINFO->dos_tab[0x02d])
#define f_getdta	(*KERINFO->dos_tab[0x02f])
#define s_version	(*KERINFO->dos_tab[0x030])
#define p_termres	(*KERINFO->dos_tab[0x031])
#define d_free		(*KERINFO->dos_tab[0x036])
#define d_create	(*KERINFO->dos_tab[0x039])
#define d_delete	(*KERINFO->dos_tab[0x03a])
#define d_setpath	(*KERINFO->dos_tab[0x03b])
#define f_create(a,b)	(*KERINFO->dos_tab[0x03c]) ((long)(a), (short)(b))
#define f_open(a,b)	(*KERINFO->dos_tab[0x03d]) ((long)(a), (short)(b))
#define f_close(a)	(*KERINFO->dos_tab[0x03e]) ((short)(a))
#define f_read(a,b,c)	(*KERINFO->dos_tab[0x03f]) ((short)(a), (long)(b), (long)(c))
#define f_write(a,b,c)	(*KERINFO->dos_tab[0x040]) ((short)(a), (long)(b), (long)(c))
#define f_delete	(*KERINFO->dos_tab[0x041])
#define f_seek		(*KERINFO->dos_tab[0x042])
#define f_attrib	(*KERINFO->dos_tab[0x043])
#define f_dup		(*KERINFO->dos_tab[0x045])
#define f_force		(*KERINFO->dos_tab[0x046])
#define d_getpath	(*KERINFO->dos_tab[0x047])
#define m_alloc		(*KERINFO->dos_tab[0x048])
#define m_free		(*KERINFO->dos_tab[0x049])
#define m_shrink	(*KERINFO->dos_tab[0x04a])
#define p_exec		(*KERINFO->dos_tab[0x04b])
#define p_term		(*KERINFO->dos_tab[0x04c])
#define f_sfirst	(*KERINFO->dos_tab[0x04e])
#define f_snext		(*KERINFO->dos_tab[0x04f])
#define f_rename	(*KERINFO->dos_tab[0x056])
#define f_datime	(*KERINFO->dos_tab[0x057])

/* MiNT GEMDOS extensions */
#define s_yield		(*KERINFO->dos_tab[0x0ff])
#define f_pipe		(*KERINFO->dos_tab[0x100])
#define f_cntl(a,b,c)	(*KERINFO->dos_tab[0x104]) ((short)(a), (long)(b), (short) (c))
#define f_instat	(*KERINFO->dos_tab[0x105])
#define f_outstat	(*KERINFO->dos_tab[0x106])
#define f_getchar	(*KERINFO->dos_tab[0x107])
#define f_putchar	(*KERINFO->dos_tab[0x108])
#define p_wait		(*KERINFO->dos_tab[0x109])
#define p_nice		(*KERINFO->dos_tab[0x10a])
#define p_getpid	(*KERINFO->dos_tab[0x10b])
#define p_getppid	(*KERINFO->dos_tab[0x10c])
#define p_getpgrp	(*KERINFO->dos_tab[0x10d])
#define p_setpgrp	(*KERINFO->dos_tab[0x10e])
#define p_getuid	(*KERINFO->dos_tab[0x10f])
#define p_setuid	(*KERINFO->dos_tab[0x110])
#define p_kill(a,b)	(*KERINFO->dos_tab[0x111]) ((short)(a), (short)(b))
#define p_signal	(*KERINFO->dos_tab[0x112])
#define p_vfork		(*KERINFO->dos_tab[0x113])
#define p_getgid	(*KERINFO->dos_tab[0x114])
#define p_setgid	(*KERINFO->dos_tab[0x115])
#define p_sigblock	(*KERINFO->dos_tab[0x116])
#define p_sigsetmask	(*KERINFO->dos_tab[0x117])
#define p_usrval	(*KERINFO->dos_tab[0x118])
#define p_domain	(*KERINFO->dos_tab[0x119])
#define p_sigreturn	(*KERINFO->dos_tab[0x11a])
#define p_fork		(*KERINFO->dos_tab[0x11b])
#define p_wait3		(*KERINFO->dos_tab[0x11c])
#define f_select	(*KERINFO->dos_tab[0x11d])
#define p_rusage	(*KERINFO->dos_tab[0x11e])
#define p_setlimit	(*KERINFO->dos_tab[0x11f])
#define t_alarm		(*KERINFO->dos_tab[0x120])
#define p_ause		(*KERINFO->dos_tab[0x121])
#define s_ysconf	(*KERINFO->dos_tab[0x122])
#define p_sigpending	(*KERINFO->dos_tab[0x123])
#define d_pathconf	(*KERINFO->dos_tab[0x124])
#define p_msg		(*KERINFO->dos_tab[0x125])
#define f_midipipe	(*KERINFO->dos_tab[0x126])
#define p_renice	(*KERINFO->dos_tab[0x127])
#define d_opendir	(*KERINFO->dos_tab[0x128])
#define d_readdir	(*KERINFO->dos_tab[0x129])
#define d_rewinddir	(*KERINFO->dos_tab[0x12a])
#define d_closedir	(*KERINFO->dos_tab[0x12b])
#define f_xattr(a,b,c)	(*KERINFO->dos_tab[0x12c]) ((short)(a), (long)(b), (long)(c))
#define f_link		(*KERINFO->dos_tab[0x12d])
#define f_symlink	(*KERINFO->dos_tab[0x12e])
#define f_readlink	(*KERINFO->dos_tab[0x12f])
#define d_cntl(a,b,c)	(*KERINFO->dos_tab[0x130]) ((short)(a), (long)(b), (long)(c))
#define f_chown		(*KERINFO->dos_tab[0x131])
#define f_chmod		(*KERINFO->dos_tab[0x132])
#define p_umask		(*KERINFO->dos_tab[0x133])
#define p_semaphore	(*KERINFO->dos_tab[0x134])
#define d_lock		(*KERINFO->dos_tab[0x135])
#define p_sigpause	(*KERINFO->dos_tab[0x136])
#define p_sigaction	(*KERINFO->dos_tab[0x137])
#define p_geteuid	(*KERINFO->dos_tab[0x138])
#define p_getegid	(*KERINFO->dos_tab[0x139])
#define p_waitpid	(*KERINFO->dos_tab[0x13a])
#define d_getcwd	(*KERINFO->dos_tab[0x13b])
#define s_alert		(*KERINFO->dos_tab[0x13c])

/* BIOS functions */
#define g_etmpb		(*KERINFO->bios_tab[0x000])
#define b_constat	(*KERINFO->bios_tab[0x001])
#define b_conin		(*KERINFO->bios_tab[0x002])
#define b_conout	(*KERINFO->bios_tab[0x003])
#define r_wabs		(*KERINFO->bios_tab[0x004])
#define s_etexec	(*KERINFO->bios_tab[0x005])
#define t_ickcal	(*KERINFO->bios_tab[0x006])
#define g_getbpb	(*KERINFO->bios_tab[0x007])
#define b_costat	(*KERINFO->bios_tab[0x008])
#define m_ediach	(*KERINFO->bios_tab[0x009])
#define d_rvmap		(*KERINFO->bios_tab[0x00a])
#define k_bshift	(*KERINFO->bios_tab[0x00b])

/* kernel provided utility functions and constants */
#define MAJ_VERSION	(KERINFO->maj_version)
#define MIN_VERSION	(KERINFO->min_version)
#define DEF_MODE	(KERINFO->default_mode)

#define drvchng		(*KERINFO->drvchng)

#ifdef NDEBUG
#define DEBUG(a)
#define TRACE(a)
#else
#define TRACE(a)	(*KERINFO->trace) a
#define DEBUG(a)	(*KERINFO->debug) a
#endif
#define ALERT(a)	(*KERINFO->alert) a
#define FATAL(a)	(*KERINFO->fatal) a

#define kmalloc		(*KERINFO->kmalloc)
#define kfree		(*KERINFO->kfree)
#define umalloc		(*KERINFO->umalloc)
#define ufree		(*KERINFO->ufree)

#define strnicmp	(*KERINFO->strnicmp)
#define stricmp		(*KERINFO->stricmp)
#define strlwr		(*KERINFO->strlwr)
#define strupr		(*KERINFO->strupr)
#define sprintf		(*KERINFO->sprintf)

#define millis_time	(*KERINFO->millis_time)
#define unixtim		(*KERINFO->unixtim)
#define dostim		(*KERINFO->dostim)

#define nap		(*KERINFO->nap)
#define sleep		(*KERINFO->sleep)

/* process queues */
#define CURPROC_Q	0
#define READY_Q		1
#define WAIT_Q		2
#define IO_Q		3
#define ZOMBIE_Q	4
#define TSR_Q		5
#define STOP_Q		6
#define SELECT_Q	7

#define wake		(*KERINFO->wake)
#define wakeselect	(*KERINFO->wakeselect)

#define denyshare	(*KERINFO->denyshare)
#define denylock	(*KERINFO->denylock)

#define addtimeout	(*KERINFO->addtimeout)
#define canceltimeout	(*KERINFO->canceltimeout)

#endif /* _KERBIND_H */
