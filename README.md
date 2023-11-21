# AHKv2-Screenshot-Tools
### **Scripts to make taking screenshots with AHK easy, written purely in AHK v2**

This repository contains a quickstart script to easily take and save various types of screenshot, plus scripts and libraries to make taking screenshots within your own scripts easy.
 Both a standalone library and a library to extend GDI+ are included.
 A sample script with various functions to take and save common types of screenshot using the before libraries is also included.

Compatible with the current [AutoHotKey v2](https://autohotkey.com/v2/).
 No support for AHK v1, see Cruncher1's similar AHK v1 script below.

This repository is based on GDI+ for AHK v2 by buliasz ([AHKv2-Gdip](https://github.com/buliasz/AHKv2-Gdip)).
 It is inspired by and draws some code from Cruncher1's [Screen capture script for AHKv1](https://www.autohotkey.com/board/topic/91585-screen-capture-using-only-ahk-no-3rd-party-software-required/).

See the [commit history](https://github.com/Buzzerb/AHKv2-Gdip-Screenshotter/commits/master) for changes made.


## Quickstart
Download and run `AHKv2_Screenshotter_Quickstart.ahk`.
 It will create a folder in the script's directory entitled screenshots if one does not already exist.

To take screenshots, press Ctrl + Alt and one of  
s: Whole screen capture  
a: Active window capture  
c: Active window client area capture  
r: Rendered active window capture (see below and comments in file for more details, not officially supported by Microsoft)  
w: Rendered active window client area capture (see below and comments in file for more details, not officially supported by Microsoft)  

Screenshots will be saved to the screenshot folder in the script directory


## Rendered vs Unrendered Screenshots
AHKv2-Screenshot_Tools' most significant advantage over pure GDI+ is the ability to take screenshots of hardware accelerated programs.  While a fullscreen screenshot (as you get from pressing Prnt Scrn) will capture hardware accelerated programs normally, 
(with the possible exception of fullscreen hardware accelerated programs), window only screenshots will be captured incorrectly, or appear as a blank black or white window.  The solution to this is to capture a screenshot post rendering.  Unfortunately, 
while the inbuilt PrintWindow function can do so, the flags required are [undocumented by Microsoft](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-printwindow).  However, they appear to work for Windows 8.1 and above, 
and are documented by [Chromium](https://chromium.googlesource.com/chromium/src.git/+/62.0.3178.1/ui/snapshot/snapshot_win.cc), [Rust](https://microsoft.github.io/windows-docs-rs/doc/windows/Win32/UI/WindowsAndMessaging/constant.PW_RENDERFULLCONTENT.html), and various Github pages. As such, I have chosen to include them in 
AHKv2-Screenshot-Tools, albeit with a warning dialog box in the example scripts.  Obviously this warning can be removed in your own scripts.

Owing to the undocumented nature of rendered screenshots, I would recommend using (the default) unrendered screenshots where possible, but in many cases (all modern browsers, all DirectX programs) it is the only option.

AHKv2-Screenshot_Tools also adds the capability to capture only the client area of a window, in both unrendered and rendered modes.


## Manifest
 - `AHKv2_Screenshotter.ahk`: Example functions to take and save screenshots. Requires either `AHKv2_Screenshot_Tools.ahk` or both of `Gdip_All.ahk` and `Gdip_Screenshot_Tools_Ext.ahk` as libraries
 - `AHKv2_Screenshotter_Quickstart.ahk`: Standalone version of `AHKv2_Screenshotter.ahk` with pre-made hotkeys to quickly take and save various types of screenshot

**Libraries inside folder `lib`:**
 - `AHKv2_Screenshot_Tools.ahk`: Standalone library containing only functions relevent for taking and saving screenshots, includes siginificant code from GDI+
 - `Gdip_All.ahk`: Clone of `Gdip_All.ahk` from ([AHKv2-Gdip])(https://github.com/buliasz/AHKv2-Gdip)
 - `Gdip_Screenshot_Tools_Ext.ahk`: Extension to add AHKv2-Screenshot-Tools' extra screenshot capabilities to GDI+, requires `Gdip_All.ahk`


## Examples
WIP, read comments of quickstart for best current info


## History
- @tic Created the original [Gdip.ahk](https://github.com/tariqporter/Gdip/) library.
- @Rseding91 Updated it to make it compatible with unicode and x64 AHK versions and renamed the file `Gdip_All.ahk`.
- @mmikeww Repository updates @Rseding91's `Gdip_All.ahk` to fix bugs and make it compatible with AHK v2.
- @buliasz Fork of mmikeww repository: updates for the current version of AHK v2 (dropping AHK v1 backward compatibility).
- @Buzzerb Fork of buliasz repository specifically for screenshot functions
