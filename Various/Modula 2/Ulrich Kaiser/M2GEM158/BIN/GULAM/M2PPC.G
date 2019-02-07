# GULAM-Script fuer M2-Code mit Praeprozessoranweisungen
# Das Ergebnis ist eine vom M2-Compiler uebersetzbare Datei
# mit den ueblichen Zeilenenden und maximal einer Leerzeile
# zwischen anderen Zeilen

echo $2
cpp -undef -P -D$1 -imacros e:\usr\include\m2\crystal.m2h $2 ${TEMP}\cpp_tmp.999
x2d1 <${TEMP}\cpp_tmp.999 >$3
rm ${TEMP}\cpp_tmp.999

