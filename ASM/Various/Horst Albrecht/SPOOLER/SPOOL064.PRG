`  �                      ` �\AUTO\SPOOL*.PRG    �                     H���":�� 8�#�   ����  �e#���   & z�ұ���g����f z��#�   &a�  �L�NsA�� � � A � @ � � A � A NuXBRASPLX   ":�^ 8�����  �e* z�\���Tf x^N�J�g
#��   `"#��>   &p Nu :�2R����$f :����g�0/ @� | "z����
fA�� (   f(   fa �F`�����f"z��#�   *F�p�NuXBRASPLX   Nh0  gA� X f?Bg x~N�X�NsN�*o B�?<  NA\�/ a\Hz?< 	NA\�A���#�   #�   *#�   &���Z#�   "a  �?<  NA\�Hy   .Bg?< NNP�Bg <  �к�,/ ?< 1NABgHz�*m $*m $J� $f.�   ?< NNAP�J@f8?< /NAT��   # @B@a&f"a"faf�� #�   C� �    0gNu 0e 9b �� 
�Ar NurNu#�~   �!�   �~Hz��?< !?< NMP�#�  �#�  ZA�� �   �   NuEp Spooler          (C) 26.6.1992  Horst Albrecht, Brahmsstr. 25, 4047 Dormagen 5 q
 - Puffergr��e:  32 KB
 - nutzt die Geschwindigkeit des Druckers optimal
 - Ausschalten des Druckers f�r 10 Sek. beendet jeden Druckvorgang
 - am Beginn eines Drucks erscheint bei ausgeschaltetem Drucker nach
   sp�testens 10 Sek. eine Fehlermeldung unabh�ngig von der Art der
   Programmierung der Anwendung
 - mu� vor jedem anderen Programm gestartet werden, welches ebenfalls
   die BIOS-PRN-bconout-Routine ver�ndert
 - Durch Umbenennung des Programms in SPOOLxxx.PRG l��t sich der Spooler
   mit frei w�hlbarer Puffergr��e verwenden.
   xxx ist die Puffergr��e in KB und mu� mit 3 Stellen angegeben werden.
   Bei einer fehlerhaften Angabe wird der Puffer mit 32 KB eingerichtet.    <z
Zb
84:  