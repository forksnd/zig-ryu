const std = @import("std");
const ryu64 = @import("../ryu.zig").ryu64;

fn ieeeFromParts(sign: bool, exponent: u32, mantissa: u64) f64 {
    std.debug.assert(exponent <= 2047);
    std.debug.assert(mantissa <= (@as(u64, 1) << 53) - 1);
    return @bitCast(f64, ((@as(u64, @boolToInt(sign)) << 63) | (@as(u64, exponent) << 52) | mantissa));
}

fn expectFixed(v: f64, precision: u32, expected: []const u8) void {
    var buffer: [ryu64.max_buf_size.fixed]u8 = undefined;
    const s = ryu64.printFixed(&buffer, v, precision);
    std.testing.expectEqualSlices(u8, expected, s);
}

test "fixed basic" {
    expectFixed(
        ieeeFromParts(false, 1234, 99999),
        0,
        "3291009114715486435425664845573426149758869524108446525879746560",
    );
}

test "fixed zero" {
    expectFixed(0.0, 4, "0.0000");
    expectFixed(0.0, 3, "0.000");
    expectFixed(0.0, 2, "0.00");
    expectFixed(0.0, 1, "0.0");
    expectFixed(0.0, 0, "0");
}

test "fixed min/max" {
    expectFixed(
        ieeeFromParts(false, 0, 1),
        1074,
        "0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" ++
            "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" ++
            "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" ++
            "000000000000000000000000000000000000000000000000000000049406564584124654417656879286822137" ++
            "236505980261432476442558568250067550727020875186529983636163599237979656469544571773092665" ++
            "671035593979639877479601078187812630071319031140452784581716784898210368871863605699873072" ++
            "305000638740915356498438731247339727316961514003171538539807412623856559117102665855668676" ++
            "818703956031062493194527159149245532930545654440112748012970999954193198940908041656332452" ++
            "475714786901472678015935523861155013480352649347201937902681071074917033322268447533357208" ++
            "324319360923828934583680601060115061698097530783422773183292479049825247307763759272478746" ++
            "560847782037344696995336470179726777175851256605511991315048911014510378627381672509558373" ++
            "89733598993664809941164205702637090279242767544565229087538682506419718265533447265625",
    );

    expectFixed(
        ieeeFromParts(false, 2046, 0xfffffffffffff),
        0,
        "179769313486231570814527423731704356798070567525844996598917476803157260780028538760589558" ++
            "632766878171540458953514382464234321326889464182768467546703537516986049910576551282076245" ++
            "490090389328944075868508455133942304583236903222948165808559332123348274797826204144723168" ++
            "738177180919299881250404026184124858368",
    );
}

test "fixed round to even" {
    expectFixed(0.125, 3, "0.125");
    expectFixed(0.125, 2, "0.12");
    expectFixed(0.375, 3, "0.375");
    expectFixed(0.375, 2, "0.38");
}

test "fixed round to even integer" {
    expectFixed(2.5, 1, "2.5");
    expectFixed(2.5, 0, "2");
    expectFixed(3.5, 1, "3.5");
    expectFixed(3.5, 0, "4");
}

test "fixed non round to even" {
    expectFixed(0.748046875, 3, "0.748");
    expectFixed(0.748046875, 2, "0.75");
    expectFixed(0.748046875, 1, "0.7"); // 0.75 would round to "0.8", but this is smaller

    expectFixed(0.2509765625, 3, "0.251");
    expectFixed(0.2509765625, 2, "0.25");
    expectFixed(0.2509765625, 1, "0.3"); // 0.25 would round to "0.2", but this is larger

    expectFixed(ieeeFromParts(false, 1021, 1), 54, "0.250000000000000055511151231257827021181583404541015625");
    expectFixed(ieeeFromParts(false, 1021, 1), 3, "0.250");
    expectFixed(ieeeFromParts(false, 1021, 1), 2, "0.25");
    expectFixed(ieeeFromParts(false, 1021, 1), 1, "0.3"); // 0.25 would round to "0.2", but this is larger (again)
}

