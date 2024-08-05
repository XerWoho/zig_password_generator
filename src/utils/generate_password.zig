const std = @import("std");
const string_compare = @import("compare_strings.zig").string_compare;
const read_file_lines = @import("security/readfile.zig").read_file_lines;
const constant_types = @import("constant_types.zig");
const string_type = constant_types.string_type;

const all_letters_lower = "abcdefghijklmnopqrstuvwxyz";
const all_letters_capital = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const all_numbers = "1234567890";

const all_special_characters = ".:,;-_#'+*";
const simple_special_characters = "-_";


pub fn generate_password(
  type_password: string_type
) !string_type {
  if(string_compare(type_password, "fun")) return try fun_password();
  if(string_compare(type_password, "simple")) return simple_password();
  if(string_compare(type_password, "complicated")) return complicated_password();
  if(string_compare(type_password, "secure")) return secure_password();

  return "not a valid option";
}

fn fun_password() !string_type {
  const path: string_type = "src/utils/security/1000_common_words.txt";
  const all_words = try read_file_lines(path);

  const allocator = std.heap.page_allocator;

  const now: u64 = @intCast(std.time.milliTimestamp());
  var rand_impl = std.rand.DefaultPrng.init(now);

  const random_words_iteration = rand_impl.random().intRangeAtMost(u16,3, 6);

  var password_buffer = std.ArrayList(u8).init(allocator);
  defer password_buffer.deinit();
  for (random_words_iteration) |_| {
      const random_index = rand_impl.random().intRangeAtMost(u16, 0, 999);

      const random_word = all_words[random_index];
      try password_buffer.appendSlice(random_word);
  }

  // why the fuck does that make my zig compile faster???
  const non = "";
  std.debug.print("{s}", .{non});

  const random_password = try password_buffer.toOwnedSlice();
  return random_password;
}

fn simple_password() string_type {
  return "123abc456def789ghi";
}
fn complicated_password() string_type {
  return "1k.-,.019@ms,.ajs19";
}
fn secure_password() string_type {
  return "Kk12_p09sk";
}
