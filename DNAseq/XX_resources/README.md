downlaoded the code from github, all nexessary packages to conda environment,  wentinto the master folder and just typed in `make` to build, the chmod +x ./grenedalf in the bin folder amd mow i cam call it 
https://github.com/lczech/grenedalf?tab=readme-ov-file
https://anaconda.org/anaconda/automake

Resouces:
https://sourceforge.net/p/popoolation/wiki/TeachingPoPoolation/
https://sourceforge.net/p/popoolation2/wiki/Tutorial/
https://sourceforge.net/p/popoolation2/wiki/Manual/
PDF powerpoint on popoolation(1 and 2)
https://marineomics.github.io/POP_03_poolseq.html
https://owensgl.github.io/biol525D/Topic_8-9/fst.html
poolfstat vignette 
https://rpubs.com/rossibarra/61700
https://knausb.github.io/vcfR_documentation/genetic_differentiation.html
https://github.com/lczech/grenedalf?tab=readme-ov-file
https://github.com/lczech/HAF-pipe
https://github.com/moiexpositoalonsolab/grenepipe?tab=readme-ov-file
https://github.com/petrov-lab/HAFpipe-line
https://github.com/RealTimeGenomics/rtg-tools
https://docs.hpc.ufs.ac.za/training/genomics_tutorial/genomics_tutorial_8/
https://genomics-fungi.sschmeier.com/ngs-variantcalling/index.html
https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6116966/
https://esnielsen.github.io/post/pool-seq-analyses-poolfstat-baypass/
https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3567740/
https://grunwaldlab.github.io/poppr/reference/poppr-package.html

https://onlinelibrary.wiley.com/doi/10.1111/1755-0998.13557
https://bernatgel.github.io/karyoploter_tutorial//Examples/GeneExpression/GeneExpression.html
https://cran.r-project.org/web/packages/chromoMap/vignettes/chromoMap.html
https://rich-iannone.github.io/DiagrammeR/
https://tskit.dev/msprime/docs/stable/demography.html#admixture
https://pubmed.ncbi.nlm.nih.gov/34837462/

## Packages 
SNPRelate: 
https://www.bioconductor.org/packages/devel/bioc/vignettes/SNPRelate/inst/doc/SNPRelate.html?fbclid=IwAR02IuopU_QxEXTDbsmZ_sPrsAj4PbJyJqSGjEEc98lmWtbDoCnwnqtJMN4
https://amakukhov.github.io/Bio381/RPresentationCode_04_19_17.html?fbclid=IwAR3N9gOtslKU2CU0ctI6c0BrRxTwBUcJWeEO6D4Tkr5UllK5h4jF_bjbBnA


GLM AF Values as response variable for(i in SNP){ AF ~ Site + Year + Batch|Year

Chord diagram : R Package circlize
bcftools: https://samtools.github.io/bcftools/bcftools.html#view

Tomahawk for LD: https://www.royfrancis.com/fast-ld-computation-from-vcf-files-using-tomahawk/?fbclid=IwAR2bjx46Tszu_Btu95vHBottE--ZpdUM7x3HvirxC06_JUStYfeCL_VaqJg#:~:text=Thinning%20VCF&text=Use%20vcftools%20to%20thin%20down%20a%20VCF%20file.&text=The%20argument%20%2D%2Dthin%2050000,SNPs%20in%20the%20thinned%20file


E) Inference of Demographic patterns
1) isolate SNPs located in Introns < 60 bp length using the D. melanogaster genome annotation in GFF file format and retain only SNPS with a minimum recombination rate >3 (based on Comeron et al. 2012) and in a minimum Distance of 1 mb to the breakpoints of common chromosomal inversions (based on Corbett-Detig et al. 2014).
# identify SNPs inside introns of < 60bp length

python scripts/IntronicSnps.py \
--gff dmel-all-filtered-r6.09.gff.gz \
--sync SNPs.sync.gz \
--target-length 60 \
> intron60_all.sync

# remove SNPs within and in 1mb distance to chromosomal inversions and with recombination rates <3

python scripts/FilterByRecomRateNInversion.py \
--inv data/inversions_breakpoints_v5v6.txt \
--RecRates data/DrosEU-SNPs.recomb.gz \
--input intron60_all.sync \
--D 1000000 \
--r 3 \
> intron60.sync
2) calculate pairwise FST based on the method of Weir & Cockerham (1984)
python scripts/FST.py \
--pool-size 80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,66,80,80,80,80,80,80,80,80,70,80,80,80 \
--input intron60.sync \
--minimum-count 2 \
--minimum-cov 10 \
| gzip > intron.fst.gz
3) average FST across all loci
python scripts/CombineFST.py \
--diff intron.fst.gz \
--stat 0 \
> intron_average.fst
4) calculate isolation by distance (IBD)
python scripts/IBD.py \
--fst intron_average.fst \
--meta data/MetaData.txt \
--output IBD_EU
5) calculate allele frequencies of the major allele
python scripts/sync2AF.py \
--inp intron60.sync \
--out intron60-af
### 6) calculate PCA in R

library(gtools)
library(LEA)

# load data
meta=read.table("data/MetaData.txt",header=T)
freq=read.table("intron60-af_freq.txt",header=F)
rown<-meta[,1]
rownames(freq)<-rown

# calculate PCA
write.lfmm(freq,"test.lfmm")
pc=pca("test.lfmm")
tw=tracy.widom(pc)
a=stars.pval(tw$pvalues)

