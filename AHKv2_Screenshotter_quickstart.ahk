#Requires AutoHotkey v2.0

;
;################################################################################################
;        Takes a screenshot, names it and puts it in folder called "ScreenShots"
; This script is an edit of a previous screenshot script by Cruncher1, based almost
; entirely on the Gdip standard library v1.45 by tic (Tariq Porter) 07/09/11 
; I have updated it to AHKv2 by modifying it to use an edit of the GDI+ library 
; updated for v2 by buliasz 21/11/2023, and extended it with functions to screenshot 
; only one window, with various areas and rendering options available by Buzzerb
;
;
;          Gdip code available from: https://github.com/buliasz/AHKv2-Gdip
;   Gdip tutorial: http://www.autohotkey.com/board/topic/29449-gdi-standard-library-145-by-tic/
;################################################################################################
;################################################################################################



pToken := Gdip_Startup()
OnExit(shutdown, )

folderPath := A_ScriptDir "\Screenshots\"
if (!DirExist(folderPath)) {
	DirCreate folderPath
}

;#####################################################################################
; Sample Hotkeys:
;#####################################################################################

; Whole Screen Capture:
^!s::
{
	CaptureWholeScreen()
	return
}

; Active Window Capture
^!a::
{
	CaptureActiveWindow()
	return
}

; Active Window Client Only Capture
^!c::
{
	CaptureActiveWindow(true)
	return
}

; Active Window Rendered Capture
^!r::
{
	CaptureRenderedActiveWindow()
	return
}

; Active Window Rendered Client Only Capture
^!w::
{
	CaptureRenderedActiveWindow(true)
	return
}

;#####################################################################################
; Screenshot Functions:
;#####################################################################################


CaptureWholeScreen()
{
	pBitmap := Gdip_BitmapFromScreen()
	fileName :=  A_YYYY "-" A_MM "-" A_DD "-" A_Hour "-" A_Min "-" A_Sec ".png"
	;NOTE: other formats are supported, just replace "jpg" with "png" or another format in the fileName.
	saveFileTo := folderPath fileName
	Gdip_SaveBitmapToFile(pBitmap, saveFileTo)
	Gdip_DisposeImage(pBitmap)
	return
}

CaptureActiveWindow(clientOnly := false)
{
	activeHWND := WinExist("A")
	if clientOnly {
		pBitmap := Gdip_ClientAreaBitmapFromHWND(activeHWND)
	}
	else {
		pBitmap := Gdip_BitmapFromHWND(activeHWND)
	}
	fileName :=  A_YYYY "-" A_MM "-" A_DD "-" A_Hour "-" A_Min "-" A_Sec ".png"
	;NOTE: other formats are supported, just replace "jpg" with "png" or another format in the fileName.
	saveFileTo := folderPath fileName
	Gdip_SaveBitmapToFile(pBitmap, saveFileTo)
	Gdip_DisposeImage(pBitmap)
	return
}

CaptureRenderedActiveWindow(clientOnly := false)
; NOTE: This function uses flags in calls to windows DLLs that are either not officially documented or ENTIRELY UNDOCUMENTED
; As such, behavior may vary or change at any time 
; Rendered capture is also significantly slower, so should be avoided where possible
; That said this is in my experience the most accurate window capture method across various apps
; USE AT YOUR OWN RISK
{
	userConfirm := MsgBox("This function uses undocumented flags for the Windows function PrintWindow. Behavior may be unexpected or change at any time. USE AT YOUR OWN RISK. Press OK if you accept to continue."
							, "WARNING!", "OKCancel Icon! 256 4096")
	if (userConfirm = "OK") {
		activeHWND := WinExist("A")
		if clientOnly {
			pBitmap := Gdip_RenderedClientAreaBitmapFromHWND(activeHWND)
		}
		else {
			pBitmap := Gdip_RenderedBitmapFromHWND(activeHWND)
		}
		fileName :=  A_YYYY "-" A_MM "-" A_DD "-" A_Hour "-" A_Min "-" A_Sec ".png"
		;NOTE: other formats are supported, just replace "jpg" with "png" or another format in the fileName.
		saveFileTo := folderPath fileName
		Gdip_SaveBitmapToFile(pBitmap, saveFileTo)
		Gdip_DisposeImage(pBitmap)
	}
	return
}


