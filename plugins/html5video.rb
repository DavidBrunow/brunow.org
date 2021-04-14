def html5video(src, args = {})
  return '' if src.empty?
  
  src = @config[:cdn_url] + src if src =~ %r{^/media/}
  
  width = args[:width] || 640
  aspect = args[:aspect] || ''

  if aspect =~ /^\s*([\d.]+)[x:]([\d.]+)\s*$/
    scale = $2.to_f / $1.to_f
  else
    scale = 3.0 / 4.0
  end
  
  %(<video src="#{src}" width="#{width}" height="#{(width * scale).to_i}" controls="controls"> <source src="#{src}" type="video/mp4">Whoa! Your browser does not support the playback of this video.<br /> <br />Try downloading it here instead: <a href="#{src}">#{src}</a></video>)
end

