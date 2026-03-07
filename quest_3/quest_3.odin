package quest_3

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:testing"
import regexp "core:text/regex"

import "../utils"

Socket :: struct {
	colour: string,
	figure: string,
}

Node :: struct {
	id:                int,
	plug:              Socket,
	left_socket:       Socket,
	left_socket_node:  ^Node,
	right_socket:      Socket,
	right_socket_node: ^Node,
}

PATTERN :: `id=(\d+), plug=(\w+) (\w+), leftSocket=(\w+) (\w+), rightSocket=(\w+) (\w+), data=`

parse :: proc(input: string) -> [dynamic]Node {
	lines := strings.split_lines(input)
	defer delete(lines)

	re, err := regexp.create(PATTERN)
	assert(err == nil)
	defer regexp.destroy(re)

	nodes: [dynamic]Node

	for line in lines {
		capture, ok := regexp.match(re, line)
		assert(ok)
		defer regexp.destroy_capture(capture)

		id, id_ok := strconv.parse_int(capture.groups[1])
		assert(id_ok)

		node := Node {
			id = id,
			plug = Socket{colour = capture.groups[2], figure = capture.groups[3]},
			left_socket = Socket{colour = capture.groups[4], figure = capture.groups[5]},
			right_socket = Socket{colour = capture.groups[6], figure = capture.groups[7]},
		}

		append(&nodes, node)
	}

	return nodes
}

connect :: proc(socket1: Socket, socket2: Socket, strong := true) -> bool {
	if strong {
		return socket1 == socket2
	} else {
		return socket1.colour == socket2.colour || socket1.figure == socket2.figure
	}
}

is_weak :: proc(socket1: Socket, socket2: Socket) -> bool {
	return (socket1 != socket2) && connect(socket1, socket2, false)
}

is_strong :: proc(socket1: Socket, socket2: Socket) -> bool {
	return connect(socket1, socket2, true)
}

build :: proc(root: ^Node, to_connect: ^^Node, strong := true, strong_can_break := false) -> bool {
	if root == nil do return false
	if to_connect == nil do return true

	if root^.left_socket_node == nil && connect(to_connect^.plug, root^.left_socket, strong) {
		root^.left_socket_node = to_connect^

		return true
	}

	was_detached := false

	if was_detached = false;
	   strong_can_break &&
	   root^.left_socket_node != nil &&
	   is_weak(root^.left_socket, root^.left_socket_node^.plug) &&
	   is_strong(root^.left_socket, to_connect^.plug) {

		was_detached = true

		detached := root^.left_socket_node
		root^.left_socket_node = to_connect^
		to_connect^ = detached
	}


	if try_deep :=
		   !was_detached && build(root^.left_socket_node, to_connect, strong, strong_can_break);
	   try_deep {
		return true
	}

	if root^.right_socket_node == nil && connect(to_connect^.plug, root^.right_socket, strong) {
		root^.right_socket_node = to_connect^

		return true
	}


	if was_detached = false;
	   strong_can_break &&
	   root^.right_socket_node != nil &&
	   is_weak(root^.right_socket, root^.right_socket_node^.plug) &&
	   is_strong(root^.right_socket, to_connect^.plug) {

		was_detached = true

		detached := root^.right_socket_node
		root^.right_socket_node = to_connect^
		to_connect^ = detached
	}

	if try_deep :=
		   !was_detached && build(root^.right_socket_node, to_connect, strong, strong_can_break);
	   try_deep {
		return true
	}

	return false
}

build_checksum :: proc(root: ^Node, ind: ^int) -> int {
	if root == nil do return 0

	left := build_checksum(root^.left_socket_node, ind)

	cur := ind^ * root^.id
	ind^ += 1

	right := build_checksum(root^.right_socket_node, ind)

	return left + cur + right
}

solve_1 :: proc(input_data: string) -> string {
	nodes := parse(input_data)
	defer delete(nodes)

	for &node, i in nodes[1:] {
		node_ptr := &node
		result := build(&nodes[0], &node_ptr)
		assert(result)
	}

	ind := 1
	checksum := build_checksum(&nodes[0], &ind)

	return fmt.aprint(checksum)
}

