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
(* Zoom.mod                                                                 *)
(*   Prozeduren fuer den Zoomvorgang                                        *)
(*   Anmerkung: Beim Zoomrechteck ist 0/0 links oben (left/top)             *)
(* ======================================================================== *)

MODULE Zoom;

(* 
 * notwendige Module importieren
 *) 
IMPORT Win := Windows,
       Sys := SYSTEM,
       T   := Tools,
       Glo := Global,
       Fra := Fractal,
       Uti := Utils;

(* 
 * globale Konstanten
 *)
CONST
  ZOOMMINRANGE = 5;          (* Mindestbereich fuer sinnvolles Zoomfenster *)
  UP           = 100;        (* Richtungsanzeiger *)
  DOWN         = 101;        (* Richtungsanzeiger *)
  LEFT         = 102;        (* Richtungsanzeiger *)
  RIGHT        = 103;        (* Richtungsanzeiger *)
  NOTHING      = 104;        (* Richtungsanzeiger *)

(*
 * globale Variablen 
 *)
VAR
  zoomActive : BOOLEAN;
  zoomRect   : Win.RECT;     (* Koordinaten des Zoomrechtecks *)
  lastXPos   : INTEGER;      (* letzte Mausposition in X *)
  lastYPos   : INTEGER;      (* letzte Mausposition in Y *)
  startXPos  : INTEGER;      (* Startposition fuer Zoomrechteck in X *)
  startYPos  : INTEGER;      (* Startposition fuer Zoomrechteck in Y *)


(* pruefe, ob das Zoomrechteck eine gewisse Mindestgroesze aufweist.
 * Werden die Mindestabmessungen nicht erreicht, so uebergebe 
 * den Wert FALSE, sonst TRUE
 *)
PROCEDURE IsZoomValid(hWnd : Win.HWND) : BOOLEAN;
VAR
  dx : INTEGER;
  dy : INTEGER;
BEGIN
  dx := zoomRect.right - zoomRect.left;
  dy := zoomRect.bottom - zoomRect.top;

  RETURN ((dx > ZOOMMINRANGE) & (dy > ZOOMMINRANGE));
END IsZoomValid;


(* ***** *)


(*
 * bereitet die Daten des Zoomfensters zoomRect auf 
 *)
PROCEDURE SetZoomParam*(hWnd : Win.HWND);
VAR
  cr          : Win.RECT;
  yMin        : LONGREAL;
  yMax        : LONGREAL;
  yMinOld     : LONGREAL;
  yMedOld     : LONGREAL;
  deltaX      : LONGREAL;
  deltaY      : LONGREAL;
  rangeXOld   : LONGREAL;
  rangeYOld   : LONGREAL;
  realData    : Glo.FracRealData;
  realDataOld : Glo.FracRealData;
  
BEGIN
  Win.GetClientRect(hWnd, Sys.ADR(cr)); (* Abmessungen des Fraktalwindows *)

  Fra.GetFracParam(hWnd, realDataOld);  (* urspruengliche Koordinaten holen *)

  rangeXOld := ABS(realDataOld.xmax - realDataOld.xmin); (* Wertebereich *)
  rangeYOld := cr.bottom/cr.right * rangeXOld;
  
  deltaX := rangeXOld / cr.right;       (* Einheit pro Pixel *)
  deltaY := rangeYOld / cr.bottom;

  yMinOld := realDataOld.ymed - (rangeYOld / 2.0);
  
  realData.xmin := (zoomRect.left  * deltaX) + realDataOld.xmin;
  realData.xmax := (zoomRect.right * deltaX) + realDataOld.xmin;
  realData.set  := realDataOld.set;
  
  yMin := (cr.bottom - zoomRect.bottom) * deltaY + yMinOld;
  yMax := (cr.bottom - zoomRect.top)  * deltaY + yMinOld;  
  realData.ymed := (yMin + yMax) / 2.0;

  realData.k_real := realDataOld.k_real; 
  realData.k_imag := realDataOld.k_imag; 

  Fra.SetFracParam(hWnd, realData, FALSE); (* Param. f. Berechnung sichern *)
END SetZoomParam;


(* ***** *)


PROCEDURE GetZoomRect(lParam : LONGINT);
VAR
  mouseX   : INTEGER;
  mouseY   : INTEGER;
  dirMoveX : INTEGER;
  dirMoveY : INTEGER;
