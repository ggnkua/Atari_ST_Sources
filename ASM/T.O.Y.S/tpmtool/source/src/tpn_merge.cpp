// tpn_merge.cpp - Merge optimized TPN modules implementation

#include "tpn.hpp"
#include "shared.hpp"
#include <cstring>
#include <algorithm>
#include <cstdio>

namespace tpmtool::tpn {

namespace {

// Deep comparison helper: compares instrument data excluding link_to and share_digi fields
bool compare_instrument_data_only(const Instrument& inst1, const Instrument& inst2) {
    // Compare everything except link_to and share_digi
    constexpr size_t link_to_offset = offsetof(Instrument, link_to);
    constexpr size_t share_digi_offset = offsetof(Instrument, share_digi);
    static_assert(link_to_offset == 17, "link_to offset mismatch");
    static_assert(share_digi_offset == 51, "share_digi offset mismatch");

    // Compare bytes before link_to
    if (std::memcmp(&inst1, &inst2, link_to_offset) != 0) {
        return false;
    }
    // Compare bytes between link_to and share_digi
    if (std::memcmp(reinterpret_cast<const uint8_t*>(&inst1) + link_to_offset + 1,
                    reinterpret_cast<const uint8_t*>(&inst2) + link_to_offset + 1,
                    share_digi_offset - link_to_offset - 1) != 0) {
        return false;
    }
    // Compare bytes after share_digi
    if (std::memcmp(reinterpret_cast<const uint8_t*>(&inst1) + share_digi_offset + 1,
                    reinterpret_cast<const uint8_t*>(&inst2) + share_digi_offset + 1,
                    sizeof(Instrument) - share_digi_offset - 1) != 0) {
        return false;
    }
    return true;
}

// Find matching digi sound in existing digi_data
std::optional<uint8_t> find_matching_digi(
    const std::vector<uint8_t>& digi_sound,
    const std::vector<std::vector<uint8_t>>& existing_digi
) {
    for (size_t i = 0; i < existing_digi.size(); ++i) {
        if (existing_digi[i] == digi_sound) {
            return static_cast<uint8_t>(i);
        }
    }
    return std::nullopt;
}

// Find matching instrument in existing instrument set
// Returns 1-based instrument number if found
std::optional<uint8_t> find_matching_instrument(
    const Instrument& inst,
    const std::vector<uint8_t>& digi_sound,
    const InstrumentSet& existing
) {
    for (size_t i = 0; i < existing.instruments.size(); ++i) {
        // Compare instrument data (excluding link_to/share_digi)
        if (!compare_instrument_data_only(inst, existing.instruments[i])) {
            continue;
        }

        // Get the digi sound for this instrument
        uint8_t share_digi_slot = existing.instruments[i].share_digi;
        if (share_digi_slot >= existing.digi_data.size()) {
            // Invalid share_digi, treat as empty
            if (digi_sound.size() == 1 && digi_sound[0] == 0x80) {
                return static_cast<uint8_t>(i + 1);  // Convert to 1-based
            }
            continue;
        }

        // Compare digi sounds
        if (existing.digi_data[share_digi_slot] == digi_sound) {
            return static_cast<uint8_t>(i + 1);  // Convert to 1-based
        }
    }
    return std::nullopt;
}

} // anonymous namespace

MultiModuleInfo create() {
    MultiModuleInfo result;
    result.instrument_set.instrument_count = 0;
    result.instrument_set.digi_slot_count = 0;
    return result;
}

// Merge instruments and digi sounds with deduplication
// Returns remap tables for updating song references
std::expected<RemapTables, Error> merge_instruments(
    MultiModuleInfo& into,
    const MultiModuleInfo& from
) {
    if (gVerbose) {
        std::fprintf(stderr, "  Merging instruments:\n");
        std::fprintf(stderr, "    From: %d instruments, %d digi sounds\n",
                    static_cast<int>(from.instrument_set.instrument_count),
                    static_cast<int>(from.instrument_set.digi_slot_count));
        std::fprintf(stderr, "    Into: %d instruments, %d digi sounds\n",
                    static_cast<int>(into.instrument_set.instrument_count),
                    static_cast<int>(into.instrument_set.digi_slot_count));
    }

    RemapTables remap;

    // Step 1: Merge digi sounds with deduplication
    for (size_t i = 0; i < from.instrument_set.digi_data.size(); ++i) {
        const auto& digi = from.instrument_set.digi_data[i];

        // Try to find existing matching digi sound
        auto existing_idx = find_matching_digi(digi, into.instrument_set.digi_data);

        if (existing_idx) {
            // Found duplicate - use existing slot
            remap.digi_remap[static_cast<uint8_t>(i)] = *existing_idx;
        } else {
            // New unique digi sound - add it
            if (into.instrument_set.digi_data.size() >= MAX_DIGI_SOUNDS) {
                char buf[128];
                std::snprintf(buf, sizeof(buf),
                    "Too many unique digi sounds (max %d). Total: %zu",
                    MAX_DIGI_SOUNDS, into.instrument_set.digi_data.size() + 1);
                return std::unexpected(Error{EINVAL, std::string(buf)});
            }

            uint8_t new_slot = static_cast<uint8_t>(into.instrument_set.digi_data.size());
            into.instrument_set.digi_data.push_back(digi);
            remap.digi_remap[static_cast<uint8_t>(i)] = new_slot;
        }
    }

    // Update digi_slot_count
    into.instrument_set.digi_slot_count = static_cast<uint8_t>(into.instrument_set.digi_data.size());

    // Step 2: Merge instruments with deduplication
    for (size_t i = 0; i < from.instrument_set.instruments.size(); ++i) {
        Instrument inst = from.instrument_set.instruments[i];
        uint8_t old_inst_num = static_cast<uint8_t>(i + 1);  // 1-based

        // Get the digi sound for this instrument
        uint8_t old_share_digi = inst.share_digi;
        std::vector<uint8_t> digi_sound;
        if (old_share_digi < from.instrument_set.digi_data.size()) {
            digi_sound = from.instrument_set.digi_data[old_share_digi];
        } else {
            digi_sound = {0x80};  // Empty digi sound
        }

        // Remap share_digi to new slot BEFORE comparison
        auto digi_it = remap.digi_remap.find(old_share_digi);
        if (digi_it != remap.digi_remap.end()) {
            inst.share_digi = digi_it->second;
        } else {
            inst.share_digi = 0;  // Default to slot 0
        }

        // Try to find existing matching instrument
        auto existing_inst = find_matching_instrument(inst, digi_sound, into.instrument_set);

        if (existing_inst) {
            // Found duplicate - use existing instrument
            remap.instrument_remap[old_inst_num] = *existing_inst;
        } else {
            // New unique instrument - add it
            if (into.instrument_set.instruments.size() >= MAX_INSTRUMENTS) {
                char buf[128];
                std::snprintf(buf, sizeof(buf),
                    "Too many unique instruments (max %d). Total: %zu",
                    MAX_INSTRUMENTS, into.instrument_set.instruments.size() + 1);
                return std::unexpected(Error{EINVAL, std::string(buf)});
            }

            uint8_t new_inst_num = static_cast<uint8_t>(into.instrument_set.instruments.size() + 1);
            into.instrument_set.instruments.push_back(inst);
            remap.instrument_remap[old_inst_num] = new_inst_num;
        }
    }

    // Update instrument_count
    into.instrument_set.instrument_count = static_cast<uint8_t>(into.instrument_set.instruments.size());

    if (gVerbose) {
        std::fprintf(stderr, "    Result: %d instruments, %d digi sounds (after deduplication)\n",
                    static_cast<int>(into.instrument_set.instrument_count),
                    static_cast<int>(into.instrument_set.digi_slot_count));
    }

    // Step 3: Remap link_to fields in newly added instruments
    // We need to do this AFTER all instruments are added, since link_to may reference
    // an instrument that comes later in the list
    for (auto& inst : into.instrument_set.instruments) {
        uint8_t old_link_to = inst.link_to;
        if (old_link_to >= 1 && old_link_to <= MAX_INSTRUMENTS) {
            auto it = remap.instrument_remap.find(old_link_to);
            if (it != remap.instrument_remap.end()) {
                inst.link_to = it->second;
            } else {
                // link_to references an instrument not in 'from'
                // This should not happen if 'from' is properly optimized
                inst.link_to = 0;
            }
        }
    }

    return remap;
}

// Remap song's instrument references using provided remap tables
// Updates all instrument numbers in patterns
void remap_song(
    SongInfo& song,
    const RemapTables& remap
) {
    // Remap instrument numbers in patterns
    for (auto& pattern : song.song.patterns) {
        for (int row = 0; row < 64; ++row) {
            for (int chan = 0; chan < 4; ++chan) {
                uint8_t old_inst = pattern.rows[row][chan].inst;
                if (old_inst >= 1 && old_inst <= MAX_INSTRUMENTS) {
                    auto it = remap.instrument_remap.find(old_inst);
                    if (it != remap.instrument_remap.end()) {
                        pattern.rows[row][chan].inst = it->second;
                    } else {
                        // Instrument not in remap - this should not happen
                        pattern.rows[row][chan].inst = 0;
                    }
                }
            }
        }
    }

    // Update used_instruments set
    std::set<uint8_t> new_used_instruments;
    for (uint8_t old_inst : song.used_instruments) {
        auto it = remap.instrument_remap.find(old_inst);
        if (it != remap.instrument_remap.end()) {
            new_used_instruments.insert(it->second);
        }
    }
    song.used_instruments = std::move(new_used_instruments);

    // Update used_digi_sounds set
    std::set<uint8_t> new_used_digi;
    for (uint8_t old_slot : song.used_digi_sounds) {
        auto it = remap.digi_remap.find(old_slot);
        if (it != remap.digi_remap.end()) {
            new_used_digi.insert(it->second);
        }
    }
    song.used_digi_sounds = std::move(new_used_digi);
}

std::expected<void, Error> merge(
    MultiModuleInfo& into,
    const MultiModuleInfo& from
) {
    if (gVerbose) {
        std::fprintf(stderr, "  Merging %zu song(s) into multi-song TPN\n", from.songs.size());
    }

    // Merge metadata: take first non-empty composer and copyright
    if (into.composer.empty() && !from.composer.empty()) {
        into.composer = from.composer;
    }
    if (into.copyright.empty() && !from.copyright.empty()) {
        into.copyright = from.copyright;
    }

    // Merge instruments and get remap tables
    auto remap_result = merge_instruments(into, from);
    if (!remap_result) {
        return std::unexpected(remap_result.error());
    }

    const auto& remap = *remap_result;

    // Add each song from 'from', remapping references
    for (const auto& song_info : from.songs) {
        into.songs.push_back(song_info);
        remap_song(into.songs.back(), remap);
    }

    if (gVerbose) {
        std::fprintf(stderr, "  Total songs: %zu\n", into.songs.size());
    }

    return {};
}

} // namespace tpmtool::tpn
