module ApplicationHelper
  def nl2br(str)
    html_escape(str).gsub(/\n/,"<br>\n").html_safe
  end
end
