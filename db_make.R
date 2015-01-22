# Load relevant packages
require(dplyr)
library(sqldf)

# Loading used data files from USDA site (http://ndb.nal.usda.gov/)
# Abbreviated data file used in conjunction with complete data set to create db
DESCRIPTION <- "data/FOOD_DES.txt"
FD_GRP <- "data/FD_GROUP.txt"
ABBRV <- "data/ABBREV.txt"

# Column names scraped from USDA documentation file and stored in CSV
# (http://www.ars.usda.gov/sp2UserFiles/Place/80400525/Data/SR27/sr27_doc.pdf)
CLNAMES <- "data/col_names.csv"

# Read data into tables
DES <- read.table(DESCRIPTION, sep = "^", header=FALSE, quote = "~", stringsAsFactors=FALSE)
FD_GROUP <- read.table(FD_GRP, sep = "^", header=FALSE, quote = "~", stringsAsFactors=FALSE)
ABBREV <- read.table(ABBRV, sep = "^", header=FALSE, quote = "~", stringsAsFactors=FALSE)
COL_NAMES <- read.csv(CLNAMES, stringsAsFactors=FALSE)

# Assigning column names for loaded tables
## Food descriptions
DES_NAME <- c("NDB_NO", "FdGrp_Cd", "Long_Desc", "Shrt_Desc", 
              "ComName", "ManufacName", "Survey", "Ref_desc", 
              "Refuse", "SciName", "N_Factor", "Pro_Factor", 
              "Fat_Factor", "CHO_Factor")
colnames(DES) <- DES_NAME

## Food groups
FD_GRP_NAME <- c("FdGrp_Cd", "FdGrp_Desc")
colnames(FD_GROUP) <-FD_GRP_NAME

## Abbreviated  data file
colnames(ABBREV) <- colnames(COL_NAMES)

# Merging tables
## Primarily to add "Food Group" data to the abbreviated data set
DES$FdGrp_Name <- FD_GROUP$FdGrp_Desc[match(DES$FdGrp_Cd,
                                            FD_GROUP$FdGrp_Cd)]
ABBREV$FdGrp_Name <- DES$FdGrp_Name[match(ABBREV$NDB_No,
                                          DES$NDB_NO)]

# Filtering and rearranging columns
ABBREV_FILT <- ABBREV %>%
  select(-c(NDB_No, GmWt_1:Refuse_Pct))
ABBREV_FILT <- ABBREV_FILT[,c(48, 1:47)]

# Adding column names
colnames(ABBREV_FILT) <- c("FoodGroup",
                       "FoodName",
                       "Water",
                       "Energy",
                       "Protein",
                       "Lipid_Tot",
                       "Ash",
                       "Carbohydrt",
                       "Fiber_TD",
                       "Sugar_Tot",
                       "Calcium",
                       "Iron",
                       "Magnesium",
                       "Phosphorus",
                       "Potassium",
                       "Sodium",
                       "Zinc",
                       "Copper",
                       "Manganese",
                       "Selenium",
                       "Vit_C",
                       "Thiamin",
                       "Riboflavin",
                       "Niacin",
                       "Panto_Acid",
                       "Vit_B6",
                       "Folate_Tot",
                       "Folic_Acid",
                       "Food_Folate",
                       "Folate_DFE",
                       "Choline_Tot",
                       "Vit_B12",
                       "Vit_A_IU",
                       "Vit_A_RAE",
                       "Retinol",
                       "Alpha_Carot",
                       "Beta_Carot",
                       "Beta_Crypt",
                       "Lycopene",
                       "LutZea",
                       "Vit_E",
                       "Vit_D_micro",
                       "Vit_D_IU",
                       "Vit_K",
                       "FA_Sat",
                       "FA_Mono",
                       "FA_Poly",
                       "Cholestrl")

# Converting data to UTF-8 to make table JSON friendly
for (j in seq_len(ncol(ABBREV_FILT))) {
  if (class(ABBREV_FILT[, j]) == "factor") {
    levels(ABBREV_FILT[, j]) <- iconv(levels(ABBREV_FILT[, j]), to = "UTF-8")
  }
}

convertUTF <- function(x) {
  temp <- colnames(x)
  store <- c()
  for(i in 1:length(temp)) {
    store[i] <- iconv(temp[i], to = "UTF-8")
  }
  store
}
colnames(ABBREV_FILT) <- convertUTF(ABBREV_FILT)

# Create SQLite database to store data in
db <- dbConnect(SQLite(), dbname="Food.sqlite")
sqldf("attach 'Food.sqlite' as new")

# Write data to SQLite database
dbWriteTable(conn = db, name = "Food", value = ABBREV_FILT, row.names = FALSE)

#Disconnect from database and remove unused files
dbDisconnect(db)
rm(ABBREV, ABBREV_FILT, DES, FD_GROUP, COL_NAMES)
