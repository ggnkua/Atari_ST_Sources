;Dies ist ein Disketten-Bootsektor, der beim Booten eine kurze Meldung
;ausgibt, als Virenschutz. Thomas Muthmann, Mlheim am 23.05.1990.
;Das assemblierte File mu genau 512 Bytes (mit Programm-Header) lang
;und der Filename "HDFORMAT.BOO" sein.
;Die ersten 28 Bytes werden vom Formatierer berschrieben, da aber der
;Assembler mit dem Programm-Header sowiso 28 unbenutzte Bytes erzeugt,
;braucht man dem Vorgang keine weitere Bedeutung schenken (welch Zufall).
;Da jedoch das folgende 29 und 30 Byte die Anzahl der versteckten Sektoren
;enth„lt, sollte hier ein plausibler Wert, n„mlich Null, stehen.
;Falls das jemand „ndern will, der sollte die 8088 Darstellung beachten!
;Direkt danach folgen 6 Bytes, in die der Formatierer seine Versionsnummer
;und danach in weitere 10 Bytes, sein Erstellungsdatum reinkopiert.
;Datum und Versionsnummer sind ASCII und mit Null abgeschlossen.
;Das erzeugte Programm mu natrlich voll relativ sein!
;Assembliert mit GFA-Assembler 1.3

hid:            .dc.w 0   ;             ;versteckte Sektoren
version:        .dcb.b 6,0
datum:          .dcb.b 10,0

;Jetzt sind dem Programmierer (fast) keine Grenzen gesetzt, zu beachten ist
;jedoch, da bei 510 Gesamtbytes Ende ist, da dort das Magic eingetragen wird.
;Das Programm mu mit Return abgeschlossen sein.

;Ausfhrbaren Programmblock einladen. Auer dem Pfad und Filenamen sollte
;in diesem Rahmenprogramm nichts ge„ndert werden!
                .path "\ASS\GFA\W\HDFORMAT\"
                .include "HDFORMT2.IS"
                .text 
ende:           rts                     ;Kommando zurck

                .data 
akt:            
                .dcb.b 478-akt,0        ;bis auf 512 Bytes auffllen
                .even 
                .dc.w 0   ;             ;Platz fr das Magic

