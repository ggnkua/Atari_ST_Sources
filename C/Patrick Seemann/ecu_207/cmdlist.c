/* --------------------------------------------------------------------
   Modul:      CMDLIST.C
   Subject:    Config Command List for ECU & LLEGADA
   Author:     ho
   Started:    16.12.1990  10:24:26                
   --------------------------------------------------------------------
   94-04-03ps  HoldScreen,
               NoWait entfernt
   93-12-20ps  HostPrefix
   93-07-29ps  Support fÅr Achmed
   92-11-08ps  MsgLink
   92-10-18ps  2+Pkt, Username
   --------------------------------------------------------------------
   03.05.1992  ExportFlags
   23.03.1992  LastReadQBBS
   06.02.1992  RouteTo, CrashToPoints
   15.01.1992  4dEchomail
   05.01.1992  Domain
   08.12.1991  SaveScreen/RestoreScreen optional
   10.11.1991  Censor-Liste
   09.11.1991  MatchMin
   03.11.1991  Arced Crashmail
   02.11.1991  IOS-Flow-Files
   13.10.1991  Signature, LharcUnpack
   28.09.1991  WhichArc
   19.09.1991  NewAreaDirectory
   18.09.1991  Cookies and Origins
   09.06.1991  Force INTL-Line
   04.05.1991  HighMessageCount
   01.05.1991  GoodUnpackReturn
   07.04.1991  UseZones
   05.04.1991  CreateTB
   25.02.1991  QuickScan
   20.01.1991  3dEchomail/3dNetmail
   18.12.1990  RouteEchos
   -------------------------------------------------------------------- */



#include "global.h"



