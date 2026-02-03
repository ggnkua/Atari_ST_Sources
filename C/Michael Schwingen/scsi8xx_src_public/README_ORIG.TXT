Kurzanleitung zu SCSI8XX.PRG

der Treiber lÑuft momentan mit SCSI-Adaptern mit 53C810 oder 53C810A von 
Symbios Logic (frÅher NCR). Der Treiber muû ins ST-RAM geladen werden 
(Flags sind entsprechend gesetzt).

Der Treiber benîtigt ein TOS vom 19.10.1998 oder neuer sowie fÅr 
den Zugriff auf Festplatten HDDRIVER ab V7.60

Installation:
 - in HDDUTIL, GerÑtekonfiguration die GerÑte E0-E6 aktivieren 
   (bzw. die IDs, wo Festplatten sind).
 - wenn nîtig neuen Bootblock mit flash.tos schreiben
 - FLASH.PRG starten, TOS/Program anwÑhlen
 - auf die Zeile unter TOS IMAGE klicken und TOS.IMG auswÑhlen
 - auf erste Zeile unter EXTENSIONS klicken und SCSI8XX.PKG anwÑhlen
 - auf 'Flash' klicken und bestÑtigen.

Der Treiber wird vom TOS vor dem Start von Plattentreiber etc. gestartet. 
Dadurch kann jetzt auch problemlos von SCSI-Festplatten gebootet werden.

Der Treiber stellt das SCSIDRV-Interface (wie in HDDriver und CBHD) zur 
VerfÅgung. Das Starten von SCSIDRV (aus dem CBHD-Paket) ist *nicht* nîtig 
(und funktioniert auch nicht).

Getestet ist:
 - Partitionieren/Sektortest/... mit HDDRUTIL und CBHDUTIL
 - CDROM mit Spin! 0.34
 - Mucke und CDplayer von A. Clauss
 - Novascan 1.25plus
 - Gemar: benîtigt GEMARFIX.PRG, siehe GEMARFIX.TXT
 - CBHD0: geht nicht (lÑuft aber auch ohne SCSI8XX nicht).

Der Treiber macht im Moment nur asynchrone Transfers - daher sind maximal 
5MB/s zu erreichen. Meine Fujitsu-Testplatte kommt beim Lesen mit HOWFAST 
auf 4.8-4.9MB/s.

ACHTUNG!
Ich habe den Treiber getestet, und er hat bei mir nicht zu Datenverlusten 
gefÅhrt. Ich kann aber nicht garantieren, daû dies generell der Fall ist - 
daher: Benutzung auf eigene Gefahr!

Wenn Probleme auftreten, gibt der Treiber auf die MFP-Schnittstelle 
Disgnoseausgaben mit der aktuell eingestellten Baudrate aus (ohne 
Handshake).

Dazu muû man beim Starten des Treibers SHIFT gedrÅckt halten - er fragt 
dann nach DEBUG-Flags. Hier ist eine Hex-zahl einzugeben, die die Summe der 
gewÅnschten Debug-Optionen ist (mit RETURN abschlieûen). Mîglich sind 
bisher:
 01: Command-Processing, BUS-Resets etc.
 02: Scatter/Gather & PMMU
 04: SCSI script processing, script trace
 08: SCSIDRV-Interface
Ohne besondere Hinweise ist 09 eine sinnvolle Einstellung - mit den 
restlichen Daten kann eh nur ich etwas anfangen.

Getestete GerÑte (ErgÑnzungen bitte melden):
CD-ROMS:
 - Toshiba 3301
Streamer:
 - Tandberg TDC4100 (SCSI-2-Firmware)
 - DEC TKZ-10
Festplatten:
 - Sony SRD2040A
 - Quantum LPS240
 - Maxtor 7345S
 - Fujitsu M2915SA
Wechselplatten:
 - Syquest SQ555
Scanner:
 - Mustek Paragon 600
 - Mustek Paragon 1200SP

Michael Schwingen, <rincewind@discworld.dascon.de>
