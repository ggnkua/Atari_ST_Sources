 Dies ist die Version 1.25, Stand August 1987.
 Deutsche Version, lizensiert fr Markt & Technik.


 Im Atari ST Assembler-Buch (Markt & Technik, Nr. 90467) sind alle Listings
 mit dem Metacomco-Assembler geschrieben worden. Die Anpassung an das
 Devpac ist recht einfach:

 1. Entfernen Sie die Direktiven TEXT, DATA und BSS soweit vorhanden.
    (Der Ersatz durch entsprechende Devpac-Direktiven ist natrlich
    m”glich, aber nicht n”tig.)
  
 2. In Kommentarzeilen, die mit einem Semikolon (;) beginnen, schreiben
    Sie stattdessen einen Stern (*).
    Stehen vor dem Semikolon noch Leerzeichen, ersetzen Sie das erste
    Leerzeichen in der Zeile durch den Stern.

 3. Folgt direkt einem Operanden ein Semikolon mit Kommentar, fgen Sie
    vor dem Semikolon ein Leerzeichen ein oder ersetzen es durch ein
    solches.
