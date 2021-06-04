library(shiny)
library(leaflet)

fluidPage(
headerPanel(h1(strong("Restaurant Seat Capacity"))),

  tabsetPanel(
    
    # First tab
    tabPanel("Restaurant map",
      fluidPage(
        h4("The Location of Restaurant in the City of Melbourne in 2019"),
        h5("Click on the marker to view the indoor and outdoor seat capacity of the restaurant"),
        
        sidebarLayout(
          sidebarPanel(
            # Show all and clear Buttons
            actionButton("show_all", label = "Show all restaurants", style="width:150px"),
            actionButton("clear", label = "Deselect all", style="width:150px"),
            
            # Checkbox for user to select restaurant type
            h5(strong("Restaurant type")),
            checkboxInput("caf_res", "Cafes and Restaurants", value = TRUE),
            checkboxInput("pub", "Pubs, Taverns and Bars", value = TRUE),
            checkboxInput("takeaway", "Takeaway Food Services", value = TRUE),
            
            # Sidebar width
            width=4),
        mainPanel(
          leafletOutput("res_map", height=500)
        )
        )
      )
    ),
    
    # Second tab
    tabPanel("Change in Seat Capacity",
      fluidPage(
        h4("The Change in Seat Capacity From 2002 to 2019"),
        sidebarLayout(
          sidebarPanel(
            
            # For user to select year
            sliderInput("year", "Year", min=2002, max=2019, value=1, sep="", animate=TRUE),
            
            # For user to select type of restaurant to display
            radioButtons("type", "Restaurant type", 
                         choices = list("All" = "all",
                                        "Cafes and Restaurants" = "caf_res", 
                                        "Pubs, Taverns and Bars" = "pub",
                                        "Takeaway Food Services" = "takeaway"),
                         selected = "all"),
            
            # For user to select type of seating
            radioButtons("type", "Restaurant type", 
                         choices = list("All" = "all",
                                        "Indoor" = "indoor", 
                                        "Outdoor" = "outdoor"),
                         selected = "all")
            ),
          mainPanel(
            "Display visualisation" #TODO: add visualisation
          )
        )
      )
    )))