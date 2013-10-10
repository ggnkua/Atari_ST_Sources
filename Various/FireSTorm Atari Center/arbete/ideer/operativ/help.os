Hj„lp systemet „r uppbygt kring flera instruktioner i Operativsystemet som 
programmen skall anv„nda sig utav n„r man anv„nder Hj„lp-funktioner, det 
finns Manuella f”r Programmet och Automatisk hj„lp som man kan anv„nda sig 
utav.

Funktioner:

int help_register(char *help_file_name);
int help_open(char *entry);
int help_search(char *search_text);
int help_settings(int function, int value);

Int help_register(char *help_file_name);
  Detta kommando talar om f”r Operativsystemet att denna hj„lp-fil skall 
  anv„ndas n„r den automatiska hj„lpen anv„ndes. Operativsystemets normala 
  hj„lp-funktioner anv„ndes d†.
  F”r att hitta denna hj„lp fil s† letar operativsystemet f”rst och fr„mst i 
  applikationens s”kv„gh, sedan i Enviromentet HELP:s s”kv„g och under 
  bibliotek, och till siste s† letas det i enviromentet PATH:s s”kv„gar.
  Vid ett lyckat anrop s† returneras HELP_OK, annars s† returneras 
  HELP_FILE_NOT_FOUND.

int help_open(char *entry);
  Standard funktion f”r att ”ppna ett hj„lp-f”nster med _entry_ som 
  referens. Om det lyckas returneras HELP_OK, om det misslyckas kan flera 
  saker h„nda. Om hj„lp-filen inte kunde hittas returneras 
  HELP_COULD_NOT_OPEN_FILE, vid l„sfel i hj„lpfilen returneras 
  HELP_COULD_NOT_READ_FILE, och om inte entryt kunde hittas s† kan 1 av tv† 
  saker h„nda. 1- funktionen returnerar endast HELP_COULD_NOT_FIND_ENTRY, 
  eller s† returneras HELP_COULD_NOT_FIND_ENTRY och den automatiska 
  s”k-funktionen startas, med indata entryt.

int help_search(char *search_string);
  Standard funktion f”r att s”ka efter ord i hj„lp-filen/filerna
  Funktionen startar den automatiska s”kfunktionen, med search_text som 
  indata. vid fel returneras endera HELP_COULD_NOT_OPEN_FILE om det inte 
  gick att ”ppna filen, eller HELP_COULD_NOT_READ_FILE om det inte gick att 
  l„sa filen, om inte entry:t kunde hittas s† returneras 
  HELP_COULD_BOT_FIND_ENTRY.

int help_settings(int function, int value);
  Denna funktion st„ller in olika inst„llningar i de standardiserade 
  s”kfunktionerna
  function                 value
    HELP_AUTOMATIC_INDEX       TRUE/FALSE
      ™ppnar automatiskt INDEX entryt vid ett tryck p† HELP (Programmet 
      beh”ver inte bry sig om att implementera egna hj„lp-funktioner)
    HELP_AUTOMATIC_SEARCH      TRUE/FALSE
      G”r Automatiskt en help_search om inte _entryt_ kunde hittats vid en 
      help_open, g„ller „ven n„r HELP_AUTOMATIC_INDEX==TRUE och inget index 
      finns.
    HELP_AUTOMATIC_OBJECT      TRUE/FALSE
      ™ppnar automatiskt hj„lpf”nstret och letar efter namnet,p† det object 
      som musen befinner sig ovanf”r, i hj„lp-texten. Denna funktion bidrar 
      till snabb f”rklaring av vad vissa knappar utf”r. OBS endast object 
      med NAMN kommer denna funktion att utf”ras p†.
    HELP_AUTOMATIC_SHOW_OBJECT TRUE/FALSE
      N„r denna funktion „r p†slagen kommer det att automatiskt, efter en 
      tid av inaktivitet hos musen (inst„llbart), att visas en kort hj„lp 
      text om objectet att visas (baserat p† object-namnet).
    HELP_AUTOMATIC_SHOW_TIME   1-255
      Tiden av inaktivitet hos musen innan den enkla hj„lp-raden av text 
      visas om objektet.


hj„lp-filernas utseende.
