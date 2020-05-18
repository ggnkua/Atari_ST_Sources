; PSEUDO-RSC

;Null
	DC.W	ONil
	DC.W	OModuleText
	DC.W	OBottomLine
	DC.W	TNull
	DC.W	0
	DC.W	0
	DC.L	0
	DC.W	0
	DC.W	0
	DC.W	40
	DC.W	25

;ModuleText
	DC.W	OCommandText
	DC.W	OFileName
	DC.W	OMinutes
	DC.W	TString
	DC.W	0
	DC.W	0
	DC.L	ModuleText
	DC.W	0
	DC.W	0
	DC.W	40
	DC.W	8

;CommandText
	DC.W	OBottomLine
	DC.W	OPlay
	DC.W	OTreble
	DC.W	TString
	DC.W	0
	DC.W	0
	DC.L	CommandText
	DC.W	0
	DC.W	8
	DC.W	40
	DC.W	16

;SampleText1
	DC.W	OBottomLine
	DC.W	ONil
	DC.W	ONil
	DC.W	TString
	DC.W	0
	DC.W	0
	DC.L	SampleText1
	DC.W	0
	DC.W	8
	DC.W	40
	DC.W	16

;SampleText2
	DC.W	OBottomLine
	DC.W	ONil
	DC.W	ONil
	DC.W	TString
	DC.W	0
	DC.W	0
	DC.L	SampleText2
	DC.W	0
	DC.W	8
	DC.W	40
	DC.W	16

;BottomLine
	DC.W	ONull
	DC.W	ONil
	DC.W	ONil
	DC.W	TString
	DC.W	0
	DC.W	0
	DC.L	BottomLine
	DC.W	0
	DC.W	24
	DC.W	40
	DC.W	1

;FileName
	DC.W	OFileLength
	DC.W	OFileExtension
	DC.W	OFileExtension
	DC.W	TString
	DC.W	0
	DC.W	SRightJustified
	DC.L	FileName
	DC.W	13
	DC.W	3
	DC.W	8
	DC.W	1

;FileExtension
	DC.W	OFileName
	DC.W	ONil
	DC.W	ONil
	DC.W	TString
	DC.W	0
	DC.W	0
	DC.L	FileExtension
	DC.W	22
	DC.W	3
	DC.W	3
	DC.W	1

;FileLength
	DC.W	OModuleName
	DC.W	ONil
	DC.W	ONil
	DC.W	TInteger32bUnsigned
	DC.W	FIndirect
	DC.W	SRightJustified
	DC.L	FileLength
	DC.W	26
	DC.W	3
	DC.W	6
	DC.W	1

;ModuleName
	DC.W	OCurrentPosition
	DC.W	ONil
	DC.W	ONil
	DC.W	TString
	DC.W	0
	DC.W	0
	DC.L	Module
	DC.W	13
	DC.W	4
	DC.W	20
	DC.W	1

;CurrentPosition
	DC.W	OPositionCount
	DC.W	ONil
	DC.W	ONil
	DC.W	TInteger16bUnsigned
	DC.W	0
	DC.W	SSelected!SRightJustified
	DC.L	0
	DC.W	13
	DC.W	5
	DC.W	3
	DC.W	1

;PositionCount
	DC.W	OCurrentPattern
	DC.W	ONil
	DC.W	ONil
	DC.W	TInteger16bUnsigned
	DC.W	0
	DC.W	0
	DC.L	0
	DC.W	17
	DC.W	5
	DC.W	3
	DC.W	1

;CurrentPattern
	DC.W	OPatternCount
	DC.W	ONil
	DC.W	ONil
	DC.W	TInteger16bUnsigned
	DC.W	0
	DC.W	SSelected!SRightJustified
	DC.L	0
	DC.W	14
	DC.W	6
	DC.W	2
	DC.W	1

;PatternCount
	DC.W	OMinutes
	DC.W	ONil
	DC.W	ONil
	DC.W	TInteger16bUnsigned
	DC.W	0
	DC.W	0
	DC.L	0
	DC.W	17
	DC.W	6
	DC.W	2
	DC.W	1

;Minutes
	DC.W	OModuleText
	DC.W	OSeconds
	DC.W	OSeconds
	DC.W	TInteger16bUnsigned
	DC.W	FIndirect
	DC.W	SSelected!SRightJustified
	DC.L	Minutes-2
	DC.W	32
	DC.W	6
	DC.W	2
	DC.W	1

