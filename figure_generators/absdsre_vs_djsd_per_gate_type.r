library(readr)
library(ggplot2)
library(dplyr)
library(scriptName)
library(scales)


COLOURS.LIST <- c("black", "#E69F00", "#999999", "#009371", "#beaed4", "#ed665a", "#1f78b4")

source("util.r")

plot <- function(datafile) {
    precision = 0.00001

    symlog_trans <- function(base = 10, thr = precision, scale = 1){
      trans <- function(x)
        ifelse(abs(x) < thr, x, sign(x) *
                 (thr + scale * suppressWarnings(log(sign(x) * x / thr, base))))

      inv <- function(x)
        ifelse(abs(x) < thr, x, sign(x) *
                 base^((sign(x) * x - thr) / scale) * thr)

      breaks <- function(x){
        sgn <- sign(x[which.max(abs(x))])
        if(all(abs(x) < thr))
          pretty_breaks()(x)
        else if(prod(x) >= 0){
          if(min(abs(x)) < thr)
            sgn * unique(c(pretty_breaks()(c(min(abs(x)), thr)),
                           log_breaks(base)(c(max(abs(x)), thr))))
          else
            sgn * log_breaks(base)(sgn * x)
        } else {
          if(min(abs(x)) < thr)
            unique(c(sgn * log_breaks()(c(max(abs(x)), thr)),
                     pretty_breaks()(c(sgn * thr, x[which.min(abs(x))]))))
          else
            unique(c(-log_breaks(base)(c(thr, -x[1])),
                     pretty_breaks()(c(-thr, thr)),
                     log_breaks(base)(c(thr, x[2]))))
        }
      }
      trans_new(paste("symlog", thr, base, scale, sep = "-"), trans, inv, breaks)
    }

    sym_log_breaks <- function(nbreaks,base=10){
        function(x){
            minx = min(x)
            maxx = max(x)
            lenx = maxx - minx
            
            if(minx > 0){
                log_breaks(base=base,n=nbreaks)(x)
            } else {
                frac_neg_x = abs(minx) / lenx
                frac_pos_x = 1 - frac_neg_x

                low_vals = -log_breaks(base=base,n=floor(frac_neg_x * nbreaks))(-x[x < 0])
                low_vals[which.min(abs(low_vals))] = 0
                high_vals = log_breaks(base=base,n=floor(frac_pos_x * nbreaks))(x[x > 0])
                high_vals[which.min(abs(high_vals))] = 0
                unique(c(
                    low_vals,
                    high_vals
                ))
            }
        }
    }

    sym_log_labels <- function(x){
        paste("$",gsub("e", "\\\\hspace{-0.35em}\\\\times\\\\hspace{-0.35em}10^{", format(x, scientific=T)), "}$")
    }

    df_unfiltered <- read_data(datafile)
    df <- filter_outliers(df_unfiltered)


    p <- df |>
    ggplot(aes(x = absdsre, y = djsd)) +
    geom_point(shape = ".", alpha = 0.1) +
    geom_smooth(method = "lm", color = COLOURS.LIST[2]) +
    scale_y_continuous(trans=symlog_trans(), breaks=sym_log_breaks(8)(df$djsd),labels=label_log()) + 
    scale_x_log10(labels=label_log()) +
    theme_light() +
    facet_grid(
        cols = vars(nGateQubits),
        labeller = labeller(nGateQubits = c("1" = "1-Qubit Gates", "2" = "2-Qubit Gates"))
    ) +
    labs(
        x = "$|\\Delta \\hbox{SRE}|$",
        y = "$\\Delta D_{\\hbox{JS}}$"
    ) + 
    theme(
        legend.position = "top",
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)
    )


    return(p)
}
