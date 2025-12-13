note
	description: "[
		Unified API facade for Win32 operations with SCOOP compatibility.

		Provides single entry point to:
		- Process execution (simple_process)
		- Environment variables (simple_env)
		- System information (simple_system)
		- Console manipulation (simple_console)
		- Clipboard access (simple_clipboard)
		- Windows Registry (simple_registry)
		- Memory-mapped files (simple_mmap)
		- Named pipes IPC (simple_ipc)
		- File system watching (simple_watcher)

		Usage:
			create api.make
			api.execute_command ("dir")
			api.get_env ("PATH")
			api.computer_name
			api.print_colored ("Error", {WIN32_API}.Red)
			api.set_clipboard_text ("Hello")
			api.registry_read_string (HKLM, "SOFTWARE\\MyApp", "Version")
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	WIN32_API

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize Win32 API facade.
		do
			create process_executor.make
			create env_accessor
			create system_info
			create console_manipulator
			create clipboard_accessor
			create registry_accessor
		ensure
			process_ready: process_executor /= Void
			env_ready: env_accessor /= Void
			system_ready: system_info /= Void
			console_ready: console_manipulator /= Void
			clipboard_ready: clipboard_accessor /= Void
			registry_ready: registry_accessor /= Void
		end

feature -- Process Execution

	execute_command (a_command: READABLE_STRING_GENERAL): STRING_32
			-- Execute shell `a_command' and return output.
		require
			command_not_empty: not a_command.is_empty
		do
			process_executor.run (a_command)
			if attached process_executor.last_output as l_output then
				Result := l_output
			else
				create Result.make_empty
			end
		end

	execute_command_with_exit_code (a_command: READABLE_STRING_GENERAL): TUPLE [output: STRING_32; exit_code: INTEGER; success: BOOLEAN]
			-- Execute `a_command' and return output, exit code, and success flag.
		require
			command_not_empty: not a_command.is_empty
		local
			l_output: STRING_32
		do
			process_executor.run (a_command)
			if attached process_executor.last_output as o then
				l_output := o
			else
				create l_output.make_empty
			end
			Result := [l_output, process_executor.last_exit_code, process_executor.was_successful]
		end

	last_exit_code: INTEGER
			-- Exit code from last command execution.
		do
			Result := process_executor.last_exit_code
		end

feature -- Environment Variables

	get_env (a_name: READABLE_STRING_GENERAL): detachable STRING_32
			-- Get environment variable value.
		require
			name_not_empty: not a_name.is_empty
		do
			Result := env_accessor.get (a_name)
		end

	set_env (a_name, a_value: READABLE_STRING_GENERAL)
			-- Set environment variable.
		require
			name_not_empty: not a_name.is_empty
		do
			env_accessor.set (a_name, a_value)
		end

	has_env (a_name: READABLE_STRING_GENERAL): BOOLEAN
			-- Does environment variable exist?
		require
			name_not_empty: not a_name.is_empty
		do
			Result := env_accessor.has (a_name)
		end

	expand_env (a_string: READABLE_STRING_GENERAL): STRING_32
			-- Expand %VAR% references in string.
		require
			string_not_void: a_string /= Void
		do
			Result := env_accessor.expand (a_string)
		end

feature -- System Information

	computer_name: STRING_32
			-- Name of the computer.
		do
			Result := system_info.computer_name
		end

	user_name: STRING_32
			-- Name of the current user.
		do
			Result := system_info.user_name
		end

	processor_count: INTEGER
			-- Number of logical processors.
		do
			Result := system_info.processor_count
		end

	processor_architecture: STRING_32
			-- Processor architecture (x86, x64, ARM64).
		do
			Result := system_info.processor_architecture
		end

	is_64_bit: BOOLEAN
			-- Is the processor 64-bit?
		do
			Result := system_info.is_64_bit
		end

	total_memory_mb: NATURAL_64
			-- Total physical memory in megabytes.
		do
			Result := system_info.total_memory_mb
		end

	total_memory_gb: REAL_64
			-- Total physical memory in gigabytes.
		do
			Result := system_info.total_memory_gb
		end

	available_memory_mb: NATURAL_64
			-- Available physical memory in megabytes.
		do
			Result := system_info.available_memory_mb
		end

	available_memory_gb: REAL_64
			-- Available physical memory in gigabytes.
		do
			Result := system_info.available_memory_gb
		end

	windows_directory: STRING_32
			-- Windows installation directory.
		do
			Result := system_info.windows_directory
		end

	system_directory: STRING_32
			-- System32 directory.
		do
			Result := system_info.system_directory
		end

	temp_directory: STRING_32
			-- Temporary files directory.
		do
			Result := system_info.temp_directory
		end

	os_version_string: STRING_32
			-- Full OS version string (e.g., "10.0.22631").
		do
			Result := system_info.os_version_string
		end

	is_windows_11: BOOLEAN
			-- Is this Windows 11?
		do
			Result := system_info.is_windows_11
		end

