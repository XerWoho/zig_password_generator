const std = @import("std");
const key_press_poll = @import("utils/key_presses.zig").key_press_poll;
const string_compare = @import("utils/compare_strings.zig").string_compare;
const generate_password = @import("utils/generate_password.zig").generate_password;
const constant_types = @import("utils/constant_types.zig");
const string_type = constant_types.string_type;


const options = [_]string_type{"Fun\n", "Simple\n", "Complicated\n", "Secure\n"};
const selected_options = [_]string_type{"> Fun\n", "> Simple\n", "> Complicated\n", "> Secure\n"};
const final_options = [_]string_type{"fun", "simple", "complicated", "secure"};

pub fn set_current_options(
  selected_option_index: u8,
  terminal: *terminal_viewer
) !void {
    var option_iteration: u8 = 0;
    for(options) |option| {
      if(option_iteration == selected_option_index) {
        try terminal.terminal_data_append(selected_options[option_iteration]);
      } else {
        try terminal.terminal_data_append(option);
      }
      option_iteration += 1;
    }
}

pub fn main() !void {
    // initializing the terminal
    const allocator = std.heap.page_allocator;
    var terminal = try terminal_viewer.init(allocator);

    const ctrl: string_type = "Ctrl + C (q), to exit the screen.\n\n\n";
    try terminal.terminal_data_append(ctrl);

    // run the terminal viewer
    const thread = try std.Thread.spawn(
      .{},
      run_teriminal_view,
      .{&terminal}
    );
    defer thread.join();


    const title: string_type = "What kind of password do you want?.\n\n";
    try terminal.terminal_data_append(title);

    var selected_option_index: u8  = 0;
    try set_current_options(
      selected_option_index,
      &terminal
    );


    while(true) {
      const down: string_type = "down";
      const up: string_type = "up";
      const quit: string_type = "quit";
      const enter: string_type = "enter";

      const key_press: string_type = key_press_poll();

      if(
        string_compare(key_press, up)
      ) {
        if(selected_option_index != 0) {
          selected_option_index -= 1;
          try terminal.remove_from_end(2);
          try set_current_options(selected_option_index, &terminal);
        }
        continue;
      }

      if(
        string_compare(key_press, down)
      ) {
        if(selected_option_index != 3) {
          selected_option_index += 1;
          try terminal.remove_from_end(2);
          try set_current_options(selected_option_index, &terminal);
        }
        continue;
      }

      // enter key breaks -> option selected
      if(string_compare(key_press, enter)) break;

      if(string_compare(key_press, quit)) {
        std.debug.print("\nQuitting the menu...\n", .{});
        std.process.exit(1);
        break;
      }
      continue;
    }

    try terminal.remove_from_end(0);
    std.time.sleep(std.time.ns_per_ms * 500);
    std.debug.print(
      "Option: {s} was selected\nGenerating password.\n\n",
      .{final_options[selected_option_index]}
    );

    const password_generated: string_type = "Password was generated:";
    std.debug.print("{s}\n", .{password_generated});

    const password: string_type = try generate_password(final_options[selected_option_index]);
    std.debug.print("{s}\n", .{password});

    std.debug.print("\nThanks for using us!\n", .{});
    std.process.exit(1);
}

pub fn run_teriminal_view(terminal_view: *terminal_viewer) !void {
  std.debug.print("Starting event loop\n", .{});
  try terminal_view.terminal_view();
}

const terminal_viewer = struct {
    terminal_data: std.ArrayList(string_type),
    last_terminal_data: std.ArrayList(string_type),

    // init the parameters
    pub fn init(
      allocator: std.mem.Allocator
    ) !terminal_viewer {
        return terminal_viewer{
            .terminal_data = std.ArrayList(string_type).init(allocator),
            .last_terminal_data = std.ArrayList(string_type).init(allocator),
        };
    }

    pub fn remove_from_start(self: *terminal_viewer, amount: u32) !void {
      if (self.terminal_data.items.len < amount) return;

      var new_terminal_data = std.ArrayList(string_type).init(self.terminal_data.allocator);
      try new_terminal_data.appendSlice(self.terminal_data.items[amount..]);
      self.terminal_data.deinit();
      self.terminal_data = new_terminal_data;
    }

    pub fn remove_from_end(self: *terminal_viewer, amount: u32) !void {
      if(self.terminal_data.items.len < amount) return;

      var new_terminal_data = std.ArrayList(string_type).init(self.terminal_data.allocator);
      try new_terminal_data.appendSlice(self.terminal_data.items[0..amount]);
      self.terminal_data.deinit();
      self.terminal_data = new_terminal_data;
    }

    pub fn terminal_deinit(self: *terminal_viewer) void {
        std.debug.print("Deiniting", .{});
        self.terminal_data.deinit();
        self.last_terminal_data.deinit();
    }

    pub fn terminal_data_append(self: *terminal_viewer, new_terminal_data: string_type) !void {
        try self.terminal_data.append(new_terminal_data);
    }


    pub fn terminal_view(self: *terminal_viewer) !void {
        while(true) {
          const check_diff = try self.check_difference();
          if(check_diff) continue;

          const stdout = std.io.getStdOut().writer();

          // clear the screen and re-print the terminal state
          try stdout.writeAll("\x1b[2J\x1b[H");
          for (self.terminal_data.items) |item| {
              try stdout.print("{s}", .{item});
          }

          // set the last used terminal data to the current terminal data
          var temp_terminal_data = std.ArrayList(string_type).init(self.last_terminal_data.allocator);
          try temp_terminal_data.appendSlice(self.terminal_data.items);
          self.last_terminal_data.deinit();
          self.last_terminal_data = temp_terminal_data;


          // break before going to next check
          std.time.sleep(
            std.time.ns_per_s * 0.5
          );
        }
        return;
    }


    // private check
    fn check_difference(self: *terminal_viewer) !bool {
        if (self.last_terminal_data.items.len != self.terminal_data.items.len) return false;

        var iterated_list_amount: usize = 0;
        while (iterated_list_amount < self.terminal_data.items.len) : (iterated_list_amount = iterated_list_amount + 1) {
            if (
                !std.mem.eql(
                    u8,
                    self.terminal_data.items[iterated_list_amount],
                    self.last_terminal_data.items[iterated_list_amount]
                  )
                ) {
                return false;
            }
        }

        return true;
    }
};
