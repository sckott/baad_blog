% The challenge of combining 176 x #otherpeoplesdata to create the Biomass And Allometry Database
% Daniel Falster, Rich FitzJohn, Remko Duursma, Diego Barneche

We are entereing the era of big data, but for much of science the challenge is not that data are too big (to load, copy or analyse), rather it is that most datasets are small and scattered on hard drives around the planet. The size of these small-data "fragemnts" varies, but they often correspond to the amount of work needed to publish a single scinetific paper. **Big** data sets emerge only when the framents are collected and merged into a single standradised source, with common units and variables names, and a documnetation about the varitey of methods used in the different studies. Combining the small-data fragments into larger - often global -- compilations allows us to address questions at an entirely new level.

Collecting and compiling small-data fragments is challenging at both politicial and technical levels. The political challenge is to manage the carrots and sticks needed to promote sharing of data within the scientific community. The polotics of data sharing have been the primary focus for debate over the last 5 years, but now that many journals and funding agencies are requring data to be archived at the time of publication, small-data fragments are appearing at an ever increasing rate. The technical challenge - by contrast - is still very much beginning: **How to trasnform small data into big data, i.e.  harmonise a collection of idependent frgaments, each with its own perculuarities, into a single quality dataset?**

Togetehr with 95 coauthors, we recently published the Biomass And Alloemtry Dataset (BAAD), combining data from 176 different scientific studies into a single unified dataset. We built BAAD for several reasons: i) we needed it for our own work ii) we perceived a strong need within the vegetation modelling community for such a dataset, and iii) because it allowed us to road-test some new methods for compiling datasets.

The purpose of this blog post is to describe the challenges in building BAAD and how we overcome these. The challenges are general and might apply to any merging of small-data fragments. If you're on twitter you may be familiar with the hashtag [#otherpeoplesdata](https://twitter.com/search?q=%23otherpeoplesdata) -- added to tweets venting about the difficultieis of working with /beautiful eccentricities in other peoples data. (We each have our own ways of constructing a datasets and unfortunately the logic is not always apparent to others.) Well, we had to deal with #otherpeoplesdata en masse!

# 1. Script everyhthing

From the begining of the project, we decided to script eveything. We wanted the entire workflow of trnasforming raw data files into a unified dataset to be completely scripted and able to be reurn at any point.

I've learnt a lot from watching colleagues like [Ian Wright]() compile [large datasets]() from #otherpeoplesdata In Excel. One of the troubles Ian encountered time and time again, was that he would find out sometime down the track that someone had sent him the wrong data, the wrong units, or no longer wanted their data included in the compilation. Each time something like this happened, it would cost Ian a lot of time to modifying his spreadsheet.

When your workflow is scripted, you can make a small change and then rebuild the database in an instant.

Another reason for scipting is that it ensures all the modifcations to the data are well documented. This simply isn't possible in excel. Lookign at our code, you can see excatly how we modified the data to arrive at the end product.

