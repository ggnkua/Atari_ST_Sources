/*-----------------------------------------*/
/* simple directory lister         13/6/88 */
/* written in shareware C by Terry Billany */
/*-----------------------------------------*/
#include <d:stdio.h>
#include <d:osbind.h>

char dta[44];

struct cell {
	int nxt_cell;
	int owner;
	int c_level;
	char filler;
	char file_att;
	unsigned int time;
	unsigned int date;
	long f_size;
	char f_name[14];
} c_table[512];

int up_to,
    nxt_free,
    level;

char work[9];

/*-----------------------------------------*/
/* select drive, read & print volume label */
/*-----------------------------------------*/
label()
{
int drv;
long d_size[4];
char root []="\\";
	Cconws("hit a/b/c/d to select drive......");
	drv=getchar()-0x41;
	if (drv > 3) drv-= 0x20;
	Dsetdrv(drv);
	Fsetdta(&dta);

	Dsetpath(root);
	Fsfirst("*.*",8);
	printf("\nvolume name = %s\n\n",&dta[30]);

	Dfree(&d_size,0);
	printf("total bytes: %ldk\n",d_size[1]);
	printf(" free space: %ldk\n\n",d_size[0]);
}
/*--------------------------------------------*/
/* follow folder owners to build pathname     */
/*--------------------------------------------*/
get_path(cptr,pathdata)
struct cell *cptr;
char *pathdata;
{
char w1[64];
	strcpy(pathdata,"\\");
	strcat(pathdata,cptr->f_name);
	while (cptr->owner != -1)
		{	cptr=&c_table[cptr->owner];
			strcpy(w1,"\\");
			strcat(w1,cptr->f_name);
			strcat(w1,pathdata);
			strcpy(pathdata,w1);
		}
}
/*-------------------------------------*/
/* read a folder and stash the entries */
/*-------------------------------------*/
do_ls(pathdata) char *pathdata;
{
int result;
	result = Dsetpath(pathdata);
	result = Fsfirst("*.*",0x17);
	if (result != -33)
	{	write_cell();
		while (result == 0)
		{  result = Fsnext();
		   if(!result) write_cell();
		}
	}
	return(result);
}
/*--------------------------------------*/
/*  copy dta to next free cell 		*/
/*--------------------------------------*/
write_cell()
{
int i;
struct cell *cptr;
char *data_ptr;
   if (nxt_free < 512)  {
	if (dta[30] != 0x2E) {  /* ignore folder headers */
	cptr=&c_table[nxt_free];
	data_ptr=&cptr->file_att;
	for (i=0; i<24; i++)
		data_ptr[i]=dta[i+21];
	cptr->owner=up_to;
	cptr->c_level=level;
	nxt_free++;
	cptr->nxt_cell=nxt_free;
	if (nxt_free > 511)
	  printf("** limit of 512 files/folders reached **");
	}
   }
}
/*------------------------------------------------*/
/* main loop - search table for folders & explode */
/*------------------------------------------------*/
explode()
{
int old_nxt;
struct cell *cptr;
char path_data[64];
	for (up_to=0 ; up_to != nxt_free; up_to++)
	{	cptr=&c_table[up_to];
		if (cptr->file_att & 0x10)
		{	old_nxt=cptr->nxt_cell; /* for rechain */
			cptr->nxt_cell=nxt_free;
			get_path(cptr,path_data);
			level=cptr->c_level+1;
			do_ls(path_data);
			c_table[nxt_free-1].nxt_cell=old_nxt; /* rechain */
		}
	}
} 
/*----------------------------------------------*/
/*    print name/size/date of current file	*/
/*----------------------------------------------*/
print_line(file_cell) struct cell *file_cell;
{
	level=file_cell->c_level*2;
	indent(level);

	{
	if (file_cell->file_att & 0x10)
		printf("*");
	else
		printf(" ");
	}

	printf("%s",file_cell->f_name);

	if(file_cell->file_att != 0x10) {
		sprintf(work,"%ld",file_cell->f_size);
		out_dent((level)+strlen(work)+strlen(file_cell->f_name));
		printf("%s  ",work);

		printf("%d/",
			(file_cell->date >> 9) + 1980);    /* year */
		printf("%02d/",(file_cell->date >> 5) & 0x0F); /* month */
		printf("%02d  ",file_cell->date & 0x1F);	   /* day */

		printf("%02d:",file_cell->time >> 11);	/* hour */
		printf("%02d",(file_cell->time >> 5) & 0x3F); /* mins */
	}
	printf("\n");
}
/*-------------------------*/
/*  print out final table  */
/*-------------------------*/
list_tab()
{
struct cell *cptr;
	cptr=&c_table[0];
	while (cptr->nxt_cell != -1)
	{	print_line(cptr);
		cptr=&c_table[cptr->nxt_cell];
	}
 	print_line(cptr);  /* dont forget the last */
}
/*----------------*/
/* print n spaces */
/*----------------*/
indent(count)
{
int i;
	for (i=0; i < count; i++)
		printf(" ");
}
/*----------------*/
/* pad with ....  */
/*----------------*/
out_dent(count)
{
int i;
	for (i=0; i < 32-count; i++)
		printf(".");
}
/*---------------------*/
/* where it all begins */
/*---------------------*/
main()
{
	label();	/* print volume label */
	nxt_free = level = 0;
	up_to = -1;
	do_ls("\\");	/* read root to kick off */
	if (nxt_free)
	{	c_table[nxt_free-1].nxt_cell=-1; /* mark EOT */
		explode();
		list_tab();   }
	else printf("******* no files found *******\n");
	Cconws(".....press any key.....");
	Crawcin();
	return(0);
}
/*-----------------------------*/
/*  return length of string s  */
/*-----------------------------*/
strlen(s) char s[];
{ int i;
i=0;
while (s[i]) ++i;
return(i); }