feature -- Console Manipulation

	print_colored (a_text: READABLE_STRING_GENERAL; a_color: INTEGER)
			-- Print text in specified color, then reset.
		require
			text_not_void: a_text /= Void
			valid_color: a_color >= 0 and a_color <= 15
		do
			console_manipulator.print_colored (a_text, a_color)
		end

	print_at (a_text: READABLE_STRING_GENERAL; a_x, a_y: INTEGER)
			-- Print text at position.
		require
			text_not_void: a_text /= Void
			valid_x: a_x >= 0
			valid_y: a_y >= 0
		do
			console_manipulator.print_at (a_text, a_x, a_y)
		end

	set_console_title (a_title: READABLE_STRING_GENERAL)
			-- Set console window title.
		require
			title_not_void: a_title /= Void
		do
			console_manipulator.set_title (a_title)
		end

	clear_console
			-- Clear the console screen.
		do
			console_manipulator.clear
		end

	set_cursor_position (a_x, a_y: INTEGER)
			-- Move cursor to position.
		require
			valid_x: a_x >= 0
			valid_y: a_y >= 0
		do
			console_manipulator.set_cursor (a_x, a_y)
		end

	console_width: INTEGER
			-- Console window width in characters.
		do
			Result := console_manipulator.width
		end

	console_height: INTEGER
			-- Console window height in characters.
		do
			Result := console_manipulator.height
		end

feature -- Console Colors

	Black: INTEGER = 0
	Dark_blue: INTEGER = 1
	Dark_green: INTEGER = 2
	Dark_cyan: INTEGER = 3
	Dark_red: INTEGER = 4
	Dark_magenta: INTEGER = 5
	Dark_yellow: INTEGER = 6
	Gray: INTEGER = 7
	Dark_gray: INTEGER = 8
	Blue: INTEGER = 9
	Green: INTEGER = 10
	Cyan: INTEGER = 11
	Red: INTEGER = 12
	Magenta: INTEGER = 13
	Yellow: INTEGER = 14
	White: INTEGER = 15

feature -- Clipboard Access

	clipboard_text: detachable STRING_32
			-- Get text from clipboard.
		do
			Result := clipboard_accessor.text
		end

	set_clipboard_text (a_text: READABLE_STRING_GENERAL)
			-- Set clipboard text.
		require
			text_not_void: a_text /= Void
		do
			clipboard_accessor.set_text (a_text)
		end

	clear_clipboard
			-- Clear clipboard contents.
		do
			clipboard_accessor.clear
		end

	clipboard_has_text: BOOLEAN
			-- Does clipboard contain text?
		do
			Result := clipboard_accessor.has_text
		end

feature -- Registry Access

	registry_read_string (a_hkey: POINTER; a_subkey, a_name: READABLE_STRING_GENERAL): detachable STRING_32
			-- Read string value from registry.
		require
			subkey_not_empty: not a_subkey.is_empty
			name_not_empty: not a_name.is_empty
		do
			Result := registry_accessor.read_string (a_hkey, a_subkey, a_name)
		end

	registry_write_string (a_hkey: POINTER; a_subkey, a_name, a_value: READABLE_STRING_GENERAL)
			-- Write string value to registry.
		require
			subkey_not_empty: not a_subkey.is_empty
			name_not_empty: not a_name.is_empty
		do
			registry_accessor.write_string (a_hkey, a_subkey, a_name, a_value)
		end

	registry_read_dword (a_hkey: POINTER; a_subkey, a_name: READABLE_STRING_GENERAL): INTEGER
			-- Read DWORD value from registry.
		require
			subkey_not_empty: not a_subkey.is_empty
			name_not_empty: not a_name.is_empty
		do
			Result := registry_accessor.read_integer (a_hkey, a_subkey, a_name)
		end

	registry_write_dword (a_hkey: POINTER; a_subkey, a_name: READABLE_STRING_GENERAL; a_value: INTEGER)
			-- Write DWORD value to registry.
		require
			subkey_not_empty: not a_subkey.is_empty
			name_not_empty: not a_name.is_empty
		do
			registry_accessor.write_integer (a_hkey, a_subkey, a_name, a_value)
		end

	registry_key_exists (a_hkey: POINTER; a_subkey: READABLE_STRING_GENERAL): BOOLEAN
			-- Does registry key exist?
		require
			subkey_not_empty: not a_subkey.is_empty
		do
			Result := registry_accessor.key_exists (a_hkey, a_subkey)
		end

	registry_value_exists (a_hkey: POINTER; a_subkey, a_name: READABLE_STRING_GENERAL): BOOLEAN
			-- Does registry value exist?
		require
			subkey_not_empty: not a_subkey.is_empty
			name_not_empty: not a_name.is_empty
		do
			Result := registry_accessor.value_exists (a_hkey, a_subkey, a_name)
		end

