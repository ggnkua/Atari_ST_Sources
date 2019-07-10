
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "fcntl.h"
#include "xxed.h"
#include "globals.h"

	int				drarray[16] = {AA,BB,CC,DD,EE,FF,GG,HH,II,JJ,
										KK,LL,MM,NN,OO,PP};
/*  The drive letters are defined in HEXED.H    */

read_file(thewin)
	windowptr	thewin;

{	int fildes, c, button, ret;
	long skres, flenr, toread, readnow, red;
	linkbufptr	bufptr;
	char str2[30];

		graf_mouse(2,0L);
		  ret = 1;	
          fildes = open(thewin->title,O_BINARY);
          skres = lseek(fildes,0L,0);       /* rewind */
          flenr = Fseek(0L,fildes,2);        /* get file length */
          	 if (flenr >= 1 && fildes != -1 && skres != -1)
           	{  	skres = lseek(fildes,0L,0);       /* rewind again */
			for(toread=flenr;toread>0;toread=toread-BLOCKSIZE)
				{	readnow = (toread < BLOCKSIZE) ? toread : BLOCKSIZE;
					bufptr = addmember(thewin); 
		if (bufptr == NULL)  /* no more memory available  */
	{   	button = form_alert(1, "[1][ Out of memory. | Partial file read. ][OK]");
	 		ret = 0; break;
	}
						/* read file to ram */
               	if( (red = Fread(fildes,readnow,bufptr->block)) > 0 )
					{
						bufptr->inuse = red;
						thewin->flen += red;
					}	  
				else
					{	button = form_alert(1, "[1][ File read error ][OK]");
						ret = 0; break;
					}	
			     }
			c = close(fildes);
           	}
           	 else	{button = form_alert(1, "[1][ File read error | or file not found ][OK]");
						ret = 0;
					}

				/* put extra char 00 at end of file  */
		if(thewin->flen > 0)
		{	if(bufptr->inuse < BLOCKSIZE)
			{	bufptr->inuse += 1;
				thewin->flen += 1;
			}
			else
			{	bufptr = addmember(thewin); 
			if (bufptr == NULL)  /* no more memory available  */
				{   	button = form_alert(1, "[1][ Out of memory. | Partial file read. ][OK]");
		 				ret = 0;
				}
			else				
				{	bufptr->inuse += 1;
					thewin->flen += 1;
				}
			}	
		}
		graf_mouse(0,0L);
          return(ret);
}


write_file(thewin)
  windowptr thewin;
{
		int button,w;
		
		drw_dialxy(dialog5,230,38/(16/gl_hchar));  /* may not work on colour   */
		if (getfile(thewin))
			 save_file(thewin);
		form_dial(FMD_FINISH, 0, 0, 0, 0, 230, 38/(16/gl_hchar),
							 dialog5->ob_width, dialog5->ob_height);

} 

save_file(thewin)
	windowptr	thewin;
{
	int fildes, c, button;
	long flenw;   /* length of buffer written to file */
	linkbufptr	amem;
	unsigned dummy;

		if (thewin->flen < 2) 
			 {button = form_alert(1, "[1][ Null file........ | Save aborted. ][OK]");
						 return;
			}
       
		graf_mouse(2,0L);
/* delete the dummy byte at end of file	*/
/*	the 0 flag in the delete_one call allows for delete last byte	*/
			delete_one(thewin,thewin->flen-1,0);

				fildes = open(thewin->title,O_RDONLY);
			if (fildes > 0)
			{	button =  form_alert(1, "[1][ File already exists. | Ok to overwrite? ][OK|CANCEL]");
				if (button == 2)
					{	c = close(fildes);
						return;
					}
				else
					c = close(fildes);
			}
      			Fdelete(thewin->title);
				fildes = creat(thewin->title,O_RDWR);
			if(fildes != -1)	
			{	for(amem=thewin->headptr;amem;amem=amem->next)
         		{  if(flenw = Fwrite(fildes,amem->inuse,amem->block))
         				;
         		   else {button = form_alert(1, "[1][ File write error ][OK]");
						 break;
						}
         		}	c = close(fildes);
					thewin->changed = FALSE;

		/* reinsert the Null byte at end of buffer copy of file    */
		/* step to the last buffer block in list	*/
			for(amem=thewin->headptr;amem->next;amem=amem->next)
         				;
					if(amem->inuse < BLOCKSIZE)
					{	amem->inuse += 1;
						*(amem->block + amem->inuse) = (char)0;
 						thewin->flen += 1;
					}
					else
					{	amem = addmember(thewin); 
					if (amem == NULL)  /* no more memory available  */
						{   	button = form_alert(1, "[1][ Out of memory. | Partial file read. ][OK]");
						}
					else				
						{	amem->inuse += 1;
							*(amem->block + amem->inuse) = (char)0;
							thewin->flen += 1;
						}
					}	
			}
			else
			button = form_alert(1, "[1][ Error creating file | Try 'SAVE AS' ][OK]");
		graf_mouse(0,0L);
}

