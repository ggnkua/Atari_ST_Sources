
 READ_ME.DOC zu GEM-Force
 ========================
 
 GEM-Force wurde geschrieben von:

 Ren‚ Rosendahl, Software-Entwicklung
 Kameruner Str. 107
 32791 Lage
 Tel. 05232/78916 (ab 17 Uhr)
 
 Die PD-Version von GEM-Force ist gegenber der Vollversion in ihrem Funktions-
 umfang eingeschr„nkt. Es k”nnen maximal 3 Fenster verwendet werden, w„hrend 
 benutzerdefinierte Objekt nur in den ersten 10 Objekt-B„umen, die mit 
 init_tree() initialisiert werden, untersttzt werden.
 Eine Vollversion mit Handbuch bekommen Sie, wenn Sie eine formatierte Leer-
 diskette, 3 DM in Briefmarken und einen Verrechnungscheck ber 49,- DM an oben 
 angegebene Adresse schicken.
 
 Erg„nzugen zum Handbuch
 -----------------------
 Wenn das Modul TOS genutzt werden soll, mssen die Libraries PCSTDLIB.LIB, 
 PCTOSLIB.LIB und PCEXTLIB.LIB gelinkt werden; fr die anderen beiden Module 
 drfte PCGEMLIB.LIB reichen.
 Sind Fenster nicht resident (Flag WI_RESIDENT), werden sie bei close_window 
 automatisch auch gel”scht (delete_window). Werden "normale" Fenster kreiert, 
 sind sie defaultm„ig noch nicht resident ! Textfenster dagegen sind bereits 
 nach dem Kreieren resident.
 
 