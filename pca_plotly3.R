# pca_plotly3.R
#
# Generate 2D and 3D plots from the top 3 PCAs. Tested with R 4.2.0.
# Modified from pca_plot_example.R to handle input data file from command line and
# create a summary word document dynamically
#
# Usage: Rscript pca_plotly3.R [chemical label] [data file path] [data file] [skipped lines]
# Example command:
# $ Rscript pca_plotly3.R EDHP "C:/Users/yangl10/Documents/Supports/Projects/Emily_Project/PCA/PCAplotting" "EDHP_example.txt" 
# Use the libraries 'tidyverse' and 'plotly' for 2D and 3D plot.
# Use the libraries reticulate and officer for save plot images and generate MS word document. 

# Block 1: Get script base path and read command line parameters
args <- commandArgs()

if (length(args) < 8) {
  print("Not enough command line parameters. At leaset 3 parameters are required with 4th optional.")
  print("Usage: $\U00A0Rscript pca_plotly3.R [chemical label] [data file path] [data file] [skipped lines]")
  print("For example:")
  print("Rscript pca_plotly3.R EDHP \"C:/Users/some_user/Documents/Projects/PCA/data/\" \"EDHP_example.txt\"")
  quit()
}

script_info <- strsplit(args[4], "=")[[1]]
base_dir <- dirname(normalizePath(script_info[2]))
print(paste("Script Path", base_dir, sep = ": "))

chemical_label <- as.character(args[6])
file_dir <- as.character(args[7])
file_name <- as.character(args[8])

skipped <- 0

if (length(args) > 8) {
  skipped <- as.integer(args[9])
  print(paste("Skipped line number:", skipped, sep = ": "))
}

analysis <- "PCA"
plots_dir <- "PCA_Plots"
file_dir <- gsub("\\\\", "/", file_dir) # In case from windows with copy/paste
print(sprintf("Input file path: %s.", file_dir))
output_dir <- file.path(file_dir, plots_dir)

