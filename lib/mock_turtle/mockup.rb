class MockTurtle::Mockup

  require 'nokogiri'

  attr_reader :templates, :path, :source

  def initialize(source, path)
    @source, @path = source, path
  end

  def templates
    @templates || begin
      prepare
      @templates
    end
  end

private

  def prepare
    root = Nokogiri::HTML(@source)

    @templates = {}

    root.xpath('//*[@data-remove]').unlink
    root.xpath('//*[@data-unwrap]').each do |node|
      node.replace node.children
    end

    root.xpath('//*[@data-partial]').each do |node|
      name = node['data-partial'].to_s
      node.delete('data-partial')
      @templates[name] = node
    end

    base = root.dup
    base.xpath('//*[@data-partial]').unlink

    root.xpath('//*[@data-view]').each do |node|
      name = node['data-view'].to_s

      view = base.dup
      view.xpath("//*[@data-view!=#{name.inspect}]").unlink
      view.xpath("//*[@data-view]").each do |node|
        node.delete('data-view')
      end

      @templates[name] = view
    end

  end

end