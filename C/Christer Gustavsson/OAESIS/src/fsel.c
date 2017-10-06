/****************************************************************************

 Module
  fsel.c
  
 Description
  File selection routines in oAESis.
  
 Author(s)
 	cg (Christer Gustavsson <d2cg@dtek.chalmers.se>)
 	
 Revision history
 
  951225 cg
   Added standard header.
	
  960103 cg
   Added Fsel_exinput().
 
 Copyright notice
  The copyright to the program code herein belongs to the authors. It may
  be freely duplicated and distributed without fee, but not charged for.
 
 ****************************************************************************/

/****************************************************************************
 * Used interfaces                                                          *
 ****************************************************************************/

#include <mintbind.h>
#include <osbind.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#include "appl.h"
#include "debug.h"
#include "form.h"
#include "fsel.h"
#include "gemdefs.h"
#include "graf.h"
#include "mintdefs.h"
#include "misc.h"
#include "objc.h"
#include "resource.h"
#include "rsrc.h"
#include "types.h"

/****************************************************************************
 * Typedefs of module global interest                                       *
 ****************************************************************************/

typedef struct direntry {
	UWORD type;
	BYTE  *name;
	LONG  length;
	
	struct direntry *next;
}DIRENTRY;

typedef struct dirdesc {
	DIRENTRY	*dent;
	WORD	num_files;
	WORD	pos;
}DIRDESC;

/****************************************************************************
 * Module global variables                                                  *
 ****************************************************************************/

static BYTE	nullstr[] = "";

/****************************************************************************
 * Local functions (use static!)                                            *
 ****************************************************************************/

static WORD	globcmp(BYTE *pattern,BYTE *str) {
	while(1) {
		switch(*pattern) {
		case '\0':
			if(*str == 0) {
				return 0;
			}
			else {
				return -1;
			};
			
		case '*':
			pattern++;
			
			if(*pattern == '\0') {
				return 0;
			};
			
			do {
				if(!globcmp(pattern,str)) {
					return 0;
				};
				
				if(*str == '\0') {
					break;
				};
				
				str++;
			}while(*str);

			return -1;
			
		default:
			if(*str == '\0') {
				return -1;
			};
			
			if(*(str++) != *(pattern++)) {
				return -1;
			};
		}
	}
}

static WORD set_path(BYTE *pattern,DIRDESC *dd) {
	BYTE	path[128];
	BYTE	pat[30];
	BYTE	*tmp;
	LONG  d;

	strcpy(path,pattern);
	
	tmp = strrchr(path,'\\');
	
	if(tmp) {
		tmp++;
		
		strcpy(pat,tmp);
		*tmp = '\0';
	}
	else {
		strcpy(pat,path);
		strcpy(path,".\\");
	};
	
	d = Dopendir(path,0);
	
	if((d & 0xff000000L) != 0xff000000L) {
		BYTE name[50];
	
		while(!Dreaddir(50,d,name)) {
			if(strcmp("..",&name[4]) && strcmp(".",&name[4])) {
				WORD  fa = 0;
				BYTE  filepath[128];

				sprintf(filepath,"%s%s",path,&name[4]);

				fa = Fattrib(filepath,0,0);
				
				if((fa & 0x10) || (!globcmp(pat,&name[4]))) {
					DIRENTRY *detmp = (DIRENTRY *)Mxalloc(sizeof(DIRENTRY),PRIVATEMEM);
					DIRENTRY **dwalk = &dd->dent;
					
					if(fa & 0x10) {
						detmp->type = S_IFDIR;
					}
					else {
						detmp->type = S_IFREG;
					};
					
					detmp->name = (BYTE *)Mxalloc(strlen(&name[4]) + 4,PRIVATEMEM);
					sprintf(detmp->name,"   %s",&name[4]);
					
					if(detmp->type == S_IFDIR) {
						detmp->name[1] = 0x7;
					};
					
					if(detmp->type == S_IFLNK) {
						detmp->name[0] = '=';
					};
					
					detmp->next = NULL;
					dd->num_files++;
					
					while(*dwalk) {
						dwalk = &(*dwalk)->next;
					};
					
					*dwalk = detmp;
				};
			};
		};

		Dclosedir(d);

		return 0;
	}
	else {
		return -1;
	};
}

