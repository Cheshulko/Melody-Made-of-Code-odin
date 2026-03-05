package main

import "core:fmt"
import "core:os"
import "core:strconv"

import q1 "./quest_1"

main :: proc() {
	defer free_all(context.temp_allocator)

	if len(os.args) < 4 {
		fmt.println("Usage: odin run . -- <quest_number> <quest_part> <input_file_name>")
		fmt.println("Example: odin run . -- 1 1 data.txt")
		return
	}

	quest_num := os.args[1]
	quest_part := os.args[2]
	input_file := os.args[3]

	part, ok := strconv.parse_int(quest_part)
	assert(ok)

	switch quest_num {
	case "1":
		q1.run(part, input_file)
	case:
		fmt.printf("Error: Quest '%s' not found.\n", quest_num)
	}
}
