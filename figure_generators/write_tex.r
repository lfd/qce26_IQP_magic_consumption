library(scriptName)

source("util.r")

main <- function() {
    args = commandArgs(trailingOnly = TRUE)
    plotsrc = args[1]
    datafile = args[2]
    width = as.double(args[3])
    height = as.double(args[4])

    filename <- paste(fs::path_ext_remove(plotsrc), ".tex", sep="")
    
    standAlone <- TRUE
    if (length(args) == 5 && args[5] == "embeddable") {
        standAlone <- FALSE
    }
    source(plotsrc)
    print(datafile)
    write_tex_plot(plot(datafile), 
                   filename, 
                   width = width, 
                   height = height,
                   standAlone = standAlone)    
}

if(!interactive()) {
    main()
}