static void reset_dirdesc(DIRDESC *dd) {
	DIRENTRY *dwalk = dd->dent;
	
	while(dwalk) {
		DIRENTRY *tmp = dwalk;
		
		dwalk = dwalk->next;

		Mfree(tmp->name);
		Mfree(tmp);
	};
	
	dd->dent = NULL;
	dd->pos = 0;
	dd->num_files = 0;
}

static void get_files(OBJECT *t,DIRDESC *dd) {
	WORD i = dd->pos;
	DIRENTRY *dwalk = dd->dent;
	
	while((i--) && dwalk) {
		dwalk = dwalk->next;
	};
	
	i = FISEL_FIRST;
	
	while(i <= FISEL_LAST) {
		if(dwalk) {
			t[i].ob_spec.tedinfo->te_ptext = dwalk->name;
			dwalk = dwalk->next;
		}
		else {
			t[i].ob_spec.tedinfo->te_ptext = nullstr;
		}
		
		i++;
	};
	
	if(dd->num_files <= (FISEL_LAST - FISEL_FIRST + 1)) {
		t[FISEL_SLIDER].ob_y = 0;
		t[FISEL_SLIDER].ob_height = t[FISEL_SB].ob_height;
	}
	else {
		t[FISEL_SLIDER].ob_height =
			(WORD)(((LONG)t[FISEL_SB].ob_height * (LONG)(FISEL_LAST - FISEL_FIRST + 1)) / (LONG)dd->num_files);
		t[FISEL_SLIDER].ob_y =
			(WORD)((((LONG)t[FISEL_SB].ob_height - (LONG)t[FISEL_SLIDER].ob_height)
				* (LONG)dd->pos) / ((LONG)dd->num_files - FISEL_LAST + FISEL_FIRST - 1));
	};
}

static DIRENTRY *find_entry(DIRDESC *dd,WORD pos) {
	DIRENTRY *walk = dd->dent;
	
	while(walk && (pos > 0)) {
		walk = walk->next;
		pos--;
	};
	
	return walk;
}

/****************************************************************************
 * Public functions                                                         *
 ****************************************************************************/

/****************************************************************************
 * Fsel_do_exinput                                                          *
 *  Implementation of fsel_exinput()                                        *
 ****************************************************************************/
