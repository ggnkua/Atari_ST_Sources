#include <aes.h>
#include <vdi.h>
#include <osbind.h>
#include <stdio.h>
#include <stdlib.h>
#include "forecast.h"
#include "main.h"

#include "transprt.h"

/*	Definitions...	*/

#define MAXHOSTNAMELEN	64

/*	Prototypes...	*/

	void	main(void);
	void	gem_init(void);
	void	gem_close(void);
	void	init_rsrc(void);

/*	Externals...	*/

	extern void	init_mfdb(void);
	extern void	close_mfdb(void);
	
	extern void	draw_win(void);
	extern void	create_win(const char *);
	extern void	close_win(void);
	extern void	delete_win(void);
	extern short	do_menu(short);
	extern short	dialog(OBJECT *, short);

	extern void	draw_template(void);
	extern void	draw_thermometer(short);
	extern void	draw_barometer(short, short);
	extern void	draw_humidity(short);
	extern void	draw_wind(char *, short);

	extern int	open_socket(char *, int);
	extern int	close_socket(int);
	extern int	read_from_socket(int, char *, int);
	extern int	send_to_socket(int, char *, int);

	extern int	initialise(void);

/*	Globals...		*/

	/*	AES/VDI...	*/

	short 	ap_id;
	short	vdi_handle;
	short	work_in[11] = {1,1,1,1,1,1,1,1,1,1,2};
	short	work_out[57], extn_out[57];
	short aes_version;
	char program_title[] = "  Forecast v. 0.4  ";

	/*	Resource...	*/

	OBJECT *menu_ptr, *about_ptr, *loc_ptr, *help_ptr;

	/*	MFDB...		*/
	
	MFDB	work, screen;

	/*	Window...	*/
	
	WINDOW	win;

	/* File IO */

	char    filename[128];
	char    filepath[128];   
	char 	program_dir[128];


	/*	Program Flow...	*/
	
	short endmainloop;
	short open=0;
	int   did_stik_init = 0;	
	char city_tla[3];


/*	Procedures...	*/

