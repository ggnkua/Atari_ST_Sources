// main.cpp - tpmtool entry point

#include "file_utils.hpp"
#include "tpm.hpp"
#include "tpn.hpp"
#include "sndh.hpp"
#include "info_display.hpp"
#include "shared.hpp"
#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <libgen.h>
#include <unistd.h>
#include <cctype>

enum class FileType {
    Unknown,
    TPM,
    TPN,
    SNDH
};

// Helper function to check if argument matches any of the provided options
bool matches_any(const char* arg, std::initializer_list<const char*> options) {
    for (const char* opt : options) {
        if (std::strcmp(arg, opt) == 0) {
            return true;
        }
    }
    return false;
}

// Detect file type based on magic bytes
FileType detect_file_type(const std::vector<uint8_t>& data) {
    if (data.size() < 16) {
        return FileType::Unknown;
    }

    // Check for SNDH (magic at offset 12)
    if (std::memcmp(&data[12], "SNDH", 4) == 0) {
        return FileType::SNDH;
    }

    // Check for TPM ("GODMOD30" at offset 0)
    if (data.size() >= 8 && std::memcmp(&data[0], "GODMOD30", 8) == 0) {
        return FileType::TPM;
    }

    // Check for TPN (IFF FORM "TPN1")
    if (data.size() >= 12 &&
        std::memcmp(&data[0], "FORM", 4) == 0 &&
        std::memcmp(&data[8], "TPN1", 4) == 0) {
        return FileType::TPN;
    }

    return FileType::Unknown;
}

// Check if filename has .snd or .sndh extension (case-insensitive)
bool is_sndh_extension(const std::string& filename) {
    if (filename.size() < 4) {
        return false;
    }

    // Extract extension
    std::string ext = filename.substr(filename.size() - 4);

    // Convert to lowercase
    for (char& c : ext) {
        c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
    }

    // Check for .snd extension
    if (ext == ".snd") {
        return true;
    }

    // Check for .sndh extension (5 characters)
    if (filename.size() >= 5) {
        ext = filename.substr(filename.size() - 5);
        for (char& c : ext) {
            c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
        }
        if (ext == ".sndh") {
            return true;
        }
    }

    return false;
}

void print_usage(const char* prog_name) {
    // Strip path components, keep only the executable name
    const char* base_name = std::strrchr(prog_name, '/');
    if (base_name) {
        base_name++;  // Skip the '/'
    } else {
        // Try Windows-style path separator
        base_name = std::strrchr(prog_name, '\\');
        if (base_name) {
            base_name++;  // Skip the '\'
        } else {
            base_name = prog_name;  // No path separator found
        }
    }

    std::fprintf(stderr, "TPMTool v0.9 - (C)2025 T.O.Y.S.\n");
    std::fprintf(stderr, "\n");
    std::fprintf(stderr, "Usage:\n");
    std::fprintf(stderr, "  %s [options] <input>...\n", base_name);
    std::fprintf(stderr, "Options:\n");

#ifdef __MINT__
    // Atari TOS: use DOS-style /x options in help text
    std::fprintf(stderr, "  /i, --info          Display detailed information about input files\n");
    std::fprintf(stderr, "                      and exit.\n");
    std::fprintf(stderr, "  /o, --out <filename>\n");
    std::fprintf(stderr, "                      Convert input files to multi-song format.\n");
    std::fprintf(stderr, "                      Extension determines output: .tpn (TPN),\n");
    std::fprintf(stderr, "                      .snd/.sndh (SNDH).\n");
    std::fprintf(stderr, "  /n, --no-metadata   Exclude metadata (title, composer, copyright)\n");
    std::fprintf(stderr, "                      from output.\n");
    std::fprintf(stderr, "  /v, --verbose       Enable verbose logging during processing.\n");
    std::fprintf(stderr, "  /h, --help          Show this help message.\n");
#else
    // Unix/macOS: use standard -x options in help text
    std::fprintf(stderr, "  -i, --info          Display detailed information about input files\n");
    std::fprintf(stderr, "                      and exit.\n");
    std::fprintf(stderr, "  -o, --out <filename>\n");
    std::fprintf(stderr, "                      Convert input files to multi-song format.\n");
    std::fprintf(stderr, "                      Extension determines output: .tpn (TPN),\n");
    std::fprintf(stderr, "                      .snd/.sndh (SNDH).\n");
    std::fprintf(stderr, "  -n, --no-metadata   Exclude metadata (title, composer, copyright)\n");
    std::fprintf(stderr, "                      from output.\n");
    std::fprintf(stderr, "  -v, --verbose       Enable verbose logging during processing.\n");
    std::fprintf(stderr, "  -h, --help          Show this help message.\n");
#endif

    std::fprintf(stderr, "Arguments:\n");
    std::fprintf(stderr, "  <input>             One or more SND, TPM, or TPN files to\n");
    std::fprintf(stderr, "                      process.\n");
    std::fprintf(stderr, "\n");
    std::fprintf(stderr, "Examples:\n");

#ifdef __MINT__
    // Atari TOS examples with DOS-style options
    std::fprintf(stderr, "  %s /i song.tpm\n", base_name);
    std::fprintf(stderr, "  %s /o output.tpn input.tpm\n", base_name);
    std::fprintf(stderr, "  %s /v /n /o output.snd song1.tpm song2.snd song3.tpm\n", base_name);
#else
    // Unix/macOS examples with standard options
    std::fprintf(stderr, "  %s --info song.tpm\n", base_name);
    std::fprintf(stderr, "  %s --out output.tpn input.tpm\n", base_name);
    std::fprintf(stderr, "  %s -v -n -o output.snd song1.tpm song2.snd song3.tpm\n", base_name);
#endif
}

