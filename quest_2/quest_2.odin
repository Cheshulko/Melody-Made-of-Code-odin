package quest_2

import "core:fmt"
import "core:strings"
import "core:testing"

import "../utils"

Pair :: struct {
	row: int,
	col: int,
}

add_pair :: proc(p1: Pair, p2: Pair) -> Pair {
	return Pair{row = p1.row + p2.row, col = p1.col + p2.col}
}

Grid :: struct {
	mtx:    [][]u8,
	source: Pair,
	bones:  [dynamic]Pair,
}

BORDERS :: 100

STEPS :: [4]Pair{{-1, 0}, {0, 1}, {1, 0}, {0, -1}}

STEPS_EXT :: [12]Pair {
	{-1, 0},
	{-1, 0},
	{-1, 0},
	{0, 1},
	{0, 1},
	{0, 1},
	{1, 0},
	{1, 0},
	{1, 0},
	{0, -1},
	{0, -1},
	{0, -1},
}

build_grid :: proc(input: string) -> Grid {
	lines := strings.split_lines(input)
	defer delete(lines)

	rows := len(lines)
	cols := len(lines[0])

	mtx := make([][]u8, rows + 2 * BORDERS)
	for i in 0 ..< rows + 2 * BORDERS {
		mtx[i] = make([]u8, cols + 2 * BORDERS)
	}

	grid := Grid {
		mtx = mtx,
	}

	for i in 0 ..< rows + 2 * BORDERS {
		for j in 0 ..< cols + 2 * BORDERS {
			mtx[i][j] = '.'
		}
	}

	for i in 0 ..< rows {
		for j in 0 ..< cols {
			i2 := i + BORDERS
			j2 := j + BORDERS

			mtx[i2][j2] = lines[i][j]
			if mtx[i2][j2] == '@' {
				grid.source = Pair {
					row = i2,
					col = j2,
				}
			}
			if mtx[i2][j2] == '#' {
				append(&grid.bones, Pair{row = i2, col = j2})
			}
		}
	}

	return grid
}

copy_grid :: proc(grid: ^Grid) -> Grid {
	rows := len(grid.mtx)
	cols := len(grid.mtx[0])

	mtx := make([][]u8, rows)
	for i in 0 ..< rows {
		mtx[i] = make([]u8, cols)
	}

	for i in 0 ..< rows {
		for j in 0 ..< cols {
			mtx[i][j] = grid.mtx[i][j]
		}
	}

	grid_out := Grid {
		mtx = mtx,
	}

	for i in 0 ..< len(grid.bones) {
		append(&grid_out.bones, grid.bones[i])
	}

	grid_out.source = grid.source

	return grid_out
}

delete_grid :: proc(grid: ^Grid) {
	rows := len(grid.mtx)
	cols := len(grid.mtx[0])

	for i in 0 ..< rows do delete(grid.mtx[i])
	delete(grid.mtx)

	delete(grid.bones)
}

make_step :: proc(
	grid: ^Grid,
	opens: []u8,
	cur: Pair,
	step: ^int,
	steps: []Pair,
	check_closed := false,
) -> Pair {
	next := cur

	for cnt := 0; cnt < len(steps); cnt += 1 {
		assert(step^ <= len(steps))

		maybe_next := add_pair(next, steps[step^])
		assert(maybe_next.row >= 0 && maybe_next.row < len(grid.mtx))
		assert(maybe_next.col >= 0 && maybe_next.col < len(grid.mtx[0]))

		step^ += 1
		step^ %= len(steps)

		for open in opens {
			if grid.mtx[maybe_next.row][maybe_next.col] == open {
				if check_closed && is_closed(grid, maybe_next) {
					grid.mtx[maybe_next.row][maybe_next.col] = '@'

					continue
				}

				next = maybe_next
				grid.mtx[next.row][next.col] = '@'

				return next
			}
		}
	}

	unreachable()
}

is_closed :: proc(grid: ^Grid, p: Pair) -> bool {
	rows := len(grid.mtx)
	cols := len(grid.mtx[0])

	seen := make([][]bool, rows)
	for i in 0 ..< rows {
		seen[i] = make([]bool, cols)
	}
	defer {
		for i in 0 ..< rows do delete(seen[i])
		delete(seen)
	}

	q: [dynamic]Pair
	defer delete(q)

	append(&q, p)
	seen[p.row][p.col] = true

	for len(q) > 0 {
		cur := pop(&q)

		for dij in STEPS {
			to := add_pair(cur, dij)
			if to.row < 0 || to.row >= rows || to.col < 0 || to.col >= cols {
				return false
			}

			if seen[to.row][to.col] || grid.mtx[to.row][to.col] != '.' {
				continue
			}

			seen[to.row][to.col] = true
			append(&q, to)
		}
	}

	return true
}

