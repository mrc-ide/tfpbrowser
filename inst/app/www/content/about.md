# tfpbrowser

## About

The Transmission Fitness Polymorphism Browser (tfpbrowser) is a visualisation tool for output from
the Transmission Fitness Polymorphism Scanner (tfpscanner)[1-3]. Information on the visualisation
options can be found below, while details regarding installation of the tfpbrowser package and the
source code can be found at
[https://github.com/mrc-ide/tfpbrowser](https://github.com/mrc-ide/tfpbrowser).

Six different visualisations can be accessed by selecting from the ‘View’ dropdown menu on the
left-hand side. If the ‘View’ option is not visible, then the left-hand side menu may need to be
expanded by clicking on the double arrow button.

### Tree Visualisations

There are four different tree visualisation options. These are described below, but a number of
characteristics are common to each tree visualisation:

- The size of the circles (for internal nodes) and triangles (tips) indicates the size of the
cluster that they represent.
- The colour indicates a particular characteristic of the cluster.
- On the right-hand side of each tree visualisation, the colouring of the bars indicates whether a
genotype (for which a key mutation is labelled) is present (true) or absent (false) in the clusters
at the same vertical level.
- Further information on each cluster can be viewed by hovering over it with the mouse cursor.

The four tree visualisation options in the ‘View’ menu are:

#### Tree Clock Outlier

Displays a phylogenetic tree with clusters colour coded (key at the top) according to the value of
the molecular clock outlier (MCO) statistic. This is computed by the tfpscanner as a measure of the
degree to which evolutionary rates differed in the lineage leading to a phylogenetic cluster.
Root-to-tip regression is used to predict the divergence of tips in a cluster and contrasts this
with divergence within an ancestral clade including the given cluster. This predicted divergence is
then compared to the true divergence of the cluster.

#### Tree Logistic Growth Rate

Displays a phylogenetic tree with clusters colour coded (key at the top) according to the value of
the logistic growth rate. This is computed in the tfpscanner using one of two different methods
depending on the level of model support calculated using the Akaike Information Criterion (AIC) and
‘relative likelihood’. The first method uses a generalised linear model (GLM) to calculate the log
odds of a sample being from a cluster of interest compared to a geographically and temporally
matched sample weighted by prevalence, and multiplied by the estimated mean generation time to
calculate the relative LGR per generation for each cluster of interest. The second method uses a
generalised additive model (GAM) combined with a Gaussian process model to identify changes in
growth rates over time.

#### Tree Mutations

This visualisation has a ‘Mutation’ menu from which to select a particular mutation to be
highlighted in the phylogenetic tree. Clusters containing the mutation selected will be coloured red
in the phylogenetic tree while clusters not containing this mutation will be grey.

#### Tree Sequences

This visualisation has a ‘Sequence’ menu from which to select a particular sequence ID. Clusters
containing this sequence will be coloured red in the phylogenetic tree while those not containing it
will be grey.

### Scatter plots

The molecular clock outlier and logistic growth rate statistics can also be viewed in scatter plots:

#### Sina Clock Outlier

Displays a scatter plot of the molecular clock outlier statistic value for each phylogenetic cluster
on the y-axis and the lineage and/or mutation is stratified along the x-axis. The plot marker
colours indicate the lineage and/or mutation and the size indicates the cluster size, both as per
the legend on the right-hand side of the plot. _See ‘Tree Clock Outlier’ above for details of the
molecular clock outlier statistic_.

#### Sina Logistic Growth Rate

Displays a scatter plot of the logistic growth rate value for each phylogenetic cluster on the
y-axis and the lineage and/or mutation is stratified along the x-axis. The circle colours indicate
the lineage and/or mutation and the size indicates the cluster size, both as per the legend on the
right-hand side of the plot. _See ‘Tree Logistic Growth Rate’ above for details of this statistic_.

### Downloads

Tables, plots and .rds files can also be downloaded by clicking on the ‘Cluster statistics’ tab and
selecting the relevant option.

### References

[1] Volz EM, Boyd O. Transmission Fitness Polymorphism Scanner. Available from:
https://github.com/mrc-ide/tfpscanner

[2] Volz EM. Fitness, growth and transmissibility of SARS-CoV-2 genetic variants. Nat Rev Genet
2023. https://doi.org/10.1038/s41576-023-00610-z

[3] Drake KO, Boyd O, Franceschi VB, Colquhoun RM, Ellaby NAF, Volz EM. Phylogenomic early warning
signals for SARS-CoV-2 epidemic waves. eBioMedicine 2024: 100.
https://doi.org/10.1016/j.ebiom.2023.104939
