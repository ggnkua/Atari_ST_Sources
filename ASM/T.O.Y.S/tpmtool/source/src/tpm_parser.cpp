// tpm_parser.cpp - TPM file format parser implementation

#include "tpm.hpp"
#include "digi_extractor.hpp"
#include <cstring>
#include <algorithm>
#include <set>

namespace tpmtool::tpm {

std::expected<const ModuleInfo, Error> parse(const std::vector<uint8_t>& data) {
    // Minimum size check (Module without vectors)
    if (data.size() < FIXED_MIN_MODULE_SIZE) {
        return std::unexpected(Error{EINVAL, "File too small to be a valid TPM module"});
    }

    // Cast to Module structure to read fixed fields (big-endian data)
    const auto* mod_ptr = reinterpret_cast<const Module*>(data.data());

    // Verify magic header "GODMOD30"
    constexpr uint8_t expected_magic[] = {'G', 'O', 'D', 'M', 'O', 'D', '3', '0'};
    if (std::memcmp(mod_ptr->header, expected_magic, 8) != 0) {
        return std::unexpected(Error{EINVAL, "Invalid TPM header magic (expected 'GODMOD30')"});
    }

    ModuleInfo info{};

    // Copy all fixed fields from module
    std::memcpy((BaseModule*)&info.module, data.data(), FIXED_MIN_MODULE_SIZE);

    // Find max pattern index from sequence and build used_patterns set
    uint8_t max_pattern = 0;

    for (int i = 0; i < info.module.song_length && i < 256; ++i) {
        uint8_t pat = info.module.sequence_data[i];
        info.used_patterns.insert(pat);
        if (pat > max_pattern) {
            max_pattern = pat;
        }
    }

    uint8_t num_patterns = max_pattern + 1;

    // Parse patterns into module.patterns vector
    size_t pattern_offset = FIXED_MIN_MODULE_SIZE;
    constexpr size_t PATTERN_SIZE = sizeof(Pattern);

    info.module.patterns.reserve(num_patterns);
    for (uint8_t i = 0; i < num_patterns; ++i) {
        if (pattern_offset + PATTERN_SIZE > data.size()) {
            return std::unexpected(Error{EINVAL, "Not enough data for patterns"});
        }

        Pattern pattern;
        std::memcpy(&pattern, &data[pattern_offset], PATTERN_SIZE);
        info.module.patterns.push_back(pattern);
        pattern_offset += PATTERN_SIZE;
    }

    // Parse digi sounds into module.digi_data vector
    auto all_digi = digi::extract_all_digi_sounds(data, mod_ptr);
    if (all_digi) {
        info.module.digi_data = std::move(*all_digi);
    } else {
        // If extraction fails, create empty digi slots
        info.module.digi_data.resize(NUM_INSTRUMENTS, std::vector<uint8_t>{0x80});
    }

    // Find used instruments by scanning patterns
    for (uint8_t pat : info.used_patterns) {
        if (pat >= info.module.patterns.size()) continue;

        const auto& pattern = info.module.patterns[pat];
        for (int row = 0; row < 64; ++row) {
            for (int chan = 0; chan < 4; ++chan) {
                uint8_t inst_num = pattern[row][chan].inst;
                if (inst_num >= 1 && inst_num <= NUM_INSTRUMENTS) {
                    info.used_instruments.insert(inst_num);
                }
            }
        }
    }

    // Find used digi sounds (0-based slot indices)
    for (uint8_t inst_num : info.used_instruments) {
        const auto& inst = info.module.instruments[inst_num - 1];  // 1-based to 0-based
        uint8_t slot = inst.share_digi;

        // Check if this slot has actual data (not just 0x80)
        if (slot < info.module.digi_data.size() && info.module.digi_data[slot].size() > 1) {
            info.used_digi_sounds.insert(slot);
        }
    }

    return info;
}

} // namespace tpmtool::tpm
