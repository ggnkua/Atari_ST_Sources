  /* 0 */                          ERR("Success", 14)
  /* 1 - EERROR */                 ERR("Generic Error", 22)
  /* 2 - EBUSY */                  ERR("Device or resource busy", 36)
  /* 3 - EUKCMD */                 ERR("Unknown command", 60)
  /* 4 - ECRC */                   ERR("CRC error", 76)
  /* 5 - EBADR */                  ERR("Invalid request descriptor", 86)
  /* 6 - ESPIPE */                 ERR("Illegal seek", 113)
  /* 7 - EMEDIUMTYPE */            ERR("Wrong medium type", 126)
  /* 8 - ESECTOR */                ERR("Sector not found", 144)
  /* 9 - EPAPER */                 ERR("Out of paper", 161)
  /* 10 - EWRITE */                ERR("Write fault", 174)
  /* 11 - EREAD */                 ERR("Read fault", 186)
  /* 12 - EGENERIC */              ERR("General mishap", 197)
  /* 13 - EROFS */                 ERR("Read-only file system", 212)
  /* 14 - ECHMEDIA */              ERR("Media changed", 234)
  /* 15 - ENODEV */                ERR("No such device", 248)
  /* 16 - EBADSEC */               ERR("Bad sectors found", 263)
  /* 17 - ENOMEDIUM */             ERR("No medium found", 281)
  /* 18 - EINSERT */               ERR("Insert media", 297)
  /* 19 - EDRVNRSP */              ERR("Drive not responding", 310)
  /* 20 - ESRCH */                 ERR("No such process", 331)
  /* 21 - ECHILD */                ERR("No child process", 347)
  /* 22 - EDEADLK */               ERR("Resource deadlock avoided", 364)
  /* 23 - ENOTBLK */               ERR("Block device required", 390)
  /* 24 - EISDIR */                ERR("Is a directory", 412)
  /* 25 - EINVAL */                ERR("Invalid argument", 427)
  /* 26 - EFTYPE */                ERR("Inappropriate file type of format", 444)
  /* 27 - EILSEQ */                ERR("Illegal byte sequence", 478)
  /* 28 */                         NONE
  /* 29 */                         NONE
  /* 30 */                         NONE
  /* 31 */                         NONE
  /* 32 - ENOSYS */                ERR("Function not implemented", 500)
  /* 33 - ENOENT */                ERR("No such file or directory", 525)
  /* 34 - ENOTDIR */               ERR("Not a directory", 551)
  /* 35 - EMFILE */                ERR("Too many open files", 567)
  /* 36 - EACCES */                ERR("Permission denied", 587)
  /* 37 - EBADF */                 ERR("Bad file descriptor", 605)
  /* 38 - EPERM */                 ERR("Operation not permitted", 625)
  /* 39 - ENOMEM */                ERR("Cannot allocate memory", 649)
  /* 40 - EFAULT */                ERR("Bad address", 672)
  /* 41 */                         NONE
  /* 42 */                         NONE
  /* 43 */                         NONE
  /* 44 */                         NONE
  /* 45 */                         NONE
  /* 46 - ENXIO */                 ERR("No such device or address", 684)
  /* 47 */                         NONE
  /* 48 - EXDEV */                 ERR("Cross-device link", 710)
  /* 49 - ENMFILES */              ERR("No more matching filenames", 728)
  /* 50 - ENFILE */                ERR("File table overflow", 755)
  /* 51 */                         NONE
  /* 52 */                         NONE
  /* 53 */                         NONE
  /* 54 */                         NONE
  /* 55 */                         NONE
  /* 56 */                         NONE
  /* 57 */                         NONE
  /* 58 - ELOCKED */               ERR("Locking conflict", 775)
  /* 59 - ENSLOCK */               ERR("No such lock", 792)
  /* 60 */                         NONE
  /* 61 */                         NONE
  /* 62 */                         NONE
  /* 63 */                         NONE
  /* 64 - EBADARG */               ERR("Bad argument", 805)
  /* 65 - EINTERNAL */             ERR("Internal error", 818)
  /* 66 - ENOEXEC */               ERR("Invalid executable file format", 833)
  /* 67 - ESBLOCK */               ERR("Memory block growth failure", 864)
  /* 68 - EBREAK */                ERR("Aborted by user", 892)
  /* 69 - EXCPT */                 ERR("Terminated with bombs", 908)
  /* 70 - ETXTBSY */               ERR("Text file busy", 930)
  /* 71 - EFBIG */                 ERR("File too big", 945)
  /* 72 */                         NONE
  /* 73 */                         NONE
  /* 74 */                         NONE
  /* 75 */                         NONE
  /* 76 */                         NONE
  /* 77 */                         NONE
  /* 78 */                         NONE
  /* 79 */                         NONE
  /* 80 - ELOOP */                 ERR("Too many symbolic links", 958)
  /* 81 - EPIPE */                 ERR("Broken pipe", 982)
  /* 82 - EMLINK */                ERR("Too many links", 994)
  /* 83 - ENOTEMPTY */             ERR("Directory not empty", 1009)
  /* 84 */                         NONE
  /* 85 - EEXIST */                ERR("File exists", 1029)
  /* 86 - ENAMETOOLONG */          ERR("Name too long", 1041)
  /* 87 - ENOTTY */                ERR("Not a tty", 1055)
  /* 88 - ERANGE */                ERR("Range error", 1065)
  /* 89 - EDOMAIN */               ERR("Domain error", 1077)
  /* 90 - EIO */                   ERR("I/O error", 1090)
  /* 91 - ENOSPC */                ERR("No space on device", 1100)
  /* 92 */                         NONE
  /* 93 */                         NONE
  /* 94 */                         NONE
  /* 95 */                         NONE
  /* 96 */                         NONE
  /* 97 */                         NONE
  /* 98 */                         NONE
  /* 99 */                         NONE
  /* 100 - EPROCLIM */             ERR("Too many processes", 1119)
  /* 101 - EUSERS */               ERR("Too many users", 1138)
  /* 102 - EDQUOT */               ERR("Quota exceeded", 1153)
  /* 103 - ESTALE */               ERR("Stale NFS file handle", 1168)
  /* 104 - EREMOTE */              ERR("Object is remote", 1190)
  /* 105 - EBADRPC */              ERR("RPC struct is bad", 1207)
  /* 106 - ERPCMISMATCH */         ERR("RPC version wrong", 1225)
  /* 107 - EPROGUNAVAIL */         ERR("RPC program not available", 1243)
  /* 108 - EPROGMISMATCH */        ERR("RPC program version wrong", 1269)
  /* 109 - EPROCUNAVAIL */         ERR("RPC bad procedure for program", 1295)
  /* 110 - ENOLCK */               ERR("No locks available", 1325)
  /* 111 - EAUTH */                ERR("Authentication error", 1344)
  /* 112 - ENEEDAUTH */            ERR("Need authenticator", 1365)
  /* 113 - EBACKGROUND */          ERR("Inappropriate operation for background process", 1384)
  /* 114 - EBADMSG */              ERR("Not a data message", 1431)
  /* 115 - EIDRM */                ERR("Identifier removed", 1450)
  /* 116 - EMULTIHOP */            ERR("Multihop attempted", 1469)
  /* 117 - ENODATA */              ERR("No data available", 1488)
  /* 118 - ENOLINK */              ERR("Link has been severed", 1506)
  /* 119 - ENOMSG */               ERR("No message of desired type", 1528)
  /* 120 - ENOSR */                ERR("Out of streams resources", 1555)
  /* 121 - ENOSTR */               ERR("Device not a stream", 1580)
  /* 122 - EOVERFLOW */            ERR("Value too large for defined data type", 1600)
  /* 123 - EPROTO */               ERR("Protocol error", 1638)
  /* 124 - ETIME */                ERR("Timer expired", 1653)
  /* 125 - E2BIG */                ERR("Argument list too long", 1667)
  /* 126 - ERESTART */             ERR("Interrupted system call restarted", 1690)
  /* 127 - ECHRNG */               ERR("Channel number out of range", 1724)
  /* 128 - EINTR */                ERR("Interrupted function call", 1752)
  /* 129 - ESNDLOCKED */           ERR("Sound system is already locked", 1778)
  /* 130 - ESNDNOTLOCK */          ERR("Sound system is not locked", 1809)
  /* 131 - EL2NSYNC */             ERR("Level 2 not synchronized", 1836)
  /* 132 - EL3HLT */               ERR("Level 3 halted", 1861)
  /* 133 - EL3RST */               ERR("Level 3 reset", 1876)
  /* 134 - ELNRNG */               ERR("Link number out of range", 1890)
  /* 135 - EUNATCH */              ERR("Protocol driver not attached", 1915)
  /* 136 - ENOCSI */               ERR("No CSI structure available", 1944)
  /* 137 - EL2HLT */               ERR("Level 2 halted", 1971)
  /* 138 - EBADE */                ERR("Invalid exchange", 1986)
  /* 139 - EXFULL */               ERR("Exchange full", 2003)
  /* 140 - ENOANO */               ERR("No anode", 2017)
  /* 141 - EBADRQC */              ERR("Invalid request code", 2026)
  /* 142 - EBADSLT */              ERR("Invalid slot", 2047)
  /* 143 - EBFONT */               ERR("Bad font file format", 2060)
  /* 144 - ENONET */               ERR("Machine is not on the network", 2081)
  /* 145 - ENOPKG */               ERR("Package is not installed", 2111)
  /* 146 - EADV */                 ERR("Advertise error", 2136)
  /* 147 - ESRMNT */               ERR("Srmount error", 2152)
  /* 148 - ECOMM */                ERR("Communication error on send", 2166)
  /* 149 - EDOTDOT */              ERR("RFS specific error", 2194)
  /* 150 - ELIBACC */              ERR("Cannot access a needed shared library", 2213)
  /* 151 - ELIBBAD */              ERR("Accessing a corrupted shared library", 2251)
  /* 152 - ELIBSCN */              ERR(".lib section in a.out corrupted", 2288)
  /* 153 - ELIBMAX */              ERR("Attempting to link in too many shared libraries", 2320)
  /* 154 - ELIBEXEC */             ERR("Cannot exec a shared library directly", 2368)
  /* 155 - ESTRPIPE */             ERR("Streams pipe error", 2406)
  /* 156 - EUCLEAN */              ERR("Structure needs cleaning", 2425)
  /* 157 - ENOTNAM */              ERR("Not a XENIX named type file", 2450)
  /* 158 - ENAVAIL */              ERR("No XENIX semaphores available", 2478)
  /* 159 - EREMOTEIO */            ERR("Remote I/O error", 2508)
  /* 160 - 299 */                  NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
                                   NONE
  /* 300 - ENOTSOCK */             ERR("Socket operation on non-socket", 2525)
  /* 301 - EDESTADDRREQ */         ERR("Destination address required", 2556)
  /* 302 - EMSGSIZE */             ERR("Message too long", 2585)
  /* 303 - EPROTOTYPE */           ERR("Protocol wrong type for socket", 2602)
  /* 304 - ENOPROTOOPT */          ERR("Protocol not available", 2633)
  /* 305 - EPROTONOSUPPORT */      ERR("Protocol not supported", 2656)
  /* 306 - ESOCKTNOSUPPORT */      ERR("Socket type not supported", 2679)
  /* 307 - EOPTNOTSUPP */          ERR("Operation not supported", 2705)
  /* 308 - EPFNOSUPPORT */         ERR("Protocol family not supported", 2729)
  /* 309 - EAFNOSUPPORT */         ERR("Address family not supported by protocol", 2759)
  /* 310 - EADDRINUSE */           ERR("Address already in use", 2800)
  /* 311 - EADDRNOTAVAIL */        ERR("Cannot assign requested address", 2823)
  /* 312 - ENETDOWN */             ERR("Network is down", 2855)
  /* 313 - ENETUNREACH */          ERR("Network is unreachable", 2871)
  /* 314 - ENETRESET */            ERR("Network dropped connection on reset", 2894)
  /* 315 - ECONNABORTED */         ERR("Software caused connection abort", 2930)
  /* 316 - ECONNRESET */           ERR("Connection reset by peer", 2963)
  /* 317 - EISCONN */              ERR("Socket is already connected", 2988)
  /* 318 - ENOTCONN */             ERR("Socket is not connected", 3016)
  /* 319 - ESHUTDOWN */            ERR("Cannot send after shutdown", 3040)
  /* 320 - ETIMEDOUT */            ERR("Connection timed out", 3067)
  /* 321 - ECONNREFUSED */         ERR("Connection refused", 3088)
  /* 322 - EHOSTDOWN */            ERR("Host is down", 3107)
  /* 323 - EHOSTUNREACH */         ERR("No route to host", 3120)
  /* 324 - EALREADY */             ERR("Operation already in progress", 3137)
  /* 325 - EINPROGRESS */          ERR("Operation now in progress", 3167)
  /* 326 - EAGAIN */               ERR("Operation would block", 3193)
  /* 327 - ENOBUFS */              ERR("No buffer space available", 3215)
  /* 328 - ETOOMANYREFS */         ERR("Too many references", 3241)
  NONE
  NONE
  NONE
  NONE
  NONE
  NONE
  NONE
  NONE
  NONE
  NONE
  NONE
  NONE
  NONE
  NONE
  NONE
  NONE
  NONE
  NONE
  NONE
  NONE
  NONE
  /* 350 - ENOTSUP */              ERR("Function not implemented", 3261)
  /* 351 - ECANCELED */            ERR("Operation canceled", 3286)
  /* 352 - EOWNERDEAD */           ERR("Owner died", 3305)
  /* 353 - ENOTRECOVERABLE */      ERR("State not recoverable", 3316)

#undef ERR
#undef NONE
