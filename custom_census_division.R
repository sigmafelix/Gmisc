# description: reorganize states into custom regional divisions
Region	States
# Northwest	WA-OR-MT-ID-WY
# Southwest Pacific	CA-NV
# Southwest Mountain	AZ-NM-CO-UT
# West North Central North	ND-SD-MN
# West North Central South	NE-KS-IA-MO
# East North Central	WI-IL-IN-MI-OH
# West South Central West	OK-TX
# West South Central East	AR-LA-MS
# East South Central	KY-TN-AL
# South Atlantic South	SC-GA-FL
# South Atlantic North	NC-VA-WV-DC-MD-DE
# Middle Atlantic	NY-PA-NJ
# New England	RI-CT-MA-VT-NH-ME

pkgs <- c("tigris", "terra", "tidyr", "dplyr")
invisible(suppressWarnings(sapply(pkgs, library, character.only = TRUE)))

states <- tigris::states(year = 2020)
states <- vect(states)
states_main <- states[!states$GEOID %in% c("02", "15", "60", "66", "68", "69", "72", "78"), ]
mod_cenreg <- read.csv("./input/data/regional_divisions.csv")
mod_cenreg <- mod_cenreg |>
  tidyr::separate_wider_delim(
    col = "States",
    delim = "-",
    names = paste0("state_", sprintf("%02d", 1:6)),
    too_few = "align_start") |>
  tidyr::pivot_longer(cols = 2:7) |>
  dplyr::filter(!is.na(value)) |>
  dplyr::select(-name)
states_m <- merge(states_main, mod_cenreg, by.x = "STUSPS", by.y = "value")
mod_cr <- terra::aggregate(states_m, by = "Region") |>
  terra::project("EPSG:5070")

