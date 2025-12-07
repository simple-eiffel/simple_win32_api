note
	description: "Test set for simple_win32_api"
	author: "Larry Rix"

class
	WIN32_API_TEST_SET

inherit
	TEST_SET_BASE

feature -- API Creation Tests

	test_create_api
			-- Test that WIN32_API can be created.
		local
			api: WIN32_API
		do
			create api.make
			assert ("api_created", api /= Void)
		end

	test_win32_alias
			-- Test that WIN32 alias works.
		local
			api: WIN32
		do
			create api.make
			assert ("alias_works", api /= Void)
		end

feature -- Process Tests

	test_execute_command
			-- Test command execution.
		local
			api: WIN32_API
			output: STRING_32
		do
			create api.make
			output := api.execute_command ("echo Hello")
			assert ("has_output", output /= Void and then not output.is_empty)
			assert ("correct_output", output.has_substring ("Hello"))
		end

	test_execute_command_with_exit_code
			-- Test command execution with exit code.
		local
			api: WIN32_API
			result_tuple: TUPLE [output: STRING_32; exit_code: INTEGER; success: BOOLEAN]
		do
			create api.make
			result_tuple := api.execute_command_with_exit_code ("echo Test")
			assert ("has_output", result_tuple.output /= Void)
			assert ("success", result_tuple.success)
			assert ("exit_zero", result_tuple.exit_code = 0)
		end

feature -- Environment Tests

	test_get_env
			-- Test getting environment variable.
		local
			api: WIN32_API
			path: detachable STRING_32
		do
			create api.make
			path := api.get_env ("PATH")
			assert ("path_exists", path /= Void)
			assert ("path_not_empty", attached path as p and then not p.is_empty)
		end

	test_has_env
			-- Test checking environment variable existence.
		local
			api: WIN32_API
		do
			create api.make
			assert ("path_exists", api.has_env ("PATH"))
			assert ("fake_not_exists", not api.has_env ("NONEXISTENT_VAR_12345"))
		end

	test_set_env
			-- Test setting environment variable.
		local
			api: WIN32_API
		do
			create api.make
			api.set_env ("WIN32_API_TEST", "test_value")
			assert ("value_set", attached api.get_env ("WIN32_API_TEST") as v and then v.same_string ("test_value"))
		end

	test_expand_env
			-- Test environment string expansion.
		local
			api: WIN32_API
			expanded_str: STRING_32
		do
			create api.make
			expanded_str := api.expand_env ("%%USERPROFILE%%")
			assert ("expanded", not expanded_str.has_substring ("%%"))
		end

feature -- System Tests

	test_computer_name
			-- Test getting computer name.
		local
			api: WIN32_API
			name: STRING_32
		do
			create api.make
			name := api.computer_name
			assert ("has_name", name /= Void and then not name.is_empty)
		end

	test_user_name
			-- Test getting user name.
		local
			api: WIN32_API
			name: STRING_32
		do
			create api.make
			name := api.user_name
			assert ("has_name", name /= Void and then not name.is_empty)
		end

	test_processor_count
			-- Test getting processor count.
		local
			api: WIN32_API
		do
			create api.make
			assert ("has_processors", api.processor_count >= 1)
		end

	test_memory_info
			-- Test getting memory info.
		local
			api: WIN32_API
		do
			create api.make
			assert ("has_total_memory", api.total_memory_mb > 0)
			assert ("has_available_memory", api.available_memory_mb > 0)
			assert ("total_gb_positive", api.total_memory_gb > 0.0)
			assert ("available_le_total", api.available_memory_mb <= api.total_memory_mb)
		end

	test_directories
			-- Test getting system directories.
		local
			api: WIN32_API
		do
			create api.make
			assert ("windows_dir", api.windows_directory /= Void and then not api.windows_directory.is_empty)
			assert ("system_dir", api.system_directory /= Void and then not api.system_directory.is_empty)
			assert ("temp_dir", api.temp_directory /= Void and then not api.temp_directory.is_empty)
		end

