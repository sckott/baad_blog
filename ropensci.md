% The challenge of combining 176 x #otherpeoplesdata to create the Biomass And Allometry Database
% Daniel Falster, Rich FitzJohn, Remko Duursma, Diego Barneche

While we are supposedly entering the era of big data, the problem for much of science is that large-scale, global databases must be assembled from a collection of small independent and  heterogeneous fragments -- the outputs of many and isolated scientific studies conducted around the globe.

Collecting and compiling these fragments is challenging at both political and technical levels. The political challenge is to manage the carrots and sticks needed to promote sharing of data within the scientific community. The politics of data sharing have been the primary focus for debate over the last 5 years, but now that many journals and funding agencies are requiring data to be archived at the time of publication, these data fragments are appearing at an ever increasing rate. But little progress has been made on the main technical challenge: **How can you combine a collection of independent fragments, each with its own peculiarities, into a single quality database?**

Together with 95 co-authors, we recently published the Biomass And Allometry Database (BAAD), combining data from 176 different scientific studies into a single unified database. We built BAAD for several reasons: i) we needed it for our own work ii) we perceived a strong need within the vegetation modelling community for such a database and iii) because it allowed us to road-test some new methods for building and maintaining a database [^database].

Until now, every other data compilation we are aware of has been assembled in the dark. By this we mean, end-users are provided with a finished product, but remain unaware of the diverse modifications that have been made to components in assembling the unified database. Thus users have limited insight into the quality of methods used, nor are they able to build on the compilation themselves.

The approach we took with BAAD is quite different: our database is built from raw inputs using scripts; plus the entire work-flow is available for users to inspect, run themselves and ultimately build upon. We believe this is a better way for managing lots of #otherpeoplesdata and so below share some of the key insights from our experience.

# 1. Script everything and rebuild from source

From the beginning of the project, we decided to script everything. We wanted the entire work-flow of transforming raw data files into a unified database to be completely scripted and able to be rerun at any point. When your work-flow is scripted, you can make a small change and then rebuild the database in an instant. Another reason for scripting is that it ensures all the modifications to the data are well documented. This simply isn't possible in Excel. Looking at our code, you can see exactly how we modified the data to arrive at the end product.

