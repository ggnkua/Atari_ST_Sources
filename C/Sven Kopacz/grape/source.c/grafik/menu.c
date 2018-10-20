#include <grape_h.h>
#include "grape.h"
#include "module.h"
#include "undo.h"
#include "penpal.h"
#include "layer.h"
#include "mask.h"
#include "file_i_o.h"
#include "maininit.h"
#include "new.h"
#include "ctcppt.h"
#include "coled.h"
#include "preview.h"
#include "print.h"
#include "zoom.h"
#include "export.h"
#include "stempel.h"

/* MenÅverwaltung */

extern void pprint(void);

void fetz_her(WINDOW *win)
{
	/* Ein Fenster auswÑhlen */
	if(!win->open)
		w_open(win);
	else
		w_top(win);
}

void redraw_colwins(void)
{/* Zeichnet alle Fenster neu, die ein Farbobjekt enthalten */
	if(wtool.open)
		s_redraw(&wtool);
	if(wcolpal.open);
		s_redraw(&wcolpal);
	if(wcoled.open);
		s_redraw(&wcoled);
	if(wpreview.open)
		s_redraw(&wpreview);
	if(wsize.open)
		s_redraw(&wsize);
	if(wprint.open)
		s_redraw(&wprint);
	if(wstampopt.open)
		s_redraw(&wstampopt);
}

