#include "SuJi_glo.h"

char versionsnummernstring[]="V1.36";

int main(int argc,char *argv[])
{
	int ob_height;
	int ret;

/* Lange Dateinamen */
	Pdomain(1);

/* Anmeldung beim AES */
	ap_id=mt_appl_init(&global);
	if(ap_id<0)
	{
		Cconws("SuJi: appl_init() failed\r\n"
				"- Hit Return -\r\n");
		Cconin();
		return 0;
	}

/* Gibt es den Check-and-set-Mode bei wind_update? */
	if(!mt_appl_getinfo(11,NULL,NULL,NULL,&there_is_check_and_set,&global) ||
		!(there_is_check_and_set & 1))
	{ /* appl_getinfo hat nicht geklappt oder kein C&S*/
		there_is_check_and_set=0;
	}
	else
	{ /* Es gibt C&S */
		there_is_check_and_set=0x100;
	}

/* Laden der Resource */
	if(!mt_rsrc_load("SuJi.rsc",&global) &&
		!mt_rsrc_load("SUJI.RSC",&global) &&
		!mt_rsrc_load("suji.rsc",&global) &&
		!mt_rsrc_load("Suji.rsc",&global))
	{
		mt_form_alert(1,"[3][SuJi:|rsrc_load(\"SuJi.rsc\") failed][Abort]",&global);
		mt_appl_exit(&global);
		return 0;
	}

/* Analyse der Parameter */
	suji.zahl_pfade=analyse_parameter(argc,argv,&suji.search_pfade);

	if(suji.zahl_pfade==-1)	/* Speichermangel */
	{
		mt_rsrc_gaddr(5,ERR_NO_MEM,&alert,&global);
		mt_form_alert(1,alert,&global);
		mt_rsrc_free(&global);
		mt_appl_exit(&global);
		return 0;
	}

/* ôffnen der VDI-Workstation */
	vdi_h=init_vwork();
	if(vdi_h==0)
	{
		mt_rsrc_gaddr(5,ERR_NO_WORKST,&alert,&global);
		mt_form_alert(1,alert,&global);
		free_pfade(suji.search_pfade);
		mt_rsrc_free(&global);
		mt_appl_exit(&global);
		return 0;
	}

/* Icons anpassen */
	icons_anpassen();

/* Dialogadresse ermitteln */
	mt_rsrc_gaddr(0,MASKE_DIALOG,&dialog_maske.tree,&global);

/* Testen, ob der Dialog auf den Bildschirm passt */
	if(!passt_auf_den_bildschirm(ASK_INHALT))
	{
		mt_rsrc_gaddr(5,ERR_TOO_BIG,&alert,&global);
		mt_form_alert(1,alert,&global);
		free_pfade(suji.search_pfade);
		mt_rsrc_free(&global);
		mt_appl_exit(&global);
		return 0;
	}

/* AV-Protokoll */
	mt_rsrc_gaddr(5,NAME_AV,&prog_name,&global);
	init_av_protokoll();

/* Entsprechend umbenennen */
	while(prog_name[strlen(prog_name)-1]==' ')
		prog_name[strlen(prog_name)-1]='\0';

	mt_menu_register(-1,prog_name,&global);

/* Maus zurÅckschalten */
	mt_graf_mouse(ARROW,NULL,&global);

	mt_rsrc_gaddr(5,DIALOG_TITEL,&alert,&global);

/* Voreinstellung der Suchmaske und Bedingungen */
	make_scroll_edit(dialog_maske.tree,MASKE_EDIT,&xted_maske,100);
	make_scroll_edit(dialog_maske.tree,INHALT_EDIT,&xted_inhalt,100);
	dialog_maske.tree[MASKE_EDIT].ob_spec.tedinfo->te_ptext[0]='\0';
	dialog_maske.tree[INHALT_EDIT].ob_spec.tedinfo->te_ptext[0]='\0';

	dialog_maske.tree[MB_EDIT].ob_spec.tedinfo->te_ptext[0]='\0';
	dialog_maske.tree[MS_EDIT].ob_spec.tedinfo->te_ptext[0]='\0';

	{
		OBJECT *tree;
		char *help;

		mt_rsrc_gaddr(0,LANGUAGE_SETTING,&tree,&global);

		help=dialog_maske.tree[MJ_EDIT].ob_spec.tedinfo->te_ptmplt;
		while(*help)
		{
			if(*help == '.')
				*help = tree[LS_DM_TRENNER].ob_spec.tedinfo->te_ptext[0];
			help++;
		}

		help=dialog_maske.tree[MO_EDIT].ob_spec.tedinfo->te_ptmplt;
		while(*help)
		{
			if(*help == '.')
				*help = tree[LS_DM_TRENNER].ob_spec.tedinfo->te_ptext[0];
			help++;
		}
	}

	dialog_maske.tree[MJ_EDIT].ob_spec.tedinfo->te_ptext[0]='\0';
	dialog_maske.tree[MO_EDIT].ob_spec.tedinfo->te_ptext[0]='\0';

	/* Userdefs fÅr die Listbox vorbereiten */
	make_listbox_userdef(&dialog_maske.tree[ENTRY_1],&ud_ENTRY1);
	make_listbox_userdef(&dialog_maske.tree[ENTRY_2],&ud_ENTRY2);
	make_listbox_userdef(&dialog_maske.tree[ENTRY_3],&ud_ENTRY3);
	make_listbox_userdef(&dialog_maske.tree[ENTRY_4],&ud_ENTRY4);

	/* Save tree high for later */
	ob_height = dialog_maske.tree[0].ob_height;

	load_config();
	
	do
	{
		/* Restore tree high */
		dialog_maske.tree[0].ob_height = ob_height;
		
		clr_or_set_dialog_titel(0,dialog_maske.tree,MASKE_TITEL);

		handle_dialog(suji.search_pfade, &config.dialog.g_x, &config.dialog.g_y);

		save_config();
		
	/* Wenn Abbruch, dann ist maske NULL */
		if(!suji.maske)
			break;
		
	/* Listfenster îffnen */
		if(!open_list_window( &config.listwindow ))
		{
			mt_rsrc_gaddr(5,ERR_NO_WINDOW,&alert,&global);
			mt_form_alert(1,alert,&global);
			break;
		}
	
	/* Durchsuche der einzelnen Pfade, ggf. eigener Eventhandler */
		searching=TRUE;
		set_mouse(ARROW);
	
		if(durchsuche_alle(suji.search_pfade,suji.zahl_pfade)!=-1)
		{
			Cconout(7);
			ret = -2;
			while(ret==-2)
				ret=master_event(0);
		}
	
	/* Alles schlieûen, abmelden usw. */
		close_list_window( &config.listwindow );
		free_whole_list();

		save_config();
			
	} while (ret == -3);

	exit_av_protokoll();
	exit_vwork();
	free_pfade(suji.search_pfade);
	mt_rsrc_free(&global);
	mt_appl_exit(&global);
	return 0;
}


