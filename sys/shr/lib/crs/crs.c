#include <stdio.h>

#if defined(__clang__) || defined(__gcc__)
#define EXPORT __attribute__((visibility("default")))
#define IMPORT
#define INLINE __attribute__((always_inline)) inline
#define NOINLINE __attribute((noinline))
#elif defined(_MSC_VER)
#define EXPORT __declspec(dllexport)
#define IMPORT __declspec(dllimport)
#define INLINE __forceinline
#define _Static_assert static_assert
#else
#define EXPORT __attribute__((visibility("default")))
#define IMPORT
#define INLINE static inline
#define NOINLINE
#endif

char* CRS_str = "Hello World\n";

EXPORT char* hello() {
  return CRS_str;
}
