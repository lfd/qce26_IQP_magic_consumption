library(readr)
library(tikzDevice)

write_tex_plot <- function(plot, filename, width, height, poster=FALSE, standAlone = TRUE) {
  options(tikzDocumentDeclaration = c(
                                 "\\documentclass[aps,rpx,reprint]{revtex4-2}", 
                                 "\\usepackage[T1]{fontenc}",
                                 "\\usepackage[utf8]{inputenc}"
                                 ))
  tikz(file = filename, width = width, height = height, standAlone = standAlone)
  print(plot)

  dev.off()
}

read_data <- function(datafile) {

    df_unfiltered <- read_csv(datafile) |>
    group_by(gamma, shot) |>
    mutate(
        absdsre = c(NA, abs(diff(sre))),
        djsd = c(NA, diff(jsd)),
        dphFrOverlap = c(NA, diff(phFrOverlap)),
        dgd = c(NA, diff(2 * acos(overlap))),
        ddkl = c(NA, diff(dkl))
    ) |>
    ungroup() |>
    filter(!is.na(absdsre)) |>
    filter(!is.na(djsd)) |>
    filter(!is.na(dphFrOverlap)) |>
    filter(!is.na(dgd)) |>
    filter(!is.na(ddkl))

    return(df_unfiltered)
}

filter_outliers <- function(df) {
    precision = 0.00001

    return( df |> 
        filter(absdsre > precision) |>
        mutate(
            zabsdsre = abs(absdsre - mean(absdsre)) / sd(absdsre),
            zdjsd = abs(djsd - mean(djsd)) / sd(djsd),
            zdphFrOverlap = abs(dphFrOverlap - mean(dphFrOverlap)) / sd(dphFrOverlap),
            zddkl = abs(ddkl - mean(ddkl)) / sd(ddkl),
            zdgd = abs(dgd - mean(dgd)) / sd(dgd)
        ) |>
        filter(zabsdsre < 3) |>
        filter(zdjsd < 3) |>
        filter(zdphFrOverlap < 3) |>
        filter(zdgd < 3) |>
        filter(zddkl < 3) |>
        filter(abs(djsd) > precision)
    )

}
