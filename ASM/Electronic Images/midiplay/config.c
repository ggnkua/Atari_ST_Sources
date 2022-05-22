/*
 * 		The Digital Sound Module.
 * 		(c) 1994 Martin Griffithis
 */ 

#include <stdio.h>
#include <e_gem.h>
#include <string.h>
#include "types.h"

char curr_mappath[256];  /* Current Song Path */
char curr_mapname[256];  /* Current Song Filename */
char selected_map[256];		

/*
 *   Wait for the mouse button(s) to be released.
 */
 
void wait_buttonup(void)
{	int mx,my,mk,kk;
	do 
	{	graf_mkstate(&mx,&my,&mk,&kk);
	}	while (mk);
}




/*
 *	Allocate memory on a 16 byte boundary.
 */
 
void *malloc16(long l,alloc16 *a)
{		if	(a != NULL)
		{	if ((a->allocd = malloc(l+16)) != NULL)
			{	a->ptr = ((long) (a->allocd)+15) & 0xfffffff0;
				return (a->ptr);
			}
		}
		return NULL;
}

/*
 *	Free a memory block on a 16 byte boundary.
 */

void free16(alloc16 *a)
{	if (a->allocd != NULL)
	{	free(a->allocd);
		a->allocd = NULL;
		a->ptr = NULL;
	}
}

/*
 *    Return the size of a file
 */

long filesize(char *fpath)
{	DTA *cdta=Fgetdta();
	if (Fsfirst(fpath,0) >= 0)
		return ((long) cdta->d_length);
	return -1;
}
/*
 *
 */

Bool Alloc_Read_File(char *name,alloc16 *m)
{	long handle;
	long length = filesize(name);
	if ((handle = Fopen(name,0)) >=0 ) 
	{	malloc16(length,m);
		if (Fread(handle,length,m->ptr) != length)	
		{	Fclose(handle);
			return FALSE;
		}	
		Fclose(handle);
		return TRUE;
	} else
		return FALSE;
}

void mapfile_is_bad(void)
{
	xalert(1,1,X_ICN_DISC_ERR,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title,
	" This does not seem to be a MAP file, |"
	" Either the MAP file is corrupted,    |"
	" Or you have selected the wrong file. "," [Ok ");
}

/*
 *		Load map file.
 */

Bool do_load_map(char *name)
{	char gm_instf[NO_INSTRUMENT][FNAME_LEN];
	char gm_percf[NO_PERCUSSION][FNAME_LEN];
	char gm_inst[NO_INSTRUMENT][PNAME_LEN];
	char gm_perc[NO_PERCUSSION][PNAME_LEN];	
	long handle;
	reg int i,c;
	if ((handle = Fopen(name,FO_READ)) >=0 ) 
	{	long ID;
		Fread(handle,sizeof(long),&ID);
		if (ID != 0x12345678)
		{	mapfile_is_bad();
			return FALSE;
		}	
		for (i= 0 ; i < NO_INSTRUMENT ; i++)
		{	reg char *curr = &gm_instf[i][0];
			unsigned int j,cs,cs_r;
			Fread(handle,(long) 2,&j);
			if (j >= FNAME_LEN)
			{	mapfile_is_bad();
				return FALSE;
			}	
			Fread(handle,(long) j,curr);
			Fread(handle,(long) 2,&cs_r);
			cs = j;
			for (c = 0 ; c < j ; c++)
				cs += curr[c];	
			if (cs_r != cs)
			{	mapfile_is_bad();
				return FALSE;
			}				
			curr[j] = 0;
		}
		for (i= 0 ; i < NO_INSTRUMENT ; i++)
		{	reg char *curr = &gm_inst[i][0];
			unsigned int j,cs,cs_r;
			Fread(handle,(long) 2,&j);
			if (j >= FNAME_LEN)
			{	mapfile_is_bad();
				return FALSE;
			}	
			Fread(handle,(long) j,curr);
			Fread(handle,(long) 2,&cs_r);
			cs = j;
			for (c = 0 ; c < j ; c++)
				cs += curr[c];	
			if (cs_r != cs)
			{	mapfile_is_bad();
				return FALSE;
			}				
			curr[j] = 0;
		}		
		
		for (i= 0 ; i < NO_PERCUSSION ; i++)
		{	reg char *curr = &gm_percf[i][0];
			unsigned int j,cs,cs_r;
			Fread(handle,(long) 2,&j);
			if (j >= FNAME_LEN)
			{	mapfile_is_bad();
				return FALSE;
			}	
			Fread(handle,(long) j,curr);
			Fread(handle,(long) 2,&cs_r);
			cs = j;
			for (c = 0 ; c < j ; c++)
				cs += curr[c];	
			if (cs_r != cs)
			{	mapfile_is_bad();
				return FALSE;
			}				
			curr[j] = 0;
		}		
		for (i= 0 ; i < NO_PERCUSSION ; i++)
		{	reg char *curr = &gm_perc[i][0];
			unsigned int j,cs,cs_r;
			Fread(handle,(long) 2,&j);
			if (j >= FNAME_LEN)
			{	mapfile_is_bad();
				return FALSE;
			}	
			Fread(handle,(long) j,curr);
			Fread(handle,(long) 2,&cs_r);
			cs = j;
			for (c = 0 ; c < j ; c++)
				cs += curr[c];	
			if (cs_r != cs)
			{	mapfile_is_bad();
				return FALSE;
			}				
			curr[j] = 0;
		}		
				
		Fclose(handle);
		memcpy (&gm_instrument_fnames[0][0],&gm_instf[0][0],(size_t) NO_INSTRUMENT*FNAME_LEN*sizeof(char));
		memcpy (&gm_instrument[0][0],&gm_inst[0][0],(size_t) NO_INSTRUMENT*PNAME_LEN*sizeof(char));
		memcpy (&gm_percussion_fnames[0][0],&gm_percf[0][0],(size_t) NO_PERCUSSION*FNAME_LEN*sizeof(char));
		memcpy (&gm_percussion[0][0],&gm_perc[0][0],(size_t) NO_PERCUSSION*PNAME_LEN*sizeof(char));
		return TRUE;
	} else
	{	xalert(	1,1,X_ICN_DISC_ERR,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title,
				" Could not Open MAP file for Reading. "," [Ok ");
		return FALSE;
	}
}

