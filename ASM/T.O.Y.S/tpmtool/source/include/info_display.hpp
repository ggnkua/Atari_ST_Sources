// info_display.hpp - Information display utilities

#pragma once

#include "tpm.hpp"
#include "tpn.hpp"
#include "sndh.hpp"

namespace tpmtool {

// Display TPM file information to stdout
void display_tpm_info(const tpm::ModuleInfo& info);

// Display TPN file information to stdout
void display_tpn_info(const tpn::MultiModuleInfo& info);

// Display SNDH file information to stdout
void display_sndh_info(const sndh::SNDHInfo& info);

} // namespace tpmtool
