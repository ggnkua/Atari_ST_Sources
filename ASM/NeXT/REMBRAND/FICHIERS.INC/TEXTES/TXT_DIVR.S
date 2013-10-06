*
* D'abord, les bˆtes messages utilisant PRINT LINE...
*
 even
message_aes_absent
 dc.l .fran‡ais
 dc.l .anglais
 dc.l .allemand
.fran‡ais
 dc.b "Ep ATTENTION !!!!!!q",10,13
 dc.b " REMBRANDT est un programme GEM",10,13
 dc.b "(ou presque), l'AES doit donc",10,13
 dc.b "etre pr‚sent. Or, je suppute que",10,13
 dc.b "je doit etre dans le dossier AUTO !",10,13
 dc.b " Vous trouvez ca drole ???",10,13
 dc.b " LANCEZ MOI DU BUREAU !",10,13,0
.anglais
 dc.b "Ep WARNING !!!!!!q",10,13
 dc.b " REMBRANDT is a GEM application,",10,13
 dc.b "even if you think it isn't !",10,13
 dc.b "So, the AES must be active... ",10,13
 dc.b "Never install Rembrandt in the",10,13
 dc.b "AUTO folder !!!!",10,13
 dc.b "LAUNCH ME FROM THE DESKTOP !",10,13,0
.allemand
 dc.b "Ep ACHTUNG !!!!!!q",10,13
 dc.b " REMBRANDT ist ein GEM program,",10,13
 dc.b "even if you think it isn't !",10,13
 dc.b "So, the AES must be activ... ",10,13
 dc.b "Never install Rembrandt in the",10,13
 dc.b "AUTO folder !!!!",10,13
 dc.b "LAUNCH ME FROM THE DESKTOP !",10,13,0


 even
message_trop_programmes
 dc.l .fran‡ais
 dc.l .anglais
 dc.l .allemand
.fran‡ais
 dc.b "Ep ATTENTION !!!!!!q",10,13
 dc.b "Il y a trop d'applications actives.",10,13
 dc.b "Impossible de lancer REMBRANDT",10,13,0
.anglais
 dc.b "Ep WARNING !!!!!!q",10,13
 dc.b "System can't launch another",10,13
 dc.b "application. Sorry",10,13,0
.allemand
 dc.b "Ep ACHTUNG !!!!!!q",10,13
 dc.b "System can't launch another",10,13
 dc.b "application. Sorry",10,13,0





*
* Toutes les boites d'alerte pour le programme
*
* Le chiffre entre crochets indique le num‚ro du pictograme affich‚e:
* [0]	-> Pas de dessin
* [1]	-> Point d'exclamation		(!)
* [2]	-> Point d'interrogation	(?)
* [3]	-> Panneau stop			(STOP)
*
 even
alert_fin_programme
 dc.l .fran‡ais
 dc.l .anglais
 dc.l .allemand
.fran‡ais
 dc.b "[2][D‚sirez vous vraiment|quitter le programme ?]"
 dc.b "[Quitter|Retourner]",0
.anglais
 dc.b "[2][Do you really want to|quit Rembrandt ?]"
 dc.b "[Quit|Continue]",0
.allemand
 dc.b "[2][Vollen sie diese|program verlassen ?]"
 dc.b "[Ja|Nein]",0


 even 
alert_aide_demand‚e
 dc.l .fran‡ais
 dc.l .anglais
 dc.l .allemand
.fran‡ais
 dc.b "[3][L'aide en ligne n'est|"
 dc.b "pas encore disponible.|"
 dc.b "D‚sol‚ !]"
 dc.b "[Retourner]",0
.anglais
 dc.b "[3][The On-line HELP isn't|"
 dc.b "yet implemented.|"
 dc.b "Sorry !]"
 dc.b "[Return]",0
.allemand
 dc.b "[3][Hilfe nicht possible.]"
 dc.b "[Arg]",0
 

 even
alert_m‚moire_insuffisante
 dc.l .fran‡ais
 dc.l .anglais
 dc.l .allemand
.fran‡ais
 dc.b "[3][Il n'y a pas assez de m‚moire|"
 dc.b "pour lancer Rembrandt. Faites de|"
 dc.b "la place, ou achetez une|"
 dc.b "extension.]"
 dc.b "[Termin‚]",0
.anglais
 dc.b "[3][There isn't enough room|"
 dc.b "for running Rembrandt. Buy an|"
 dc.b "expension board, or delete some|"
 dc.b "accessories and residents.]"
 dc.b "[Terminated]",0
.allemand
 dc.b "[3][Speicher ist voll.]"
 dc.b "[Abbruch]",0
 

 even 
alert_image_pas_sauv‚e
 dc.l .fran‡ais
 dc.l .anglais
 dc.l .allemand
.fran‡ais
 dc.b "[2][Vous n'avez pas sauv‚ votre|"
 dc.b "image. Les modifications seront|"
 dc.b "perdues ! Confirmez vous le|"
 dc.b "chargement d'une nouvelle image ?]"
 dc.b "[Confirmer|Annuler]",0
