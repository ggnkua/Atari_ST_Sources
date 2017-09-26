<GEMSETUP 0150>

<GLOBAL>
	APP_FILE="Teli.app"
	APP_NAME="Teli"
	APP_VERS="1.14"
	APP_LOCN="$DEST"
	APP_FOLD="Teli"
	APP_ICRS="TeliIcon.rsc"
	APP_ICNR=0

	URL="http://www.camelot.de/~zulu/"

	DEF_PATH="german"

	ROOTPATH=FALSE
	SERIALIZE=FALSE
	CALCSIZE=TRUE
	ARCSSIZE=149274

	HYP_FILE="Teli.hyp"
	HYP_PAGE=""
</GLOBAL>

<LOCAL>
</LOCAL>

<ENTRY>
	TYPE=CHECKBOX
	NAME="-"
	TEXT="Teli"
	BHLP=""
	<ARCHIVE>
		TYPE=APPL
		TEXT="Programm"
		FILE="data\Teli.lzh"
		PATH="Teli*.[arb][psg][pch]"
		LINK=2
		SETS=1
		FCNT=4
		SIZE=266433
	</ARCHIVE>
	<ARCHIVE>
		TYPE=APPL
		TEXT="Resourcen"
		FILE="$LOCAL\Rsc.lzh"
		PATH="*"
		LINK=1
		SETS=1
		FCNT=4
		SIZE=266433
	</ARCHIVE>
	<ARCHIVE>
		TYPE=AUTO
		TEXT="KEYTAB installieren"
		FILE="data\KEYTAB.LZH"
		NAME="KEYTAB.PRG"
		PATH="KEYTAB\KEYTAB.PRG"
		SETS=1
		FCNT=1
		SIZE=8889
	</ARCHIVE>
</ENTRY>

<ENTRY>
	TYPE=CHECKBOX
	NAME="-"
	TEXT="Telis Online-Hilfe"
	BHLP=""
	<ARCHIVE>
		TYPE=HYP
		TEXT="ST-Guide-Hypertext installieren"
		FILE="data\Teli.lzh"
		PATH="Teli.[hr][ye][pf]"
		SETS=1
		FCNT=2
		SIZE=69902
	</ARCHIVE>
	<ARCHIVE>
		TYPE=APPL
		TEXT="ST-Guide-Hypertext kopieren"
		FILE="data\Teli.lzh"
		PATH="Teli.[hr][ye][pf]"
		FCNT=2
		SIZE=69902
	</ARCHIVE>
</ENTRY>

<ENTRY>
	TYPE=CHECKBOX
	NAME="-"
	TEXT="BubbleGEM einrichten"
	BHLP=""
	<ARCHIVE>
		TYPE=START
		TEXT="BubbleGEM als START-Programm installieren"
		FILE="data\Bubble.lzh"
		NAME="Bubble.app"
		PATH="Bubble\Bubble.app"
		SETS=1
		FCNT=1
		SIZE=19686
	</ARCHIVE>
	<ARCHIVE>
		TYPE=CPX
		TEXT="CPX-Modul installieren"
		FILE="data\Bubble.lzh"
		NAME="BubblGEM.cpx"
		PATH="Bubble\BubblGEM.cpx"
		SETS=1
		FCNT=1
		SIZE=7302
	</ARCHIVE>
	<ARCHIVE>
		TYPE=HYP
		TEXT="ST-Guide-Hypertext installieren"
		FILE="data\Bubble.lzh"
		PATH="Bubble\Bubble.[hr][ye][pf]"
		SETS=1
		FCNT=2
		SIZE=28678
	</ARCHIVE>
	<ARCHIVE>
		TYPE=APPL
		TEXT="BubbleGEM kopieren"
		FILE="data\Bubble.lzh"
		PATH="*"
		NAME="ZUSATZ\"
		FCNT=6
		SIZE=60119
	</ARCHIVE>
</ENTRY>

<ENTRY>
	TYPE=CHECKBOX
	NAME="-"
	TEXT="Colors einrichten"
	BHLP=""
	<ARCHIVE>
		TYPE=APPL
		TEXT="Programm"
		FILE="data\Colors.lzh"
		PATH="Colors\Colors.[ar][ps][pc]"
		NAME="ZUSATZ\"
		SETS=1
		FCNT=2
		SIZE=7742
	</ARCHIVE>
	<ARCHIVE>
		TYPE=HYP
		TEXT="ST-Guide-Hypertext installieren"
		FILE="data\Colors.lzh"
		PATH="Colors\Colors.[hr][ye][pf]"
		SETS=1
		FCNT=2
		SIZE=3470
	</ARCHIVE>
	<ARCHIVE>
		TYPE=APPL
		TEXT="ST-Guide-Hypertext kopieren"
		FILE="data\Colors.lzh"
		PATH="Colors\Colors.[hr][ye][pf]"
		NAME="ZUSATZ\"
		FCNT=2
		SIZE=3470
	</ARCHIVE>
</ENTRY>

<ENTRY>
	TYPE=CHECKBOX
	NAME="-"
	TEXT="DRAGFONT einrichten"
	BHLP=""
	<ARCHIVE>
		TYPE=APPL
		TEXT=""
		FILE="data\DRAGFONT.LZH"
		PATH="*"
		NAME="ZUSATZ\"
		SETS=1
		FCNT=1
		SIZE=5896
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

