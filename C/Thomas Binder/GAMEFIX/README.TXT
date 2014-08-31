Wichtige Informationen zu den einzelnen Dateien:

GAMEFIX.C:    Der Quellcode des GEM-Frontends des Programms GAMEFIX
GAMEFIX.H:    Headerdatei fÅr GAMEFIX.C, MINI1.C und MINI2.C
GAMEFIX.RSH:  Die Resourcedaten fÅr GAMEFIX.C
GAMEFIX.PRJ:  Pure-C-Projektdatei fÅr GAMEFIX.PRG
GAMEFIX.PRG:  AusfÅhrbares Programm zum Steigern der ST(E)-
              KompatibilitÑt des Falcon030
ASSEM.S:      Maschinenspracheteil fÅr GAMEFIX.C, MINI1.C und MINI2.C
              Wird im Artikel als Listing 1 bezeichnet
MINI1.C:      Quellcode des aus GAMEFIX heraus speicherbaren 
              Miniprogramms 1 fÅr bootende Spiele (im Artikel als 
              Listing 2 bezeichnet)
MINI1.HEX:    Das fertige Miniprogramm 1 als Hexdump, wird von 
              GAMEFIX.C per #include eingebunden
MINI2.C:      Quellcode des aus GAMEFIX heraus speicherbaren 
              Miniprogramms 2 fÅr schnelles Einstellen und 
              eventuelles Starten eines Programms (im Artikel Listing 3)
MINI2.HEX:    Wie MINI1.HEX, fÅr Miniprogramm 2
FALCON.H:     Die Headerdatei zur Falcon-XBIOS-Library
FALCNLIB.S:   Der Quellcode der Falcon-XBIOS-Library
FALCNLIB.PRJ: Pure-C-Projektdatei fÅr FALCNLIB.LIB
FALCNLIB.LIB: Die fertig Åbersetzte Falcon-XBIOS-Library fÅr Pure C 1.0

