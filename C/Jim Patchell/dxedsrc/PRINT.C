/*
	this is the module that prints the data for the editor out to
	the line printer.		I only had the LQ-800, so I hope this
	works on other stuff
*/
#include <osbind.h>
#include <obdefs.h>
#include <gemdefs.h>
#include <string.h>
#include "dx.h"
#include "dxed.h"
#include <stdio.h>
#include <ctype.h>

#define TAB 4
/*
	external variables
*/
extern int midi_ch;
extern char bulk_buff[4096],per_bulk[4096];
extern char file_path[128];
extern char old_file[20];
extern char edit[155],pedit[94];

/*
	global variables
*/
FILE *printer;

char per_types[3][] = {
	"pitch      ",
	"amp        ",
	"EG-Bias    "
};

/*
	this routine will print out one or all of the data for the
	voices loaded into buffers in the ST.  If one is selected,
	it prints out the data in the edit buffer, if all are selected
	it prints out the bulk buffer
*/

print_data(vw)
int vw;
{
	char temp[80],*e,*p;
	int result;
	int i;
	char te[155],tp[94];

	printer = fopen("PRT:","w");	/*	open printer	*/
	result = form_alert(1,"[2][Print which BUFFERS][EDIT|ALL|CANCEL]");
	switch(result)
	{
		case 1:	/*	EDIT	*/
			print_edit(edit,pedit);	/*	print out edit buffers	*/
			break;
		case 2:	/*	all	*/
			for(i=0;i < 32;++i)
			{
				bulk2ed(&bulk_buff[i * 128],te);
				pblk2ped(&per_bulk[i * 64],tp);
				print_edit(te,tp);
				fprintf(printer,"%c",0xc);	/*	do form feed */
			}
			break;
		case 3:	/*	cancel	*/
			break;
	}	/*	end of switch statement	*/
	fclose(printer);	/*	close the printer	*/
}

print_catalog(vw)
int vw;
{
	int result;
	char in_file[128],tempy[128];
	int fd;	/*	file descriptor	*/
	char *t_bulk;

	printer = fopen("PRT:","w");	/*	open printer	*/
	result = form_alert(1,"[2][Catalog of|which FILES][ONE|ALL|CANCEL]");
	switch(result)
	{
		case 1:	/*	one	*/
			if(get_file(tempy) == 0)
			{
				fclose(printer);	/*	close the printer	*/
				return;	/*	cancel was hit	*/
			}
			join_fname(in_file,file_path,tempy);
			if((fd = Fopen(in_file,0)) < 0)
			{
				form_alert(1,"[3][Cannot open file][Shucks]");
				fclose(printer);	/*	close the printer	*/
				return;
			}
			t_bulk = (char *)Malloc(4096l);
			Fread(fd,4096l,t_bulk);
			Fclose(fd);
			cat_print(in_file,t_bulk);	/*	print out catalog	*/
			fprintf(printer,"%c",0x0c);	/*	form feed	*/
			fclose(printer);	/*	close the printer	*/
			Mfree(t_bulk);
			break;
		case 2:	/*	all	*/
			form_alert(1,"[1][The following selector|box is to select the|path only][OK]");
			if(get_file(tempy) == 0)
			{
				fclose(printer);	/*	close the printer	*/
				return;	/*	cancel was hit	*/
			}
			t_bulk = (char *)Malloc(4096l);
			cat_all(file_path,t_bulk);
			fprintf(printer,"%c",0x0c);	/*	form feed	*/
			fclose(printer);	/*	close the printer	*/
			Mfree(t_bulk);
			break;
		case 3:	/*	cancel	*/
			break;
	}	/*	end of switch statement	*/
}

cat_all(path,b)
char path[],b[];
{
	int lines = 0;
	DTA dta;
	long old_dta;
	int fd;
	char in_file[128];

	old_dta = Fgetdta();
	Fsetdta(&dta);
	if(Fsfirst(path,0) >= 0)
	{
		do
		{
			join_fname(in_file,file_path,dta.name);
			fd = Fopen(in_file,0);
			Fread(fd,4096l,b);	/*	read in data	*/
			Fclose(fd);
			lines += cat_print(in_file,b);
			if( 66 - lines < 12)
			{
				fprintf(printer,"%c",0x0c);		/*	form feed	*/
				lines = 0;
			}
		}while(Fsnext() >= 0);
	}
	Fsetdta(old_dta);
}

cat_print(name,b)
char name[],b[];
{
	int lines;
	char lb[90],temp[10];
	int i,j,c,a;

	lines = 0;
	fprintf(printer,"\n\nCatalog of %s\n",name);
	lines += 3;
	for(i=0;i<80;++i)
		lb[i] = ' ';	/*	fill with spaces	*/
	lb[i] = '\0';
	for(i=0,c=0;i < 32;++i)
	{
		for(j=0;j<10;++j)
		{
			a = b[(i * 128) + j + 118];
			if(isprint(a))
				lb[(c * 20) + j + TAB] = a;
			else
				lb[(c * 20) + j + TAB] = ' ';
		}
		sprintf(temp,"%2d\n",i+1);
		lb[(c * 20)] = temp[0];
		lb[(c * 20) + 1] = temp[1];
		++c;
		if(c == 4)
		{
			fprintf(printer,"%s\n",lb);
			c = 0;
			++lines;
		}
	}
	return(lines);
}

