
/****************************************************************/
/*                                                              */
/*      Define BDOS Function Codes                              */
/*    File: BDOSFunc.H                                          */
/****************************************************************/
 
#define SYSRESET 0
#define CONIN   1
#define CONOUT  2
#define READIN  3
#define PUNOUT  4
#define LISTOUT 5
#define DCONIO  6
#define GETIOB  7
#define SETIOB  8
#define PRNTSTR 9
#define READBUF 10
#define CONSTAT 11

#define SUPVMOD	0x20
#define MALLOC 	0x48
#define READ	0x3f
#define CREATE	0x3c
#define UNLINK	0x41
#define WRITE	0x40
#define CLOSE	0x3e
#define EXEC	0x4b
#define OPEN	0x3d
#define LSEEK	0x42
#define SETBLK	0x4a

extern long trap();
