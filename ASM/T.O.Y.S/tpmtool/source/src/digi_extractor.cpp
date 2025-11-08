// digi_extractor.cpp - Digital sound data extraction implementation

#include "digi_extractor.hpp"
#include <arpa/inet.h>  // for ntohl (big-endian conversion)
#include <cstring>

namespace tpmtool::digi {

std::expected<std::vector<uint8_t>, Error> extract_digi_sound(
    const std::vector<uint8_t>& tpm_data,
    const tpm::Module* module,
    uint8_t inst_index
) {
    if (inst_index >= tpm::NUM_INSTRUMENTS) {
        return std::unexpected(Error{EINVAL, "Instrument index out of range (0-31)"});
    }

    // Calculate the base offset for digi data
    // Digi data starts after the Module structure and all pattern data
    // We need to count how many patterns exist by scanning sequence_data
    uint8_t max_pattern = 0;
    for (int i = 0; i < module->song_length && i < 256; ++i) {
        if (module->sequence_data[i] > max_pattern) {
            max_pattern = module->sequence_data[i];
        }
    }
    uint8_t num_patterns = max_pattern + 1;

    // Use the fixed size of Module structure on disk (33990 bytes), not sizeof()
    // because Module now contains std::vector members which add extra bytes
    size_t digi_data_start = tpm::FIXED_MIN_MODULE_SIZE + (num_patterns * sizeof(tpm::Pattern));

    // Read the digi offset for this instrument (big-endian)
    uint32_t digi_offset_be;
    std::memcpy(&digi_offset_be, &module->digi_table[inst_index], sizeof(uint32_t));
    uint32_t digi_offset = ntohl(digi_offset_be);

    // Calculate absolute position in file
    size_t digi_position = digi_data_start + digi_offset;

    // Check bounds
    if (digi_position >= tpm_data.size()) {
        // No digi data or invalid offset - return minimal valid digi (just end marker)
        return std::vector<uint8_t>{0x80};
    }

    // Extract bytes until we find 0x80 end marker
    std::vector<uint8_t> digi_sound;
    for (size_t pos = digi_position; pos < tpm_data.size(); ++pos) {
        uint8_t byte = tpm_data[pos];
        digi_sound.push_back(byte);

        if (byte == 0x80) {
            // Found end marker
            break;
        }

        // Safety limit: prevent infinite loop on malformed data
        if (digi_sound.size() > 1024 * 1024) {  // 1MB limit
            return std::unexpected(Error{EINVAL, "Digi sound data exceeds reasonable size"});
        }
    }

    // Ensure we have at least the end marker
    if (digi_sound.empty() || digi_sound.back() != 0x80) {
        digi_sound.push_back(0x80);
    }

    return digi_sound;
}

std::expected<std::vector<std::vector<uint8_t>>, Error> extract_all_digi_sounds(
    const std::vector<uint8_t>& tpm_data,
    const tpm::Module* module
) {
    std::vector<std::vector<uint8_t>> all_digi_sounds;
    all_digi_sounds.reserve(tpm::NUM_INSTRUMENTS);

    for (uint8_t i = 0; i < tpm::NUM_INSTRUMENTS; ++i) {
        auto result = extract_digi_sound(tpm_data, module, i);
        if (!result) {
            return std::unexpected(result.error());
        }
        all_digi_sounds.push_back(std::move(*result));
    }

    return all_digi_sounds;
}

} // namespace tpmtool::digi