shutdown(A_ExitReason, ExitCode)
{
	Gdip_Shutdown(pToken)
	ExitApp()
	Return 1
}


;#####################################################################################
; Extension GDI+ Functions for Screenshots:
;#####################################################################################
; extended by Buzzerb 21/11/2023
;
; Inclues functions to screenshot only the client area of an application, and to use 
; an unofficially documented PrintWindow flag to get a rendered screenshot of an application
; which is required by most hardware accelerated apps to screenshot correctly



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


;################################################################################################
; All that follows are copied from the GDI+ library updated for v2 by buliasz 21/11/20231
;
; v1.61
;
;#####################################################################################
;#####################################################################################
; FUNCTIONS
;#####################################################################################

; Function				BitBlt
; Description			The BitBlt function performs a bit-block transfer of the color data corresponding to a rectangle
;						of pixels from the specified source device context into a destination device context.
;
; dDC					handle to destination DC
; dx					x-coord of destination upper-left corner
; dy					y-coord of destination upper-left corner
; dw					width of the area to copy
; dh					height of the area to copy
; sDC					handle to source DC
; sx					x-coordinate of source upper-left corner
; sy					y-coordinate of source upper-left corner
; Raster				raster operation code
;
; return				if the function succeeds, the return value is nonzero
;
; notes					if no raster operation is specified, then SRCCOPY is used, which copies the source directly to the destination rectangle
;
; BLACKNESS				= 0x00000042
; NOTSRCERASE			= 0x001100A6
; NOTSRCCOPY			= 0x00330008
; SRCERASE				= 0x00440328
; DSTINVERT				= 0x00550009
; PATINVERT				= 0x005A0049
; SRCINVERT				= 0x00660046
; SRCAND				= 0x008800C6
; MERGEPAINT			= 0x00BB0226
; MERGECOPY				= 0x00C000CA
; SRCCOPY				= 0x00CC0020
; SRCPAINT				= 0x00EE0086
; PATCOPY				= 0x00F00021
; PATPAINT				= 0x00FB0A09
; WHITENESS				= 0x00FF0062
; CAPTUREBLT			= 0x40000000
; NOMIRRORBITMAP		= 0x80000000

BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster:="")
{
	return DllCall("gdi32\BitBlt"
					, "UPtr", dDC
					, "Int", dx
					, "Int", dy
					, "Int", dw
					, "Int", dh
					, "UPtr", sDC
					, "Int", sx
					, "Int", sy
					, "UInt", Raster ? Raster : 0x00CC0020)
}

;#####################################################################################

; Function				Gdip_BitmapFromScreen
; Description			Gets a gdi+ bitmap from the screen
;
; Screen				0 = All screens
;						Any numerical value = Just that screen
;						x|y|w|h = Take specific coordinates with a width and height
; Raster				raster operation code
;
; return					if the function succeeds, the return value is a pointer to a gdi+ bitmap
;						-1:		one or more of x,y,w,h not passed properly
;
; notes					if no raster operation is specified, then SRCCOPY is used to the returned bitmap

