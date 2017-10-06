MT_AES
======

Haftung
ÿÿÿÿÿÿÿÿ
Trotz sorgf„ltiger Entwicklung und umfangreicher Tests k”nnen wir keine Gew„hr
bernehmen, da die beiliegende Software unterbrechungs- und fehlerfrei l„uft.
Die Haftung fr unmittelbare Sch„den, Folgesch„den und Drittsch„den
ist ausgeschlossen!

Beschreibung
ÿÿÿÿÿÿÿÿÿÿÿÿ
MT_AES ist eine multitaskingf„hige AES-Bibliothek.

Fr den Hauptproze einer Applikation erfolgen die AES-Aufrufe in der bisher
gewohnten Schreibweise und das global-Array ist ber den _GemParBlk
anzusprechen. Jeder Thread hat sein eigenes (lokales) global-Array, das er bei
AES-Aufrufen als letzten Funktionsparameter bergibt. Die Funktionsnamen „ndern
sich dabei derart, da bei jedem AES-Aufruf eines Threads ein "MT_" vor den
Funktionsnamen geh„ngt wird. Eine n„here Erl„uterung dazu wird in MT_AES.C
gegeben.

Die Dateien in den Ordnern "INCLUDE" und "LIB" sollten in die korrespondierenden
Verzeichnisse des Compilers kopiert werden.