solve_1 :: proc(input_data: string) -> string {
	grid := build_grid(input_data)
	defer delete_grid(&grid)

	cur := grid.source
	ans := 0
	step := 0

	opens := [2]u8{'.', '#'}
	steps := STEPS

	for cur != grid.bones[0] {
		cur = make_step(&grid, opens[:], cur, &step, steps[:])
		ans += 1
	}

	return fmt.aprint(ans)
}

solve :: proc(input_data: string, steps: []Pair) -> string {
	grid := build_grid(input_data)
	defer delete_grid(&grid)

	opens := [1]u8{'.'}

	left := 0
	right := 10000
	for right - left > 1 {
		mid := (left + right) >> 1

		grid_copy := copy_grid(&grid)
		defer delete_grid(&grid_copy)
		cur := grid_copy.source
		step := 0

		for cnt := 0; cnt < mid; cnt += 1 {
			cur = make_step(&grid_copy, opens[:], cur, &step, steps[:], true)
		}

		cnt := 0
		for bone in grid_copy.bones {
			if is_closed(&grid_copy, bone) {
				cnt += 1
			}
		}

		if cnt == len(grid_copy.bones) {
			right = mid
		} else {
			left = mid
		}
	}

	return fmt.aprint(right)
}

solve_2 :: proc(input_data: string) -> string {
	steps := STEPS

	return solve(input_data, steps[:])
}

solve_3 :: proc(input_data: string) -> string {
	steps := STEPS_EXT

	return solve(input_data, steps[:])
}

run :: proc(quest_part: int, input_file: string) {
	filepath := fmt.tprintf("quest_2/input/part_%d/%s", quest_part, input_file)

	fmt.printf("=== RUNNING QUEST 2 PART %d ===\nLoading file: %s\n\n", quest_part, filepath)

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
	input := utils.read_input("quest_2/input/part_1/input_sample.txt")
	defer delete(input)

	expected := "12"
	result := solve_1(input)
	defer delete(result)

	testing.expect(t, result == expected, fmt.tprint("Expected: %s. Result: %s", expected, result))
}

@(test)
test_1 :: proc(t: ^testing.T) {
	input := utils.read_input("quest_2/input/part_1/input.txt")
	defer delete(input)

	expected := "284"
	result := solve_1(input)
	defer delete(result)

	testing.expect(t, result == expected, fmt.tprint("Expected: %s. Result: %s", expected, result))
}

@(test)
test_2_sample :: proc(t: ^testing.T) {
	input := utils.read_input("quest_2/input/part_2/input_sample.txt")
	defer delete(input)

	expected := "47"
	result := solve_2(input)
	defer delete(result)

	testing.expect(t, result == expected, fmt.tprint("Expected: %s. Result: %s", expected, result))
}

@(test)
test_2 :: proc(t: ^testing.T) {
	input := utils.read_input("quest_2/input/part_2/input.txt")
	defer delete(input)

	expected := "3309"
	result := solve_2(input)
	defer delete(result)

	testing.expect(t, result == expected, fmt.tprint("Expected: %s. Result: %s", expected, result))
}

@(test)
test_3_sample_1 :: proc(t: ^testing.T) {
	input := utils.read_input("quest_2/input/part_3/input_sample_1.txt")
	defer delete(input)

	expected := "87"
	result := solve_3(input)
	defer delete(result)

	testing.expect(t, result == expected, fmt.tprint("Expected: %s. Result: %s", expected, result))
}

@(test)
test_3_sample_2 :: proc(t: ^testing.T) {
	input := utils.read_input("quest_2/input/part_3/input_sample_2.txt")
	defer delete(input)

	expected := "239"
	result := solve_3(input)
	defer delete(result)

	testing.expect(t, result == expected, fmt.tprint("Expected: %s. Result: %s", expected, result))
}

@(test)
test_3_sample_3 :: proc(t: ^testing.T) {
	input := utils.read_input("quest_2/input/part_3/input_sample_3.txt")
	defer delete(input)

	expected := "1539"
	result := solve_3(input)
	defer delete(result)

	testing.expect(t, result == expected, fmt.tprint("Expected: %s. Result: %s", expected, result))
}

@(test)
test_3 :: proc(t: ^testing.T) {
	input := utils.read_input("quest_2/input/part_3/input.txt")
	defer delete(input)

	expected := "2422"
	result := solve_3(input)
	defer delete(result)

	testing.expect(t, result == expected, fmt.tprint("Expected: %s. Result: %s", expected, result))
}
