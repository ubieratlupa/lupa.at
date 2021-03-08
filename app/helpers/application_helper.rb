module ApplicationHelper
  def nl2br(str)
    html_escape(str).gsub(/\n/,"<br>\n").gsub(/(https?:\/\/)(\S+)[,;<]?/,"<a href=$1$2>$2</a>").html_safe
  end
  
  def unumlaut(str)
    replacements = {
      "ä"=>"ae",
      "Ä"=>"Ae",
      "Ü"=>"Ue",
      "Ö"=>"Oe",
      "ö"=>"oe",
      "ü"=>"ue",
      "ß"=>"ss",
      "é"=>"e"
    }
    str.gsub(Regexp.union(replacements.keys),replacements).gsub(/\W+/,"_")
  end
  
  def pretty_monument_count(count)
    count == 1 ? "#{count} Steindenkmal" : "#{count} Steindenkmäler"
  end
end
