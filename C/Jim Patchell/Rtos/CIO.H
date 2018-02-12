/*
** Header file for Central I/O Handler
*/

#ifndef CIO__H
#define CIO__H

#include "erorcode.h"
#include <stdarg.h>
/*
** This data structure is used to describe the i/o device
** that has been opened.
*/

typedef struct {
	int ichid;		/*	handler ID							0	*/
	int devnum;		/*	device number						2	*/
	char *dev_name;	/*	pointer to file name				4	*/
	int mode;		/*	i/o mode file was opened with		8	*/
	void *p;	/*	general purpose pointer					10	*/
	int exp2;		/*	future expansion					14	*/
}IOCB;

/*
** This vector table is used to locate the functions that
** perform the primitive I/O functions for a device
**
** A pointer to this vector table is located in the device
** handler lookup table.
*/

#ifdef __cplusplus
extern "C" {
#endif

#pragma function ( calling)
typedef struct {
	long (*openv)(IOCB *,va_list);				/*	0	open vector	*/
	long (*closv)(IOCB *,va_list);				/*	1	close vector	*/
	long (*getv)(IOCB *,va_list);				/*	2	get byte vector	*/
	long (*readv)(IOCB *,va_list);				/*	3	read buffer	*/
	long (*putv)(IOCB *,int,va_list);			/*	4	put byte vector	*/
	long (*writev)(IOCB *,va_list);				/*	5	write a buffer	*/
	long (*statv)(IOCB *,va_list);				/*	6	get status vector	*/
	long (*specv)(int cmd,IOCB *,va_list);		/*	7	special vector	*/
	long (*initv)(void);						/*	8	init code vector	*/
}H_JVEC;

#pragma function()

#ifdef __cplusplus
}
#endif

/*
** this is the structure of one element in the device driver
** lookup table.  Each device name is associtated with a vector
** table.
*/

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
	const char *dev_name;	/*	pointer to device name			*/
	H_JVEC *HtabsEntry;		/*	pointer to handler jump table	*/
}HTABS;

#ifdef __cplusplus
}
#endif

/*
	function numbers

	These functions are the predefined by CIO
*/

#define	ADD_HANDLER	1	/*	add handler to device table	*/
#define	OPEN		3	/*	open a device		*/
#define READ		5	/*	read a buffer		*/
#define	GETC		7	/*	get a character		*/
#define WRITE		9	/*	write a buffer		*/
#define	PUTC		11	/*	put a character		*/
#define	CLOSE		12	/*	close a device		*/
#define	STATUS		13	/*	get device status	*/

#define	MAX_HANDLE	31
#define	EOL	0x0a


/*
** file modes
*/
#define READ_ONLY	4
#define WRITE_ONLY	8

#ifdef __cplusplus
extern "C" {
#endif

extern void init_iocb(void);
extern long cio(va_list argp);

extern long AddHandler(const char *dev_name,const H_JVEC *jump_table);
extern int Open(char *dev_name,int mode);
extern int Close(int handle);
extern int Getc(int handle);
extern int Putc(int handle,int c);
extern int Status(int handle,char *buff,long count,int aux);
extern long Xio(int cmd,int handle,char *dev_name,char *buff,long count,int aux,...);
extern int StatusO(char *dev_name,char *buff,long count,int aux);
extern long Read(int handle,char *buff,long count);
extern long Write(int handle,char *buff,long count);

#ifdef __cplusplus
}
#endif

#endif
