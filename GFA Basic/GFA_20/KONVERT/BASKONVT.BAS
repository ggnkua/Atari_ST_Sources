 GfABASIC      �  �  �  �  �  �  �  �  �  "  "  "  "  P  ;�  =0  =�  =�  =�  =�  >  >  >  >�  >�  >�  >�  >�INUMZEILEVALK	NUMZEILERL1LNUMZEILL2NZLIIIGIKZNR	LEERTASTE
DPPELPUNKTLAENGETHENPUNKTLGLSLPROPROGRAMMZEILEZEILEFREANFRZEICHENANFRZEICHEN1ANFRZEICHEN2
APOSTROPH2DPPELPUNKT2
APOSTROPH1LVARLNEUVARZLNRWLWRWNANZAHLGOTONUMMERNANZAHLGOSUBNUMMERNANZAHLGOTONAMENANZAHLGOSUBNAMEN
ZEILANZAHLKOMMABLANKQM1MZEILENDEMPROJZEILENNUMMERJGJKSPALTESPZLTRENNSTAPSTAPELIALTANZAHLSCHLEIFVARANZAHLLAUFVARLLLAUFVACDTNRMIDANZAHLFEHLERMARKENJEJFLAUFVAROZEILEZEILE1ZEILE2OXOYOOMARKEPROGRAMMZEILEALTNAMENEUNAMEVARMODNEUVAR	NAMSPRUNGLEFT
SUCHSTRINGZEILEALTOPBAMENVARMNVARMVARZEILEREMERGFEHLERMARKENUMNUMPRONAM MIDLEFTNAMPRONAMSCHLFVARSCHLVARLAUFVARFEHLERMARKE 
FRTSETZUNGSPRUNG	TEIL1ENDEANFANGWEITERSUCHENANFANG1ANFANG2TEIL2	TEIL2ENDEDPPELPUNKTSUCHENEUERDPPELPUNKTNEUERAPOSTROPH	NEUESUCHESUCHENDE	RESULTAT1	RESULTAT2TEILBTEILAMEHRERESPRUENGESCHLUSSMEHRGOTOSPRUENGEMEHRGOSUBSPRUENGEMARKENVERGLEICHBEDINGUNGENAUFLOESENMARKENVERGLEICH1MARKENVERGLEICH2WIEDERHABBRUCHMARKESUMMEIDENTIFIKATION	SUCHENDE1
NEUESUCHE1IDENTIFIKATION1
VAR_LAENGETEILCFRTSETZFRTSTZNGVARIABLAENGEZEILEFERTIGMEHRRESUMESPRUENGE FEHLER1FEHLER2	MODIFIKATEINZELBEFEHL
SUCHELINKSSUCHERECHTSSTRINGSUCHESCHLEIFENSUCHEMODIF_ONGOTOMODFIKATONGOTO YF�XF�F6�0         ***************************************F6�0         **     ATARI ST:  BASIC KONVERTER    **F6�0         **       ST BASIC in GfA-BASIC       **F6�0         ***************************************FF#8�3 Atari - GfA -Basic / (c) 1986 by GfA SystemtechnikF(�" written by Klaus Keller, HerdeckeFf&�! Programmversion 3.0 / 10.10.1986F��\   !�>    F0�+Folgende Programmpunkte werden durchlaufen:F�TEIL A:F8�2(1) Einsetzen fehlender GOTO's nach THEN oder ELSEF 6�1(2) Ersetzen der Zeilensprungnummern durch MarkenF<�7(3) Erg�nzen der Unterprogrammanspr�nge durch procedureF,�&(4) Ersetzen von GOTOXY durch PRINT AtF 6�0(5) Auflisten aller Sprungmarken und SprungzieleFc�TEIL B:F4�/(6) Aufl�sen von THEN..., THEN-ELSE BedingungenF$�(7) Umschreiben von ON... GOTOF6<�6(8) Umwandlung von ON ERROR GOTO und der FehlerroutineF "�(9) L�schen der ZeilennummernF6�1(10) Zerlegen der Programmzeilen in EinzelbefehleFL�F(11) Auflisten aller Schleifenvariablen und Erg�nzen bei NEXT-BefehlenF F|F:�=Fortsetzung mit Einlesen des zu bearbeitenden Programms (J/N)"� F  �v� �N� �nJFlqF F YF F�Auswahl der Datei:FtD�>(Nach Dateiwahl zuerst OK-Feld und dann Abbruchfeld anklicken)F Ff�A:\*.*!�	!� F 
 �Z� � F��	E>� @�      F��F�F,�$Name des zu bearbeitenden Programms "�	F�EC�	@�. F  �~��      JF�
