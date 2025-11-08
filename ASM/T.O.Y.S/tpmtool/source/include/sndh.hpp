// sndh.hpp - SNDH file format structures, parser, and writer

#pragma once

#include "tpm.hpp"
#include "tpn.hpp"
#include "file_utils.hpp"
#include <cstdint>
#include <string>
#include <vector>
#include <optional>
#include <expected>
#include <variant>

namespace tpmtool::sndh {

// SNDH header structure (first 16 bytes)
struct [[gnu::packed]] SNDHHeader {
    uint8_t init_music[4];      // bra.w init (offset 0)
    uint8_t exit_music[4];      // bra.w exit (offset 4)
    uint8_t play_music[4];      // bra.w play (offset 8)
    uint8_t magic[4];           // "SNDH" magic (offset 12)
};
static_assert(sizeof(SNDHHeader) == 16);

// Parsed SNDH tags
struct SNDHTags {
    std::optional<std::string> title;           // TITL
    std::optional<std::string> composer;        // COMM
    std::optional<std::string> ripper;          // RIPP
    std::optional<std::string> converter;       // CONV
    std::optional<uint32_t> num_subtunes;       // ##??
    std::optional<uint32_t> default_subtune;    // #!??
    std::optional<std::string> timer_a;         // TA???
    std::optional<std::string> timer_b;         // TB???
    std::optional<std::string> timer_c;         // TC???
    std::optional<std::string> timer_d;         // TD???
    std::optional<std::string> vbl;             // !V??
    std::optional<std::string> year;            // YEAR
    std::vector<std::string> subtune_names;     // #!SN
    std::vector<uint16_t> subtune_times;        // TIME
};

// Embedded file type
enum class EmbeddedType {
    None,
    TPM,
    TPN
};

// Complete SNDH file information
struct SNDHInfo {
    SNDHHeader header;
    SNDHTags tags;
    size_t embedded_offset;     // Offset to embedded TPM/TPN data
    EmbeddedType embedded_type;
    std::variant<std::monostate, tpm::ModuleInfo, tpn::MultiModuleInfo> embedded_file;
};
static_assert(std::is_same_v<std::monostate, std::variant_alternative_t<(size_t)EmbeddedType::None, decltype(SNDHInfo::embedded_file)>>, "Wrong index");
static_assert(std::is_same_v<tpm::ModuleInfo, std::variant_alternative_t<(size_t)EmbeddedType::TPM, decltype(SNDHInfo::embedded_file)>>, "Wrong index");
static_assert(std::is_same_v<tpn::MultiModuleInfo, std::variant_alternative_t<(size_t)EmbeddedType::TPN, decltype(SNDHInfo::embedded_file)>>, "Wrong index");

// Parse SNDH file from memory buffer
// Returns Info on success, Error on failure
std::expected<const SNDHInfo, Error> parse(const std::vector<uint8_t>& data);

// Serialize TPN module to SNDH format with embedded player
// The player binary is embedded at compile time via #embed
// If include_metadata is false, only essential tags are written (TC200, ##??, HDNS)
std::expected<std::vector<uint8_t>, Error> serialize(
    const tpn::MultiModuleInfo& tpn_module,
    bool include_metadata = true
);

// Write SNDH file to disk
std::expected<void, Error> write(
    const std::string& filepath,
    const tpn::MultiModuleInfo& tpn_module,
    bool include_metadata = true
);

} // namespace tpmtool::sndh
