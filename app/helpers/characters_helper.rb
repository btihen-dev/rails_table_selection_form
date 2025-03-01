module CharactersHelper
  def sort_link(column:)
    next_direction = column == params[:column] ? future_direction : 'asc'
    display_arrow = params[:column] == column ? current_sort_arrow : tag.i(class: "bi bi-arrow-down-up")
    link_to_params = params.permit!.to_h.merge(column: column, direction: next_direction)
    link_to(
      display_arrow.html_safe,
      characters_path(link_to_params),
      # characters_path(column: column, direction: next_sort),
      data: { turbo_action: 'replace' }
    )
  end

  def future_direction
    case params[:direction]
    when 'none' then 'asc'
    when 'asc' then 'desc'
    else 'none'
    end
  end

  def current_sort_arrow
    case params[:direction]
    when 'asc' then tag.i(class: "bi bi-arrow-up")
    when 'desc' then tag.i(class: "bi bi-arrow-down")
    else tag.i(class: "bi bi-arrow-down-up")
    end
  end
end
