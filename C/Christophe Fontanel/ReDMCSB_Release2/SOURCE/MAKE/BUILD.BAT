ECHO OFF
CLS
ECHO *******************************************************************************
ECHO *        This batch file builds all executable files for each version         *
ECHO *            of Dungeon Master and Chaos Strikes Back for Atari ST            *
ECHO *******************************************************************************
GEM :ALERT 2 [2][Do you want to build now?][Yes|No]
IF %:e==2 EXIT
ECHO ON


CD \

IF NOT FOLDER OBJECT MKDIR OBJECT
IF NOT FOLDER BUILD MKDIR BUILD

ECHO OFF
ECHO *******************************************************************************
ECHO *                       Build default Megamax C loader                        *
ECHO *******************************************************************************
ECHO ON
REM Replace C loader object code in the system library used by the Megamax linker
REM with original version supplied with Megamax C
IF NOT FOLDER OBJECT\BUILDASM MKDIR OBJECT\BUILDASM
SOURCE\MAKE\BUILDINI.BAT MEGAMAX OBJECT\BUILDASM
DEL OBJECT\BUILDASM\INIT.O
DEL OBJECT\BUILDASM\INIT.S
RMDIR OBJECT\BUILDASM


ECHO OFF
ECHO *******************************************************************************
ECHO *                        Build floppy disk boot sector                        *
ECHO *******************************************************************************
ECHO ON

IF NOT FOLDER BUILD\BOOTSECT MKDIR BUILD\BOOTSECT
SOURCE\MAKE\BUILDASM.BAT SOURCE\BOOTSECT\BOOTSECT.C BUILD\BOOTSECT\BOOTSECT.BIN


ECHO OFF
ECHO *******************************************************************************
ECHO *                               Build SWOOSH.IMG                              *
ECHO *******************************************************************************
ECHO ON

IF NOT FOLDER BUILD\SWOOSH.IMG MKDIR BUILD\SWOOSH.IMG
SOURCE\MAKE\BUILDASM.BAT SOURCE\SWOOSH.IMG\SWOOSH.C BUILD\SWOOSH.IMG\SWOOSH.IMG


ECHO OFF
ECHO *******************************************************************************
ECHO *                Build copy protection code hidden as graphics                *
ECHO *******************************************************************************
ECHO ON

IF NOT FOLDER BUILD\ENGINE MKDIR BUILD\ENGINE
SOURCE\MAKE\BUILDASM.BAT SOURCE\ENGINE\GRA21CSB.C BUILD\ENGINE\GRA21CSB.BIN
SOURCE\MAKE\BUILDASM.BAT SOURCE\ENGINE\GRA21DM.C  BUILD\ENGINE\GRA21DM.BIN
SOURCE\MAKE\BUILDASM.BAT SOURCE\ENGINE\GRAPH538.C BUILD\ENGINE\GRAPH538.BIN
SOURCE\MAKE\BUILDASM.BAT SOURCE\ENGINE\GRAPH548.C BUILD\ENGINE\GRAPH548.BIN


ECHO OFF
ECHO *******************************************************************************
ECHO *                               Build START.PRG                               *
ECHO *******************************************************************************
ECHO ON

IF NOT FOLDER OBJECT\START.PRG MKDIR OBJECT\START.PRG
IF NOT FOLDER BUILD\START.PRG MKDIR BUILD\START.PRG

REM Replace C loader object code in the system library used by the Megamax linker
REM with a custom version for START.PRG by FTL (based on original Megamax C loader)
SOURCE\MAKE\BUILDINI.BAT SOURCE\START.PRG OBJECT\START.PRG

REM Compile source code file to object file
MMCC.TTP SOURCE\START.PRG\START.C
COPY SOURCE\START.PRG\START.O OBJECT\START.PRG\START.O
DEL SOURCE\START.PRG\START.O

REM Do not improve START.O with code improver MMIMP.TTP

