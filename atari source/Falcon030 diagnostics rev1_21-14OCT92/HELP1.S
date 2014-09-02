help1:  dc.b    'RUNNING UNATTENDED TESTS',cr,lf
.if PREPROD=0
        dc.b    'Select a single test or any combination of  tests by typing the corresponding'
        dc.b    cr,lf
        dc.b    'letter or letters, then typing the RETURN key.  To run repeated cycles of the'
        dc.b    cr,lf
        dc.b    'test or (tests), follow the last letter with the number of cycles to run. For'
        dc.b    cr,lf
        dc.b    'example,  "RSM25",  will run  RAM,  Serial, and MIDI tests 25 times.  If 0 is'
        dc.b    cr,lf
        dc.b    'entered, testing will be continuous.'
        dc.b    cr,lf,lf

        dc.b    'Use the ESC key to quit the test cycle.   In some cases there will be a delay'
        dc.b    cr,lf
        dc.b    'before control returns to the keyboard.'
        dc.b    cr,lf,lf

        dc.b    'An RS232 terminal may  be used for input and display.   The Serial RS232 test'
        dc.b    cr,lf
        dc.b    'will not pass  if  a  terminal  is installed  in  place of the loopback plug.'
        dc.b    cr,lf
        dc.b    'Normally a  color monitor  is used for  all tests accept high resolution.  If'
        dc.b    cr,lf
        dc.b    'an error occurs,  an error message will be displayed and the screen will turn'
        dc.b    cr,lf
        dc.b    'red. When the test completes, Pass or Fail will be displayed,  and the screen'
        dc.b    cr,lf
        dc.b    'will turn green or red.'
        dc.b    cr,lf,lf
        dc.b    'If  multiple tests are run and an error occurs  on any test,  the screen will'
        dc.b    cr,lf
        dc.b    'remain  red,  although successive tests pass.  Once the test has halted,  the'
        dc.b    cr,lf
        dc.b    'SPACE BAR is used to return to the menu.'
        dc.b    cr,lf,lf

        dc.b    'The  DMA  and Printer/joystick/game port  tests require  that  the  port test'
        dc.b    cr,lf
        dc.b    'fixtures be connected.',cr,lf
.endif
        dc.b    lf,eot

help2:  dc.b    'The  O.S. ROM test calculates  a  checksum/CRC  of  the ROMs and compares the'
.if PREPROD=0
        dc.b    cr,lf
        dc.b    'resultant CRC with the value found in the ROMs.'
        dc.b    cr,lf,lf

        dc.b    'If the RAM test fails, the error code,  address,  data written, data read and'
        dc.b    cr,lf
        dc.b    'bad bits (0-15) are displayed.'
        dc.b    cr,lf
        dc.b    '>> INCLUDE DSP HELP HERE! <<'
        dc.b    cr,lf,lf

        dc.b    'The short Blitter test does not display any graphics  on the screen. The long' 
        dc.b    cr,lf
        dc.b    'Blitter test, while appearing not to finish the rectangle, is ok.'
        dc.b    cr,lf,lf 
        dc.b    'OPERATOR REQUIRED TESTS',cr,lf
        dc.b    'The Audio, Video, Keyboard, and Hard disk tests have few error'
        dc.b    cr,lf
        dc.b    'messages.  The operator must determine  if the output results are acceptable.'
        dc.b    cr,lf,lf
        dc.b    'The Gen/lock test is run twice.  Toggling the switch on the  gen/lock fixture'
        dc.b    cr,lf
        dc.b    'should switch between the normal menu and no menu.  With no menu a "sweeping"'
        dc.b    cr,lf
        dc.b    'cycle should be heard.  Reset the computer with each change  of the  gen/lock'
        dc.b    cr,lf 
        dc.b    'switch.' 
        dc.b    cr,lf 
        dc.b    '               NOTE - RUN THIS TEST ONLY WITH A COLOR MONITOR'
.endif
        dc.b    eot 

  
