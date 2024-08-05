pub fn string_compare(string: []const u8, compare: []const u8) bool {
    if (string.len != compare.len) { return false; }

    var indexed: u8 = 0;
    for (string) |c1| {
        if (c1 != compare[indexed]) { return false; }
        indexed += 1;
    }
    return true;
}
