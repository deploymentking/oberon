(**************************************************************************)
(*                                                                        *)
(*  Fallstudien Betriebssysteme: Windowsprogrammierung mit Oberon-2       *)
(*  Abschlußprojekt:    Black Jack                                        *)
(*  Aufgabe:            Kartenspiel unter Verwendung von cardList.DLL     *)
(*                                                                        *)
(*  Modulname:          INI.MOD                                           *)
(*  Aufgabe:            Ini Datei lesen bzw. schreiben                    *)
(*                                                                        *)
(*  Autoren:            Gschnell Christian, 9155609, 880                  *)
(*                      Jungwirth Josef,    9155355, 880                  *)
(*                      Köttstorfer Marco,  9155255, 880                  *)
(*                                                                        *)
(*  Erstellt am:        16.05.1995                                        *)
(*  Änderungen:         17.03.1997 Es wird angenommen, daß sich die WAV-  *)
(*                                 Dateien im selben Verzeichnis wie das  *)
(*                                 Programm befindet.                     *)
(*                                                                        *)
(**************************************************************************)

MODULE INI;

IMPORT W := Windows, S := Strings, SYSTEM;

CONST
  FILENAME     = "bj.ini";
  APPLICATION1 = "Sound";
  APPLICATION2 = "Files";
  APPLICATION3 = "Cards";
  APPLICATION4 = "Players";
  APPLICATION6 = "Bet";
  
  KEY1         = "SoundOn";
  KEY2         = "WavDir"; 
  KEY3         = "CardDLL";
  KEY4         = "NoOfPlayers";
  KEY5         = "Player";  
  KEY6         = "MinBet";
  KEY7         = "MaxBet";
  
  SOUND_ON     = "on";
  SOUND_OFF    = "off";
  CARD_NAME    = "CARDS.DLL";

VAR
  CardDLL-     : ARRAY 255 OF CHAR;
  bjfile       : ARRAY 255 OF CHAR;    
  path-        : ARRAY 255 OF CHAR;  
  SoundOn*     : BOOLEAN;
  dummy        : LONGINT;
  wavDir-      : ARRAY 255 OF CHAR;
  noOfPlayers* : SHORTINT;
  PlayerTable* : ARRAY 7 OF ARRAY 255 OF CHAR;
  minBet*      : LONGINT;
  maxBet*      : LONGINT;

(*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*)

PROCEDURE GetFileName(hWnd : W.HWND);
VAR start  : LONGINT;
    module : W.HINSTANCE;
