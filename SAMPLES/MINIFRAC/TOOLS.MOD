(* ======================================================================== *)
(* Projekt Minifrac                                                         *)
(*                                                                          *)
(* Fallstudie Betriebssysteme (Windowsprogrammierung unter Oberon-2         *)
(*                                                                          *)
(* Autoren:                                                                 *)
(*          Richard Beitelmair   Matr.Nr.: 9155387 /880   SS1995            *)
(*          Michael Trauner      Matr.Nr.  9356714 /881   SS1996            *)
(*          Peter   Winter       Matr.Nr.: 9355148 /881   SS1996            *)
(*                                                                          *)
(* LVA-Leiter:                                                              *)
(*          Peter René Dietmüller, dietmueller@fim.uni-linz.ac.at           *)
(*                                                                          *)
(* Sprache:                                                                 *)
(*          Pow! 3.0 beta                                                   *)
(*          Oberon-2 Compiler Version 1.18 Beta5                            *)
(*                                                                          *)
(* Datum der letzten Aenderung: 24.09.1996                                  *)
(* ------------------------------------------------------------------------ *)
(* Tools.mod                                                                *)
(*   diverse Hilfsprozeduren fuer Konvertierungen und Windowshandling       *)
(* ======================================================================== *)

MODULE Tools;

(* 
 * notwendige Module importieren
 *) 
IMPORT Win := Windows,
       Sys := SYSTEM,
       Glo := Global,
       Str := Strings;
 

(* 
 * Konvertieren einer LONGREAL-Zahl in ein ARRAY OF CHAR vom Typ Glo.StrType
 *)
PROCEDURE RealToString*(r     : LONGREAL;
                        VAR s : Glo.StrType);
VAR
  count  : INTEGER;          (* Anzahl der Vorkommastellen von r *)
  rHelp  : LONGREAL;
  digit  : LONGINT;
  i      : INTEGER;
  j      : INTEGER;
  strLen : INTEGER;
  
BEGIN
  strLen := LEN(s) - 1;
  i := 0;

  IF (r < 0) THEN  (* Vorzeichen setzen *)
    s[0] := '-';
    INC (i);
  END;
  rHelp := ABS(r);
  
  count := 0;
  WHILE ((rHelp > 10.0) & (i < strLen)) DO  (* Anzahl der Vorkommastellen *)
    rHelp := rHelp / 10.0;
    INC (count);
  END;
  FOR j := 0 TO count DO
    digit := ENTIER(rHelp);
    s[i] := CHR(digit + ORD('0'));
    INC (i);
    rHelp := (rHelp - digit) * 10;
  END;

  IF (i < strLen) THEN       (* Komma setzen *)
    s[i] := '.';  
    INC (i);
  END;
  
  WHILE (i < strLen) DO      (* Nachkommaanteil *)
    digit := ENTIER(rHelp);
    IF (rHelp # 0.0) THEN
      s[i] := CHR(digit + ORD('0'));
    ELSE
      s[i] := 0X;
    END;
    INC (i);
    rHelp := (rHelp - digit) * 10;
  END; 

  s[strLen] := 0X;           (* Terminierung *)
END RealToString;


(* ***** *)


(*
 * Konvertierung von Record realData zu Record StringData 
 *)
PROCEDURE ConvertToStr*(realData    : Glo.FracRealData; 
                        VAR strData : Glo.FracStrData);
BEGIN
  strData.set := realData.set;
  RealToString(realData.xmin, strData.xmin);
  RealToString(realData.xmax, strData.xmax);
  RealToString(realData.ymed, strData.ymed);
  RealToString(realData.k_real, strData.k_real);
  RealToString(realData.k_imag, strData.k_imag);
END ConvertToStr;


(* ***** *)


(*
 * Farbumrechnung 
 *)
PROCEDURE CalcRGB* (r, g, b : INTEGER) : LONGINT;
  BEGIN
    RETURN ((256*b)+g)*256+r;
END CalcRGB;          


(* ***** *)


(*
 * ErrorBox
 *)
PROCEDURE DisplayError*(msg : ARRAY OF CHAR);
VAR
  dummy : INTEGER;
BEGIN
  dummy := Win.MessageBox(Win.NULL, Sys.ADR(msg), Sys.ADR("Error"), 
                          Win.MB_OK);
END DisplayError;


(* ***** *)


(*
 * MessageBox Information
 *)
PROCEDURE InfoMessageBox* (header : ARRAY OF CHAR; 
                           msg    : ARRAY OF CHAR);
VAR 
  dummy : LONGINT;
BEGIN
  dummy := Win.MessageBox(Win.NULL, Sys.ADR (msg), Sys.ADR (header),
                          Win.MB_OK + Win.MB_ICONINFORMATION);
END InfoMessageBox;


(* ***** *)


(*
 * MessageBox Stop
 *)
PROCEDURE StopMessageBox* (header : ARRAY OF CHAR; 
                           msg    : ARRAY OF CHAR);
VAR 
  dummy : LONGINT;
BEGIN
  dummy := Win.MessageBox(Win.NULL, Sys.ADR (msg), Sys.ADR (header),
                          Win.MB_OK + Win.MB_ICONSTOP);
END StopMessageBox;


(* ***** *)


(* 
 * ExitBox
 * Abfrage, ob die Applikation geschlossen werden soll
 *)
PROCEDURE ExitBox*(hWnd : Win.HWND);
VAR
  dummy : LONGINT;
BEGIN
  IF (Win.MessageBox(hWnd, Sys.ADR("Sind Sie sicher?"), 
          Sys.ADR("Anwendung schließen"),
          Win.MB_ICONQUESTION + Win.MB_OKCANCEL) = Win.IDOK) THEN
    dummy := Win.DestroyWindow(hWnd);
  END;
END ExitBox;


(* ***** *)


(*
 * merkt vor, dasz das Childwindow minimiert wurde
 * sizeStat = MINIMIZED 
 * sonst NOTMINIMIZED
 *)
PROCEDURE SetStatMinimized*(hWnd     : Win.HWND; 
                            sizeStat : LONGINT);
VAR
  dummy     : LONGINT;
  pSizeStat : Glo.PLongint;
BEGIN
  NEW(pSizeStat);
  pSizeStat[0] := sizeStat;
  dummy := Win.SetWindowLong(hWnd, 20, Sys.VAL(LONGINT, pSizeStat[0]));
  DISPOSE(pSizeStat);
END SetStatMinimized;


(* ***** *)


(*
 * uebergibt MIN, falls das Childwindow minimiert dargestellt ist,
 * sonst NOTMIN
 *)
PROCEDURE IsMinimized*(hWnd : Win.HWND) : LONGINT;
BEGIN
  RETURN Sys.VAL(Win.HDC, Win.GetWindowLong(hWnd, 20));
END IsMinimized;


(* ***** *)


(*
 * merkt vor, welche fortlaufende Nummer das Fenster traegt
 *)
PROCEDURE SetNrOfWindow*(hWnd : Win.HWND; 
                         nr   : LONGINT);
VAR
  dummy : LONGINT;
  pNr   : Glo.PLongint;
BEGIN
  NEW(pNr);
  pNr[0] := nr;
  dummy := Win.SetWindowLong(hWnd, 24, Sys.VAL(LONGINT, pNr[0]));
  DISPOSE(pNr);
END SetNrOfWindow;


(* ***** *)


(*
 * uebergibt die laufende Nummer des Fensters
 *)
PROCEDURE GetNrOfWindow*(hWnd : Win.HWND) : LONGINT;
BEGIN
  RETURN Sys.VAL(Win.HDC, Win.GetWindowLong(hWnd, 24));
END GetNrOfWindow;


(* ***** *)


(*
 * bestimme Titeltext fuer Childwindow
 *)
PROCEDURE GetTitleOfWindow*(number       : LONGINT; 
                            VAR titleStr : ARRAY OF CHAR);
VAR
  s : ARRAY 10 OF CHAR;
BEGIN 
  COPY(Glo.TITLESTR, titleStr);
  Str.Str(number, s);
  Str.Append(titleStr, s);
END GetTitleOfWindow;


(* ***** *)


(*
 * setze Titelzeile, dasz erkannt wird, dasz Berechnung laeuft
 *)
PROCEDURE SetTitleOfWindowToCalc*(hWnd : Win.HWND);
VAR
  s    : ARRAY 30 OF CHAR;
  pStr : Win.LPCSTR;
BEGIN
  GetTitleOfWindow(GetNrOfWindow(hWnd), s);
  Str.Append(s, " in Berechnung");
  pStr := Sys.ADR(s);
  Win.SetWindowText(hWnd, pStr);
END SetTitleOfWindowToCalc;


(* ***** *)


(*
 * setze Titelzeile auf Standard
 *)
PROCEDURE SetTitleOfWindowToReady*(hWnd : Win.HWND);
VAR
  s    : ARRAY 20 OF CHAR;
  pStr : Win.LPCSTR;
BEGIN
  GetTitleOfWindow(GetNrOfWindow(hWnd), s);
  pStr := Sys.ADR(s);
  Win.SetWindowText(hWnd, pStr);
END SetTitleOfWindowToReady;


END Tools.
