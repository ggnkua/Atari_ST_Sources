 GfABASIC       x   �   �   �            F  F  F  	�  �  &  �        R  R  X  X  X  l  l  l  ��SKXCXGRXYAOLDXOLDYICETHATTHEPOINTERHARDLYFLICKERSCOUNTTMYMXTOG11TOG12TOG13TOG14S_COUNTS_TOGCOL MOUSEMASKSCBAR2STFSPHERESPHERE_MASKG_SPRF_SPRA_SPRSCROLL_WINDOWGFA_DEMO_LOGOBAR1S AAABPHYSADRBCLRMOVEMOVEXMOVEYMOUEXMXMYXVALYVALSCREEN UNTILGET_SPRITESINIT
SPHERE_CALGFA_ANIM @       The GFA Demo! Part 3 - Main Part - (C) ST Format 1991.2                     Written by James Beswick.T ** VERSION 1.7 ** NThe routine that was on the coverdisk last month has now been incorporatedNinto the demo. You should start to see everything slowing down now, but it&will speed up when it's compiled... M�Ff "** THE DEMO CONTROL ROUTINE **r <6� 0   !�@   FO Now set all the colours! Colour 11...$6� @   !�    FO Colour 12...h(6� P   !�    FO Colour 13 set...o"6� `   !�F  Colour 14 set...e2j�!�!�!�F Toggle variables are needed here.(�!�!�!� @   Fo2F  Repeat the idented segment until key press.��FRM�FRM�F 0Y�!�@    ";�@�    F Display scroller.B�E=�@6� � ;�@� FF Calculate scrolling position - complex!��� !�� !�!�    Fl��� !�� !�!�@   FlH� !�F���    !�� !��!� Fl,�NS� F� Exit when a key is pressed... <6�!� n�  
F  Set the colours again for the editor, or we86� p   !�F  won't be able to see what we're doing!r*�F  Return straight back to the editor.  D** Long routines are pushed into procedures and put at the end ** +�F  ���E�G�   F �� E��� F �� E��� F 
	�^�F��     EPF��     EQF&���      !��      !�!�    FE&���      !��      !�!�@   FE&���      !��      !�!�    FE&���      !��      !�!�@   FE��� !�� !�	!�    F��� !�� !�	!�@   F.F  2+�Fo This routine GET's (some of) the sprites. �� B   !�!�^   !�p   !�F �� b   !�!�~   !�p   !�F ��    !�!�	   !�    !�F ��    !�!�   !�    !�F ��    !�!�   !�    !�	F ��!� P   !��  !�3   !�F ��!� 5   !��  !�=   !�F ��!� ?   !��  !�G   !�F&��     !�    !�G   !�L   !�F.F  +�F  ����F 0�!�F �F1�!�FF  ���x   F��E�FF  �4��F �E�FF .F  +�FD** INITIALISATION PART (GET THE SPRITES, SET THE MOUSE, ETC.) ** B*��      !��      F These are for the G.F.A. animation...P*� �{{�  �     !��xx    !��xx    F These four lines are the basisp&� E�� F! for the non-flicker routineB�E#z� �  �      � �  Ft to smooth out the animation...a�E�� F : ��E�G�    Fn Make sure that the start of the GFA<�� E�     Fs animation is not visible at the start.b
	���F  > �j�E�G�x   F  Read in the positions for the sphere...Q�� !�� F
	�R�F� ��E��H    ��ST Format proudly present the GFA Demo! This small demonstration shows off what is indeed the best implementation of Basic on any microcomputer. This was written with the earliest version of GFA Basic, version 2, F��E�ޫwhich was given away FREE with the February (nineteenth) issue of ST Format. This program has been slowly built up over a number of issues, and finally, here it is!       Ft �F  Hide the mouse.Dl� �  
!2� �  
  �F Key click off. Another weird instruction!YF  CLear the Screen. ��gfademo.pi1!�� �    F @���@   !��� �      F These 2 lines load the demo screen.�a� F 6M�F  Go directly to the procedure with this name.mN                              ! The procedure, once executed, returns here.YF  Clear the screen.F N�E�0   G�`   F  Loop the idented line three times, whilst26�!�FE incrementing COL by 1 from 11, until it6	 ��Fi reaches 14. This clears the logo colours.8��!�!�F
 Place the logo at the top of the screen and:��!� /   !�F Place two metallic bar sprites at these ��!� @   !�F positions...a*��F@ Now get the entire screen in SC$..F  B** 63 Data Lines Follow ** These are the sphere's positions **i 3,60 5,58 7,55 10,5114,4718,4222,4027,4034,4437,4742,5345,5747,5947,6050,5856,5166,4575,4283,4289,4695,5497,5798,60
102,55a
107,48a
116,44a
125,40a
129,41a
138,46a
145,54a
146,55a
148,59a
153,52a
160,46a
164,43a
172,41a
177,40a
185,42a
189,47a
192,52a
192,57a
193,52a
195,50a
198,44a
203,42a
207,41a
214,39a
222,40a
228,47a
234,53a
234,58a
235,54a
235,52a
236,48a
239,44a
244,39a
249,38a
258,38a
263,40a
266,45a
272,51a
272,52a
274,57a�                                                                                    |                                           @        p                �}  �� �f �~ ~ �� ~ �� V �H V �� V       �d/� ���  � �    �                                �  .  �x  ��  t      �� �B �� �J