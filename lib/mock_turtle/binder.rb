module MockTurtle::Binder
  class SkipMember < RuntimeError ; end

  class Proxy
    include MockTurtle::Binder

    def initialize(base, scope)
      @__base_context = base
      @__scope = scope
    end

    def html_safe
      @__scope
    end

    def to_s
      @__scope.to_xhtml
    end
    alias_method :inspect, :to_s

    def _base_context
      @__base_context
    end

    def __scope
      @__base_context.__scope
    end

    def __scope=(scope)
      @__base_context.__scope = scope
    end

  end

  attr_accessor :__scope

private

  def _bind_document(document, &block)
    _scoped(document) do
      @__root = @__scope
      yield
    end

    Proxy.new(_base_context, @__root)
  ensure
    @__scope = nil
  end

  def _scoped(node)
    case node
    when Nokogiri::XML::Document
      list = Nokogiri::XML::NodeSet.new(node, [node.root])
    when Nokogiri::XML::Node
      list = Nokogiri::XML::NodeSet.new(node.document, [node])
    when Nokogiri::XML::NodeSet
      list = node
    else
      raise "invalid type #{node.class}"
    end

    __old_scope, self.__scope = self.__scope, list
    yield
  ensure
    self.__scope = __old_scope
  end

  def _base_context
    self
  end

public

  def find_css(*rules, &block)
    list = @__scope.css(*rules)
    _scoped(list, &block) if block
    Proxy.new(_base_context, list)
  end

  def find_xpath(*rules, &block)
    list = @__scope.xpath(*rules)
    _scoped(list, &block) if block
    Proxy.new(_base_context, list)
  end

  if $KCODE == 'u' or $KCODE == 'UTF8'
    alias_method '§', :find_css
  end

  def this
    Proxy.new(_base_context, @__scope)
  end

  def each(&block)
    @__scope.each do |node|
      _scoped(node, &block)
    end

    self
  end

  def attr(name, value=nil)
    if value
      return self if @__scope.empty?
      @__scope.attr(name.to_s, value.to_s)
      self
    else
      values = @__scope.attr(name.to_s, value)
      (@__scope.size == 1 ? values.first : values)
    end
  end

  %w( value rel id name alt title ).each do |attr|
    m = attr.gsub(/[^a-z0-9_]+/, '_')
    class_eval %{
      def #{m}(value=nil)            # def src(value=nil)
        attr(#{attr.inspect}, value) #   attr('src', value)
      end                            # end
      alias_method :#{m}=, :#{m}     # alias_method :src=, :src
    }
  end

  %w( src href action ).each do |attr|
    m = attr.gsub(/[^a-z0-9_]+/, '_')
    class_eval %{
      def #{m}(value=nil)            # def src(value=nil)
        if value                     #   if value
          value = _base_context.url_for(value) #     value = _base_context.url_for(value)
        end                          #   end
        attr(#{attr.inspect}, value) #   attr('src', value)
      end                            # end
      alias_method :#{m}=, :#{m}     # alias_method :src=, :src
    }
  end

  def remove_class(klass)
    @__scope.remove_class(klass)
    self
  end

  def add_class(klass)
    @__scope.add_class(klass)
    self
  end

  def remove
    @__scope.unlink
    self
  end

  def inner_text(text=nil)
    if text
      return self if @__scope.empty?
      text = @__scope.first.encode_special_chars(text)
      @__scope.each { |node| node.send :native_content=, text }
      self
    else
      @__scope.inject('') do |memo, node|
        memo.concat node.text.to_s
        memo
      end
    end
  end

  def inner_html(html=nil)
    if html
      return self if @__scope.empty?
      @__scope.each do |node|
        node.inner_html = html
      end
      self
    else
      @__scope.inject('') do |memo, node|
        memo.concat node.inner_html
        memo
      end
    end
  end

  def outer_text(text=nil)
    if text
      return self if @__scope.empty?
      text = @__scope.first.encode_special_chars(text)
      @__scope.each do |node|
        node.replace text
      end
      self
    else
      @__scope.inject('') do |memo, node|
        memo.concat node.text.to_s
        memo
      end
    end
  end

  def outer_html(html=nil)
    if html
      return self if @__scope.empty?
      @__scope.each do |node|
        node.replace html
      end
      self
    else
      @__scope.inject('') do |memo, node|
        memo.concat node.to_s
        memo
      end
    end
  end

  alias_method :inner_text=, :inner_text
  alias_method :inner_html=, :inner_html
  alias_method :outer_text=, :outer_text
  alias_method :outer_html=, :outer_html

  def for(collection)
    return self if @__scope.empty?
    nodes = []
    prototype = @__scope.first
    collection.each do |member|
      begin
        node = prototype.dup
        prototype.before node
        _scoped(node) do
          yield(member)
        end
        nodes << node
      rescue SkipMember
        node.unlink
      end
    end

    Proxy.new(_base_context,
      Nokogiri::XML::NodeSet.new(@__scope.document, nodes))
  ensure
    @__scope.unlink
  end

end
