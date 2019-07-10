#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>
#include <stdio.h>
#include "xxed.h"  

#include "globals.h"

	extern unsigned getbyte();
	extern char str2[],str3[];
	extern char twoblanks[];


print(thewin) /* send file or block to printer */
windowptr thewin;
{
	int button;
	char str[200];
	long l;

	if(Bcostat(0)==0)
	{	button = form_alert(1, "[1][ The printer is not connected | or not turned on! ][ OK ]");
		return;
	}

	while(Cconis()) Crawcin(); /* make sure io buffer clear */
	if(thewin->markson)
	{	sprintf(str, "[1][ Print block from | %s ? | (Any key aborts    |  while printing) ][ OK | CANCEL ]",thewin->title);
		button = form_alert(1,str);
		if (button == 1)	
			for (l=thewin->startmark;l<thewin->endmark+16;l+=16)
            {   print_line(thewin,l);
				if (Cconis())
				{	Crawcin();
				 	break;  /* any key to abort */
				}		
			}
	}		
	else
	{	sprintf(str, "[1][ Print file | %s ? | (Any key aborts    |  while printing) ][ OK | CANCEL ]",thewin->title);
		button = form_alert(1,str);
		if (button == 1)	
			for (l=0;l<thewin->flen+17;l+=16)
            {   print_line(thewin,l);
				if (Cconis())
				{	Crawcin();
				 	break;  /* any key to abort */
				}		
			}
	}		
	
}



print_line(thewin,pos) /* send a line to the printer */
	windowptr	thewin;
	long		pos;
{	int i;
	long  l;
	unsigned num;
	register int j,k;
	char *ptr2,*ptr3;

			l = pos&~0xf;
			ptr2 = str2;
			ptr3 = str3;

	           for (j=0; j < 16 ; j +=2 )
          {  for (k=0; k < 2  ; k++   )
            {	num = getbyte(thewin,l + j + k);
            	if(l+j+k < thewin->flen-1)
				{
					if(num>31)
						*(ptr3++) = num;
					else
						*(ptr3++) = (unsigned)0x2E;
					bcopy(table+num*2,ptr2,2);
					ptr2+=2;
				}
				else
				{	bcopy(twoblanks,ptr2,2);
					ptr2+=2;
					*(ptr3++) = 0x20;
				}
             }
				*(ptr2++)=0x20;
				*(ptr2++)=0x20;
           }   
				*(ptr2++)=0x20;
				*(ptr2++)=0x20;
				*(ptr2++)=0x0;
				pr_print(str2);
				*(ptr3++)=0x0D;
				*(ptr3++)=0x0A;
				*(ptr3++)=0x0;
				pr_print(str3);
}


pr_print(str) /* send a string to the printer */
	char *str;
{	int i;

	{	for (i=0;i<(strlen(str)+1);i++)
			Bconout(0,str[i]);
	}
}	