if (!file.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# Data file format: tab-separated .txt
# 1st line: Sample names. Skipped line parameter if data contain top lines with additinal information
# 2nd line: doses
# Remaining lines: probe ID/row name in first column, then 
# gene expression measurements for each sample or other dose-reponse data in each column and dose.
file_in <- file.path(file_dir, file_name)

if (!file.exists(file_in)) {
  stop(sprintf("The following data file dose not exist and the process is stoped:\n %s.", file_in))
}

# The packages "tidyverse" and "plotly" are used for PCA 3D plot.
options(warn=-1)
suppressWarnings(suppressMessages(library(tidyverse)))
suppressMessages(library(plotly))
library(reticulate)
library(officer)

# Read data from the file
suppressMessages(data <- read_delim(file_in, delim = '\t', col_names=TRUE, skip = skipped))
print(dim(data))

if (startsWith(tolower(data[1, 1]), "dose")) {
  print("Doses found.")
} else {
  stop("Doses not found or data with format and row name issue. Aborted!")
}

# The first row of data is the doses.
dose_numeric <- as.numeric(data[1,2:ncol(data)])

# The remaining part of data is the probe ID (not needed for this analysis)
# in the first column, and response data in the remaining columns.
response <- as.matrix(data[-1,-1])

# The PCA will be based on correlation of genes to each other.
# The PCA function prcomp() calculate the correlations of columns of a data matrix.
# So the original data needs to be transposed
response <- t(response)

# The matrix 'response' now has these dimensions:
# Number of columns = number of genes/probes measured
# Number of rows = number of samples; the row names are the names of the samples
# (from the first line of the text file)

# Call prcomp() to perform the PCA
pca <- prcomp(x = response)

# 'scores' is the PCA scores from the analysis. Each row corresponds to one sample
# (one row of the transposed data matrix) and each column to one principal component.
# The row names of 'scores' are the sample names. 
scores <- pca$x
# names_pca <- attributes(scores)$dimnames[[2]]

# sd_comps is the standard deviations of the components.
sd_comps <- pca$sdev
# variance = square of standard deviation
var_comps <- sd_comps ^ 2 

# Calculate percent variance for each component
var_perc <- 100 * var_comps / sum(var_comps)
var_round <- round(var_perc, 1)
var_percentage <- paste(var_round, "%", sep = "")

# Put the scores into a table with the doses
pca_scores <- data.frame(dose_numeric, scores)
pca_scores$Dose <- factor(pca_scores$dose_numeric)
doses_count <- table(dose_numeric)
# names(doses_count); doses_count[[1]]
pca_names <- names(pca_scores)[-1]

# 3D plot: Create axis labels and title, axes include percentage of variance for a component
# and title includes the sum of those values.
xlabel <- sprintf('<b>%s (%s)</b>', pca_names[1], var_percentage[1])
ylabel <- sprintf('<b>%s (%s)</b>', pca_names[2], var_percentage[2])
zlabel <- sprintf('<b>%s (%s)</b>', pca_names[3], var_percentage[3])
title <- sprintf("<b> %s PCA (%s) </b>", chemical_label, paste(sum(var_round[1:3]), "%", sep = ""))

# Specify a small font for axis labels
font_14b <- list(family = "Arial", size = 14, color = "black")
colors_hex <- c("#332288", "#88CCEE", "#44AA99", "#117733", "#999933", "#DDCC77", "#CC6677", "#882255", "#AA4499")
colors_hex <- sort(colors_hex)
colors_hex <- c("#000000", "#322DA8", "#0077C8", "#00A378", "#B12E0F", "#ED6C21")
colors_hex <- sort(colors_hex)
shapes <- c("circle","square", "diamond", "cross") #, "arrow-up", "x", "triangle-down", "bowtie", "hash", "star", "pentagon", "asterisk")
shapes_open <- c("circle-open", "square-open", "diamond-open", "cross-open")
shapes_open_dot <- c("circle-open-dot","square-open-dot", "diamond-open-dot", "cross-open-dot")
# Plotly doc listed 8 symbols available for 3D but "x" is too large.
# Online link: https://plotly.com/python/reference/#scatter3d-marker-symbol
shape_names <- c("circle","square", "diamond", "cross", "circle-open", "square-open", "diamond-open") #, "cross-open") # , "x"
# shape_indices <- c(16, 15, 18, 1, 0, 23, 16, 15, 18) # for ggplot

#Create the 3D scatter plot 
fig <- plot_ly(data=pca_scores,x=~PC1,y=~PC2,z=~PC3, width = 600, height = 600) %>%
  add_markers(color=~Dose, colors = colors_hex[1:length(doses_count)],
              symbol = ~Dose, symbols = shape_names[1:length(doses_count)], # shapes_open[1:length(doses_count)], # shape_names[1:length(doses_count)],
              marker = list(line = list(width = 2))) %>%
  layout(title=list(text=title),
         margin = list(t = 40, r = 10, b = 10, l = 10),
         legend = list(title = list(text = "<b>  Dose </b>"), x = 0.9, y = 0.95, itemsizing="constant"), # keep legend marker size the same as plot. otherwise, it is smaller
         # legend = list(title = list(text = "<b>  Dose <b/>"), x = 0.9, y = 0.95, font = list(family = "arial", size = 16)), # Newly added
         font = list(family = "Arial", size = 12, color = "black"), # tick 
         scene=list(
           xaxis = list(title = list(text=xlabel,font=font_14b)),
           yaxis = list(title = list(text=ylabel,font=font_14b)),
           zaxis = list(title = list(text=zlabel,font=font_14b)),
           camera = list(eye = list(x=1.5, y=1.5, z = 1.5)) # newly fix bottom out of range
           # camera = list(eye = list(x=1.4, y=1.4, z = 1.6)) # newly fix bottom out of range
         )
  )

# fig

# 09/20/2022. Need to use orca to save plot_ly image.
# Original plot will drawn bottom outside of plot range and need to adjust via camera-eye to fully display graph.
# Export graph requires additional work: install "reticulate" package and "orca"
timestamp <- format(Sys.time(), "%Y%m%d%H") # 2021071517
png_file_name <- paste(paste(chemical_label, analysis, "3D", timestamp, sep = "_"), "png", sep = ".")
# png_file <- file.path(output_dir, png_file_name)

# It seems that orca only works on current directory, otherwise with absolute path will throw js exceptions
setwd(output_dir)
orca(fig, file = png_file_name) # With warning message but works with current directory

# Create word document
bold_face <- fp_text(bold = TRUE)
pca_doc <- read_docx()

# Add 3D plots
fp_title <- fpar(ftext("PCA Analysis", bold_face), run_linebreak())
pca_doc <- body_add_fpar(pca_doc, fp_title)
fpar_3D <- fpar(ftext("Three-dimensional plot of top three PCA components", bold_face), run_linebreak())
pca_doc <- body_add_fpar(pca_doc, fpar_3D)
# pca_doc <- body_add_plot(pca_doc, value = plot_instr(code = {fig}), style = "centered") # Not working
pca_doc <-  body_add_img(pca_doc, src = png_file_name, width = 6.25, height = 6.25)
file.remove(png_file_name)

# Choose number scatter plot pairs of principal component scores
nplot <- 3

# i is the number for the first component, j for the second
for (i in 1:(nplot - 1)) {
  for (j in (i + 1):nplot) {
    # Create the 2D scatter plot with plotly
    pca_x <- pca_names[i]
    pca_y <- pca_names[j]
    label_x <- sprintf("<b>%s (%s)</b>", pca_x, var_percentage[i])
    label_y <- sprintf("<b>%s (%s)</b>", pca_y, var_percentage[j])
    
    # fig <- plot_ly(data=pca_scores,x=~PC1,y=~PC2, width = 600, height = 600, size = 10) %>%
    fig <- plot_ly(data=pca_scores,x=~pca_scores[[pca_x]],y=~pca_scores[[pca_y]], width = 600, height = 600, size = 10) %>%
      add_markers(color=~Dose, colors = colors_hex[1:length(doses_count)],
                  symbol = ~Dose, symbols = shape_names[1:length(doses_count)], # shape_names[1:length(doses_count)],
                  marker = list(line = list(width = 2))) %>%
      layout(title=list(text=paste("<b>", chemical_label, "</b>")),
             margin = list(t = 40, r = 10, b = 10, l = 10),
             legend = list(title = list(text = "<b>  Dose </b>"), itemsizing="constant"),
             # legend = list(title = list(text = "<b>   Dose </b>"), x = 0.9, y = 0.95, font = list(family = "arial", size = 16)), # Newly added
             font = list(family = "Arial", size = 12, color = "black"),
             xaxis = list(title = list(text=label_x,font=font_14b), zeroline = FALSE, showline = FALSE, gridcolor = "grey"),
             yaxis = list(title = list(text=label_y,font=font_14b),zeroline = FALSE, showline = FALSE, gridcolor = "grey")#,
             # plot_bgcolor="rgb(254, 247, 234)"
             # plot_bgcolor="rgb(234, 234, 234)"
      )
    
    # fig
    file_name2 <- paste(paste(chemical_label, analysis, "2D", timestamp, sep = "_"), "png", sep = ".")
    # png_file <- file.path(output_dir, file_name2)
    orca(fig, file = file_name2) # With warning message but works with current directory
    
    pca_doc <- body_add_break(pca_doc)
    
    if (i == 1 && j == 2) { # Add heading before first 2D plot
      fpar_2D <- fpar(ftext("Two-dimensional plot of top three PCA components", bold_face), run_linebreak())
      pca_doc <- body_add_fpar(pca_doc, fpar_2D)
    }
    
    header_fpar <- fpar(ftext(sprintf("PCA %s vs PCA %s Plot", i, j), bold_face), run_linebreak())
    pca_doc <- body_add_fpar(pca_doc, header_fpar)
    
    # Use body_add_plot() will not control plot size, instead, use saved PNG image files
    pca_doc <-  body_add_img(pca_doc, src = file_name2, width = 6.25, height = 6.25)
    file.remove(file_name2)
  }
}

# Add foot note after a few empty lines
empty_lines_fpar <- fpar(run_linebreak(), run_linebreak(), run_linebreak(), run_linebreak(), run_linebreak(), run_linebreak())
pca_doc <- body_add_fpar(pca_doc, empty_lines_fpar)
# Add an empty heading 1 to show a line
# pca_doc <- body_add_par(pca_doc, value = "", style = "heading 1")
foot_note <- paste("The principal component analysis (PCA) plots are generated using R scripts",
                   "from the Division of Translational Toxicology, NIEHS.",
                   "The three 2-dimensional PCA plots and the 3-dimensional PCA plot",
                   "are created using tidyverse R library and plotly R library, respectively.",
                   "The original R code was modified to output the expected format of the PCA plots.", sep = " ")
fnote_fpar <- fpar(ftext(foot_note), run_linebreak())
pca_doc <- body_add_fpar(pca_doc, fnote_fpar)

file_prefix <- sub(pattern = "(.*)\\..*$", replacement = "\\1", basename(file_name))
file_name_doc <- paste(paste(file_prefix, analysis, "Plots", timestamp, sep = "_"), "docx", sep = ".")
file_out <- print(pca_doc , target = file_name_doc)
print(sprintf("An MS word document '%s' is created at '%s'.", file_name_doc, output_dir))
