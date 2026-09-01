# pca_plotly3.R
#
# Generate 2D and 3D plots from the top 3 PCAs. Tested with R 4.4.3.
# Modified from pca_plot_example.R to handle input data file from command line and
# create a summary word document dynamically
#
# Usage: Rscript pca_plotly3.R [chemical label] [data file path] [data file] [skipped lines]
# Example command:
# $ Rscript pca_plotly3.R GBE-Lot1 "C:/Users/blackev/Documents/pcaplot/" "GBE-Lot1-expressiondata.txt" 
# Use the libraries 'tidyverse' and 'plotly' for 2D and 3D plot.
# Use the libraries reticulate and officer for save plot images and generate MS word document. 

Terminal Output: 
[1] "Script Path: C:/Users/blackev/Documents/.."
[1] "Input file path: C:/Users/blackev/Documents/../data/pca_plots/PCA_Plots/."
[1] 31100    29
[1] "Doses found."
list()
[1] TRUE
[1] "An MS word document 'GBELot1_PCA_Plots_2026090113.docx' is created at 'C:/Users/blackev/Documents/../data/pca_plots/PCA_Plots/PCA_Plots'."
[1] "A pdf document 'GBELot1_PCA_Plots_2026090113.pdf' is created at 'C:/Users/blackev/Documents/../data/pca_plots/PCA_Plots/PCA_Plots'."
