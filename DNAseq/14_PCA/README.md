# PCA

population genetics? is it a good idea? questionable. shangzhe says take it with a grain of salt. see https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7750941/ and https://doi.org/10.1101/2021.04.11.439381

The goal of a PCA is to try to cluster samples in how ever many degrees of a "principle component" that explains X% of variation among the samples while reducing noise. It's basically a visual check (and should be used as one) to measure how each variable is assoicated with another in a covariance matrix. It transforms some correlated features in data into orthogonal components. PCA uses eigen-decomposition to breakdown a matrix where we get a diagonal matrix of eigenvalues (the dimension of the matrix, coefficients applied to eigenvectors to give length/magnitude) and a matrix formed by the eigenvectors (unit vectors that assess the directions of the spread of the data). 

To run a PCA with the sample sizes
first get the list of samples (see section 15, with bcftools), then copy and paste to word, replace all the new paragraphs ^p with "," add an extra comma at the top and the bottom, then you have to get a list of all the pool sizes 
