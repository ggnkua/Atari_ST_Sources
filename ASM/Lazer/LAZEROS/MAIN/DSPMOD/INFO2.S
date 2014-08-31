* Adresse       Funktion                Input                Output
*-------------------------------------------------------------------------
* player+28:    install Player          -                    d0: Version (BCD)
* player+32:    deinstall Player        -                    -
* player+36:    PlayerOn                a0: Zeiger auf Modul -
*                                       a1: Zeiger auf Volumetabelle
* player+40:    PlayerOff               -                    -
* player+44:    PlayMusic               Player-Interrupt
* player+48:    nop                     -                    d0: $1234
* player+52:    ModType                 a0: Modul            d0: Anzahl Tracks
* player+56:    fx                      siehe Doc
;---------------------------------------
* player+60:    .w SurroundDelay        siehe Doc
* player+62:    .w DspTracks            siehe Doc
* player+64:    .b playmodflag          (0: Pause Modreplay, $FF: Playmod)
* player+65:    .b command8mode         (0: kein command
*                                        1: command8 als Setstereo-command)
* player+66:    .b command8flag         (wird $FF wenn Command8 benutzt wird;
*                                        fÅr Synchrozwecke)
* player+67:    .b unbenutzt
* player+68:    .l SampleSets           siehe Doc
;---------------------------------------
* Diese Offsets fÅr DSPMOD2.TCE
