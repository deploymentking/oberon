(* ======================================================================== *)
(* Projekt Minifrac                                                         *)
(*                                                                          *)
(* Fallstudie Betriebssysteme (Windowsprogrammierung unter Oberon-2         *)
(*                                                                          *)
(* Autoren:                                                                 *)
(*          Richard Beitelmair   Matr.Nr.: 9155387 /880   SS1995            *)
(*          Michael Trauner      Matr.Nr.: 9356714 /881   SS1996            *)
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
(* Fractal.mod                                                              *)
(*   diverse Parameter-, Zeichen- und Rechenoperationen fuer Fraktale       *)
(* ======================================================================== *)

MODULE Fractal;

(* 
 * notwendige Module importieren
 *) 
IMPORT Win := Windows,
       Sys := SYSTEM,
       Glo := Global,
       T   := Tools;
 
 
(*
 * globale Typen, Konstanten, Variablen
 *)
CONST
  XMIN   = -2.5;   (* voreingestellte Zeichenparamneter *)
  XMAX   =  1.5;
  YMED   =  0.0;
  K_REAL =  0.33;
  K_IMAG =  0.42;

  RMAX = 100.0;
  NMAX = 100.0;

  COLOURS = 10;


(*
 * globale Variablen
 *)
VAR
  palette       : ARRAY COLOURS OF LONGINT;
  fracCalculate : BOOLEAN;   (* irgendeine Fraktalberechnung aktiv? *)


  
(*
 * ist irgendeine Fraktalberechnung aktiv -> return TRUE
 *                                            sonst FALSE
 *)
PROCEDURE IsFracCalcActive*() : BOOLEAN;
BEGIN
  RETURN fracCalculate;
END IsFracCalcActive;


(* ***** *)


(*
 * initialisiert die Parameter fuer das Fraktal-Eingabefenster mit 
 * Standardwerten
 *)
PROCEDURE InitParam*(VAR realData : Glo.FracRealData);
BEGIN
  realData.set    := "M";
  realData.xmin   := XMIN;
  realData.xmax   := XMAX;
  realData.ymed   := YMED;
  realData.k_real := K_REAL; 
  realData.k_imag := K_IMAG; 
END InitParam;


(* ***** *)


(*
 * legt die Anfangsgroesse eines Childwindows fest
 *)
PROCEDURE InitChildSize*(VAR cr : Win.RECT);
BEGIN
  cr.left   := 0;
  cr.top    := 0;
  cr.bottom := Glo.HEIGHT;
  cr.right  := Glo.WIDTH;
END InitChildSize;


(*
 * setzt den Status eines Fraktal-Child-Windows
 *)
PROCEDURE SetStatus*(hWnd   : Win.HWND; 
                     status : LONGINT);
VAR
  dummy   : LONGINT;
  pStatus : Glo.PLongint;
BEGIN
  NEW(pStatus);
  pStatus[0] := status;
  dummy := Win.SetWindowLong(hWnd, 12, Sys.VAL(LONGINT, pStatus[0]));
  DISPOSE(pStatus);
END SetStatus;


(* ***** *)


(*
 * uebergibt den Status eines Fraktal-Child-Windows
 *)
PROCEDURE GetStatus*(hWnd : Win.HWND) : LONGINT;
BEGIN
  RETURN Sys.VAL(Win.HDC, Win.GetWindowLong(hWnd, 12));
END GetStatus;


(* ***** *)


(*
 * initialisiert den internen Zaehler, welcher die Anzahl momentan 
 * anstehender Fraktalberechnungen fuer ein Childwindow haelt
 *)
PROCEDURE InitNoOfCalculations*(hWnd : Win.HWND);
VAR
  dummy : LONGINT;
  pCounter : POINTER TO ARRAY 1 OF LONGINT;
BEGIN
  NEW(pCounter);
  pCounter[0] := 0;
  dummy := Win.SetWindowLong(hWnd, 16, Sys.VAL(LONGINT, pCounter[0]));
  DISPOSE(pCounter);
END InitNoOfCalculations;


(* ***** *)


(*
 * uebergibt den Stand des internen Berechnungszaehlers eines Fraktalfensters
 *)
PROCEDURE GetNoOfCalculations*(hWnd : Win.HWND) : LONGINT;
BEGIN
  RETURN Sys.VAL(Win.HDC, Win.GetWindowLong(hWnd, 16));
END GetNoOfCalculations;


(* ***** *)
 

(*
 * erhoeht den internen Zaehler, welcher die Anzahl momentan anstehender
 * Fraktalberechnungen fuer ein Childwindow haelt
 *)
PROCEDURE IncNoOfCalculations*(hWnd : Win.HWND);
VAR
  dummy : LONGINT;
  pCounter : Glo.PLongint;
BEGIN
  NEW(pCounter);
  pCounter[0] := GetNoOfCalculations(hWnd);
  INC (pCounter[0]);
  dummy := Win.SetWindowLong(hWnd, 16, Sys.VAL(LONGINT, pCounter[0]));
  DISPOSE(pCounter);
END IncNoOfCalculations;


(* ***** *)


(*
 * erniedrigt den internen Zaehler, welcher die Anzahl momentan anstehender
 * Fraktalberechnungen fuer ein Childwindow haelt
 *)
PROCEDURE DecNoOfCalculations*(hWnd : Win.HWND);
VAR
  dummy : LONGINT;
  pCounter : Glo.PLongint;
BEGIN
  NEW(pCounter);
  pCounter[0] := GetNoOfCalculations(hWnd);
  DEC (pCounter[0]);
  dummy := Win.SetWindowLong(hWnd, 16, Sys.VAL(LONGINT, pCounter[0]));
  DISPOSE(pCounter);
END DecNoOfCalculations;


(* ***** *)


(*
 * ruft die abhaengigen Parameter fuer das Fraktal ab
 * (benoetigt fuer Berechnung des Fraktals)  
 *)
PROCEDURE GetFracParam*(hWnd         : Win.HWND; 
                        VAR realData : Glo.FracRealData);
VAR
  dummy     : LONGINT;  
  pRealData : Glo.PFracRealData;
BEGIN
  pRealData := Sys.VAL(Glo.PFracRealData, Win.GetWindowLong(hWnd, 8));
  realData  := pRealData^;
END GetFracParam;


(* ***** *)


(*
 * speichert die abhaengigen Parameter fuer das Fraktal ab 
 * (benoetigt fuer Berechnung des Fraktals)  
 *     new -> TRUE  ...  Speicherplatz fuer Parameter neu anfordern
 *         -> FALSE ...  Speicherplatz bereits angefordert => ueberschreiben
 *)
PROCEDURE SetFracParam*(hWnd     : Win.HWND; 
                        realData : Glo.FracRealData; 
                        new      : BOOLEAN); 
VAR
  dummy     : LONGINT;  
  pRealData : Glo.PFracRealData;
BEGIN
  IF (new) THEN 
    NEW (pRealData);
  ELSE
    pRealData := Sys.VAL(Glo.PFracRealData, Win.GetWindowLong(hWnd, 8));
  END;
   
  pRealData^ := realData;
  dummy      := Win.SetWindowLong(hWnd, 8, Sys.ADR(pRealData^));
END SetFracParam;


(* ***** *)


(*
 * Speicherplatz, welcher auf Parameter zeigte, aufraeumen 
 *)
PROCEDURE CleanParam*(hWnd : Win.HWND);
VAR
  pRealData : Glo.PFracRealData;
BEGIN
  pRealData := Sys.VAL(Glo.PFracRealData, Win.GetWindowLong(hWnd, 8));
  DISPOSE (pRealData);
END CleanParam;



(* ***** *)


(*
 * Fraktal berechnen, in Bitmap speichern und anzeigen 
 *)
PROCEDURE PaintSet*(hdc  : Win.HDC; 
                    hWnd : Win.HWND);
VAR i        : INTEGER;
    j        : INTEGER;
    xr       : LONGREAL;
    yr       : LONGREAL;
    d        : LONGREAL;
    yRange   : LONGREAL;
    ymax     : LONGREAL;
    color    : LONGINT;
    dummy    : LONGINT;
    msg      : Win.MSG;
    b        : Win.BOOL;
    cr       : Win.RECT;
    realData : Glo.FracRealData;
    hdcmem   : Win.HDC;

  (* *** *)

  PROCEDURE Iteration(e, f : LONGREAL) : INTEGER;
  VAR a    : LONGREAL;
      b    : LONGREAL; 
      aNew : LONGREAL; 
      r    : LONGREAL; 
      g    : LONGREAL; 
      h    : LONGREAL;
      i    : INTEGER;
  BEGIN
    IF (realData.set="M") THEN
      a := 0;
      b := 0; 
      g := e;
      h := f;
    ELSE
      a := e;
      b := f;
      g := realData.k_real; 
      h := realData.k_imag;
    END;
    i := 0;
    REPEAT
      aNew := (a * a) - (b * b) + g;
      b := (2 * a * b) + h;
      a := aNew;
      INC(i);  
      r := (a * a) + (b * b);     
    UNTIL (r > RMAX) OR (i > NMAX);
    RETURN i;
  END Iteration;
  (* *** *)
BEGIN
  GetFracParam(hWnd, realData);
  SetStatus(hWnd, Glo.CALCULATING); (* Berechnung des Fraktals aktiv *)
  Win.GetClientRect(hWnd, Sys.ADR(cr)); 
  hdcmem := Sys.VAL(Win.HDC, Win.GetWindowLong(hWnd, 0));
  dummy  := Win.FillRect(hdcmem, Sys.ADR(cr), 
                         Win.GetStockObject(Win.WHITE_BRUSH));

  yRange := ABS(cr.bottom/cr.right*(realData.xmax-realData.xmin)); 
  ymax   := realData.ymed + (yRange / 2.0);
  d  := (realData.xmax-realData.xmin)/cr.right; 
  xr := realData.xmin;

  FOR i:=0 TO cr.right DO  
    yr := ymax;
    FOR j := 0 TO cr.bottom DO          
      (* Events abfragen *)
      IF (Win.PeekMessage(Sys.ADR(msg), 0, 0, 0, Win.PM_REMOVE) 
                                                    = Win.true) THEN
        IF (msg.message = Win.WM_LBUTTONDBLCLK) THEN  (* Abbruch *)
          SetStatus(msg.hwnd, Glo.BREAK);
          T.SetTitleOfWindowToReady(msg.hwnd);
        ELSE
          dummy := Win.SendMessage(msg.hwnd, msg.message, msg.wParam, 
                                   msg.lParam);
        END;   
      END;

      IF (GetStatus(hWnd) = Glo.BREAK) THEN  (* Berechnung abbrechen? *)
        fracCalculate := FALSE;
        RETURN;
      END;      

      fracCalculate := TRUE; (* Berechnung aktiv *)
         
      color := palette[Iteration(xr, yr) MOD COLOURS];
      dummy := Win.SetPixel (hdcmem, i, j, color);    (* zeichne *)
      yr := yr - d;
    END;
    dummy := Win.BitBlt(hdc, 0, 0, cr.right, cr.bottom, hdcmem, 0, 0, 
                        Win.SRCCOPY);
    xr := xr + d;
    fracCalculate := FALSE;
  END;   
END PaintSet;


(*
 * Modulinitialisierung 
 *)
BEGIN
   palette [0] := T.CalcRGB(  0,   0,   0); 
   palette [1] := T.CalcRGB(  0,   0,  50);  
   palette [2] := T.CalcRGB(  0,   0, 100); 
   palette [3] := T.CalcRGB( 50,  50, 150); 
   palette [4] := T.CalcRGB(100, 100, 200); 
   palette [5] := T.CalcRGB(220, 240, 255); 
   palette [6] := T.CalcRGB(100, 100, 200); 
   palette [7] := T.CalcRGB( 50,  50, 100);  
   palette [8] := T.CalcRGB(130, 150,   0); 
   palette [9] := T.CalcRGB( 20,  50, 110); 

   fracCalculate := FALSE;     (* keine Fraktalberechnung aktiv *)

END Fractal.

