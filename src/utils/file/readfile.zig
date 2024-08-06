const std = @import("std");

pub fn read_file_lines(
  file_path: []const u8
) ![][]u8 {
  var file = try std.fs.cwd().openFile(file_path, .{});
  defer file.close();

  var buf_reader = std.io.bufferedReader(file.reader());
  var in_stream = buf_reader.reader();

  const allocator = std.heap.page_allocator;
  var lines = std.ArrayList([]u8).init(allocator);
  var buf: [1024]u8 = undefined;

  while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
      const line_copy = try allocator.alloc(u8, line.len);
      std.mem.copyForwards(u8, line_copy, line);
      try lines.append(line_copy);
  }

  return lines.items;
}
