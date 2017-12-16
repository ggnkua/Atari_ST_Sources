       _____________________ __________.___    ____________________
      /  _  \__    ___/  _  \\______   \   |  /   _____/\__    ___/
     /  /_\  \|    | /  /_\  \|       _/   |  \_____  \   |    |520
    /    |    \    |/    |    \    |   \   |  /        \  |    |F/E
    \____|__  /____|\____|__  /____|_  /___| /_______  /  |____|
            \/              \/       \/              \/
  .-----------------------------------------------------------------.
 /  4K 4-BITS MEGA SCROLLER, by DYNO             SILLY VENTURE 2K17  \
 '-------------------------------------------------------------------'
  :                                                                 :
  : Dyno proudly presents his contribution to the SillyVenture demo :
  : party that took place in Gdansk (Poland) on december 9th 2017   :
  :                                                                 :
  : This is a Mega Scroller in just four kilobyte, using the 4-bits :
  : hardscroll technique created by Alien/ST Connexion.             :
  :                                                                 :
  : The demo works on Atari STF with 512k RAM.                      :
  :                                                                 :
  : It also works on STE/Mega STE, using native scroll features     :
  : (hscroll register without prefetch) at the expense of a black   :
  : border added on the left of the screen                          :
  :                                                                 :
  : I had inspiration for this screen watching the hidden screen by :
  : the Black Cats on the Vodka demo by Equinox, with its nice and  :
  : polished font.                                                  :
  :                                                                 :
  : To fit into 4kb, the demo is compressed with the amazing        :
  : Shrinkler packer, by Blueberry/Loonies.                         :
  :                                                                 :
  : The commented source code is attached if anyone is interested.  :
  :                                                                 :
  .-----------------------------------------------------------------.
 /  CREDITS FOR THIS SCREEN                                          \
 '-------------------------------------------------------------------'
  :                                                                 :
  : Code and font      : DYNO                                       :
  : Background pattern : SKYWALKER / Exo7                           :
  : Music              : TAO / Cream                                :
  :                                                                 :
  .-----------------------------------------------------------------.
 /  SPECIAL THANKS                                                   \
 '-------------------------------------------------------------------'
  :                                                                 :
  : I would like to send a special thanks to Alien/ST Connexion     :
  : who did a series of articles about overscan in ST Magazine, a   :
  : french publication (that were partially translated in Alive     :
  : diskmag 9 & 11), and where he explained the 4-bits hardscroll   :
  : technique in detail, in ST Magazine 55 from october 1991...     :
  :                                                                 :
  : This article (like the previous ones !) have been a great       :
  : source of inspiration when coding this screen. For all these    :
  : brilliant articles, thank you very much Alien, you have my      :
  : eternal gratitude !                                             :
  :                                                                 :
  .-----------------------------------------------------------------.
 /  GREETINGS                                                        \
 '-------------------------------------------------------------------'
  :                                                                 :
  : ACF Design Team  (Agent -T-, Jacky, Tao)                        :
  : Aenigmatica  (The Mind, The Nutty Snake, Zokathra)              :
  : Aggression  (Creator, Teque, WizTom)                            :
  : Alive Team  (CiH, Felice, ST Survivor)                          :
  : Atari Legend  (Brume, ST Graveyard)                             :
  : Avena  (Fried, Tat, Thyroxin)                                   :
  : Checkpoint  (Defjam, Lsl)                                       :
  : D-Bug  (Cyrano Jones, GGN)                                      :
  : Dead Hackers Society (Evil, Gizmo)                              :
  : Delta Force  (Big Alec, Chaos Inc, Flix)                        :
  : Demografica  (Big Boss Man)                                     :
  : Dune  (Chuck, Mic, Thadoss)                                     :
  : Effect  (Pandafox, Tronic)                                      :
  : Electra  (Abel, Icarus, Kasper)                                 :
  : Equinox  (Keops, Starlion)                                      :
  : Exo7  (Blue Murder, Goofy, Rick, Sademan, Skywalker)            :
  : Fuzion (Orion)                                                  :
  : Hemoroids  (Ayoros, Marco Polo, Sink, Totorman, Wieczor)        :
  : Holocaust (Zappy)                                               :
  : Legacy (Fury, Vickers)                                          :
  : Level 16  (Ilja, Nod)                                           :
  : MJJ Prod  (Gloky, Shazz, Strider)                               :
  : Mystic Bytes  (Grey, Sqward)                                    :
  : Naos (Nucleus, Ric)                                             :
  : NeXT  (Dbug, Mit)                                               :
  : NoExtra  (Hylst, Zorro2)                                        :
  : No Group  (Mcoder)                                              :
  : Omega  (Haq, Liesen, The Flying Egg)                            :
  : Overlanders  (Adso, Dim, Mr. Bee, Ziggy Stardust)               :
  : Oxygene  (Leonard, Mon, Niko)                                   :
  : Paradize  (ST Cooper, Sunnyboy)                                 :
  : Paradox  (Dan, Paranoid, RA)                                    :
  : Pendragons  (Megadeth, Terence)                                 :
  : Quartermass Xperiment  (Cronos, Relayer)                        :
  : Replicants  (Illegal)                                           :
  : Reservoir Gods  (Griff, Mr. Pink)                               :
  : Sector One  (Hello, Zerkman, Splash, Zoby One)                  :
  : SMFX  (SPKR)                                                    :
  : STAX  (Rockabit)                                                :
  : ST Connexion  (Alien, Belzebub, Vantage)                        :
  : ST Knights  (Dieu, Kelly X)                                     :
  : Superior (Axe)                                                  :
  : SYNC  (BlueSTar, Redhead, Troed)                                :
  : Synergy  (Rapido, Wingleader)                                   :
  : The Carebears  (An Cool, Jas, Nic, Tanis)                       :
  : The Exceptions  (6719, Alyssa, Daryl, ES, Mad Max)              :
  : The Giants  (Corsair, Havoc, Rex)                               :
  : The Invisibles  (Skaven)                                        :
  : The Lost Boys  (Digital Insanity, Manikin, Oxygene, Sammy Joe)  :
  : The Respectables  (Duke, Tyrem)                                 :
  : TOS-Crew  (Mr Ni)                                               :
  : Trio  (NoNameNo)                                                :
  : Tscc  (Insane, Lotek Style, Ray, Thorn)                         :
  : Unlimited Matricks  (Chris, Gunstick, The Fate)                 :
  : WAB Group  (Dr Skull, Frutbunn, Mellow Man, NewCore, SoLo)      :
  : YM Rockerz  (Dma-Sc, gwEm)                                      :
  :                                                                 :
  .-----------------------------------------------------------------.
 /  CONTACT ADDRESS                                                  \
 '-------------------------------------------------------------------'
  :                                                                 :
  : If you have any comment, remark, suggestion, just contact me at :
  : the following address : dyno@aldabase.com                       :
  :                                                                 :
  : Or if you want to recruit a new friendly coder to expand your   :
  : team, do not hesitate, I am open to all offers ;-)              :
  :                                                                 :
  .-----------------------------------------------------------------.
   ______  ___ ___ ______  _______     _______ _______ _____ _______ 
  |   _  \|   Y   |   _  \|   _   |   |       |   _   | _   |   _   |
  |.  |   |   1   |.  |   |.  |   |   |___|   |.  |   |.|   |___|   |
  |.  |    \_   _/|.  |   |.  |   |    /  ___/|.  |   `-|.  |  /   / 
  |:  1    /|:  | |:  |   |:  1   |   |:  1  \|:  1   | |:  | |   |  
  |::.. . / |::.| |::.|   |::.. . |   |::.. . |::.. . | |::.| |   |  
  `------'  `---' `--- ---`-------'   `-------`-------' `---' `---'  
                                                    December 9th 2017