CMDLIST  CmdList[]   = {
                        {  "2+Pkt",             CMD_2PLUSPKT      },
                        {  "3dAddress",         CMD_3DADDRESS     },
                        {  "3dEchomail",        CMD_3DECHOMAIL    },
                        {  "3dMsgId",           CMD_3DMSGID       },
                        {  "3dNetmail",         CMD_3DNETMAIL     },
                        {  "3dOrigin",          CMD_3DORIGIN      },
                        {  "3dPath",            CMD_3DPATH        },
                        {  "3dSeenBy",          CMD_3DSEENBY      },
                        {  "3dTick",            CMD_3DTICK        },
                        {  "4dEchomail",        CMD_4DECHOMAIL    },
                        {  "Achmed",            CMD_ACHMED        },
                        {  "AddressPrefix",     CMD_ADRPREFIX     },
                        {  "Alias",             CMD_ALIAS         },
                        {  "AppendTB",          CMD_APPENDTB      },
                        {  "ArcMailName",       CMD_ARCMAIL       },
                        {  "ArcPack",           CMD_ARCOUT        },
                        {  "ArcUnpack",         CMD_ARCIN         },
                        {  "Area",              CMD_AREA          },
                        {  "AreaName",          CMD_AREANAME      },
                        {  "Arealist",          CMD_AREAS         },
                        {  "Areasize",          CMD_AREASIZE      },
                        {  "ArjUnpack",         CMD_ARJIN         },
                        {  "BadMsgArea",        CMD_BADMSGAREA    },
                        {  "Boss",              CMD_BOSS          },
                        {  "CalcCrc",           CMD_STORECRC      },
                        {  "Compress",          CMD_COMPRESS      },
                        {  "CookieJar",         CMD_COOKIE        },
                        {  "CrashToPoints",     CMD_CRASHPOINTS   },
                        {  "CreateIOS",         CMD_IOSFLOW       },
                        {  "CreateTB",          CMD_CREATETB      },
                        {  "Crunch",            CMD_CRUNCH        },
                        {  "Days",              CMD_DAYS          },
                        {  "DaysLocal",         CMD_LDAYS         },
                        {  "DecimalCRC",        CMD_DECCRC        },
                        {  "Default",           CMD_DEFAULT       },
                        {  "DefaultUnpack",     CMD_DEFIN         },
                        {  "DefaultZone",       CMD_DEFAULTZONE   },
                        {  "DeleteArchive",     CMD_GOODUNPACK    },
                        {  "DeletePkt",         CMD_ARCDEL        },
                        {  "DiskName",          CMD_FILENAME      },
                        {  "Domain",            CMD_DOMAIN        },
                        {  "DummyFLO",          CMD_DUMMYFLOW     },
                        {  "End",               CMD_END           },
                        {  "ExportFlags",       CMD_EXFLAGS       },
                        {  "ForceIntl",         CMD_FORCEINTL     },
                        {  "FormatPrefix",      CMD_FMTPREFIX     },
                        {  "FroDoPkt",          CMD_FRODOPKT      },
                        {  "HexCRC",            CMD_HEXCRC        },
                        {  "HighLimit",         CMD_HIGHLIMIT     },
                        {  "HoldScreen",	CMD_HOLDSCREEN    },
                        {  "HomeDir",           CMD_HOMEDIR       },
                        {  "Host",              CMD_HOST          },
                        {  "HostPrefix",        CMD_HOSTPREFIX    },
                        {  "Inbound",           CMD_INBOUND       },
                        {  "KeepArea",          CMD_KEEPAREA      },
                        {  "KillDupes",         CMD_DUPES         },
                        {  "KillHold",          CMD_KILLHOLD      },
                        {  "KillLocal",         CMD_KILLLOCAL     },
                        {  "LastRead",          CMD_LASTREAD      },
                        {  "LastReadQBBS",      CMD_LASTREADQBBS  },
                        {  "LedNew",            CMD_LEDNEW        },
                        {  "LhaUnpack",         CMD_LHAIN         },
                        {  "LharcUnpack",       CMD_LZHIN         },
                        {  "LogLevel",          CMD_LOGLEVEL      },
                        {  "LogMsgArea",        CMD_LOGAREA       },
                        {  "Logfile",           CMD_LOGFILE       },
                        {  "LowLimit",          CMD_LOWLIMIT      },
                        {  "MatchMin",          CMD_NONETMAIL     },
                        {  "Matrix",            CMD_MATRIX        },
                        {  "MsgLink",           CMD_MSGLINK       },
                        {  "Netmail",           CMD_NETMAIL       },
                        {  "NewAreaDirectory",  CMD_NEWAREADIR    },
                        {  "NoCrunch",          CMD_NOCRUNCH      },
                        {  "Node",              CMD_NODE          },
                        {  "NoNetmail",         CMD_NONETMAIL     },
                        {  "NoOutput",          CMD_NOOUTPUT      },
                        {  "NoRestore",         CMD_NORESTORE     },
                        {  "Origin",            CMD_ORIGIN        },
                        {  "Outbound",          CMD_OUTBOUND      },
                        {  "PackCrashMail",     CMD_ARCEDCRASH    },
                        {  "Password",          CMD_PASSWORD      },
                        {  "Point",             CMD_POINT         },
                        {  "ProductId",         CMD_PRODID        },
                        {  "QMailPkt",          CMD_QMAILPKT      },
                        {  "QuickScan",         CMD_QUICK         },
                        {  "RandomOrigin",      CMD_RNDORIGIN     },
                        {  "RouteEchos",        CMD_ROUTEECHO     },
                        {  "RouteTo",           CMD_ROUTETO       },
                        {  "Rules",             CMD_CENSOR        },
                        {  "SerialNumber",      CMD_SERIAL        },
                        {  "Signature",         CMD_SIGNATURE     },
                        {  "SoftReturn",        CMD_SOFTRETURN    },
                        {  "StandardPkt",       CMD_STDPKT        },
                        {  "Sysop",             CMD_SYSOP         },
                        {  "TickArea",          CMD_TICKAREA      },
                        {  "TickIndicator",     CMD_TICKINDICATOR },
                        {  "TickPrefix",        CMD_TICKPREFIX    },
                        {  "UseAreas",          CMD_USEAREAS      },
                        {  "UseZones",          CMD_USEZONES      },
                        {  "Username",          CMD_USERNAME      },
                        {  "ZipUnpack",         CMD_ZIPIN         },
                        {  "ZooUnpack",         CMD_ZOOIN         },
                        {  NULL,                0                 },
                       };

