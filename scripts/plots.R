# Plots for ITSXPress paper

library(ggplot2)
library(plyr)
library(reshape2)
library(HDInterval)

# Set file locations
WORKDIR <- "../"
sampleloc <- paste0(WORKDIR,'analysis/timingdata.csv')
derep1loc <- paste0(WORKDIR,'analysis/its1_derep.csv')
derep2loc <-paste0(WORKDIR,'analysis/its2_derep.csv')
setwd(WORKDIR)

# Import data sample and thread timing experiment data

sampledat <-read.csv(sampleloc, header=T)
sampledat <-sampledat[,-1]
names(sampledat)[6] <-"ITSxpress"
names(sampledat)[7] <-"ITSx"

# import table on the number of duplicated reads
derep1 <- read.csv(derep1loc, header=T)
derep2 <- read.csv(derep2loc, header=T)
derep <- rbind(derep1, derep2)
derep$region <-c(rep("ITS1",15), rep("ITS2",15) )
derep$ratio<-(derep$seqs/derep$unique)

fancy_scientific <- function(l) {
  # turn in to character string in scientific notation
  l <- format(l, scientific = TRUE)
  # quote the part before the exponent to keep all the digits
  l <- gsub("^(.*)e", "'\\1'e", l)
  # turn the 'e+' into plotmath format
  l <- gsub("e", "%*%10^", l)
  # return this as an expression
  parse(text=l)
}

#Fig1 slope chart

# Select samples data
df <-sampledat[sampledat$experiment_type=='samples',c(4,6,7,1)]

# createggplot2 slope plot
p <- ggplot(df) + geom_segment(aes(x=1, xend=2, y=`ITSx`, yend=`ITSxpress`, col=region), size=.75, alpha = 1, show.legend=T) +
  scale_y_log10(limits=c(10,10000), breaks=c(10,20,50,100,200,500,1000,2000,5000,10000)) +
  geom_vline(xintercept=1, linetype="dashed", size=.1) +
  geom_vline(xintercept=2, linetype="dashed", size=.1) +
  scale_color_manual(labels = c("ITS1", "ITS2"),
                     values = c("#1f78b4", "#33a02c")) +  # color of lines
  labs(x="", y="Run time in seconds using 4 cores") +  # Axis labels
  xlim(.5, 2.5)  # X and Y axis
# Add text
p <- p + geom_text(label="ITSx", x=1, y=log10(max(df$`ITSx`, df$`ITSxpress`)), hjust=1.2, size=3)  # title
p <- p + geom_text(label="ITSxpress", x=2, y=log10(max(df$`ITSx`, df$`ITSxpress`)), hjust=-0.1, size=3)  # title

p + theme_bw(12) + theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), legend.position = "bottom") +guides(color=guide_legend("Region"))
ggsave("../output/fig1.eps", width = 4, height = 4)



# Plot Fig 2. the in sequences processed by clustering
p <- ggplot(derep) + geom_segment(aes(x=1, xend=2, y=`seqs`, yend=`unique`, col=region), size=.75, alpha = 1, show.legend=T) +
  scale_y_log10(breaks=c(100,200,500,1000,2000,5000,10000,20000,50000,100000,200000),labels=fancy_scientific) +
  geom_vline(xintercept=1, linetype="dashed", size=.1) +
  geom_vline(xintercept=2, linetype="dashed", size=.1) +
  scale_color_manual(labels = c("ITS1", "ITS2"),
                     values = c("#1f78b4", "#33a02c")) +  # color of lines
  labs(x="", y="Number of sequences processed") +  # Axis labels
  xlim(.5, 2.5)  # X and Y axis

p <- p + geom_text(label="Total", x=1, y=log10(max(derep$seqs)), hjust=1.1, size=3)  # title
p <- p + geom_text(label="Clustered", x=2, y=log10(max(derep$seqs)), hjust=-0.1, size=3)  # title

p + theme_bw(11) + theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(),legend.position = "bottom") +guides(color=guide_legend("Region"))
ggsave("../output/fig2.eps", width = 4, height = 4)

## Plot thread data

# Create a long data frame
tl <- melt(sampledat[sampledat$experiment_type=='threads',],id.vars=c("region","sample","experiment_type","threads", "jobid"),value.name="runtime")

# summarize the data
bdata <- ddply(tl, c("region", "variable","threads" ), summarise,
               N    = length(runtime),
               mean = mean(runtime),
               sd   = sd(runtime),
               se   = sd / sqrt(N))

# Plot Runtimes for ITSx and ITSXpress with different cores
p <-ggplot(bdata, aes(x=threads, y=mean,  linetype=variable, color=region, group = interaction(region,variable, sep=": ")), size=1, show.legend=F) +
 scale_y_log10(limits=c(20,50000), breaks=c(10,20,50,100,200,500,1000,2000,5000,10000,20000)) +
 geom_line(size=1, show.legend=F) +
 scale_color_manual(values=c('#1f78b4','#33a02c','#1f78b4','#33a02c')) +
 geom_point(show.legend = FALSE) +
 geom_errorbar(data=bdata, mapping=aes(x=threads, ymin=mean - se, ymax=mean + se), size=1) +
 labs( y = "Run time in seconds", x = "Processor cores", color = "Region:Program") + theme_bw(12) +guides(color=guide_legend("Region")) + guides(linetype=guide_legend("Program"))

p
ggsave("../output/fig3.eps", width = 5, height = 4)


# Compute median speed increases and the Bayesian 95% credible intervals
sampledat$ratio <-sampledat$ITSx/sampledat$ITSxpress

d1<-sampledat[(sampledat$experiment_type=='samples' & sampledat$region=='its1'),]
d2<-sampledat[(sampledat$experiment_type=='samples' & sampledat$region=='its2'),]

its1median <- median(d1$ratio)
its1hdi <- hdi(d1$ratio)
paste0("The median speed increase for the ITS1 region was ", its1median, ". The 95% HDI interval was ", its1hdi[1], " to ", its1hdi[2])
its2median <- median(d2$ratio)
its2hdi <- hdi(d2$ratio)
paste0("The median speed increase for the ITS2 region was ", its2median, ". The 95% HDI interval was ", its2hdi[1], " to ", its2hdi[2])
