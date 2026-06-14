Anti-Virus V2.03b
Programm und Anleitung:M.Klocke-Sewing

Wichtig:Auf Ihrer Anti-Virus-Diskette (Ordner) finden Sie folgende
Programme:

A_Virus.Prg  = Anti-Virus
Auto.Prg     = Sucht auf der Diskette in Floppy A nach einer Vire!
               (FÅr Autoordner auf Diskette oder Festplatte)
Read_me.TXT  = Diese Anleitung im ASCII-Format !
V_Schutz.Lst = Eine Gfa-Basic Procedure zum Schutz Ihrer eigenen
               Programme vor File-Viren !

BACKUP.ORD   = Ein Ordner mit den obrigen Programmen ! Wenn eines
               der Programme durch einen Lesefehler auf der Disk-
               ette NICHT lÑuft,versuchen Sie bitte das Programm
               aus diesem Ordner !




DIE VERSCHIEDENEN COMPUTERVIREN:

Bootsektor-Virus
Diese Vire ist die sicher verbreitetste auf dem ST ! Sie kopiert
sich bei einem Reset des Systems automatisch in den Speicher !
Von dort zerstîrt Sie Daten und Programme !

Desktop-Virus
Eigentlich kein `richtiger` Virus ! Es handelt sich einfach um eine
verÑnderte Desktop.Inf Datei,die Åber ein TrÑgerprogramm auf
Diskette oder Harddisk geschrieben wird ! Sie ist dann im Desktop
nicht sichtbar !

File(Auto) Viren
Auch diese Vire wird Åber ein TrÑgerprogramm in den Autoordner von
Disketten oder der Harddisk geschrieben ! Dieser Virus ist sehr
leicht zu schreiben ! (zB:auch in Gfa/Omikron Basic)

*.ACC Vire
Dieser Virus wird als *.ACC in den Speicher geladen und kopiert
sich wie auch die Bootsektor-Vire automatisch weiter !

Sich ankopierende-Viren (Link-Viren)
Dieser Virus kopiert sich vor sein Opferprogramm und wird mit
diesem gestartet ! 

Die Anti-Virus V2.03b bekannten LINK-Viren sind:

A)Der Milzbrand-Virus
B)Die VCS-Viren  

Beachten Sie das Modul "File-Viren-Searcher"

STARTEN VON ANTI-VIRUS

Starten Sie das Programm `A_VIRUS.PRG` von der Floppy oder
Harddisk ! Dabei darf das Programm auch in einem Ordner stehen !

SUCHEN UND LôSCHEN VON VIREN

Nach dem Start erscheint das Menufeld ! Von dort kînnen alle
Funktionen des Programms angesprochen werden !
Durch drÅcken der Taste `HELP` bekommen Sie weitere Informationen
zu den einzelnen Menupunkten !

Suchen und lîschen einer Bootsektor-Vire !

A)Legen Sie die zu testende Diskette in Floppy A ein.
B)DrÅcken Sie die Taste `1`.
Wird kein Virus gefunden erhalten Sie die Meldung:
`Kein Bootsektor Virus/Name des Laders:NNNNN`

Darunter sehen Sie Byte 200-234 aus dem Bootsektor !

Wird ein Bootsektor-Virus gefunden erhalten Sie die Meldung:
`Kein TOS-Bootsektor !/Name des Laders.....`

Wenn Sie den Lader lîschen wollen drÅcken Sie die Taste `J` !
Der Lader wird nun gelîscht ! Dabei werden andere Daten oder Files
von der Diskette NICHT verÑndert !

Anzeigen des Bootsektor und einiger wichtiger Bootsektor Daten !

A)Legen Sie die betr. Diskette in Floppy A ein.
B)DrÅcken Sie die Taste `2`.
Sie erhalten nun genauere Informationen Åber den Bootsektor !
C)DrÅcken Sie eine Taste um wieder zurÅck ins Auswahlmenu zu
  gelangen !

Suchen nach einer File(Auto) Vire !

A)Legen sie die betr. Diskette in Floppy A ein.
B)DrÅcken Sie die Taste `3`.
Sie erhalten nun eine Liste ALLER (auch versteckter) Programme des
Autoordners von Diskette A.

Wollen Sie ein Programm lîschen-geben Sie nun hinter:`Lîsche File:`
den Namen des betr. Files ein. (zB:Virus.Prg)

Wenn Sie keinen File lîschen wollen,drÅcken Sie einfach die Return
Taste !

Suchen nach einer *.ACC Vire !

A)Legen Sie die betr. Diskette in Floppy A ein.
B)DrÅcken Sie die Taste `4`.
Sie erhalten nun eine Liste ALLER (auch versteckter) *.ACC Files
aus dem A:\*.Acc Verzeichnis von Diskette A.

Wollen Sie ein Programm lîschen-geben Sie nun hinter:`Lîsche File:`
den Namen des betr. Files ein. (zB:Virus.ACC)

Wenn Sie keinen File lîschen wollen,drÅcken Sie einfach die Return
Taste !

SUCHEN NACH VIREN AUF DER HARDDISK C:

DrÅcken Sie die Taste `5` oder `6` und machen Sie wie bei Funktion
3-4 weiter !

Info zum Programm:

Durch drÅcken der Taste `7` erhalten Sie Informationen Åber
Anti-Virus !