The only potential cost of continually rebuilding the database is that the process of rebuilding can take time. Actually, the time taken to make all the transformations and combine all 176 studies is pretty minimal ~9s all-up. But the job of continually rebuilding the database became a lot quicker once we started using [remake](https://github.com/richfitz/remake)[^remake], one of our new R packages. Remake caches built objects (e.g. the transformed data from each study) and only rebuilds each of them if either the data or code generating that particular object has changed. So after the first longer run, rebuilding the entire database takes in the range of 1-2s.

Another advantage of constantly rebuilding is that we were forced to make our code more robust and potable, so that it would run safely on all the collaborators machines. Recently we took this one step further by setting up some automated builds, using a continuous integration system ([Travis](https://travis-ci.or)) that automatically rebuilds the database on a fresh remote virtual machine [^TravisCI].

**Figure:** Possible screen shot showing TRAVIS results

[![Build Status](https://travis-ci.org/dfalster/baad.svg?branch=master)](https://travis-ci.org/dfalster/baad)

# 2. Establish a data-processing pipeline

If you're on twitter you may be familiar with the hash-tag [#otherpeoplesdata](https://twitter.com/search?q=%23otherpeoplesdata) -- added to tweets venting about the curious challenges of working with other peoples data. (We each have our own ways of preparing a dataset, but often the logic we bring to the problem may cannot be inferred from the spreadsheet alone.) For us, the trick to working with large amounts of #otherpeoplesdata was to establish a solid processing pipeline, and then focus on getting every new study into that pipeline. Once in the pipeline, a common set of operations is applied (see figure). So the challenge for each new study was reduced from "transform into final output", to "get it into the pipeline".

![Work flow for building the BAAD. Data from each study is processed in the same way, using a standardised set of input files, resulting in a single database with a common format.](https://raw.githubusercontent.com/dfalster/baad/3c8ace94a913f4d6c914a244021742ab18a4d639/ms/Figure2.png)


The following principles were applied in establishing our processing pipeline.

## Don't modify raw data files

Raw data is holy. A back-of-the-envelope calculation suggests the data we are managing would cost about $17 million to collect afresh (in Australian dollars and pay rates) [^Cost]. We decided early on that we would aim to keep the original files sent to us unchanged, as much as possible. In many cases it was necessary to export an Excel spreadsheet as a csv file, but beyond that, the file should be basically as it was provided. A limited number of actions were allowed on raw data files. These, included (click on links for examples) [incorporating an updated dataset from a contributor](https://github.com/dfalster/baad/commit/7d10aede58080d83d59fe3be5043829b15f0236b), [modifying line endings](https://github.com/dfalster/baad/commit/5bb9044e7e4b63ad2febca986ebf1e45f24cdd0e)[^line_endings], [removing a string of trailing empty columns](https://github.com/dfalster/baad/commit/ec82e83d1b50f4e6bc2df2a780d2bb1684530652), [correcting trivial spelling mistakes](https://github.com/dfalster/baad/commit/f284744d1e0562d2ec92eea898b7195cc6de1814), [removing special characters causing R to crash](https://github.com/dfalster/baad/commit/d22bc1ee1db3870a7e281de22862eaa1ced4ddd1), [making column names unique](https://github.com/dfalster/baad/commit/4c83c70eb965bfd9c3b7c30f88312e646476836b).

The types of operations that were not allowed include data-transformations and creation of new columns -- these were all handled in our pipeline (see next point).

## Encode meta-data as data, not as code

In the early stages of our project, we encoded a lot of the changes we wanted to make to the data into our R scripts. For example, the code below is taken from [early in the project's history](https://github.com/dfalster/baad/blob/912163bb371e280340dee2bb4cf872a1d7ede81b/R/makeCleanDataFiles.R):

```{r}
	if(names[i]=="Kohyama1987"){
		raw        <-  read.csv(paste(dir.rawData,"/",names[i],"/data.csv", sep=''), h=T, stringsAsFactors=FALSE)
		raw$SpecCode[raw$SpecCode=='Cs']  <-  "Camellia sasanqua"
		raw$SpecCode[raw$SpecCode=='Cj']  <-  "Camellia japonia"
		...
		...
		raw$leaf.mass  <-  raw$Wtl.g + raw$Wbl.g
		raw$m.st       <-  raw$Wts.g + raw$Wbs.g
		new[[i]]   <-  cbind(dataset=names[i], species=raw$SpecCode, raw[,c(5:8, 14:ncol(raw))], latitude=30.31667, longitude=130.4333, location="Ohkou River, Yakushima Island, Kyushu, Japan", reference="Kohyama T (1987) Significance of architecture and allometry in saplings. Functional Ecology 1:399–404.", growingCondition="FW", vegetation="TempRf", stringsAsFactors=FALSE)
	}
```
The code above shows operations for a single study: loading raw data, making new columns, save the compiled object. The **problem** with this code is that it mixes in a bunch of useful data with our R code. We had not yet identified a common pipeline for processing data. Eventually we moved all this extra data into their own csv files and treated them as we should, as data.

Each study in the database was therefore required to have a standard set of files to enter the data-processing pipeline:

- `data.csv`: raw data table provided by authors.
- `dataMatchColumns.csv`: for each column in `data.csv`, provides units of the incoming variable, and the name of the variable onto which we want to map this data.
- `dataNew.csv`: allows for addition of any new data not present in `data.csv`, or modification of existing values based on a find and replace logic.
- `studyMetadata.csv`: information about the methods used to collect the data.
- `studyContact.csv`: contacts and affiliations information for contributors.
- `studyRef.bib`: bibliographic record of primary source, in [bibtex format](https://en.wikipedia.org/wiki/Bibtex).

There are several important benefits to this approach of separating code from data:

- it is highly scalable.
- it separates data from code, so that potentially someone could replace the R code using the exact same data.
- it drastically reduces the amount of R code needed.

## Establish a formal process for processing and reviewing each data set

We established a system for tracking the progress of each dataset entering BAAD

1. Initial screening (basic meta-data extracted from paper).
2. Primary authors contacted (asking if they wish to contribute).
3. Initial response from authors (indicating interest or not).
4. Email sent requesting raw data from authors.
5. Raw data received from authors.
6. Data processed and entered into BAAD (we filled out as much of information as we could ourselves).
7. A review of data, including any queries, sent to authors for error checking.
9. Data approved (finish).
10. Data excluded because of issues that arose (no response, not interested, could not locate data, data not suitable etc.)  (finish).

At each stage we automated as much as possible. We used a script to generate emails in R based on information in our database, and made it as easy as possible for the contributors to fulfil their tasks and get back to us.

Step 7, where we inspected data for errors,  was really important. To make this easier for both us and original contirbutors, we used the package [knitr](http://cran.r-project.org/package=knitr) (using [this Rmd template](https://github.com/dfalster/baad/blob/841c346d5c90181b47b0757994901fc520f5e4c6/reports/report.Rmd)) to create a standardised report for each study.  Each report includes a processed version of the data and metadta, including maps of study site locations and bivariate plots of all variables provided in this study, overlayed againt the rest of the data from BAAD. The current set of reports can be viewed [on our wiki](https://github.com/dfalster/baad/wiki).

The generated reports are useful in two key ways. First that provide a nice overview of the data contributed from any single study. Second, they were invaluable in identifying errors (see figure).

Figure: Example figure showing problematic data.

# 3. Use version control (git) to track changes and code sharing website (github) for effective collaboration

The BAAD project began in July 2012, in Feb 2013 Rich FitzJohn got involved and introduced us to version control. You can see the structure of our database at that time [here](https://github.com/dfalster/baad/tree/912163bb371e280340dee2bb4cf872a1d7ede81b). We can't recall that much about what happened prior 13 Feb 2013, but since that day, every single change to the BAAD has been recorded. We know who changed what lines of code or data and when. Many people have been extolling the virtues of git for managing computer code (e.g. [Chacon 2009](http://git-scm.com/book)), but others have noted that git is equally good for managing data ([Ram et al 2013](http://doi.org/10.1186/1751-0473-8-7)).

Alongside git, we used the code-sharing website [Github](www.github.com) to host our git repository. Github facilitates seamless collaboration by:

- syncing changes to scripts and data among collaborators.
- providing a nice interface for seeing who changed what and when.
- allowing others to make changes to their data.
- releasing compiled versions of the data.

# 4. Embrace openness

BAAD is far from the first compilation in our field, but as far we know, it is the first to be entirely open. By entirely open, we mean

- the entire work flow is open and transparent,
- the raw data and meta-data are made available for others to reuse in new and different contexts,
- the data is immediately available on the web, without need to register or login into a site, or submit a project approval.

Anyone can use the compiled data in whatever way they see fit. Our goal was to create a database that many scientists would immediately want to use, and that would therefore get cited.

Another concern was that the database would be sustainable. By making the entire process open and scripted, we are effectively allowing ourselves to step away from the project at some point in the future, if that's what we want to do.

# Conclusion

We really hope that the techniques used in building BAAD will help others develop open and transparent compilations of #otherpeoplesdata. On that point, we conclude by thanking all our wonderful co-authors who were willing to put put their data out there for others to use.

# Footnotes
[^database]:  BAAD is a database in the sense that it is an [organized collection of data](http://en.wikipedia.org/wiki/Database), but we do not use common database tools like SQL or Microsoft Access etc. These are simply not needed and prevent other features like version control.

[^remake]: the package `remake` was originally called maker and was introduced on [Nov 19 2014](https://github.com/dfalster/baad/tree/82b0b1c832e9fcfd7c1d1e6cf42f7c8b97e5d323), relatively late in development of BAAD.

[^TravisCI]: You can see the record of the automated [builds here](https://travis-ci.org/dfalster/baad/builds/)

[^Cost]: Let's assume each dataset takes a single person 1 year to collect. If that person was paid at $60k p.a., and we add on-costs and costs of field work, the cost of each dataset might be $100k. The cost of the entire database is then 175 datasets * $100k per dataset = $17 million.

[^line_endings]: something ....