feature -- Console Tests

	test_console_dimensions
			-- Test getting console dimensions.
		local
			api: WIN32_API
		do
			create api.make
			-- Console dimensions may be 0 if not a real console
			assert ("width_non_negative", api.console_width >= 0)
			assert ("height_non_negative", api.console_height >= 0)
		end

	test_console_colors
			-- Test console color constants.
		local
			api: WIN32_API
		do
			create api.make
			assert ("black_is_0", api.Black = 0)
			assert ("white_is_15", api.White = 15)
			assert ("red_is_12", api.Red = 12)
			assert ("green_is_10", api.Green = 10)
			assert ("blue_is_9", api.Blue = 9)
		end

feature -- Clipboard Tests

	test_clipboard_set_get
			-- Test setting and getting clipboard text.
		local
			api: WIN32_API
			test_text: STRING
		do
			test_text := "Win32 API Test"
			create api.make
			api.set_clipboard_text (test_text)
			assert ("text_set", attached api.clipboard_text as t and then t.same_string (test_text))
		end

	test_clipboard_has_text
			-- Test checking if clipboard has text.
		local
			api: WIN32_API
		do
			create api.make
			api.set_clipboard_text ("test")
			assert ("has_text", api.clipboard_has_text)
		end

feature -- Registry Tests

	test_registry_key_exists
			-- Test checking if registry key exists.
		local
			api: WIN32_API
		do
			create api.make
			-- SOFTWARE key should always exist in HKLM
			assert ("software_exists", api.registry_key_exists (api.HKLM, "SOFTWARE"))
		end

	test_registry_root_keys
			-- Test that root key constants are accessible.
		local
			api: WIN32_API
		do
			create api.make
			assert ("hklm_accessible", api.HKLM /= default_pointer)
			assert ("hkcu_accessible", api.HKCU /= default_pointer)
			assert ("hkcr_accessible", api.HKCR /= default_pointer)
			assert ("hku_accessible", api.HKU /= default_pointer)
		end

feature -- Factory Tests

	test_new_mmap
			-- Test creating memory-mapped file.
		local
			api: WIN32_API
			mmap: SIMPLE_MMAP
		do
			create api.make
			mmap := api.new_mmap ("Win32ApiTestMmap", 4096)
			assert ("mmap_created", mmap /= Void)
			if mmap.is_valid then
				mmap.close
			end
		end

	test_new_pipe_server
			-- Test creating pipe server.
		local
			api: WIN32_API
			server: SIMPLE_IPC
		do
			create api.make
			server := api.new_pipe_server ("Win32ApiTestPipe")
			assert ("server_created", server /= Void)
			server.close
		end

	test_new_watcher
			-- Test creating file watcher.
		local
			api: WIN32_API
			watcher: SIMPLE_WATCHER
		do
			create api.make
			watcher := api.new_watcher_all (api.temp_directory, False)
			assert ("watcher_created", watcher /= Void)
			if watcher.is_valid then
				watcher.close
			end
		end

feature -- Direct Access Tests

	test_direct_access_process
			-- Test direct access to process executor.
		local
			api: WIN32_API
		do
			create api.make
			assert ("process_accessible", api.process /= Void)
		end

	test_direct_access_env
			-- Test direct access to environment accessor.
		local
			api: WIN32_API
		do
			create api.make
			assert ("env_accessible", api.env /= Void)
		end

	test_direct_access_system
			-- Test direct access to system info.
		local
			api: WIN32_API
		do
			create api.make
			assert ("system_accessible", api.system /= Void)
		end

	test_direct_access_console
			-- Test direct access to console manipulator.
		local
			api: WIN32_API
		do
			create api.make
			assert ("console_accessible", api.console /= Void)
		end

	test_direct_access_clipboard
			-- Test direct access to clipboard accessor.
		local
			api: WIN32_API
		do
			create api.make
			assert ("clipboard_accessible", api.clipboard /= Void)
		end

	test_direct_access_registry
			-- Test direct access to registry accessor.
		local
			api: WIN32_API
		do
			create api.make
			assert ("registry_accessible", api.registry /= Void)
		end

end