So while we call it a database, BAAD does not use common database tools like SQL or Microsoft Access etc. It is a database in the sense that it is an [organized collection of data](http://en.wikipedia.org/wiki/Database). Otehwrise we mainatain the raw inputs and a collection of scripts for producing the harmosnied dataset. Like good software, we are constantlyr ebuilding this output from the source.

The only potential cost of continually rebuilding the dataset is that this can take time. Actually, the time taken to make all the trasnformations and combine all 176 studies is pretty minimial - 9.5sec all toegtehr. However, the job of rebuilding the dataset can was made a lot quicker through use of [remake](https://github.com/richfitz/remake)[^remake], one of our new R packages. Essentailly remake cahces built objects (e.g. the tansfromformed dataset for each study) and only rebuilds each of them if either the data or code generating that particuakr dataset has changed. So if I change a single value in one of the dtasets, remake notices that and rebuilds only that file. So after the first longer run, rebuilding the dataset takes in the range of 1-3s.

# 2. Use version control (git) to track changes

The BAAD project began in July 2012, in Feb 2013 Rich FitzJohn got involved and introduced us to version control. You can see the structure of our database at that time [here](https://github.com/dfalster/baad/tree/912163bb371e280340dee2bb4cf872a1d7ede81b). We don't know much about what happended prior 13 Feb 2013, but since that day, every single change to the BAAD has been recorded. We know who changed what lines of code or data and when.

Of the various systems for version contorl that are available, we prefer [git](http://en.wikipedia.org/wiki/Git_(software)). Many people have been extolling the virtues of git for managing computer code (e.g. [Chacon 2009](http://git-scm.com/book)), but git is equally good for managing data ([Ram et al 2013](http://doi.org/10.1186/1751-0473-8-7)). Since many readers may not be familar with some of git's vitues, it is worthr epeating them, focussing on current use case of storing data:

- fossil history, confidence to delete, streamline, identify errors
- blame - who editted which line and when
- more

# 3. Use code sharing website (github) to collaboriate effectively

Alongside git, we used the code-sharing website [github](www.github.com) to host our git repository. Github facilitates seamless collaboration

- easy collaboration (people fixing mistakes, PRs)
- working across diff machines. helpful to have windows person. Early issues with
line endings

Also other features

- tag releases
- pull requests - new data, e.g.

# 4. Establish a data-processing pipeline


We minimised the amount of code by requiring each study to conform to a common format, with separate files for raw data, units of data, meta data, contact details, and citation (see examples in attached code). These files were then processed in a standardised way (Fig.).


- list of desriable units and outputs


Funnel
- unlock dark data
- define common workflow
- encode everything as data
- highly scalable and entirely replacebale

- each study
	- contributors prepare files in std format
		- csv files
		- units, variable names
	- single point for customised manipulations


![Workflow for building the BAAD. Data from each study is processed in the same way, using a standardised set of input files, resulting in a single dataset with a common format.](https://raw.githubusercontent.com/dfalster/baad/3c8ace94a913f4d6c914a244021742ab18a4d639/ms/Figure2.png)

# 5. Do no modify raw data files

Raw data is holy. A back-of-the-envelope calculation suggests the data we are managing would cost about $17 million to collect afresh (in Australian dollars and pay rates) [^Cost]. We decided early on that we would aim to keep the original file sent to us unchaged, as much as possible. In many cases it was necessary to export an excel spreadsheet as a csv file, but beyond that, the file should be beasically as it was porvided. A limited number of actions were allowed on reaw data files, icnluding  [incorporating an updated dataset from a contributor](https://github.com/dfalster/baad/commit/7d10aede58080d83d59fe3be5043829b15f0236b), [modifying line endings](https://github.com/dfalster/baad/commit/5bb9044e7e4b63ad2febca986ebf1e45f24cdd0e)[^line_endings], [removing a string of trailing empty columns](https://github.com/dfalster/baad/commit/ec82e83d1b50f4e6bc2df2a780d2bb1684530652), [correcting spelling mistakes](https://github.com/dfalster/baad/commit/f284744d1e0562d2ec92eea898b7195cc6de1814), [removing special characters causing R to crash](https://github.com/dfalster/baad/commit/d22bc1ee1db3870a7e281de22862eaa1ced4ddd1), [making column names unique](https://github.com/dfalster/baad/commit/4c83c70eb965bfd9c3b7c30f88312e646476836b).

The types of operations that were not allowed include data-trasformations and creation of new columns -- these were all hadnled in our pipeline (see point 4.)

# 6. Encode metadata as data

In the early stages of our project, we encoded a lot of the changes we wanted to make to the data into our R scripts. For example, the code below is from our [first commit](https://github.com/dfalster/baad/blob/912163bb371e280340dee2bb4cf872a1d7ede81b/R/makeCleanDataFiles.R).

```{r}
	if(names[i]=="Kohyama1987"){
		raw        <-  read.csv(paste(dir.rawData,"/",names[i],"/data.csv", sep=''), h=T, stringsAsFactors=FALSE)
		# change species names
		raw$SpecCode[raw$SpecCode=='Cs']  <-  "Camellia sasanqua"
		raw$SpecCode[raw$SpecCode=='Cj']  <-  "Camellia japonia"
		...
		...
		raw$SpecCode[raw$SpecCode=='Sp']  <-  "Symplocos purnifolia"
		raw$SpecCode[raw$SpecCode=='Rt']  <-  "Rhododendron tashiroi"
		raw$SpecCode[raw$SpecCode=='La']  <-  "Litsea acuminata"
		raw$SpecCode[raw$SpecCode=='Cl']  <-  "Cleyera japonica"
		raw$SpecCode[raw$SpecCode=='Ej']  <-  "Eurya japonica"
		raw$leaf.mass  <-  raw$Wtl.g + raw$Wbl.g
		raw$m.st       <-  raw$Wts.g + raw$Wbs.g
		new[[i]]   <-  cbind(dataset=names[i], species=raw$SpecCode, raw[,c(5:8, 14:ncol(raw))], latitude=30.31667, longitude=130.4333, location="Ohkou River, Yakushima Island, Kyushu, Japan", reference="Kohyama T (1987) Significance of architecture and allometry in saplings. Functional Ecology 1:399–404.", growingCondition="FW", vegetation="TempRf", stringsAsFactors=FALSE)
	}
```

The code shows operations for a single study, where we load raw data, make a new columns, add columns and save the compiled object. The **problem** with this code is that it mixes in a bunch of useful data with our R code. We had not yet identified a common pipeline for processing data. Eventually we moved all this extra data into their own csv files and treated them as we should, as data. This also allowed us to drsatcially reduce the amount of R code by moving each dataset through a common pipeline (see point 4).

Ina dditon, we sought a stanadrised description of each study, and saved this in a common format.

# 7. Setup automated reporting and screening

Once we had decided to store metdata as data (point 6), and established a common pipeline for processing data (point 4), a lot becomes possible. For example, you can write a standard template for reporting on each study. To do this we used the package [knitr](http://cran.r-project.org/package=knitr), using [this Rmd file](https://github.com/dfalster/baad/blob/841c346d5c90181b47b0757994901fc520f5e4c6/reports/report.Rmd). Each report includes a processed version of the data and metadta, including maps of study site locations and bivariate plots of all varaibles provided in this study, overlayed againt the rest of the data from BAAD. The current set of reprots can be viewed [on our wiki](https://github.com/dfalster/baad/wiki).

The generated reprots are useful in tow key ways. First that provdie a nice overview of the data contributedd from any single study. Second, they were invaluble in identifying errors (see point 8 below).

# 8. Establish a formal process for processing each data fragment



stages for each dataset, 0-6,

dataset testing

1.
2.
3.
4. review of datasets, first by us then by contributors
	- *knitr reports*, all automated
	- identify errors
	- bivariate plots more helpful than single (show example)

Build

- run on all machines
- now using Travis CI: now open use this to ensure nothing breaks, in retrospect would have


# 9. Provide a clear vision for data contributors

- contacted contributors with clear vision (data paper in Ecology)
	- specifying license
- make it worthwhile for contributors: coauthor on data paper.
	- tangible but no over the top, not persistent/ongoing

# 10. Automate repitive tasks

- EmailR
- emails: automatically fill with relevant details, make it personal and specific
- Google forms for feedback



# Tool chain

Biggest challenges

- software missing - wrote our own prototype
	- scripts to package to scripts
- sometimes data already lost [Gibney, E. & Van Noorden, R. 2013, Scientists losing data
...]at a rapid rate. Nature. 10.1038/nature.2013.14416


# Openness

BAAD is certainly not the first data compilation in my field, but as far we known, it is the first to be entirely open. By this I mean the entire workflow is open and transparent

Every other data compilation that exists in my field, has been conducted in the dark, i.e.

does not meet goals of transparancy and reproducibility. Wwo approaches

1. Individual researchers cut and pasting Excel.
2. Large SQL database, few people with access (TRY).
	- downsides?

Problems:

- mistake is made at some point, how to find and reverse?
- how can users trust database if cannot see how data cleaning and harmonisation
- how to handle infomration does not readily fit into table?


We suggest an alternative approach - small-to medium-szed databases should be constantly rebuilt from source, usiong scripts, all modifications are recorded and available, history of changes tracked under version control. All ifnormation in this workflow is encoded as data to maximise furture reuse.



Ideally techniques for harmosniation should be

- be entirely transparanet and reproducible, potentially reversible. and
- achieved with minial amount of work
- scalable
- open to being superceeded
- crowd-source


# Footnotes

[^remake]: the package `remake` wasoriginally called maker and was introduced on [Nov 19 2014](https://github.com/dfalster/baad/tree/82b0b1c832e9fcfd7c1d1e6cf42f7c8b97e5d323), relatively late in development of BAAD.
[^Cost]: Let's assume each dataset takes a insgle person 1 year to collect. If that person was paid at $60k p.a., and we add oncosts and costs of field work, the cost of each dataset might be $100k. 175 datasets * $100k per dataset = $17mill.
[^line_endings]: something ....