ZurÅck ins Desktop:

Durch drÅcken der Tasten 9 und dann `J` und Return kommen Sie
zurÅck ins Desktop !


Mîgliche Fehlermeldungen von Anti-Virus:

Diskettenfehler Nr.6 = Die Diskette konnte nicht gelesen werden !
Fehler Nr.16         = Auf der Diskette sind keine Autoordner oder
                       keine *.ACC Files !
Sorry,Sie haben keine= Sie haben keine Harddisk angeschlossen !
Harddisk C !!!


öber das Programm `AUTO.PRG` !

Kopieren Sie dieses Programm bitte in den AUTOORDNER Ihrer Boot-
Disketten oder auf den Autoordner Ihrer Harddisk !

Bei jedem System-Reset testet dieses Programm nun den Bootsektor
der Diskette von Floppy A ! Wird kein Virus gefunden gibt das Programm
eine Meldung aus und es wird weitergeladen !

Dieses Programm schÅtzt Ihr System 100%ig gegen jede
Art von Bootsektor-Viren ! Das Programm benîtigt dafÅr nur kurze
Zeit !

öber die Procedure `V_Schutz.Lst` !
Mit diesem Programm schÅtzen Sie Ihren eigenen Programme (zB:als
PD Software) gegen den Angriff von File-Viren ! Das Programm lÑuft
leicht verÑndert auch in Omikron Basic !)

Klicken Sie diese Procedure an Ihr Hauptprogramm an und lassen Sie
es GLEICH nach dem Start aufrufen ! Beim ERSTEN Start wird eine
Zusatzdatei angelegt in der die LÑnge Ihres Programms gespeichert
wird ! Beim Angriff eines Virus wird Ihr Orginalprogramm lÑnger und
ein Virus wird so erkannt !

Dies ist,nach meiner Meinung,die einzige Mîglichkeit eine
Verbreitung der File-Viren zu stoppen !

Wenn Sie noch weitere Fragen zum Programm haben schreiben Sie bitte
mit 80 PD RÅckporto an:
Marcus Klocke-Sewing
Gronauer Str.19
4800 Bielefeld 1 (Deutschland-West)

Am Ende noch eine BITTE:
Wenn Sie einen Virus haben,der von Anti-Virus NICHT gemeldet wird-
schicken Sie mir bitte die betr. Diskette zu ! Ich werde dann
versuchen Anti-Virus auch auf diesen Virus anzupassen ! Ihre
Diskette bekommen Sie natÅrlich sofort wieder zurÅck !

A N T I _ V I R U S   U P D A T E :

DA ANTI-VIRUS VON MIR IMMER ERWEITERT WIRD,HéTTEN SIE SCHON GROûES
GLöCK, WENN SIE WIRKLICH DIE ALLERNEUSTE VERSION IN DEN HéNDEN
HéTTEN !

DARUM KôNNEN SIE VON MIR GEGEN EINSENDUNG VON:

A)EINER DISKETTE
B)39.-DM (V-SCHECK)

DIE NEUSTE VERSION BEKOMMEN ! 

ACHTUNG:
FöR  W E I T E R E UPDATES SENDEN SIE MIR DANN NUR NOCH EINFACH
EINE DISKETTE UND 80.PF RöCKPORTO ZU !



ZU DEN MODULEN:


File-Viren-Searcher !

Mit diesem Modul haben Sie die Mîglichkeit,die ersten 1024 Byte Ihrer
wichtigen Programme zu sichern und so einen durch eine Vire befallenen File
zu ermitteln !

Formatieren Sie sich als ERSTES bitte eine Diskette (1S oder 2S) !!
Diese Diskette ist ab jetzt Ihre A_Virus Datendiskette !!

1)Laden Sie nun A_Virus !!
2)DrÅcken Sie die Taste "8" um in die Modul-Auswahl zu gelangen !
3)DrÅcken Sie `1` und Return !

Der Atari fragt Sie nun:`A)Vergleiche 1024 Byte oder B)Read/Save 1024 Byte ?
(Legen Sie nun die Diskette mit Ihrem Programm ein !!)
(Achtung:Das Programm darf in KEINEM Ordner stehen !!)
(Bitte Diskette schreibschÅtzten !!)

1)Wenn Sie die ersten Byte eines Programms (fÅr spÑtere VERGLEICHE) auf
Ihrer Datendiskette sichern mîchten,klicken Sie `B` !!

2)Wenn Sie eine schon gesicherte Datei testen wollen,klicken Sie `A` !!

Bei 1:
Es erscheint eine Auswahlbox !
1)Klicken Sie Ihr zu sicherndes Prg an !
2)Legen Sie nun Ihre Datendiskette ein.
3)Klicken Sie "OK" an !
Die ersten 1024 Byte werden nun unter gleichem Namen gesichert !

Bei 2:
Legen Sie Ihre Prg. Disk ein !
1)Klicken Sie das zu testende Prg.
2)Legen Sie die Datendiskette in Floppy A und drÅcken Sie `Return` !!

Sie bekommen nun eine Meldung-ob die ersten 1024 Byte die selben sind,
wie die zuerst gespeicherten !


`Link-Viren-Searcher`

Dieses Modul schÅtzt Sie sicher vor den versch. Link-Viren !
Besonders dieses Modul wird immer erweitert !
 

Ende der Anleitung...












