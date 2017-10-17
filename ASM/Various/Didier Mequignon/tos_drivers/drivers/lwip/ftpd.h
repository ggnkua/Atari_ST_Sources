/*
 *  Copyright (c) 2004, Dennis Kuschel.
 *  All rights reserved. 
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *   3. The name of the author may not be used to endorse or promote
 *      products derived from this software without specific prior written
 *      permission. 
 *
 *  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
 *  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 *  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *  ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
 *  INDIRECT,  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 *  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 *  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 *  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 *  OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

/**
 * @file    ftpd.h
 * @author  Dennis Kuschel
 * @brief   FTP demon for embedded devices
 *
 * This software is from http://mycpu.mikrocontroller.net.
 * Please send questions and bug reports to dennis_k@freenet.de.
 */

#ifndef _FTPD_H_
#define _FTPD_H_

/* ------------------------ System includes ------------------------------- */
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>

/* ------------------------ FreeRTOS includes ----------------------------- */
#include "../freertos/FreeRTOS.h"
#include "../freertos/task.h"

/* ------------------------ LWIP includes --------------------------------- */
#include "inet.h"
#include "sockets.h"

/* ------------------------ BDOS includes ----------------------------------*/
/* cannot use TOS trap out of CF68KLIB !!! */
#include "../bdos/bdos.h"

/* correct a bug in lwip/sockets.h */
#if FD_SETSIZE < MEMP_NUM_NETCONN
#undef FD_SETSIZE
#define FD_SETSIZE MEMP_NUM_NETCONN
#ifdef fd_set
#undef fd_set
#endif
#define fd_set fd_set_2
typedef struct fd_set_2 {
  unsigned char fd_bits [(FD_SETSIZE+7)/8];
} fd_set_2;
#endif

typedef unsigned int   uint_t;
typedef signed   int   sint_t;

#define sprintf sprintD
extern int sprintD(char *s, const char *fmt, ...);
extern void board_printf(const char *fmt, ...);

#define FS_SUBDIRECTORIES 1
#define FS_MAXFNAMELEN 256

/** @defgroup ftpd Embedded FTP Demon *//** @{ */


/**
 * This function starts the FTP demon. The function
 * call does not return; to terminate the demon again
 * you can do a call to ::ftpd_stop.
 * @param username  Username. The FTPD supports only one
 *                  user name and has no rights management.
 *                  Anonymous login is not supported.
 * @param password  Password for the user with username.
 * @return zero on success.
 */
sint_t ftpd_start(char *username, char *password);


/**
 * This function stoppes the FTP demon.
 * Note that it takes a while (up to 1 second) until
 * this function returns.
 * @return zero on success.
 */
sint_t ftpd_stop(void);


/**
 * This function can be used to test if the
 * FTP demon task is still running.
 * @return  nonzero when the ftpd is running.
 */
sint_t ftpd_running(void);


/*@}*/
#endif /* _FTPD_H_ */
