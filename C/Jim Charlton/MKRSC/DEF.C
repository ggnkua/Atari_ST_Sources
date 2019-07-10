#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "mkrsc.h"
#include "globals.h"
#include "strings.h"
#include <fcntl.h>



int make_def(dname)
	char dname[];
{
	long size;
	char temp[80];
	int fildes, c, i, j, button, num;
	long flenw;   /* number of bytes written to file */
	objtreeptr	thetree, *linkptr;
	defstruct1 def1;
	defstruct2 def2;
	int numobjs, order[MAXONUM];

	thetree = thefrontwin->inwindow;
	linkptr = thetree->treelink;


      	Fdelete(dname);
#ifndef __GNUC__
  		fildes = creat(dname,O_RDWR);
  	if(fildes != -1)	
#else
 		fildes = creat(dname,0666);
 	if(fildes > -1)	
#endif
        {	num = 0;
			for( i=1;i < thetree->count + 1; i++)
			{	if(strlen(thetree->name[i])) num++;
				for(j=0;j < linkptr[i]->count+1;j++)
				if(strlen(linkptr[i]->name[j])) num++;
			}
			strcpy(def1.mkstr,"MKRCS1.0");
			def1.num = num;
			size = sizeof(defstruct1);
			if( (flenw = Fwrite(fildes,size,(char *)&def1)) <= 0)
			{
				button = form_alert(1, "[1][ Error writing file ][OK]");
			    c = close(fildes);
				return;
			}
			
			
			for( i=1;i < thetree->count + 1; i++)
			{	if(strlen(thetree->name[i]))
				{	def2.totree = 0;
					def2.index = i;
					def2.type = thetree->kind[i];
					strcpy(def2.namestr,thetree->name[i]);
					size = sizeof(defstruct2);
					if( (flenw = Fwrite(fildes,size,(char *)&def2)) <= 0)
					{
						button = form_alert(1, "[1][ Error writing file ][OK]");
			       		c = close(fildes);
						return;
					}
				}
				numobjs = trav_tree(linkptr[i]->objt,order);
				for(j=0;j < numobjs; j++)
				if(strlen(linkptr[i]->name[order[j]]))
				{	def2.totree = i;
					def2.index = j;
					def2.type = 0x100;
					strcpy(def2.namestr,linkptr[i]->name[order[j]]);
					size = sizeof(defstruct2);
					if( (flenw = Fwrite(fildes,size,(char *)&def2)) <= 0)
					{
						button = form_alert(1, "[1][ Error writing file ][OK]");
			       		c = close(fildes);
						return;
					}
				}
			}
			c = close(fildes);
		}
		else
			button = form_alert(1, "[1][ Error creating file | Try 'SAVE AS' ][OK]");
}

int read_def(dname)
	char dname[];
{
	long size;
	int fildes, c, i, button, num;
	long red;   /* number of bytes read from file */
	objtreeptr	thetree, *linkptr;
	defstruct1 def1;
	defstruct2 def2;

	thetree = thefrontwin->inwindow;
	linkptr = thetree->treelink;

	size = sizeof(defstruct1);
#ifndef __GNUC__
  	fildes = open(dname,O_BINARY);
  	if( (fildes == -1)||(red = Fread(fildes,size,(char *)&def1)) != size)
#else
 	fildes = open(dname,0);
 	if( (fildes < 0)||(red = Fread(fildes,size,(char *)&def1)) != size)
#endif
			{	button = form_alert(1, "[1][ DEF file read error | or DEF file not found. ][OK]");
				close(fildes);
				return;
			}
	if(i=strcmp(def1.mkstr,"MKRCS1.0") != 0)
			{	button = form_alert(1, "[1][ Incorrect .DEF file ][OK]");
				close(fildes);
				return;
			}
        num = def1.num;
		size = sizeof(defstruct2);
		for( i=0;i < num; i++)
		{	if((red = Fread(fildes,size,(char *)&def2)) != size)
			{	button = form_alert(1, "[1][ DEF file read error ][OK]");
				close(fildes);
				return;
			}
			if(def2.type < 0xFF)
			{	thetree->kind[def2.index] = def2.type;
				linkptr[def2.index]->kind[0] = def2.type;
				strcpy(thetree->name[def2.index],def2.namestr);

	/* copy the new icon's ICONBLK to the maintree array of ICONBLKs	*/

				thetree->icblk[def2.index] =
							*((ICONBLK *)(treicont[def2.type].ob_spec));
	/*  and point ICONBLK ptext to 'name' in maintree struct */

				thetree->icblk[def2.index].ib_ptext =
									 thetree->name[def2.index];
			}
			else if(def2.type > 0xFF)
				strcpy(linkptr[def2.totree]->name[def2.index],def2.namestr);
		}
			c = close(fildes);
}
