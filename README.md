## PCA Plot Analysis
The pca_plotly3.R script performs principal component analysis and generates both 
2D and 3D visualizations of the top three principal components. This has been tested 
with R 4.4.3.

![Example PCA Analysis](/images/5DAY_AUTOMATION-PCA.png)

### Generated Reports
The code allows for input data file and chemical name to be added as parameters 
from the command line.
Usage: Rscript pca_plotly3.R [chemical label] [data file path] [data file] [skipped lines if needed]

Example command:
$ Rscript pca_plotly3.R GBE-Lot1 "C:/Users/blackev/Documents/pcaplot/" "GBE-Lot1-expressdata.txt" 

![Example PCA Analysis](/images/5DAY_AUTOMATION-PCA2.png)

Terminal Output should appear similarly to : 

[1] "Script Path: C:/Users/blackev/Documents/.."

[1] "Input file path: C:/Users/blackev/Documents/../data/pca_plots/PCA_Plots/."

[1] 31100    29

[1] "Doses found."

list()

[1] TRUE

[1] "An MS word document 'GBELot1_PCA_Plots_2026090113.docx' is created at 'C:/Users/blackev/Documents/pcaplot/PCA_Plots/'."

[1] "A pdf document 'GBELot1_PCA_Plots_2026090113.pdf' is created at 'C:/Users/blackev/Documents/pcaplot/PCA_Plots/'."
