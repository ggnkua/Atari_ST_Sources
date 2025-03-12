/* BANK NR 1 ----------------------------------------------------------	*/				
enum TYPESTYLE_AND_PITCH_SELECTION	
{	FPOS=1,						/*	Front_Panel_Or_Software							*/
	FPO		};					/*	Front_Panel_Only 									*/
enum PRINT_STYLE_AT_POWER_UP
{ 	C10=1,						/* COURIER_10											*/
	C12,							/* COURIER_12											*/
	P10,							/* PRESTIGE_10											*/
	P12, 							/* PRESTIGE_12											*/
	Q10,							/* Q_GOTHIC_10											*/
	Q12,							/* Q_GOTHIC_12											*/
	D10, 							/* D_GOTHIC_10											*/
	D12,							/* D_GOTHIC_12											*/
	HPS,							/* HELVETICA_PS										*/
	TPS,							/* TIMES_PS												*/
	BPS};							/*	BOLD_PS												*/
enum CPI_12_DRAFT_SPEED
{	HS12=1,						/* HIGH_SPEED											*/
	N12};							/* NORMAL												*/
enum LANGUAGE_CHAR_SET
{	LCUSA=1, LCFRA, LCGER, LCENG, LCDM1, LCSWD, LCITL, LCSPA, LCJPN, LCNOR,
	LCDM2, LCNET, LCTUK,	LCSP2, LCLA, LCMUL, LCPOR, LCCFR, LCNR2 };
enum CHAR_SET_DEFAULT
{	CSDIT=1,						/* Char Set Default ITalic							*/
	CSIBM };						/* Char Set Default IBM								*/
enum SHAPE_OF_ZERO
{	SOZNULL=1,					/* Shape Of Zero normale NULL						*/
	SOZSLNU };					/* Shape Of Zeor als SLash NUll					*/
enum GRAPHICS_PRINT_DIRECTION
{	GPDUNI=1,					/* Graphics Print Direction UNIdirectional	*/
	GPDBI };						/* Graphics Print Direction BIdirectional		*/
enum QUIET_MODE
{	QUIET=1,						/* QUIET mode on										*/
	LOUD };						/* quiet mode off (=LOUD)							*/

/* BANK NR 2 ----------------------------------------------------------	*/				
enum FORM_FEED_LENGTH_IN_INCHES
{	FF3=1, FF35, FF4, FF55, FF6, FF7, FF8, FF85, FF11, FF1033, FF12, FF14 };
enum SKIP_OVER_EMULATION
{	SKOON=1,						/* SKip Over emulation on							*/
   SKOOFF };					/* SKip Over emulation off							*/
enum LINES_PER_INCH
{	FSIX=1,						/* one line Feed is SIX linex per inch			*/
	FEIGHT };					/* one line Feed is EIGHT linex per inch		*/
enum MARGIN_EMULATION_0
{	MEDIS=1,						/*	null Margin Emulation is DISable				*/
	MEEN };						/* null Margin Emulation is ENable				*/
enum AUTO_TEAR_OFF
{	ATODIS=1,					/* Auto Tear Off is DISable						*/
	ATOEN };						/* Auto Tear Off is ENable							*/
enum CUTTER_POSITION
{	ACRYLIC=1,					/* cutter position of paper is the ACRYLIC	*/
	ROLLER };					/* cutter position of paper is the ROLLER		*/
enum CR_FUNKTION
{	CRONLY=1,					/* Carriage Return ONLY for a carriage return*/
	CRLF,							/* Carriage Return and Line Feed for a cr		*/
	CRPROUT };					/* PRint OUT at least at line feed, no CR		*/
enum LF_FUNKTION
{	LFCR=1,						/* Line Feed and CR for a line feed				*/
	LFONLY };					/* ONLY Line Feed for a line feed				*/
enum BUFFER_FULL_AUTO_LINE_FEED
{	BFON=1,						/* if buffer full, then line feed				*/
	BFOFF };						/* if buffer full, no line feed, wait			*/
enum PULL_TRACTOR
{	PULLTR=1,					/* PULL TRactor is installed						*/
	NPULLTR };					/* No PULL TRactor									*/
enum SHEET_FEEDER_LEFT_MARGIN
{	COL1=1,						/* left marin for sheet feeder is 1				*/
	COL35 };						/* left marin for sheet feeder is 35			*/

/* BANK NR 3 ----------------------------------------------------------	*/				
enum DOWNLOAD_CHARAKTER_BUFFER_CAPACITY
{	BUF8=1,						/* BUFfer is only for printer data (8 KByte)	*/
 	BUFCH4,						/* BUFfer = 4 KByte, CHarakterdownload=96 	*/
 	CHAR05 };					/* buffer = 0.5 KByte, CHARakterdownload=128 */
enum BAUD_RATE
{	BR150=1, BR300, BR600, BR1200, BR2400, BR4800, BR9600, BR19200 };
enum WORD_LENGTH
{	BITS8=1, BITS7 };
enum PARITY_CHECK
{	PCNONE=1, PCODD, PCEVEN };
enum DCD_SIGNALS
{  DCDEN=1, DCDDIS };
enum COMMUNICATION_PROTOCOL
{	ETXACK=1, XON, XONREP };

/* BANK NR 3 ----------------------------------------------------------	*/				
enum DRAFT_HORIZONTAL_ALIGNMENT
{	DM4=1, DM3, DM2, DM1, D0, D1, D2, D3, D4 };
enum LQ_HORIZONTAL_ALIGNMENT
{	LM4=1, LM3, LM2, LM1, L0, L1, L2, L3, L4 };
