	Dokumentation zum Programm ST_HERC.PRG	     ½ by Christian Rupp
	======================================


	Das Programm ST_HERC.PRG wandelt - wie der Name schon erahnen 
	l„t - Bilder zwischen dem Atari-ST Bildschirmformat und dem 
	Bildschirmformat eines IBM-kompatiblen Rechners mit Hercules-
	Grafikkarte um.
	Es besteht somit die M”glichkeit, Bilder zwischen dem IBM-PC 
	und dem Atari-ST auszutauschen.

	Das Programm ist in GEM eingebunden, es wird daher wohl keine
	ausfhrliche Beschreibung n”tig sein. Hier noch einige Hinweise:

	- Es werden nur monochrome Grafiken untersttzt.
	- Grafiken des Atari-ST mssen im Bildschirmformat vorliegen,
	  also genau 32000 Byte lang.
	- Hercules-Bilder sind etwa 50 Zeilen krzer und 80 Spalten
	  breiter als Atari-Bilder. Das Programm bietet daher die
	  M”glichkeit, zwei Atari-Bilder zu einem Hercules-Bild
	  zusammenzusetzen bzw. den rechten Rand mit einem vorgegebenen
	  Muster aufzufllen. Umgekehrt ist es auch m”glich, ein
	  Hercules-Bild wieder in zwei Atari-Bilder aufzuteilen.
	- Die šbertragung der Dateien vom Atari auf den IBM erfolgt am
	  besten ber ein am Atari angeschlossenes 5¬"-Laufwerk oder ein
	  am IBM angeschlossenes 3«"-Laufwerk. Denkbar ist auch eine
	  šbertragung ber ein serielles Kabel mit geeigneten Terminal-
	  Programmen.
	- Anhand der beiden Turbo-Pascal 3.0 Programme l„t sich er-
	  kennen, wie in das Hercules-Format gewandelte Bilder auf dem
	  IBM weiterverarbeitet werden k”nnen. Die Programme wurden 
	  erstellt auf einem IBM-PC mit AGA-Karte in der Hercules- 
	  Emulation. 
	  Das Programm VIEW liest ein Hercules-Bild von Diskette ein
	  und zeigt es auf dem Bildschirm. M”glicherweise vertragen es 
	  „ltere (langsame) Hercules-Karten nicht, wenn man 32K am Stck 
	  in sie hineinliest. Das Einlesen mu dann byteweise erfolgen.
	  So wird in VIEW2 vorgegangen.
	  Das Programm SLIDE stellt eine ganze Bilderserie auf dem Bild-
	  schirm dar. Die Namen der zu zeigenden Bilder mssen in einer
	  Datei INHALT im gleichen Verzeichnis, in dem sich auch SLIDE
	  befindet, abgelegt sein.



	  Das Programm ist geschrieben mit ST-Pascal+ 2.04. Der Quell-
	  text ist fr 10,- DM bei mir erh„ltlich:

	  Christian Rupp, Am Kronwerk 9, 6740 Landau


