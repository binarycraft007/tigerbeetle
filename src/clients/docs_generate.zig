const std = @import("std");

const Docs = @import("./docs_types.zig").Docs;
const go = @import("./go/docs.zig").GoDocs;
const node = @import("./node/docs.zig").NodeDocs;

const languages = [_]Docs{ go, node };

const MarkdownWriter = struct {
    buf: *std.ArrayList(u8),
    writer: std.ArrayList(u8).Writer,

    fn init(buf: *std.ArrayList(u8)) MarkdownWriter {
        return MarkdownWriter{ .buf = buf, .writer = buf.writer() };
    }

    fn header(mw: *MarkdownWriter, comptime n: i8, content: []const u8) void {
        mw.print(("#" ** n) ++ " {s}\n\n", .{content});
    }

    fn paragraph(mw: *MarkdownWriter, content: []const u8) void {
        // Don't print empty lines.
        if (content.len == 0) {
            return;
        }
        mw.print("{s}\n\n", .{content});
    }

    fn code(mw: *MarkdownWriter, language: []const u8, content: []const u8) void {
        // Don't print empty lines.
        if (content.len == 0) {
            return;
        }
        mw.print("```{s}\n{s}\n```\n\n", .{ language, content });
    }

    fn commands(mw: *MarkdownWriter, content: []const u8) void {
        mw.print("```console\n", .{});
        var splits = std.mem.split(u8, content, "\n");
        while (splits.next()) |chunk| {
            mw.print("$ {s}\n", .{chunk});
        }

        mw.print("```\n\n", .{});
    }

    fn print(mw: *MarkdownWriter, comptime fmt: []const u8, args: anytype) void {
        mw.writer.print(fmt, args) catch unreachable;
    }

    fn reset(mw: *MarkdownWriter) void {
        mw.buf.clearRetainingCapacity();
    }

    fn diffOnDisk(mw: *MarkdownWriter, filename: []const u8) !bool {
        const file = try std.fs.cwd().createFile(filename, .{ .read = true, .truncate = false });
        const fSize = (try file.stat()).size;
        if (fSize != mw.buf.items.len) {
            return true;
        }

        var buf = std.mem.zeroes([4096]u8);
        var cursor: usize = 0;
        while (cursor < fSize) {
            var maxCanRead = if (fSize - cursor > 4096) 4096 else fSize - cursor;
            _ = try file.read(buf[0..maxCanRead]);
            if (std.mem.eql(u8, buf[0..], mw.buf.items[cursor..maxCanRead])) {
                return false;
            }
        }

        return true;
    }

    // save() only actually writes the buffer to disk if it has
    // changed compared to what's on disk, so that file modify time stays
    // reasonable.
    fn save(mw: *MarkdownWriter, filename: []const u8) !void {
        var diff = try mw.diffOnDisk(filename);
        if (!diff) {
            return;
        }

        const file = try std.fs.cwd().openFile(filename, .{ .write = true });
        defer file.close();

        try file.setEndPos(0);
        try file.writeAll(mw.buf.items);
    }
};