E�	�.lstF ��F��
E;�	@� �lstFFE7�i!M�     !�	F> : --------------------  Kommentare ------------------------$ : nach 'REM' wird nicht abgeteilt< : mehrere Sprunganweisungen nach ON .. werden verarbeitet0 : ON   GOTO  wird aufgel�st in Einzelspr�ngel8 : ON ERROR GOTO und RESUME Zeilennr wird umgewandelte@ : Namensprungmarken werden registriert und korrekt behandelteF : Bei zwei Sprungmarken in einer Zeile bekommt die zweite kein ':' > : verschachtelte IF-THEN-ELSE-Bedingungen werden aufgel�st 2 : Gro�-und Kleinschreibung wird ber�cksichtigtnD : RETURN in Fehlerroutine mu� an richtige Stelle versetzt werdene* : Nur ein NEXT pro FOR-Schleife erlaubt2 : Sprung aus Schleife ist mit EXIT zu ersetzenc0 : Graphik-Befehle sind selbst zu modifizieren6 : DEFSTR .. ist mit Programm VARMODIF zu bearbeiten> : ------------------ Programmanfang ----------------------: :######################################################: :######################################################�|F-6 :Obere Schranken f�r Anzahl der Marken ver�nderbar.�&E�   FF�'E�HH   FF�(E�HH   FF�)E�HH   FF�DE�     F��;E�     FF�>E�     FK*� �& F*��' F*��( F*��) F*��D F*��; F*��> F7�o!M�    !�
Auxdat.korFv�L� Fr-�F)+� FFF  ���� P   JF�--- Dateiende ---F �
Fe�Fehler Nr. "�F"�letzte bearbeitete Zeile: "�F(�#Zur Fortsetzung eine Taste dr�cken!FF#� ESF��� � FF ��Fh.F�|F)F �TEIL A:F�ANALYSE DES PROGRAMMS:FF�SUCHE DER SPRUNGZIELEF�Sprungadressen:"FaF=`M�      !�F :ZeilenreduktionF
�E]� F �E5;�@�  F�E>�@��      F ��;�@�       � F�E>�@�      F��F�  4;�@�       �'JFn�E�REM: >�@�      FFE" :Abtrennen von REM-Erg�nzungen � E�      F
�E�remF,�Fr�E� F  �� �      JF�E>�@�  F�E;�@� �      FFE  �6� �@   JF-�&F�F& :Erg�nzen fehlender  GOTO's� E�      FFE�E�thenFF,�Fe �� �      JF�E;�@� �@    F�E>�@� �     F
�E]� F  �5;�@�  �       JF�E�� GOTO �FsFE� E� �@   FFE � �      Fs� E�      FFE�E�elseF ,�Fe \� �      JF�E;�@� �     F�E>�@� �     F
�E]� F  H5;�@�  �       JF�E�� GOTO �FsFE� E� �@   FFE�� �      Fs( : ersetzen von gotoxy durch print atn� E�      FFE�E�gotoxyFx,�F �� �      JF�E;�@� �      F�E>�@� �@    F�+EC�@�, F  ��+�      JF�7E5;�@�+�        FF�E]>�@�+�        Fu ���      JF�8E5?�@�+�      @�  F�E>�@�+��       F*�E��	PRINT At(A�7 �,A�8 �) �FdF F � E� �    F(F �� �      FA( :error goto in error gosub umwandeln � E�      Fk�E�errorF,�Fe �� �      JF� E� �    FF�E�gotoF,�Fg,�E;�@� �      �GOSUB>�@� �     FFE :goto-Sprungmarken suchen� E�      FF �E�goto F,�Fg �� �      JF�|F+�E;�@� �     F�E>�@� �     F @;�@�       � F�E>�@�      FF@�+EC�@�, Fm�,EC�@�  F�EC�@�: Fm�0E6� �     F  ��+�      JF�+E�zz   	F FE ��,�      JF�,E�zz   	F FE ���      JF�E�zz   	F FE�Eu�+!�,!�!�0 F
�-E]� F� 8�-��      JF�E5;�@��        F/ 0��      FF�E� Z�F
�E��F� E� �    FF ��E�      G�F
�Z� � �F
	~�F ,� � �JF� ��       E�Fu�E�F  � ��      � � FH� � !� ��      F�E��     F �F��"� ,"Fl�E��     FFF  BF-�E;�@��      F ~;�@�       � F�E>�@�      FLF@ ��.E�      G�/F
�Z��. �F
	��.F. >��. �JF��/�       E�Fr�.E�/F   ��.�      ��. FH��. !��.�      F�.E�.�     F �F�
�"�,"F�/E�/�     F FEFE r�+�z   	 �+�JF
� E� �+F-�F �FF� E� ��      FFF �� �      F :resume-Sprungmarken suchen� E�      FgFE�E�resumeFe,�Fg �� �      JF�E;�@� �@    F�E>�@� �`    F 	P;�@�       � F�E>�@�      F	F@�EC�@�ELSE F 	���      JF�EC�@�Else FFE 	���      JF�EC�@�else FFE�,EC�@�  F�EC�@�: Fm�0E6� �     F  	���      JF�E�zz   	F FE 
"�,�      JF�,E�zz   	F FE 
F��      JF�E�zz   	F FE�Eu�!�,!�!�0 F
�-E]� F� ��-��      JF�E5;�@��        F/ ���      JF�E� Z�F
�E��F� E� �    FF 
��E�      G�F

