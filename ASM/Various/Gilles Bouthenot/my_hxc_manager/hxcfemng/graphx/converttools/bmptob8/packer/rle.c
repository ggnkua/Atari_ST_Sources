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

void rlepack(unsigned char * bufferin,int sizein,unsigned char * bufferout,int * sizeout)
{
//	unsigned char* buffer;
	unsigned char c1;	
	unsigned char count1;	
int i,j,k;
	int mode;
		
	mode=0; //retit

	//buffer=(unsigned char*)malloc(sizein*2);


// 1 0000000 BBBBBBBB ...........
// 0 0000000 OOOOOOOO OOOOOOO
//
	
	
	count1=0;
	if(bufferin[0]==bufferin[1]) 
	{
		c1=bufferin[0];
		mode=0;
		k=0;
	}
	else 
	{
		c1=~bufferin[0];
		mode=1;
		k=0;
	}

	
	i=0;
	j=0;
	do
	{

		
		switch(mode)
		{
		case 0:
		
			if(c1==bufferin[i])
			{
				count1++;
				if(count1==0x7F)
				{
					bufferout[j]=count1&0x7F;
					j++;
					bufferout[j]=c1;
					j++;
					count1=1;
				}
			}
			else
			{	
				bufferout[j]=count1&0x7F;
				j++;
				bufferout[j]=c1;
				j++;
				c1=bufferin[i];
				count1=1;
				if(c1==bufferin[i+1]) mode=0;
				else
				{
					mode=1;
					k=j;
					j++;
				}
			}
		break;
		
		case 1:
			if(c1!=bufferin[i] && (bufferin[i]!=bufferin[i+1]) )
			{
				count1++;
				bufferout[j]=c1;
				c1=bufferin[i];
				
				j++;
				if(count1==0x7F)
				{
					bufferout[k]=(count1&0x7F)|0x80;
					k=j;
					count1=1;
				}

			}
			else
			{
				bufferout[j]=c1;
				j++;
				c1=bufferin[i];
				bufferout[k]=(count1&0x7F)|0x80;
				k=j;
				count1=1;
			
				if(c1==bufferin[i+1]) mode=0;
				else mode=1;
			}
		break;
		}

	i++;
	}while(i<=sizein);


	*sizeout=j;

}


unsigned char * rleunpack(unsigned char * bufferin,int sizein,unsigned char * bufferout,int * sizeout)
{
	unsigned char c1,c2;		
	int i,j,k;


	i=0;
	k=0;
	do
	{

		c1=bufferin[i];
		switch(c1&0x80)
		{

		case 0:
			i++;
			j=c1&0x7F;
			c2=bufferin[i];
			while(j)
			{
				bufferout[k]=c2;
				k++;
				j--;
			}
			i++;
			break;

		case 0x80:
			i++;
			j=c1&0x7F;

			while(j)
			{
				bufferout[k]=bufferin[i];
				k++;
				i++;
				j--;
			}
			break;
		}

	}while(i<=sizein);

	return 0;
}
