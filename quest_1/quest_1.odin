package quest_1

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:testing"
import "core:unicode"

import "../utils"

Component :: enum {
	Red,
	Green,
	Blue,
	Shine,
}

Colour :: struct {
	r, g, b, s: int,
}

set_component :: proc(colour: ^Colour, component: Component, value: int) {
	switch component {
	case .Red:
		colour.r = value
	case .Green:
		colour.g = value
	case .Blue:
		colour.b = value
	case .Shine:
		colour.s = value
	}
}

build_colour :: proc(row: ^string) -> Colour {
	colour: Colour = {}

	index := 0
	for channels in strings.split_iterator(row, " ") {
		rate := 0
		pow := 1
		#reverse for channel in channels {
			if unicode.is_upper(channel) {
				rate += pow
			}
			pow <<= 1
		}
		set_component(&colour, Component(index), rate)
		index += 1
	}

	return colour
}

solve_1 :: proc(input_data: string) -> string {
	lines := strings.split_lines(input_data)
	defer delete(lines)

	sum := 0
	for line in lines {
		row := strings.split_n(line, ":", 2)
		defer delete(row)

		colour := build_colour(&row[1])
		red := colour.r
		green := colour.g
		blue := colour.b

		if green > red && green > blue {
			scale, ok := strconv.parse_int(row[0])
			assert(ok)

			sum += scale
		}

	}

	return fmt.aprint(sum)
}

solve_2 :: proc(input_data: string) -> string {
	lines := strings.split_lines(input_data)
	defer delete(lines)

	max_shine := -1
	colour_sum := 0
	ans := 0
	for line in lines {
		row := strings.split_n(line, ":", 2)
		defer delete(row)

		colour := build_colour(&row[1])
		red := colour.r
		green := colour.g
		blue := colour.b
		shine := colour.s

		if shine > max_shine {
			scale, ok := strconv.parse_int(row[0])
			assert(ok)

			colour_sum = red + green + blue
			ans = scale
			max_shine = shine
		} else if shine == max_shine {
			new_colour_sum := red + green + blue

			if new_colour_sum < colour_sum {
				scale, ok := strconv.parse_int(row[0])
				assert(ok)

				colour_sum = new_colour_sum
				ans = scale
			}

		}
	}

	return fmt.aprint(ans)
}

solve_3 :: proc(input_data: string) -> string {
	lines := strings.split_lines(input_data)
	defer delete(lines)

	COLOURS :: 3
	SHINES :: 2
	groups: [COLOURS][SHINES][dynamic]int
	defer {
		for i in 0 ..< COLOURS {
			for j in 0 ..< SHINES {
				delete(groups[i][j])
			}
		}
	}

	MIN_SHINE :: 30
	MAX_SHINE :: 33
	for line in lines {
		row := strings.split_n(line, ":", 2)
		defer delete(row)

		colour := build_colour(&row[1])
		red := colour.r
		green := colour.g
		blue := colour.b
		shine := colour.s

		if shine > MIN_SHINE && shine < MAX_SHINE {
			continue
		}

		ma := max(red, green, blue)
		channels := [3]int{red, green, blue}

		cnt := 0
		for c in channels {
			if c == ma {
				cnt += 1
			}
		}
		if cnt != 1 {
			continue
		}


		for c, i in channels {
			if c == ma {
				scale, ok := strconv.parse_int(row[0])
				assert(ok)

				shiny := 0
				if shine >= MAX_SHINE {
					shiny = 1
				}

				append(&groups[i][shiny], scale)

				break
			}
		}
	}

	ans := 0
	max_group := 0
	for i in 0 ..< COLOURS {
		for j in 0 ..< SHINES {
			if len(groups[i][j]) > max_group {
				max_group = len(groups[i][j])

				sum := 0
				for scale in groups[i][j] {
					sum += scale
				}
				ans = sum
			}
		}
	}

	return fmt.aprint(ans)
}

run :: proc(quest_part: int, input_file: string) {
	filepath := fmt.tprintf("quest_1/input/part_%d/%s", quest_part, input_file)

	fmt.printf("=== RUNNING QUEST 1 PART %d ===\nLoading file: %s\n\n", quest_part, filepath)

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
	input := utils.read_input("quest_1/input/part_1/input_sample.txt")
	defer delete(input)

	expected := "9166"
	result := solve_1(input)
	defer delete(result)

	testing.expect(t, result == expected, fmt.tprint("Expected: %s. Result: %s", expected, result))
}

@(test)
test_1 :: proc(t: ^testing.T) {
	input := utils.read_input("quest_1/input/part_1/input.txt")
	defer delete(input)

	expected := "70165"
	result := solve_1(input)
	defer delete(result)

	testing.expect(t, result == expected, fmt.tprint("Expected: %s. Result: %s", expected, result))
}

@(test)
test_2_sample :: proc(t: ^testing.T) {
	input := utils.read_input("quest_1/input/part_2/input_sample.txt")
	defer delete(input)

	expected := "2456"
	result := solve_2(input)
	defer delete(result)

	testing.expect(t, result == expected, fmt.tprint("Expected: %s. Result: %s", expected, result))
}

@(test)
test_2 :: proc(t: ^testing.T) {
	input := utils.read_input("quest_1/input/part_2/input.txt")
	defer delete(input)

	expected := "59369"
	result := solve_2(input)
	defer delete(result)

	testing.expect(t, result == expected, fmt.tprint("Expected: %s. Result: %s", expected, result))
}

@(test)
test_3_sample :: proc(t: ^testing.T) {
	input := utils.read_input("quest_1/input/part_3/input_sample.txt")
	defer delete(input)

	expected := "292320"
	result := solve_3(input)
	defer delete(result)

	testing.expect(t, result == expected, fmt.tprint("Expected: %s. Result: %s", expected, result))
}

@(test)
test_3 :: proc(t: ^testing.T) {
	input := utils.read_input("quest_1/input/part_3/input.txt")
	defer delete(input)

	expected := "10443300"
	result := solve_3(input)
	defer delete(result)

	testing.expect(t, result == expected, fmt.tprint("Expected: %s. Result: %s", expected, result))
}
