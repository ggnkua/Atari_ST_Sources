   _______ _______ _______ _______ ___     ___     _______  ___ ___
  |   _   |   _   |   _   |   _   |   |   |   |   |   _   |(   Y   )
  |.  1   |.  1   |.  l   |.  1   |.  |   |.  |   |.  1   | \  1  /
  |.  ____|.  _   |.  _   |.  _   |.  |___|.  |___|.  _   | /  _  \
  |:  |   |:  |   |:  |   |:  |   |:  1   |:  1   |:  |   |/:  |   \
  |::.|   |::.|:. |::.|:. |::.|:. |::.. . |::.. . |::.|:. (::. |:.  )
  `---'   `--- ---`--- ---`--- ---`-------`-------`--- ---'`--- ---'
 ______   ___ _______ _______ _______ _______ _______ _______ _______ 
|   _  \ |   |   _   |       |   _   |   _   |       |   _   |   _   \
|.  |   \|.  |   1___|.|   | |.  |   |.  l   |.|   | |.  1___|.  l   /
|.  |    |.  |____   `-|.  |-|.  |   |.  _   `-|.  |-|.  __)_|.  _   1
|:  1    |:  |:  1   | |:  | |:  1   |:  |   | |:  | |:  1   |:  |   |
|::.. . /|::.|::.. . | |::.| |::.. . |::.|:. | |::.| |::.. . |::.|:. |
`------' `---`-------' `---' `-------`--- ---' `---' `-------`--- ---'

  .-----------------------------------------------------------------.
 /  PARADIS3 - PARALLAX DISTORTER - DYNO - STNICC 2015               \
 '-------------------------------------------------------------------'
  :                                                                 :
  : Dyno proudly presents his first demo-screen since 1995, as a    :
  : contribution to the STNICCC 2015 demoparty that took place in   :
  : Gouda (Netherlands) on december 18th 2015.                      :
  :                                                                 :
  : Yet another parallax distorter, will you say ? Yes ! In my      :
  : opinion, the original demo by ULM has always been the best      :
  : fullscreen scroller ever on Atari ST, but I always thought it   :
  : was possible to do more. Therefore, this year, during a period  :
  : of nostalgia, I decided to dive myself again in assembly        :
  : programming, and tried to do it better. I spent a few months    :
  : coding on the screen, from scratch, and here is the result, not :
  : very original I must admit (no revolutionary technique here !), :
  : but I think the result was worth the effort.                    :
  :                                                                 :
  : Unfortunately, due to hardware issues, this demo was entirely   :
  : coded on Hatari emulator, tested on my 520 STF+STE, but I was   :
  : not able to intensively test my overscan and sync-scroll        :
  : routines on lot of computers, so I do apologize if this screen  :
  : does not work on some STs !                                     :
  :                                                                 :
  : This screen is released with the open-source code included if   :
  : anyone is interested...                                         :
  :                                                                 :
  .-----------------------------------------------------------------.
 /  CREDITS FOR THIS SCREEN                                          \
 '-------------------------------------------------------------------'
  :                                                                 :
  :  .oO  Code, Font, Sample : DYNO                            Oo.  :
  :  .oO  Original font      : OXAR                            Oo.  :
  :  .oO  Background pattern : AGENT-t / Cream                 Oo.  :
  :  .oO  Intro YM music     : DMA-SC / Sector One             Oo.  :
  :                                                                 :
  .-----------------------------------------------------------------.
 /  SOME INTERESTING STATS                                           \
 '-------------------------------------------------------------------'
  :                                                                 :
  :  .oO  The demo run in 512K                                 Oo.  :
  :  .oO  4 overscan screens : 4*288*230 = 265K                Oo.  :
  :  .oO  Font size : 48x36 px                                 Oo.  :
  :  .oO  Font : 121 tiles * 48 bytes * 16 shifts = 93K        Oo.  :
  :  .oO  Text data : 44K                                      Oo.  :
  :  .oO  Background palette : 10K                             Oo.  :
  :  .oO  Curves : 11K                                         Oo.  :
  :  .oO  Generated code for the overscan : 24K                Oo.  :
  :  .oO  8.3 Khz digital samples : 4*14K = 57K                Oo.  :
  :  .oO  Code : 8K                                            Oo.  :
  :                                                                 :
  .-----------------------------------------------------------------.
 /  GREETINGS (IN NO SPECIAL ORDER)                                  \
 '-------------------------------------------------------------------'
  :                                                                 :
  :  .oO  Sector One             Oo.oO  The Exceptions         Oo.  :
  :  .oO  NoExtra                Oo.oO  The Lost Boys          Oo.  :
  :  .oO  ST Knights             Oo.oO  The Respectables       Oo.  :
  :  .oO  Hemoroids              Oo.oO  Electra                Oo.  :
  :  .oO  Overlanders            Oo.oO  Level 16               Oo.  :
  :  .oO  MJJ Prod               Oo.oO  Avena                  Oo.  :
  :  .oO  Oxygene                Oo.oO  Omega                  Oo.  :
  :  .oO  Dune                   Oo.oO  SYNC                   Oo.  :
  :  .oO  Paradize               Oo.oO  Quartermass Xperiment  Oo.  :
  :  .oO  Equinox                Oo.oO  tSCc                   Oo.  :
  :  .oO  NeXT                   Oo.oO  Aggression             Oo.  :
  :  .oO  ST Connexion           Oo.oO  ACF                    Oo.  :
  :  .oO  WAB Group              Oo.oO  Paradox                Oo.  :
  :  .oO  Trio                   Oo.oO  Unlimited Matricks     Oo.  :
  :                                                                 :
  .-----------------------------------------------------------------.
 /  CONTACT ADDRESS                                                  \
 '-------------------------------------------------------------------'
  :                                                                 :
  : If you have any comment, remark, suggestion, just contact me at :
  : the following address : dyno@aldabase.com                       :
  :                                                                 :
  .-----------------------------------------------------------------.
   ______  ___ ___ ______  _______     _______ _______ _____ _______
  |   _  \|   Y   |   _  \|   _   |   |       |   _   | _   |   _   |
  |.  |   |   1   |.  |   |.  |   |   |___|   |.  |   |.|   |   1___|
  |.  |    \_   _/|.  |   |.  |   |    /  ___/|.  |   `-|.  |____   |
  |:  1    /|:  | |:  |   |:  1   |   |:  1  \|:  1   | |:  |:  1   |
  |::.. . / |::.| |::.|   |::.. . |   |::.. . |::.. . | |::.|::.. . |
  `------'  `---' `--- ---`-------'   `-------`-------' `---`-------'
                                                   December 18th 2015