const std = @import("std");
const mem = std.mem;
const math = std.math;
const assert = std.debug.assert;

const config = @import("../config.zig");
const div_ceil = @import("../util.zig").div_ceil;
const binary_search = @import("binary_search.zig");
const snapshot_latest = @import("tree.zig").snapshot_latest;

const GridType = @import("grid.zig").GridType;
const ManifestType = @import("manifest.zig").ManifestType;

pub fn ImmutableTableType(comptime Table: type) type {
    const Key = Table.Key;
    const Value = Table.Value;
    const compare_keys = Table.compare_keys;
    const key_from_value = Table.key_from_value;

    return struct {
        const ImmutableTable = @This();

        value_count_max: u32,
        values: []Value,
        snapshot_min: u64,
        free: bool,

        pub fn init(allocator: mem.Allocator, commit_count_max: u32) !ImmutableTable {
            // The in-memory immutable table is the same size as the mutable table:
            const value_count_max = commit_count_max * config.lsm_mutable_table_batch_multiple;
            const data_block_count = div_ceil(value_count_max, Table.data.value_count_max);
            assert(data_block_count <= Table.data_block_count_max);

            const values = try allocator.alloc(Value, value_count_max);
            errdefer allocator.free(values);

            return ImmutableTable{
                .value_count_max = value_count_max,
                .snapshot_min = undefined,
                .values = values,
                .free = true,
            };
        }

        pub inline fn values_max(table: *const ImmutableTable) []Value {
            return table.values.ptr[0..table.value_count_max];
        }

        pub fn deinit(table: *ImmutableTable, allocator: mem.Allocator) void {
            allocator.free(table.values_max());
        }

        pub fn reset_with_sorted_values(
            table: *ImmutableTable,
            snapshot_min: u64,
            sorted_values: []const Value,
        ) void {
            assert(table.free);
            assert(snapshot_min > 0);
            assert(snapshot_min < snapshot_latest);

            assert(sorted_values.ptr == table.values.ptr);
            assert(sorted_values.len > 0);
            assert(sorted_values.len <= table.value_count_max);
            assert(sorted_values.len <= Table.data.value_count_max * Table.data_block_count_max);

            if (config.verify) {
                var i: usize = 1;
                while (i < sorted_values.len) : (i += 1) {
                    assert(i > 0);
                    const left_key = key_from_value(sorted_values[i - 1]);
                    const right_key = key_from_value(sorted_values[i]);
                    assert(compare_keys(left_key, right_key) != .gt);
                }
            }

            table.* = .{
                .value_count_max = table.value_count_max,
                .values = sorted_values,
                .snapshot_min = snapshot_min,
                .free = false,
            };
        }

        // TODO(ifreund) This would be great to unit test.
        pub fn get(table: *const ImmutableTable, key: Key) ?*const Value {
            assert(!table.free);

            if (table.values.len > 0) {
                const result = binary_search.binary_search_values(
                    Key,
                    Value,
                    key_from_value,
                    compare_keys,
                    table.values,
                    key,
                );
                if (result.exact) {
                    const value = &table.values[result.index];
                    if (config.verify) assert(compare_keys(key, key_from_value(value.*)) == .eq);
                    return value;
                }
            }

            return null;
        }
    };
}

pub fn ImmutableTableIteratorType(comptime Table: type) type {
    return struct {
        const ImmutableTableIterator = @This();

        const Grid = GridType(Table.Storage);
        const Manifest = ManifestType(Table);
        const ImmutableTable = ImmutableTableType(Table);

        table: *ImmutableTable,
        values_index: u32,

        pub fn init(allocator: mem.Allocator) !ImmutableTableIterator {
            _ = allocator; // This only iterates an existing immutable table.

            return ImmutableTableIterator{
                .table = undefined,
                .values_index = undefined,
            };
        }

        pub fn deinit(it: *ImmutableTableIterator, allocator: mem.Allocator) void {
            _ = allocator; // No memory allocation was initially performed.
            it.* = undefined;
        }

        pub const Context = struct {
            table: *ImmutableTable,
        };

        pub fn reset(
            it: *ImmutableTableIterator,
            grid: *Grid,
            manifest: *Manifest,
            read_done: fn (*ImmutableTableIterator) void,
            context: Context,
        ) void {
            _ = grid;
            _ = manifest;
            _ = read_done;

            it.* = .{
                .table = context.table,
                .values_index = 0,
            };
        }

        pub fn tick(it: *ImmutableTableIterator) bool {
            _ = it;
            return false; // No I/O is performed as it's all in memory.
        }

        pub fn buffered_all_values(it: *ImmutableTableIterator) bool {
            _ = it;
            return true; // All values are "buffered" in memory.
        }

        pub fn peek(it: *ImmutableTableIterator) ?Table.Key {
            const values = it.table.values;
            if (it.values_index == values.len) return null;
            return Table.key_from_value(values[it.values_index]);
        }

        pub fn pop(it: *ImmutableTableIterator) Table.Value {
            defer it.values_index += 1;
            return it.table.values[it.values_index];
        }
    };
}