<GEMSETUP 0160>

<GLOBAL>
	APP_FILE="iFusion.prg"
	APP_NAME="iFusion (Milan 060)"
	APP_VERS="1.0"
	APP_FOLD="iFusion"
	APP_LOCN="$DEST"

	URL="http://www.camelot.de/~zulu/"

	DEF_PATH=""

	ROOTPATH=FALSE
	CALCSIZE=TRUE
	ARCSSIZE=14275

	HYP_FILE="iFusion.hyp"
	HYP_PAGE=""
</GLOBAL>

<LOCAL>
	SIZE=0
</LOCAL>

<ENTRY>
	TYPE=RADIO
	NAME="-"
	TEXT="iFusion V1.0"
	BHLP=""
	<FILE>
		TYPE=AUTO
		TEXT="iFusion fÅr Draconis installieren"
		PATH="data\Draconis\iFusion.prg"
		SETS=1
		FCNT=1
		SIZE=23063
	</FILE>
	<FILE>
		TYPE=AUTO
		TEXT="iFusion fÅr IConnect installieren"
		PATH="data\IConnect\iFusion.prg"
		SETS=0
		FCNT=1
		SIZE=23063
	</FILE>
</ENTRY>

<ENTRY>
	TYPE=CHECKBOX
	NAME="-"
	TEXT="Online-Hilfe"
	BHLP=""
	<ARCHIVE>
		TYPE=HYP
		TEXT="ST-Guide-Hypertext installieren"
		FILE="data\hyp.lzh"
		PATH="iFusion.*"
		SETS=1
		FCNT=1
		SIZE=2971
	</ARCHIVE>
	<ARCHIVE>
		TYPE=APPL
		TEXT="ST-Guide-Hypertext kopieren"
		FILE="data\hyp.lzh"
		PATH="iFusion.*"
		FCNT=1
		SIZE=2971
	</ARCHIVE>
</ENTRY>

<ENTRY>
	TYPE=CHECKBOX
	NAME="-"
	TEXT="ST-Guide einrichten"
	BHLP=""
	<ARCHIVE>
		TYPE=APPL
		TEXT="ST-Guide kopieren"
		FILE="data\ST-GUIDE.LZH"
		PATH="*"
		NAME="ZUSATZ\"
		SETS=1
		FCNT=5
		SIZE=104757
	</ARCHIVE>
</ENTRY>