// Helper to wait for keypress on Atari before exit
void wait_for_keypress() {
#ifdef __MINT__
    std::fprintf(stderr, "\nPress Enter to exit...");
    std::getchar();
#endif
}

// Helper to print error, wait for keypress, and exit
[[noreturn]] void exit_error(const std::string& message) {
    std::fprintf(stderr, "%s\n", message.c_str());
    wait_for_keypress();
    std::exit(EXIT_FAILURE);
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        print_usage(argv[0]);
        wait_for_keypress();
        return EXIT_FAILURE;
    }

    bool info_mode = false;
    bool add_metadata = true;  // Default to including metadata
    std::string output_file;
    std::vector<std::string> input_files;

    // Parse arguments
    for (int i = 1; i < argc; ++i) {
        if (matches_any(argv[i], {"--info", "-i", "/i"})) {
            info_mode = true;
        } else if (matches_any(argv[i], {"--out", "-o", "/o"})) {
            if (i + 1 >= argc) {
                exit_error("Error: --out requires a filename argument");
            }
            output_file = argv[++i];
        } else if (matches_any(argv[i], {"--no-metadata", "-n", "/n"})) {
            add_metadata = false;
        } else if (matches_any(argv[i], {"--verbose", "-v", "/v"})) {
            tpmtool::gVerbose = true;
        } else if (matches_any(argv[i], {"--help", "-h", "/h"})) {
            print_usage(argv[0]);
            wait_for_keypress();
            return EXIT_SUCCESS;
        } else {
            input_files.push_back(argv[i]);
        }
    }

    if (input_files.empty()) {
        exit_error("Error: No input files specified");
    }

    // Output mode: merge songs to multi-song format (TPN or SNDH)
    if (!output_file.empty()) {
        // Detect output format by extension
        bool is_sndh = is_sndh_extension(output_file);
        bool is_tpn = false;

        if (!is_sndh) {
            // Check for .tpn extension (case-insensitive)
            if (output_file.size() >= 4) {
                std::string extension = output_file.substr(output_file.size() - 4);
                for (char& c : extension) {
                    c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
                }
                if (extension == ".tpn") {
                    is_tpn = true;
                }
            }
        }

        if (!is_sndh && !is_tpn) {
            exit_error("Error: Output file must have .tpn, .snd, or .sndh extension");
        }

        // Merge all input files using modular tpn_convert + tpn_merge
        auto merged = tpmtool::tpn::create();

        for (const auto& filepath : input_files) {
            if (tpmtool::gVerbose) {
                std::fprintf(stderr, "Processing: %s\n", filepath.c_str());
            }

            // Read file
            auto data = tpmtool::read_file(filepath);
            if (!data) {
                const auto& [err_code, err_msg] = data.error();
                exit_error("Error reading " + filepath + ": " + err_msg);
            }

            // Detect file type
            FileType type = detect_file_type(*data);

            if (tpmtool::gVerbose) {
                const char* type_name = "Unknown";
                switch (type) {
                    case FileType::TPM: type_name = "TPM"; break;
                    case FileType::TPN: type_name = "TPN"; break;
                    case FileType::SNDH: type_name = "SNDH"; break;
                    default: break;
                }
                std::fprintf(stderr, "  File type: %s\n", type_name);
            }

            tpmtool::tpn::MultiModuleInfo tpn_module;
            bool converted = false;

            switch (type) {
                case FileType::TPM: {
                    auto tpm_result = tpmtool::tpm::parse(*data);
                    if (!tpm_result) {
                        const auto& [err_code, err_msg] = tpm_result.error();
                        exit_error("Error parsing TPM " + filepath + ": " + err_msg);
                    }
                    auto tpn_result = tpmtool::tpn::convert(*tpm_result);
                    if (!tpn_result) {
                        const auto& [err_code, err_msg] = tpn_result.error();
                        exit_error("Error converting TPM " + filepath + ": " + err_msg);
                    }
                    tpn_module = *tpn_result;
                    converted = true;
                    break;
                }

                case FileType::TPN: {
                    auto tpn_result = tpmtool::tpn::parse(*data);
                    if (!tpn_result) {
                        const auto& [err_code, err_msg] = tpn_result.error();
                        exit_error("Error parsing TPN " + filepath + ": " + err_msg);
                    }
                    tpn_module = *tpn_result;
                    converted = true;
                    break;
                }

                case FileType::SNDH: {
                    auto sndh_result = tpmtool::sndh::parse(*data);
                    if (!sndh_result) {
                        const auto& [err_code, err_msg] = sndh_result.error();
                        exit_error("Error parsing SNDH " + filepath + ": " + err_msg);
                    }

                    if (sndh_result->embedded_type == tpmtool::sndh::EmbeddedType::TPM) {
                        // Extract embedded TPM and convert to TPN
                        auto& tpm_info = std::get<tpmtool::tpm::ModuleInfo>(sndh_result->embedded_file);
                        auto tpn_result = tpmtool::tpn::convert(tpm_info);
                        if (!tpn_result) {
                            const auto& [err_code, err_msg] = tpn_result.error();
                            exit_error("Error converting embedded TPM " + filepath + ": " + err_msg);
                        }
                        tpn_module = *tpn_result;
                    } else if (sndh_result->embedded_type == tpmtool::sndh::EmbeddedType::TPN) {
                        // Extract embedded TPN directly
                        tpn_module = std::get<tpmtool::tpn::MultiModuleInfo>(sndh_result->embedded_file);
                    } else {
                        exit_error("Error: SNDH file " + filepath + " does not contain embedded TPM or TPN");
                    }

                    // Override with SNDH metadata if present
                    if (sndh_result->tags.composer) {
                        tpn_module.composer = *sndh_result->tags.composer;
                    }
                    if (sndh_result->tags.year) {
                        tpn_module.copyright = *sndh_result->tags.year;
                    }

                    // Apply song titles from SNDH subtune names
                    if (!sndh_result->tags.subtune_names.empty()) {
                        // Multi-song: use subtune names
                        for (size_t i = 0; i < tpn_module.songs.size() && i < sndh_result->tags.subtune_names.size(); ++i) {
                            tpn_module.songs[i].title = sndh_result->tags.subtune_names[i];
                        }
                    } else if (sndh_result->tags.title && !tpn_module.songs.empty()) {
                        // Single song: use TITL tag
                        tpn_module.songs[0].title = *sndh_result->tags.title;
                    }

                    converted = true;
                    break;
                }

                case FileType::Unknown:
                    exit_error("Error: Unknown or unsupported file format: " + filepath);
            }

            if (converted) {
                auto merge_result = tpmtool::tpn::merge(merged, tpn_module);
                if (!merge_result) {
                    const auto& [err_code, err_msg] = merge_result.error();
                    exit_error("Error merging " + filepath + ": " + err_msg);
                }
            }
        }

        // Write output file based on format
        if (is_sndh) {
            // Write SNDH file
            auto write_result = tpmtool::sndh::write(output_file, merged, add_metadata);
            if (!write_result) {
                const auto& [err_code, err_msg] = write_result.error();
                exit_error("Error writing SNDH: " + err_msg);
            }

            // Display success information
            std::printf("Successfully created SNDH file\n");
        } else {
            // Write TPN file
            auto write_result = tpmtool::tpn::write(output_file, merged, add_metadata);
            if (!write_result) {
                const auto& [err_code, err_msg] = write_result.error();
                exit_error("Error writing TPN: " + err_msg);
            }

            // Display success information
            std::printf("Successfully created multi-song TPN\n");
        }
        std::printf("  Input files: %zu\n", input_files.size());
        for (const auto& file : input_files) {
            std::printf("    - %s\n", file.c_str());
        }
        std::printf("  Output: %s\n", output_file.c_str());
        std::printf("  Songs: %zu\n", merged.songs.size());
        std::printf("  Instruments: %d\n", static_cast<int>(merged.instrument_set.instrument_count));
        std::printf("  Digi sounds: %d\n", static_cast<int>(merged.instrument_set.digi_slot_count));

        wait_for_keypress();
        return EXIT_SUCCESS;
    }

    // Info mode (default)
    if (!info_mode) {
        print_usage(argv[0]);
        exit_error("Error: No mode specified. Use --info or --out");
    }

    // Process each input file
    for (const auto& filepath : input_files) {
        if (input_files.size() > 1) {
            std::printf("\n=== %s ===\n", filepath.c_str());
        }

        // Read file
        auto data_result = tpmtool::read_file(filepath);
        if (!data_result) {
            const auto& [err_code, err_msg] = data_result.error();
            std::fprintf(stderr, "Error: %s (code: %d)\n", err_msg.c_str(), err_code);
            continue;
        }

        const auto& data = *data_result;

        // Detect file type
        FileType type = detect_file_type(data);

        switch (type) {
            case FileType::TPM: {
                auto info_result = tpmtool::tpm::parse(data);
                if (!info_result) {
                    const auto& [err_code, err_msg] = info_result.error();
                    std::fprintf(stderr, "Error parsing TPM: %s\n", err_msg.c_str());
                } else {
                    tpmtool::display_tpm_info(*info_result);
                }
                break;
            }

            case FileType::TPN: {
                auto info_result = tpmtool::tpn::parse(data);
                if (!info_result) {
                    const auto& [err_code, err_msg] = info_result.error();
                    std::fprintf(stderr, "Error parsing TPN: %s\n", err_msg.c_str());
                } else {
                    tpmtool::display_tpn_info(*info_result);
                }
                break;
            }

            case FileType::SNDH: {
                auto info_result = tpmtool::sndh::parse(data);
                if (!info_result) {
                    const auto& [err_code, err_msg] = info_result.error();
                    std::fprintf(stderr, "Error parsing SNDH: %s\n", err_msg.c_str());
                } else {
                    tpmtool::display_sndh_info(*info_result);

                    // Display embedded format if present
                    if (info_result->embedded_type == tpmtool::sndh::EmbeddedType::TPM) {
                        std::printf("\n");
                        const auto& tpm_info = std::get<tpmtool::tpm::ModuleInfo>(info_result->embedded_file);
                        tpmtool::display_tpm_info(tpm_info);
                    } else if (info_result->embedded_type == tpmtool::sndh::EmbeddedType::TPN) {
                        std::printf("\n");
                        // Make a mutable copy to apply metadata
                        auto tpn_info = std::get<tpmtool::tpn::MultiModuleInfo>(info_result->embedded_file);

                        // Apply SNDH metadata to TPN songs
                        if (!info_result->tags.subtune_names.empty()) {
                            for (size_t i = 0; i < tpn_info.songs.size() && i < info_result->tags.subtune_names.size(); ++i) {
                                tpn_info.songs[i].title = info_result->tags.subtune_names[i];
                            }
                        } else if (info_result->tags.title && !tpn_info.songs.empty()) {
                            tpn_info.songs[0].title = *info_result->tags.title;
                        }

                        tpmtool::display_tpn_info(tpn_info);
                    }
                }
                break;
            }

            case FileType::Unknown:
                std::fprintf(stderr, "Error: Unknown or unsupported file format\n");
                break;
        }
    }

    wait_for_keypress();
    return EXIT_SUCCESS;
}
