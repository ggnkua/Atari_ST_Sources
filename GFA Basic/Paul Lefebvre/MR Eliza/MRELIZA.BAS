 GfABASIC       @   l   �   �   �   �   �   �   �   �   �   �   �     #,  #�  #�  #�  #�  $  $  $  $  $4  $D  $D  $D  $DSNDXBUFPHENOMESPEECHBUTTONBPAGEPRGN1N2N3QLVSKT TALKABPHENOMESPEECHZIPKFCSRTXTIKSPEECHPHENOME MUTETXT SRNELIZASAY_IT	GET_INPUT
START_DATASPEECH_DATA230570510540557INIT_SPEECHTALKFREEMEM( Mr. Eliza - The Talking Psychiatrist  (c) Creative Computing   8 Converted to GFA BASIC 2.0 by Paul Lefebvre   2-23-92" GEnie mail address : P.LEFEBVRE    J ======================================================================   &*� �    !��    !��    FM� F� E�F� E�F-� F �|F 
M���  F-�F L =========================================================================  J The following two procedures are used to access STSPEECH.TOS for sound   L -------------------------------------------------------------------------+��� Fq  Talk to me...  z��  � Fl�E�F z��7�.  �7�* F��!6� F�E�B� F �z� !��!6� F|�F!|�F!F {�     F!j�!�FF .F   L ------------------------------------------------------------------------   +� F  Thanx to Dave Morrisonh� !�!�!�F
 }F� F {���STSPEECH.TOS F,)�!�Can't find STSPEECH.TOS.!�!�Abort!�FqF F &�X� � b�  Fd  Reserve some space.�E��!�STSPEECH.TOS!� !�  Fe  Load ML file�E��    F.��`   !�   F ��p   !�j   F ��X   !�   F ��Z   !�j   F �E��]�  F �!�~   F �E��H   F �E��   F R�F |�� E�G�@   F Q�F��E�B� F�E�B� F
	|�� F �E�c� F�E�c� F }.� E�G�@   F Q�F��E�B� F�E�B� F
	}� F 
�Ez� FF
�Ez� FFF .F �|F>&h48,&he7,&hff,&hfe,&h4e,&hb9,&h4c,&hdf,&h7f,&hff,&h4e,&h75H =====================================================================  � |F,��    "�	Mr. ElizaF&��`    "�(c) Creative ComputingF &��`    "�Morristown, New JerseyF F B��    "�2Converted to GFA BASIC 2 by Paul Lefebvre  2-23-92F .��8    "�GEnie mail address : P.LEFEBVREFF 6��    "�'(To end your session, type : 'Shut up')FF DM���;Thanks to Paul Lefeever for giving me the courage to speak. FF 2�-Do you want my comments output to the screen?F6M���-Do you want my comments output to the screen? F:�F 
�E� F@ �?�@�@� �YJF�E�F �F��E�FF T�N==============================================================================F F *  ---------- Initialization -----------,�E�   F �	E�``   F �
E�``   F R�F` ���E�G��	�
FQ�F�
	���FG ���E�G�FQ� � !�F�� E� � F��� E� � ��F
	���F
 �2�JF2�,Hi!, I am Mr. Eliza.  Tell me your problems.FSF 8M���/HI I AM MISTER E LIE ZA. TELL ME YOUR PROBLEMS. F  ,  ---------- User input section ----------  �|F-:�F-
�E� F�E� ��  F --- Get rid of apostrophes  �&�E�G6� F�|F� �4?�@�@� �/JFo�E;�@�� =�@6� � FF-�FF  ���    6� JFF> �?�@�@�     �SHUT�� QUIT�� STOP�� BYEJF
 ���JF:�5I hope I was able to help.  Your bill is in the mail.FF >M���5I hope I was able to help.  Your bill is in the mail. FqF F F 
	���Fn ����JF,
 �d�JF"�Please don't repeat yourself!FF &M���Please donte repeat yourself Fr-�FeF   & ------- Find keyword in I$ --------  R�F-�E�F �R�E�G�FQ�F� �H��JF �D�E�G6� 6� �FI �:?�@�@6�  �JF$�E�F@�E�F@�	E�F@F 
	��F�F 
	���F� �v��JF�E�F��E�F� ��F��E�   F6-�FF " --- We didn't find any keywords  0    Take right part of string and conjugate it.    using the list of strings to be swappedi  R�Fs �:�E�G�FQ�F�
	�*�FG �
