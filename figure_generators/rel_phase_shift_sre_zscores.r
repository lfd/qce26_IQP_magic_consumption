library(readr)
library(ggplot2)
library(dplyr)
library(scriptName)


COLOURS.LIST <- c("black", "#E69F00", "#999999", "#009371", "#beaed4", "#ed665a", "#1f78b4")

source("util.r")

plot <- function(datafile) {
    df <- read_csv(datafile)

    cil <- c(1,3,7,9)

    everysecond <- function(x) {
        x <- sort(unique(x))
        x[seq(2, length(x), 2)] <- ""
        return(x)
    }

    p <- df |>
    group_by(circ, circDepth) |>
    mutate(zsre = (sre - mean(sre)) / sd(sre)) |>
    ungroup() |>
    filter(type == "orig") |>
    ggplot(aes(x = circDepth, y = zsre)) +
    geom_point(shape=".") +
    geom_smooth(color=COLOURS.LIST[2]) +
    geom_hline(
        yintercept = -3,
        linetype = "dashed",
        color=COLOURS.LIST[3]
    ) +
    geom_hline(
        yintercept = 0,
        linetype = "dotted",
        color=COLOURS.LIST[3]
    ) +
    theme_light() +
    labs(
        x = "Circuit Depth $k$",
        y = "$z(\\hbox{SRE}(|C_k\\rangle))$"
    ) 

    return(p)
}