Gdip_BitmapFromScreen(Screen:=0, Raster:="")
{
	hhdc := 0
	if (Screen = 0) {
		_x := DllCall( "GetSystemMetrics", "Int", 76 )
		_y := DllCall( "GetSystemMetrics", "Int", 77 )
		_w := DllCall( "GetSystemMetrics", "Int", 78 )
		_h := DllCall( "GetSystemMetrics", "Int", 79 )
	}
	else if (SubStr(Screen, 1, 5) = "hwnd:") {
		Screen := SubStr(Screen, 6)
		if !WinExist("ahk_id " Screen) {
			return -2
		}
		WinGetRect(Screen,,, &_w, &_h)
		_x := _y := 0
		hhdc := GetDCEx(Screen, 3)
	}
	else if IsInteger(Screen) {
		M := GetMonitorInfo(Screen)
		_x := M.Left, _y := M.Top, _w := M.Right-M.Left, _h := M.Bottom-M.Top
	}
	else {
		S := StrSplit(Screen, "|")
		_x := S[1], _y := S[2], _w := S[3], _h := S[4]
	}

	if (_x = "") || (_y = "") || (_w = "") || (_h = "") {
		return -1
	}

	chdc := CreateCompatibleDC()
	hbm := CreateDIBSection(_w, _h, chdc)
	obm := SelectObject(chdc, hbm)
	hhdc := hhdc ? hhdc : GetDC()
	BitBlt(chdc, 0, 0, _w, _h, hhdc, _x, _y, Raster)
	ReleaseDC(hhdc)

	pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)

	SelectObject(chdc, obm)
	DeleteObject(hbm)
	DeleteDC(hhdc)
	DeleteDC(chdc)
	return pBitmap
}

;#####################################################################################

; Function				Gdip_BitmapFromHWND
; Description			Uses PrintWindow to get a handle to the specified window and return a bitmap from it
;
; hwnd					handle to the window to get a bitmap from
;
; return				if the function succeeds, the return value is a pointer to a gdi+ bitmap
;
; notes					Window must not be not minimised in order to get a handle to it's client area

