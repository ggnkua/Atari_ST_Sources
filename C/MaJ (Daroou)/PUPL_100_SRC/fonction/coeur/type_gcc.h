/* --------------------------------------------------------------- */
/* Cr‚e le: 09.06.2014                                             */
/* modification le: 22.11.2023                                     */
/*******************************************************************/


#ifndef  __TYPE_GCC_H__
 #define __TYPE_GCC_H__


 /* Quelques D‚fines */
 #ifndef	TRUE
  #define	TRUE	(1)
 #endif

 #ifndef FALSE
  #define	FALSE	(0)
 #endif

 #ifndef  CRLF
 #define	CRLF	"\015\012"
 #endif

 #ifndef int8
  #define int8	char
 #endif

 #ifndef uint8
  #define uint8	unsigned char
 #endif

#ifndef int16
  #define int16	short
 #endif

 #ifndef uint16
  #define uint16 unsigned short
 #endif

 #ifndef int32
  #define int32	long
 #else
 #warning "probleme type gcc int32 deja defini"
 #endif

 #ifndef uint32
  #define uint32 unsigned long
 #endif

 #ifndef int64
  #define int64	long long
 #endif

 #ifndef uint64
  #define uint64 unsigned long long
 #endif


#endif	/*   __TYPE_GCC_H__   */


