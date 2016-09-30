(**************************************************************************)
(*                                                                        *)
(*  Fallstudien Betriebssysteme: Windowsprogrammierung mit Oberon-2       *)
(*  Abschlußprojekt:    Black Jack                                        *)
(*  Aufgabe:            Kartenspiel unter Verwendung von cardList.DLL     *)
(*                                                                        *)
(*  Modulname:          Sound.MOD                                         *)
(*  Aufgabe:            Musik spielen                                     *)
(*                                                                        *)
(*  Autoren:            Gschnell Christian, 9155609, 880                  *)
(*                      Jungwirth Josef,    9155355, 880                  *)
(*                      Köttstorfer Marco,  9155255, 880                  *)
(*                                                                        *)
(*  Erstellt am:        22. Mai 1995                                      *)
(*  Änderungen:                                                           *)
(*                                                                        *)
(*                                                                        *)
(**************************************************************************)

MODULE Sound;

IMPORT M := MMSystem, I := Ini, SYSTEM, G := General, S := Strings,
       W := Windows;


VAR dummy : LONGINT;

PROCEDURE PlaySound*(number : INTEGER);
VAR name : ARRAY 255 OF CHAR;
    count: ARRAY 4 OF CHAR;
   
BEGIN
  IF (I.SoundOn) THEN
    IF number > 22 THEN number := 22; END;
    G.StringCopy(name,I.wavDir);
    S.Str(number,count);
    IF (number = -1) THEN
      S.Append(name,"bj.wav");
    ELSE
      S.Append(name,count);
      S.Append(name,".wav");
    END;  
    dummy := M.sndPlaySound(SYSTEM.ADR(name),M.snd_Async);
  END;
END PlaySound;

END Sound.