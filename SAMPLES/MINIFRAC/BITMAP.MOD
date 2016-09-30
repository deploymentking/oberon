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
(* Bitmap.mod                                                               *)
(*   erzeugen und loeschen einer Bitmap im Speicher                         *)
(* ======================================================================== *)

MODULE Bitmap;

(* 
 * notwendige Module importieren
 *) 
IMPORT Win := Windows,
       Sys := SYSTEM,
       Glo := Global;
 
 
(*
 * globale Variablen
 *)
VAR
  hbmpOld : Win.HBITMAP;  


(* 
 * entfernt die unter hWnd referenzierte Bitmap aus dem Speicher 
 *)
PROCEDURE KillBitmap*(hWnd : Win.HWND);
VAR
  hdcmem : Win.HDC;
  hbmp   : Win.HBITMAP;
  dummy  : LONGINT;
BEGIN
  hdcmem := Sys.VAL(Win.HDC, Win.GetWindowLong(hWnd, 0));
  hbmp   := Sys.VAL(Win.HBITMAP, Win.GetWindowLong(hWnd, 4)); 
  dummy  := Win.SelectObject(hdcmem, hbmpOld);
  dummy  := Win.DeleteObject(hbmp);
  dummy  := Win.DeleteDC(hdcmem);
END KillBitmap;


(* ***** *)


(*
 * erzeugt eine Bitmap und weist sie dem hWnd zu
 *)
PROCEDURE CreateBitmap*(hWnd : Win.HWND);
VAR
  hdc     : Win.HDC;
  cr      : Win.RECT;
  pHdcmem : Glo.PHdc;
  pHbmp   : Glo.PHbmp;
  dummy   : LONGINT;
BEGIN
  NEW(pHdcmem);
  NEW(pHbmp);
  (* Bitmap neu anlegen *)
  Win.GetClientRect(hWnd, Sys.ADR(cr));
  hdc := Win.GetDC(hWnd);
  pHdcmem[0] := Win.CreateCompatibleDC(hdc);  (* Bitmap init. *)
  pHbmp[0] := Win.CreateCompatibleBitmap(hdc, cr.right, cr.bottom);
  hbmpOld := Win.SelectObject(pHdcmem[0], pHbmp[0]);
  dummy := Win.FillRect(pHdcmem[0], Sys.ADR(cr), Win.GetStockObject(Win.WHITE_BRUSH));
  dummy := Win.ReleaseDC(hWnd, hdc);
  dummy := Win.SetWindowLong(hWnd, 0, Sys.VAL(LONGINT, pHdcmem[0]));
  dummy := Win.SetWindowLong(hWnd, 4, Sys.VAL(LONGINT, pHbmp[0]));
  dummy := Win.ReleaseDC(hWnd, hdc);
  DISPOSE(pHdcmem);
  DISPOSE(pHbmp);
END CreateBitmap;



(*
 * Modulinitialisierung 
 *) 
BEGIN
  hbmpOld := Win.NULL;
END Bitmap.

