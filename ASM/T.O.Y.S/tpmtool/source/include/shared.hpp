// shared.hpp - Global shared flags and platform detection

#pragma once

namespace tpmtool {

// Platform detection constant
#ifdef __M68000__
inline constexpr bool gIsAtari = true;
#else
inline constexpr bool gIsAtari = false;
#endif

// Global verbose flag (disabled on Atari)
extern bool gVerbose;

} // namespace tpmtool
