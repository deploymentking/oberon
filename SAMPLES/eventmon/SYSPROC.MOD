(******************************************************************************)
(* MODULE:      SysProc                                         ME - 29.06.96 *)
(* DESCRIPTION: Decoding procedures for system messages                       *)
(* LANGUAGE:    Oberon-2                                                      *)
(* COMPILER:    Robinson Associates Oberon-2 V1.18 beta6                      *)
(* WORKBENCH    POW 3.0 beta3                                                 *)
(* AUTHOR:      Martin Erdpresser, k3075e2@c210.edvz.uni-linz.ac.at (ME)      *)
(******************************************************************************)
(* DATE      AUTHOR  CHANGES                                                  *)
(* --------  ------  ---------------------------------------------------------*)
(* 29.05.96  ME      Initial Version                                          *)
(******************************************************************************)

MODULE SysProc;

IMPORT W := Windows, Strings, Utils, SYSTEM;


CONST
  STR_LEN = 128;

(*==============< Decoding procedures for system messages >===================*)
(* This Application provides for system message group:                        *)
(*                WM_COMPACTING                                               *)
(*                WM_DEVMODECHANGE                                            *)
(*                WM_FONTCHANGE     (using default)                           *)
(*                WM_ENTERIDLE                                                *)
(*                WM_NULL           (using default)                           *)
(*                WM_PALETTEISCHANGING                                        *)
(*                WM_PALETTECHANGED                                           *)
(*                WM_POWER                                                    *)
(*                WM_QUEUESYNC      (using default)                           *)
(*                WM_SPOOLERSTATUS                                            *)
(*                WM_SYSCOLORCHANGE (using default)                           *)
(*                WM_SYSCOMMAND                                               *)
(*                WM_TIMECHANGE     (using default)                           *)
(*                WM_WININICHANGE                                             *)
(*============================================================================*)


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_COMPACTING                             *)
(*                                                                            *)
(* COMMENTS: The WM_COMPACTING message is sent to all top-level windows when  *)
(*           Windows detects that more than 12.5 percent of system time over  *)
(*           a 30- to 60-second interval is being spent compacting memory.    *)
(*           This indicates that system memory is low. (0x8000 = 50%)         *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wCompactRatio = wParam: compacting ratio                    *)
(* lParam                                                                     *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_COMPACTING*(wParam : W.WPARAM; 
                              lParam : W.LPARAM;
                              VAR str : ARRAY OF CHAR);
VAR
  numStr : ARRAY STR_LEN OF CHAR;
 
BEGIN
  Strings.Append(str," wCompactRation:"); numStr := "";          
  Strings.HexStr(wParam,numStr); Strings.Append(str,numStr);
  Strings.Append(str," (="); numStr := "";          
  Strings.Str(ENTIER(100 / 65536 * wParam),numStr); Strings.Append(str,numStr);       
  Strings.Append(str,"%)");
END Proc_WM_COMPACTING;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_DEVMODECHANGE                          *)
(*                                                                            *)
(* COMMENTS: The WM_DEVMODECHANGE message is sent to all top-level windows    *)
(*           when the default device-mode settings have changed.              *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam                                                                     *)
(* lParam         lpszDev = (LPCSTR) lParam: address of device name           *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_DEVMODECHANGE*(wParam : W.WPARAM; 
                                 lParam : W.LPARAM;
                                 VAR str : ARRAY OF CHAR);
VAR
  numStr : ARRAY STR_LEN OF CHAR;
  r : LONGINT;

BEGIN
  Strings.Append(str," lpsz:"); numStr := "";          
  Strings.HexStr(lParam,numStr); Strings.Append(str,numStr);
  numStr := ""; r := W.lstrcpy(SYSTEM.ADR(numStr),lParam);
  IF (r # W.NULL) THEN
    Strings.Append(str,' ("'); 
    Strings.Append(str,numStr);
    Strings.Append(str,'")') 
  END  
END Proc_WM_DEVMODECHANGE;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_ENTERIDLE                              *)
(*                                                                            *)
(* COMMENTS: The WM_ENTERIDLE message informs an application's main window    *)
(*           procedure that a modal dialog box or a menu is entering an idle  *)
(*           state. A modal dialog box or menu enters an idle state when no   *)
(*           messages are waiting in its queue after it has processed one or  *)
(*           more previous messages.                                          *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fwSource = wParam: idle-source flag                         *)
(* lParam         hwndDlg = (HWND) LOWORD(lParam): handle dialog box or window*)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_ENTERIDLE*(wParam : W.WPARAM; 
                             lParam : W.LPARAM;
                             VAR str : ARRAY OF CHAR);
VAR
  numStr : ARRAY STR_LEN OF CHAR;
 
BEGIN
  Strings.Append(str," fwSource:"); 
  IF wParam = W.MSGF_DIALOGBOX THEN
    Strings.Append(str,"MSGF_DIALOGBOX")
  ELSIF wParam = W.MSGF_MENU THEN
    Strings.Append(str,"MSGF_MENU")
  ELSE
    numStr := ""; Strings.HexStr(wParam,numStr); 
    Strings.Append(str,numStr);    
  END;
  Strings.Append(str," hwndDlg:"); numStr := "";    
  Strings.HexStr(Utils.LoWord(lParam),numStr); Strings.Append(str,numStr)
END Proc_WM_ENTERIDLE;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_PALETTEISCHANGING                      *)
(*                                                                            *)
(* COMMENTS: The WM_PALETTEISCHANGING message informs applications that an    *)
(*           application is going to realize its logical palette.             *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         hwndRealize = (HWND) wParam: wind. handle to realize palette*)
(* lParam                                                                     *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_PALETTEISCHANGING*(wParam : W.WPARAM; 
                                     lParam : W.LPARAM;
                                     VAR str : ARRAY OF CHAR);
VAR
  numStr : ARRAY STR_LEN OF CHAR;
 
BEGIN
  Strings.Append(str," hwndRealize:"); numStr := "";    
  Strings.HexStr(wParam,numStr); Strings.Append(str,numStr)
END Proc_WM_PALETTEISCHANGING;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_PALETTECHANGED                         *)
(*                                                                            *)
(* COMMENTS: The WM_PALETTECHANGED message is sent to all top-level and       *)
(*           overlapped windows after the window with the input focus has     *)
(*           realized its logical palette, thereby changing the system        *)
(*           palette. This message allows a window without the input focus    *)
(*           that uses a color palette to realize its logical palette and     *)
(*           update its client area.                                          *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         hwndPalChg = (HWND) wParam: handle of window that changed   *)
(*                                            palette                         *)
(* lParam                                                                     *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_PALETTECHANGED*(wParam : W.WPARAM; 
                                  lParam : W.LPARAM;
                                  VAR str : ARRAY OF CHAR);
VAR
  numStr : ARRAY STR_LEN OF CHAR;
 
BEGIN
  Strings.Append(str," hwndPalChg:"); numStr := "";    
  Strings.HexStr(wParam,numStr); Strings.Append(str,numStr)
END Proc_WM_PALETTECHANGED;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_POWER                                  *)
(*                                                                            *)
(* COMMENTS: The WM_POWER message is sent when the system, typically a        *)
(*           battery-powered personal computer, is about to enter the         *)
(*           suspended mode.                                                  *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fwPowerEvt = wParam: power-event notification message       *)
(* lParam                                                                     *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_POWER*(wParam : W.WPARAM; 
                         lParam : W.LPARAM;
                         VAR str : ARRAY OF CHAR);
VAR
  numStr : ARRAY STR_LEN OF CHAR;
 
BEGIN
  Strings.Append(str," fwPowerEvent:"); 
  IF wParam = W.PWR_SUSPENDREQUEST THEN
    Strings.Append(str,"PWR_SUSPENDREQUEST")
  ELSIF wParam = W.PWR_SUSPENDRESUME THEN
    Strings.Append(str,"PWR_SUSPENDRESUME")
  ELSIF wParam = W.PWR_CRITICALRESUME THEN
    Strings.Append(str,"PWR_CRITICALRESUME")
  ELSE
    numStr := ""; Strings.HexStr(wParam,numStr); 
    Strings.Append(str,numStr)    
  END
END Proc_WM_POWER;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_SPOOLERSTATUS                          *)
(*                                                                            *)
(* COMMENTS: The WM_SPOOLERSTATUS message is sent from Print Manager whenever *)
(*           a job is added to or removed from the Print Manager queue.       *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         fwJobStatus = wParam: job-status flag                       *)
(* lParam         nJobsLeft = LOWORD(lParam): number of jobs remaining        *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_SPOOLERSTATUS*(wParam : W.WPARAM; 
                                 lParam : W.LPARAM;
                                 VAR str : ARRAY OF CHAR);
VAR
  numStr : ARRAY STR_LEN OF CHAR;
 
BEGIN
  Strings.Append(str," fwJobStatus:"); numStr := "";          
  Strings.HexStr(wParam,numStr); Strings.Append(str,numStr);
  Strings.Append(str," nJobsLeft"); numStr := "";          
  Strings.Str(Utils.LoWord(lParam),numStr); Strings.Append(str,numStr);       
END Proc_WM_SPOOLERSTATUS;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_SYSCOMMAND                             *)
(*                                                                            *)
(* COMMENTS: The WM_SYSCOMMAND message is sent when the user selects a        *)
(*           command from the System menu (sometimes referred to as the       *)
(*           Control menu) or when the user selects the Maximize button or    *)
(*           the Minimize button.                                             *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wCmdType = wParam: command value                            *)
(* lParam         xPos = LOWORD(lParam): horizontal position of cursor        *)
(*                yPos = HIWORD(lParam): vertical position of cursor          *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_SYSCOMMAND*(wParam : W.WPARAM; 
                              lParam : W.LPARAM;
                              VAR str : ARRAY OF CHAR);
CONST 
  mask = -16; (* 0xFFF0 *)

VAR 
  numStr : ARRAY STR_LEN OF CHAR;

BEGIN
  Strings.Append(str, " wCmdType:");
  wParam := Utils.BitAnd(wParam,mask);    (* four lower bits used internally *) 
  
  IF wParam = W.SC_CLOSE THEN
    Strings.Append(str,"SC_CLOSE")
  ELSIF wParam = W.SC_HSCROLL THEN
    Strings.Append(str,"SC_HSCROLL")
  ELSIF wParam = W.SC_HOTKEY THEN
    Strings.Append(str,"SC_HOTKEY") 
  ELSIF wParam = W.SC_KEYMENU THEN
    Strings.Append(str,"SC_KEYMENU")
  ELSIF wParam = W.SC_MAXIMIZE THEN
    Strings.Append(str,"SC_MAXIMIZE")
  ELSIF wParam = W.SC_MINIMIZE THEN
    Strings.Append(str,"SC_MINIMIZE")
  ELSIF wParam = W.SC_MOUSEMENU THEN
    Strings.Append(str,"SC_MOUSEMENU")
  ELSIF wParam = W.SC_MOVE THEN
    Strings.Append(str,"SC_MOVE")
  ELSIF wParam = W.SC_NEXTWINDOW THEN
    Strings.Append(str,"SC_NEXTWINDOW")
  ELSIF wParam = W.SC_PREVWINDOW THEN
    Strings.Append(str,"SC_PREVWINDOW")
  ELSIF wParam = W.SC_RESTORE THEN
    Strings.Append(str,"SC_RESTORE")
  ELSIF wParam = W.SC_SCREENSAVE THEN
    Strings.Append(str,"SC_SCREENSAVE")
  ELSIF wParam = W.SC_SIZE THEN
    Strings.Append(str,"SC_SIZE")
  ELSIF wParam = W.SC_TASKLIST THEN
    Strings.Append(str,"SC_TASKLIST")
  ELSIF wParam = W.SC_VSCROLL THEN
    Strings.Append(str,"SC_VSCROLL")
  ELSE
    Strings.Append(str,"unknown"); numStr := "";
    Strings.HexStr(wParam, numStr); Strings.Append(str,numStr)  
  END;
      
  IF wParam = W.SC_HOTKEY THEN
    Strings.Append(str,"hwndActivate"); numStr := "";
    Strings.HexStr(Utils.LoWord(lParam), numStr); Strings.Append(str,numStr) 
  ELSE
    Strings.Append(str, " Cursor xPos:"); numStr := "";
    Strings.Str(Utils.LoWord(lParam), numStr); Strings.Append(str,numStr);  
    Strings.Append(str, " yPos:"); numStr := "";
    Strings.Str(Utils.HiWord(lParam), numStr); Strings.Append(str,numStr)
  END
END Proc_WM_SYSCOMMAND;


(*============================================================================*)
(* PURPOSE:  Decoding procedure for WM_WININICHANGE                           *)
(*                                                                            *)
(* COMMENTS: An application sends the WM_WININICHANGE message to all          *)
(*           top-level windows after making a change to the Windows           *)
(*           initialization file, WIN.INI. The SystemParametersInfo function  *)
(*           sends the WM_WININICHANGE message after an application uses the  *)
(*           function to change a setting in the WIN.INI file.                *)
(*----------------------------------------------------------------------------*)
(* PARAMETER      DESCRIPTION                                                 *)
(* -------------- ------------------------------------------------------------*)
(* wParam         wParam = 0: not used, must be zero                          *)
(* lParam         lParam = (LPARAM) (LPCSTR) pszSection: address of string    *)
(* str            string to receive output                                    *)
(*============================================================================*)
PROCEDURE Proc_WM_WININICHANGE*(wParam : W.WPARAM; 
                                lParam : W.LPARAM;
                                VAR str : ARRAY OF CHAR);
VAR
  numStr : ARRAY STR_LEN OF CHAR;
  r : LONGINT;

BEGIN
  Strings.Append(str," pszSection:"); numStr := "";          
  Strings.HexStr(lParam,numStr); Strings.Append(str,numStr);
  numStr := ""; r := W.lstrcpy(SYSTEM.ADR(numStr),lParam);
  IF (r # W.NULL) THEN
    Strings.Append(str," ["); 
    Strings.Append(str,numStr);
    Strings.AppendChar(str,"]") 
  END  
END Proc_WM_WININICHANGE;



(*==============< Begin of module-body >======================================*)

BEGIN

END SysProc.
