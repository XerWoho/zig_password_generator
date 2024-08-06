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
  if(string_compare(type_password, "simple")) return try simple_password();
  if(string_compare(type_password, "complicated")) return try complicated_password();
  if(string_compare(type_password, "secure")) return try secure_password();

  return "not a valid option";
}

fn fun_password() !string_type {
  const path: string_type = "src/utils/security/1000_common_words.txt";
  const all_words = try read_file_lines(path);

  const now: u64 = @intCast(std.time.milliTimestamp());
  var rand_impl = std.rand.DefaultPrng.init(now);
  const random_words_iteration = rand_impl.random().intRangeAtMost(u16,3, 6);

  const allocator = std.heap.page_allocator;
  var password_buffer = std.ArrayList(u8).init(allocator);
  defer password_buffer.deinit();
  for (random_words_iteration) |_| {
      const random_index = rand_impl.random().intRangeAtMost(u16, 0, 999);

      const random_word = all_words[random_index];
      try password_buffer.appendSlice(random_word);
  }

  const random_password = try password_buffer.toOwnedSlice();
  return random_password;
}

fn simple_password() !string_type {
  const now: u64 = @intCast(std.time.milliTimestamp());
  var rand_impl = std.rand.DefaultPrng.init(now);

  const allocator = std.heap.page_allocator;
  var password_buffer = std.ArrayList(u8).init(allocator);

  for(3) |_| {
    for(3) |_| {
      const random_numbers = rand_impl.random().intRangeAtMost(u16,0, 9);
      try password_buffer.append(all_numbers[random_numbers]);
    }

    for(3) |_| {
      const random_numbers = rand_impl.random().intRangeAtMost(u16,0, 9);
      try password_buffer.append(all_letters_lower[random_numbers]);
    }
  }

  const random_password = try password_buffer.toOwnedSlice();
  return random_password;
}
fn complicated_password() !string_type {
  const now: u64 = @intCast(std.time.milliTimestamp());
  var rand_impl = std.rand.DefaultPrng.init(now);

  const allocator = std.heap.page_allocator;
  var password_buffer = std.ArrayList(u8).init(allocator);

  const random_iteration = rand_impl.random().intRangeAtMost(u16,16, 30);
  for(random_iteration) |_| {
    const random_type = rand_impl.random().intRangeAtMost(u16,0, 4);

    if(random_type == 0) {
      const random_numbers = rand_impl.random().intRangeAtMost(u16,0, all_numbers.len - 1);
      try password_buffer.append(all_numbers[random_numbers]);
      continue;
    }
    if(random_type == 1) {
      const random_lower = rand_impl.random().intRangeAtMost(u16,0, all_letters_lower.len - 1);
      try password_buffer.append(all_letters_lower[random_lower]);
      continue;
    }
    if(random_type == 2) {
      const random_upper = rand_impl.random().intRangeAtMost(u16,0, all_letters_capital.len - 1);
      try password_buffer.append(all_letters_capital[random_upper]);
      continue;
    }
    if(random_type >= 3) {
      const random_characters = rand_impl.random().intRangeAtMost(u16,0, all_special_characters.len - 1);
      try password_buffer.append(all_special_characters[random_characters]);
      continue;
    }
  }

  const random_password = try password_buffer.toOwnedSlice();
  return random_password;
}
fn secure_password() !string_type {
  const now: u64 = @intCast(std.time.milliTimestamp());
  var rand_impl = std.rand.DefaultPrng.init(now);

  const allocator = std.heap.page_allocator;
  var password_buffer = std.ArrayList(u8).init(allocator);
  var special_characters_used: u8 = 0;

  for(12) |_| {
    var random_type = rand_impl.random().intRangeAtMost(u16,0, 3);

    if(special_characters_used == 2 and random_type == 3) {
      random_type = rand_impl.random().intRangeAtMost(u16,0, 2);
    }

    if(random_type == 0) {
      const random_numbers = rand_impl.random().intRangeAtMost(u16,0, all_numbers.len - 1);
      try password_buffer.append(all_numbers[random_numbers]);
      continue;
    }
    if(random_type == 1) {
      const random_lower = rand_impl.random().intRangeAtMost(u16,0, all_letters_lower.len - 1);
      try password_buffer.append(all_letters_lower[random_lower]);
      continue;
    }
    if(random_type == 2) {
      const random_upper = rand_impl.random().intRangeAtMost(u16,0, all_letters_capital.len - 1);
      try password_buffer.append(all_letters_capital[random_upper]);
      continue;
    }
    if(
      random_type == 3
      and
      special_characters_used < 2
    ) {
      const random_characters = rand_impl.random().intRangeAtMost(u16,0, simple_special_characters.len - 1);
      try password_buffer.append(simple_special_characters[random_characters]);
      special_characters_used += 1;
      continue;
    }
  }

  const random_password = try password_buffer.toOwnedSlice();
  return random_password;
}
