// tpn_convert.cpp - Convert TPM modules to optimized TPN format

#include "tpn.hpp"
#include "shared.hpp"
#include <cstring>
#include <map>
#include <cstdio>

namespace tpmtool::tpn {

// Helper: trim trailing spaces and dashes from TPM string fields
static std::string trim_tpm_string(const uint8_t* data, size_t max_len) {
    size_t len = strnlen(reinterpret_cast<const char*>(data), max_len);
    std::string result(reinterpret_cast<const char*>(data), len);

    // Trim trailing spaces and dashes
    while (!result.empty() && (result.back() == ' ' || result.back() == '-')) {
        result.pop_back();
    }

    return result;
}

static std::map<uint8_t, uint8_t> make_remap(const std::set<uint8_t>& set, uint8_t start_index = 1) {
    std::map<uint8_t, uint8_t> remap;  // old# → new#
    uint8_t new_num = start_index;
    for (uint8_t old_num : set) {  // already sorted via set
        remap[old_num] = new_num++;
    }
    return remap;
}

std::expected<const MultiModuleInfo, Error> convert(
    const tpm::ModuleInfo& module
) {
    if (gVerbose) {
        std::fprintf(stderr, "  Converting TPM to TPN:\n");
        std::fprintf(stderr, "    Instruments: %zu used\n", module.used_instruments.size());
        std::fprintf(stderr, "    Patterns: %zu used\n", module.used_patterns.size());
    }

    // Step 1: Build remap tables
    if (gVerbose) {
        std::fprintf(stderr, "    Building remap tables...\n");
    }
    auto inst_remap = make_remap(module.used_instruments, 1);  // old inst# → new inst# (1-based)
    auto digi_remap = make_remap(module.used_digi_sounds, 0);  // old slot → new slot (0-based)
    auto pattern_remap = make_remap(module.used_patterns, 0);  // old pattern# → new pattern# (0-based)

    // Step 2: Build digi slot list and remap based on share_digi references
    // Collect all digi slots referenced by share_digi fields
    std::set<uint8_t> used_digi_slots;
    for (uint8_t old_inst : module.used_instruments) {
        const auto& inst = module.module.instruments[old_inst - 1];
        uint8_t slot = inst.share_digi;
        if (slot < tpm::NUM_INSTRUMENTS) {
            used_digi_slots.insert(slot);
        }
    }

    // Build digi deduplication map and remap table
    std::map<std::vector<uint8_t>, uint8_t> digi_dedup;  // digi_data → new slot
    digi_remap.clear();

    if (gVerbose) {
        std::fprintf(stderr, "    Deduplicating digi sounds (%zu referenced)...\n", used_digi_slots.size());
    }

    for (uint8_t old_slot : used_digi_slots) {
        std::vector<uint8_t> digi_data;
        if (old_slot < module.module.digi_data.size()) {
            digi_data = module.module.digi_data[old_slot];
        } else {
            digi_data = {0x80};  // Empty digi sound
        }

        // Check if we've seen this digi data before
        auto it = digi_dedup.find(digi_data);
        if (it != digi_dedup.end()) {
            // Reuse existing slot
            digi_remap[old_slot] = it->second;
        } else {
            // New unique digi sound
            uint8_t new_slot = static_cast<uint8_t>(digi_dedup.size());
            digi_dedup[digi_data] = new_slot;
            digi_remap[old_slot] = new_slot;
        }
    }

    // Step 3: Create InstrumentSet with deduplicated digi sounds
    if (gVerbose) {
        std::fprintf(stderr, "    Creating InstrumentSet: %zu instruments, %zu unique digi sounds\n",
                    module.used_instruments.size(), digi_dedup.size());
    }

    InstrumentSet inst_set;
    inst_set.instrument_count = static_cast<uint8_t>(module.used_instruments.size());
    inst_set.digi_slot_count = static_cast<uint8_t>(digi_dedup.size());

    // Copy digi sounds in order
    inst_set.digi_data.resize(digi_dedup.size());
    for (const auto& [digi_data, slot] : digi_dedup) {
        inst_set.digi_data[slot] = digi_data;
    }

    // Copy instruments in sorted order, remapping link_to and share_digi
    for (uint8_t old_inst : module.used_instruments) {
        Instrument new_inst;
        // Copy from TPM instrument (1046 bytes) to TPN instrument (1030 bytes, no name)
        std::memcpy(&new_inst, &module.module.instruments[old_inst - 1], sizeof(Instrument));

        // Remap link_to field
        if (new_inst.link_to >= 1 && new_inst.link_to <= tpm::NUM_INSTRUMENTS) {
            auto it = inst_remap.find(new_inst.link_to);
            new_inst.link_to = (it != inst_remap.end()) ? it->second : 0;
        }

        // Remap share_digi field
        if (new_inst.share_digi < tpm::NUM_INSTRUMENTS) {
            auto digi_it = digi_remap.find(new_inst.share_digi);
            if (digi_it != digi_remap.end()) {
                new_inst.share_digi = digi_it->second;
            } else {
                new_inst.share_digi = 0;
            }
        }

        inst_set.instruments.push_back(new_inst);
    }

    // Step 4: Create Song with remapped patterns and instruments
    Song song;
    song.song_length = module.module.song_length;
    song.song_restart = module.module.song_restart;
    song.tick_speed = module.module.tick_speed;
    song.pattern_count = static_cast<uint8_t>(module.used_patterns.size());
    std::memcpy(song.groove_seq, module.module.groove_seq, 16);

    // Remap sequence_data
    std::memset(song.sequence_data, 0, 256);
    for (uint8_t i = 0; i < song.song_length; ++i) {
        uint8_t old_pat = module.module.sequence_data[i];
        auto it = pattern_remap.find(old_pat);
        song.sequence_data[i] = (it != pattern_remap.end()) ? it->second : 0;
    }

    // Copy patterns in sorted order, remapping instrument numbers
    for (uint8_t old_pat : module.used_patterns) {
        if (old_pat >= module.module.patterns.size()) {
            continue;  // Skip invalid patterns
        }

        Pattern new_pattern;
        const auto& src_pattern = module.module.patterns[old_pat];

        for (int row = 0; row < 64; ++row) {
            for (int chan = 0; chan < 4; ++chan) {
                new_pattern.rows[row][chan] = src_pattern[row][chan];

                uint8_t old_inst = new_pattern.rows[row][chan].inst;
                if (old_inst >= 1 && old_inst <= tpm::NUM_INSTRUMENTS) {
                    auto it = inst_remap.find(old_inst);
                    new_pattern.rows[row][chan].inst = (it != inst_remap.end()) ? it->second : 0;
                }
            }
        }

        song.patterns.push_back(new_pattern);
    }

    // Step 5: Create SongInfo with used instruments/digi and metadata
    SongInfo song_info;
    song_info.song = song;

    // Extract song title from TPM (null-terminated, max 16 bytes, trim trailing spaces/dashes)
    song_info.title = trim_tpm_string(module.module.song_title, 16);

    // All instruments in the compacted instrument_set are used
    for (uint8_t i = 1; i <= inst_set.instrument_count; ++i) {
        song_info.used_instruments.insert(i);
    }

    // All digi slots in the compacted digi_data are used
    for (uint8_t i = 0; i < inst_set.digi_slot_count; ++i) {
        if (i < inst_set.digi_data.size() && inst_set.digi_data[i].size() > 1) {
            song_info.used_digi_sounds.insert(i);
        }
    }

    // Step 6: Create MultiModuleInfo with metadata
    MultiModuleInfo result;
    result.instrument_set = inst_set;
    result.songs.push_back(song_info);

    // Extract composer from TPM (null-terminated, max 16 bytes, trim trailing spaces/dashes)
    result.composer = trim_tpm_string(module.module.composer, 16);

    return result;
}

} // namespace tpmtool::tpn
