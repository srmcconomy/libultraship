#pragma once

// Stand-in for BS::thread_pool in the single threaded browser build. It is found ahead of
// the real header on the include path and runs every task immediately on the calling
// thread, so futures it returns are always ready.

#include <cstddef>
#include <cstdint>
#include <future>
#include <type_traits>
#include <utility>

namespace BS {

using priority_t = std::int_least16_t;

namespace pr {
constexpr priority_t highest = 32767;
constexpr priority_t high = 16383;
constexpr priority_t normal = 0;
constexpr priority_t low = -16384;
constexpr priority_t lowest = -32768;
} // namespace pr

class thread_pool {
  public:
    explicit thread_pool(std::size_t = 0) {
    }

    template <typename F, typename R = std::invoke_result_t<std::decay_t<F>>>
    std::future<R> submit_task(F&& task, priority_t = pr::normal) {
        std::promise<R> promise;
        try {
            if constexpr (std::is_void_v<R>) {
                task();
                promise.set_value();
            } else {
                promise.set_value(task());
            }
        } catch (...) {
            promise.set_exception(std::current_exception());
        }
        return promise.get_future();
    }

    template <typename F> void detach_task(F&& task, priority_t = pr::normal) {
        task();
    }

    void wait() {
    }

    void pause() {
    }

    void unpause() {
    }

    std::size_t get_thread_count() const {
        return 1;
    }
};

} // namespace BS
