// bintoh.cpp : Defines the entry point for the console application.
//

//#include "stdafx.h"
#include "stdio.h"
#include "malloc.h"
#include "string.h"

#include <windows.h>
#include "packer/pack.h"

typedef struct {
	unsigned long xres;
	unsigned long yres;
	unsigned long size;
	unsigned long csize;
	unsigned char type;
	unsigned char pack;
} bmpinfo;


char * extractbmpdata(char *bmpfile,bmpinfo *info)
{
	FILE * file;
	int p,m,i,j,o,k;
	long s;
	unsigned long taille,taille2;
	unsigned char * dbuffer;
	unsigned char vc;

	BITMAPFILEHEADER bmph;
	BITMAPINFOHEADER bmih;
	unsigned char pallette[256*8];


	file=fopen(bmpfile,"rb");
	if(file!=NULL)
	{
		//Determination taille fichier
		fseek(file,0,SEEK_END);
		taille=ftell(file);
		fseek(file,0,SEEK_SET);

		// lecture entetes
		if(info->type!=0xff)
		{
		fread(&bmph,sizeof(bmph),1,file);
		fread(&bmih,sizeof(bmih),1,file);

	
		info->xres=bmih.biWidth;
		info->yres=bmih.biHeight;

			if(info->type==9)
			{
				fread(&pallette,256*4,1,file);
			}
			
		}
		//info->type=bmih.biBitCount;
		
		s=bmih.biWidth;
		do
		{
			s=s-4;
		}while(s>=4);
			
		if(s!=0)
		s=4-s;
		
		taille2=((taille-bmph.bfOffBits)-(s*bmih.biHeight));
		if(info->type==0xff) taille2=taille;

		if(info->type==9) taille2=taille2+(4*256);

		if(info->type==1) 	info->size=taille2/8;
		else	info->size=taille2;
		
		//mem data
		dbuffer=(char *) malloc(taille2+100);
		
		p=0;
		j=0;
		if(info->type==9)
		{
			for(i=0;i<256;i++)
			{
				dbuffer[(i*4)+2]=pallette[(i*4)]>>3;
				dbuffer[(i*4)+1]=pallette[(i*4)+1]>>2;
				dbuffer[(i*4)+0]=pallette[(i*4)+2]>>3;


			}
			p=4*256;
			j=p;
		}


		fseek(file,bmph.bfOffBits,SEEK_SET);

	
		
		m=0;
		
		k=0;
		vc=0;

		for(i=0;i<taille2-j;i++)
		{

			if(info->type==1)
			{
				if(fgetc(file)) vc=vc|(0x80>>k);
				k++;
				if(k>=8)
				{
					dbuffer[p]=vc;
					p++;
					k=0;
					vc=0;
				}

			}
			else
			{	
				dbuffer[p]=fgetc(file);
				p++;
			}
			
			//sup du padding bmp
			if(info->type!=0xff)
			{
				m++;
				if(m>=bmih.biWidth)
				{
					for(o=0;o<s;o++)fgetc(file);
					m=0;
				}
			}
							
			
		}
		fclose(file);
		return dbuffer;
	}
	return NULL;


}

