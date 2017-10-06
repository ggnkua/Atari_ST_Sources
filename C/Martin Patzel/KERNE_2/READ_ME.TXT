========================================================================
=== Hallo Fans  ========================================================
========================================================================
Der Krieg der Kerne ist ein Spiel, bei dem zwei Programme gegeneinander
kaempfen. Die Programme werden von den Mitspielern erstellt, von
unserem Programm uebersetzt und dann gegeneinander laufen gelassen.
Der Krieg der Kerne ist ein Programmierspiel, das nichts mit den all-
seits beliebten Baller- und Adventurespielen zu tun hat. Es aehnelt
einem Assembler mit einem auf 10 Befehle reduzierten Befehlssatz. Mehr
allgemeine Informationen zum Spiel finden sich in dem Artikel "Der
Krieg der Kerne" im ST-Computer-Magazin 11/87. Der Artikel wurde
fuer die erste Version des Kriegs der Kerne geschrieben, weshalb 
es einige Abweichungen zur Version 2.1 in der Syntax gibt.
(-> 'Was hat sich veraendert)

Die Version 2.1 der Kerne wurde entsprechend den Core War Standards
programmiert. Die Syntax wird im SYNTAX.TXT erlaeutert.  
 
Die Programmbefehle und ihre Funktion werden im  PROGRAMM.TXT er-
klaert.

Im BEISPIEL.TXT befindet sich eine ausfuehrliche Beschreibung einiger
Krieg der Kerne Programme.

Beim EDITOR.TXT handelt es sich um das KURZDOC.TXT FILE des 
PD-Editors EDI.PRG.



========================================================================
=== Was hat sich geaendert =============================================
========================================================================

- Die Syntax entspricht den Core-War-Standards

- Der SPL-Befehl wurde implementiert

- Der CMP-Befehl prueft jetzt auf Gleichheit, anstatt Ungleichheit

- bei unmittelbarer Adressierung werden nur die letzten 4 Bytes
  eines Speicherplatzes ueberschrieben

- Labels erleichtern jetzt die Programmierung

- Ein zusaetzliches Window, das den Speicher grafisch darstellt,
  kann geoeffnet werden

- Es gibt drei Modi - Einzelschritt,Einzelspieler,feste Adresse -, 
  die die Programmentwicklung vereinfachen


Veraenderungen gegenueber der Version 2.0:

- Der SPL-Befehl benutzt jetzt das B-Feld

- Die Probleme die der Abarbeitung auftraten, wenn mehr als 5957
  Speicherplaetze eingestellt wurden, sind behoben. 


========================================================================
=== Folgende Files gehoeren zur Version 2.1 ============================
========================================================================

Im Ordner KERNE_2:

  EDITOR.PRG      29250     
  KERNE.PRG       32773     
  KERNE.RSC        5750     
  BEISPIEL.TXT    11374     
  EDITOR.TXT       2112     
  PROGRAMM.TXT     9151     
  READ_ME.TXT      9144     
  SYNTAX.TXT      18172     


Im Ordner PROG.RED:

  COMMANDO.RED      174     
  FACTA.RED         158     
  KNIRPS.RED         22     
  MICE.RED          200     
  MIDGET.RED        109     
  MINID.RED          52     
  NOTHING.RED        36     
  PARASITE.RED      139     
  ZWILLING.RED      315     
  BENCH.RED        3848     
  COMMAND1.RED      333     
  CHANG1.RED        234     
  LOCUST.RED        149



========================================================================
=== Was, weshalb, warum? ===============================================
========================================================================
Der Krieg der Kerne ist ein computerspezifisches Spiel, d.h., die Aus-
fuehrung des Spiels ist nur mit Hilfe eines Computers sinnvoll moeglich.
Natuerlich ist es auch moeglich, die Abarbeitung der Programme mit Papier 
und Bleistift vorzunehmen; nur duerfte die Bearbeitungszeit dafuer enorm 
hoch sein, also nehmen wir lieber den Computer.
Krieg der Kerne Programme sind Computerprogramme, denn die Struktur und
der Befehlssatz sind assembleraehnlich. Allerdings -und dies ist der
grosse Unterschied zu jeder "normalen" Programmierung- besteht der 
Zweck dieser Programme einzig darin, nicht vom Gegner getroffen zu
werden bzw. den Gegner zu treffen.
Vor 2 Jahren erzaehlte uns jemand in einer Kneipe von einem Artikel
in "Spektrum der Wissenschaft", in dem das Spiel beschrieben werde.
Zu der Zeit hatten wir uns gerade die Ataris zugelegt und waren mehr
damit beschaeftigt, irgendetwas auf der Maschine zum Laufen zu
bringen, als irgendwelche Spiele zu programmieren.
Aber irgendwie blieb diese Idee haengen von einem Spiel in dem zwei
Programme gegeneinander kaempfen. Und vor einem Jahr haben wir uns den
Artikel besorgt und angefangen, die erste Version zu programmieren.
Mittlerweile gibt's einen Standard fuer das Spiel und wir haben 
unser Programm diesem angepasst und einiges gegenueber der Version 
vom Februar 87 verbessert.
In den USA wurde eine International Core War Society gegruendet, die
mittlerweile 120 Mitglieder zaehlt und die den Standard herausge-
bracht hat. Es gibt sogar in Japan eine Gruppe, die sich mit dem Krieg 
der Kerne beschaeftigt. Das Spiel scheint sich weltweit zu ver-
breiten. 
In Deutschland ist die Zahl der Spieler, soweit wir das Uebersehen
koennen, noch ziemlich klein, doch wir hoffen, dass sich dies mit 
dieser Version aendert. Wir moechten an dieser Stelle auch noch mal 
allen Anrufern fuer Informationen und Anregungen danken, die wir durch 
sie erhalten haben. Insbesondere Martin Stent aus Frankfurt ist es zu 
danken, das wir nicht zulange auf die Standards warten mussten, denn
er hat uns eine Kopie der Standards zur Verfuegung gestellt, lange
bevor wir eine Antwort aus den USA erhalten haben. Dort hatte es
einen Brand beim Direktor der Core War Society gegeben, der einiges
durcheinandergebracht hatte.
Das Spiel in der jetzigen Form ist noch nicht am Ende seiner 
Entwicklung. Erstens sind von der Spieleprogrammierung noch einige 
neue Strategien zu erwarten. Wir sind schon gespannt welche Programme 
beim naechsten Core Contest auftauchen. Zweitens muesste ueberlegt
werden, wie der Befehlssatz des Kriegs der Kerne erweitert werden
sollte. Es besteht beim Krieg der Kerne die Gefahr, dass das
Spiel langweilig wird, denn es besteht die Moeglichkeit, das ein  
Algorithmus gefunden wird, der die Syntax optimal nutzt und somit
unschlagbar ist. Ob es so kommen wird, wird die Zukunft zeigen! Eins 
laesst sich auf jeden Fall momentan schon sagen: Durch den SPL-Befehl 
ist es wesentlich schwieriger geworden, einen Gegner zu schlagen, da 
man erst gewonnen hat, wenn alle Splits getroffen wurden. 



========================================================================
=== Zusatzprogramme ====================================================
========================================================================
Auf der Diskette befindet ein Editor mit dem Namen EDITOR.PRG. Es 
handelt sich dabei um den Editor EDI.PRG, der, um in unserem Pro-
gramm verwendet werden zu koennen, umbenannt wurde. Der Editor ist ein 
Public Domain Produkt und wurde von U. Romahn programmiert. 
Wer den Editor îfters benutzt sollte dem Autor schon mal 10 oder 20DM 
zukommen lassen, denn der Editor ist wirklich gut.
Gleiches gilt im Åbrigen fÅr den zweiten Public Domain Editor EDIMAX.PRG
von Matthias Pfersdorff, der auch fÅr die Kerne verwendet werden kann.



========================================================================
=== Benchmarks =========================================================
======================================================================== 
Wir haben folgende Ausfuehrungszeiten fuer unser Programm 
ermittelt:

     Anzahl der Speicherplaetze:   2.048
     Anzahl der Ausfuehrungen:    20.000
     
     Einzelspielermodus             Sek.
     -----------------------------------
     CHANG1                         29
     MICE                           35
     KNIRPS                         28       Dies ergibt eine Durch-
     NOTHING                        21       schnittszeit von 30 Sek.
     FACTA NON VERBA                30
     COMMANDO                       29
     

     Pro Minute werden somit im Durchschnitt 40.000 Befehle 
     abgearbeitet. Die Unterschiede in den Programmausfuehr-
     ungszeiten ergeben sich durch die unterschiedliche 
     Komplexitaet der Befehle. 
     
     Normalmodus (10 Wiederholungen) Sek.
     ------------------------------------
     CHANG1   vs. MICE               524
     COMMANDO vs. PARASITE           459
     
     
     Der Assembler benoetigt auch einige Zeit fuer die Uebersetzung.
     Mit dem Programm BENCH.RED kann diese Uebersetzungszeit er-
     mittelt werden. Das Programm enthaelt 100 Befehlszeilen mit
     100 verschiedenen Labeln. 
     
     Assembler-Test                 Sek.
     -----------------------------------
     BENCH                      ca. 5
                
