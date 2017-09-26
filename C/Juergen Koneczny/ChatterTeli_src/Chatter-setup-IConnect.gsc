<GEMSETUP 0150>

<GLOBAL>
	APP_FILE="Chatter.app"
	APP_NAME="Chatter"
	APP_VERS="1.1"
	APP_FOLD="Chatter"
	APP_ICRS="ChatterIcon.rsc"
	APP_ICNR=0
	APP_LOCN="$DEST"

	URL="http://www.zulu.camelot.de"

	DEF_PATH="german\"

	ROOTPATH=FALSE
	SERIALIZE=TRUE
	CALCSIZE=TRUE
	ARCSSIZE=828237

	HYP_FILE="Chatter.hyp"
	HYP_PAGE=""
</GLOBAL>

<LOCAL>
</LOCAL>

<ENTRY>
	TYPE=CHECKBOX
	NAME="-"
	TEXT="Chatter V1.1"
	BHLP=""
	<ARCHIVE>
		TYPE=APPL
		TEXT="Programm"
		FILE="data\Chatter.lzh"
		PATH="Chatter*.[ar][ps][pc]"
		SN="Chatter.app"
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
	<FILE>
		TYPE=APPL
		TEXT="Erweiterung fÅr Online-Update"
		NAME="reg.ovl"
		PATH="reg.ovl"
		SETS=1
		FCNT=1
		SIZE=2576
	</FILE>
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
	TEXT="PPP-Connect V1.8"
	BHLP=""
	<ARCHIVE>
		TYPE=APPL
		TEXT="PPP-Connect installieren"
		FILE="data\PPP.LZH"
		PATH="*"
		SN="PPP\ICONF.PRG"
		LINK=2
		SETS=1
		FCNT=54
		SIZE=798181
	</ARCHIVE>
	<ARCHIVE>
		TYPE=AUTO
		TEXT="SOCKETS in den Auto-Ordner installieren"
		FILE="data\AUTOPPP.LZH"
		NAME="SOCKETS.PRG"
		PATH="SOCKETS.PRG"
		SN="SOCKETS.PRG"
		LINK=1
		SETS=1
		FCNT=1
		SIZE=59822
	</ARCHIVE>
</ENTRY>

<ENTRY>
	TYPE=CHECKBOX
	NAME="-"
	TEXT="Chatters Online-Hilfe"
	BHLP=""
	<ARCHIVE>
		TYPE=HYP
		TEXT="ST-Guide-Hypertext installieren"
		FILE="data\Chatter.lzh"
		<ITEM NAME="Chatter.hyp" PATH="Chatter.hyp">
		<ITEM NAME="Chatter.ref" PATH="Chatter.ref">
		SETS=1
		FCNT=2
		SIZE=69902
	</ARCHIVE>
	<ARCHIVE>
		TYPE=APPL
		TEXT="ST-Guide-Hypertext kopieren"
		FILE="data\Chatter.lzh"
		<ITEM NAME="Chatter.hyp" PATH="Chatter.hyp">
		<ITEM NAME="Chatter.ref" PATH="Chatter.ref">
		FCNT=2
		SIZE=69902
	</ARCHIVE>
	<ARCHIVE>
		TYPE=APPL
		TEXT="HTML-Dokument Åber das IRC kopieren"
		FILE="data\IRC.LZH"
		PATH="*"
		NAME="ZUSATZ\"
		SETS=1
		FCNT=8
		SIZE=164451
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
		<ITEM NAME="Bubble.hyp" PATH="Bubble\Bubble.hyp">
		<ITEM NAME="Bubble.ref" PATH="Bubble\Bubble.ref">
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
		<ITEM NAME="ZUSATZ\Colors\Colors.app" PATH="Colors\Colors.app">
		<ITEM NAME="ZUSATZ\Colors\Colors.rsc" PATH="Colors\Colors.rsc">
		SETS=1
		FCNT=2
		SIZE=7742
	</ARCHIVE>
	<ARCHIVE>
		TYPE=HYP
		TEXT="ST-Guide-Hypertext installieren"
		FILE="data\Colors.lzh"
		<ITEM NAME="Colors.hyp" PATH="Colors\Colors.hyp">
		<ITEM NAME="Colors.ref" PATH="Colors\Colors.ref">
		SETS=1
		FCNT=2
		SIZE=3470
	</ARCHIVE>
	<ARCHIVE>
		TYPE=APPL
		TEXT="ST-Guide-Hypertext kopieren"
		FILE="data\Colors.lzh"
		<ITEM NAME="ZUSATZ\Colors\Colors.hyp" PATH="Colors\Colors.hyp">
		<ITEM NAME="ZUSATZ\Colors\Colors.ref" PATH="Colors\Colors.ref">
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
