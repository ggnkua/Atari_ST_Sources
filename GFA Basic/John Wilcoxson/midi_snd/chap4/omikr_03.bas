Beispielprogramm Nr.     in Omikron-BASIC
'
10 'Vierstimmiges Akkord-Demo-Programm in Omikron-BASIC
20 PRINT "Akkord-Demo"
30 PRINT "Zum Beenden Taste drÅcken"
40 Sende_Kanal=1
50 Kein_Statusbyte=0
60 Midi_Init
70 REPEAT
80    Midi_Byte=FN Midi_In
90    Chk_Stat(Midi_Byte,Flag,Stat,Chn)
100    IF Flag=Kein_Statusbyte THEN
110       IF Stat=Note_On THEN
120          Velocity=FN Midi_In
130          Tonhoehe=Midi_Byte+4'
140          Note_On(Sende_Kanal,Tonhoehe,Velocity)
150          Tonhoehe=Midi_Byte+7
160          Note_On(Sende_Kanal,Tonhoehe,Velocity)
170          Tonhoehe=Midi_Byte+12
180          Note_On(Sende_Kanal,Tonhoehe,Velocity)
190       ENDIF
200       IF Stat=Note_Off THEN
210          Velocity=FN Midi_In
220          Tonhoehe=Midi_Byte+4
230          Note_Off(Sende_Kanal,Tonhoehe,Velocity)
240          Tonhoehe=Midi_Byte+7
250          Note_Off(Sende_Kanal,Tonhoehe,Velocity)
260          Tonhoehe=Midi_Byte+12
270          Note_Off(Sende_Kanal,Tonhoehe,Velocity)
280       ENDIF
290    ENDIF
300 UNTIL LEN( INKEY$ )
310 Notes_Off(Sende_Kanal)
320 Midi_Exit
330 ' Hier kommt jetzt noch die MIDI-Library

