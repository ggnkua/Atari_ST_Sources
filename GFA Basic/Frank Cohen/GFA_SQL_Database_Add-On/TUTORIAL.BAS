 GfABASIC          (   0   0   0   0   0   0   0          J  L  R  v  z  z  z  z  z  z  z  �  �  �  �XCOMMANDERRORFIELD1FIELD2FIELD3X SQLADR INITSQLCREATEINSERTINSERT2SELECT1SELECT2SELECTFIELD
SELECTNEXTSELECTWHEREUPDATEUPDATEWHEREDELETEUPDATECURRENTDELETECURRENT
REORGANIZECREATEINDEX	DROPINDEX	DROPTABLESORTERROREDINITVARS
SHOWFIELDS @ =============================================================@ ===                 TUTORIAL PROGRAM                      ===@ ===          SQL Database Add-On for GFA Basic            ===@ ===         by Frank Cohen, Super Genius [hehe]           ===@ =============================================================  F This program was written to show how most of the Add-On's commands B are processed.  I strongly suggest you make a hard-copy of thisB program and use it as an example of how you can use the Add-Onh& for your application programs.  -FC  (,� FpFind the SQL Add-On informationu   Show menu of user options   
��� �   F YF �Tutorial ProgramFO&�!SQL Database Add-On for GFA BasicF�by Frank Cohen (c) 101088F&�!---------------------------------FF  � 1. Create Table PhonebookF-�
 2. InsertFT� 3. Insert second recordFk� 4. Select first recordF$� 5. Select second (next) recordF� 6. Select field specificF$� 7. Select next field specificFF$� 8. Select using a WHERE clauseF�
 9. UpdateFu$�10. Update using a WHERE clauseF$�11. Delete using a WHERE clauseF �12. Update Current functionF �13. Delete Current functionF�14. Reorganize PhonebookFo�15. Create IndexFo�16. Drop IndexFx�17. Drop TableFx�18. Sort PhonebookF �19. QuitFP:� F.�Now working...Fi<w� L�!�!�!�!�!�!�!�!�	!�
!�!�!�!�!�!�!�!�F 4�.Finished.  Press RETURN when ready to continueFe:�Fn
�zF! ====================� === CREATE TABLE ===� ====================�+�F=H� E�ACREATE TABLE phonelist name CHAR(20), age INT(2), phone CHAR(20);F|� �� !� F 
�v��0000F,�F�F .F  ====================e === INSERT INTO  ===e ====================e+�F=P� E�HINSERT INTO phonelist Name='John Rayston',Phone='(305) 555-1616',Age=35;F |� �� !� F 
�>��0000F,�F�F .F   =============================  === INSERT SECOND RECORD  ===  =============================+�F=P� E�IINSERT INTO phonelist Name='Martha Windum',Phone='(818) 555-2646',Age=22;F|� �� !� F 
���0000F,�F�F .F  ==============  === SELECT ===  ============== +�F=,�F=$� E�SELECT [1] * FROM phonelist;Fr|� �� !�!�!�!� Fn,�F  
¾��0000F,�F�F .F  ===================== === SELECT NEXT * === =====================+�F=,�F=$� E�SELECT NEXT * FROM phonelist;F|� �� !�!�!�!� Fo,�F  
�p��0000F,�F�F .F  ====================o === SELECT FIELD ===o ====================o+�F=,�F=&� E�SELECT [1] name FROM phonelist;F|� �� !�!� Fm,�F  
���0000F,�F�F .F  =================== === SELECT NEXT === ===================+�F=,�F=(� E� SELECT NEXT name FROM phonelist;F |� �� !�!� Fa,�F  
����0000F,�F�F .F  ====================F === SELECT WHERE ===F ====================F+�F=,�F=>� E�6SELECT [1] * FROM phonelist WHERE name='John Rayston';F5|� �� !�!�!�!� Fn,�F  
Ŕ��0000F,�F�F .F  ==============� === UPDATE ===� ==============�+�	F=.� E�&UPDATE phonelist SET phone='555-2244';FJ|� �� !� F 
�(��0000F,�F�F .F  ====================S === UPDATE WHERE ===S ====================S+�
F=H� E�AUPDATE phonelist SET phone='555-9512' WHERE name='Martha Windum';F|� �� !� F 
����0000F,�F�F .F  ====================S === DELETE WHERE ===S ====================S+�F=4� E�,DELETE phonelist WHERE name='Martha Windum';Fm|� �� !� F 
ǔ��0000F,�F�F .F  ======================E === UPDATE CURRENT ===E ======================E+�F=,�F=6� E�.UPDATE phonelist CURRENT SET phone='555-2144';F=|� �� !� F 
�N��0000F,�F�F .F  ======================R === DELETE CURRENT ===R ======================R+�F=,�F= � E�DELETE phonelist CURRENT;F|� �� !� F 
����0000F,�F�F .F  ==================t === REORGANIZE ===t ==================t+�F=� E�REORGANIZE phonelist;F|� �� !� F 
ɀ��0000F,�F�F .F  ====================i === CREATE INDEX ===i ====================i+�F=$� E�CREATE INDEX phonelist name;Fh|� �� !� F 
���0000F,�F�F .F  ==================o === DROP INDEX ===o ==================o+�F=� E�DROP INDEX phonelist;F|� �� !� F 
ʪ��0000F,�F�F .F  ==================e === DROP TABLE ===e ==================e+�F=� E�DROP TABLE phonelist;F|� �� !� F 
�8��0000F,�F�F .F  ============F === SORT ===F ============F+�F=� E�SORT phonelist name;Fn|� �� !� F 
˴��0000F,�F�F .F 2 ===============================================2 === Establish variables for Phonelist table ===2 ===============================================+�F=4�E��((   !�  FThis will hold the NAME field;�E��!�  F!Age field (�E��((   !�  FPhone number field.F  =========================== === Print field results === ===========================+�F=�
Results...F F :�4Field 1 (Name)        Field 2 (Age)  Field 3 (Phone)F. �"�  "�"�             "�FF .F B ==============================================================nB === Find SQL Addon program address from disk file: SQL.$$$ ===nB ==============================================================n.+� F  XBIOS(500) is a special command that ,� E�F returns the run location of the SQL� E��z    F Add-on. 
�0� �z   F :�4Stop!  The SQL Add-on is not present on this system.F rF F �E�0000F.F ( =====================================( === Add-On returned an error code ===( =====================================+�F=(�#The Add-On has reported an error...F�	  Error #"�F @�;Refer to the Error Codes section of the manual for details.F.F �                                               
Θ 
� 
�� 
�� 
�^ 
� 
�� 
�j 
� 
�� 
�z 
�: 
�� 
Ȧ 
�> 
�� 
�h 
�� 
�r 
Ͼ 
�T 
�.