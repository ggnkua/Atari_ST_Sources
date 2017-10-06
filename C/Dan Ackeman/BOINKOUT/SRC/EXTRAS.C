/*********************************************************
 *					EXTRAS.C							 *
 *					version 1.0							 *
 *														 *
 *  Dan Ackerman January, 2000							 *
 *														 *
 * Routines that don't fit properly elsewhere in code	 *
 * for iconification, getting AES version, and object	 *
 * manipulation.										 *
 *********************************************************/

#include <stdio.h>
#include <string.h>

#include "boink.h"

/*  This identifies what AES you are running under 
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

#if OS_TOS
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
#ifdef __GNUC__
 		&& ( _global[1] > 1  ||  _global[1] <0 )
#else
  		&& ( _GemParBlk.global[1] > 1  ||  _GemParBlk.global[1] <0 )
#endif
	)
		retv = AES_MTOS;

#endif /* OS_TOS */

	return( retv );
}	/* Ends:	int identify_AES(void) */


/* 
 * Handle modifications for iconifying a window
 */
void
iconify(int window_info, GRECT *new_size)
{
	win[window_info].status = 3; /* Iconified */
				
#if OS_TOS
	wind_set( win[window_info].handle, WF_ICONIFY, PTRS(new_size));
	wind_set( win[window_info].handle, WF_NAME, win[window_info].title);
	wind_get( win[window_info].handle, WF_WORKXYWH, ELTR(win[window_info].icon));

	/* Set icon's location for later redraws */

	win[window_info].icon_obj[ROOT].ob_x = win[window_info].icon.g_x;
	win[window_info].icon_obj[ROOT].ob_y = win[window_info].icon.g_y;
	win[window_info].icon_obj[ROOT].ob_width = win[window_info].icon.g_w;
	win[window_info].icon_obj[ROOT].ob_height = win[window_info].icon.g_h;
	win[window_info].icon_obj[ICON1].ob_x = (win[window_info].icon.g_w - win[window_info].icon_obj[ICON1].ob_width)/2;
	win[window_info].icon_obj[ICON1].ob_y = (win[window_info].icon.g_h - win[window_info].icon_obj[ICON1].ob_height)/2;
#endif /* OS_TOS */
}

/*
 * Handle modifications for uniconifying a window
 */
void
un_iconify(int window_info,GRECT *new_size)
{
	win[window_info].status = 1;
			
#if OS_TOS
	wind_set( win[window_info].handle, WF_UNICONIFY, PTRS(new_size));

/*	wind_get( win[window_info].handle, WF_WORKXYWH, &win[window_info].icon.g_x,&win[window_info].icon.g_y,&win[window_info].icon.g_w,&win[window_info].icon.g_h);
*/

	wind_get(win[window_info].handle, WF_CURRXYWH, ELTR(win[window_info].curr));
			 
/*	wind_set( win[window_info].handle, WF_NAME, &win[window_info].title);*/
#endif /* OS_TOS */
}


/*
 * copy a string into a TEDINFO structure.
 */
void set_tedinfo(OBJECT *tree,int obj,char *source)
{
	char *dest;

#if OS_TOS	
	dest=tree[obj].ob_spec.tedinfo->te_ptext;
#else
	dest=((TEDINFO *)tree[obj].ob_spec)->te_ptext;
#endif
	strcpy(dest,source);
}

/*
 * Get a string from a TEDINFO structure.
 */
void get_tedinfo(OBJECT *tree,int obj,char *dest)
{
	char *source;

#if OS_TOS	
	source=tree[obj].ob_spec.tedinfo->te_ptext;
#else
	source=((TEDINFO *)tree[obj].ob_spec)->te_ptext;
#endif
	strcpy(dest,source);
}

/*
 * construct_path - build a GEMDOS path name out of a stem, which
 * optionally has junk on the end which we must delete, and a filename
 * which we are interested in.
*/
 
void
construct_path(char *dest,const char *path,const char *name)
{
	char *s=NULL;		/* used to track the position after final \ or :*/

	if (path[0] && path[1]==':')
		s=&dest[2];
	while (*dest++=*path)
		if (*path++=='\\')
			s=dest;
	if (!s)
		s=dest;
	strcpy(s,name);
}

