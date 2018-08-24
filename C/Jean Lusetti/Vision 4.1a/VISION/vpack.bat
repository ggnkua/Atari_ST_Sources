echo Packing VISION...
rmdir /S /Q vpack
mkdir vpack
cd vpack
mkdir VISION
cd VISION

copy /Y ..\..\vision.in0 vision.ini
xcopy ..\..\DSP DSP\ /S /Y
xcopy ..\..\FILTRES FILTRES\ /S /Y
xcopy ..\..\LANGUES LANGUES\ /S /Y
xcopy /Y /E X:\documents\MonWeb\vision.doc\ldv ..\..\LDV\doc\
xcopy /Y /E X:\documents\MonWeb\vision.doc\english\ldv ..\..\LDV\doc\english\
xcopy ..\..\LDV LDV\ /S /Y

del /S /Q LANGUES\*.pdb
del /S /Q LDV\*.pdb
del /S /Q LDV\*.o

copy /Y ..\..\vision.prg .
copy /Y ..\..\histoire.txt .
copy /Y ..\..\leggimi.txt .
copy /Y ..\..\readme.txt .
copy /Y ..\..\tcw*.dat .
copy /Y ..\..\vision.img .
copy /Y ..\..\license.txt .

del /Q ..\..\vision.zip
cd ..
"%ProgramFiles%\7-Zip\7z.exe" a -r -y ..\vision.zip vision
xcopy /Y ..\vision.zip X:\documents\MonWeb\download\

cd ..
rmdir /S /Q vpack
