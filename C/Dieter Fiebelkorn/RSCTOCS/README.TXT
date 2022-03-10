



                 D E R   R E S O U R C E - T O - C - W A N D L E R
                 =================================================



                                        von

                                 Dieter Fiebelkorn
                                  Grner Weg  29a
                              4370 Marl 1  (Brassert)

                       (Entwickelt mit dem Turbo-C Compiler)
                    (Idee und die rsrc_load-Routine entstammen
                    der ST-Computer Dezember '87 Seite 129 f.)


                            >>>>  PUBLIC - DOMAIN  <<<<





 Dieses Programm wird vielleicht vielen C Programmierer helfen mit Resourcen
 zu arbeiten.
 
 So kann zum Beispiel ein Programm entwickelt werden, daž ganz auf
 externe Resourcen verzichten kann.
 Dazu werden einfach die Resoucen mit diesem Wandler geladen und auf
 Wunsch bearbeitet und abgespeichert. Das gespeicherte File hat die
 Form einer C-Source, die lediglich compiliert und zu dem eigentlichen
 Programm hinzugelinkt werden muž. Das Hauptprogramm muž nicht abge„ndert
 werden, da der Aufruf der rsrc_load und "rsrc_free" - Routine 
 syntaktisch mit den Betriebssystemfunktionen bereinstimmt.

 Eine andere M”glichkeit besteht darin die "#include" - Anweisungen
 der erzeugten Source zu entfernen und die Source selbst als Include-
 File fr das Hauptprogramm zu benutzen.

 Weiterhin wird nach dem Laden der Resource eine Kurzinformation der
 Resource angezeigt, es ist der sogenannte Resource-Header.

 
 ACHTUNG  : FALLS EIN EDITOBJEKT GLEICHZEITIG AUCH DAS LASTOBJEKT EINES
 =======    BAUMES IST KOMMT DAS BETRIEBSSYSTEM DURCHEINANDER.
            ES IST DANN M™GLICH DIE EDITIERFELDER DES IM SPEICHER FOLGENDEN
            BAUMES ZU BENUTZEN.
            NACH ABSCHLUž DER EDITIERARBEITEN KANN ES ZUM ABSTURZ KOMMEN
            FALLS DIESE UNERLAUBTEN EDITIERFELDER BENUTZT WURDEN.
            DA DIE RESOURCE-CONSTRUCTION-SET'S DIESEN UMSTAND SCHEINBAR NICHT
            BEACHTEN EMPFIEHLT ES SICH IN DER C-SOURCE EINE UMGRUPPIERUNG DER
            OBJEKTE VORZUNEHMEN. (VORAUSSETZUNG IST, DAž SIE šBER DEN GENAUEN
            AUFBAU EINES OBJEKTBAUMES BESCHEID WISSEN.
            UND VERGESSEN SIE NICHT EVTL. DIE '*.H'-DATEI ZU ŽNDERN ODER BEI
            ERGŽNZUNGEN UND EINFšGUNGEN DIE "BAUMADRESSEN" ABZUŽNDERN
            'rs_trindex' !!!)
            




 ACHTUNG : "FREE_IMAGES" und "FREE_STRINGS" werden nicht untersttzt !




 
 Noch zwei Tips:
     1. Wollen Sie eine interne und externe Resource benutzen, so benennen
        Sie die Routinen der erzeugten Source um z.B. in r_load bzw. r_free
        und sichern Sie die evtl. schon bestehende Resource.


            extern int     global[];
            static int     rsrcload_flag = 0;
            static int     rsrcsave_flag = 0;               <<-- Einfgen
            static OBJECT  rsc_save;                        <<-- Einfgen



            T0OBJ = 12;
            :
            :

            /*        ========= Resource-Load-Segment =========          */

            int r_load (RscFile)
            char *RscFile;
            {
            int         dx,
                        dy,
                        Obj;

            OBJECT  **GEM_rsc;

            GEM_rsc = (OBJECT **) &global[5];
            if (rsrcsave_flag == 0)                             <<-- Einfgen
            {                                                   <<-- Einfgen
                rsc_save = *GEM_rsc;                            <<-- Einfgen
                rsrcsave_flag = 1;                              <<-- Einfgen
            }                                                   <<-- Einfgen
            *GEM_rsc = (OBJECT *) &rs_trindex[0];
 
            if (rsrcload_flag == 0)
            {
            :
            :
            }
        }

        int r_free ()
        {
            OBJECT  **GEM_rsc;

            if (rsrcsave_flag == 1)                             <<-- Einfgen
            {                                                   <<-- Einfgen
                GEM_rsc = (OBJECT **) &global[5];               <<-- Einfgen
                *GEM_rsc = rsc_save;                            <<-- Einfgen
                rsrcsave_flag = 0;                              <<-- Einfgen
            }                                                   <<-- Einfgen
            return(1);
        }



     2. Wollen Sie jedoch zwei interne Resource benutzen, so mssen Sie 
        zus„tzlich die Variablen einer "Resource" umbenennen.




 Ich wnsche viel Spaž mit dem

                      RESOURCE-TO-C-WANDLER


                                                        D I E T E R






 P.S.   : Wie schon angefhrt entstannt die Idee dieses Wandles beim Lesen
          des Artikels der aus des ST-Computer die rsrc_load - Routine wurde
          diesem Artikel entnommen und fr dieses Programm in geeigneter
          Weise modifiziert und in ein, wie ich glaube, sinnvolles Programm
          integriert.

          Ich hoffe auf Verst„ndnis bei dem Autoren dieses Artikel und beim
          Heim-Verlag.


 P.P.S. : Fr Angabe von Fehlern in diesem Programm und Verbesserungs-
          vorschl„gen w„re ich sehr dankbar.
            (Bei Fehlern bitte eine m”glichst genaue Beschreibung des
             Vorganges der zu dem Fehler fhrte)





~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                              Vorliegende Dateien
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    - RSC_TO_C.PRG  : "Das Programm ! "
    - README.TXT    : "Schon gelesen. (hoffe ich jedenfalls)"

