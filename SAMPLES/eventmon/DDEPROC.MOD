(******************************************************************************)
(* MODULE:      DDEProc                                         ME - 29.06.96 *)
(* DESCRIPTION: Decoding procedures for DDE messages                          *)
(* LANGUAGE:    Oberon-2                                                      *)
(* COMPILER:    Robinson Associates Oberon-2 V1.18 beta6                      *)
(* WORKBENCH    POW 3.0 beta3                                                 *)
(* AUTHOR:      Martin Erdpresser, k3075e2@c210.edvz.uni-linz.ac.at (ME)      *)
(******************************************************************************)
(* DATE      AUTHOR  CHANGES                                                  *)
(* --------  ------  ---------------------------------------------------------*)
(* 29.05.96  ME      Initial Version                                          *)
(******************************************************************************)

MODULE DDEProc;

IMPORT W := Windows, Strings, Utils;


CONST
  STR_LEN = 128;

(*==============< Decoding procedures for DDE messages >======================*)
(* This Application provides for nonclient message group:                     *)
(*                WM_DDE_ACK                                                  *)
(*                WM_DDE_ADVISE                                               *)
(*                WM_DDE_DATA                                                 *)
(*                WM_DDE_EXECUTE                                              *)
(*                WM_DDE_INITIATE                                             *)
(*                WM_DDE_POKE                                                 *)
(*                WM_DDE_REQUEST                                              *)
(*                WM_DDE_TERMINATE                                            *)
(*                WM_DDE_UNADVISE                                             *)
(*============================================================================*)


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_DDE_ACK                                *)
(*                                                                            *)
(* COMMENTS: The WM_DDE_ACK message notifies an application of the receipt    *)
(*           and processing of a WM_DDE_INITIATE, WM_DDE_EXECUTE, WM_DDE_DATA,*)
(*           WM_DDE_ADVISE, WM_DDE_UNADVISE, or WM_DDE_POKE message, and in   *)
(*           some cases, of a WM_DDE_REQUEST message.                         *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) hwnd: handle of posting window            *)
(* lParam         lParam = MAKELPARAM(wLow, wHigh): depending on message      *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_DDE_ACK*(wParam : W.WPARAM; 
                           lParam : W.LPARAM;
                           VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN 
  Strings.Append(str," hwndPosting:"); numStr := ""; 
  Strings.Str(wParam, numStr); Strings.Append(str,numStr); 
  Strings.Append(str," wLow:"); numStr := ""; 
  Strings.HexStr(Utils.LoWord(lParam), numStr); Strings.Append(str,numStr);
  Strings.Append(str," wHigh:"); numStr := ""; 
  Strings.HexStr(Utils.HiWord(lParam), numStr); Strings.Append(str,numStr)
END Proc_WM_DDE_ACK;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_DDE_ADVISE                             *)
(*                                                                            *)
(* COMMENTS: A dynamic data exchange (DDE) client application posts the       *)
(*           WM_DDE_ADVISE message to a DDE server application to request the *)
(*           server to supply an update for a data item whenever it changes.  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) hwnd: handle of posting window            *)
(* lParam         lParam = MAKELPARAM(hOptions, aItem): send options,data item*)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_DDE_ADVISE*(wParam : W.WPARAM; 
                              lParam : W.LPARAM;
                              VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN 
  Strings.Append(str," hwndPosting:"); numStr := ""; 
  Strings.Str(wParam, numStr); Strings.Append(str,numStr); 
  Strings.Append(str," hOptions:"); numStr := ""; 
  Strings.HexStr(Utils.LoWord(lParam), numStr); Strings.Append(str,numStr);
  Strings.Append(str," aItem:"); numStr := ""; 
  Strings.HexStr(Utils.HiWord(lParam), numStr); Strings.Append(str,numStr)
END Proc_WM_DDE_ADVISE;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_DDE_DATA                               *)
(*                                                                            *)
(* COMMENTS: A dynamic data exchange (DDE) server application posts a         *)
(*           WM_DDE_DATA message to a DDE client application to pass a data   *)
(*           item to the client or to notify the client of the availability   *)
(*           of a data item.                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) hwnd: handle of posting window            *)
(* lParam         lParam = MAKELPARAM(hData, aItem): memory object, data item *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_DDE_DATA*(wParam : W.WPARAM; 
                            lParam : W.LPARAM;
                            VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN 
  Strings.Append(str," hwndPosting:"); numStr := ""; 
  Strings.Str(wParam, numStr); Strings.Append(str,numStr); 
  Strings.Append(str," hData:"); numStr := ""; 
  Strings.HexStr(Utils.LoWord(lParam), numStr); Strings.Append(str,numStr);
  Strings.Append(str," aItem:"); numStr := ""; 
  Strings.HexStr(Utils.HiWord(lParam), numStr); Strings.Append(str,numStr)
END Proc_WM_DDE_DATA;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_DDE_EXECUTE                            *)
(*                                                                            *)
(* COMMENTS: A dynamic data exchange (DDE) client application posts a         *)
(*           WM_DDE_EXECUTE message to a DDE server application to send a     *)
(*           string to the server to be processed as a series of commands.    *)
(*           The server application is expected to post a WM_DDE_ACK message  *)
(*           in response.                                                     *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) hwnd: handle of posting window            *)
(* lParam         lParam = MAKELPARAM(reserved,hCommands): commands to execute*)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_DDE_EXECUTE*(wParam : W.WPARAM; 
                               lParam : W.LPARAM;
                               VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN 
  Strings.Append(str," hwndPosting:"); numStr := ""; 
  Strings.Str(wParam, numStr); Strings.Append(str,numStr); 
  Strings.Append(str," hCommands:"); numStr := ""; 
  Strings.HexStr(Utils.HiWord(lParam), numStr); Strings.Append(str,numStr)
END Proc_WM_DDE_EXECUTE;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_DDE_INITIATE                           *)
(*                                                                            *)
(* COMMENTS: A dynamic data exchange (DDE) client application sends a         *)
(*           WM_DDE_INITIATE message to initiate a conversation with server   *)
(*           applications responding to the specified application and         *)
(*           topic names.                                                     *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) hwnd: handle of sending window            *)
(* lParam         lParam = MAKELPARAM(aApplication, aTopic): app.,topic atoms *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_DDE_INITIATE*(wParam : W.WPARAM; 
                                lParam : W.LPARAM;
                                VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN 
  Strings.Append(str," hwndSending:"); numStr := ""; 
  Strings.Str(wParam, numStr); Strings.Append(str,numStr); 
  Strings.Append(str," aApplication:"); numStr := ""; 
  Strings.HexStr(Utils.LoWord(lParam), numStr); Strings.Append(str,numStr);
  Strings.Append(str," aTopic:"); numStr := ""; 
  Strings.HexStr(Utils.HiWord(lParam), numStr); Strings.Append(str,numStr)
END Proc_WM_DDE_INITIATE;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_DDE_POKE                               *)
(*                                                                            *)
(* COMMENTS: A dynamic data exchange (DDE) client application posts a         *)
(*           WM_DDE_POKE message to a server application. A client uses this  *)
(*           message to request the server to accept an unsolicited data item.*)
(*           The server is expected to reply with a WM_DDE_ACK message        *)
(*           indicating whether it accepted the data item.                    *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) hwnd: handle of posting window            *)
(* lParam         lParam = MAKELPARAM(hData, aItem): memory object, data item *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_DDE_POKE*(wParam : W.WPARAM; 
                            lParam : W.LPARAM;
                            VAR str : ARRAY OF CHAR);
BEGIN 
  Proc_WM_DDE_DATA(wParam,lParam,str)         (* same output, so use this one *)
END Proc_WM_DDE_POKE;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_DDE_REQUEST                            *)
(*                                                                            *)
(* COMMENTS: A dynamic data exchange (DDE) client application posts a         *)
(*           WM_DDE_REQUEST message to a DDE server application to request    *)
(*           the value of a data item.                                        *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) hwnd: handle of posting window            *)
(* lParam         lParam = MAKELPARAM(cfFormat, aItem): clipboard format,item *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_DDE_REQUEST*(wParam : W.WPARAM; 
                               lParam : W.LPARAM;
                               VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN 
  Strings.Append(str," hwndPosting:"); numStr := ""; 
  Strings.Str(wParam, numStr); Strings.Append(str,numStr); 
  Strings.Append(str," cfFormat:"); numStr := ""; 
  Strings.HexStr(Utils.LoWord(lParam), numStr); Strings.Append(str,numStr);
  Strings.Append(str," aItem:"); numStr := ""; 
  Strings.HexStr(Utils.HiWord(lParam), numStr); Strings.Append(str,numStr)
END Proc_WM_DDE_REQUEST;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_DDE_TEMINATE                           *)
(*                                                                            *)
(* COMMENTS: A dynamic data exchange (DDE) application (client or server)     *)
(*           posts a WM_DDE_TERMINATE message to terminate a conversation.    *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) hwnd: handle of posting window            *)
(* lParam         lParam = 0L: not used, must be zero                         *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_DDE_TERMINATE*(wParam : W.WPARAM; 
                                 lParam : W.LPARAM;
                                 VAR str : ARRAY OF CHAR);
VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN 
  Strings.Append(str," hwndPosting:"); numStr := ""; 
  Strings.Str(wParam, numStr); Strings.Append(str,numStr) 
END Proc_WM_DDE_TERMINATE;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_DDE_UNADVISE                           *)
(*                                                                            *)
(* COMMENTS: A dynamic data exchange (DDE) client application posts a         *)
(*           WM_DDE_UNADVISE message to inform a server application that the  *)
(*           specified item or a particular clipboard format for the item     *)
(*           should no longer be updated. This terminates the warm or hot     *)
(*           link for the specified item.                                     *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = (WPARAM) hwnd: handle of posting window            *)
(* lParam         lParam = MAKELPARAM(cfFormat, aItem): clipboard format, item*)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_DDE_UNADVISE*(wParam : W.WPARAM; 
                                lParam : W.LPARAM;
                                VAR str : ARRAY OF CHAR);
BEGIN 
  Proc_WM_DDE_REQUEST(wParam,lParam,str)     (* same output, so use this one *)
END Proc_WM_DDE_UNADVISE;


BEGIN
END DDEProc.
