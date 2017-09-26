<GEMSETUP 0150>

<GLOBAL>
	APP_FILE="Fiffi.app"
	APP_NAME="Fiffi"
	APP_VERS="1.2"
	APP_LOCN="$DEST"
	APP_FOLD="Fiffi"
	APP_ICRS="FiffiIcon.rsc"
	APP_ICNR=0

	URL="http://www.camelot.de/~zulu/"

	DEF_PATH=""

	ROOTPATH=FALSE
	SERIALIZE=FALSE
	CALCSIZE=TRUE
	ARCSSIZE=149274

	HYP_FILE=""
	HYP_PAGE=""
</GLOBAL>

<LOCAL>
	RSRC="LOCAL\Fiffi.rsc"
	SIZE=102647
</LOCAL>

<ENTRY>
	TYPE=CHECKBOX
	NAME="-"
	TEXT="Fiffi"
	BHLP="Dateien, die fÅr die Installation von Fiffi notwendig sind!"
	<FILE>
		TYPE=APPL
		TEXT="Programm"
		NAME="Fiffi.app"
		PATH="Data\Fiffi.app"
		LINK=2
		SETS=1
		FCNT=1
		SIZE=127053
	</FILE>
	<FILE>
		TYPE=APPL
		TEXT="Resourcen"
		NAME="Fiffi.rsc"
		PATH="Data\Fiffi.rsc"
		LINK=1
		SETS=1
		FCNT=1
		SIZE=0
	</FILE>
	<FILE>
		TYPE=APPL
		TEXT="Beschreibung der GEMScript-Kommandos"
		NAME="GEMScript.txt"
		PATH="Data\GEMScript.txt"
		LINK=0
		SETS=1
		FCNT=1
		SIZE=127053
	</FILE>
	<FILE>
		TYPE=APPL
		TEXT="Resource-Datei mit Icons"
		NAME="FiffiIcon.rsc"
		PATH="Data\FiffiIcon.rsc"
		SETS=1
		FCNT=1
		SIZE=1438
	</FILE>
</ENTRY>

<ENTRY>
	TYPE=CHECKBOX
	NAME="-"
	TEXT="Beispiel-Skripts fÅr den MagiC Scripter"
	BHLP=""
	<FILE>
		TYPE=APPL
		TEXT="Upload-Skript"
		NAME="Scripter\Upload.sic"
		PATH="Data\Scripter\Upload.sic"
		LINK=0
		SETS=1
		FCNT=1
		SIZE=127053
	</FILE>
	<FILE>
		TYPE=APPL
		TEXT="Download-Skript"
		NAME="Scripter\Download.sic"
		PATH="Data\Scripter\Download.sic"
		LINK=0
		SETS=1
		FCNT=1
		SIZE=127053
	</FILE>
</ENTRY>
