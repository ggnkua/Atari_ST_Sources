Image Maker 1.0 - 05/1992 - Public Domain - erstellt von Volker Hemsen
mit Lattice C 5.5 fr Atari ST in monochromer Aufl”sung

Dieses Programm l„dt Bilder verschiedener Formate, die dann als Image
in einer Resource-Datei abgespeichert werden. So ist es m”glich auch
gr”ere Bilder in eine Dialogbox einzubauen, soweit dies das verwendete
RCS erlaubt.
Achtung: Mit dem RCS/RCS2 von Digital Research kann man nur Bilder bis
2kB L„nge verarbeiten. Siehe meinen RCS-Patch als Beilage zu
Desert Drain oder ST-Computer 11/91 'Groe Bilder im RCS' und 3/92
unter Quick-Tips.

Ich behaupte nicht das die Idee hierzu von mir selbst stammt! Ich hatte
leider kein Programm, das dies beherschte, und brauchte sowas.

Und so geht Ihr mit dem Programm um:
1. Nach dem Programmstart erscheint eine Dialogbox mit drei Buttons.
2. Drckt 'Bild laden' und es erscheint eine Fileselectbox mit der ein
   Bild der folgenden Formate geladen werden kann. Die Formaterkennung
   erfolgt durch die entsprechende Extension.
   
                   Degas (alt)   :  PI3
                   Doodle        :  DOO,PIC
                   GFA-Blockbild :  BLK,SET,OBJ
                   STAD          :  PAC
                   
3. Nach dem Laden erscheint die Dialogbox wieder.
4. Drcke 'Image speichern' und es erscheint das zuvor geladene Bild
   und die Maus als Hand. Jetzt markiert Ihr bei gedrckter linker
   Maustaste ein Rechteck mit dem gewnschten Bildausschnitt und lat
   diese dann los. Es erscheint eine Fileselectbox in der Ihr einen
   Pfad fr die Resource-Datei angeben mt unter dem das Image
   gespeichert werden soll. Ein Drcken der rechten Maustaste gilt
   immer als Abbruch.
5. Verlat das Programm mit 'Quit'.
6. Startet Euer RCS. Ladet eine RSC-Datei in die das Image eingefgt
   werden soll. 'Merged' die RSC-Datei mit dem abgespeicherten Image
   hinzu. Eine Meldung nach der keine DFN/DEF-Datei gefunden wurde
   ist zu ignorieren. ™ffnet den Baum mit dem Image. Legt es mit Copy
   aufs Clipboard. ™ffnet einen gewnschten Baum und kopiert das
   Image hinein. L”scht den 'hinzugemergden' Objektbaum und Ihr seit
   fertig.
   
   So das war's. Bis dann.