BEGIN
  mouseX := Uti.LoWord(lParam);
  mouseY := Uti.HiWord(lParam);

  IF (lastXPos < mouseX) THEN           (* bestimme Bewegungsrichtung *)
    dirMoveX := RIGHT;
  ELSIF (lastXPos > mouseX) THEN
    dirMoveX := LEFT;
  ELSE
    dirMoveX := NOTHING;
  END;  

  IF (lastYPos < mouseY) THEN
    dirMoveY := DOWN;
  ELSIF (lastYPos > mouseY) THEN
    dirMoveY := UP;
  ELSE
    dirMoveY := NOTHING;
  END;  
  
  IF (dirMoveX = RIGHT) THEN            (* nach rechts *)
    IF (zoomRect.right < mouseX) THEN
      zoomRect.right := mouseX;
      zoomRect.left  := startXPos;
    ELSE
      zoomRect.left  := mouseX;
      zoomRect.right := startXPos;
    END;
  END;

  IF (dirMoveX = LEFT) THEN             (* nach links *)
    IF (zoomRect.left > mouseX) THEN
      zoomRect.left  := mouseX;
      zoomRect.right := startXPos;
    ELSE
      zoomRect.right := mouseX;
      zoomRect.left  := startXPos;
    END;
  END;

  IF (dirMoveY = UP) THEN               (* nach oben *)
    IF (zoomRect.top > mouseY) THEN
      zoomRect.top    := mouseY;
      zoomRect.bottom := startYPos;
    ELSE
      zoomRect.bottom := mouseY;
      zoomRect.top    := startYPos;
    END;
  END;

  
  IF (dirMoveY = DOWN) THEN             (* nach unten *)
    IF (zoomRect.bottom < mouseY) THEN
      zoomRect.bottom := mouseY;
      zoomRect.top    := startYPos;
    ELSE
      zoomRect.top    := mouseY;
      zoomRect.bottom := startYPos;
    END;
  END;

  lastXPos := mouseX;                   (* letzte Position der Maus merken *)
  lastYPos := mouseY;
END GetZoomRect;


(* ***** *)


(*
 * merke vor, dass der Zoomvorgang aktiv ist
 * und merke die Mauskoordinaten vor
 *)
PROCEDURE ZoomStart*(hWnd  : Win.HWND; 
                    lParam : LONGINT); 
VAR
  dummy : LONGINT;
BEGIN
  dummy           := Win.SetCapture(hWnd);          
  zoomActive      := TRUE;
  zoomRect.left   := Uti.LoWord(lParam); (* weise neue Koordinaten zu *)
  zoomRect.right  := zoomRect.left;
  zoomRect.top    := Uti.HiWord(lParam);
  zoomRect.bottom := zoomRect.top;
  startXPos       := zoomRect.left;
  startYPos       := zoomRect.top;
  lastXPos        := zoomRect.left;
  lastYPos        := zoomRect.top;

END ZoomStart;


(* ***** *)


(*
 * markiere, dass der Zoomvorgang beendet wurde
 * entferne das Zoomrechteck vom Bildschirm 
 * uebergebe TRUE. falls der Zoom gueltig ist. sonst FALSE
 *)
PROCEDURE ZoomEnd*(hWnd : Win.HWND) : BOOLEAN; 
VAR
  hdc   : Win.HDC;
  dummy : LONGINT;
  ret   : BOOLEAN;
BEGIN
  ret := FALSE;
  IF (zoomActive) THEN                  (* Zoomvorgang eingeleitet? *)
    hdc := Win.GetDC(hWnd);
    Win.DrawFocusRect(hdc, Sys.ADR(zoomRect)); (* altes Rechteck loeschen *)
    dummy := Win.ReleaseDC(hWnd, hdc);

    zoomActive := FALSE;
    Win.ReleaseCapture();          

    IF (IsZoomValid(hWnd)) THEN 
      SetZoomParam(hWnd);               (* fuehre Auswertung durch *)
      ret := TRUE;
    END;
  END;
  RETURN ret;
END ZoomEnd;


(* ***** *)

 
(*
 * spanne ein strichliertes Zoomfenster auf
 *)
PROCEDURE DrawZoomRect*(hWnd   : Win.HWND; 
                        lParam : LONGINT); 
VAR 
  hdc   : Win.HDC;
  dummy : LONGINT;
BEGIN
  IF (zoomActive) THEN
    hdc := Win.GetDC(hWnd);
    Win.DrawFocusRect(hdc, Sys.ADR(zoomRect)); (* altes Rechteck loeschen *)
    GetZoomRect(lParam);                       (* setze neue Koordinaten  *)
    Win.DrawFocusRect(hdc, Sys.ADR(zoomRect)); (* neues Rechteck zeichnen *)
    dummy := Win.ReleaseDC(hWnd, hdc);
  END;
END DrawZoomRect;
 

(*
 * Modulinitialisierung 
 *)
BEGIN
  zoomActive := FALSE;
END Zoom.

