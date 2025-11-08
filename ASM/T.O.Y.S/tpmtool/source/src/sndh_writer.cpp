// sndh_writer.cpp - SNDH file writer implementation

#include "sndh.hpp"
#include <cstring>
#include <algorithm>

namespace tpmtool::sndh {

namespace {

// Embed player binary at compile time
static constexpr uint8_t PLAYER_BINARY[] = {
    #embed "../artifacts/player.bin"
};
static constexpr size_t PLAYER_SIZE = sizeof(PLAYER_BINARY);

// Validate player binary at compile time
static_assert(PLAYER_SIZE > 16, "Invalid player binary size");

// Write 16-bit big-endian value
void write_be16(std::vector<uint8_t>& buffer, uint16_t value) {
    buffer.push_back(static_cast<uint8_t>(value >> 8));
    buffer.push_back(static_cast<uint8_t>(value & 0xFF));
}

// Rewrite 16-bit big-endian value at specific position
void rewrite_be16(std::vector<uint8_t>& buffer, uint16_t value, size_t at) {
    buffer[at] = static_cast<uint8_t>(value >> 8);
    buffer[at + 1] = static_cast<uint8_t>(value & 0xFF);
}

// Write SNDH tag (free-form string)
void write_tag(std::vector<uint8_t>& buffer, const std::string& tag, bool null_terminate = true) {
    buffer.insert(buffer.end(), tag.begin(), tag.end());
    if (null_terminate) {
        buffer.push_back(0);
    }
}

// Align buffer to even byte boundary
void align_even(std::vector<uint8_t>& buffer) {
    if (buffer.size() % 2 != 0) {
        buffer.push_back(0);
    }
}

// Write m68k bra.w (branch word) instruction
// offset = target_address - (current_position + 2)
void write_branch(std::vector<uint8_t>& buffer, size_t branch_position, size_t target_address) {
    // Calculate offset relative to PC after opcode fetch
    // For bra.w, PC points to the extension word when calculating the offset
    int32_t offset = static_cast<int32_t>(target_address) - static_cast<int32_t>(branch_position + 2);

    // Encode as bra.w instruction: 0x6000 followed by 16-bit offset word
    rewrite_be16(buffer, 0x6000, branch_position);
    rewrite_be16(buffer, static_cast<uint16_t>(offset), branch_position + 2);
}

// Build !#SN subtune name table
void write_subtune_names(std::vector<uint8_t>& buffer, const std::vector<tpmtool::tpn::SongInfo>& songs) {
    // Skip writing !#SN table if all songs are unnamed
    bool all_empty = true;
    for (const auto& song : songs) {
        if (!song.title.empty()) {
            all_empty = false;
            break;
        }
    }
    if (all_empty) {
        return;
    }

    // Align to even boundary (required before !#SN)
    align_even(buffer);

    size_t table_start = buffer.size();

    // Write !#SN tag (no null terminator - followed by binary data)
    write_tag(buffer, "!#SN", false);

    // Reserve space for offset table (N words)
    size_t offset_table_start = buffer.size();
    for (size_t i = 0; i < songs.size(); ++i) {
        write_be16(buffer, 0);  // Placeholder
    }

    // Write each song title and record its offset
    for (size_t i = 0; i < songs.size(); ++i) {
        // Calculate offset from table_start
        size_t title_offset = buffer.size() - table_start;

        // Go back and write the offset
        size_t offset_pos = offset_table_start + (i * 2);
        rewrite_be16(buffer, static_cast<uint16_t>(title_offset), offset_pos);

        // Write title string (use "----" for unnamed songs)
        const std::string& title = songs[i].title.empty() ? "----" : songs[i].title;
        write_tag(buffer, title);
    }
}

} // anonymous namespace

std::expected<std::vector<uint8_t>, Error> serialize(
    const tpmtool::tpn::MultiModuleInfo& tpn_module,
    bool include_metadata
) {
    std::vector<uint8_t> buffer;

    // Reserve space for 3 branch instructions (12 bytes)
    // We'll fill these in later once we know the player position
    size_t branch_init = 0;
    size_t branch_shutdown = 4;
    size_t branch_frame = 8;
    buffer.resize(12, 0);

    // Write SNDH magic (no null terminator)
    write_tag(buffer, "SNDH", false);

    // Write song information
    size_t song_count = tpn_module.songs.size();

    if (include_metadata) {
        // Write TITL tag with first song's name (use "----" if empty)
        if (!tpn_module.songs.empty()) {
            const std::string& title = tpn_module.songs[0].title.empty() ? "----" : tpn_module.songs[0].title;
            write_tag(buffer, "TITL" + title);
        }

        // Write COMM tag (composer)
        if (!tpn_module.composer.empty()) {
            write_tag(buffer, "COMM" + tpn_module.composer);
        }

        // Write CONV tag (converter)
        write_tag(buffer, "CONVtpmtool v0.9");
    }

    if (song_count > 1) {
        // Multiple songs - use ##?? tag and !#SN subtune names
        char count_str[5];
        std::snprintf(count_str, sizeof(count_str), "##%02d", static_cast<int>(song_count));
        write_tag(buffer, count_str);
    }

    // Write TC200 tag (Timer C at 200Hz)
    write_tag(buffer, "TC200");

    if (include_metadata) {
        // Write YEAR tag (copyright)
        if (!tpn_module.copyright.empty()) {
            write_tag(buffer, "YEAR" + tpn_module.copyright);
        }

        // Write subtune name table (for multi-song files)
        if (song_count > 1) {
            write_subtune_names(buffer, tpn_module.songs);
        }
    }

    // Align to even boundary (required before closing HDNS tag)
    align_even(buffer);

    // Write HDNS tag (header end marker, no null terminator)
    write_tag(buffer, "HDNS", false);

    // Record player start position
    size_t player_start = buffer.size();

    // Embed player binary
    buffer.insert(buffer.end(), PLAYER_BINARY, PLAYER_BINARY + PLAYER_SIZE);

    // Serialize TPN data WITHOUT metadata (to avoid duplication with SNDH tags)
    auto tpn_data = tpmtool::tpn::serialize(tpn_module, false);
    if (!tpn_data) {
        return std::unexpected(tpn_data.error());
    }

    // Append TPN data
    buffer.insert(buffer.end(), tpn_data->begin(), tpn_data->end());

    // Now fill in the branch instructions
    // Player entry points are at fixed offsets: 0, 8, 12
    write_branch(buffer, branch_init, player_start + 0);      // playsys_sndh_init_indexed
    write_branch(buffer, branch_shutdown, player_start + 8);  // playsys_sndh_shutdown
    write_branch(buffer, branch_frame, player_start + 12);    // playsys_sndh_frame

    return buffer;
}

std::expected<void, Error> write(
    const std::string& filepath,
    const tpmtool::tpn::MultiModuleInfo& tpn_module,
    bool include_metadata
) {
    // Serialize to SNDH format
    auto data = sndh::serialize(tpn_module, include_metadata);
    if (!data) {
        return std::unexpected(data.error());
    }

    // Write to file
    return write_file(filepath, *data);
}

} // namespace tpmtool::sndh