const Generator = struct {
    allocator: std.mem.Allocator,
    language: Docs,

    fn run_in_docker(self: Generator, cmds: []const u8, mount: []const u8, stdout: ?std.fs.File) !void {
        var full_cmd = &[_][]const u8{
            "docker",
            "run",
            "-v",
            mount,
            self.language.test_linux_docker_image,
            "bash",
            "-c",
            cmds,
        };
        var cp = try std.ChildProcess.init(full_cmd, self.allocator);
        cp.stdout = stdout;
        var res = try cp.spawnAndWait();
        switch (res) {
            .Exited => |code| {
                if (code != 0) {
                    std.process.exit(1);
                }
            },

            else => unreachable,
        }
    }

    fn run_with_file_in_docker(self: Generator, file: []const u8, to_run: []const u8, stdout: ?std.fs.File) !void {
        // Delete the directory if it already exists.
        std.fs.cwd().deleteTree("/tmp/wrk") catch {};
        std.fs.cwd().makeDir("/tmp/wrk") catch {};

        var tmp_file_name = try std.fmt.allocPrint(
            self.allocator,
            "/tmp/wrk/test.{s}",
            .{self.language.extension},
        );
        var tmp_file = try std.fs.cwd().createFile(tmp_file_name, .{
            .truncate = true,
        });
        _ = try tmp_file.write(file);

        var cmd = std.ArrayList(u8).init(self.allocator);
        defer cmd.deinit();

        try cmd.writer().print("cd /tmp/wrk", .{});
        var splits = std.mem.split(u8, self.language.install_commands, "\n");
        while (splits.next()) |chunk| {
            try cmd.writer().print(" && {s}", .{chunk});
        }

        try cmd.writer().print(" && {s}", .{to_run});

        try self.run_in_docker(
            cmd.items,
            "/tmp/wrk:/tmp/wrk",
            stdout,
        );

        tmp_file.close();

        // Don't delete the temp file so the parent calling this can
        // use it if it wants. Cleanup always only happens in the
        // beginning of the function.
    }

    fn build_file_in_docker(self: Generator, file: []const u8) !void {
        try self.run_with_file_in_docker(
            file,
            self.language.install_sample_file_build_commands,
            null,
        );
    }

    fn validate(self: Generator) !void {
        // Test the sample file
        try self.build_file_in_docker(self.language.install_sample_file);

        // Test major sample code
        var sample = try self.make_aggregate_sample();
        try self.build_file_in_docker(sample);
    }

    // This will not include every snippet but it includes as much as //
    // reasonable. Both so we can type-check as much as possible and also so
    // we can produce a building sample file for READMEs.
    fn make_aggregate_sample(self: Generator) ![]const u8 {
        return try std.fmt.allocPrint(
            self.allocator,
            "{s}\n{s}\n{s}\n{s}\n{s}\n{s}",
            .{
                self.language.test_main_prefix,
                self.language.client_object_example,
                self.language.create_accounts_example,
                self.language.lookup_accounts_example,
                self.language.create_transfers_example,
                self.language.test_main_suffix,
            },
        );
    }

    fn make_and_format_aggregate_sample(self: Generator) ![]const u8 {
        var sample = try self.make_aggregate_sample();
        try self.run_with_file_in_docker(
            sample,
            self.language.code_format_commands,
            null,
        );

        // This is the place where run_with_file_in_docker places the file.
        var formatted_file_name = try std.fmt.allocPrint(
            self.allocator,
            "/tmp/wrk/test.{s}",
            .{self.language.extension},
        );
        var formatted_file = try std.fs.cwd().openFile(formatted_file_name, .{
            .read = true,
        });

        const file_size = try formatted_file.getEndPos();
        var formatted = try self.allocator.alloc(u8, file_size);
        _ = try formatted_file.read(formatted);

        // Temp file cleanup

        try std.fs.cwd().deleteFile(formatted_file_name);

        return formatted;
    }

    fn generate(self: Generator, mw: *MarkdownWriter) !void {
        var language = self.language;

        mw.paragraph(
            \\This file is generated by
            \\[src/clients/docs_generate.zig](/src/clients/docs_generate.zig).
        );

        mw.header(1, language.name);
        mw.paragraph(language.description);

        mw.header(3, "Prerequisites");
        mw.paragraph(language.prerequisites);

        mw.header(2, "Setup");

        mw.commands(language.install_commands);
        mw.print("Create `test.{s}` and copy this into it:\n\n", .{language.extension});
        mw.code(language.markdown_name, language.install_sample_file);
        mw.paragraph("And run:");
        mw.commands(language.install_sample_file_test_commands);

        mw.paragraph(language.install_documentation);

        if (language.examples.len != 0) {
            mw.header(2, "Examples");
            mw.paragraph(language.examples);
        }

        mw.header(2, "Creating a Client");
        mw.code(language.markdown_name, language.client_object_example);
        mw.paragraph(language.client_object_documentation);

        mw.paragraph(
            \\The following are valid addresses:
            \\* `3000` (interpreted as `127.0.0.1:3000`)
            \\* `127.0.0.1:3000` (interpreted as `127.0.0.1:3000`)
            \\* `127.0.0.1` (interpreted as `127.0.0.1:3001`, `3001` is the default port)
        );

        mw.header(2, "Creating Accounts");
        mw.paragraph(
            \\See details for account fields in the [Accounts
            \\reference](https://docs.tigerbeetle.com/reference/accounts).
        );
        mw.code(language.markdown_name, language.create_accounts_example);
        mw.paragraph(language.create_accounts_documentation);

        mw.header(3, "Account Flags");
        mw.paragraph(
            \\The account flags value is a bitfield. See details for
            \\these flags in the [Accounts
            \\reference](https://docs.tigerbeetle.com/reference/accounts#flags).
        );
        mw.paragraph(language.account_flags_details);

        mw.header(3, "Response and Errors");
        mw.paragraph(
            \\The response is an empty array if all accounts were
            \\created successfully. If the response is non-empty, each
            \\object in the response array contains error information
            \\for an account that failed. The error object contains an
            \\error code and the index of the account in the request
            \\batch.
            \\
            \\See all error conditions in the [create_accounts
            \\reference](https://docs.tigerbeetle.com/reference/operations/create_accounts).
        );

        mw.code(language.markdown_name, language.create_accounts_errors_example);
        mw.paragraph(language.create_accounts_errors_documentation);

        mw.header(2, "Account Lookup");
        mw.paragraph(
            \\Account lookup is batched, like account creation. Pass
            \\in all IDs to fetch, and matched accounts are returned.
            \\
            \\If no account matches an ID, no object is returned for
            \\that account. So the order of accounts in the response is
            \\not necessarily the same as the order of IDs in the
            \\request. You can refer to the ID field in the response to
            \\distinguish accounts.
        );
        mw.code(language.markdown_name, language.lookup_accounts_example);

        mw.header(2, "Create Transfers");
        mw.paragraph(
            \\This creates a journal entry between two accounts.
            \\
            \\See details for transfer fields in the [Transfers
            \\reference](https://docs.tigerbeetle.com/reference/transfers).
        );

        mw.header(3, "Response and Errors");
        mw.paragraph(
            \\The response is an empty array if all transfers were created
            \\successfully. If the response is non-empty, each object in the
            \\response array contains error information for an transfer that
            \\failed. The error object contains an error code and the index of the
            \\transfer in the request batch.
            \\
            \\See all error conditions in the [create_transfers
            \\reference](https://docs.tigerbeetle.com/reference/operations/create_transfers).
        );
        mw.code(language.markdown_name, language.create_transfers_errors_example);
        mw.paragraph(
            \\The example above shows that the transfer in index 1 failed with
            \\error 1. This error here means that `transfer1` and `transfer3` were
            \\created successfully. But `transfer2` was not created.
        );
        mw.paragraph(language.create_transfers_errors_documentation);

        mw.header(3, "Batching");
        mw.paragraph(
            \\TigerBeetle performance is maximized when you batch
            \\inserts. The client does not do this automatically for
            \\you. So, for example, you *can* insert 1 million transfers
            \\one at a time like so:
        );
        mw.code(language.markdown_name, language.no_batch_example);
        mw.paragraph(
            \\But the insert rate will be a *fraction* of
            \\potential. Instead, **always batch what you can**.
            \\
            \\The maximum batch size is set in the TigerBeetle server. The default
            \\is 8191.
        );
        mw.code(language.markdown_name, language.batch_example);

        // Full sample
        mw.header(2, "Complete sample file");
        var formatted_sample = try self.make_and_format_aggregate_sample();
        mw.code(language.markdown_name, formatted_sample);

        mw.header(2, "Development Setup");
        // Bash setup
        mw.header(3, "On Linux and macOS");
        mw.commands(language.developer_setup_bash_commands);

        // Windows setup
        mw.header(3, "On Windows");
        mw.commands(language.developer_setup_windows_commands);

        try mw.save(language.readme);
    }
};

pub fn main() !void {
    for (languages) |language| {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();

        const allocator = arena.allocator();
        var buf = std.ArrayList(u8).init(allocator);
        var mw = MarkdownWriter.init(&buf);

        var generator = Generator{ .allocator = allocator, .language = language };
        try generator.validate();

        try generator.generate(&mw);
    }
}