char  buildincludefile(char *includefile,bmpinfo *info,unsigned char * dbuffer)
{
	int l,i;
	FILE * file2;
	
	char temp[128];
	char temp2[128];

	sprintf(temp,"%s",includefile);
	for(i=0;i<strlen(temp);i++) 
	{
		if(temp[i]=='.') temp[i]='_';
	}
	if(info->type!=0xff) sprintf(temp2,"data_bmp_%s.h",temp);
	else sprintf(temp2,"data_%s.h",temp);
	printf("Create %s :",temp2);


	file2=fopen(temp2,"w");
	if(info->type!=0xff)
	{
		fprintf(file2,"//////////////////////////////\n//\n//\n// Created by Binary2Header V0.5\n// (c) HxC2001\n// (c) PowerOfAsm\n//\n");
		fprintf(file2,"// File: %s  Size: %d  (%d) x:%d y:%d\n//\n//\n",includefile,info->size,info->csize,info->xres,info->yres);
		fprintf(file2,"\n\n");
		fprintf(file2,"#ifndef BMAPTYPEDEF\n#define BMAPTYPEDEF\n\n");
		fprintf(file2,"typedef  struct _bmaptype\n{\n   int type;\n   int Xsize;\n   int Ysize;\n   int size;\n   int csize;\n   unsigned char * data;\n}bmaptype __attribute__ ((aligned (2)));\n\n");
		fprintf(file2,"#endif\n");			
		fprintf(file2,"\n\n");
		fprintf(file2,"unsigned char __attribute__ ((aligned (2))) data_bmp%s[]={\n",temp);
	}
	else
	{
		fprintf(file2,"//////////////////////////////\n//\n//\n// Created by Binary2Header V0.5\n// (c) HxC2001\n// (c) PowerOfAsm\n//\n");
		fprintf(file2,"// File: %s  Size: %d  (%d) \n//\n//\n",includefile,info->size,info->csize);
		fprintf(file2,"\n\n");
		fprintf(file2,"#ifndef DATATYPEDEF\n#define DATATYPEDEF\n\n");
		fprintf(file2,"typedef  struct _datatype\n{\n   int type;\n   int size;\n   int csize;\n   unsigned char * data;\n}datatype __attribute__ ((aligned (2)));\n\n");
		fprintf(file2,"#endif\n");			
		fprintf(file2,"\n\n");
		fprintf(file2,"unsigned char __attribute__ ((aligned (2))) data__%s[]={\n",temp);

	}
		
	l=0;
	for(i=0;i<info->csize;i++)
	{
		{
			fprintf(file2,"0x%.2x",dbuffer[i]);
			if((i+1)<info->csize)fprintf(file2,",");
		}
		
		l++;
		if(l>=32) 
		{
			l=0;						
			fprintf(file2,"\n");
		}
	}

	fprintf(file2,"};\n");
	if(info->type!=0xff) fprintf(file2,"\n\nstatic bmaptype bitmap_%s[]=\n{{\n %d,\n %d,\n %d,\n %d,\n %d,\n data_bmp%s\n}};\n",temp,info->type,info->xres,info->yres,info->size,info->csize,temp);
	else fprintf(file2,"\n\nstatic datatype data_%s[]=\n{{\n %d,\n %d,\n %d,\n data__%s\n}};\n",temp,info->type,info->size,info->csize,temp);
	fclose(file2);
	return 0;
}


int main(int argc, char* argv[])
{
	
	bmpinfo infoo;
	unsigned char * dbuffer;
	unsigned char * cbuffer;
	int size,i;
	printf("Binary2Header V0.5\nHxC2001\n");
	if(argc==1)printf("Usage:\n");
	else
	{		
		i=argc-1;
		do{
			if(strcmp("-BMP8",argv[i])==0)  infoo.type=8;
			if(strcmp("-BMP8P",argv[i])==0)  infoo.type=9;
			if(strcmp("-BMP1",argv[i])==0)  infoo.type=1;
			if(strcmp("-DATA",argv[i])==0)  infoo.type=0xff;
			i--;
		}while(i);

			dbuffer=NULL;
			dbuffer=(unsigned char *)extractbmpdata(argv[1],&infoo);

			if(dbuffer!=NULL)
			{//(info.size+100+1024
				printf("%d\n",infoo.size+100+1024);
				cbuffer=(unsigned char *)malloc(infoo.size+100+1024);
				if(cbuffer!=NULL)
				{
					printf("Pack...\n");
					pack(dbuffer,infoo.size,cbuffer, &size);
				
					printf("build include file...\n");
					infoo.csize=size;
					buildincludefile(argv[1],&infoo,cbuffer);
					free(cbuffer);
					free(dbuffer);
				}
				else
				{
					printf("MallocError!\n");					
				}
			}
	}
	return 0;
}