�Z� � �F
	
��F �� � �JF� ��       E�Fu�E�F  j� ��      � � FH� � !� ��      F�E��     F "F��"� ,"Fl�E��     FF F �F- ���     JF�E;�@��      F �;�@�       � F�E>�@�      F�F@& ���next ��Next ��NEXTJF B�.E�      G�/F
BZ��. �F
	(�.F. ���. �JF��/�       E�Fr�.E�/F  ���.�      ��. FH��. !��.�      F�.E�.�     F nF�
�"�,"F�/E�/�     F FEF FEF
� E� �FF �� �      FF :gosub-Sprungmarken suchen� E�      FF �E�gosub F*,�Fg�|F �� �      JF�E;�@� �     F�E>�@� �@    F�EEC�@�ERROR F  ��E�      JF�EEC�@�Error F FE ��E�      JF�EEC�@�error F FE ;�@�       � F�E>�@�      F�F@�+EC�@�, Fm�,EC�@�  F �EC�@�: Fm�0E6� �     F  x�+�      JF�+E�zz   	F FE ��,�      JF�,E�zz   	F FE ���      JF�E�zz   	F FE�Eu�+!�,!�!�0 F
�-E]� F� P�-��      JF�E5;�@��        F  H��      JF ^�E�      JF��F E�Z;�@��       F�FE�F�     F FE�E� Z�F
�E��F� E� �    F ��E�      G�F
�Z�� �F
	��F D�� �JF���       E�Fu�E�F  &���      �� FH�� !���      F�E��     F �F�
�"�,"F�E��     FF FE �F �E;�@��      F �;�@�       � F�E>�@�      FdF@ ��E�      JF
��F E�F�FE�F�     FFFE ��.E�      G�1F
�Z��. �F
	��.F. ���. �JF��1�       E�F�.E�1F  h��.�      ��. FH��. !��.�      F�.E�.�     F  F�
