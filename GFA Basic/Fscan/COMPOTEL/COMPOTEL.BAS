 GfABASIC      (  ~      2  2  2  2  �  :  :  :  �  ,  6    p  h  n  �  �  �  �  �  Z  Z  Z  Z
LNG_BUFFERADRSUCCESBEGADDRENDADDRPOINTERBUFFPOINTERSRCDSTSRCCLKPRESCALEPROTOCOLMODEDONNEESNDCMDREG
PLAYTRACKS	RECTRACKSMONTRACKGAIN_INDSRON_OFFEIAMULCOEFFDEBUTTAILLECOS0COS0.1COS0.2	FREQUENCE	FRAQUENCE
FREAQUENCENBREPDUREEFECH
NB_PERIODENB_PERIODE4RAPPORTKXPTSINXFSIGNALSIN0RAPRAZPVALNBRE_PTSALPHACOS_2X_KM2X_KM1X_KADR_DEBFSIGNAL1FSIGNAL2FREQ1FREQ2X_ALPHAX_COS_2Y_ALPHAY_COS_2Y_KM2Y_KM1Y_KOPER	CODE_OPER	NBPERIODE	ADR_SINUSNBPOINTADR_BUF_TEMPADR_BUF_TEMPORAIRENBVAL1PASADR_FREQMEM STRUCBUFFERKEYANOMHAUTBASHAUT2BAS2TCHCAR	SINUSBASEROUTINECODE
TEXTEPARAM PASLEVELX1X2Y1XYY2STGAIN_INH1LHH_ECRANL_ECRANHECRANMODEGAIN_OUTRET
SPACE_DISKREPONSEADR_HAUTADR_BASIVALDEBUTTAILLEXMAXCPTPTSDKDECALAMPLLARGVAL_XVAL_Y	ADR_SINUSNBPTSADRESSEADR_BASEADNBPOINT	SINUSBASENB_VAL2NB_VAL1NBVAL1POINTEUR_SINUSNB_VALNBREPNBVAL2NB_PERIODE1NB_PERIODE2ADR_BUF_TEMPROUTINECODEIM_ECRANIM_8	BASE_COULLONGUEUR	LONGPARAMPOSTRIGMEMO
MEMO_SAUVE SHLSPEEKCMDFREZ FIN_CHARGER_FSCFIN_SAUVER_FSCSAUT	TONALITES
RETR_8BITSADDITIONADDITION_ASM 
TRAITE_KEYSELECTSWITCHCASEAFFICHE_KEY
PROCEDUUREFINVALSETCOLORSAVE
DEVCONNECTSOUNDCMDSNDCMD	SETBUFFERFIXEBFFSETMODE	SETTRACKSBUFFOPERSETHPSET_HPHP_ONHP_OFF	BUFFOPPERSETMONTRACKSBUFFPTRCHARGE_SAMPLECHARGER_FSC
SAUVER_FSCTRACESPOKEPOKETRACE_SAMPLECOSCREATION_SAMPLEGENERATION_SAMPLENEXTRAP	TRACE_COS
GENERE_COS
GENERE_SINGENERATION_TONALITEINIT_DMAEMET_TONALITEPBOXGENERATION_SINUS_BASETESTER_TEXTE_PARAM  *** **** ***** COMPOTEL **m *** **** ***.Auteur FSCAN, derni�re version le 03/12/951 LComposeur de num�ro t�l�phonique (pass� en param�tre ou entr� au clavier)8Ce programme peut etre ex�cut� de plusieurs fa�ons :o&=> Comme .PRG appel� directement : @  num�ro compos� au clavier pendant l'ex�cution du programmeh=> Comme .TTP :>  num�ro de t�l = param�tre pass� dans la ligne de commande=> Comme .PRG :J  cr�ation d'un fichier factice dont le nom comporte le num�ro de t�l.L  puis faire glisser icone de ce fichier factice sur le programme actuelL  ex. de noms : "46223344.TEL", "16146223.344", "11.TEL", "3614.TEL", ...=> Comme application GEM :n4  cr��er des fichiers factices dans un r�pertoireJ  installer une application du type appel du prog par les fichiers .TEL :�X� � @  F1 Reserve de la m�moire pour les Mallocso M�-F�J@Hp_off                        !  => d�fini librement par l'utilisateur<l� �  
!#2��  
 � F   Coupe/R�tablit le clic clavier ,�$E�LL�����F Dur�e du sample en secondes�
E�F Fr�quence = 25 kHzm,�%E�@@  Fe Fr�quence d'�chantillonnage�E�F 8 bits mono<�E�     Fd Gain en sortie �ventuellement (cf Init_dma) YF  �COMPOTEL 03/12/95 par FSCANFF 2 O��� F Si pas de num�ro pass� en param�tre"�Appuyez sur une des touches :F&� 1,2,3,4,5,6,7,8,9,A,B,C,D,* ou #FtF �Cliquez pour quitterF F �E� F� O�#R� F�ESF O�#��  FM�*��!�$ FF O�F PF�Composition du num�ro : "F P�=E�G6� F�E?�@�=@� FM�*��!�$ F
	O��=FGF <l� �  
!#2��  
 � F   Coupe/R�tablit le clic clavierqF  +�*��!�$ FR�FF�	E� F"
�E� F   P�##��	  #�	�FinData  FsQ�	!�9!�:F P�F# QJ#��	 F�"F.M�(��9!�: F G�n�ration du sample en m�moire<M�)�� F Audition du sample (1 seule fois, pas en boucle)*{�     FuM��� FF  8DATAs sous la forme : touche$,fr�quence1%,fr�quence2%�|F#0,1336,941 1,1209,697 2,1336,697 3,1477,697 4,1209,770 5,1336,770 6,1477,770 7,1209,852 8,1336,852 9,1477,852 *,1209,941 #,1477,941 A,1633,697 B,1633,770 C,1633,852 D,1633,941 FinData,10,10.F  
+�)��E F  M��� F �E�F	 DMAPLAY�E�F	 reli� au DACi*�	E�F horloge interne (compatible STE)E&Prescale=3    ! fr�quence => 25 kHz�E�F mode non handshakingaM�
��!�!�	!�
!� F  "SOUNDCMD(LTATTEN,Gain_out << 4)�E�F Gain sortie gauchet�E��    F�B @Sndcmd(Mode,Donnee)   ! => D�fini librement par l'utilisateur "SOUNDCMD(RTATTEN,Gain_out << 4)�E�F Gain sortie droitet�E��    F�B @Sndcmd(Mode,Donnee)   ! => D�fini librement par l'utilisateur SOUNDCMD(ADDERIN,adderin)&�E�     F� ADDITIONNEUR ADDERINT<�E�F branchement sur l'entr�e micro (ADC) et la matrice'M���!� F $SETBUFFER(0,adr,adr+lng_buffer+1)<�E�F Buffer utilis� pour la lecture (1 = enregistrement)�E�F=*�E�� �F Dernier octet du Buffer + 1M���!�!� F� SETMODE(1),mode=0 !  8 bits st�r�omode=1 ! 16 bits st�r�omode=2 !  8 bits mono�E�F
M��� F� 6�E�F Nombre de pistes utilis�es en restitution - 1:�E�F Nombre de pistes utilis�es en enregistrement - 1tM���!� F 2M��� F S�lection de la piste qui sera �cout�eo "M���E F�	 Restitution en boucle.F   +�(��;!�< F� E%��%�$ F0�IE��   !��  F R�servation m�moire buffer 0�E��   !��  F R�servation m�moire buffere�E��     F
�%Ez� F  ZB#�� F$G�n�ration du buffer temporaire :
�4E�<�$F,�,E��%�<F	 Nombre de valeurs par p�riode�LE�     �,FM�,��I!�,� F W��E�G�4�F��I!�I��,!�,Fv
	W��F G�n�ration du buffer en Adr :