getfile(thewin)  /* returns 1 with name in thewin->title, 0 with cancel */
 	windowptr thewin;

{		int  fs_button, c, i, len;

        c = fsel_input(fs_inpath,fs_insel,&fs_button);
		if(( c!=0 ) && (fs_button != 0))
		{
			len = strlen(fs_inpath);
			for(i=len;i>0;i--)  /* find last occurrence of \  */
				if(fs_inpath[i]=='\\') break;

			strncpy(thewin->title,fs_inpath,i+1); /* copy pathname to title */
    		thewin->title[i+1] = '\0';
    		strcat(thewin->title,fs_insel);
			wind_set(thewin->handle, WF_NAME, thewin -> title, 0, 0);
			return(1);
		}
    	else	return(0);
}

delfile()  /* returns 1 with del, 0 with cancel */

     {  int  fs_button, c, i, len;
        char filespec[40];

		drw_dialxy(dialog6,230,38/(16/gl_hchar));  /* may not work on colour   */
									/* see form_dial at end of func */
		c = fsel_input(fs_inpath,fs_insel,&fs_button);
		form_dial(FMD_FINISH, 0, 0, 0, 0, 230, 38/(16/gl_hchar),
							 dialog6->ob_width, dialog6->ob_height);
		if(( c!=0 ) && (fs_button != 0))
		{
			len = strlen(fs_inpath);
			for(i=len;i>0;i--)  /* find last occurrence of \  */
				if(fs_inpath[i]=='\\') break;

			strncpy(filespec,fs_inpath,i+1); /* copy pathname to filespec*/
    		filespec[i+1] = '\0';
    		strcat(filespec,fs_insel);
			c = Fdelete(filespec);
            if(c>=0)
				return(1);
			else
				form_error(c);
		}
    	else	return(0);
}

drives()
{
	unsigned long	drvs;
	int				dr, cx, cy, cw, ch, button, idr;
	int				dx, dy, dw, dh;
	disk_info		myinfo;

	dr_str[0] = 0;
	for (dr = 1; dr < 17; dr++)
			dialog4[drarray[dr]].ob_state = DISABLED;
		
	idr = 0;
	drvs = Drvmap();
	for (dr = 1; dr < 17; dr++, drvs >>= 1)
		if(drvs & 0x001)
			dialog4[drarray[dr-1]].ob_state = NORMAL;

		form_center(dialog4, &cx, &cy, &cw, &ch);
		form_dial(FMD_START, 0, 0, 0, 0, cx, cy, cw, ch);
		objc_draw(dialog4, 0, 10, cx, cy, cw, ch);
	while((button = form_do(dialog4, 0)) != DREXIT)
	{	for(dr = 1;dr<18;dr++)
			if(drarray[dr-1] == button)
				idr = dr;
		Dfree(&myinfo,idr);
		sprintf(dr_str,"%ld Free bytes in disk %c",
				myinfo.b_free*myinfo.b_clsiz*myinfo.b_secsiz,
				'A' + (idr-1));
		dialog4[button].ob_state = NORMAL;
		objc_draw(dialog4, button, 10, cx, cy, cw, ch);
		objc_draw(dialog4, DRBOX, 1, cx, cy, cw, ch);
	}
		form_dial(FMD_FINISH, 0, 0, 0, 0, cx, cy, cw, ch);
		dialog4[DREXIT].ob_state = NORMAL;

}
				