BEGIN
  module := W.GetClassWord(hWnd, W.GCW_HMODULE);
  dummy := W.GetModuleFileName(module, SYSTEM.ADR(bjfile), 254);
  dummy := 1;
  WHILE (dummy # 0) DO
    start := dummy+1;
    dummy := S.PosChar('\',bjfile,start);
  END;
  S.Copy(bjfile,bjfile,1,start-1);
  S.Copy(bjfile,path,1,S.Length(bjfile));
  S.Append(bjfile,FILENAME);
END GetFileName;

(*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*)

PROCEDURE WriteIni*(hWnd : W.HANDLE);
VAR name   : ARRAY 255 OF CHAR;
    count  : ARRAY 10 OF CHAR;
    i      : INTEGER;

BEGIN
  GetFileName(hWnd);

  dummy := W.WritePrivateProfileString(SYSTEM.ADR(APPLICATION3),SYSTEM.ADR(KEY3),SYSTEM.ADR(CardDLL),SYSTEM.ADR(bjfile));

  (* by PDI
  dummy := W.WritePrivateProfileString(SYSTEM.ADR(APPLICATION2),SYSTEM.ADR(KEY2),SYSTEM.ADR(wavDir),
                                       SYSTEM.ADR(bjfile));*)

  IF (SoundOn) THEN
    name := SOUND_ON;
  ELSE
    name := SOUND_OFF;
  END;
  dummy := W.WritePrivateProfileString(SYSTEM.ADR(APPLICATION1),SYSTEM.ADR(KEY1),SYSTEM.ADR(name),SYSTEM.ADR(bjfile));
  S.Str(noOfPlayers,name);
  dummy := W.WritePrivateProfileString(SYSTEM.ADR(APPLICATION4),SYSTEM.ADR(KEY4),SYSTEM.ADR(name),SYSTEM.ADR(bjfile));
  
  FOR i := 1 TO 7 DO
    name := KEY5;
    S.Str(i,count);
    S.Append(name,count);
    dummy := W.WritePrivateProfileString(SYSTEM.ADR(APPLICATION4),SYSTEM.ADR(name),SYSTEM.ADR(PlayerTable[i-1]),SYSTEM.ADR(bjfile));  
  END;  

  S.Str(minBet,name);
  dummy := W.WritePrivateProfileString(SYSTEM.ADR(APPLICATION6),SYSTEM.ADR(KEY6),SYSTEM.ADR(name),SYSTEM.ADR(bjfile));

  S.Str(maxBet,name);
  dummy := W.WritePrivateProfileString(SYSTEM.ADR(APPLICATION6),SYSTEM.ADR(KEY7),SYSTEM.ADR(name),SYSTEM.ADR(bjfile));

END WriteIni;

(*|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*)

PROCEDURE ReadIni*(hWnd : W.HANDLE);
VAR sound  : ARRAY 50 OF CHAR;
    name   : ARRAY 255 OF CHAR;
    i      : INTEGER;
    name2  : ARRAY 255 OF CHAR;
    count  : ARRAY 10 OF CHAR;

BEGIN
  GetFileName(hWnd);

  dummy := W.GetPrivateProfileString(SYSTEM.ADR(APPLICATION1),SYSTEM.ADR(KEY1),SYSTEM.ADR("on"),SYSTEM.ADR(sound),
                                       48,SYSTEM.ADR(bjfile));
                                       
  SoundOn := (sound = SOUND_ON);

  S.Copy(path,name,1,S.Length(path));
  S.Append(name,CARD_NAME);
  dummy := W.GetPrivateProfileString(SYSTEM.ADR(APPLICATION3),SYSTEM.ADR(KEY3),SYSTEM.ADR(name),
                                     SYSTEM.ADR(CardDLL),255,SYSTEM.ADR(bjfile));

    
  COPY(path, wavDir);
(* by PDI  
  dummy := W.GetPrivateProfileString(SYSTEM.ADR(APPLICATION2),SYSTEM.ADR(KEY2),SYSTEM.ADR(path),
                                     SYSTEM.ADR(wavDir),255,SYSTEM.ADR(bjfile));    *)

  
  noOfPlayers := SHORT(W.GetPrivateProfileInt(SYSTEM.ADR(APPLICATION4),SYSTEM.ADR(KEY4),
                                        2,SYSTEM.ADR(bjfile)));

  FOR i := 1 TO 7 DO
    name := KEY5;
    S.Str(i,count);
    S.Append(name,count);
    name2:=KEY5;
    S.Append(name2,"_");
    S.Append(name2,count);
    dummy := W.GetPrivateProfileString(SYSTEM.ADR(APPLICATION4),SYSTEM.ADR(name),SYSTEM.ADR(name2),
                                       SYSTEM.ADR(PlayerTable[i-1]),255,SYSTEM.ADR(bjfile));                                               
  END;

  minBet := W.GetPrivateProfileInt(SYSTEM.ADR(APPLICATION6),SYSTEM.ADR(KEY6),
                                        5,SYSTEM.ADR(bjfile));
  maxBet := W.GetPrivateProfileInt(SYSTEM.ADR(APPLICATION6),SYSTEM.ADR(KEY7),
                                        1000,SYSTEM.ADR(bjfile));
                                        

END ReadIni;


END INI.
