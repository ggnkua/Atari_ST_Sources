25.05.2005: Endlich laeuft auch der awk!

Zuerst habe ich es mit dem Sozobon versucht; Prototypen etc. Das half nicht.
Immer dasselbe Ergebnis, ein 'print $n' liefert immer print $1.

Dann mit dem c68. Fuer den musste nur bei Aufrufen der Funktion emalloc
ueberall ein Cast auf (unsigned int) eingefuegt werden, dann lief der awk!

Ein Fehler im Sozobon also ...

Davon abgesehen hat der awk mindestens einen Fehler: In r.c in der
Funktion Getrec() wird die Funktion getvar() mit nur zwei Parametern
aufgerufen, es muessen aber drei sein.

 VS 25.05.2005
