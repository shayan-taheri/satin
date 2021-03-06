#' Create sidebar
#'
#' @param config Dashboard configuration read from _site.yml
#' @param data_global Global data passed to the sidebar.
#' @param display_page A function that returns a boolean indicating if a page
#'   should be displayed in the sidebar.
#' @export
st_create_sidebar <- function(config, data_global,
    display_page = function(x){TRUE}){
  s1 <- config$sidebar %>%
    purrr::map(~ {
      if (!display_page(.$text)){
        return(NULL)
      }
      if (length(.$menu) >= 1){
          .text <- .x$text
          .startExpanded <- if (is.null(.x$startExpanded)) {
              FALSE
           } else {
             .x$startExpanded
           }
          .icon=   icon(.x$icon)
          .$menu %>%
             map(~ {
               if (!display_page(.$text)) {
                 return(NULL)
               }
               if (!is.null(.$href)){
                 return(menuSubItem(.$text, href = .$href))
               }
               tabName = make_tab_name(.)
               if (.$text != "") {
                   menuSubItem(.$text, tabName = tabName)
               } else {
                 fun_ui_sidebar <- match.fun(paste0(.$module, '_ui_sidebar'))
                 fun_ui_sidebar(tabName)
               }
             }) %>%
             append(list(text = .text, icon = .icon, startExpanded = .startExpanded)) %>%
             do.call(menuItem, .)
      } else {
        if (!is.null(.$href)) {
          menuItem(.$text, href = .$href, icon = icon(.$icon))
        } else {
          menuItem(.$text, tabName = make_tab_name(.), icon = icon(.$icon))
        }
      }
    }) %>%
    append(list(id = 'smenu')) %>%
    do.call(sidebarMenu, .)
  # COMMENT OUT CONDITIONAL PANELS FOR NOW ---
  # s2 <- create_conditional_panels(config)
  # tagList(s1, s2)
  s1
}

# Create conditional panels
create_conditional_panels <- function(config){
  modules <- get_modules(config)
  modules %>%
    purrr::map(~ {
      tabName = make_tab_name(.)
      if (!is.null(.$module)){
        .fun <- purrr::possibly(match.fun, NULL)(
          paste0(.$module, "_ui_sidebar")
        )
        if (!is.null(.fun)){
          conditionalPanel(
            sprintf("input.smenu == '%s'", tabName),
            .fun(tabName)
          )
        }
      }
    }) %>%
    tagList()
}
