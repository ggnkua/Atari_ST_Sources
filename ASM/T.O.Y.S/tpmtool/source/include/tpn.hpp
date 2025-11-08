// tpn.hpp - TPN (TTrak Multi Module) file format structures and parser
// Manually constructed from tpm.hpp

#pragma once

#include "tpm.hpp"  // Include TPM format for shared pattern types
#include "file_utils.hpp"
#include <cstddef>
#include <cstdint>
#include <vector>
#include <string>
#include <set>
#include <map>
#include <expected>

namespace tpmtool::tpn {

    // TPN is an EA IFF 85 file for storing one shared instrument set and one or more songs
    // See TPN_FORMAT.md for details

    // Constants
    inline constexpr int MAX_INSTRUMENTS = 254; // (1-255)
    inline constexpr int MAX_DIGI_SOUNDS = 32;  // (0-31)

    // Instrument structure
    // Same as tpmtool::tpm::Instrument, excluding name field.
    struct [[gnu::packed]] Instrument {
        uint8_t  data1[17];                  // Opaque data
        uint8_t  link_to;                    // inst_link_to_b, instrument index
        uint8_t  data2[33];                  // Opaque data
        uint8_t  share_digi;                 // inst_share_digi_b
        uint8_t  data3[978];                 // Opaque data
    };
    static_assert(sizeof(Instrument) == 1030);
    static_assert(offsetof(Instrument, link_to) == 17);
    static_assert(offsetof(Instrument, share_digi) == 51);

    // Pattern types: aliased from TPM format to avoid duplication
    using PatternEntry = tpm::PatternEntry;
    using PatternRow = tpm::PatternRow;

    // 64 rows in one pattern
    // Wrapped in struct to allow std::vector storage
    struct [[gnu::packed]] Pattern {
        PatternEntry rows[64][4];
    };
    static_assert(sizeof(Pattern) == 1024);
    
    using DigiData = std::vector<uint8_t>;
    
    // Instrument set structure
    // Subset of tpmtool::tpm::Module, with data only relevant for instruments.
    struct [[gnu::packed]] BaseInstrumentSet {
        uint8_t  header[4];                  // instset_header, 4CC "TPIS"
        uint32_t size;                       // instset_size (Size of struct - 8)
        uint8_t  instrument_count;           // instset_count
        uint8_t  digi_slot_count;            // instset_digi_count (number of digi slots)
    };
    static_assert(sizeof(BaseInstrumentSet) == 10);
    struct InstrumentSet : BaseInstrumentSet {
        // When storing to file instruments is a flat instrument_count * sizeof(Instrument) data block
        std::vector<Instrument> instruments;  // instset_instrument_data

        // When storing to file digi_data is a flat digi_slot_count * <variable_size> data block
        // Each digi_data entry is at minimum a 0x80 end marker,
        std::vector<DigiData> digi_data;      // instset_digi_data
    };

    // Song structure
    // Subset of tpmtool::tpm::Module, with data only relevant for song data.
    struct [[gnu::packed]] BaseSong {
        uint8_t  header[4];                  // song_header, 4CC "TPSN"
        uint32_t size;                       // song_size (Size of struct - 8)
        
        uint8_t  song_length;                // song_song_length_b
        uint8_t  song_restart;               // song_song_restart_b
        uint8_t  tick_speed;                 // song_tick_speed_b
        uint8_t  pattern_count;              // song_pattern_count
        
        uint8_t  groove_seq[16];             // song_groove_seq
        
        uint8_t  sequence_data[256];         // song_sequence_data, song_length long list of pattern indexes, padded with zero
    };
    static_assert(sizeof(BaseSong) == 284);
    struct Song : BaseSong {
        // When storing to file pattern_data is a flat pattern_count * sizeof(Pattern) data block.
        std::vector<Pattern> patterns;       // song_pattern_data
    };

    // Parsed song information
    struct SongInfo {
        Song song;

        std::string title;                   // Title of song
        std::set<uint8_t> used_instruments;  // Instrument indices used in this song's patterns (1-based)
        std::set<uint8_t> used_digi_sounds;  // Digi slot indices used by this song's instruments (0-based)
    };

    // Parsed TPN file information
    struct MultiModuleInfo {
        InstrumentSet instrument_set;       // Shared instrument set info
        std::vector<SongInfo> songs;        // Info for each song

        std::string composer;               // Composer of songs, or empty
        std::string copyright;              // Copyright of songs, or empty
    };

    // Parse TPN file from memory buffer
    // Returns Info on success, Error on failure
    std::expected<const MultiModuleInfo, Error> parse(const std::vector<uint8_t>& data);

    // Convert TPM module to optimized TPN multi-module with one song
    // Creates fully compacted TPN with only used instruments/digi/patterns, remapped references
    std::expected<const MultiModuleInfo, Error> convert(
        const tpm::ModuleInfo& module
    );

    // Create an empty TPN multi-module
    MultiModuleInfo create();

    // Remap tables for merging instruments and digi sounds
    struct RemapTables {
        std::map<uint8_t, uint8_t> instrument_remap;  // old inst# → new inst#
        std::map<uint8_t, uint8_t> digi_remap;        // old slot → new slot
    };

    // Merge TPN multi-module into another with deduplication
    // Merges instruments and songs, remaps all references in patterns
    std::expected<void, Error> merge(
        MultiModuleInfo& into,
        const MultiModuleInfo& from
    );

    // Serialize TPN to byte array
    std::expected<std::vector<uint8_t>, Error> serialize(
        const MultiModuleInfo& multi_module,
        bool add_metadata = false
    );

    // Write complete TPN file
    std::expected<void, Error> write(
        const std::string& filepath,
        const MultiModuleInfo& multi_module,
        bool add_metadata = false
    );

} // namespace tpmtool::tpn