Gdip_BitmapFromHWND(hwnd)
{
	WinGetRect(hwnd,,, &Width, &Height)
	hbm := CreateDIBSection(Width, Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
	PrintWindow(hwnd, hdc)
	pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
	return pBitmap
}

;#####################################################################################

; Function				CreateRect
; Description			Creates a Rect object, containing a the coordinates and dimensions of a rectangle
;
; RectF		 			Name to call the RectF object
; x						x-coordinate of the upper left corner of the rectangle
; y						y-coordinate of the upper left corner of the rectangle
; w						Width of the rectangle
; h						Height of the rectangle
;
; return				No return value
CreateRect(&Rect, x, y, w, h)
{
	Rect := Buffer(16)
	NumPut("UInt", x, "UInt", y, "UInt", w, "UInt", h, Rect)
}
;#####################################################################################

; Function				CreateDIBSection
; Description			The CreateDIBSection function creates a DIB (Device Independent Bitmap) that applications can write to directly
;
; w						width of the bitmap to create
; h						height of the bitmap to create
; hdc					a handle to the device context to use the palette from
; bpp					bits per pixel (32 = ARGB)
; ppvBits				A pointer to a variable that receives a pointer to the location of the DIB bit values
;
; return				returns a DIB. A gdi bitmap
;
; notes					ppvBits will receive the location of the pixels in the DIB

CreateDIBSection(w, h, hdc:="", bpp:=32, &ppvBits:=0)
{
	hdc2 := hdc ? hdc : GetDC()
	bi := Buffer(40, 0)

	NumPut("UInt", 40, "UInt", w, "UInt", h, "ushort", 1, "ushort", bpp, "UInt", 0, bi)

	hbm := DllCall("CreateDIBSection"
					, "UPtr", hdc2
					, "UPtr", bi.Ptr
					, "UInt", 0
					, "UPtr*", &ppvBits
					, "UPtr", 0
					, "UInt", 0, "UPtr")

	if (!hdc) {
		ReleaseDC(hdc2)
	}
	return hbm
}

;#####################################################################################

; Function				PrintWindow
; Description			The PrintWindow function copies a visual window into the specified device context (DC), typically a printer DC
;
; hwnd					A handle to the window that will be copied
; hdc					A handle to the device context
; Flags					Drawing options
;
; return				if the function succeeds, it returns a nonzero value
;
; PW_CLIENTONLY			= 1

PrintWindow(hwnd, hdc, Flags:=0)
{
	return DllCall("PrintWindow", "UPtr", hwnd, "UPtr", hdc, "UInt", Flags)
}


;#####################################################################################

; Function				CreateCompatibleDC
; Description			This function creates a memory device context (DC) compatible with the specified device
;
; hdc					Handle to an existing device context
;
; return				returns the handle to a device context or 0 on failure
;
; notes					if this handle is 0 (by default), the function creates a memory device context compatible with the application's current screen

CreateCompatibleDC(hdc:=0)
{
	return DllCall("CreateCompatibleDC", "UPtr", hdc)
}

;#####################################################################################
; Function				SelectObject
; Description			The SelectObject function selects an object into the specified device context (DC). The new object replaces the previous object of the same type
;
; hdc					Handle to a DC
; hgdiobj				A handle to the object to be selected into the DC
;
; return				if the selected object is not a region and the function succeeds, the return value is a handle to the object being replaced
;
; notes					The specified object must have been created by using one of the following functions
;						Bitmap - CreateBitmap, CreateBitmapIndirect, CreateCompatibleBitmap, CreateDIBitmap, CreateDIBSection (A single bitmap cannot be selected into more than one DC at the same time)
;						Brush - CreateBrushIndirect, CreateDIBPatternBrush, CreateDIBPatternBrushPt, CreateHatchBrush, CreatePatternBrush, CreateSolidBrush
;						Font - CreateFont, CreateFontIndirect
;						Pen - CreatePen, CreatePenIndirect
;						Region - CombineRgn, CreateEllipticRgn, CreateEllipticRgnIndirect, CreatePolygonRgn, CreateRectRgn, CreateRectRgnIndirect
;
; notes					if the selected object is a region and the function succeeds, the return value is one of the following value
;
; SIMPLEREGION			= 2 Region consists of a single rectangle
; COMPLEXREGION			= 3 Region consists of more than one rectangle
; NULLREGION			= 1 Region is empty

SelectObject(hdc, hgdiobj)
{
	return DllCall("SelectObject", "UPtr", hdc, "UPtr", hgdiobj)
}

;#####################################################################################

; Function				DeleteObject
; Description			This function deletes a logical pen, brush, font, bitmap, region, or palette, freeing all system resources associated with the object
;						After the object is deleted, the specified handle is no longer valid
;
; hObject				Handle to a logical pen, brush, font, bitmap, region, or palette to delete
;
; return				Nonzero indicates success. Zero indicates that the specified handle is not valid or that the handle is currently selected into a device context

DeleteObject(hObject)
{
	return DllCall("DeleteObject", "UPtr", hObject)
}

;#####################################################################################

; Function				GetDC
; Description			This function retrieves a handle to a display device context (DC) for the client area of the specified window.
;						The display device context can be used in subsequent graphics display interface (GDI) functions to draw in the client area of the window.
;
; hwnd					Handle to the window whose device context is to be retrieved. If this value is NULL, GetDC retrieves the device context for the entire screen
;
; return				The handle the device context for the specified window's client area indicates success. NULL indicates failure

GetDC(hwnd:=0)
{
	return DllCall("GetDC", "UPtr", hwnd)
}

;#####################################################################################

; DCX_CACHE = 0x2
; DCX_CLIPCHILDREN = 0x8
; DCX_CLIPSIBLINGS = 0x10
; DCX_EXCLUDERGN = 0x40
; DCX_EXCLUDEUPDATE = 0x100
; DCX_INTERSECTRGN = 0x80
; DCX_INTERSECTUPDATE = 0x200
; DCX_LOCKWINDOWUPDATE = 0x400
; DCX_NORECOMPUTE = 0x100000
; DCX_NORESETATTRS = 0x4
; DCX_PARENTCLIP = 0x20
; DCX_VALIDATE = 0x200000
; DCX_WINDOW = 0x1

GetDCEx(hwnd, flags:=0, hrgnClip:=0)
{
	return DllCall("GetDCEx", "UPtr", hwnd, "UPtr", hrgnClip, "Int", flags)
}

;#####################################################################################

; Function				ReleaseDC
; Description			This function releases a device context (DC), freeing it for use by other applications. The effect of ReleaseDC depends on the type of device context
;
; hdc					Handle to the device context to be released
; hwnd					Handle to the window whose device context is to be released
;
; return				1 = released
;						0 = not released
;
; notes					The application must call the ReleaseDC function for each call to the GetWindowDC function and for each call to the GetDC function that retrieves a common device context
;						An application cannot use the ReleaseDC function to release a device context that was created by calling the CreateDC function; instead, it must use the DeleteDC function.

ReleaseDC(hdc, hwnd:=0)
{
	return DllCall("ReleaseDC", "UPtr", hwnd, "UPtr", hdc)
}

;#####################################################################################

; Function				DeleteDC
; Description			The DeleteDC function deletes the specified device context (DC)
;
; hdc					A handle to the device context
;
; return				if the function succeeds, the return value is nonzero
;
; notes					An application must not delete a DC whose handle was obtained by calling the GetDC function. Instead, it must call the ReleaseDC function to free the DC

DeleteDC(hdc)
{
	return DllCall("DeleteDC", "UPtr", hdc)
}

;#####################################################################################

; Function:				Gdip_SaveBitmapToFile
; Description:			Saves a bitmap to a file in any supported format onto disk
;
; pBitmap				Pointer to a bitmap
; sOutput				The name of the file that the bitmap will be saved to. Supported extensions are: .BMP,.DIB,.RLE,.JPG,.JPEG,.JPE,.JFIF,.GIF,.TIF,.TIFF,.PNG
; Quality				if saving as jpg (.JPG,.JPEG,.JPE,.JFIF) then quality can be 1-100 with default at maximum quality
;
; return				if the function succeeds, the return value is zero, otherwise:
;						-1 = Extension supplied is not a supported file format
;						-2 = Could not get a list of encoders on system
;						-3 = Could not find matching encoder for specified file format
;						-4 = Could not get WideChar name of output file
;						-5 = Could not save file to disk
;
; notes					This function will use the extension supplied from the sOutput parameter to determine the output format

Gdip_SaveBitmapToFile(pBitmap, sOutput, Quality:=75)
{
	_p := 0

	SplitPath sOutput,,, &extension:=""
	if (!RegExMatch(extension, "^(?i:BMP|DIB|RLE|JPG|JPEG|JPE|JFIF|GIF|TIF|TIFF|PNG)$")) {
		return -1
	}
	extension := "." extension

	DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", &nCount:=0, "uint*", &nSize:=0)
	ci := Buffer(nSize)
	DllCall("gdiplus\GdipGetImageEncoders", "UInt", nCount, "UInt", nSize, "UPtr", ci.Ptr)
	if !(nCount && nSize) {
		return -2
	}

	loop nCount {
		address := NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize, "UPtr")
		sString := StrGet(address, "UTF-16")
		if !InStr(sString, "*" extension)
			continue

		pCodec := ci.Ptr+idx
		break
	}

	if !pCodec {
		return -3
	}

	if (Quality != 75) {
		Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality

		if RegExMatch(extension, "^\.(?i:JPG|JPEG|JPE|JFIF)$") {
			DllCall("gdiplus\GdipGetEncoderParameterListSize", "UPtr", pBitmap, "UPtr", pCodec, "uint*", &nSize)
			EncoderParameters := Buffer(nSize, 0)
			DllCall("gdiplus\GdipGetEncoderParameterList", "UPtr", pBitmap, "UPtr", pCodec, "UInt", nSize, "UPtr", EncoderParameters.Ptr)
			nCount := NumGet(EncoderParameters, "UInt")
			loop nCount
			{
				elem := (24+(A_PtrSize ? A_PtrSize : 4))*(A_Index-1) + 4 + (pad := A_PtrSize = 8 ? 4 : 0)
				if (NumGet(EncoderParameters, elem+16, "UInt") = 1) && (NumGet(EncoderParameters, elem+20, "UInt") = 6)
				{
					_p := elem + EncoderParameters.Ptr - pad - 4
					NumPut("UInt", Quality, NumGet(NumPut("UInt", 4, NumPut("UInt", 1, _p+0)+20), "UInt"))
					break
				}
			}
		}
	}

	_E := DllCall("gdiplus\GdipSaveImageToFile", "UPtr", pBitmap, "UPtr", StrPtr(sOutput), "UPtr", pCodec, "UInt", _p ? _p : 0)

	return _E ? -5 : 0
}

