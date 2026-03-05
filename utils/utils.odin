package utils

import "core:fmt"
import "core:os"

read_input :: proc(filepath: string) -> string {
	data, err := os.read_entire_file(filepath, context.allocator)
	if err != os.ERROR_NONE {
		fmt.eprintf("Error: Could not read file '%s'\n", filepath)

		os.exit(1)
	}

	return string(data)
}
