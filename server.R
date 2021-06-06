library(shiny)
library(leaflet)
library(dplyr)
library(ggplot2)

# Manage the data to display in the first tab
# Read data
seat_data <- read.csv("clean_restaurants_seats.csv", header = TRUE)

# Separate each type of restaurant
res_data <- filter(seat_data, res_type == "Cafes and Restaurants")
pub_data <- filter(seat_data, res_type == "Pubs, Taverns and Bars")
take_data <- filter(seat_data, res_type == "Takeaway Food Services")


# SERVER
function(input, output, session){
  
  # FIRST TAB
  # Responsive checkboxes
  # When click deselect all of the checkbox
  # Reference: https://stackoverflow.com/a/24269691
  observe({
    if (input$clear > 0){
      updateCheckboxInput(session = session, inputId = "caf_res_c", value = FALSE)
      updateCheckboxInput(session = session, inputId = "pub_c", value = FALSE)
      updateCheckboxInput(session = session, inputId = "takeaway_c", value = FALSE)
    }
  })
  
  # When click Show all
  observe({
    if (input$show_all > 0){
      updateCheckboxInput(session = session, inputId = "caf_res_c", value = TRUE)
      updateCheckboxInput(session = session, inputId = "pub_c", value = TRUE)
      updateCheckboxInput(session = session, inputId = "takeaway_c", value = TRUE)
    }
  })
  
  # Create the map marker styles
  # For cafes and restaurants
  caf_icons <- awesomeIcons(
    icon =  "fa-cutlery",
    iconColor = "#FFFFFF",
    library = "fa",
    markerColor = "lightred"
  )
  
  # For pubs, taverns and bars
  pub_icons <- awesomeIcons(
    icon =  "fa-glass",
    iconColor = "#FFFFFF",
    library = "fa",
    markerColor = "cadetblue"
  )
  
  # For takeaway food services
  take_icons <- awesomeIcons(
    icon =  "fa-shopping-bag",
    iconColor = "#FFFFFF",
    library = "fa",
    markerColor = "lightgreen"
  )
  
  
  # Map output
  output$res_map<- renderLeaflet({
    map <- leaflet(options = leafletOptions(minZoom = 11)) %>% 
      setView(lng = 144.9615, lat = -37.8156, zoom = 13) %>%
      addTiles()%>%
      
      # Set map boundery
      setMaxBounds(lng1 = 144.8615
                   ,lat1 = -37.9156
                   ,lng2 = 145.0615
                   ,lat2 = -37.7156) %>%
      # Legend
      addLegend("bottomright", 
                colors =c("#eb7d7f", "#436978",  "#bbf970"),
                labels= c("Cafes and Restaurants",
                          "Pubs, Taverns and Bars", 
                          "Takeaway Food Services"), opacity = 1)
  })
  
  # Display cafes and restaurants locations
  # References: https://stackoverflow.com/a/37435428
  # https://stackoverflow.com/a/43596736
  # https://stackoverflow.com/a/41961038
  observe({if(input$caf_res_c){
    leafletProxy("res_map", data = res_data) %>% 
      addAwesomeMarkers(~lon, ~lat, group = "rest_gr", 
                        icon = caf_icons, 
                        popup = ~as.character(description), 
                        label = ~as.character(name),
                        clusterOptions = markerClusterOptions(disableClusteringAtZoom=18))
  }else{
    leafletProxy("res_map") %>%
      clearGroup(group = "rest_gr")
  }
  })
  
  # Display pubs, taverns and bars locations
  observe({if(input$pub_c){
    leafletProxy("res_map", data = pub_data) %>% 
      addAwesomeMarkers(~lon, ~lat, group = "pub_gr", 
                        icon = pub_icons, 
                        popup = ~as.character(description), 
                        label = ~as.character(name),
                        clusterOptions = markerClusterOptions(disableClusteringAtZoom=18))
  }else{
    leafletProxy("res_map") %>%
      clearGroup(group = "pub_gr")
  }
  })
  
  # Display takeaway food services locations
  # Display pubs, taverns and bars locations
  observe({if(input$takeaway_c){
    leafletProxy("res_map", data = take_data) %>% 
      addAwesomeMarkers(~lon, ~lat, group = "take_gr", 
                        icon = take_icons, 
                        popup = ~as.character(description), 
                        label = ~as.character(name),
                        clusterOptions = markerClusterOptions(disableClusteringAtZoom=18))
  }else{
    leafletProxy("res_map") %>%
      clearGroup(group = "take_gr")
  }
  })
  
  # SECOND TAB
  output$seat_change <- renderPlot({
    # TODO: create bar graph
  })
  
}