;#####################################################################################

Gdip_CreateBitmapFromHBITMAP(hBitmap, Palette:=0)
{
	DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "UPtr", hBitmap, "UPtr", Palette, "UPtr*", &pBitmap:=0)
	return pBitmap
}

;#####################################################################################
; Create resources
;#####################################################################################

Gdip_DisposeImage(pBitmap)
{
	return DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap)
}

;#####################################################################################
; Extra functions
;#####################################################################################

Gdip_Startup()
{
	if (!DllCall("LoadLibrary", "str", "gdiplus", "UPtr")) {
		throw Error("Could not load GDI+ library")
	}

	si := Buffer(A_PtrSize = 8 ? 24 : 16, 0)
	NumPut("UInt", 1, si)
	DllCall("gdiplus\GdiplusStartup", "UPtr*", &pToken:=0, "UPtr", si.Ptr, "UPtr", 0)
	if (!pToken) {
		throw Error("Gdiplus failed to start. Please ensure you have gdiplus on your system")
	}

	return pToken
}

Gdip_Shutdown(pToken)
{
	DllCall("gdiplus\GdiplusShutdown", "UPtr", pToken)
	hModule := DllCall("GetModuleHandle", "str", "gdiplus", "UPtr")
	if (!hModule) {
		throw Error("GDI+ library was unloaded before shutdown")
	}
	if (!DllCall("FreeLibrary", "UPtr", hModule)) {
		throw Error("Could not free GDI+ library")
	}

	return 0
}

