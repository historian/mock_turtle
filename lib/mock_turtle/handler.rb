class MockTurtle::Handler

  include ActionView::Template::Handlers::Compilable

  def compile(template)
    if template.virtual_path.include?('layouts')
      %{ _bind_document(yield()) do ; ( %s
        ) end.to_s } % [
        template.source
      ]
    else
      src = %{
        unless MockTurtle::Binder === self              ;
          extend MockTurtle::Binder                     ;
        end                                             ;
        __document = MockTurtle.templates[%s].dup       ;
        raise 'Missing document %s' unless __document   ;
        _bind_document(__document) do                   ;
          ( %s
        ) end
      }.gsub(";\n", ";")

      src % [
        template.virtual_path.inspect,
        template.virtual_path.inspect,
        template.source
      ]
    end
  end

end