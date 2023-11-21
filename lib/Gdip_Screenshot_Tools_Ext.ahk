#Requires AutoHotkey v2.0

;#####################################################################################
; Extension GDI+ Functions for Screenshots:
;#####################################################################################
; created by Buzzerb 21/11/2023
;
; Inclues functions to screenshot only the client area of an application, and to use 
; an unofficially documented PrintWindow flag to get a rendered screenshot of an application,
; which is required by most hardware accelerated apps to screenshot correctly
; Heavily based on GDI+ for AHKv2 by buliasz 21/11/2023
; Requires Gdip_All, available from: https://github.com/buliasz/AHKv2-Gdip


;#####################################################################################
; Modified GDI+ function to get bitmap of just the client areas of the window

; Function				Gdip_ClientAreaBitmapFromHWND
; Description			Uses PrintWindow to get a handle to the specified window and return a bitmap of just its client area
;						Note that the 
;
; hwnd					handle to the window to get a bitmap from
;
; return				if the function succeeds, the return value is a pointer to a gdi+ bitmap
;
; notes					Window must not be not minimised in order to get a handle to it's client area


Gdip_ClientAreaBitmapFromHWND(hwnd)
{
	WinGetClientRect(hwnd,,, &Width, &Height)
	hbm := CreateDIBSection(Width, Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
	PrintWindow(hwnd, hdc, 1)
	pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
	return pBitmap
}


;#####################################################################################
; Modified GDI+ function to get bitmap of a window post rendering
; WARNING: THIS USES A PrintWindow FLAG THAT IS NOT OFFICIALLY DOCUMENTED AND ONLY AVAILABLE IN WIN 8.1 AND HIGHER
; DUE TO THE UNDOCUMENTED NATURE, THE BEHAVIOUR OF THIS SCRIPT MAY CHANGE AT ANY TIME

; Function				Gdip_RenderedBitmapFromHWND
; Description			Uses PrintWindow to get a handle to the specified window and return a bitmap 
;						of that window post rendering. This is necessary for most hardware accelerated
;						applications to get a screenshot that is not blank or corrupted. Note that the 
;						area screenshotted includes the non-client area, which may include the drop shadow
;						often present in modern themes as a border. To avoid this, try capturing the client area 
;						only, using Gdip_RenderedClientAreaBitmapFromHWND
;
; hwnd					handle to the window to get a bitmap from
;
; return				if the function succeeds, the return value is a pointer to a gdi+ bitmap
;
; notes					Window must not be not minimised in order to get a handle to it's client area


Gdip_RenderedBitmapFromHWND(hwnd)
{
	WinGetRect(hwnd,,, &Width, &Height)
	hbm := CreateDIBSection(Width, Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
	PrintWindow(hwnd, hdc, 2)
	pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
	return pBitmap
}

;#####################################################################################
; Modified GDI+ function to get bitmap of just the client area of a window post rendering
; WARNING: THIS USES A PrintWindow FLAG THAT IS ENTIRELY UNDOCUMENTED. USE AT YOUR OWN RISK
; DUE TO THE  ENTIRELY UNDOCUMENTED NATURE, THE BEHAVIOUR OF THIS SCRIPT MAY CHANGE AT ANY TIME

; Function				Gdip_RenderedClientAreaBitmapFromHWND
; Description			Uses PrintWindow to get a handle to the specified window and return a bitmap 
;						of just that window's client area post rendering. This is necessary for most 
;						hardware accelerated applications to get a screenshot that is not blank or corrupted.
;
; hwnd					handle to the window to get a bitmap from
;
; return				if the function succeeds, the return value is a pointer to a gdi+ bitmap
;
; notes					Window must not be not minimised in order to get a handle to it's client area


Gdip_RenderedClientAreaBitmapFromHWND(hwnd)
{
	WinGetClientRect(hwnd,,, &Width, &Height)
	hbm := CreateDIBSection(Width, Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
	PrintWindow(hwnd, hdc, 3)
	pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
	return pBitmap
}

;#####################################################################################
; Basic function to get a rectangle of the client area of an application
; Based on WinGetClientPos by dd900 and Frosti - https://www.autohotkey.com/boards/viewtopic.php?t=484
; and the modified version of the above, WinGetRect as found in GDI+ for v2
WinGetClientRect( hwnd, &x:="", &y:="", &w:="", &h:="" ) {
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	CreateRect(&winRect, 0, 0, 0, 0) ;is 16 on both 32 and 64
	; VarSetCapacity( winRect, 16, 0 )	; Alternative of above two lines
	DllCall( "GetClientRect", "Ptr", hwnd, "Ptr", winRect )
	DllCall( "ClientToScreen", "Ptr", hwnd, "Ptr", winRect )
	x := NumGet(winRect,  0, "UInt")
	y := NumGet(winRect,  4, "UInt")
	w := NumGet(winRect,  8, "UInt")
	h := NumGet(winRect, 12, "UInt")
}

