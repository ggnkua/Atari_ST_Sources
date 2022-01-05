#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <tos.h>

void READ_LOD(long*,long*);

/*void main()
{	long buf[1024];
	long LAB[1024];
	strcpy((char*)&buf,&"d:\\A.LOD");
	READ_LOD(&buf,&LAB);
}
*/

void READ_LOD(long *dst,long *symb)
{
	FILE *handle;
	char *temp;
	char cmd[80],label[26];
	char MEM[2];
	long ADR,*nb,*nb_cmd,fpos;
	long *nb_symb=symb;
	*symb++=0;
	
	handle=fopen(((char*)dst),"r");
	nb_cmd=dst;*dst++=0;
	do{
		fscanf(handle,"%s",cmd);
		if (strcmp(cmd,"_END")==0) break;
		if (strcmp(cmd,"_DATA")==0)
		{	(*nb_cmd)++;
			fscanf(handle,"%s %4lx",&MEM,&ADR);
			*dst++=('MEM '+MEM[0]-32);*dst++=ADR;
			nb=dst;*dst++=0;
			do
			{	if (fscanf(handle,"%6lx",&ADR)==0) break;
				*dst++=ADR;(*nb)++;
			}while(1);						
		}
		if (strcmp(cmd,"_SYMBOL")==0)
		{	if(fscanf(handle,"%s",&MEM)==0) break;
			do
			{	fpos=ftell(handle);
				if (fscanf(handle,"%s I %6lx",&label,&ADR)==0) break;
				if (strcmp(label,"_DATA")==0){ fseek(handle,fpos,0);break;}
				if (strcmp(label,"_SYMBOL")==0){ fseek(handle,fpos,0);break;}
				if (strcmp(label,"_END")==0){ fseek(handle,fpos,0);break;}
				(*nb_symb)++;
				temp=(char*)symb;*temp++=MEM[0];*temp++=0;
				symb=(long*)temp;*symb++=ADR;
				temp=(char*)symb;strcpy(temp++,label);
				symb+=5;
			}while(1);						
		}
		
		
	}while (1);
	fclose(handle);
}