void do_menu(int title, int ob)
{
	switch(ob)
	{
		case MINFO:
			grape_info();
		break;
		
		/* Datei */
		case MNEW:
			if (main_win.id == -1)
				new_window();
			else
				form_alert(1,"[3][Grape:|Es kann nur eine Hauptdatei geîffnet|werden. Um weitere Grafiken zu|bearbeiten, wÑhlen Sie \'HinzufÅgen\'|aus dem Ebenen-MenÅ.][Abbruch]");
		break;
		case MOPEN:
			if(main_win.id > -1)
			{
				if(form_alert(1,"[2][Grape:|Zuerst muû die aktuelle|Datei geschlossen werden.][Schlieûen|Abbruch]")==1)
					if(!close_main_win())
						main_load();
			}
			else
				main_load();
		break;
		case MSAVE:
			if(main_win.id > -1)
				main_save();
			else
				form_alert(1,"[3][Grape:|Sichern? Tja, vielleicht|erst mal was îffnen...][Stimmt]");
		break;
		case MSAVEAS:
			if(main_win.id > -1)
				main_save_as();
			else
				form_alert(1,"[3][Grape:|Sichern? Tja, vielleicht|erst mal was îffnen...][Stimmt]");
		break;
		case MSIZE:
			if (main_win.id > -1)
				change_window(0);
			else
				form_alert(1,"[3][Grape:|Es ist keine Hauptdatei geîffnet!|WÑhlen Sie \'Neu\' oder \'ôffnen\' aus|dem Datei-MenÅ.][Abbruch]");
		break;

		case MEXPORT:
			if(main_win.id > -1)
				export_window();
			else
				form_alert(1,"[3][Grape:|Exportieren? Tja, vielleicht|erst mal was îffnen...][Stimmt]");
		break;
					
		case MPRINT:
			if (main_win.id > -1)
				print_window();
			else
				form_alert(1,"[3][Grape:|Es ist keine Hauptdatei geîffnet!|WÑhlen Sie \'Neu\' oder \'ôffnen\' aus|dem Datei-MenÅ.][Abbruch]");
		break;

		case MQUIT:
			if(main_win.id > -1)
			{
				if(!close_main_win())
					quit=1;
			}
			else
				quit=1;
		break;
		case MCLOSE:
			if(main_win.id > -1)
				close_main_win();
			else
				form_alert(1,"[3][Grape:|Schlieûen? Tja, vielleicht|erst mal was îffnen...][Stimmt]");
		break;
		

		/* *** */
		/* Bearbeiten */
		/* *** */

		case MUNDO:
			rw_undo(1);
		break;
		case MREDO:
			ff_undo(1);
		break;
		
		case MCUT:
		case MCOPY:
		case MVISCOPY:
		case MPASTE:
		case MFIX:
		case MALL:
			if(main_win.id == -1)
			{
				form_alert(1,"[3][Grape:|Es ist keine Hauptdatei geîffnet!|WÑhlen Sie \'Neu\' oder \'ôffnen\' aus|dem Datei-MenÅ.][Abbruch]");
				break;
			}
			switch(ob)
			{
				case MCUT:
					cut();
				break;
				case MCOPY:
					copy();
				break;
				case MVISCOPY:
					copy_vis();
				break;
				case MPASTE:
					paste();
				break;
				case MFIX:
					clip_size();
				break;
				case MALL:
					select_all();
				break;
			}
		break;
		

		/* *** */
		/* Ebene */
		/* *** */


		case MLINS:
		case MLDEL:
		case MLCLR:
		case MLCOPY:
		case MLIMP:
		case MLEXP:
			if(main_win.id == -1)
			{
				form_alert(1,"[3][Grape:|Es ist keine Hauptdatei geîffnet!|WÑhlen Sie \'Neu\' oder \'ôffnen\' aus|dem Datei-MenÅ.][Abbruch]");
				break;
			}
			switch(ob)
			{
				case MLINS:
					insert_layer_win();
				break;
				case MLDEL:
					delete_layer();
				break;
				case MLCLR:
					clear_layer();
				break;
				
				case MLCOPY:
					copy_layer_init();
				break;
				
				case MLIMP:
					import_layer();
				break;
				case MLEXP:
				break;
			}
		break;
		

		/* *** */
		/* Maske */
		/* *** */


		case MMINS:
		case MMDEL:
		case MMCLR:
		case MMCOPY:
		case MMIMP:
		case MMEXP:
			if(main_win.id == -1)
			{
				form_alert(1,"[3][Grape:|Es ist keine Hauptdatei geîffnet!|WÑhlen Sie \'Neu\' oder \'ôffnen\' aus|dem Datei-MenÅ.][Abbruch]");
				break;
			}
			switch(ob)
			{
				case MMINS:
					if(count_masks() < 16)
						insert_mask_win();
					else
						form_alert(1,"[3][Grape:|Es wurden bereits 16 Masken|angelegt.][Abbruch]");
				break;
				case MMDEL:
					delete_mask();
				break;
				case MMCLR:
					clear_mask();
				break;
				
				case MMCOPY:
					copy_mask_init();
				break;
				
				case MMIMP:
					if(import_mask())
						redraw_pic();
				break;
		/*
				case MMEXP:
				break;
		*/
			}
		break;		

		/* Fenster */
		case MWSPECIAL:
			fetz_her(&wspecial);
		break;
		case MWPEN:
			fetz_her(&wtool);
		break;
		case MWPENS:
			fetz_her(&wpens);
		break;
		case MWCOL:
			fetz_her(&wcolpal);
		break;
		case MWCOLED:
			fetz_her(&wcoled);
		break;
		case MWUNDO:
			fetz_her(&wundorec);
		break;
		case MFILTER:
			show_modules();
		break;
		case MPREVIEW:
			show_preview();
		break;


		/* *** */
		/* Ansicht */
		/* *** */


		case MCOLOR:
			if(col_or_grey==0) break;
			set_vdi_colors();
			menu_icheck(mmenu, MCOLOR, 1);
			menu_icheck(mmenu, MGREYS, 0);
			col_or_grey=0;
			if(main_win.id > -1)
				redraw_pic();
			redraw_colwins();
		break;
		case MGREYS:
			if(col_or_grey==1) break;
			set_grey_pal();
			menu_icheck(mmenu, MCOLOR, 0);
			menu_icheck(mmenu, MGREYS, 1);
			col_or_grey=1;
			if(main_win.id > -1)
				redraw_pic();
			redraw_colwins();
		break;

		case MZOUT:
			if(main_win.id == -1)
			{
				form_alert(1,"[3][Grape:|Es ist keine Hauptdatei geîffnet!|WÑhlen Sie \'Neu\' oder \'ôffnen\' aus|dem Datei-MenÅ.][Abbruch]");
				break;
			}
			zoom_out();
		break;
		case MZIN:
			if(main_win.id == -1)
			{
				form_alert(1,"[3][Grape:|Es ist keine Hauptdatei geîffnet!|WÑhlen Sie \'Neu\' oder \'ôffnen\' aus|dem Datei-MenÅ.][Abbruch]");
				break;
			}
			zoom_in();
		break;
		case MZOOM:
			if(main_win.id == -1)
			{
				form_alert(1,"[3][Grape:|Es ist keine Hauptdatei geîffnet!|WÑhlen Sie \'Neu\' oder \'ôffnen\' aus|dem Datei-MenÅ.][Abbruch]");
				break;
			}
			zoom_window();
		break;
		case MZFIT:
			if(main_win.id == -1)
			{
				form_alert(1,"[3][Grape:|Es ist keine Hauptdatei geîffnet!|WÑhlen Sie \'Neu\' oder \'ôffnen\' aus|dem Datei-MenÅ.][Abbruch]");
				break;
			}
			fit_zoom();
		break;
		case MZ1:
		case MZ2:
		case MZ3:
		case MZ4:
		case MZ5:
		case MZ6:
			if(main_win.id == -1)
			{
				form_alert(1,"[3][Grape:|Es ist keine Hauptdatei geîffnet!|WÑhlen Sie \'Neu\' oder \'ôffnen\' aus|dem Datei-MenÅ.][Abbruch]");
				break;
			}
			set_menu_zoom(ob);
		break;
		case MSETZOOM:
			fzooms_window();
		break;

		
		/* *** */
		/* Optionen */
		/* *** */


		case MPMODE:
			paste_mode();
		break;
		case MUNOPT:
			undo_options();
		break;
		case MPARAM:
			a_options();
		break;
		case GMODOPT:
			modopt_window();
		break;
		case MFEXPORT:
			fexport_window();
		break;
		default:
			form_alert(1,"[3][Des isch no ned drenna][kantzl]");
		break;
	}
	menu_tnormal(mmenu, title, 1);
}
