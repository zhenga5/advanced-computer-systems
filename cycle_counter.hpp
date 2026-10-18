#pragma once
#include <linux/perf_event.h>
#include <sys/syscall.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <cstdint>
#include <cerrno>
#include <cstring>
#include <stdexcept>
#include <string>

// One fresh, disabled, thread-local hardware event per trial.
// API reference: https://man7.org/linux/man-pages/man2/perf_event_open.2.html
class CycleCounter {
    int fd_ = -1;
    static void fail(const char* what) {
        throw std::runtime_error(std::string(what) + ": " + std::strerror(errno));
    }
public:
    struct Reading { std::uint64_t cycles, enabled_ns, running_ns; };
    CycleCounter() {
        perf_event_attr attr{};
        attr.type = PERF_TYPE_HARDWARE;
        attr.size = sizeof(attr);
        attr.config = PERF_COUNT_HW_CPU_CYCLES;
        attr.disabled = 1;
        attr.pinned = 1;
        attr.exclude_kernel = 1;
        attr.exclude_hv = 1;
        attr.read_format = PERF_FORMAT_TOTAL_TIME_ENABLED | PERF_FORMAT_TOTAL_TIME_RUNNING;
        fd_ = static_cast<int>(syscall(SYS_perf_event_open, &attr, 0, -1, -1, PERF_FLAG_FD_CLOEXEC));
        if (fd_ < 0) fail("perf_event_open failed");
    }
    ~CycleCounter() { if (fd_ >= 0) close(fd_); }
    CycleCounter(const CycleCounter&) = delete;
    CycleCounter& operator=(const CycleCounter&) = delete;
    void start() {
        if (ioctl(fd_, PERF_EVENT_IOC_ENABLE, 0) < 0) fail("Counter enable failed");
    }
    Reading stop() {
        if (ioctl(fd_, PERF_EVENT_IOC_DISABLE, 0) < 0) fail("Counter disable failed");
        Reading r{};
        const auto bytes = read(fd_, &r, sizeof(r));
        if (bytes != sizeof(r)) throw std::runtime_error("Counter read failed or pinned event could not run");
        if (!r.cycles || !r.enabled_ns || !r.running_ns ||
            double(r.running_ns) / double(r.enabled_ns) < 0.99)
            throw std::runtime_error("Counter unavailable or running fraction below 99%; no result accepted");
        return r; // Raw counts; no frequency assumption or multiplex scaling.
    }
};