;Seconds
	DC.W	OMinutes
	DC.W	ONil
	DC.W	ONil
	DC.W	TInteger16bUnsigned
	DC.W	FIndirect
	DC.W	SSelected!SRightJustified!SZeroed
	DC.L	Seconds-2
	DC.W	35
	DC.W	6
	DC.W	2
	DC.W	1

;Play
	DC.W	OFastForward
	DC.W	ONil
	DC.W	ONil
	DC.W	TIndexedString
	DC.W	0
	DC.W	SSelected
	DC.L	StrucPlay
	DC.W	30
	DC.W	1+8
	DC.W	5
	DC.W	1

;FastForward
	DC.W	ORepeat
	DC.W	ONil
	DC.W	ONil
	DC.W	TIndexedString
	DC.W	0
	DC.W	SSelected
	DC.L	StrucFastForward
	DC.W	32
	DC.W	4+8
	DC.W	3
	DC.W	1

;Repeat
	DC.W	OMonoStereo
	DC.W	ONil
	DC.W	ONil
	DC.W	TIndexedString
	DC.W	0
	DC.W	SSelected
	DC.L	StrucRepeat
	DC.W	32
	DC.W	5+8
	DC.W	3
	DC.W	1

;MonoStereo
	DC.W	OFrequency
	DC.W	ONil
	DC.W	ONil
	DC.W	TIndexedString
	DC.W	0
	DC.W	SSelected
	DC.L	StrucStereo
	DC.W	29
	DC.W	9+8
	DC.W	6
	DC.W	1

;Frequency
	DC.W	OVolume
	DC.W	ONil
	DC.W	ONil
	DC.W	TIndexedString
	DC.W	0
	DC.W	SSelected
	DC.L	StrucFrequency
	DC.W	30
	DC.W	10+8
	DC.W	5
	DC.W	1

;Volume
	DC.W	OLeftFader
	DC.W	ONil
	DC.W	ONil
	DC.W	TInteger16bSigned
	DC.W	FIndirect
	DC.W	SSelected!SRightJustified!SPlus_0
	DC.L	Volume-2
	DC.W	32
	DC.W	11+8
	DC.W	3
	DC.W	1

;LeftFader
	DC.W	ORightFader
	DC.W	ONil
	DC.W	ONil
	DC.W	TInteger16bSigned
	DC.W	FIndirect
	DC.W	SSelected!SRightJustified!SPlus_0
	DC.L	LeftFader-2
	DC.W	32
	DC.W	12+8
	DC.W	3
	DC.W	1

;RightFader
	DC.W	OBass
	DC.W	ONil
	DC.W	ONil
	DC.W	TInteger16bSigned
	DC.W	FIndirect
	DC.W	SSelected!SRightJustified!SPlus_0
	DC.L	RightFader-2
	DC.W	32
	DC.W	13+8
	DC.W	3
	DC.W	1

;Bass
	DC.W	OTreble
	DC.W	ONil
	DC.W	ONil
	DC.W	TInteger16bSigned
	DC.W	FIndirect
	DC.W	SSelected!SRightJustified!SPlus_0
	DC.L	Bass-2
	DC.W	32
	DC.W	14+8
	DC.W	3
	DC.W	1

;Treble
	DC.W	OCommandText
	DC.W	ONil
	DC.W	ONil
	DC.W	TInteger16bSigned
	DC.W	FIndirect
	DC.W	SSelected!SRightJustified!SPlus_0
	DC.L	Treble-2
	DC.W	32
	DC.W	15+8
	DC.W	3
	DC.W	1

ModuleText:
  DC.B "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  DC.B "~      CPU_MOD  by  Patrick RUIZ       ~"
  DC.B "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  DC.B "~     File = --------.--- ------ bytes ~" ;FileName FileExtension FileLength
  DC.B "~   Module = --------------------      ~" ;ModuleName
  DC.B "~ Position = ---/---                   ~" ;CurrentPosition/PositionCount
  DC.B "~  Pattern =  --/--      Time = --",39,"--",34," ~" ;CurrentPattern/PatternCount
  DC.B "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" ;Minutes/Seconds
