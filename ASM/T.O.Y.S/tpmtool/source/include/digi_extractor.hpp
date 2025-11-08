// digi_extractor.hpp - Digital sound data extraction from TPM files

#pragma once

#include "tpm.hpp"
#include "file_utils.hpp"
#include <vector>
#include <expected>
#include <cstdint>

namespace tpmtool::digi {

// Extract digi sound data for a specific instrument index (0-31)
// Returns vector of bytes up to and including 0x80 end marker
std::expected<std::vector<uint8_t>, Error> extract_digi_sound(
    const std::vector<uint8_t>& tpm_data,
    const tpm::Module* module,
    uint8_t inst_index
);

// Extract all digi sounds (32 entries, even if empty)
// Returns vector with 32 entries, empty vectors for unused instruments
std::expected<std::vector<std::vector<uint8_t>>, Error> extract_all_digi_sounds(
    const std::vector<uint8_t>& tpm_data,
    const tpm::Module* module
);

} // namespace tpmtool::digi
