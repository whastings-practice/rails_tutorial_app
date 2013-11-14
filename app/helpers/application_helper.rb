module ApplicationHelper

  BASE_TITLE = 'Rails Tutorial App'

  # Returns the full title on a per-page basis.
  def full_title(page_title)
    return BASE_TITLE if page_title.empty?
    "#{BASE_TITLE} | #{page_title}"
  end

end