�"�,"F�1E�1�     F FEFE ��+�z   	 �+�JF
� E� �+F-�F �F�� E� ��      FFF 0� �      FF�&|F��EA� �  ��FM�    !�F
 *ZrM�      F�zF �|F.8FEF*�$Tabelle aller angesprungenen Zeilen:Fu2�+Zeilennummern von  <GOTO> oder <RESUME> :  "F  ��E�     G�F� � "�,"Fn
	��F F*�#Marken von <GOTO> oder <RESUME> :  "F> �.E�     G�/F��. "�,"Fs
	�.F F$�Zeilennummern von <GOSUB> :  "F< n�E�     G�F�� "�,"F 
	V�F,F �Marken von <GOSUB>:  "F> ��.E�     G�1F��. "�,"F 
	��.F,FF :�4Davon Zeilennummern oder Marken von ON ERROR GOSUB: "F�FE�       F  :��F � Fu��F "�,"Fr�FE�F�     Fu
F�FFE$:�Ausdrucken der Tabelle (J/N)"� F �� �J� �jJFl;F ;F*;�$Tabelle aller angesprungenen Zeilen:F &;� Ziel von  <GOTO Zeilennummer>:  "F  �E�     G�F;� � "�,"FG
	��F ;F  ;�Marken von <GOTO Marke>:  "F P�.E�     G�/F;��. "�,"F<
	8�.F ;F&;� Ziel von <GOSUB-Zeilennummer>:  "F ��E�     G�F;�� "�,"FO
	��F,;F";�Marken von <GOSUB Marke>:  "F: ��.E�     G�1F;��. "�,"F<
	��.F,;F ;F :;�4Davon Zeilennummern oder Marken von ON ERROR GOSUB: "F�FE�       F  x��F � Fu;��F "�,"Fr�FE�F�     FuHF�;F;FF D :################################################################D :################################################################v�L�FA-�FF+�FF�
Fehler Nr."�Fi.:�&Fortsetzung mit n�chstem Befehl (J/N) "� F �� �J� �jJFh��F �F $�Zum Abbruch eine Taste dr�cken!FF#� ESF�� � F��FFF.F�|FFF9�TEIL B:F �KONVERTIEREN DES PROGRAMMSFFE4:�,Ausdrucken des konvertierten Programms (J/N)"�F�E�      F �E�      F 7�i!M�     !�
auxdat.korF7�o!M�    !�
F�bearbeitete Zeile:F9�E�      F��E�      F�F=`M�      !�F�F�
�E]� F �E5;�@�  F�"F ��J��jJFl;�"FF�E>�@��      F T;�@�       � F�E>�@�      F"F@ �;�@�       �:JFi�E>�@�      FFE :Zeilenmarken feststellen ��� �  � � �      F �E��     Fa�F� �� � JF�E�ZA� ���:�F-�F F >���  �� �      FH�E��     F�F� $��� JF� E�ZA� F�FE�       F �� ��F  ��F � F�FE�F�     F�jF� �� ��F JFH�E�
PROCEDURE � �-:RETURN(nach letztes RESUME zu verschieben!):�F   FR�E�
PROCEDURE � �:�Fz-�F FEFE�|F �EC�@�: F# ���      JF�.E�      F & �;�@��      ��.  ��. � FF�.E�.�     F�XF� �;�@��      ��. JF �E;�@��      ��>�@� F-�F F F �|F �EC�@�: F  >��      JF�.E�      F & T;�@��      ��.  ��. � FF�.E�.�     F�F� :;�@��      ��. JF�FE�       FR ���. ��F  ��F � Fv�FE�F�     F �F� ��. ��F JFN�E�
PROCEDURE ��. �,:RETURN(nach letztes RESUME zu verschieben!)>�@� F 6F�E�
PROCEDURE �FF FEFE�|F   : THEN...ELSE Konstruktioneni� E�     Fb�2E�     Fe�|FF� E� �    F �2E�2�    F�E�thenF ,�Ft �� �      JF�E;�@� �@    F�E>�@� �     F�E��:��:ENDIFFFH� !�2F� E� �`   FA�E�elseF ,�FeH� !�2F ��2�      JF�E;�@�2�      F�E>�@�2�     F�E��:ELSE:�FFF -�F�F|
�E�onFa,�Fo  F� �      JF$  B?�@� �    @�      � JF 0  >� �     ?�@� �      @�      �:JF �2E� �@   F? P?�@�2@�      � F�2E�2�     F F��E��@� @�2�      F�E?�@�2@��2 F6  :C�@�error C�@�Error C�@�ERROR �      JF�E��     FF �?�@�@�      � F�E��     F �F�� E?�@�@�     F&  6� �GOTO� �Goto� �gotoJF ,�	F�F	F F	F	F	*  �;�@�       � ;�@�       �:F�E>�@�      F FF@ "r�� F�E�     F �E�       F��E�       F* !p��F�E��@�:@��      F !H��F�E��@B�    @��      F�E��@B�    @��      F
 !HZ��       F �F@ 
 !pZ��       ��       F3 �F� !���      JF�E�F��E� F�,�F@,�F� "jF !���@   JF� E?�@��@   @�@    F !�F� E� FFE" ".� �rem� �REM� �RemJF�E�F��E� F�,�F@,�F "fF��E;�@��      F�E>�@��      F,�F@,�FFF �F@
 "�ZrM�      F�Fr8F A�
