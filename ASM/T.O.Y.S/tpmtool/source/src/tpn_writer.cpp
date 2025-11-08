// tpn_writer.cpp - TPN file format writer implementation

#include "tpn.hpp"
#include "shared.hpp"
#include <arpa/inet.h>
#include <cstring>
#include <cstdio>

namespace tpmtool::tpn {

static void write_be32(std::vector<uint8_t>& buffer, uint32_t value) {
    uint32_t be_value = htonl(value);
    const uint8_t* bytes = reinterpret_cast<const uint8_t*>(&be_value);
    buffer.insert(buffer.end(), bytes, bytes + 4);
}

static void write_4cc(std::vector<uint8_t>& buffer, const char* fourcc) {
    buffer.insert(buffer.end(), fourcc, fourcc + 4);
}

static void add_iff85_padding(std::vector<uint8_t>& buffer) {
    if (buffer.size() % 2 != 0) {
        buffer.push_back(0);  // Pad to even byte boundary
    }
}

// Write null-terminated string chunk
static void write_string_chunk(std::vector<uint8_t>& buffer, const char* fourcc, const std::string& text) {
    if (text.empty()) return;

    uint32_t chunk_size = static_cast<uint32_t>(text.length() + 1);  // +1 for null terminator
    write_4cc(buffer, fourcc);
    write_be32(buffer, chunk_size);
    buffer.insert(buffer.end(), text.begin(), text.end());
    buffer.push_back(0);  // Null terminator
    add_iff85_padding(buffer);
}

std::expected<std::vector<uint8_t>, Error> serialize(
    const MultiModuleInfo& multi_module,
    bool add_metadata
) {
    const auto& inst_set = multi_module.instrument_set;
    const auto& songs = multi_module.songs;

    if (songs.empty()) {
        return std::unexpected(Error{EINVAL, "Cannot serialize TPN with no songs"});
    }

    if (inst_set.instrument_count == 0) {
        return std::unexpected(Error{EINVAL, "Cannot serialize TPN with no instruments"});
    }

    if (gVerbose) {
        std::fprintf(stderr, "  Serializing TPN:\n");
        std::fprintf(stderr, "    Songs: %zu\n", songs.size());
        std::fprintf(stderr, "    Instruments: %d\n", static_cast<int>(inst_set.instrument_count));
        std::fprintf(stderr, "    Digi sounds: %d\n", static_cast<int>(inst_set.digi_slot_count));
    }

    std::vector<uint8_t> buffer;

    // Calculate metadata chunk sizes if requested
    uint32_t auth_chunk_size = 0;
    uint32_t copy_chunk_size = 0;
    uint32_t anno_chunk_size = 0;
    if (add_metadata) {
        if (!multi_module.composer.empty()) {
            uint32_t body_size = static_cast<uint32_t>(multi_module.composer.length() + 1);
            auth_chunk_size = 8 + body_size;  // 8-byte header + body
            if (body_size % 2 != 0) auth_chunk_size += 1;  // Padding
        }
        if (!multi_module.copyright.empty()) {
            uint32_t body_size = static_cast<uint32_t>(multi_module.copyright.length() + 1);
            copy_chunk_size = 8 + body_size;  // 8-byte header + body
            if (body_size % 2 != 0) copy_chunk_size += 1;  // Padding
        }
        // ANNO chunk is always written when metadata is enabled
        uint32_t anno_body_size = 8;  // "tpmtool" + null terminator
        anno_chunk_size = 8 + anno_body_size;  // 8-byte header + body
    }

    // Calculate TPIS chunk body size (actual data, not including IFF85 chunk padding)
    uint32_t tpis_body_size = 2;  // instrument_count + digi_slot_count
    tpis_body_size += static_cast<uint32_t>(inst_set.instruments.size()) * sizeof(Instrument);
    for (const auto& digi : inst_set.digi_data) {
        tpis_body_size += static_cast<uint32_t>(digi.size());
    }

    // Calculate LIST chunk body size (actual data, not including padding)
    uint32_t list_body_size = 4;  // "TPSN" type identifier
    for (const auto& song_info : songs) {
        const auto& song = song_info.song;

        // Add NAME chunk size if metadata enabled and title present
        if (add_metadata && !song_info.title.empty()) {
            uint32_t title_body_size = static_cast<uint32_t>(song_info.title.length() + 1);
            uint32_t title_chunk_size = 8 + title_body_size;
            if (title_body_size % 2 != 0) title_chunk_size += 1;
            list_body_size += title_chunk_size;
        }

        uint32_t tpsn_body_size = 4 + 16 + 256;  // header fields + groove + sequence
        tpsn_body_size += static_cast<uint32_t>(song.patterns.size()) * sizeof(Pattern);

        // For nested chunks, we need to include their padding in the parent's size
        uint32_t tpsn_padded_size = tpsn_body_size;
        if (tpsn_body_size % 2 != 0) {
            tpsn_padded_size += 1;
        }
        list_body_size += 8 + tpsn_padded_size;  // 8-byte header + padded body
    }

    // Calculate FORM chunk body size (includes padded sizes of children)
    uint32_t tpis_padded_size = tpis_body_size;
    if (tpis_body_size % 2 != 0) {
        tpis_padded_size += 1;
    }

    uint32_t list_padded_size = list_body_size;
    if (list_body_size % 2 != 0) {
        list_padded_size += 1;
    }

    uint32_t form_body_size = 4;  // "TPN1" type identifier
    form_body_size += auth_chunk_size;  // AUTH chunk (if present)
    form_body_size += copy_chunk_size;  // (C)  chunk (if present)
    form_body_size += anno_chunk_size;  // ANNO chunk (if metadata enabled)
    form_body_size += 8 + tpis_padded_size;  // TPIS chunk with padding
    form_body_size += 8 + list_padded_size;  // LIST chunk with padding

    // Write FORM chunk
    write_4cc(buffer, "FORM");
    write_be32(buffer, form_body_size);
    write_4cc(buffer, "TPN1");

    // Write metadata chunks before TPIS
    if (add_metadata) {
        write_string_chunk(buffer, "AUTH", multi_module.composer);
        write_string_chunk(buffer, "(C) ", multi_module.copyright);
        write_string_chunk(buffer, "ANNO", "tpmtool");
    }

    // Write TPIS chunk
    write_4cc(buffer, "TPIS");
    write_be32(buffer, tpis_body_size);
    buffer.push_back(inst_set.instrument_count);
    buffer.push_back(inst_set.digi_slot_count);

    // Write instruments (without name field - 1030 bytes each)
    for (const auto& inst : inst_set.instruments) {
        const uint8_t* inst_bytes = reinterpret_cast<const uint8_t*>(&inst);
        buffer.insert(buffer.end(), inst_bytes, inst_bytes + sizeof(Instrument));
    }

    // Write digi data
    for (const auto& digi : inst_set.digi_data) {
        buffer.insert(buffer.end(), digi.begin(), digi.end());
    }

    // Add TPIS padding if needed
    add_iff85_padding(buffer);

    // Write LIST chunk
    write_4cc(buffer, "LIST");
    write_be32(buffer, list_body_size);
    write_4cc(buffer, "TPSN");

    // Write TPSN chunks
    for (const auto& song_info : songs) {
        const auto& song = song_info.song;

        // Write NAME chunk before TPSN if metadata enabled and title present
        if (add_metadata) {
            write_string_chunk(buffer, "NAME", song_info.title);
        }

        uint32_t tpsn_body_size = 4 + 16 + 256;  // header + groove + sequence
        tpsn_body_size += static_cast<uint32_t>(song.patterns.size()) * sizeof(Pattern);
        uint32_t tpsn_body_size_padded = tpsn_body_size;
        if (tpsn_body_size_padded % 2 != 0) {
            tpsn_body_size_padded += 1;
        }

        write_4cc(buffer, "TPSN");
        write_be32(buffer, tpsn_body_size);

        // Write song header fields
        buffer.push_back(song.song_length);
        buffer.push_back(song.song_restart);
        buffer.push_back(song.tick_speed);
        buffer.push_back(song.pattern_count);

        // Write groove sequence
        buffer.insert(buffer.end(), song.groove_seq, song.groove_seq + 16);

        // Write sequence data
        buffer.insert(buffer.end(), song.sequence_data, song.sequence_data + 256);

        // Write patterns
        for (const auto& pattern : song.patterns) {
            const uint8_t* pattern_bytes = reinterpret_cast<const uint8_t*>(&pattern.rows);
            buffer.insert(buffer.end(), pattern_bytes, pattern_bytes + sizeof(pattern.rows));
        }

        // Add TPSN padding if needed
        add_iff85_padding(buffer);
    }

    // Add final LIST padding if needed
    add_iff85_padding(buffer);

    return buffer;
}

std::expected<void, Error> write(
    const std::string& filepath,
    const MultiModuleInfo& multi_module,
    bool add_metadata
) {
    auto buffer = serialize(multi_module, add_metadata);
    if (!buffer) {
        return std::unexpected(buffer.error());
    }

    if (gVerbose) {
        std::fprintf(stderr, "  Writing TPN file: %s (%zu bytes)\n", filepath.c_str(), buffer->size());
    }

    return tpmtool::write_file(filepath, *buffer);
}

} // namespace tpmtool::tpn
