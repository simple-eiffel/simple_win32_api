note
	description: "Test application for simple_win32_api"
	author: "Larry Rix"

class
	WIN32_API_TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run tests.
		local
			tests: WIN32_API_TEST_SET
		do
			create tests
			io.put_string ("simple_win32_api test runner%N")
			io.put_string ("====================================%N%N")

			passed := 0
			failed := 0

			-- API Creation Tests
			io.put_string ("API Creation Tests%N")
			io.put_string ("------------------%N")
			run_test (agent tests.test_create_api, "test_create_api")
			run_test (agent tests.test_win32_alias, "test_win32_alias")

			-- Process Tests
			io.put_string ("%NProcess Tests%N")
			io.put_string ("-------------%N")
			run_test (agent tests.test_execute_command, "test_execute_command")
			run_test (agent tests.test_execute_command_with_exit_code, "test_execute_command_with_exit_code")

			-- Environment Tests
			io.put_string ("%NEnvironment Tests%N")
			io.put_string ("-----------------%N")
			run_test (agent tests.test_get_env, "test_get_env")
			run_test (agent tests.test_has_env, "test_has_env")
			run_test (agent tests.test_set_env, "test_set_env")
			run_test (agent tests.test_expand_env, "test_expand_env")

			-- System Tests
			io.put_string ("%NSystem Tests%N")
			io.put_string ("------------%N")
			run_test (agent tests.test_computer_name, "test_computer_name")
			run_test (agent tests.test_user_name, "test_user_name")
			run_test (agent tests.test_processor_count, "test_processor_count")
			run_test (agent tests.test_memory_info, "test_memory_info")
			run_test (agent tests.test_directories, "test_directories")

			-- Console Tests
			io.put_string ("%NConsole Tests%N")
			io.put_string ("-------------%N")
			run_test (agent tests.test_console_dimensions, "test_console_dimensions")
			run_test (agent tests.test_console_colors, "test_console_colors")

			-- Clipboard Tests
			io.put_string ("%NClipboard Tests%N")
			io.put_string ("---------------%N")
			run_test (agent tests.test_clipboard_set_get, "test_clipboard_set_get")
			run_test (agent tests.test_clipboard_has_text, "test_clipboard_has_text")

			-- Registry Tests
			io.put_string ("%NRegistry Tests%N")
			io.put_string ("--------------%N")
			run_test (agent tests.test_registry_key_exists, "test_registry_key_exists")
			run_test (agent tests.test_registry_root_keys, "test_registry_root_keys")

			-- Factory Tests
			io.put_string ("%NFactory Tests%N")
			io.put_string ("-------------%N")
			run_test (agent tests.test_new_mmap, "test_new_mmap")
			run_test (agent tests.test_new_pipe_server, "test_new_pipe_server")
			run_test (agent tests.test_new_watcher, "test_new_watcher")

			-- Direct Access Tests
			io.put_string ("%NDirect Access Tests%N")
			io.put_string ("-------------------%N")
			run_test (agent tests.test_direct_access_process, "test_direct_access_process")
			run_test (agent tests.test_direct_access_env, "test_direct_access_env")
			run_test (agent tests.test_direct_access_system, "test_direct_access_system")
			run_test (agent tests.test_direct_access_console, "test_direct_access_console")
			run_test (agent tests.test_direct_access_clipboard, "test_direct_access_clipboard")
			run_test (agent tests.test_direct_access_registry, "test_direct_access_registry")

			io.put_string ("%N====================================%N")
			io.put_string ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				io.put_string ("TESTS FAILED%N")
			else
				io.put_string ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Implementation

	passed: INTEGER
	failed: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test and update counters.
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				io.put_string ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			io.put_string ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_retried := True
			retry
		end

end
