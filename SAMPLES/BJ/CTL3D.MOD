DEFINITION Ctl3D;

IMPORT W:=Windows;

(* Ctl3dSubclassDlg3d flags *)
CONST CTL3D_BUTTONS      = 1;
      CTL3D_LISTBOXES    = 2;
      CTL3D_EDITS        = 4;
      CTL3D_COMBOS       = 8;
      CTL3D_STATICTEXTS  = 16;
      CTL3D_STATICFRAMES = 32;
      CTL3D_NODLGWINDOW  = 65536;

      CTL3D_ALL          = 65535;


      WM_DLGBORDER       = W.WM_USER+3567;
      (* WM_DLGBORDER PInteger(lParam)^ return codes *)
      CTL3D_NOBORDER     = 0;
      CTL3D_BORDER       = 1;

      WM_DLGSUBCLASS     = W.WM_USER+3568;
      (* WM_DLGSUBCLASS PInteger(lParam)^ return codes *)
      CTL3D_NOSUBCLASS   = 0;
      CTL3D_SUBCLASS     = 1;


PROCEDURE [WINDOWS] Ctl3DSubclassDlg(hWindow : W.HWND; grBits : W.WORD) : W.BOOL;
PROCEDURE [WINDOWS] Ctl3DSubclassDlgEx(hWindow : W.HWND; grBits : W.WORD) : W.BOOL;
PROCEDURE [WINDOWS] Ctl3DGetVer() : W.WORD;
PROCEDURE [WINDOWS] Ctl3DEnabled() : W.BOOL;
PROCEDURE [WINDOWS] Ctl3DCtlColor(dc : W.HDC; color : W.COLORREF) : W.HBRUSH; 
PROCEDURE [WINDOWS] Ctl3DCtlColorEx(message, wParam : W.WORD; lParam : LONGINT) : W.HBRUSH;
PROCEDURE [WINDOWS] Ctl3DColorChange() : W.BOOL;
PROCEDURE [WINDOWS] Ctl3DSubclassCtl(hWindow : W.HWND) : W.BOOL;
PROCEDURE [WINDOWS] Ctl3DDlgFramePaint(hWindow : W.HWND; message, wParam : W.WORD; lParam : LONGINT) : LONGINT;
PROCEDURE [WINDOWS] Ctl3DAutoSubclass(instance : W.HINSTANCE) : W.BOOL;
PROCEDURE [WINDOWS] Ctl3DRegister(instance : W.HINSTANCE) : W.BOOL;
PROCEDURE [WINDOWS] Ctl3DUnregister(instance : W.HINSTANCE) : W.BOOL;
(* begin DBCS: far east short cut key support *)
PROCEDURE [WINDOWS] Ctl3DWinIniChange();
(* end DBCS *)

END Ctl3D.