auxdat.korFdF�Anzahl der Zeilen  "�*FF*"�Liste der Schleifenvariablen:F #�E�     G�@F�� "�,"Fd
	"��F F$:� Ausdrucken der Liste (J/N)"�Fr #���j��JJFt;F";�Liste der Schleifenvariablen:F #��E�     G�@F;�� "�,"F.
	#��F F �|FFF=0�(Dateiname des konvertierten Programms:  "�
F>�9Konvertiertes Programm ist abgespeichert im ASCII-Format,F�daher Laden mit  MERGEFi�F�r Ende [E] dr�cken!FF� ESF$X� �E� �eFqF 8 :====================================================+�FM�E��@�@�  Fx
�E� F��E��@�@�  F  %��      JF�E�zz   	F FE %&��      JF�E�zz   	F FE� Eu�!� F %V� �z   	JF� E�       F FE.FE+�F�E�F��E�F��E�for FE� E�      Fi,�Fn &�� �      JF�2EC�@�= F (��: E?�@� �     @�2�     �  F  &
�?E�      G�@F
&
Z��? ��: F9
	%��?F  &���? ��: JF9��@�       E��: F�?E�@F? &���?�      ��? FH��? !��?�      F�?E�?�     F &<F��@E�@�     F FE�:E�:�     F  '�F�J '|C�@�resume �        C�@�RESUME �       C�@�Resume �      JF�E�nextF� E�      F ,�Fn 'x� �      JF�:E�:�     FF�-EC�@��:  F 't�-�      JF�E�� ��: F FEFEF FE�E�F��E�F�.F+�FF '�<� ��JF
�E6� F�E;�@��      �:FFE�E�B� P    F (;�@�       � F�E>�@�      F'�F@M�    !�F&��`    "�*�     "�� p    "�F- (���J��jJFe&;��`    "�*�     "�� p    "�F-F�*E�*�     Fa.F�+�	F��E;�@� �      F�E��@�:@��@    F (���      JF�E6� �     FFE�E>�@� F�E?�@� @��  � F
�E6� F�� E��    � F�%E�       F��|F�%E�%�     F�E��@�,@�  F )���      JF�E�F@FE�E?�@� @��  F )��� JF��E��:F�FE4�E��IF ��=A�% � THEN:GOTO ��:ENDIFF � E��     F *��JF-�F�F *B;�@�       �:JF/�E>�@�      FFE
�E��F.FE�                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       0     � � �     #�                                 �`         � J     D * �)H                                             �     �`       '�         $� %`     (