# identify optimal number of clusters
d=data.frame(pc$eigenvectors[,1:4)
library(mclust)
d_clust=Mclust(as.matrix(d), G=1:4)
m.best <- dim(d_clust$z)[2]

# identify cluster with K-means clustering
comp <- data.frame(pc$eigenvectors[,1:4])
k <- kmeans(comp, 5, nstart=25, iter.max=1000)
library(RColorBrewer)
library(scales)
palette(alpha(brewer.pal(9,"Set1"), 0.5))

# plot first two axes
pdf("PCA.pdf",width=14,height=10)
layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE),widths=c(1,1), heights=c(1.5,1))
par(cex=1.5,mar=c(4,4,2,2))
plot(-1*comp[,1],comp[,2], col=k$clust, pch=16,cex=1.5,xlab="PC1",ylab="PC2")
names=c("Austria","Austria","Turkey","Turkey","France","France","France","UK","UK","Cyprus","UK","UK","Germany","Germany","Ukraine","Ukraine","Ukraine","Ukraine","Ukraine","Ukraine","Ukraine","Ukraine","Ukraine","Ukraine","Ukraine","Ukraine","Ukraine","Sweden","Germany","Germany","Portugal","Spain","Spain","Finland","Finland","Finland","Denmark","Denmark","Switzerland","Switzerland","Austria","Ukraine","Ukraine","Ukraine","Ukraine","Ukraine","Ukraine","Russia")

text( -1*comp[,1],comp[,2],names, pos= 3,cex=0.75,pch=19)
barplot(pc$eigenvalues[,1],ylab="Eigenvalues",names.arg=1:nrow(pc$eigenvalues),xlab="Principal components")
abline(h=1,col="red",lwd=2,lty=2)
b=barplot(cumsum(tw$percentage),ylim=c(0,1),names.arg =1:length(tw$percentage),ylab="variance explained",xlab="Principal components")
abline(h=0.8,col="blue",lwd=2,lty=2)
dev.off()

# write PCA scores of first 3 axes to text file
write.table(cbind(k$cluster,comp[,1],comp[,2],comp[,3]),file="PCA-scores.txt",row.names = T, quote=F)
analyse population structure and admixture with the R package conStruct
# install.packages("conStruct")
library(conStruct)

# Load allele frequencies, coordinates of each sampling site and geographic distances in kilometers
Freq=read.table("intron60-af_freq.txt",header=F)
CoordRaw=read.table("data/DrosEU-coord.txt",header=T)
Coord=as.matrix(CoordRaw[,4:3])
colnames(Coord)=c("Lon","Lat")
DistRaw=read.table("data/DrosEU-geo.dist",header=T)
Dist=as.matrix(DistRaw)

# Set working directory
setwd("/Volumes/MartinResearch2/new2014Analyses/analyses/4fold/construct")

# test values of K ranging from 1 to 10 in 8-fold replication with cross-validation
my.xvals <- x.validation(train.prop = 0.9,
    n.reps = 8,
    K = 1:10,
    freqs = as.matrix(Freq),
    data.partitions = NULL,
    geoDist = Dist,
    coords = Coord,
    prefix = "example2",
    n.iter = 1e3,
    make.figs = T,
    save.files = T,
    parallel = TRUE,
    n.nodes = 20)

# load both the results for the spatial and non-spation models
sp.results <- as.matrix(
    read.table("example2_sp_xval_results.txt",
    header = TRUE,
    stringsAsFactors = FALSE))
nsp.results <- as.matrix(
    read.table("example2_nsp_xval_results.txt",
    header = TRUE,
    stringsAsFactors = FALSE))

# format results from the output list
sp.results <- Reduce("cbind",lapply(my.xvals,function(x){unlist(x$sp)}),init=NULL)
nsp.results <- Reduce("cbind",lapply(my.xvals,function(x){unlist(x$nsp)}),init=NULL)
sp.CIs <- apply(sp.results,1,function(x){mean(x) + c(-1.96,1.96) * sd(x)/length(x)})
nsp.CIs <- apply(nsp.results,1,function(x){mean(x) + c(-1.96,1.96) * sd(x)/length(x)})

# then, plot cross-validation results for K=1:10 with 8 replicates and visualize results with confidence interval bars
pdf("cross-validate-sp.pdf",width=4,height=12)
plot(rowMeans(sp.results),
pch=19,col="blue",
ylab="predictive accuracy",xlab="values of K",
ylim=range(sp.CIs),
main="spatial cross-validation results")
segments(x0 = 1:nrow(sp.results),
y0 = sp.CIs[1,],
x1 = 1:nrow(sp.results),
y1 = sp.CIs[2,],
col = "blue",lwd=2)
dev.off()

# plot all Admixture plots for values of K ranging from 1:10
for (i in seq(1,10,1)){
      my.run <- conStruct(spatial = TRUE,
            K = i,
            freqs = as.matrix(Freq),
            geoDist = Dist,
            coords = Coord,
            prefix = paste("test_",i,seq=""),
            n.chains = 1,
            n.iter = 1e3,
            make.figs = T,
            save.files = T)

      admix.props <- my.run$chain_1$MAP$admix.proportions
      pdf(paste("STRUCTURE_",i,"_1.pdf"),width=8,height=4)
      make.structure.plot(admix.proportions = admix.props,
            sample.names=CoordRaw$node_label,
            mar = c(6,4,2,2),
            sort.by=1)
      dev.off()

      # plot map with pie-charts showing proportion admixture  
      pdf(paste("AdmPIE_",i,"_1.pdf"),width=9,height=8)
      maps::map(xlim = range(Coord[,1]) + c(-5,5), ylim = range(Coord[,2])+c(-2,2), col="gray")
      make.admix.pie.plot(admix.proportions = admix.props,
            coords = Coord,
            add = TRUE)
      box()
      axis(1)
      axis(2)
      dev.off()
}
