// tpm.hpp - TPM (TTrak Module) file format structures and parser
// Auto-generated from player/SOS.S

#pragma once

#include <cstddef>
#include <cstdint>
#include <vector>
#include <set>
#include <expected>
#include "file_utils.hpp"

namespace tpmtool::tpm {

    // TPM is a flat binary format using big endian for storing one song
    // File consists of one Module struct and trailing digi sound data

    // Constants
    inline constexpr int NUM_INSTRUMENTS = 32;
        
    // Instrument structure (uncompressed format, COMPRESS=0)
    struct [[gnu::packed]] Instrument {
        uint8_t  data1[17];                  // Opaque data
        uint8_t  link_to;                    // inst_link_to_b
        uint8_t  data2[33];                  // Opaque data
        uint8_t  share_digi;                 // inst_share_digi_b
        uint8_t  data3[978];                 // Opaque data
        
        uint8_t  name[16];                   // inst_name
    };
    static_assert(sizeof(Instrument) == 1046);
    static_assert(offsetof(Instrument, link_to) == 17);
    static_assert(offsetof(Instrument, share_digi) == 51);
    
    // Pattern entry for one channel track
    struct [[gnu::packed]] PatternEntry {
        uint8_t  note;                       // td_note_b
        uint8_t  inst;                       // td_inst_b
        uint8_t  fx_type;                    // td_fx_type_b
        uint8_t  fx_val;                     // td_fx_val_b
    };
    static_assert(sizeof(PatternEntry) == 4);
    
    // Four entries per row, for four channels, only first three can play notes
    using PatternRow = PatternEntry[4];

    // 64 rows in one pattern - wrapped in struct for vector storage
    struct [[gnu::packed]] Pattern {
        PatternRow rows[64];

        // Array access operators for compatibility with C array syntax
        PatternRow& operator[](size_t idx) { return rows[idx]; }
        const PatternRow& operator[](size_t idx) const { return rows[idx]; }
    };
    static_assert(sizeof(Pattern) == 1024);
    
    using DigiData = std::vector<uint8_t>;

    // Module structure (uncompressed, COMPRESS=0)
    struct [[gnu::packed]] BaseModule {
        uint8_t  header[8];                  // mod_header
        uint8_t  song_title[16];             // mod_song_title
        uint8_t  composer[16];               // mod_composer
        
        uint8_t  song_length;                // mod_song_length_b
        uint8_t  song_restart;               // mod_song_restart_b
        uint8_t  tick_speed;                 // mod_tick_speed_b
        uint8_t  reserved[5];                // mod_resa
        
        uint8_t  groove_seq[16];             // mod_groove_seq
        
        uint16_t inst_table[NUM_INSTRUMENTS + 1];  // mod_inst_table_w (33 entries)
        
        uint32_t digi_table[NUM_INSTRUMENTS + 1];  // mod_digi_table_l (33 entries)
        
        uint8_t  sequence_data[256];         // mod_sequence_data
        
        // Uncompressed format only (COMPRESS=0)
        Instrument instruments[NUM_INSTRUMENTS];  // mod_instrument_data
                                                  // pattern_data follows here (variable length)
    };
    inline constexpr size_t FIXED_MIN_MODULE_SIZE = 33990;
    static_assert(sizeof(BaseModule) == FIXED_MIN_MODULE_SIZE);
    struct Module : BaseModule {
        std::vector<Pattern> patterns;
        std::vector<DigiData> digi_data;
    };
    // After the last pattern is the digi sound data.
    // Variable size, minimum one 0x80 byte per digi sound as end marker.

    // Parsed TPM file information
    struct ModuleInfo {
        Module module;

        std::set<uint8_t> used_patterns;     // Sorted list of unique pattern indices (0-based)
        std::set<uint8_t> used_instruments;  // Sorted list of instrument indices (1-based)
        std::set<uint8_t> used_digi_sounds;  // Sorted list of unique the digi sound indexes (0-based)
    };

    // Parse TPM file from memory buffer
    // Returns ModuleInfo on success, Error on failure
    std::expected<const ModuleInfo, Error> parse(const std::vector<uint8_t>& data);

} // namespace tpmtool::tpm
