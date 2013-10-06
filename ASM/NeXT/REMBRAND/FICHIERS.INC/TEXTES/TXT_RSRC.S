; REMBRANDT 3.0 - Ω  Dbug II
;
; Chaines de caractäre pour la ressource.
;
; 0-> Franáais
; 1-> Anglais
; 2-> Allemand
; 3-> Espagnol
; 4-> Italien
;
; Structure des textes:
; .L Adresse du pointeur sur le formulaire
;    .W NumÇro de l'objet*24
;    .B Chaine de caractäres en Franáais +0
;    .B Chaine de caractäres en Anglais +0
;    .B Chaine de caractäres en Allemand +0
;    .B 0
; .W -1

 even
convertir_ressources
;
; Le formulaire principal dans la fenàtre
;
 dc.l ptr_page_principale

 dc.w objet_charger_fichier*24
 dc.b "CHARGER IMAGE",0
 dc.b "LOAD PICTURE",0
 dc.b "LADEN BILD",0
 dc.b 0

 dc.w objet_sauver_fichier*24
 dc.b "SAUVER IMAGE",0
 dc.b "SAVE PICTURE",0
 dc.b "SICHERN BILD",0
 dc.b 0

 
 dc.w objet_effacer_image*24
 dc.b "EFFACER",0
 dc.b "DELETE",0
 dc.b "DELETE",0
 dc.b 0
 
 dc.w objet_reglage_image*24
 dc.b "RêSOLUTION",0
 dc.b "VIDEO",0
 dc.b "VIDEO",0
 dc.b 0
 
 dc.w objet_infos_image*24
 dc.b "INFOS",0
 dc.b "INFOS",0
 dc.b "INFOS",0
 dc.b 0

 dc.w objet_charger_par_type*24
 dc.b "CHARGER COMME",0
 dc.b "LOADING AS",0
 dc.b "LADEN ALS",0
 dc.b 0
 
 dc.w objet_dessiner*24
 dc.b "DESSINER",0
 dc.b "DRAWING",0
 dc.b "ZEICHNEN",0
 dc.b 0

 dc.w -1

 
;
; La barre des menus dÇroulants
; 
 dc.l ptr_menu_accessoires

 dc.w objet_menu_a_propos_de*24
 dc.b " A propos de Rembrandt...",0
 dc.b " About Rembrandt...",0
 dc.b " Das ist Rembrandt...",0
 dc.b 0
 
 dc.w objet_titre_fichier*24
 dc.b " Fichier",0
 dc.b "  Files",0
 dc.b "  Disk",0
 dc.b 0

 dc.w objet_menu_charger*24
 dc.b " Charger image       C",0
 dc.b " Load picture        C",0
 dc.b " Laden Bild          C",0
 dc.b 0

 dc.w objet_menu_charger_com*24
 dc.b " Charger comme      C",0
 dc.b " Load picture as    C",0
 dc.b " Laden Bild als     C",0
 dc.b 0

 dc.w objet_menu_sauver*24
 dc.b " Sauver image        S",0
 dc.b " Save picture        S",0
 dc.b " Sichern Bild        S",0
 dc.b 0

 dc.w objet_menu_sauver_sous*24
 dc.b " Sauver comme       S",0
 dc.b " Save picture as    S",0
 dc.b " Sichern Bild als   S",0
 dc.b 0

 dc.w objet_menu_quitter*24
 dc.b " Quitter             Q",0
 dc.b " Quit                Q",0
 dc.b " Ende                Q",0
 dc.b 0

 dc.w objet_titre_reglage*24
 dc.b " RÇglage",0
 dc.b " Set-up",0
 dc.b " Set-up",0
 dc.b 0
 
 dc.w objet_menu_preferences*24
 dc.b " PrÇfÇrences   P",0
 dc.b " Preferences   P",0
 dc.b " Preferences   P",0
 dc.b 0
 
; dc.w objet_menu_langage*24
; dc.b " Langue          ",0
; dc.b " Language        ",0
; dc.b " Sprache         ",0
; dc.b 0
 
 dc.w objet_menu_sauve_prefs*24
 dc.b " Sauvegarder",0
 dc.b " Saving",0
 dc.b " Sichern",0
 dc.b 0

 dc.w -1
 

;
; La boite avec le titre Rembrandt 3.0x
;   
 dc.l ptr_infos
 
 dc.w objet_quitte_infos*24
 dc.b "RETOUR AU MENU",0
 dc.b "BACK TO MENU",0
 dc.b "ENDE",0
 dc.b 0
 
 dc.w objet_plus_infos*24
 dc.b "PLUS D'INFO",0
 dc.b "MORE INFOS",0
 dc.b "MEHRE...",0
 dc.b 0
 
 dc.w objet_copyright_infos*24
 dc.b "Ω  NeXT (tous droits rÇservÇs)",0
 dc.b "Ω  NeXT (all rights reserved)",0
 dc.b "Ω  NeXT (alles richtung...)",0
 dc.b 0  
 
 dc.w -1 
 dc.l 0				Fin de la structure
