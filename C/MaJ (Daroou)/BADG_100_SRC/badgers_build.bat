@echo off

rem Batch pour construire les archives de Badgers sous CygWin
rem MaJ 23/03/2026

rem ATTENTION !!! ATTENTION !!! ATTENTION !!! ATTENTION !!! 
rem  3 commandes 'rm' dans ce batch sans confirmation
rem ATTENTION !!! ATTENTION !!! ATTENTION !!! ATTENTION !!! 


set home_dev=e:/cygwin64/home/Hawlk/dev
rem set home_dev=h:/cygwin/home/Hawlk/dev


set nom_appli=BADGERS
set appli_prefix=BADG_
set version=100
set ObjetSrc2zip=badgers fonction badgers.bat badgers_build.bat executable/exe_badgers/exe_badgers.txt build/badgers/build.txt
set EXE_binaire=EXEcutable/EXE_badgers

set projet=Build/%nom_appli%

set dossier=%appli_prefix%%version%
set nom_archive=%appli_prefix%%version%
set dossier_TGA_SA_LDG=%home_dev%\EXEcutable\EXE_tga_sa_ldg\LIBCMINI



@echo -------------------------
@echo nom_appli %nom_appli%
@echo appli_prefix %appli_prefix%
@echo projet %projet%
@echo version %version%
@echo dossier %dossier%
@echo nom_archive %nom_archive%
@echo -------------------------




@echo  creation dossier si inexistant
cd     %home_dev%/build
mkdir  %nom_appli%


rem ########################################################################
@echo *
@echo ************  Archive du Source  **************
cd %home_dev%
@echo suppression de l'archive si elle existe
rm -v %projet%/%nom_archive%_SRC.ZIP
@echo creation de la nouvelle archive ZIP du code source
zip -r %projet%/%nom_archive%_SRC.ZIP %ObjetSrc2zip%  > CONout.txt



rem ########################################################################
@echo *
@echo ************  Archive du binaire  **************
cd      %home_dev%/%projet%
@echo suppression du dossier pour un refresh complet de l'archive
@echo suppression de %dossier%
rm -vr  %dossier%                                      > CONout.txt
mkdir   %dossier%

@echo on copie tous les dossiers et fichiers necessaire
cd      %home_dev%

cp -Rv  %nom_appli%/RSC     %projet%/%dossier%/RSC     > CONout.txt
cp -Rv  %nom_appli%/DATA    %projet%/%dossier%/DATA    > CONout.txt
cp -R   %nom_appli%/DOC_FR  %projet%/%dossier%/DOC_FR  > CONout.txt
cp -R   %nom_appli%/OUTIL   %projet%/%dossier%/OUTIL   > CONout.txt




rem ########################################################################
set Target_CPU=68K

@echo .
@echo - construction de %nom_archive%_%Target_CPU%.ZIP -------------------
cd      %home_dev%
cp -R   %EXE_binaire%/%appli_prefix%%Target_CPU%.PRG  %projet%/%dossier%/ > CONout.txt
cp -R   %EXE_binaire%/%appli_prefix%68D.PRG           %projet%/%dossier%/ > CONout.txt
cp -R   %dossier_TGA_SA_LDG%/68000/TGA_SA.LDG         %projet%/%dossier%/ > CONout.txt

cd      %home_dev%/%projet%
@echo suppression de l'archive si elle existe
rm -v   %nom_archive%_%Target_CPU%.ZIP

@echo creation de l'archive ZIP du binaire...
zip -rv %nom_archive%_%Target_CPU%.ZIP  %dossier% -x*.H -x*.HRD -x*.h -x*.hrd  > CONout.txt

cd   %home_dev%/%projet%/%dossier%
rm -v   %appli_prefix%%Target_CPU%.PRG



rem ########################################################################
set Target_CPU=206

@echo .
@echo - construction de %nom_archive%_%Target_CPU%.ZIP -------------------
cd      %home_dev%
cp -R   %EXE_binaire%/%appli_prefix%%Target_CPU%.PRG  %projet%/%dossier%/ > CONout.txt
rem cp -R   %EXE_binaire%/%appli_prefix%68D.PRG           %projet%/%dossier%/ > CONout.txt
cp -R   %dossier_TGA_SA_LDG%/6802060/TGA_SA.LDG       %projet%/%dossier%/ > CONout.txt

cd      %home_dev%/%projet%
@echo suppression de l'archive si elle existe
rm -v   %nom_archive%_%Target_CPU%.ZIP

@echo creation de l'archive ZIP du binaire...
zip -rv %nom_archive%_%Target_CPU%.ZIP  %dossier% -x*.H -x*.HRD    > CONout.txt

cd   %home_dev%/%projet%/%dossier%
rm -v   %appli_prefix%%Target_CPU%.PRG
rm -v   %appli_prefix%68D.PRG



rem ########################################################################
set Target_CPU=V4E
cd      %home_dev%
@echo .
@echo - construction de %nom_archive%_%Target_CPU%.ZIP -------------------

cp -R   %EXE_binaire%/%appli_prefix%%Target_CPU%.PRG  %projet%/%dossier%/ > CONout.txt
cp -R   %EXE_binaire%/%appli_prefix%V4D.PRG           %projet%/%dossier%/ > CONout.txt
cp -R   %dossier_TGA_SA_LDG%/CFV4E/TGA_SA.LDG         %projet%/%dossier%/ > CONout.txt

cd      %home_dev%/%projet%
@echo suppression de l'archive si elle existe
rm -v   %nom_archive%_%Target_CPU%.ZIP

@echo creation de l'archive ZIP du binaire...
zip -rv %nom_archive%_%Target_CPU%.ZIP  %dossier% -x*.H -x*.HRD    > CONout.txt





rem ########################################################################

rem suppression du fichier qui avale les textes de la console
rm -v   CONout.txt
cd      %home_dev%
rm -v   CONout.txt

@echo *
@echo c'est fini
cd %home_dev%