.anglais
 dc.b "[2][You haven't saved your picture|"
 dc.b "Click on CONTINUE if you want|"
 dc.b "loosing the modifications.]"
 dc.b "[Continue|Cancel]",0
.allemand
 dc.b "[2][Achtung, achtung ! Das Bild|"
 dc.b "war nicht sichern... Alles arbeit|"
 dc.b "werden erasiert !.]"
 dc.b "[Ok|Abbruch]",0
  

 even
alert_fin_programme_sauve
 dc.l .fran‡ais
 dc.l .anglais
 dc.l .allemand
.fran‡ais
 dc.b "[2][L'image en cours a ‚t‚ modifi‚e|"
 dc.b "depuis la derniŠre sauvegarde|"
 dc.b "Si vous quitter, l'image sera perdue.|"
 dc.b "Confirmez vous ce choix ?]"
 dc.b "[Quitter|Retourner|Sauver]",0
.anglais
 dc.b "[2][The current picture has been|"
 dc.b "modified since the last saving.|"
 dc.b "Are you sure ?]"
 dc.b "[Quit|Return|Save]",0
.allemand
 dc.b "[2][Diese Bild war nicht sichern.]"
 dc.b "[Ende|Arf|Sichern]",0


 even
alert_efface_image
 dc.l .fran‡ais
 dc.l .anglais
 dc.l .allemand
.fran‡ais
 dc.b "[2][Vous n'avez pas sauv‚ votre|"
 dc.b "image. Les modifications seront|"
 dc.b "perdues ! Confirmez vous|"
 dc.b "l'effacement de cette image ?]"
 dc.b "[Confirmer|Annuler]",0
.anglais
 dc.b "[2][The current picture has been|"
 dc.b "modified since the last saving.|"
 dc.b "Are you sure of deleting ?]"
 dc.b "[Ok|Cancel]",0
.allemand
 dc.b "[2][The current picture has been|"
 dc.b "modified since the last saving.|"
 dc.b "Are you sure of deleting ?]"
 dc.b "[Ok|Abbruch]",0


 even
alert_multitos_pr‚sent
 dc.l .fran‡ais
 dc.l .anglais
 dc.l .allemand
.fran‡ais
 dc.b "[3][Il n'est pas possible de|"
 dc.b "proceder … un changement de|"
 dc.b "r‚solution lorsque MULTITOS|"
 dc.b "est activ‚.]"
 dc.b "[Annuler]",0
.anglais
 dc.b "[3][Displaying the picture|"
 dc.b "isn't possible under MULTITOS.]"
 dc.b "[Cancel]",0
.allemand
 dc.b "[3][Displaying the picture|"
 dc.b "isn't possible under MULTITOS.]"
 dc.b "[Abbruch]",0


 even 
alert_moniteur_monochrome
 dc.l .fran‡ais
 dc.l .anglais
 dc.l .allemand
.fran‡ais
 dc.b "[1][Il n'est malheureusement|"
 dc.b "pas possible d'afficher une|"
 dc.b "image TrueColor sur un|"
 dc.b "moniteur monochrome !]"
 dc.b "[Annuler]",0
.anglais
 dc.b "[1][Displaying a True Color|"
 dc.b "picture on a monochrom|"
 dc.b "monitor is impossible !]"
 dc.b "[Cancel]",0
.allemand
 dc.b "[1][Displaying a True Color|"
 dc.b "picture on a monochrom|"
 dc.b "monitor is impossible !]"
 dc.b "[Abbruch]",0


 even
alert_sauve_param‚trage      
 dc.l .fran‡ais
 dc.l .anglais
 dc.l .allemand
.fran‡ais
 dc.b "[1][Erreur durant la sauvegarde|"
 dc.b "du fichier de param‚trage.|"
 dc.b "Sauvegarde annul‚e.]"
 dc.b "[Annuler]",0
.anglais
 dc.b "[1][Error while saving the|"
 dc.b "configuration file.]"
 dc.b "[Cancel]",0
.allemand
 dc.b "[1][Error while saving the|"
 dc.b "configuration file.]"
 dc.b "[Abbruch]",0


 even
alert_charge_param‚trage      
 dc.l .fran‡ais
 dc.l .anglais
 dc.l .allemand
.fran‡ais
 dc.b "[1][Erreur durant le chargement|"
 dc.b "du fichier de param‚trage.|"
 dc.b "Chargement annul‚.]"
 dc.b "[Annuler]",0
.anglais
 dc.b "[1][Error while loading the|"
 dc.b "configuration file."
 dc.b "[Cancel]",0
.allemand
 dc.b "[1][Error while loading the|"
 dc.b "configuration file."
 dc.b "[Abbruch]",0


 even
alert_reglage_image
 dc.l .fran‡ais
 dc.l .anglais
 dc.l .allemand
.fran‡ais
 dc.b "[2][L'image en cours a ‚t‚ modifi‚e|"
 dc.b "depuis la derniŠre sauvegarde|"
 dc.b "ce r‚glage va l'effacer...|"
 dc.b "Confirmez vous ce choix ?]"
 dc.b "[Confirmer|Annuler|Sauver]",0
