 # Load necessary packages
library(ggvis)
library(shiny)

# Load variables defined in global.r file
source("global.r")

# Beginning of content
shinyUI(navbarPage("What's in Your Food?", id = "nav",
  tabPanel("Interactive Graph",
    fluidPage(
      tags$head(
        # Load Custom CSS, fonts, and custom jQuery function for slide toggling documentation effect
        includeCSS("styles.css"),
        tags$link(rel = "stylesheet", type = "text/css", href = "http://fonts.googleapis.com/css?family=Open+Sans:400,300,600,700,800"),
        includeScript("slideToggle.js")
      ),
      fluidRow(
        column(3, wellPanel(id = "clickme", p("Hide Documentation")))),
      fluidRow(
        column(6,
         wellPanel(class = "documentation",
            h4("Documentation"),
            p("Ever wonder how much dietary fiber is in your burrito? Ever wonder what you should eat to maximize your protein intake while minimizing your fat intake?"),
            p("You can use this app to answer those questions and more. Use the filters and search functions on the left side panel, and the graph will update to show the foods that meet that criteria."),
            p("Each point on the chart is a separate food item. Hover over a point to see its name, food group, and selected stats.")
          )
        ),
        column(6,
          wellPanel(class = "documentation",
            h4("Sources"),
            p("Nutrient Data: Pulled from the ", tags$a("USDA National Nutrient Database for Standard Reference", href = "http://ndb.nal.usda.gov/"), ", cleaned, and stored in SQLite database for quick access."),
            p("Nutrient Definitions can be found in the " ,tags$a("USDA's Related Documentation.", href = "http://www.ars.usda.gov/sp2UserFiles/Place/80400525/Data/SR27/sr27_doc.pdf")),
            p("Packages used: ggVis, RSQLite, dplyr, Shiny")
          )
        )
      ),
      fluidRow(width = "auto",
        column(3,
          wellPanel(id = "controls",
            h4("Filter"),
            sliderInput("calories", "Calories per 100g",
                        0, 1000, value = c(0, 900), step = 10),
            selectInput("foodgroup", "Filter by Food Groups",foodgroup_names, multiple = TRUE, selectize = TRUE),
            selectInput("xvar", "X-axis Nutrient", axis_vars, selected = "Energy"),
            selectInput("yvar", "Y-axis Nutrient", axis_vars, selected = "Water"),
            textInput("keyword", "Food Name Contains (e.g. Apple)")
          ),
          wellPanel(id = "counter",
            # Still trying to make this come out on one line without fudging around with the HTML output file...one of these days...
            HTML(paste(tags$b(textOutput("n_food")), " out of ", tags$b("8618"), " foods selected.", tags$br(), tags$b(textOutput("percent_food")), sep = ""))
          )
        ),
        column(9,
          ggvisOutput("plot1")
        )
      )
    )
  ),
  tabPanel("Food Explorer",
    titlePanel("Food Explorer"),
    fluidRow(
      column(6, selectInput("mychooser", "Filter by Food Groups",foodgroup_names, multiple = TRUE, selectize = TRUE))
    ),
    tags$hr(),
    dataTableOutput("foodtable")
  ),
  tags$hr(), 
  p("A Shiny Production by Johannes Rebane", a("(Source Code)", href = "https://github.com/jrebane/"),
          align = "right")
))