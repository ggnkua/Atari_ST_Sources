<GEMSETUP 0150>

<GLOBAL>
	APP_FILE="Fiffi.app"
	APP_LOCN="$DEST"
	APP_NAME="Fiffi 1.5"
	APP_VERS=""
	APP_FOLD="Fiffi"
	APP_ICRS="FiffiIcon.rsc"
	APP_ICNR=0

	URL="http://www.zulu.camelot.de"

	DEF_PATH="german\"

	ROOTPATH=FALSE
	CALCSIZE=TRUE
	ARCSSIZE=167996

	HYP_FILE=""
	HYP_PAGE=""
</GLOBAL>

<LOCAL>
</LOCAL>

<ENTRY>
	TYPE=CHECKBOX
	NAME="-"
	TEXT="Fiffi V1.5"
	BHLP=""
	<ARCHIVE>
		TYPE=APPL
		TEXT="Programm"
		FILE="data\Fiffi.lzh"
		PATH="Fiffi*.[ar][ps][pc]"
		SN="Fiffi.app"
		SETS=1
		LINK=2
		FCNT=1
		SIZE=143516
	</ARCHIVE>
	<ARCHIVE>
		TYPE=APPL
		TEXT="Resourcen"
		FILE="$LOCAL\Rsc.lzh"
		PATH="*"
		SETS=1
		LINK=1
		FCNT=1
		SIZE=143516
	</ARCHIVE>
</ENTRY>

<ENTRY>
	TYPE=CHECKBOX
	NAME="-"
	TEXT="Online-Hilfe zu Fiffi"
	BHLP=""
	<ARCHIVE>
		TYPE=HYP
		TEXT="ST-Guide-Hypertext installieren"
		FILE="data\hyp.lzh"
		PATH="Fiffi.*"
		SETS=1
		FCNT=1
		SIZE=2971
	</ARCHIVE>
	<ARCHIVE>
		TYPE=APPL
		TEXT="ST-Guide-Hypertext kopieren"
		FILE="data\hyp.lzh"
		PATH="Fiffi.*"
		FCNT=1
		SIZE=2971
	</ARCHIVE>
</ENTRY>

<ENTRY>
	TYPE=CHECKBOX
	NAME="-"
	TEXT="Beispiel-Skripts fÅr den MagiC Scripter"
	BHLP=""
	<ARCHIVE>
		TYPE=APPL
		TEXT=""
		FILE="data\Fiffi.lzh"
		PATH="Scripter\*"
		SETS=1
	</ARCHIVE>
</ENTRY>

