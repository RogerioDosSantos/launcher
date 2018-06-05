# Main

```bash
main --<command> [<command_options>]
```
 
## Commands:

`--help (h)` : Display this command help

`--log_enable (-le)` : Enable log

`--show_log (-ls)` : Enable log and show it

`--log_level (-ll) <level>` : Define the Log Level (Default: ${config_log_level})

`--log_type (-lt) <type>` : Define the Log Type [Options: all, error, warning, info]

`--setup (-s)` : Allow the user to setup its machine by exporting the *runner*.

`--serve (-se)` : Start the container and let it running indefinitely.

`--debug (-d)` : Save the build script and runner the debug file prior running it.

`--build_script (-bs) <name> <out_path>` : Build a script and return the value on the screen or on a file.

`--run_script (-rs) <name> [<commands>...]` : Build and Run Script.

`--run_test (-rt) <test_name>` : Run unit test. You can use test file or test function. E.g.: -rt json_tests

`--docker_execute (-de) [<commands>...]` : Enter the docker machine on the bash command.

`--get_activity (-ga)` : Get the activity of an execution. 
