Lionpoulos  �  �                                                    �  �   
 
� **   : � ** Routine to load and display an overscan picture    � ** (c) 1992 Top Notch  " (� ** Written by Colin A Watt   
 2� **   0 <� ** Part of the Misty registration package  & F� ** requires the Misty extension  
 P� **    Q� ** Modification List   
 R� **   & S� ** Martin Cubitt   20 July 1994  
 T� **   > U� ** Bank 15 added with a patch to allow more flexibility  6 V� ** Routine changed to take account of new parms  
 W� **    Z���:��:�ͦ:��       d�����    ,�  �N   < n� �z�F$�(�    *.big,�    Load an overscan picture)   x���z�F$��    �    頧   ��z� �z�F$,�       ����:��:�ͦ:��:��        n ����     ,�    ,�    ,�    ,�    ,�    ,�    ,�    ,�    ,�    ,�    ,�    ,�    ,�    ,�    ,�    :��(�)    ����(�   ),��,�  �N   " �������    ,����   �,�        �������    p,��,�   ��   
 �����   ` Ȋ *** areg(0)=default back : areg(1)=default back+63000 : call start(14)+28 : fade 1 : cls   ( ʊ a0,a1 are as before, then add...   $ ˊ areg(2)=start of Neil's code   > ̊ dreg(0)=type of wait (1 = wait for key X to be pressed   > ͊                       2 = wait for Y seconds to pass or  L Ί                       3 = wait for Y seconds unless key X is pressed)  N ϊ dreg(1)=number of seconds to wait, Y above. (NB. approx 1 second unit)   N Њ dreg(2)=key to wait for, X above. Eg. $1=Esc, $39=SPACEBAR, $9C=Return   z Ҽ(�     )���:�(�   )�����  �:�(�   )��(�    ):�(�     )��    :�(�   )��    
:�(�   )��    :���   :�q�   :�   
 ��:��    `  @           �          �H!�� L� �H� � �jN� �dBy ��Jy ��g�L� � �jH� � �*N� y�f�N� ��Nu?< %NNT�F�' p ���� �����	 ����� �B9���B9���	�  ����  ���B9���#� p �!� �� pF�# Nu!� � p!�  � !�		  � !�

  � � ��� ��	� ��Nu �>d>                                   ��� ?� �;���"�� � {� 9�<;=                                   ��� ?� �;���"�� � {� 9�<;= ��H���A� �*C��@"�"�"�"�"�"�"�"�0<�Q����  �
NqNqNqNqNqNqNqNqNqNqNqNq� �
C��	2< ?p g��@�hNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqrp A��
C��`>< �NqNqNqNqNqNq� �`�  �`NqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNq�  �
� �
NqNqNqNqNqNqNqNq� �`�  �`Q��NqNqNqNqNq� �`�  �`NqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNq�  �
� �
NqNqNqNqNqNqNqNq� �`�  �`�  �
NqNqNqNqNq� �`�  �`� �
NqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNq�  �
� �
NqNqNqNqNqNqNqNq� �`�  �`Nq>< NqNqNqNqNqNq� �`�  �`NqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNqNq�  �
� �
NqNqNqNqNqNqNqNq� �`�  �`Q��A� �
C��@"�"�"�"�"�"�"�"�L��Fy ��/9 �Nu   


* �� ��k�
��)�:�(r�U^(�#���+1�A��@�K��=�7�T]^G���R��prO/��`{0��$�"]$=7� �����s	������?� �	�                       `   �           �         #� ��#�     ��G� �|B G� ��B G� ��B G� T6�N��| f
&� �|N� �| f
&� ��N� &� ��N� 8 �Nu8 �R� ���   2 ��m#�     ��S� ���     ��Nu8 �g,R� ���   2 ��m#�     ��S� ���     ��Nu           







  �
NqNqNqNqNqNqNqNq� �`�  �`Q��A� u
C��@"�"�"�"�"�"�"�"�L��Fy u�/9 uNu   


* �� ��k�
��)�:�(r�U^(�#���+1�A��@�K��=�7�T]^G���R��prO/��`{0��$�"]$=7� �����s	������?� �	�                       