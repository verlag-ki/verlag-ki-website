import Foundation
import Darwin

/// A monotonic clock including device sleep. No value from this clock is exported.
enum DeviceClock {
    static func now() -> TimeInterval {
        var info = mach_timebase_info_data_t()
        mach_timebase_info(&info)
        return Double(mach_continuous_time()) * Double(info.numer) / Double(max(info.denom, 1)) / 1_000_000_000
    }
}
