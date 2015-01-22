## Include Required Libraries
library(ggvis)
library(dplyr)
library(RSQLite)

# Setting up access to database tables when app starts
db <- src_sqlite("Food.sqlite")
food <- tbl(db, "Food")

# Start the session!
shinyServer(function(input, output, session) {
# Filtering foods based on user inputs
food_filtered <- reactive({
  # Storing input as variables so it can be used with the filter function
  caloriesmin <- input$calories[1]
  caloriesmax <- input$calories[2]
  # Apply calorie filter
  df <- food %>%
    filter(
      Energy >= caloriesmin,
      Energy <= caloriesmax)
  # Return as data frame
  df <- as.data.frame(df)
  # Food search functionality
  if (!is.null(input$keyword) && input$keyword != "") {
    keyword <- toupper(input$keyword)
    df <- df %>% filter(grepl(keyword,FoodName))
  }
  # Filtering food groups
  df <- df %>% filter(is.null(input$foodgroup) | FoodGroup %in% input$foodgroup)
  df
})

# Function for generating tooltip text (Inspired by Shiny's Movie Explorer Example)
food_tooltip <- function(x) {
  if (is.null(x)) return(NULL)
  if (is.null(x$FoodName)) return(NULL)
  # Pick out the food with the same name
  all_food <- isolate(food_filtered())
  foods <- all_food[all_food$FoodName == x$FoodName, ]
  # Pull proper names of axis variables
  xvar_name <- names(axis_vars)[axis_vars == input$xvar]
  yvar_name <- names(axis_vars)[axis_vars == input$yvar]
  # Put it all together, and whaddaya got?
  paste0("<b>Food: </b>", foods$FoodName, "<br>",
         "<b>Food group:</b> ", foods$FoodGroup, "<br>",
         "<b>",xvar_name, ": </b>", format(foods[input$xvar], big.mark = ",", scientific = FALSE), "<br>",
         "<b>",yvar_name, ": </b>", format(foods[input$yvar], big.mark = ",", scientific = FALSE)
  )
}

# A reactive expression with the ggvis plot
vis <- reactive({
  # Lables for axes
  xvar_name <- names(axis_vars)[axis_vars == input$xvar]
  yvar_name <- names(axis_vars)[axis_vars == input$yvar]
  # Preparing inputs for use in graph
  xvar <- prop("x", as.symbol(input$xvar))
  yvar <- prop("y", as.symbol(input$yvar))

  food_filtered %>%
    # Creating the graph! Weeeee!
    ggvis(x = xvar, y = yvar) %>%
    layer_points(fill = ~factor(FoodGroup), size := 50, size.hover := 200,
                 fillOpacity := 0.2, fillOpacity.hover := 0.7,
                 key := ~FoodName) %>%
    add_tooltip(food_tooltip, "hover") %>%
    add_axis("x", title = xvar_name) %>%
    add_axis("y", title = yvar_name) %>%
    add_legend(scales = "fill", title = "Food Groups") %>%
    set_options(width = 500, height = 500)
})

# Binding the Graph
vis %>% bind_shiny("plot1")

# Creating the outputs for the "Counter" section
output$n_food <- renderText({ nrow(food_filtered()) })
output$percent_food <- renderText({paste0("(",round(nrow(food_filtered())/86.18, 2),"%)")})

## Data Explorer ###############################################
# Creating a basic, non-filtered data frame for use on this page
food_filtered2 <- reactive({
  df <- food
  df <- as.data.frame(df)
  df
})
# Filtering the table based on user inputs
output$foodtable <- renderDataTable({
  food_filtered2() %>%
    filter(is.null(input$mychooser) | FoodGroup %in% input$mychooser)
})
})