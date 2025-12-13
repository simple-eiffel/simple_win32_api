note
	description: "Tests for SIMPLE_WIN32_API"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	testing: "covers"

class
	LIB_TESTS

inherit
	TEST_SET_BASE

feature -- Test: API Creation

	test_api_make
			-- Test Win32 API facade creation.
		note
			testing: "covers/{WIN32_API}.make"
		local
			api: WIN32_API
		do
			create api.make
			assert_attached ("api created", api)
		end

feature -- Test: Process Execution

	test_execute_command
			-- Test executing shell command.
		note
			testing: "covers/{WIN32_API}.execute_command"
			testing: "execution/isolated"
		local
			api: WIN32_API
			output: STRING_32
		do
			create api.make
			output := api.execute_command ("cmd /c echo Hello")
			assert_false ("has output", output.is_empty)
			assert_string_contains ("contains hello", output, "Hello")
		end

	test_execute_command_with_exit_code
			-- Test executing command with exit code.
		note
			testing: "covers/{WIN32_API}.execute_command_with_exit_code"
			testing: "execution/isolated"
		local
			api: WIN32_API
			l_result: TUPLE [output: STRING_32; exit_code: INTEGER; success: BOOLEAN]
		do
			create api.make
			l_result := api.execute_command_with_exit_code ("cmd /c echo OK")
			assert_true ("success", l_result.success)
			assert_integers_equal ("exit code", 0, l_result.exit_code)
		end

feature -- Test: Environment Variables

	test_get_env
			-- Test getting environment variable.
		note
			testing: "covers/{WIN32_API}.get_env"
		local
			api: WIN32_API
		do
			create api.make
			if attached api.get_env ("PATH") as l_path then
				assert_false ("PATH not empty", l_path.is_empty)
			else
				assert_true ("PATH should exist", False)
			end
		end

	test_has_env
			-- Test checking environment variable exists.
		note
			testing: "covers/{WIN32_API}.has_env"
		local
			api: WIN32_API
		do
			create api.make
			assert_true ("PATH exists", api.has_env ("PATH"))
			assert_false ("random not exists", api.has_env ("UNLIKELY_VAR_NAME_XYZ123"))
		end

feature -- Test: System Information

	test_computer_name
			-- Test getting computer name.
		note
			testing: "covers/{WIN32_API}.computer_name"
		local
			api: WIN32_API
		do
			create api.make
			assert_false ("has computer name", api.computer_name.is_empty)
		end

	test_user_name
			-- Test getting user name.
		note
			testing: "covers/{WIN32_API}.user_name"
		local
			api: WIN32_API
		do
			create api.make
			assert_false ("has user name", api.user_name.is_empty)
		end

	test_windows_directory
			-- Test getting Windows directory.
		note
			testing: "covers/{WIN32_API}.windows_directory"
		local
			api: WIN32_API
		do
			create api.make
			assert_string_contains ("has windows", api.windows_directory.as_lower, "windows")
		end

feature -- Test: Clipboard

	test_clipboard_text
			-- Test clipboard text operations.
		note
			testing: "covers/{WIN32_API}.set_clipboard_text"
			testing: "covers/{WIN32_API}.clipboard_text"
			testing: "execution/isolated"
		local
			api: WIN32_API
		do
			create api.make
			api.set_clipboard_text ("Test clipboard")
			if attached api.clipboard_text as l_text then
				assert_strings_equal ("clipboard text", "Test clipboard", l_text)
			else
				assert_true ("clipboard should have text", False)
			end
		end

feature -- Test: Registry

	test_registry_key_exists
			-- Test checking registry key exists.
		note
			testing: "covers/{WIN32_API}.registry_key_exists"
		local
			api: WIN32_API
		do
			create api.make
			-- HKEY_LOCAL_MACHINE\SOFTWARE should always exist
			assert_true ("software key exists", api.registry_key_exists (api.HKLM, "SOFTWARE"))
		end

end
