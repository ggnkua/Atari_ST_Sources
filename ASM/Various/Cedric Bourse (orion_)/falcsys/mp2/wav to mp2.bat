echo off
cls
echo Warning, your wav file must be 32000 hz !
echo Use this version of twolame:
echo http://www.rarewares.org/files/mp3/twolame0.3.13.zip
pause
twolame -b 128 music.wav music.mp2
pause
