/* This is a 'quick n dirty' hack to convert DRI objects to the GNU.OUT format
   used on the ATARI ST.
	For problems contact
	<Joerg.Hessdoerfer@EUROPA.rs.kp.dlr.de> (preferable adress!) or, if this
	doesn't work, <Hessdorf@sun.ph-cip.uni-koeln.de> */

/* Copyright (C) 1992 Joerg Hessdoerfer, Cologne, Germany.
   written by Joerg Hessdoerfer
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.  */

#include <stdio.h>
#include <stdlib.h>
#include "gnu-out.h"

struct
{
	short magic;
	long tsize;
	long dsize;
	long bsize;
	long ssize;
	char reserved[10];
}ObjHeader;

/* pointers to DRI segments */
short *txtbase,*database;
short *txtfixup,*datafixup;
char *symbase;

/* pointers & indices to GNU segments */
struct exec GNUheader;
int *symxtab;
struct nlist *syment;
char *symstrs;
long symstrpos;
struct relocation_info *textreloc,*datareloc;
int textrelpos,datarelpos;
int symentpos,validsym;

int main(int argc, char **argv)
{
	int i,width;

	if(argc<2)printf("Usage: %s file...\n",argv[0]);
	else
	{
		for(i=1;i<argc;i++)
		{
			FILE *fp;
			short *buffer;
			int size,j;
			
			fp=fopen(argv[i],"rb");
			if(!fp)
			{
				printf("%s: can't open '%s'!\n",argv[0],argv[i]);
				exit(1);
			}
			fread(&ObjHeader,1,sizeof(ObjHeader),fp);
			if(ObjHeader.magic!=0x601a)
			{
				printf("%s: '%s' is no standard DRI object. Sorry.\n",argv[0],argv[i]);
				fclose(fp);
				exit(2);
			}

			N_SET_INFO(GNUheader,OMAGIC,0,0);
			GNUheader.a_text=ObjHeader.tsize;
			GNUheader.a_data=ObjHeader.dsize;
			GNUheader.a_bss=ObjHeader.bsize;
			GNUheader.a_syms=(ObjHeader.ssize/14)*sizeof(struct nlist);
			GNUheader.a_trsize=0; /* we don't know the size yet, compute it later! */
			GNUheader.a_drsize=0; /* same goes here! */
			GNUheader.a_entry=0; /* always zero for object files! */
			
			size=2*ObjHeader.tsize+2*ObjHeader.dsize+ObjHeader.ssize;
			if((buffer=malloc(size))==NULL)
			{
				printf("%s: not enough memory! Stop!\n",argv[0]);
				fclose(fp);
				exit(3);
			}

			fread(buffer,1,size,fp);
			fclose(fp);

			/* now calculate the DRI object segment starts */
			txtbase=buffer;
			txtfixup=&buffer[(ObjHeader.tsize+ObjHeader.dsize+ObjHeader.ssize)/2];
			database=&buffer[ObjHeader.tsize/2];
			datafixup=&buffer[ObjHeader.tsize+(ObjHeader.dsize+ObjHeader.ssize)/2];
			symbase=(char *)&buffer[(ObjHeader.tsize+ObjHeader.dsize)/2];

			symstrs=malloc((ObjHeader.ssize/14)*10); /* a DRI sym entry is 14 bytes wide,
																	  it's name is restricted to 8 bytes */
			syment=malloc(GNUheader.a_syms);
			symxtab=malloc((ObjHeader.ssize/14)*sizeof(int));
			
			if(!symstrs || !syment || !symxtab)
			{
				printf("%s: not enough memory! Stop!\n",argv[0]);
				exit(1);
			}

			symstrpos=4; /* IMPORTANT!!! A value of 0 is considered to refer to NO name at all! */
			/* Besides, it could have been documented that the size of the string-table is noted
			   in the longword immediately before it!! ( therefore the '4'!!!!) */
			
			for(j=0; j<((ObjHeader.ssize/14)*10);j++)symstrs[j]=0; /* clear stringtable first! */

			symentpos=0;						
			for(j=0; j<ObjHeader.ssize;j+=14)
			{
				switch((unsigned char)(symbase[j+8]))
				{
					case 0x88: /* external */
					case 0xa8:
						syment[symentpos].n_type=N_UNDF | N_EXT;
						syment[symentpos].n_value=0;
						validsym=1;
						break;
					case 0x81: /* local syms */
					case 0x82:
					case 0x84:
						validsym=0;	/* ignore them for now, as they're not needed for linking! */
						break;	
					case 0xa1: /* BSS */
						syment[symentpos].n_type=N_BSS | N_EXT;
						syment[symentpos].n_value=*(long *)&symbase[j+10];
						validsym=1;
						break;
					case 0xa2: /* TEXT */
						syment[symentpos].n_type=N_TEXT | N_EXT;
						syment[symentpos].n_value=*(long *)&symbase[j+10];
						validsym=1;
						break;
					case 0xa4: /* DATA */
						syment[symentpos].n_type=N_DATA | N_EXT;
						syment[symentpos].n_value=*(long *)&symbase[j+10]+GNUheader.a_text;
						/* now here's a real goodie: in a.out objects, the address of a symbol
						   in the data segment refers to its address plus the size of the text
						   segment. Man, I can't tell ya how I hate this! (Of course that feature's
						   not documented!!!) */
						validsym=1;
						break;
					default:
						printf("%s: unknown symbol type '%x' at %d! Ignored!\n",
								argv[0],(unsigned int)symbase[j+8],symentpos);
						validsym=0;
						break;
				}
				if(validsym)
				{
					symxtab[j/14]=symentpos;	/* build up cross-refs */
					strncpy(&symstrs[symstrpos],&symbase[j],8);
					symstrs[symstrpos+strlen(&symstrs[symstrpos])]=0;
					syment[symentpos].n_un.n_strx=symstrpos;
					symstrpos+=strlen(&symstrs[symstrpos])+1;
					symstrs[symstrpos]=0; /* temporarily terminate string-list */
					syment[symentpos].n_other=0;
					syment[symentpos].n_desc=0;
					symentpos++;
				}
			}

			*(long *)symstrs=symstrpos;
			GNUheader.a_syms=symentpos*sizeof(struct nlist); /* correct symbol table size */
			
			for(j=0;j<(ObjHeader.tsize/2);j++)
			{
				/* compute a_trsize */
				switch(txtfixup[j] & 0x07)
				{
					case 0:		/* ignore zero types (no reloc) and LW markers,
										as well as instructions */
					case 5:		
					case 7:		
						break;
					default:
						GNUheader.a_trsize+=sizeof(struct relocation_info);
						break;
				}
			}
			
			for(j=0;j<(ObjHeader.dsize/2);j++)
			{
				/* compute a_drsize */
				switch(datafixup[j] & 0x07)
				{
					case 0:		/* ignore zero types (no reloc) and LW markers,
										as well as instructions */
					case 5:		
					case 7:		
						break;
					default:
						GNUheader.a_drsize+=sizeof(struct relocation_info);
						break;
				}
			}

			textreloc=malloc(GNUheader.a_trsize);
			datareloc=malloc(GNUheader.a_drsize);
			textrelpos=datarelpos=0;
			
			if(!textreloc || !datareloc)
			{
				printf("%s: not enough memory! Stop!\n",argv[0]);
				exit(1);
			}

			width=1; /* default word size is 16bit */
			
			for(j=0;j<(ObjHeader.tsize/2);j++)
			{
				switch(txtfixup[j] & 0x07)
				{
					case 0:
						break;
					case 1: /* absolute DATA reloc */
						textreloc[textrelpos].r_address=((width==2) ? j*2 - 2 : j*2);
						textreloc[textrelpos].r_symbolnum=N_DATA;
						textreloc[textrelpos].r_pcrel=0;
						textreloc[textrelpos].r_length=width; width=1;
						textreloc[textrelpos].r_extern=0;
						textreloc[textrelpos++].r_pad=0;
						break;
					case 2: /* absolute TEXT reloc */
						textreloc[textrelpos].r_address=((width==2) ? j*2 - 2 : j*2);
						textreloc[textrelpos].r_symbolnum=N_TEXT;
						textreloc[textrelpos].r_pcrel=0;
						textreloc[textrelpos].r_length=width; width=1;
						textreloc[textrelpos].r_extern=0;
						textreloc[textrelpos++].r_pad=0;
						break;
					case 3: /* absolute BSS reloc */
						textreloc[textrelpos].r_address=((width==2) ? j*2 - 2 : j*2);
						textreloc[textrelpos].r_symbolnum=N_BSS;
						textreloc[textrelpos].r_pcrel=0;
						textreloc[textrelpos].r_length=width; width=1;
						textreloc[textrelpos].r_extern=0;
						textreloc[textrelpos++].r_pad=0;
						break;
					case 4: /* absolute EXTERN reloc */
						textreloc[textrelpos].r_address=((width==2) ? j*2 - 2 : j*2);
						textreloc[textrelpos].r_symbolnum=symxtab[(txtfixup[j] >> 3)];
						textreloc[textrelpos].r_pcrel=0;
						textreloc[textrelpos].r_length=width; width=1;
						textreloc[textrelpos].r_extern=1;
						textreloc[textrelpos++].r_pad=0;
						break;
					case 5: /* longword marker */
						width=2;
						break;
					case 6: /* PC-rel EXTERN reloc */
						textreloc[textrelpos].r_address=((width==2) ? j*2 - 2 : j*2);
						textreloc[textrelpos].r_symbolnum=symxtab[(txtfixup[j] >> 3)];
						textreloc[textrelpos].r_pcrel=1;
						textreloc[textrelpos].r_length=width; width=1;
						textreloc[textrelpos].r_extern=1;
						textreloc[textrelpos++].r_pad=0;
						break;
					case 7: /* Instruction marker */
						break;
				}
			}

			width=1; /* default word size is 16bit */
			
			for(j=0;j<(ObjHeader.dsize/2);j++)
			{
				switch(datafixup[j] & 0x07)
				{
					case 0:
						break;
					case 1: /* absolute DATA reloc */
						datareloc[datarelpos].r_address=((width==2) ? j*2 - 2 : j*2);
						datareloc[datarelpos].r_symbolnum=N_DATA;
						datareloc[datarelpos].r_pcrel=0;
						datareloc[datarelpos].r_length=width; width=1;
						datareloc[datarelpos].r_extern=0;
						datareloc[datarelpos++].r_pad=0;
						break;
					case 2: /* absolute TEXT reloc */
						datareloc[datarelpos].r_address=((width==2) ? j*2 - 2 : j*2);
						datareloc[datarelpos].r_symbolnum=N_TEXT;
						datareloc[datarelpos].r_pcrel=0;
						datareloc[datarelpos].r_length=width; width=1;
						datareloc[datarelpos].r_extern=0;
						datareloc[datarelpos++].r_pad=0;
						break;
					case 3: /* absolute BSS reloc */
						datareloc[datarelpos].r_address=((width==2) ? j*2 - 2 : j*2);
						datareloc[datarelpos].r_symbolnum=N_BSS;
						datareloc[datarelpos].r_pcrel=0;
						datareloc[datarelpos].r_length=width; width=1;
						datareloc[datarelpos].r_extern=0;
						datareloc[datarelpos++].r_pad=0;
						break;
					case 4: /* absolute EXTERN reloc */
						datareloc[datarelpos].r_address=((width==2) ? j*2 - 2 : j*2);
						datareloc[datarelpos].r_symbolnum=symxtab[(datafixup[j] >> 3)];
						datareloc[datarelpos].r_pcrel=0;
						datareloc[datarelpos].r_length=width; width=1;
						datareloc[datarelpos].r_extern=1;
						datareloc[datarelpos++].r_pad=0;
						break;
					case 5: /* longword marker */
						width=2;
						break;
					case 6: /* PC-rel EXTERN reloc */
						datareloc[datarelpos].r_address=((width==2) ? j*2 - 2 : j*2);
						datareloc[datarelpos].r_symbolnum=symxtab[(datafixup[j] >> 3)];
						datareloc[datarelpos].r_pcrel=1;
						datareloc[datarelpos].r_length=width; width=1;
						datareloc[datarelpos].r_extern=1;
						datareloc[datarelpos++].r_pad=0;
						break;
					case 7: /* Instruction marker */
						break;
				}
			}

			/* now the complete file's processed! just write it to disk:
			   we are a bit crappy here: since we work on object files,
			   there's no error checking nor saving of the original, since
			   that may easily be reproduced! (I hope) */
			
			fp=fopen(argv[i],"wb");
			if(!fp)
			{
				printf("%s: Can't write file! Stop!\n",argv[0]);
				exit(1);
			}
			fwrite(&GNUheader,sizeof(GNUheader),1,fp);
			fwrite(buffer,1,GNUheader.a_text+GNUheader.a_data,fp);
			fwrite(textreloc,1,GNUheader.a_trsize,fp);
			fwrite(datareloc,1,GNUheader.a_drsize,fp);
			fwrite(syment,1,GNUheader.a_syms,fp);
			fwrite(symstrs,1,symstrpos+1,fp);
			fwrite(&"\0\0\0\0",1,4,fp);
			/* just terminate with 0L, this prevents mashing of last symbol,
			   don't ask me why this is necessary, it doesn't appear in
			   /real/ gcc objects. Remember, because of this the entire
			   size of the stringtable is 4 bytes larger! (Set somewhere
			   above into the first longword of the stringtable) */
			fclose(fp);

			free(buffer);
			free(syment);
			free(symxtab);
			free(symstrs);
			free(textreloc);
			free(datareloc);
		}
	}
	return 0;
}

/* Hey, long time ago since I've last written a prog in a /single/ procedure ;-) */