E� =�@6� 6�	 �� � F ���E�G�	�FQ�!�F ���E�G6�
 F ���6� 6�
 JF-�F�F  ��?�
@�@6�  �JF-�F?F &�
E;�
@�� �=�
@6�
 �6� � Fi�E�6� F-�F�|F ��6� 6�
 JF-�F�F  �@?�
@�@6�  �JF-�F?F &�
E;�
@�� �=�
@6�
 �6� � Fi�E�6� F�|F
	���F 
	�j�F  ��?�
@�@� � JF �
E=�
@6�
 � F only 1 spaceF  � �E�G6�
 F�	|F� �?�
@�@� �!JF1�
E;�
@�� =�
@6�
 � F-�	F
F 
	���F  0   Now using the keyword number (k) get reply  �|FwR�Fw ���E�G��	FyQ�F�
	�v�FG ���E�G�� FyQ�	F�
	���FG�� E�� �Fy ���� �� JFr�� E� � FJF   L The following lines are responsible for outputting Mr. Eliza's response.    �t=�	@� �*JF
 �X�JF�	F�F 
M���	 F �E�F -�FFF � E;�	@6�	 � �
Fr
 ���JF� F�F 
M���  F �E�F -�FF  " --------- program data follows(   keywords   �|Fo8"CAN YOU","CAN I","YOU ARE","YOURE","I DONT","I FEEL">"WHY DONT YOU","WHY CANT I","ARE YOU","I CANT","I AM","IM":"YOU ","I WANT","WHAT","HOW","WHO","WHERE","WHEN","WHY"8"NAME","CAUSE","SORRY","DREAM","HELLO","HI ","MAYBE"Y8" NO","YOUR","ALWAYS","THINK","ALIKE","YES","FRIEND"Y"COMPUTER","NOKEYFOUND"    STRING DATA FOR CONJUGATIONS,  <" ARE "," AM ","WERE ","WAS "," YOU "," I ","YOUR ","MY "&" IVE "," YOUVE "," IM "," YOURE " " ME "," !YOU "  
 REPLIES  ""DON'T YOU BELIEVE THAT I CAN*"*"PERHAPS YOU WOULD LIKE TO BE ABLE TO*" "YOU WANT ME TO BE ABLE TO*"s "PERHAPS YOU DON'T WANT TO*"  "DO YOU WANT TO BE ABLE TO*"  "WHAT MAKES YOU THINK I AM*" ("DOES IT PLEASE YOU TO BELIEVE I AM*"""PERHAPS YOU WOULD LIKE TO BE*"$"DO YOU SOMETIMES WISH YOU WERE*""DON'T YOU REALLY*""WHY DON'T YOU*"* "DO YOU WISH TO BE ABLE TO*"R"DOES THAT TROUBLE YOU?"O&"TELL ME MORE ABOUT SUCH FEELINGS.""DO YOU OFTEN FEEL*"U"DO YOU ENJOY FEELING*"$"DO YOU REALLY BELIEVE I DON'T*" ""PERHAPS IN GOOD TIME I WILL*""DO YOU WANT ME TO*" ("DO YOU THINK YOU SHOULD BE ABLE TO*""WHY CAN'T YOU*" 4"WHY ARE YOU INTERESTED IN WHETHER OR NOT I AM*" $"WOULD YOU PREFER IF I WERE NOT*"&"PERHAPS IN YOUR FANTASTIES I AM*"O$"HOW DO YOU KNOW THAT YOU CAN'T*""HAVE YOU TRIED?""PERHAPS YOU CAN NOW*"O("DID YOU COME TO ME BECAUSE YOU ARE*""HOW LONG HAVE YOU BEEN*"("DO YOU BELIEVE IT IS NORMAL TO BE*""DO YOU ENJOY BEING*"$"WE WERE DISCUSSING YOU, NOT ME.""OH, I*"D2"YOU'RE NOT REALLY TALKING ABOUT ME, ARE YOU?""*"WHAT WOULD IT MEAN TO YOU IF YOU GOT*""WHY DO YOU WANT*" "SUPPOSE YOU SOON GOT*""WHAT IF YOU NEVER GOT*"U"I SOMETIMES ALSO WANT*"U"WHY DO YOU ASK?"&"DOES THAT QUESTION INTEREST YOU?"O("WHAT ANSWER WOULD PLEASE YOU MOST?"*"WHAT DO YOU THINK?"E,"ARE SUCH QUESTIONS ON YOUR MIND OFTEN?"Y,"WHAT IS IT THAT YOU RELLY WANT TO KNOW?" "HAVE YOU ASKED ANYONE ELSE?"*"HAVE YOU ASKED SUCH QUESTIONS BEFORE?"0"WHAT ELSE COMES TO MIND WHEN YOU ASK THAT?"""NAMES DO NOT INTEREST ME.","I DON'T CARE ABOUT NAMES, PLEASE GO ON.""IS THAT THE REAL REASON?"P*"DON'T ANY OTHER REASONS COME TO MIND?","DOES THAT REASON EXPLAIN ANYTHING ELSE?"("WHAT OTHER REASONS MIGHT THERE BE?"S"PLEASE DON'T APOLOGIZE!"""APOLOGIES ARE NOT NECESSARY." 2"WHAT FEELINGS DO YOU HAVE WHEN YOU APOLOGIZE?""DON'T BE SO DEFENSIVE!"E*"WHAT DOES THAT DREAM SUGGEST TO YOU?"L"DO YOU DREAM OFTEN?"("WHAT PERSONS APPEAR IN YOUR DREAMS?"&"ARE YOU DISTURBED BY YOUR DREAMS?"."HOW DO YOU DO. PLEASE STATE YOUR PROBLEM."""YOU DON'T SEEM QUITE CERTAIN.""WHY THE UNCERTAIN TONE?" "CAN'T YOU BE MORE POSITIVE?""YOU AREN'T SURE?"P"DON'T YOU KNOW?","ARE YOU SAYING NO JUST TO BE NEGATIVE?".""YOU ARE BEING A BIT NEGATIVE.""WHY NOT?"I"ARE YOU SURE?""WHY NO?"$"WHY ARE YOU CONCERNED ABOUT MY*""WHAT ABOUT YOUR OWN*"A*"CAN YOU THINK OF A SPECIFIC EXAMPLE?""
"WHEN?""WHAT ARE YOU THINKING OF?""REALLY, ALWAYS?""DO YOU REALLY THINK SO?""BUT YOU ARE NOT SURE YOU*""DO YOU DOUBT YOU*""IN WHAT WAY?"O""WHAT RESEMBLANCE DO YOU SEE?"A."WHAT DOES THE SIMILARITY SUGGEST TO YOU?"("WHAT OTHER CONNECTIONS DO YOU SEE?"Y,"COULD THERE REALLY BE SOME CONNECTION?""
"HOW?"T"YOU SEEM QUITE POSITIVE." "ARE YOU SURE?""I SEE."S"I UNDERSTAND."."WHY DO YOU BRING UP THE TOPIC OF FRIENDS?" "DO YOUR FRIENDS WORRY YOU?"C "DO YOUR FRIEND PICK ON YOU?"("ARE YOU SURE YOU HAVE ANY FRIENDS?"E$"DO YOU IMPOSE ON YOUR FRIENDS?"S0"PERHAPS YOUR LOVE FOR FRIENDS WORRIES YOU."?"DO COMPUTERS WORRY YOU?","ARE YOU TALKING ABOUT ME IN PARTICULAR?"$"ARE YOU FRIGHTENED BY MACHINES?"$"WHY DO YOU MENTION COMPUTERES?">"WHAT DO YOU THINK MACHINES HAVE TO DO WITH YOUR PROBLEM?" 0"DON'T YOU THINK COMPUTERS CAN HELP PEOPLE?"U0"WHAT IS IT ABOUT MACHINES THAT WORRIES YOU?"2"SAY, DO YOU HAVE ANY PSYCHOLOGICAL PROBLEMS?" $"WHAT DOES THAT SUGGEST TO YOU?"A"I SEE."S*"I'M NOT SURE I UNDERSTAND YOU FULLY."B("COME, COME ELUCIDATE YOUR THOUGHTS." "CAN YOU ELABORATE ON THAT?"O "THAT IS QUITE INTERESTING."O  " DATA FOR FINDING RIGHT REPLIESG  01,3,4,2,6,4,6,4,10,4,14,3,17,3,20,2,22,3,25,3428,4,28,4,32,3,35,5,40,9,40,9,40,9,40,9,40,9,40,9449,2,51,4,55,4,59,4,63,1,63,1,64,5,69,5,74,2,76,4"80,3,83,7,90,3,93,6,99,7,106,64�                                                                                                                                                                                                                                 }� y, �� �� }P �� �^ �  �x �� {:�z&        