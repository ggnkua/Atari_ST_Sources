                    W a s   i s t   d b _ c a l c  ?
                    ================================

Es  ist ein kleines Zeilenkommando-Programm zur Umrechnung von  Verst„r-
kungs-  oder D„mpfungsfaktoren in Dezibelwerte und  umgekehrt.  Eingeben 
muss man also entweder das Zahlenverhaeltnis

     z.B.           1)   db_calc 1200

oder den Dezibelwert

     z.B.           2)   db_calc 48.7 db


Berechnet  werden jeweils die Werte fuer Spannungen,  bzw.  Stroeme  und 
Leistung. Im vorliegenden Beispiel ergeben sich die Werte:

                    1)    61.58  dB  (Spannungs- oder Strom-dB-Mass)
                          30.79  dB  (Leistungs-dB-Mass)

                    2)   272.2701    (Spannungs- oder Stromfaktor)
                          74.1310 K  (Leistungsfaktor)

                         Die Ausgabe erfolgt zwecks besserer Ueber-
                         sichtlichkeit mit Groessenordnungssymbolen:
                              T    =    Tera   (1'000'000'000'000)
                              G    =    Giga   (    1'000'000'000)
                              M    =    Mega   (        1'000'000)
                              K    =    Kilo   (            1'000)
                              m    =    Milli  (0.001)
                              u    =    Micro  (0.000'001)
                              n    =    Nano   (0.000'000'001)
                              p    =    Pico   (0.000'000'000'001)


Bloede Eingaben und die ?-Eingabe
---------------------------------
Wenn man Parametermist oder gar keinen eingibt,  wird dies  beanstandet. 
Es wird aber auch gezeigt,  wie man's richtig macht.  Uebergibt man  als 
Parameter ein Fragezeichen, gibt's ein paar weitere Kurzinfos.


Warum ein Zeilenkommando- und kein GEM-Programm?
------------------------------------------------
Es  ist  heute  ueblich geworden jedes kleine Programm  gleich  in  eine 
graphische  Benutzershell zu verpacken.  Manchmal viel farbige Show  und 
wenig Nutzen.  In der Praxis zeigt sich jedoch,  dass dies sich nur fuer 
Programme lohnt,  bei denen aufwendige Ein- und Ausgaben notwendig  sind 
oder man fuer weitere Rechenvorgaenge im Programm bleiben muss.  Zeilen-
kommandoprogramme haben den Vorteil,  dass man die Eingaben gleich  beim 
Start als Parameter uebergeben kann und die Ausgabe, wenn erwuenscht, in 
eine  Textdatei  umgeleitet  oder mittels  Pipefunktion  einem  weiteren 
Programm zugewiesen werden kann.  Dies setzt allerdings praktischerweise 
voaraus, dass man eine UNIX-aehnliche Umgebung besitzt.

     Beispiel fuer Redirekt:       db_calc -36.8 dB > wert.txt

     Beispiel fuer Pipe:           db_calc 0.06 | programm

Arbeitet man mit einem Multitaskingsystem, wie z.B. MAGIC auf dem ATARI, 
ist es sowieso problemlos,  waehrend man ganz anderes tut,  ein  solches 
Zeilenkommandoprogramm rasch in einem freien Fenster ablaufen zu lassen. 
Benutzt  man keine Zeilenkommandoshell,  sollte die Extension  des  Pro-
grammes  die  Bezeichnung TTP (TOS Takes Parameter)  haben,  damit  beim 
Start  des  'db_calc' ein Fenster fuer die Eingabe der  Werte  geoeffnet 
wird.  Da diese Methode aber ATARI-Steinzeit ist,  erwaehne ich dies nur 
vollstaendigkeitshalber.


Portierbarkeit
--------------
'db_calc' wurde auf dem ATARI-ST mittels TURBO-2.0-C in C  programmiert. 
Da  der Quelltext keine ATARI-spezifischen Kommandos und  Zugriffe  auf-
weist,  ist es leicht 'db_calc' auf andere Computersysteme zu portieren. 
Dies duerfte sowieso fuer die meisten Elektronikern unter den ATARIanern 
wichtig sein,  das sie sowieso laengst eine Systemerweiterung ueber sich 
ergehen lassen mussten....


Status des 'db_calc'
--------------------
'db_calc'  steht  inklusive  Quelltext jedermann  frei  zur  Verfuegung. 
Weitergeben   muss  man  stets  alles,   also   lauffaehiges   Programm, 
(veraenderter)  C-Quelltext und dieses (erweiterte)  Minimalistenmanual. 
Rechte  gibt es selbstverstaendlich keine.  Wenn es jemand  schafft  mit 
diesem Programm seinen Computer explodieren zu lassen, dann ist das ganz 
alleine seine Angelegenheit. :-)


Feedback
--------
Wenn  jemand in den Besitz dieses Prograemmchen geraet,  -  was  mittels 
FTP-Server  oder  durch den PD-Pool der ATARI-Sektion  des  Computerclub 
Elmshorn ganz leicht geschehen kann -, wuerde es mich freuen irgendetwas 
zu  lesen.  Sei es eine kurze E-Mail oder eine Postkarte aus der  Gegend 
des Users.  Bitte keine Esswaren schicken, da diese den Transport in der 
Regel nicht ueberstehen.  Jemand der mir mal hessischen Handkaes schick-
te, warf sein Geld zum Fenster raus. Hatte der gestunken....  :-)))))


Zugriffsadressen
----------------
Wohn-Adresse:            Thomas Schaerer
                         Im Lindenhof 6
                         CH - 8307 Effretikon 
                         (Schweiz)

E-Mail-Adresse:          schaerer@isi.ee.ethz.ch


ts / April-1996          (Nein, 'db_calc' ist kein Aprilscherz!)

