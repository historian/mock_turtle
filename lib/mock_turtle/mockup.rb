class MockTurtle::Mockup

  require 'nokogiri'

  attr_reader :templates, :path, :source

  def initialize(source, path)
    @source, @path = source, path
  end

  def compile!
    prepare
    build_templates
  end

private

  def prepare
    doc = Nokogiri::HTML(@source)

    @nodes = {}

    doc.traverse do |node|
      if node.text? and node.parent.name != 'pre'
        node.content = node.to_s.gsub(/[ \t]+/, ' ')
      end
    end

    doc.xpath('//*[@data-remove]').each do |node|
      node.unlink if node['data-remove'].blank?
    end

    doc.xpath('//*[@data-content]').each do |node|
      node.children.each { |c| c.unlink }
    end

    doc.xpath('//*[@data-partial]').each do |node|
      name = node['data-partial'].to_s
      node.delete('data-partial')
      @nodes[name] = node
      node.unlink
    end

    already_yielding = false
    doc.xpath('//*[@data-view]').each do |node|
      name = node['data-view'].to_s
      node.delete('data-view')
      @nodes[name] = node
      unless already_yielding
        node.before(%Q{<script type="text/ruby">concat(yield)</script>})
        already_yielding = true
      end
      node.unlink
    end

    base = File.basename(@path).split('.', 2).first
    @nodes["layouts/#{base}"] = doc.root
  end

  def build_templates
    @templates = {}
    handler  = MockTurtle::Handler
    format   = @path.split('.')[-2].to_sym

    @nodes.each do |path, node|
      template = MockTurtle::Template.new(
        @source, node, @path+"##{path}", handler,
        :virtual_path => path, :format => format)
      @templates[path] = template
    end
  end

end