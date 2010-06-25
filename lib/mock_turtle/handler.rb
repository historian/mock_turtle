require 'action_view/template/resolver'

class ActionView::PathResolver
  alias_method :query_without_mock_turtle, :query

  def query(path, exts, formats)
    templates = query_without_mock_turtle(path, exts, formats)
    if template = MockTurtle.templates[path]
      templates = [template] + templates
    end
    templates
  end
end

class MockTurtle::Handler < ActionView::Template::Handlers::ERB

  def compile(template)
    fragment = template.fragment.dup
    erb_tags = []

    fragment.xpath('.//*[@data-repeat]').each do |node|
      code  = node['data-repeat']
      node.delete('data-repeat')

      local = node['data-as'] || 'object'
      node.delete('data-as')

      node.before "--BOUNDRY-#{erb_tags.size}--"
      erb_tags << %{<%- (#{code}).each do |#{local}| -%>}

      node.after "--BOUNDRY-#{erb_tags.size}--"
      erb_tags << %{<%- end -%>}
    end

    fragment.xpath('.//*[@data-render]').each do |node|
      partial = node['data-render']

      code  = %{render :partial => #{partial.inspect}}
      if node['data-locals']
        code += %{, :locals => { #{node['data-locals']} }}
      end

      node.replace "--BOUNDRY-#{erb_tags.size}--"
      erb_tags << %{<%= (#{code}) -%>}
    end

    fragment.xpath('.//*[@data-content]').each do |node|
      code  = node['data-content']
      node.delete('data-content')

      node.content = "--BOUNDRY-#{erb_tags.size}--"
      erb_tags << %{<%= (#{code}) -%>}
    end

    fragment.xpath('.//script[@type="text/ruby"]').each do |node|
      code  = node.text.to_s

      node.replace "--BOUNDRY-#{erb_tags.size}--"
      erb_tags << %{<%- (#{code}) -%>}
    end

    fragment.xpath('.//form[@for]').each do |node|
      code = node['for'].to_s

      node.before "--BOUNDRY-#{erb_tags.size}--"
      erb_tags << %{<%= form_for(#{code}) do -%>}

      node.after "--BOUNDRY-#{erb_tags.size}--"
      erb_tags << %{<%- end -%>}

      node.after node.children
      node.unlink
    end

    fragment.traverse do |node|
      node.keys.each do |data_attr|
        next unless data_attr =~ /^data-attr-(.*)$/
        attr  = $1
        code  = node[data_attr]

        node.delete(data_attr)
        node[attr] = "--BOUNDRY-#{erb_tags.size}--"
        erb_tags << %{<%= (#{code}) %>}
      end
    end

    fragment_str = fragment.to_s
    src = "<%-" + ("\n" * fragment.line) + "-%>" + fragment_str
    src.gsub! /--BOUNDRY-(\d+)--/ do |m|
      erb_tags[$1.to_i]
    end

    super(ActionView::Template.new(src, template.identifier, template.handler,
      :virtual_path => template.virtual_path, :format => template.formats.first))
  end

end