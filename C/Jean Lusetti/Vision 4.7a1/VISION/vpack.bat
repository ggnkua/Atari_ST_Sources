echo Packing VISION...
rem rmdir /S /Q vpack
rem mkdir vpack
rem cd vpack
rem mkdir VISION
rem cd VISION

rem copy /Y ..\..\vision.in0 vision.ini
rem xcopy ..\..\DSP DSP\ /S /Y
rem xcopy ..\..\FILTRES FILTRES\ /S /Y
rem xcopy ..\..\LANGUES LANGUES\ /S /Y
rem xcopy ..\..\SCRIPTS SCRIPTS\ /S /Y
xcopy /Y /E X:\documents\MonWeb\vision.doc\ldv LDV\doc\
xcopy /Y /E X:\documents\MonWeb\vision.doc\english\ldv LDV\doc\english\
rem xcopy ..\..\LDV LDV\ /S /Y
rem mkdir TEMP
rem mkdir UPDATE

rem del /S /Q LANGUES\*.pdb
rem del /S /Q LDV\*.pdb
rem del /S /Q LDV\*.o

rem copy /Y ..\..\vision.prg .
rem copy /Y ..\..\visionl.prg .
rem copy /Y ..\..\histoire.txt .
rem copy /Y ..\..\leggimi.txt .
rem copy /Y ..\..\readme.txt .
rem copy /Y ..\..\tcw*.dat .
rem copy /Y ..\..\vision.img .
rem copy /Y ..\..\license.txt .
rem copy /Y ..\..\png.txt .
rem copy /Y ..\..\vision.ver .

cd vpack/VISION
del /Q ..\..\vision.zip
cd ..
"%ProgramFiles%\7-Zip\7z.exe" a -r -y ..\vision.zip vision
xcopy /Y ..\vision.zip X:\documents\MonWeb\download\
xcopy /Y ..\srcvis.zip X:\documents\MonWeb\download\

echo copy to Hatari...
xcopy /Y /E vision D:\app\Hatari\drivec\temp\vision
xcopy /Y /E vision D:\app\Hatari\drivecst\temp\vision

rem cd ..
rem rmdir /S /Q vpack
