#' Extract inner borderline from given polygons
#' @description This function would be useful when users want to
#' get borderlines between contiguous polygons
#' @param poly repaired (e.g., running st_make_valid) polygons
#' @param unique_id unique id of each polygon
#' @importFrom dplyr filter
#' @importFrom dplyr rowwise
#' @importFrom dplyr mutate
#' @importFrom dplyr c_across
#' @importFrom dplyr ungroup
#' @importFrom dplyr all_of
#' @importFrom dplyr select
#' @importFrom sf st_cast
#' @importFrom sf st_intersection
#' @importFrom sf st_geometry_type
#' @importFrom rlang sym
#' @author Insang Song
#' @examples
#' library(sf)
#' library(dplyr)
#' library(rlang)
#' library(tigris)
#' options(sf_use_s2 = FALSE)
#'
#' rr <- tigris::states(year = 2020)
#' rri <- rr |>
#'   dplyr::filter(
#'     STATEFP <= 56 &
#'       (STATEFP != "02" & STATEFP != "15")
#'   )
#' rri <- st_make_valid(rri)
#' rrin <- st_innerborder(rri, "GEOID")
#' ## end of file ##
st_innerborder <- function(poly, unique_id) {
  poly <- poly |> dplyr::select(dplyr::all_of(unique_id))
  intfields <- c(unique_id, paste(unique_id, 1, sep = "."))
  polyb <- sf::st_cast(poly, "MULTILINESTRING")
  sf::st_intersection(polyb, polyb) |>
    dplyr::filter(!!sym(intfields[1]) != !!sym(intfields[2])) |>
    dplyr::rowwise() |>
    dplyr::mutate(uniquepair = paste0(sort(dplyr::c_across(!!sym(intfields[1]):!!sym(intfields[2]))), collapse = "|")) |>
    dplyr::ungroup() |>
    dplyr::filter(!duplicated(uniquepair)) |>
    dplyr::filter(sf::st_geometry_type(!!sym(attr(., "sf_column_name"))) != "POINT")
}

