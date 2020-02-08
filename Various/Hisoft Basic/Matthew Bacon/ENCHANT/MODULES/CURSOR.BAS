
' [CURSOR.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

GOTO redirect_mouse
captureform:
DIM SHARED mform(100),mform2(100),mform3(100),mform4(100)

mform(0)=1 : mform(1)=1 : mform(2)=1 : mform(3)=0 : mform(4)=1
mform(5)=&h0000 : mform(6)=&h07C0 : mform(7)=&h1FF0 : mform(8)=&h3FF8
mform(9)=&h7FFC : mform(10)=&h7FFC : mform(11)=&hFFFE : mform(12)=&hFFFE
mform(13)=&hFFFE : mform(14)=&hFFFE : mform(15)=&hFFFE : mform(16)=&h7FFC
mform(17)=&h7FFC : mform(18)=&h3FF8 : mform(19)=&h1FF0 : mform(20)=&h07C0
mform(21)=&h0000 : mform(22)=&h07C0 : mform(23)=&h1FF0 : mform(24)=&h3FF8
mform(25)=&h5FF4 : mform(26)=&h4FE4 : mform(27)=&h87C2 : mform(28)=&h8382
mform(29)=&h8102 : mform(30)=&h8382 : mform(31)=&h87C2 : mform(32)=&h4FE4
mform(33)=&h5FF4 : mform(34)=&h3FF8 : mform(35)=&h1FF0 : mform(36)=&h07C0

mform2(0)=1 : mform2(1)=1 : mform2(2)=1 : mform2(3)=0 : mform2(4)=1
mform2(5)=&h0000 : mform2(6)=&h07C0 : mform2(7)=&h1FF0 : mform2(8)=&h3FF8
mform2(9)=&h7FFC : mform2(10)=&h7FFC : mform2(11)=&hFFFE : mform2(12)=&hFFFE
mform2(13)=&hFFFE : mform2(14)=&hFFFE : mform2(15)=&hFFFE : mform2(16)=&h7FFC
mform2(17)=&h7FFC : mform2(18)=&h3FF8 : mform2(19)=&h1FF0 : mform2(20)=&h07C0
mform2(21)=&h0000 : mform2(22)=&h07C0 : mform2(23)=&h19F0 : mform2(24)=&h21F8
mform2(25)=&h41FC : mform2(26)=&h41FC : mform2(27)=&h81FE : mform2(28)=&h81FE
mform2(29)=&hFFFE : mform2(30)=&hFF02 : mform2(31)=&hFF02 : mform2(32)=&h7F04
mform2(33)=&h7F04 : mform2(34)=&h3F08 : mform2(35)=&h1F30 : mform2(36)=&h07C0

mform3(0)=1 : mform3(1)=1 : mform3(2)=1 : mform3(3)=0 : mform3(4)=1
mform3(5)=&h0000 : mform3(6)=&h07C0 : mform3(7)=&h1FF0 : mform3(8)=&h3FF8
mform3(9)=&h7FFC : mform3(10)=&h7FFC : mform3(11)=&hFFFE : mform3(12)=&hFFFE
mform3(13)=&hFFFE : mform3(14)=&hFFFE : mform3(15)=&hFFFE : mform3(16)=&h7FFC
mform3(17)=&h7FFC : mform3(18)=&h3FF8 : mform3(19)=&h1FF0 : mform3(20)=&h07C0
mform3(21)=&h0000 : mform3(22)=&h07C0 : mform3(23)=&h1830 : mform3(24)=&h2008
mform3(25)=&h701C : mform3(26)=&h783C : mform3(27)=&hFC7E : mform3(28)=&hFEFE
mform3(29)=&hFFFE : mform3(30)=&hFEFE : mform3(31)=&hFC7E : mform3(32)=&h783C
mform3(33)=&h701C : mform3(34)=&h2008 : mform3(35)=&h1830 : mform3(36)=&h07C0

mform4(0)=1 : mform4(1)=1 : mform4(2)=1 : mform4(3)=0 : mform4(4)=1
mform4(5)=&h0000 : mform4(6)=&h07C0 : mform4(7)=&h1FF0 : mform4(8)=&h3FF8
mform4(9)=&h7FFC : mform4(10)=&h7FFC : mform4(11)=&hFFFE : mform4(12)=&hFFFE
mform4(13)=&hFFFE : mform4(14)=&hFFFE : mform4(15)=&hFFFE : mform4(16)=&h7FFC
mform4(17)=&h7FFC : mform4(18)=&h3FF8 : mform4(19)=&h1FF0 : mform4(20)=&h07C0
mform4(21)=&h0000 : mform4(22)=&h07C0 : mform4(23)=&h1F30 : mform4(24)=&h3F08
mform4(25)=&h7F04 : mform4(26)=&h7F04 : mform4(27)=&hFF02 : mform4(28)=&hFF02
mform4(29)=&hFFFE : mform4(30)=&h81FE : mform4(31)=&h81FE : mform4(32)=&h41FC
mform4(33)=&h41FC : mform4(34)=&h21F8 : mform4(35)=&h19F0 : mform4(36)=&h07C0
GOTO return_mouse

SUB update_mouse
SHARED mform(),mform2(),mform3(),mform4()
STATIC formstyle,dummy&,dummy2&,dummy3&,dummy4&

IF formstyle=0 THEN GOTO captureform
return_mouse:
dummy&=VARPTR(mform(0))
dummy2&=VARPTR(mform2(0))
dummy3&=VARPTR(mform3(0))
dummy4&=VARPTR(mform4(0))

INCR formstyle
SELECT CASE formstyle
	CASE<3 : graf_mouse 255,dummy& : formstyle=2
	CASE 3 : graf_mouse 255,dummy2&
	CASE 4 : graf_mouse 255,dummy3&
	CASE 5 : graf_mouse 255,dummy4&
	CASE 6 : formstyle=1
END SELECT
END SUB

redirect_mouse:

'[*END OF FILE*]
