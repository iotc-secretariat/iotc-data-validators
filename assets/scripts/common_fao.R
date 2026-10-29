
#fao_header
fao_header <- function(
    app_title = "Application",
    app_url = "#",
    logo_url = "https://design-system.fao.org/images/logo/fao-logo-three-lines.svg",
    right_content = NULL
) {
  
  tags$header(
    class = "navbar navbar-expand-lg navbar-dark app-navbar sticky-top",
    style = "padding-bottom: 10px;",
    tags$div(
      class = "container-fluid flex-wrap flex-lg-nowrap",
      `aria-label` = "Main navigation",
      
      # Brand
      tags$a(
        class = "navbar-brand p-0 me-0 me-lg-4 d-flex align-items-center",
        href = app_url,
        style = "display:flex;",
        tags$img(
          src = logo_url,
          height = "40px",
          alt = "FAO"
          # style = paste(
          #   "padding-right: 10px;"
          # )
        ),
        
        tags$span(
          app_title,
          class = "ms-3 ps-3 fw-semibold text-uppercase vertical-sep-header"
        )
      ),
      
      # Right side content
      tags$div(
        class = "d-flex align-items-center gap-2 ms-auto",
        
        right_content
      )
    )
  )
}

#fao_footer
fao_footer <- function(
    copyright_year = format(Sys.Date(), "%Y")
) {
  
  tags$footer(
    class = "footer-dashboard mt-auto py-4 border-top",
    
    tags$div(
      class = "container-fluid",
      
      tags$div(
        class = "row align-items-center",
        
        # Left section
        tags$div(
          class = "col-md-12",
          
          tags$div(
            class = "text-md-end mt-3 mt-md-0",
            style = "float:left;",
            
            tags$a(
              href = "https://www.fao.org/contact-us/en/",
              target = "_blank",
              class = "text-decoration-none me-3",
              "Contact us"
            ),
            
            tags$a(
              href = "https://www.fao.org/about/policies/en/",
              target = "_blank",
              class = "text-decoration-none me-3 vertical-sep-footer",
              "Terms and Conditions"
            ),
            
            tags$a(
              href = "https://www.fao.org/contact-us/data-protection-and-privacy/en/",
              target = "_blank",
              class = "text-decoration-none vertical-sep-footer",
              "Data protection and privacy"
            ),
            
            tags$a(
              href = "https://www.fao.org/contact-us/scam-alert/en/",
              target = "_blank",
              class = "text-decoration-none vertical-sep-footer",
              "Scam Alert"
            ),
            
            tags$a(
              href = "https://www.fao.org/audit-and-investigations/reporting-misconduct/en/",
              target = "_blank",
              class = "text-decoration-none vertical-sep-footer",
              "Report Misconduct"
            ),
            
            tags$a(
              href = "https://www.fao.org/transparency/en",
              target = "_blank",
              class = "text-decoration-none vertical-sep-footer",
              "Transparency and Accountability"
            )
            
          ),
          
          tags$div(
            style = "float:right;",
            tags$span(
              class = "ms-3 text-muted small",
              sprintf(
                "\u00A9 %s FAO",
                copyright_year
              )
            )
          )
        )
      )
    )
  )
}