REM Disassemble object file
MMDIS.TTP OBJECT\START.PRG\START.O  -o OBJECT\START.PRG\START.S

REM Link object file to build executable file
IF NOT FOLDER BUILD\START.PRG MKDIR BUILD\START.PRG
CD OBJECT\START.PRG
..\..\MMLINK.TTP -o ..\..\BUILD\START.PRG\START.PRG ..\..\OBJECT\START.PRG\START.O -M ..\..\BUILD\START.PRG\START.MAP
CD ..\..


ECHO OFF
ECHO *******************************************************************************
ECHO *                    Build each version of the game engine                    *
ECHO *******************************************************************************
ECHO ON

IF NOT FOLDER OBJECT\ENGINE MKDIR OBJECT\ENGINE
IF NOT FOLDER BUILD\ENGINE MKDIR BUILD\ENGINE

REM Replace C loader object code in the system library used by the Megamax linker
REM with a custom version for the game by FTL (based on original Megamax C loader)
SOURCE\MAKE\BUILDINI.BAT SOURCE\ENGINE OBJECT\ENGINE

REM Build executable file for each version
SOURCE\MAKE\BUILDENG.BAT FULL DM10aEN DM10ab.LNK   -DGAMEVERSION=0
SOURCE\MAKE\BUILDENG.BAT FULL DM10bEN DM10ab.LNK   -DGAMEVERSION=1
SOURCE\MAKE\BUILDENG.BAT FULL DM11EN  DM11.LNK     -DGAMEVERSION=2
SOURCE\MAKE\BUILDENG.BAT FULL DM12EN  DM12_13.LNK  -DGAMEVERSION=3
SOURCE\MAKE\BUILDENG.BAT FULL DM12GE  DM12_13.LNK  -DGAMEVERSION=4
SOURCE\MAKE\BUILDENG.BAT FULL DM13aFR DM12_13.LNK  -DGAMEVERSION=5
SOURCE\MAKE\BUILDENG.BAT FULL DM13bFR DM12_13.LNK  -DGAMEVERSION=6
SOURCE\MAKE\BUILDENG.BAT FULL CSB20EN CSB20_21.LNK -DGAMEVERSION=7
SOURCE\MAKE\BUILDENG.BAT FULL CSB21EN CSB20_21.LNK -DGAMEVERSION=8

REM Build executable file for each version and without the copy protection
SOURCE\MAKE\BUILDENG.BAT NOCP DM10aEN DM10ab.LNK   -DGAMEVERSION=0 -DNOCOPYPROTECTION=1
SOURCE\MAKE\BUILDENG.BAT NOCP DM10bEN DM10ab.LNK   -DGAMEVERSION=1 -DNOCOPYPROTECTION=1
SOURCE\MAKE\BUILDENG.BAT NOCP DM11EN  DM11.LNK     -DGAMEVERSION=2 -DNOCOPYPROTECTION=1
SOURCE\MAKE\BUILDENG.BAT NOCP DM12EN  DM12_13.LNK  -DGAMEVERSION=3 -DNOCOPYPROTECTION=1
SOURCE\MAKE\BUILDENG.BAT NOCP DM12GE  DM12_13.LNK  -DGAMEVERSION=4 -DNOCOPYPROTECTION=1
SOURCE\MAKE\BUILDENG.BAT NOCP DM13aFR DM12_13.LNK  -DGAMEVERSION=5 -DNOCOPYPROTECTION=1
SOURCE\MAKE\BUILDENG.BAT NOCP DM13bFR DM12_13.LNK  -DGAMEVERSION=6 -DNOCOPYPROTECTION=1
SOURCE\MAKE\BUILDENG.BAT NOCP CSB20EN CSB20_21.LNK -DGAMEVERSION=7 -DNOCOPYPROTECTION=1
SOURCE\MAKE\BUILDENG.BAT NOCP CSB21EN CSB20_21.LNK -DGAMEVERSION=8 -DNOCOPYPROTECTION=1
