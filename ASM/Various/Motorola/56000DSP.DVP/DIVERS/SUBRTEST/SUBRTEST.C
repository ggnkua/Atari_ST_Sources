#include "osbind.h"
#include "dspbind.h"

/*	Subroutines 0 to 8	 -	move	htx,r0
					move	#1,htx
					rti
*/

char subr0[] = {0x60,0xf0,0x00,0x00,0xff,0xeb,0x08,0xf4,0xab,
		0x00,0x00,0x00,0x00,0x00,0x04};
char subr1[] = {0x60,0xf0,0x00,0x00,0xff,0xeb,0x08,0xf4,0xab,
		0x00,0x00,0x01,0x00,0x00,0x04};
char subr2[] = {0x60,0xf0,0x00,0x00,0xff,0xeb,0x08,0xf4,0xab,
		0x00,0x00,0x02,0x00,0x00,0x04};
char subr3[] = {0x60,0xf0,0x00,0x00,0xff,0xeb,0x08,0xf4,0xab,
		0x00,0x00,0x03,0x00,0x00,0x04};
char subr4[] = {0x60,0xf0,0x00,0x00,0xff,0xeb,0x08,0xf4,0xab,
		0x00,0x00,0x04,0x00,0x00,0x04};
char subr5[] = {0x60,0xf0,0x00,0x00,0xff,0xeb,0x08,0xf4,0xab,
		0x00,0x00,0x05,0x00,0x00,0x04};
char subr6[] = {0x60,0xf0,0x00,0x00,0xff,0xeb,0x08,0xf4,0xab,
		0x00,0x00,0x06,0x00,0x00,0x04};
char subr7[] = {0x60,0xf0,0x00,0x00,0xff,0xeb,0x08,0xf4,0xab,
		0x00,0x00,0x07,0x00,0x00,0x04};
char subr8[] = {0x60,0xf0,0x00,0x00,0xff,0xeb,0x08,0xf4,0xab,
		0x00,0x00,0x08,0x00,0x00,0x04};

/* 		subroutine 9		-		
						move	X:HTX,r0
						move	#>500,A1
						move	#>10,n0
						move	#>1,x0
						move	#>0,B1
					loop
						add	x0,B
						sub	x0,A
						jgt	(r0+n0)
						move	B1,X:HTX
						rti
*/

char subr9[] = {0x60,0xf0,0x00,0x00,0xff,0xeb,0x54,0xf4,0x00,0x00,0x01,0xf4,
		0x70,0xf4,0x00,0x00,0x00,0x0a,0x44,0xf4,0x00,0x00,0x00,0x01,
		0x55,0xf4,0x00,0x00,0x00,0x00,0x20,0x00,0x48,0x20,0x00,0x44,
		0x0a,0xe8,0xa7,0x55,0x70,0x00,0x00,0xff,0xeb,0x00,0x00,0x04};

long subrsize[] = {5,5,5,5,5,5,5,5,5,16};
int  abil[10];

long temp;
char *subptr;
long subsize;
int  ability;
int  dsphandle;

long ptemp;
int pability;
int state;
long xavail,yavail;
long buffer;

main()
{
   int i;
   char ch;
   int val;

   ability = 0;

/* FIRST TEST PROGRAM STUFF */

   buffer = Malloc(50000L);
   Dsp_LoadProg("test1.lod",55,buffer);
   Dsp_DoBlock(0L,0L,&ptemp,1L);
   ptemp = (ptemp >> 8);
   printf("Program return value = %X. \n",ptemp);   
   pability = Dsp_GetProgAbility();
   printf("Program ability is %d. \n",pability);
   for(i = 0;i < 10;i++)
	abil[i] = Dsp_RequestUniqueAbility();

   printf(" Begin input (0 - 9) to execute subroutines.\n");
   printf("\n");
   ch = Bconin(2);
   while(ch != 'q')
   {
	val = (int)(ch - '0');
	switch(ch)
	{
	   case 'a':
		   Dsp_Available(&xavail,&yavail);
		   printf("Dsp_Avail call made\n");
		   printf("X available = %D\n",xavail);
		   printf("Y available = %D\n",yavail);
		   ability = 0;
		   break;
	   case 'f':
		   Dsp_FlushSubroutines();
		   printf("Subroutines flushed\n");
		   ability = 0;
		   break;
	   case 'l':
		   state = Dsp_Lock();
		   printf("Dsp_Lock: state = %d \n",state);
		   ability = 0;
		   break;		   
	   case 'u':
		   Dsp_Unlock();
		   printf("Dsp_Unlock call made \n");
		   ability = 0;
		   break;		   

	   case 'h':
		   printf("Inquiring Host flag 0 \n");			
		   state = Dsp_Hf0(0xffff);
		   printf("Host flag 0 = %d\n",state);
		   ability = 0;
		   break;
	   case 'j':
		   printf("Clearing Host flag 0 \n");			
		   Dsp_Hf0(0);
		   ability = 0;
		   break;
	   case 'k':
		   printf("setting Host flag 0 \n");			
		   Dsp_Hf0(1);
		   ability = 0;
		   break;
	   case '0':
		   subptr = subr0;
		   subsize = subrsize[val];
		   ability = abil[val];
		   break;			
	   case '1':
		   subptr = subr1;
		   subsize = subrsize[val];
		   ability = abil[val];
		   break;			
	   case '2':
		   subptr = subr2;
		   subsize = subrsize[val];
		   ability = abil[val];
		   break;			
	   case '3':
		   subptr = subr3;
		   subsize = subrsize[val];
		   ability = abil[val];
		   break;			
	   case '4':
		   subptr = subr4;
		   subsize = subrsize[val];
		   ability = abil[val];
		   break;			
  	   case '5':
		   subptr = subr5;
		   subsize = subrsize[val];
		   ability = abil[val];
		   break;			
	   case '6':
		   subptr = subr6;
		   subsize = subrsize[val];
		   ability = abil[val];
		   break;			
	   case '7':
		   subptr = subr7;
		   subsize = subrsize[val];
		   ability = abil[val];
		   break;			
	   case '8':
		   subptr = subr8;
		   subsize = subrsize[val];
		   ability = abil[val];
		   break;			
	   case '9':
		   subptr = subr9;
		   subsize = subrsize[val];
		   ability = abil[val];
		   break;			
	   default:
		   ability = 0;
		   break;
	}
        if(ability)
	{
	   dsphandle = Dsp_InqSubrAbility(ability);
	   if(dsphandle)
	   {
		Dsp_RunSubroutine(dsphandle);
   		Dsp_BlkUnpacked(0L,0L,&temp,1L);
		printf("DSP handle found with matching ability\n");
   		printf("Output from DSP = %D \n",temp);
	   }
	   else
	   {
	        dsphandle = Dsp_LoadSubroutine(subptr,subsize,ability);
	        Dsp_RunSubroutine(dsphandle);
	        Dsp_BlkUnpacked(0L,0L,&temp,1L);
		printf("Ability not found, loading subroutine\n");
	        printf("Output from DSP = %D \n",temp);
	   }
	}
   ch = Bconin(2);
   }
}

