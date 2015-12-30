::
:: http://sun.hasenbraten.de/vasm/index.php?view=tutorial
:: http://sun.hasenbraten.de/vasm/release/vasm.html
::


md exported

::
:: Fonts
::
%osdk%/bin/PictConv -m1 -f2 -o2 data\c64_charset.png exported\c64_charset_converted.pi3
%osdk%/bin/PictConv -m1 -f2 -o2 data\16x16_ANSI.png exported\16x16_ANSI.pi3
%osdk%/bin/PictConv -m1 -f2 -o2 data\stniccc-2015.png exported\stniccc.pi3



::
:: Logos
::
%osdk%/bin/PictConv -m1 -f2 -o2 -s1 data\logo_defence-force.png exported\logo_defence-force.pi3
%osdk%/bin/PictConv -m1 -f2 -o2 -s1 data\c128.png exported\c128.pi3
%osdk%/bin/PictConv -m1 -f2 -o2 -s1 data\impact.png exported\impact.pi3

%osdk%/bin/PictConv -m1 -f2 -o2 data\logo_punks.png exported\logo_punks.pi3
%osdk%/bin/PictConv -m1 -f2 -o2 data\logo_beat-slappaz.png exported\logo_beat-slappaz.pi3

::
:: Audio
::

::
:: Convert the samples from whatever they are to 8 bit mono
::
:: Wavosaur pbm:31.95
:: 
:: Total: 3:17:746 = (60*3+17)*1000+746=197746
:: 
:: Loops:    
:: 1:875
:: 1:877
:: 1:873
:: 1:872
:: 1:879
:: 
:: 
:: 197746/1875=105
::
:: Possible frequencies:
::  6258 hertz
:: 12517 hertz
:: 25033 hertz
:: 50066 hertz
::
:: -e unsigned-integer   <- for SampleTweaker / dlt files
:: -e signed-integer     <- if samples are loaded directly on the ste
::
:: Sox Manual: http://sox.sourceforge.net/sox.html
::
set SOX=C:\Tools\sox-14.4.2-win32\sox-14.4.2\sox.exe
set PARAMS=-b 8 -c 1 -r 6258 -e unsigned-integer
set PARAMS2=-b 8 -c 1 -r 6258

::set PARAMS=-b 8 -c 1 -r 12517 -e unsigned-integer 
set EFFECT=gain -6

%SOX% data\duumduum.wav %PARAMS% data\temp\duumduum.raw %EFFECT%
%SOX% data\a_1.wav %PARAMS% data\temp\a_1.raw %EFFECT%
%SOX% data\a_2.wav %PARAMS% data\temp\a_2.raw %EFFECT%
%SOX% data\b_1.wav %PARAMS% data\temp\b_1.raw %EFFECT%
%SOX% data\b_2.wav %PARAMS% data\temp\b_2.raw %EFFECT%
%SOX% data\c_1.wav %PARAMS% data\temp\c_1.raw %EFFECT%
%SOX% data\c_2.wav %PARAMS% data\temp\c_2.raw %EFFECT%
%SOX% data\c_3.wav %PARAMS% data\temp\c_3.raw %EFFECT%
%SOX% data\end.wav %PARAMS% data\temp\end.raw %EFFECT%
%SOX% data\ping_ah.wav %PARAMS% data\temp\ping_ah.raw %EFFECT%
%SOX% data\gunshot.wav %PARAMS% data\temp\gunshot.raw %EFFECT%

%SOX% data\kickthat.wav %PARAMS2% exported\kickthat.raw %EFFECT%
%SOX% data\flipthis.wav %PARAMS2% exported\flipthis.raw %EFFECT%
%SOX% data\bulletholes.wav %PARAMS2% exported\bulletholes.raw %EFFECT%

SampleTweaker.exe  data\temp\duumduum.raw exported\duumduum.dlt
SampleTweaker.exe  data\temp\a_1.raw exported\a_1.dlt
SampleTweaker.exe  data\temp\a_2.raw exported\a_2.dlt
SampleTweaker.exe  data\temp\b_1.raw exported\b_1.dlt
SampleTweaker.exe  data\temp\b_2.raw exported\b_2.dlt
SampleTweaker.exe  data\temp\c_1.raw exported\c_1.dlt
SampleTweaker.exe  data\temp\c_2.raw exported\c_2.dlt
SampleTweaker.exe  data\temp\c_3.raw exported\c_3.dlt
SampleTweaker.exe  data\temp\end.raw exported\end.dlt
SampleTweaker.exe  data\temp\ping_ah.raw exported\ping_ah.dlt
SampleTweaker.exe  data\temp\gunshot.raw exported\gunshot.dlt

::
:: Missing
:: - keyboard.dlt
:: - sine_16b.bin
:: - sine_255.bin
:: - dithering.ani
::

pause