void	main(void)
	{
	short junk, event, scan, msg[8];
/*	struct sockaddr_in	soc_address, *sin = &soc_address;
	struct hostent		*hp;
	char			*hostname, hnamebuf[MAXHOSTNAMELEN];
	char			*cityname;
	char			weatherhost[]="um-weather.sprl.umich.edu";*/
	char			*ptr, *ptr2, *temp, *baro_p, *baro_dec, *humid, *wind_dir, *wind;
	char			*buff;
	char			message[64]; /* Scratch buffer for alert */
	int			s;
	short			i, j;

	gem_init();
	init_mfdb();
	draw_template();
	create_win("AtariForecast");

/*	wind_info(win.handle, "Loading Map Data");*/
/*	wind_info(win.handle, "Initializing Identity Matricies");*/

	graf_mouse(ARROW, NULL);
	did_stik_init = init_network();

	do
		{
		event = evnt_multi(MU_MESAG | MU_KEYBD,
				0, 0, 0,
				0, 0, 0, 0, 0,
				0, 0, 0, 0, 0,
				msg,
				0, 0,
				&junk, &junk, &junk, &junk, &scan, &junk);

		if (MU_MESAG & event)
			{
			if (msg[0]==MN_SELECTED)
				{
				wind_update(BEG_UPDATE);
				endmainloop=do_menu(msg[4]);
				menu_tnormal(menu_ptr, msg[3], 1);
				wind_update(END_UPDATE);
				}

			switch (msg[0])
				{
				case WM_TOPPED:
					if (win.handle==msg[3])
						{
						wind_set(win.handle, WF_TOP, &junk, &junk, &junk, &junk);
						}
				break;

				case WM_CLOSED:
					if (win.handle==msg[3])	endmainloop=TRUE;
				break;

				case WM_MOVED:
					if (win.handle==msg[3])
						{
						wind_set(win.handle, WF_CXYWH, msg[4], msg[5], msg[6], msg[7]);
						win.b_rect.g_x=msg[4];
						win.b_rect.g_y=msg[5];
						win.b_rect.g_w=msg[6];
						win.b_rect.g_h=msg[7];
						wind_calc(WC_WORK, WINTYPE, msg[4], msg[5], msg[6], msg[7],
									&win.w_rect.g_x, &win.w_rect.g_y,
									&win.w_rect.g_w, &win.w_rect.g_h);
						}
				break;

				case WM_REDRAW:
					if (win.handle==msg[3])	draw_win();
				break;
				}
			}

		if (MU_KEYBD & event)
			{
			switch (scan)
				{
				case 0x180F:
					open=0x01;
					break;

				case 0x1011:
					endmainloop=TRUE;
					break;

				case 0x6200:
					/* help */
					dialog(help_ptr,0);
					break;

				case 0x0F09:
					/* Tab - about */
					dialog(about_ptr,0);
					break;
				}
			}

		if (open==0x01)
			{
			bzero(message, sizeof(message));
			clear_mfdb(&work);
			draw_template();

			read_prefs_file(filename);

			dialog(loc_ptr, city);
			strcpy(city_tla, ((TEDINFO *)(loc_ptr[city].ob_spec))->te_ptext);

			write_prefs_file(filename);

			strcpy(message, ((TEDINFO *)(loc_ptr[city].ob_spec))->te_ptext);
			message[3]=13;
			message[4]=10;
			message[5]=0;

			if (did_stik_init != TRUE)
				{
					did_stik_init = init_network();
				}

			if (did_stik_init == TRUE)
				{
				    buff = KRmalloc((long)2000);   /* That should be enough    */

				    if (buff == (char *)NULL) 
						{
							strcpy(message, "[1][");
							strcat(message, "Can't allocate line buffer|for Forecast!");
							strcat(message, "][  OK  ]");
							form_alert(1, message);
					        return;
					    }

					bzero(buff, sizeof(buff));

					s=open_socket("um-weather.sprl.umich.edu", 3000);
					read_from_socket(s, NULL, 0);
					send_to_socket(s, message, 5);
					read_from_socket(s, buff, 2048);
					close_socket(s);

					for (i=0; ((buff[i]!='=') && (i<2048)); i++);
					ptr=&buff[i];
					for (; ((buff[i]!=13) && (i<2048)); i++);
					ptr=&buff[i];
					for (i++; ((buff[i]!=13) && (i<2048)); i++);
					buff[--i]=0;

					ptr++;

					for (j=0; (ptr<&buff[i]); j++)
						{
						for (; ((ptr<&buff[i]) && (*ptr==' ')); ptr++);
						for (ptr2=ptr+1; ((ptr2<&buff[i]) && (*ptr2!=' ')); ptr2++);
						*ptr2=0;
		/*				printf("%d. %s\n", (short)(ptr2-ptr), ptr);*/
						switch (j)
							{
							case 0:
								temp=ptr;
								draw_thermometer(atoi(temp));
								break;

							case 1:
								humid=ptr;
								draw_humidity(atoi(humid));
								break;

							case 2:
								wind_dir=ptr;
								break;
	
							case 4:
								wind=ptr;
								draw_wind(wind_dir, atoi(wind));
								break;

							case 5:
								baro_dec=baro_p=ptr;
								for (; ((baro_dec<ptr2) && (*baro_dec!='.')); baro_dec++);
								*baro_dec++=0;
								draw_barometer(atoi(baro_p), atoi(baro_dec));
								break;
							}
						ptr=ptr2+1;
						}

			        KRfree(buff);

				}
		
			else if(did_stik_init == FALSE)
				{
					strcpy(message, "[1][");
					strcat(message, "Connection NOT possible|Enable STiK");
					strcat(message, "][  OK  ]");
					form_alert(1, message);
				}

			draw_win();
			open=0;
			}
		}
	while (endmainloop==FALSE);

	close_win();
	delete_win();

	close_mfdb();
	gem_close();
	}

void init_rsrc(void)
	{
	rsrc_gaddr(R_TREE, menu, &menu_ptr);
	rsrc_gaddr(R_TREE, about, &about_ptr);
	rsrc_gaddr(R_TREE, location, &loc_ptr);
	rsrc_gaddr(R_TREE, help, &help_ptr);
/*
 *	for (i=0; i<last; i++)
 *		{
 *		rsrc_gaddr(R_STRING, i, &ptr);
 *		strings[i]=ptr;
 *		}
 */
	}

void gem_init(void)
	{
	short junk;

	ap_id = appl_init();

	if (!rsrc_load("FORECAST.RSC"))
		{
		form_alert(1,"[1][Error Loading Resource! ][Quit]");
		exit(EXIT_FAILURE);
		}

	init_rsrc();
	aes_version = _AESglobal[0];

	if (aes_version >= 0x0400)		/* check for MultiTOS*/
	{
		menu_register(ap_id, program_title); /* if it is make the name pretty*/
	}

	vdi_handle=graf_handle(&junk,&junk,&junk,&junk);
	for (junk=0; junk<10; junk++)	work_in[junk]=1;
	work_in[10]=2;
	v_opnvwk(work_in, &vdi_handle, work_out);
	vq_extnd(vdi_handle, 1, extn_out);
	vst_alignment(vdi_handle, 0, 1, &junk, &junk);

	getcd(0,program_dir);  /* path that antmail is being run from*/
	strcat(program_dir,"\\*.*");       

	construct_path(filename,program_dir,"FORECAST.PRF");
	read_prefs_file(filename);

	menu_bar(menu_ptr, 1);
	}

void gem_close(void)
	{
	menu_bar(menu_ptr, 0);
	v_clsvwk(vdi_handle);
	rsrc_free();
	appl_exit();
	}
