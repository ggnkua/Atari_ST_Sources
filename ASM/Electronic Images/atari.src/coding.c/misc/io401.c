/* IO401.ASM  c calls for mpu-401 input/output.
   uses small memory model in line with with main project program

*/

#include <dos.h>


#define	DATAPORT	0x330	/* MPU401 DATA PORT */
#define	STATPORT	0x331	/* MPU401 STATUS PORT */
#define DRR			0x040
#define MPUACK		0x0FE	/* MPU401 CODES: ACKNOWLEGE */

#define	TRIES		255		/* MAXIMUM TRIES ON GETTING RESPONSE FROM 401 */




int putcmd(int cmd)
/* output a byte of data to MPU401, check for acknowledge */
/* returns -1 if error, 1 if ok */
{
	int	count, retval;

	disable();
	outportb(STATPORT, (unsigned char)cmd);


	for(count=0; count <TRIES; count++)
	{
		if((inportb(STATPORT) & DRR) == 0)
			break;
	}
	if(count == TRIES)
		retval = -1;



	for(count=0; count <TRIES; count++)
	{
		if((inportb(STATPORT) & 0x80) == 0)
			break;
	}
	if(count == TRIES)
		retval = -1;

	if(inportb(DATAPORT) == MPUACK)
		retval = 1;
	else
		retval = -1;

	enable();
	return retval;

}


int getdata(void)
{
/*       getdata()                        */
/*       get a byte of data from MPU401 */
/*		 -1 indicates error */

	int		count;
	int		data;

	for(count=0; count <TRIES; count++)
	{
		if((inportb(STATPORT) & 0x80) == 0)
			break;
	}
	if(count == TRIES)
		return -1;

	data=(int)(inportb(DATAPORT));
	return data;

}


int putdata(int data)
/*       putdata()*/
/*       send a byte of data to MPU401 */
/*		 -1 indicates error, 1 = ok */
{
	int	count;

	for(count=0; count <TRIES; count++)
	{
		if((inportb(STATPORT) & DRR) == 0)
			break;
	}
	if(count == TRIES)
		return -1;

	outportb(DATAPORT,(unsigned char)data);
	return 1;
}

