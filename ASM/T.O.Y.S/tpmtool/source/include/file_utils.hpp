// file_utils.hpp - File I/O utilities for tpmtool

#pragma once

#include <expected>
#include <string>
#include <utility>
#include <vector>
#include <cstdint>

namespace tpmtool {

// Error type: pair of errno and user-readable message
using Error = std::pair<int, std::string>;

// Read entire file into memory
// Returns vector of bytes on success, or error on failure
std::expected<std::vector<uint8_t>, Error> read_file(const std::string& path);

// Write data to file
// Returns void on success, or error on failure
std::expected<void, Error> write_file(const std::string& path, const std::vector<uint8_t>& data);

} // namespace tpmtool
