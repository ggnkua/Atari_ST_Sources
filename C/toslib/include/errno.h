/*
 * $Id: errno.h pdonze Exp $
 * 
 * TOS.LIB - (c) 1998 - 2006 Philipp Donze
 *
 * A replacement for PureC PCTOSLIB.LIB
 *
 * This file is part of TOS.LIB and contains definitions for system call return
 * values. (Identical to those of mintlib)
 *
 * TOS.LIB is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * TOS.LIB is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with the GNU C Library; see the file COPYING.LIB.  If not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#ifndef _ERRNO_H
# define _ERRNO_H

extern int errno;

#define E_OK             0
#define EERROR          -1   /* Generic error. */
#define EBUSY           -2   /* Resource busy. */
#define EUKCMD          -3   /* Unknown command. */
#define ECRC            -4   /* CRC error. */
#define EBADR           -5   /* Bad request. */
#define ESPIPE          -6   /* Illegal seek. */
#define EMEDIUMTYPE     -7   /* Wrong medium type. */
#define ESECTOR         -8   /* Sector not found. */
#define EPAPER          -9   /* No paper. */
#define EWRITE          -10  /* Write fault. */
#define EREAD           -11  /* Read fault. */
#define EGENERIC        -12  /* General mishap. */
#define EROFS           -13  /* Write protect. */
#define ECHMEDIA        -14  /* Media change. */
#define ENODEV          -15  /* No such device. */
#define EBADSEC         -16  /* Bad sectors found. */
#define ENOMEDIUM       -17  /* No medium found. */
#define EINSERT         -18  /* Insert media. */
#define EDRVNRSP        -19  /* Drive not responding. */
#define ESRCH           -20  /* No such process. */
#define ECHILD          -21  /* No child processes. */
#define EDEADLK         -22  /* Resource deadlock would occur. */
#define EDEADLOCK       EDEADLK
#define ENOTBLK         -23  /* Block device required. */
#define EISDIR          -24  /* Is a directory. */
#define EINVAL          -25  /* Invalid argument. */
#define EFTYPE          -26  /* Inappropriate file type or format. */
#define EILSEQ          -27  /* Illegal byte sequence. */
#define ENOSYS          -32  /* Function not implemented. */
#define EINVFN          ENOSYS  /* Invalid function */
#define ENOENT          -33  /* No such file or directory. */
#define EFILNF          ENOENT  /* File not found */
#define ENOTDIR         -34  /* Not a directory. */
#define EPTHNF          ENOTDIR /* Path not found */
#define EMFILE          -35  /* Too many open files. */
#define ENHNDL          EMFILE /* No more file handles available */
#define EACCES          -36  /* Permission denied. */
#define EACCDN          EACCES /* Access denied */
#define EBADF           -37  /* Bad file descriptor. */
#define EIHNDL          EBADF /* Invalid file handle */
#define EPERM           -38  /* Operation not permitted. */
#define ENOMEM          -39  /* Cannot allocate memory. */
#define ENSMEM          ENOMEM /* Insufficient memory */
#define EFAULT          -40  /* Bad address. */
#define EIMBA           EFAULT /* Invalid memory block address */
#define ENXIO           -46  /* No such device or address. */
#define EDRIVE          ENXIO /* Invalid drive specified */
#define ECWD            -47  /* Unable to free current working directory */
#define EXDEV           -48  /* Cross-device link. */
#define ENSAME          EXDEV /* Files are not on same logical drive */
#define ENMFILES        -49  /* No more matching file names. */
#define ENMFIL          ENMFILES /* No more files available */
#define ENFILE          -50  /* File table overflow. */
#define ELOCKED         -58  /* Locking conflict. */
#define ENSLOCK         -59  /* No such lock. */
#define EBADARG         -64  /* Bad argument. */
#define EINTERNAL       -65  /* Internal error. */
#define EINTRN          EINTERNAL
#define ENOEXEC         -66  /* Invalid executable file format. */
#define EPLFMT          ENOEXEC
#define ESBLOCK         -67  /* Memory block growth failure. */
#define EGSBF           ESBLOCK
#define EBREAK          -68  /* Aborted by user. */
#define EXCPT           -69  /* Terminated with bombs. */
#define ETXTBSY         -70  /* Text file busy. */
#define EPTHOV          ETXTBSY /* Path overflow */
#define EFBIG           -71  /* File too big. */
#define ELOOP           -80  /* Too many symbolic links. */
#define EPIPE           -81  /* Broken pipe. */
#define EMLINK          -82  /* Too many links. */

#define ENOTEMPTY       -83  /* Directory not empty. */
#define EEXIST          -85  /* File exists. */
#define ENAMETOOLONG    -86  /* Name too long. */
#define ENOTTY          -87  /* Not a tty. */
#define ERANGE          -88  /* Range error. */
#define EDOM            -89  /* Domain error. */
#define EIO             -90  /* I/O error */
#define ENOSPC          -91  /* No space left on device. */
#define EPROCLIM        -100 /* Too many processes for user. */
#define EUSERS          -101 /* Too many users. */
#define EDQUOT          -102 /* Quota exceeded. */

#define ESTALE          -103 /* Stale NFS file handle. */

#define EREMOTE         -104 /* Object is remote. */

