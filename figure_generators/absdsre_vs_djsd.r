library(readr)
library(ggplot2)
library(dplyr)
library(scriptName)


COLOURS.LIST <- c("black", "#E69F00", "#999999", "#009371", "#beaed4", "#ed665a", "#1f78b4")

source("util.r")

plot <- function(datafile) {
    precision = 0.00001

    df_unfiltered <- read_data(datafile)
    df <- filter_outliers(df_unfiltered)

    gamma_labeller <- function(val) {
        paste("$\\gamma = ", val, "$")
    }

    p <- df |>
    filter(gamma <= 3) |>
    ggplot(aes(x = absdsre, y = djsd)) +
    geom_point(shape=".", alpha = 0.25) +
    geom_smooth(method = "lm", color = COLOURS.LIST[2]) +
    scale_color_manual(values = c(COLOURS.LIST[1], COLOURS.LIST[6]), breaks = c("filtered", "all")) +
    theme_light() +
    facet_wrap(
        vars(gamma),
        labeller = as_labeller(gamma_labeller)
    ) +
    labs(
        x = "$|\\Delta \\hbox{SRE}|$",
        y = "$\\Delta D_{\\hbox{JS}}$"
    ) + 
    theme(
        legend.position = "none",
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)
    )

    return(p)
}