test "fixed varying precision" {
    expectFixed(1729.142857142857, 47, "1729.14285714285711037518922239542007446289062500000");
    expectFixed(1729.142857142857, 46, "1729.1428571428571103751892223954200744628906250000");
    expectFixed(1729.142857142857, 45, "1729.142857142857110375189222395420074462890625000");
    expectFixed(1729.142857142857, 44, "1729.14285714285711037518922239542007446289062500");
    expectFixed(1729.142857142857, 43, "1729.1428571428571103751892223954200744628906250");
    expectFixed(1729.142857142857, 42, "1729.142857142857110375189222395420074462890625");
    expectFixed(1729.142857142857, 41, "1729.14285714285711037518922239542007446289062");
    expectFixed(1729.142857142857, 40, "1729.1428571428571103751892223954200744628906");
    expectFixed(1729.142857142857, 39, "1729.142857142857110375189222395420074462891");
    expectFixed(1729.142857142857, 38, "1729.14285714285711037518922239542007446289");
    expectFixed(1729.142857142857, 37, "1729.1428571428571103751892223954200744629");
    expectFixed(1729.142857142857, 36, "1729.142857142857110375189222395420074463");
    expectFixed(1729.142857142857, 35, "1729.14285714285711037518922239542007446");
    expectFixed(1729.142857142857, 34, "1729.1428571428571103751892223954200745");
    expectFixed(1729.142857142857, 33, "1729.142857142857110375189222395420074");
    expectFixed(1729.142857142857, 32, "1729.14285714285711037518922239542007");
    expectFixed(1729.142857142857, 31, "1729.1428571428571103751892223954201");
    expectFixed(1729.142857142857, 30, "1729.142857142857110375189222395420");
    expectFixed(1729.142857142857, 29, "1729.14285714285711037518922239542");
    expectFixed(1729.142857142857, 28, "1729.1428571428571103751892223954");
    expectFixed(1729.142857142857, 27, "1729.142857142857110375189222395");
    expectFixed(1729.142857142857, 26, "1729.14285714285711037518922240");
    expectFixed(1729.142857142857, 25, "1729.1428571428571103751892224");
    expectFixed(1729.142857142857, 24, "1729.142857142857110375189222");
    expectFixed(1729.142857142857, 23, "1729.14285714285711037518922");
    expectFixed(1729.142857142857, 22, "1729.1428571428571103751892");
    expectFixed(1729.142857142857, 21, "1729.142857142857110375189");
    expectFixed(1729.142857142857, 20, "1729.14285714285711037519");
    expectFixed(1729.142857142857, 19, "1729.1428571428571103752");
    expectFixed(1729.142857142857, 18, "1729.142857142857110375");
    expectFixed(1729.142857142857, 17, "1729.14285714285711038");
    expectFixed(1729.142857142857, 16, "1729.1428571428571104");
    expectFixed(1729.142857142857, 15, "1729.142857142857110");
    expectFixed(1729.142857142857, 14, "1729.14285714285711");
    expectFixed(1729.142857142857, 13, "1729.1428571428571");
    expectFixed(1729.142857142857, 12, "1729.142857142857");
    expectFixed(1729.142857142857, 11, "1729.14285714286");
    expectFixed(1729.142857142857, 10, "1729.1428571429");
    expectFixed(1729.142857142857, 9, "1729.142857143");
    expectFixed(1729.142857142857, 8, "1729.14285714");
    expectFixed(1729.142857142857, 7, "1729.1428571");
    expectFixed(1729.142857142857, 6, "1729.142857");
    expectFixed(1729.142857142857, 5, "1729.14286");
    expectFixed(1729.142857142857, 4, "1729.1429");
    expectFixed(1729.142857142857, 3, "1729.143");
    expectFixed(1729.142857142857, 2, "1729.14");
    expectFixed(1729.142857142857, 1, "1729.1");
    expectFixed(1729.142857142857, 0, "1729");
}

test "fixed carrying" {
    expectFixed(0.0009, 4, "0.0009");
    expectFixed(0.0009, 3, "0.001");
    expectFixed(0.0029, 4, "0.0029");
    expectFixed(0.0029, 3, "0.003");
    expectFixed(0.0099, 4, "0.0099");
    expectFixed(0.0099, 3, "0.010");
    expectFixed(0.0299, 4, "0.0299");
    expectFixed(0.0299, 3, "0.030");
    expectFixed(0.0999, 4, "0.0999");
    expectFixed(0.0999, 3, "0.100");
    expectFixed(0.2999, 4, "0.2999");
    expectFixed(0.2999, 3, "0.300");
    expectFixed(0.9999, 4, "0.9999");
    expectFixed(0.9999, 3, "1.000");
    expectFixed(2.9999, 4, "2.9999");
    expectFixed(2.9999, 3, "3.000");
    expectFixed(9.9999, 4, "9.9999");
    expectFixed(9.9999, 3, "10.000");
    expectFixed(29.9999, 4, "29.9999");
    expectFixed(29.9999, 3, "30.000");
    expectFixed(99.9999, 4, "99.9999");
    expectFixed(99.9999, 3, "100.000");
    expectFixed(299.9999, 4, "299.9999");
    expectFixed(299.9999, 3, "300.000");

    expectFixed(0.09, 2, "0.09");
    expectFixed(0.09, 1, "0.1");
    expectFixed(0.29, 2, "0.29");
    expectFixed(0.29, 1, "0.3");
    expectFixed(0.99, 2, "0.99");
    expectFixed(0.99, 1, "1.0");
    expectFixed(2.99, 2, "2.99");
    expectFixed(2.99, 1, "3.0");
    expectFixed(9.99, 2, "9.99");
    expectFixed(9.99, 1, "10.0");
    expectFixed(29.99, 2, "29.99");
    expectFixed(29.99, 1, "30.0");
    expectFixed(99.99, 2, "99.99");
    expectFixed(99.99, 1, "100.0");
    expectFixed(299.99, 2, "299.99");
    expectFixed(299.99, 1, "300.0");

    expectFixed(0.9, 1, "0.9");
    expectFixed(0.9, 0, "1");
    expectFixed(2.9, 1, "2.9");
    expectFixed(2.9, 0, "3");
    expectFixed(9.9, 1, "9.9");
    expectFixed(9.9, 0, "10");
    expectFixed(29.9, 1, "29.9");
    expectFixed(29.9, 0, "30");
    expectFixed(99.9, 1, "99.9");
    expectFixed(99.9, 0, "100");
    expectFixed(299.9, 1, "299.9");
    expectFixed(299.9, 0, "300");
}

test "fixed rounding result zero" {
    expectFixed(0.004, 3, "0.004");
    expectFixed(0.004, 2, "0.00");
    expectFixed(0.4, 1, "0.4");
    expectFixed(0.4, 0, "0");
    expectFixed(0.5, 1, "0.5");
    expectFixed(0.5, 0, "0");
}

test "fixed regression #1" {
    expectFixed(7.018232e-82, 6, "0.000000");
}