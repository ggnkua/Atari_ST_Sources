/*===========================================================================--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-----------H----H--X----X-----CCCCC----22222----0000-----0000------11----------
----------H----H----X-X-----C--------------2---0----0---0----0--1--1-----------
---------HHHHHH-----X------C----------22222---0----0---0----0-----1------------
--------H----H----X--X----C----------2-------0----0---0----0-----1-------------
-------H----H---X-----X---CCCCC-----222222----0000-----0000----1111------------
-------------------------------------------------------------------------------
----------------------------------------- http://jeanfrancoisdelnero.free.fr --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------- official Infoticaires 2006 invitation ---------------------
------------------ French Retro-Gaming party in Courcelles --------------------
--------------------------- www.obsolete-tears.com ----------------------------
----------------------------  Jeff -  14/06/2006  -----------------------------
--===========================================================================*/

#include <malloc.h>
#include <string.h> 
#include "lzw.h"
#include "rle.h"

unsigned char pack(unsigned char * bufferin, unsigned long sizein,unsigned char * bufferout, int * sizeout)
{
	unsigned char* buffer;
	unsigned char* buffer2;
	unsigned long  newsize;
	unsigned long  newsize2;
	unsigned long  newsize3;
	int mode;


	buffer=(unsigned char*)malloc(sizein*10);
	buffer2=(unsigned char*)malloc(sizein*10);

//	rlepack(bufferin,sizein,buffer2,&newsize2);
	//lzw_compress(bufferin,buffer2,sizein,&newsize);

	lzw_compress(bufferin,buffer,sizein,&newsize3);

	mode=0;
	if(sizein<=newsize3 ) mode = 0; //rien
//	if(newsize2<sizein && newsize2< newsize) mode=1; //rle
	//if(newsize<sizein && newsize< newsize2) mode=2; //lzw
	else mode =2;
  //  if(newsize3<sizein && newsize3< newsize2 && newsize3< newsize) mode=3; //lzw+rle*/
//mode=2;
//printf("mode : %d\n",mode);
	mode=0;
	switch(mode)
	{

	case 0:
		memcpy((buffer2),bufferin,sizein);
		//buffer2[0]=0x0;
		memcpy(bufferout,buffer2,sizein+1);
		*sizeout=sizein+1;
		break;
		
		case 1:
			rlepack(bufferin,sizein,buffer+1,(int*)&newsize);
			buffer[0]=0x2;
			memcpy(bufferout,buffer,newsize+1);
			*sizeout=newsize+1;
		break;

		case 2:
			lzw_compress(bufferin,buffer+1,sizein,(int*)&newsize);
			buffer[0]=0x1;
			memcpy(bufferout,buffer,newsize+1);
			*sizeout=newsize+1;
		break;

		case 3:
			rlepack(bufferin,sizein,buffer2,(int*)&newsize);
			lzw_compress(buffer2,buffer+1,newsize,(int*)&newsize2);
			buffer[0]=0x3;
			memcpy(bufferout,buffer,newsize2+1);
			*sizeout=newsize2+1;

			break;


	}

//	free(buffer);
	free(buffer2);

return 0;
};



unsigned char * unpack(unsigned char * bufferin, unsigned long sizein,unsigned char * bufferout, unsigned long sizeout)
{
	unsigned char* buffer;
	buffer=(unsigned char*)malloc(sizeout+100);
	if(bufferin[0]&0x01)
	{
		lzw_expand(bufferin+1,buffer, sizeout );
	}
	else
	{
		memcpy(buffer,bufferin+1,sizeout);
	}

return  buffer;
};
