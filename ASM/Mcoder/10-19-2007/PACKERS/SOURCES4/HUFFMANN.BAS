 GfABASIC       J   X   �   �   �   �   �   �   �   �   �   �  j  �    �  �      T  `  r  r  v  z  z  z  fXN1IVITJKEB1B2B3B4LENGTHUSINGABCDFGHLMNOPSOMME FILETFILOUTILENGTHJKB1B4B2LNBBM1M2SNLIABIAINIMIXZIRPFILECODETREEIYBIN IRCODETREE HUFF DICHO Programme d'analyse de datar,Indicateur du coefficient de compression n7�o!M�!�prn:FM�F M�!�DATANALYSISF M�F�M�!�LECTURE DU FICHIER "� FM�F����F �E�pp   FF *� � F c\� E�G�FQ� �  F0�!� �  FF
	c>� F�AffichagefBM�!�OCTETS TROUVES DANS "� "� TRIES DANS L'ORDRE DECROISSANTF M�F *Attribution d'un code pour chaque octett*�� F d� E�G�F
��  E� F
	d � F  Tri des occurencesd0 Par ordre d�croissant num�rique et par codenP eN� E�G��F�E� F  d��E� �G�Fe d�� � � � F�E�Fe d�F  d�� � � � F d��� �� F�E�F F F FE
	d��F  eD�� F
�E� �  F� �  E� � Fh
� � E�F
�E��  F��  E�� Fh
�� E�FF 
	dr� FFFr�quence des occurencesNr*�� F e�� E�G�F��  E� �  �F
	e�� F EAffichage des occurencesaf f
�E�G�p   H�    FcM�!�� "�BYTE COUNT    %"F 
	e��FGM�F� f�� E�G�F��E�F  f��E� G� �@   H�    F M�!�� "�$"=�0n��  @� "F""M�!���     "��#####!� � "F$M�!���     "��###.##!�� "FR0�!�    F�
	fD�FM�F 
	f� F 
Calcul de l'entropie aM�F�M�!�ANALYSE DE L'ENTROPIEFM�F��E�F gf� E�G�F g\��  �F�E���  0��   0� F FE
	g0� F ,�E%��� Fon ajoute un bit au maximum0�E��    Fe�
E#�� ��H   F >�E%#��`    �      F
on arrondit � l'octet sup�rieurrM�!�Entropie : "FM�!��##.##!�"FM�!� bits par octetFRM�FF6M�!� "�
 contient "�"� octets soient "�"� bitsF M�F�:M�!�$Compression statistique th�orique : "��###.##!�
"F
M�!�%FmM�F�0M�!�&Taille du fichier apr�s compression : "F#&M�!�"� bits soient "�"� octetsFi| CALCUL DES CODES DE HUFFMANN AM�FF$M�!�CALCUL DES CODES DE HUFFMANF0M�F�
Nb%=255 i�� � �F5�F�izF  *��#�� �@� F� jT� E�G�F2�� @� E� �  FS	 valeur pour Hu-Tucker algorithm.�� @� E�F lien nul pour la feuille gauche.�� @� E�F lien nul pour la feuille droite
	i�� F�FEe,recherche des 2 valeurs les plus petiteste(Pour cela, on explore tous les noeudsFet � chaque fois, on calcule la somme des 2 valeurs les plus bassest2M1% pointe sur la valeur la plus haute des deux6M2% pointe donc sur la valeur la plus basse trouv�e2<�
E�Fc indique qu'il faut trouver 2 valeurs quelconquese�E�F� l�� E�G�F. l��� @� �F	 si noeud vide -> au suivant l��F�E� F l�F lT�
�F l@�� @� ��@� F�
E�F �E� F  lLF �
E� F FE l�F  l��� @� ��
@� F l��� @� ��@� F�
E�F �E� F  l�F �
E� F FEFEFEFEF 
	k�� F@B
 nbZ�
�Ff s'il ne reste plus qu'une valeur, c'est fini !!!s2FA partir des 2 valeurs trouv�es, on cr�e un noeud ayant pour valeur la somme des 2 valeursl�E��
@� ��@� F4�Fs��@� E�F2��@� E�
F pointe sur la composante de gaucheu2��@� E�F pointe sur la composante de droiteu�*Ensuite on efface les 2 noeuds trouv�sg"  mais on garde leurs pointeurs��
@� E�Fe��@� E�FejXF  0A pr�sent M2% pointe sur la racine de l'arbre :On calcule ici les codes de Huffmann de chaque �l�ment nM� ��!�!� F8M�F�qF  :On parcourt l'arbre � la recherche des noeuds terminauxnI%=numero du noeud examin��(B%=code Huffmann en cours de d�calage(N%=nombre de bits du code de Huffmann%+� �� !�	!� F  pV�� @� �Fn,si le noeud examin� est un noeud terminal"on donne imm�diatement son code:M�!�	CODE DE $"=�0n��   @� "�="=�00000000p�	 @� F p�FEM� ��� @� !�	�!�� FM� ��� @� !�	��!�� FF .F Q�!�!�!�!�!�!�!�FQ�!�!�!�!�!�!�!�F6�E#���������������� F�FPrint (A+B+C+D+E+F+G+H)�#������     ��     ��     ��     ��@@   ��@@   ��``   ��``   ��@@   ��     ��     ������@@    FJPrint (A*2+B*2+C*5+D*5+E*4+F*5+G*6+H*6+I*7+J*7+K*6+L*8+M*8+N*3+O*3+P*6)*Print (A*2+B*2+C*5+D*5+E*4+F*5+G*6+H*6)F RF F Q�Ft rb��F+�E�F rxF�E0�� 0� F+F ��!�F�rBF!4Data &h8f8,&h7de,&hb3,&h138,&h18a,&hc4,&h78,&h9a6frequences des methodes4Data &h8d3,&h79d,&had,&h130,&h16b,&hb2,&h6c,&h8a2Data &h40,&h40,&h4a,&h1d,&h2a,&h5de,&h342,&h50a frequence des briques,0,&hb41,&h191,&h68,&h3e2,&h12a,&h43,&he1,.&hfa,&h107,&h15a,&h81,&h15c,&hf3,&h207,&hb3�                                          E6O�z            u�%�"                                                                                                                       O      Q  W<  
�  �x          ����     O                                                         u�                                u  uZ  v     �o