<GEMSETUP 0150>

<GLOBAL>
	APP_FILE="iFusion.prg"
	APP_NAME="iFusion"
	APP_VERS="1.0"
	APP_FOLD="iFusion"
	APP_LOCN="$DEST"

	URL="http://www.camelot.de/~zulu/"

	DEF_PATH=""

	ROOTPATH=FALSE
	SERIALIZE=TRUE
	CALCSIZE=TRUE
	ARCSSIZE=14275

	HYP_FILE="iFusion.hyp"
	HYP_PAGE=""
</GLOBAL>

<LOCAL>
	SIZE=0
</LOCAL>

<ENTRY>
	TYPE=CHECKBOX
	NAME="-"
	TEXT="iFusion V1.0"
	BHLP=""
	<ARCHIVE>
		TYPE=AUTO
		TEXT="iFusion installieren"
		FILE="data\iFusion.lzh"
      NAME="iFusion.prg"
		PATH="iFusion.prg"
		SN="iFusion.prg"
		SETS=1
		FCNT=1
		SIZE=23063
	</ARCHIVE>
	<ARCHIVE>
		TYPE=APPL
		TEXT="iFusion kopieren"
		FILE="data\iFusion.lzh"
      NAME="iFusion.prg"
		PATH="iFusion.prg"
		SN="iFusion.prg"
		FCNT=1
		SIZE=23063
	</ARCHIVE>
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
