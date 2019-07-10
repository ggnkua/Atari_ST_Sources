#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "mkrsc.h"
#include "globals.h"
#include "strings.h"
#include <fcntl.h>




save_file(size,start)
	long size;
	char *start;
{
	char temp[30], pname[30];
	int len, i, fildes, c, button;

	len = strlen(thefrontwin->title);
	for(i = len - 1; i > 0; i--)
		if(thefrontwin->title[i] == '.')
			break;
	strncpy(temp,thefrontwin->title,i);
	temp[i] = '\0';
	sprintf(pname,"%s.RSC",temp);	

		fildes = open(pname,O_RDONLY);
		if (fildes > 0)
			{	button =  form_alert(1, "[1][ File already exists. | Ok to overwrite? ][OK|CANCEL]");
				if (button == 2)
					{	c = close(fildes);
						return;
					}
				c = close(fildes);
			}
		save_rsc(pname,size,start);
		sprintf(pname,"%s.H",temp);	
		make_hdr(pname);

		sprintf(pname,"%s.DEF",temp);	
		make_def(pname);

		if(cout)
		{	for(i = len - 1; i > 0; i--)
			if(temp[i] == '\\')
				break;
			temp[i+6] = '\0';
			strcat(temp,"RSC.C");
			make_cout(temp);
		}
/*
  		if(cout)
 		{	sprintf(pname,"%s.RSH",temp);
		    make_cout(pname);
  		}
*/
}

int make_hdr(hname)
	char hname[];
{
	long size;
	char temp[80];
	int fildes, c, i, j, button;
	long flenw;   /* number of bytes written to file */
	objtreeptr	thetree, *linkptr;
	int numobjs, order[MAXONUM];

	thetree = thefrontwin->inwindow;
	linkptr = thetree->treelink;


      	Fdelete(hname);
#ifndef __GNUC__
  		fildes = creat(hname,O_RDWR);
  	if(fildes != -1)	
#else
		fildes = creat(hname,0666);
	if(fildes > -1)	
#endif
        { 
			for( i=1;i < thetree->count + 1; i++)
			{	if(strlen(thetree->name[i]))
				{	sprintf(temp,"#define %s %d\n",thetree->name[i],i-1);
					size = strlen(temp);
					if( (flenw = Fwrite(fildes,size,temp)) <= 0)
					{
						button = form_alert(1, "[1][ Error writing file ][OK]");
			       		c = close(fildes);
						return;
					}
				}
			numobjs = trav_tree(linkptr[i]->objt,order);
				for(j=0;j < numobjs; j++)
				if(strlen(linkptr[i]->name[order[j]]))
				{	sprintf(temp,"#define %s %d\n",linkptr[i]->name[order[j]],j);
					size = strlen(temp);
					if( (flenw = Fwrite(fildes,size,temp)) <= 0)
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

int save_rsc(rname,size,start)
	long size;
	char *start, rname[];
{
	int fildes, c, button;
	long flenw;   /* number of bytes written to file */
	unsigned dummy;
       
     			Fdelete(rname);
#ifndef __GNUC__
  				fildes = creat(rname,O_RDWR);
  			if(fildes != -1)	
#else
				fildes = creat(rname,0666);
			if(fildes > -1)	
#endif
        		{ 	if(flenw = Fwrite(fildes,size,start))
						;
         			else
						button = form_alert(1, "[1][ Error writing file ][OK]");
	       			c = close(fildes);
				}
			else
				button = form_alert(1, "[1][ Error creating file | Try 'SAVE AS' ][OK]");
}



getfile(thewin)  /* returns 1 with name in thewin->title, 0 with cancel */
 	windowptr thewin;

{		int  fs_button, c, i, len;
		char *fname;
		
		len = strlen(thewin->title);
		for(i=len;i>0;i--)  /* find last occurrence of \  */
			if(thewin->title[i]=='\\') break;
		fname = (char *)&(thewin->title[i+1]);
		strcpy(fs_insel,fname); /* copy title to fs_insel */

        c = fsel_input(fs_inpath,fs_insel,&fs_button);
		if(( c!=0 ) && (fs_button != 0))
		{
			len = strlen(fs_inpath);
			for(i=len;i>0;i--)  /* find last occurrence of \  */
				if(fs_inpath[i]=='\\') break;

			strncpy(thewin->title,fs_inpath,i+1); /* copy pathname to title */
    		thewin->title[i+1] = '\0';
    		strcat(thewin->title,fs_insel);
			if(thefrontwin)
				wind_set(thewin->wihandle, WF_NAME, thewin -> title, 0, 0);
			return(1);
		}
    	else	return(0);
}
