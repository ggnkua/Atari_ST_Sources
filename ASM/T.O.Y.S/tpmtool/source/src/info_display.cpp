// info_display.cpp - Information display utilities implementation

#include "info_display.hpp"
#include <cstdio>
#include <cstring>
#include <iterator>

namespace tpmtool {

namespace {
    // Helper function to format a sorted sequence of uint8_t as ranges with usage info
    // Example: [1,2,3,5,7,8] -> " (6 used 1-3,5,7-8)"
    // Empty sequence produces no output
    // Works with any container via iterators (vector, set, etc.)
    template<typename Iterator>
    requires std::integral<typename std::iterator_traits<Iterator>::value_type>
    void format_ranges(Iterator begin, Iterator end) {
        if (begin == end) {
            return;
        }

        // Count elements
        size_t count = std::distance(begin, end);
        std::printf(" (%zu used ", count);

        bool first = true;
        auto it = begin;

        while (it != end) {
            if (!first) std::printf(",");
            first = false;

            uint8_t range_start = *it;
            uint8_t range_end = range_start;

            auto next_it = it;
            ++next_it;

            // Find consecutive values
            while (next_it != end && *next_it == range_end + 1) {
                range_end = *next_it;
                it = next_it;
                ++next_it;
            }

            // Output range or single value
            if (range_start == range_end) {
                std::printf("%d", static_cast<int>(range_start));
            } else {
                std::printf("%d-%d", static_cast<int>(range_start), static_cast<int>(range_end));
            }

            ++it;
        }

        std::printf(")");
    }

