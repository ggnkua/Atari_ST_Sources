* Motorola Fast Floating Point Demonstration
* MECB I/O, Intermetrics assembler

          NOPAGE
          ORG       $001000
START     BRA.L     MAIN
          INCLUDE   'FFPCPYRT.X68'
          INCLUDE   'IOMECB.X68'
          INCLUDE   'FFPADD.X68'
          INCLUDE   'FFPMUL.X68'
          INCLUDE   'FFPDIV.X68'
          INCLUDE   'FFPSQRT.X68'
          INCLUDE   'FFP10TBL.X68'
          INCLUDE   'FFPDBF.X68'
          INCLUDE   'FFPAFP.X68'
          INCLUDE   'FFPFPA.X68'
          INCLUDE   'FFPTNORM.X68'
          INCLUDE   'FFPTHETA.X68'
          INCLUDE   'FFPSIN.X68'
          INCLUDE   'FFPDEMO.X68'
MAIN      BRA       FFPDEMO
          END       START
