* Supervisor Fault
* Tentative d'acces a une zone memoire superviseur
* Fait aussi croire que l'on veut faire un reset...

    .EXPORT sfault

sfault:
    MOVEQ.L  #17,D1
    LSR.L    #2,D1
    MOVE.L   D1,A2     ; Si on etait en mode superviseur, cela fera
    JSR      (A2)      ; un reset a chaud
