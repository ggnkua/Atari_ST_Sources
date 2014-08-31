* Adresse       Funktion                Input                Output
*-------------------------------------------------------------------------
* player+28:    install Player          -                    d0: Version (BCD)
* player+32:    deinstall Player        -                    -
* player+36:    PlayerOn                a0: Zeiger auf Modul -
*                                       a1: Zeiger auf Volumetabelle
* player+40:    PlayerOff               -                    -
* player+44:    PlayMusic               Player-Interrupt
* player+48:    PlayTime                a0: Modul            d0: Playtime in BCD
*                                                            z.B. $1234 =
*                                                            12 Min, 34 Sek
* player+52:    ModType                 a0: Modul            d0: Anzahl Tracks
* player+56:    fx                      siehe Doc
* player+60:    SurroundDelay           siehe Doc
* player+62:    DspTracks               siehe Doc
* player+64:    PlayInfos               siehe Doc
* player+68:    SampleSets              siehe Doc
