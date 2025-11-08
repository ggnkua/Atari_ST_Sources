// sndh_parser.cpp - SNDH file format parser implementation

#include "sndh.hpp"
#include <cstring>
#include <algorithm>

namespace tpmtool::sndh {

// Helper: Read null-terminated string from buffer
// Returns the string and the number of bytes to skip (including null terminators and padding)
static std::pair<std::string, size_t> read_cstring(const uint8_t* data, size_t max_len) {
    max_len = std::min(max_len, (size_t)512);
    auto end = std::find(data, data + max_len, '\0');
    size_t len = end - data;
    std::string str(reinterpret_cast<const char*>(data), len);

    // Skip past the string and its null terminator
    size_t skip = len + 1;

    // Skip any additional null bytes (alignment padding)
    while (skip < max_len && data[skip] == '\0') {
        skip++;
    }

    return {str, skip};
}

// Helper: Parse numeric value from tag (e.g., "##04" -> 4)
static bool parse_tag_number(const char* tag, uint32_t& out) {
    // Skip first 2 chars (tag prefix), parse remaining digits
    const char* p = tag + 2;
    out = 0;
    while (*p >= '0' && *p <= '9') {
        out = out * 10 + (*p - '0');
        p++;
    }
    return p != tag + 2;  // At least one digit parsed
}

std::expected<const SNDHInfo, Error> parse(const std::vector<uint8_t>& data) {
    if (data.size() < sizeof(SNDHHeader)) {
        return std::unexpected(Error{EINVAL, "File too small to be a valid SNDH file"});
    }

    SNDHInfo info{};

    // Copy header
    std::memcpy(&info.header, data.data(), sizeof(SNDHHeader));

    // Verify SNDH magic
    if (std::memcmp(info.header.magic, "SNDH", 4) != 0) {
        return std::unexpected(Error{EINVAL, "Invalid SNDH magic header"});
    }

    // Parse tags starting at offset 16
    size_t offset = sizeof(SNDHHeader);
    size_t last_known_tag_offset = offset;

    while (offset + 4 <= data.size()) {
        // Safety check: if we haven't found a known tag in 512 bytes, bail out
        if (offset - last_known_tag_offset > 512) {
            return std::unexpected(Error{EINVAL, "SNDH header parsing failed: no valid tag found within 512 bytes"});
        }

        // Read tag ID (4 bytes)
        const char* tag = reinterpret_cast<const char*>(&data[offset]);

        // Check for end of tags (HDNS or HNDS - both variants exist)
        if (std::memcmp(tag, "HDNS", 4) == 0 || std::memcmp(tag, "HNDS", 4) == 0) {
            offset += 4;
            break;  // End of header
        }

        // Parse tag based on first characters
        if (std::memcmp(tag, "TITL", 4) == 0) {
            last_known_tag_offset = offset;
            offset += 4;
            auto [str, skip] = read_cstring(&data[offset], data.size() - offset);
            info.tags.title = str;
            offset += skip;
        } else if (std::memcmp(tag, "COMM", 4) == 0) {
            last_known_tag_offset = offset;
            offset += 4;
            auto [str, skip] = read_cstring(&data[offset], data.size() - offset);
            info.tags.composer = str;
            offset += skip;
        } else if (std::memcmp(tag, "RIPP", 4) == 0) {
            last_known_tag_offset = offset;
            offset += 4;
            auto [str, skip] = read_cstring(&data[offset], data.size() - offset);
            info.tags.ripper = str;
            offset += skip;
        } else if (std::memcmp(tag, "CONV", 4) == 0) {
            last_known_tag_offset = offset;
            offset += 4;
            auto [str, skip] = read_cstring(&data[offset], data.size() - offset);
            info.tags.converter = str;
            offset += skip;
        } else if (std::memcmp(tag, "YEAR", 4) == 0) {
            last_known_tag_offset = offset;
            offset += 4;
            auto [str, skip] = read_cstring(&data[offset], data.size() - offset);
            info.tags.year = str;
            offset += skip;
        } else if (std::memcmp(tag, "##", 2) == 0) {
            last_known_tag_offset = offset;
            uint32_t num_subtunes;
            if (parse_tag_number(tag, num_subtunes)) {
                info.tags.num_subtunes = num_subtunes;
            }
            // Skip tag + null terminator + padding
            auto [str, skip] = read_cstring(&data[offset], data.size() - offset);
            offset += skip;
        } else if (std::memcmp(tag, "#!", 2) == 0) {
            last_known_tag_offset = offset;
            uint32_t default_subtune;
            if (parse_tag_number(tag, default_subtune)) {
                info.tags.default_subtune = default_subtune;
            }
            // Skip tag + null terminator + padding
            auto [str, skip] = read_cstring(&data[offset], data.size() - offset);
            offset += skip;
        } else if (std::memcmp(tag, "TA", 2) == 0 || std::memcmp(tag, "TB", 2) == 0 ||
                   std::memcmp(tag, "TC", 2) == 0 || std::memcmp(tag, "TD", 2) == 0) {
            last_known_tag_offset = offset;
            // Timer tags are variable length (e.g., TC50, TC200, TD100)
            // Read from current position to null terminator
            auto [timer_value, skip] = read_cstring(&data[offset], data.size() - offset);
            if (tag[0] == 'T') {
                if (tag[1] == 'A') info.tags.timer_a = timer_value;
                else if (tag[1] == 'B') info.tags.timer_b = timer_value;
                else if (tag[1] == 'C') info.tags.timer_c = timer_value;
                else if (tag[1] == 'D') info.tags.timer_d = timer_value;
            }
            offset += skip;
        } else if (std::memcmp(tag, "!V", 2) == 0) {
            last_known_tag_offset = offset;
            info.tags.vbl = std::string(tag, 4);
            // Skip tag + null terminator + padding
            auto [str, skip] = read_cstring(&data[offset], data.size() - offset);
            offset += skip;
        } else if (std::memcmp(tag, "TIME", 4) == 0) {
            last_known_tag_offset = offset;
            // TIME tag - skip tag (4) + 2 bytes of binary data
            offset += 6;
        } else if (std::memcmp(tag, "!#SN", 4) == 0) {
            last_known_tag_offset = offset;
            // !#SN tag - subtune name table (binary data, not null-terminated)
            // Format: !#SN + N words (offsets) + null-terminated strings
            offset += 4;
            size_t table_start = offset;

            // Determine number of subtunes from ##?? tag
            uint32_t num_subtunes = info.tags.num_subtunes.value_or(1);

            // Read offset table (N words)
            std::vector<uint16_t> offsets;
            for (uint32_t i = 0; i < num_subtunes && offset + 2 <= data.size(); ++i) {
                uint16_t word_offset = (static_cast<uint16_t>(data[offset]) << 8) | data[offset + 1];
                offsets.push_back(word_offset);
                offset += 2;
            }

            // Read strings using offsets
            for (uint16_t word_offset : offsets) {
                size_t string_pos = table_start - 4 + word_offset;  // Offset is from start of tag
                if (string_pos < data.size()) {
                    auto [name, skip] = read_cstring(&data[string_pos], data.size() - string_pos);
                    info.tags.subtune_names.push_back(name);
                }
            }

            // Skip to HDNS
            while (offset + 4 <= data.size()) {
                if (std::memcmp(&data[offset], "HDNS", 4) == 0 ||
                    std::memcmp(&data[offset], "HNDS", 4) == 0) {
                    break;
                }
                offset++;
            }
        } else {
            // Unknown tag, skip it (including any padding)
            auto [str, skip] = read_cstring(&data[offset], data.size() - offset);
            offset += skip;
        }
    }

    // Search for embedded TPM or TPN after header
    info.embedded_type = EmbeddedType::None;
    info.embedded_offset = offset;
    info.embedded_file = std::monostate{};

    // Align to even boundary before searching (IFF chunks are word-aligned)
    if (offset % 2 != 0) {
        offset++;
    }

    // Search for "GODMOD30" (TPM) or "FORM" "TPN1" (TPN)
    // Search on word boundaries (even offsets) to avoid false matches in player code
    while (offset + 12 <= data.size()) {
        if (std::memcmp(&data[offset], "GODMOD30", 8) == 0) {
            info.embedded_type = EmbeddedType::TPM;
            info.embedded_offset = offset;

            // Parse embedded TPM
            std::vector<uint8_t> embedded_data(data.begin() + offset, data.end());
            auto tpm_result = tpm::parse(embedded_data);
            if (tpm_result) {
                info.embedded_file = std::move(*tpm_result);
            }
            break;
        }
        if (std::memcmp(&data[offset], "FORM", 4) == 0 &&
            std::memcmp(&data[offset + 8], "TPN1", 4) == 0) {
            info.embedded_type = EmbeddedType::TPN;
            info.embedded_offset = offset;

            // Parse embedded TPN
            std::vector<uint8_t> embedded_data(data.begin() + offset, data.end());
            auto tpn_result = tpn::parse(embedded_data);
            if (tpn_result) {
                info.embedded_file = std::move(*tpn_result);
            }
            break;
        }
        offset += 2;  // Skip by 2 bytes (word boundary)
    }

    return info;
}

} // namespace tpmtool::sndh
