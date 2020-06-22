/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <OSBIND.H>
#include <VDI.H>
#include <memory.h>
#include "XA_TYPES.H"
#include "XA_DEFS.H"
#include "XA_GLOBL.H"
#include "KERNAL.H"
#include "K_DEFS.H"
#include "KERNAL.H"
#include "GRAF_MOU.H"
#include "C_WINDOW.H"
#include "RECTLIST.H"
#include "BOX3D.H"
#include "OBJECTS.H"
#include "MESSAGES.H"
#include "SYS_MENU.H"
#include "std_widg.h"
#include "system.h"
#include "resource.h"
#include "desktop.h"

#ifndef THICKENED
/* Lattice C should better use the TF_xxx-constants anyway... */
#define THICKENED	0x01
#define SHADED		0x02
#define SKEWED		0x04
#define UNDERLINED	0x08
#define OUTLINE		0x10
#define SHADOW		0x20
#endif

/*
	Menu Widget display
*/
short display_menu_widget(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short x,y;
	XA_WIDGET_TREE *w_otree=(XA_WIDGET_TREE*)widg->stuff;
	XA_CLIENT *client;
	OBJECT *root;
	short pxy[4];
	short title,this_t=-1,sel_t=-1,sel_t_menu;
	short menu_x,menu_y;
	short menu_text,mty;
	short mx,my,mb;

	rp_2_ap(wind, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */
	
	root=w_otree->tree;

	root->ob_x=x; root->ob_y=y;

	vst_color(V_handle, BLACK);

	pxy[0]=x; pxy[1]=y;
	pxy[2]=wind->w+wind->x-x; pxy[3]=y+widg->h;
	vsf_color(V_handle, display.dial_colours.bg_col);
	v_bar(V_handle,pxy);
		
	title=root[root[root[0].ob_head].ob_head].ob_head;

	vq_mouse(V_handle, &mb, &mx, &my);
	
	vsf_color(V_handle, BLACK);
	
	while(title!=root[root[0].ob_head].ob_head)		/* Display titles */
	{
		this_t++;
		if (root[title].ob_state&SELECTED)
		{
			sel_t=this_t; 
			menu_x=root[title].ob_x+x-2; menu_y=y;
			vst_color(V_handle, WHITE);
			pxy[0]=menu_x+2; pxy[1]=menu_y;
			pxy[2]=pxy[0]+root[title].ob_width+4;
			pxy[3]=pxy[1]+widg->h;
			v_bar(V_handle,pxy);
			v_gtext(V_handle, root[title].ob_x+x, y+2, (char*)root[title].ob_spec);
			vst_color(V_handle, BLACK);
		}else{
			v_gtext(V_handle, root[title].ob_x+x, y+2, (char*)root[title].ob_spec);
		}
		title=root[title].ob_next;
	}
	
	if ((widg->stat==XAW_SELECTED)&&(sel_t!=-1))	/* If a menu is selected, display the actual menu */
	{
		sel_t_menu=root[root[0].ob_tail].ob_head;
		for(title=0; (title!=sel_t); title++)
			sel_t_menu=root[sel_t_menu].ob_next;
			
		if (sel_t!=0)
		{
			pxy[1]=y+widg->h; 
			pxy[2]=pxy[0]+root[sel_t_menu].ob_width;
			pxy[3]=pxy[1]+root[sel_t_menu].ob_height;
			XA_3D_rect(menu_x,menu_y+widg->h+2,root[sel_t_menu].ob_width+10,root[sel_t_menu].ob_height+4,2,1);

			vsf_color(V_handle,BLACK);

			mty=menu_y+widg->h+5;
		
			for(menu_text=root[sel_t_menu].ob_head; menu_text!=sel_t_menu; menu_text=root[menu_text].ob_next)
			{
				if (root[menu_text].ob_state&DISABLED)			/* Disabled item? */
				{
					vst_effects(V_handle, SHADED);
				}else{
					if (root[menu_text].ob_state&SELECTED)		/* Selected menu item? */
					{
						vst_color(V_handle, WHITE);
						pxy[0]=menu_x+5; pxy[1]=mty;
						pxy[2]=pxy[0]+root[sel_t_menu].ob_width+1;
						pxy[3]=pxy[1]+display.c_max_h;
						v_bar(V_handle,pxy);
					}
				}
				v_gtext(V_handle, menu_x+5, mty, (char*)root[menu_text].ob_spec);

				if (root[menu_text].ob_state&CHECKED)	/* Display a check mark if needed */
					v_gtext(V_handle, menu_x+5, mty, "");
			
				vst_effects(V_handle, 0);
				vst_color(V_handle,BLACK);
				mty+=display.c_max_h;
			}
		}else{
			pxy[1]=y+widg->h; 
			pxy[2]=pxy[0]+root[sel_t_menu].ob_width;
			pxy[3]=pxy[1]+root[sel_t_menu].ob_height;
			XA_3D_rect(menu_x,menu_y+widg->h+2,root[sel_t_menu].ob_width+10,root[sel_t_menu].ob_height+4,2,1);

			vsf_color(V_handle,BLACK);

			mty=menu_y+widg->h+5;
		
			menu_text=root[sel_t_menu].ob_head;

			if (root[menu_text].ob_state&DISABLED)			/* Disabled item? */
			{
				vst_effects(V_handle, SHADED);
			}else{
				if (root[menu_text].ob_state&SELECTED)		/* Selected menu item? */
				{
					vst_color(V_handle, WHITE);
					pxy[0]=menu_x+5; pxy[1]=mty;
					pxy[2]=pxy[0]+root[sel_t_menu].ob_width+1;
					pxy[3]=pxy[1]+display.c_max_h;
					v_bar(V_handle,pxy);
				}
			}
			v_gtext(V_handle, menu_x+5, mty, (char*)root[menu_text].ob_spec);
			
			mty+=display.c_max_h;
			pxy[0]=menu_x+4; pxy[1]=pxy[3]=mty;
			pxy[2]=pxy[0]+root[sel_t_menu].ob_width+1;
			v_pline(V_handle,2,pxy);
			
			mty+=3;
			
			for(client=FirstClient(); client!=NULL; client=NextClient(client))
			{
				if (client->clnt_pipe_rd)
				{
					if (((mx>menu_x)&&(mx<menu_x+root[sel_t_menu].ob_width))&&((my>mty)&&(my<mty+display.c_max_h)))
					{
						vst_color(V_handle, WHITE);
						vsf_color(V_handle,BLACK);
					}else{
						vst_color(V_handle, BLACK);
						vsf_color(V_handle, display.dial_colours.bg_col);
					}
					pxy[0]=menu_x+5; pxy[1]=mty;
					pxy[2]=pxy[0]+root[sel_t_menu].ob_width+1;
					pxy[3]=pxy[1]+display.c_max_h;
					v_bar(V_handle,pxy);
					
					v_gtext(V_handle, menu_x+5, mty, client->name);

					if (((XA_WIDGET_TREE*)root_window->widgets[XAW_MENU].stuff)->owner==Client2Pid(client))
					{
						v_gtext(V_handle, menu_x+5, mty, "");
					}else{
						if (client->client_type==XA_CT_ACC)
						{
							v_gtext(V_handle, menu_x+5, mty, "ø");
						}
					}
					
					vst_color(V_handle,BLACK);
					mty+=display.c_max_h;
				}
			}
		}
	}
	return TRUE;
}

/*
	Generic Object Tree Widget display
*/
short display_object_widget(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short x,y;
	XA_WIDGET_TREE *w_otree=(XA_WIDGET_TREE*)widg->stuff;
	OBJECT *root;

	rp_2_ap(wind, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */
	
	root=w_otree->tree;

	root->ob_x=x; root->ob_y=y;
	draw_object_tree(root, 0, 100);

	return TRUE;
}

/*
	Really should get the multi-thread support in here....doesn't work at the
	moment though...
*/
const char *empty_title="";

short click_menu_widget(XA_WINDOW *wind, XA_WIDGET *widg)
{
	XA_WIDGET_TREE *w_otree=(XA_WIDGET_TREE*)widg->stuff;
	OBJECT *root;
	XA_CLIENT *client;
	short clicked_title,selected_menu=-1,x,y,f,n;
	short point_at_menu=-1,t,pxy[8];
	short mx,my,mb,omx,omy;
	short menu_x,menu_y,old_menu_y=0;
	MFDB Mscreen;
	MFDB Mpreserve;

	rp_2_ap(wind, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */
	root=w_otree->tree;
	root->ob_x=x; root->ob_y=y;

	if (wind==root_window)		/* Tear off menu bar support (root menu only) */
	{
		vq_key_s(V_handle,&t);
		if (t&4)
		{
			XA_WINDOW *new_menu_window;
			short w,max_w;
			
			max_w=0;
			for(f=root[root[root[0].ob_head].ob_head].ob_head; f!=root[root[0].ob_head].ob_head; f=root[f].ob_next)
			{
				w=root[f].ob_x+root[f].ob_width;
				if (w>max_w)
					max_w=w;
			}
			new_menu_window=create_window(((XA_WIDGET_TREE*)root_window->widgets[XAW_MENU].stuff)->owner, CLOSE|NAME|MOVE|NO_MESSAGES|NO_WORK, x,y+widg->h, max_w+34, widg->h+8);
			new_menu_window->is_open=TRUE;
			new_menu_window->widgets[XAW_TITLE].stuff=(void*)empty_title;

			set_menu_widget(new_menu_window, widg->loc, (OBJECT*)((XA_WIDGET_TREE*)root_window->widgets[XAW_MENU].stuff)->tree);
			new_menu_window->widgets[XAW_TITLE].w=new_menu_window->widgets[XAW_CLOSE].w;
			new_menu_window->widgets[XAW_TITLE].loc.x=new_menu_window->widgets[XAW_CLOSE].loc.x+new_menu_window->widgets[XAW_CLOSE].w+1;
			new_menu_window->widgets[XAW_MENU].loc.x=new_menu_window->widgets[XAW_TITLE].loc.x+new_menu_window->widgets[XAW_TITLE].w;
			new_menu_window->widgets[XAW_MENU].w=max_w;
			new_menu_window->widgets[XAW_MENU].loc.y=2;
			((XA_WIDGET_TREE*)new_menu_window->widgets[XAW_MENU].stuff)->owner=((XA_WIDGET_TREE*)root_window->widgets[XAW_MENU].stuff)->owner;
			pull_wind_to_top(new_menu_window);
			v_hide_c(V_handle);
			display_non_topped_window(new_menu_window,NULL);
			v_show_c(V_handle,1);

			return FALSE;
		}
	}
	
	omx=x+widg->click_x; omy=y+widg->click_y;
	clicked_title=find_object(root, root[root[0].ob_head].ob_head, 2, omx, omy);

	if ((clicked_title>-1)&&(root[clicked_title].ob_type==G_TITLE))
	{
		widg->stat=XAW_SELECTED;
		
		n=root[root[0].ob_tail].ob_head;
		for(f=root[root[root[0].ob_head].ob_head].ob_head; f!=root[root[0].ob_head].ob_head; f=root[f].ob_next)
		{
			if (f==clicked_title)
			{
				selected_menu=n;
			}else{
				root[f].ob_state&=~SELECTED;
			}
			n=root[n].ob_next;
		}
		root[clicked_title].ob_state|=SELECTED;
		
		menu_x=root[clicked_title].ob_x+x-2;
		menu_y=y+widg->h;
		
		Mpreserve.fd_w=root[selected_menu].ob_width+20;
		Mpreserve.fd_h=root[selected_menu].ob_height+20;
		Mpreserve.fd_wdwidth=(Mpreserve.fd_w+15)>>4;
		Mpreserve.fd_nplanes=display.planes;
		Mpreserve.fd_stand=0;
/* Always remember that the MFDB-members are short, and short * short = short,
 * which will be converted into a long for the malloc call. Usually, it will
 * be converted preserving the sign, so that 0x8000 becomes 0xffff8000!
 * Also consider that short * short may easily no longer fit into a short.
 */
		Mpreserve.fd_addr=(void*)malloc((long)Mpreserve.fd_h * (long)Mpreserve.fd_wdwidth * 2L * (long)display.planes);

		Mscreen.fd_addr=NULL;

		if (!Mpreserve.fd_addr)
		{
			root[clicked_title].ob_state&=~SELECTED;	/* Deselect the title */
			DIAGS(("ERROR: Cann't allocate memory for menu background\n"));
			return TRUE;
		}

		clear_clip();				/* Menu's are always on top...so don't clip */

		pxy[0]=menu_x; pxy[1]=menu_y;					/* Preserve background */
		pxy[2]=menu_x+Mpreserve.fd_w-1; pxy[3]=menu_y+Mpreserve.fd_h-4;
		pxy[4]=0; pxy[5]=0;
		pxy[6]=Mpreserve.fd_w-1; pxy[7]=Mpreserve.fd_h-4;

		v_hide_c(V_handle);
		vro_cpyfm(V_handle, S_ONLY, pxy, &Mscreen, &Mpreserve);

		display_menu_widget(wind, widg);
		v_show_c(V_handle, 1);
		
/* Do a point-at-and-click menu selection */
		do{
			vq_mouse(V_handle,&mb,&mx,&my);
			
			if ((mx!=omx)||(my!=omy))
			{
				omx=mx; omy=my;
				menu_y=y+widg->h+5;
				
				t=-1;

				if ((mx>menu_x)&&(mx<menu_x+root[selected_menu].ob_width))	/* Find pointed at menu entry */
				{
					for(f=root[selected_menu].ob_head; (f!=selected_menu)&&(t==-1); f=root[f].ob_next)
					{
						if ((my>menu_y)&&(my<menu_y+display.c_max_h))
						{
							t=f;
						}else{
							menu_y+=display.c_max_h;
						}
					}
				}

				if (t!=point_at_menu)
				{
					if (point_at_menu!=-1)		/* De-select current selection (if any) */
					{
						root[point_at_menu].ob_state&=~SELECTED;
						set_clip(menu_x-5, old_menu_y-5,
								root[selected_menu].ob_width+10, display.c_max_h+10);
						v_hide_c(V_handle);
						display_menu_widget(wind, widg);
						v_show_c(V_handle, 1);
					}
				
					if (t!=-1)				/* Something selected at the moment? */
					{						/* Highlight current selection */
						root[t].ob_state|=SELECTED;
						set_clip(menu_x-5,menu_y-5,
								root[selected_menu].ob_width+10,display.c_max_h+10);
						v_hide_c(V_handle);
						display_menu_widget(wind, widg);
						v_show_c(V_handle, 1);
						old_menu_y=menu_y;
					}

					clear_clip();
					point_at_menu=t;
				}
			}
		}while(!mb);

		root[clicked_title].ob_state&=~SELECTED;	/* Deselect the title */

		pxy[4]=pxy[0]; pxy[5]=pxy[1];				/* Restore background */
		pxy[6]=pxy[2]; pxy[7]=pxy[3];
		pxy[0]=0; pxy[1]=0;
		pxy[2]=Mpreserve.fd_w-1; pxy[3]=Mpreserve.fd_h-4;
		v_hide_c(V_handle);
		vro_cpyfm(V_handle, S_ONLY, pxy, &Mpreserve, &Mscreen);
		v_show_c(V_handle, 1);
		
		free(Mpreserve.fd_addr);
		
		if ((clicked_title!=root[root[root[0].ob_head].ob_head].ob_head)||(point_at_menu==root[selected_menu].ob_head))
		{
			if (point_at_menu!=-1)	/* Exitting with a selection - send it */
			{
				DIAGS(("Menu selected\n"));
				root[point_at_menu].ob_state&=~SELECTED;	/* Deselect the menu entry */
				if (w_otree->owner!=AESpid)		/* If it's a client program menu, send it a little message to say hi.... */
				{
					DIAGS(("Calling send_app_message()\n"));
					DIAGS(("app=%d,title=%d,point_at=%d\n",w_otree->owner,clicked_title, point_at_menu));
					DIAGS(("root=%ld, sel_menu=%d\n",root, selected_menu));
									/* Note the AES4.0 extended message format...... */
					send_app_message(w_otree->owner, MN_SELECTED, AESpid, clicked_title, point_at_menu, (short)((long)root>>16), (short)((long)root&0xffff), selected_menu);
				}else{							/* Otherwise, process system menu clicks */
					DIAGS(("do_system_menu()\n"));
					do_system_menu(clicked_title, point_at_menu);
				}
			}
		}else{
			DIAGS(("click on desk menu\n"));
			menu_y=y+widg->h+9+display.c_max_h; n=1;
			for(client=FirstClient(); client; client=NextClient(client))
			{
				if (client->clnt_pipe_rd)
				{
					DIAGS(("candidate:%s\n",client->name));
					if ((my>menu_y)&&(my<menu_y+display.c_max_h))
					{
						DIAGS(("match\n"));
						break;
					}
					menu_y+=display.c_max_h;
				}
			}
			
			if (client)
			{
				DIAGS(("got client pid=%d\n",Client2Pid(client)));
				switch (client->client_type)
				{
					case XA_CT_ACC:		/* Accessory - send AC_OPEN */
						DIAGS(("is an accessory\n"));
						send_app_message(Client2Pid(client), AC_OPEN, AESpid, 0, 0, 0, 0, 0);
						break;
			
					case XA_CT_APP:		/* Application, swap topped app */
						DIAGS(("is a real GEM client\n"));
						{
							XA_WIDGET_TREE *menu_bar=(XA_WIDGET_TREE*)(root_window->widgets[XAW_MENU].stuff);
						
							if (client->std_menu!=menu_bar->tree)	/* Different menu? */
							{
								GRECT clip;
			
								menu_bar->tree=client->std_menu;
					
								if (client->std_menu==clients[AESpid].std_menu)
									menu_bar->owner=AESpid;		/* Apps with no menu get the default menu, and that's owned by the AES */
								else
									menu_bar->owner=Client2Pid(client);	/* Apps with menu's own their own menu */
				
								rp_2_ap(root_window, root_window->widgets+XAW_MENU, &clip.g_x, &clip.g_y);
	
									clip.g_w=root_window->widgets[XAW_MENU].w;
								clip.g_h=root_window->widgets[XAW_MENU].h;
	
								v_hide_c(V_handle);
								display_non_topped_window(root_window,&clip);
								v_show_c(V_handle,1);
							}else{											/* Same menu, just a different owner... */
								menu_bar->owner=Client2Pid(client);
							}
			
							if ((client->desktop)					/* Change desktops? */
								&&((client->desktop!=desktop)&&(client->desktop!=ResourceTree(system_resources,DEF_DESKTOP))))
							{
								set_desktop(client->desktop);
								root_window->owner=Client2Pid(client);
	
								v_hide_c(V_handle);
								display_non_topped_window(root_window,NULL);
								v_show_c(V_handle,1);
							}
						}
						break;
				}
			}
		}
		widg->stat=XAW_PLAIN;
	}

	return FALSE;		/* Return false so we don't re-display the widget */
}

