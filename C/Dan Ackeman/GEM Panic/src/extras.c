/* extras.c (c) Dan Ackerman 1997         baldrick@netset.com
 *
 * Misc. routines for various purposes
 */
 
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "global.h"


/* construct_path()
 *
 * build a GEMDOS path name out of a stem, which
 * optionally has junk on the end which we must delete,
 * and a filename which we are interested in.
 */
 
void
construct_path(char *dest,const char *path,const char *name)
{
	char *s=NULL;		/* used to track the position after final \ or : */

	if (path[0] && path[1]==':')
		s=&dest[2];
	while (*dest++ = *path)
		if (*path++=='\\')
			s=dest;
	if (!s)
		s=dest;
	strcpy(s,name);
}
 
/* getcookie() - needed the routine as easy to write my
 * own as it is to link to a lib
 * 
 * searches for cookie_name and sets cookie_val if found
 * else cookie_val is 0
 */
  
long
getcookie(long cookie_name)
{	
	void	*old_SSP;
	long 	i = 0;
	ck_entry *jar;
	long 	cookie_val = -1;

	/* cookie search is made in Super mode to access any RAM */

	old_SSP = (void *) Super(0L);
	if ((jar = *((ck_entry **)_cookies)) == NULL)	goto exit_super;

	while (jar[i].cktag) 
	{
		if (jar[i].cktag == cookie_name)
		{
			cookie_val = jar[i].ckvalue;
			goto exit_super;
		}
		
		++i;
	}
		
exit_super:
	Super(old_SSP);

	return(cookie_val);
}


/* identify_AES() 
 *
 * This identifies what AES you are running under 
 *  based almost entirely on code by Ulf Ronald Anderson
 */
 
int
identify_AES(void)
{	
	void	*old_SSP;
	long	search_id;
	long	*search_p;
	int		MiNT_flag = 0;
	int		retv = AES_single;

	/* cookie search is made in Super mode to access any RAM */

	old_SSP = (void *) Super(0L);
	if ((search_p = *_cookies) == NULL)	goto exit_super;

search_loop:
	search_id = *search_p;
	if( search_id == 0L )	goto exit_super; /* search completed */
	if( search_id == 0x4D674D63L  ||  search_id == 0x4D616758L ) retv = AES_MagiC;
	if( search_id == 0x6E414553L ) retv = AES_nAES;
	if( search_id == 0x476E7661L ) retv = AES_Geneva;
	if( search_id == 0x4D694E54L ) MiNT_flag = 1;
	search_p += 2;
	goto	search_loop
;
exit_super:
	Super(old_SSP);

	if
	(	retv == AES_single  &&  MiNT_flag
		#ifdef _GEMLIB_H_
			&& ( aes_global[1] > 1  ||  aes_global[1] <0 )
		#else
			&& ( _GemParBlk.global[1] > 1  ||  _GemParBlk.global[1] <0 )
		#endif
	)
		retv = AES_MTOS;

	return( retv );
}	/* Ends:	int identify_AES(void) */

/* save_colors()
 *
 * Saves system colors in global array colortab[] 
 */
 
void
save_colors(RGB1000 *colortab)
{
	int i;
	int coltab[3];
	
	for (i=0;i<screen_colors;i++)
	{
		vq_color(vdi_handle,i,0,coltab);

		colortab[i].red = coltab[0];
		colortab[i].green = coltab[1];
		colortab[i].blue = coltab[2];			
	}
}

/* reset_colors()
 * 
 * returns the system colors to where
 * they were when the program started
 */
 
void
reset_colors(RGB1000 *colortab)
{
	int i;
	int coltab[3];

	for (i=0;i<screen_colors;i++)
		{
			coltab[0] = colortab[i].red;
			coltab[1] = colortab[i].green;
			coltab[2] = colortab[i].blue;

			vs_color(vdi_handle,i,coltab);
		}
}

/* iconify()
 * 
 * Handle modifications for iconifying a window
 */
 
void
iconify(int window_info, GRECT *new_size)
{
	win[window_info].status = 3; /* Iconified */

				
	wind_set( win[window_info].handle, WF_ICONIFY, PTRS(new_size));

	#ifdef _GEMLIB_H_
		wind_set_str( win[window_info].handle, WF_NAME, win[window_info].title);
	#else
		wind_set( win[window_info].handle, WF_NAME, win[window_info].title);
	#endif

	wind_get( win[window_info].handle, WF_WORKXYWH, ELTR(win[window_info].icon));

	/* Set icon's location for later redraws */

	win[window_info].icon_obj[ROOT].ob_x = win[window_info].icon.g_x;
	win[window_info].icon_obj[ROOT].ob_y = win[window_info].icon.g_y;
	win[window_info].icon_obj[ROOT].ob_width = win[window_info].icon.g_w;
	win[window_info].icon_obj[ROOT].ob_height = win[window_info].icon.g_h;
	win[window_info].icon_obj[ICON1].ob_x = (win[window_info].icon.g_w - win[window_info].icon_obj[ICON1].ob_width)/2;
	win[window_info].icon_obj[ICON1].ob_y = (win[window_info].icon.g_h - win[window_info].icon_obj[ICON1].ob_height)/2;
}

/* un_iconify()
 *
 * Handle modifications for uniconifying a window
 */
void
un_iconify(int window_info,GRECT *new_size)
{
	win[window_info].status = 1;
	
	wind_set( win[window_info].handle, WF_UNICONIFY, PTRS(new_size));
}

/* set_tedinfo()
 *
 * copy a string into a TEDINFO structure.
 */

void 
set_tedinfo(OBJECT *tree, int obj, char *source)
{
	char *dest;

	dest=tree[obj].ob_spec.tedinfo->te_ptext;

	strcpy(dest,source);
}

/* get_tedinfo()
 *
 * Get a string from a TEDINFO structure.
 */
 
void 
get_tedinfo(OBJECT *tree,int obj,char *dest)
{
	char *source;

	source=tree[obj].ob_spec.tedinfo->te_ptext;

	strcpy(dest,source);
}

/* set_edits()
 *
 * copies source into the edit field object
 */
 
void
set_edits(OBJECT *tree, int object,char *source)
{
	char *dest;
	
	dest = tree[object].ob_spec.tedinfo->te_ptext;

	strncpy(dest,source,tree[object].ob_spec.tedinfo->te_txtlen);
}

/* paste_text()
 * 
 * inserts SCRAP.TXT into windows
 * current edit field
 */

void
paste_text(int w_info)
{
	GRECT temp;
	char scrap[128];
	char scrap_name[128];
	FILE *fp;
	char line[500];
					
	if (win[w_info].edit == 1)
	{
		wind_get(win[w_info].handle,WF_WORKXYWH,&temp.g_x,&temp.g_y,&temp.g_w,&temp.g_h);

		if(scrp_read((char *)scrap) == 0)
			return;

		if (win[w_info].cur_item != -1)
		{
			construct_path(scrap_name,scrap,"SCRAP.TXT");
			
			if ((fp = fopen(scrap_name, "r")) > 0)
			{
				fgets(line,500,fp);
				fclose(fp);

				strcat(line,"\0");
										
				objc_edit(win[w_info].window_obj, win[w_info].cur_item, 0, &win[w_info].edit_pos, ED_END);
	
				set_edits(win[w_info].window_obj,win[w_info].cur_item,line);
	
				objc_draw(win[w_info].window_obj,win[w_info].cur_item,7,ELTS(temp));

				objc_edit(win[w_info].window_obj, win[w_info].cur_item, 0, &win[w_info].edit_pos, ED_INIT);
			}
		}
	}
}