CommandText:
  DC.B "~   Help : Show Sample Names           ~" ;in 1 or 2 pages
  DC.B "~     SP : Pause/Play.......: -----    ~" ;PAUSE/PLAY
  DC.B "~      - : Stop                        ~"
  DC.B "~    ( ) : Pos. Reverse/Forward Search ~"
  DC.B "~      + : Fast Forward.......: ---    ~" ;OFF/ON
  DC.B "~      . : Repeat mode........: ---    ~" ;OFF/ON
  DC.B "~      T : Reset Time                  ~"
  DC.B "~    Esc : End                         ~"
  DC.B "~      S : Save Preferences (Below)    ~"
  DC.B "~      * : Mono/Stereo.....: ------    ~" ;MONO/STEREO
  DC.B "~ 0 to 3 : Frequency........: ----- Hz ~" ;6258/12517/25033/50066 Hz
  DC.B "~ F1 F2  : Dec/Inc Volume.....: --- dB ~" ;-80 to   0 step 2
  DC.B "~ F3 F4  : Dec/Inc Left  Fader: --- dB ~" ;-40 to   0 step 2
  DC.B "~ F5 F6  : Dec/Inc Right Fader: --- dB ~" ;-40 to   0 step 2
  DC.B "~ F7 F8  : Dec/Inc Bass.......: --- dB ~" ;-12 to +12 step 2
  DC.B "~ F9 F10 : Dec/Inc Treble.....: --- dB ~" ;-12 to +12 step 2
SampleText1:
  DC.B "~             Sample names             ~"
  DC.B "~    01  ----------------------        ~" ;SampleNumber SampleName
  DC.B "~    02  ----------------------        ~"
  DC.B "~    03  ----------------------        ~"
  DC.B "~    04  ----------------------        ~"
  DC.B "~    05  ----------------------        ~"
  DC.B "~    06  ----------------------        ~"
  DC.B "~    07  ----------------------        ~"
  DC.B "~    08  ----------------------        ~"
  DC.B "~    09  ----------------------        ~"
  DC.B "~    10  ----------------------        ~"
  DC.B "~    11  ----------------------        ~"
  DC.B "~    12  ----------------------        ~"
  DC.B "~    13  ----------------------        ~"
  DC.B "~    14  ----------------------        ~"
  DC.B "~    15  ----------------------        ~"
SampleText2:
  DC.B "~    16  ----------------------        ~"
  DC.B "~    17  ----------------------        ~"
  DC.B "~    18  ----------------------        ~"
  DC.B "~    19  ----------------------        ~"
  DC.B "~    20  ----------------------        ~"
  DC.B "~    21  ----------------------        ~"
  DC.B "~    22  ----------------------        ~"
  DC.B "~    23  ----------------------        ~"
  DC.B "~    24  ----------------------        ~"
  DC.B "~    25  ----------------------        ~"
  DC.B "~    26  ----------------------        ~"
  DC.B "~    27  ----------------------        ~"
  DC.B "~    28  ----------------------        ~"
  DC.B "~    29  ----------------------        ~"
  DC.B "~    30  ----------------------        ~"
  DC.B "~    31  ----------------------        ~"
BottomLine:
  DC.B "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	EVEN

FileName	DS.B 8+1
FileExtension	DS.B 3
	EVEN
FileLength	DS.L 1
Minutes		DC.W 0
Seconds		DC.W 0
Play		DC.W 0
FastForward	DC.W 0
Repeat		DC.W 0

StrucPlay:
	DC.L	Play
	DC.L	StringPause
	DC.L	StringPlay
StringPause	DC.B "PAUSE"
StringPlay	DC.B " PLAY"
	EVEN

StrucFastForward:
	DC.L	FastForward
	DC.L	StringOff
	DC.L	StringOn
StringOff	DC.B "OFF"
StringOn	DC.B " ON"
	EVEN

StrucRepeat:
	DC.L	Repeat
	DC.L	StringOff
	DC.L	StringOn
	EVEN

StrucStereo:
	DC.L	MonoStereo
	DC.L	StringMono
	DC.L	StringStereo
StringMono	DC.B "  MONO"
StringStereo	DC.B "STEREO"
	EVEN

StrucFrequency
	DC.L	Frequency
	DC.L	String6258
	DC.L	String12517
	DC.L	String25033
	DC.L	String50066

String6258	DC.B " 6258"
String12517	DC.B "12517"
String25033	DC.B "25033"
String50066	DC.B "50066"
