/*-------------------------------------------------------------------*/
/* Fonction Coeur des applications                                   */
/*-------------------------------------------------------------------*/
#include <ldg.h>

#include "type_gcc.h"

#include "coeur_define.h"
#include "coeur_type.h"
#include "coeur_prototypes.h"
#include "coeur_variables.h"

#include "fcm_cookie_definition.h"
#include "../protocole/av.h"
#include "../include/nvdi.h"
#include "../pci/pcixbios.h"
#include "../graphique/pixel_format_id.h"


#include "fcm_log_print.h"

#ifdef LOG_FILE
  #include "fcm_log_print.c"
#endif

//#ifdef FCM_CONSOLE_COEUR
 #include "console/fcm_console.c"
//#endif


#include "fcm_affiche_alerte.c"
#include "fcm_analyse_raccourci_gem.c"

#include "fcm_bload.c"

#include "fcm_charger_config.c"
#include "fcm_charge_rsc.c"
#include "fcm_check_rsc_alerte.c"
//#include "fcm_conversion_ascii_to_long.c"
#include "fcm_cookies_exist.c"

#include "fcm_dir_exist.c"

#include "fcm_eddi_version.c"

#include "fcm_fermer_fenetre.c"
#include "fcm_file_exist.c"
#include "fcm_file_size.c"
#include "fcm_fprint.c"


#include "fcm_gestion_message.c"
#include "fcm_gestion_souris.c"
#include "fcm_gestion_clavier.c"
#include "fcm_gestion_barre_menu.c"

#include "fcm_gestion_va_start.c"
#include "fcm_gestion_perte_ldg.c"
#include "fcm_gestion_uniconify.c"
#include "fcm_gestion_iconify.c"
#include "fcm_gestion_shaded.c"
#include "fcm_gestion_topped.c"
#include "fcm_gestion_untopped.c"
#include "fcm_gestion_ontop.c"
#include "fcm_gestion_bottom.c"
#include "fcm_gestion_moved.c"
#include "fcm_gestion_redraw_fenetre.c"
#include "fcm_gestion_sized.c"
#include "fcm_gestion_widgets.c"

#include "fcm_gestion_bit_objet.c"
#include "fcm_gestion_objet_bouton.c"
#include "fcm_gestion_app_arg.c"
#include "fcm_gestion_aes.c"
#include "fcm_gestion_fenetre_info.c"
#include "fcm_gestion_fenetre_preference.c"
#include "fcm_gestion_fermeture_fenetre.c"
#include "fcm_gestion_fermeture_programme.c"
#include "fcm_gestion_preference_langue.c"
/*#include "fcm_gestion_erreur_config.c"*/
#include "fcm_gestion_pop_up.c"

#include "fcm_get_chemin_home.c"
#include "fcm_get_cookies.c"
//#include "fcm_get_cookies_table.c"
#include "fcm_get_indexwindow.c"
#include "fcm_get_screen_info.c"
#include "fcm_get_machine_info.c"
#include "Fcm_get_objet_parent.c"

#include "fcm_get_tag_config_generale.c"
//#include "fcm_get_tag.c"
#include "fcm_get_tag_booleen.c"
#include "fcm_get_tag_int32.c"
#include "fcm_get_tag_string.c"

#include "fcm_get_timer.c"
#include "fcm_get_tos_version.c"
#include "fcm_get_shel_envrn.c"
#include "fcm_get_win_parametre.c"

#include "Fcm_get_rsrc_gaddr_rtree.c"

#include "fcm_init_coeur_application.c"
#include "fcm_init_environnement.c"
#include "fcm_init_aes_vdi.c"
#include "fcm_init_win_parametre.c"
#include "fcm_init_rsc_info.c"
#include "fcm_init_prog.c"
#include "fcm_is_my_win_ontop.c"

#include "fcm_libere_rsc.c"
#include "fcm_libere_aes_vdi.c"
#include "fcm_libere_ram.c"

#include "fcm_menu_tnormal.c"
#include "fcm_my_menu_bar.c"
#include "fcm_mouse_no_bouton.c"

#include "fcm_objet_change.c"
#include "fcm_objet_draw.c"
#include "fcm_ouvre_fenetre_start.c"
#include "fcm_ouvre_fenetre.c"

/*#include "fcm_point_in_area.c"*/
#include "fcm_purge_clavier.c"
//#include "fcm_purge_redraw.c"
#include "fcm_purge_aes_message.c"

#include "fcm_redraw_fenetre.c"
#include "fcm_rescale_bar_menu.c"
#include "fcm_rescale_fenetre_info.c"
#include "fcm_rescale_fenetre_preference.c"
#include "fcm_reserve_ram.c"

#include "fcm_sauver_config.c"
#include "fcm_save_config_generale.c"
#include "fcm_set_rsc_string.c"
#include "fcm_set_rsc_string_int32.c"
#include "fcm_set_config_generale.c"
#include "fcm_set_win_position.c"

#include "fcm_win_form_alert.c"