feature -- Registry Root Keys

	HKEY_CLASSES_ROOT: POINTER
		do
			Result := registry_accessor.HKEY_CLASSES_ROOT
		end

	HKEY_CURRENT_USER: POINTER
		do
			Result := registry_accessor.HKEY_CURRENT_USER
		end

	HKEY_LOCAL_MACHINE: POINTER
		do
			Result := registry_accessor.HKEY_LOCAL_MACHINE
		end

	HKEY_USERS: POINTER
		do
			Result := registry_accessor.HKEY_USERS
		end

	HKCR: POINTER do Result := HKEY_CLASSES_ROOT end
	HKCU: POINTER do Result := HKEY_CURRENT_USER end
	HKLM: POINTER do Result := HKEY_LOCAL_MACHINE end
	HKU: POINTER do Result := HKEY_USERS end

feature -- Factory: Memory-Mapped Files

	new_mmap (a_name: READABLE_STRING_GENERAL; a_size: INTEGER): SIMPLE_MMAP
			-- Create a new shared memory-mapped region.
		require
			name_not_empty: not a_name.is_empty
			valid_size: a_size > 0
		do
			create Result.make_shared (a_name, a_size)
		ensure
			created: Result /= Void
		end

	open_mmap (a_name: READABLE_STRING_GENERAL): SIMPLE_MMAP
			-- Open an existing shared memory-mapped region.
		require
			name_not_empty: not a_name.is_empty
		do
			create Result.open_shared (a_name)
		ensure
			created: Result /= Void
		end

feature -- Factory: IPC (Named Pipes)

	new_pipe_server (a_name: READABLE_STRING_GENERAL): SIMPLE_IPC
			-- Create a new named pipe server.
		require
			name_not_empty: not a_name.is_empty
		do
			create Result.make_server (a_name)
		ensure
			created: Result /= Void
		end

	new_pipe_client (a_name: READABLE_STRING_GENERAL): SIMPLE_IPC
			-- Create a new named pipe client.
		require
			name_not_empty: not a_name.is_empty
		do
			create Result.make_client (a_name)
		ensure
			created: Result /= Void
		end

feature -- Factory: File System Watcher

	new_watcher (a_path: READABLE_STRING_GENERAL; a_recursive: BOOLEAN; a_flags: INTEGER): SIMPLE_WATCHER
			-- Create a new file system watcher.
		require
			path_not_empty: not a_path.is_empty
		do
			create Result.make (a_path, a_recursive, a_flags)
		ensure
			created: Result /= Void
		end

	new_watcher_all (a_path: READABLE_STRING_GENERAL; a_recursive: BOOLEAN): SIMPLE_WATCHER
			-- Create a new file system watcher monitoring all change types.
		require
			path_not_empty: not a_path.is_empty
		do
			create Result.make (a_path, a_recursive, {SIMPLE_WATCHER}.Watch_all)
		ensure
			created: Result /= Void
		end

feature -- Watch Flags

	Watch_file_name: INTEGER = 0x0001
	Watch_dir_name: INTEGER = 0x0002
	Watch_attributes: INTEGER = 0x0004
	Watch_size: INTEGER = 0x0008
	Watch_last_write: INTEGER = 0x0010
	Watch_security: INTEGER = 0x0020
	Watch_all: INTEGER = 0x003F

feature -- Direct Access

	process: SIMPLE_PROCESS
			-- Direct access to process executor.
		do
			Result := process_executor
		end

	env: SIMPLE_ENV
			-- Direct access to environment accessor.
		do
			Result := env_accessor
		end

	system: SIMPLE_SYSTEM
			-- Direct access to system information.
		do
			Result := system_info
		end

	console: SIMPLE_CONSOLE
			-- Direct access to console manipulator.
		do
			Result := console_manipulator
		end

	clipboard: SIMPLE_CLIPBOARD
			-- Direct access to clipboard accessor.
		do
			Result := clipboard_accessor
		end

	registry: SIMPLE_REGISTRY
			-- Direct access to registry accessor.
		do
			Result := registry_accessor
		end

feature {NONE} -- Implementation

	process_executor: SIMPLE_PROCESS
			-- Process execution engine.

	env_accessor: SIMPLE_ENV
			-- Environment variable accessor.

	system_info: SIMPLE_SYSTEM
			-- System information provider.

	console_manipulator: SIMPLE_CONSOLE
			-- Console manipulation engine.

	clipboard_accessor: SIMPLE_CLIPBOARD
			-- Clipboard access engine.

	registry_accessor: SIMPLE_REGISTRY
			-- Registry access engine.

invariant
	process_exists: process_executor /= Void
	env_exists: env_accessor /= Void
	system_exists: system_info /= Void
	console_exists: console_manipulator /= Void
	clipboard_exists: clipboard_accessor /= Void
	registry_exists: registry_accessor /= Void

end
