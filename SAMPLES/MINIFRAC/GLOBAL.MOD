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
(* Datum der letzten Aenderung: 30.10.1996                                  *)
(* ------------------------------------------------------------------------ *)
(* Global.mod                                                               *)
(*   diverse allgemeinbekannte Typen und Konstanten                         *)
(* ======================================================================== *)

DEFINITION Global;

(* 
 * notwendige Module importieren
 *) 
IMPORT 
  Win := Windows;

(*
 * globale Datentypen und Konstanten 
 *)
TYPE
  WNDPROC = PROCEDURE [WINDOWS] (hWnd    : Win.HWND;
                                 message : Win.WORD;
                                 wParam  : Win.WORD;
                                 lParam  : LONGINT): LONGINT;
                                 
  DLGPROC = PROCEDURE [WINDOWS] (hDlg   : Win.HWND;
                                 msg    : Win.WORD;
                                 wParam : Win.WORD;
                                 lParam : LONGINT) : Win.BOOL;
  StrType = ARRAY 11 OF CHAR;

  FracRealData = RECORD 
                   set    : CHAR;     (* Mandelbrot oder Julia *)
                   xmin   : LONGREAL;
                   xmax   : LONGREAL;
                   ymed   : LONGREAL;
                   k_real : LONGREAL;
                   k_imag : LONGREAL;
                 END;
  PFracRealData = POINTER TO FracRealData;

  FracStrData = RECORD
                  set    : CHAR;    (* Mandelbrot oder Julia *)
                  xmin   : StrType;
                  ymed   : StrType;
                  xmax   : StrType;
                  k_real : StrType;
                  k_imag : StrType;
                END;           

  CALLBACKPROC = PROCEDURE [WINDOWS] (hWnd   : Win.HWND;
                                      lParam : LONGINT) : Win.BOOL;

  PLongreal = POINTER TO ARRAY 1 OF LONGREAL;
  PChar     = POINTER TO ARRAY 1 OF CHAR;
  PHdc      = POINTER TO ARRAY 1 OF Win.HDC;  
  PHbmp     = POINTER TO ARRAY 1 OF Win.HBITMAP;
  PMmi      = POINTER TO Win.MINMAXINFO;
  PLongint  = POINTER TO ARRAY 1 OF LONGINT;
  
CONST
  WIDTH        =  400;  (* Standardbreite eines Fraktalfensters *) 
  HEIGHT       =  300;  (* Standardhoehe  eines Fraktalfensters *)
  READY        = 1001;  (* Fraktal in Childfenster hat aktuellen Stand *)
  BREAK        = 1002;  (* Berechnung sofort abbrechen *)
  DEMANDCALC   = 1003;  (* Neuberechnung eines Fraktals angefordert *)
  CALCULATING  = 1004;  (* Fraktalberechnung aktiv *)
  MINIMIZED    = 2001;  (* Childwindow ist minimiert *)
  NOTMINIMIZED = 2002;  (* Childwindow ist nicht minimiert *)
  TITLESTR     = "Fraktal #"; (* Titel eines Childfensters *)
  
END Global.
