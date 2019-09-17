* ERROR MESSAGES
****************
	DATA
BIOS_ERRORS	dc.l	Bios_ok		0
	dc.l	Bios_error		1
	dc.l	Drive_not_ready		2
	dc.l	Unknown_command		3
	dc.l	Crc_error		4	
	dc.l	Bad_request		5
	dc.l	Seek_error		6
	dc.l	Unknown_media		7
	dc.l	Sector_not_found	8
	dc.l	No_paper		9
	dc.l	Write_fault		10
	dc.l	Read_fault		11
	dc.l	General_mishap		12
	dc.l	Write_protect		13
	dc.l	Media_change		14
	dc.l	Unknown_device		15
	dc.l	Bad_sectors		16
	dc.l	Insert_disk		17
	dc.l	Unknown_error		18
	dc.l	Unknown_error		19
	dc.l	Unknown_error		20
	dc.l	Unknown_error		21
	dc.l	Unknown_error		22
	dc.l	Unknown_error		23
	dc.l	Unknown_error		24
	dc.l	Unknown_error		25
	dc.l	Unknown_error		26
	dc.l	Unknown_error		27
	dc.l	Unknown_error		28
	dc.l	Unknown_error		29
	dc.l	Unknown_error		30
	dc.l	Unknown_error		31
	dc.l	Einvfn			32
	dc.l	Efilnf			33
	dc.l	Epthnf			34
	dc.l	Enhndl			35
	dc.l	Eaccdn			36
	dc.l	Eihndl			37
	dc.l	Unknown_error		38
	dc.l	Ensmem			39
	dc.l	Eimba			40
	dc.l	Unknown_error		41
	dc.l	Unknown_error		42
	dc.l	Unknown_error		43
	dc.l	Unknown_error		44
	dc.l	Unknown_error		45
	dc.l	Edrive			46
	dc.l	Unknown_error		47
	dc.l	Ensame			48
	dc.l	Enmfil			49
	dc.l	Unknown_error		50
	dc.l	Unknown_error		51
	dc.l	Unknown_error		52
	dc.l	Unknown_error		53
	dc.l	Unknown_error		54
	dc.l	Unknown_error		55
	dc.l	Unknown_error		56
	dc.l	Unknown_error		57
	dc.l	Unknown_error		58
	dc.l	Unknown_error		59
	dc.l	Unknown_error		60
	dc.l	Unknown_error		61
	dc.l	Unknown_error		62
	dc.l	Unknown_error		63
	dc.l	Erange			64
	dc.l	Eintrn			65
	dc.l	Eplfmt			66
	dc.l	Egsbf			67

*	dc.l	Eloop			80
*	dc.l	Emount			200

Bios_ok		dc.b	"No Error!",0
Bios_error	dc.b	"General Error!",0
Drive_not_ready	dc.b	"Device not Ready!",0
Unknown_command	dc.b	"Unknown Device Command!",0
Crc_error	dc.b	"CRC Error!",0
Bad_request	dc.b	"Possible Bad Parameters!",0
Seek_error	dc.b	"Drive cannot Seek to Track!",0
Unknown_media	dc.b	"Not a ST Boot Sector!",0
Sector_not_found dc.b	"Sector not Found!",0
No_paper	dc.b	"Device out of Paper!",0
Write_fault	dc.b	"Write operation Failed!",0
Read_fault	dc.b	"Read operation Failed!",0
General_mishap	dc.b	"Error - Reserved for Future Use!",0
Write_protect	dc.b	"Device Write Protected!",0
Media_change	dc.b	"Disk Changed!",0
Unknown_device	dc.b	"Unknown Device!",0
Bad_sectors	dc.b	"Format found Bad Sectors!",0
Insert_disk	dc.b	"Need Disk in Drive!",0
Unknown_error	dc.b	"Undocumented Error!",0
Einvfn		dc.b	"Invalid Function Number!",0
Efilnf		dc.b	"File not Found!",0
Epthnf		dc.b	"Path not Found!",0
Enhndl		dc.b	"Out of File Handles!",0
Eaccdn		dc.b	"Access Denied!",0
Eihndl		dc.b	"Invalid Handle!",0
Ensmem		dc.b	"Insufficient Memory!",0
Eimba		dc.b	"Invalid Memory Block Address!",0
Edrive		dc.b	"Invalid Drive Specification!",0
Ensame		dc.b	"Not the Same Drive!",0
Enmfil		dc.b	"No more Files!",0
Erange		dc.b	"Range Error!",0
Eintrn		dc.b	"GEMDOS Internal Error!",0
Eplfmt		dc.b	"Not an Executable file!",0
Egsbf		dc.b	"Memory Block Growth Failure!",0

Gd_ver_err_msg	dc.b	"Gemdos Version too early for that call!",0
Malloc_err_msg	dc.b	"Not enough Memory Available!"
Printer_err_msg	dc.b	"Parallel Port Failed to Respond!",0
Stklo_err_msg	dc.b	"Stack Overflow!",0
Stkhi_err_msg	dc.b	"Stack Underflow!",0
		even
		TEXT
