# AHKv2-Screenshotter
This repository contains extensions to the GDI+ library ('Gdip_All.ahk') designed to assist in taking screenshots with pure AHKv2
It also contains various functions to easily take and save common types of screenshot using the above GDI+ and extensions
A trimmed version of Gdip_All.ahk with only the functions relevant for screenshots, plus extensions, is included.

Compatible with the current [AutoHotKey v2](https://autohotkey.com/v2/).
Support for AHK v1 is dropped.

This repository is based heavily on the version of GDI+ for AHKv2 by buliasz [(AHKv2-Gdip)](https://github.com/buliasz/AHKv2-Gdip). It is inspired by and draws some code from Cruncher1's [Screen capture script for AHKv1](https://www.autohotkey.com/board/topic/91585-screen-capture-using-only-ahk-no-3rd-party-software-required/).

See the [commit history](https://github.com/Buzzerb/AHKv2-Gdip-Screenshotter/commits/master) to see the changes made.

#Quickstart:
Download and run 'AHKv2_Screenshotter_quickstart.ahk'
It will create a folder in the script's directory entitled screenshots if one does not already exist
To take screenshots, press Ctrl + Alt and one of:
s: Whole screen capture
a: Active window capture
c: Active window client area capture
r: Rendered active window capture (see comments in file for more details, only supported unofficially)
w: Rendered active window client area capture (see comments in file for more details, only supported unofficially)
Screenshots will be saved to the screenshot folder in the script directory


# Manifest:
'Gdip_All.ahk': Clone of 'Gdip_All.ahk' from [(AHKv2-Gdip)](https://github.com/buliasz/AHKv2-Gdip)
'Gdip_screenshot_ext.ahk': Extra functions that extend GDI+ specifically for taking screenshots
'Gdip_trimmed_screenshot_tools.ahk': Trimmed version of 'Gdip_All.ahk' with only functions relevent for taking and saving screenshots included, plus the extensions in the above file
'AHKv2_Screenshotter.ahk': Example functions to take and save screenshots. Requires either 'Gdip_trimmed_screenshot_tools.ahk' or both of 'Gdip_All.ahk' and 'Gdip_screenshot_ext.ahk'
'AHKv2_Screenshotter_quickstart.ahk': Self-contained script for easy taking and saving of various types of screenshot

# Retained GDI+ Functions related to screenshots:
WIP, read comments of quickstart for best current info

# Examples
WIP, read comments of quickstart for best current info

# History
- @tic Created the original [Gdip.ahk](https://github.com/tariqporter/Gdip/) library.
- @Rseding91 Updated it to make it compatible with unicode and x64 AHK versions and renamed the file `Gdip_All.ahk`.
- @mmikeww Repository updates @Rseding91's `Gdip_All.ahk` to fix bugs and make it compatible with AHK v2.
- @buliasz Fork of mmikeww repository: updates for the current version of AHK v2 (dropping AHK v1 backward compatibility).
- @Buzzerb Fork of buliasz specifically for screenshot functions
