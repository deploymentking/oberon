(******************************************************************************)
(* MODULE:      ClpProc                                         ME - 29.06.96 *)
(* DESCRIPTION: Decoding procedures for clipboard messages                    *)
(* LANGUAGE:    Oberon-2                                                      *)
(* COMPILER:    Robinson Associates Oberon-2 V1.18 beta6                      *)
(* WORKBENCH    POW 3.0 beta3                                                 *)
(* AUTHOR:      Martin Erdpresser, k3075e2@c210.edvz.uni-linz.ac.at (ME)      *)
(******************************************************************************)
(* DATE      AUTHOR  CHANGES                                                  *)
(* --------  ------  ---------------------------------------------------------*)
(* 29.05.96  ME      Initial Version                                          *)
(******************************************************************************)

MODULE ClpProc;

IMPORT W := Windows, Strings, Utils, SYSTEM, ht := htConst;


CONST
  STR_LEN = 128;

(*==============< Decoding procedures for clipboard messages >================*)
(* This Application provides for nonclient message group:                     *)
(*                WM_ASKCBFORMATNAME                                          *)
(*                WM_CHANGECBCHAIN                                            *)
(*                WM_CLEAR            (using default)                         *)
(*                WM_CUT              (using default)                         *)
(*                WM_COPY             (using default)                         *)
(*                WM_DESTROYCLIPBOARD (using default)                         *)
(*                WM_DRAWCLIPBOARD    (using default)                         *)
(*                WM_HSCROLLCLIPBOARD                                         *)
(*                WM_PASTE            (using default)                         *)
(*                WM_RENDERALLFORMATS (using default)                         *)
(*                WM_RENDERFORMAT                                             *)
(*                WM_SIZECLIPBOARD                                            *)
(*                WM_UNDO             (using default)                         *)
(*                WM_VSCROLLCLIPBOARD                                         *)
(*============================================================================*)


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_ASKCBFORMATNAME                        *)
(*                                                                            *)
(* COMMENTS: A clipboard viewer application sends a WM_ASKCBFORMATNAME msg.   *)
(*           to the clipboard owner when the clipboard contains the data      *)
(*           handle of the CF_OWNERDISPLAY format (that is, when the          *)
(*           clipboard owner should display the clipboard contents).          *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) cbMax: maximum bytes to copy              *)
(* lParam         lParam = (LPARAM) lpszFormatName: address of format name    *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_ASKCBFORMATNAME*(wParam : W.WPARAM; 
                                   lParam : W.LPARAM;
                                   VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN 
  Strings.Append(str," cbMax:"); numStr := ""; 
  Strings.Str(wParam, numStr); Strings.Append(str,numStr);
  Strings.Append(str," lpszFormatName:"); numStr := ""; 
  Strings.HexStr(lParam, numStr); Strings.Append(str,numStr);
END Proc_WM_ASKCBFORMATNAME;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_CHANGECBCHAIN                          *)
(*                                                                            *)
(* COMMENTS: The WM_CHANGECBCHAIN message notifies the first window in the    *)
(*           clipboard-viewer chain that a window is being removed from       *)
(*           the chain.                                                       *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         hwndRemoved = (HWND) wParam: handle of removed window       *)
(* lParam         hwndNext = (HWND) LOWORD(lParam): handle of next window     *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_CHANGECBCHAIN*(wParam : W.WPARAM; 
                                 lParam : W.LPARAM;
                                 VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN 
  Strings.Append(str," hwndRemoved:"); numStr := ""; 
  Strings.HexStr(wParam, numStr); Strings.Append(str,numStr);
  Strings.Append(str," hwndHext:"); numStr := ""; 
  Strings.HexStr(Utils.LoWord(lParam), numStr); Strings.Append(str,numStr);
END Proc_WM_CHANGECBCHAIN;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_CHANGECBCHAIN                          *)
(*                                                                            *)
(* COMMENTS: The WM_HSCROLLCLIPBOARD message is sent by the clipboard viewer  *)
(*           to the clipboard owner when the clipboard data has the           *)
(*           CF_OWNERDISPLAY format and an event occurs in the clipboard      *)
(*           viewer's horizontal scroll bar. The owner should scroll the      *)
(*           clipboard image, invalidate the appropriate section, and update  *)
(*           the scroll bar values.                                           *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         hwndCBViewer = (HWND) wParam: handle of clipboard viewer    *)
(* lParam         wScrollCode = LOWORD(lParam): scroll bar code               *)
(*                nPos = (int) HIWORD(lParam): scroll box position            *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_HSCROLLCLIPBOARD*(wParam : W.WPARAM; 
                                    lParam : W.LPARAM;
                                    VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN 
  Strings.Append(str," hwndCBViewer:"); numStr := "";
  Strings.HexStr(wParam, numStr); Strings.Append(str, numStr);

  Strings.Append(str," wScrollCode:");
  ASSERT((Utils.LoWord(lParam) >= 0) & (Utils.LoWord(lParam) < LEN(ht.sbHscrTab)));
  IF (ht.sbHscrTab[Utils.LoWord(lParam)] # "") THEN
    Strings.Append(str, ht.sbHscrTab[Utils.LoWord(lParam)])
  ELSE
    Strings.Append(str," unknown:"); numStr := ""; 
    Strings.HexStr(Utils.LoWord(lParam), numStr); Strings.Append(str, numStr)
  END;
  
  IF (Utils.LoWord(lParam) = W.SB_THUMBPOSITION) THEN
    Strings.Append(str," nPos:"); numStr := "";  
    Strings.Str(Utils.HiWord(lParam), numStr); Strings.Append(str, numStr) 
  END
END Proc_WM_HSCROLLCLIPBOARD;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_PAINTCLIPBOARD                         *)
(*                                                                            *)
(* COMMENTS: The WM_PAINTCLIPBOARD message is sent by a clipboard viewer to   *)
(*           the clipboard owner when the owner has placed data on the        *)
(*           clipboard in the CF_OWNERDISPLAY format and the clipboard        *)
(*           viewer's client area needs repainting.                           *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         hwndViewer = (HWND) wParam: handle of viewer                *)
(* lParam         pps =(PAINTSTRUCT FAR* )LOWORD(lParam):points to paint data *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_PAINTCLIPBOARD*(wParam : W.WPARAM; 
                                  lParam : W.LPARAM;
                                  VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN 
  Strings.Append(str," hwndViewer:"); numStr := ""; 
  Strings.HexStr(wParam, numStr); Strings.Append(str,numStr);
  Strings.Append(str," pps:"); numStr := ""; 
  Strings.HexStr(Utils.LoWord(lParam), numStr); Strings.Append(str,numStr);
END Proc_WM_PAINTCLIPBOARD;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_RENDERFORMAT                           *)
(*                                                                            *)
(* COMMENTS: The WM_RENDERFORMAT message is sent to the clipboard owner when  *)
(*           a particular format with delayed rendering needs to be rendered. *)
(*           The receiver should render the data in that format and pass it   *)
(*           to the clipboard by calling the SetClipboardData function.       *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         uFmt = (UINT) wParam: clipboard data format                 *)
(* lParam                                                                     *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_RENDERFORMAT*(wParam : W.WPARAM; 
                                lParam : W.LPARAM;
                                VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str, " uFmt:"); 
  IF wParam = W.CF_BITMAP THEN
    Strings.Append(str,"CF_BITMAP")
  ELSIF wParam = W.CF_DIB THEN
    Strings.Append(str,"CF_DIB")
  ELSIF wParam = W.CF_DIF THEN
    Strings.Append(str,"CF_DIF") 
  ELSIF wParam = W.CF_DSPBITMAP THEN
    Strings.Append(str,"CF_DSPBITMAP")
  ELSIF wParam = W.CF_DSPMETAFILEPICT THEN
    Strings.Append(str,"CF_DSPMETAFILEPICT")
  ELSIF wParam = W.CF_DSPTEXT THEN
    Strings.Append(str,"CF_DSPTEXT")
  ELSIF wParam = W.CF_METAFILEPICT THEN
    Strings.Append(str,"CF_METAFILEPICT")
  ELSIF wParam = W.CF_OEMTEXT THEN
    Strings.Append(str,"CF_OEMTEXT")
  ELSIF wParam = W.CF_OWNERDISPLAY THEN
    Strings.Append(str,"CF_OWNERDISPLAY")
  ELSIF wParam = W.CF_PALETTE THEN
    Strings.Append(str,"CF_PALETTE")
  ELSIF wParam = W.CF_PENDATA THEN
    Strings.Append(str,"CF_PENDATA")
  ELSIF wParam = W.CF_RIFF THEN
    Strings.Append(str,"CF_RIFF")
  ELSIF wParam = W.CF_SYLK THEN
    Strings.Append(str,"CF_SYLK")
  ELSIF wParam = W.CF_TEXT THEN
    Strings.Append(str,"CF_TEXT")
  ELSIF wParam = W.CF_TIFF THEN
    Strings.Append(str,"CF_TIFF")
  ELSIF wParam = W.CF_WAVE THEN
    Strings.Append(str,"CF_WAVE")
  ELSE
    Strings.Append(str,"unknown"); numStr := "";
    Strings.HexStr(wParam, numStr); Strings.Append(str,numStr)  
  END;
END Proc_WM_RENDERFORMAT;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_SIZECLIPBOARD                          *)
(*                                                                            *)
(* COMMENTS: The WM_SIZECLIPBOARD message is sent by the clipboard viewer to  *)
(*           the clipboard owner when the clipboard contains data with the    *)
(*           CF_OWNERDISPLAY attribute and the size of the client area of the *)
(*           clipboard-viewer window has changed.                             *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         hwndViewer = (HWND) wParam: handle of clipboard viewer      *)
(* lParam         hglb = (HGLOBAL) LOWORD(lParam): handle of global object    *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_SIZECLIPBOARD*(wParam : W.WPARAM; 
                                   lParam : W.LPARAM;
                                   VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN 
  Strings.Append(str," hwndViewer:"); numStr := ""; 
  Strings.Str(wParam, numStr); Strings.Append(str,numStr);
  Strings.Append(str," hglb:"); numStr := ""; 
  Strings.HexStr(Utils.LoWord(lParam), numStr); Strings.Append(str,numStr);
END Proc_WM_SIZECLIPBOARD;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_VSCROLLCLIPBOARD                       *)
(*                                                                            *)
(* COMMENTS: The WM_VSCROLLCLIPBOARD message is sent by the clipboard viewer  *)
(*           to the clipboard owner when the clipboard data has the           *)
(*           CF_OWNERDISPLAY format and there is an event in the clipboard    *)
(*           viewer's vertical scroll bar. The owner should scroll the        *)
(*           clipboard image, invalidate the appropriate section, and update  *)
(*           the scroll bar values.                                           *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         hwndCBViewer = (HWND) wParam: handle of clipboard viewer    *)
(* lParam         wScrollCode = LOWORD(lParam): scroll bar code               *)
(*                wThumbPos = HIWORD(lParam): scroll box position             *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_VSCROLLCLIPBOARD*(wParam : W.WPARAM; 
                                    lParam : W.LPARAM;
                                    VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN 
  Strings.Append(str," hwndCBViewer:"); numStr := "";
  Strings.HexStr(wParam, numStr); Strings.Append(str, numStr);

  Strings.Append(str," wScrollCode:");
  ASSERT((Utils.LoWord(lParam) >= 0) & (Utils.LoWord(lParam) < LEN(ht.sbVscrTab)));
  IF (ht.sbVscrTab[Utils.LoWord(lParam)] # "") THEN
    Strings.Append(str, ht.sbVscrTab[Utils.LoWord(lParam)])
  ELSE
    Strings.Append(str," unknown:"); numStr := ""; 
    Strings.HexStr(Utils.LoWord(lParam), numStr); Strings.Append(str, numStr)
  END;
  
  IF (Utils.LoWord(lParam) = W.SB_THUMBPOSITION) THEN
    Strings.Append(str," wThumbPos:"); numStr := "";  
    Strings.Str(Utils.HiWord(lParam), numStr); Strings.Append(str, numStr) 
  END
END Proc_WM_VSCROLLCLIPBOARD;


BEGIN
END ClpProc.