/* Set the text in an edit field */
void
set_edits(OBJECT *tree, int object,char *source)
{
	char *dest;
	
	dest = tree[object].ob_spec.tedinfo->te_ptext;

	strncpy(dest,source,tree[object].ob_spec.tedinfo->te_txtlen);
}


/* The heart of the paste routine */

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
		wind_get(win[w_info].handle,WF_WORKXYWH,ELTR(temp));

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
										
				objc_edit(win[w_info].window_obj, win[w_info].cur_item, 0, win[w_info].edit_pos, ED_END, &win[w_info].edit_pos);
	
				set_edits(win[w_info].window_obj,win[w_info].cur_item,line);
	
				objc_draw(win[w_info].window_obj,win[w_info].cur_item,7,ELTS(temp));

				objc_edit(win[w_info].window_obj, win[w_info].cur_item, 0, win[w_info].edit_pos, ED_INIT, &win[w_info].edit_pos);
			}
		}
	}
}

void
copy_paste(int w_info)
{
	char scrap[128];
	char scrap_name[128];
	GRECT p;
	FILE   *pastefp;                  
	char line[500];

	wind_get(win[w_info].handle,WF_WORKXYWH,ELTR(p));

	if(scrp_read((char *)scrap) == 0)
		return;

	construct_path(scrap_name,scrap,"SCRAP.TXT");
					
	if ((pastefp = fopen(scrap_name, "r")) > 0)
	{
		fclose(pastefp);
		Fdelete(scrap_name);
	}

	pastefp = fopen(scrap_name,"w");

	if (pastefp != NULL)
	{
		get_tedinfo(win[w_info].window_obj, win[w_info].cur_item,line);
		
		fwrite(line, sizeof(char), strlen(line), pastefp);

		fclose(pastefp);
	}

}


/* This sends a message to the main loop 
 * We are just making certain that the app_id is set properly
 */
	
int
send_message(int msg[8])
{
	int newmsg[8];

	newmsg[0] = msg[0];
	newmsg[1] = aes_id;    /* my apps id */
	newmsg[2] = msg[2];
	newmsg[3] = msg[3];   
	newmsg[4] = msg[4];
	newmsg[5] = msg[5];
	newmsg[6] = msg[6];
	newmsg[7] = msg[7];

	appl_write(msg[1], (int)sizeof(newmsg), newmsg);

	return(1);
}

/* This sends a message to the main loop */
int
send_extmessage(int extapp, int msg0, int msg2, int msg3, int msg4, int msg5, int msg6, int msg7)
{
	int msg[8];

	msg[0] = msg0;
#ifdef __GNUC__
 	msg[1] = _global[2];  /* my apps id */
#else
  	msg[1] = _GemParBlk.global[2];  /* my apps id */
#endif
	msg[2] = msg2;
	msg[3] = msg3;   
	msg[4] = msg4;
	msg[5] = msg5;
	msg[6] = msg6;
	msg[7] = msg7;

	appl_write(extapp, (int)sizeof(msg), msg);

	return(1);
}

/* -------------------------------------------------------------------- */
/*       boolean rc_intersect( GRECT *r1, GRECT *r2 );                  */
/*                                                                      */
/*       Calculate the intersecten of two rectangles.                   */
/*                                                                      */
/*       -> r1, r2       Pointer to the two rectangles structs.         */
/*                                                                      */
/*       <-              == 0  if the rectangles do not intersect       */
/*                                                                      */
/*                       != 0  if they intersect.                       */
/* -------------------------------------------------------------------- */
#if !GL_RCINTER
int rc_intersect( GRECT *r1, GRECT *r2 )
{
   int x, y, w, h;

   x = max( r2->g_x, r1->g_x );
   y = max( r2->g_y, r1->g_y );
   w = min( r2->g_x + r2->g_w, r1->g_x + r1->g_w );
   h = min( r2->g_y + r2->g_h, r1->g_y + r1->g_h );

   r2->g_x = x;
   r2->g_y = y;
   r2->g_w = w - x;
   r2->g_h = h - y;

   return ( ((w > x) && (h > y) ) );
}
#endif
