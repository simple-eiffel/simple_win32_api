# simple_win32_api

![simple_* logo](docs/images/logo.png)

**Unified Win32 API Library for Eiffel Projects**

[Documentation](https://simple-eiffel.github.io/simple_win32_api/) | [GitHub](https://github.com/simple-eiffel/simple_win32_api)

## Overview

`simple_win32_api` is a unified facade that bundles all Win32 wrapper libraries for SCOOP-compatible Windows programming in Eiffel. Instead of managing multiple library dependencies, use a single `WIN32_API` class that provides access to processes, environment variables, system information, console manipulation, clipboard, registry, memory-mapped files, IPC, and file system monitoring.

## Features

- **Process** - Execute shell commands and capture output
- **Environment** - Get, set, and expand environment variables
- **System** - Query CPU, memory, OS version, and directories
- **Console** - Colors, cursor control, screen operations
- **Clipboard** - Read and write clipboard text
- **Registry** - Read and write Windows Registry values
- **Memory-Mapped Files** - Shared memory between processes
- **IPC** - Named pipes for inter-process communication
- **File Watcher** - Monitor file system changes in real-time

## Dependencies

This library bundles the following simple_* libraries:

| Library | Purpose | Environment Variable |
|---------|---------|---------------------|
| [simple_process](https://github.com/simple-eiffel/simple_process) | Process execution | `$SIMPLE_PROCESS` |
| [simple_env](https://github.com/simple-eiffel/simple_env) | Environment variables | `$SIMPLE_ENV` |
| [simple_system](https://github.com/simple-eiffel/simple_system) | System information | `$SIMPLE_SYSTEM` |
| [simple_console](https://github.com/simple-eiffel/simple_console) | Console manipulation | `$SIMPLE_CONSOLE` |
| [simple_clipboard](https://github.com/simple-eiffel/simple_clipboard) | Clipboard access | `$SIMPLE_CLIPBOARD` |
| [simple_registry](https://github.com/simple-eiffel/simple_registry) | Windows Registry | `$SIMPLE_REGISTRY` |
| [simple_mmap](https://github.com/simple-eiffel/simple_mmap) | Memory-mapped files | `$SIMPLE_MMAP` |
| [simple_ipc](https://github.com/simple-eiffel/simple_ipc) | Named pipes IPC | `$SIMPLE_IPC` |
| [simple_watcher](https://github.com/simple-eiffel/simple_watcher) | File system monitoring | `$SIMPLE_WATCHER` |

## Installation

1. Clone all required repositories
2. Set environment variables for each library
3. Add to your ECF:

```xml
<library name="simple_win32_api"
        location="$SIMPLE_WIN32_API\simple_win32_api.ecf"/>
```

## Quick Start

```eiffel
local
    api: WIN32_API
do
    create api.make

    -- Execute commands
    print (api.execute_command ("dir"))

    -- Environment variables
    if attached api.get_env ("PATH") as path then
        print (path)
    end

    -- System information
    print ("Computer: " + api.computer_name + "%N")
    print ("User: " + api.user_name + "%N")
    print ("CPUs: " + api.processor_count.out + "%N")
    print ("RAM: " + api.total_memory_gb.out + " GB%N")

    -- Console colors
    api.print_colored ("Error: ", api.Red)
    print ("Something went wrong%N")

    -- Clipboard
    api.set_clipboard_text ("Hello from Eiffel!")
    if attached api.clipboard_text as t then
        print ("Clipboard: " + t + "%N")
    end

    -- Registry
    if attached api.registry_read_string (api.HKLM, "SOFTWARE\Microsoft\Windows NT\CurrentVersion", "ProductName") as product then
        print ("OS: " + product + "%N")
    end

    -- Memory-mapped file
    if attached api.new_mmap ("MySharedMem", 4096) as mmap then
        if mmap.is_valid then
            mmap.write_string ("Hello")
            mmap.close
        end
    end

    -- File watcher
    if attached api.new_watcher_all ("C:\MyFolder", True) as watcher then
        if watcher.is_valid then
            watcher.start
            -- Poll for events...
            watcher.close
        end
    end
end
```

## API Summary

### Process Execution
- `execute_command (cmd)` - Execute command and return output
- `execute_command_with_exit_code (cmd)` - Get output, exit code, and success flag
- `last_exit_code` - Exit code from last execution

### Environment Variables
- `get_env (name)` - Get variable value
- `set_env (name, value)` - Set variable
- `has_env (name)` - Check if variable exists
- `expand_env (string)` - Expand %VAR% references

### System Information
- `computer_name`, `user_name`
- `processor_count`, `processor_architecture`, `is_64_bit`
- `total_memory_mb`, `available_memory_mb`, `total_memory_gb`, `available_memory_gb`
- `windows_directory`, `system_directory`, `temp_directory`
- `os_version_string`, `is_windows_11`

### Console Manipulation
- `print_colored (text, color)` - Print colored text
- `print_at (text, x, y)` - Print at position
- `set_console_title (title)` - Set window title
- `clear_console` - Clear screen
- `set_cursor_position (x, y)` - Move cursor
- `console_width`, `console_height` - Get dimensions
- Color constants: `Black`, `Red`, `Green`, `Blue`, `Yellow`, `White`, etc.

### Clipboard Access
- `clipboard_text` - Get text from clipboard
- `set_clipboard_text (text)` - Set clipboard text
- `clear_clipboard` - Clear clipboard
- `clipboard_has_text` - Check if has text

### Registry Access
- `registry_read_string (hkey, subkey, name)` - Read string value
- `registry_write_string (hkey, subkey, name, value)` - Write string
- `registry_read_dword`, `registry_write_dword` - DWORD values
- `registry_key_exists`, `registry_value_exists` - Check existence
- Root keys: `HKLM`, `HKCU`, `HKCR`, `HKU`

### Factory Methods
- `new_mmap (name, size)` - Create memory-mapped file
- `open_mmap (name)` - Open existing mmap
- `new_pipe_server (name)` - Create named pipe server
- `new_pipe_client (name)` - Create named pipe client
- `new_watcher (path, recursive, flags)` - Create file watcher
- `new_watcher_all (path, recursive)` - Watch all change types

### Direct Access
For advanced operations, access underlying libraries directly:
- `process` - SIMPLE_PROCESS
- `env` - SIMPLE_ENV
- `system` - SIMPLE_SYSTEM
- `console` - SIMPLE_CONSOLE
- `clipboard` - SIMPLE_CLIPBOARD
- `registry` - SIMPLE_REGISTRY

## License

MIT License - see LICENSE file for details.

## Author

Larry Rix