    // Helper function to format pattern sequences with compression
    // Example: [0,0,1,2,3,2,4] -> "0x2,1-3,2,4"
    // Uses "xN" for consecutive duplicates and "start-end" for ascending sequences
    void format_pattern_sequence(const std::vector<uint8_t>& sequence) {
        if (sequence.empty()) {
            return;
        }

        bool first = true;

        for (size_t i = 0; i < sequence.size(); ) {
            if (!first) std::printf(",");
            first = false;

            uint8_t current = sequence[i];

            // Check for consecutive duplicates
            size_t repeat_count = 1;
            while (i + repeat_count < sequence.size() && sequence[i + repeat_count] == current) {
                ++repeat_count;
            }

            // Check for ascending sequence (only if not duplicates)
            size_t sequence_length = 1;
            if (repeat_count == 1) {
                while (i + sequence_length < sequence.size() &&
                       sequence[i + sequence_length] == current + sequence_length) {
                    ++sequence_length;
                }
            }

            // Choose best representation
            if (repeat_count >= 2) {
                // Duplicates (2+): use "valueXcount"
                std::printf("%dx%zu", static_cast<int>(current), repeat_count);
                i += repeat_count;
            } else if (sequence_length >= 3) {
                // Ascending sequence of 3+: use "start-end"
                std::printf("%d-%d", static_cast<int>(current), static_cast<int>(current + sequence_length - 1));
                i += sequence_length;
            } else {
                // Single value or short run: just output the value
                std::printf("%d", static_cast<int>(current));
                ++i;
            }
        }
    }
} // anonymous namespace

void display_tpm_info(const tpm::ModuleInfo& info) {
    std::printf("File Type: TPM (TTrak Module)\n");

    // Extract header string
    std::printf("  Header: %.8s\n", reinterpret_cast<const char*>(info.module.header));

    // Extract song title and composer (null-terminated, max 16 bytes)
    char song_title[17] = {0};
    char composer[17] = {0};
    std::strncpy(song_title, reinterpret_cast<const char*>(info.module.song_title), 16);
    std::strncpy(composer, reinterpret_cast<const char*>(info.module.composer), 16);

    std::printf("  Song Title: %s\n", song_title);
    std::printf("  Composer: %s\n", composer);

    // Display instruments with usage details
    std::printf("  Instruments: 32");
    format_ranges(info.used_instruments.begin(), info.used_instruments.end());
    std::printf("\n");

    // Display digi sounds - count non-empty digi slots
    size_t total_digi_bytes = 0;
    for (const auto& digi : info.module.digi_data) {
        if (digi.size() > 1) {  // More than just 0x80 marker
            total_digi_bytes += digi.size();
        }
    }
    std::printf("  Digi Sounds: %zu (%zu bytes)", info.used_digi_sounds.size(), total_digi_bytes);
    format_ranges(info.used_digi_sounds.begin(), info.used_digi_sounds.end());
    std::printf("\n");

    std::printf("  Song Length: %d\n", static_cast<int>(info.module.song_length));
    std::printf("  Song Restart: %d\n", static_cast<int>(info.module.song_restart));
    std::printf("  Tick Speed: %d Hz\n", static_cast<int>(info.module.tick_speed));

    // Display patterns with usage details
    std::printf("  Patterns: %zu", info.module.patterns.size());
    format_ranges(info.used_patterns.begin(), info.used_patterns.end());
    std::printf("\n");

    // Display pattern sequence from module.sequence_data
    std::vector<uint8_t> pattern_sequence(
        info.module.sequence_data,
        info.module.sequence_data + info.module.song_length
    );
    std::printf("  Pattern List: ");
    format_pattern_sequence(pattern_sequence);
    std::printf("\n");
}

void display_tpn_info(const tpn::MultiModuleInfo& info) {
    std::printf("File Type: TPN (TTrak Multi Module)\n");
    if (!info.composer.empty()) {
        std::printf("  Composer: %s\n", info.composer.c_str());
    }
    if (!info.copyright.empty()) {
        std::printf("  Copyright: %s\n", info.copyright.c_str());
    }
    std::printf("  Instrument Count: %d\n", static_cast<int>(info.instrument_set.instrument_count));

    // Calculate digi statistics from instrument_set.digi_data
    std::vector<uint8_t> digi_slots;
    size_t total_digi_bytes = 0;
    for (size_t i = 0; i < info.instrument_set.digi_data.size(); ++i) {
        const auto& digi = info.instrument_set.digi_data[i];
        total_digi_bytes += digi.size();
        if (digi.size() > 1) {  // Non-empty digi (more than just 0x80)
            digi_slots.push_back(static_cast<uint8_t>(i));
        }
    }

    std::printf("  Digi Sounds: %d", static_cast<int>(info.instrument_set.digi_slot_count));
    format_ranges(digi_slots.begin(), digi_slots.end());
    std::printf(" %zu bytes\n", total_digi_bytes);
    std::printf("  Song Count: %zu\n", info.songs.size());

    for (size_t i = 0; i < info.songs.size(); ++i) {
        const auto& song = info.songs[i];
        std::printf("\n  Song #%zu", i + 1);
        if (!song.title.empty()) {
            std::printf(" - %s", song.title.c_str());
        }
        std::printf("\n");

        // Show instruments with usage details
        std::printf("    Instruments:");
        format_ranges(song.used_instruments.begin(), song.used_instruments.end());
        std::printf("\n");

        // Show digi sounds used by this song
        if (!song.used_digi_sounds.empty()) {
            std::printf("    Digi Sounds:");
            format_ranges(song.used_digi_sounds.begin(), song.used_digi_sounds.end());
            std::printf("\n");
        }

        std::printf("    Song Length: %d\n", static_cast<int>(song.song.song_length));
        std::printf("    Song Restart: %d\n", static_cast<int>(song.song.song_restart));
        std::printf("    Tick Speed: %d Hz\n", static_cast<int>(song.song.tick_speed));
        std::printf("    Patterns: %d\n", static_cast<int>(song.song.pattern_count));

        // Extract pattern sequence from song.sequence_data
        std::vector<uint8_t> pattern_sequence(
            song.song.sequence_data,
            song.song.sequence_data + song.song.song_length
        );
        std::printf("    Pattern List: ");
        format_pattern_sequence(pattern_sequence);
        std::printf("\n");
    }
}

void display_sndh_info(const sndh::SNDHInfo& info) {
    std::printf("File Type: SNDH (Atari ST Sound Format)\n");

    if (info.tags.title) {
        std::printf("  Title: %s\n", info.tags.title->c_str());
    }
    if (info.tags.composer) {
        std::printf("  Composer: %s\n", info.tags.composer->c_str());
    }
    if (info.tags.year) {
        std::printf("  Year: %s\n", info.tags.year->c_str());
    }
    if (info.tags.ripper) {
        std::printf("  Ripper: %s\n", info.tags.ripper->c_str());
    }
    if (info.tags.converter) {
        std::printf("  Converter: %s\n", info.tags.converter->c_str());
    }
    if (info.tags.num_subtunes) {
        std::printf("  Sub-tunes: %d\n", *info.tags.num_subtunes);
    }
    if (info.tags.default_subtune) {
        std::printf("  Default Sub-tune: %d\n", *info.tags.default_subtune);
    }

    // Display timer info
    if (info.tags.timer_a) {
        std::printf("  Timer A: %s\n", info.tags.timer_a->c_str());
    }
    if (info.tags.timer_b) {
        std::printf("  Timer B: %s\n", info.tags.timer_b->c_str());
    }
    if (info.tags.timer_c) {
        std::printf("  Timer C: %s\n", info.tags.timer_c->c_str());
    }
    if (info.tags.timer_d) {
        std::printf("  Timer D: %s\n", info.tags.timer_d->c_str());
    }
    if (info.tags.vbl) {
        std::printf("  VBL: %s\n", info.tags.vbl->c_str());
    }

    // Display embedded format
    std::printf("  Embedded Format: ");
    switch (info.embedded_type) {
        case sndh::EmbeddedType::TPM:
            std::printf("TPM (at offset %zu)\n", info.embedded_offset);
            break;
        case sndh::EmbeddedType::TPN:
            std::printf("TPN (at offset %zu)\n", info.embedded_offset);
            break;
        case sndh::EmbeddedType::None:
            std::printf("None detected\n");
            break;
    }
}

} // namespace tpmtool
