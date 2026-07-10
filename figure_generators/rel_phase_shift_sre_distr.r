library(readr)
library(ggplot2)
library(dplyr)
library(scriptName)


COLOURS.LIST <- c("black", "#E69F00", "#999999", "#009371", "#beaed4", "#ed665a", "#1f78b4")

source("util.r")

plot <- function(datafile) {
    df <- read_csv(datafile)

    cil <- c(18, 29, 42, 26)

    everysecond <- function(x) {
        x <- sort(unique(x))
        x[seq(2, length(x), 2)] <- ""
        return(x)
    }

    p <- df |>
    filter(circ %in% cil) |>
    ggplot(aes(x = factor(circDepth), y = sre)) +
    geom_boxplot() +
    geom_line(
       aes(x = circDepth),
       data = df |>
           filter(type == "orig") |>
           filter(circ %in% cil),
       color = COLOURS.LIST[2],
       linetype = "dashed"
    ) +
    facet_wrap(vars(circ), ncol = 2) +
    scale_x_discrete(labels = everysecond(df$circDepth |> unique())) +
    theme_light() +
    labs(
        x = "Circuit Depth $k$",
        y = "$\\hbox{SRE}$"
    ) + 
    theme(
        strip.text = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)
    )

    return(p)
}
