Lionpoulos                                                                  
� MAIN PROGRAM   $ � PROGRAM = A:\MENUS\NUMBER.BAS   :   (�ͦ:��    :�ަ    2���     ,�  w,�      : <� ��BLACK��     :���WHITE��    :���RED��        F���   M$(�   
)   P:   Z� CALL SUBROUTINE  ` d� 
��NO_ENTRIES��   :���BCOL����RED:� ��FCOL����WHITE:� ���T$��    GAMES MENU    * n� ���M$(�   )��    Set level easy   , x� ���M$(�   )��    Set level medium   * �� ���M$(�   )��    Set level hard   . �� ���M$(�   )��    Display high scores  & �� ���M$(�   )��    
Start Game    �� A�   �    ����4I   ���    �:  (� MENU SUBROUTINE- NUMBER SELECTION  � HIDE MOUSE POINTER   ����  :  � FIND LONGEST ENTRY    �    LONGEST_ENTRY��        *�  B� �|A��    ��
��NO_ENTRIES    $� �vL��(� ���M$(��|A))  @.���vL�� �pLONGEST_ENTRY�   � �pLONGEST_ENTRY�� �vL  8���|A  B:  "L� CALCULATE SIZE AND POSITION  ,V� �^WIDTH�� �pLONGEST_ENTRY��       (`� �THEIGHT��
��NO_ENTRIES��      &j� �HX�(�   (���^WIDTH)��      (t� �BY�(�   ���THEIGHT)��       ~:  �� OPEN THE WINDOW  �����BCOL:�� ��FCOL   <����    ,��HX,� �BY,� �^WIDTH,� �THEIGHT,�      ���� ���T$   ��  �:  *Ċ DISPLAY MENU ENTRIES WITHIN WINDOW   *Ν  C�� �|A��    ��
��NO_ENTRIES   &ء��|A;�    .;� ���M$(��|A)   ���|A  �  ����    ENTER OPTION    :  
� WAIT FOR USER INPUT  � ��<I$�(�    )  � �4I��(� ��<I$)  8(���4I��     ���4I�� 
��NO_ENTRIES�    �      2:  <���       F���  P�   