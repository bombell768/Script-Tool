# SwiftUI Script Runner

## Overview

This is a macOS desktop application built using **SwiftUI** with **AppKit** integration. It allows users to write and execute Swift scripts within a simple and modern GUI. The tool displays script output live during execution, shows errors, highlights keywords, and provides a clear indication of script execution status.

## Features

- Split view layout:  
  - **Editor Pane** for writing Swift scripts.  
  - **Output Pane** for live output and error messages.

- Scripts are executed using:  
  `/usr/bin/env swift foo.swift`

- Live display of standard output and standard error during script execution.

- Execution indicators:
  - **Running Status**
  - **Exit Code Indicator** 

- Basic syntax highlighting of Swift language keywords.

## Screenshot

![App Screenshot](Screenshots/main_view.png)


## Requirements

- macOS 15.2+
- Xcode 16.3+
- Swift 6.1+

## Building & Running the App

   ```bash
   git clone https://github.com/bombell768/Script-Tool.git
   open Script-Tool/ScriptExec.xcodeproj

