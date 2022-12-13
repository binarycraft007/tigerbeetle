const std = @import("std");

const Docs = @import("./docs_types.zig").Docs;
const go = @import("./go/docs.zig").GoDocs;
const node = @import("./node/docs.zig").NodeDocs;

const languages = [_]Docs{ go, node };

// pub fn run_in_docker(image: []const u8, cmds: [][]const u8) !void {
//     var cp = std.child_process.ChildProcess.init("docker", &[_][]const u8{
//         "run",
//         language,
//         },
//                                                  );
// }

// pub fn validate_docs(language: Docs) {
//     try run_in_docker(
//         language.test_linux_docker_image,
//         language.install,
//     );
//     try run_in_docker(
//         language.test_linux_docker_image,
//         language.developer_setup_bash_commands,
//     );
// }

const MarkdownWriter = struct {
    buf: *std.ArrayList(u8),
    writer: std.ArrayList(u8).Writer,

    fn init(buf: *std.ArrayList(u8)) MarkdownWriter {
        return MarkdownWriter{ .buf = buf, .writer = buf.writer() };
    }

    fn header(mw: *MarkdownWriter, comptime n: i8, content: []const u8) !void {
        try mw.print(("#" ** n) ++ " {s}\n\n", .{content});
    }

    fn paragraph(mw: *MarkdownWriter, content: []const u8) !void {
        // Don't print empty lines.
        if (content.len == 0) {
            return;
        }
        try mw.print("{s}\n\n", .{content});
    }

    fn code(mw: *MarkdownWriter, language: []const u8, content: []const u8) !void {
        // Don't print empty lines.
        if (content.len == 0) {
            return;
        }
        try mw.print("```{s}\n{s}\n```\n\n", .{ language, content });
    }

    fn commands(mw: *MarkdownWriter, content: []const u8) !void {
        try mw.print("```console\n", .{});
        var splits = std.mem.split(u8, content, "\n");
        while (splits.next()) |chunk| {
            try mw.print("$ {s}\n", .{chunk});
        }

        try mw.print("```\n\n", .{});
    }

    fn print(mw: *MarkdownWriter, comptime fmt: []const u8, args: anytype) !void {
        try mw.writer.print(fmt, args);
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

        var h = std.crypto.hash.sha2.Sha256.init(.{});
        var buf = std.mem.zeroes([4096]u8);
        var cursor: usize = 0;
        while (cursor < fSize) {
            var maxCanRead = if (fSize - cursor > 4096) 4096 else fSize - cursor;
            var read = try file.read(buf[0..maxCanRead]);
            h.update(buf[0..read]);
            cursor += read;
        }

        var newH = std.crypto.hash.sha2.Sha256.init(.{});
        newH.update(mw.buf.items);
        var newHash: [std.crypto.hash.sha2.Sha256.digest_length]u8 = undefined;
        newH.final(newHash[0..]);
        var existingHash: [std.crypto.hash.sha2.Sha256.digest_length]u8 = undefined;
        h.final(existingHash[0..]);

        return !std.mem.eql(u8, newHash[0..], existingHash[0..]);
    }

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

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    var buf = std.ArrayList(u8).init(allocator);
    var mw = MarkdownWriter.init(&buf);

    for (languages) |language| {
        //try validate_docs(language);

        mw.reset();

        try mw.paragraph(
            \\This file is generated by
            \\[src/clients/docs_generate.zig](/src/clients/docs_generate.zig).
        );

        try mw.header(1, language.name);
        try mw.paragraph(language.description);

        try mw.header(3, "Prerequisites");
        try mw.paragraph(language.prerequisites);

        try mw.header(2, "Setup");

        try mw.commands(language.install_commands);
        try mw.print("To test the installation, create `test.{s}` and copy this into it:\n\n", .{language.extension});
        try mw.code(language.markdown_name, language.install_sample_file);
        try mw.paragraph("Now run it:");
        try mw.commands(language.install_sample_file_test_commands);

        try mw.paragraph(language.install_documentation);

        if (language.examples.len != 0) {
            try mw.header(2, "Examples");
            try mw.paragraph(language.examples);
        }

        try mw.header(2, "Creating a Client");
        try mw.code(language.markdown_name, language.client_object_example);
        try mw.paragraph(language.client_object_documentation);

        try mw.paragraph(
            \\The following are valid addresses:
            \\* `3000` (interpreted as `127.0.0.1:3000`)
            \\* `127.0.0.1:3000` (interpreted as `127.0.0.1:3000`)
            \\* `127.0.0.1` (interpreted as `127.0.0.1:3001`, `3001` is the default port)
        );

        try mw.header(2, "Creating Accounts");
        try mw.paragraph(
            \\See details for account fields in the [Accounts
            \\reference](https://docs.tigerbeetle.com/reference/accounts).
        );
        try mw.code(language.markdown_name, language.create_accounts_example);
        try mw.paragraph(language.create_accounts_documentation);

        try mw.header(3, "Account Flags");
        try mw.paragraph(
            \\The account flags value is a bitfield. See details for
            \\these flags in the [Accounts
            \\reference](https://docs.tigerbeetle.com/reference/accounts#flags).
        );
        try mw.paragraph(language.account_flags_details);

        try mw.header(3, "Response and Errors");
        try mw.paragraph(
            \\The response is an empty array if all accounts were
            \\created successfully. If the response is non-empty, each
            \\object in the response array contains error information
            \\for an account that failed. The error object contains an
            \\error code and the index of the account in the request
            \\batch.
        );

        try mw.header(2, "Account Lookup");
        try mw.paragraph(
            \\Account lookup is batched, like account creation. Pass
            \\in all IDs to fetch, and matched accounts are returned.
            \\
            \\If no account matches an ID, no object is returned for
            \\that account. So the order of accounts in the response is
            \\not necessarily the same as the order of IDs in the
            \\request. You can refer to the ID field in the response to
            \\distinguish accounts.
        );
        try mw.code(language.markdown_name, language.lookup_accounts_example);

        try mw.header(2, "Development Setup");
        // Bash setup
        try mw.header(3, "On Linux and macOS");
        try mw.commands(language.developer_setup_bash_commands);

        // Windows setup
        try mw.header(3, "On Windows");
        try mw.commands(language.developer_setup_windows_commands);

        try mw.save(language.readme);
    }
}
