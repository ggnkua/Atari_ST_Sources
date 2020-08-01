/*
 * @(#)osbind.h, SozobonX XdLibs (c) jerry g geiger 1995
 *
 * operating system calls
 * last change
 *  - VS:   1995/08/19
 */

#ifndef _OSBIND_H
#define _OSBIND_H

#ifdef __MSHORT__
extern	long	gemdos(short, ...);
extern	long	bios(short, ...);
extern	long	xbios(short, ...);
extern	short	bdos();
#endif /* __MSHORT__ */

#include <bios.h>
#include <tosbind.h>
#include <mintbind.h>

#endif /* _OSBIND_H */
