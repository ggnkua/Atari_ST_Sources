
	CPX-Module fÅr den Control-Panel-Server COPS
	============================================



	VERSION:  0.01 û     01.02.97
	

Rechtliches:
	
	FREEWARE FREEWARE FREEWARE

	Das Archiv CPXE-001.* darf nur komplett und kostenlos weitergegeben
	werden!
	
	FÅr eventuelle SchÑden, die durch die Benutzung dieser Software
	entsteht (seeehr unwahrscheinlich ;-) wird (wie immer) keine
	Haftung Åbernommen!!
	
	Daher:  BENUTZUNG AUCH EIGENE GEFAHR !!!!
	


Im Archiv CPXE-001 befinden sich folgende CPX-Module:

	eyes.cpx	Ein Clone von XEYES ( 2 Augen, die der Maus folgen )
	
	galaxy.cpx	Eine sich drehende Galaxy
	
	dog.cpx     Der Hund, des Menschen bester Freund.
				Eine Animation, in der ein kleiner Hund Åber den
				Bildschirm spaziert.
				(Die Grafik stammt aus einem animiertem GIF-Bild,
				 das ich im WWW entdeckte)


Vorraussetzung:

	Control-Panel-Server COPS

	Rechnersystem, auf dem TOS Software lauffÑhig ist.
	(ST/STE/TT/Falcon/MagiC-Mac/Magic-PC/ .... )
	
	Getestet auf:
		1040 STF, 4MByte, TOS 2.06, Winx, MiNT, MultiTOS, Geneva (Demo)

Bedienung:

	COPS installieren, wenn noch nicht geschehen, die Module in den
	CPX-Ordner kopieren, den Rechner neu starten oder im COPS-Popup
	den MenÅpunkt "Neuladen" anklicken, die Module aufrufen und schon
	kann man sie bewundern ;-)

	Alle Module sind sogenannte Event-CPXe, sie verwenden insbesondere
	den Timer-Event. Durch einen Klick in das Innere des Fensters îffnet
	sich ein Popup, in dem man die "Refreshrate" grob einstellen kann.
	
	Allerdings "bewegen" sich diese Module nur, wenn ihnen das oberste
	Fenster gehîrt. Dies ist kein Fehler im Modul, sondern eine Eigenschaft
	von COPS, der nur dem Modul mit dem oberstem Fenster einen
	Timer-Event schickt.
	Vielleicht Ñndert sich das ja in Zukunft, schîn wÑrs auf jeden Fall.

Entstehung:

	Beide Module wurden zu Testzwecken geschrieben, um insbesondere
	die von COPS unterstÅtzte variable Fenstergrîûe auszuprobieren.
	
	Weitere solcher kleinen "nÅtzlichen" Module sind bereits geplant
	und werden auch bald als komplette (farbige) Versionen verfÅgbar sein.
	


Bezugsquelle fÅr COPS:

	http://www.stud.uni-karlsruhe.de/~Thomas.Much
	ftp://ftp.uni-paderborn.de/pub/atari/tools/mtask/magic/  (oder so Ñhnlich)

Das Archiv CPXE-001 findet man auf

	http://www.eikon.e-technik.tu-muenchen.de/~tomst


Entwicklungssystem:

	GNU C 2.7.2  unter der KGMD

Sourcen:

	Die C Source-Codes zu allen CPX-Modulen sind beigelegt.
	Wenn allerdings jemand die Sourcen kompilieren mîchte, muû er selbst
	Anpassungen an den Sourcefiles und Makefiles machen, da ich fÅr meine
	C-Programme eigene "Tools" verwende (insbesondere trifft dies auf die
	Headerdateien tm****.h zu)!
	
	Die Sourcen sind eigentlich nur dazu im Archiv, um einen Einblick in
	die Implementierung zu geben.
	Vielleicht fÑllt auch jedem etwas ein, wie man etwas verbessern kann!?

Autor:
	
	ToMST
	
	Thomas Maier         01.02.97
	
	
	Email:  tomst@eikon.e-technik.tu-muenchen.de
