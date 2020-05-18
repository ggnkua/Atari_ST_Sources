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
	DC.W	OInversionV0V1
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
	DC.W	O_8_16bits
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

;_8_16bits
	DC.W	OMonoStereo
	DC.W	ONil
	DC.W	ONil
	DC.W	TIndexedString
	DC.W	0
	DC.W	SSelected
	DC.L	Struc_8_16bits
	DC.W	33
	DC.W	9+8
	DC.W	2
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
	DC.W	10+8
	DC.W	6
	DC.W	1

;Frequency
	DC.W	OVolumeInt
	DC.W	ONil
	DC.W	ONil
	DC.W	TIndexedString
	DC.W	0
	DC.W	SSelected
	DC.L	StrucFrequency
	DC.W	30
	DC.W	11+8
	DC.W	5
	DC.W	1

;VolumeInt
	DC.W	OInversionV0V1
	DC.W	OVolumeFrc
	DC.W	OVolumeFrc
	DC.W	TInteger16bSigned
	DC.W	FIndirect
	DC.W	SSelected!SRightJustified!SPlus_0
	DC.L	VolumeInt2-2
	DC.W	30
	DC.W	12+8
	DC.W	3
	DC.W	1

;VolumeFrc
	DC.W	OVolumeInt
	DC.W	ONil
	DC.W	ONil
	DC.W	TFrac16bSigned
	DC.W	FIndirect
	DC.W	SSelected
	DC.L	VolumeFrc2
	DC.W	33
	DC.W	12+8
	DC.W	2
	DC.W	1

;InversionV0V1
	DC.W	OCommandText
	DC.W	OInversionV2V3
	DC.W	OInversionV2V3
	DC.W	TFrac16bSigned
	DC.W	FIndirect
	DC.W	SSelected!SZeroed
	DC.L	InversionV0V1
	DC.W	30
	DC.W	13+8
	DC.W	5
	DC.W	1

;InversionV2V3
	DC.W	OInversionV0V1
	DC.W	ONil
	DC.W	ONil
	DC.W	TFrac16bSigned
	DC.W	FIndirect
	DC.W	SSelected!SZeroed
	DC.L	InversionV2V3
	DC.W	30
	DC.W	14+8
	DC.W	5
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
  DC.B "~      / : 8/16 bits...........: -- b  ~" ;8/16
  DC.B "~      * : Mono/Stereo.....: ------    ~" ;MONO/STEREO
  DC.B "~ 0 to 7 : Frequency........: ----- Hz ~"
  DC.B "~  F1 F2 : Dec/Inc Volume...: ---.- dB ~" ;0 to -22.5 dB
  DC.B "~ LMouse : Set InversionV0V1: .----    ~" ;.0000 to .9999
  DC.B "~ RMouse : Set InversionV2V3: .----    ~" ;.0000 to .9999
  DC.B "~     Inversion=MouseX/ScreenWidth     ~"
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

StrucFastForward:
	DC.L	FastForward
	DC.L	StringOff
	DC.L	StringOn
StringOff	DC.B "OFF"
StringOn	DC.B " ON"

StrucRepeat:
	DC.L	Repeat
	DC.L	StringOff
	DC.L	StringOn

Struc_8_16bits:
	DC.L	_8_16bits
	DC.L	String8
	DC.L	String16
String8		DC.B " 8"
String16	DC.B "16"

StrucStereo:
	DC.L	MonoStereo
	DC.L	StringMono
	DC.L	StringStereo
StringMono	DC.B "  MONO"
StringStereo	DC.B "STEREO"

StrucFrequency
	DC.L	Frequency
	DC.L	String8195
	DC.L	String9834
	DC.L	String12292
	DC.L	String16390
	DC.L	String19668
	DC.L	String24585
	DC.L	String32780
	DC.L	String49170

String8195	DC.B " 8195"
String9834	DC.B " 9834"
String12292	DC.B "12292"
String16390	DC.B "16390"
String19668	DC.B "19668"
String24585	DC.B "24585"
String32780	DC.B "34780"
String49170	DC.B "49170"
