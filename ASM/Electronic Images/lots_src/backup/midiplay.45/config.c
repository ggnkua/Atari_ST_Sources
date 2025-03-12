/*
 * 		The Digital Sound Module.
 * 		(c) 1994 Martin Griffithis
 */ 

#include <e_gem.h>
#include <string.h>
#include "types.h"

static char curr_mappath[256];  /* Current Song Path */
static char curr_mapname[256];  /* Current Song Filename */
static char selected_map[256];		

void mapfile_is_bad(void)
{
	xalert(1,1,X_ICN_DISC_ERR,NULL,BUTTONS_CENTERED,TRUE,title,
	" This does not seem to be a MAP file, |"
	" Either the MAP file is corrupted,    |"
	" Or you have selected the wrong file. "," [Ok ");
}
/*
 *
 */

Bool do_load_map(char *name)
{	char gm_inst[NO_INSTRUMENT][FNAME_LEN];
	char gm_perc[NO_PERCUSSION][FNAME_LEN];
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
		memcpy (&gm_instrument_fnames[0][0],&gm_inst[0][0],(size_t) NO_INSTRUMENT*FNAME_LEN*sizeof(char));
		memcpy (&gm_percussion_fnames[0][0],&gm_perc[0][0],(size_t) NO_PERCUSSION*FNAME_LEN*sizeof(char));
		return TRUE;
	} else
	{	xalert(	1,1,X_ICN_DISC_ERR,NULL,BUTTONS_CENTERED,TRUE,title,
				" Could not Open MAP file for Reading. "," [Ok ");
		return FALSE;
	}
}

void load_map(void)
{	if (select_file(selected_map,curr_mappath,curr_mapname,"*.MAP","Load .MAP file"))
	{	graf_mouse(BUSYBEE,NULL);
		do_load_map(selected_map);
		graf_mouse(ARROW,NULL);
	}
}

/*
 *
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
		for (i= 0 ; i < NO_PERCUSSION ; i++)
		{	char *curr = &gm_percussion_fnames[i][0];
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
	{	xalert(	1,1,X_ICN_DISC_ERR,NULL,BUTTONS_CENTERED,TRUE,title,
				" Could not Open MAP file for Writing. "," [Ok ");
		return FALSE;
	}
}

void save_map(void)
{	if (select_file(selected_map,curr_mappath,curr_mapname,"*.MAP","Save .MAP file"))
	{	graf_mouse(BUSYBEE,NULL);
		do_save_map(selected_map);
		graf_mouse(ARROW,NULL);
	}
}