.anglais
 dc.b "[2][The current picture had been|"
 dc.b "modified since the last saving.|"
 dc.b "It would be unrecoverable !]"
 dc.b "[Ok|Cancel|Save]",0
.allemand
 dc.b "[2][The current picture had been|"
 dc.b "modified since the last saving.|"
 dc.b "It would be unrecoverable !]"
 dc.b "[Ja|Abbruch|Sichern]",0


 even 
alert_image_invalide
 dc.l .fran‡ais
 dc.l .anglais
 dc.l .allemand
.fran‡ais
 dc.b "[1][Impossible de travailler|"
 dc.b "avec une image de cette taille.|"
 dc.b "Il n'y a plus asser de m‚moire]"
 dc.b "[Annuler]",0
.anglais
 dc.b "[1][It's impossible to work|"
 dc.b "with such a big picture.|"
 dc.b "Memory is full.]"
 dc.b "[Cancel]",0
.allemand
 dc.b "[1][It's impossible to work|"
 dc.b "with such a big picture.|"
 dc.b "Memory is full.]"
 dc.b "[Abbruch]",0


 even 
alert_dessiner_impossible
 dc.l .fran‡ais
 dc.l .anglais
 dc.l .allemand
.fran‡ais
 dc.b "[1][Il n'y a plus asser de m‚moire|"
 dc.b "pour travailler. R‚duisez la|"
 dc.b "taille de l'image ou bien|"
 dc.b "supprimez des accessoires...]"
 dc.b "[Annuler]",0
.anglais
 dc.b "[1][There isn't enough memory|"
 dc.b "for working. Reduce picture size|"
 dc.b "or remove some accessories...]"
 dc.b "[Cancel]",0
.allemand
 dc.b "[1][There isn't enough memory|"
 dc.b "for working. Reduce picture size|"
 dc.b "or remove some accessories...]"
 dc.b "[Abbruch]",0


 even
alert_non_cod‚
 dc.l .fran‡ais
 dc.l .anglais
 dc.l .allemand
.fran‡ais
 dc.b "[1][D‚sol‚, mais cette fonction|"
 dc.b "n'a pas encore ‚t‚ cod‚e.|"
 dc.b "Peut-etre dans une version|"
 dc.b "future ??? D‚sol‚ !]"
 dc.b "[Annuler]",0
.anglais
 dc.b "[1][Function hasn't been|"
 dc.b "implemented yet.]"
 dc.b "[Cancel]",0
.allemand
 dc.b "[1][Function hasn't been|"
 dc.b "implemented yet.]"
 dc.b "[Abbruch]",0



************** Messages d'erreur concernant le DSP

 even
alert_dsp_absent
 dc.l .fran‡ais
 dc.l .anglais
 dc.l .allemand
.fran‡ais
 dc.b "[1][Erreur avec DSP_LOCK:|"
 dc.b "Le DSP n'est pas accessible.|"
 dc.b "Il est mpossible de dessiner.]"
 dc.b "[Annuler]",0
.anglais
 dc.b "[1][DSP_LOCK error:|"
 dc.b "DSP isn't available.|"
 dc.b "Drawing is impossible.]"
 dc.b "[Cancel]",0
.allemand
 dc.b "[1][DSP_LOCK felher:|"
 dc.b "DSP isnt nicht ihr.|"
 dc.b "Zeichnen nicht possible.]"
 dc.b "[Abbruch]",0

 even
alert_dsp_occup‚
 dc.l .fran‡ais
 dc.l .anglais
 dc.l .allemand
.fran‡ais
 dc.b "[1][Le DSP est d‚ja utilis‚|"
 dc.b "par une autre application.|"
 dc.b "Veuillez le lib‚rer, SVP.]"
 dc.b "[Annuler]",0
.anglais
 dc.b "[1][DSP is already used by|"
 dc.b "another application.|"
 dc.b "You must free it.]"
 dc.b "[Cancel]",0
.allemand
 dc.b "[1][DSP ist arbeiten.|"
 dc.b "Ich will die DSP !!!.]"
 dc.b "[Abbruch]",0

 
 
titre_fenetre dc.b ' REMBRANDT 3.06á ',0


*********************** Les messages pour le s‚lecteur d'outils ******

str_crayon_dessin		dc.b "CRAYON",0

str_rŠgle_ligne			dc.b "SEGMENT",0
str_rŠgle_kligne		dc.b "CONTOUR",0
str_rŠgle_rayon			dc.b "RAYON",0

str_peinture_remplissage	dc.b "PEINTURE",0

str_compas_cercle		dc.b "CERCLE",0
str_compas_disque		dc.b "DISQUE",0

str_equerre_cadre		dc.b "CADRE",0
str_equerre_boite		dc.b "BOITE",0

str_a‚rosol_spray_1		dc.b "AEROSOL1",0
str_a‚rosol_spray_2		dc.b "AEROSOL2",0

***************** On ‚crit rien derriere cela !
 even
