REM ******************************************************
REM * STE PLAYBACK  Demo for HISOFT AND POWER BASIC      *
REM * USES DMA OUTPUT ON A SINGLE MONO CHANNEL           *
REM * by D.A.W. (c) Audio Visual Research 1991           *
REM ******************************************************
REM * Reserve memory for sample   *
REM *******************************
DIM b%(10000)
sample=VARPTR(b%(0))
REM ********************
REM * Load Demo sample *
REM ********************
PRINT "Loading Sample."
BLOAD "welcome.avr",sample
REM remove header
sample=sample+128
REM *************************
REM * Sample data :-        *
REM * length =  7000 bytes  *
REM *************************
length=7000
dma=&HFF8900
' reset dma
POKE dma,0
'
' set sample rate and mono mode
POKE dma+32,&H81

'
' set start , count and end addresses
POKE dma+2,sample/&H10000
POKE dma+4,sample/&H100
POKE dma+6,sample AND &HFF
POKE dma+8,sample/&H10000
POKE dma+&HA,sample/&H100
POKE dma+&HC,sample AND &HFF
POKE dma+&HE,(sample+length)/&H10000
POKE dma+&H10,(sample+length)/&H100
POKE dma+&H12,(sample+length) AND &HFF
'
' play sample
POKE dma,1
FOR n=0 TO 30000
NEXT n
' play sample at different playback rates
FOR speed=0 TO 3
  PRINT "PLAYING SAMPLE AT SPEED ";speed
  POKE dma+32,&h80+speed
  ' DMA LOOPED
  POKE dma,3
  FOR n=0 TO 20000
  NEXT n
NEXT speed
'
' STOP DMA
POKE dma,0
END