�3E�;�$F,�-E��%�;F	 Nombre de valeurs par p�riode�LE�     �-F�/E�%F�M�,��!�-� F X|�E�G�3�F��!���-!�-Fv
	X`�F (Addition des buffers => buffer en Adr >Chargement de la routine de retraitement Basse r�solution:eR�F �E� F F Q�FF
 Y<Z��finF�E�&H�F
�7E5� FF�E�b�7 FX�Fb�6E��   !�� (    F�z� !�6!� (   F�|F 4206F,0004,226F,0008,246F,000C,2012,1210,1419,0241400FF,0242,00FF,D242,0441,00FF,E241,10C1,51C8,FFE84E750fin �;E� F!���6���!��I!�z�;  F2���   !��6 F ���   !��I F���   !�� F ZxF.�)Pas assez de m�moire pour cr�er le sampleFqF F .F  +�,��%!�* F�E�O�*FF [�E�G�*�H�F�E�~~   �~   )�� F  Z�#�� FF0�!�    FF �%�!�Fe�%��!�Fr
	Z��F .F  :******************************************************  +�F &���h   !� F R�tablit le son du HP.F +�F *���p   !�     F Coupe le son du HP .F +�
��!�!�	!�
!� F ���   !�!�!�	!�
!� F*.F +���!� F���   !�!� F.F +���!�!� F*���   !�!��!�� F*.F 
+��� F����   !� F .F +���!� F���   !�!� F.F 
+��� Fe���   !� Fn.F 
+��� FF���   !� F�.F 
+��� F����   !�� F.F  :******************************************************  +�-F �<E2y�     F�E� F  ]x#�<� F  ]t�=E�G�<F�E�B2y�    ��=  F
	]P�=FF .F �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            Q�        Yn                                        �[�    �[�\    �\:�\X�\�         [X [�    �\z�\�                                                            �V��R��P\    �Z� ]