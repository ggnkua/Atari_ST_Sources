* fspool.prg
* Minimal-Programm zum Starten des Spoolers

        trap    #0              Spooler starten

        clr     -(sp)           pterm0
        trap    #1              und das war's!