; Prepend = 0; The new operation is applied before the old operation.
; Append = 1; The new operation is applied after the old operation.

; ======================================================================================================================
; Multiple Display Monitors Functions -> msdn.microsoft.com/en-us/library/dd145072(v=vs.85).aspx
; by 'just me'
; https://autohotkey.com/boards/viewtopic.php?f=6&t=4606
; ======================================================================================================================

GetMonitorInfo(MonitorNum)
{
	Monitors := MDMF_Enum()
	for k,v in Monitors {
		if (v.Num = MonitorNum) {
			return v
		}
	}
}

; ----------------------------------------------------------------------------------------------------------------------
; Name ..........: MDMF - Multiple Display Monitor Functions
; Description ...: Various functions for multiple display monitor environments
; Tested with ...: AHK 1.1.32.00 (A32/U32/U64) and 2.0-a108-a2fa0498 (U32/U64)
; Original Author: just me (https://www.autohotkey.com/boards/viewtopic.php?f=6&t=4606)
; Mod Authors ...: iPhilip, guest3456
; Changes .......: Modified to work with v2.0-a108 and changed 'Count' key to 'TotalCount' to avoid conflicts
; ................ Modified MDMF_Enum() so that it works under both AHK v1 and v2.
; ................ Modified MDMF_EnumProc() to provide Count and Primary keys to the Monitors array.
; ................ Modified MDMF_FromHWND() to allow flag values that determine the function's return value if the
; ................    window does not intersect any display monitor.
; ................ Modified MDMF_FromPoint() to allow the cursor position to be returned ByRef if not specified and
; ................    allow flag values that determine the function's return value if the point is not contained within
; ................    any display monitor.
; ................ Modified MDMF_FromRect() to allow flag values that determine the function's return value if the
; ................    rectangle does not intersect any display monitor.
;................. Modified MDMF_GetInfo() with minor changes.
; ----------------------------------------------------------------------------------------------------------------------
;
; ======================================================================================================================
; Multiple Display Monitors Functions -> msdn.microsoft.com/en-us/library/dd145072(v=vs.85).aspx =======================
; ======================================================================================================================
; Enumerates display monitors and returns an object containing the properties of all monitors or the specified monitor.
; ======================================================================================================================
MDMF_Enum(HMON := "") {
	static EnumProc := CallbackCreate(MDMF_EnumProc)
	static Monitors := Map()

	if (HMON = "") { 	; new enumeration
		Monitors := Map("TotalCount", 0)
		if !DllCall("User32.dll\EnumDisplayMonitors", "Ptr", 0, "Ptr", 0, "Ptr", EnumProc, "Ptr", ObjPtr(Monitors), "Int")
			return False
	}

	return (HMON = "") ? Monitors : Monitors.HasKey(HMON) ? Monitors[HMON] : False
}
; ======================================================================================================================
;  Callback function that is called by the MDMF_Enum function.
; ======================================================================================================================
MDMF_EnumProc(HMON, HDC, PRECT, ObjectAddr) {
	Monitors := ObjFromPtrAddRef(ObjectAddr)

	Monitors[HMON] := MDMF_GetInfo(HMON)
	Monitors["TotalCount"]++
	if (Monitors[HMON].Primary) {
		Monitors["Primary"] := HMON
	}

	return true
}

; ======================================================================================================================
; Retrieves information about a display monitor.
; ======================================================================================================================
MDMF_GetInfo(HMON) {
	MIEX := Buffer(40 + (32 << !!1))
	NumPut("UInt", MIEX.Size, MIEX)
	if DllCall("User32.dll\GetMonitorInfo", "Ptr", HMON, "Ptr", MIEX.Ptr, "Int") {
		return {Name:      (Name := StrGet(MIEX.Ptr + 40, 32))  ; CCHDEVICENAME = 32
		      , Num:       RegExReplace(Name, ".*(\d+)$", "$1")
		      , Left:      NumGet(MIEX, 4, "Int")    ; display rectangle
		      , Top:       NumGet(MIEX, 8, "Int")    ; "
		      , Right:     NumGet(MIEX, 12, "Int")   ; "
		      , Bottom:    NumGet(MIEX, 16, "Int")   ; "
		      , WALeft:    NumGet(MIEX, 20, "Int")   ; work area
		      , WATop:     NumGet(MIEX, 24, "Int")   ; "
		      , WARight:   NumGet(MIEX, 28, "Int")   ; "
		      , WABottom:  NumGet(MIEX, 32, "Int")   ; "
		      , Primary:   NumGet(MIEX, 36, "UInt")} ; contains a non-zero value for the primary monitor.
	}
	return False
}


; Based on WinGetClientPos by dd900 and Frosti - https://www.autohotkey.com/boards/viewtopic.php?t=484
WinGetRect( hwnd, &x:="", &y:="", &w:="", &h:="" ) {
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	CreateRect(&winRect, 0, 0, 0, 0) ;is 16 on both 32 and 64
	;VarSetCapacity( winRect, 16, 0 )	; Alternative of above two lines
	DllCall( "GetWindowRect", "Ptr", hwnd, "Ptr", winRect )
	x := NumGet(winRect,  0, "UInt")
	y := NumGet(winRect,  4, "UInt")
	w := NumGet(winRect,  8, "UInt") - x
	h := NumGet(winRect, 12, "UInt") - y
}
