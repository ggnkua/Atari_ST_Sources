// tpn_parser.cpp - TPN/IFF85 file format parser implementation

#include "tpn.hpp"
#include <algorithm>
#include <cstring>
#include <arpa/inet.h>  // for ntohl (big-endian conversion)

namespace tpmtool::tpn {

// Helper: Read 4CC at offset
static bool read_4cc(const std::vector<uint8_t>& data, size_t offset, char out[5]) {
    if (offset + 4 > data.size()) return false;
    std::memcpy(out, &data[offset], 4);
    out[4] = '\0';
    return true;
}

// Helper: Read uint32_t in big-endian
static bool read_u32be(const std::vector<uint8_t>& data, size_t offset, uint32_t& out) {
    if (offset + 4 > data.size()) return false;
    uint32_t value;
    std::memcpy(&value, &data[offset], 4);
    out = ntohl(value);
    return true;
}

std::expected<const MultiModuleInfo, Error> parse(const std::vector<uint8_t>& data) {
    if (data.size() < 12) {
        return std::unexpected(Error{EINVAL, "File too small to be a valid TPN file"});
    }

    // Parse FORM chunk
    char chunk_id[5];
    if (!read_4cc(data, 0, chunk_id) || std::strcmp(chunk_id, "FORM") != 0) {
        return std::unexpected(Error{EINVAL, "Missing FORM chunk header"});
    }

    uint32_t form_size;
    if (!read_u32be(data, 4, form_size)) {
        return std::unexpected(Error{EINVAL, "Invalid FORM size"});
    }

    // Check FORM type
    char form_type[5];
    if (!read_4cc(data, 8, form_type) || std::strcmp(form_type, "TPN1") != 0) {
        return std::unexpected(Error{EINVAL, "Invalid FORM type (expected 'TPN1')"});
    }

    MultiModuleInfo info{};
    size_t offset = 12;  // Start after FORM header
    size_t form_end = 8 + form_size;  // End of FORM chunk

    // Parse chunks until we find TPIS, extracting metadata along the way
    bool found_tpis = false;
    while (offset + 8 <= data.size() && offset < form_end) {
        if (!read_4cc(data, offset, chunk_id)) {
            return std::unexpected(Error{EINVAL, "Failed to read chunk ID"});
        }

        uint32_t chunk_size;
        if (!read_u32be(data, offset + 4, chunk_size)) {
            return std::unexpected(Error{EINVAL, "Failed to read chunk size"});
        }

        // Check for metadata chunks
        if (std::strcmp(chunk_id, "AUTH") == 0 || std::strcmp(chunk_id, "COMP") == 0) {
            // Extract composer (AUTH is new name, COMP is legacy)
            if (offset + 8 + chunk_size <= data.size() && chunk_size > 0) {
                size_t text_len = chunk_size - 1;  // Exclude null terminator
                info.composer = std::string(reinterpret_cast<const char*>(&data[offset + 8]), text_len);
            }
        } else if (std::strcmp(chunk_id, "(C) ") == 0) {
            // Extract copyright
            if (offset + 8 + chunk_size <= data.size() && chunk_size > 0) {
                size_t text_len = chunk_size - 1;  // Exclude null terminator
                info.copyright = std::string(reinterpret_cast<const char*>(&data[offset + 8]), text_len);
            }
        } else if (std::strcmp(chunk_id, "ANNO") == 0) {
            // Skip ANNO chunk (annotation of tool used to create file)
        } else if (std::strcmp(chunk_id, "TPIS") == 0) {
            found_tpis = true;
            break;
        }

        // Skip to next chunk (with IFF85 padding)
        offset += 8 + chunk_size;
        if (chunk_size & 1) offset++;  // IFF85 alignment
    }

    if (!found_tpis) {
        return std::unexpected(Error{EINVAL, "Missing TPIS chunk"});
    }

    // Now offset points to TPIS chunk

    uint32_t tpis_size;
    if (!read_u32be(data, offset + 4, tpis_size)) {
        return std::unexpected(Error{EINVAL, "Invalid TPIS size"});
    }

    // Read instrument_count and digi_slot_count from TPIS body
    if (offset + 8 + 2 > data.size()) {
        return std::unexpected(Error{EINVAL, "TPIS chunk truncated"});
    }
    info.instrument_set.instrument_count = data[offset + 8];      // After header[4] + size[4]
    info.instrument_set.digi_slot_count = data[offset + 8 + 1];   // Second byte

    // Parse instruments and digi sounds into instrument_set
    // TPIS structure: instrument_count[1] + digi_slot_count[1] + instruments[count * 1030] + digi_data[variable]
    size_t tpis_data_offset = offset + 8 + 2;  // Skip instrument_count + digi_slot_count
    size_t instruments_size = info.instrument_set.instrument_count * sizeof(Instrument);
    size_t digi_data_start = tpis_data_offset + instruments_size;
    size_t digi_data_end = offset + 8 + tpis_size;

    // Load instruments into instrument_set.instruments
    if (tpis_data_offset + instruments_size <= data.size()) {
        for (int i = 0; i < info.instrument_set.instrument_count; ++i) {
            Instrument inst;
            size_t inst_offset = tpis_data_offset + (i * sizeof(Instrument));
            std::memcpy(&inst, &data[inst_offset], sizeof(Instrument));
            info.instrument_set.instruments.push_back(inst);
        }
    }

    // Parse digi sounds into digi_data vector
    if (digi_data_start < digi_data_end) {
        size_t current = digi_data_start;
        for (int i = 0; i < info.instrument_set.digi_slot_count && current < digi_data_end; ++i) {
            size_t digi_start = current;
            // Find end marker (0x80)
            while (current < digi_data_end && data[current] != 0x80) {
                current++;
            }
            if (current < digi_data_end && data[current] == 0x80) {
                current++;  // Include the 0x80 marker
                // Store the digi data
                std::vector<uint8_t> digi_bytes(data.begin() + digi_start, data.begin() + current);
                info.instrument_set.digi_data.push_back(std::move(digi_bytes));
            }
        }
    }

    offset += 8 + tpis_size;  // Skip entire TPIS chunk
    if (tpis_size & 1) offset++;  // IFF85 alignment

    // Parse LIST chunk (containing songs)
    if (offset + 8 > data.size()) {
        return std::unexpected(Error{EINVAL, "Missing LIST chunk"});
    }

    if (!read_4cc(data, offset, chunk_id) || std::strcmp(chunk_id, "LIST") != 0) {
        return std::unexpected(Error{EINVAL, "Missing LIST chunk"});
    }

    uint32_t list_size;
    if (!read_u32be(data, offset + 4, list_size)) {
        return std::unexpected(Error{EINVAL, "Invalid LIST size"});
    }

    // Check LIST type
    char list_type[5];
    if (!read_4cc(data, offset + 8, list_type) || std::strcmp(list_type, "TPSN") != 0) {
        return std::unexpected(Error{EINVAL, "Invalid LIST type (expected 'TPSN')"});
    }

    offset += 12;  // Skip LIST header
    size_t list_end = offset + list_size - 4;  // -4 for the type field

    // Parse TPSN chunks (songs) within LIST
    while (offset < list_end && offset + 8 <= data.size()) {
        if (!read_4cc(data, offset, chunk_id)) break;

        // Check for NAME/TITL chunk (song title) before TPSN
        std::string song_title;
        if (std::strcmp(chunk_id, "NAME") == 0 || std::strcmp(chunk_id, "TITL") == 0) {
            // NAME is new name, TITL is legacy
            uint32_t name_size;
            if (!read_u32be(data, offset + 4, name_size)) {
                return std::unexpected(Error{EINVAL, "Invalid NAME/TITL size"});
            }

            // Extract title
            if (offset + 8 + name_size <= data.size() && name_size > 0) {
                size_t text_len = name_size - 1;  // Exclude null terminator
                song_title = std::string(reinterpret_cast<const char*>(&data[offset + 8]), text_len);
            }

            // Skip to next chunk
            offset += 8 + name_size;
            if (name_size & 1) offset++;  // IFF85 alignment

            // Read next chunk ID (should be TPSN)
            if (offset + 8 > data.size() || !read_4cc(data, offset, chunk_id)) {
                break;
            }
        }

        if (std::strcmp(chunk_id, "TPSN") != 0) {
            // Skip unknown chunks
            uint32_t skip_size;
            if (!read_u32be(data, offset + 4, skip_size)) {
                break;
            }
            offset += 8 + skip_size;
            if (skip_size & 1) offset++;
            continue;
        }

        uint32_t tpsn_size;
        if (!read_u32be(data, offset + 4, tpsn_size)) {
            return std::unexpected(Error{EINVAL, "Invalid TPSN size"});
        }

        // Read song data (after chunk header)
        size_t song_offset = offset + 8;
        if (song_offset + 4 > data.size()) {
            return std::unexpected(Error{EINVAL, "TPSN chunk truncated"});
        }

        SongInfo song{};
        song.title = song_title;  // Set the extracted title
        song.song.song_length = data[song_offset + 0];
        song.song.song_restart = data[song_offset + 1];
        song.song.tick_speed = data[song_offset + 2];
        song.song.pattern_count = data[song_offset + 3];

        // Copy pattern sequence into song.sequence_data (at offset 4 + 16 = 20 from song_offset)
        size_t sequence_offset = song_offset + 20;
        if (sequence_offset + 256 <= data.size()) {
            std::memcpy(song.song.sequence_data, &data[sequence_offset], 256);
        }

        // Scan pattern data to find used instruments
        // Pattern data starts after: song metadata (4) + groove_seq (16) + sequence_data (256) = 276
        size_t pattern_data_offset = song_offset + 276;
        constexpr size_t PATTERN_SIZE = 1024;
        constexpr size_t PATTERN_ENTRY_SIZE = 4;

        for (int pat = 0; pat < song.song.pattern_count; ++pat) {
            size_t pat_absolute_offset = pattern_data_offset + (pat * PATTERN_SIZE);

            if (pat_absolute_offset + PATTERN_SIZE > data.size()) {
                break;
            }

            // Scan all 64 rows, 4 channels per pattern
            for (int row = 0; row < 64; ++row) {
                for (int chan = 0; chan < 4; ++chan) {
                    size_t entry_offset = pat_absolute_offset + (row * 4 + chan) * PATTERN_ENTRY_SIZE;
                    uint8_t inst_num = data[entry_offset + 1];  // Instrument is byte 1 of PatternEntry

                    if (inst_num >= 1) {  // Valid instrument (1-based indexing, no upper bound check for TPN)
                        song.used_instruments.insert(inst_num);
                    }
                }
            }
        }

        // Find digi sounds used by this song's instruments
        // Read share_digi field (offset 51) from each used instrument
        for (uint8_t inst_num : song.used_instruments) {
            if (inst_num < 1 || inst_num > info.instrument_set.instrument_count) continue;

            // Instrument data starts at tpis_data_offset, each is 1030 bytes
            size_t inst_offset = tpis_data_offset + ((inst_num - 1) * sizeof(Instrument));  // 1-based to 0-based

            // Check bounds: need to read up to offset 51 (inclusive), so need inst_offset + 52 to be valid
            if (inst_offset >= data.size() || inst_offset + 52 > data.size()) continue;

            uint8_t share_digi = data[inst_offset + 51];  // share_digi field at offset 51

            // Check if this digi slot has actual data (not just empty marker)
            if (share_digi < info.instrument_set.digi_data.size() &&
                info.instrument_set.digi_data[share_digi].size() > 1) {
                song.used_digi_sounds.insert(share_digi);
            }
        }

        info.songs.push_back(song);

        offset += 8 + tpsn_size;
        if (tpsn_size & 1) offset++;  // IFF85 alignment
    }

    return info;
}

} // namespace tpmtool::tpn