WORD                /* 1 if OK, 0 if CANCEL.                                */
Fsel_do_exinput(    /*                                                      */
WORD apid,          /* Application id.                                      */
WORD vid,           /* VDI workstation id.                                  */
WORD eventpipe,     /* Event message pipe.                                  */
WORD *button,       /* Pressed button.                                      */
BYTE *description,  /* Description.                                         */
BYTE *path,         /* Path buffer.                                         */
BYTE *file)         /* File name buffer.                                    */
/****************************************************************************/
{
	WORD cwidth,cheight,width,height;
	WORD selected = -1;
	BYTE oldpath[128];
		
	OBJECT	*tree;
	
	RECT	area,clip;
	
	WORD but_chosen;
	DIRDESC dd = { NULL,0,0 };
	RECT src,dst;

	tree = Rsrc_duplicate(globals.fiseltad);	
	
	Graf_do_handle(&cwidth,&cheight,&width,&height);
	
	set_path(path,&dd);

	get_files(tree,&dd);

	tree[FISEL_DESCR].ob_spec.tedinfo->te_ptext = description;
	tree[FISEL_DIRECTORY].ob_spec.tedinfo->te_ptext = path;
	tree[FISEL_SELECTION].ob_spec.tedinfo->te_ptext = file;

	strcpy(oldpath,path);

	Form_do_center(tree,&clip);

	Objc_do_offset(tree,FISEL_FIRST,(WORD *)&dst);
	dst.width = tree[FISEL_FIRST].ob_width;
	dst.height = tree[FISEL_FIRST].ob_height *
		(FISEL_LAST - FISEL_FIRST);

	src = dst;
	src.y = dst.y + tree[FISEL_FIRST].ob_height;

	Form_do_dial(apid,vid,FMD_START,&clip,&clip);

	Objc_do_draw(vid,tree,0,9,&clip);

	while(1) {
		but_chosen = Form_do_do(apid,vid,eventpipe,tree,FISEL_DIRECTORY);
	
		switch(but_chosen & 0x7fff) {
		case FISEL_OK:
			if(strcmp(oldpath,path)) {
				tree[FISEL_OK].ob_state &= ~SELECTED;
				Objc_do_draw(vid,tree,FISEL_OK,9,&clip);
				
				reset_dirdesc(&dd);
				set_path(path,&dd);

				get_files(tree,&dd);

				Objc_do_draw(vid,tree,FISEL_ENTBG,9,&clip);	
				Objc_do_draw(vid,tree,FISEL_SB,9,&clip);	
				
				strcpy(oldpath,path);
				break;
			};
			
			/* Fall through... */
			
		case FISEL_CANCEL:
			Form_do_dial(apid,vid,FMD_FINISH,&clip,&clip);
		
			Rsrc_free_tree(tree);
		
			if(but_chosen == FISEL_OK) {
				*button = FSEL_OK;
			}
			else {
				*button = FSEL_CANCEL;
			};
				
			reset_dirdesc(&dd);
	
			return 1;
				
		case FISEL_UP:
			if(dd.pos > 0) {
				tree[FISEL_UP].ob_state |= SELECTED;
				Objc_do_draw(vid,tree,FISEL_UP,9,&clip);					

				if(((selected - dd.pos) >= 0) &&
					((selected - dd.pos) <= (FISEL_LAST - FISEL_FIRST))) {
					WORD oldobj = selected - dd.pos + FISEL_FIRST;
												
					Objc_do_change(vid,tree,oldobj,&clip,
							tree[oldobj].ob_state &= ~SELECTED,NO_DRAW);								
				};
						
				dd.pos--;

				if(((selected - dd.pos) >= 0) &&
					((selected - dd.pos) <= (FISEL_LAST - FISEL_FIRST))) {
					WORD oldobj = selected - dd.pos + FISEL_FIRST;
											
					Objc_do_change(vid,tree,oldobj,&clip,
							tree[oldobj].ob_state |= SELECTED,NO_DRAW);								
				};
					
				get_files(tree,&dd);
				Misc_copy_area(vid,&src,&dst);

				Objc_do_draw(vid,tree,FISEL_FIRST,9,&clip);
				tree[FISEL_UP].ob_state &= ~SELECTED;
				Objc_do_draw(vid,tree,FISEL_UP,9,&clip);					
				Objc_do_draw(vid,tree,FISEL_SB,9,&clip);					
			};
			break;
			
		case FISEL_DOWN:
			if(dd.pos < (dd.num_files - FISEL_LAST + FISEL_FIRST - 1)) {
				tree[FISEL_DOWN].ob_state |= SELECTED;
				Objc_do_draw(vid,tree,FISEL_DOWN,9,&clip);					

				if(((selected - dd.pos) >= 0) &&
					((selected - dd.pos) <= (FISEL_LAST - FISEL_FIRST))) {
					WORD oldobj = selected - dd.pos + FISEL_FIRST;
											
					Objc_do_change(vid,tree,oldobj,&clip,
							tree[oldobj].ob_state &= ~SELECTED,NO_DRAW);								
				};
					
				dd.pos++;

				if(((selected - dd.pos) >= 0) &&
					((selected - dd.pos) <= (FISEL_LAST - FISEL_FIRST))) {
					WORD oldobj = selected - dd.pos + FISEL_FIRST;
											
					Objc_do_change(vid,tree,oldobj,&clip,
							tree[oldobj].ob_state |= SELECTED,NO_DRAW);								
				};
					
				get_files(tree,&dd);
				Misc_copy_area(vid,&dst,&src);
				Objc_do_draw(vid,tree,FISEL_LAST,9,&clip);
				tree[FISEL_DOWN].ob_state &= ~SELECTED;
				Objc_do_draw(vid,tree,FISEL_DOWN,9,&clip);					
				Objc_do_draw(vid,tree,FISEL_SB,9,&clip);					
			};
			break;
			
		case FISEL_SB:
			{
				WORD xy[2];
				
				Objc_do_offset(tree,FISEL_SLIDER,xy);
				
				if(((selected - dd.pos) >= 0) &&
					((selected - dd.pos) <= (FISEL_LAST - FISEL_FIRST))) {
					WORD oldobj = selected - dd.pos + FISEL_FIRST;
											
					Objc_do_change(vid,tree,oldobj,&clip,
							tree[oldobj].ob_state &= ~SELECTED,NO_DRAW);								
				};
					
				if(globals.mouse_y > xy[1]) {
					dd.pos += FISEL_LAST - FISEL_FIRST + 1;
					if(dd.pos >= (dd.num_files - FISEL_LAST + FISEL_FIRST)) {
						dd.pos = dd.num_files - FISEL_LAST + FISEL_FIRST - 1;
					};
				}
				else {
					dd.pos -= FISEL_LAST - FISEL_FIRST + 1;
					if(dd.pos < 0) {
						dd.pos = 0;
					};
				};
				

				if(((selected - dd.pos) >= 0) &&
					((selected - dd.pos) <= (FISEL_LAST - FISEL_FIRST))) {
					WORD oldobj = selected - dd.pos + FISEL_FIRST;
											
					Objc_do_change(vid,tree,oldobj,&clip,
							tree[oldobj].ob_state |= SELECTED,NO_DRAW);								
				};

				get_files(tree,&dd);
				Objc_do_draw(vid,tree,FISEL_ENTBG,9,&clip);
				Objc_do_draw(vid,tree,FISEL_SB,9,&clip);
			};
			break;
		
		case FISEL_SLIDER:
			{
				WORD newpos;
				
				Objc_do_change(vid,tree,FISEL_SLIDER,&clip,SELECTED,REDRAW);
				newpos = Graf_do_slidebox(apid,vid,eventpipe,tree,FISEL_SB,FISEL_SLIDER,1);
				
				dd.pos = (WORD)(((LONG)(dd.num_files - FISEL_LAST + FISEL_FIRST - 1) * (LONG)newpos) / 1000L);
				
				get_files(tree,&dd);
				Objc_do_change(vid,tree,FISEL_SLIDER,&clip,0,NO_DRAW);
				Objc_do_draw(vid,tree,FISEL_ENTBG,9,&clip);
				Objc_do_draw(vid,tree,FISEL_SB,9,&clip);
			};
			break;
			
		case FISEL_BACK:
			{
				BYTE newpath[128],*tmp;
				
				tree[FISEL_BACK].ob_state &= ~SELECTED;
				Objc_do_draw(vid,tree,FISEL_BACK,9,&clip);	

				strcpy(newpath,path);
								
				tmp = strrchr(newpath,'\\');

				if(!tmp)
					break;
					
				*tmp = '\0';
				tmp = strrchr(newpath,'\\');
				
				if(!tmp)
					break;
					
				*tmp = '\0';
							
				tmp = strrchr(path,'\\');
				strcat(newpath,tmp);
				strcpy(path,newpath);

				reset_dirdesc(&dd);
				set_path(path,&dd);

				Objc_area_needed(tree,FISEL_DIRECTORY,&area);	
				Objc_do_draw(vid,tree,0,9,&area);	

				get_files(tree,&dd);

				Objc_do_draw(vid,tree,FISEL_ENTBG,9,&clip);	
				Objc_do_draw(vid,tree,FISEL_SB,9,&clip);	
				
				strcpy(oldpath,path);
			};
			break;
			
		default:
			if(((but_chosen & 0x7fff) >= FISEL_FIRST) &&
				((but_chosen & 0x7fff) <= FISEL_LAST)) {
				WORD     obj = but_chosen & 0x7fff;
				DIRENTRY *dent;
				
				dent = find_entry(&dd,dd.pos + (but_chosen & 0x7fff) - FISEL_FIRST);

				if(dent) {
					if(dent->type & S_IFDIR) {
						BYTE newpath[128];
						BYTE *tmp;
						
						strcpy(newpath,path);
							
						tmp = strrchr(newpath,'\\');
							
						sprintf(tmp,"\\%s\\",&dent->name[3]);
							
						tmp = strrchr(path,'\\');
						tmp++;
						strcat(newpath,tmp);
						strcpy(path,newpath);
						
						Objc_do_change(vid,tree,obj,&clip,
								tree[obj].ob_state |= SELECTED,REDRAW);

						Objc_do_change(vid,tree,obj,&clip,
								tree[obj].ob_state &= ~SELECTED,REDRAW);		

						reset_dirdesc(&dd);
						set_path(path,&dd);


						Objc_area_needed(tree,FISEL_DIRECTORY,&area);	
						Objc_do_draw(vid,tree,0,9,&area);	

						get_files(tree,&dd);

						Objc_do_draw(vid,tree,FISEL_ENTBG,9,&clip);	
						Objc_do_draw(vid,tree,FISEL_SB,9,&clip);	
						
						strcpy(oldpath,path);
					}
					else {
						strcpy(file,&dent->name[3]);
						
						if(((selected - dd.pos) >= 0) &&
							((selected - dd.pos) <= (FISEL_LAST - FISEL_FIRST))) {
							WORD oldobj = selected - dd.pos + FISEL_FIRST;
													
							Objc_do_change(vid,tree,oldobj,&clip,
									tree[oldobj].ob_state &= ~SELECTED,REDRAW);								
						};
					
						Objc_do_change(vid,tree,obj,&clip,
								tree[obj].ob_state | SELECTED,REDRAW);
					
						selected = obj - FISEL_FIRST + dd.pos;
					
						Objc_area_needed(tree,FISEL_SELECTION,&area);	
						Objc_do_draw(vid,tree,0,9,&area);	

						if(but_chosen & 0x8000) {						
							Form_do_dial(apid,vid,FMD_FINISH,&clip,&clip);

							Rsrc_free_tree(tree);
	
							*button = FSEL_OK;
							reset_dirdesc(&dd);

							return 1;
						};						
					};
				};
			};
		};
	};
}

/****************************************************************************
 * Fsel_input                                                               *
 *  0x005a fsel_input()                                                     *
 ****************************************************************************/
void              /*                                                        */
Fsel_input(       /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	apb->int_out[0] = Fsel_do_exinput(apb->global->apid,
		apb->global->int_info->vid,apb->global->int_info->eventpipe,
		&apb->int_out[1],
		"Select a file",(BYTE *)apb->addr_in[0],(BYTE *)apb->addr_in[1]);
}

/****************************************************************************
 * Fsel_exinput                                                             *
 *  0x005b fsel_exinput()                                                   *
 ****************************************************************************/
void              /*                                                        */
Fsel_exinput(     /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	apb->int_out[0] = Fsel_do_exinput(apb->global->apid,
		apb->global->int_info->vid,apb->global->int_info->eventpipe,
		&apb->int_out[1],
		(BYTE *)apb->addr_in[2],(BYTE *)apb->addr_in[0],(BYTE *)apb->addr_in[1]);
}