#define EBADRPC         -105 /* RPC struct is bad. */
#define ERPCMISMATCH    -106 /* RPC version wrong. */
#define EPROGUNAVAIL    -107 /* RPC program not available. */
#define EPROGMISMATCH   -108 /* RPC program version wrong. */
#define EPROCUNAVAIL    -109 /* RPC bad procedure for program. */

#define ENOLCK          -110 /* No locks available. */

#define EAUTH           -111 /* Authentication error. */
#define ENEEDAUTH       -112 /* Need authenticator. */

#define EBACKGROUND     -113 /* Inappropriate operation for background process*/

#define EBADMSG         -114 /* Not a data message. */
#define EIDRM           -115 /* Identifier removed. */
#define EMULTIHOP       -116 /* Multihop attempted. */
#define ENODATA         -117 /* No data available. */
#define ENOLINK         -118 /* Link has been severed. */
#define ENOMSG          -119 /* No message of desired type. */
#define ENOSR           -120 /* Out of streams resources. */
#define ENOSTR          -121 /* Device not a stream. */
#define EOVERFLOW       -122 /* Value too large for defined data type. */
#define EPROTO          -123 /* Protocol error. */
#define ETIME           -124 /* Timer expired. */

#define E2BIG           -125 /* Argument list too long. */
#define ERESTART        -126 /* Interrupted system call should be restarted. */
#define ECHRNG          -127 /* Channel number out of range. */
#define EINTR           -128 /* Interrupted function call. */

/* Falcon XBIOS errors. */   
#define ESNDLOCKED      -129 /* Sound system is already locked. */
#define ESNDNOTLOCK     -130 /* Sound system is not locked. */

#define EL2NSYNC        -131 /* Level 2 not synchronized. */
#define EL3HLT          -132 /* Level 3 halted. */
#define EL3RST          -133 /* Level 3 reset. */
#define ELNRNG          -134 /* Link number out of range. */
#define EUNATCH         -135 /* Protocol driver not attached. */
#define ENOCSI          -136 /* No CSI structure available. */
#define EL2HLT          -137 /* Level 2 halted. */
#define EBADE           -138 /* Invalid exchange. */
#define EXFULL          -139 /* Exchange full. */
#define ENOANO          -140 /* No anode. */
#define EBADRQC         -141 /* Invalid request code. */
#define EBADSLT         -142 /* Invalid slot. */
#define EBFONT          -143 /* Bad font file format. */
#define ENONET          -144 /* Machine is not on the network. */
#define ENOPKG          -145 /* Package is not installed. */
#define EADV            -146 /* Advertise error. */
#define ESRMNT          -147 /* Srmount error. */
#define ECOMM           -148 /* Communication error on send. */
#define EDOTDOT         -149 /* RFS specific error. */
#define ELIBACC         -150 /* Cannot access a needed shared library. */
#define ELIBBAD         -151 /* Accessing a corrupted shared library. */
#define ELIBSCN         -152 /* .lib section in a.out corrupted. */
#define ELIBMAX         -153 /* Attempting to link too many shared
                                libraries. */
#define ELIBEXEC        -154 /* Cannot exec a shared library directly. */
#define ESTRPIPE        -155 /* Streams pipe error. */
#define EUCLEAN         -156 /* Structure needs cleaning. */
#define ENOTNAM         -157 /* Not a XENIX named type file. */
#define ENAVAIL         -158 /* NO XENIX semaphores available. */
#define EREMOTEIO       -159 /* Remote I/O error. */

#define ENOTSOCK        -300 /* Socket operation on non-socket. */
#define EDESTADDRREQ    -301 /* Destination address required. */
#define EMSGSIZE        -302 /* Message too long. */
#define EPROTOTYPE      -303 /* Protocol wrong type for socket. */
#define ENOPROTOOPT     -304 /* Protocol not available. */
#define EPROTONOSUPPORT -305 /* Protocol not supported. */
#define ESOCKTNOSUPPORT -306 /* Socket type not supported. */
#define EOPNOTSUPP      -307 /* Operation not supported. */
#define EPFNOSUPPORT    -308 /* Protocol family not supported. */
#define EAFNOSUPPORT    -309 /* Address family not supported by protocol. */
#define EADDRINUSE      -310 /* Address already in use */
#define EADDRNOTAVAIL   -311 /* Cannot assign requested address. */
#define ENETDOWN        -312 /* Network is down. */
#define ENETUNREACH     -313 /* Network is unreachable. */
#define ENETRESET       -314 /* Network dropped conn. because of reset. */
#define ECONNABORTED    -315 /* Software caused connection abort. */
#define ECONNRESET      -316 /* Connection reset by peer. */
#define EISCONN         -317 /* Socket is already connected. */
#define ENOTCONN        -318 /* Socket is not connected. */
#define ESHUTDOWN       -319 /* Cannot send after shutdown. */
#define ETIMEDOUT       -320 /* Connection timed out. */
#define ECONNREFUSED    -321 /* Connection refused. */
#define EHOSTDOWN       -322 /* Host is down. */
#define EHOSTUNREACH    -323 /* No route to host. */
#define EALREADY        -324 /* Operation already in progress. */
#define EINPROGRESS     -325 /* Operation now in progress. */
#define EAGAIN          -326 /* Operation would block. */
#define EWOULDBLOCK     EAGAIN
#define ENOBUFS         -327 /* No buffer space available. */
#define ETOOMANYREFS    -328 /* Too many references. */

#endif      /* _ERRNO_H */