print_edit(e,p)
char e[];	/*	voice edit buffer	*/
char p[];	/*	performance edit buffer	*/
{
	/*
		this routine prints the edit buffer to the printer
	*/
	char temp[20];
	char wave[20],sync[5];
	char a[4][4];
	char name[31];
	int i,j,k;

	for(i=0,j=145;i < 10;++i,++j)
		name[i] = e[j];
	name[i] = '\0';
	fprintf(printer,"\n\n\n");
	p_emp(14,name);
	fprintf(printer,"\n");
	print_operator(e);
	fprintf(printer,"\n   <Pitch Envelope>\n");
	fprintf(printer,"R1 R2 R3 R4 L1 L2 L3 L4\n");
	fprintf(printer,"%2d %2d %2d %2d %2d %2d %2d %2d\n",
		e[126],e[127],e[128],e[129],e[130],e[131],e[132],e[133]);
	fprintf(printer,"\n              < LFO >\n");
	fprintf(printer,"WAVE  Speed  Delay PMD  AMD  SYNC  PMS\n");
	ksset(e[141],sync);
	wset(e[142],wave);
	fprintf(printer,"%s    %2d     %2d  %2d   %2d   %s    %1d\n",
		wave,e[137],e[138],e[139],e[140],sync,e[143]);
	fprintf(printer,"\n        <Misc>\n");
	fprintf(printer,"Algorythm   Mid C    FB  KeySync\n");
	ksset(e[136],sync);
	get_bp(temp,e[144] + 15);
	fprintf(printer,"   %2d        %s    %1d   %s\n",e[134] + 1,temp,e[135],sync);
	for(i=0,j=64;i < 30;++i,++j)
		name[i] = p[j];
	name[i] = '\0';
	p_emp(1,name);
	fprintf(printer,"\n");
	fprintf(printer,"          < Modulation >\n");
	fprintf(printer,"           MOD WH F.C.   B.C.  Aft Tch\n");
	fprintf(printer,"senstivity  %2d    %2d     %2d     %2d\n",
		p[9],p[11],p[13],p[15]);
	for(i=0;i < 3;++i)
	{
		for(k = 0,j=9;j < 17;j+=2,k++)
		{
			ksset((p[j] >> i) & 0x01,a[k]);
		}
		fprintf(printer,"%s %s   %s    %s    %s\n",per_types[i],a[0],a[1],a[2],a[3]);
	}
	fprintf(printer,"    <Portamento>            <Pitch Bend>\n");
	fprintf(printer,"Mode   Glis/Port Md  Time     Range     Step\n");
	portset(p[7],temp);
	pmodeset(p[6],wave);
	fprintf(printer,"%s   %s   %2d       %2d       %2d\n",
		wave,temp,p[5],p[3],p[4]);
	ppolyset(p[2],temp);
	fprintf(printer,"\n%s Mode   Level Attenuation %1d\n",temp,p[26]);
}

print_operator(e)
char e[];
{
	int operator;

	fprintf(printer,"        Frequency>     <Envelope Parameters>    <Keyboard Scaling>     <S>\n");
	fprintf(printer,"OP  M     FC   ff  d  R1 R2 R3 R4 L1 L2 L3 L4  LD  LC   BP  RD  RC  R  M V TL\n");
	for(operator = 1;operator < 7; ++operator)
		p_oper(operator,e);
}

p_oper(o,e)
int o;
char e[];
{
	int index;
	char freq[10];
	char bp[10];
	char lc[10],rc[10];
	int mode;
	int len,i;
	char temp[20];

	index = (6 - o) * 21;
	if(e[index + 17] == 1)
		mode = 'F';
	else
		mode = 'N';
	freqset(freq,e[index + 18],e[index+19],e[index+17]);
	len = strlen(freq);
	if(len < 8)
	{
		for(i=0; i< 8 - len;++i)
			temp[i] = ' ';
		temp[i] = '\0';
		strcat(temp,freq);
		strcpy(freq,temp);
	}
	get_bp(bp,e[index + 8]);
	get_lc(lc,e[index + 11]);
	get_lc(rc,e[index + 12]);

	fprintf(printer,"%d   %c %s %2d %2d  %2d %2d %2d %2d %2d %2d %2d %2d  %2d %s %s %2d %s %1d  %1d %1d %2d\n",
		o,mode,freq,e[index +19],e[index + 20] - 7,e[index],e[index +1],e[index + 2],e[index + 3],e[index + 4],
		e[index + 5],e[index + 6], e[index + 7],e[index + 9],lc,bp,e[index + 10],rc,e[index + 13],e[index + 14],e[index + 15],
		e[index + 16]);
}

p_emp(tab,string)
int tab;	/*	number of tabs to space	*/
char string[];	/*	string to print	*/
{
	int i;

	fprintf(printer,"%c%c",0x1b,14);
	for(i=0;i<tab;++i)
		fprintf(printer,"%c",' ');	/*	tab out with spaces	*/
	fprintf(printer,"%s%c",string,20);	/*	print string and cancel	*/
}