Bool load_map(void)
{	Bool ret = FALSE;
	if (select_file(selected_map,curr_mappath,curr_mapname,"*.MAP","Load .MAP file"))
	{	graf_mouse(BUSYBEE,NULL);
		ret = do_load_map(selected_map);
		graf_mouse(ARROW,NULL);
	}
	return ret;
}

/*
 *		Save map file.
 */
 
Bool do_save_map(char *name)
{	reg int i,c;
	long handle;
	if ((handle = Fcreate(name,0)) >=0 ) 
	{	long ID = 0x12345678;
		Fwrite(handle,sizeof(long),&ID);
		for (i= 0 ; i < NO_INSTRUMENT ; i++)
		{	char *curr = &gm_instrument_fnames[i][0];
			unsigned int cs,j = cs = strlen(curr);
			for (c = 0 ; c < j ; c++)
				cs += curr[c];			
			Fwrite(handle,(long) 2,&j);
			Fwrite(handle,(long) j,curr);
			Fwrite(handle,(long) 2,&cs);
		}
		for (i= 0 ; i < NO_INSTRUMENT ; i++)
		{	char *curr = &gm_instrument[i][0];
			unsigned int cs,j = cs = strlen(curr);
			for (c = 0 ; c < j ; c++)
				cs += curr[c];			
			Fwrite(handle,(long) 2,&j);
			Fwrite(handle,(long) j,curr);
			Fwrite(handle,(long) 2,&cs);
		}
				
		for (i= 0 ; i < NO_PERCUSSION ; i++)
		{	char *curr = &gm_percussion_fnames[i][0];
			unsigned int cs,j = cs = strlen(curr);
			for (c = 0 ; c < j ; c++)
				cs += curr[c];			
			Fwrite(handle,(long) 2,&j);
			Fwrite(handle,(long) j,curr);
			Fwrite(handle,(long) 2,&cs);
		}
		for (i= 0 ; i < NO_PERCUSSION ; i++)
		{	char *curr = &gm_percussion[i][0];
			unsigned int cs,j = cs = strlen(curr);
			for (c = 0 ; c < j ; c++)
				cs += curr[c];			
			Fwrite(handle,(long) 2,&j);
			Fwrite(handle,(long) j,curr);
			Fwrite(handle,(long) 2,&cs);
		}						
		Fclose(handle);
		return TRUE;
	} else
	{	xalert(	1,1,X_ICN_DISC_ERR,NULL,SYS_MODAL,BUTTONS_CENTERED,TRUE,title,
				" Could not Open MAP file for Writing. "," [Ok ");
		return FALSE;
	}
}

Bool save_map(void)
{	Bool ret = FALSE;
	if (select_file(selected_map,curr_mappath,curr_mapname,"*.MAP","Save .MAP file"))
	{	graf_mouse(BUSYBEE,NULL);
		ret = do_save_map(selected_map);
		graf_mouse(ARROW,NULL);
	}
	return ret;
}