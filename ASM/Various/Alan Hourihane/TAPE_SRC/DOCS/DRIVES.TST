SCSI Tape Streamers supported by TapeBIOS - Tested
==================================================

	The tape drives that have been tested with TapeBIOS, with the caveats
stated, are listed below:-

Tandberg TDC 36xx series.
	Works faultlessy. No timeout value needed whatsoever.

Archive Viper 150S.
	Timeout value must be specified, Spurious errors otherwise occur.
	Some versions of the tape drive bios i.e. 21247-xxx do not fully
	report the proper error information. Most of the time a General
	Failure error will occur from these streamers.

FA.ST (ICD) 155mb mini cartridge. 
	Load/Unload commands not supported.
	For the above commands the tape drive returns an illegal request call.
	Instead use the ready/rewind combination to replace these commands.
	As for the Archive Viper 150S, a timeout value must be specified.

Adaptec 3530 (SCSI to QIC-02 Controller).
	Tested with Wangtek 5099EN (60MB). Works fine. No problems occurred.

Cypher CT540.

	If anyone else uses TapeBIOS with or without problems, or has any 
comments on the above information, please get in contact so i can review it
and update if necessary.

Alan Hourihane
email: alanh@logitek.co.uk
15/3/91.

