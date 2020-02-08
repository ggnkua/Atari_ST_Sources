
' [ERROR.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

' Thanks go to Gary Bell for his idea to provide advice when an error occured to
' help the user! - cool 8-)

FUNCTION ReportError$ (error_no)
SHARED err_advice$

err_advice$=""
SELECT CASE error_no
	CASE 81 : ReportError$="Sub-program not present" : err_advice$="Sorry- no advice available!"
	CASE 80 : ReportError$="Array not diminished" : err_advice$="Inform the author/publisher of this fault A.S.A.P"
	CASE 79 : ReportError$="Fatal address error" : err_advice$="Sorry- no advice available!"
	CASE 78 : ReportError$="Fatal bus error" : err_advice$="Sorry- no advice available!"
	CASE 77 : ReportError$="BREAK pressed" : err_advice$="There is no escape!"
	CASE 76 : ReportError$="Path not found" : err_advice$="Re-insert the floppy, or respecify the path to which the file is to be written/read."
	CASE 75 : ReportError$="Path/file access error" : err_advice$="The file must be write protected, or else you are not the owner"
	CASE 70 : ReportError$="Disk 'Write protected!'" : err_advice$="Remove the write protection."
	CASE 69 : ReportError$="MagiC O/S reported fault" : err_advice$="Exit this application without saving the files and restart it from the desktop."
	CASE 68 : ReportError$="Device unavailable" : err_advice$="Check your setup, particularly the device driver currently selected."
	CASE 67 : ReportError$="Too many files" : err_advice$="Close a file."
	CASE 64 : ReportError$="Bad file name" : err_advice$="Try sticking to a filename of 11 characters."
	CASE 63 : ReportError$="Bad record number" : err_advice$="Sorry- no advice available!"
	CASE 62 : ReportError$="Input past end" : err_advice$="The file may be corrupt - or of an unknown format."
	CASE 61 : ReportError$="Disk full" : err_advice$="Insert a blank (formatted) disk & try again."
	CASE 57 : ReportError$="Device I/O error" : err_advice$="Make sure the device is connected properly & that it is ONLINE."
	CASE 54 : ReportError$="Bad file mode" : err_advice$="Sorry- no advice available!"
	CASE 53 : ReportError$="File not found" : err_advice$="Sorry- no advice available!"
	CASE 52 : ReportError$="Bad channel number" : err_advice$="Sorry- no advice available!"
	CASE 51 : ReportError$="Internal error" : err_advice$="Sorry- no advice available!"
	CASE 50 : ReportError$="FIELD overflow" : err_advice$="Sorry- no advice available!"
	CASE 31 : ReportError$="Wrong number of dimensions" : err_advice$="Sorry- no advice available!"
	CASE 23 : ReportError$="Line buffer overflow" : err_advice$="Sorry- no advice available!"
	CASE 20 : ReportError$="RESUME without error" : err_advice$="Sorry- no advice available!"
	CASE 16 : ReportError$="String formula too complex" : err_advice$="Sorry- no advice available!"
	CASE 13 : ReportError$="Type mismatch" : err_advice$="Sorry- no advice available!"
	CASE 11 : ReportError$="Division by zero" : err_advice$="Sorry- no advice available!"
	CASE 10 : ReportError$="Redimensioned array" : err_advice$="Sorry- no advice available!"
	CASE 9 : ReportError$="Subscript out of range" : err_advice$="Sorry- no advice available!"
	CASE 7 : ReportError$="Out of memory" : err_advice$="Try exiting an application you no longer need."
	CASE 6 : ReportError$="Overflow" : err_advice$="Notify author/publisher now!"
	CASE 5 : ReportError$="Illegal function call" : err_advice$="Sorry- no advice available!"
	CASE 4 : ReportError$="Out of data" : err_advice$="Sorry- no advice available!"
	CASE 3 : ReportError$="RUTURN without GOSUB" : err_advice$="Sorry- no advice available!"
	CASE -1 : ReportError$="Fundamental error" : err_advice$="Beats me!"
	CASE -2 : ReportError$="Drive not ready!" : err_advice$="Check that the disk drive is switched on & connected."
	CASE -3 : ReportError$="Unknown command" : err_advice$="Sorry- no advice available!"
	CASE -4 : ReportError$="CRC error" : err_advice$="Sorry- no advice available!"
	CASE -5 : ReportError$="Bad request" : err_advice$="Your version of TOS does not support a requested action."
	CASE -6 : ReportError$="Seek error" : err_advice$="Sorry- no advice available!"
	CASE -7 : ReportError$="Unknown media" : err_advice$="Check that the disk is formatted & is compatable with your system."
	CASE -8 : ReportError$="Sector not found" : err_advice$="The disk does not have enough sectors, is it formatted?"
	CASE -9 : ReportError$="No paper" : err_advice$="Put some more paper in!"
	CASE -10 : ReportError$="Write fault" : err_advice$="Check that there is space on the disk. The disk may also be damaged."
	CASE -11 : ReportError$="Read fault" : err_advice$="Check that the drive is ready & online. If it is a floppy disk, check that a disk is in the drive."
	CASE -12 : ReportError$="General error" : err_advice$="Sorry- no advice available!"
	CASE -13 : ReportError$="Disk 'Write protected!'" : err_advice$="Close the write protection tab on the disk & try again."
	CASE -14 : ReportError$="Media change" : err_advice$="Sorry- no advice available!"
	CASE -15 : ReportError$="Unknown device" : err_advice$="Sorry- no advice available!"
	CASE -16 : ReportError$="Bad sectors on format" : err_advice$="Insert a new formatted disk in the disk drive. If it is hard drive then check your partitions with a disk doctor."
	CASE -17 : ReportError$="Insert another disk" : err_advice$="Insert another disk!"
	CASE -32 : ReportError$="Invalid function number" : err_advice$="Sorry- no advice available!"
	CASE -33 : ReportError$="File not found" : err_advice$="Try selecting the file again."
	CASE -34 : ReportError$="Path not found" : err_advice$="Try selecting the folder again."
	CASE -35 : ReportError$="Too many files open" : err_advice$="Too many files already open, close an open file and try again."
	CASE -36 : ReportError$="Access denied" : err_advice$="You do not have the necessary authority to access the file. Change the permissions & try again."
	CASE -37 : ReportError$="Invalid handle" : err_advice$="Sorry- no advice available!"
	CASE -39 : ReportError$="Insufficient memory" : err_advice$="Get a memory uprade!"
	CASE -40 : ReportError$="Invalid memory block address" : err_advice$="Sorry- no advice available!"
	CASE -46 : ReportError$="Invalid drive" : err_advice$="This drive might not exist or be correctly connected."
	CASE -49 : ReportError$="No more files" : err_advice$="Sorry- no advice available!"
	CASE -50 : ReportError$="Disk full" : err_advice$="Sorry- no advice available!"
	CASE -64 : ReportError$="Range error" : err_advice$="Sorry- no advice available!"
	CASE -65 : ReportError$="Internal error" : err_advice$="This is a system error, nothing to do with this program"
	CASE -66 : ReportError$="Invalid program load format" : err_advice$="Sorry- no advice available!"
	CASE -67 : ReportError$="Setblock failure" : err_advice$="Sorry- no advice available!"
	CASE -69 : ReportError$="MagiC O/S reported fault" : err_advice$="Sorry- no advice available!"
	CASE ELSE : ReportError$="A"+STR$(error_no)+" has occured" : err_advice$="Sorry- no advice available!"
END SELECT
ON ERROR GOTO ERROR_HANDLER
END FUNCTION

'[*END OF FILE*]
