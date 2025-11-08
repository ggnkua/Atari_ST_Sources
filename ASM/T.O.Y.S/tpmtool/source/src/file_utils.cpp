// file_utils.cpp - File I/O utilities implementation

#include "file_utils.hpp"
#include <cstdio>
#include <cerrno>
#include <cstring>

namespace tpmtool {

std::expected<std::vector<uint8_t>, Error> read_file(const std::string& path) {
    FILE* file = std::fopen(path.c_str(), "rb");
    if (!file) {
        return std::unexpected(Error{errno, std::string("Failed to open file: ") + std::strerror(errno)});
    }

    // Get file size
    if (std::fseek(file, 0, SEEK_END) != 0) {
        int err = errno;
        std::fclose(file);
        return std::unexpected(Error{err, std::string("Failed to seek file: ") + std::strerror(err)});
    }

    long size = std::ftell(file);
    if (size < 0) {
        int err = errno;
        std::fclose(file);
        return std::unexpected(Error{err, "Failed to determine file size"});
    }

    if (std::fseek(file, 0, SEEK_SET) != 0) {
        int err = errno;
        std::fclose(file);
        return std::unexpected(Error{err, std::string("Failed to seek to beginning: ") + std::strerror(err)});
    }

    std::vector<uint8_t> buffer(static_cast<size_t>(size));

    size_t bytes_read = std::fread(buffer.data(), 1, static_cast<size_t>(size), file);
    if (bytes_read != static_cast<size_t>(size)) {
        int err = errno;
        std::fclose(file);
        return std::unexpected(Error{err, std::string("Failed to read file: ") + std::strerror(err)});
    }

    std::fclose(file);
    return buffer;
}

std::expected<void, Error> write_file(const std::string& path, const std::vector<uint8_t>& data) {
    FILE* file = std::fopen(path.c_str(), "wb");
    if (!file) {
        return std::unexpected(Error{errno, std::string("Failed to open file for writing: ") + std::strerror(errno)});
    }

    size_t bytes_written = std::fwrite(data.data(), 1, data.size(), file);
    if (bytes_written != data.size()) {
        int err = errno;
        std::fclose(file);
        return std::unexpected(Error{err, std::string("Failed to write file: ") + std::strerror(err)});
    }

    if (std::fclose(file) != 0) {
        return std::unexpected(Error{errno, std::string("Failed to close file: ") + std::strerror(errno)});
    }

    return {};
}

} // namespace tpmtool