solve_2 :: proc(input_data: string) -> string {
	nodes := parse(input_data)
	defer delete(nodes)

	for &node, i in nodes[1:] {
		node_ptr := &node
		result := build(&nodes[0], &node_ptr, false)
		assert(result)
	}

	ind := 1
	checksum := build_checksum(&nodes[0], &ind)

	return fmt.aprint(checksum)
}

solve_3 :: proc(input_data: string) -> string {
	nodes := parse(input_data)
	defer delete(nodes)

	for &node, i in nodes[1:] {
		node_ptr := &node

		for result := false; !result; {
			result = build(&nodes[0], &node_ptr, false, true)
		}
	}

	ind := 1
	checksum := build_checksum(&nodes[0], &ind)

	return fmt.aprint(checksum)
}

run :: proc(quest_part: int, input_file: string) {
	filepath := fmt.tprintf("quest_3/input/part_%d/%s", quest_part, input_file)

	fmt.printf("=== RUNNING QUEST 3 PART %d ===\nLoading file: %s\n\n", quest_part, filepath)

	input := utils.read_input(filepath)
	defer delete(input)

	switch quest_part {
	case 1:
		{
			result := solve_1(input)
			defer delete(result)

			fmt.println(result)
		}
	case 2:
		{
			result := solve_2(input)
			defer delete(result)

			fmt.println(result)
		}
	case 3:
		{
			result := solve_3(input)
			defer delete(result)

			fmt.println(result)
		}
	case:
		fmt.printf("Error: Part '%d' not found.\n", quest_part)
	}
}

@(test)
test_1_sample :: proc(t: ^testing.T) {
	input := utils.read_input("quest_3/input/part_1/input_sample.txt")
	defer delete(input)

	expected := "43"
	result := solve_1(input)
	defer delete(result)

	testing.expect(t, result == expected, fmt.tprint("Expected: %s. Result: %s", expected, result))
}

@(test)
test_1 :: proc(t: ^testing.T) {
	input := utils.read_input("quest_3/input/part_1/input.txt")
	defer delete(input)

	expected := "5878"
	result := solve_1(input)
	defer delete(result)

	testing.expect(t, result == expected, fmt.tprint("Expected: %s. Result: %s", expected, result))
}

@(test)
test_2_sample :: proc(t: ^testing.T) {
	input := utils.read_input("quest_3/input/part_2/input_sample.txt")
	defer delete(input)

	expected := "50"
	result := solve_2(input)
	defer delete(result)

	testing.expect(t, result == expected, fmt.tprint("Expected: %s. Result: %s", expected, result))
}

@(test)
test_2 :: proc(t: ^testing.T) {
	input := utils.read_input("quest_3/input/part_2/input.txt")
	defer delete(input)

	expected := "320153"
	result := solve_2(input)
	defer delete(result)

	testing.expect(t, result == expected, fmt.tprint("Expected: %s. Result: %s", expected, result))
}

@(test)
test_3_sample_1 :: proc(t: ^testing.T) {
	input := utils.read_input("quest_3/input/part_3/input_sample_1.txt")
	defer delete(input)

	expected := "38"
	result := solve_3(input)
	defer delete(result)

	testing.expect(t, result == expected, fmt.tprint("Expected: %s. Result: %s", expected, result))
}

@(test)
test_3_sample_2 :: proc(t: ^testing.T) {
	input := utils.read_input("quest_3/input/part_3/input_sample_2.txt")
	defer delete(input)

	expected := "60"
	result := solve_3(input)
	defer delete(result)

	testing.expect(t, result == expected, fmt.tprint("Expected: %s. Result: %s", expected, result))
}

@(test)
test_3 :: proc(t: ^testing.T) {
	input := utils.read_input("quest_3/input/part_3/input.txt")
	defer delete(input)

	expected := "427241"
	result := solve_3(input)
	defer delete(result)

	testing.expect(t, result == expected, fmt.tprint("Expected: %s. Result: %s", expected, result))
}
